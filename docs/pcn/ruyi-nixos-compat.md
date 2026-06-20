# ruyi-nixos-compat

[中文](../../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | [偽中国語](../pcn/ruyi-nixos-compat.md)

ruyi NixOS 運行時互換性提供： RISC-V 工具期待動的 `/lib64/ld-linux-x86-64.so.2` NixOS 存在実行 overlay 補丁通問題透過的処理

## 適用範囲

ruyi 経由 RISC-V 工具GCCQEMU 等実行 NixOS 必要RISC-V 開発関有効化必要

## 追加

```nix
nixpkgs.overlays = [
nix-kits.overlays.ruyi-nixos-compat # 単独 overlay
];
```

## 功能

- **動的**：埋込 FHS NixOS `ld.so` 置換
- **工具修復**：GCC 内部 `cc1``as``collect2` 等 `patchelf` 自動修復
- **Nix console_scripts 互換**：`RUYI_ARGV0` `exec -a` 動作回復

## 設計

最小限侵襲性：補丁 NixOS 環境検出工具 `execv` 場合 ruyi 内部作動NixOS 以外環境補丁完全短絡

## 検証

```bash
# nixos_compat 模塊確認
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'