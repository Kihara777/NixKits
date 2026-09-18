# ruyi (devShell)

[中文](../zh/ruyi-devshell.md) | [English](../en/ruyi-devshell.md) | 日本語  | [偽中国語](../pcn/ruyi-devshell.md)

RuyiSDK パッケージマネージャ開発環境（stable / beta / alpha の 3 チャンネルで利用可能）：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#ruyi        # stable
nix develop nixkits#ruyi-beta   # beta
nix develop nixkits#ruyi-alpha  # alpha
```

## 主要コマンド

```bash
ruyi update           # ローカルパッケージ索引を更新
ruyi list             # 利用可能パッケージ一覧
ruyi install <pkg>    # パッケージのインストール
ruyi extract <pkg>   # パッケージ内容を取得して展開（引数はパッケージ atom でファイルパスではない。root 不要）
ruyi venv -t gnu-plct gnu-plct ./myvenv  # venv 作成：-t <toolchain> <profile> <dest>
ruyi device provision # RISC-V デバイス仮想環境を作成
```

> `ruyi venv` は三つとも必須です（`-t` で toolchain、`profile` と `dest` は位置引数）。また `profile` はローカル索引に存在する必要があるため、初回は先に `ruyi update` を実行してください。

バージョン詳細は [ruyi パッケージ文書](../zh/ruyi.md) を参照。