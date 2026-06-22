# ruyi-nixos-compat

[中文](../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](../ja/ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | 偽中国語

提供 ruyi NixOS 実行時互換性：予編訳 RISC-V 道具連二進法、期待動的連結器経路 `/lib64/ld-linux-x86-64.so.2` NixOS 存在不、故其儘実行不可。本上乗透過的処理此問題。

## 適用範囲

ruyi 経由 RISC-V 交叉編訳道具連（GCC、QEMU 等）之下載・実行 NixOS 利用者必要。RISC-V 開発非関与利用者、有効化不要。

## 追加

```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 単独上乗
];
```

## 機能

- **動的連結器 redirect**：二進法埋込 FHS 経路 NixOS `ld.so` 置換
- **道具連子過程修復**：GCC 内部之 `cc1`、`as`、`collect2` 等子過程 `patchelf` 以自動修復
- **Nix console_scripts 互換**：`RUYI_ARGV0` 以 `exec -a` 動作回復

## 設計

最小限侵襲性：修正、NixOS 環境検出、且予編訳道具連 `execv` 将行時限 ruyi 内部作動。NixOS 以外環境、修正論理完全短絡。

## 検証

```bash
# nixos_compat 部品 loaded 確認
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```
