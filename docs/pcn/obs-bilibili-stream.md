# obs-bilibili-stream

[中文](../../zh/obs-bilibili-stream.md) | [English](../../en/obs-bilibili-stream.md) | 日本語 | [ｶﾀﾘｯｼｭ](../../katalish/obs-bilibili-stream.md) | [偽中国語](../../pcn/obs-bilibili-stream.md)

OBS Studio 用 Bilibili 配信插件

## 基本情報

|項目|値|
|------|-----|
|版本|2.1.0|
||[Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream)|
||Linux|

## 安裝

**推奨: NixOS 模塊**

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