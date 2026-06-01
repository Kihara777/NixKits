# rcc-fix

[中文](rcc-fix.md) | [English](../en/rcc-fix.md) | [日本語](../ja/rcc-fix.md)

修补 `asusctl`，改善 ASUS ROG Control Center 在二合一设备上的体验。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 nixpkgs `asusctl` |
| 上游 | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| 补丁 | 本仓库 `patches/rog-control-center-fix.patch` |
| 注意 | 此包以 overlay 形式替换 `pkgs.asusctl`，无独立 package 输出 |

## 修复内容

- **键盘断开 UI**：`visible` 属性控制显示/隐藏，键盘未连接时主界面隐藏，显示多语言提示覆盖层
- **热插拔恢复**：键盘重新连接后每 5 秒轮询，自动恢复 Aura 界面（无需重启）
- **数组边界检查**：PowerZone 索引越界保护，处理固件报告无效区域的情况

## 引用

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-fix ];

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
