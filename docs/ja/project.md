# NixKits プロジェクト文書

[中文](../zh/project.md) | [English](../en/project.md) | [日本語](project.md)

## プロジェクトの役割

| 役割 | 名前 | 担当 |
|------|------|------|
| 作成・保守 | 狐莉 (キツのり) | コア開発、アーキテクチャ、リリース管理 |
| 設計・開発 | 小爪 (キツのめ) | AI コーディングエージェント、ビルド設定、スキルシステム — feat. DeepSeek V4 Pro (Max) |
| 推論インフラ | 小小爪 (キツのめ) | ローカル LLM 推論、モデル量子化、ROCm アクセラレーション — feat. llama-cpp-rocm |
| 翻訳 (ja) | 尾巻 (オマキ) | すべての日本語文書の翻訳とレビュー |
| 翻訳 (en) | 耳廓狐 (フェネック) | すべての英語文書の翻訳とレビュー |
| 文書設計 | 小爪 (キツのめ) | 多言語文書システムアーキテクチャ、言語切替器、テンプレート設計 |

## プロジェクトアーキテクチャ

```
NixKits/
├── packages/          # パッケージ定義（スタンドアロンバイナリまたはソースビルド）
├── modules/           # NixOS モジュール（systemd サービス、設定オプション）
├── overlays/          # Nixpkgs オーバーレイ（default に含まれないものもあり）
├── patches/           # スタンドアロンパッチファイル
├── skills/            # AI コーディングアシスタント向けスキル定義
├── docs/              # 多言語文書
│   ├── zh/            # 中国語（ベースライン）
│   ├── en/            # 英語
│   ├── ja/            # 日本語
│   └── katalish/      # カタカナ英語（en から自動翻訳）
```

## コンポーネントカタログ

完全なカタログデータは中国語ベースライン文書に定義されています：
[docs/zh/project.md](../zh/project.md)

主要セクション：
- **ソフトウェア** — 7 パッケージ（`nix build nix-kits#<name>` で直接ビルド可能）
- **NixOS モジュール** — 6 モジュール（systemd サービスと設定を提供）
- **スタンドアロンオーバーレイ** — 5 オーバーレイ（`default` を除く 4 つ）
- **スタンドアロンパッチ** — 3 パッチ（オーバーレイまたはモジュールから参照）
- **AI コーディングスキル** — 8 スキル（translate-* 言語の自動検出付き）

## 多言語文書システム

### 言語マップ

| コード | 表示名 | ディレクトリ | 命名 | 翻訳者 |
|--------|--------|-------------|------|--------|
| zh | 中文 | `docs/zh/` | `<name>.md` (ベースライン) | 狐莉 |
| en | English | `docs/en/` | `<name>.md` | 耳廓狐 |
| ja | 日本語 | `docs/ja/` | `<name>.md` | 尾巻 |
| katalish | ｶﾀﾘｯｼｭ | `docs/katalish/` | `<name>.md` | 小爪 (自動機械翻訳) |
| pcn | 偽中国語 | `docs/pcn/` | `<name>.md` | 小爪 (自動機械翻訳) |

### 拡張言語の自動検出

`translate-*` スキルは `write-project-docs` によって自動検出されます：

```
skills/translate-*/SKILL.md → frontmatter の language_code と display_name
```

現在インストール済みの拡張言語：
- `translate-katalish`: `language_code: katalish` → カタカナ英語
- `translate-pseudocn`: `language_code: pcn` → 偽中国語
