# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-check-updates.md) | 偽中国語

> NixKits 全包之上流更新チェック、自動アップグレド・アップグレド・文書同期、修正之メンテナンスログ記録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| パス | `skills/nixkits-check-updates/SKILL.md` |

## 機能

- `flake.nix` 全外部包自動検出最新 GitHub Release チェック
- 構築設定（版、source hash、npmDepsHash）更新
- 全言語之文書之版番号同期
- 更新後 `write-maintenance-log` スキル自動呼出、メンテナンス記録作成
- ロカルロカル導入ロカルインストル版報告
- パッチパッチ書類内之ハドコドハドコド版識別確認手順提供

## hash 之注意点

- SRI hash 標準 base64（`+` `/` `=`）使用、URL-safe 変種（`-` `_`）不可
- `fetchFromGitHub` 之 source hash GitHub archive tarball **事前計算** — `nix build` 之 hash mismatch エラ取得必要
- `npmDepsHash` 空場合空文字列 `""` `lib.fakeHash` 使用
- npm 包 2 回之 `nix build` 必要：1 回目 source hash、2 回目 npmDepsHash

## チェック範囲

`flake.nix` → `packages` 動的読取、以下除外：
- セルフホストセルフホスト包（倉庫内ソス）
- 動的版追跡（構築時最新取得）
- nixpkgs 追従（パッチパッチ上乗）
- パッチ内蔵版（手動確認、例：`comfyui-strix-halo`）

残之外部包自動チェック対象。

## 使用

ユザ「更新チェック」「包パッケジ版更新」依頼起動。
