# nix-flake-update-check (Skill)

[中文](../../zh/skills/nix-flake-update-check.md) | [English](../../en/skills/nix-flake-update-check.md) | 日本語  | [偽中国語](../../pcn/skills/nix-flake-update-check.md)

> **任意の nix flake リポジトリ**におけるパッケージの上流更新を確認してアップグレードする——ビルダー別 hash フロー、flake.lock の扱い、パッチ内蔵バージョン確認、nixpkgs ドリフトの罠。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/nix-flake-update-check/SKILL.md` |
| 位置づけ | **汎用**（特定リポジトリに非結合） |
| 相棒 | リポジトリ固有の工程は適応層スキルが補完（NixKits は `nixkits-check-updates`） |

## 機能

- `flake.nix` から外部パッケージを**動的に検出**し、セルフホスト / 動的バージョン / nixpkgs 追従 / パッチ内蔵を除外
- **ビルダー別**の hash 更新フロー（npm / cmake / Rust `buildRustPackage` / `fetchurl` / python）
- **Dependabot の自動 PR の扱い**：npm の更新 PR は `npmDepsHash` を bot が認識できないため必ず CI が失敗する。ブランチを取得して hash を補う手順と、「対象バージョンが `next` / `alpha` チャネルより遅れていないか」の確認を含む
- hash の罠：SRI 形式、`fetchFromGitHub` と archive tarball の不一致、`lib.fakeHash`、npm の 2 回ビルド
- Rust パッケージは **`Cargo.lock` の同期**が必要（最も漏れやすい）
- `flake.lock` の三者分岐：gitignore 済み → スキップ；動的バージョンあり → 除外必須；その他 → hash と共にコミット
- `.patch` ファイル内にハードコードされたバージョン（version / url / hash）の識別と更新フロー
- nixpkgs ドリフトの罠：`inputs.*.follows`、`doInstallCheck`、`pythonRuntimeDepsCheckHook`、引数なし `nix flake lock`

## 設計：なぜ二つのスキルに分割したか

本スキルは旧名 `nixkits-check-updates` で、NixKits リポジトリと強く結合していた（四言語ドキュメントパスのハードコード、dsh プラグイン一覧、メンテナンスログスキル）。そのため他の nix flake リポジトリでは**そのままでは使えなかった**。

「汎用コア + リポジトリ適応層」に分割した結果：

- 汎用手法（本スキル）は任意の nix flake リポジトリで直接再利用できる
- NixKits 固有の経験（事故教訓、ドキュメント規約）は適応層に残り、**移植性のために薄める必要がない**

## 適応層の契約

本スキルは「変更の記録」までをカバーする。リポジトリ固有の工程は適応層が補完する。適応層は以下を説明すべき：

| 工程 | 適応層が述べるべき内容 |
|------|----------------------|
| ドキュメント同期 | ドキュメントパス、言語一覧、同期すべき特殊セクション |
| 変更記録 | そのリポジトリが使う記録スキルまたはファイル |
| 動的バージョン入力 | ロック不可の浮動 input があるか |
| 既知の事故教訓 | 過去に更新起因で発生した障害と回避策 |
| 追加同期項目 | 内蔵一覧、生成ファイルなど |

衝突する場合は**適応層を優先**する。

## 使用

ユーザーが「更新をチェック」または「パッケージバージョンを更新」と依頼したときに起動。
現在のリポジトリに適応層スキルがある場合は、先に適応層をロードしてから本スキルを実行する。
