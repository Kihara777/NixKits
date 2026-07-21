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


[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md)  | 偽中国語

[RuyiSDK](https://ruyisdk.org) 包管理者。RISC-V 開発環境向工具鎖導入、仮想環境管理、機器配備、包倉庫操作使用。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.51.0（安定版） |
| 上流 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 許諾 | Apache 2.0 |
| 通道 | stable 0.51.0 · beta 0.51.0-beta.20260714 · alpha 0.52.0-alpha.20260714 |

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# 又上乗経由
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 版通道

ruyi 三独立包提供：

| 包 | 版 | 用途 |
|------|------|------|
| `ruyi` | 0.51.0（安定版）| 本番環境 |
| `ruyi-beta` | 0.50.0-beta.20260623 | 予覧 |
| `ruyi-alpha` | 0.51.0-alpha.20260616 | 先行開発 |

```nix
environment.systemPackages = [
  inputs.nixkits.packages.${pkgs.system}.ruyi-beta
];
```

## 使用方法

```bash
ruyi --help
ruyi list --all          # 利用可能全包一覧表示
ruyi install <pkg>       # 軟件包導入
ruyi venv --toolchain <t> # 指定 toolchain 以 Python virtualenv 作成
ruyi device provision    # 機器仮想環境作成
```

> ruyi 包倉庫（`packages-index`）複製連接必要。初回 `ruyi list` 実行時自動取得。

## 部品

ruyi 実行時動作宣言的設定：

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

部品 `/etc/xdg/ruyi/config.toml` 自動生成、環境変数設定、体系起動時包倉庫索引自動更新。

宣言的仮想環境支援：

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "~/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits 包版上乗 `ruyi-nixos-compat`（`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`）含、NixOS 上実行時非互換性透過処理：

**追加**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 独立上乗
];
```

**機能**
- **動的連結器転送**：予構築 RISC-V 工具鎖二進 `/lib64/ld-linux-x86-64.so.2` 期待、NixOS 当経路不存在。修正 NixOS `ld.so` 介実行自動転送。
- **GCC 副工程修正**：`cc1`、`as`、`collect2` 等副工程 ruyi mux 迂回、修正 `patchelf` ELF 解釈修正。
- **Nix console_scripts 互換性**：`RUYI_ARGV0` 環境変数 Nix 包装失 `exec -a` 意味復元。

**検証**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> 当上乗 NixOS 限定有効。非 NixOS 環境修正論理完全短絡、他配布干渉不可。ruyi 使用 RISC-V 交叉編集工具鎖取得・実行利用者必須。

## 注意事項

- 上流 [ISCAS](https://www.iscas.ac.cn) 保守 RISC-V 開発者道具
- 二進 wrapProgram 経由 curl、gnutar、git、patchelf 等実行時依存注入済
- 試験覆蓋：ruff lint、mypy 型確認、pytest 単体試験（320項目）、統合試験（52項目）——全通過

## 緩衝

`cachix use nixkits`（flake `nixConfig` 自動宣言済。flake input 使用時自動案内表示）。