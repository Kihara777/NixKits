# kitsfmt

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-kitsfmt-x86_64.yml?branch=main&label=x86_64%20v0.5.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-kitsfmt-aarch64.yml?branch=main&label=aarch64%20v0.5.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-kitsfmt-riscv64.yml?branch=main&label=riscv64%20v0.5.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/kitsfmt.md) | [English](../en/kitsfmt.md) | [日本語](../ja/kitsfmt.md)  | 偽中国語

**Nix 整形器** — rnix AST 基盤、属性整序・注釈保持・字下正規化。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.5.0 |
| 言語 | Rust |
| 源 | 本倉庫 `packages/kitsfmt-src/` |

## 使用法

```bash
kitsfmt file.nix             # stdout 出力
kitsfmt --inplace file.nix   # 上書整形
kitsfmt --check file.nix     # 整形確認
kitsfmt --no-best-practices  # 自動修正無効
kitsfmt file1.nix file2.nix  # 複数書類
```

環境変数: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_STDIN=1`, `KITSFMT_BEST_PRACTICES=0`

## 導入

```nix
# 直接
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.kitsfmt ];

# 既定上乗（推奨）
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.kitsfmt

# nix fmt 整形器
# formatter.${system} = inputs.nixkits.formatter.${system};
# 以後: nix fmt
```

## 機能

- 属性整序（APC `a.b.c` 折畳対応）
- **注釈保持（先行注釈 限定）**：属性／`let` 束縛／list 要素 **直前 行** 注釈、其 節点 與 共 整序 移動。制限 下記 参照
- 冪等整形
- **最善慣行自動修正**（既定有効、`-B` 以無効）:
  - 裸 URL 引用符化（RFC 45）
  - `rec` → `let-in` 変換
  - `with` → `builtins.attrValues` 変換

### 注釈保持 制限

「注釈保持」対象 **節点 直前 先行注釈**：属性／`let` 束縛／list 要素 直前 行 注釈、其 節点 與 共 整序 移動。kitsfmt 0.5.0 実測、**以下 位置 破棄**：

| 注釈位置 | 結果 |
|----------|------|
| 属性／`let` 束縛／list 要素 **直前 行** | 節点 追随 保持 |
| 属性 同行 末尾（**最後 以外**） | **次 属性 上** 移動 |
| **最後** 属性 同行 末尾 | 破棄 |
| 書類 先頭（上位 式 前） | 破棄 |
| 書類 末尾（上位 式 後） | 破棄 |

> 整形前、此等 位置 注釈 再生 不能 情報 含 無 確認、或 何 属性 上 移動。

## 緩衝

`cachix use nixkits`（flake `nixConfig` 以自動宣言、flake input 使用時自動案内）。
