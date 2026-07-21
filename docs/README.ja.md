# NixKits

[中文](../README.md) | [English](README.en.md) | 日本語  | [偽中国語](README.pcn.md)

NixKits — ソフトウェア、パッチ、NixOS モジュール、AI コーディングアシスタントスキルのコレクション。

## 追加

```nix
# リモート
inputs.nixkits.url = "github:Kihara777/NixKits";

# ローカル
inputs.nixkits.url = "/home/kix/NixKits";
```

## ソフトウェア

全パッケージはデフォルトで nixpkgs プラットフォーム対応（`lib.platforms.linux`）。一部パッケージのアーキテクチャ対応は上流の影響を受ける — 各パッケージ文書のビルドバッジを参照。

| ソフトウェア | 説明 | ドキュメント |
|---|------|------|
| blender-mcp | Blender 向け MCP サーバー（自然言語による Blender 操作） | [docs/ja/blender-mcp.md](ja/blender-mcp.md) |
| codewhale | DeepSeek V4 端末コーディングエージェント | [docs/ja/codewhale.md](ja/codewhale.md) |
| kitsfmt | Nix フォーマッタ（AST ソート + ベストプラクティス自動修正） | [docs/ja/kitsfmt.md](ja/kitsfmt.md) |
| mcp-searxng | SearXNG 向け MCP サーバー | [docs/ja/mcp-searxng.md](ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili 配信プラグイン | [docs/ja/obs-bilibili-stream.md](ja/obs-bilibili-stream.md) |
| opencode | OpenCode 向け Telegram Bot クライアント | [docs/ja/opencode-telegram.md](ja/opencode-telegram.md) |
| ruyi | RuyiSDK パッケージマネージャー（RISC-V 開発ツール）<br>stable 0.50.0 · beta 0.50.0-beta.20260623 · alpha 0.51.0-alpha.20260616 | [docs/ja/ruyi.md](ja/ruyi.md) |

> ⚠️ comfyui-strix-halo はモジュール+パッチであり、独立したパッケージではないため、バイナリキャッシュに含まれません。

> ⚠️ comfyui-strix-halo はモジュール+パッチであり、独立したパッケージではないため、バイナリキャッシュに含まれません。

## 開発

`nix develop` で即利用可能。まずレジストリを追加：

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| パッケージ | `nix develop` |
|-----------|---------------|
| opencode | `nix develop nixkits#opencode-telegram` |
| ruyi | `nix develop nixkits#ruyi` |
| ruyi-beta | `nix develop nixkits#ruyi-beta` |
| ruyi-alpha | `nix develop nixkits#ruyi-alpha` |

## パッチ

スタンドアロンオーバーレイ。`default` には含まれない：

| パッチ | 説明 | ドキュメント |
|------|------|------|
| llama-cpp-rocm | 上流最新リリースを追跡する ROCm アクセラレーション | [docs/ja/llama-cpp-rocm.md](ja/llama-cpp-rocm.md) |
| rcc-fix | asusctl の 2-in-1 デバイス体験を修正 | [docs/ja/rcc-fix.md](ja/rcc-fix.md) |
| comfyui-rocm-patch | ComfyUI に ROCm 機能パッチを提供 | [docs/ja/comfyui-rocm-patch.md](ja/comfyui-rocm-patch.md) |
| efl-cross-fix | efl クロスコンパイルのコード生成ツール不足を修正 | [docs/ja/efl-cross-fix.md](ja/efl-cross-fix.md) |
| rog-control-center-fix | シャットダウン時の asusd デッドロックを修正 | [docs/ja/rog-control-center-fix.md](ja/rog-control-center-fix.md) |

> ⚠️ パッチは overlay であり、上流の nixpkgs パッケージを変更するもので、独立したビルドではありません。そのためバイナリキャッシュに含まれません。動的バージョン追跡プロジェクト（llama-cpp-rocm など）はハッシュが上流リリースごとに変化し、キャッシュ固定不可です。

> ⚠️ パッチは overlay であり、上流の nixpkgs パッケージを変更するもので、独立したビルドではありません。そのためバイナリキャッシュに含まれません。動的バージョン追跡プロジェクト（llama-cpp-rocm など）はハッシュが上流リリースごとに変化し、キャッシュ固定不可です。

## スキル

AI コーディングアシスタント向け：

> 本プロジェクトのスキルは主に中国語ユーザーと中国のオープンソースモデルを対象としています。すべての SKILL.md は中国語で記述されています。

| スキル | 説明 | ドキュメント |
|------|------|------|
> ⚠️ **Claude Code** は nixkits-skills インストール対象から削除されました。ユーザーデータに基づく国籍推論を実装し、セキュリティ境界を越えています。詳細は [nixkits-skills 文書](ja/skills/nixkits-skills.md) を参照。
| nixkits-check-updates | 上流アップデートをチェックして自動更新 | [docs/ja/skills/nixkits-check-updates.md](ja/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits スキルインストーラー（ローカル/オンライン） | [docs/ja/skills/nixkits-skills.md](ja/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS モダン CLI ガイド（AI モデル向け） | [docs/ja/skills/nixos-modern-cli.md](ja/skills/nixos-modern-cli.md) |
| recover-nixos-config | 削除された /etc/nixos 設定を Nix store から復元 | [docs/ja/skills/recover-nixos-config.md](ja/skills/recover-nixos-config.md) |
| translate-pseudocn | 偽中国語翻訳（日本語→仮名除去＋語順変換） | [docs/ja/skills/translate-pseudocn.md](ja/skills/translate-pseudocn.md) |
| write-maintenance-log | NixKits 仕様に沿った MAINTENANCE.md エントリの作成（ソフトウェア更新 + バグ修正） | [docs/ja/skills/write-maintenance-log.md](ja/skills/write-maintenance-log.md) |
| write-project-docs | 任意のプロジェクトに NixKits スタイルの多言語ドキュメントを作成 | [docs/ja/skills/write-project-docs.md](ja/skills/write-project-docs.md) |

## クレジット

- **狐莉 (キツのり)** — 作成と保守
- **小爪 (キツのめ)** — 設計・開発 feat. DeepSeek V4 Pro (Max)
- **小小爪 (キツのめ)** — ハードウェア推論インフラ feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ライセンス

[MIT](../LICENSE)