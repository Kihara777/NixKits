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

## ruyi

RuyiSDK パッケージマネージャ開発環境（stable / beta / alpha 共通）：

```bash
nix develop nixkits#ruyi       # stable
nix develop nixkits#ruyi-beta   # beta channel
nix develop nixkits#ruyi-alpha  # alpha channel
```

**主要コマンド**：

```bash
ruyi update          # パッケージマネージャの更新
ruyi list            # 利用可能パッケージ一覧
ruyi install <pkg>   # パッケージのインストール
ruyi device provision # RISC-V デバイス環境のセットアップ
```

バージョン詳細は [ruyi パッケージ文書](../zh/ruyi.md) を参照。