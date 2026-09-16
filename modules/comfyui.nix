# ComfyUI integration — ROCm wiring + Strix Halo (gfx1151) accommodations.
#
#   - rocmGfxOverride option (HSA_OVERRIDE_GFX_VERSION)
#   - --disable-xformers in ROCm mode (nixpkgs xformers lacks ROCm backend)
#   - C build toolchain (gcc, binutils, make) for custom node compilation
#   - CC=gcc environment variable
#   - ROCm runtime (clr, rocminfo) via hardware.graphics
#   - GPU device access (DeviceAllow) + amdgpu.gttsize kernel param
#
# ── 本模块**不含补丁** ──────────────────────────────────────────────
# 它原名 `nixkits.comfyui-rocm`，因为最初是一个"给 ComfyUI 打 ROCm 补丁"
# 的项目。三个补丁已于 2026-09-15 全部删除 —— 上游 comfyui-nix 0.34.0
# 已把它们的成果全部内置，详见仓库根目录的 DEPRECATED.md。
#
# 现名 `nixkits.comfyui`：它做的是**集成接线**（服务选项、设备权限、
# 内核参数、工具链），而非修补上游代码。改名意在让名字与实际职责一致。
#
# 补丁删除的判定依据（保留在此以备回溯）：
#   - comfyui-nix-stdenv-api   : 上游已迁移 hostPlatform（旧写法 0 处，
#                                新写法 34 处）—— 静态可证
#   - comfyui-nix-strix-halo   : 上游已内置 ROCm 7.1 / PyTorch 2.10.0
#                                wheels（版本、URL、hash 逐字节一致）
#   - comfyui-nix-nixpkgs-compat: ⚠️ **此项判定曾出错**。初次结论是
#                                "不需要"，依据是一次 717-derivation 的
#                                构建 —— 但那次 scipy 是**缓存命中**，
#                                从未真正构建。实际在本地钉定的 nixpkgs
#                                组合下，scipy 的 test_support_moments_sample
#                                会因浮点断言失败。该补丁的价值依 nixpkgs
#                                组合而定，我们的组合恰好需要它。
#                                详见 DEPRECATED.md。
#
# This module extends services.comfyui; enable with:
#
#   nixkits.comfyui.enable = true;
#   services.comfyui.enable = true;
#
{ config, lib, pkgs, ... }:
let
  comfyCfg = config.services.comfyui or null;
  cfg = config.nixkits.comfyui;
  useRocm = comfyCfg != null && comfyCfg.gpuSupport == "rocm";
in
{
  options = {
    services.comfyui.rocmGfxOverride = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "11.0.0";
      description = ''
        Override the GPU architecture version reported to the ROCm runtime via
        the HSA_OVERRIDE_GFX_VERSION environment variable.

        This is useful for newer AMD GPUs that are not yet in the ROCm support
        matrix but are binary-compatible with an existing architecture.

        Common values:
        - "11.0.0": gfx1100 (RDNA 3) — recommended for gfx1151 (Strix Halo)
        - "11.5.1": gfx1151 native — may work if runtime recognizes it
        - "10.3.0": gfx1030 (RDNA 2) — fallback for older RDNA cards

        Only takes effect when gpuSupport = "rocm".
      '';
    };

    nixkits.comfyui = {
      enable = lib.mkEnableOption "ComfyUI ROCm support (GFX override, xformers bypass, C toolchain, Strix Halo optimizations)";

      gfxOverride = lib.mkOption {
        type = lib.types.str;
        default = "11.0.0";
        description = ''
          GPU architecture version to override via HSA_OVERRIDE_GFX_VERSION.
          - "11.0.0": gfx1100 (RDNA3) — most compatible for gfx1151
          - "11.5.1": gfx1151 native — try if ROCm runtime supports it
        '';
      };
    };
  };

  config = lib.mkIf (cfg.enable && (comfyCfg != null && comfyCfg.enable)) {
    assertions = [
      {
        assertion = config.services ? comfyui;
        message = ''
          nixkits.comfyui requires services.comfyui, but it was
          not found. Import the comfyui-nix module in your flake first.
        '';
      }
      {
        assertion = builtins.compareVersions pkgs.glibc.version "2.42" >= 0;
        message = ''
          nixkits.comfyui: ROCm 7.2 requires glibc >= 2.42 for GPU support
          (hsa-runtime needs GLIBC_ABI_GNU2_TLS symbol). Current glibc:
          ${pkgs.glibc.version}. Update your nixpkgs input.
        '';
      }
    ];

    # ⚠️ 曾在此处用 overlay 给 `pkgs.comfyui` 打 strix-halo 补丁（ROCm 7.2 wheels
    # + gfx1151 支持）。2026-09-15 移除：上游 0.34.0 已内置等效内容，且该补丁
    # 会与上游冲突。此 overlay 若保留，会因补丁文件不存在而**在构建期失败**
    # （求值期不报错，故不易察觉）。
    #
    # 当时保留它的另一层理由——覆盖 nixpkgs 里那个同名 `pkgs.comfyui`——也已不成立：
    # 上游模块自带 `disabledModules = [ "services/misc/comfyui.nix" ]`，
    # 其 `package` 选项即指向上游自己的构建，无需再由 overlay 介入。

    # Configure comfyui service for ROCm / Strix Halo
    services.comfyui = {
      gpuSupport = lib.mkDefault "rocm";
      rocmGfxOverride = lib.mkDefault cfg.gfxOverride;

      # Disable xformers in ROCm mode (nixpkgs xformers lacks ROCm backend)
      extraArgs = lib.optionals useRocm [ "--disable-xformers" ];

      # Environment: GFX override + C compiler for custom node builds
      environment = lib.mkMerge [
        (lib.mkIf (useRocm && comfyCfg.rocmGfxOverride != null) {
          HSA_OVERRIDE_GFX_VERSION = comfyCfg.rocmGfxOverride;
        })
        {
          CC = "gcc";
        }
      ];
    };

    # Ensure ROCm runtime is available
    hardware.graphics = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        rocmPackages.clr
        rocmPackages.rocminfo
      ];
    };

    # C build toolchain in service PATH for custom node builds
    systemd.services.comfyui.path = [
      pkgs.stdenv.cc
      pkgs.binutils
      pkgs.gnumake
    ];

    # Systemd service hardening for ROCm — allow GPU device access
    systemd.services.comfyui.serviceConfig = {
      DeviceAllow = [
        "/dev/kfd"
        "/dev/dri/renderD128"
      ];
    };

    # Recommended kernel parameters for Strix Halo (shared memory APU)
    # These improve GPU memory allocation for the unified memory architecture
    boot.kernelParams = lib.mkAfter [
      "amdgpu.gttsize=131072"  # 128GB GTT for large model support
    ];
  };
}
