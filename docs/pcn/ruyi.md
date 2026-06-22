# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | 偽中国語

[RuyiSDK](https://ruyisdk.org) 包管理者。RISC-V 開発環境道具連導入、仮想環境管理、機器配備、包倉庫操作提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.51.0-alpha.20260616 |
| 上流 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 許諾 | Apache 2.0 |
| 注意 | 初期段階軟体、API 変更可能性有 |

## Dev Shell

```bash
nix develop nixkits#ruyi             # nixkits flake input 追加済場合
nix develop github:Kihara777/NixKits#ruyi  # 事前設定不要単発
```

`$PATH` `ruyi` 追加環境入。

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# 又上乗経由
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 使用法

```bash
ruyi --help
ruyi list --all          # 利用可能全包表示
ruyi install <pkg>       # 道具連導入
ruyi venv --toolchain <t> # 仮想環境作成
ruyi device provision    # 機器配備
```

> ruyi 包索引（`packages-index`）複製網絡接続必要。初回 `ruyi list` 時自動実行。

## 部品

NixOS 部品以 ruyi 実行時設定宣言的構成：

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

`/etc/xdg/ruyi/config.toml` 自動生成、環境変数設定、更体系活性化時包索引自動更新。

宣言的仮想環境支援：

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits ruyi 構築 `patches/ruyi-nixos-compat.patch` 包含、NixOS 固有問題透過的処理：

- **動的連結路**：予編集 RISC-V 道具連二進（GCC、QEMU 等）`/lib64/ld-linux-x86-64.so.2` 期待、NixOS 存在非。修正 NixOS `ld.so` 経由実行転送。
- **道具連子工程修復**：GCC 内部 `cc1`、`as`、`collect2` 等子工程 ruyi mux 迂回。修正 `patchelf` 以 ELF interpreter 自動修復。
- **Nix console_scripts 互換**：`RUYI_ARGV0` 環境変数以 Nix 包装器喪失 `exec -a` 動作回復。

## 注意

- [ISCAS](https://www.iscas.ac.cn) RISC-V 開発者向保守
- 実行時依存（curl、gnutar、git、patchelf 等）wrapProgram 以注入
- 試験覆域：ruff lint、mypy 型確認、pytest 単体（320）、統合（52）— 全通過

## 緩衝

`cachix use nixkits`（flake `nixConfig` 以自動宣言、flake input 使用時自動案内）。
