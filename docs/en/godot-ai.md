# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | English | [日本語](../ja/godot-ai.md)  | [偽中国語](../pcn/godot-ai.md)

Production-grade MCP server and AI tools for the Godot engine — connects MCP clients to a **running Godot editor**, enabling AI assistants to build scenes, edit nodes/scripts, wire signals, configure UI/materials/animations, and more. 46 MCP tools / 120+ operations.

## Basic Info

| Item | Value |
|------|-------|
| Type | Python application (MCP server) |
| Upstream | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| Version | `4.1.0` |
| License | MIT |
| Python | ≥ 3.11 |

## Architecture

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: standalone Python process started by the MCP client over stdio
- **Godot Editor Plugin**: installable from the Godot Asset Library (`hi-godot/godot-ai`), receives requests over WebSocket

## Dependencies

**Fail-closed exact pins since v4**: at startup it verifies the **exact version** of the nine packages below and raises `RuntimeError` on any mismatch, refusing to start. nixpkgs lags on five of them, so `overlays/godot-ai-v4-deps.nix` raises them to what upstream requires.

| Dependency | Version | Source |
|------------|---------|--------|
| fastmcp | `3.4.7` | `overlays/fastmcp.nix` |
| anyio | `4.14.2` | nixpkgs |
| mcp | `1.29.1` | `overlays/godot-ai-v4-deps.nix` |
| websockets | `17.1` | `overlays/godot-ai-v4-deps.nix` |
| pydantic | `2.13.5` | `overlays/godot-ai-v4-deps.nix` |
| httpx | `0.28.1` | nixpkgs |
| uvicorn | `0.52.4` | `overlays/godot-ai-v4-deps.nix` |
| starlette | `1.6.0` | `overlays/godot-ai-v4-deps.nix` |
| h11 | `0.16.0` | nixpkgs |

> **pydantic-core**: pydantic 2.13.5 requires `pydantic-core==2.46.5` (nixpkgs ships 2.46.4). That package is Rust-built, so bumping it means re-fetching `cargoDeps` as well.

> **Build-time pin**: upstream hardcodes `setuptools==84.0.0` in `[build-system].requires` (nixpkgs ships 83.0.0); the package's `postPatch` relaxes it — that pin is a reproducibility guard, not a feature requirement.

> **Why not patch the check out**: v4's exact pins serve its security boundaries (connection / body / frame / session budgets), so relaxing `runtime_dependencies.py` would silently weaken that boundary. We raise the dependencies to match upstream rather than bending the check to nixpkgs.

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
