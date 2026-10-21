# nix-packaging (Skill)

[中文](../../zh/skills/nix-packaging.md) | [English](../../en/skills/nix-packaging.md) | 日本語  | [偽中国語](../../pcn/skills/nix-packaging.md)

> 上流ソフトウェアをゼロから Nix 式としてパッケージ化する。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| パス | `skills/nix-packaging/SKILL.md` |
| 対象 | 「このソフトにはまだパッケージが無い」最初の一歩 |

## 四層の受入

| 層 | 判据 | 罠 |
|---|---|---|
| 評価 | `nix eval` が期待のバージョンを返す | 評価できてもビルドできるとは限らない |
| ビルド | ログに `building` が出る（全キャッシュでない） | キャッシュ命中 = 一行もビルドしていない |
| 成果物 | `$out/bin` が空でない | 空 bin = 無駄なビルド |
| 実行 | `--help` の終了コードが 0 | node の wrapper 欠如はここで初めて出る |

## 扱う範囲

- 来源別の分岐（GitHub ソース / npm / Rust / プリビルド / Gitea / PyPI）
- hash の二段階取得（`lib.fakeHash` → `got:` を読む → 埋める → **再ビルドで受入**）
- vendored lock の生成（npm、`--legacy-peer-deps` は罠）
- wrapper が必要なとき
- 本リポジトリの約束（`__structuredAttrs` とクロスコンパイルの衝突）と実測の罠六件

## 扱わない範囲

- 既存パッケージのバージョン更新 → `nix-flake-update-check`
- 上流への投稿 → `upstream-audit`
