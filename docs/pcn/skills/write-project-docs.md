# write-project-docs (Skill)

[中文](../../zh/skills/write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-project-docs.md) | 偽中国語

> NixKits スタイル完全多言語ドキュメント生成 — 中英日+偽中国語四言語、簡潔、表駆動。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査、各 SKILL.md 之 frontmatter フィールド（`language_code` / `display_name` / `base_language`）読取、文書生成パイプライン利用可能言語與登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| パス | `skills/write-project-docs/SKILL.md` |

## 機能

- プロジェクト之メタデータ評価モジュル情報抽出
- 機能別モジュル分類（インフラ/サービス/プロキシ/スキル）
- `docs/{zh,en,ja}/` ディレクトリ構造生成
- `skills/translate-*/` 之 `translate-*` 命名規則言語拡張之自動検出
- 分類 README 作成（言語切替付）
- モジュルドキュメント作成（基本情報表 + 導入 + 参照）
- 統一テンプレートスキルドキュメント作成（基本情報 → 機能 → 使用）
- サブエージェントモジュルカテゴリ別之並列化対応

## スキルドキュメント同期ルール

`SKILL.md` 変更場合、対応全言語之ドキュメント必更新。
staleness check 古ファイル特定：

```bash
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

更新順序：中国語ベースライン → 英語翻訳 → 日本語翻訳 → 偽中国語翻訳。
列名マッピング：`基本信息` → `Info` / `基本情報` / `基本情報`、`功能` → `Features` / `機能` / `機能`。

- ゼロ修辞、表優先、コードブロックコピペ実行可能
- 技術用語英語之、警告引用ブロック形式
- 中国語セクションタイトル 2  4 文字視覚的リズム統一
- 目標行数 ~40-60 行。パッチ/モジュルドキュメント 4 セクション標準（基本情報 → 修正内容 → 導入 → 注意）
- 独立技術詳細・トラブルシュティング・参考セクション禁止 — `## 注意` 之 bullet 圧縮
- 4 之 README 必同時更新
- ルートディレクトリ中国語（サフィックス）之配置、ローカライズ版（`*.en.md`、`*.ja.md`） `docs/` 格納
- 全言語基本情報セクション必須（中文 `## 基本信息`、英文 `## Info`、日文 `## 基本情報`、偽中国語 `## 基本情報`）
- パッチ/モジュル之ソース変更後「修正内容」/「機能」リスト必同期、各 bullet 実際之変更対応

## 双方向自動検出

本スキル與 `translate-*` 翻訳スキル命名規則相互発見：

| 方向 | メカニズム |
|------|-----------|
| ドキュメント生成 → 翻訳スキル | `skills/translate-*/` スキャン、各 SKILL.md 之 frontmatter  `language_code`/`display_name`/`base_language` 読取 |
| 翻訳スキル → 本プロジェクト | 各スキル SKILL.md 内「他之スキル與之関係」表宣言、呼出チェーン明示 |
| 言語コード → パス | `language_code` → ディレクトリ名・ファイル拡張子；`display_name` → 言語切替ラベル |

翻訳スキル之ドキュメント自身本テンプレート従、ループ閉：ドキュメント生成 → 翻訳呼出 → 翻訳スキルドキュメント生成。

## 使用

ユーザー「ドキュメント作成」「NixKits スタイルドキュメント生成」與依頼與起動。
