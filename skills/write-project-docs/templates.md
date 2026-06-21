# 文档模板

NixKits 风格的完整文档模板集。正文参考 [`SKILL.md`](SKILL.md) 中的编写规则。

## 目录结构

```
<project>/
├── README.md          # 主语言 README（中文）
├── MAINTENANCE.md     # 维护记录（中文）
├── docs/
│   ├── README.en.md   # 英文 README
│   ├── README.ja.md   # 日文 README
│   ├── MAINTENANCE.en.md
│   ├── MAINTENANCE.ja.md
│   ├── zh/            # 中文文档
│   │   ├── <module>.md
│   │   └── skills/
│   ├── en/            # 英文文档
│   └── ja/            # 日文文档
```

> **规则**：根目录仅保留中文（无语言后缀）`.md` 文件。所有本地化版本移入 `docs/`，文件名保持不变。扩展语言目录通过 `skills/translate-*/SKILL.md` frontmatter 自动发现。

## 模块文档模板

```markdown
# <module-name>

[中文](<module>.md) | [English](../en/<module>.md) | [日本語](../ja/<module>.md)

<一行描述>

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | <type> |
| ... | ... |

## 安装

<install>

## 缓存

可通过 <project> 二进制缓存获取，避免本地编译：

```bash
cachix use <project>
```

或 NixOS 配置添加：

```nix
nix.settings.substituters = [ "https://<project>.cachix.org" ];
nix.settings.trusted-public-keys = [ "<project>.cachix.org-1:<key>" ];
```
```

- 语言切换器路径按各语言目录计算
- 自身语言不加链接（纯文本）
- 扩展语言切换器从英文/日文源按 display_name 生成

## 技能文档模板

```markdown
# <skill-name> (Skill)

[中文](<skill>.md) | [English](../../en/skills/<skill>.md) | [日本語](../../ja/skills/<skill>.md)

> <一行摘要>

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/<skill>.md` |

## 功能

- <功能列表>

## 使用

<触发条件或使用方法>
```

## README 模板

```markdown
# <Project Name>

[![CI](https://github.com/<org>/<repo>/actions/workflows/check.yml/badge.svg)](https://github.com/<org>/<repo>/actions/workflows/check.yml) [![Cache](https://img.shields.io/badge/cache-cachix-blue)](https://app.cachix.org/cache/<project>) [![NixOS](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos)](https://nixos.org)

[中文](README.md) | [English](docs/README.en.md) | [日本語](docs/README.ja.md)

<一行项目描述>

## 添加

```nix
inputs.<project>.url = "github:<org>/<repo>";
```

> **二进制缓存**（避免本地编译）：
>
> ```bash
> cachix use <project>       # 或 nix profile install nixpkgs#cachix 后执行
> ```
>
> 或 NixOS 配置：
> ```nix
> nix.settings.substituters = [ "https://<project>.cachix.org" ];
> nix.settings.trusted-public-keys = [ "<project>.cachix.org-1:<key>" ];
> ```
>
> 缓存由 CI 自动构建推送（x86_64-linux）。aarch64 / riscv64 暂不支持 CI 构建，可通过本地 `cachix push` 手动推送。

## <分类 1>

| 模块 | 说明 | 文档 |
|------|------|------|
| <模块名> | <描述> | [<语言>/<模块>.md](<语言>/<模块>.md) |

## <分类 N>

...

## 开发

```bash
nix registry add <project> <remote-url>
```

| 包 | `nix develop` |
|-----|---------------|
| <pkg> | `nix develop <project>#<pkg>` |

## 作者

<作者信息>

## 许可

<license>
```

多语言 README 的「文档」列中的 `<语言>` 替换为当前语言的目录代码。CI 徽章和缓存配置块仅当项目实际配置了 CI 和 Cachix 时才包含。

## 缓存外项目警告

在 README 的软件表和补丁表之后，使用引用块标注不在二进制缓存中的项目：

```markdown
> ⚠️ <name> 为模块+补丁，非独立软件包，不在二进制缓存中。
```

```markdown
> ⚠️ 补丁均为 overlay，修改上游 nixpkgs 包而非独立构建，不在二进制缓存中。
> 动态追踪版本的项目其 hash 随上游发布变化，无法被缓存固定。
```

这些警告仅当项目中存在非缓存的 overlay / 模块+补丁 条目时才添加。

## 包文档 CI 徽章

在每个包文档的标题后、语言切换器前，添加双架构构建状态徽章（每架构独立一行，末尾与语言切换器间保留空行）：

```markdown
# <package-name>

[![x86_64](...)](...)
[![aarch64](...)](...)

[中文](...) | [English](...) | ...
```

Job name 必须 URL 编码（空格→`%20`、括号→`%28`/`%29`、逗号→`%2C`）。


