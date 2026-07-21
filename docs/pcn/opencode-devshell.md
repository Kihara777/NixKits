# devShell

[中文](../zh/opencode-devshell.md) | [English](devshell.en.md) | [日本語](devshell.ja.md)  | 偽中国語

NixKits 開発環境 `nix develop` 即用入口提供。

## opencode

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
| SearXNG | `http://127.0.0.1:42899`（lighttpd 逆代行 → searxng:42999） |
| Redis | unix socket（SearXNG 用） |
| lighttpd | 逆代行（42899 → 42999、X-Forwarded-For 注入） |
| blender-mcp | `blender-mcp`（MCP 協議、stdio） |
| godot-mcp | `godot-mcp`（MCP 協議、stdio） |

**環境変数**：

- `BLENDER_PATH` — Blender 実行可能径路
- `GODOT_PATH` — Godot 実行可能径路
- `SEARXNG_URL` — SearXNG 端点（`http://127.0.0.1:42899`）

**初回起動**：`shellHook` `~/.config/opencode/mcp.json` 不存在時自動生成 MCP 設定、SearXNG、Blender、Godot 三 MCP 伺服器登録。

## ruyi

RuyiSDK 包管理開発環境（安定 / β / α 三通道共文書）：

```bash
nix develop nixkits#ruyi       # 安定
nix develop nixkits#ruyi-beta   # β 通道
nix develop nixkits#ruyi-alpha  # α 通道
```

**主要命令**：

```bash
ruyi update          # 包管理器更新
ruyi list            # 利用可能包一覧
ruyi install <pkg>   # 包導入
ruyi device provision # RISC-V 装置環境設定
```

版詳細 [ruyi 軟件文書参照](../zh/ruyi.md)。