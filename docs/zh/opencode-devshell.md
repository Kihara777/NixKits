# opencode (devShell)

中文 | [English](../en/opencode-devshell.md) | [日本語](../ja/opencode-devshell.md)  | [偽中国語](../pcn/opencode-devshell.md)

完整的 AI 编码辅助开发环境：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#opencode
```

## 内置组件

| 组件 | 包 | 路径 / 端口 |
|------|------|------------|
| opencode | `opencode` | `opencode`（CLI） |
| opencode-telegram | `opencode-telegram` | `opencode-telegram`（Telegram Bot） |
| blender | `blender` | `${BLENDER_PATH}` |
| blender-mcp | `blender-mcp` | `blender-mcp`（MCP，stdio） |
| godot | `godot` | `${GODOT_PATH}` |
| godot-ai | `nixkits#godot-ai` | `godot-ai`（MCP，stdio） |
| SearXNG | `searxng` | `http://127.0.0.1:4270`（lighttpd 反代 → searxng:42701） |
| mcp-searxng | `mcp-searxng` | `mcp-searxng`（MCP，stdio） |
| Redis | `redis` | unix socket |
| lighttpd | `lighttpd` | 反向代理（4270 → 42701） |

## 环境变量

| 变量 | 值 |
|------|-----|
| `BLENDER_PATH` | `${pkgs.blender}/bin/blender` |
| `GODOT_PATH` | `${pkgs.godot}/bin/godot` |
| `SEARXNG_URL` | `http://127.0.0.1:4270` |

## MCP 自动注册

首次进入 devShell 时，`~/.config/opencode/mcp.json` 不存在则自动生成，注册以下 3 个 MCP 服务器：

| 服务器 | 命令 | 依赖环境变量 |
|--------|------|------------|
| SearXNG | `mcp-searxng` | `SEARXNG_URL` |
| Blender | `blender-mcp` | `BLENDER_PATH` |
| Godot | `godot-ai` | `GODOT_PATH` |

## 技能自动安装

首次进入时，若 `~/.opencode/skills/` 目录为空，自动从本地 `~/NixKits/skills/`（或 GitHub）安装所有 NixKits 技能。