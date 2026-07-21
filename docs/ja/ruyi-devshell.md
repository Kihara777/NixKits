# ruyi (devShell)

[中文](../zh/ruyi-devshell.md) | [English](ruyi-devshell.en.md) | 日本語  | [偽中国語](ruyi-devshell.pcn.md)

RuyiSDK パッケージマネージャ開発環境（stable / beta / alpha の 3 チャンネルで利用可能）：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#ruyi        # stable
nix develop nixkits#ruyi-beta   # beta
nix develop nixkits#ruyi-alpha  # alpha
```

## 主要コマンド

```bash
ruyi update           # パッケージマネージャの更新
ruyi list             # 利用可能パッケージ一覧
ruyi install <pkg>    # パッケージのインストール
ruyi extract <file>  # RISC-V AppImage を展開（root 不要）
ruyi venv <name>      # 対応 RISC-V toolchain で Python virtualenv を作成
ruyi device provision # RISC-V デバイス環境のセットアップ
```

バージョン詳細は [ruyi パッケージ文書](../zh/ruyi.md) を参照。