# mcp-searxng self-built package (retired)

[中文](../../zh/deprecated/mcp-searxng.md) | English | [日本語](../../ja/deprecated/mcp-searxng.md)  | [偽中国語](../../pcn/deprecated/mcp-searxng.md)

[← Back to the retired-projects index](../../../DEPRECATED.md)

**Status**: retired (2026-10-20)
**Former location**: `packages/mcp-searxng.nix` + `.github/workflows/build-mcp-searxng-{x86_64,aarch64,riscv64}.yml`
**Current state**: the package definition and all three build workflows are deleted; the flake and devshell point at nixpkgs' attribute of the same name; the overlay line was removed outright (nixpkgs provides it, keeping it would self-reference).

## What it used to solve

NixKits packaged mcp-searxng (an MCP server for SearXNG) and built x86_64 / aarch64 /
riscv64 outputs with three workflows into the Cachix cache.

## Why it can be retired

Upstream nixpkgs added it on **2026-08-29** (`init at 2.1.0`) and bumped it to **2.6.0**
on 2026-10-13. Both versions and both hashes are now **identical**:

| Item | This repo (old) | nixpkgs |
|---|---|---|
| Version | 2.6.0 | 2.6.0 |
| src hash | `sha256-dbxJSS…` | same |
| npmDepsHash | `sha256-+df6o…` | same |
| `__structuredAttrs` / `strictDeps` | present | present |
| wrapper | manual `makeWrapper` | none (handled by `buildNpmPackage`) |

The nixpkgs definition is simpler, and `mcp-searxng --help` works when measured.

## How to configure it after retirement

```nix
environment.systemPackages = [ pkgs.mcp-searxng ];
```

Or through this repo's alias (equivalent): `inputs.nixkits.packages.${pkgs.system}.mcp-searxng`.

## One criterion

Before retiring I verified **that the command runs** (`mcp-searxng --help`), not that the
version numbers match — the nixpkgs definition has no manual wrapper, so the two
definitions are not equivalent, and "same version" does not imply "same behaviour".
