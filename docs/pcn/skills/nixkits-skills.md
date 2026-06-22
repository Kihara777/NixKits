# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-skills.md) | 偽中国語

> NixKits 技能符号化代理ディレクトリ（opencode、codewhale、claude、openclaw、agents）導入更新。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| パス | `skills/nixkits-skills/SKILL.md` |

## 機能

- ソスディレクトリ git remote URL 自動検出
- 導入済代理之技能ディレクトリ検出
- ロカル技能 NixKits ソス比較差異表示
- ロカル導入（ソス）オンライン導入（GitHub クロン）対応
- 適用前差分表示ユザ確認要求
- 導入後コピ之一貫性検証

## 対応代理

| 代理 | ディレクトリ |
|-------------|-------------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude Code | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| 汎用 | `~/.agents/skills/` |

## 使用

ユザ「技能導入」「NixKits 技能更新」依頼起動。
