{
  lib,
  gcc13Stdenv,
  fetchgit,
  cmake,
  pkg-config,
  git,
  python3,
  boost,
  protobuf,
  ncurses,
  opencl-headers,
  ocl-icd,
  libdrm,
  libudev-zero,
  zlib,
  openssl,
  curl,
  rapidjson,
  libuuid,
}:

# XRT —— AMD/Xilinx 的运行时（XDNA NPU 的用户态那一半）。
#
# ## 为什么用这个 commit
#
# NPU 的内核驱动 `amdxdna` 是**内核自带**的（这台机器 7.3.0 内核里是
# `amdxdna_accel_driver 0.10.0`，2026-11-04 实测加载成功）。所以本仓要打的是
# **用户态**：XRT 基座 + `xdna-driver` 的 XRT 插件。
#
# 版本不能随便挑：`amd/xdna-driver` 用 git submodule **钉死**一个 XRT commit，
# 两者是一起测过的。这里就用它钉的那个（`6af5787` 的 submodule →
# `fdb373b1a43cd44201c799b80e2dd38df68e86b1`），**不用 XRT master**——
# 驱动与运行时版本错配的症状是「设备在、就是打不开」，那比编译失败难查得多。
# 为什么不用默认 stdenv（2026-11-04 实测）：nixpkgs 的 gcc 16.2 在编
# `src/runtime_src/hip/core/` 时从 `<format>` 里报
#
#   gcc-16.2.0/include/c++/16.2.0/format:4550:30:
#   error: expected an identifier for the attribute name
#
# 那是 gcc 16 对 `__attribute__` 解析收紧与本项目写法相撞，不是缺库。
# 上游的测试矩阵是 gcc 11–13，所以退到 **gcc13**——跟着上游测过的版本走，
# 而不是去改它的源码。
gcc13Stdenv.mkDerivation (finalAttrs: {
  pname = "xrt";
  version = "unstable-2026-11-03";

  src = fetchgit {
    url = "https://github.com/Xilinx/XRT";
    rev = "fdb373b1a43cd44201c799b80e2dd38df68e86b1";
    # **必须带子模块**（2026-11-04 实测）：`src/runtime_src/xdp` 与
    # `core/common/aiebu` 是 git submodule，`fetchFromGitHub` 的 tarball 里是**空目录**，
    # 于是配置阶段直接崩：
    #
    #   CMake Error: The source directory /build/source/src/runtime_src/xdp
    #   does not contain a CMakeLists.txt file.
    #
    # 而且 `xrt_add_subdirectory(xdp)` 是**无条件**的——关不掉，只能把内容取回来。
    fetchSubmodules = true;
    hash = "sha256-pb2dHNPiTBV+P2wKSXdU03rMYGg9XBhQHUFItkid2uI=";
  };

  # 2026-11-04：配置阶段已通过（依赖齐、子模块齐、LINUX_FLAVOR 兜住），
  # 这里放开到完整构建。之前那版只跑 `unpackPhase`/`patchPhase`/`configurePhase`，
  # 症状是「配置过、但没有产出 output path」——那本来就是只验配置的写法。

  nativeBuildInputs = [ cmake pkg-config git python3 ];
  buildInputs = [
    boost
    protobuf
    ncurses
    opencl-headers
    ocl-icd
    libdrm
    libudev-zero
    zlib
    openssl
    curl
    rapidjson
    # `core/include/xrt/detail/xclbin.h` 里 `#include <uuid/uuid.h>`。
    # 缺它的症状是一连串 `fatal error: uuid/uuid.h: No such file or directory`
    # （2026-11-04 实测：xocl / core_common / runner 一起挂，看第一条就够）。
    libuuid
  ];

  # aiebu 把 `aiebu-asm` / `aiebu-dump` / `aiebu-transform` **静态链接**：
  #
  #     target_link_options(... "-static" "-static-libgcc" "-static-libstdc++")
  #
  # NixOS 上直接崩：`ld.bfd: cannot find -lc / -lm / -lpthread`（2026-11-04 实测，
  # 55% 处）。上游为此留了 `AIEBU_UPSTREAM` 开关（注释：「Upstreaming does not allow
  # statically linked executables」），但**传 `-DAIEBU_UPSTREAM=ON` 不生效**——
  # 已在 cmakeFlags 里试过。所以直接改源：只去掉 `-static`，保留
  # `-static-libgcc` / `-static-libstdc++`（那两个是上游为躲 `gcc_s_asneeded`
  # 才加的，与 NixOS 不冲突，去掉反而可能引回它躲的那个坑）。
  postPatch = ''
    for f in \
      src/runtime_src/core/common/aiebu/src/cpp/utils/asm/CMakeLists.txt \
      src/runtime_src/core/common/aiebu/src/cpp/utils/dump/CMakeLists.txt \
      src/runtime_src/core/common/aiebu/src/cpp/utils/transform/CMakeLists.txt; do
      substituteInPlace "$f" \
        --replace-fail '"-static" "-static-libgcc" "-static-libstdc++"' '"-static-libgcc" "-static-libstdc++"'
      # `-DAIEBU_UPSTREAM=ON` 传了也不生效（**实测**：`tranform_check_dynamic_deps`
      # 那个只在 `if (NOT AIEBU_UPSTREAM)` 里建的构建目标照样被建出来，然后在
      # NixOS 上判「有动态依赖」失败）。说明这个变量在 XRT 的某处被覆盖掉了。
      # 不去追它被谁覆盖——直接让这三个判断恒假，等价于「按上游子模块的方式构建」。
      substituteInPlace "$f" \
        --replace-fail 'if (NOT AIEBU_UPSTREAM)' 'if (FALSE)'
    done

    # 两处把安装路径写死成 `/usr/local/bin`：
    #   core/tools/xbflash2/CMakeLists.txt:33
    #   core/pcie/tools/xbflash.qspi/CMakeLists.txt:18
    # NixOS 上没有那个目录，install 阶段直接 `file cannot create directory:
    # /usr/local/bin`（2026-11-04 实测，两处先后各报一次）。都指到本包的 bin。
    for f in \
      src/runtime_src/core/tools/xbflash2/CMakeLists.txt \
      src/runtime_src/core/pcie/tools/xbflash.qspi/CMakeLists.txt; do
      substituteInPlace "$f" \
        --replace-fail 'set(XBFLASH_INSTALL_DEST "/usr/local/bin")' \
          'set(XBFLASH_INSTALL_DEST "${placeholder "out"}/bin")'
    done

    # **根因**（`src/CMake/xrtVariables.cmake:28`）：
    #
    #     set (XRT_BUILD_INSTALL_DIR [$]{CMAKE_BINARY_DIR}[$]{CMAKE_INSTALL_PREFIX})
    #
    # 它假设 prefix 是**相对**路径（DEB 包的做法），拼出来是
    # `/build/source/build/nix/store/…`；而 nix 的 prefix 是绝对路径，于是安装
    # 落到了 `$out/$out/…`，`xrt.pc` 里也出现 `[$]{prefix}//nix/store/…/lib`，
    # 被 fixup 判成坏路径。这正是 nixpkgs#144170 描述的那类拼接错误。
    # 让 prefix 自己就是最终目录。
    # **替换串里那一对双单引号加美元号是真的变量写法**：nix 会把它转成字面，
    # 而 shell 单引号里它不被展开，sed 的替换部分也不解析美元号。
    # 上一版我在替换串里写了「方括号包美元号」——那玩意只在**匹配模式**里是字符类，
    # 在替换串里就是字面三个字符，于是写进去的是字面方括号，cmake 当然不认。
    # **模式里必须带上右花括号**：目标行是 `…PREFIX})`，`PREFIX` 后面先是 `}` 再是 `)`。
    # 我原来写 `.*CMAKE_INSTALL_PREFIX)`（少了 `}`），sed 在整份文件里一次都没匹配到——
    # 而它又不报错，于是每一轮都是「构建跑了、路径还是双份」。od 一看才明白。
    sed -i 's|XRT_BUILD_INSTALL_DIR .*CMAKE_INSTALL_PREFIX}|XRT_BUILD_INSTALL_DIR      ''${CMAKE_INSTALL_PREFIX}|' \
      src/CMake/xrtVariables.cmake
    # 判据：改完读回来。命令成功 ≠ 文件变了。
    grep -qE 'XRT_BUILD_INSTALL_DIR +[$][{]CMAKE_INSTALL_PREFIX[}]' src/CMake/xrtVariables.cmake \
      || { echo "xrt.nix: xrtVariables.cmake 没改成" >&2; exit 1; }

    # OpenCL ICD 注册文件也写死到 `/etc/OpenCL/vendors`（`src/CMake/icd.cmake:17`）。
    # NixOS 上装不进去（`file cannot create directory: /etc/OpenCL/vendors`）。
    # 落到 store，消费方用 `OCL_ICD_VENDORS` 指过来——这是 nix 里放 ICD 的标准做法。
    substituteInPlace src/CMake/icd.cmake \
      --replace-fail 'set(OCL_ICD_INSTALL_PREFIX "/etc/OpenCL/vendors")' \
        'set(OCL_ICD_INSTALL_PREFIX "${placeholder "out"}/etc/OpenCL/vendors")'
  '';

  # `xrt.pc` 生成时把 `${prefix}` 和绝对安装路径拼在一起，结果是
  #
  #     libdir=${prefix}//nix/store/<hash>-xrt-…/lib
  #
  # fixup 判它为坏路径（`Broken paths found in a .pc file`，2026-11-04 实测）。
  # 根因是 XRT 的 `XRT_BUILD_INSTALL_DIR` 在 store 路径下退化成绝对路径又被当相对用。
  # 不去追那个变量，直接把重复的绝对前缀去掉：`${prefix}` 本来就等于 $out。
  postInstall = ''
    # `xrt.pc` 的模板把绝对路径和 prefix 拼在一起：
    #     prefix=/nix/store/<hash>-xrt-…
    #     libdir=[$]{prefix}//nix/store/<hash>-xrt-…/lib      ← 双份
    # fixup 判它坏（`Broken paths found in a .pc file`）。
    #
    # ⚠️ 用 `find` 而不是 `$out/lib/pkgconfig/*.pc`：这份 pc **不在** `$out/lib` 下，
    # 它在 `$out/$out/lib/pkgconfig/`（安装路径自己也双份了）。上一版按固定目录找，
    # 一个字都没改到，而日志显示的却是「构建仍在报错」——**看不出「没改到」**。
    find "$out" -name '*.pc' -type f | while read -r pc; do
      # **单引号**：双引号里 bash 会把 nix 转出来的那个美元变量展开成空串，
      # 于是 sed 只收到 `s|//|/|g`——看着像执行了，实际匹配的不是那一处。
      sed -i 's|''${prefix}//|''${prefix}/|g' "$pc"
    done
    # 判据：改完立刻读回来。命令成功不等于文件变了。
    for pc in $(find "$out" -name '*.pc' -type f); do
      if grep -q '[$]{prefix}//' "$pc"; then
        echo "xrt.nix 后处理失败：$pc 里仍有双斜杠" >&2
        exit 1
      fi
    done

    # 有组件把绝对 prefix 当相对拼，装到了 `$out/nix/store/<hash>/*`（2026-11-04 实测：
    # `xrt-smi` / `xball` 在那儿，而 `setup.sh` 在 `$out` 顶层）。结果运行时报
    # `Could not find XRT setup script`——wrapper 里的相对路径（`…/unwrapped/../../setup.sh`）
    # 恰好假设这一层就在 `$out` 下。
    #
    # 挪上来，再把那层空的 `nix/` 删掉。这是「让它自洽」，不是掩盖：
    # 内容全都来自这次安装，只是位置差了一层。
    if [ -d "$out/nix/store" ]; then
      for d in "$out"/nix/store/*/; do
        [ -d "$d" ] || continue
        cp -a "$d". "$out/"
      done
      rm -rf "$out/nix"
    fi
  '';

  cmakeFlags = [
    # **不构建内核模块**：`amdxdna.ko` 由内核提供（这台机器上是 7.3.0 自带），
    # DKMS 在 NixOS 上没有意义，而且会和内核里的那份打架。
    "-DXRT_ENABLE_DKMS=OFF"
    # 只要 host/PCIe 的运行时；Alveo 与 edge 是别的硬件形态。
    "-DXRT_ALVEO=OFF"
    "-DXRT_EDGE=OFF"
    # USDT（systemtap 探针）我们用不上，而它要 `sys/sdt.h`（systemtap-sdt）。
    # 关掉比拉一份 systemtap 进闭包干净——探针是给 `xrt-smi` 追踪用的，不是运行必需。
    "-DXRT_ENABLE_USDT=OFF"
    # XRT 的 `xclbinutil/CMakeLists.txt` 里有这么一行（2026-11-04 实测会崩）：
    #
    #     if ((${LINUX_FLAVOR} STREQUAL "ubuntu") AND ("x${LINUX_VERSION}x" STREQUAL "x16.04x"))
    #
    # NixOS 上这两个变量是**空**的，展开成 `if (("" STREQUAL "ubuntu") …)`，
    # CMake 直接语法错误（`if given arguments: "(" "STREQUAL" "ubuntu" ")"`）。
    # 给它一个明确的、**不是 ubuntu** 的标识，它就走 else 分支去 find_package(RapidJSON)
    # ——那条分支是正常的，rapidjson 在 buildInputs 里。
    "-DLINUX_FLAVOR=nixos"
    "-DLINUX_VERSION=0"
    # nixpkgs 的 `abseil-cpp`（20260817）头文件用 `std::partial_ordering` /
    # `std::strong_ordering`——那是 **C++20** 的东西，而 XRT 默认按旧标准编：
    #
    #   absl/types/compare.h:60: error: 'partial_ordering' has not been declared in 'std'
    #
    # 它不是缺库，是标准版本对不上。抬到 20。
    "-DCMAKE_CXX_STANDARD=20"
    # aiebu 默认把 `aiebu-asm` / `aiebu-dump` / `aiebu-transform` **静态链接**：
    #
    #   target_link_options(... "-static" "-static-libgcc" "-static-libstdc++")
    #
    # 在 NixOS 上这直接崩——`ld.bfd: cannot find -lc / -lm / -lpthread`（2026-11-04
    # 实测，55% 处）。上游自己留了开关：`AIEBU_UPSTREAM` 为真时走动态链接分支，
    # 注释写得很清楚「Upstreaming does not allow statically linked executables」。
    # 我们的场景正好是它描述的那种（XRT 把 aiebu 当 submodule 用）。
    "-DAIEBU_UPSTREAM=ON"
  ];

  meta = {
    description = "Xilinx Runtime (XRT) — userspace half of the XDNA NPU stack";
    homepage = "https://github.com/Xilinx/XRT";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.kitsunori ];
    platforms = [ "x86_64-linux" ];
  };
})
