# 按包型的 hash 更新流程（配套参考）

本文件是 **`nix-flake-update-check` 技能第 4 步**的展开：按 `.nix` 文件中的
builder 选择对应流程，并处理 `flake.lock`。

> **包型由 `.nix` 文件中的 builder 决定**，不是由包名决定。

**目录**（按 builder 查）：

| builder | 何时用 | 本文件章节 |
|---|---|---|
| `buildNpmPackage` | Node/npm 包 | [npm 包](#npm-包) |
| `stdenv.mkDerivation` + cmake | C/C++ 项目 | [cmake 包](#cmake-包) |
| `buildRustPackage` | Rust 包（**注意 Cargo.lock**） | [Rust 包](#rust-包buildrustpackage) |
| `fetchzip` / `fetchFromGitea` | 自托管 forge 取源 | [自托管 forge](#自托管-forgefetchfromgitea-等) |
| `fetchurl` | 预编译二进制 | [预编译二进制包](#预编译二进制包fetchurl) |

**通用注意（所有包型适用）**：

> - SRI hash 格式必须使用标准 base64（`+` `/` `=`），**不能**使用 URL-safe base64（`-` `_`）。
>   用 `nix hash to-sri --type sha256 <hash>` 或 `nix-prefetch-url --type sha256 <url>` 获取正确格式
> - `fetchFromGitHub` 的 source hash **不能**从 GitHub archive tarball（`/archive/refs/tags/`）预计算 —
>   两者可能不同。必须通过 `nix build` 的 hash mismatch 错误获取
> - `npmDepsHash` 不能设为空字符串 `""`。清空时使用 `lib.fakeHash` 占位
> - npm 包需要两次 `nix build`：第一次获取 source hash，第二次获取 npmDepsHash。
>   如果 source hash 已知正确，可只清空 npmDepsHash 一次构建完成

---

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

#### 升级时：vendored lock 是否随上游依赖集一起更新（易漏）

`npmDepsHash` 是 **lock 文件内容的函数**。上游新版本若增删了依赖，而 vendored
lock 仍是旧版生成的，则**只改 `version` + source hash 必然失败**：

```
error: hash mismatch in fixed-output derivation '...-<pkg>-<ver>-npm-deps.drv'
```

**这里有个会误导人的现象**：Nix 报出的 `got:` 有时**恰好等于**你原先写的
`npmDepsHash`——因为旧 hash 本就是旧 lock 的正确 hash。此时别以为「hash 没变，
所以依赖没变」，要**独立核对依赖集**：

```bash
# 直接对比新旧 tarball 的 dependencies（这是权威依据，不是 lock）
for v in <old> <new>; do
  curl -sL "https://registry.npmjs.org/<pkg>/-/<pkg>-$v.tgz" | tar xzO package/package.json \
    | grep -oP '"@scope/[^"]*"' | sort -u > "/tmp/deps-$v.txt"
done
diff /tmp/deps-*.txt     # 有差异 → lock 必须重生成
```

**重生成 vendored lock 的唯一正确姿势**：必须对**包定义 `postPatch` 处理后**的
`package.json` 生成——若包定义删了 `devDependencies`（未发布的 monorepo 内部包
会 404），生成 lock 前要**执行同样的删除操作**，否则 lock 与构建期的
`package.json` 不同源，仍会报 `npmDepsHash is out of date`：

```bash
# 1. 解包 tarball，复刻派生 postPatch 对 package.json 的改动
tar xzf <pkg>.tgz && cd package
sed -i '/^  "devDependencies": {/,$d' package.json
sed -i '$s/,$//' package.json && echo '}' >> package.json
# 2. 生成 lock（不加 --legacy-peer-deps，见上节）
npm install --package-lock-only --ignore-scripts
# 3. 覆盖仓库内的 vendored lock，再让 nix build 报出新的 npmDepsHash 并回填
```

> **多通道包尤其容易踩**：`stable` / `alpha` 各自带一份 vendored lock
> （如 `<pkg>-package-lock.json` / `<pkg>-package-lock-alpha.json`）。升级
> **其中一个通道**时，只有那一份需要重生成——但**两份都必须复验**，因为 base
> 定义是共享的。

#### 若 PR 由外部依赖自动化开出（如 Dependabot）

> **这是通用情形，不是某个仓库的特例**：只要仓库启用了外部依赖自动化
> （由托管平台替维护者开 PR），其 npm 更新 PR **必然无法通过本类仓库的 CI**
> ——这是**结构性错配**，不是配置错误。无论你是维护者、贡献者还是评审者，
> 遇到这类 PR 都按本节处置。

| 它会改 | 它不知道 |
|---|---|
| `package.json` | `.nix` 文件里的 `npmDepsHash` |
| `package-lock.json` | `buildNpmPackage` 会把 src 的 lock 与 npm-deps 产物**逐字节**校验 |

> ⚠️ **有些仓库刻意不启用这类自动化**（把"不在仓库内运行不可审计的外部代码"
> 作为安全边界）。那种情况下不会有这类 PR——更新改由**本技能主动检查**完成
> （含 GitHub Actions 的 SHA，见 `traps.md`）。判据是**你所在仓库的实际选择**：
> 有就按本节处置，没有就自行检查，两者并不冲突。

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

> ⚠️ **同时核对目标版本是否落后**：这类自动化只在其配置的 semver 通道内推进
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

### 自托管 forge（`fetchFromGitea` 等）

流程与包型无关（源结构照旧），但**取源路径可能被上游禁用**。升级前先按
「非 GitHub 源（Gitea 等自托管 forge）」一节判定 `archive` 路径是否仍可用；
若已 403 而 API 端点可用，改用 `fetchzip` + `stripRoot = true`，
并**对比新旧 fetcher 的产物顶层目录**确认布局等价。

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

先判断仓库属于哪一种——**处置顺序有意义**：

```bash
# 情况 1：flake.lock 已被 .gitignore 排除 → 跳过
if grep -qx 'flake.lock' .gitignore 2>/dev/null; then
  echo "SKIP: flake.lock 已在 .gitignore 中"
  exit 0
fi

# 情况 2：仓库含**浮动输入**（动态版本包 / API URL input）
if grep -rq 'builtins.fetchurl.*releases/latest|\.url\s*=\s*"https?://api\.' \
   overlays/ flake.nix 2>/dev/null; then
  echo "WARN: 检测到浮动输入——正确处置见下，不要直接 gitignore"
fi
```

> **情况 2 的正确处置不是「把 flake.lock 加进 .gitignore」**（2026-10-22 修正）。
> 那样做等于宣布本仓不可复现，代价会一路传染：CI 判的是浮动输入、徽章可能在主
> 检查红着时仍显示 passing、追溯时无法回答「那次跑的是哪个 nixpkgs」。
> 优先做法是**把浮动的那一个输入隔离出去**：
>
> - 迁到独立分支或独立仓库。NixKits 的做法：`llama-cpp-rocm`、它的 overlay/模块，
>   以及那个 `api.github.com/.../releases/latest` 的 URL input 一起搬进 orphan 分支
>   `impure`（该分支**不提交 lock**、只装这一个包）；
> - 主仓用一条钉 rev 的 input 引用它，升级时只 bump 那一条。
>
> 只有「隔离不可行」时才排除 lock，并且必须在 README / AGENTS 里写明
> 「本仓 CI 不可复现」这条代价——不要让它悄悄存在。

#### 提交要求（lock 已提交的仓库）

`nix build` 之后先看 lock 有没有被动过：

```bash
git diff --stat flake.lock
```

| 情况 | 意味着什么 | 怎么办 |
|---|---|---|
| **没变** | 只改了包定义（hash / version 都在 `.nix` 里） | 正常提交包改动 |
| **变了** | 某个 input 被重新解析 | **单独审视**：是 `nix flake update` 的预期结果，还是某条命令顺带刷新了 nixpkgs？后者不要混进包更新提交 |

三条硬规则：

1. **lock 与 `flake.nix` 必须一致**：提交前跑
   `nix flake check --no-write-lock-file`——lock 缺 input 或有未写回的变更时它会
   **直接失败**，不会自己生成一份新 lock 再判绿。
2. **升 nixpkgs 单独一次提交**，不要与「包版本升级」混在一起。混在一起会失去归因：
   产物变了到底是包升级还是 nixpkgs 升级引起的？2026-10-21 实测，一次
   `--update-input nixpkgs` 顺带让三个包构建失败（`v4l2loopback` × 内核、
   `mozc` × 新 Qt、`syrupy` 测试过期），与业务改动毫无关系。
3. **交叉构建必须跟 lock**：不要在 CI 里用
   `builtins.getFlake "github:NixOS/nixpkgs/nixos-unstable"` 取「最新 nixpkgs」——
   同一个 commit 在不同时间会产出不同二进制，riscv64 尤其明显。从 `flake.lock`
   读 rev 再求值：

   ```bash
   NP_REV="$(jq -r '.nodes.nixpkgs.locked.rev' flake.lock)"
   nix build --impure --no-write-lock-file --expr \
     "let np = builtins.getFlake \"github:NixOS/nixpkgs/$NP_REV\";
      in np.legacyPackages.x86_64-linux.pkgsCross.riscv64.callPackage ./packages/<pkg>.nix { }"
   ```
