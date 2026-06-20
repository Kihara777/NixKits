# mihomo-alpha

[中文](../zh/mihomo-alpha.md) | [English](../en/mihomo-alpha.md) | [日本語](mihomo-alpha.md) | [ｶﾀﾘｯｼｭ](../katalish/mihomo-alpha.md) | [偽中国語](../pcn/mihomo-alpha.md)

> Prerelease-Alpha 追跡版（プロキシツール）— MetaCubeX/mihomo の Prerelease-Alpha リリースをオーバーレイ登録し、NixOS モジュールで利用可能に。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種類 | オーバーレイ |
| オーバーレイパス | `nix-kits.overlays.mihomo-alpha` |
| パッケージ名 | `mihomo` |
| 上流 | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) |
| 追跡バージョン | Prerelease-Alpha |

## インストール

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

## 機能

- MetaCubeX/mihomo Prerelease-Alpha の最新リリースを追跡
- ビルド済み Linux amd64 バイナリを使用
- `pkgs.mihomo` のバージョンを上書き

## 注意

- llama-cpp-rocm と同じ更新フロー：`nix flake update` 後に再ビルド
- Prerelease-Alpha はローリングタグ；バージョンはコミットハッシュで識別
