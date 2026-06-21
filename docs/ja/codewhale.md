# codewhale

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | 日本語 | [ｶﾀﾘｯｼｭ](../katalish/codewhale.md) | [偽中国語](../pcn/codewhale.md)

DeepSeek V4 専用のターミナルコーディングエージェント。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.8.62 |
| アップストリーム | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| タイプ | ビルド済みバイナリ（GitHub Releases） |

## インストール

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.codewhale ];

# デフォルト overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## 使い方

```bash
codewhale                              # 対話型 TUI
codewhale "explain this function"      # ワンショットプロンプト
codewhale --model auto "fix this bug"  # 自動モデル選択
codewhale --yolo                       # 自動承認モード
codewhale doctor                       # セットアップ確認
codewhale auth set --provider deepseek # API キー保存
```

初回実行時に [DeepSeek API キー](https://platform.deepseek.com/api_keys) が必要です。

## キャッシュ

`cachix use nixkits`（flake は `nixConfig` で自動宣言、flake input として使用時に自動案内）。
