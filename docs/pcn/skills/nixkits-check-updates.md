# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-check-updates.md) | 偽中国語

> NixKits 全包之上流更新、自動文書同期、修正之記録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| | `skills/nixkits-check-updates/SKILL.md` |

## 機能

- `flake.nix` 全外部包自動検出最新 GitHub Release 
- 構築設定（版、source hash、npmDepsHash）更新
- 全言語之文書之版番号同期
- 更新後 `write-maintenance-log` 自動呼出、記録作成
- 導入版報告
- 書類内之版識別確認手順提供

## hash 之注意点

- SRI hash 標準 base64（`+` `/` `=`）使用、URL-safe 変種（`-` `_`）不可
- `fetchFromGitHub` 之 source hash GitHub archive tarball **事前計算** — `nix build` 之 hash mismatch 取得必要
- `npmDepsHash` 空場合空文字列 `""` `lib.fakeHash` 使用
- npm 包 2 回之 `nix build` 必要：1 回目 source hash、2 回目 npmDepsHash

## 範囲

`flake.nix` → `packages` 動的読取、以下除外：
- 包（倉庫内）
- 動的版追跡（構築時最新取得）
- nixpkgs 追従（上乗）
- 内蔵版（手動確認、例：`comfyui-strix-halo`）

残之外部包自動対象。

## 使用

「更新」「包版更新」依頼起動。
