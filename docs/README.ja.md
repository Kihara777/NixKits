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
| dsh-alpha | DeepSeek Harness（DSH）— アルファ開発チャネル（0.1.5-alpha.2） | [docs/ja/dsh.md](ja/dsh.md) |
| godot-ai | Godot エンジン向けの MCP サーバーと AI ツール | [docs/ja/godot-ai.md](ja/godot-ai.md) |
| kitsfmt | Nix フォーマッタ（AST ソート + ベストプラクティス自動修正） | [docs/ja/kitsfmt.md](ja/kitsfmt.md) |
| mcp-searxng | SearXNG 向け MCP サーバー | [docs/ja/mcp-searxng.md](ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili 配信プラグイン | [docs/ja/obs-bilibili-stream.md](ja/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 向け Telegram Bot クライアント | [docs/ja/opencode-telegram.md](ja/opencode-telegram.md) |
| ruyi<br>ruyi-beta<br>ruyi-alpha | RuyiSDK パッケージマネージャ（RISC-V 開発ツール）<br>stable 0.52.0 · beta 0.52.0-beta.20260824 · alpha 0.52.0-alpha.20260714 | [docs/ja/ruyi.md](ja/ruyi.md) |


## プラグイン

DeepSeek Harness（DSH）コンポーネントはソフトウェアと分けて掲載する（マウント方法は [docs/ja/dsh.md](ja/dsh.md)）：

| プラグイン | 説明 | ドキュメント |
|------------|------|--------------|
| dsh-nixos-shell | NixOS 操作統合（シェル実行、ツールブートストラップ、sudo デーモンルーティング、NixOS 診断） | [docs/ja/dsh-nixos-shell.md](ja/dsh-nixos-shell.md) |
| dsh-api-balance | API 使用量残高——webui の使用量リング（送信ボタン左）に「用量 / 残高」タブ切替を追加。残高・当日 / 当月 / 30 日消費とチャートを表示。プラットフォームトークンはデフォルトで本機ブラウザのログイン状態から自動スキャン取得（手動接続はフォールバック） | [docs/ja/dsh-api-balance.md](ja/dsh-api-balance.md) |

## モード

Agent プリセット（セッション形態）はプラグインと同級で、それぞれ独立したドキュメントを持つ：

| モード | id | 説明 | 配布方式 | ドキュメント |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | 初期化時に NixOS ホストを検証（非 NixOS は全リクエスト拒否）；`nixos_shell`/`nixos_cli` と NixOS 開発プロンプトを読み込む | dsh-nixos-shell パッケージ内、seed-once | [docs/ja/modes/nixos.md](ja/modes/nixos.md) |
| 維護模式 | `maintenance` | NixOS模式から派生；`write-project-docs`/`write-maintenance-log`/`nixkits-check-updates`/`translate-*` スキルとリポジトリ保守ワークフロープロンプトを注入 | dsh-nixos-shell パッケージ内、seed-once | [docs/ja/modes/maintenance.md](ja/modes/maintenance.md) |
| 新聞三要素模式 | `news-three-elements` | 極簡模式から派生した**読取専用**の創作モード：「新聞三要素」は必ず揃う三人の主人公、素材優先（接続できないときだけ拒否）、技能パッケージをオンライン取得、開始時問答は三択、簡体中文以外は一律拒否 | **独立パッケージ** `dsh-preset-news-three-elements` | [docs/ja/modes/news-three-elements.md](ja/modes/news-three-elements.md) |

> 前二者は dsh-nixos-shell パッケージに同梱され、`nixkits.dsh.presets.nixosMode` / `.maintenanceMode` により seed-once で `$DSH_HOME/.agent-presets` へ書き込まれる；新聞三要素模式は独立パッケージ `dsh-preset-news-three-elements` が配布し、`nixkits.dsh.presets.newsThreeElements` がその `share/dsh-agent-presets` をプリセットルートとして登録する（コピーなし）。詳細は [docs/ja/dsh.md](ja/dsh.md) の「モード」節を参照。

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
| asusd-pd-profile | 電源種別でプラットフォームプロファイルを選択（USB-C PD と原生 AC を区別） | [docs/ja/asusd-pd-profile.md](ja/asusd-pd-profile.md) |
| asusd-thermal-guard | 温度監視：過熱時にプロファイルを降格し、冷却後に復帰 | [docs/ja/asusd-thermal-guard.md](ja/asusd-thermal-guard.md) |
| comfyui-rocm | ComfyUI に ROCm 機能パッチを提供 | [docs/ja/comfyui-rocm.md](ja/comfyui-rocm.md) |
| efl-cross-fix | efl クロスコンパイルのコード生成ツール不足を修正 | [docs/ja/efl-cross-fix.md](ja/efl-cross-fix.md) |
| breeze-black | Plasma 6 高コントラスト Breeze Black アクセシビリティテーマ | [docs/ja/breeze-black.md](ja/breeze-black.md) |
| codewhale-sudo | overlay — codewhale v0.9.12 の sudo 機能を復元（ptrace インターセプター） | [docs/ja/codewhale-sudo.md](ja/codewhale-sudo.md) |

> ⚠️ パッチは overlay であり、上流の nixpkgs パッケージを変更するもので、独立したビルドではありません。そのためバイナリキャッシュに含まれません。動的バージョン追跡プロジェクト（llama-cpp-rocm など）はハッシュが上流リリースごとに変化し、キャッシュ固定不可です。

> ⚠️ **StrixHalo デバイスでは `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` を設定しないでください。** この変数は GPU メモリ割り当て経路を変更し、ユニファイドメモリ環境でモデル出力の退化（単語の繰り返し、文の崩壊）を引き起こします。実測により、このリスクは**モデルの量子化精度が下がるほど著しく増大**します —— 低ビット量子化（例：1.5 bpw）が最も影響を受けます。詳細は [llama-cpp-rocm ドキュメント](ja/llama-cpp-rocm.md#ユニファイドメモリ環境変数による退化リスク) を参照。

## スキル

AI コーディングアシスタント向け：

> 本プロジェクトのスキルは主に中国語ユーザーと中国のオープンソースモデルを対象としています。すべての SKILL.md は中国語で記述されています。

| スキル | 説明 | ドキュメント |
|------|------|------|
> ⚠️ **Claude Code** は nixkits-skills インストール対象から削除されました。ユーザーデータに基づく国籍推論を実装し、セキュリティ境界を越えています。詳細は [nixkits-skills 文書](ja/skills/nixkits-skills.md) を参照。
| news-three-elements | 本物の通信社報道形式でロシア風速報を捏造——「報道三要素」とは必ず揃う三人の主人公、バランニコフ・ユディンツェフ・ブヤノフを指す（遊技機構ネタ + 素材優先の拒否サービス） | [docs/ja/skills/news-three-elements.md](ja/skills/news-three-elements.md) |
| nixkits-check-updates | 上流アップデートをチェックして自動更新 | [docs/ja/skills/nixkits-check-updates.md](ja/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits スキルインストーラー（ローカル/オンライン） | [docs/ja/skills/nixkits-skills.md](ja/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS モダン CLI ガイド（AI モデル向け） | [docs/ja/skills/nixos-modern-cli.md](ja/skills/nixos-modern-cli.md) |
| recover-nixos-config | 削除された /etc/nixos 設定を Nix store から復元 | [docs/ja/skills/recover-nixos-config.md](ja/skills/recover-nixos-config.md) |
| translate-pseudocn | 偽中国語翻訳（日本語→仮名除去＋語順変換） | [docs/ja/skills/translate-pseudocn.md](ja/skills/translate-pseudocn.md) |
| write-maintenance-log | NixKits 仕様に沿った MAINTENANCE.md エントリの作成（ソフトウェア更新 + バグ修正） | [docs/ja/skills/write-maintenance-log.md](ja/skills/write-maintenance-log.md) |
| write-project-docs | 任意のプロジェクトに NixKits スタイルの多言語ドキュメントを作成 | [docs/ja/skills/write-project-docs.md](ja/skills/write-project-docs.md) |
| nixos-specialisation-tuning | NixOS の specialisation 面を設計し、ユニファイドメモリ機器で llama.cpp を最適化 | [docs/ja/skills/nixos-specialisation-tuning.md](ja/skills/nixos-specialisation-tuning.md) |

## クレジット

- **狐莉 (キツのり)** — 作成と保守
- **小爪 (キツのめ)** — 設計・開発 feat. DeepSeek V4 Flash · DeepSeek V4.1 Flash
- **小小爪 (キツのめ)** — ハードウェア推論インフラ feat. llama-cpp-rocm: DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)

> [!NOTE]
> 关于 DeepSeek Harness (DSH) 生态 —— 小爪与小小爪使用 dsh-nixos-shell 插件，以及 NixOS模式 / 维护模式 Agent 预设武装了自己☆

## ライセンス

[MIT](../LICENSE)