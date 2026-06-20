# kitsfmt

[中文](../../zh/kitsfmt.md) | [English](../en/kitsfmt.md) | [日本語](../ja/kitsfmt.md) | [Katalish](../katalish/kitsfmt.md) | Pseudo-Chinese

**Nix 格式化器** — rnix AST 属性保持正規化

## 基本情報

|項目|値|
|------|-----|
|版本|0.5.0|
|言語|Rust|
||本倉庫 `packages/kitsfmt-src/`|

## 使方

```bash
kitsfmt file.nix # stdout 出力
kitsfmt --inplace file.nix # 上書格式化
kitsfmt --check file.nix # 格式化確認
kitsfmt --no-best-practices # 自動修正
kitsfmt file1.nix file2.nix # 複数文件
```

環境変数: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

## 安裝

```nix
# 直接
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.kitsfmt ];

# 默認 overlay推奨
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ]; # → pkgs.kitsfmt

# nix fmt 格式化器
# formatter.${system} = inputs.nix-kits.formatter.${system};
# 後: nix fmt
```

## 機能

- 属性APC `a.b.c` 折対応
- 保持
- 冪等格式化
- **自動修正**默認有効`-B` 無効:
  - 裸 URL 引用符化RFC 45
  - `rec` → `let-in` 変換
  - `with` → `builtins.attrValues` 変換