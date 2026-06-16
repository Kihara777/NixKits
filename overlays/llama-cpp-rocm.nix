# llama-cpp-rocm: overlay that tracks upstream llama.cpp latest release.
#
# Version is fetched dynamically via builtins.fetchurl at evaluation time.
# This avoids the instability of locking a rapidly-changing API URL in flake.lock.
# Graceful fallback to nixpkgs llama-cpp.version on network / API failures.
(final: prev: let
  fetchedTag = builtins.tryEval (
    let
      json = builtins.fromJSON (
        builtins.readFile (
          builtins.fetchurl {
            # Nix ≥ 2.19 allows empty hash for impure fetches in flakes.
            # This is intentional — the upstream releases are updated hourly,
            # so a fixed hash would be stale within minutes.
            url = "https://api.github.com/repos/ggml-org/llama.cpp/releases/latest";
            hash = "";
          }
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