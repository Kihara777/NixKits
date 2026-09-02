# NixKits

[中文](../README.md) | [English](README.en.md) | 日本語  | [偽中国語](README.pcn.md)

NixKits — ソフトウェア、パッチ、NixOS モジュール、AI コーディングアシスタントスキルのコレクション。

## 追加

```nix
# リモート
inputs.nixkits.url = "github:Kihara777/NixKits";

# ローカル
inputs.nixkits.url = "~/NixKits";
```

## ソフトウェア

全パッケージはデフォルトで nixpkgs プラットフォーム対応（`lib.platforms.linux`）。一部パッケージのアーキテクチャ対応は上流の影響を受ける — 各パッケージ文書のビルドバッジを参照。

| ソフトウェア | 説明 | ドキュメント |
|---|------|------|
| blender-mcp | Blender 向け MCP サーバー（自然言語による Blender 操作） | [docs/ja/blender-mcp.md](ja/blender-mcp.md) |
| codewhale | DeepSeek V4 端末コーディングエージェント | [docs/ja/codewhale.md](ja/codewhale.md) |
| dsh | DeepSeek Harness（DSH）— すべてがプラグイン | [docs/ja/dsh.md](ja/dsh.md) |
| dsh-alpha | DeepSeek Harness（DSH）— アルファ開発チャネル（0.1.2-alpha.3） | [docs/ja/dsh.md](ja/dsh.md) |
| godot-ai | Godot エンジン向けの MCP サーバーと AI ツール | [docs/ja/godot-ai.md](ja/godot-ai.md) |
| kitsfmt | Nix フォーマッタ（AST ソート + ベストプラクティス自動修正） | [docs/ja/kitsfmt.md](ja/kitsfmt.md) |
| mcp-searxng | SearXNG 向け MCP サーバー | [docs/ja/mcp-searxng.md](ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili 配信プラグイン | [docs/ja/obs-bilibili-stream.md](ja/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 向け Telegram Bot クライアント | [docs/ja/opencode-telegram.md](ja/opencode-telegram.md) |
| ruyi<br>ruyi-beta<br>ruyi-alpha | RuyiSDK パッケージマネージャ（RISC-V 開発ツール）<br>stable 0.52.0 · beta 0.52.0-beta.20260824 · alpha 0.52.0-alpha.20260714 | [docs/ja/ruyi.md](docs/ja/ruyi.md) |


## プラグイン

DeepSeek Harness（DSH）コンポーネントはソフトウェアと分けて掲載する（マウント方法は [docs/ja/dsh.md](ja/dsh.md)）：

| プラグイン | 説明 | ドキュメント |
|------------|------|--------------|
| dsh-nixos-shell | NixOS 操作統合（シェル実行、ツールブートストラップ、sudo デーモンルーティング、NixOS 診断） | [docs/ja/dsh-nixos-shell.md](ja/dsh-nixos-shell.md) |
| dsh-api-balance | API 使用量残高——webui の使用量リング（送信ボタン左）に「用量 / 残高」タブ切替を追加。残高・当日 / 当月 / 30 日消費とチャートを表示。プラットフォームトークンはデフォルトで本機ブラウザのログイン状態から自動スキャン取得（手動接続はフォールバック） | [docs/ja/dsh-api-balance.md](ja/dsh-api-balance.md) |

**Agent プリセット**（dsh-nixos-shell に同梱、`nixkits.dsh.presets` で DSH へ一度だけシード）：

| プリセット | 説明 |
|------------|------|
| NixOS模式（id `nixos`） | 初期化時に NixOS ホストを検証（非 NixOS は全拒否）；`nixos_shell`/`nixos_cli` と NixOS 開発ガイドをロード |
| 維護模式（id `maintenance`） | NixOS模式基盤；`write-project-docs`/`write-maintenance-log`/`nixkits-check-updates`/`translate-*` スキルとリポジトリ保守ワークフローを注入 |

## 開発

`nix develop` で即利用可能。まずレジストリを追加：

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| 環境 | コマンド | 文書 |
|-----------|------|------|
| opencode | `nix develop nixkits#opencode` | [ja/opencode-devshell.md](ja/opencode-devshell.md) |
| ruyi | `nix develop nixkits#ruyi` | [ja/ruyi-devshell.md](ja/ruyi-devshell.md) |
| ruyi-beta | `nix develop nixkits#ruyi-beta` |  |
| ruyi-alpha | `nix develop nixkits#ruyi-alpha` | |

## パッチ

スタンドアロンオーバーレイ。`default` には含まれない：

| パッチ | 説明 | ドキュメント |
|------|------|------|
| llama-cpp-rocm | 上流最新リリースを追跡する ROCm アクセラレーション | [docs/ja/llama-cpp-rocm.md](ja/llama-cpp-rocm.md) |
| rcc-fix | asusctl の 2-in-1 デバイス体験を修正 | [docs/ja/rcc-fix.md](ja/rcc-fix.md) |
| comfyui-rocm | ComfyUI に ROCm 機能パッチを提供 | [docs/ja/comfyui-rocm.md](ja/comfyui-rocm.md) |
| efl-cross-fix | efl クロスコンパイルのコード生成ツール不足を修正 | [docs/ja/efl-cross-fix.md](ja/efl-cross-fix.md) |
| breeze-black | Plasma 6 高コントラスト Breeze Black アクセシビリティテーマ | [docs/ja/breeze-black.md](ja/breeze-black.md) |
| codewhale-sudo | overlay — codewhale v0.9.11 の sudo 機能を復元（ptrace インターセプター） | [docs/ja/codewhale-sudo.md](ja/codewhale-sudo.md) |

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
- **小爪 (キツのめ)** — 設計・開発 feat. DeepSeek V4 Flash · DeepSeek Harness (DSH) エコシステム（dsh-nixos-shell プラグインと NixOS模式/維護模式 Agent プリセット）
- **小小爪 (キツのめ)** — ハードウェア推論インフラ feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ライセンス

[MIT](../LICENSE)