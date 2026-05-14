{ llama-cpp-src }:

final: prev: {
  llama-cpp-rocm = prev.llama-cpp-rocm.overrideAttrs (oldAttrs: {
    src = llama-cpp-src;
  });
}
