# NixKits 項目文書

[中文](../zh/project.md) | [English](../en/project.md) | [日本語](project.md)

## 項目役割

|役割|名前|担当|
|------|------|------|
|作成保守|狐莉 ()|開発架構發佈管理|
|設計開発|小爪 ()|AI 構建設定技能系統 — feat. DeepSeek V4 Pro (Max)|
|推論基礎設施|小小爪 ()|LLM 推論量子化ROCm 加速 — feat. llama-cpp-rocm|
|翻訳 (ja)|尾巻 ()|日本語文書翻訳|
|翻訳 (en)|耳廓狐 ()|英語文書翻訳|
|文書設計|小爪 ()|多言語文書系統架構言語切替器模板設計|

## 項目架構

```
NixKits/
├── packages/ # 軟件包定義構建
├── modules/ # NixOS 模塊systemd 服務設定選項
├── overlays/ # Nixpkgs 覆蓋層default 含
├── patches/ # 補丁文件
├── skills/ # AI 向技能定義
├── docs/ # 多言語文書
│ ├── zh/ # 中国語
│ ├── en/ # 英語
│ ├── ja/ # 日本語
│ └── katalish/ # 英語en 自動翻訳
```

## 組件日誌

完全日誌數據中国語文書定義：
[docs/zh/project.md](../zh/project.md)

主要章節：
- **軟件** — 7 軟件包`nix build nix-kits#<name>` 直接構建可能
- **NixOS 模塊** — 6 模塊systemd 服務設定提供
- **覆蓋層** — 5 覆蓋層`default` 除 4
- **補丁** — 3 補丁覆蓋層模塊参照
- **AI 技能** — 8 技能translate-* 言語自動検出付

## 多言語文書系統

### 言語

|代碼|表示名|目錄|命名|翻訳者|
|--------|--------|-------------|------|--------|
|zh|中文|`docs/zh/`|`<name>.md` ()|狐莉|
|en|English|`docs/en/`|`<name>.md`|耳廓狐|
|ja|日本語|`docs/ja/`|`<name>.md`|尾巻|
|katalish|ｶﾀﾘｯｼｭ|`docs/katalish/`|`<name>.md`|小爪 (自動機械翻訳)|
|pcn|偽中国語|`docs/pcn/`|`<name>.md`|小爪 (自動機械翻訳)|

### 拡張言語自動検出

`translate-*` 技能 `write-project-docs` 自動検出：

```
skills/translate-*/SKILL.md → frontmatter language_code display_name
```

現在安裝済拡張言語：
- `translate-katalish`: `language_code: katalish` → 英語
- `translate-pseudocn`: `language_code: pcn` → 偽中国語