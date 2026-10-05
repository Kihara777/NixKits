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
#   包             nixpkgs   godot-ai 4.3.0
#   anyio          4.14.2    4.15.1
#   fastmcp        3.4.7     4.0.10   ← 见 overlays/fastmcp.nix
#   fastmcp-slim   3.4.7     4.0.10   ← 见 overlays/fastmcp.nix
#   httpx2         2.9.1     2.13.1
#   httpcore2      2.9.1     2.13.1
#   mcp            1.29.0    2.2.0
#   mcp-types      无        2.2.0    ← 本文件新增定义
#   pydantic       2.13.4    2.13.5   （连带 pydantic-core 2.46.4 → 2.46.5）
#   starlette      1.3.1     1.7.0
#   uvicorn        0.51.0    0.54.0
#   websockets     16.1      17.1
#
# 4.3.0 相对 4.2.3 **不增删条目**，只抬六项：fastmcp / fastmcp-slim 4.0.5 → 4.0.10、
# httpx2 / httpcore2 2.13.0 → 2.13.1、uvicorn 0.53.0 → 0.54.0、starlette 1.6.0 → 1.7.0。
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
    tag = "v2.13.1";
    hash = "sha256-XgjFiSwc4xCyPJcTB/Exh838fUOKsT0JRrha7s70C50=";
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
  # pydantic-core 住在 pydantic monorepo 里，但独立发版（`core-v<ver>`）。实测两个 tag
  # 指向**同一个提交**（`gh api repos/pydantic/pydantic/commits/<tag> --jq .sha` →
  # v2.13.5 与 core-v2.46.5 均为 001dea02），而 fetchFromGitHub 会剥掉顶层目录，
  # 故两份 src 的**哈希相同**——这不是笔误，是有意复用同一个值。
  pydanticCoreSrc = prev.fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic";
    tag = "core-v2.46.5";
    hash = "sha256-ZtXEQfN1QKDvvaBwIRnzs5NgRcsBikPvCdWHHeIiYDg=";
  };
  starletteSrc = prev.fetchFromGitHub {
    owner = "Kludex";
    repo = "starlette";
    tag = "1.7.0";
    hash = "sha256-5/gQtC0JbQM7eSQeu2aVJtD63v4LjnbSSC0jF96e958=";
  };
  uvicornSrc = prev.fetchFromGitHub {
    owner = "encode";
    repo = "uvicorn";
    tag = "0.54.0";
    hash = "sha256-tfRdlqiMQ/+LZBQyTIAY+g6szR+JWn0X7Fd1yP3dntM=";
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
        # ── Python 3.12.15 × anyio 4.15.1 的 TLS 用例不兼容（**环境漂移，与 godot-ai 升级无关**）──
        # 这里的 12 个用例用 `pytestFlags` 的 `--deselect`（**nodeid 前缀**匹配）摘除，
        # 而**不是** `disabledTests`：后者经 pytestCheckPhase 变成 `-k` 子串表达式，而
        # `test_receive_invalid_max_bytes` 这个名字在 anyio 测试集里被**五个模块**共用
        # （本文件 TestTLSStream、test_stapled.py、test_file.py、test_buffered.py，
        # 以及 tests/test_sockets.py 两处）。实测：用裸名字做 `-k` 时 passed 掉到 2760，
        # 即连四个**与 TLS 无关、本来全绿**的模块里的同名用例一并摘掉了（多摘 24 个）。
        # `--deselect` 的文件+类前缀只命中真正坏掉的那一个，其余判据全部保留。
        #
        # 失败形态：15 failed / 2781 passed，其中 12 个集中在 tests/streams/test_tls.py，
        # 且全部是同一条 ValueError：
        #   File "anyio/streams/tls.py", line 156, in wrap
        #     ssl_object = ssl_context.wrap_bio(...)
        #   File ".../python3.12/ssl.py", line 808, in _create
        #     raise ValueError("server_hostname can only be specified in client mode")
        # 根因：CPython 3.12.15 收紧了 stdlib —— `server_side=True` 时再传 `server_hostname`
        # 直接抛错，而 anyio 的 `TLSStream.wrap()` 在**服务端**分支也照样把它传下去
        # （tests/streams/test_tls.py 的 server fixture 走的正是这条路径）。
        # 归因判据（决定性，不是推测）：用 `git show HEAD:overlays/*.nix` 取**已提交**的
        # overlay 链出的 anyio drvPath，与本次失败的 drvPath **完全相同**：
        #   /nix/store/dsmsss7ddlzl04mkf2nmcrcpr934yrvc-python3.12-anyio-4.15.1.drv
        # 且 anyio 覆盖段与 HEAD 逐字相同（`diff` 实测）。derivation 路径对全部输入内容
        # 寻址 ⇒ 该失败与 4.3.0 升级的任何改动无关，是 nixpkgs 漂移的结果——仓库此前那句
        # 「实跑 2796 passed」记录的是**旧 nixpkgs rev**（旧 Python）下的结果，现已过期。
        # 环境：nixpkgs `a7868a727837f3c09cee2ce0ca671c76b1589fed`（2026-10-03）；
        # 本仓按约定不提交 flake.lock，故每次构建/CI 都会重新解析到这条线上。
        # 另有 3 个「multiple unraisable exception warnings」失败（test_gather_results_in_order
        # [asyncio]、TestTLSStream::test_extra_attributes[asyncio+eager]、
        # TestBlockingPortal::test_start_crash_before_started_call[asyncio+uvloop]）——
        # 它们**不在**下面的摘除表里：那是 `MemoryObjectSendStream.__del__` 的 GC 时机告警，
        # 属**负载诱发的偶发**（当时并行的 riscv64 构建把机器压满），复跑即过，故保留其判据。
        #
        # 期望判据：0 failed 且 passed == 2784（= 原 2781 + 上述 3 个偶发转为通过），
        # 即恰好摘掉 4 + 8 = 12 个。
        # ⚠️ **上游把 `anyio/streams/tls.py` 的 `wrap_bio` 调用改成「仅客户端传
        #    `server_hostname`」之后，请删掉这两条 `--deselect`**——否则它会变成没人敢动的化石。
        pytestFlags = (old.pytestFlags or [ ]) ++ [
          "--deselect" "tests/streams/test_tls.py::test_tls_connectable"
          "--deselect" "tests/streams/test_tls.py::TestTLSStream::test_receive_invalid_max_bytes"
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

      # httpcore2：依赖集（h11 + truststore）在 2.9.1 → 2.13.1 之间未变，只抬版本与源。
      # 2.13.0 → 2.13.1 更是一处纯 patch 抬版：两份 pyproject.toml **逐字节相同**
      # （`cmp` 实测），故下面那条放宽构建工具地板的 postPatch 依然命中同一处锚点。
      httpcore2 = pyPrev.httpcore2.overridePythonAttrs (old: {
        version = "2.13.1";
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
      # 2.13.0 → 2.13.1：`src/httpx2/pyproject.toml` 逐字节未变（`cmp` 实测），
      # 故上面的依赖表与下面的 postPatch 都原样适用于 2.13.1。
      #
      # postPatch 放宽的是**构建工具**的地板，不是运行期 pin：上游把
      # `[build-system].requires` 的 `uv-dynamic-versioning>=0.8.0` 抬到 `>=0.14.1`，
      # 而 nixpkgs 提供 0.13.0，于是 `python -m build --no-isolation` 直接报
      #   ERROR Unmet dependencies ...: uv-dynamic-versioning>=0.14.1
      #       wanted: >=0.14.1  found: 0.13.0
      # 判据（不是猜的）：对比 2.9.1 与 2.13.x 的 pyproject，`[tool.uv-dynamic-versioning]`
      # 配置面逐字未变（vcs / style / bump / fallback-version），而**版本号本身由
      # nixpkgs 的 setup hook 注入 `UV_DYNAMIC_VERSIONING_BYPASS=<version>`**——
      # 插件的版本推算逻辑根本不参与，产物版本仍等于本文件的 `version`。
      # 之所以不打补丁绕「运行期」校验：那是两条完全不同的东西（见本文件顶部）。
      httpx2 = pyPrev.httpx2.overridePythonAttrs (old: {
        version = "2.13.1";
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

      # starlette 1.6.0 → 1.7.0。
      #
      # ⚠️ 1.6.0 时代这里有一条 postPatch，为 `starlette/testclient.py` 在**模块顶层**
      # 引用 `anyio.abc.BlockingPortal` 加一条弃用警告豁免（anyio 4.15.1 已把该别名改成
      # 惰性导入并发 DeprecationWarning，而 starlette 自己的
      # `filterwarnings = ["error", …]` 把未过滤的警告升为异常，于是测试收集期就炸）。
      # **1.7.0 已在上游修掉这个引用**——同一文件的三处现在都写
      # `anyio.from_thread.BlockingPortal`（实测 `grep -n BlockingPortal` 对 1.7.0
      # 的命中全部是新名字），该豁免**已无对象**，故删除。
      #
      # 判据不是「补丁还能不能打上」：`--replace-fail '"error",'` 在 1.7.0 里仍能命中
      # （那行还在），留着它构建照样成功——只是注释会描述一个 1.7.0 里不存在的问题。
      # **过期的工作区补丁是负债，不是保险**（同 overlays/fastmcp.nix 顶部对
      # py-key-value-aio 覆盖的处理）。
      #
      # 但 1.7.0 的**测试集**新增了依赖——nixpkgs 的 starlette 派生是按 1.3.1 的测试集写的
      # `nativeCheckInputs`，1.7.0 的 tests/ 多出两个 import，缺任一个都**在收集期**
      # 就中断整个测试会话（不是「少跑几个用例」，是「一个都不跑」）：
      #   1. `tests/conftest.py` 顶端 `from blockbuster import BlockBuster, BlockBusterFunction`，
      #      并有一个 autouse fixture 用它在事件循环上拦截阻塞调用。实测报错：
      #        ModuleNotFoundError: No module named 'blockbuster'
      #   2. `tests/middleware/test_opentelemetry.py` 顶端 `from opentelemetry import
      #      metrics, trace` 与 `from opentelemetry.sdk.trace import ReadableSpan,
      #      TracerProvider`（1.7.0 把 opentelemetry-api 加进 `full` extra，并在 dev
      #      依赖里要求 opentelemetry-sdk>=1.44.0）。实测报错依次为：
      #        ImportError while importing test module '.../tests/middleware/test_opentelemetry.py'
      #        E   ModuleNotFoundError: No module named 'opentelemetry'
      #        !!!! Interrupted: 1 error during collection !!!!
      #      补上 api 后下一层是 `E   ModuleNotFoundError: No module named 'opentelemetry.sdk'`
      #      （api 与 sdk 是两个发行版，只补前者不够）。
      # 这些都是**测试期**依赖，与运行期 pin 表无关（表里没有它们），故补进 check inputs
      # 而不是关掉测试——关掉等于把这一层判据整个删掉。nixpkgs 提供 blockbuster 1.5.26
      # （上游要求 >=1.5.23）与 opentelemetry-api / opentelemetry-sdk，均可用。
      starlette = pyPrev.starlette.overridePythonAttrs (old: {
        version = "1.7.0";
        src = starletteSrc;
        nativeCheckInputs = (old.nativeCheckInputs or [ ]) ++ [
          pyFinal.blockbuster
          pyFinal.opentelemetry-api
          pyFinal.opentelemetry-sdk
        ];
      });

      uvicorn = pyPrev.uvicorn.overridePythonAttrs (old: {
        version = "0.54.0";
        src = uvicornSrc;
        # 0.53.0 → 0.54.0 的运行期依赖未变（仍是 click + h11）；pyproject 的差异只在
        # `[dependency-groups]`（test-only 的 zttp 地板）与 pytest 的
        # `faulthandler_timeout`，两者都不进本派生（nixpkgs 的 uvicorn `doCheck = false`，
        # 测试走 passthru.tests.pytest 的独立派生）。
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
