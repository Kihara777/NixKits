# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | 偽中国語

[RuyiSDK](https://ruyisdk.org) 包管理者。使用 RISC-V 開発環境道具鎖導入、仮想環境管理、機器配備、包倉庫操作。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.51.0-alpha.20260616 |
| 上流 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 許諾 | Apache 2.0 |
| 注意 | 段階軟体、API 変更可能性有 |

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# 上乗経由
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 使用方法

```bash
ruyi --help
ruyi list --all          # 全利用可能包一覧表示
ruyi install <pkg>       # 道具鎖導入
ruyi venv --toolchain <t> # 仮想環境作成
ruyi device provision    # 機器配備
```

> ruyi 必要網絡接続、包倉庫（`packages-index`）複製之為。初回 `ruyi list` 実行時自動取得。

## 部品

宣言的設定 ruyi 実行時動作：

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

部品自動生成 `/etc/xdg/ruyi/config.toml`、設定環境変数、体系活性化時自動更新包倉庫索引。

支援宣言的仮想環境：

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits 包版包含上乗 `ruyi-nixos-compat`（`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`）、透過的処理 NixOS 上実行時非互換性：

**追加**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 独立上乗
];
```

**機能**
- **動的転送**：構築済 RISC-V 道具鎖二進期待 `/lib64/ld-linux-x86-64.so.2`、NixOS 不存在該。修正自動的転送実行、NixOS `ld.so` 介。
- **GCC 工程修正**：`cc1`、`as`、`collect2` 等工程迂回 ruyi mux、修正 `patchelf` 修正 ELF 解釈器。
- **Nix console_scripts 互換性**：`RUYI_ARGV0` 環境変数復元 `exec -a` 意味論、Nix 包装失。

**検証**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> 此上乗 NixOS 限定有効。非 NixOS 環境修正論理完全短絡、不干渉他配布。使用 ruyi 取得実行 RISC-V 交叉編集道具鎖利用者必須。

## 注意事項

- 上流 [ISCAS](https://www.iscas.ac.cn) 維持 RISC-V 開発者道具
- 二進 wrapProgram 経由注入実行時依存（curl、gnutar、git、patchelf）
- 試験被覆：ruff lint、mypy 型確認、pytest 単位試験（320 項目）、統合試験（52 項目）——全通過

## 緩衝

`cachix use nixkits`（flake `nixConfig` 自動宣言済、flake input 使用時自動提示）。
