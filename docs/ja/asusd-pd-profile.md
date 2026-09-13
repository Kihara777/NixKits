# asusd-pd-profile

[中文](../zh/asusd-pd-profile.md) | [English](../en/asusd-pd-profile.md) | 日本語  | [偽中国語](../pcn/asusd-pd-profile.md)

給電方式に応じて ASUS のプラットフォームプロファイルを選択 —— **USB-C PD** と**ネイティブ／バレル型 AC** を区別し、`asusd` 自身の設定では表現できない第三の状態を補います。

## 基本情報

| 項目 | 値 |
|------|-----|
| アップストリーム | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl)（`asusd` デーモン） |
| モジュール | `nixosModules.asusd-pd-profile` |
| 依存 | `services.asusd.enable = true` |
| インターフェース | asusd D-Bus `xyz.ljones.Platform` + udev |
| 注意 | 常駐プロセスなし、ポーリングなし。udev イベントで起動する oneshot サービス |

## 解決する問題

`asusd` の `asusd.ron` には**プロファイルキーが 2 つしかありません**：

```ron
platform_profile_on_ac: Performance,
platform_profile_on_battery: Quiet,
```

**USB-C PD の分岐は存在しません。** したがって「PD 接続時は Balanced、バレル型電源接続時は Performance」
といったポリシーは設定では表現できません。

問題は ACPI 層が **AC 供給元を 1 つしか公開しない**ことです —— PD とバレル型充電は
どちらも `/sys/class/power_supply/AC0/online` 上で `1` となり、区別できないように見えます。

**しかしカーネルは USB-C PD を別個の供給元として公開しています。** 本モジュールはこれに基づいて区別します：

| シグナル | パス | PD オンライン時 |
|------|------|----------|
| Type-C ポートモード | `/sys/class/typec/port*/power_operation_mode` | `usb_power_delivery` |
| USB 型供給元 | `/sys/class/power_supply/*/`（`type` が `USB`） | `online` が `1` |

2 つの判定基準は互いに冗長であり、いずれも**汎用カーネル属性**を用いるため、
特定機種の UCSI 列挙順に依存しません。

## 使い方

```nix
{
  imports = [ inputs.nixkits.nixosModules.asusd-pd-profile ];

  services.asusd.enable = true;

  nixkits.asusd-pd-profile = {
    enable = true;
    pdProfile = "balanced";        # USB-C PD 給電時（デフォルト）
    nativeAcProfile = "performance"; # ネイティブ／バレル型 AC 給電時（デフォルト）
  };
}
```

バッテリー給電は**本モジュールでは処理しません** —— それは `platform_profile_on_battery` の責務であり、
本モジュールはバッテリー給電を検出すると即座に終了し、asusd との競合を避けます。

### オプション

| オプション | 型 | デフォルト | 説明 |
|------|------|------|------|
| `enable` | bool | `false` | 本モジュールを有効化 |
| `pdProfile` | enum | `"balanced"` | USB-C PD 給電時に選択するプロファイル |
| `nativeAcProfile` | enum | `"performance"` | ネイティブ／バレル型 AC 給電時に選択するプロファイル |

プロファイルは `quiet` / `balanced` / `performance` から選択できます。

## 実装上の要点

### 1. sysfs へ直接書き込まない

`/sys/firmware/acpi/platform_profile` へ**書き込まないでください** —— asusd は AC イベントのたびに
自身の AC プロファイルに従って再設定するため、外部からの書き込みは即座に上書きされます
（ログに `[DEBUG asusd::ctrl_platform] Setting Performance before EPP` が現れます）。

本モジュールは代わりに asusd **自身の**永続設定（`PlatformProfileOnAc`）へ書き込み、
両者の意図を一致させ、相互上書きを解消します。

### 2. CLI テキストの解析ではなく D-Bus を経由

asusd は `xyz.ljones.Platform` インターフェースを公開し、そのうち `PlatformProfileOnAc` は書き込み可能なプロパティです：

```
.PlatformProfileOnAc  property  u  0  emits-change writable
```

`asusctl profile set -a <名>` と比べ、D-Bus へ直接書き込む利点：

- CLI の**人間可読な出力形式**に依存しない（上流が文言を変えれば静かに失効する）
- `asusctl` バイナリが `PATH` にあることに依存しない

> ⚠️ **プロファイルの列挙値**（asusctl 6.4.0 で実測）：
>
> | 値 | プロファイル |
> |----|------|
> | `0` | balanced |
> | `1` | performance |
> | `2` | quiet |
> | `3` | quiet（エイリアス） |
>
> `0` は quiet ではなく **balanced** である点に注意 —— ACPI sysfs の
> `platform_profile_choices` の順序（`quiet balanced performance`）とは**異なり**、
> 混用できません。字面から推測してもいけません：`PlatformProfileOnBattery = 2` は
> 「quiet は 2」という誤判定の原因でしたが、実測では `3` も同様に quiet へマップされます。

### 3. udev は汎用属性でマッチング

ルールは機種固有のデバイス名（例：`ucsi-source-psy-USBC000:001`。
そのインデックスは UCSI の列挙順で決まり、機種が変われば失効します）をハードコードせず、
汎用属性を用います：

```
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ...
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="USB", ...
ACTION=="add|change", SUBSYSTEM=="typec", KERNEL=="port[0-9]*", ...
```

## 検証

```bash
# 現在のプロファイル（D-Bus）
busctl get-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform \
  PlatformProfileOnAc

# イベント処理ログ
journalctl -u asusd-pd-profile --since '5 min ago'
```

正常な出力は次のような形です：

```
power source=USB-C PD -> setting PlatformProfileOnAc to 0 (balanced), was 1
PlatformProfileOnAc already 0 (balanced), nothing to do
on battery — asusd handles it (platform_profile_on_battery), no action
```

> ⚠️ **ウィンドウ期の罠**：`power_operation_mode` と USB 供給元の `online` は
> **抜き差しの瞬間にのみ**変化します。PD 未接続時に読み取ると `power_operation_mode`
> は常に `default` となり —— これに基づいて「カーネルは PD とバレル型を区別できない」
> と誤判定してしまいます。判断の前に、その時点で実際に PD 給電であることを必ず確認してください。

## 消費電力プロファイルの実測

同一プロンプト、同一セッション、400 トークン生成（Strix Halo / Radeon 8060S）：

| プロファイル | 消費電力 | sclk | 温度 | 生成速度 |
|------|------|------|------|---------|
| quiet | **38.6–43.9 W** | 2228–2464 MHz | **59–78 °C** | 12.12–12.35 t/s |
| balanced | 55.1 W | 2586–2731 MHz | 87–93 °C | 12.84 t/s |
| performance | 76.7 W | 2753–2859 MHz | 90–95 °C | 13.07 t/s |

**quiet は performance 比で消費電力 −49%、温度 −17~36 °C、速度はわずか −5~7%。**
ユニファイドメモリデバイスでは生成のボトルネックは周波数ではなく**依存レイテンシ**であるため、
プロファイルを下げてもスループットはほとんど損なわれません。
