# codewhale

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | 偽中国語 | [ｶﾀﾘｯｼｭ](../katalish/codewhale.md) 

DeepSeek V4 専用ターミナルコーディングエージェント。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.8.62 |
| アップストリーム | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| タイプ | ビルド済バイナリ(GitHub Releases) |

## インストール

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

初回実行時 [DeepSeek API キー](https://platform.deepseek.com/api_keys) 必要。
