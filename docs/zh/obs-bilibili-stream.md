# obs-bilibili-stream

中文 | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md)  | [偽中国語](../pcn/obs-bilibili-stream.md)

**状态**：已废弃（2026-10-21）—— 本仓的提交已并入上游 nixpkgs，本仓不再自行打包。
详情见[废弃项目说明](deprecated/obs-bilibili-stream.md)。

## 现在怎么用

**从 nixpkgs 的 obs-studio-plugins 集合取**

```nix
programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
```

经本仓的别名等价（`inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream` 指向同一个包）；
`nixkits.obs-bilibili-stream` 模块保留，内部已改为引用上游集合。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 2.1.5（跟随 nixpkgs） |
| 上游 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| nixpkgs 属性 | `obs-studio-plugins.obs-bilibili-stream` |
| 并入时间 | PR #574725，2026-10-19 合并；2026-10-20 进入 `nixos-unstable` |

> OBS Studio 的 Bilibili 直播推流插件。
