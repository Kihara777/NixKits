# NixKits · impure 通道 —— 只有 llama-cpp-rocm，浮动版本，不提交 flake.lock。
#
# 存在的理由只有一个：把「每次求值都可能变」的那个量（llama.cpp 的最新版本）
# 关在这一个分支里，好让 main 可以提交 flake.lock。详见 README.md。
{
  description = "NixKits impure channel — llama-cpp-rocm only, floating upstream version, no lockfile";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # 浮动输入：上游 llama.cpp 最新 release 的 JSON（普通 URL 输入，不是 flake）。
    # Nix 不会给这类 fetch 附加 access-tokens，未认证额度 60 次/小时；
    # 撞上限流时用 `--override-input llama-cpp-ver path:<json>` 覆盖（CI 就这么做）。
    llama-cpp-ver.url = "https://api.github.com/repos/ggml-org/llama.cpp/releases/latest";
    llama-cpp-ver.flake = false;
  };

  outputs = { self, nixpkgs, llama-cpp-ver, ... }: {
    # curried overlay，形状与 main 中的同名定义一致：
    #   { llama-cpp-ver }: (final: prev: …)
    # 外部应经 `nixkits-impure.overlays.default` 使用，不要直接塞进 nixpkgs.overlays。
    overlays.default = import ./overlay.nix { inherit llama-cpp-ver; };

    nixosModules.default = import ./module.nix;
    nixosModules.llama-cpp-rocm = self.nixosModules.default;

    # ROCm 的实际目标是 x86_64-linux（本机 UMA 设备即此架构）。
    # 其他架构请自行给 nixpkgs `.override { rocmSupport = true; }` 是否成立做判断，
    # 不要假定这里能过。
    packages.x86_64-linux = {
      llama-cpp-rocm = (import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
      }).llama-cpp-rocm;
      default = self.packages.x86_64-linux.llama-cpp-rocm;
    };
  };
}
