---
name: nix-flake-update-check
description: 检查任意 nix flake 仓库中软件包的上游版本更新并升级——按包型（npm / cmake / Rust / fetchurl / python）分流的 hash 更新流程、Dependabot 自动 PR 的 hash 修补、flake.lock 处置、补丁内版本检查与 nixpkgs 漂移陷阱。仓库特有的文档与日志环节经「仓库适配层」注入。
---

# nix flake 软件包更新检查（通用）

检查 nix flake 仓库中各软件包的上游发布更新并执行版本升级。

本技能只包含**与仓库无关**的通用方法。仓库特有的环节（文档同步、维护日志、
内置插件清单等）由**仓库适配层**提供——见文末「仓库适配层」。

## 适用前提

- 仓库是 nix flake（根目录存在 `flake.nix`）。
- 包定义以独立 `.nix` 文件形式存在，通常位于 `packages/`（或其他目录），
  由 `flake.nix` 经 `callPackage` 引用。
- 若仓库布局不同（如所有包写在单个 `flake.nix`、或位于 `nix/` 等目录），
  以第 2 步的自动发现结果为准，不必强行套用目录名。

## 第 1 步：确认本地仓库

```bash
test -f flake.nix && echo "OK: $(grep -oP 'description\s*=\s*"\K[^"]+' flake.nix | head -1)" || echo "ERROR: not in a flake project"
```

## 第 2 步：发现待检查的软件包

从 `flake.nix` 自动提取被 `callPackage` 引用的包文件，再按排除规则过滤。
**不要硬编码包列表**——从仓库现状动态发现：

```bash
# 自动发现所有被引用的包文件（按仓库实际路径调整正则）
grep -oP '\./[a-zA-Z0-9_/-]+\.nix' flake.nix | sort -u > /tmp/all_pkgs.txt

# 排除自建包（src 指向本地路径）
while read -r f; do
  grep -q 'src\s*=\s*\./\.\.\|src\s*=\s*\.\/' "$f" 2>/dev/null && echo "SKIP self-hosted: $f"
done < /tmp/all_pkgs.txt
```

`flake.nix` 中 packages 段的其余包均纳入检查。

## 排除的软件包

以下类别**不检查**（无固定上游发布版本）。通过 `.nix` 文件特征自动分类：

- **自建软件包**：`src` 指向本地路径（`./` 或 `../` 开头），如
  `rustPlatform.buildRustPackage { src = ./src; }`
- **动态版本追踪**：`version` 从外部输入动态读取，如 `builtins.readFile`、URL 抓取、flake input
- **跟随 nixpkgs 版本**：使用 `overrideAttrs` 仅追加 patch，不定义独立 version
- **补丁内硬编码版本**：`.patch` 文件中直接包含 `${version}` 或 wheel URL 及 hash
  （见下方「检查补丁内版本」节）

## 第 3 步：检查上游版本

对每个外部包，从其 `.nix` 文件确定上游仓库，然后比对：

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

上游不一定用 GitHub Release。按实际来源选择：GitHub tag（`/tags`）、PyPI
（`/pypi/<pkg>/json`）、crates.io（`/api/v1/crates/<pkg>`）、上游 CHANGELOG 等。

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

按包型选择对应流程。**包型由 `.nix` 文件中的 builder 决定**，不是由包名决定。

### npm 包

1. 更新 `.nix` 文件中的 `version` 字符串
2. 将 `fetchFromGitHub` 的 `hash` 置为空占位符
3. 将 `npmDepsHash` 置为空占位符
4. 运行 `nix build .#<pkg>` 两次 — 第一次获取源码 hash，第二次获取 npmDepsHash
5. 用实际值更新两个 hash
6. 运行 `nix build .#<pkg>` 验证构建成功

#### Dependabot 的自动 PR 不能直接合并

若仓库启用了 Dependabot，它的 npm 更新 PR **必然无法通过 CI**——这是结构性错配，不是配置错误：

| Dependabot 会改 | Dependabot 不知道 |
|---|---|
| `package.json` | `.nix` 文件里的 `npmDepsHash` |
| `package-lock.json` | `buildNpmPackage` 会把 src 的 lock 与 npm-deps 产物**逐字节**校验 |

症状固定为：

```
ERROR: npmDepsHash is out of date
The package-lock.json in src is not the same as the in /nix/store/...-npm-deps
```

**处置**：不要直接合并，也不要简单地关掉。取回分支后补一次 hash：

```bash
gh pr checkout <n>
sed -i 's|npmDepsHash = "sha256-[^"]*";|npmDepsHash = lib.fakeHash;|' packages/<pkg>.nix
nix build .#<pkg> 2>&1 | grep -oP 'got:\s+\Ksha256-[A-Za-z0-9+/=]+'   # 取实际值回填
```

> ⚠️ **同时核对目标版本是否落后**：Dependabot 只在其配置的 semver 通道内推进
> （如 `0.1.2-alpha.2` → `0.1.2-rc.1`），不会跨到 `next` / `alpha` 这类 dist-tag。
> 若宿主或生态已用更新的通道，直接手动指定该版本更有意义：
>
> ```bash
> npm view <pkg> dist-tags          # 查看 latest / next / alpha 各指向何处
> ```
>
> 判据：**被包装的库若在运行时与宿主交互**（如插件依赖宿主框架），应让版本与宿主对齐，
> 而非停留在旧通道——否则插件内嵌的副本会长期落后于宿主树。

### cmake 包

1. 更新 `version` 字符串
2. 将 `fetchFromGitHub` 的 `hash` 置空
3. 运行 `nix build .#<pkg>` 获取正确的 hash
4. 更新 hash
5. 运行 `nix build .#<pkg>` 验证构建成功

### Rust 包（buildRustPackage）

`rustPlatform.buildRustPackage` 通过 `cargoLock.lockFile` 声明式锁定依赖，
不会自动生成 lock 文件。**版本升级必须同步三处**：

1. 更新 `version` 字符串
2. 将 `fetchFromGitHub` 的 `hash` 置空，`nix build` 获取正确 hash 后更新
3. **同步 `Cargo.lock`**（最容易遗漏）：
   - 上游发布新 tag 时，源码中的 `Cargo.lock` 依赖集可能变化
   - 从上游仓库下载对应 tag 的 lock 文件覆盖本地副本：
     ```bash
     curl -sL "https://raw.githubusercontent.com/<owner>/<repo>/v<version>/Cargo.lock" \
       -o <local-lock-file>
     ```
   - 验证条目数是否变化（`grep -c '^name = '`），变化即说明依赖集更新，必须同步
   - 本地 lock 副本名通常形如 `<pkg>-src-Cargo.lock`，与上游内容不一致时构建报
     `lock file ... needs to be updated` 或 hash 校验失败
4. 运行 `nix build .#<pkg>` 验证构建成功

### 预编译二进制包（fetchurl）

1. 更新 `version` 字符串及所有下载 URL
2. 将所有 `hash` 值置空
3. 运行 `nix build .#<pkg>` 获取各二进制 hash（可能需要多次，每次获取一个 hash）
4. 逐一更新 hash
5. 运行 `nix build .#<pkg>` 验证构建成功

> **交叉编译注意**：riscv64 等交叉构建 eval 可能超时。获取 `fetchFromGitHub`
> source hash 的正确姿势：
> - **禁止**用 `nix-prefetch-url` 预取
>   `https://github.com/<owner>/<repo>/archive/v<version>.tar.gz` 的 hash ——
>   archive tarball 与 `fetchFromGitHub`（git 协议）hash **不一致**，会导致 CI
>   构建失败（`hash mismatch ... got:` 与本地预取值不同）。
> - 正确方法：用任意 nixpkgs 的 `fetchFromGitHub` + 占位 hash 构建一次，从报错中获取 got 值：
>   ```bash
>   nix build --impure --expr '
>   let pkgs = import (builtins.getFlake "/path/to/flake").inputs.nixpkgs.legacyPackages.x86_64-linux;
>   in pkgs.fetchFromGitHub { owner = "<owner>"; repo = "<repo>"; rev = "v<version>"; hash = lib.fakeHash; }
>   ' 2>&1 | grep got:
>   ```

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

在不属于上述两种情况时，每次 `nix build` 后 Nix 会根据实际获取的资源更新
`flake.lock` 中的 input hash。**必须在提交 hash 变更的同时提交 `flake.lock`**，
确保锁文件与包定义一致。

```bash
git diff flake.lock
```

## 第 5 步：更新文档

**文档布局因仓库而异。** 按仓库实际结构选择：

- 若仓库有 `docs/<lang>/<pkg>.md` 多语体系 → 在各语言文档中同步版本号
- 若仓库只有单语 README / 包内注释 → 更新对应位置
- 若仓库无文档 → 跳过本步

```bash
# 多语示例（语言列表从仓库实际目录发现，不要硬编码）
for lang in $(ls docs/ | grep -v '\.md$'); do
  [ -f "docs/$lang/<pkg>.md" ] && sed -i "s/$OLD_VER/$NEW_VER/g" "docs/$lang/<pkg>.md"
done
```

同时检查并更新 `.nix` 文件中的 `meta.changelog` URL。

> 仓库若有**额外的文档同步要求**（如内置插件清单、特定章节），由仓库适配层补充。

## 第 6 步：检查本地安装版本

```bash
nix eval --raw .#<pkg>.version 2>/dev/null
which <binary> 2>/dev/null && <binary> --version 2>/dev/null
```

## 第 7 步：输出汇总报告

以表格呈现：包名、旧版本 → 新版本、构建状态、本地安装版本。

## 第 8 步：记录变更

按仓库约定记录本次更新（维护日志 / CHANGELOG / 无）。NixKits 仓库的对应
技能为 `write-maintenance-log`，由仓库适配层指定。

## 检查补丁内版本

部分补丁在上游项目的 `.patch` 文件中直接硬编码了依赖的版本号和 hash。
这类补丁的版本更新需要手动处理。

### 识别

```bash
# 搜索 patch 文件中的版本号模式（目录名按仓库实际调整）
grep -rln -E '[0-9]+\.[0-9]+\.[0-9]+' patches/*.patch | sort -u

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

> **⚠️ 警告**：补丁内版本更新后，旧的 hash 将失效。务必在提交前完成完整的
> 构建测试。涉及 GPU/硬件相关补丁时，需在目标硬件上实测验证。

## 常见陷阱（nixpkgs 漂移）

更新后若系统切换（`nixos-rebuild switch` / `darwin-rebuild switch`）失败，
优先排查以下 nixpkgs 漂移陷阱。

### 1. 恢复旧 generation / flake.lock 时必须核对 `inputs.*.follows`

只复制旧 `flake.lock` 而忽略 `flake.nix` 会丢失 `inputs.<x>.follows` 配置，
导致子 flake 重新用独立锁定的旧 nixpkgs（如 glibc 2.40）→ 运行时
`GLIBC_ABI_GNU2_TLS` 崩溃。恢复时需同时核对 `flake.nix` 中子 flake 的
follows/url 定义，并验证 eval 出的实际 nixpkgs rev。

### 2. python 包跳过测试用 `doInstallCheck = false`，不是 `doCheck = false`

`pytestCheckHook` 把 pytest 套件跑在 **installCheckPhase**，`doCheck=false`
无效（测试仍执行）。跳过测试必须设置 `doInstallCheck = false`。

### 3. nixpkgs ≥ 2026-08-05 的 `pythonRuntimeDepsCheckHook` 破坏 wheel 构建

新版 nixpkgs 引入 `pythonRuntimeDepsCheckHook`：wheel 的 METADATA 声明了运行时
依赖（由运行环境提供）时构建失败。对策：在 vendored wheel 的 mkWheel 中加
`dontCheckRuntimeDeps = true`。

### 4. 无参数 `nix flake lock` 会刷新所有浮动 input（nixpkgs 漂移重演）

`nix flake lock`（不带参数）会把所有浮动引用的 input（如
`nixpkgs.url = ".../nixos-unstable"`）更新到最新版本。恢复旧 generation /
固定依赖后若需重新 lock：

- ✅ 用 `nix flake lock --update-input <name>` 只更新目标 input
- ✅ 或直接在 `flake.nix` 中把 nixpkgs 固定到已验证 rev（`github:nixos/nixpkgs/<full-rev>`）
- ❌ 避免无参数 `nix flake lock` —— 会把 nixpkgs 漂移到新版本，触发新的
  `pythonRuntimeDepsCheckHook` / flaky 测试失败

> 判断方法：报错含 `pythonRuntimeDepsCheckHook` / `not installed` /
> `GLIBC_ABI_GNU2_TLS` 且位于 python 包构建阶段 → 命中陷阱 2 或 3；
> 位于服务启动阶段 → 命中陷阱 1。

## 仓库适配层

通用流程覆盖到第 8 步为止。**仓库特有的环节不由本技能定义**，而由该仓库的
适配层技能补充。若当前仓库存在适配层技能，先加载它，再执行本技能；两者冲突时
以适配层为准（适配层了解本仓库的真实约定）。

适配层通常补充以下内容：

| 环节 | 适配层需说明的内容 |
|---|---|
| 文档同步（第 5 步） | 文档路径、语言清单、需同步的特殊章节 |
| 变更记录（第 8 步） | 该仓库使用的记录技能或文件（如维护日志） |
| 动态版本输入 | 仓库是否有不可锁定的浮动 input，及其影响 |
| 已知事故教训 | 该仓库历史上因更新导致的故障与规避方式 |
| 额外同步项 | 内置清单、生成文件等需随版本一并更新的内容 |
