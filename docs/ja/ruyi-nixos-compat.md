# ruyi-nixos-compat

[中文](../../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | [偽中国語](../pcn/ruyi-nixos-compat.md)

ruyi に NixOS ランタイム互換性を提供します：プリコンパイルされた RISC-V ツールチェーンバイナリは、期待する動的リンカパス `/lib64/ld-linux-x86-64.so.2` が NixOS に存在しないため、そのままでは実行できません。この overlay はパッチを通じてこの問題を透過的に処理します。

## 適用範囲

ruyi 経由で RISC-V クロスコンパイルツールチェーン（GCC、QEMU 等）をダウンロード・実行する NixOS ユーザーに必要です。RISC-V 開発に関わらないユーザーは有効化する必要はありません。

## 追加

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # 単独 overlay
];
```

## 機能

- **動的リンカリダイレクト**：バイナリに埋め込まれた FHS パスを NixOS の `ld.so` に置換
- **ツールチェーンサブプロセス修復**：GCC 内部の `cc1`、`as`、`collect2` 等のサブプロセスを `patchelf` で自動修復
- **Nix console_scripts 互換**：`RUYI_ARGV0` で `exec -a` の動作を回復

## 設計

最小限の侵襲性：パッチは NixOS 環境が検出され、プリコンパイルツールチェーンが `execv` されようとしている場合にのみ ruyi 内部で作動します。NixOS 以外の環境ではパッチロジックは完全に短絡されます。

## 検証

```bash
# nixos_compat モジュールがロードされているか確認
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
