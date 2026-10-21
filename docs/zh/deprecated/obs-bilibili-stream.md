# obs-bilibili-stream 自建包（已废弃）

中文 | [English](../../en/deprecated/obs-bilibili-stream.md) | [日本語](../../ja/deprecated/obs-bilibili-stream.md)  | [偽中国語](../../pcn/deprecated/obs-bilibili-stream.md)

[← 废弃项目索引](../../../DEPRECATED.md)

**状态**：已废弃（2026-10-21）
**原位置**：`packages/obs-bilibili-stream.nix` + `.github/workflows/build-obs-bilibili-stream-{x86_64,aarch64}.yml`
**现状**：包定义与两个构建工作流已删除；flake 别名指向 `pkgs.obs-studio-plugins.obs-bilibili-stream`；overlay 行移除；`nixkits.obs-bilibili-stream` 模块保留并改为引用上游集合。

## 它曾解决什么

NixKits 自行打包 OBS Studio 的 Bilibili 直播插件，用两个 workflow 构建 x86_64 / aarch64
产物并推入 Cachix。

## 为何可以废弃

本仓把这份定义提交给了上游 nixpkgs：

- **PR #574725**（`obs-bilibili-stream: init at 2.1.5` + 维护者条目），
  **2026-10-19 04:38Z 合并**，merge commit `4f4b7322`；
- **2026-10-20** 进入 `nixos-unstable`（分支 head `02c087f3`）。

| 项 | 本仓（旧） | nixpkgs |
|---|---|---|
| 版本 | 2.1.5 | 2.1.5 |
| 属性 | `pkgs.obs-bilibili-stream` | `pkgs.obs-studio-plugins.obs-bilibili-stream` |
| 定义 | `packages/obs-bilibili-stream.nix` | `pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix` |
| 维护者 | `Kihara777`（本仓） | `Kihara777`（上游 maintainers 条目） |

## 废弃后如何配置

```nix
programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
```

或经本仓别名（等价）：`inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream`。

## 一条判据

退役的判据不是「PR 已合并」，而是 **`nixos-unstable` 上真的有这个文件**。合并（10-19）到
进通道（10-20）隔了一天，而通道本身会卡——它从 10-17 停到 10-20。判据落在产物层，
不落在引用层；判据落在「本仓实际消费的分支」，不落在「master 上有没有」。
