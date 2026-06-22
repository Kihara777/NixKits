# codewhale

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20codewhale%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20codewhale%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md) | [ｶﾀﾘｯｼｭ](../katalish/codewhale.md) | 偽中国語

DeepSeek V4 専用端末符号化代理。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.8.62 |
| 上流 | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| 種別 | 構築済二進（GitHub Releases） |

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.codewhale ];

# 既定上乗 → pkgs.codewhale
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## 使用法

```bash
codewhale                              # 対話型 TUI
codewhale "explain this function"      # 単発指示
codewhale --model auto "fix this bug"  # 自動模型選択
codewhale --yolo                       # 自動承認模式
codewhale doctor                       # 準備確認
codewhale auth set --provider deepseek # API 鍵保存
```

初回実行時 [DeepSeek API 鍵](https://platform.deepseek.com/api_keys) 必要。

## 緩衝

`cachix use nixkits`（flake `nixConfig` 以自動宣言、flake input 使用時自動案内）。
