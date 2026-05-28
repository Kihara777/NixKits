# rcc-fix

修补 `asusctl`，改善 ASUS ROG Control Center 在二合一设备上的体验。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 nixpkgs `asusctl` |
| 上游 | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| 补丁 | 本仓库 `patches/rog-control-center-fix.patch` |

## 修复内容

- 键盘连接检测
- Aura 灯光控制数组边界检查
- 友好提示信息

## 引用

```nix
nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-fix ];

services.asusctl = {
  enable = true;
  power-profile = true;
  cpu-power-control = true;
};
```

此 overlay 会替换 `pkgs.asusctl` 为带补丁的版本。
