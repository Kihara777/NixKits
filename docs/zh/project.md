# NixKits 项目文档

[中文](project.md) | [English](../en/project.md) | [日本語](../ja/project.md)

## 项目角色

| 角色 | 名称 | 职责 |
|------|------|------|
| 创建与维护 | 狐莉 (キツのり) | 主干开发、架构维护、发布管理 |
| 设计与开发 | 小爪 (キツのめ) | AI 编码代理、构建配置、技能系统 — feat. DeepSeek V4 Pro (Max) |
| 硬件推理基础设施 | 小小爪 (キツのめ) | 本地 LLM 推理、模型量化、ROCm 加速 — feat. llama-cpp-rocm |
| 翻译 (ja) | 尾巻 (オマキ) | 所有日文文档翻译与校对 |
| 翻译 (en) | 耳廓狐 (フェネック) | 所有英文文档翻译与校对 |
| 文档设计 | 小爪 (キツのめ) | 多语言文档系统架构、语言切换器、模板设计 |

## 项目架构

```
NixKits/
├── packages/          # 包定义（独立二进制或源码构建）
├── modules/           # NixOS 模块（systemd 服务、配置选项）
├── overlays/          # Nixpkgs 覆盖层（独立或不包含在 default 内）
├── patches/           # 独立补丁文件
├── skills/            # AI 编码助手使用的技能定义
├── docs/              # 多语言文档
│   ├── zh/            # 中文（基准）
│   ├── en/            # 英文
│   ├── ja/            # 日文
│   └── katalish/      # 片假名英语（从 en 自动翻译）
```

## 组件目录

### 软件

可作为 NixOS 包通过 `nix build nix-kits#<name>` 直接构建和使用。

| 软件 | 路径 | 类型 | 加载方式 | 文档 |
|------|------|------|---------|------|
| codewhale | `packages/codewhale.nix` | 二进制（预编译） | `pkgs.callPackage` → 输出 `packages.codewhale` | [codewhale](codewhale.md) |
| kitsfmt | `packages/kitsfmt.nix` | 源码（Rust） | `pkgs.callPackage` → 输出 `packages.kitsfmt` | [kitsfmt](kitsfmt.md) |
| mcp-searxng | `packages/mcp-searxng.nix` | Node 包 | `pkgs.buildNpmPackage` → 输出 `packages.mcp-searxng` | [mcp-searxng](mcp-searxng.md) |
| obs-bilibili-stream | `packages/obs-bilibili-stream.nix` | OBS 插件 | `pkgs.callPackage` → 输出 `packages.obs-bilibili-stream` | [obs-bilibili-stream](obs-bilibili-stream.md) |
| opencode-telegram | `packages/opencode-telegram.nix` | Node 包 | `pkgs.buildNpmPackage` → 输出 `packages.opencode-telegram` | [opencode-telegram](opencode-telegram.md) |
| ruyi | `packages/ruyi.nix` | Python 包 (Poetry) | `pkgs.callPackage` → 输出 `packages.ruyi` | [ruyi](ruyi.md) |
| comfyui-strix-halo | `modules/comfyui-strix-halo.nix` | NixOS 模块 + 覆盖层组合 | 通过 `modules/comfyui-strix-halo.nix` 提供环境配置 | [comfyui-strix-halo](comfyui-strix-halo.md) |

### NixOS 模块

通过 `nix-kits.nixosModules.<name>` 引入，提供 systemd 服务和配置选项。

| 模块 | 路径 | 关联组件 | 文档 |
|------|------|---------|------|
| llama-cpp-rocm | `modules/llama-cpp-rocm.nix` | 覆盖层 `llama-cpp-rocm` | [llama-cpp-rocm](llama-cpp-rocm.md) |
| obs-bilibili-stream | `modules/obs-bilibili-stream.nix` | 包 `obs-bilibili-stream` | [obs-bilibili-stream](obs-bilibili-stream.md) |
| opencode-telegram | `modules/opencode-telegram.nix` | 包 `opencode-telegram` | [opencode-telegram](opencode-telegram.md) |
| comfyui-rocm-patch | `modules/comfyui-rocm-patch.nix` | 覆盖层 `comfyui-strix-halo` | [comfyui-strix-halo](comfyui-strix-halo.md) |
| rog-control-center-fix | `modules/rog-control-center-fix.nix` | 覆盖层 `rcc-fix` | [rcc-fix](rcc-fix.md) |
| ruyi | `modules/ruyi.nix` | 包 `ruyi` + 覆盖层 `ruyi-nixos-compat` | [ruyi](ruyi.md) |

### 独立覆盖层

不包含在 `overlays.default` 内，需显式添加到 `nixpkgs.overlays` 列表。

| 覆盖层 | 路径 | 依赖 | 加载方式 | 文档 |
|--------|------|------|---------|------|
| llama-cpp-rocm | `overlays/llama-cpp-rocm.nix` | `llama-cpp-ver` flake 输入 | `nix-kits.overlays.llama-cpp-rocm` | [llama-cpp-rocm](llama-cpp-rocm.md) |
| rcc-fix | `overlays/rog-control-center-fix.nix` | 无 | `nix-kits.overlays.rcc-fix` | [rcc-fix](rcc-fix.md) |
| ruyi-nixos-compat | `overlays/ruyi-nixos-compat.nix` | `ruyi` 包 + `patches/ruyi-nixos-compat.patch` | `nix-kits.overlays.ruyi-nixos-compat` | [ruyi-nixos-compat](ruyi-nixos-compat.md) |
| mihomo-alpha | `overlays/mihomo-alpha.nix` | `mihomo-ver` flake 输入 | `nix-kits.overlays.mihomo-alpha` | — |

### 独立补丁

| 补丁 | 路径 | 被引用方 | 文档 |
|------|------|---------|------|
| comfyui-nix-strix-halo | `patches/comfyui-nix-strix-halo.patch` | `comfyui-rocm-patch` 模块 | — |
| ruyi-nixos-compat | `patches/ruyi-nixos-compat.patch` | `ruyi-nixos-compat` 覆盖层 | — |
| rog-control-center-fix | `patches/rog-control-center-fix.patch` | `rcc-fix` 覆盖层 | — |

### AI 编码助手技能

按 `translate-*` 约定的自动发现机制。

| 技能 | 路径 | 触发方式 | 文档 |
|------|------|---------|------|
| nixkits-check-updates | `skills/nixkits-check-updates/SKILL.md` | "检查更新" → 自动执行，完成后触发 write-maintenance-log | [nixkits-check-updates](../zh/skills/nixkits-check-updates.md) |
| nixkits-skills | `skills/nixkits-skills/SKILL.md` | "安装技能" | [nixkits-skills](../zh/skills/nixkits-skills.md) |
| nixos-modern-cli | `skills/nixos-modern-cli/SKILL.md` | NixOS 环境自动激活 | [nixos-modern-cli](../zh/skills/nixos-modern-cli.md) |
| recover-nixos-config | `skills/recover-nixos-config/SKILL.md` | "恢复 /etc/nixos" | [recover-nixos-config](../zh/skills/recover-nixos-config.md) |
| translate-katalish | `skills/translate-katalish/SKILL.md` | `write-project-docs` 自动发现 → `language_code: katalish` | [translate-katalish](../zh/skills/translate-katalish.md) |
| translate-pseudocn | `skills/translate-pseudocn/SKILL.md` | `write-project-docs` 自动发现 → `language_code: pcn` | [translate-pseudocn](../zh/skills/translate-pseudocn.md) |
| write-maintenance-log | `skills/write-maintenance-log/SKILL.md` | `nixkits-check-updates` 完成时触发 / 手动 "记录修复" | [write-maintenance-log](../zh/skills/write-maintenance-log.md) |
| write-project-docs | `skills/write-project-docs/SKILL.md` | "生成文档" / "编写文档" | [write-project-docs](../zh/skills/write-project-docs.md) |

## 关系图

```
flake.nix
├── packages.* ← 6 个包（直接输出）
├── nixosModules.* ← 6 个模块
├── overlays.* ← 5 个覆盖层（各覆盖一个包）
│   ├── llama-cpp-rocm → 覆盖 pkgs.llama-cpp
│   ├── mihomo-alpha → 覆盖 pkgs.mihomo
│   ├── rcc-fix → 覆盖 pkgs.asusctl
│   └── ruyi-nixos-compat → 覆盖 pkgs.ruyi
└── skills/ ← 8 个 AI 技能
    ├── 独立技能: nixkits-skills, recover-nixos-config, nixos-modern-cli
    ├── 文档链: nixkits-check-updates → write-maintenance-log
    ├── 扩展语言: translate-katalish, translate-pseudocn
    └── 文档生成: write-project-docs → translate-* (自动发现)
```

### 组件与文档的关系

- **包**（7 个）：每个包对应 `packages/<name>.nix` 和一个多语言文档文件
- **模块**（6 个）：每个模块对应 `modules/<name>.nix` 和一个文档文件
- **覆盖层**（5 个）：每个覆盖层对应 `overlays/<name>.nix`
- **补丁**（3 个）：每个补丁对应 `patches/<name>.patch`，被覆盖层引用
- **技能**（8 个）：每个技能对应 `skills/<name>/SKILL.md` 和一个文档文件

### 包与覆盖层的关系

| 包 | 被覆盖层引用 | 关联模块 | flake 输出 |
|----|------------|---------|-----------|
| codewhale | — | — | `packages.codewhale` |
| kitsfmt | — | — | `packages.kitsfmt` |
| mcp-searxng | — | — | `packages.mcp-searxng` |
| obs-bilibili-stream | — | `obs-bilibili-stream` (服务模块) | `packages.obs-bilibili-stream` |
| opencode-telegram | — | `opencode-telegram` (服务模块) | `packages.opencode-telegram` |
| ruyi | `ruyi-nixos-compat` | `ruyi` (配置模块 + autoUpdate + buildTools) | `packages.ruyi` |
| llama-cpp | `llama-cpp-rocm` (rocm 构建覆盖) | `llama-cpp-rocm` (modelsPreset + 沙箱覆盖) | — (通过覆盖层使用) |
| mihomo | `mihomo-alpha` (Prerelease-Alpha 覆盖) | `mihomo` (nixpkgs 原模块) | — (通过覆盖层使用) |
| asusctl | `rcc-fix` (D-Bus 热插拔修复) | `rog-control-center-fix` (服务修复模块) | — (通过覆盖层使用) |
| comfyui | `comfyui-nix-strix-halo` (补丁) | `comfyui-strix-halo` (ROCm 环境配置) | — (通过覆盖层使用) |

## 多语言文档系统

### 语言映射

| 语言代码 | 显示名称 | 目录 | 文件命名 | 翻译人员 |
|---------|---------|------|---------|---------|
| zh | 中文 | `docs/zh/` | `<name>.md` (基准名称) | 狐莉 |
| en | English | `docs/en/` | `<name>.md` | 耳廓狐 (フェネック) |
| ja | 日本語 | `docs/ja/` | `<name>.md` | 尾巻 (オマキ) |
| katalish | ｶﾀﾘｯｼｭ | `docs/katalish/` | `<name>.md` | 小爪 (自动机器翻译) |
| pcn | 偽中国語 | `docs/pcn/` | `<name>.md` | 小爪 (自动机器翻译) |

### 语言切换器格式

**模块文档**（在 `docs/<lang>/` 下）：
```
[中文](project.md) | [English](../en/project.md) | [日本語](../ja/project.md) | [ｶﾀﾘｯｼｭ](../katalish/project.md) | [偽中国語](../pcn/project.md)
```

**技能文档**（在 `docs/<lang>/skills/` 下）：
```
[中文](<name>.md) | [English](../../en/skills/<name>.md) | [日本語](../../ja/skills/<name>.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/<name>.md)
```

### 扩展语言自动发现

`translate-*` 技能通过 `write-project-docs` 的扫描机制自动发现：

```
skills/translate-*/SKILL.md → frontmatter 中的 language_code 和 display_name
```

当前已安装的扩展语言：
- `translate-katalish`: `language_code: katalish` → 片假名英语
- `translate-pseudocn`: `language_code: pcn` → 伪中国语

### 维护日志系统

由 `write-maintenance-log` 技能驱动，自动关联 git commit 和三语同步。

维护日志采用**作为代码的文档**映射表（5 语言 × 5 字段），包含以下字段：
- `TITLE` — 文档标题
- `SUBTITLE` — 子标题
- `SUMMARY` — 摘要前缀
- `COMMIT_HDR` — 提交表头
- `SW_TABLE_HDR` — 软件表头

## Nix Flake 输出结构

```
nix-kits
├── packages          # 7 个可构建包
├── nixosModules      # 6 个 NixOS 模块
├── overlays          # 5 个覆盖层
│   ├── default       # 默认覆盖层（包含所有不以独立形式存在的包）
│   ├── llama-cpp-rocm
│   ├── mihomo-alpha
│   ├── rcc-fix
│   └── ruyi-nixos-compat
└── devShells.ruyi    # ruyi 开发环境
```

## 使用方式

### 加载 NixKits

```nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nix-kits, ... }: {
    nixosConfigurations.<host> = nixpkgs.lib.nixosSystem {
      modules = [
        nix-kits.nixosModules.llama-cpp-rocm    # 覆盖 llama-cpp + 服务
        nix-kits.nixosModules.comfyui-strix-halo # ROCm 环境 + 覆盖
        nix-kits.nixosModules.ruyi               # ruyi 配置
        {
          nixpkgs.overlays = [
            nix-kits.overlays.default
            nix-kits.overlays.llama-cpp-rocm    # ROCm 加速构建
            nix-kits.overlays.mihomo-alpha      # Prerelease-Alpha
            nix-kits.overlays.rcc-fix           # asusctl 修复
            nix-kits.overlays.ruyi-nixos-compat # NixOS 运行时兼容
          ];
        }
      ];
    };
  };
}
```

### 使用 devShell

```bash
nix registry add nix-kits github:Kihara777/NixKits
nix develop nix-kits#ruyi
```

## 文档编写规范

参见 [write-project-docs 技能](skills/write-project-docs.md)。

- **中文基准**：所有文档先写中文版本，再翻译到其他语言
- **表驱动格式**：组件使用表格进行分类，保持简洁
- **四段式结构**：基本信息 → 安装/使用 → 引用 → 修正内容
- **语言切换器**：每个文档开头包含完整的多语言链接
- **技能自动发现**：`translate-*` 技能通过 `write-project-docs` 自动整合
- **维护日志同步**：软件更新后自动写入 MAINTENANCE.md 并同步三语版本
