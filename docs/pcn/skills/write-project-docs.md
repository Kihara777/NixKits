# write-project-docs (Skill)

[中文](../../zh/skills/write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-project-docs.md) | 偽中国語

> NixKits 完全多言語生成 — 中英日+偽中国語四言語，簡潔，表駆動。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査，各 SKILL.md frontmatter (`language_code` / `display_name` / `base_language`)読取，文書生成利用可能言語登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Coding Agent Skill |
| | `skills/write-project-docs/SKILL.md` |

## 功能

- 評価模塊情報抽出
- 功能別模塊分類(/服務//)
- `docs/{zh,en,ja}/` 構造生成
- `skills/translate-*/` `translate-*` 命名規則言語拡張自動検出
- 分類 README 作成(言語切替付)
- 模塊作成(基本情報表 + 安裝 + 参照)
- 統一作成(基本情報 → 功能 → 使用)
- 代理模塊別並列化対応

## 同期

`SKILL.md` 変更場合，対応全言語必更新。
staleness check 古ァ特定：

```bash
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

更新順序：中国語 → 英語翻訳 → 日本語翻訳 → 偽中国語翻訳。
列名：`基本信息` → `Info` / `基本情報` / `基本情報`，`功能` → `Features` / `功能` / `功能`。

- 修辞，表優先，実行可能
- 技術用語英語，警告引用形式
- 中国語 2 4 文字視覚的統一
- 目標行数 ~40-60 行。/模塊 4 標準(基本情報 → 修復内容 → 安裝 → 注意)
- 独立技術詳細・・参考禁止 — `## 注意` bullet 圧縮
- 4 README 必同時更新
- 中国語()配置，版(`*.en.md`，`*.ja.md`) `docs/` 格納
- 全言語基本情報必須(中文 `## 基本信息`，英文 `## Info`，日文 `## 基本情報`，偽中国語 `## 基本情報`)
- /模塊変更後「修復内容」/「功能」必同期，各 bullet 実際変更対応

## 双方向自動検出

本 `translate-*` 翻訳命名規則相互発見：

| 方向 | |
|------|-----------|
| 生成 → 翻訳 | `skills/translate-*/` ，各 SKILL.md frontmatter `language_code`/`display_name`/`base_language` 読取 |
| 翻訳 → 本 | 各 SKILL.md 内「他関係」表宣言，呼出明示 |
| 言語 → | `language_code` → 名・ァ拡張子；`display_name` → 言語切替 |

翻訳自身本従，閉：生成 → 翻訳呼出 → 翻訳生成。

## 使用

「作成」「NixKits 生成」依頼起動。
