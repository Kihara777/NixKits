# opencode (devShell)

[中文](../zh/opencode-devshell.md) | English | [日本語](opencode-devshell.ja.md)  | [偽中国語](opencode-devshell.pcn.md)

Full AI coding assistant development environment:

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#opencode
```

## Built-in Components

| Component | Package | Path / Port |
|------|------|------------|
| opencode | `opencode` | `opencode` (CLI) |
| opencode-telegram | `opencode-telegram` | `opencode-telegram` (Telegram Bot) |
| blender | `blender` | `${BLENDER_PATH}` |
| blender-mcp | `blender-mcp` | `blender-mcp` (MCP, stdio) |
| godot | `godot` | `${GODOT_PATH}` |
| godot-mcp | `nixpkgs#godot-mcp` | `godot-mcp` (MCP, stdio) |
| SearXNG | `searxng` | `http://127.0.0.1:4270` (lighttpd proxy → searxng:42701) |
| mcp-searxng | `mcp-searxng` | `mcp-searxng` (MCP, stdio) |
| Redis | `redis` | unix socket |
| lighttpd | `lighttpd` | reverse proxy (4270 → 42701) |

## Environment Variables

| Variable | Value |
|------|-----|
| `BLENDER_PATH` | `${pkgs.blender}/bin/blender` |
| `GODOT_PATH` | `${pkgs.godot}/bin/godot` |
| `SEARXNG_URL` | `http://127.0.0.1:4270` |

## MCP Auto-Registration

On first entry, if `~/.config/opencode/mcp.json` does not exist, it is auto-generated with 3 MCP servers:

| Server | Command | Env |
|--------|--------|-----|
| SearXNG | `mcp-searxng` | `SEARXNG_URL` |
| Blender | `blender-mcp` | `BLENDER_PATH` |
| Godot | `godot-mcp` | `GODOT_PATH` |

## Skill Auto-Install

On first entry, if `~/.opencode/skills/` is empty, all NixKits skills are auto-installed from `~/NixKits/skills/` (or GitHub).
