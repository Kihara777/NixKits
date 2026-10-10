{
  lib,
  python3Packages,
  fetchFromGitea,
  makeWrapper,
  nix-update-script,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "blender-mcp";
  version = "1.0.3";
  pyproject = true;

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitea {
    domain = "projects.blender.org";
    owner = "lab";
    repo = "blender_mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pYeByO4Oi5eyynsJhGVd1vBWXHvhGn+Y5LGit6Kazlw=";
  };

  # The Python distribution lives in the repository's mcp/ subdirectory; the
  # Blender add-on sits next to it in addon/ and is installed in postInstall.
  sourceRoot = "${finalAttrs.src.name}/mcp";

  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [ makeWrapper ];

  # Upstream declares mcp[cli]; python-dotenv and typer come from that extra.
  dependencies = with python3Packages; [
    docutils
    mcp
    pyyaml
    python-dotenv
    typer
  ];

  # The test helpers build a subprocess environment by assigning PYTHONPATH
  # rather than appending to it. Inside a virtualenv that is harmless, since
  # the dependencies are in the interpreter's own site-packages, but outside
  # one it discards every dependency and the server subprocess fails to start
  # with a wall of McpError('Connection closed') and
  # ModuleNotFoundError: No module named 'yaml'. Appending instead makes the
  # suite pass without changing what it exercises.
  #
  # --replace-fail is deliberate: if upstream rewrites these lines the build
  # fails loudly rather than silently running fewer tests.
  postPatch = ''
    substituteInPlace ../tests/test_mcp_server.py \
      --replace-fail \
      'env["PYTHONPATH"] = os.path.join(_REPO_DIR, "mcp")' \
      'env["PYTHONPATH"] = os.pathsep.join([_MCP_DIR, env.get("PYTHONPATH", "")])'
    substituteInPlace ../tests/test_tool_listing.py \
      --replace-fail \
      'env["PYTHONPATH"] = os.path.join(_REPO_DIR, "mcp")' \
      'env["PYTHONPATH"] = os.pathsep.join([os.path.join(_REPO_DIR, "mcp"), env.get("PYTHONPATH", "")])'
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-asyncio
  ];

  doCheck = true;

  # The tests read from the source tree's tests/, while sourceRoot points at mcp/.
  preCheck = ''
    cd ..
    export HOME="$TMPDIR"
  '';

  # This file drives a real Blender editor instance and cannot run in a build
  # sandbox. The remaining files do run: 102 passed, 9 skipped.
  disabledTestPaths = [ "tests/test_blender_mcp_with_blender.py" ];

  # The add-on is the other half of the TCP connection the server opens, so
  # ship it alongside the server.
  postInstall = ''
    addonDir="$out/share/blender/scripts/addons/blender_mcp_addon"
    mkdir -p "$(dirname "$addonDir")"
    cp -r ../addon/blender_mcp_addon "$addonDir"
  '';

  pythonImportsCheck = [ "blmcp" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCP server exposing Blender's Python API, manual and documentation to LLM clients";
    longDescription = ''
      A lightweight Model Context Protocol server for Blender, developed by
      Blender Lab. It runs as a separate process launched by the MCP client and
      talks to a Blender add-on over a local TCP socket, letting an LLM explore
      and drive a running Blender instance.
    '';
    homepage = "https://www.blender.org/lab/mcp-server/";
    changelog = "https://projects.blender.org/lab/blender_mcp/releases/tag/v${finalAttrs.version}";
    # The v1.0.3 tag carries no LICENSE file, but the licence is not ambiguous:
    # every source file has an "SPDX-License-Identifier: GPL-3.0-or-later"
    # header, and the add-on's blender_manifest.toml declares the same. Upstream
    # confirmed this in issue #59 and added a LICENSE file to main afterwards.
    license = lib.licenses.gpl3Plus;
    mainProgram = "blender-mcp";
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.grg41 ];
  };
})
