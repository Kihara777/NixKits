# llama-cpp-rocm: overlay that tracks upstream llama.cpp latest release.
#
# Version is fetched dynamically via builtins.fetchurl (impure fetch) at evaluation
# time — no hash parameter means "fetch the current resource regardless of content".
# This avoids the instability of locking a rapidly-changing API URL in flake.lock.
#
# Requirements:
#   • Pure mode (default): falls back to nixpkgs llama-cpp.version
#   • Impure mode (--impure): fetches live upstream release tag → version
#
# Graceful fallback to nixpkgs version on network / API failures in all modes.
(final: prev: let
  fetchedTag = builtins.tryEval (
    let
      json = builtins.fromJSON (
        builtins.readFile (
          builtins.fetchurl "https://api.github.com/repos/ggml-org/llama.cpp/releases/latest"
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