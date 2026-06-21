# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/obs-bilibili-stream.md)

OBS Studio の Bilibili ﾗｲﾌﾞ ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ。

## 基本ｼﾞｮｳﾎｳ

| ｺｳﾓｸ | ｱﾀｲ |
|------|-----|
| ﾊﾞｰｼﾞｮﾝ | 2.1.0 |
| ｱｯﾌﾟｽﾄﾘｰﾑ | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| ﾌﾟﾗｯﾄﾌｫｰﾑ | Linux only |

## ｻﾝｼｮｳ

**推奨：NixOS ﾓｼﾞｭｰﾙ**

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

## ｷｬｯｼｭ

`cachix use nixkits`（flake ﾊ `nixConfig` ﾃﾞ 自動宣言、flake input 使用時 ﾆ 自動案内）。
