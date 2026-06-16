# ruyi

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](ruyi.md)

[RuyiSDK](https://ruyisdk.org) のパッケージマネージャー。RISC-V 開発環境のツールチェーンインストール、仮想環境管理、デバイスプロビジョニング、パッケージリポジトリ操作を提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.51.0-alpha.20260616 |
| アップストリーム | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ライセンス | Apache 2.0 |
| 注意 | アルファ段階のソフトウェア、API 変更の可能性あり |

## インストール

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

# または overlay 経由
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 使い方

```bash
ruyi --help
ruyi list --all          # 利用可能な全パッケージを表示
ruyi install <pkg>       # ツールチェーンをインストール
ruyi venv --toolchain <t> # 仮想環境を作成
ruyi device provision    # デバイスをプロビジョニング
```

> ruyi はパッケージインデックス（`packages-index`）のクローンにネットワーク接続が必要です。初回 `ruyi list` 時に自動で行われます。

## 注意

- [ISCAS](https://www.iscas.ac.cn) が RISC-V 開発者向けにメンテナンス
- ランタイム依存（curl、gnutar、git など）は wrapProgram で注入
- テストカバレッジ：ruff lint、mypy 型チェック、pytest ユニット（277）、統合（52）— すべて通過
