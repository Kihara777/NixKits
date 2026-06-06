# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](nixkits-check-updates.md)

> NixKits の全パッケージとパッチの上流更新をチェックし、バージョンアップとドキュメント同期を自動適用。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/nixkits-check-updates/SKILL.md` |

## 機能

- `flake.nix` 内の外部パッケージの最新 GitHub Release を自動検出
- ビルド設定（バージョン、source hash、npmDepsHash）を更新
- 3 言語のドキュメントのバージョン番号を同期
- ローカルにインストールされたバージョンを報告
- パッチファイル内のハードコードされたバージョンを識別し確認手順を提供

## チェック範囲

`flake.nix` → `packages` を動的読み取り、以下を除外：
- セルフホストパッケージ（リポジトリ内にソースあり）
- 動的バージョン追跡（ビルド時に最新を取得）
- nixpkgs 追従（パッチオーバーレイ）
- パッチ内蔵バージョン（手動確認、例：`comfyui-strix-halo`）

残りの外部パッケージはすべて自動チェック対象。

## 使用

ユーザーが「更新をチェック」または「パッケージバージョンを更新」と依頼したときに起動。
