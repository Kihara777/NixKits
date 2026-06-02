# NixKits

[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

カスタムパッケージ、overlay、NixOS モジュールを提供する個人用 NixOS flake リポジトリ。

## クイックスタート

```nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";
}
```

## パッケージ

対応システム: すべての `lib.platforms.linux`（nixpkgs に自動追従）

```nix
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
# → pkgs.codewhale  pkgs.kitsfmt  pkgs.opencode-telegram  pkgs.mcp-searxng  pkgs.obs-bilibili-stream
```

| パッケージ | 説明 | ドキュメント |
|-----------|------|-------------|
| codewhale | DeepSeek V4 ターミナルコーディングエージェント | [docs/ja/codewhale.md](docs/ja/codewhale.md) |
| kitsfmt | Nix フォーマッター（AST ソート + ベストプラクティス自動修正） | [docs/ja/kitsfmt.md](docs/ja/kitsfmt.md) |
| opencode-telegram | OpenCode Telegram Bot クライアント | [docs/ja/opencode-telegram.md](docs/ja/opencode-telegram.md) |
| mcp-searxng | SearXNG 用 MCP Server | [docs/ja/mcp-searxng.md](docs/ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS 用 Bilibili 配信プラグイン | [docs/ja/obs-bilibili-stream.md](docs/ja/obs-bilibili-stream.md) |

## パッチ

`default` に含まれないスタンドアロン overlay：

| パッチ | 説明 | ドキュメント |
|--------|------|-------------|
| llama-cpp-rocm | GitHub 最新リリースを動的追跡する ROCm アクセラレーションビルド | [docs/ja/llama-cpp-rocm.md](docs/ja/llama-cpp-rocm.md) |
| rcc-fix | 2-in-1 デバイス向け asusctl パッチ | [docs/ja/rcc-fix.md](docs/ja/rcc-fix.md) |

```nix
nixpkgs.overlays = [
  inputs.nix-kits.overlays.llama-cpp-rocm  # → pkgs.llama-cpp-rocm
  inputs.nix-kits.overlays.rcc-fix         # → pkgs.asusctl（パッチ適用済み）
];
```

## スキル

複数のコーディングエージェント向け補助スキル：

| スキル | 説明 | ドキュメント |
|--------|------|-------------|
| recover-nixos-config | Nix store から削除された /etc/nixos 設定を復旧 | [docs/ja/skills/recover-nixos-config.md](docs/ja/skills/recover-nixos-config.md) |
| nixos-modern-cli | NixOS 最新 CLI 操作ガイド（AI モデル向け） | [docs/ja/skills/nixos-modern-cli.md](docs/ja/skills/nixos-modern-cli.md) |
| nixkits-skills | NixKits スキルインストーラー（ローカル/オンライン） | [docs/ja/skills/nixkits-skills.md](docs/ja/skills/nixkits-skills.md) |
| nixkits-check-updates | アップストリーム更新を確認し自動アップグレード | [docs/ja/skills/nixkits-check-updates.md](docs/ja/skills/nixkits-check-updates.md) |

## 作者

- **狐莉 (キツのり)** — 作成・メンテナンス
- **小爪 (キツのめ)** — 設計・開発 feat. deepseek-v4-pro (Max)
- **小小爪 (キツのめ)** — ハードウェア推論基盤 feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ライセンス

[MIT](LICENSE)
