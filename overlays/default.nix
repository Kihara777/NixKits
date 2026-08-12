final: prev: {
  blender-mcp          = final.callPackage ../packages/blender-mcp.nix { };
  codewhale            = final.callPackage ../packages/codewhale.nix { };
  kitsfmt              = final.callPackage ../packages/kitsfmt.nix { };
  opencode-telegram    = final.callPackage ../packages/opencode-telegram.nix { };
  mcp-searxng          = final.callPackage ../packages/mcp-searxng.nix { };
  obs-bilibili-stream  = final.callPackage ../packages/obs-bilibili-stream.nix { };
  ruyi                 = final.callPackage ../packages/ruyi/ruyi.nix { };
  ruyi-beta            = final.callPackage ../packages/ruyi/ruyi-beta.nix { };
  ruyi-alpha           = final.callPackage ../packages/ruyi/ruyi-alpha.nix { };
  # godot-ai needs fastmcp >= 3.4.0 (nixpkgs pins 3.3.1, which has a
  # circular-import bug).  Build it with the fastmcp overlay applied so its
  # dependencies resolve to 3.4.7.
  godot-ai             = (prev.extend (import ./fastmcp.nix)).callPackage ../packages/godot-ai.nix { };
}
