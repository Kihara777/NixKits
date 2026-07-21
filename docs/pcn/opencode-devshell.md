# opencode (devShell)

[中文](../zh/opencode-devshell.md) | [English](opencode-devshell.en.md) | [日本語](opencode-devshell.ja.md)  | 偽中国語

完全 AI 符号化補助開発環境：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#opencode
```

## 内蔵部品

| 部品 | 包 | 径路 / 端口 |
|------|------|------------|
| opencode | `opencode` | `opencode`（CLI） |
| opencode-telegram | `opencode-telegram` | `opencode-telegram`（電報 Bot） |
| blender | `blender` | `${BLENDER_PATH}` |
| blender-mcp | `blender-mcp` | `blender-mcp`（MCP、stdio） |
| godot | `godot` | `${GODOT_PATH}` |
| godot-mcp | `nixpkgs#godot-mcp` | `godot-mcp`（MCP、stdio） |
| SearXNG | `searxng` | `http://127.0.0.1:4270`（lighttpd 逆代行 → searxng:42701） |
| mcp-searxng | `mcp-searxng` | `mcp-searxng`（MCP、stdio） |
| Redis | `redis` | unix socket |
| lighttpd | `lighttpd` | 逆代行（4270 → 42701） |

## 環境変数

| 変数 | 値 |
|------|-----|
| `BLENDER_PATH` | `${pkgs.blender}/bin/blender` |
| `GODOT_PATH` | `${pkgs.godot}/bin/godot` |
| `SEARXNG_URL` | `http://127.0.0.1:4270` |

## MCP 自動登録

初回起動時、`~/.config/opencode/mcp.json` 不存在時、3 MCP 伺服器自動登録：

| 伺服器 | 命令 | 環境変数 |
|--------|--------|-----|
| SearXNG | `mcp-searxng` | `SEARXNG_URL` |
| Blender | `blender-mcp` | `BLENDER_PATH` |
| Godot | `godot-mcp` | `GODOT_PATH` |

## 技能自動導入

初回起動時、`~/.opencode/skills/` 空時、全 NixKits 技能 `~/NixKits/skills/`（又 GitHub）自動導入。
