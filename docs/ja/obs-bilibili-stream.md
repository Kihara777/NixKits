# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | 日本語  | [偽中国語](../pcn/obs-bilibili-stream.md)

**状態**：廃止（2026-10-21）—— 本リポジトリの投稿が上流 nixpkgs に取り込まれたため、自前ビルドを終了した。
詳細は[廃止プロジェクトの説明](deprecated/obs-bilibili-stream.md)。

## 現在の使い方

**nixpkgs の obs-studio-plugins 集合から取る**

```nix
programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
```

本リポジトリの別名は等価（`inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream` は同じパッケージを指す）。
`nixkits.obs-bilibili-stream` モジュールは残り、内部は上流集合を参照する。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 2.1.5（nixpkgs に追従） |
| 上流 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| nixpkgs 属性 | `obs-studio-plugins.obs-bilibili-stream` |
| 取り込み | PR #574725、2026-10-19 マージ；2026-10-20 に `nixos-unstable` へ |

> OBS Studio 向け Bilibili 配信プラグイン。
