# opencode (devShell)

[中文](../zh/opencode-devshell.md) | [English](opencode-devshell.en.md) | 日本語  | [偽中国語](opencode-devshell.pcn.md)

完全な AI コーディングアシスタント開発環境：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#opencode
```

## 内蔵コンポーネント

| コンポーネント | パッケージ | パス / ポート |
|------|------|------------|
| opencode | `opencode` | `opencode`（CLI） |
| opencode-telegram | `opencode-telegram` | `opencode-telegram`（Telegram Bot） |
| blender | `blender` | `${BLENDER_PATH}` |
| blender-mcp | `blender-mcp` | `blender-mcp`（MCP、stdio） |
| godot | `godot` | `${GODOT_PATH}` |
| godot-mcp | `nixpkgs#godot-mcp` | `godot-mcp`（MCP、stdio） |
| SearXNG | `searxng` | `http://127.0.0.1:4270`（lighttpd プロキシ → searxng:42701） |
| mcp-searxng | `mcp-searxng` | `mcp-searxng`（MCP、stdio） |
| Redis | `redis` | unix socket |
| lighttpd | `lighttpd` | リバースプロキシ（4270 → 42701） |

## 環境変数

| 変数 | 値 |
|------|-----|
| `BLENDER_PATH` | `${pkgs.blender}/bin/blender` |
| `GODOT_PATH` | `${pkgs.godot}/bin/godot` |
| `SEARXNG_URL` | `http://127.0.0.1:4270` |

## MCP 自動登録

初回起動時、`~/.config/opencode/mcp.json` が存在しない場合、3 つの MCP サーバーが自動登録される：

| サーバー | コマンド | 環境変数 |
|--------|--------|-----|
| SearXNG | `mcp-searxng` | `SEARXNG_URL` |
| Blender | `blender-mcp` | `BLENDER_PATH` |
| Godot | `godot-mcp` | `GODOT_PATH` |

## スキル自動インストール

初回起動時、`~/.opencode/skills/` が空の場合、全 NixKits スキルが `~/NixKits/skills/`（または GitHub）から自動インストールされる。
