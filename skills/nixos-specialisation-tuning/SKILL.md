---
name: nixos-specialisation-tuning
description: 为 NixOS 设计 specialisation 分面（默认 headless + 可选桌面），并在统一内存（UMA）设备上调优 llama.cpp 本地推理。覆盖分面架构、模型服务参数、思考等级映射、上下文开销分析与静默故障诊断方法论。
---

# NixOS 分面设计与本地推理调优

用于两类任务：把 NixOS 配置拆成多个启动面，以及在统一内存设备上让本地大模型跑得动、跑得对、跑得快。

## 适用场景

- 需要"默认精简 + 可选全功能"两套配置，开机菜单选择
- 本地 llama.cpp 服务出现输出退化、加载失败、速度异常
- 需要判断某项优化是否值得（要求给出成本/收益/代价，而非单一收益）

## 分面架构

### 三文件布局

| 文件 | 职责 | 原则 |
|------|------|------|
| `spec/<默认面>.nix` | 默认配置（如 headless core） | 只 import 必需模块 |
| `spec/<可选面>.nix` | `specialisation.<name>.configuration` | 叠加在默认面之上 |
| `system/base.nix` | 两面共用的模式无关底座 | 不含只服务某一面的配置 |

```nix
# flake.nix
nixosConfigurations.HOST.modules = [
  ./spec/core.nix                       # 默认面
  { specialisation.plasma.configuration = {
      imports = [ ./spec/plasma.nix ];  # 可选面
    };
  }
];
```

### 覆盖与冲突

共用模块中的值用 `lib.mkDefault` 声明，供分面用普通赋值覆盖：

```nix
# base/core 中
networking.wireless.iwd.enable = lib.mkDefault true;

# plasma 中覆盖
networking.wireless.iwd.enable = lib.mkForce true;
```

**陷阱**：`lib.mkForce` 覆盖整个属性时，会连带删掉其它模块对该属性的贡献。

> ⚠️ 实战案例：core 曾用 `lib.mkForce` 覆盖 `environment.systemPackages`，把 base 层提供的 `bash` 与 `systemd` 一并删除，导致无法登录、`systemctl`/`reboot` 全部缺失。
> **规则：`systemPackages` 类列表用追加，不用 `mkForce` 覆盖。**

### 面向消费者的归属原则

一个配置项应放在**它的消费者**所在模块，而非"共用的那个文件"。

> ⚠️ 实战案例：为给 mihomo 腾出 53 端口而设置的 `DNSStubListener=no`，起初写进了共用的 `base.nix`。这会让不使用 mihomo 的面也无谓地失去 DNS stub。
> **判据：若某个面不启用该消费者，它就不该承受这个副作用。**

## llama.cpp 统一内存调优

### 参数速查

| 参数 | 推荐 | 依据 |
|------|------|------|
| `jinja` | `"on"` | 缺失则无 chat template → 输出退化 |
| `fit` | 保持默认 `on` | **不要写死 `n-gpu-layers`/`load-mode`**，会使自适应失效；`fit=off` 在显存受限时直接 OOM |
| `batch-size` / `ubatch-size` | `"2048"` | prefill 142.7 → 168.7 t/s（+18%），代价约 0.9 GiB；4096 退化 |
| `cache-type-k/v` | `"q4_0"` | `iq4_nl` 因缺 ROCm kernel 回退 CPU（慢 2.6 倍）；`f16` prefill 反而更慢 |
| `parallel` | `"1"` | 多槽位按槽位倍增 KV 预留，长上下文模型会因此无法载入 |
| `threads` | 等于核心数 | — |

### 关键禁用项

| 项 | 后果 |
|----|------|
| `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` | **UMA 设备上导致输出退化**（token 重复、乱码），且风险随量化精度降低而提升 |
| `cache-ram` 调优 | 默认 8192 是**上限非预分配**；禁用后实测显存占用完全相同，无收益 |
| 写死 `n-gpu-layers` | 禁用 `fit` 的设备内存自适应 |

### 诊断顺序

出现输出异常时，**先排除环境变量，再怀疑量化与模板**：

1. `GGML_CUDA_ENABLE_UNIFIED_MEMORY` 是否被设置（最高频根因）
2. `jinja` 是否开启
3. chat template 是否匹配模型
4. 量化的 KV 类型是否触发了 CPU 回退

> ⚠️ 误判陷阱：`llama-cli` 与 `llama-server` 的默认值不同（cli 默认 `--fit on`、`--n-gpu-layers auto`），
> 因此"cli 正常但 server 异常"极易被误读为模型或量化问题，实际常是该环境变量或 `fit` 差异。

### 优化优先级

**prefill 通常是 agentic 场景的主要瓶颈**，而非生成。低比特量化对生成有利（权重带宽小）但对 prefill 不利（每层需反量化，而 prefill 是计算密集阶段）。

| 方向 | 典型收益 | 备注 |
|------|---------|------|
| 清理无用工具 schema | 可达数万 token/轮 | 见下节 |
| `batch`/`ubatch` 调优 | prefill +15~18% | 低成本，先做 |
| `ngram` 投机解码 | 生成 +141%（**内容相关**） | 零内存；短对话无收益 |
| 减少上下文 | 线性收益 | prefill 是 O(n) |

**先验证再宣称收益**：不要凭 help 文本或直觉推算节省量。

> ⚠️ 实战教训：曾据 `cache-ram` 默认值 8192 推断"可省 8GB"，实测禁用后显存占用完全相同——该值是上限而非已分配。**未经实测的数字不应写入建议。**

## 电源状态与平台档位

### 生成速度的瓶颈是依赖延迟，不是频率

在统一内存设备上调优推理时，**提频与提精度几乎都不提升生成速度**。三条独立证据：

| 实验 | 结果 |
|------|------|
| 权重精度 1.56 → 3.44 bpw（体积 +39%） | 生成 12.8 → 12.9 t/s（**无变化**） |
| 3 个并发请求 | 聚合吞吐 12.5 t/s，与单请求**相同** |
| performance vs balanced 档 | 功耗 +54%（45.6 → 70.2 W），速度仅 +2.4% |

三条共同指向：生成受限于**逐 token 的依赖延迟**。故：

- 不要为提高生成速度而解锁功耗墙 / 提高平台档位
- 不要为提高生成速度而改用更高精度量化（prefill 反而更慢，见上节）
- 想要生成提速，唯一有效方向是 `ngram` 类投机解码（且内容相关）

### 功耗档位实测（Strix Halo，400 token 生成）

| 档位 | 功耗 | sclk | 温度 | 生成速度 |
|------|------|------|------|---------|
| quiet | **38.6–43.9 W** | 2228–2464 MHz | **59–78 °C** | 12.12–12.35 t/s |
| balanced | 55.1 W | 2586–2731 MHz | 87–93 °C | 12.84 t/s |
| performance | 76.7 W | 2753–2859 MHz | 90–95 °C | 13.07 t/s |

**quiet 相对 performance：功耗 −49%、温度 −17~36 °C，速度仅 −5~7%。**
按每瓦吞吐衡量 quiet 最优——降档几乎不损失吞吐，却能大幅省电降温。

> ⚠️ 测量必须用 `hwmon` 的 `power1_average`（`/sys/class/drm/card*/device/hwmon/hwmon*/`），
> BAT0 的 `power_now` 在 AC 供电下恒为 0，不能作为负载功耗来源。

### 补足 asusd 缺失的第三态

`asusd`（ASUS ROG 硬件守护进程）的 `asusd.ron` **只有两个档位键**：
`platform_profile_on_ac` 与 `platform_profile_on_battery`，**没有 USB-C PD 分支**
（可从 `asusctl` 二进制直接确认）。

若要区分"USB-C PD 供电"与"原生/桶形 AC 供电"，需自行补 udev 监听器。两条要点：

**1. PD 与 AC 是同一信号，但有独立旁证**——`AC0.online` 在两者下都为 1，
必须读以下之一：

| 信号 | 路径 | PD 在线值 |
|------|------|----------|
| PD 供应器 | `/sys/class/power_supply/ucsi-source-psy-USBC*/online` | `1` |
| Type-C 模式 | `/sys/class/typec/port*/power_operation_mode` | `usb_power_delivery` |

> ⚠️ **窗口期陷阱**：这两处只在插拔瞬间变化。未接 PD 时 `power_operation_mode`
> 恒为 `default` —— 若此时采样会**误判"内核无法区分 PD 与 AC"**。
> 判断能力前，务必先确认当时确实处于 PD 供电状态。

**2. 不要直接写 `/sys/firmware/acpi/platform_profile`**——asusd 在每次 AC 事件时
都会按 `platform_profile_on_ac` 重设档位（日志 `Setting ... before EPP` 可证），
会立即覆盖外部写入。应改用 `asusctl profile set -a <档>` 修改
**asusd 自己的持久化 AC 档位**，使二者意图一致。

> ⚠️ 事件驱动可行：`udevadm monitor --subsystem-match=power_supply --subsystem-match=typec`
> 在插拔时给出完整序列（`AC0 online` 变化 → `portN-partner` add/remove → `ucsi` online 变化），
> 故无需轮询，用 `ENV{SYSTEMD_WANTS}` 触发 oneshot 服务即可。

## 上下文开销分析

Agent 框架的工具 schema 是每轮固定开销，且可能包含**已失效的 MCP 工具**。

### 检测方法

解码会话记录，统计 `request.header.tools` 的体积与数量：

```bash
for f in docs/path/to/session.jsonl.zst; do
  zstd -d -c "$f" | python3 -c "
import json,sys
for line in sys.stdin:
    o=json.loads(line)
    if o.get('type')=='request/header':
        t=o['data']['header'].get('tools',[])
        mcp=[x for x in t if (x.get('function',{}).get('name') or '').startswith('mcp__')]
        print('tools=%d mcp=%d bytes=%d' % (len(t),len(mcp),len(json.dumps(t))))
"
done
```

### 对症处理

| 症状 | 处理 |
|------|------|
| MCP 工具数与实际可用服务不符 | 检查该工具的**可执行文件是否存在**——配置声明了但未安装的 MCP 会照常注入 schema |
| 无用工具占大量 token | 从消费它的**分面**移除；共用配置里的 MCP 会污染所有面 |

> ⚠️ 实战案例：某面声明了两个 MCP server，但其可执行文件在该面的 profile 中并不存在——工具永远无法执行，却每轮注入 50 个 schema（约 28k token）。**声明了却跑不起来的工具是最纯粹的浪费。**

## 静默故障诊断

**"服务 active + 端口监听"不等于功能正常。**

> ⚠️ 实战案例：移除 SearXNG 时连带删掉 lighttpd 的 `mod_proxy`，反代配置块被 lighttpd **静默丢弃**：
> ```
> WARNING: unknown config-key: proxy.server (ignored)
> ```
> 服务照常启动、端口照常监听，但 vhost 后无 handler，表现为 HTTP 403。
> 仅检查 `systemctl is-active` 和 `ss -tlnp` **完全看不出问题**。

### 规则

1. 改动中间件（反代/代理/DNS）后，**必须读该服务的配置日志**，不能只看 systemd 状态
2. 关注 `unknown config-key` / `ignored` 类警告——配置合并系统中，未加载模块的配置键常被静默忽略
3. 配置合并类选项（`types.lines` / `types.listOf`）会**拼接而非覆盖**，要确认各贡献方都到位

### 实验有效性自检

设计对照实验时，确认实验本身有效：

> ⚠️ 实战教训：曾用沙箱测试网络，得到 DNS 解析失败，据此判断"沙箱 DNS 有问题"。但真实构建已成功下载数百个包——**证明 DNS 正常，是测试脚本未使用正确的网络配置**。
> **若实验结果与生产行为矛盾，先怀疑实验方法，而非生产环境。**

## 验证清单

改动后进行：

```bash
# 求值（不构建，快速验证语法与选项合法性）
nix eval .#nixosConfigurations.HOST.config.system.build.toplevel.drvPath

# 分面同样求值
nix eval .#nixosConfigurations.HOST.config.specialisation.NAME.configuration.system.build.toplevel.drvPath

# 构建
nix build .#nixosConfigurations.HOST.config.system.build.toplevel --no-link --print-out-paths
```

服务类改动的额外核对：

```bash
systemctl is-active <svc>              # 基础
journalctl -u <svc> --since '5 min ago' | grep -iE 'warn|error|ignored'   # 关键
ss -tulnp | grep <port>                # 端口归属（确认是谁在监听）
```

> ⚠️ 本机同时只能驻留一个大模型实例。测试实例务必按 PID 精确清理，并确认显存指标归零后再启动系统服务，否则 OOM 会伪装成配置错误。
