# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | 日本語  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— Everything is a Plugin（すべてがプラグイン）。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Node.js アプリ（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| バージョン | `0.1.0-rc.6` |
| ライセンス | MIT |
| コマンド | `dsh` |

## インストール

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.dsh ];
```

## 使い方

```bash
dsh --help
dsh web   # ブラウザ UI を起動
```
