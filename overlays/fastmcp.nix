# Overlay: fastmcp 3.4.7 + py-key-value-aio 0.4.5
#
# godot-ai requires fastmcp >= 3.4.0 (3.3.x has a circular-import bug in
# fastmcp.server).  nixpkgs pins fastmcp/fastmcp-slim at 3.3.1, so bump:
#   - fastmcp         3.3.1 → 3.4.7
#   - fastmcp-slim    3.3.1 → 3.4.7  (inherits version/src from fastmcp)
#   - py-key-value-aio 0.3.0 → 0.4.5 (fastmcp-slim 3.4 requires >=0.4.4,<0.5.0)
(final: prev: let
  fastmcpSrc = prev.fetchFromGitHub {
    owner = "PrefectHQ";
    repo = "fastmcp";
    tag = "v3.4.7";
    hash = "sha256-EysVbtFbop5ENupc9T5EmtUSZ8osVtQSzpwa6rea/OQ=";
  };
  pyKvSrc = prev.fetchFromGitHub {
    owner = "strawgate";
    repo = "py-key-value";
    tag = "0.4.5";
    hash = "sha256-N+bqgKkSVGEKW/BEWgcFiHEuFjGbgIn/j33Vd0YoJ7s=";
  };
in {
  python312 = prev.python312.override {
    packageOverrides = pyFinal: pyPrev: {
      # Use overridePythonAttrs (not overrideAttrs) — nativeCheckInputs is an
      # excludeDrvArgNames entry in mk-python-derivation, so plain overrideAttrs
      # cannot clear it; extendDrvArgs rebuilds nativeInstallCheckInputs from
      # the original value.  overridePythonAttrs handles the passthru layers
      # correctly so nativeCheckInputs = [] actually takes effect.
      fastmcp = pyPrev.fastmcp.overridePythonAttrs (old: {
        version = "3.4.7";
        src = fastmcpSrc;
        doCheck = false;
        nativeCheckInputs = [ ];
      });
      fastmcp-slim = pyPrev.fastmcp-slim.overridePythonAttrs (old: {
        version = "3.4.7";
        src = fastmcpSrc;
        doCheck = false;
        nativeCheckInputs = [ ];
      });
      py-key-value-aio = pyPrev.py-key-value-aio.overridePythonAttrs (old: {
        version = "0.4.5";
        src = pyKvSrc;
      });
    };
  };
})
