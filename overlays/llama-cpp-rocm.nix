final: prev: {
  llama-cpp-rocm = prev.llama-cpp.override {
    rocmSupport = true;
  };
}
