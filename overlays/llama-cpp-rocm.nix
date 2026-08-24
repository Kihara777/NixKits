# This overlay dynamically tracks the latest llama.cpp release tag via a
# flake input (llama-cpp-ver). The curried form `{ llama-cpp-ver }: (final: prev: ...)`
# is deliberate — use it through the flake (`nixkits.overlays.llama-cpp-rocm`),
# not directly in `nixpkgs.overlays`.
{ llama-cpp-ver }:
(final: prev: let
  fetchedTag = builtins.tryEval (
    let
      json = builtins.fromJSON (
        builtins.readFile (
          llama-cpp-ver
        )
      );
    in json.tag_name
  );

  rawVersion = if fetchedTag.success
    then fetchedTag.value
    else prev.llama-cpp.version;
  # llama.cpp 上游版本号方案从 build number（b10549）切换为语义化版本
  # （v0.2.0）。剥离 b/v 前缀得到纯版本号；build number 无法从语义化
  # 版本推导出整数，故覆盖 LLAMA_BUILD_NUMBER 为 0 —— 否则 nixpkgs 会把
  # version 传入 LLAMA_BUILD_NUMBER，生成 `int LLAMA_BUILD_NUMBER = v0.2.0;`
  # 导致 C++ 编译失败（too many decimal points）。
  version = prev.lib.removePrefix "v" (prev.lib.removePrefix "b" rawVersion);
in {
  llama-cpp-rocm = (prev.llama-cpp.override {
    rocmSupport = true;
  }).overrideAttrs (oldAttrs: {
    inherit version;
    __intentionallyOverridingVersion = true;
    # 后出现的 -D 覆盖 nixpkgs 里 `cmakeFeature "LLAMA_BUILD_NUMBER" finalAttrs.version`。
    cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DLLAMA_BUILD_NUMBER=0" ];
  });
})
