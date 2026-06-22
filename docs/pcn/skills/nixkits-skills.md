# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-skills.md) | 偽中国語

> NixKits スキルコーディングエージェントディレクトリ（opencode、codewhale、claude、openclaw、agents）導入更新。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| パス | `skills/nixkits-skills/SKILL.md` |

## 機能

- ソースディレクトリ與 git remote URL 自動検出
- 導入済エージェント之スキルディレクトリ検出
- ローカルスキル NixKits ソース與比較差異表示
- ローカル導入（ソース）與オンライン導入（GitHub クローン）対応
- 適用前差分表示ユーザー確認要求
- 導入後コピー之一貫性検証

## 対応エージェント

| エージェント | ディレクトリ |
|-------------|-------------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude Code | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| 汎用 | `~/.agents/skills/` |

## 使用

ユーザー「スキル導入」「NixKits スキル更新」與依頼與起動。
