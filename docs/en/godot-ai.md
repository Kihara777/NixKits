# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | English | [日本語](../ja/godot-ai.md)  | [偽中国語](../pcn/godot-ai.md)

Production-grade MCP server and AI tools for the Godot engine — connects MCP clients to a **running Godot editor**, enabling AI assistants to build scenes, edit nodes/scripts, wire signals, configure UI/materials/animations, and more. 43 MCP tools / 120+ operations.

## Basic Info

| Item | Value |
|------|-------|
| Type | Python application (MCP server) |
| Upstream | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| Version | `3.2.0` |
| License | MIT |
| Python | ≥ 3.11 |

## Architecture

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: standalone Python process started by the MCP client over stdio
- **Godot Editor Plugin**: installable from the Godot Asset Library (`hi-godot/godot-ai`), receives requests over WebSocket

## Dependencies

| Dependency | Source | Requirement |
|------------|--------|-------------|
| fastmcp | NixKits overlay | ≥ 3.4.0 (nixpkgs pins 3.3.1 which has a circular-import bug) |
| websockets | nixpkgs | ≥ 13.0 |
| pydantic | nixpkgs | ≥ 2.0 |
| httpx | nixpkgs | ≥ 0.27 |
| uvicorn | nixpkgs | ≥ 0.23 |
| starlette | nixpkgs | ≥ 0.40 |

> **fastmcp 3.4 upgrade**: nixpkgs fastmcp 3.3.1 has a circular-import bug (`fastmcp.server` fails to import). NixKits bumps it to 3.4.7 via `overlays/fastmcp.nix`, with cascading fastmcp-slim + py-key-value-aio 0.4.5 upgrades.

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
3. Start the Godot editor; godot-ai auto-connects via WebSocket at `ws://127.0.0.1:9876`
