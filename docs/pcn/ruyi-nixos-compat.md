# ruyi-nixos-compat

[中文](../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](../ja/ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | 偽中国語

ruyi  NixOS ランタイム互換性提供：プリコンパイル RISC-V ツールチェーンバイナリ，期待動的リンカパス `/lib64/ld-linux-x86-64.so.2`  NixOS 存在，実行。 overlay パッチ通問題透過的処理。

## 適用範囲

ruyi 経由 RISC-V クロスコンパイルツールチェーン(GCC，QEMU 等)ダウンロード・実行 NixOS ユーザー必要。RISC-V 開発関ユーザー有効化必要。

## 追加

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # 単独 overlay
];
```

## 機能

- **動的リンカリダイレクト**：バイナリ埋込 FHS パス NixOS  `ld.so` 置換
- **ツールチェーンサブプロセス修復**：GCC 内部 `cc1`，`as`，`collect2` 等サブプロセス `patchelf` 自動修復
- **Nix console_scripts 互換**：`RUYI_ARGV0`  `exec -a` 動作回復

## 設計

最小限侵襲性：パッチ NixOS 環境検出，プリコンパイルツールチェーン `execv` 場合 ruyi 内部作動。NixOS 以外環境パッチロジック完全短絡。

## 検証

```bash
# nixos_compat モジュールロード確認
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
