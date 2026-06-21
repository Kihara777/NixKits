# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | 日本語 | [ｶﾀﾘｯｼｭ](../katalish/obs-bilibili-stream.md) | [偽中国語](../pcn/obs-bilibili-stream.md)

OBS Studio の Bilibili ライブ配信プラグイン。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 2.1.0 |
| アップストリーム | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| プラットフォーム | Linux only |

## 参照

**推奨：NixOS モジュール**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**手動**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-bilibili-stream ];
  };
}
```

**Home Manager**

```nix
home.packages = [ inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream ];
```
