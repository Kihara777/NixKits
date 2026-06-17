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

## Dev Shell

```bash
nix develop nix-kits#ruyi             # nix-kits を flake input に追加済みの場合
nix develop github:Kihara777/NixKits#ruyi  # 事前設定不要のワンショット
```

`$PATH` に `ruyi` が追加された環境に入ります。

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

## モジュール

NixOS モジュールで ruyi のランタイム設定を宣言的に構成：

```nix
# flake.nix
{ modules = [ nix-kits.nixosModules.ruyi ]; }

services.ruyi = {
  enable = true;
  settings = {
    packages.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.mode = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

`/etc/xdg/ruyi/config.toml` を自動生成し、環境変数を設定、さらにシステムアクティベーション時にパッケージインデックスを自動更新します。

宣言的仮想環境もサポート：

```nix
services.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## 注意

- [ISCAS](https://www.iscas.ac.cn) が RISC-V 開発者向けにメンテナンス
- ランタイム依存（curl、gnutar、git など）は wrapProgram で注入
- テストカバレッジ：ruff lint、mypy 型チェック、pytest ユニット（277）、統合（52）— すべて通過
