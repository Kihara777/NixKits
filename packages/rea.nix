{
  lib,
  buildNpmPackage,
  fetchurl,
  makeWrapper,
  procps,
  jdk,
  # version/hash/npmDepsHash/lockFile 可覆盖，便于将来拆通道（如需要）。
  version ? "6.7.0",
  # npm registry 的 integrity 是 sha512；这里必须原样写 sha512-，写成 sha256- 会被
  # 「base64 长度对不上」拒掉（错误会出现在 npmDeps 的求值栈里，看起来像别处的错）。
  hash ? "sha512-yhIx2ioJYYT1C/tONfYeitC6LhnKmCh+ZwRUOgYuhSc733lGhkkt73zhug9WmLgxoMdKuqIYGCoBfD4fXkOhFw==",
  npmDepsHash ? "sha256-t6CBYCkMsgrSfSSyMLeY+Ltl0DT8Yo13STgje8dIH0M=",
  lockFile ? ./rea-package-lock.json,
}:

# REA（Reverse Engineer Anything）——「用 agent 逆向任何东西」的 CLI + MCP 服务。
#
# 上游：https://github.com/morluto/rea（MIT），npm 包 `rea-agents`。
# 这里打包的是**官方已构建好的 npm tarball**，与上游发布物逐字节一致：
#   · `bin/rea` → `scripts/rea.mjs` → `dist/`（dist 由上游 `npm run compile` 产出，
#     自己重建要整棵 turbo monorepo 的 devDependencies，且产物与发布物不一定相等）；
#   · 因此 `dontNpmBuild = true`——本包不编译任何东西，只装依赖 + 落盘文件。
#
# 运行时依赖的边界（诚实记录，别当成全都支持）：
#   · 纯静态分析（JS/Electron、.NET、Go、Rust、Godot PCK、IL2CPP、SQLite、包与
#     资源、WASM/固件头）**不需要任何外部引擎**，这是本包的主要用途；
#   · 原生逆向（伪代码/反汇编）需要外部安装的 Hopper / Ghidra / IDA —— 本包不提供，
#     也不去猜它们的路径；
#   · Android 需要 JADX（外部 jar，见 `REA_JADX_MCP_JAR`）**与完整 JDK**：
#     JDK 是本包**带上**的（wrapper 把 `java` 放进 PATH），JADX 仍要自备 ——
#     REA 要的是 `jadx-headless-mcp` 的 jar，不是 nixpkgs 里的 `jadx` 可执行文件；
#   · Linux 上静态 JS/Electron 分析与固件工具启动需要 procps 的 `ps`（README 明说
#     进程归属检查依赖它）——这一条也是本包**带上**的，不是可选项；
#   · `frida` 是上游的 optionalDependency，靠 prebuild-install 在安装期下载预编译
#     二进制；Nix 构建离线且 `--ignore-scripts`，因此**动态插桩在本包内不可用**，
#     frida 的相关命令会失败而不是静默降级。
buildNpmPackage (finalAttrs: {
  pname = "rea";
  inherit version;

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchurl {
    url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${version}.tgz";
    inherit hash;
  };

  inherit npmDepsHash;

  # Prebuilt npm package (dist/ 已在 tarball 内)；没有要跑的构建脚本。
  dontNpmBuild = true;

  # 唯一带 install script 的依赖是 optionalDependency `frida`：它的脚本会用
  # prebuild-install 去**下载**预编译二进制（还要跑 `which`/Python），在 Nix 构建
  # 沙箱里必然失败（实测：EACCES 写 store、DNS 解析被禁、`which: not found`）。
  # `npm ci` 本来就带 `--ignore-scripts`，但 nixpkgs 的 npmConfigHook 在它之后
  # 还会跑一次 `npm rebuild`，那一步会把脚本跑起来——于是整个构建挂在 prune 阶段。
  # 本包没有任何需要重建的原生模块（@lydell/node-pty 用平台预编译的 optional 包），
  # 所以 rebuild 也不需要脚本。代价：frida 的动态插桩在本包内不可用，见文件头。
  npmRebuildFlags = [ "--ignore-scripts" ];

  # npm tarball 不带 lockfile：vendor 一份（`nix-flake-update-check` 技能里的流程）。
  #
  # ⚠️ 必须同时删掉 `devDependencies`：vendored lock 只含生产依赖，而 tarball 的
  #    package.json 带着 24 个 devDependencies（vitest / stryker / typescript /
  #    turbo …）。不删的话 `npm ci` 会因「lock 与 package.json 不同步」硬失败；
  #    删了才让两份东西同源。
  #    字段顺序**不可假设**：本 tarball 里 devDependencies 夹在 overrides 与
  #    optionalDependencies 之间（不是最后一个），所以不能按「删到文件末尾」截断
  #    ——那会连 optionalDependencies/allowScripts 一起删掉，构建照样成功而产物
  #    少了 frida 一类的可选依赖（静默损坏）。这里用 JSON 解析改写，与位置无关。
  # ⚠️ 这个 `postPatch` 会被跑**两遍**：一遍在 `fetchNpmDeps`（`stdenvNoCC`，
  #    里面**没有 node**），一遍在主 derivation。所以里面只能用 stdenv 自带的
  #    工具（awk/sed），不能用 `node -e` 改 package.json —— 实测第一版正是这样
  #    死在 npm-deps 的 patchPhase：`node: command not found`（退出码 127）。
  #    下面是按**块**删除并用 awk 修尾逗号的写法（与 `packages/dsh.nix` 同一段，
  #    两种上游布局都覆盖：devDependencies 在中间、或在末尾）。
  postPatch = ''
    cp ${lockFile} package-lock.json
    awk '
      /^  "devDependencies": \{/ { skip = 1; next }
      skip { if ($0 ~ /^  \},?$/) { skip = 0; deleted = 1 } next }
      { buf[++n] = $0 }
      END {
        if (deleted) {
          last = n
          while (last > 0 && buf[last] ~ /^[[:space:]]*$/) last--
          if (last >= 2 && buf[last] ~ /^\}[[:space:]]*$/ && buf[last-1] ~ /,[[:space:]]*$/)
            sub(/,[[:space:]]*$/, "", buf[last-1])
        }
        for (i = 1; i <= n; i++) print buf[i]
      }
    ' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  nativeBuildInputs = [ makeWrapper ];

  # bin 由 nodejsInstallExecutables 生成 wrapper（`$out/bin/rea` → `$out/bin/.rea-wrapped`
  # → node + scripts/rea.mjs）。这里在 wrapper 上补 PATH：
  #   · procps 的 `ps`：README 明确说 Linux 的静态 JS/Electron 分析与固件工具启动
  #     依赖它做进程归属检查；
  #   · `jdk`：Android 分析要把 `java` 跑起来（REA 调 JADX 的 jar）。代价是这个
  #     JDK 会进本包的闭包（约 +200 MiB），这是有意的选择而不是遗漏——不用 Android
  #     分析的人也会带上它。
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ procps jdk ])
  ];

  meta = {
    description = "Reverse engineer anything with agents — one CLI and MCP server (static app/binary analysis down to native binaries)";
    homepage = "https://github.com/morluto/rea";
    changelog = "https://github.com/morluto/rea/releases";
    license = lib.licenses.mit;
    mainProgram = "rea";
    # 只声明实测过的平台：@lydell/node-pty 只提供 x64/arm64 预编译件，
    # riscv64 上缺 node-pty（REA 会 import 它），不能声称支持。
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ ];
  };
})
