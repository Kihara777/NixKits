# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md)  | 偽中国語

**状態**：廃止（2026-10-21）—— 本倉 投稿 上流 nixpkgs 取込 故、自前 build 終了。
詳細 [廃止 project 説明](deprecated/obs-bilibili-stream.md)。

## 現在 使用法

**nixpkgs obs-studio-plugins 集合 取**

```nix
programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
```

本倉 別名 等価（`inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream` 同一 package 指）。
`nixkits.obs-bilibili-stream` module 残、内部 上流集合 参照。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 2.1.5（nixpkgs 追従） |
| 上流 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| nixpkgs 属性 | `obs-studio-plugins.obs-bilibili-stream` |
| 取込 | PR #574725、2026-10-19 merge；2026-10-20 `nixos-unstable` 到達 |

> OBS Studio 向 Bilibili 配信 plugin。
