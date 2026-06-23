# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | 日本語 | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | [偽中国語](../pcn/ruyi.md)

[RuyiSDK](https://ruyisdk.org) のパッケージマネージャー。RISC-V 開発環境のツールチェーンインストール、仮想環境管理、デバイスプロビジョニング、リポジトリ操作を提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.51.0-alpha.20260616 |
| 上流 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ライセンス | Apache 2.0 |
| 注意 | アルファ段階のソフトウェア。API は変更される可能性があります |

## インストール

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# または overlay 経由
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

> ruyi はパッケージインデックスリポジトリのクローンにネットワーク接続が必要です。初回実行時に `ruyi list` が自動的にダウンロードします。

## モジュール

ruyi ランタイム動作の宣言的設定:

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

モジュールは自動的に `/etc/xdg/ruyi/config.toml` を生成し、環境変数を設定し、システムアクティベーション時にパッケージリポジトリインデックスを更新します。

宣言的仮想環境:

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits ビルドには `ruyi-nixos-compat` overlay（`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`）が含まれており、NixOS 上で透過的なランタイム互換性を提供します：

**有効化**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 独立 overlay
];
```

**機能**
- **動的リンカリダイレクト**: プリビルドの RISC-V ツールチェーンバイナリは `/lib64/ld-linux-x86-64.so.2` を期待しますが、NixOS には存在しません。パッチは NixOS の `ld.so` を介して透過的にリダイレクトします。
- **GCC サブプロセス修正**: `cc1`、`as`、`collect2` などが ruyi mux をバイパスするため、パッチは `patchelf` で ELF interpreter を修正します。
- **Nix console_scripts 互換**: `RUYI_ARGV0` 環境変数が Nix wrapper で失われた `exec -a` セマンティクスを復元します。

**検証**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> この overlay は NixOS でのみ有効にしてください。他のディストリビューションではパッチロジックは完全に短絡します。ruyi 経由で RISC-V クロスコンパイルツールチェーンをダウンロード・実行するユーザーに必須です。

## 注意

- [ISCAS](https://www.iscas.ac.cn) がメンテナンスする RISC-V 開発者ツール
- ランタイム依存（curl、gnutar、git、patchelf）は wrapProgram で注入
- テストカバレッジ: ruff lint、mypy 型チェック、pytest ユニット（320 件）、統合（52 件）— すべて通過

## キャッシュ

`cachix use nixkits`（flake input として使用時に `nixConfig` で自動宣言）。
