# mcp-searxng

[中文](../zh/mcp-searxng.md) | English | [日本語](../ja/mcp-searxng.md)  | [偽中国語](../pcn/mcp-searxng.md)

**Status**: retired (2026-10-20) — upstream nixpkgs ships this package, so NixKits no longer builds it.
See the [retirement note](deprecated/mcp-searxng.md).

## How to use it now

**Straight from nixpkgs**

```nix
environment.systemPackages = [ pkgs.mcp-searxng ];
```

The alias kept by this repo is equivalent (`inputs.nixkits.packages.${pkgs.system}.mcp-searxng` points at the same package).

## Info

| Item | Value |
|------|-------|
| Version | 2.6.0 (tracks nixpkgs) |
| Upstream | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |
| nixpkgs attribute | `mcp-searxng` |
| Added to nixpkgs | 2026-08-29 (init 2.1.0) |

> An MCP server for SearXNG, giving AI assistants web search. It needs the `SEARXNG_URL` environment variable at runtime.
