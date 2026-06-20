# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md) | [ｶﾀﾘｯｼｭ](../katalish/obs-bilibili-stream.md) | 偽中国語

OBS Studio 用 Bilibili ライブ配信プラグイン。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 2.1.0 |
| アップストリーム | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| プラットフォーム | Linux  |

## インストール

**推奨: NixOS モジュール**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
  imports = [ inputs.nix-kits.nixosModules.obs-bilibili-stream ];
}
```

**手動**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-bilibili-stream ];
  };
}
```

**Home Manager**

```nix
home.packages = [ inputs.nix-kits.packages.${pkgs.system}.obs-bilibili-stream ];
```
