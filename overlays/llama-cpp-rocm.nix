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

  version = if fetchedTag.success
    then prev.lib.removePrefix "b" fetchedTag.value
    else prev.llama-cpp.version;
in {
  llama-cpp-rocm = (prev.llama-cpp.override {
    rocmSupport = true;
  }).overrideAttrs (oldAttrs: {
    inherit version;
    __intentionallyOverridingVersion = true;
  });
})
