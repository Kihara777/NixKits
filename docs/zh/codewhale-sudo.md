# codewhale-sudo

中文 | [English](../en/codewhale-sudo.md) | [日本語](../ja/codewhale-sudo.md)  | [偽中国語](../pcn/codewhale-sudo.md)

codewhale v0.9.0 默认启用 `prctl(PR_SET_NO_NEW_PRIVS)` 深度防御，阻止 `sudo` 执行。此补丁通过 `LD_PRELOAD` shim 拦截该 prctl 调用，恢复 sudo 功能。

## 基本信息

| 项目 | 值 |
|------|-----|
| 补丁 | `overlays/codewhale-sudo-fix.nix` |
| 类型 | overlay（覆盖 codewhale 包） |
| 上游 | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |

## 安装

```nix
nixpkgs.overlays = [ inputs.nixkits.overlays.codewhale-sudo-fix ];
```

## 前置条件

codewhale 通过 PTY 执行命令，需要 **免密 sudo** 配置。将用户加入 `wheel` 组并配置 NixOS：

```nix
security.sudo = {
  enable = true;
  wheelNeedsPassword = false;  # wheel 组免密 sudo
};
users.users.your-user = {
  extraGroups = [ "wheel" ];
};
```


## 关注点

- 此补丁降低沙箱安全性，仅建议在需要 `sudo` 的开发环境中启用
- `sudo` 功能依赖正确的 NixOS 用户免密配置，补丁本身不绕过密码验证

## 缓存

补丁为 overlay，不在二进制缓存中。