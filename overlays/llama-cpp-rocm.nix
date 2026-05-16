(final: prev: {
  llama-cpp-rocm-mtp = (prev.llama-cpp.override {
    rocmSupport = true;
  }).overrideAttrs (oldAttrs: {
    npmDepsHash = "sha256-WaEePrEZ7O/7deP2KJhe0AwiSKYA8HOqETmMHUkmBe0=";
    src = final.fetchFromGitHub {
      owner = "am17an";
      repo = "llama.cpp";
      rev = "mtp-clean";
      hash = "sha256-UyjHNI27a/3OQU8giT32sim73toI1Uir6KcL4U+RFGI=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };
  });
})
