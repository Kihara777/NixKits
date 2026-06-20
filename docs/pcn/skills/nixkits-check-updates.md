# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-check-updates.md) | 偽中国語

> NixKits 全軟件包上流更新，自動・同期，修復記録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Coding Agent Skill |
| | `skills/nixkits-check-updates/SKILL.md` |

## 功能

- `flake.nix` 全外部軟件包自動検出最新 GitHub Release 
- 構建設置(版本，source hash，npmDepsHash)更新
- 全言語版本番号同期
- 更新後 `write-maintenance-log` 自動呼出，記録作成
- 安裝版本報告
- ァ内版本識別確認手順提供

## hash 注意点

- SRI hash 標準 base64(`+` `/` `=`)使用，URL-safe 変種(`-` `_`)不可
- `fetchFromGitHub` source hash GitHub archive tarball **事前計算** — `nix build` hash mismatch 取得必要
- `npmDepsHash` 空場合空文字列 `""` `lib.fakeHash` 使用
- npm 軟件包 2 回 `nix build` 必要：1 回目 source hash，2 回目 npmDepsHash

## 範囲

`flake.nix` → `packages` 動的読取，以下除外：
- 軟件包(倉庫内)
- 動的版本追跡(構建時最新取得)
- nixpkgs 追従(覆蓋層)
- 内蔵版本(手動確認，例：`comfyui-strix-halo`)

残外部軟件包自動対象。

## 使用

「更新」「軟件包版本更新」依頼起動。
