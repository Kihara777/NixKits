# opencode-telegram

[中文](../../zh/opencode-telegram.md) | [English](../en/opencode-telegram.md) | [日本語](../ja/opencode-telegram.md) | [Katalish](../katalish/opencode-telegram.md) | 偽中国語

[OpenCode](https://opencode.ai) Telegram Bot 客户端

## 基本情報

|項目|値|
|------|-----|
|版本|0.21.2|
||[grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot)|

## 使方

```bash
# 初回
opencode serve # opencode 服務器起動
opencode-telegram config # 対話型 Telegram Bot 設定

# 日常使用
opencode-telegram start # 起動opencode 自動起動
opencode-telegram status # 状態確認
opencode-telegram stop # 停止
```

## 安裝

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.opencode-telegram ];

# 默認 overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## Flake 模塊

```nix
# flake.nix
{
inputs.nix-kits.url = "github:Kihara777/NixKits";

outputs = { nixpkgs, nix-kits, ... }: {
nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
modules = [
nix-kits.nixosModules.opencode-telegram
{
services.opencode-telegram = {
enable = true;
user = "kix";
group = "users";
afterServices = [ "network-online.target" "llama-cpp.service" ];
};
}
];
};
};
}
```