# NixKits

[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

NixKits — ソフトウェア、パッチ、NixOS モジュール、AI コーディングアシスタントスキルのコレクション。

## クイックスタート

```nix
# リモート
inputs.nix-kits.url = "github:Kihara777/NixKits";

# ローカル
inputs.nix-kits.url = "/home/kix/NixKits";
```

## パッケージ

対応システム: すべての `lib.platforms.linux`（nixpkgs に自動追従）

| パッケージ | 説明 | ドキュメント |
|-----------|------|-------------|
| codewhale | DeepSeek V4 ターミナルコーディングエージェント | [docs/ja/codewhale.md](docs/ja/codewhale.md) |
| kitsfmt | Nix フォーマッター（AST ソート + ベストプラクティス自動修正） | [docs/ja/kitsfmt.md](docs/ja/kitsfmt.md) |
| mcp-searxng | SearXNG 用 MCP Server | [docs/ja/mcp-searxng.md](docs/ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS 用 Bilibili 配信プラグイン | [docs/ja/obs-bilibili-stream.md](docs/ja/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode Telegram Bot クライアント | [docs/ja/opencode-telegram.md](docs/ja/opencode-telegram.md) |

## パッチ

`default` に含まれないスタンドアロン overlay：

| パッチ | 説明 | ドキュメント |
|--------|------|-------------|
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA 3.5) 向け ComfyUI ROCm サポート | [docs/ja/comfyui-strix-halo.md](docs/ja/comfyui-strix-halo.md) |
| llama-cpp-rocm | GitHub 最新リリースを動的追跡する ROCm アクセラレーションビルド | [docs/ja/llama-cpp-rocm.md](docs/ja/llama-cpp-rocm.md) |
| rcc-fix | 2-in-1 デバイス向け asusctl パッチ | [docs/ja/rcc-fix.md](docs/ja/rcc-fix.md) |

## スキル

複数のコーディングエージェント向け補助スキル：

> 本プロジェクトのスキルは主に中国語ユーザーと中国のオープンソース LLM を対象としており、すべての SKILL.md は中国語で記述されています。

| スキル | 説明 | ドキュメント |
|--------|------|-------------|
| nixkits-check-updates | アップストリーム更新を確認し自動アップグレード | [docs/ja/skills/nixkits-check-updates.md](docs/ja/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits スキルインストーラー（ローカル/オンライン） | [docs/ja/skills/nixkits-skills.md](docs/ja/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS 最新 CLI 操作ガイド（AI モデル向け） | [docs/ja/skills/nixos-modern-cli.md](docs/ja/skills/nixos-modern-cli.md) |
| recover-nixos-config | Nix store から削除された /etc/nixos 設定を復旧 | [docs/ja/skills/recover-nixos-config.md](docs/ja/skills/recover-nixos-config.md) |
| write-project-docs | 任意のプロジェクトに NixKits スタイルの多言語ドキュメントを生成 | [docs/ja/skills/write-project-docs.md](docs/ja/skills/write-project-docs.md) |

## 作者

- **狐莉 (キツのり)** — 作成・メンテナンス
- **小爪 (キツのめ)** — 設計・開発 feat. deepseek-v4-pro (Max)
- **小小爪 (キツのめ)** — ハードウェア推論基盤 feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ライセンス

[MIT](LICENSE)
