final: prev: {
  codewhale            = final.callPackage ../packages/codewhale.nix { };
  kitsfmt              = final.callPackage ../packages/kitsfmt.nix { };
  opencode-telegram    = final.callPackage ../packages/opencode-telegram.nix { };
  mcp-searxng          = final.callPackage ../packages/mcp-searxng.nix { };
  obs-bilibili-stream  = final.callPackage ../packages/obs-bilibili-stream.nix { };
}
