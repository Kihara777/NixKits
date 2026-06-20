# mihomo-alpha

[中文](mihomo-alpha.md) | [English](../en/mihomo-alpha.md) | [日本語](../ja/mihomo-alpha.md) | [ｶﾀﾘｯｼｭ](../katalish/mihomo-alpha.md) | [偽中国語](../pcn/mihomo-alpha.md)

> Prerelease-Alpha 追踪版（代理工具）——对上游 MetaCubeX/mihomo 的 Prerelease-Alpha 版本进行覆盖层注册，以便 NixOS 模块使用。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | 覆盖层 |
| 覆盖层路径 | `nix-kits.overlays.mihomo-alpha` |
| 包名 | `mihomo` |
| 上游 | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) |
| 追踪版本 | Prerelease-Alpha |

## 安装

```nix
# flake.nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nix-kits, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.overlays = [ nix-kits.overlays.mihomo-alpha ]; }
      ];
    };
  };
}
```

## 功能

- 追踪 MetaCubeX/mihomo Prerelease-Alpha 最新 Release
- 使用预构建 Linux amd64 二进制
- 覆盖 `pkgs.mihomo` 版本

## 注意

- 更新方式同 llama-cpp-rocm：`nix flake update` 后重建即可
- Prerelease-Alpha 是持续滚动更新的 tag，版本由 commit hash 确定
