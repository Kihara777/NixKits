# ruyi-nixos-compat

[中文](../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](../ja/ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | 偽中国語

ruyi NixOS 実行時互換性提供： RISC-V 道具、期待動的 `/lib64/ld-linux-x86-64.so.2` NixOS 存在、之実行。之 overlay 通之問題透過的処理。

## 適用範囲

ruyi 経由 RISC-V 道具（GCC、QEMU 等）実行 NixOS 必要。RISC-V 開発関有効化必要。

## 追加

```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 単独 overlay
];
```

## 機能

- **動的**：埋込 FHS NixOS 之 `ld.so` 置換
- **道具修復**：GCC 内部之 `cc1`、`as`、`collect2` 等之 `patchelf` 自動修復
- **Nix console_scripts 互換**：`RUYI_ARGV0` `exec -a` 之動作回復

## 設計

最小限之侵襲性： NixOS 環境検出、道具 `execv` 場合之 ruyi 内部作動。NixOS 以外之環境完全短絡。

## 検証

```bash
# nixos_compat モジュールがロードされているか確認
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
