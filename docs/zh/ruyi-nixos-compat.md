# ruyi-nixos-compat

[中文](ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](../ja/ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | [偽中国語](../pcn/ruyi-nixos-compat.md)

为 ruyi 提供 NixOS 运行时兼容性：预编译的 RISC-V 工具链二进制文件在 NixOS 上无法直接运行，因为期望的动态链接器路径 `/lib64/ld-linux-x86-64.so.2` 不存在。本 overlay 通过 patch 透明化处理此问题。

## 适用范围

对使用 ruyi 下载并执行 RISC-V 交叉编译工具链（GCC、QEMU 等）的 NixOS 用户必需。不涉及 RISC-V 开发场景的用户无需启用。

## 添加

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # 独立 overlay
];
```

## 功能

- **动态链接器重定向**：以 NixOS 的 `ld.so` 替代二进制文件内嵌的 FHS 路径
- **工具链子进程修复**：GCC 内部启动的 `cc1`、`as`、`collect2` 等子进程自动通过 `patchelf` 修复 ELF interpreter
- **Nix console_scripts 兼容**：通过 `RUYI_ARGV0` 恢复 `exec -a` 语义

## 设计

补丁采用最小侵入策略：仅在 ruyi 内部检测到 NixOS 环境且准备 `execv` 预编译工具链时介入。非 NixOS 环境下补丁逻辑完全短路，不影响其他发行版。

## 验证

```bash
# 检查 nixos_compat 模块是否加载
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
