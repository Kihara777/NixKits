# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | 偽中国語 | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-skills.md) 

> NixKits スキルコーディングエージェントディレクトリ(opencode，codewhale，claude，openclaw，agents)インストール更新。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/nixkits-skills/SKILL.md` |

## 機能

- ソースディレクトリ git remote URL 自動検出
- インストール済エージェントスキルディレクトリ検出
- ローカルスキル NixKits ソース比較差異表示
- ローカルインストール(ソース)オンラインインストール(GitHub クローン)対応
- 適用前差分表示ユーザー確認要求
- インストール後コピー一貫性検証

## 対応エージェント

| エージェント | ディレクトリ |
|-------------|-------------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude Code | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| 汎用 | `~/.agents/skills/` |

## 使用

ユーザー「スキルインストール」「NixKits スキル更新」依頼起動。
