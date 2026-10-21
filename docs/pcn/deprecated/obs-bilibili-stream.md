# obs-bilibili-stream 自前 package（廃止済）

[中文](../../zh/deprecated/obs-bilibili-stream.md) | [English](../../en/deprecated/obs-bilibili-stream.md) | [日本語](../../ja/deprecated/obs-bilibili-stream.md)  | 偽中国語

[← 廃止工程索引](../../../DEPRECATED.md)

**状態**：廃止（2026-10-21）
**旧位置**：`packages/obs-bilibili-stream.nix` + `.github/workflows/build-obs-bilibili-stream-{x86_64,aarch64}.yml`
**現状**：package 定義 與 二 build workflow 削除；flake 別名 `pkgs.obs-studio-plugins.obs-bilibili-stream` 指；overlay 行 削除；`nixkits.obs-bilibili-stream` module 残、上流集合 参照。

## 曾 何 解決

NixKits OBS Studio 向 Bilibili 配信 plugin 自前 package 化、二 workflow x86_64 /
aarch64 成果物 build、Cachix push。

## 為何 廃止 可能

本倉 定義 上流 投稿：

- **PR #574725**（`obs-bilibili-stream: init at 2.1.5` 與 maintainer 条目）、
  **2026-10-19 04:38Z merge**、merge commit `4f4b7322`；
- **2026-10-20** `nixos-unstable` 到達（branch head `02c087f3`）。

| 項 | 本倉（旧） | nixpkgs |
|---|---|---|
| 版本 | 2.1.5 | 2.1.5 |
| 属性 | `pkgs.obs-bilibili-stream` | `pkgs.obs-studio-plugins.obs-bilibili-stream` |
| 定義 | `packages/obs-bilibili-stream.nix` | `pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix` |
| maintainer | `Kihara777`（本倉） | `Kihara777`（上流 maintainers 条目） |

## 廃止後 設定方法

```nix
programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
```

或 本倉 別名（等価）：`inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream`。

## 一 判据

判据「PR merge 済」非、**`nixos-unstable` 上 該 file 実在**。merge（10-19）→ channel
（10-20）一日 要、channel 自体 停止 —— 10-17 〜 10-20 動 無。判据 成果物層 置、参照層
置 無。本倉 実際 消費 branch 置、master 置 無。
