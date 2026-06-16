---
name: nixkits-check-updates
description: 检查 NixKits 所有软件包的上游版本更新并自动应用。检测新版本、更新构建配置（版本号、hash、meta）、更新文档、报告本地安装版本。
---

# NixKits 软件包更新检查

检查 NixKits 各软件包的上游发布更新，执行版本升级，并更新文档。

## 排除的软件包

以下类别**不检查**（无固定上游发布版本）。通过 `.nix` 文件特征自动分类：

- **自建软件包**：`src` 指向本地路径（`./` 或 `../` 开头），如 `rustPlatform.buildRustPackage { src = ./src; }`
- **动态版本追踪**：`version` 从外部输入动态读取，如 `builtins.readFile`、URL 抓取、`flake` input
- **跟随 nixpkgs 版本**：使用 `overrideAttrs` 仅追加 patch，不定义独立 version
- **补丁内硬编码版本**：`.patch` 文件中直接包含 `${version}` 或 wheel URL 及 hash（见下方「检查补丁内版本」节）

`flake.nix` → `packages` 中的其余包均自动纳入检查。

## 第 1 步：确认本地仓库

```bash
# 通过 flake.nix 自动发现项目名
test -f flake.nix && echo "OK: $(grep -oP 'description\s*=\s*"\K[^"]+' flake.nix | head -1)" || echo "ERROR: not in a flake project"
```

## 第 2 步：发现待检查的软件包

从 `flake.nix` 的 packages 段自动提取，再按排除规则过滤：

```bash
# 自动发现所有被 callPackage 引用的包文件
grep -oP '\./[a-zA-Z0-9_/-]+\.nix' flake.nix | sort -u > /tmp/all_pkgs.txt

# 排除自建包（src 包含 ./ 或 ../）
while read f; do
  grep -q 'src\s*=\s*\./\.\.\|src\s*=\s*\.\/' "$f" 2>/dev/null && echo "SKIP self-hosted: $f"
done < /tmp/all_pkgs.txt

# 剩余包即为外部更新候选
```

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
6. 运行 `nix build .#<pkg>` 验证构建成功

### cmake 包

1. 更新 `version` 字符串
2. 将 `fetchFromGitHub` 的 `hash` 置空
3. 运行 `nix build .#<pkg>` 获取正确的 hash
4. 更新 hash
5. 运行 `nix build .#<pkg>` 验证构建成功

### 预编译二进制包（fetchurl）

1. 更新 `version` 字符串及所有下载 URL
2. 将所有 `hash` 值置空
3. 运行 `nix build .#<pkg>` 获取各二进制 hash（可能需要多次，每次获取一个 hash）
4. 逐一更新 hash
5. 运行 `nix build .#<pkg>` 验证构建成功

### flake.lock 同步

#### 前置检测

根据仓库状态决定如何处理 `flake.lock`：

```bash
# 情况 1：flake.lock 已被 .gitignore 排除 → 跳过，无需提交
if grep -qx 'flake.lock' .gitignore 2>/dev/null; then
  echo "SKIP: flake.lock 已在 .gitignore 中，无需提交"
  exit 0
fi

# 情况 2：仓库包含动态版本包 → 必须排除 flake.lock
# 检测特征：builtins.fetchurl 无 hash 参数、flake input 指向 API URL 等
if grep -rq 'builtins.fetchurl.*releases/latest\|\.url\s*=\s*"https\?://api\.' \
   overlays/ flake.nix 2>/dev/null; then
  echo "WARN: 检测到动态版本包，flake.lock 不可复现"
  if ! grep -qx 'flake.lock' .gitignore 2>/dev/null; then
    echo "flake.lock" >> .gitignore
    echo "已添加 flake.lock 到 .gitignore"
  fi
  exit 0
fi
```

> **判断逻辑**：已排除 → 跳过；有动态版本 → 必须排除；其他情况 → 正常提交。

#### 提交要求

在不属于上述两种情况时，每次 `nix build` 后 Nix 会根据实际获取的资源更新 `flake.lock` 中的 input hash。
**必须在提交 hash 变更的同时提交 `flake.lock`**，确保锁文件与包定义一致。

```bash
# 验证 flake.lock 是否有未提交的变更
git diff flake.lock
```

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

每次软件更新或错误修复后，在 `MAINTENANCE.md` 中追加记录。遵循以下规则：

### 记录时机

- **软件版本变更**：上游发布新版时记录（原有规则）
- **错误修复**：修复了影响功能的 bug 时记录（即使无版本变更）
- **文档更新默认不记录**：仅涉及文档的提交不写入维护记录

### 格式规则

- **LIFO 顺序**：最新记录插入文件顶部（紧随 `---` 分隔线之后）
- **章节标题**：ISO 8601 精确到秒的日期时间（`YYYY-MM-DDTHH:MM:SS+09:00`）
  时间来源必须为 `git log -1 --format="%ai"` 提取的实际 commit 时间，**禁止使用占位符**
- **摘要行**：每条记录以粗体 `**摘要**` 开头，一句话说明本次更新内容（允许从上游 release note 摘录）
- **关联提交表**：列出本次变更相关的所有 commit id 及说明
- **软件版本表**：仅在有版本变更时出现（格式同旧版）
  - 已有软件更新：旧版本 → 新版本
  - 首次添加的软件：新旧版本列合并为一列，显示 `新增 v<version>`
  - 仅**有变更的 hash** 占据后续行
- **纯 bug 修复无版本变更**：省略软件版本表，仅保留摘要和提交表
- **三语同步**：每次更新需同步 `MAINTENANCE.md` `docs/MAINTENANCE.en.md` `docs/MAINTENANCE.ja.md` 三个文件
- **标题**：使用描述性标题而非文件名：zh `# 维护日志`、en `# Maintenance Log`、ja `# メンテナンスログ`

### 示例格式

**软件更新**：

```markdown
## 2026-06-14T07:56:11+09:00

**摘要**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；mcp-searxng 1.4.0 — 新增 HTTP 传输模式

| 提交 | 说明 |
|------|------|
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `ec7d5ca` | docs(MAINTENANCE): record 2026-06-14 updates |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
```

**错误修复**：

```markdown
## 2026-06-16TXX:XX:XX+09:00

**摘要**：修复 mcp-searxng 入口文件错误 — dist/index.js → dist/cli.js，MCP 服务器可正常启动

| 提交 | 说明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point |
```

## 检查补丁内版本

部分补丁在上游项目的 `.patch` 文件中直接硬编码了依赖的版本号和 hash。
这类补丁的版本更新需要手动处理。

### 识别

在 `patches/` 目录下自动搜索硬编码版本：

```bash
# 搜索 patch 文件中的版本号模式
grep -rln -E '[0-9]+\.[0-9]+\.[0-9]+' patches/*.patch | sort -u

# 对每个匹配的 patch，提取版本上下文
for patch in $(grep -rln -E '[0-9]+\.[0-9]+\.[0-9]+' patches/*.patch); do
  echo "=== $patch ==="
  grep -n -E 'version|hash|url.*http' "$patch" | head -10
done
```

### 通用更新流程

1. 从 patch 中提取上游资源 URL 和当前版本
2. 检查上游是否有新版本：

```bash
# GitHub Release（如适用）
curl -s "https://api.github.com/repos/<owner>/<repo>/releases/latest" | grep -oP '"tag_name":\s*"\K[^"]+'

# PyPI / wheel 目录（如适用）
curl -s "<wheel-index-url>" | grep -oP '<package>-[0-9]+\.[0-9]+\.[0-9]+' | sort -Vu | tail -1
```

3. 下载新资源获取 SRI hash：

```bash
nix hash to-sri sha256:$(curl -sL <new-url> | sha256sum | cut -d' ' -f1)
```

4. 更新 patch 文件中对应的 `version`、`url`、`hash` 字段
5. 重新生成 patch：在上游仓库中修改后执行 `git diff > patches/<name>.patch`
6. 在目标环境测试构建

> **⚠️ 警告**：补丁内版本更新后，旧的 hash 将失效。务必在提交前完成完整的构建测试。
> 涉及 GPU/硬件相关补丁时，需在目标硬件上实测验证。
