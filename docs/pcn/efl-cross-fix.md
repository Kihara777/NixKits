# efl-cross-fix

[中文](../zh/efl-cross-fix.md) | [English](../en/efl-cross-fix.md) | [日本語](../ja/efl-cross-fix.md)  | 偽中国語

`efl`（Enlightenment Foundation Libraries）交叉編集時原生符号生成道具不足構築失敗修正。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | nixpkgs `enlightenment.efl` 追従 |
| 上流 | [Enlightenment/efl](https://git.enlightenment.org/enlightenment/efl) |
| 上乗 | `overlays/efl-cross-fix.nix` |
| 影響範囲 | `pkgsCross.{riscv64,riscv64-musl,aarch64}.enlightenment.efl` |
| 注意 | 上乗上流包変更、二進緩衝非対象 |

## 修正内容

- **符号生成道具注入**：交叉編集 `efl` 構築前、宿主編集済原生 `efl` `bin/` 構築目録複写 `PATH` 追加、meson `eolian_gen` `eet` 等原生道具検出可能化
- **多構造対応**：`riscv64` `riscv64-musl` `aarch64` 三目標構造覆蓋
- **依存鎖自動適用**：`pkgsCross` 経由 `efl` 依存包（例 `fastfetch`）自動受益

## 導入

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.efl-cross-fix ];
}
```

## 緩衝

修正上乗、上流 nixpkgs 包変更独立構築非、二進緩衝未含。