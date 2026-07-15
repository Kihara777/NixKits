# ruyi

[![ruyi x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-x86_64.yml?branch=main&label=ruyi%20x86_64%20v0.50.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-aarch64.yml?branch=main&label=ruyi%20aarch64%20v0.50.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-riscv64.yml?branch=main&label=ruyi%20riscv64%20v0.50.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-x86_64.yml?branch=main&label=ruyi-beta%20x86_64%20v0.50.0-beta.20260623)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-aarch64.yml?branch=main&label=ruyi-beta%20aarch64%20v0.50.0-beta.20260623)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-riscv64.yml?branch=main&label=ruyi-beta%20riscv64%20v0.50.0-beta.20260623)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-x86_64.yml?branch=main&label=ruyi-alpha%20x86_64%20v0.51.0-alpha.20260616)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-aarch64.yml?branch=main&label=ruyi-alpha%20aarch64%20v0.51.0-alpha.20260616)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-riscv64.yml?branch=main&label=ruyi-alpha%20riscv64%20v0.51.0-alpha.20260616)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)


[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | 日本語 | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | [偽中国語](../pcn/ruyi.md)

[RuyiSDK](https://ruyisdk.org)のパッケージマネージャー。RISC-V開発環境向けのツールチェーンインストール、仮想環境管理、デバイスプロビジョニング、パッケージリポジトリ操作に使用する。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.50.0（安定版） |
| 上流 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ライセンス | Apache 2.0 |
| チャンネル | stable 0.50.0 · beta 0.50.0-beta.20260623 · alpha 0.51.0-alpha.20260616 |

## インストール

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# またはoverlay経由
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## バージョンチャンネル

ruyi は 3 つの独立したパッケージを提供します：

| パッケージ | バージョン | 用途 |
|------|------|------|
| `ruyi` | 0.50.0（安定版）| 本番環境 |
| `ruyi-beta` | 0.50.0-beta.20260623 | プレビュー |
| `ruyi-alpha` | 0.51.0-alpha.20260616 | 先行開発 |

```nix
environment.systemPackages = [
  inputs.nixkits.packages.${pkgs.system}.ruyi-beta
];
```

## 使用方法

```bash
ruyi --help
ruyi list --all          # 利用可能な全パッケージを一覧表示
ruyi install <pkg>       # ツールチェーンをインストール
ruyi venv --toolchain <t> # 仮想環境を作成
ruyi device provision    # デバイスプロビジョニング
```

> ruyiはパッケージリポジトリ（`packages-index`）のクローンにネットワーク接続が必要です。初回の`ruyi list`実行時に自動的にダウンロードされます。

## モジュール

ruyiのランタイム動作を宣言的に設定：

```nix
# flake.nix
{ modules = [ nixkits.nixosModules.ruyi ]; }

nixkits.ruyi = {
  enable = true;
  settings = {
    packages.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.mode = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

モジュールは`/etc/xdg/ruyi/config.toml`を自動生成し、環境変数を設定し、システムアクティベーション時にパッケージリポジトリインデックスを自動更新する。

宣言的仮想環境をサポート：

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS互換性

NixKitsのパッケージバージョンにはoverlay`ruyi-nixos-compat`（`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`）が含まれており、NixOS上でのランタイム非互換性を透過的に処理する：

**追加**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 独立したoverlay
];
```

**機能**
- **動的リンカーリダイレクト**：プリビルドのRISC-Vツールチェーンバイナリは`/lib64/ld-linux-x86-64.so.2`を期待するが、NixOSにはこのパスが存在しない。パッチはNixOSの`ld.so`を介して実行を自動的にリダイレクトする。
- **GCCサブプロセス修正**：`cc1`、`as`、`collect2`などのサブプロセスがruyi muxをバイパスするため、パッチは`patchelf`でELFインタプリタを修正する。
- **Nix console_scripts互換性**：`RUYI_ARGV0`環境変数がNixラッパーで失われた`exec -a`セマンティクスを復元する。

**検証**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> このoverlayはNixOSでのみ有効。非NixOS環境ではパッチロジックが完全に短絡され、他のディストリビューションに干渉しない。ruyiを使用してRISC-Vクロスコンパイルツールチェーンをダウンロード・実行するユーザーに必須。

## 注意事項

- 上流は[ISCAS](https://www.iscas.ac.cn)がメンテナンスするRISC-V開発者ツール
- バイナリにはwrapProgram経由でcurl、gnutar、git、patchelfなどのランタイム依存が注入されている
- テストカバレッジ：ruff lint、mypy型チェック、pytestユニットテスト（320項目）、統合テスト（52項目）——すべて通過

## キャッシュ

`cachix use nixkits`（flakeは`nixConfig`で自動宣言済み。flake input使用時に自動的にプロンプトが表示される）。
