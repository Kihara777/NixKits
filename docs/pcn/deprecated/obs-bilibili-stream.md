# obs-bilibili-stream 自前 package（廃止済）

[中文](../../zh/deprecated/obs-bilibili-stream.md) | [English](../../en/deprecated/obs-bilibili-stream.md) | [日本語](../../ja/deprecated/obs-bilibili-stream.md)  | 偽中国語

[← 廃止工程索引](../../../DEPRECATED.md)

**状態**：廃止（2026-10-19）
**旧位置**：`packages/obs-bilibili-stream.nix` + `.github/workflows/build-obs-bilibili-stream-{x86_64,aarch64}.yml`
**現状**：package 定義 與 二 build workflow 削除済；`modules/obs-bilibili-stream.nix` 保持、上流 package 参照 変更；overlay 同名 互換別名 保持。

### 我等 貢献 package 上流 収録：2026-10-19、[NixOS/nixpkgs#574725](https://github.com/NixOS/nixpkgs/pull/574725) 併合。

## 曾 何 解決

NixKits 2026-10-10 obs-bilibili-stream（OBS Bilibili 配信拡張）初 打包、本倉 利用者
overlay / module 経由 導入 可能。二 workflow x86_64 與 aarch64 成果物 build、
Cachix cache push。

## 為何 廃止 可能

上流 nixpkgs 本 package 収録済、且 **其定義 此処 貢献、review 改良 物**：

| 項 | 本倉 旧版 | 上流 併合版 |
|---|---|---|
| `strictDeps` / `__structuredAttrs` | 無 | 有 |
| CMake flag | 手書文字列（`-DOBS_SOURCE=` 含） | `lib.cmakeBool` |
| `platforms` | `lib.platforms.linux` 硬書 | `inherit (obs-studio.meta) platforms` |
| `maintainers` | `[ ]` | `[ kitsunori ]` |

local copy 保守継続 上流 乖離 唯。上流版 aarch64-linux 亦 `nixpkgs-review`
`1 package built` 検証済。

## 廃止後 設定方法

**NixOS module（本倉 保持、内部 上流 package 参照 変更済）**

```nix
{
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**nixpkgs 直接 使用**

```nix
{
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
  };
}
```

**互換別名**：`pkgs.obs-bilibili-stream`（overlay）與
`nixkits.packages.<system>.obs-bilibili-stream` 引続 利用可能、同一 上流 package 指。

## 記録 値 一 判断

廃止時点 本倉 版 既 **上流 遅**（`__structuredAttrs` 等 欠）。
先 local copy 「同期」後 廃止 無駄作業。**判据「上流版 我等 版 覆 有」、
「我等 版 今 build 可能」非** —— build 可能 古 copy 也 廃止 当然。
