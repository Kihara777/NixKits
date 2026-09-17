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
  # godot-ai needs two things nixpkgs does not provide:
  #   1. fastmcp >= 3.4.0 (nixpkgs pins 3.3.1, which has a circular-import bug)
  #   2. the exact runtime package versions its v4 fail-closed contract verifies
  #      at startup (mcp / pydantic / starlette / uvicorn / websockets)
  # Chain both overlays so the package's dependencies resolve to what upstream
  # requires — without them `godot-ai --version` aborts immediately with
  # "unsupported godot-ai runtime dependency set".
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
