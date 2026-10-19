# obs-bilibili-stream 自建包（已废弃）

中文 | [English](../../en/deprecated/obs-bilibili-stream.md) | [日本語](../../ja/deprecated/obs-bilibili-stream.md)  | [偽中国語](../../pcn/deprecated/obs-bilibili-stream.md)

[← 废弃项目索引](../../../DEPRECATED.md)

**状态**：已废弃（2026-10-19）
**原位置**：`packages/obs-bilibili-stream.nix` + `.github/workflows/build-obs-bilibili-stream-{x86_64,aarch64}.yml`
**现状**：包定义与两个构建工作流已删除；`modules/obs-bilibili-stream.nix` 保留，改为引用上游包；overlay 保留同名兼容别名。

### 我们贡献的包已被上游收录：2026-10-19，[NixOS/nixpkgs#574725](https://github.com/NixOS/nixpkgs/pull/574725) 合并。

## 它曾解决什么

NixKits 在 2026-10-10 首次打包 obs-bilibili-stream（OBS 的 Bilibili 直播插件），
让本仓用户通过 overlay / 模块安装，并由两个 workflow 构建 x86_64 与 aarch64
产物、推入 Cachix 缓存。

## 为何可以废弃

上游 nixpkgs 已收录该包，而且**那份定义就是从这里贡献出去、再经 review 改进的版本**：

| 项 | 本仓旧版 | 上游合并版 |
|---|---|---|
| `strictDeps` / `__structuredAttrs` | 无 | 有 |
| CMake 标志 | 手写字符串（含 `-DOBS_SOURCE=`） | `lib.cmakeBool` |
| `platforms` | 硬写 `lib.platforms.linux` | `inherit (obs-studio.meta) platforms` |
| `maintainers` | `[ ]` | `[ kitsunori ]` |

继续维护本地副本只会与上游漂移。上游版本在 aarch64-linux 上也已由
`nixpkgs-review` 验证为 `1 package built`。

## 废弃后如何配置

**NixOS 模块（本仓保留，内部已改为引用上游包）**

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

**兼容别名**：`pkgs.obs-bilibili-stream`（overlay）与
`nixkits.packages.<system>.obs-bilibili-stream` 仍然可用，指向同一个上游包。

## 一次值得记的判断

退役时本仓版本已经**落后于上游**（缺 `__structuredAttrs` 等）。
如果当时先「同步」本仓副本再退役，会白做一遍。**判据是「上游版本是否已覆盖我们的版本」，
不是「我们的版本是否还能构建」**——能构建的旧副本仍然该退。
