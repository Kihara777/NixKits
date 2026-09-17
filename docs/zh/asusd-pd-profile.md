# asusd-pd-profile

中文 | [English](../en/asusd-pd-profile.md) | [日本語](../ja/asusd-pd-profile.md)  | [偽中国語](../pcn/asusd-pd-profile.md)

按供电类型选择 ASUS 平台档位 —— 区分 **USB-C PD** 与**原生/桶形 AC**，补足 `asusd` 自身配置无法表达的第三态。

## 基本信息

| 项目 | 值 |
|------|-----|
| 上游 | [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)（`asusd` 守护进程） |
| 模块 | `nixosModules.asusd-pd-profile` |
| 依赖 | `services.asusd.enable = true` |
| 接口 | asusd D-Bus `xyz.ljones.Platform` + udev |
| 注意 | 无常驻进程、无轮询；由 udev 事件触发的 oneshot 服务 |

## 解决的问题

`asusd` 的 `asusd.ron` **只有两个档位键**：

```ron
platform_profile_on_ac: Performance,
platform_profile_on_battery: Quiet,
```

**没有 USB-C PD 分支。** 因此"插 PD 时用 Balanced、插桶形电源时用 Performance"
这类策略无法用配置表达。

问题在于 ACPI 层**只暴露一个 AC 供应器** —— PD 与桶形充电在
`/sys/class/power_supply/AC0/online` 上都是 `1`，看似无法区分。

**但内核另把 USB-C PD 暴露为独立供应器**，本模块据此区分：

| 信号 | 路径 | PD 在线时 |
|------|------|----------|
| Type-C 端口模式 | `/sys/class/typec/port*/power_operation_mode` | `usb_power_delivery` |
| USB 型供应器 | `/sys/class/power_supply/*/`（`type` 为 `USB`） | `online` 为 `1` |

两级判据互为冗余，且都用**通用内核属性**，不依赖具体机型的 UCSI 枚举顺序。

## 用法

```nix
{
  imports = [ inputs.nixkits.nixosModules.asusd-pd-profile ];

  services.asusd.enable = true;

  nixkits.asusd-pd-profile = {
    enable = true;
    pdProfile = "balanced";        # USB-C PD 供电时（默认）
    nativeAcProfile = "performance"; # 原生/桶形 AC 供电时（默认）
  };
}
```

电池供电**不由本模块处理** —— 那是 `platform_profile_on_battery` 的职责，
本模块检测到电池供电时立即退出，避免与 asusd 争抢。

### 选项

| 选项 | 类型 | 默认 | 说明 |
|------|------|------|------|
| `enable` | bool | `false` | 启用本模块 |
| `pdProfile` | enum | `"balanced"` | USB-C PD 供电时选用的档位 |
| `nativeAcProfile` | enum | `"performance"` | 原生/桶形 AC 供电时选用的档位 |

档位可选 `quiet` / `balanced` / `performance`。

## 关键实现要点

### 1. 绝不直接写 sysfs

**不要**写 `/sys/firmware/acpi/platform_profile` —— asusd 在每次 AC 事件时
都会按自己的 AC 档位重设，会立即覆盖外部写入（日志可见
`[DEBUG asusd::ctrl_platform] Setting Performance before EPP`）。

本模块改为写 asusd **自己的**持久化设置（`PlatformProfileOnAc`），
使二者意图一致，不再互相覆盖。

### 2. 通过 D-Bus 而非解析 CLI 文本

asusd 暴露 `xyz.ljones.Platform` 接口，其中 `PlatformProfileOnAc` 是可写属性：

```
.PlatformProfileOnAc  property  u  0  emits-change writable
```

相较 `asusctl profile set -a <名>`，直接写 D-Bus：

- 不依赖 CLI 的**人类可读输出格式**（上游改措辞即静默失效）
- 不依赖 `asusctl` 二进制在 `PATH` 中

> ⚠️ **档位枚举值**（实测 asusctl 6.4.0）：
>
> | 值 | 档位 |
> |----|------|
> | `0` | balanced |
> | `1` | performance |
> | `2` | quiet |
> | `3` | quiet（别名） |
>
> 注意 `0` 是 **balanced** 而非 quiet —— 与 ACPI sysfs
> `platform_profile_choices` 的顺序（`quiet balanced performance`）**不同**，
> 不可混用。也不要按字面推断：`PlatformProfileOnBattery = 2` 曾是
> "quiet 是 2" 的误判来源，而实测 `3` 同样映射到 quiet。

### 3. udev 用通用属性匹配

规则不写死机型专属设备名（如 `ucsi-source-psy-USBC000:001`，
其索引由 UCSI 枚举顺序决定、换机型即失效），而用通用属性：

```
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ...
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="USB", ...
ACTION=="add|change", SUBSYSTEM=="typec", KERNEL=="port[0-9]*", ...
```

## 验证

```bash
# 当前档位（D-Bus）
busctl get-property xyz.ljones.Asusd /xyz/ljones xyz.ljones.Platform \
  PlatformProfileOnAc

# 事件处理日志
journalctl -u asusd-pd-profile --since '5 min ago'
```

正常输出形如：

```
power source=USB-C PD -> setting PlatformProfileOnAc to 0 (balanced), was 1
PlatformProfileOnAc already 0 (balanced), nothing to do
on battery — asusd handles it (platform_profile_on_battery), no action
```

> ⚠️ **窗口期陷阱**：`power_operation_mode` 与 USB 供应器的 `online`
> **只在插拔瞬间**变化。若在未连接 PD 时读取，`power_operation_mode`
> 恒为 `default` —— 据此会误判"内核无法区分 PD 与桶形"。
> 判断前必须先确认当时确实处于 PD 供电。

## 功耗档位实测

同一提示词、同一会话、400 token 生成（Strix Halo / Radeon 8060S）：

| 档位 | 功耗 | sclk | 温度 | 生成速度 |
|------|------|------|------|---------|
| quiet | **38.6–43.9 W** | 2228–2464 MHz | **59–78 °C** | 12.12–12.35 t/s |
| balanced | 55.1 W | 2586–2731 MHz | 87–93 °C | 12.84 t/s |
| performance | 76.7 W | 2753–2859 MHz | 90–95 °C | 13.07 t/s |

**quiet 相对 performance：功耗 −49%、温度 −17~36 °C，速度仅 −5~7%。**
在统一内存设备上，生成瓶颈是**依赖延迟**而非频率，故降档几乎不损失吞吐。
