{
  lib,
  fetchFromGitHub,
  python312,
}:

python312.pkgs.buildPythonApplication rec {
  pname = "godot-ai";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "hi-godot";
    repo = "godot-ai";
    tag = "v${version}";
    hash = "sha256-ImKAsIEIynliM8Rc8pp+BvOkFOekuhEuRuWrsYM5wD0=";
  };

  pyproject = true;

  # godot-ai's pyproject.toml uses setuptools.build_meta (requires
  # setuptools>=75.0); buildPythonApplication must declare it via build-system
  # or the pypa build phase fails with "Backend 'setuptools.build_meta' is
  # not available".
  build-system = with python312.pkgs; [
    setuptools
  ];

  dependencies = with python312.pkgs; [
    fastmcp
    websockets
    pydantic
    httpx
    uvicorn
    starlette
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
