# opencode (devShell)

[中文](../zh/opencode-devshell.md) | [English](devshell.en.md) | 日本語  | [偽中国語](devshell.pcn.md)



完全な AI コーディングアシスタント開発環境：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#opencode
```

**内蔵コンポーネント**：

| コンポーネント | パス / ポート |
|-------------|------------|
| opencode | `opencode`（CLI） |
| opencode-telegram | `opencode-telegram`（Telegram Bot） |
| SearXNG | `http://127.0.0.1:4270`（lighttpd プロキシ → searxng:42701） |
| Redis | unix socket（SearXNG 用） |
| lighttpd | リバースプロキシ（4270 → 42701、X-Forwarded-For 注入） |
| blender-mcp | `blender-mcp`（MCP プロトコル、stdio） |
| godot-mcp | `godot-mcp`（MCP プロトコル、stdio） |

**環境変数**：

- `BLENDER_PATH` — Blender 実行パス
- `GODOT_PATH` — Godot 実行パス
- `SEARXNG_URL` — SearXNG エンドポイント（`http://127.0.0.1:4270`）

**初回起動**：`shellHook` が `~/.config/opencode/mcp.json` に SearXNG、Blender、Godot の MCP サーバー設定を自動生成します（ファイルが存在しない場合）。
