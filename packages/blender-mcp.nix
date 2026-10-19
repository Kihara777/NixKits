{
  lib,
  python3Packages,
  fetchFromGitea,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "blender-mcp";
  version = "1.0.3";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitea {
    domain = "projects.blender.org";
    owner = "lab";
    repo = "blender_mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pYeByO4Oi5eyynsJhGVd1vBWXHvhGn+Y5LGit6Kazlw=";
  };

  preConfigure = ''
    cd mcp
  '';

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  # ⚠️ 这里原本有一个 `blender ? null` 参数与配套的 postFixup，意图是
  # 「默认不拉 Blender 进闭包，想要的人自己 .override { blender = …; }」。
  #
  # **2026-10-12 实测推翻了那个意图。** 用 `callPackage { }`（**正如本仓 flake
  # 的调用方式**）时，`blender` 仍然被自动绑定——它存在于 nixpkgs，callPackage
  # 就填——于是 postFixup 真的执行、**整个 Blender 闭包进了每个消费者的路径**：
  #
  #   callPackage { }            → drv 里有 d0ba3a5g…-blender-5.2.1
  #   callPackage { blender=null } → drv 里一个 blender 都没有
  #
  # 也就是说 `? null` 那个默认**挡不住自动绑定**，它只掩盖了发生的事情。
  # 已整个删掉：上游本来是按 PATH 找 `blender` 的，不需要我们绑定；
  # 需要固定路径的人设环境变量 `BLENDER_PATH` 即可。
  #
  # 判据：drv 里不再出现 blender-*。

  dependencies = [
    python3Packages.mcp
    python3Packages.docutils
    python3Packages.pyyaml
  ];

  # The build cd's into mcp/ via preConfigure. The addon lives at ../addon/
  # alongside it. Ship it so users can install it from the package.
  postInstall = ''
    addon_out="$out/share/blender/scripts/addons/blender_mcp_addon"
    mkdir -p "$(dirname "$addon_out")"
    cp -r ../addon/blender_mcp_addon "$addon_out"
  '';

  # ⚠️ 本包此前**一个测试都不跑**（没有 nativeCheckInputs）。
  # 2026-10-12 从上游准备那版回填 —— 那里的判据是实测的：
  # 102 passed / 9 skipped，其中 9 个是 skip、不是失败。
  #
  # 上游测试自己的一个 bug：它构造子进程环境时**覆盖** PYTHONPATH 而不是追加。
  # 在 venv 里没关系（依赖在解释器自己的 site-packages 里），在没有 venv 的
  # 构建环境里等于把依赖整个丢掉 —— 子进程起不来，表现为一片 McpError
  # 与 `ModuleNotFoundError: No module named 'yaml'`。用 `--replace-fail`：
  # 上游若改了这两行，构建当场失败而不是静默少跑测试。
  #
  # 路径说明：patchPhase 时 cwd 是**源树根**（`cd mcp` 发生在 configurePhase），
  # 所以这里写 `tests/`；而 preCheck 时 cwd 已经在 `mcp/` 里，所以要 `cd ..`。
  postPatch = ''
    substituteInPlace tests/test_mcp_server.py \
      --replace-fail \
      'env["PYTHONPATH"] = os.path.join(_REPO_DIR, "mcp")' \
      'env["PYTHONPATH"] = os.pathsep.join([_MCP_DIR, env.get("PYTHONPATH", "")])'
    substituteInPlace tests/test_tool_listing.py \
      --replace-fail \
      'env["PYTHONPATH"] = os.path.join(_REPO_DIR, "mcp")' \
      'env["PYTHONPATH"] = os.pathsep.join([os.path.join(_REPO_DIR, "mcp"), env.get("PYTHONPATH", "")])'
  '';

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-asyncio
  ];

  doCheck = true;

  preCheck = ''
    cd ..
    export HOME="$TMPDIR"
  '';

  # 这一个文件要**真实运行的 Blender 编辑器实例**（`FileNotFoundError: 'blender'`），
  # 在构建沙箱里永远跑不了，不是修的问题。其余三个文件全跑。
  disabledTestPaths = [ "tests/test_blender_mcp_with_blender.py" ];

  pythonImportsCheck = [ "blmcp" ];

  meta = {
    description = "MCP server for Blender — lightweight Model Context Protocol server";
    longDescription = ''
      A lightweight MCP (Model Context Protocol) server for Blender.
      It offers a natural language interface with Blender's Python API,
      improving access to documentation, and allowing users to explore
      and understand complex setups.
    '';
    homepage = "https://www.blender.org/lab/mcp-server/";
    changelog = "https://projects.blender.org/lab/blender_mcp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "blender-mcp";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
