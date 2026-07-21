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

## ruyi

RuyiSDK package manager dev environment (stable / beta / alpha share one doc):

```bash
nix develop nixkits#ruyi       # stable
nix develop nixkits#ruyi-beta   # beta channel
nix develop nixkits#ruyi-alpha  # alpha channel
```

**Key commands**:

```bash
ruyi update          # update package manager
ruyi list            # list available packages
ruyi install <pkg>   # install a package
ruyi device provision # set up RISC-V device environment
```

See [ruyi package docs](../zh/ruyi.md) for version details.