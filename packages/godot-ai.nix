{
  lib,
  fetchFromGitHub,
  python312,
}:

python312.pkgs.buildPythonApplication rec {
  pname = "godot-ai";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "hi-godot";
    repo = "godot-ai";
    tag = "v${version}";
    hash = "sha256-9e88tOY2pOe/4iuy6W09PSgWmQpcbZ2Rc2/Z5AEUWKE=";
  };

  pyproject = true;

  # godot-ai's pyproject.toml uses setuptools.build_meta; buildPythonApplication
  # must declare build-system or the pypa build phase fails with
  # "Backend 'setuptools.build_meta' is not available".
  #
  # v4 pins `setuptools==84.0.0` in [build-system].requires while nixpkgs ships
  # 83.0.0, so the pypa build phase aborts with "Unmet dependencies
  # (checked against .../python3.12): setuptools==84.0.0 wanted: ==84.0.0
  # found: 83.0.0".  The pin is an upstream reproducibility guard, not a
  # feature requirement — relax it to the nixpkgs-provided version instead of
  # vendoring a second setuptools, so the build uses the toolchain the rest of
  # the closure is built with.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["setuptools==84.0.0"]' 'requires = ["setuptools"]'
  '';

  build-system = with python312.pkgs; [
    setuptools
  ];

  # v4.0.0+ exact-pins every runtime distribution (see the [project].dependencies
  # block) because its security limits touch narrow FastMCP/Uvicorn/websockets
  # internals.  `godot_ai.runtime_dependencies.verify_runtime_dependencies()`
  # re-checks all nine at process start and **raises** on any mismatch — it
  # refuses to start rather than warn.
  #
  # The five package versions below come from `overlays/godot-ai-v4-deps.nix`,
  # which moves nixpkgs' copies up to exactly what upstream expects (mcp,
  # pydantic + pydantic-core, starlette, uvicorn, websockets).  That overlay is
  # what makes this package runnable; nothing here relaxes upstream's contract.
  #
  # `fastmcp` comes from `overlays/fastmcp.nix` (nixpkgs pins 3.3.1, which has a
  # circular-import bug in fastmcp.server); `anyio`/`httpx`/`h11` already match
  # nixpkgs.  `dontCheckRuntimeDeps` silences `pythonRuntimeDepsCheckHook`
  # (nixpkgs >= 2026-08-05), which would otherwise reject the build for the
  # `setuptools` pin that `postPatch` relaxes above.
  dontCheckRuntimeDeps = true;

  dependencies = with python312.pkgs; [
    fastmcp
    mcp
    anyio
    websockets
    pydantic
    httpx
    uvicorn
    starlette
    h11
  ];

  # Tests split into unit/ and integration/; integration tests require a
  # live Godot editor instance, unavailable in the sandbox.
  doCheck = false;

  meta = {
    description = "Production-grade MCP server and AI tools for the Godot engine";
    homepage = "https://github.com/hi-godot/godot-ai";
    changelog = "https://github.com/hi-godot/godot-ai/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "godot-ai";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
