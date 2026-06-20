# codewhale

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md) | [ｶﾀﾘｯｼｭ](../katalish/codewhale.md) | 偽中国語

DeepSeek V4 専用終端編碼代理。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 0.8.62 |
| 上游 | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| 類型 | 構建済(GitHub Releases) |

## 安裝

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.codewhale ];

# デフォルト overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## 使方

```bash
codewhale                              # 対話型 TUI
codewhale "explain this function"      # ワンショットプロンプト
codewhale --model auto "fix this bug"  # 自動モデル選択
codewhale --yolo                       # 自動承認モード
codewhale doctor                       # セットアップ確認
codewhale auth set --provider deepseek # API キー保存
```

初回実行時 [DeepSeek API ](https://platform.deepseek.com/api_keys) 必要。
