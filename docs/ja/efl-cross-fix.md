# efl-cross-fix

[中文](../zh/efl-cross-fix.md) | [English](../en/efl-cross-fix.md) | 日本語  | [偽中国語](../pcn/efl-cross-fix.md)

`efl`（Enlightenment Foundation Libraries）のクロスコンパイル時、ホストアーキテクチャのコード生成ツール不足によるビルド失敗を修正。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | nixpkgs `enlightenment.efl` に追従 |
| 上流 | [Enlightenment/efl](https://git.enlightenment.org/enlightenment/efl) |
| overlay | `overlays/efl-cross-fix.nix` |
| 影響範囲 | `pkgsCross.{riscv64,riscv64-musl,aarch64}.enlightenment.efl` |
| 注意 | overlay は上流パッケージを変更、バイナリキャッシュ非対象 |

## 修正内容

- **コード生成ツール注入**：クロスコンパイル `efl` のビルド前に、ホストコンパイル済みネイティブ `efl` の `bin/` をビルドディレクトリにコピーし `PATH` に追加、meson が `eolian_gen`、`eet` 等のネイティブツールを検出可能に
- **マルチアーキテクチャ対応**：`riscv64`、`riscv64-musl`、`aarch64` の 3 ターゲットをカバー
- **依存チェーン自動適用**：`pkgsCross` 経由で `efl` に依存するパッケージ（例：`fastfetch`）が自動的に恩恵

## インストール

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.efl-cross-fix ];
}
```

## キャッシュ

パッチは overlay であり、上流 nixpkgs パッケージを変更するもので独立したビルドではないため、バイナリキャッシュに含まれない。