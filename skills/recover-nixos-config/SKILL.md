---
name: recover-nixos-config
description: 当用户误删 /etc/nixos 目录下的文件（flake.nix、flake.lock 等）时，从 Nix store 中恢复。
---

# 恢复误删的 /etc/nixos 文件

当 `/etc/nixos` 下的文件被误删，但 NixOS 系统此前已从该配置成功构建过，
则 flake 源码（包括 flake.nix、flake.lock 及所有本地模块）仍保留在 Nix store 中。
任何构建文件 — flake.nix、flake.lock、boot.nix、system.nix、home.nix 等 — 均可恢复。

## 第 1 步：在 Nix store 中定位 flake 源码

Nix store 中保留了每次成功执行 `nixos-rebuild` 的 flake 源码快照。
按主机名搜索：

```bash
grep -rl '<HOSTNAME>' /nix/store/*-source/flake.nix 2>/dev/null
```

源码目录命名为 `*-source`，包含构建时 `/etc/nixos` 中的全部文件：
- `flake.nix`
- `flake.lock`
- 所有本地 `.nix` 模块（boot.nix、home.nix、system.nix 等）

## 第 2 步：确认最新的 generation

在第 1 步的候选中找出最新 generation 的源码。最新的源码通常具有最大的
store path hash。如不确定，可将各候选的 `flake.nix` 与 `/etc/nixos` 中
尚存的文件对比 — 正确的源码会引用相同的本地模块
（如 `./boot.nix`、`./system.nix`）。

列出所有历史 generation：

```bash
nixos-rebuild list-generations
```

与当前 generation 匹配的源码目录包含构建当前运行系统的配置。

## 第 3 步：验证内容

检查 `flake.nix` 的第一行以确认是正确的配置：

```bash
head -1 /nix/store/<hash>-source/flake.nix
```

列出源码中的所有文件：

```bash
ls /nix/store/<hash>-source/
```

## 第 4 步：恢复已删除的文件

将需要的文件复制回 `/etc/nixos/`。仅恢复丢失的文件：

```bash
cp /nix/store/<hash>-source/<filename> /etc/nixos/<filename>
```

示例 — 仅恢复 flake.nix：

```bash
cp /nix/store/<hash>-source/flake.nix /etc/nixos/flake.nix
```

恢复多个文件：

```bash
cp /nix/store/<hash>-source/flake.nix /etc/nixos/flake.nix
cp /nix/store/<hash>-source/flake.lock /etc/nixos/flake.lock
cp /nix/store/<hash>-source/home.nix   /etc/nixos/home.nix
```

## 第 5 步：验证

```bash
nix flake check /etc/nixos
```
