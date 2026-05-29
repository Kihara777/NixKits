# kitsfmt

[中文](../zh/kitsfmt.md) | [English](../en/kitsfmt.md) | [日本語](kitsfmt.md)

**Nix フォーマッター** — rnix AST ベース、属性ソート・コメント保持・インデント正規化。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.5.0 |
| 言語 | Rust |
| ソース | 本リポジトリ `packages/kitsfmt-src/` |

## 使い方

```bash
kitsfmt file.nix             # stdout に出力
kitsfmt --inplace file.nix   # 上書きフォーマット
kitsfmt --check file.nix     # フォーマット確認
kitsfmt --no-best-practices  # 自動修正オフ
kitsfmt file1.nix file2.nix  # 複数ファイル
```

環境変数: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

## インストール

```nix
# 直接
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.kitsfmt ];

# デフォルト overlay（推奨）
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];  # → pkgs.kitsfmt

# nix fmt フォーマッターとして
# formatter.${system} = inputs.nix-kits.formatter.${system};
# その後: nix fmt
```

## 機能

- 属性ソート（APC `a.b.c` 折りたたみ対応）
- コメント保持
- 冪等フォーマット
- **ベストプラクティス自動修正**（デフォルト有効、`-B` で無効）:
  - 裸 URL 引用符化（RFC 45）
  - `rec` → `let-in` 変換
  - `with` → `builtins.attrValues` 変換
