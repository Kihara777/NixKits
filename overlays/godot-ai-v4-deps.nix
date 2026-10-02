# Overlay：godot-ai v4 运行时依赖的精确对齐
#
# godot-ai 4.x 是 **fail-closed** 的：进程启动时
# `godot_ai.runtime_dependencies.verify_runtime_dependencies()` 逐项比对运行时发行版
# 的**精确版本**，任一不符即 `RuntimeError: unsupported godot-ai runtime dependency
# set` —— 它拒绝启动，而不是警告。上游锁死到精确版本是有理由的：v4 的安全边界
# （连接 / 请求体 / 帧 / 会话预算）深入到 FastMCP、Uvicorn、websockets、Starlette
# 的窄接口内部，依赖一旦浮动，边界就不再是它评审过的那条。
#
# nixpkgs 独立解析这些版本，本仓 flake input（nixos-unstable）落在后面的有：
#
#   包             nixpkgs   godot-ai 4.2.3
#   anyio          4.14.2    4.15.1
#   fastmcp        3.4.7     4.0.5    ← 见 overlays/fastmcp.nix
#   fastmcp-slim   3.4.7     4.0.5    ← 见 overlays/fastmcp.nix
#   httpx2         2.9.1     2.13.0
#   httpcore2      2.9.1     2.13.0
#   mcp            1.29.0    2.2.0
#   mcp-types      无        2.2.0    ← 本文件新增定义
#   pydantic       2.13.4    2.13.5   （连带 pydantic-core 2.46.4 → 2.46.5）
#   starlette      1.3.1     1.6.0
#   uvicorn        0.51.0    0.53.0
#   websockets     16.1      17.1
#
# h11 0.16.0 / httpx 0.28.1 / sniffio 1.3.1 三项 nixpkgs 已经吻合，不在此重复声明。
#
# 没有这个 overlay，`godot-ai --version` 会直接崩在启动校验上。**抬版本**而不是放宽
# `runtime_dependencies.py`：后者会静默拆掉 v4 存在的理由——用「改校验迁就 nixpkgs」
# 换来的绿灯，比构建失败危险得多。
#
# ⚠️ 落点有两处：本文件与 overlays/fastmcp.nix 必须被 flake.nix 的 `godotPkgs` 与
# overlays/default.nix **同时**链上。历史事故：只链一处时构建产物仍用旧依赖，
# `--version` 直接 RuntimeError——构建成功，运行即死。两文件都经
# `pythonPackagesExtensions` 挂载，故彼此叠加且与先后顺序无关。
(final: prev: let
  py = prev.python312;

  # 取源坐标。tagPattern 与各上游仓库的发版习惯一致：python-sdk / httpx2 / fastmcp
  # 用 `v${version}`，anyio / starlette / uvicorn / websockets 用裸 `${version}`，
  # pydantic-core 用 pydantic monorepo 的 `core-v${version}`。
  #
  # ⚠️ 改版本号必须连 hash 一起改，且**先把 hash 置成 lib.fakeHash 再构建**取真值。
  # 固定输出派生的输出路径由 hash 决定：留着旧 hash 改 version，Nix 会直接复用旧版本
  # 的源码树——构建在一份与 version 不符的代码上跑完，而且**不报任何错**。
  mcpSrc = prev.fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "python-sdk";
    tag = "v2.2.0";
    hash = "sha256-nnpNXnQiFSGx5KQBDXHCOH0wE3cznlmI6s7vtchcj3A=";
  };
  # 2.x 起上游把仓库改成 uv workspace，wire types 拆成独立发行版 `mcp-types`，
  # 源码在同一 tag 的 `src/mcp-types/` 子目录下——**同一份 tarball**，
  # 只是构建时 sourceRoot 不同，故复用上面的取源结果。
  mcpTypesSrc = mcpSrc;
  # httpx2 与 httpcore2 同属 pydantic/httpx2 monorepo 的 `src/` 两个子项目，
  # 同样共用一份源码包。
  httpx2Src = prev.fetchFromGitHub {
    owner = "pydantic";
    repo = "httpx2";
    tag = "v2.13.0";
    hash = "sha256-HpI0+z8vJfOFl/AMBLoVYX0g8V7DlwDJsEe9IkPBRdQ=";
  };
  anyioSrc = prev.fetchFromGitHub {
    owner = "agronholm";
    repo = "anyio";
    tag = "4.15.1";
    hash = "sha256-cuTOVLyqLfp4LMuBd1BnFgey2gu3wehDk7VAb7yoqng=";
  };
  pydanticSrc = prev.fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic";
    tag = "v2.13.5";
    hash = "sha256-ZtXEQfN1QKDvvaBwIRnzs5NgRcsBikPvCdWHHeIiYDg=";
  };
  # pydantic-core 住在 pydantic monorepo 里，但独立发版（`core-v<ver>`）。两个版本
  # 恰好同批发布时才是同一份 tarball——此处并不相同，故再取一次。
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
    tag = "0.53.0";
    hash = "sha256-MXJoHl4vfZy3CfPqdDFuxrcmIiEyy3QjoR0AtZ3au48=";
  };
  websocketsSrc = prev.fetchFromGitHub {
    owner = "aaugustin";
    repo = "websockets";
    tag = "17.1";
    hash = "sha256-fribsGeH4+AfePbGSkqjP8UPJIGjSeOnaCA1y+7POEc=";
  };
in {
  # 与 overlays/fastmcp.nix 一样，走 `pythonPackagesExtensions`（可叠加）而不是
  # `python312.override { packageOverrides = ...; }`（替换语义）。用后者时本文件会
  # **静默丢弃** fastmcp overlay 的全部 Python 覆盖——两者链起来的结果就是
  # 「fastmcp 仍是 nixpkgs 的旧版」，而构建不会报任何错。详见 fastmcp.nix 顶部说明。
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyFinal: pyPrev: let
      # 只关测试套件，不动运行期行为。inline-snapshot 的文档测试断言自己渲染出来的
      # README，对本仓的 nixpkgs 是 flaky 的（见 overlays/fastmcp.nix 同名函数的
      # 说明）；pydantic 2.13.4 → 2.13.5 会**重新解析**这条 test-only 依赖链，
      # 新派生不在二进制缓存里，于是那个 flaky 用例每次都会真的跑一遍并失败。
      noTests = old: {
        doCheck = false;
        nativeCheckInputs = [ ];
      };
    in {
      # pydantic-core 必须先动：pydantic 构建时会跑
      # `check_pydantic_core_version()` 比对已安装的 core 版本，新的 pydantic 配旧的
      # core 会**在构建期**失败，而不是运行期。
      pydantic-core = pyPrev.pydantic-core.overridePythonAttrs (old: {
        version = "2.46.5";
        src = pydanticCoreSrc;
        # fetchCargoVendor 解包到的是 `source/`（fetchFromGitHub 的目录名），
        # 而不是 `<pname>-<version>/`；写错会报
        # "chmod: cannot access '.../pydantic-core': No such file or directory"。
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

      # anyio：上游把 typing_extensions 的地板提到 >=4.16.0（nixpkgs 恰为 4.16.0），
      # 其余（idna>=2.8）已满足。测试**照常跑**（实跑 2796 passed）——只精确禁用
      # 下面那一条沙箱内不可行的用例，不整体关掉。
      anyio = pyPrev.anyio.overridePythonAttrs (old: {
        version = "4.15.1";
        src = anyioSrc;
        disabledTests = (old.disabledTests or [ ]) ++ [
          # 4.15.1 新增 tests/test_lazyimport.py::test_sourceless_install：它建一个 venv
          # 再在子进程里 `python -m pip install <项目根>`（构建隔离还要联网下载
          # setuptools-scm）。沙箱里既无 pip 也无网络，必然失败——nixpkgs 的 4.14.2
          # 派生里没有这一条，因为该用例是新增的。实测报错原文：
          #   subprocess.CalledProcessError: Command '[PosixPath('.../bin/python'),
          #   '-m', 'pip', 'install', PosixPath('/build/source')]' returned non-zero exit
          #   status 1  →  1 failed, 2796 passed, 122 skipped
          # 与 anyio 的行为无关，故只禁这一条，不整体关掉测试。
          "test_sourceless_install"
        ];
      });

      # mcp 2.x 是**破坏性重构**，只改 version + src 会留下三处致命偏差：
      #   1. wire types 拆成独立发行版 mcp-types（缺它 = 运行期 ModuleNotFoundError）；
      #   2. HTTP 客户端由 httpx 换成 httpx2（httpx 仍在，但 mcp 用不到它）；
      #   3. httpx-sse / pydantic-settings 不再是依赖。
      # 故 dependencies 整份重写。不重写的直接后果是 pythonRuntimeDepsCheckHook
      # 按 1.x 的 requires_dist 报 unmet，而运行期则会真的缺包。
      # 测试保持关闭：overlays/fastmcp.nix 原本就为它关了测试，而 nixpkgs 里的
      # nativeCheckInputs / disabledTests 是**按 1.x 的测试集**写的，照搬到 2.x 只会
      # 得到一堆与代码无关的失败。要恢复得先按 2.x 的 tests/ 重写这份测试配置。
      mcp = pyPrev.mcp.overridePythonAttrs (old:
        (noTests old) // {
          version = "2.2.0";
          src = mcpSrc;
          dependencies = with pyFinal; [
            anyio
            httpx2
            jsonschema
            mcp-types
            opentelemetry-api
            pydantic
            pyjwt
            python-multipart
            sse-starlette
            starlette
            typing-extensions
            typing-inspection
            uvicorn
          ];
          # 1.29 时代为绕开 nixpkgs 的 pydantic-settings 约束而放宽；2.x 已不依赖它，
          # 留着只会掩盖将来真的缺依赖的情形。
          pythonRelaxDeps = [ ];
        });

      # mcp-types 在 nixpkgs 里**不存在**（godot-ai 4.2.3 起才成为独立发行版），
      # 故从上游源自行定义。它的 pyproject 位于仓库的 `src/mcp-types/` 子目录，
      # wheel 目标 packages = ["mcp_types"]，构建系统为 hatchling + uv-dynamic-versioning
      # （后者由 setup hook 注入 UV_DYNAMIC_VERSIONING_BYPASS=<version>，
      # 保证 dist-info 的版本号等于本文件的 `version`——运行期校验读的就是它）。
      mcp-types = pyFinal.buildPythonPackage (finalAttrs: {
        pname = "mcp-types";
        version = "2.2.0";
        pyproject = true;
        src = mcpTypesSrc;
        sourceRoot = "${finalAttrs.src.name}/src/mcp-types";
        build-system = with pyFinal; [
          hatchling
          uv-dynamic-versioning
        ];
        dependencies = with pyFinal; [
          pydantic
          typing-extensions
        ];
        pythonImportsCheck = [ "mcp_types" ];
        # 上游测试在仓库根的 tests/ 下，子项目内没有可跑的用例。
        doCheck = false;
        meta = {
          description = "Model Context Protocol wire types";
          homepage = "https://modelcontextprotocol.io";
          license = prev.lib.licenses.mit;
          maintainers = [ ];
        };
      });

      # httpcore2：依赖集（h11 + truststore）在 2.9.1 → 2.13.0 之间未变，只抬版本与源。
      httpcore2 = pyPrev.httpcore2.overridePythonAttrs (old: {
        version = "2.13.0";
        src = httpx2Src;
        # nixpkgs 的派生在此已 `pushd src/httpcore2`，故 pyproject.toml 就是子项目那本。
        postPatch = (old.postPatch or "") + ''
          substituteInPlace pyproject.toml \
            --replace-fail "uv-dynamic-versioning>=0.14.1" "uv-dynamic-versioning"
        '';
      });

      # httpx2：2.13.0 的 requires_dist 比 nixpkgs 的 2.9.1 多出 truststore 与
      # typing-extensions（py<3.13），少掉的 certifi 仍保留——多一个闭包成员不会
      # 破坏校验，少一个真的会被 import 的包才会。
      #
      # postPatch 放宽的是**构建工具**的地板，不是运行期 pin：上游把
      # `[build-system].requires` 的 `uv-dynamic-versioning>=0.8.0` 抬到 `>=0.14.1`，
      # 而 nixpkgs 提供 0.13.0，于是 `python -m build --no-isolation` 直接报
      #   ERROR Unmet dependencies ...: uv-dynamic-versioning>=0.14.1
      #       wanted: >=0.14.1  found: 0.13.0
      # 判据（不是猜的）：对比 2.9.1 与 2.13.0 的 pyproject，`[tool.uv-dynamic-versioning]`
      # 配置面逐字未变（vcs / style / bump / fallback-version），而**版本号本身由
      # nixpkgs 的 setup hook 注入 `UV_DYNAMIC_VERSIONING_BYPASS=<version>`**——
      # 插件的版本推算逻辑根本不参与，产物版本仍等于本文件的 `version`。
      # 之所以不打补丁绕「运行期」校验：那是两条完全不同的东西（见本文件顶部）。
      httpx2 = pyPrev.httpx2.overridePythonAttrs (old: {
        version = "2.13.0";
        src = httpx2Src;
        postPatch = (old.postPatch or "") + ''
          substituteInPlace pyproject.toml \
            --replace-fail "uv-dynamic-versioning>=0.14.1" "uv-dynamic-versioning"
        '';
        dependencies = with pyFinal; [
          anyio
          certifi
          httpcore2
          idna
          truststore
          typing-extensions
        ];
      });

      starlette = pyPrev.starlette.overridePythonAttrs (old: {
        version = "1.6.0";
        src = starletteSrc;
        # starlette 1.6.0 的 `starlette/testclient.py` 在**模块顶层**引用
        # `anyio.abc.BlockingPortal`，而 anyio 4.15.1 把这个别名改成了惰性导入并发
        # DeprecationWarning（指向 `anyio.from_thread.BlockingPortal`）。starlette 自己的
        # `[tool.pytest.ini_options] filterwarnings = ["error", …]` 把未过滤的警告升为
        # 异常，于是**测试收集期**就炸：
        #   ImportError while loading conftest '/build/source/tests/conftest.py'
        #   E DeprecationWarning: The anyio.abc.BlockingPortal alias is deprecated,
        #     use anyio.from_thread.BlockingPortal instead.
        # 这只在测试里成立：godot-ai 运行期不 import testclient，别名本身也照常可用
        # （上游正是把这两个版本配在一起发布的）。
        # 处置：**只**为这一条弃用警告加豁免，`"error"` 仍在——其余任何警告照样让测试失败。
        postPatch = (old.postPatch or "") + ''
          substituteInPlace pyproject.toml \
            --replace-fail '"error",' '"error", "ignore: The anyio.abc.BlockingPortal alias is deprecated, use anyio.from_thread.BlockingPortal instead.:DeprecationWarning",'
        '';
      });

      uvicorn = pyPrev.uvicorn.overridePythonAttrs (old: {
        version = "0.53.0";
        src = uvicornSrc;
      });

      websockets = pyPrev.websockets.overridePythonAttrs (old: {
        version = "17.1";
        src = websocketsSrc;
        # 17.1 多出 `tests/trio/` 测试集，而 nixpkgs 的 check inputs 里没有 trio，
        # 于是测试直接报 "ModuleNotFoundError: No module named 'trio'"
        # （6 errors / 2112 tests）。nixpkgs 自己的 16.1 派生也没有 trio——这是新增依赖。
        nativeCheckInputs = (old.nativeCheckInputs or [ ]) ++ [ pyFinal.trio ];
      });

      # test-only 依赖链：经 pydantic 的 check inputs 抵达，见 noTests 的说明。
      inline-snapshot = pyPrev.inline-snapshot.overridePythonAttrs noTests;
    })
  ];
})
