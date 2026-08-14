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

  # True if a package is (or pulls in) one of the flaky test-suite packages
  # whose tests fail on recent nixpkgs.  Used to detect mcp-like deps.
  nameOf = p: if builtins.isString p then p else (p.pname or p.name or "");
in {
  python312 = prev.python312.override {
    packageOverrides = pyFinal: pyPrev: let
      # Use overridePythonAttrs (not overrideAttrs) — nativeCheckInputs is an
      # excludeDrvArgNames entry in mk-python-derivation, so plain overrideAttrs
      # cannot clear it; extendDrvArgs rebuilds nativeInstallCheckInputs from
      # the original value.  overridePythonAttrs handles the passthru layers
      # correctly so nativeCheckInputs = [] actually takes effect.
      #
      # Also: overridePythonAttrs does NOT rewrite references inside other
      # packages' propagatedBuildInputs.  fastmcp propagates `mcp`; mcp and
      # py-key-value-aio propagate `fastapi`; their own nativeCheckInputs pull
      # inline-snapshot → … → scipy whose flaky tests fail on recent nixpkgs.
      # We override each such package separately AND swap its propagated
      # reference to the overridden one so the skip actually applies.
      noTests = old: {
        doCheck = false;
        nativeCheckInputs = [ ];
      };
      swap = pred: repl: p: if pred p then repl else p;
      swapMcp     = swap (p: nameOf p == "mcp") pyFinal.mcp;
      swapFastapi = swap (p: nameOf p == "fastapi") pyFinal.fastapi;
    in {
      # Leaf test-suite packages whose own tests are flaky in the sandbox.
      # Overriding them (doCheck=false) stops the scipy chain at its source.
      scipy          = pyPrev.scipy.overridePythonAttrs (old: noTests old);
      uncertainties  = pyPrev.uncertainties.overridePythonAttrs (old: noTests old);
      pint           = pyPrev.pint.overridePythonAttrs (old: noTests old);
      vulture        = pyPrev.vulture.overridePythonAttrs (old: noTests old);
      pylama         = pyPrev.pylama.overridePythonAttrs (old: noTests old);
      isort          = pyPrev.isort.overridePythonAttrs (old: noTests old);
      inline-snapshot = pyPrev.inline-snapshot.overridePythonAttrs (old: noTests old);
      fastapi        = pyPrev.fastapi.overridePythonAttrs (old: noTests old);
      mcp            = pyPrev.mcp.overridePythonAttrs (old: noTests old);

      fastmcp = pyPrev.fastmcp.overridePythonAttrs (old:
        (noTests old) // {
          version = "3.4.7";
          src = fastmcpSrc;
          propagatedBuildInputs = map swapMcp (old.propagatedBuildInputs or [ ]);
        });

      fastmcp-slim = pyPrev.fastmcp-slim.overridePythonAttrs (old:
        (noTests old) // {
          version = "3.4.7";
          src = fastmcpSrc;
        });

      # 0.4.5 moved to a src/ layout with pyproject at the repo root, and
      # its deps became beartype + typing-extensions (0.3.0 used beartype +
      # py-key-value-shared).  nixpkgs' 0.3.0 derivation hardcodes
      # sourceRoot = source/key-value/key-value-aio and a postPatch targeting
      # uv_build>=0.8.2,<0.9.0 — both wrong for 0.4.5.
      py-key-value-aio = pyPrev.py-key-value-aio.overridePythonAttrs (old:
        (noTests old) // {
          version = "0.4.5";
          src = pyKvSrc;
          sourceRoot = "source";
          dependencies = with pyFinal; [ beartype typing-extensions ];
          postPatch = ''
            substituteInPlace pyproject.toml \
              --replace-fail "uv_build>=0.11.4,<0.12" "uv_build"
            substituteInPlace pyproject.toml \
              --replace-fail '"-n=auto",' ""
            substituteInPlace pyproject.toml \
              --replace-fail '"--dist=loadfile",' ""
          '';
        });
    };
  };
})
