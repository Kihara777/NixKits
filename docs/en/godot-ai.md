# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | English | [日本語](../ja/godot-ai.md)  | [偽中国語](../pcn/godot-ai.md)

Production-grade MCP server and AI tools for the Godot engine — connects MCP clients to a **running Godot editor**, enabling AI assistants to build scenes, edit nodes/scripts, wire signals, configure UI/materials/animations, and more. 46 MCP tools / 120+ operations.

## Basic Info

| Item | Value |
|------|-------|
| Type | Python application (MCP server) |
| Upstream | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| Version | `4.3.0` |
| License | MIT |
| Python | ≥ 3.11, < 3.15 |

## Architecture

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: standalone Python process started by the MCP client over stdio
- **Godot Editor Plugin**: installable from the Godot Asset Library (`hi-godot/godot-ai`), receives requests over WebSocket

## Dependencies

**Fail-closed exact pins since v4**: at startup it verifies the **exact version** of the fourteen packages below and raises `RuntimeError` on any mismatch, refusing to start. The list settled at fourteen entries in 4.2.3 (which added `fastmcp-slim` / `httpx2` / `httpcore2` / `mcp-types` / `sniffio` and moved `mcp` across a major version, 1.29.1 → 2.2.0: upstream split the wire types into the standalone `mcp-types` distribution and switched its HTTP client to `httpx2`). 4.3.0 **adds and removes nothing** — it raises six of the entries: `fastmcp` / `fastmcp-slim` 4.0.5 → 4.0.10, `httpx2` / `httpcore2` 2.13.0 → 2.13.1, `uvicorn` 0.53.0 → 0.54.0, and `starlette` 1.6.0 → 1.7.0.

| Dependency | Version | Source |
|------------|---------|--------|
| anyio | `4.15.1` | `overlays/godot-ai-v4-deps.nix` |
| fastmcp | `4.0.10` | `overlays/fastmcp.nix` |
| fastmcp-slim | `4.0.10` | `overlays/fastmcp.nix` |
| h11 | `0.16.0` | nixpkgs |
| httpx | `0.28.1` | nixpkgs |
| httpx2 | `2.13.1` | `overlays/godot-ai-v4-deps.nix` |
| httpcore2 | `2.13.1` | `overlays/godot-ai-v4-deps.nix` |
| mcp | `2.2.0` | `overlays/godot-ai-v4-deps.nix` |
| mcp-types | `2.2.0` | `overlays/godot-ai-v4-deps.nix` (absent from nixpkgs; definition built from upstream source) |
| pydantic | `2.13.5` | `overlays/godot-ai-v4-deps.nix` |
| sniffio | `1.3.1` | nixpkgs |
| starlette | `1.7.0` | `overlays/godot-ai-v4-deps.nix` |
| uvicorn | `0.54.0` | `overlays/godot-ai-v4-deps.nix` |
| websockets | `17.1` | `overlays/godot-ai-v4-deps.nix` |

> The fourteen rows above map one-to-one onto `dependencies` in `packages/godot-ai.nix` (same count, same versions), and match the pin table in upstream's `runtime_dependencies.py`.

> **mcp-types**: not present in nixpkgs; `overlays/godot-ai-v4-deps.nix` defines it from upstream's own repository (`src/mcp-types/` in `modelcontextprotocol/python-sdk`).

> **pydantic-core**: pydantic 2.13.5 requires `pydantic-core==2.46.5` (nixpkgs ships 2.46.4). That package is Rust-built, so bumping it means re-fetching `cargoDeps` as well.

> **Build-time pin**: upstream hardcodes `setuptools==84.0.0` in `[build-system].requires` (nixpkgs ships 83.0.0); the package's `postPatch` relaxes it — that pin is a reproducibility guard, not a feature requirement.

> **Why not patch the check out**: v4's exact pins serve its security boundaries (connection / body / frame / session budgets), so relaxing `runtime_dependencies.py` would silently weaken that boundary. We raise the dependencies to match upstream rather than bending the check to nixpkgs.

> **Both overlays must actually take effect**: `overlays/fastmcp.nix` and `overlays/godot-ai-v4-deps.nix` are chained in two places (`godotPkgs` in `flake.nix` and `overlays/default.nix`), and both attach through nixpkgs' `pythonPackagesExtensions`. With `python312.override { packageOverrides = …; }` the second one **replaces** the first, silently dropping the fastmcp overrides while the build still succeeds.

## Install & Usage

### System Install

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.godot-ai ];
```

### Quick Start

```bash
godot-ai
```

MCP client config (Claude Code / Codex / etc.):

```json
{
  "Godot": {
    "command": "godot-ai",
    "env": {}
  }
}
```

### Prerequisites

1. Godot 4.5+ editor (4.7+ recommended)
2. Install the `hi-godot/godot-ai` plugin from the Godot Asset Library (editor **AssetLib** tab)
3. Start the Godot editor; godot-ai auto-connects via WebSocket at `ws://127.0.0.1:9500` (the default; change it with `--ws-port`)
