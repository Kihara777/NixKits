# obs-bilibili-stream

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-x86_64.yml?branch=main&label=x86_64%20v2.1.5)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-aarch64.yml?branch=main&label=aarch64%20v2.1.5)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md)  | [偽中国語](../pcn/obs-bilibili-stream.md)

OBS Studio 的 Bilibili 直播推流插件。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 2.1.5 |
| 上游 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| 平台 | Linux only |

## 引用

**推荐：NixOS 模块**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**手动**

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

> ⚠️ **仅用 `home.packages` 装包不会让 OBS 加载它**：OBS 通过 `OBS_PLUGINS_PATH`
> 查找插件，而该变量只由 nixpkgs 的 `wrapOBS`（即 `programs.obs-studio.plugins`）
> 注入。`home.packages` 只是把 `.so` 放进 profile，OBS 不会扫描该路径。因此：
>
> - **NixOS 上**用上面的模块或 `programs.obs-studio.plugins`（推荐）
> - **非 NixOS / 仅 Home Manager** 时，需要自行确保 OBS 的插件搜索路径包含
>   `.../lib/obs-plugins`（例如用 `wrapOBS` 包装，或手动放置 `.so`）

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。
