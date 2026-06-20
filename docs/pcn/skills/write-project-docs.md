# write-project-docs (技能)

[中文](../zh/skills/write-project-docs.md) | [English](../en/skills/write-project-docs.md) | [日本語](../ja/skills/write-project-docs.md) | [偽中国語](write-project-docs.md)

> NixKits 風格任意企画向完全多言語文書系作成 — 中英日+偽中国語四言語、簡潔、表駆動方式。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | 符号作成 Agent 技能 |
| 路径 | `skills/write-project-docs/SKILL.md` |

## 機能

- 企画 metadata 評価及部品情報抽出
- 部品機能別分類（基盤/役務/代理/技能等）
- `docs/{zh,en,ja,pcn}/` 四言語目録構造生成
- 分類 README 作成（言語切替器付）
- 部品文書作成（基本情報表 + 安裝 + 引用）
- 技能文書作成（統一雛形：基本情報→機能→使用）
- 子代理並列化対応：部品類別別分派

## 技能文書同期規則

`SKILL.md` 変更時、対応四言語文書同期更新必須。
staleness check 用過期文件定位：

```bash
for lang in zh en ja pcn; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

更新順序：中文基準→英文翻訳→日文翻訳→偽中国語翻訳。
四言語列名映射：`基本信息`→`Info`/`基本情報`/`基本情報`、`功能`→`Features`/`機能`/`機能`。
偽中国語（pcn）規則：日語漢字詞彙基盤、全仮名及送仮名剥離、日語構文中国語語順転換、中文標点使用。技術用語原形維持、英文略号及記号非翻訳。

## 作成規則

- 零冗語、表優先、符号塊完全実行可能
- 技術用語英文維持、警告引用塊使用
- 中文標題 2 或 4 字詞使用視覚節奏確保
- 目標行数 ~40-60 行、補丁/部品文書四段式標準（基本情報→修正内容→安裝→注意）
- 禁止独立技術詳細、問題調査、参考章節 — 圧縮 `## 注意` bullet
- 四 README 表行同期更新必須
- 根目録中文無後綴 `.md` 維持、地域化版（`*.en.md`、`*.ja.md`、`*.pcn.md`）`docs/` 移動
- 全言語基本情報表包含必須（中文 `## 基本信息`、英文 `## Info`、日文 `## 基本情報`、偽中国語 `## 基本情報`）
- 補丁/部品源符号変更後、「修正内容」/「機能」列表同期更新必須、各 bullet 実際修正対応

## 使用

AI 補助者「文書作成」或「NixKits 風格文書生成」要求時起動。
