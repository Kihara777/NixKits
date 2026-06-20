# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | 偽中国語 | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-check-updates.md) 

> NixKits 全パッケージ上流更新チェック，自動アップグレード・ドキュメント同期，修正メンテナンスログ記録。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/nixkits-check-updates/SKILL.md` |

## 機能

- `flake.nix` 全外部パッケージ自動検出最新 GitHub Release チェック
- ビルド設定(バージョン，source hash，npmDepsHash)更新
- 全言語ドキュメントバージョン番号同期
- 更新後 `write-maintenance-log` スキル自動呼出，メンテナンス記録作成
- ローカルインストールバージョン報告
- パッチファイル内ハードコードバージョン識別確認手順提供

## hash 注意点

- SRI hash 標準 base64(`+` `/` `=`)使用，URL-safe 変種(`-` `_`)不可
- `fetchFromGitHub`  source hash  GitHub archive tarball **事前計算** — `nix build`  hash mismatch エラー取得必要
- `npmDepsHash` 空場合空文字列 `""`  `lib.fakeHash` 使用
- npm パッケージ 2 回 `nix build` 必要：1 回目 source hash，2 回目 npmDepsHash

## チェック範囲

`flake.nix` → `packages` 動的読取，以下除外：
- セルフホストパッケージ(リポジトリ内ソース)
- 動的バージョン追跡(ビルド時最新取得)
- nixpkgs 追従(パッチオーバーレイ)
- パッチ内蔵バージョン(手動確認，例：`comfyui-strix-halo`)

残外部パッケージ自動チェック対象。

## 使用

ユーザー「更新チェック」「パッケージバージョン更新」依頼起動。
