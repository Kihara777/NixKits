---
name: nix-packaging
description: 从零把一个上游软件打包成 Nix 表达式——按来源类型分流（GitHub 源码 / npm / Rust / 预编译二进制 / Gitea）、hash 的两段式获取（fakeHash → 读取 got → 回填 → 再构建验收）、vendored lock 的生成、wrapper 何时需要、四层验收（求值 / 真实构建 / 产物 / 运行），以及本仓（NixKits）的约定与六条实测陷阱。适用于「这个软件还没有包」的第一步，不覆盖「已有包的版本更新」（那在 nix-flake-update-check）与「提交上游」（那在 upstream-audit）。
---

# 从零打包

## 判据：四层验收，缺一层就不算完成

| 层 | 判据 | 什么会骗过你 |
|---|---|---|
| 求值 | `nix eval .#packages.<system>.<name>.name` 得到预期版本 | 求值过 ≠ 能构建 |
| 构建 | `nix build` 日志里出现 `building '…'`，**不是全缓存** | 缓存命中 = 一行没构建 |
| 产物 | `ls $out/bin` 与关键文件存在 | 空 bin = 白构建 |
| 运行 | `<pkg> --help` / `--version` 退出码 0 | node 无 wrapper、二进制缺库都在这一层暴露 |

**「构建成功」不等于「能用」。** 前三层全绿而第四层失败，是这类工作最常见的假通过。

## 第 1 步：按来源分流

| 来源 | 工具 | 关键点 |
|---|---|---|
| GitHub 源码（C/C++/CMake） | `fetchFromGitHub` + `stdenv.mkDerivation` | 布尔 flag 用 `lib.cmakeBool`，别拼字符串 |
| GitHub 源码（Rust） | `rustPlatform.buildRustPackage` | `cargoHash` 同样两段式 |
| GitHub 源码（npm 前端） | `buildNpmPackage` | `npmDepsHash` + vendored lock（第 3 步） |
| 预编译二进制 | `fetchurl` + `stdenv.mkDerivation` | 每架构一个 hash；`autoPatchelfHook` |
| Python（PyPI） | `buildPythonApplication` | `format = "pyproject"` |
| **Gitea / 自托管 forge** | `fetchFromGitea` | ⚠️ `/archive/<tag>.tar.gz` 返 **403**；走 API 端点 + `stripRoot = true` |
| npm registry tarball | `fetchurl` | tarball hash 与 `npmDepsHash` 是**两个**独立的 hash |

## 第 2 步：hash 两段式（核心手法）

**不要猜 hash，让构建报给你。**

1. hash 写 `lib.fakeHash`（**字符串，不加括号**）；
2. 构建 → 第一处 mismatch 报 `got: sha256-…`，回填；
3. 再构建 → 下一处 mismatch（src 之后通常是 `npmDepsHash` / `cargoHash`），回填；
4. **全部回填后必须再构建一次**——这次才是验收，不是取 hash。

⚠️ npm 包的特殊陷阱：`npmDepsHash` 相同**不代表依赖没变**。新版可能新增依赖而旧 lock
里没有，症状是 `ENOTCACHED`（`request to … failed: cache mode is 'only-if-cached'`）。
判据是 `npm ci` 真的过了，不是 hash 对上了。

## 第 3 步：vendored lock（npm 包）

npm 包 tarball **不带 lock 文件**，必须自己 vendor：

1. 解出 tarball 的 `package.json`（`tar xzf` 后取 `package/package.json`）；
2. `npm install --package-lock-only --ignore-scripts`
   ——**不要**加 `--legacy-peer-deps`：它会丢 `"peer": true` 条目，构建报 `ENOTCACHED`；
3. 生成的 `package-lock.json` 复制进 `packages/<name>-package-lock.json`；
4. 代码里 `lockFile ? ./<name>-package-lock.json`，`npmDepsHash` 走两段式。

升级时先看新 lock 的根 `"version"` 是不是本次版本——同名 store 路径可能装着旧内容。

## 第 4 步：wrapper 何时需要

- **node 包**：`buildNpmPackage` 是否生成可执行 `$out/bin` 取决于 `package.json` 的 `bin`。
  不保证时用 `makeWrapper` 包 node，`--add-flags <entry>.js`，并 `--prefix PATH : ${lib.makeBinPath [ nodejs ]}`。
- **预编译二进制**：`autoPatchelfHook` + `buildInputs`（foundation、glibc、libgcc 等）。
- 拿不准就靠第 4 层验收——`--help` 会直接告诉你缺什么。

## 第 5 步：本仓约定（NixKits）

| 约定 | 内容 |
|---|---|
| 文件位置 | `packages/<name>.nix`，flake 里 `callPackage` |
| 公共属性 | `__structuredAttrs = true;` + `strictDeps = true;` |
| **例外** | **交叉编译的包不能开 `__structuredAttrs`**：`AR_<triplet>` 里的 `-` 不是合法 shell 标识符，报 `declare: AR_x86_64-unknown-linux-gnu=…: not a valid identifier`。本仓 `codewhale-src` 因此刻意不开 |
| 属性集合 | 插件类包可能属于某个集合（`pkgs.obs-studio-plugins.<name>`），不是顶层 `pkgs.<name>` |
| 文档 | 四语 `docs/<lang>/<name>.md` + README 行 + 构建徽章 |
| CI | `.github/workflows/build-<name>-<arch>.yml`，架构数**先数一遍** |
| 维护日志 | 按 `write-maintenance-log` 补四语条目 |

## 陷阱清单（六条，全部实测过）

1. **`lib.fakeHash` 是字符串**：`hash = lib.fakeHash;`，写 `lib.fakeHash()` 会报错。
2. **同名 store 路径不等于同版本内容**：`npmDepsHash` 写错时 fixup 会命中旧的
   `…-npm-deps`，比对前先看那个路径里的 `"version"`。
3. **glob 别打进 vendor**：`packages/**/*.nix` 会命中 `packages/*/vendor/` 里的第三方文件，
   改了会污染 `src` 的 hash。
4. **`__structuredAttrs` 与交叉编译冲突**（见第 5 步例外）。
5. **Gitea 取源 403**（见第 1 步）。
6. **徽章竞态**：workflow 删了而文档里徽章还在 → 断链。文档与 workflow 同一次提交改。
7. **`meta.maintainers` 的属性名不是 GitHub handle**：`lib.maintainers` 里放的是
   maintainer-list 的**属性名**（如 `kitsunori`），而 GitHub handle 是另一个字段
   （`github = "Kihara777"`）。写错时 **`nix-build` 照样成功**——`meta` 是懒求值，
   构建根本不读它。只有 `nix-eval-jobs --meta` 或显式求值才会暴露：

   ```
   error: undefined variable 'Kihara777'
     at package.nix:83:43
   ```

   验证方式（四层验收之外的第 5 层）：

   ```bash
   nix eval --raw .#packages.<system>.<pkg>.meta.maintainers \
     --apply 'ms: builtins.concatStringsSep "," (map (m: m.name) ms)'
   ```
