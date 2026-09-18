# ruyi devShell — RuyiSDK package manager for RISC-V development
#
# 补丁（ruyi-nixos-compat）现已并入 packages/ruyi/ruyi.nix，三通道共用，
# 故此处不再套 overlay —— devShell 与 flake 包 / NixOS 模块得到的是
# 同一个带 NixOS 兼容处理的构建。
{
  pkgs,
  ruyi,
}:

pkgs.mkShell {
  name = "ruyi-dev";
  packages = [ ruyi ];
  shellHook = ''
    echo "RuyiSDK $(ruyi --version 2>/dev/null | head -1)"
  '';
}
