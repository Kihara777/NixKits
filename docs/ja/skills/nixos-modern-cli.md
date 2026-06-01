# nixos-modern-cli（スキル）

[中文](../../zh/skills/nixos-modern-cli.md) | [English](../../en/skills/nixos-modern-cli.md) | [日本語](nixos-modern-cli.md)

> AI モデルが NixOS と従来の Linux の違いを正しく理解し、最新 CLI でシステムメンテナンスを行えるようにします。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent スキル |
| パス | `skills/nixos-modern-cli/SKILL.md` |

## インストール

任意のコーディングエージェントスキルディレクトリにコピー：

```
~/.opencode/skills/
~/.codewhale/skills/
~/.claude/skills/
~/.openclaw/skills/
~/.agents/skills/
```

## 解決する問題

小規模モデルは NixOS を従来の Linux ディストリビューションと誤認しがちです：
- `apt`/`yum` でパッケージをインストールしようとする
- 一般的なコマンドのパスを見つけられない
- 設定変更の適用方法がわからない

このスキルは完全な NixOS 運用リファレンスを提供します。

## 主な内容

- NixOS の宣言型・イミュータブルシステムの重要な違い
- 最新 CLI の優先（`nixos`/`nix` > `nixos-rebuild`/`nix-env`）
- シェル環境とアドホックツールのインストール
- システム更新とメンテナンスのワークフロー
- よくある落とし穴と解決策
