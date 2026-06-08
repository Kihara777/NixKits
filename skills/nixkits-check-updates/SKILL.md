---
name: nixkits-check-updates
description: 检查 NixKits 所有软件包的上游版本更新并自动应用。检测新版本、更新构建配置（版本号、hash、meta）、更新文档、报告本地安装版本。
---

# NixKits 软件包更新检查

检查 NixKits 各软件包的上游发布更新，执行版本升级，并更新文档。

## 排除的软件包

以下**不检查**（无固定上游发布版本）：

- 自建软件包（源码为 `./kitsfmt-src` 或类似目录）
- 动态版本追踪（如 `llama-cpp-rocm` — 构建时获取最新版）
- 跟随 nixpkgs 版本（如 `rcc-fix` — 跟随 nixpkgs 版本号）
- 补丁内硬编码版本（如 `comfyui-strix-halo` — 上游 wheel 版本嵌入在 `.patch` 文件中，见下方「检查补丁内版本」节）

`flake.nix` → `packages` 中的其余所有包均需检查。

## 第 1 步：确认本地 NixKits 仓库

```bash
test -f flake.nix && grep -q "NixKits" flake.nix && echo "OK: NixKits repo" || echo "ERROR: not in NixKits repo"
```

## 第 2 步：发现待检查的软件包

读取 `flake.nix` 的 packages 段，找出所有外部包：

```bash
# 提取使用 fetchFromGitHub 或 fetchurl 的包名
grep -B1 "fetchFromGitHub\|fetchurl" flake.nix packages/*.nix | grep -oP '(?<=packages\.)\w+|(?<=pkgs\.callPackage \./packages/)\w+'
```

排除已知的自建/动态/nixpkgs 包。剩余的包需要检查。

## 第 3 步：检查上游版本

对每个发现的外部包，从其 `.nix` 文件确定上游仓库，然后比对：

```bash
check() {
  local pkg="$1" current="$2" repo="$3"
  latest=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -oP '"tag_name":\s*"\K[^"]+')
  if [ "$current" != "$latest" ]; then
    echo "UPDATE: $pkg  $current → $latest"
  else
    echo "OK: $pkg  $current"
  fi
}
```

## 第 4 步：更新构建配置

> **⚠️ hash 计算注意事项**
>
> - SRI hash 格式必须使用标准 base64（`+` `/` `=`），**不能**使用 URL-safe base64（`-` `_`）。
>   用 `nix hash to-sri --type sha256 <hash>` 或 `nix-prefetch-url --type sha256 <url>` 获取正确格式
> - `fetchFromGitHub` 的 source hash **不能**从 GitHub archive tarball（`/archive/refs/tags/`）预计算 —
>   两者可能不同。必须通过 `nix build` 的 hash mismatch 错误获取
> - `npmDepsHash` 不能设为空字符串 `""`。清空时使用 `lib.fakeHash` 占位
> - npm 包需要两次 `nix build`：第一次获取 source hash，第二次获取 npmDepsHash。
>   如果 source hash 已知正确，可只清空 npmDepsHash 一次构建完成

对每个有更新的包：

### npm 包

1. 更新 `.nix` 文件中的 `version` 字符串
2. 将 `fetchFromGitHub` 的 `hash` 置为空占位符
3. 将 `npmDepsHash` 置为空占位符
4. 运行 `nix build .#<pkg>` 两次 — 第一次获取源码 hash，第二次获取 npmDepsHash
5. 用实际值更新两个 hash

### cmake 包

1. 更新 `version` 字符串
2. 将 `fetchFromGitHub` 的 `hash` 置空
3. 运行 `nix build .#<pkg>` 获取正确的 hash
4. 更新 hash

### 预编译二进制包（fetchurl）

1. 更新 `version` 字符串及所有下载 URL
2. 将所有 `hash` 值置空
3. 运行 `nix build .#<pkg>` 获取各二进制 hash
4. 逐一更新 hash

## 第 5 步：更新文档

对每个更新的包，在三种语言文档中更新版本号：

```bash
for lang in zh en ja; do
  sed -i "s/$OLD_VER/$NEW_VER/g" docs/$lang/<pkg>.md
done
```

同时检查并更新 `.nix` 文件中的 `meta.changelog` URL。

## 第 6 步：检查本地安装版本

```bash
nix eval --raw .#<pkg>.version 2>/dev/null
which <binary> 2>/dev/null && <binary> --version 2>/dev/null
```

## 第 7 步：输出汇总报告

以表格呈现：包名、旧版本 → 新版本、构建状态、本地安装版本。

## 第 8 步：更新维护记录

每次软件更新后，在 `MAINTENANCE.md` 中追加记录。遵循以下规则：

- **LIFO 顺序**：最新更新插入文件顶部（紧随 `---` 分隔线之后）。越早的更新越靠下
- **章节标题**：ISO 8601 精确到秒的日期时间（`YYYY-MM-DDTHH:MM:SS+09:00`）
- **章节开头**：三行三语摘要（中文 / English / 日本語），格式为「软件更新：<内容>」
- **变更内容**：列出每个包的 `packages/<name>.nix` 路径、版本变更、hash 变更、构建验证状态、上游发布 URL
- **文档**：列出同步更新的文档文件

示例格式：

```markdown
## 2026-06-08T14:25:02+09:00

软件更新：mcp-searxng 1.1.0 → 1.2.1

Package update: mcp-searxng 1.1.0 → 1.2.1

パッケージ更新：mcp-searxng 1.1.0 → 1.2.1

### 变更内容

- **mcp-searxng** (`packages/mcp-searxng.nix`)
  - 版本号：`1.1.0` → `1.2.1`
  - source hash：未变（`sha256-...`）
  - npmDepsHash：未变（`sha256-...`）
  - 构建验证：`/nix/store/...-mcp-searxng-1.2.1` ✅
  - 上游发布：<https://github.com/ihor-sokoliuk/MCP-searxng/releases/tag/v1.2.1>

### 文档

- `docs/zh/mcp-searxng.md` `docs/en/mcp-searxng.md` `docs/ja/mcp-searxng.md` — 版本号同步
```

## 检查补丁内版本

部分 NixKits 补丁（如 `comfyui-strix-halo`）在上游项目的补丁文件中直接硬编码了
依赖的版本号和 hash，而非通过独立的 `.nix` 包定义管理。这类补丁的版本更新需要手动处理。

### 识别

在 `patches/` 目录下搜索硬编码版本：

```bash
grep -rn 'version\|torch\|wheel' patches/*.patch | grep -E '[0-9]+\.[0-9]+\.[0-9]+'
```

### 检查 comfyui-strix-halo 的 PyTorch ROCm wheel 更新

该补丁的版本定义位于 patch 文件内的 `nix/versions.nix` 段：

```bash
# 提取当前版本
grep -A2 'rocm72' patches/comfyui-nix-strix-halo.patch | grep -E '(torch|torchvision|torchaudio|version)'
```

检查上游是否有新 wheel 发布：

```bash
# 检查 PyTorch ROCm wheel 目录
curl -s https://download.pytorch.org/whl/rocm7.2/ | grep -oP 'torch-[0-9]+\.[0-9]+\.[0-9]+' | sort -Vu | tail -1

# 或检查 comfyui-nix 上游是否已更新 versions.nix
curl -s https://raw.githubusercontent.com/utensils/comfyui-nix/main/nix/versions.nix | grep -A4 'rocm72'
```

### 更新流程

1. 确认新版本在目标硬件上可用（Strix Halo 需要实测验证）
2. 从 `https://download.pytorch.org/whl/rocm7.2/` 下载新 wheel 获取 SRI hash：

```bash
nix hash to-sri sha256:$(curl -sL <wheel-url> | sha256sum | cut -d' ' -f1)
```

3. 更新补丁文件中对应的 `version`、`url`、`hash` 字段
4. 如果补丁引用了新 ROCm 主版本（如 `rocm7.3`），需要同步修改 `python-overrides.nix` 段中的版本选择逻辑
5. 重新生成补丁：在 `comfyui-nix` 仓库中修改后执行 `git diff > patches/comfyui-nix-strix-halo.patch`
6. 在目标硬件上测试构建和推理

> **⚠️ 警告**：补丁内版本更新后，旧的 hash 将失效。务必在提交前完成完整的构建测试。
