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

