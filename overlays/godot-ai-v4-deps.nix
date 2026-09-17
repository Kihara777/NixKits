# Overlay: godot-ai v4 runtime dependency pins
#
# godot-ai 4.0.0+ ships a **fail-closed runtime contract**: at process start
# `godot_ai.runtime_dependencies.verify_runtime_dependencies()` compares the
# installed version of nine distributions against an exact pin table and
# raises `RuntimeError: unsupported godot-ai runtime dependency set` on any
# mismatch — it refuses to start, it does not warn.  The pins exist because
# v4's security limits (bounded connection/body/frame/session budgets) reach
# into narrow internals of FastMCP, Uvicorn, websockets and Starlette.
#
# nixpkgs resolves these independently and lags on five of them, on both
# nixos-unstable and master:
#
#   package     nixpkgs   godot-ai v4.1.0
#   mcp         1.29.0    1.29.1
#   pydantic    2.13.4    2.13.5   (needs pydantic-core 2.46.5 vs 2.46.4)
#   starlette   1.3.1     1.6.0
#   uvicorn     0.51.0    0.52.4
#   websockets  16.1      17.1
#
# Without this overlay `godot-ai --version` aborts on startup.  Bumping the
# pins here (rather than patching the check out) keeps upstream's contract
# intact — the alternative, relaxing `runtime_dependencies.py`, would silently
# defeat the security boundary that motivated v4 in the first place.
#
# `fastmcp` / `anyio` / `httpx` / `h11` already match; their pins come from
# overlays/fastmcp.nix or nixpkgs as-is.
(final: prev: let
  py = prev.python312;

  # Each entry: the version godot-ai expects plus the source coordinates.
  # `tagPattern` mirrors how nixpkgs builds that repo's tag (`v${version}`,
  # bare `${version}`, or the pydantic monorepo's `core-v${version}`).
  mcpSrc = prev.fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "python-sdk";
    tag = "v1.29.1";
    hash = "sha256-x5cm1QojKp7K1mKc9ejazzJzBhIkFBif6/A+hEryYKo=";
  };
  pydanticSrc = prev.fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic";
    tag = "v2.13.5";
    hash = "sha256-ZtXEQfN1QKDvvaBwIRnzs5NgRcsBikPvCdWHHeIiYDg=";
  };
  # pydantic-core lives inside the pydantic monorepo and is versioned
  # separately (`core-v<ver>`).  Same tarball as pydanticSrc only when the two
  # versions happen to be released together — here they differ, so fetch again.
  pydanticCoreSrc = prev.fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic";
    tag = "core-v2.46.5";
    hash = "sha256-ZtXEQfN1QKDvvaBwIRnzs5NgRcsBikPvCdWHHeIiYDg=";
  };
  starletteSrc = prev.fetchFromGitHub {
    owner = "Kludex";
    repo = "starlette";
    tag = "1.6.0";
    hash = "sha256-Cp6wkRxbDdC+Yf3z4TvRF5xrchJ+PAo36qHbBg+FcXw=";
  };
  uvicornSrc = prev.fetchFromGitHub {
    owner = "encode";
    repo = "uvicorn";
    tag = "0.52.4";
    hash = "sha256-XDhfyL2+L2Dfa01brCgqKibdtkGOI0Xv4Mx0foqHT3A=";
  };
  websocketsSrc = prev.fetchFromGitHub {
    owner = "aaugustin";
    repo = "websockets";
    tag = "17.1";
    hash = "sha256-fribsGeH4+AfePbGSkqjP8UPJIGjSeOnaCA1y+7POEc=";
  };
in {
  python312 = prev.python312.override {
    packageOverrides = pyFinal: pyPrev: let
      # Riding the bump of pydantic 2.13.4 → 2.13.5 re-resolves the test-only
      # chain, and `inline-snapshot`'s docs test (`tests/test_docs.py`) is
      # flaky against this nixpkgs: it asserts on its own rendered README and
      # fails (3 failed, 1402 passed).  overlays/fastmcp.nix already neutralises
      # this same package for the same reason; the two overlays are chained, but
      # the instance here is a *newly resolved* derivation, so the skip must be
      # restated.  These are build-time test suites, not runtime behaviour.
      noTests = old: {
        doCheck = false;
        nativeCheckInputs = [ ];
      };
    in {
      # pydantic-core must move first: pydantic's build runs
      # `check_pydantic_core_version()` against the installed core, so a new
      # pydantic over an old core fails the build rather than the runtime.
      pydantic-core = pyPrev.pydantic-core.overridePythonAttrs (old: {
        version = "2.46.5";
        src = pydanticCoreSrc;
        # fetchCargoVendor unpacks to `source/` (fetchFromGitHub's dir name),
        # not `<pname>-<version>/` — getting this wrong fails with
        # "chmod: cannot access '.../pydantic-core': No such file or directory".
        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          pname = "pydantic-core";
          version = "2.46.5";
          src = pydanticCoreSrc;
          sourceRoot = "source/pydantic-core";
          hash = "sha256-h955lauGYYxIN9hPQXGRESFa4sYvcyPsHxCTMCFSMXs=";
        };
      });

      pydantic = pyPrev.pydantic.overridePythonAttrs (old: {
        version = "2.13.5";
        src = pydanticSrc;
      });

      mcp = pyPrev.mcp.overridePythonAttrs (old: {
        version = "1.29.1";
        src = mcpSrc;
      });

      starlette = pyPrev.starlette.overridePythonAttrs (old: {
        version = "1.6.0";
        src = starletteSrc;
      });

      uvicorn = pyPrev.uvicorn.overridePythonAttrs (old: {
        version = "0.52.4";
        src = uvicornSrc;
      });

      websockets = pyPrev.websockets.overridePythonAttrs (old: {
        version = "17.1";
        src = websocketsSrc;
        # 17.1 added a `tests/trio/` suite and nixpkgs' check inputs do not
        # include trio, so the run fails with
        # "ModuleNotFoundError: No module named 'trio'" (6 errors, 2112 tests).
        # nixpkgs' own 16.1 derivation has no trio either — the dep is new.
        nativeCheckInputs = (old.nativeCheckInputs or [ ]) ++ [ pyFinal.trio ];
      });

      # Test-only chain reached through pydantic's check inputs; see noTests.
      inline-snapshot = pyPrev.inline-snapshot.overridePythonAttrs noTests;
    };
  };
})
