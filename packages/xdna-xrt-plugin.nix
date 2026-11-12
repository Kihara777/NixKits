{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  git,
  python3,
  xrt,
  libdrm,
  opencl-headers,
  ocl-icd,
  ncurses,
  protobuf,
  zlib,
  openssl,
  boost,
  rapidjson,
  systemtap-sdt,
  libuuid,
}:

# xdna-xrt-plugin —— XRT 与 XDNA NPU 之间的那层胶水。
#
# ## 为什么需要它
#
# XRT 基座（`packages/xrt.nix`）认的是 PCIe 板卡；装上之后 `xrt-smi examine` 会说
# `Device(s) Present: 0`。AMD 的 `xdna-driver` README 写得很清楚：
# 「with both XRT **and XRT plugin** packages installed, user can start using XDNA device」。
# 内核那半（`amdxdna.ko`）由内核自带（这台机器 7.3.0 里是 0.10.0，已加载），
# 所以本包**只编用户态 shim**。
#
# ## 走 `XRT_UPSTREAM=ON`
#
# 它的顶层 CMakeLists 有两条路：
#   - `native.cmake`：把 `<src>/xrt` 子模块整个编一遍（那是 DEB 包的做法）；
#   - `upstream.cmake`：**只编 `src/shim`，XRT 的 headers/targets 由外部提供**。
# 我们已经有 XRT 包了，所以走后者——这同时避免把 XRT 编两遍。
#
# `SKIP_KMOD` 默认就是 ON，不必显式给；给了也无妨，写出来是为了读的人知道
# 「这个包不含内核模块」是有意的。
stdenv.mkDerivation (finalAttrs: {
  pname = "xdna-xrt-plugin";
  version = "unstable-2026-11-11";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "amd";
    repo = "xdna-driver";
    # 与 `packages/xrt.nix` 里钉的 XRT commit 来自**同一次** submodule 更新
    # （`amd/xdna-driver@1d3e56f8` 的 `xrt` 指向 `06c43a7f`）。驱动与运行时错配的症状
    # 是「设备在、就是打不开」，比编译失败难查。
    rev = "1d3e56f8cfe2033ddd35b534b8b598e94ea2663b";
    # **必须带子模块**（2026-11-04 实测）：shim 直接 `#include "core/common/system.h"`，
    # 那是 XRT **源码树里**的内部头，XRT 装包时并不安装它。所以 `XRT_UPSTREAM=ON`
    # （只编 shim、XRT 由外部提供）这条路走不通——试过，报
    # `fatal error: core/common/system.h: No such file or directory`。
    #
    # 带子模块后走 native 分支，`CMake/xrt.cmake` 会 `add_subdirectory(xrt)` 编一个
    # **裁剪过**的 XRT（排除了 xocl / edge / tools / xrt 等）。代价是 XRT 编两遍，
    # 收益是 shim 拿到它真正依赖的内部头。
    fetchSubmodules = true;
    hash = "sha256-lo6JOh3259ITAPuWOV3NdpxeLvjve1HYxQGmFLIv7ZQ=";
  };

  # `git`：子模块里的 XRT 在 `src/CMake/settings.cmake:46` 硬要求它
  # （`-- GIT not found, required for internal build`），用来算版本号。
  nativeBuildInputs = [ cmake pkg-config git python3 ];
  # 子模块里那份 XRT 走 `nativeLnx.cmake`，它的依赖与 `packages/xrt.nix` 同一套
  # （OpenCL 在 configure 期就检查，缺了直接 `Looking for OPENCL - not found`）。
  buildInputs = [ xrt libdrm opencl-headers ocl-icd ncurses protobuf zlib openssl boost rapidjson libuuid systemtap-sdt ];

  cmakeFlags = [
    # **不开 `XRT_UPSTREAM`**（2026-11-04 实测）：那条路假设 XRT 的 header/target 由外部
    # 提供，而 shim 要的是 XRT **源码树里**的 `core/common/system.h`。走 native，
    # 用子模块里那份裁剪过的 XRT。
    # 内核模块由内核提供（`amdxdna.ko` 0.10.0），这里不编、也不打包固件。
    "-DSKIP_KMOD=ON"
    # **两层要分开管**（2026-11-04 实测）：
    #   - CMake 层 `runtime_src/CMakeLists.txt:29` 用 `if (NOT XRT_ENABLE_USDT)` 决定
    #     要不要检查 `sys/sdt.h`——所以这里**必须**传 `OFF`，否则 configure 就死；
    #   - C 层 `trace.h` 用 `#ifdef`，传 `-D` 会把宏**定义**出来（OFF 也算已定义），
    #     于是它照样去 include 那个头 → `fatal error: sys/sdt.h`。
    # 所以 CMake 传 OFF（跳过检查），同时 postPatch 把 `#ifdef` 改成恒假（走空宏分支）。
    "-DXRT_ENABLE_USDT=OFF"
    "-DLINUX_FLAVOR=nixos"
    "-DLINUX_VERSION=0"
    # 它的 `CMake/pkg.cmake:166` 按发行版选 CPack 生成器，只认 deb/rpm/arch：
    #
    #   Unknown Linux package flavor: . Supported distributions: …
    #
    # 我们**不需要**它的打包格式（产物由 nix 接管），给 `arch` 让它走 TGZ 分支——
    # 那条分支就是「没有原生生成器、只产出文件」，正是我们要的。
    "-DXDNA_CPACK_LINUX_PKG_FLAVOR=arch"
  ];

  # 这两条 install 是给 DEB 打包的「测试目录」（`/bins`）准备的：它们想装
  # `xrt_core` / `xrt_coreutil` 两个库。而在 upstream 模式下，那两个是**外部 XRT 包**
  # 提供的 imported target，`install(TARGETS …)` 不接受 imported target：
  #
  #   CMake Error at src/shim/CMakeLists.txt:76 (install):
  #     install TARGETS given target "xrt_core" which does not exist.
  #
  # 我们要装的是 shim 本身（上一条 `install(TARGETS ${XDNA_TARGET} …)` 就是），
  # 那两个库已经在 `xrt` 包里。删掉这两条——**上游在 upstream 分支下本来就不该走到它们**。
  postPatch = ''
    # `XDNA_BIN_DIR` 被写死成 `/bins`（`CMakeLists.txt` 里 `set(XDNA_BIN_DIR /bins)`），
    # 那是它给 DEB 打包留的「测试产物目录」：
    #   file cannot create directory: /bins/./nix/store/<hash>-xdna-xrt-plugin/lib
    # 我们不要那个目录，把用到它的 install 行一并删掉（第 76/77 行的 XRT_CORE 两条也在此列）。
    sed -i '/XDNA_BIN_DIR/d' src/shim/CMakeLists.txt

    # `CMake/pkg.cmake:29-37` **无条件覆盖** `XDNA_CPACK_LINUX_PKG_FLAVOR`
    # （先看 `/etc/arch-release`，否则 source `/etc/os-release` 取 `$ID`）——
    # `set()` 不检查是否已有值，所以 `-D` 传进去被它盖掉，仍然报
    # `Unknown Linux package flavor: .`（NixOS 的 ID 是 "nixos"）。
    #
    # 让 arch 分支恒成立：我们只要它产出文件，不要它的打包格式。
    sed -i 's|if (EXISTS "/etc/arch-release")|if (TRUE)|' CMake/pkg.cmake

    # `xrt/src/runtime_src/core/common/detail/linux/trace.h` 用的是 `#ifdef XRT_ENABLE_USDT`：
    #   定了宏 → `#include <sys/sdt.h>`；没定 → 把 STAP/DTRACE 宏定义成空操作。
    # 所以**不能**用 `-DXRT_ENABLE_USDT=OFF`——`#ifdef` 只看"有没有定义"，值是多少不管，
    # 传 OFF 反而把它打开了（2026-11-04 实测：`fatal error: sys/sdt.h`）。
    # 我们不要探针，直接让它走 else 分支。
    sed -i 's|#ifdef XRT_ENABLE_USDT|#if defined(XRT_ENABLE_USDT) \&\& defined(XRT_USDT_PLEASE)|' \
      xrt/src/runtime_src/core/common/detail/linux/trace.h
  '';

  # 同 `packages/xrt.nix`：安装前缀被当成相对路径又拼了一次，产物落在
  # `$out/nix/store/<hash>/lib/`（2026-11-04 实测）。挪上来，删掉那层。
  postInstall = ''
    if [ -d "$out/nix/store" ]; then
      for d in "$out"/nix/store/*/; do
        [ -d "$d" ] || continue
        cp -a "$d". "$out/"
      done
      rm -rf "$out/nix"
    fi
  '';

  meta = {
    description = "XRT plugin (shim) for AMD XDNA NPUs";
    homepage = "https://github.com/amd/xdna-driver";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.kitsunori ];
    platforms = [ "x86_64-linux" ];
  };
})
