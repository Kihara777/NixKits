# asusd-thermal-guard

[中文](../zh/asusd-thermal-guard.md) | [English](../en/asusd-thermal-guard.md) | [日本語](../ja/asusd-thermal-guard.md)  | 偽中国語

温度看門犬 —— 温度不能压制時**自動降格平台檔位**、冷却後再恢復。

## 基本情報

| 項目 | 値 |
|------|-----|
| 上流 | [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)（`asusd` 守護工程） |
| 部品 | `nixosModules.asusd-thermal-guard` |
| 依存 | `services.asusd.enable = true` |
| 実装 | systemd timer + oneshot（常駐工程無） |
| 注意 | 降檔専用、`profileCeiling` 超過之昇檔無 |

## 為何必要：風扇曲線会飽和

ROG Flow Z13（Strix Halo）上跑本地 LLM 推理時**連續三次過熱 shutdown**。
排查過程自体即本部品存在之理由：

| 段階 | 観察 | 結論 |
|------|------|------|
| ① 調査風扇曲線 | 曲線於 80 °C 封頂（145/255 = 56%）、而芯片跑 90–95 °C | 修好終点値、温度確実回落 |
| ② 再 shutdown | 風扇**已満転 8800 RPM**、温度平穏 **85.4 °C 持續 28 分**（90 個採樣、Δ = −0.3 °C） | 非失控昇温、是環境平衡点 |
| ③ 対照実験 | 把曲線改成「65 °C 即満転」之激進版 | **85.6 °C / 55 W —— 與温和曲線毫無差別** |

**結論：風扇一旦飽和、曲線之形状就不再重要。**

```
温和曲線 (80°C→255):  85.4 °C @ 52 W,  8700–8800 RPM
激進曲線 (65°C→255):  85.6 °C @ 55 W,  8700–8800 RPM
```

両者風扇皆已在硬体上限 8800 RPM、温度亦相同 ——
該機箱於満転下只能耗散約 55 W、**此即物理極限**。

故唯一有効之杠杆是**降低功耗**。而「多低才安全」随機型、環境温度、
進灰程度而変、写死一個更低之 PPT 既保守又僵硬 ——
**動態監測 + 超過降檔**更穏妥。

## 使用法

```nix
{
  imports = [ inputs.nixkits.nixosModules.asusd-thermal-guard ];

  services.asusd.enable = true;

  nixkits.asusd-thermal-guard = {
    enable = true;
    profileCeiling = "performance"; # 允許使用之最高檔位
    triggerTemp = 88;               # ≥ 此温度即降一檔
    resumeTemp = 80;                # ≤ 此温度且連續達標才恢復
    resumeSamples = 6;              # 連續採樣次數（防抖動）
    interval = "10s";               # 採樣周期
  };
}
```

### 選項

| 選項 | 種別 | 既定 | 説明 |
|------|------|------|------|
| `enable` | bool | `false` | 有効化看門犬 |
| `profileCeiling` | enum | `"performance"` | 允許使用之最高檔位；看門犬**降檔専用、不昇過此値** |
| `triggerTemp` | int | `90` | 觸發降檔之温度（°C） |
| `resumeTemp` | int | `78` | 允許恢復之温度閾値（°C） |
| `resumeSamples` | int | `6` | 連續低於 `resumeTemp` 何回才恢復 |
| `interval` | str | `"10s"` | 採樣周期 |

檔位階段（由低到高）：`quiet` → `balanced` → `performance`。
降檔即向下取一檔；已在最低檔時不再動作。

> ⚠️ `triggerTemp` 必須大於 `resumeTemp`（部品内含 assertion 検証）、
> 否則会於閾値附近反復横跳。

## 実装要点

### 1. 按 `name` 解析 hwmon、不写死 `hwmonN`

**実測同一機器 reboot 後編号会変**（`k10temp` 1→3、`asus` 9→8）。
写死編号之 script 於 reboot 後必然読到錯誤之 sensor：

```bash
for d in /sys/class/hwmon/hwmon*/; do
  [ "$(cat "$d/name" 2>/dev/null)" = k10temp ] && echo "$d"
done
```

### 2. 取 CPU 與 GPU 之**較大値**作為判據

任一過熱皆应觸發：

```
max(cpu_tctl, gpu_edge) >= triggerTemp
```

### 3. 用 `asusctl` 改檔位、不直接書 sysfs

**不要**書 `/sys/firmware/acpi/platform_profile` ——
`asusd` 於毎回 AC 事象時皆按自身持久化檔位覆盖之
（日誌 `Setting Performance before EPP` 可証）。
`asusctl profile set <檔>` 改的是 asusd **自身**之檔位、二者意圖一致。

### 4. 滞回 + 冷却計数

降檔後即時允許恢復、会於閾値附近反復切換。故恢復需**連續 N 回**
低於 `resumeTemp` 才生效、且任一次超過皆清零計数。

## 検証

```bash
# 看門犬日誌（毎 10 秒一次採樣）
journalctl -u asusd-thermal-guard --since '5 min ago'
journalctl -u asusd-thermal-guard-resume --since '5 min ago'

# 當前有効檔位
asusctl profile get

# 手動跑一次（root 必要：asusctl 特権 必要、冷却計数 StateDirectory
# （/var/lib/private/asusd-thermal-guard）書。systemd 外 /var/lib/asusd-thermal-guard 代替 使用）
sudo "$(systemctl show asusd-thermal-guard -p ExecStart --value | cut -d';' -f1 | awk '{print $1}')"
```

正常出力形如：

```
cpu=85.1 gpu=86.0 max=86.0 current=performance
below trigger (88C)
```

觸發時：

```
cpu=90.2 gpu=88.0 max=90.2 current=performance
OVERHEAT (90.2 C >= 88 C) — performance -> balanced
```

## 與 `asusd-pd-profile` 之関係

両者互補、可同時有効化：

| 部品 | 職責 |
|------|------|
| `asusd-pd-profile` | 按**給電種別**選檔（PD / 原生 AC / 電池） |
| `asusd-thermal-guard` | 按**温度**降檔（過熱時） |

看門犬只負責於過熱時**向下**調整、不変更按電源選檔之規則；
冷却後它会恢復到 `profileCeiling` 允許之範囲、而不会自作主張昇到更高檔。
