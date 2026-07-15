# nixkits-check-updates (技能)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md)  | 偽中国語

> NixKits 全包上流更新確認、自動昇級・文書同期、修正保守記録記入。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/nixkits-check-updates/SKILL.md` |

## 機能

- `flake.nix` 自全外部包自動検出、最新 GitHub Release 確認
- 構築設定（版、source hash、npmDepsHash）更新
- 全言語文書版番号同期
- 更新後 `write-maintenance-log` 技能自動呼出、保守記録作成
- 局所導入版報告
- 修正書類内硬符号版識別、確認手順提供

## hash 注意点

- SRI hash 標準 base64（`+` `/` `=`）使用、URL-safe 変種（`-` `_`）不可
- `fetchFromGitHub` source hash GitHub archive tarball 自**事前計算不可** — `nix build` hash mismatch 誤取得必要
- `npmDepsHash` 空場合、空文字列 `""` 非 `lib.fakeHash` 使用
- npm 包 2 回 `nix build` 必要：1 回目 source hash、2 回目 npmDepsHash

## 確認範囲

`flake.nix` → `packages` 動的読取、以下除外：
- 自己 hosting 包（倉庫内源有）
- 動的版追跡（構築時最新取得）
- nixpkgs 追従（修正上乗）
- 修正内蔵版（手動確認、例：`comfyui-strix-halo`）

残余外部包全自動確認対象。

## 使用

利用者「更新確認」又「包版更新」依頼時起動。
