final: prev: {
  blender-mcp          = final.callPackage ../packages/blender-mcp.nix { };
  codewhale            = if final.stdenv.hostPlatform.isRiscV
    then final.callPackage ../packages/codewhale-src.nix { }
    else final.callPackage ../packages/codewhale.nix { };
  kitsfmt              = final.callPackage ../packages/kitsfmt.nix { };
  opencode-telegram    = final.callPackage ../packages/opencode-telegram.nix { };
  mcp-searxng          = final.callPackage ../packages/mcp-searxng.nix { };
  obs-bilibili-stream  = final.callPackage ../packages/obs-bilibili-stream.nix { };
  ruyi                 = final.callPackage ../packages/ruyi/ruyi.nix { };
  ruyi-beta            = final.callPackage ../packages/ruyi/ruyi-beta.nix { };
  ruyi-alpha           = final.callPackage ../packages/ruyi/ruyi-alpha.nix { };
  # godot-ai 有两件事 nixpkgs 不提供：
  #   1. fastmcp / fastmcp-slim 4.0.5（nixpkgs 停在 3.4.7）
  #   2. v4 fail-closed 校验表要求的精确运行时版本（anyio / httpx2 / httpcore2 /
  #      mcp / mcp-types / pydantic / starlette / uvicorn / websockets）
  # 两个 overlay 必须**链起来**（顺序无关：两者都经 nixpkgs 的
  # `pythonPackagesExtensions` 挂载，彼此叠加），否则 `godot-ai --version` 立刻以
  # "unsupported godot-ai runtime dependency set" 中止。
  # ⚠️ 这里与 flake.nix 的 `godotPkgs` 是**两个落点**，必须同步：只改一处会让
  # `nix build .#godot-ai` 与经 overlay 消费的结果不一致（历史事故：flake.nix 只链了
  # fastmcp，构建产物仍用旧依赖，构建成功而 `--version` 直接 RuntimeError）。
  godot-ai             = ((prev.extend (import ./fastmcp.nix)).extend (import ./godot-ai-v4-deps.nix))
                           .callPackage ../packages/godot-ai.nix { };
  dsh                  = final.callPackage ../packages/dsh.nix { };
  dsh-alpha            = final.callPackage ../packages/dsh-alpha.nix { };
  # NixOS-aware shell tool plugin for dsh (fixes "spawn bash ENOENT").
  dsh-nixos-shell      = final.callPackage ../packages/dsh-nixos-shell.nix { };
  # API 用量余额插件: webui 用量显示旁添加「用量 / 开销」标签切换。
  dsh-api-balance      = final.callPackage ../packages/dsh-api-balance.nix { };
  # 独立分发的 Agent 预设包（新闻三要素模式）。
  dsh-preset-news-three-elements = final.callPackage ../packages/dsh-preset-news-three-elements.nix { };
  # NixKits skills as native dsh skill plugins (one plugin entry per skill).
}
