# rcc-fix

修补 `asusctl`，改善 ASUS ROG Control Center 在二合一设备上的体验。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 nixpkgs `asusctl` |
| 上游 | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| 补丁 | 本仓库 `patches/rog-control-center-fix.patch` |
| 注意 | 此包以 overlay 形式替换 `pkgs.asusctl`，无独立 package 输出 |

## 修复内容

- **键盘连接检测**：二合一设备重启后键盘未连接时，禁用 Aura 控制页并显示友好提示
- **数组边界检查**：PowerZone 索引越界保护，防止崩溃
- **提示信息**：多语言友好的键盘未连接提示

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
