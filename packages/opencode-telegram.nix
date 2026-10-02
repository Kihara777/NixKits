# opencode-telegram —— OpenCode 的 Telegram Bot 客户端。
#
# ── riscv64：**建**，而且必须**真跑过**才算数 ────────────────────────────────
# 上游对 riscv64 没有预编译，两个原生模块都得在构建期现编，而它们是**硬需求**：
# `better-sqlite3` 是本包的**直接依赖**、在 `dist/app/services/session-cache-service.js`
# 里被**静态 import**（启动即加载），其 `prebuilds/` 只有 darwin/linux/musl/win32 ×
# x64/arm64。少一个绑定 = 构建照样绿、一启动就抛。踩过并修掉的两处：
#
# ① **gyp 的命令展开会拿到空串。** `msgpackr-extract` 的 binding.gyp 里有
#       "gcc_version": "<!(<(os_linux_compiler) -dumpversion | cut -d '.' -f 1)"
#       ["gcc_version>=7", { ... }]
#    `<!()` 是真的 shell out，而交叉构建的 PATH 上**没有裸 `gcc`**（交叉编译器只以
#    带前缀的名字出现；实测 `command -v gcc` → 无）⇒ 展开成空串 ⇒ gyp 里变成
#    `"" >= 7` ⇒ `TypeError: '>=' not supported between instances of 'str' and 'int'`。
#    → 补一个名为 `gcc` 的 shim 指向**交叉**编译器（指向宿主的会给 riscv64 包编出
#      x64 的 `.node`，比构建失败更糟）。
#
# ② **`better-sqlite3` 会「构建成功但一行都不编」。** 它的 binding.gyp 写着
#       'force_build%': 0,
#       'prebuild_exists%': '<!(node lib/binding.js)',
#       ['force_build==1 or prebuild_exists==0', { …真源码… }, { 'type': 'none' }]
#    交叉构建里那句 `<!(node ...)` 跑不起来（PATH 上的 node 是 riscv64 的）⇒ 展开成
#    **空串**，而空串既不等于 1 也不等于 0 ⇒ 两条件都不成立 ⇒ target 退化成
#    `type: none` ⇒ `make` 只盖 stamp。→ 显式 `--force_build=1`（上游自己的
#    `build-release` 脚本就是这么用的）。另：v13 起它取消了 `install` 脚本，
#    所以 `npm rebuild` 根本不会碰它，得自己叫 node-gyp。
#
# 判据是**产物真的能跑**，不是「构建成功」：CI 的 riscv64 job 带 `smoke-test: true`，
# 跑 `develop/qemu-smoke-tests/opencode-telegram.sh`（qemu-user + binfmt；开库建表
# 写入读回，不是「能 require」）。那个 job 曾经长期靠 Cachix 缓存「成功」——
# 取的是上一个版本的产物，一行都没构建过。

{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
  python3,
  pkgs,
  stdenv,
}:

let
  # 给 gyp 一个**裸名 `gcc`**，并让它指向**交叉**编译器。理由见 nativeBuildInputs。
  gccShim = pkgs.writeShellScriptBin "gcc" ''
    exec ${pkgs.stdenv.cc}/bin/${pkgs.stdenv.cc.targetPrefix}cc "$@"
  '';
in

buildNpmPackage (finalAttrs: {
  pname = "opencode-telegram";
  version = "0.26.2";

  src = fetchFromGitHub {
    owner = "grinev";
    repo = "opencode-telegram-bot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t8MjkxXKKvAfqmC67o2M7vhx7QPIkhOmraxJ6XJ3LiU=";
  };

  npmDepsHash = "sha256-5IW3Zk1nRjUZHetvqKvJTlOlm8DzexkgNrkzCVRz0AQ=";
  npmBuildScript = "build";
  npmInstallFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    makeWrapper
    # gcc shim 只在交叉构建时加：x86_64 与 aarch64 都在**原生 runner** 上构建
    # （ubuntu-latest / ubuntu-24.04-arm），PATH 上本来就有裸 `gcc`，不需要它。
    # 少动一个本来正常的构建路径。
  ] ++ lib.optional stdenv.hostPlatform.isRiscV64 gccShim;

  buildInputs = [ nodejs ] ++ lib.optionals (lib.versionAtLeast nodejs.version "20") [ python3 ];

  # ⚠️ riscv64：必须**显式**把两个原生模块编出来。
  #
  # 背景：这两个包**都没有 riscv64 预编译**（better-sqlite3 的 `prebuilds/` 只有
  # darwin/linux/musl/win32 × x64/arm64），而 `better-sqlite3` 又是本包的**直接依赖**、
  # 在 `dist/app/services/session-cache-service.js` 里被**静态 import**（启动即加载）。
  #
  # ① 为什么要 `--force_build=1`：`better-sqlite3/binding.gyp` 自己写着
  #       'force_build%': 0,
  #       'prebuild_exists%': '<!(node lib/binding.js)',
  #       ['force_build==1 or prebuild_exists==0', { …真源码… }, { 'type': 'none' }]
  #    交叉构建里那句 `<!(node ...)` **跑不起来**（PATH 上的 node 是 riscv64 的，
  #    在这台 x86_64 builder 上执行不了）→ 展开成**空串**；而空串既不等于 1 也不等于 0
  #    ⇒ 两个条件都不成立 ⇒ target 退化成 `type: none` ⇒ `make` **只盖 stamp、一行都不编**
  #    （实测）。上游自己的 `build-release` 脚本用的就是 `--release --force_build=1`，照抄即可。
  # ② 为什么 `npm rebuild` 指望不上：v13 取消了 `install` 脚本（改成纯 prebuilds 分发），
  #    所以 npm 根本不会去编它——得我们自己叫 node-gyp。
  # ③ 用**构建平台**的 node 跑 node-gyp，并把 PATH 限定在这个子 shell 里。
  #    原因：`node-gyp.js` 的 shebang 是 `#!/usr/bin/env node`，而 PATH 上的 `node`
  #    是 **riscv64** 的（`buildInputs` 里那个，是给运行时 wrapper 用的）——在 x86_64
  #    runner 上执行不了，shebang 失败后 shell 会把它当**脚本**读，报一串
  #    `line 3: use strict: command not found`。binding.gyp 里还有
  #    `<!@(node -p "require('node-addon-api').include")`，同样要靠 PATH 上的 node。
  #    ⚠️ 本地测不出这个缺陷：本机注册了 riscv64 的 binfmt，那些 riscv64 二进制**能跑**。
  #    所以「本地构建通过」在这件事上没有验证力——要么把 binfmt 摘掉测，要么在 CI 上测。
  preBuild = lib.optionalString stdenv.hostPlatform.isRiscV64 ''
    echo "== 为 riscv64 编 better-sqlite3（上游无预编译）=="
    (
      export PATH="${pkgs.buildPackages.nodejs}/bin:$PATH"
      cd node_modules/better-sqlite3
      node ${pkgs.buildPackages.nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js \
        rebuild --release --force_build=1
    )
  '';

  postInstall = ''
    wrapProgram "$out/bin/opencode-telegram" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  meta = {
    description = "OpenCode Telegram Bot - Secure Telegram client for OpenCode CLI";
    homepage = "https://github.com/grinev/opencode-telegram-bot";
    changelog = "https://github.com/grinev/opencode-telegram-bot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "opencode-telegram";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
