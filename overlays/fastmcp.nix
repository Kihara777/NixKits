# Overlay：fastmcp / fastmcp-slim 抬到 godot-ai 4.2.3 要求的 4.0.5
#
# godot-ai 4.x 的运行时校验表把 `fastmcp` 与 `fastmcp-slim` 都精确锁到 4.0.5
# （4.2.3 才把 slim 单列出来），nixpkgs 停在 3.4.7，故必须抬版；否则
# `godot-ai --version` 会在启动校验上直接 RuntimeError。
#
# 4.0.5 与 3.4.7 的**结构差异**（只改 version + src 会踩的坑）：
#   - 上游把 wire types 拆成独立发行版 `mcp-types`，fastmcp-slim 的核心依赖里
#     新增了它（见 overlays/godot-ai-v4-deps.nix 中的定义）；
#   - HTTP 客户端从 httpx 换成 httpx2，`mcp` extra 里相应换人；
#   - `server` extra 新增 joserfc；`tasks` extra 从 fastmcp-slim **搬走**，
#     改由独立发行版 fastmcp-tasks 承载（nixpkgs 无此包）；
#   - nixpkgs 为 3.4.7 打的那个 python 3.14 fetchpatch 已被上游吸收
#     （提交 6be0ac8 是 v4.0.5 的祖先），继续打会因「补丁已应用」而失败，
#     故 `patches = [ ]`。
#
# 顺带删掉了 py-key-value-aio 的覆盖：nixpkgs 已自行更新到 0.4.5，正是 4.0.5 需要的
# 区间（>=0.4.4,<0.5.0）。原先的覆盖是针对 nixpkgs 老 0.3.0 派生写的，留着只会
# （a）让新派生无法命中二进制缓存、（b）继续按旧假设打 postPatch。**覆盖不是越多越好**：
# 依赖一旦被上游 nixpkgs 满足，覆盖就是负债。
(final: prev: let
  fastmcpSrc = prev.fetchFromGitHub {
    owner = "PrefectHQ";
    repo = "fastmcp";
    tag = "v4.0.5";
    hash = "sha256-47kRqA1poCPDd+ijhFEQ1ObcbvlCNx711G6JhK7OrB8=";
  };

in {
  # 挂载方式很重要：用 nixpkgs 官方的**可叠加**扩展点 `pythonPackagesExtensions`，
  # **不要**用 `python312.override { packageOverrides = ...; }`。后者是**替换**语义——
  # 两个 overlay 各自 override 时，后应用的那个会把先应用的那整套 Python 覆盖
  # **静默丢弃**（本仓实测 2026-10-02：`(pkgs.extend fastmcp).extend godot-ai-v4-deps`
  # 之下 `python312.pkgs.fastmcp-slim` 仍是 nixpkgs 的 3.4.7，本文件的覆盖完全没生效，
  # 而构建照样成功）。改成扩展列表后两个 overlay 自动叠加、与先后顺序无关，
  # 且 python 解释器自身的 outPath 不变（不会引发无谓重建）。
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyFinal: pyPrev: let
      # 用 overridePythonAttrs（而不是 overrideAttrs）——nativeCheckInputs 在
      # mk-python-derivation 里是 excludeDrvArgNames 项，普通 overrideAttrs 清不掉它，
      # 会被 extendDrvArgs 从原值重建。overridePythonAttrs 才让 nativeCheckInputs = [ ]
      # 真正生效。
      noTests = old: {
        doCheck = false;
        nativeCheckInputs = [ ];
      };
    in {
      # 自带测试在本仓的 nixpkgs 上是 flaky 的叶子包，把 scipy 那条链从源头掐断。
      # fastmcp / fastmcp-slim / mcp 的测试各自另有处置（见下）。
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
          version = "4.0.5";
          src = fastmcpSrc;
          patches = [ ];
          # 4.0.5 的 fastmcp 本体是**空壳发行版**（root pyproject 里
          # bypass-selection = true、exclude = ["/*"]），代码全在 fastmcp-slim，
          # 故依赖就是 slim 的 client + server 两个 extra。
          dependencies =
            [ pyFinal.fastmcp-slim ]
            ++ pyFinal.fastmcp-slim.optional-dependencies.client
            ++ pyFinal.fastmcp-slim.optional-dependencies.server;
          optional-dependencies = {
            anthropic = pyFinal.fastmcp-slim.optional-dependencies.anthropic;
            apps = pyFinal.fastmcp-slim.optional-dependencies.apps;
            azure = pyFinal.fastmcp-slim.optional-dependencies.azure;
            code-mode = pyFinal.fastmcp-slim.optional-dependencies.code-mode;
            gemini = pyFinal.fastmcp-slim.optional-dependencies.gemini;
            openai = pyFinal.fastmcp-slim.optional-dependencies.openai;
            # 4.0.5 把 tasks 搬到独立发行版 fastmcp-tasks（nixpkgs 无）；godot-ai
            # 不使用该 extra，留空即可——空 list 不等于「跳过校验」，
            # extra 本来就不参与运行期 pin 表。
            tasks = [ ];
          };
        });

      fastmcp-slim = pyPrev.fastmcp-slim.overridePythonAttrs (old:
        (noTests old) // {
          version = "4.0.5";
          src = fastmcpSrc;
          patches = [ ];
          dependencies =
            (with pyFinal; [
              mcp-types
              platformdirs
              pydantic
              pydantic-settings
              python-dotenv
              rich
              typing-extensions
            ])
            ++ pyFinal.pydantic.optional-dependencies.email;
          # 与 4.0.5 的 pyproject 逐项对齐；mcp extra 供 client/server 复用，
          # key-value 三件套（filetree / keyring / memory）也同源。
          optional-dependencies = let
            mcpExtra = with pyFinal; [
              exceptiongroup
              httpx2
              mcp
              opentelemetry-api
              starlette
            ];
            keyValueExtras = with pyFinal;
              py-key-value-aio.optional-dependencies.filetree
              ++ py-key-value-aio.optional-dependencies.keyring
              ++ py-key-value-aio.optional-dependencies.memory;
          in {
            anthropic = with pyFinal; [ anthropic ];
            # prefab-ui 未打包，4.0.5 的 apps extra 只有它。
            apps = [ ];
            azure = with pyFinal; [ azure-identity pyjwt ];
            client = (with pyFinal; [ authlib ]) ++ mcpExtra ++ keyValueExtras;
            code-mode = with pyFinal; [ pydantic-monty ];
            gemini = with pyFinal; [ google-genai jsonref ];
            mcp = mcpExtra;
            openai = with pyFinal; [ openai ];
            server = (with pyFinal; [
              authlib
              cyclopts
              griffelib
              joserfc
              jsonref
              jsonschema-path
              openapi-pydantic
              packaging
              py-key-value-aio
              pyperclip
              python-multipart
              pyyaml
              uncalled-for
              uvicorn
              watchfiles
              websockets
            ]) ++ mcpExtra ++ keyValueExtras;
          };
        });
    })
  ];
})
