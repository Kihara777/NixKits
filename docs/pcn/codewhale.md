# codewhale

[中文](../../zh/codewhale.md) | [English](../en/codewhale.md) | [日本語](../../ja/codewhale.md) | [ｶﾀﾘｯｼｭ](../../katalish/codewhale.md) | [偽中国語](codewhale.md)

DeepSeek V4 専用

## 基本情報

|項目|値|
|------|-----|
|版本|0.8.60|
||[Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale)|
||構建済GitHub Releases|

## 安裝

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.codewhale ];

# 默認 overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## 使方

```bash
codewhale # 対話型 TUI
codewhale "explain this function" #
codewhale --model auto "fix this bug" # 自動選択
codewhale --yolo # 自動承認
codewhale doctor # 確認
codewhale auth set --provider deepseek # API 保存
```

初回実行時 [DeepSeek API ](https://platform.deepseek.com/api_keys) 必要