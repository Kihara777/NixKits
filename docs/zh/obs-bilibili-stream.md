# obs-bilibili-stream

中文 | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md)  | [偽中国語](../pcn/obs-bilibili-stream.md)

**状态**：已废弃（2026-10-19）—— 上游 nixpkgs 已收录，本仓不再自行打包。
详情见[废弃项目说明](deprecated/obs-bilibili-stream.md)。

## 现在怎么用

**NixOS 模块（本仓仍提供，内部引用上游包）**

```nix
{
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**直接用 nixpkgs**

```nix
{
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
  };
}
```

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 2.1.5（跟随 nixpkgs） |
| 上游 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| nixpkgs 属性 | `obs-studio-plugins.obs-bilibili-stream` |
| 我们的贡献 | [NixOS/nixpkgs#574725](https://github.com/NixOS/nixpkgs/pull/574725)（2026-10-19 合并） |
| 平台 | x86_64 / aarch64（riscv64 不支持：`obs-studio` 的 `meta.platforms` 不含它） |

> ⚠️ **仅用 `home.packages` 装包不会让 OBS 加载它**：OBS 通过 `OBS_PLUGINS_PATH`
> 查找插件，而该变量只由 nixpkgs 的 `wrapOBS`（即 `programs.obs-studio.plugins`）
> 注入。`home.packages` 只是把 `.so` 放进 profile，OBS 不会扫描该路径。因此：
>
> - **NixOS 上**用上面的模块或 `programs.obs-studio.plugins`（推荐）
> - **非 NixOS / 仅 Home Manager** 时，需要自行确保 OBS 的插件搜索路径包含
>   `.../lib/obs-plugins`（例如用 `wrapOBS` 包装，或手动放置 `.so`）
