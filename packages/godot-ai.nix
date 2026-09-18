{
  lib,
  fetchFromGitHub,
  python312,
  makeWrapper,
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

  # `godot-ai` 默认走 attach 桥：主进程会**再 spawn 一个后端**，命令行是
  # `sys.executable -m godot_ai --transport streamable-http`（见
  # godot_ai/attach/ensure.py 的 spawn_backend）。在 Nix 包装下
  # `sys.executable` 是**裸 CPython** —— 依赖只由包装脚本在运行时经
  # `site.addsitedir()` 注入，**不会**被 spawn 出的子进程继承，于是后端以
  # `No module named godot_ai` 退出，前端报
  # `BACKEND_START_FAILED: Backend exited with code 1`。
  #
  # 上游用 `uvx`／真实 venv 安装，没有这个落差；这是 Nix 打包特有的问题。
  # 修法：把本环境全部 site-packages 前置到 PYTHONPATH，使子进程可直接导入。
  # 用 `--prefix`（而非 `--set`）以保留调用者自己的 PYTHONPATH。
  #
  # `${placeholder "out"}/${python312.sitePackages}` 必须是**绝对**路径：
  # `python312.sitePackages` 本身是相对值（`lib/python3.12/site-packages`），
  # 直接拼进 PYTHONPATH 相当于一个相对目录，子进程在任意 cwd 下都解析不到。
  #
  # 除直接 `dependencies` 外还要带上**完整传递闭包**——子进程是独立启动的，
  # 不经过 buildPythonApplication 生成的 site-packages 链接，故
  # `pydantic_core` / `platformdirs` 这类深层依赖同样必须在 PYTHONPATH 上。
  # 只展开一层是不够的（fastmcp → fastmcp-slim → platformdirs 有三层）。
  #
  # 注意不要用 `d.pythonPath`：那个属性来自 `python3.pkgs` 的**另一份**包
  # （如 nixpkgs 的 pydantic 2.13.4），会绕开本包经 overlay 抬上去的精确
  # 版本（2.13.5），导致 fail-closed 校验失败。故一律取 drv 自身的 outPath。
  #
  # 闭包用 fixpoint 展开 `propagatedBuildInputs`；以 outPath 去重、排序，
  # 保证求值可复现（Nix 对 list 顺序敏感）。
  nativeBuildInputs = [ makeWrapper ];

  postFixup = let
    outOf = d: d.outPath or (toString d);
    # 广度优先展开，用 outPath 去重防止环/重复。
    expand = seen: queue:
      if queue == [ ] then seen
      else let
        d = builtins.head queue;
        rest = builtins.tail queue;
        key = outOf d;
      in if builtins.elem key seen then expand seen rest
         else expand (seen ++ [ key ]) (rest ++ (d.propagatedBuildInputs or [ ]));
    closure = expand [ ] dependencies;
    depPath = lib.makeSearchPath "lib/python3.12/site-packages" closure;
  in ''
    wrapProgram "$out/bin/godot-ai" \
      --prefix PYTHONPATH : "${placeholder "out"}/${python312.sitePackages}:${depPath}"
  '';

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
