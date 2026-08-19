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
  version = "0.9.8";

  src = fetchFromGitHub {
    owner = "Hmbown";
    repo = "CodeWhale";
    rev = "v${version}";
    hash = "sha256-/j43zxaC7rOu4M2Sk9khI/Bb2drs9n/WghhJiKqQDyU=";
  };

  # Cargo.lock is in workspace root
  cargoLock = {
    lockFile = ./codewhale-src-Cargo.lock;
  };

  # rquickjs-sys 0.12.2 (newest release) does not ship riscv64gc bindings:
  # its build.rs non-bindgen path does include!("bindings/<TARGET>.rs"), so the
  # riscv64 cross build fails with "couldn't read .../bindings/
  # riscv64gc-unknown-linux-gnu.rs". Upstream ships byte-identical bindings for
  # every LP64 little-endian target (x86_64 == aarch64 == loongarch64 ==
  # powerpc64), so a copy is valid for riscv64gc. Drop it into the vendored
  # crate directory that cargoSetupPostUnpackHook materialized (and made
  # writable) in the build tree; $cargoDepsCopy points at it.
  postPatch = ''
    cp ${./codewhale-rquickjs-riscv64.rs} \
      "$cargoDepsCopy/rquickjs-sys-0.12.2/src/bindings/riscv64gc-unknown-linux-gnu.rs"
  '';

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

  # Build both CLI and TUI binaries
  postInstall = ''
    # Build TUI binary as well (not part of default-members).
    # cargoBuildHook always passes --target; mirror it here, otherwise the
    # bare cargo build falls back to the default target and cross builds link
    # with the wrong toolchain.
    cargo build --release --target ${stdenv.hostPlatform.rust.rustcTarget} -p codewhale-tui
    install -Dm755 target/${stdenv.hostPlatform.rust.rustcTarget}/release/codewhale-tui -t $out/bin
  '';

  meta = {
    description = "Terminal coding agent for DeepSeek V4";
    homepage = "https://github.com/Hmbown/CodeWhale";
    changelog = "https://github.com/Hmbown/CodeWhale/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "codewhale";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}