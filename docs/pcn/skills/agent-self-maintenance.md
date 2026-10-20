# agent-self-maintenance (Skill)

[中文](../../zh/skills/agent-self-maintenance.md) | [English](../../en/skills/agent-self-maintenance.md) | [日本語](../../ja/skills/agent-self-maintenance.md)  | 偽中国語

> 失敗 可能 五 小 仕組、AI 符号化代理 自己 記憶 長期保守 可能 化。

## 基本情報

| 項 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| path | `skills/agent-self-maintenance/SKILL.md` |
| 対象 | `journal/` 與 自己検査 script 持 任意 repo |

## 五 仕組

| 仕組 | 判据 | 境界 |
|---|---|---|
| 日記 gate | commit 有 且 当日 日記 未変更 → 一度 通知 | 未設定 静 |
| 開始時 照合 | 受領書 / 日記 / 事実 読；ok / red / stale 混 無 | 「一度 走 無」 言 |
| 事実検査 | 各 事実 探針 持；`検証不能` 第三状態 | data repo 残 |
| 自己観察 | 彼女 言 / 私 測 / 不明、分 記録 | 条目 日付 與 証拠 |
| 自己検査受領書 | 五状態、`ok` 唯 静 | 受領書 commit 無 |

## data 帰属

仕組 移植可能、**data 移 無**：事実条目・観察条目・閾値 各 repo 物。

## 参考実装

dsh 掌灯 mode（`presets/lampkeeper/`）五 仕組 完全実装。
