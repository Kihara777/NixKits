# nixkits-package-upstream skill 名（廃止）

[中文](../../zh/deprecated/nixkits-package-upstream.md) | [English](../../en/deprecated/nixkits-package-upstream.md) | [日本語](../../ja/deprecated/nixkits-package-upstream.md)  | 偽中国語

[← 廃止工程索引](../../../DEPRECATED.md)

**状態**：skill 名 廃止（2026-10-20）
**旧位置**：`skills/nixkits-package-upstream/`
**現状**：file **純監査適配層** 残、先頭 廃止告知 有。汎用手法 `upstream-audit` 移動済。

## 為何 廃止

上流貢献 skill 二層 分割：

| 層 | 内容 | 場所 |
|---|---|---|
| `upstream-audit` | 評価・要求 監査・dry-run —— **読取専用、dry-run 迄** | 本 repo |
| 私有提出層 | fork / branch / commit / push / PR / review 対応 | 展開側 私有 preset（本 repo 配布 無） |

旧名「監査」與「提出」両方 暗示、新構造 適配層 監査責務 唯 持 ——
**責務 超 広 名前、次 誤用 入口 化**。

## 移行

- 汎用監査 `upstream-audit` 使用；
- 提出 環境側 権限 有 層 使用（本 repo 提供 無）；
- 旧名 skill 一覧・登録・preset 出現 無；`MAINTENANCE.*` 履歴 旧名 保（履歴 書換 無）。

## 一 判据

**名前 廃止 file 削除 非。** 内容 適配層 残、**書込操作 既 含 無**
—— 権限 要 層 移 済。廃止 物「一 名前 二 事 約束」形状。
