# kitsfmt

[中文](../zh/kitsfmt.md) | [English](../en/kitsfmt.md) | [日本語](../ja/kitsfmt.md) | [ｶﾀﾘｯｼｭ](../katalish/kitsfmt.md) | 偽中国語

**Nix ** — rnix AST ，属性・保持・正規化。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 0.5.0 |
| 言語 | Rust |
| | 本倉庫 `packages/kitsfmt-src/` |

## 使方

```bash
kitsfmt file.nix             # stdout に出力
kitsfmt --inplace file.nix   # 上書きフォーマット
kitsfmt --check file.nix     # フォーマット確認
kitsfmt --no-best-practices  # 自動修正オフ
kitsfmt file1.nix file2.nix  # 複数ファイル
```

環境変数: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

## 安裝

```nix
# 直接
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.kitsfmt ];

# デフォルト overlay（推奨）
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.kitsfmt

# nix fmt フォーマッターとして
# formatter.${system} = inputs.nixkits.formatter.${system};
# その後: nix fmt
```

## 功能

- 属性(APC `a.b.c` 折対応)
- 保持
- 冪等
- **自動修復**(默認有効，`-B` 無効):
 - 裸 URL 引用符化(RFC 45)
 - `rec` → `let-in` 変換
 - `with` → `builtins.attrValues` 変換

## 緩存

`cachix use nixkits`（flake 已自 `nixConfig` 自動宣言、直以 flake input 使用時自動提示）。
