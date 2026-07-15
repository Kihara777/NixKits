# rcc-fix

中文 | [English](../en/rcc-fix.md) | [日本語](../ja/rcc-fix.md)  | [偽中国語](../pcn/rcc-fix.md)

修补 `asusctl`，改善 ASUS ROG Control Center 在二合一设备上的体验。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 nixpkgs `asusctl` |
| 上游 | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| 补丁 | 本仓库 `patches/rog-control-center-fix.patch` |
| 模块 | `nixosModules.rog-control-center-fix`（systemd 死锁修复） |
| 注意 | overlay 替换 `pkgs.asusctl`，无独立 package 输出 |

## 修正内容

- **键盘断开 UI**：键盘未连接时显示多语言提示覆盖层，避免崩溃
- **热插拔恢复**：D-Bus 事件驱动，键盘重连后自动恢复 Aura UI
- **数组边界检查**：PowerZone 索引越界保护，过滤固件报告的无效区域
- **systemd 死锁修复**：移除 `asus-shutdown.service` 的 `PartOf` 依赖，防止 asusd 停止时连带死锁

## 安装

overlay（代码补丁）+ NixOS 模块（systemd 修复），推荐组合使用：

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.rcc-fix ];

  imports = [ inputs.nixkits.nixosModules.rog-control-center-fix ];

  nixkits.rog-control-center-fix.enable = true;

  services.asusctl = {
    enable = true;
    power-profile = true;
    cpu-power-control = true;
  };

  programs.rog-control-center = {
    enable = true;
    autoStart = true;
  };
}
```
