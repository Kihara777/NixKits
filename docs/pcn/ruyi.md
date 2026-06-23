# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | 偽中国語

[RuyiSDK](https://ruyisdk.org) 之包管理者。提供 RISC-V 開発環境之道具導入、仮想環境管理、機器配備、倉庫操作。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.51.0-alpha.20260616 |
| 上流 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 許諾 | Apache 2.0 |
| 注意 | 段階之軟体。API 変更可能性有 |

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# 又 上乗 経由
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 使用方法

```bash
ruyi --help
ruyi list --all          # 一覧表示 利用可能全包
ruyi install <pkg>       # 導入 道具
ruyi venv --toolchain <t> # 作成 仮想環境
ruyi device provision    # 機器配備
```

> ruyi 要 網絡接続 複製 包索引倉庫。初回実行時 `ruyi list` 自動取得。

## 部品

ruyi 実行時動作之宣言的設定:

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

部品 自動生成 `/etc/xdg/ruyi/config.toml`、設定環境変数、更新 包倉庫索引 系統活性化時。

支援 宣言的仮想環境:

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits 構築 包含 `ruyi-nixos-compat` 上乗（`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`）、提供 NixOS 上透過的実行時互換性：

**有効化**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 独立 上乗
];
```

**機能**
- **動的連結器転送**: 事前構築 RISC-V 道具二進 期待 `/lib64/ld-linux-x86-64.so.2`、NixOS 不存在。修正 透過的転送 経由 NixOS `ld.so`。
- **GCC 副工程修正**: `cc1`、`as`、`collect2` 等 迂回 ruyi 多重化、修正 `patchelf` 以 ELF 接続修正。
- **Nix console_scripts 互換**: `RUYI_ARGV0` 環境変数 復元 Nix 包装器喪失 `exec -a` 意味。

**検証**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> 此上乗 有効 限 NixOS。他配布版 修正論理 完全短絡。必須 ruyi 経由取得実行 RISC-V 交叉編集道具之使用者。

## 注意

- [ISCAS](https://www.iscas.ac.cn) 維持 RISC-V 開発者道具
- 実行時依存（curl、gnutar、git、patchelf）注入 以 wrapProgram
- 試験網羅: ruff 整形確認、mypy 種別確認、pytest 単体（320 件）、統合（52 件）— 全通過

## 緩衝

`cachix use nixkits`（flake input 使用時 `nixConfig` 以自動宣言）。
