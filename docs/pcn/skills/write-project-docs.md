# write-project-docs (Skill)

[中文](../../zh/skills/write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | [Katalish](../../katalish/skills/write-project-docs.md) | Pseudo-Chinese

> NixKits 完全多言語文檔生成 — 中英日+偽中国語四言語簡潔表駆動

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査各 SKILL.md frontmatter `language_code` / `display_name` / `base_language`読取文書生成利用可能言語登録

## 基本情報

|項目|値|
|------|-----|
||Coding Agent Skill|
||`skills/write-project-docs/SKILL.md`|

## 機能

- 項目數據評価模塊情報抽出
- 機能別模塊分類基礎設施/服務//技能
- `docs/{zh,en,ja}/` 目錄構造生成
- `skills/translate-*/` `translate-*` 命名規則言語拡張自動検出
- 分類 README 作成言語切替付
- 模塊文檔作成基本情報表 + 安裝 + 参照
- 統一模板技能文檔作成基本情報 → 機能 → 使用
- 模塊分類別並列化対応

## 技能文檔同期

`SKILL.md` 変更場合対応全言語文檔必更新
staleness check 古文件特定：

```bash
for lang in zh en ja; do
for skill in skills/*/SKILL.md; do
name=$(basename $(dirname $skill))
doc="docs/$lang/skills/$name.md"
[ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
done
done
```

更新順序：中国語 → 英語翻訳 → 日本語翻訳 → 偽中国語翻訳
列名：`基本信息` → `Info` / `基本情報` / `基本情報``功能` → `Features` / `機能` / `機能`

- 修辞表優先代碼実行可能
- 技術用語英語警告引用形式
- 中国語章節 2 4 文字視覚的統一
- 目標行数 ~40-60 行補丁/模塊文檔 4 章節標準基本情報 → 修正内容 → 安裝 → 注意
- 独立技術詳細参考章節禁止 — `## 注意` bullet 圧縮
- 4 README 必同時更新
- 目錄中国語配置版`*.en.md``*.ja.md` `docs/` 格納
- 全言語基本情報章節必須中文 `## 基本信息`英文 `## Info`日文 `## 基本情報`偽中国語 `## 基本情報`
- 補丁/模塊変更後修正内容/機能必同期各 bullet 実際変更対応

## 双方向自動検出

本技能 `translate-*` 翻訳技能命名規則相互発見：

|方向||
|------|-----------|
|文檔生成 → 翻訳技能|`skills/translate-*/` 各 SKILL.md frontmatter `language_code`/`display_name`/`base_language` 読取|
|翻訳技能 → 本項目|各技能 SKILL.md 内他技能関係表宣言呼出明示|
|言語代碼 →|`language_code` → 目錄名文件拡張子；`display_name` → 言語切替|

翻訳技能文檔自身本模板従閉：文檔生成 → 翻訳呼出 → 翻訳技能文檔生成

## 使用

文檔作成NixKits 文檔生成依頼起動