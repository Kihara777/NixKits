# nixkits-skills（スキル）

[中文](../../zh/skills/nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](nixkits-skills.md)

> NixKits スキルを各コーディングエージェントのディレクトリにインストールするインストーラー。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent スキル |
| パス | `skills/nixkits-skills/SKILL.md` |

## 機能

- **ローカルインストール**: NixKits ソースディレクトリからスキルをコピー
- **オンラインインストール**: GitHub からクローンしてインストール
- **更新チェック**: インストール済みスキルとソースを比較、ユーザーに更新を確認

## 対応エージェント

`~/.opencode/skills/` `~/.codewhale/skills/` `~/.claude/skills/` `~/.openclaw/skills/` `~/.agents/skills/`

## ワークフロー

1. 既存のエージェントディレクトリを検出
2. インストール済み NixKits スキルの更新をチェック
3. 差異がある場合にユーザーへ確認
4. モードを自動選択（ローカル/オンライン）
5. インストールと検証
