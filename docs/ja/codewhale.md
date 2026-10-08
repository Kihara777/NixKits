# codewhale

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-x86_64.yml?branch=main&label=x86_64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-aarch64.yml?branch=main&label=aarch64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-riscv64.yml?branch=main&label=riscv64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | 日本語  | [偽中国語](../pcn/codewhale.md)

DeepSeek V4 専用のターミナルコーディングエージェント。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.10.1 |
| アップストリーム | [codewhale-hq/Codewhale](https://github.com/codewhale-hq/Codewhale) |
| タイプ | ビルド済みバイナリ（GitHub Releases） |

## インストール

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.codewhale ];

# デフォルト overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

Run without installing:

```bash
nix run github:Kihara777/NixKits#codewhale
```

## 使い方

```bash
codewhale                              # 対話型 TUI
codew                                  # TUI 入口（v0.9.9 から上流で改名、旧 codewhale-tui）
codewhale "explain this function"      # ワンショットプロンプト
codewhale --model auto "fix this bug"  # 自動モデル選択
codewhale --sandbox-mode <tier>        # サンドボックス段階を選択（既定では一切緩めない）
codewhale --approval-policy never      # ツール承認ポリシー：on-request / untrusted / never
codewhale doctor                       # セットアップ確認
codewhale auth set --provider deepseek # API キー保存
```

初回実行時に [DeepSeek API キー](https://platform.deepseek.com/api_keys) が必要です。

> `--sandbox-mode` の有効な値：`read-only`、`workspace-write`、`danger-full-access`、`external-sandbox`（`codewhale --help` で実測。`danger-full-access` はサンドボックスを完全に無効化）。引数名は **`--sandbox-mode`** であり、`--sandbox` ではありません（後者は存在せず拒否されます）。

## sudo の有効化

codewhale v0.10.1 はデフォルトで `sudo` をブロックします。 [codewhale-sudo パッチ文書](codewhale-sudo.md) を参照。

## 既知の問題

> ⚠️ **riscv64 ソースビルド**: 上流が v0.9.8 から riscv64 プリビルドバイナリを削除。NixKits は `rustPlatform.buildRustPackage` でソースからクロスコンパイルして riscv64 を提供。**2026-10-08 実測**：eval + ビルド + **実行**まで検証済み——成果物は RISC-V ELF で、qemu-user/binfmt 経由で `codewhale doctor` が実際に走る。三つのアーキテクチャで CI の `smoke-test` を有効化した（`develop/qemu-smoke-tests/codewhale.sh`、ローカルと CI で同一）。**ビルドが通ることと動くことは別**で、ここで判定するのは後者。

## キャッシュ

`cachix use nixkits`（flake は `nixConfig` で自動宣言、flake input として使用時に自動案内）。

