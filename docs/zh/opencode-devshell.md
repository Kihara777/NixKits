# opencode (devShell)

中文 | [English](../en/opencode-devshell.md) | [日本語](../ja/opencode-devshell.md)  | [偽中国語](../pcn/opencode-devshell.md)



完整的 AI 编码辅助开发环境：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#opencode
```

**内置组件**：

| 组件 | 包 | 路径 / 端口 |
|------|------|------------|
| opencode | `opencode` | `opencode`（CLI） |
| opencode-telegram | `opencode-telegram` | `opencode-telegram`（Telegram Bot） |
| SearXNG | `searxng` | `http://127.0.0.1:4270`（lighttpd 反代 → searxng:42701） |
| Redis | `redis` | unix socket（SearXNG 用） |
| lighttpd | `lighttpd` | 反向代理（4270 → 42701，注入 X-Forwarded-For） |
| blender-mcp | `blender-mcp` | `blender-mcp`（MCP 协议，stdio） |
| godot-mcp | `nixpkgs#godot-mcp` | `godot-mcp`（MCP 协议，stdio） |

**环境变量**：

- `BLENDER_PATH` — Blender 可执行路径
- `GODOT_PATH` — Godot 可执行路径
- `SEARXNG_URL` — SearXNG 接口地址（`http://127.0.0.1:4270`）

**首次使用**：`shellHook` 会在 `~/.config/opencode/mcp.json` 不存在时自动生成 MCP 配置文件，注册 SearXNG、Blender、Godot 三个 MCP 服务器。

## ruyi

RuyiSDK 包管理器开发环境（stable / beta / alpha 三通道共用同一文档）：

```bash
nix develop nixkits#ruyi       # stable
nix develop nixkits#ruyi-beta   # beta channel
nix develop nixkits#ruyi-alpha  # alpha channel
```

**主要命令**：

```bash
ruyi update          # 更新包管理器
ruyi list            # 列出可用包
ruyi install <pkg>   # 安装指定包
ruyi device provision # 为 RISC-V 设备配置环境
```

具体包版本见 [ruyi 软件文档](../zh/ruyi.md)。