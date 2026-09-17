---
name: nix-flake-update-check
description: 检查任意 nix flake 仓库中软件包的上游版本更新并升级——按包型（npm / cmake / Rust / fetchurl / python）分流的 hash 更新流程与自托管 forge（Gitea）取源、开工前的交互式澄清（支持提问的智能体须主动使用以确保一次跑完）、同账户子项目的链式并行检查（含回环与依赖冲突防护）、文档外部链接的失效审计、GitHub Actions 的 SHA 固定更新检查、外部自动化 PR 的 hash 修补、flake.lock 处置、补丁内版本检查与 nixpkgs 漂移陷阱。仓库特有的文档与日志环节经「仓库适配层」注入。
---

# nix flake 软件包更新检查（通用）

检查 nix flake 仓库中各软件包的上游发布更新并执行版本升级。

本技能只包含**与仓库无关**的通用方法。仓库特有的环节（文档同步、维护日志、
内置插件清单等）由**仓库适配层**提供——见文末「仓库适配层」。

## 交互式澄清：一次流程内解决所有待定项

**在开始前先判断所运行的智能体是否支持交互式提问**（如 DSH 提供
`ask_user_question`，可一次提出多个问题并等待用户选择）。**支持就积极使用**
——凡是不确定、有多种合理做法、或必须由用户拍板的事项，**当场问**，不要
先按自己的猜测执行完、再让用户在下一条消息里纠正。

**为什么这条是强要求**：软件更新是**多决策点**流程（升级策略、跨大版本取舍、
依赖冲突的解法、通道选择、是否部署）。若每个决策点都退化成「猜一次 → 被纠正
→ 重来」，一次更新会膨胀成多轮往返，且**每次重来都要重跑构建**——而构建是
本流程最贵的环节（Rust/python 包动辄数十分钟）。把决策点前置到开始之前，
整个流程才可能**一次跑完**。

### 必须提问的情形

| 情形 | 为什么必须问 |
|---|---|
| **跨大版本升级**（3.x → 4.x） | 可能含 breaking change、新的硬性要求，或需要用户接受行为变化 |
| **依赖冲突有两种以上合理解法** | 如「抬依赖版本」vs「跳过该包」vs「打补丁放宽校验」——代价与风险差别很大，且有的会破坏上游安全契约 |
| **需要新增 overlay / 补丁 / 额外 vendored 包** | 增加维护面，属结构性改动 |
| **构建时长或体积显著增加** | 用户可能宁愿暂缓 |
| **通道选择**（stable / next / alpha） | 取决于用户想跟哪条线，技能无法推断 |
| **是否部署到运行中的系统** | 影响生产环境 |
| **发现的信息与文档记载冲突** | 可能是文档过时，也可能是现状异常，需用户判断 |

### 提问的写法

- **一次问全**：把本轮所有待定项**合并成一批**提问，不要挤牙膏式地一问一等。
- **给出可选项与代价**：每个选项写清影响（尤其「破坏上游契约」这类后果）。
- **给出推荐项并说明理由**：把推荐项放第一位，标注「推荐」。
- **能自己查证的不要问**：先查 release notes / 上游源码 / 构建报错，
  把问题收敛到真正需要人决策的那几个。

> **不支持交互式提问时**（如纯命令行 agent）：把上述待定项**汇总成一份清单**
> 一次性输出，并说明每项的影响与推荐做法，然后**停下等待**——同样避免
> 「猜完再被纠正」的多轮往返。宁可一次问完，不要边做边猜。

### 与「先做完再汇报」的取舍

默认行为是自主推进，本技能是**例外**：因为更新流程的返工成本极高（重建代价），
**提问的成本远低于猜测的错误成本**。但**只问真正需要决策的**——机械步骤
（取 hash、改版本号、同步文档、记日志）自行完成，不要拿流程细节去打扰用户。

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

#### vendored lock 必须包含 peer 依赖条目

当上游 tarball **不带** lock（需自己生成 vendored lock）时，注意 npm 的
`--legacy-peer-deps` 会**不写入 `"peer": true` 条目**，导致沙箱内离线构建报：

```
npm error code ENOTCACHED
npm error request to https://registry.npmjs.org/<pkg> failed:
cache mode is 'only-if-cached' but no cached response is available
```

**判据**：生成的 lock 里 `grep -c '"peer": true'` 应为非零（与仓库既有可工作
的 lock 对照该数值）。**对策**：生成 vendored lock 时**不要**加
`--legacy-peer-deps`：

```bash
npm install --package-lock-only --ignore-scripts      # ✅ 记录 peer 条目
npm install --package-lock-only --legacy-peer-deps    # ❌ peer 条目缺失
```

> 注意区分两处 `--legacy-peer-deps` 的用途：**生成 vendored lock 时不要用**
> （会丢 peer 条目）；而 `buildNpmPackage` 的 `npmFlags`/`npm install` 阶段
> 用它跳过 peer 解析是**另一回事**，由包定义决定。

#### 若仓库启用了外部依赖自动化（如 Dependabot）

> **NixKits 不使用这类外部自动化**（见仓库 AGENTS.md「安全边界」），本节保留
> 供**其他仓库**参考——若你所在的仓库启用了，其 npm 更新 PR **必然无法通过
> CI**，这是结构性错配，不是配置错误：

| 它会改 | 它不知道 |
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

### 自托管 forge（`fetchFromGitea` 等）

流程与包型无关（源结构照旧），但**取源路径可能被上游禁用**。升级前先按
「非 GitHub 源（Gitea 等自托管 forge）」一节判定 `archive` 路径是否仍可用；
若已 403 而 API 端点可用，改用 `fetchzip` + `stripRoot = true`，
并**对比新旧 fetcher 的产物顶层目录**确认布局等价。

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

### 非 GitHub 源（Gitea 等自托管 forge）

`fetchFromGitea` **委托给 `fetchFromGitHub`**（源码里只有一层 `makeOverridable`
包装，把 `domain` 映射成 `githubBase`），所以它生成的是 GitHub 风格的
`/archive/<rev>.tar.gz` 路径。**自托管的 Gitea 实例不一定接受该路径。**

**症状**：

```
curl: (22) The requested URL returned error: 403
error: cannot download source from any mirror
```

**先判定，再动手**——403 可能是反爬，也可能是该路径真的被禁用：

```bash
# 逐 tag 对比两条路径，避免把「某个 rev 写错」误判成「接口变了」
for tag in v1.0.0 v1.0.1 v1.0.2 v1.0.3; do
  a=$(curl -s -o /dev/null -w '%{http_code}' "https://<domain>/<owner>/<repo>/archive/$tag.tar.gz")
  b=$(curl -s -o /dev/null -w '%{http_code}' "https://<domain>/api/v1/repos/<owner>/<repo>/archive/$tag.tar.gz")
  echo "$tag archive=$a api=$b"
done
```

| 观察 | 结论 |
|---|---|
| **所有 tag** 的 `archive` 都 403，而 `api/v1` 全 200 | **接口已变**（与 rev 无关），改用 API 端点 |
| 只有目标 tag 403，旧 tag 正常 | rev/tag 名写错，去核对上游 |
| 加浏览器 UA 后 200 | 纯反爬，保持原样即可 |

> ⚠️ **「旧版本还能构建」不代表旧路径可用**：老的 source 早已在 Nix store 或
> 二进制缓存里，`nix build` 直接命中缓存、**根本不发请求**。用
> `nix build --rebuild` 或在干净机器上验证，才能看出真实情况。

**对策**：改用 `fetchzip` 指向 API 端点，并用 `stripRoot` 复现原布局：

```nix
src = fetchzip {
  url = "https://<domain>/api/v1/repos/<owner>/<repo>/archive/v${finalAttrs.version}.tar.gz";
  stripRoot = true;   # 关键：见下
  hash = "sha256-...";
};
```

> ⚠️ **`stripRoot` 必须与原 fetcher 的语义一致**——这是最容易搞错的一步。
> `fetchFromGitea` / `fetchFromGitHub` 产出的是**剥掉顶层目录**的树，
> 而 `fetchzip` **默认保留**。若包定义里有 `preConfigure = "cd mcp"` 这类
> 依赖原始布局的语句，`stripRoot` 写错会让路径变成 `<repo>/mcp`，构建失败。
>
> **验证方法**：对比新旧 fetcher 的产物顶层目录名
>
> ```bash
> nix build --impure --no-link --print-out-paths --expr '
> let pkgs = import (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.x86_64-linux;
> in pkgs.fetchFromGitea { domain = "<domain>"; owner = "<owner>"; repo = "<repo>";
>                          rev = "v<旧版本>"; hash = "<原 hash>"; }' | xargs ls
> ```
>
> 两者列出的条目一致（如都直接是 `mcp/`）才算等价。**取两次 hash**
> （`stripRoot` 两种取值各一次）确认行为，不要凭猜。

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

## 第 9 步：同账户子项目链式检查

当仓库引用了**同一账户下的其他仓库**（典型形态是薄封装：本仓只固定子仓的
`rev` + hash，源码与文档都在子仓），则**子仓自身的上游版本也要检查**——
否则子仓会长期停在旧版本，而主仓的薄封装只是忠实地钉住那个旧版本。

```bash
# 本仓属于哪个账户
OWNER=$(git remote get-url origin | sed -E 's#.*[:/]([^/]+)/[^/]+(\.git)?$#\1#')

# 本仓引用了同账户的哪些仓库（薄封装坐标 = owner + repo）
# 注意用 -h 去掉 "文件名:行号:" 前缀，否则 awk 的字段号会错位
grep -rh -B2 -A4 'fetchFromGitHub {' packages/*.nix 2>/dev/null |
  awk -v o="$OWNER" '
    /owner[[:space:]]*=/ {owner=$3; gsub(/[";]/,"",owner)}
    /repo[[:space:]]*=/  {repo=$3;  gsub(/[";]/,"",repo);
      if (owner==o) print repo}' | sort -u
```

> ⚠️ **必须 `-h`**：带 `-n` 时输出为 `path:line:content`，`content` 会落到
> 第 3 个字段之后，`$3` 取到的是行号而非值——症状是**匹配结果为空**（而非报错），
> 极易误判为「本仓没有子项目」。

**引用关系不止 `fetchFromGitHub`**：flake input（`github:<owner>/<repo>`）、
git submodule、vendored 源码目录都算。以实际引用方式为准，逐个核对。

### 前提：确认不会引发回环或依赖冲突

链式检查**先验证再执行**。以下任何一条不成立，就**不链式**，退化为在报告里
提示「子仓 X 存在更新，请单独在其仓库内运行」：

| 前提 | 判据 |
|---|---|
| **无回环** | 沿引用关系展开形成的是 **DAG**，不是环。子仓不得（直接或间接）引用回本仓 |
| **无版本冲突** | 子仓的升级目标版本与主仓的其他依赖不冲突（如两包共享同一 peer 版本约束） |
| **可独立升级** | 子仓有独立的上游发布，且升级不需要主仓同步改代码（否则属主仓的普通升级） |
| **账户一致** | 沿链展开时维持同一账户，不越界到第三方仓（第三方的升级由第 3 步照常处理，不属本条） |

#### 回环检测

```bash
# 收集链条；每进入一层前，检查该仓是否已在访问集合中
declare -A VISITED
MAX_DEPTH=3

chain_check() {
  local repo="$1" depth="$2"
  if [ -n "${VISITED[$repo]}" ]; then
    echo "ABORT: 回环 — $repo 已在访问集合中（链条: ${!VISITED[*]}）"; return 1
  fi
  if [ "$depth" -gt "$MAX_DEPTH" ]; then
    echo "ABORT: 超出深度上限 $MAX_DEPTH — 疑似意外的长链"; return 1
  fi
  VISITED[$repo]=1
}
```

> **深度上限是安全网，不是配额**：真正的薄封装链通常只有 1~2 层。命中上限
> 往往意味着引用关系被误读（如把 vendored 的第三方源码当成子仓）。

**回环的实际形态**（子仓可能不是 flake，所以不能只查 flake input）：

```bash
# 子仓以任何方式引用回本仓，都构成回环——逐个检查子仓的引用面
SUB=<sub-repo>
gh api "repos/$OWNER/$SUB/contents" --jq '.[].name' | grep -E '^(flake\.nix|\.gitmodules)$' \
  && echo "有 flake.nix / submodule → 必须展开核对"
gh api "repos/$OWNER/$SUB/contents/package.json" --jq '.content' 2>/dev/null |
  base64 -d | grep -E '"(@[^"]*/)?'"$MAIN_REPO"'[^"]*":'   # 依赖名里出现主仓名
```

> 子仓**没有** `flake.nix` 也**不等于**不可能回环——它仍可能以 submodule、
> 依赖名、CI 脚本等方式拉回主仓。判据是「子仓的任何引用面是否指向主仓」，
> 不是「子仓是否是我认识的形态」。

#### 依赖冲突检测

子仓与主仓共享同一依赖时，**比对两边的目标版本**：

```bash
# 主仓侧该依赖的版本约束
grep -rn '<dep-name>' packages/*.nix | grep -oP 'version\s*=\s*"\K[^"]+'
# 子仓侧的目标版本
gh api "repos/$OWNER/<sub-repo>/contents/package.json" --jq '.content' |
  base64 -d | grep -oP '"<dep-name>":\s*"\K[^"]+'
```

两侧指向同一大版本 → 可并行升级。若子仓升级会把主仓的 peer 约束顶到
不兼容区间，**先升主仓侧**（或同步升），不要并行。

> ⚠️ **运行时由宿主解析的依赖不构成冲突**——这是最容易误报的一类。
> 当子仓声明的是 `peerDependencies`（或实际表现为 peer：声明版本低于宿主、
> 由宿主树在运行时解析，如 dsh 生态的 `@deepseek-ai/dsh-*`），则
>
> | 现象 | 判定 |
> |---|---|
> | 子仓声明 `0.1.1-rc.2`，宿主提供 `0.1.5-rc.2` | **不冲突**——运行时取宿主树 |
> | 子仓声明 `0.2.0`，宿主提供 `0.1.5-rc.2`（子仓要求**更高**） | 冲突——宿主满足不了 |
>
> 判据：**只查「子仓要求的版本是否高于宿主能提供的版本」**，而不是「两侧是否相等」。
> 宿主版本更高是正常状态，不是漂移。主仓侧薄封装一律用 `--legacy-peer-deps`
> 跳过 peer 解析，正因如此它才能正常工作。

### 执行：链式并行

前提全部成立时，各子仓的检查**并行**执行，互不阻塞：

| 规则 | 说明 |
|---|---|
| **并行** | 多个子仓（及其各自的子仓）同时展开，无依赖的检查不必串行等待 |
| **各自独立** | 子仓的检查在**子仓自己的工作副本**中进行，不得在主仓目录内改子仓文件 |
| **失败隔离** | 某个子仓失败不阻断其他子仓；失败项进入报告，其余照常推进 |
| **不越权提交** | 子仓的 commit / push 在子仓仓库内进行；主仓只提交自己的薄封装更新 |

```bash
# 并行展开（每个子仓一个工作副本）
for sub in $SUBPROJECTS; do
  ( git -C "/tmp/$sub" fetch -q origin &&
    cd "/tmp/$sub" && <本技能第 1~8 步> ) &
done
wait
```

> **子项目不一定是 nix flake**：被引用的子仓常常是普通 npm / python / rust
> 项目（主仓的薄封装只负责用 `buildNpmPackage` 等包装它）。此时**不要**套用
> 本技能的 flake 专属步骤（`nix flake check`、flake.lock 处置）——按子仓
> 自身的构建体系升级（`npm version` / `pyproject.toml` / `Cargo.toml`），
> 只在主仓侧重新计算薄封装的 `rev` + hash。

### 判据：子仓何时需要在主仓侧跟进

子仓有新提交 ≠ 主仓薄封装要动。按子仓变更的**性质**分流：

| 子仓变更 | 主仓侧动作 |
|---|---|
| **版本号变更**（`version` 字段变了） | **必须跟进**——更新薄封装的 `version` + `rev` + 两侧 hash |
| **仅源码变更、版本未变**（同为 docs/修复提交） | 分情况：<br>• 变更影响**运行时行为** → 跟进 `rev` + src hash（`npmDepsHash` 可能不变）<br>• 仅改文档/README/注释 → **不跟进**，主仓无需重新钉住文档 |
| **仅依赖变更** | 跟进，且需重算 `npmDepsHash`（依赖集变了） |
| **仅清单文件的发布元数据变更**（`package.json` 的 `publishConfig` / `repository` / `keywords` 等） | **不跟进**——文件字节变了但语义输入未变，详细字段分界见下 |

> ⚠️ **别把「子仓 HEAD ≠ 主仓 rev」直接当成待办**。薄封装钉的是**版本坐标**，
> 不是「子仓最新提交」。子仓的 README 改动对主仓构建产物毫无影响，为它重钉
> rev 只会制造无意义的构建与缓存失效。
>
> 判据：**先 diff 判断变更性质，再决定是否跟进**——而不是 rev 不等就升级。

```bash
# 判断子仓在 pin 之后改了什么
gh api "repos/$OWNER/$SUB/compare/$PINNED_REV...$SUB_HEAD" \
  --jq '.files[] | "\(.status)  \(.filename)"'
# 版本号是否变了（最硬的判据）
gh api "repos/$OWNER/$SUB/contents/package.json" --jq '.content' |
  base64 -d | grep -oP '"version":\s*"\K[^"]+'
```

#### ⚠️ 判据的真实分界：不是「有没有变」，而是「变的是不是构建输入」

版本号未变时，**不能只看「是否只有文档」**——`package.json` 这类**清单文件**
的改动尤其容易误导。必须进一步判断改动是否落在**构建输入**上：

| 子仓改动 | 是否构建输入 | 主仓动作 |
|---|---|---|
| `README` / `docs/` / 注释 | 否 | **不跟进** |
| `.github/workflows/`、`.gitignore` | 否（主仓薄封装不消费子仓 CI） | **不跟进** |
| **清单文件中的发布元数据**（`publishConfig`、`repository`、`keywords`、`description`、`bugs`、`homepage`） | **否** | **不跟进** |
| `dependencies` / `devDependencies` / `peerDependencies` / 锁文件 | **是** → 影响 `npmDepsHash` | **跟进** |
| `files` / `main` / `exports` / `scripts` | **是** → 影响打包产物 | **跟进** |
| `version` | **是**（最硬的信号） | **必须跟进** |
| `lib/`、`src/` 等源码 | **是** → 影响产物 | **跟进** |

**关键区分**：`package.json` **整个文件**都是构建输入的一部分（它进 tarball，
src hash 会变），但**它的诸多字段中只有一部分是语义输入**。判据落在**字段级**：

```bash
# 提取 package.json 的实际 diff，逐字段判定
gh api "repos/$OWNER/$SUB/compare/$PINNED_REV...$SUB_HEAD" \
  --jq '.files[] | select(.filename=="package.json") | .patch'
```

> **两种结论的取舍**：
>
> - **不跟进**（仅发布元数据/文档变化）：主仓薄封装确实与子仓 HEAD 不再逐字节
>   一致，但**构建产物与运行时行为完全相同**。重钉只会制造一次无意义的全架构
>   重建与缓存失效。这是**正确的**选择。
> - **跟进**（任何语义字段变化）：必须重钉 `rev`；依赖相关字段变了还要重算
>   `npmDepsHash`；仅源码/元数据变了则 `npmDepsHash` 通常不变。
>
> 若无法确定某字段是否影响产物，**按「跟进」处理**——多一次构建远好过漏掉
> 一次真实变更。

### 结果归属

| 场合 | 归属 |
|---|---|
| 汇总报告 | 子仓结果**视为主仓结果**，一并呈现（报告读者关心的是主仓最终钉住的版本） |
| 主仓维护日志 | 记录**薄封装坐标变更**（`rev` / hash），并提供**指向子仓维护条目章节的链接** |
| 子仓维护日志 | 记录**子仓自身的版本变更**（它是该项目的完整记录所在） |

主仓条目里的链接必须**锚定到具体章节**，而不是只给日志文件：

```markdown
**摘要**：dsh-api-balance 0.1.0 → 0.2.0 — 薄封装 rev/hash 同步（子仓变更见
[子仓维护日志](https://github.com/<owner>/<sub>/blob/main/MAINTENANCE.md#<timestamp-anchor>)）
```

> 锚点用子仓条目的**时间戳**（如 `#2026-09-17t11-21-34-09-00`）——它在该仓库内
> 唯一，且子仓与主仓都用同一套标题格式时可直接推导。**推导规则与易错点见
> `write-maintenance-log` 技能「主仓条目的链接写法」**（逐字符替换，不是删除
> 分隔符）。给不出锚点就退化为给日志文件链接 + 条目标题文本。

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

## 审计文档中的外部链接

更新流程结束前，检查文档里的上游链接是否仍然有效。**上游项目会改名、迁移
组织、归档仓库**——这些变化不产生任何构建错误，只让文档里的链接悄悄失效，
而链接恰恰是读者追溯来源的唯一入口。

```bash
# 抽取所有外部链接（含各语言文档），逐个探测
grep -rhoP 'https://[a-zA-Z0-9.-]+/[a-zA-Z0-9._/%#-]+' --include="*.md" . |
  sed 's/[.,)]*$//' | sort -u | while read u; do
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$u")
    case "$code" in 200|301|302|429) ;; *) echo "$code  $u";; esac
  done
```

**判定与处置**：

| 结果 | 含义 | 处置 |
|---|---|---|
| `404` | 目标确实不存在（项目迁移/改名） | **查证新地址并修正**（见下） |
| `403` | 常有反爬（如 `projects.blender.org`） | **不是死链**，用浏览器或 `gh api` 复核 |
| `429` | 被限流 | 稍后重试，**不要**据此判定失效 |
| `301/302` | 正常重定向 | 可保留 |

> ⚠️ **`curl` 的 404 不足以定案**：GitHub 对某些请求返回 404 也可能是
> 权限或限流所致。用 `gh api repos/<owner>/<repo>` 复核——
> **能取到仓库信息才是确证**。

**查证迁移去向**：项目改名后旧地址通常 404，新地址可用以下方式找到：

```bash
gh api repos/<old-owner>/<repo> --jq '.full_name'   # 404 → 已迁移
gh search repos <repo-name> --limit 5 --json fullName,stargazersCount
```

**修正时同步改「链接文字」**：显示文本若含 `owner/repo`，必须与新地址一致
（只改 URL 会让读者看到与实际不符的来源）。**多语言文档全部同步。**

> **不要改 vendored 第三方内容**：若链接出现在 `vendor/`、`*-src/` 等随上游
> 一同引入的路径中（如依赖包的 CHANGELOG），那是上游的文档，**其链接失效
> 不属我们的维护范围**，强行改写反而偏离上游。

## 检查 GitHub Actions 的更新

若仓库把第三方 action 固定到提交 SHA（供应链卫生的常见做法），
**固定之后就收不到更新通知了**——这是一处必须主动检查的盲点。

**为什么要自己查而不是靠外部自动化**：Dependabot 一类工具是外部自动化集成，
由 GitHub 平台运行、我们无法审计其行为。若仓库的安全边界要求"不引入
外部自动化"，就应自行实现同等能力——下面的流程只用到 `gh api` 与 `git`，
完全可审计。

### 第 1 步：列出所有固定的 action

```bash
grep -rhoE 'uses: [^ ]+@[0-9a-f]{40}' .github/workflows/*.yml |
  sed 's/uses: //' | sort -u
```

输出形如 `actions/checkout@3d3c42e5…`。**同时记下注释里的版本号**
（如 `# v7.0.1`），流程末尾需要同步更新它。

### 第 2 步：查最新版本

```bash
check_action() {
  local repo="$1"          # 如 actions/checkout
  echo "=== $repo ==="
  gh api "repos/$repo/releases/latest" --jq '.tag_name' 2>/dev/null ||
    gh api "repos/$repo/tags" --jq '.[0].name' 2>/dev/null ||
    echo "（无 release/tag，改用分支：见下）"
}
```

> ⚠️ **有些 action 不用 release**（如 `DeterminateSystems/nix-installer-action`
> 直接跟踪 `main`）。这类要查分支头：
>
> ```bash
> gh api repos/DeterminateSystems/nix-installer-action/commits/main --jq '.sha'
> ```

### 第 3 步：取 tag 对应的提交 SHA

**必须取 tag 指向的 commit，不能取分支头**——否则会把未发布状态引入 CI：

```bash
gh api repos/<owner>/<repo>/git/ref/tags/<tag> --jq '.object.sha'
```

> ⚠️ **若返回 `type: "tag"`（annotated tag）**，再取一层：
>
> ```bash
> gh api repos/<owner>/<repo>/git/tags/<sha> --jq '.object.sha'
> ```

### 第 4 步：更新并写回注释

```diff
-      - uses: actions/checkout@11d5960a…  # v4
+      - uses: actions/checkout@3d3c42e5…  # v7.0.1
```

**注释中的版本号必须一并更新**——它是下次检查时的比对基准，不同步会让
后续核对失去参照。

### 第 5 步：验证

```bash
nix flake check          # 语法与结构
```

并确认 CI 通过。**注意区分偶发失败**：GitHub API 限流（`HTTP error 403`
拉取 `api.github.com`）与 action 升级无关，重跑即可——判断方法是看**失败
的是否只有涉及该 API 的 job、其余 job 是否通过**。

### 判据：何时该升级

| 情况 | 处理 |
|------|------|
| 跨大版本（如 v4 → v7） | 读 release notes 确认 breaking change 与安全修复 |
| 仅 patch/minor | 通常可直接升 |
| action 跟踪浮动分支（`@main`） | **优先固定到 SHA**，而非被动跟随 |

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

### 5. 上游的「fail-closed 运行时依赖校验」：构建通过 ≠ 可用

有些项目在**启动时**校验依赖的精确版本，不匹配就直接拒绝启动。此时
`nix build` **会成功**，但你第一次运行才炸——典型的假成功。

实测样本（godot-ai v4）：`verify_runtime_dependencies()` 比对 9 个包的精确
版本，任一不符即 `RuntimeError: unsupported godot-ai runtime dependency set`。
nixpkgs（含 unstable/master）在 5 个包上落后，故构建产物**根本起不来**。

**识别**：上游把依赖写成 `==x.y.z` 硬 pin，且源码中有 `verify_*`/
`check_*version*` 一类的启动期校验函数。

**验证**：构建后**必须实际运行一次**（`--version` 即可），不能只看构建成功：

```bash
OUT=$(nix build .#<pkg> --print-out-paths --no-link)
"$OUT/bin/<pkg>" --version        # 构建成功但此处抛错 = 命中本陷阱
```

**对策（按优先级）**：

1. **抬依赖版本对齐上游**（推荐）——建 overlay 把 nixpkgs 的包改到上游要求
   的版本。nixpkgs 落后不代表不能改：用 `overridePythonAttrs` 改
   `version` + `src` + `hash` 即可（Rust 构建的包还要改 `cargoDeps`）。
2. **确认无法对齐时**（如多个包需大改），向用户提问取舍，不要自行打补丁
   绕过校验——那会**破坏上游有意的安全契约**，而 v4 的校验恰恰是为安全
   边界服务的。

> ⚠️ **不要把 `dontCheckRuntimeDeps = true` 当成万能解**：它只静默
> **构建期**的 `pythonRuntimeDepsCheckHook`，对**运行期**的自校验完全无效。
> 两者名字相似但作用阶段不同——构建期过了，运行时照样拒绝启动。

### 6. `overridePythonAttrs` 改动 Rust 构建的包时，`cargoDeps` 要一并重取

python 包若含原生扩展（如 `pydantic-core` 由 Rust 构建），改 `version`/`src`
后 `cargoDeps` 也必须重算，否则 vendor 阶段失败。取 hash 的报错路径：

```bash
# sourceRoot 用 fetchFromGitHub 解包后的实际目录名（通常是 "source/<子目录>"），
# 不是 "<pname>-<version>/<子目录>"——写错会报
# "chmod: cannot access '...': No such file or directory"
```

> 顺带：若包的测试套件在新版本中新增依赖（如 websockets 17.1 新增
> `tests/trio/` 而 nixpkgs 的 check inputs 没有 trio），报
> `ModuleNotFoundError` 时给 `nativeCheckInputs` 补上即可。

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
| 子项目清单（第 9 步） | 本仓引用了哪些同账户子仓、各自的构建体系、子仓日志的路径与语言约定 |
