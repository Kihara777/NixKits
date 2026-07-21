# opencode (devShell)

[中文](../zh/opencode-devshell.md) | [English](devshell.en.md) | [日本語](devshell.ja.md)  | 偽中国語



完全 AI 符号化補助開発環境：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#opencode
```

**内蔵部品**：

| 部品 | 径路 / 端口 |
|------|------------|
| opencode | `opencode`（CLI） |
| opencode-telegram | `opencode-telegram`（電報 Bot） |
| SearXNG | `http://127.0.0.1:4270`（lighttpd 逆代行 → searxng:42701） |
| Redis | unix socket（SearXNG 用） |
| lighttpd | 逆代行（4270 → 42701、X-Forwarded-For 注入） |
| blender-mcp | `blender-mcp`（MCP 協議、stdio） |
| godot-mcp | `godot-mcp`（MCP 協議、stdio） |

**環境変数**：

- `BLENDER_PATH` — Blender 実行可能径路
- `GODOT_PATH` — Godot 実行可能径路
- `SEARXNG_URL` — SearXNG 端点（`http://127.0.0.1:4270`）

**初回起動**：`shellHook` `~/.config/opencode/mcp.json` 不存在時自動生成 MCP 設定、SearXNG、Blender、Godot 三 MCP 伺服器登録。

