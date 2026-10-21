# obs-bilibili-stream 自前パッケージ（廃止済み）

[中文](../../zh/deprecated/obs-bilibili-stream.md) | [English](../../en/deprecated/obs-bilibili-stream.md) | 日本語  | [偽中国語](../../pcn/deprecated/obs-bilibili-stream.md)

[← 廃止プロジェクト索引](../../../DEPRECATED.md)

**状態**：廃止（2026-10-21）
**旧位置**：`packages/obs-bilibili-stream.nix` + `.github/workflows/build-obs-bilibili-stream-{x86_64,aarch64}.yml`
**現状**：パッケージ定義と二つのビルドワークフローを削除；flake の別名は `pkgs.obs-studio-plugins.obs-bilibili-stream` を指す；overlay の行は削除；`nixkits.obs-bilibili-stream` モジュールは残り、上流集合を参照する。

## かつて何を解決していたか

NixKits が OBS Studio 向け Bilibili 配信プラグインを自前でパッケージ化し、二つの
ワークフローで x86_64 / aarch64 の成果物をビルドして Cachix に push していた。

## なぜ廃止できるか

本リポジトリがその定義を上流へ投稿した：

- **PR #574725**（`obs-bilibili-stream: init at 2.1.5` と maintainer 条目）、
  **2026-10-19 04:38Z マージ**、merge commit `4f4b7322`；
- **2026-10-20** に `nixos-unstable` へ（ブランチ head `02c087f3`）。

| 項目 | 本リポジトリ（旧） | nixpkgs |
|---|---|---|
| バージョン | 2.1.5 | 2.1.5 |
| 属性 | `pkgs.obs-bilibili-stream` | `pkgs.obs-studio-plugins.obs-bilibili-stream` |
| 定義 | `packages/obs-bilibili-stream.nix` | `pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix` |
| メンテナ | `Kihara777`（本リポジトリ） | `Kihara777`（上流 maintainers 条目） |

## 廃止後の設定方法

```nix
programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
```

または本リポジトリの別名（等価）：`inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream`。

## 一つの判据

判据は「PR がマージされた」ではなく、**`nixos-unstable` 上にそのファイルが実在すること**。
マージ（10-19）からチャネル（10-20）まで一日かかり、チャネル自体も止まる —— 10-17 から
10-20 まで動かなかった。判据は成果物層に置き、参照層に置かない。本リポジトリが実際に
消費するブランチに置き、master に置かない。
