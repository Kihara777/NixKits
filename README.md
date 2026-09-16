# NixKits

[![CI](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/Kihara777/NixKits/gh-pages/ci-status.json)](https://github.com/Kihara777/NixKits/actions) [![Cache](https://img.shields.io/badge/cache-cachix-blue)](https://app.cachix.org/cache/nixkits) [![NixOS](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos)](https://nixos.org)

中文 | [English](docs/README.en.md) | [日本語](docs/README.ja.md)  | [偽中国語](docs/README.pcn.md)

NixKits — 软件、补丁、NixOS 模块与 AI 编码助手的技能合集。

## 添加

```nix
# 远程
inputs.nixkits.url = "github:Kihara777/NixKits";

# 本地
inputs.nixkits.url = "~/NixKits";
```

> **二进制缓存**：flake 已通过 `nixConfig` 自动声明。直接使用 flake input 时 Nix 自动提示。手动：`cachix use nixkits`。
>
## 软件

所有包默认跟随 nixpkgs 平台支持（`lib.platforms.linux`）。部分包的架构支持受上游影响，具体请查看各包文档中的构建徽章。

| 软件 | 说明 | 文档 |
|---|------|------|
| blender-mcp | Blender 的 MCP Server（自然语言控制 Blender） | [docs/zh/blender-mcp.md](docs/zh/blender-mcp.md) |
| codewhale | DeepSeek V4 终端编码代理 | [docs/zh/codewhale.md](docs/zh/codewhale.md) |
| dsh | DeepSeek Harness（DSH）— 万物皆插件 | [docs/zh/dsh.md](docs/zh/dsh.md) |
| dsh-alpha | DeepSeek Harness（DSH）— alpha 开发通道（0.1.5-alpha.2） | [docs/zh/dsh.md](docs/zh/dsh.md) |
| godot-ai | Godot 引擎的 MCP Server 与 AI 工具 | [docs/zh/godot-ai.md](docs/zh/godot-ai.md) |
| kitsfmt | Nix 格式化器（AST 排序 + Best-Practice 自动修正） | [docs/zh/kitsfmt.md](docs/zh/kitsfmt.md) |
| mcp-searxng | SearXNG 的 MCP Server | [docs/zh/mcp-searxng.md](docs/zh/mcp-searxng.md) |
| obs-bilibili-stream | OBS 的 Bilibili 直播插件 | [docs/zh/obs-bilibili-stream.md](docs/zh/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 的 Telegram Bot 客户端 | [docs/zh/opencode-telegram.md](docs/zh/opencode-telegram.md) |
| ruyi | RuyiSDK 包管理器（RISC-V 开发工具）<br>stable 0.52.0 · beta 0.52.0-beta.20260824 · alpha 0.52.0-alpha.20260714 | [docs/zh/ruyi.md](docs/zh/ruyi.md) |


## 插件

DeepSeek Harness（DSH）组件与软件独立展示（挂载方式见 [docs/zh/dsh.md](docs/zh/dsh.md)）：

| 插件 | 说明 | 文档 |
|------|------|------|
| dsh-nixos-shell | NixOS 场景能力整合（shell 执行、工具引导、sudo 守护路由、NixOS 诊断） | [docs/zh/dsh-nixos-shell.md](docs/zh/dsh-nixos-shell.md) |
| dsh-api-balance | API 用量余额——webui 用量圆圈（发送按钮左侧）添加「用量 / 余额」标签切换，展示账户余额、当日 / 当月 / 30 日消耗与图表；平台令牌默认从本机浏览器登录态自动扫描获取（手动连接回退） | [docs/zh/dsh-api-balance.md](docs/zh/dsh-api-balance.md) |

## 模式

Agent 预设（会话形态）与插件同级，各自独立文档：

| 模式 | id | 说明 | 分发方式 | 文档 |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | 初始化校验 NixOS 宿主（非 NixOS 拒绝一切请求）；加载 `nixos_shell`/`nixos_cli` 与 NixOS 开发提示词 | dsh-nixos-shell 包内，seed-once | [docs/zh/modes/nixos.md](docs/zh/modes/nixos.md) |
| 维护模式 | `maintenance` | 派生自 NixOS模式；注入 `write-project-docs`/`write-maintenance-log`/`nix-flake-update-check`/`nixkits-check-updates`/`translate-*` 技能与仓库维护工作流提示词 | dsh-nixos-shell 包内，seed-once | [docs/zh/modes/maintenance.md](docs/zh/modes/maintenance.md) |
| 新闻三要素模式 | `news-three-elements` | 派生自极简模式的**只读**创作模式：「新闻三要素」= 三位必须到齐的主角；素材优先（接不回来才拒）、素材共创先检索再改写（无检索即退稿）、在线抓取技能包、开场问答三选一、非简体中文一律拒绝 | **独立包** `dsh-preset-news-three-elements` | [docs/zh/modes/news-three-elements.md](docs/zh/modes/news-three-elements.md) |

> 前两者随 dsh-nixos-shell 包经 `nixkits.dsh.presets.nixosMode` / `.maintenanceMode` seed-once 写入 `$DSH_HOME/.agent-presets`；新闻三要素模式由独立包 `dsh-preset-news-three-elements` 分发，`nixkits.dsh.presets.newsThreeElements` 把它的 `share/dsh-agent-presets` 注册为预设根（不复制）。详见 [docs/zh/dsh.md](docs/zh/dsh.md) 的「模式」章节。

## 开发

提供 `nix develop` 即用环境。首先添加 registry：
```bash
nix registry add nixkits github:Kihara777/NixKits
```

| 环境 | 命令 | 文档 |
|------|------|------|
| opencode | `nix develop nixkits#opencode` | [docs/zh/opencode-devshell.md](docs/zh/opencode-devshell.md) |
| ruyi<br>ruyi-beta<br>ruyi-alpha | `nix develop nixkits#ruyi`<br>`nix develop nixkits#ruyi-beta`<br>`nix develop nixkits#ruyi-alpha` | [docs/zh/ruyi-devshell.md](docs/zh/ruyi-devshell.md) |

## 补丁

独立 overlay，不包含在 `default` 内：

| 补丁 | 说明 | 文档 |
|------|------|------|
| llama-cpp-rocm | 动态追踪上游最新 Release 的 ROCm 加速构建 | [docs/zh/llama-cpp-rocm.md](docs/zh/llama-cpp-rocm.md) |
| rcc-fix | 修补 asusctl 的二合一设备体验 | [docs/zh/rcc-fix.md](docs/zh/rcc-fix.md) |
| asusd-pd-profile | 按供电类型选择平台档位（区分 USB-C PD 与原生 AC） | [docs/zh/asusd-pd-profile.md](docs/zh/asusd-pd-profile.md) |
| asusd-thermal-guard | 温度看门狗：过热时自动降档，冷却后恢复 | [docs/zh/asusd-thermal-guard.md](docs/zh/asusd-thermal-guard.md) |
| comfyui | ComfyUI 的 ROCm 集成（GFX override / 设备权限 / 内核参数） | [docs/zh/comfyui.md](docs/zh/comfyui.md) |
| efl-cross-fix | 修复 efl 交叉编译代码生成器缺失 | [docs/zh/efl-cross-fix.md](docs/zh/efl-cross-fix.md) |
| breeze-black | Plasma 6 高对比度 Breeze Black 无障碍主题 | [docs/zh/breeze-black.md](docs/zh/breeze-black.md) |
| codewhale-sudo | overlay — 恢复 codewhale v0.9.12 的 sudo 功能（ptrace 拦截器） | [docs/zh/codewhale-sudo.md](docs/zh/codewhale-sudo.md) |

> ⚠️ 补丁均为 overlay，修改上游 nixpkgs 包而非独立构建，不在二进制缓存中。动态追踪版本的项目（如 llama-cpp-rocm）其 hash 随上游发布变化，无法被缓存固定。

> ⚠️ **StrixHalo 设备请勿开启 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1`**。该变量会改变 GPU 显存分配路径，在统一内存设备上导致模型输出退化（重复词、语句崩坏）。实测该风险**随模型量化精度降低而显著提升** —— 低比特量化（如 1.5 bpw）受影响最重。详见 [llama-cpp-rocm 文档](docs/zh/llama-cpp-rocm.md#统一内存环境变量的退化风险)。

## 废弃项目

曾经维护、现已废弃的项目（多数因上游已内置等效能力）。索引见 [`DEPRECATED.md`](DEPRECATED.md)：

| 项目 | 说明 | 详情 |
|------|------|------|
| comfyui-rocm | ComfyUI 的 ROCm 补丁项目 —— 上游已内置，补丁全部移除 | [docs/zh/deprecated/comfyui-rocm.md](docs/zh/deprecated/comfyui-rocm.md) |

## 技能

供 AI 编码助手使用的技能：

> 本项目的技能主要面向中文用户和中国开源模型，所有 SKILL.md 均使用中文编写。

> ⚠️ **Claude Code** 已从 nixkits-skills 安装目标中移除。该软件实施了基于用户数据的国籍判断逻辑，跨越了安全模型边界。详见 [nixkits-skills 文档](docs/zh/skills/nixkits-skills.md)。

| 技能 | 说明 | 文档 |
|------|------|------|
| news-three-elements | 以真实通讯社格式编造俄式快讯——「新闻三要素」指巴兰尼科夫、尤丁采夫、布亚诺夫三位必须到齐的主角（游戏机制梗 + 素材优先的拒绝服务话术） | [docs/zh/skills/news-three-elements.md](docs/zh/skills/news-three-elements.md) |
| nix-flake-update-check | **通用**：检查任意 nix flake 仓库的上游软件更新并升级（包型分流 hash 流程 / flake.lock / 补丁内版本 / nixpkgs 漂移陷阱） | [docs/zh/skills/nix-flake-update-check.md](docs/zh/skills/nix-flake-update-check.md) |
| nixkits-check-updates | NixKits 更新适配层：四语文档、插件清单、维护日志、历史事故教训（依赖 nix-flake-update-check） | [docs/zh/skills/nixkits-check-updates.md](docs/zh/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits 技能安装器（本地/在线） | [docs/zh/skills/nixkits-skills.md](docs/zh/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS 现代 CLI 操作指南（面向 AI 模型） | [docs/zh/skills/nixos-modern-cli.md](docs/zh/skills/nixos-modern-cli.md) |
| recover-nixos-config | 从 Nix store 恢复误删的 /etc/nixos 配置 | [docs/zh/skills/recover-nixos-config.md](docs/zh/skills/recover-nixos-config.md) |
| translate-pseudocn | 偽中国語翻译（日语假名剥离 + 语序转换） | [docs/zh/skills/translate-pseudocn.md](docs/zh/skills/translate-pseudocn.md) |
| write-maintenance-log | 按 NixKits 规范撰写维护日志（软件更新 + 错误修复） | [docs/zh/skills/write-maintenance-log.md](docs/zh/skills/write-maintenance-log.md) |
| write-project-docs | 按 NixKits 风格为任意项目编写多语言文档系统 | [docs/zh/skills/write-project-docs.md](docs/zh/skills/write-project-docs.md) |
| nixos-specialisation-tuning | 设计 NixOS specialisation 分面并在统一内存设备上调优 llama.cpp | [docs/zh/skills/nixos-specialisation-tuning.md](docs/zh/skills/nixos-specialisation-tuning.md) |

## 作者

- **狐莉 (キツのり)** — 创建和维护
- **小爪 (キツのめ)** — 设计、开发 feat. DeepSeek V4 Flash · DeepSeek V4.1 Flash
- **小小爪 (キツのめ)** — 硬件推理基础设施 feat. llama-cpp-rocm: DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)

> [!NOTE]
> 关于 DeepSeek Harness (DSH) 生态 —— 小爪与小小爪使用 dsh-nixos-shell 插件，以及 NixOS模式 / 维护模式 Agent 预设武装了自己☆

## 许可

[MIT](LICENSE)