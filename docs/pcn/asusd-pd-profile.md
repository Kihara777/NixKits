# asusd-pd-profile

[中文](../zh/asusd-pd-profile.md) | [English](../en/asusd-pd-profile.md) | [日本語](../ja/asusd-pd-profile.md)  | 偽中国語

按給電種別選択 ASUS 平台檔位 —— 区分 **USB-C PD** 與**原生/桶形 AC**、補足 `asusd` 自身設定不能表現之第三態。

## 基本情報

| 項目 | 値 |
|------|-----|
| 上流 | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl)（`asusd` 守護工程） |
| 部品 | `nixosModules.asusd-pd-profile` |
| 依存 | `services.asusd.enable = true` |
| 接続 | asusd D-Bus `xyz.ljones.Platform` + udev |
| 注意 | 常駐工程無、輪詢無；udev 事象觸發之 oneshot 服務 |

## 解決之問題

`asusd` 之 `asusd.ron` **僅有二個檔位鍵**：

```ron
platform_profile_on_ac: Performance,
platform_profile_on_battery: Quiet,
```

**USB-C PD 分支無。** 故「插 PD 時用 Balanced、插桶形電源時用 Performance」
此類策略不能用設定表現。

問題在於 ACPI 層**僅暴露一個 AC 供給器** —— PD 與桶形充電在
`/sys/class/power_supply/AC0/online` 上皆為 `1`、看似不能区分。

**但内核別把 USB-C PD 暴露為独立供給器**、本部品據此区分：

| 信号 | 経路 | PD 在線時 |
|------|------|----------|
| Type-C 模式 | `/sys/class/typec/port*/power_operation_mode` | `usb_power_delivery` |
| USB 型供給元 | `/sys/class/power_supply/*/`（`type` 為 `USB`） | `online` 為 `1` |

二級判據互為冗長、且皆用**通用内核属性**、不依存具体機型之 UCSI 列挙順序。

## 使用法

```nix
{
  imports = [ inputs.nixkits.nixosModules.asusd-pd-profile ];

  services.asusd.enable = true;

  nixkits.asusd-pd-profile = {
    enable = true;
    pdProfile = "balanced";        # USB-C PD 給電時（既定）
    nativeAcProfile = "performance"; # 原生/桶形 AC 給電時（既定）
  };
}
```

電池給電**不由本部品処理** —— 那是 `platform_profile_on_battery` 之職責、
本部品検測到電池給電時即時退出、避免與 asusd 争奪。

### 選項

| 選項 | 種別 | 既定 | 説明 |
|------|------|------|------|
| `enable` | bool | `false` | 有効化本部品 |
| `pdProfile` | enum | `"balanced"` | USB-C PD 給電時選用之檔位 |
| `nativeAcProfile` | enum | `"performance"` | 原生/桶形 AC 給電時選用之檔位 |

檔位可選 `quiet` / `balanced` / `performance`。

## 重要実装要点

### 1. 絶対不直接書 sysfs

**不要**書 `/sys/firmware/acpi/platform_profile` —— asusd 於毎回 AC 事象時
皆按自身 AC 檔位重設、会即時覆盖外部書込（日誌可見
`[DEBUG asusd::ctrl_platform] Setting Performance before EPP`）。

本部品改為書 asusd **自身**之持久化設定（`PlatformProfileOnAc`）、
使二者意圖一致、不再互相覆盖。

### 2. D-Bus 経由、非 CLI 文本解析

asusd 暴露 `xyz.ljones.Platform` 接続、其中 `PlatformProfileOnAc` 是可書属性：

```
.PlatformProfileOnAc  property  u  0  emits-change writable
```

相較 `asusctl profile set -a <名>`、直接書 D-Bus：

- 不依存 CLI 之**人間可読出力格式**（上流改措辞即静黙失效）
- 不依存 `asusctl` 二進在 `PATH` 中

> ⚠️ **檔位列挙値**（実測 asusctl 6.4.0）：
>
> | 値 | 檔位 |
> |----|------|
> | `0` | balanced |
> | `1` | performance |
> | `2` | quiet |
> | `3` | quiet（別名） |
>
> 注意 `0` 是 **balanced** 而非 quiet —— 與 ACPI sysfs
> `platform_profile_choices` 之順序（`quiet balanced performance`）**不同**、
> 不可混用。也不要按字面推断：`PlatformProfileOnBattery = 2` 曾是
> 「quiet 是 2」之誤判起源、而実測 `3` 同様映射到 quiet。

### 3. udev 用通用属性匹配

規則不寫死機型専属機器名（如 `ucsi-source-psy-USBC000:001`、
其索引由 UCSI 列挙順序決定、換機型即失效）、而用通用属性：

```
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ...
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="USB", ...
ACTION=="add|change", SUBSYSTEM=="typec", KERNEL=="port[0-9]*", ...
```

## 検証

```bash
# 當前檔位（D-Bus）
busctl get-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform \
  PlatformProfileOnAc

# 事象処理日誌
journalctl -u asusd-pd-profile --since '5 min ago'
```

正常出力形如：

```
power source=USB-C PD -> setting PlatformProfileOnAc to 0 (balanced), was 1
PlatformProfileOnAc already 0 (balanced), nothing to do
on battery — asusd handles it (platform_profile_on_battery), no action
```

> ⚠️ **窓口期陷阱**：`power_operation_mode` 與 USB 供給器之 `online`
> **僅在拔插瞬間**変化。若在未接続 PD 時読取、`power_operation_mode`
> 恒為 `default` —— 據此会誤判「内核不能区分 PD 與桶形」。
> 判断前必須先確認當時確実處於 PD 給電。

## 功耗檔位実測

同一提示詞、同一会期、400 語彙 生成（Strix Halo / Radeon 8060S）：

| 檔位 | 功耗 | sclk | 温度 | 生成速度 |
|------|------|------|------|---------|
| quiet | **38.6–43.9 W** | 2228–2464 MHz | **59–78 °C** | 12.12–12.35 t/s |
| balanced | 55.1 W | 2586–2731 MHz | 87–93 °C | 12.84 t/s |
| performance | 76.7 W | 2753–2859 MHz | 90–95 °C | 13.07 t/s |

**quiet 相対 performance：功耗 −49%、温度 −17~36 °C、速度僅 −5~7%。**
統一記憶域機器上、生成隘路是**依頼遅延**而非周波数、故降檔幾乎不損失吞吐。
