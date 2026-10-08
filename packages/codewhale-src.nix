{
  lib,
  rustPlatform,
  buildPackages,
  fetchFromGitHub,
  pkg-config,
  cmake,
  dbus,
  autoPatchelfHook,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "codewhale";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "codewhale-hq";
    repo = "Codewhale";
    rev = "v${version}";
    # fetchFromGitHub 的哈希按 fetchzip 语义（解包后的树），无法离线预算：
    # 取自本机构建报错的 `got:`，并用 `nix store prefetch-file --unpack`
    # 独立复算，两者一致（sha256-/aTVxY+l3S30wm31BlWExbkIZx8s2R2lqCsQJVZa7TE=）。
    #
    # ⚠️ 改 version 时**必须先清空 hash**（置 `lib.fakeHash`）再构建。hash 与
    # version 不同步时不会报错：固定输出派生（fixed-output derivation）的路径
    # 由 hash 决定，旧 hash 对应的 store 路径若仍在，Nix 直接复用**旧版本的
    # 源码树**，构建在一份与 version 不符的代码上跑完，全程无提示。
    hash = "sha256-/aTVxY+l3S30wm31BlWExbkIZx8s2R2lqCsQJVZa7TE=";
  };

  # Cargo.lock is in workspace root
  cargoLock = {
    lockFile = ./codewhale-src-Cargo.lock;
  };

  # rquickjs-sys gained riscv64gc bindings in 0.14.0 (0.10.1's lock), so the
  # former postPatch that materialized a copy of the x86_64 bindings — needed
  # while the lock pinned 0.12.2, which shipped none — is gone. Verified:
  # 0.14.0's src/bindings/{riscv64gc,x86_64}-unknown-linux-gnu.rs are
  # byte-identical, and the crate now ships the riscv64gc file itself.

  nativeBuildInputs = [
    pkg-config
    cmake
    autoPatchelfHook
  ];

  buildInputs = [
    dbus
    # 交叉 gcc 的 libgcc_s.so.1：二进制以 -lgcc_s 动态链接，autoPatchelfHook
    # 只会扫描 hostPlatform 依赖，需显式加入才能解析并注入 rpath。
    stdenv.cc.cc.libgcc
  ];

  # Only build CLI and TUI (default workspace members)
  buildAndTestSubdir = "crates/cli";

  # ring/cc-rs cross-compile fixes.
  #
  # 1) cc-rs inherits optimization/arch flags from the environment: clear the
  #    per-target and generic CFLAGS/CXXFLAGS (commit 7160431 + 22b9f28) so the
  #    riscv64 cross compiler gets a clean flag set.
  # 2) ring is also built for the HOST (x86_64) as a build-script dependency.
  #    For that host-side build cc-rs resolves the compiler by host triple
  #    (CC_x86_64_...), falls back to the derivation-level CC — the riscv64
  #    cross compiler — and then adds -m64 because arch == x86_64, which the
  #    cross gcc rejects. Point the host-triple vars at the build platform's
  #    toolchain explicitly.
  env = lib.optionalAttrs stdenv.hostPlatform.isRiscV {
    CFLAGS_riscv64_unknown_linux_gnu = "";
    CXXFLAGS_riscv64_unknown_linux_gnu = "";
    CFLAGS = "";
    CXXFLAGS = "";
    # cc-rs also inherits from Nix's internal flag variables; clear those too
    # so -m64 (x86_64-only) doesn't leak into the riscv64 cross-compiler.
    NIX_CFLAGS_COMPILE = "";
    NIX_CXXFLAGS_COMPILE = "";
    # Host-side (build-script) toolchain for the x86_64 build platform.
    "CC_x86_64_unknown_linux_gnu" = "${buildPackages.stdenv.cc}/bin/cc";
    "CC_x86_64-unknown-linux-gnu" = "${buildPackages.stdenv.cc}/bin/cc";
    "CXX_x86_64_unknown_linux_gnu" = "${buildPackages.stdenv.cc}/bin/c++";
    "AR_x86_64_unknown_linux_gnu" = "${buildPackages.stdenv.cc.bintools.bintools}/bin/ar";
    "AR_x86_64-unknown-linux-gnu" = "${buildPackages.stdenv.cc.bintools.bintools}/bin/ar";
  };

  # Skip tests during build (they require network access)
  doCheck = false;

  # v0.10.1 collapsed the two executables into one: `crates/tui` is now a
  # library (`autobins = false`, no `[[bin]]` target) that `crates/cli` links
  # against, and the allocator features say the allocators "belong exclusively
  # to the canonical codewhale-cli executable". So `cargoInstallHook` already
  # produced the whole runtime as a single `codewhale` binary — there is no
  # second `codewhale-tui` target left to build (0.10.0 still had one, which is
  # why this hook previously compiled it separately).
  #
  # The prebuilt releases ship the same bytes under both `codewhale` and
  # `codew`; upstream tells Cargo users to add a `codew` symlink, so mirror
  # that shape here, plus the pre-0.9.9 `codewhale-tui` alias for scripts.
  postInstall = ''
    ln -s codewhale $out/bin/codew
    ln -s codew $out/bin/codewhale-tui
  '';

  meta = {
    description = "Terminal coding agent for DeepSeek V4";
    homepage = "https://github.com/codewhale-hq/Codewhale";
    changelog = "https://github.com/codewhale-hq/Codewhale/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "codewhale";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}