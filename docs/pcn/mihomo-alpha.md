# mihomo-alpha

[中文](../zh/mihomo-alpha.md) | [English](../en/mihomo-alpha.md) | [日本語](mihomo-alpha.md) | [ｶﾀﾘｯｼｭ](../katalish/mihomo-alpha.md) | [偽中国語](../pcn/mihomo-alpha.md)

> Prerelease-Alpha 追跡版工具— MetaCubeX/mihomo Prerelease-Alpha 發佈覆蓋層登録NixOS 模塊利用可能

## 基本情報

|項目|値|
|------|-----|
|種類|覆蓋層|
|覆蓋層|`nix-kits.overlays.mihomo-alpha`|
|軟件包名|`mihomo`|
|上流|[MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo)|
|追跡版本|Prerelease-Alpha|

## 安裝

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

- MetaCubeX/mihomo Prerelease-Alpha 最新發佈追跡
- 構建済 Linux amd64 使用
- `pkgs.mihomo` 版本上書

## 注意

- llama-cpp-rocm 同更新：`nix flake update` 後再構建
- Prerelease-Alpha ；版本識別