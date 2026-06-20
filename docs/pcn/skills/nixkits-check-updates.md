# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](nixkits-check-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-check-updates.md) | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> NixKits 全軟件包補丁上流更新版本文檔同期自動適用

## 基本情報

|項目|値|
|------|-----|
||Coding Agent Skill|
||`skills/nixkits-check-updates/SKILL.md`|

## 機能

- `flake.nix` 全外部軟件包自動検出最新 GitHub Release
- 構建設定版本source hashnpmDepsHash更新
- 3 言語文檔版本番号同期
- 更新後 `write-maintenance-log` 技能自動呼出維護記録作成
- 安裝版本報告
- 補丁文件内代碼版本識別確認手順提供

## hash 注意点

- SRI hash 標準 base64`+` `/` `=`使用URL-safe 変種`-` `_`不可
- `fetchFromGitHub` source hash GitHub archive tarball **事前計算** — `nix build` hash mismatch 取得必要
- `npmDepsHash` 空場合空文字列 `""` `lib.fakeHash` 使用
- npm 軟件包 2 回 `nix build` 必要：1 回目 source hash2 回目 npmDepsHash

## 範囲

`flake.nix` → `packages` 動的読取以下除外：
- 軟件包倉庫内
- 動的版本追跡構建時最新取得
- nixpkgs 追従補丁覆蓋層
- 補丁内蔵版本手動確認例：`comfyui-strix-halo`

残外部軟件包自動対象

## 使用

更新軟件包版本更新依頼起動