# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | 日本語 | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | [偽中国語](../pcn/ruyi.md)

[RuyiSDK](https://ruyisdk.org)のパッケージマネージャー。RISC-V開発環境向けのツールチェーンインストール、仮想環境管理、デバイスプロビジョニング、パッケージリポジトリ操作に使用する。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.51.0-alpha.20260616 |
| 上流 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ライセンス | Apache 2.0 |
| 注意 | アルファ段階のソフトウェアであり、APIが変更される可能性があります |

## インストール

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# またはoverlay経由
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
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
