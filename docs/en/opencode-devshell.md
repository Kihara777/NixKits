# opencode (devShell)

[中文](../zh/opencode-devshell.md) | English | [日本語](devshell.ja.md)  | [偽中国語](devshell.pcn.md)



Full AI coding assistant dev environment:

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#opencode
```

**Bundled components**:

| Component | Package | Path / Port |
|----------|---------|------------|
| opencode | `opencode` | `opencode` (CLI) |
| opencode-telegram | `opencode-telegram` | `opencode-telegram` (Telegram Bot) |
| SearXNG | `searxng` | `http://127.0.0.1:4270` (lighttpd proxy → searxng:42701) |
| Redis | `redis` | unix socket (for SearXNG) |
| lighttpd | `lighttpd` | reverse proxy (4270 → 42701, injects X-Forwarded-For) |
| blender-mcp | `blender-mcp` (MCP protocol, stdio) |
| godot-mcp | `godot-mcp` (MCP protocol, stdio) |

**Environment variables**:

- `BLENDER_PATH` — blender executable path
- `GODOT_PATH` — godot executable path
- `SEARXNG_URL` — SearXNG endpoint (`http://127.0.0.1:4270`)

**First run**: `shellHook` auto-generates `~/.config/opencode/mcp.json` with SearXNG, Blender, and Godot MCP server registration if the file doesn't exist.


## MCP Auto-Registration

On first entry, if `~/.config/opencode/mcp.json` does not exist, it is auto-generated:

| Server | Command | Env |
|--------|--------|-----|
| SearXNG | `mcp-searxng` | `SEARXNG_URL` |
| Blender | `blender-mcp` | `BLENDER_PATH` |
| Godot | `godot-mcp` | `GODOT_PATH` |

## Skill Auto-Install

On first entry, if `~/.opencode/skills/` is empty, all NixKits skills are auto-installed from `~/NixKits/skills/` (or GitHub).
