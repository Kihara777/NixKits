# mihomo-alpha（覆蓋層）

[ｶﾀﾘｯｼｭ](../katalish/mihomo-alpha.md) | [偽中国語](../pcn/mihomo-alpha.md) | [English](../en/mihomo-alpha.md) | [日本語](../ja/mihomo-alpha.md) | [中文](mihomo-alpha.md)

`nix-kits.overlays.mihomo-alpha` — 追蹤 MetaCubeX/mihomo 的 Prerelease-Alpha 版本。

## 適用對象

需要使用 mihomo 最新 alpha 功能的用戶。

## 功能

- 追蹤 Prerelease-Alpha tag，自動匹配最新 asset
- 使用預編譯二進制，無需額外構建環境
- 覆蓋 nixpkgs 中的 `pkgs.mihomo`

## 註冊

在系統 flake.nix 中添加：

```nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";

  outputs = { self, nixpkgs, nix-kits }:
  {
    nixosConfigurations.「 ホスト 」 = nixpkgs.lib.nixosSystem {
      modules = [
        nix-kits.nixosModules.rog-control-center-fix
        { nixpkgs.overlays = [ nix-kits.overlays.mihomo-alpha ]; }
      ];
    };
  };
}
```

## 注意

- 首次添加覆蓋層後需執行 `nix flake update nix-kits` 以獲取 `mihomo-ver` input
- `mihomo-ver` input 返回 GitHub API JSON，Nix 從中解析 asset URL 和檔案雜湊
- 版本號格式：`alpha-<commit_hash>`（從 asset 檔名中提取）
