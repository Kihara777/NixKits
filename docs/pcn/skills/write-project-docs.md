# write-project-docs (Skill)

[中文](../../zh/skills/write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-project-docs.md) | 偽中国語

> NixKits 完全多言語文書生成 — 中英日+偽中国語四言語、簡潔、表駆動。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査、各 SKILL.md 之 frontmatter （`language_code` / `display_name` / `base_language`）読取、文書生成利用可能言語登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| | `skills/write-project-docs/SKILL.md` |

## 機能

- 計画之評価部品情報抽出
- 機能別部品分類（基盤/服務//）
- `docs/{zh,en,ja}/` 構造生成
- `skills/translate-*/` 之 `translate-*` 命名規則言語拡張之自動検出
- 分類 README 作成（言語切替付）
- 部品文書作成（基本情報表 + 導入 + 参照）
- 統一雛形文書作成（基本情報 → 機能 → 使用）
- 代理部品別之並列化対応

## 文書同期

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

更新順序：中国語 → 英語翻訳 → 日本語翻訳 → 偽中国語翻訳。
列名：`基本信息` → `Info` / `基本情報` / `基本情報`、`功能` → `Features` / `機能` / `機能`。

- 修辞、表優先、実行可能
- 技術用語英語之、警告引用形式
- 中国語 2 4 文字視覚的統一
- 目標行数 ~40-60 行。/部品文書 4 標準（基本情報 → 修正内容 → 導入 → 注意）
- 独立技術詳細参考禁止 — `## 注意` 之 bullet 圧縮
- 4 之 README 必同時更新
- 中国語（）之配置、版（`*.en.md`、`*.ja.md`） `docs/` 格納
- 全言語基本情報必須（中文 `## 基本信息`、英文 `## Info`、日文 `## 基本情報`、偽中国語 `## 基本情報`）
- /部品之変更後「修正内容」/「機能」必同期、各 bullet 実際之変更対応

## 双方向自動検出

本 `translate-*` 翻訳命名規則相互発見：

| 方向 | |
|------|-----------|
| 文書生成 → 翻訳 | `skills/translate-*/`、各 SKILL.md 之 frontmatter `language_code`/`display_name`/`base_language` 読取 |
| 翻訳 → 本計画 | 各 SKILL.md 内「他之之関係」表宣言、呼出明示 |
| 言語 → | `language_code` → 名書類拡張子；`display_name` → 言語切替 |

翻訳之文書自身本雛形従、閉：文書生成 → 翻訳呼出 → 翻訳文書生成。

## 使用

「文書作成」「NixKits 文書生成」依頼起動。
