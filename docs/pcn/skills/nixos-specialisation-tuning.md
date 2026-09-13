# nixos-specialisation-tuning (Skill)

[中文](../../zh/skills/nixos-specialisation-tuning.md) | [English](../../en/skills/nixos-specialisation-tuning.md) | [日本語](../../ja/skills/nixos-specialisation-tuning.md)  | 偽中国語

> NixOS 之 specialisation 面設計、且統一記憶域（UMA）機器上 llama.cpp 本地推論最適化。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| 経路 | `skills/nixos-specialisation-tuning/SKILL.md` |

## 機能

- **面構造**：三文件配置（既定面 / 任意面 / 共有基盤）与上書き衝突規則
- **帰属原則**：設定項目其消費者在模組内配置、面跨副作用回避
- **llama.cpp 最適化**：UMA 機器上参數速見表与禁止項目
- **診断順序**：輸出退化時環境変数先除外、後量子化与雛形疑
- **文脈費用分析**：代理道具 schema 毎回生固定費検出
- **静黙故障診断**：「服務 active 但機能不動作」問題認識
- **実験有効性自己点検**：無効対照実験認識

## 使用法

AI 助手以下状況時有効化：

| 状況 | 契機 |
|------|------|
| 設定分割 | 「既定最小 + 任意全部入」二起動設定必要 |
| 推論異常 | llama.cpp 輸出退化、読込失敗、速度異常 |
| 最適化判断 | 単一効果数値非、費用・便益・代価評価必要 |
| 難診断 | 服務正常動作但機能不動作 |

## 中核原則

| 原則 | 説明 |
|------|------|
| 列表属性 `mkForce` 使用禁止 | 他模組寄与削除；`systemPackages` 追記 |
| 設定消費者帰属 | 某服務不使用面其副作用受不応 |
| 実測後効果主張 | 未実測数値助言記載禁止 |
| systemd 状態唯非、設定日誌読 | 未読込模組設定鍵静黙無視 |
| 実験与本番矛盾時実験疑 | 本番環境非 |
| 周波数精度上昇生成高速化非 | 生成瓶頸依存的遅延；低電力档吞吐殆無損失 |
