# asusd-thermal-guard

中文 | [English](../en/asusd-thermal-guard.md) | [日本語](../ja/asusd-thermal-guard.md)  | [偽中国語](../pcn/asusd-thermal-guard.md)

温度看门狗 —— 当温度无法压制时**自动降级平台档位**，冷却后再恢复。

## 基本信息

| 项目 | 值 |
|------|-----|
| 上游 | [OpenGamingCollective/asusctl](https://github.com/OpenGamingCollective/asusctl)（`asusd` 守护进程） |
| 模块 | `nixosModules.asusd-thermal-guard` |
| 依赖 | `services.asusd.enable = true` |
| 实现 | systemd timer + oneshot（无常驻进程） |
| 注意 | 只降档、不升档超过 `profileCeiling` |

## 为何需要：风扇曲线会饱和

在 ROG Flow Z13（Strix Halo）上跑本地 LLM 推理时**连续三次过热关机**。
排查过程本身就是这个模块存在的理由：

| 步骤 | 观察 | 结论 |
|------|------|------|
| ① 查风扇曲线 | 曲线在 80 °C 封顶（145/255 = 56%），而芯片跑 90–95 °C | 修好终点值，温度确实回落 |
| ② 再次关机 | 风扇**已满转 8800 RPM**，温度平稳 **85.4 °C 持续 28 分钟**（90 个采样，Δ = −0.3 °C） | 非失控升温，是环境平衡点 |
| ③ 对照实验 | 把曲线改成「65 °C 即满转」的激进版 | **85.6 °C / 55 W —— 与温和曲线毫无差别** |

**结论：风扇一旦饱和，曲线的形状就不再重要。**

```
温和曲线 (80°C→255):  85.4 °C @ 52 W,  8700–8800 RPM
激进曲线 (65°C→255):  85.6 °C @ 55 W,  8700–8800 RPM
```

两者风扇都已在硬件上限 8800 RPM，温度也相同 ——
该机箱在满转下只能耗散约 55 W，**这就是物理极限**。

因此唯一有效的杠杆是**降低功耗**。而「多低才安全」随机型、环境温度、
进灰程度而变，写死一个更低的 PPT 既保守又僵硬 ——
**动态监测 + 超标降档**更稳妥。

## 用法

```nix
{
  imports = [ inputs.nixkits.nixosModules.asusd-thermal-guard ];

  services.asusd.enable = true;

  nixkits.asusd-thermal-guard = {
    enable = true;
    profileCeiling = "performance"; # 允许使用的最高档位
    triggerTemp = 88;               # ≥ 此温度即降一档
    resumeTemp = 80;                # ≤ 此温度且连续达标才恢复
    resumeSamples = 6;              # 连续采样次数（防抖动）
    interval = "10s";               # 采样周期
  };
}
```

### 选项

| 选项 | 类型 | 默认 | 说明 |
|------|------|------|------|
| `enable` | bool | `false` | 启用看门狗 |
| `profileCeiling` | enum | `"performance"` | 允许使用的最高档位；看门狗**只降不升过此值** |
| `triggerTemp` | int | `90` | 触发降档的温度（°C） |
| `resumeTemp` | int | `78` | 允许恢复的温度阈值（°C） |
| `resumeSamples` | int | `6` | 连续低于 `resumeTemp` 多少次才恢复 |
| `interval` | str | `"10s"` | 采样周期 |

档位阶梯（由低到高）：`quiet` → `balanced` → `performance`。
降档即向下取一档；已在最低档时不再动作。

> ⚠️ `triggerTemp` 必须大于 `resumeTemp`（模块内含 assertion 校验），
> 否则会在阈值附近反复横跳。

## 实现要点

### 1. 按 `name` 解析 hwmon，不写死 `hwmonN`

**实测同一机器重启后编号会变**（`k10temp` 1→3、`asus` 9→8）。
写死编号的脚本在重启后必然读到错误的传感器：

```bash
for d in /sys/class/hwmon/hwmon*/; do
  [ "$(cat "$d/name" 2>/dev/null)" = k10temp ] && echo "$d"
done
```

### 2. 取 CPU 与 GPU 的**较大值**作为判据

任一过热都应触发：

```
max(cpu_tctl, gpu_edge) >= triggerTemp
```

### 3. 用 `asusctl` 改档位，不直接写 sysfs

**不要**写 `/sys/firmware/acpi/platform_profile` ——
`asusd` 在每次 AC 事件时都会按自己的持久化档位覆盖它
（日志 `Setting Performance before EPP` 可证）。
`asusctl profile set <档>` 改的是 asusd **自己的**档位，二者意图一致。

### 4. 滞回 + 冷却计数

降档后立即允许恢复，会在阈值附近反复切换。故恢复需**连续 N 次**
低于 `resumeTemp` 才生效，且任何一次超标都会清零计数。

## 验证

```bash
# 看门狗日志（每 10 秒一次采样）
journalctl -u asusd-thermal-guard --since '5 min ago'
journalctl -u asusd-thermal-guard-resume --since '5 min ago'

# 当前生效档位
asusctl profile get

# 手动跑一次（需 root：asusctl 需特权，冷却计数写在 StateDirectory
# —— /var/lib/private/asusd-thermal-guard，手动运行时兜底到 /var/lib/asusd-thermal-guard）
sudo "$(systemctl show asusd-thermal-guard -p ExecStart --value | cut -d';' -f1 | awk '{print $1}')"
```

正常输出形如：

```
cpu=85.1 gpu=86.0 max=86.0 current=performance
below trigger (88C)
```

触发时：

```
cpu=90.2 gpu=88.0 max=90.2 current=performance
OVERHEAT (90.2 C >= 88 C) — performance -> balanced
```

## 与 `asusd-pd-profile` 的关系

两者互补，可同时启用：

| 模块 | 职责 |
|------|------|
| `asusd-pd-profile` | 按**供电类型**选档（PD / 原生 AC / 电池） |
| `asusd-thermal-guard` | 按**温度**降档（过热时） |

看门狗只负责在过热时**向下**调整，不改变按电源选档的规则；
冷却后它会恢复到 `profileCeiling` 允许的范围，而不会自作主张升到更高档。
