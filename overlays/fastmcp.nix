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

  # nixpkgs' buildPythonPackage merges nativeCheckInputs into nativeBuildInputs
  # even when doCheck=false, so the test-only tools (and their dependency
  # chains) are still built.  inline-snapshot drags in
  # isort→pylama→vulture→pint→uncertainties→scipy, whose flaky float tests
  # fail on recent nixpkgs.  Strip every test-only tool from nativeBuildInputs.
  #
  # NOTE: old.nativeBuildInputs items are raw store-path STRINGS (already
  # merged), not packages — so p.pname would throw on a string.  Match on
  # baseNameOf(path) instead.
  stripTestTools = inputs:
    prev.lib.filter
      (p: let
        n = if builtins.isString p
            then builtins.baseNameOf (prev.lib.removeSuffix "-dist" p)
            else (p.pname or p.name or "");
      in
        !(prev.lib.hasInfix "pytest" n
          || prev.lib.hasInfix "inline-snapshot" n
          || prev.lib.hasInfix "dirty-equals" n
          || prev.lib.hasInfix "fastapi" n
          || prev.lib.hasInfix "opentelemetry-sdk" n
          || prev.lib.hasInfix "psutil" n
          || prev.lib.hasInfix "writable-tmpdir" n))
      inputs;
in {
  python312 = prev.python312.override {
    packageOverrides = pyFinal: pyPrev: {
      fastmcp = pyPrev.fastmcp.overrideAttrs (old: {
        version = "3.4.7";
        src = fastmcpSrc;
        doCheck = false;
        nativeCheckInputs = [ ];
        nativeBuildInputs = stripTestTools (old.nativeBuildInputs or [ ]);
      });
      fastmcp-slim = pyPrev.fastmcp-slim.overrideAttrs (old: {
        version = "3.4.7";
        src = fastmcpSrc;
        doCheck = false;
        nativeCheckInputs = [ ];
        nativeBuildInputs = stripTestTools (old.nativeBuildInputs or [ ]);
      });
      py-key-value-aio = pyPrev.py-key-value-aio.overrideAttrs (old: {
        version = "0.4.5";
        src = pyKvSrc;
      });
    };
  };
})
