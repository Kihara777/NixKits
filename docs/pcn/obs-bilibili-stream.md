# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md)  | 偽中国語

**状態**：廃止（2026-10-19）—— 上流 nixpkgs 収録済、本倉 自前 build 終了。
詳細 [廃止 project 説明](deprecated/obs-bilibili-stream.md)。

## 現在 使用法

**NixOS module（本倉 提供継続、内部 上流 package 参照）**

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

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 2.1.5（nixpkgs 追従） |
| 上流 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| nixpkgs 属性 | `obs-studio-plugins.obs-bilibili-stream` |
| 貢献 | [NixOS/nixpkgs#574725](https://github.com/NixOS/nixpkgs/pull/574725)（2026-10-19 併合） |
| 平台 | x86_64 / aarch64（riscv64 非対応：`obs-studio` `meta.platforms` 含 無） |

> ⚠️ **`home.packages` 単独 導入 package OBS 読込 無**：OBS `OBS_PLUGINS_PATH`
> 経由 plugin 探索、此変数 nixpkgs `wrapOBS`（即 `programs.obs-studio.plugins`）
> 単独 注入。`home.packages` `.so` profile 配置 単独、OBS 此 path 走査 無。故：
>
> - **NixOS 上** 上記 module 或 `programs.obs-studio.plugins` 使用（推奨）
> - **NixOS 外 / Home Manager 単独** 場合、OBS plugin 探索 path
>   `.../lib/obs-plugins` 含 事 自己確保（`wrapOBS` 包、或 `.so` 手動配置）
