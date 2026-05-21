(final: prev: let
  # 获取 llama.cpp 最新 release tag，去掉前缀 "b" 作为版本号
  # 例如: "b9245" -> "9245"
  # 离线或网络不可用时 fallback 到默认版本
  defaultVersion = "9254";

  fetchedTag = builtins.tryEval (
    let
      json = builtins.fromJSON (
        builtins.readFile (
          builtins.fetchurl "https://api.github.com/repos/ggerganov/llama.cpp/releases/latest"
        )
      );
    in json.tag_name
  );

  version = if fetchedTag.success
    then prev.lib.removePrefix "b" fetchedTag.value
    else defaultVersion;
in {
  llama-cpp-rocm = (prev.llama-cpp.override {
    rocmSupport = true;
  }).overrideAttrs (oldAttrs: {
    inherit version;
    __intentionallyOverridingVersion = true;
  });
})
