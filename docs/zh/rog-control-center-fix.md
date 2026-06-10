# rog-control-center-fix

[中文](rog-control-center-fix.md) | [English](../en/rog-control-center-fix.md) | [日本語](../ja/rog-control-center-fix.md)

修复 asusd 关机时 `asus-shutdown.service` 的死锁问题。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 nixpkgs |
| 类型 | NixOS 模块 |
| 路径 | `modules/rog-control-center-fix.nix` |
| 触发条件 | `services.asusd.enable = true` |

## 修正内容

- **移除 PartOf 依赖**：将 `asus-shutdown.service` 的 `PartOf` 设为空列表，防止 asusd 停止时连带停止导致死锁

## 安装

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```
