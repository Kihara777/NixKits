# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](nixkits-skills.md)

> NixKits スキルをコーディングエージェントディレクトリ（opencode、codewhale、claude、openclaw、agents）にインストールまたは更新。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/nixkits-skills/SKILL.md` |

## 機能

- インストール済みエージェントのスキルディレクトリを検出
- ローカルスキルを NixKits ソースと比較し差異を表示
- ローカルインストール（ソースから）とオンラインインストール（GitHub クローン）に対応
- 適用前に差分を表示しユーザー確認を要求
- インストール後にコピーの一貫性を検証

## 対応エージェント

| エージェント | ディレクトリ |
|-------------|-------------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude Code | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| 汎用 | `~/.agents/skills/` |

## 使用

ユーザーが「スキルをインストール」または「NixKits スキルを更新」と依頼したときに起動。
