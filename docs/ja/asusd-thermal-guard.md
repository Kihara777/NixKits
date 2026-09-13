# asusd-thermal-guard

[中文](../zh/asusd-thermal-guard.md) | [English](../en/asusd-thermal-guard.md) | 日本語  | [偽中国語](../pcn/asusd-thermal-guard.md)

温度監視ウォッチドッグ —— 温度を抑え込めなくなったら**プラットフォームプロファイルを自動的に降格**し、冷却後に復帰させます。

## 基本情報

| 項目 | 値 |
|------|-----|
| アップストリーム | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl)（`asusd` デーモン） |
| モジュール | `nixosModules.asusd-thermal-guard` |
| 依存 | `services.asusd.enable = true` |
| 実装 | systemd timer + oneshot（常駐プロセスなし） |
| 注意 | 降格のみ。`profileCeiling` を超える昇格は行わない |

## なぜ必要か：ファン曲線は飽和する

ROG Flow Z13（Strix Halo）でローカル LLM 推論を実行中、**3 回連続で過熱シャットダウン**しました。
その調査過程そのものが、このモジュールが存在する理由です：

| 手順 | 観察 | 結論 |
|------|------|------|
| ① ファン曲線を確認 | 曲線は 80 °C で頭打ち（145/255 = 56%）、一方チップは 90–95 °C で動作 | 終点値を修正すると、温度は確かに低下した |
| ② 再びシャットダウン | ファンは**すでに 8800 RPM で全開**、温度は**85.4 °C のまま 28 分間**安定（90 サンプル、Δ = −0.3 °C） | 暴走した昇温ではなく、環境平衡点である |
| ③ 対照実験 | 曲線を「65 °C で全開」の過激版に変更 | **85.6 °C / 55 W —— 温和な曲線とまったく差がない** |

**結論：ファンが一度飽和すれば、曲線の形状はもう意味を持たない。**

```
温和な曲線 (80°C→255):  85.4 °C @ 52 W,  8700–8800 RPM
過激な曲線 (65°C→255):  85.6 °C @ 55 W,  8700–8800 RPM
```

どちらもファンはすでにハードウェア上限の 8800 RPM に達しており、温度も同一 ——
この筐体は全開でも約 55 W しか放熱できず、**これが物理的な限界**です。

したがって唯一有効なレバーは**消費電力を下げる**ことです。そして「どこまで下げれば安全か」は
機種・周囲温度・ほこりの堆積具合によって変わるため、より低い PPT を決め打ちするのは
保守的であると同時に硬直的です —— **動的な監視 + 超過時の降格**のほうが堅実です。

## 使い方

```nix
{
  imports = [ inputs.nixkits.nixosModules.asusd-thermal-guard ];

  services.asusd.enable = true;

  nixkits.asusd-thermal-guard = {
    enable = true;
    profileCeiling = "performance"; # 許可する最高プロファイル
    triggerTemp = 88;               # ≥ この温度で 1 段降格
    resumeTemp = 80;                # ≤ この温度が連続して満たされたときのみ復帰
    resumeSamples = 6;              # 連続サンプル数（ハンチング防止）
    interval = "10s";               # サンプリング周期
  };
}
```

### オプション

| オプション | 型 | デフォルト | 説明 |
|------|------|------|------|
| `enable` | bool | `false` | ウォッチドッグを有効化 |
| `profileCeiling` | enum | `"performance"` | 許可する最高プロファイル。ウォッチドッグは**この値を超えて昇格しない（降格のみ）** |
| `triggerTemp` | int | `90` | 降格を引き起こす温度（°C） |
| `resumeTemp` | int | `78` | 復帰を許可する温度しきい値（°C） |
| `resumeSamples` | int | `6` | `resumeTemp` を何回連続で下回ったら復帰するか |
| `interval` | str | `"10s"` | サンプリング周期 |

プロファイルの階段（低い順）：`quiet` → `balanced` → `performance`。
降格とは 1 段下げることです。すでに最低プロファイルにある場合は何も行いません。

> ⚠️ `triggerTemp` は `resumeTemp` より大きくなければなりません（モジュール内に assertion による検証があります）。
> そうでないと、しきい値付近で復帰と降格を繰り返します。

## 実装上の要点

### 1. hwmon は `name` で解決し、`hwmonN` を決め打ちしない

**実測では、同じマシンでも再起動後に番号が変わります**（`k10temp` 1→3、`asus` 9→8）。
番号を決め打ちしたスクリプトは、再起動後に必ず誤ったセンサーを読みます：

```bash
for d in /sys/class/hwmon/hwmon*/; do
  [ "$(cat "$d/name" 2>/dev/null)" = k10temp ] && echo "$d"
done
```

### 2. CPU と GPU の**大きいほう**を判定基準にする

どちらかが過熱すれば発火すべきです：

```
max(cpu_tctl, gpu_edge) >= triggerTemp
```

### 3. プロファイルの変更は `asusctl` で行い、sysfs へ直接書き込まない

`/sys/firmware/acpi/platform_profile` へは**書き込まないでください** ——
`asusd` は AC イベントのたびに自身の永続プロファイルに従って上書きします
（ログの `Setting Performance before EPP` がその証拠です）。
`asusctl profile set <プロファイル>` は asusd **自身の**プロファイルを変更するため、両者の意図が一致します。

### 4. ヒステリシス + 冷却カウント

降格直後に復帰を許すと、しきい値付近で切り替えを繰り返します。そこで復帰には
`resumeTemp` を**連続 N 回**下回ることを要し、一度でも超過すればカウントはゼロに戻されます。

## 検証

```bash
# ウォッチドッグのログ（10 秒ごとに 1 サンプル）
journalctl -u asusd-thermal-guard --since '5 min ago'
journalctl -u asusd-thermal-guard-resume --since '5 min ago'

# 現在有効なプロファイル
asusctl profile get

# 手動で 1 回実行（root が必要：状態は /run に書き込まれ、asusctl にも特権が要る）
sudo "$(systemctl show asusd-thermal-guard -p ExecStart --value | cut -d';' -f1 | awk '{print $1}')"
```

正常な出力は次のような形です：

```
cpu=85.1 gpu=86.0 max=86.0 current=performance
below trigger (88C)
```

発火時：

```
cpu=90.2 gpu=88.0 max=90.2 current=performance
OVERHEAT (90.2 C >= 88 C) — performance -> balanced
```

## `asusd-pd-profile` との関係

両者は補完的であり、同時に有効化できます：

| モジュール | 責務 |
|------|------|
| `asusd-pd-profile` | **給電方式**でプロファイルを選ぶ（PD / ネイティブ AC / バッテリー） |
| `asusd-thermal-guard` | **温度**でプロファイルを下げる（過熱時） |

ウォッチドッグは過熱時に**下方へ**調整するだけの役割であり、電源によるプロファイル選択の規則は変えません。
冷却後は `profileCeiling` が許す範囲へ復帰するだけで、勝手により高いプロファイルへ昇格することはありません。
