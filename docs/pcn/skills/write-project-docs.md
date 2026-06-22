# write-project-docs (Skill)

[中文](../../zh/skills/write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-project-docs.md) | 偽中国語

> NixKits スタイル完全多言語文書生成 — 中英日+偽中国語四言語、簡潔、表駆動。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査、各 SKILL.md 之 frontmatter フィルド（`language_code` / `display_name` / `base_language`）読取、文書生成パイプライン利用可能言語登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| パス | `skills/write-project-docs/SKILL.md` |

## 機能

- 計画之メタデタ評価部品情報抽出
- 機能別部品分類（基盤/服務/プロキシ/技能）
- `docs/{zh,en,ja}/` ディレクトリ構造生成
- `skills/translate-*/` 之 `translate-*` 命名規則言語拡張之自動検出
- 分類 README 作成（言語切替付）
- 部品文書作成（基本情報表 + 導入 + 参照）
- 統一雛形技能文書作成（基本情報 → 機能 → 使用）
- サブ代理部品カテゴリ別之並列化対応

## 技能文書同期ルル

`SKILL.md` 変更場合、対応全言語之文書必更新。
staleness check 古書類特定：

```bash
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

更新順序：中国語ベスライン → 英語翻訳 → 日本語翻訳 → 偽中国語翻訳。
列名マッピング：`基本信息` → `Info` / `基本情報` / `基本情報`、`功能` → `Features` / `機能` / `機能`。

- ゼロ修辞、表優先、コドブロックコピペ実行可能
- 技術用語英語之、警告引用ブロック形式
- 中国語セクションタイトル 2 4 文字視覚的リズム統一
- 目標行数 ~40-60 行。パッチ/部品文書 4 セクション標準（基本情報 → 修正内容 → 導入 → 注意）
- 独立技術詳細・トラブルシュティング・参考セクション禁止 — `## 注意` 之 bullet 圧縮
- 4 之 README 必同時更新
- ルトディレクトリ中国語（サフィックス）之配置、ロカライズ版（`*.en.md`、`*.ja.md`） `docs/` 格納
- 全言語基本情報セクション必須（中文 `## 基本信息`、英文 `## Info`、日文 `## 基本情報`、偽中国語 `## 基本情報`）
- パッチ/部品之ソス変更後「修正内容」/「機能」リスト必同期、各 bullet 実際之変更対応

## 双方向自動検出

本技能 `translate-*` 翻訳技能命名規則相互発見：

| 方向 | メカニズム |
|------|-----------|
| 文書生成 → 翻訳技能 | `skills/translate-*/` スキャン、各 SKILL.md 之 frontmatter `language_code`/`display_name`/`base_language` 読取 |
| 翻訳技能 → 本計画 | 各技能 SKILL.md 内「他之技能之関係」表宣言、呼出チェン明示 |
| 言語コド → パス | `language_code` → ディレクトリ名・書類拡張子；`display_name` → 言語切替ラベル |

翻訳技能之文書自身本雛形従、ルプ閉：文書生成 → 翻訳呼出 → 翻訳技能文書生成。

## 使用

ユザ「文書作成」「NixKits スタイル文書生成」依頼起動。
