# nixkits-skills (技能)

[中文](../../zh/skills/nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-skills.md) | 偽中国語

> NixKits 技能符号化代理目録（opencode、codewhale、claude、openclaw、agents）導入又更新。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/nixkits-skills/SKILL.md` |

## 機能

- 源目録及 git remote URL 自動検出
- 導入済代理技能目録検出
- 局所技能 NixKits 源比較差異表示
- 局所導入（源自）及線上導入（GitHub 複製）対応
- 適用前差分表示利用者確認要求
- 導入後複写一貫性検証

## 対応代理

| 代理 | 目録 |
|-------------|-------------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude Code | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| 汎用 | `~/.agents/skills/` |

## 使用

利用者「技能導入」又「NixKits 技能更新」依頼時起動。
