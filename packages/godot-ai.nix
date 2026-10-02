{
  lib,
  fetchFromGitHub,
  python312,
  makeWrapper,
}:

python312.pkgs.buildPythonApplication rec {
  pname = "godot-ai";
  version = "4.2.3";

  src = fetchFromGitHub {
    owner = "hi-godot";
    repo = "godot-ai";
    tag = "v${version}";
    # ⚠️ 改 version 必须连 hash 一起改，且**先把 hash 置成 lib.fakeHash 再构建**取真值：
    # 固定输出派生的输出路径由 hash 决定，留着旧 hash 改 version 会让 Nix 直接复用旧版本
    # 的源码树——构建在一份与 version 不符的代码上跑完，而且**不报任何错**。
    hash = "sha256-8OQsZycLSWR+jQ48S7V9Ckl4zBOPC0HM130BPVtjwQU=";
  };

  pyproject = true;

  # 上游 pyproject.toml 用 setuptools.build_meta；buildPythonApplication 必须显式声明
  # build-system，否则 pypa 构建阶段报
  # "Backend 'setuptools.build_meta' is not available"。
  #
  # v4 在 [build-system].requires 里写死 `setuptools==84.0.0`，而 nixpkgs 提供的是
  # 83.0.0，构建会中止于 "Unmet dependencies (checked against .../python3.12):
  # setuptools==84.0.0 wanted: ==84.0.0 found: 83.0.0"。该 pin 是可复现性守卫、
  # 不是功能需求——放宽到 nixpkgs 的版本，而不是再 vendor 一份 setuptools，
  # 这样整个闭包都用同一套工具链构建。4.2.3 仍保留这个 pin，故 postPatch 继续有效。
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["setuptools==84.0.0"]' 'requires = ["setuptools"]'
  '';

  build-system = with python312.pkgs; [
    setuptools
  ];

  # v4.0.0+ 精确锁定每一个运行时发行版（见 pyproject 的 [project].dependencies），
  # 因为它的安全上限触及 FastMCP / Uvicorn / websockets 的窄接口内部。
  # `godot_ai.runtime_dependencies.verify_runtime_dependencies()` 在进程启动时
  # **复查全部十四个**，任一不符即抛错——拒绝启动，而不是警告。
  #
  # 下面十四条与上游 pin 表**一一对应**。4.2.3 由 9 项增至 14 项：新增
  # fastmcp-slim / httpx2 / httpcore2 / mcp-types / sniffio，且 mcp 跨大版本
  # （1.29.1 → 2.2.0，上游把 wire types 拆成独立发行版）、fastmcp 3.4.7 → 4.0.5。
  #
  # 版本来源分三处，缺一不可：
  #   - overlays/fastmcp.nix        → fastmcp、fastmcp-slim
  #   - overlays/godot-ai-v4-deps.nix → anyio、httpx2、httpcore2、mcp、mcp-types、
  #                                     pydantic(+core)、starlette、uvicorn、websockets
  #   - nixpkgs 直接满足            → h11 0.16.0、httpx 0.28.1、sniffio 1.3.1
  #
  # 这里**不设** `dontCheckRuntimeDeps`：构建期的 `pythonRuntimeDepsCheckHook` 会拿
  # 本包的 wheel 元数据（即上面 14 个精确 pin）去比对 PYTHONPATH 上的实际版本，
  # 不符就让构建失败——那是比「构建成功、运行时才崩」更早的一道判据。
  # 它不能替代运行期校验（判据不同层），但让失败发生在更便宜的地方。
  dependencies = with python312.pkgs; [
    fastmcp
    fastmcp-slim
    anyio
    mcp
    mcp-types
    websockets
    pydantic
    httpx
    sniffio
    httpx2
    httpcore2
    uvicorn
    starlette
    h11
  ];

  # 测试分 unit/ 与 integration/；后者需要活的 Godot 编辑器实例，沙箱里没有。
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
  # ⚠️ 闭包必须覆盖 4.2.3 的**新**传递依赖（mcp-types、httpx2、httpcore2、
  # sniffio……）。历史事故：只展开一层导致子进程 `No module named godot_ai`
  # 或运行期 pin 校验读不到包——构建期一切正常，实跑才炸。
  #
  # 注意不要用 `d.pythonPath`：那个属性来自 `python3.pkgs` 的**另一份**包
  # （如 nixpkgs 的 pydantic 2.13.4），会绕开本包经 overlay 抬上去的精确版本
  # （2.13.5），导致 fail-closed 校验失败。故一律取 drv 自身的 outPath。
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
