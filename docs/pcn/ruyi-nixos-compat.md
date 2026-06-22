# ruyi-nixos-compat

[中文](../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](../ja/ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | 偽中国語

ruyi NixOS 実行時互換性提供：予編集 RISC-V 道具連二進、期待動的連結路 `/lib64/ld-linux-x86-64.so.2` NixOS 存在非、其儘実行不可。本上乗修正通透過的問題処理。

## 適用範囲

ruyi 経由 RISC-V 交叉編集道具連（GCC、QEMU 等） download・実行 NixOS 利用者必要。RISC-V 開発関与非利用者有効化不要。

## 追加

```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 単独上乗
];
```

## 機能

- **動的連結転送**：二進埋込 FHS 路 NixOS `ld.so` 置換
- **道具連子工程修復**：GCC 内部 `cc1`、`as`、`collect2` 等子工程 `patchelf` 以自動修復
- **Nix console_scripts 互換**：`RUYI_ARGV0` 以 `exec -a` 動作回復

## 設計

最小侵襲性：修正 NixOS 環境検出、予編集道具連 `execv` 場合 ruyi 内部動作。NixOS 以外環境修正論理完全短絡。

## 検証

```bash
# nixos_compat 部品積載確認
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```
