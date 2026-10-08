# codewhale

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-x86_64.yml?branch=main&label=x86_64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-aarch64.yml?branch=main&label=aarch64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-riscv64.yml?branch=main&label=riscv64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md)  | 偽中国語

DeepSeek V4 専用端末符号化代理。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.10.1 |
| 上流 | [codewhale-hq/Codewhale](https://github.com/codewhale-hq/Codewhale) |
| 種別 | 構築済二進（GitHub Releases） |

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.codewhale ];

# 既定上乗 → pkgs.codewhale
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

Run without installing:

```bash
nix run github:Kihara777/NixKits#codewhale
```

## 使用法

```bash
codewhale                              # 対話型 TUI
codew                                  # TUI 入口（v0.9.9 起上流改名、旧 codewhale-tui）
codewhale "explain this function"      # 単発指示
codewhale --model auto "fix this bug"  # 自動模型選択
codewhale --sandbox-mode <tier>        # sandbox 段階 選択（既定 一切 緩 不）
codewhale --approval-policy never      # 道具承認方針：on-request / untrusted / never
codewhale doctor                       # 準備確認
codewhale auth set --provider deepseek # API 鍵保存
```

初回実行時 [DeepSeek API 鍵](https://platform.deepseek.com/api_keys) 必要。

> `--sandbox-mode` 有効値：`read-only`、`workspace-write`、`danger-full-access`、`external-sandbox`（`codewhale --help` 実測。`danger-full-access` 沙箱 完全 無効化）。引数名 **`--sandbox-mode`**、`--sandbox` 非（後者 存在 不、拒否 等）。

## sudo 有効化

codewhale v0.10.1 既定 `sudo` 遮断。 [codewhale-sudo 補丁文書](codewhale-sudo.md) 参照。

## 既知問題

> ⚠️ **riscv64 源構築**: 上流 v0.9.8 以降 riscv64 予構築二進削除。NixKits `rustPlatform.buildRustPackage` 経由 源 交叉編輯 提供。**2026-10-08 実測**：eval + 構築 + **実行** 迄 検証済——成果物 RISC-V ELF、qemu-user/binfmt 経由 `codewhale doctor` 実走。三 架構 CI `smoke-test` 有効化（`develop/qemu-smoke-tests/codewhale.sh`、local 與 CI 同一）。**構築 通過 與 動作 別**、此処 判定 後者。

## 緩衝

`cachix use nixkits`（flake `nixConfig` 以自動宣言、flake input 使用時自動案内）。

