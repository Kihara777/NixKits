# write-project-docs (技能)

[中文](../../zh/skills/write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-project-docs.md) | 偽中国語

> NixKits 式完全多言語文書生成 — 中英日+偽中国語四言語、簡潔、表駆動。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査、各 SKILL.md frontmatter 欄（`language_code` / `display_name` / `base_language`）読取、文書生成管路利用可能言語登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/write-project-docs/SKILL.md` |

## 機能

- 計画 metadata 評価部品情報抽出
- 機能別部品分類（基盤/服務/代理/技能）
- `docs/{zh,en,ja}/` 目録構造生成
- `skills/translate-*/` `translate-*` 命名規則言語拡張自動検出
- 分類 README 作成（言語切替付）
- 部品文書作成（基本情報表 + 導入 + 参照）
- 統一雛形以技能文書作成（基本情報 → 機能 → 使用）
- 子代理部品種別並列化対応

## 技能文書同期規則

`SKILL.md` 変更時、対応全言語文書必更新。
staleness check 以古書類特定：

```bash
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

更新順序：中国語基線 → 英語翻訳 → 日本語翻訳 → 偽中国語翻訳。
列名対応：`基本信息` → `Info` / `基本情報` / `基本情報`、`功能` → `Features` / `機能` / `機能`。

- 零修辞、表優先、符号塊複写貼付実行可能
- 技術用語英語儘、警告引用塊形式
- 中国語節題 2 又 4 文字視覚律統一
- 目標行数 ~40-60 行。修正/部品文書 4 節標準（基本情報 → 修正内容 → 導入 → 注意）
- 独立技術詳細・障害対処・参考節禁止 — `## 注意` bullet 圧縮
- 4 README 必同時更新
- 根目録中国語（接尾辞無）配置、局所化版（`*.en.md`、`*.ja.md`）`docs/` 格納
- 全言語基本情報節必須（中文 `## 基本信息`、英文 `## Info`、日文 `## 基本情報`、偽中国語 `## 基本情報`）
- 修正/部品源変更後「修正内容」/「機能」一覧必同期、各 bullet 実際変更対応

## 双方向自動検出

本技能 `translate-*` 翻訳技能命名規則相互発見：

| 方向 | 機構 |
|------|-----------|
| 文書生成 → 翻訳技能 | `skills/translate-*/` 走査、各 SKILL.md frontmatter 自 `language_code`/`display_name`/`base_language` 読取 |
| 翻訳技能 → 本計画 | 各技能 SKILL.md 内「他技能関係」表宣言、呼出連鎖明示 |
| 言語符号 → 路 | `language_code` → 目録名・書類拡張子；`display_name` → 言語切替札 |

翻訳技能文書自身本雛形従、循環閉：文書生成 → 翻訳呼出 → 翻訳技能文書生成。

## 使用

利用者「文書作成」又「NixKits 式文書生成」依頼時起動。
