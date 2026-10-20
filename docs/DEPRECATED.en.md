# Retired Projects

[中文](../DEPRECATED.md) | English | [日本語](DEPRECATED.ja.md)  | [偽中国語](DEPRECATED.pcn.md)

This file is the **index** of projects in NixKits that were once maintained and are now
retired. The details of each project — what it used to solve, why it can be retired, and
how to configure things after retirement — live in its own document.

Retired does not mean worthless: most entries are retired because **upstream now ships
equivalent capability**. Recording them saves whoever comes next from walking the same
ground, and makes past decisions easy to locate if something regresses.

## List

| Project | Upstream status (why retired) | Former location | Details |
|---------|--------|-----------------|---------|
| comfyui-rocm patch project | Upstream comfyui-nix 0.34.0 built ROCm support in | `modules/comfyui-rocm.nix` + three patches | [EN](en/deprecated/comfyui-rocm.md) |
| mcp-searxng self-built package | Upstream nixpkgs ships it (2026-08-29, now 2.6.0) | `packages/mcp-searxng.nix` + three build workflows | [EN](en/deprecated/mcp-searxng.md) |
