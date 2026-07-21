# ruyi (devShell)

[中文](../zh/ruyi-devshell.md) | [English](ruyi-devshell.en.md) | [日本語](ruyi-devshell.ja.md)  | 偽中国語

RuyiSDK 包管理開発環境（安定 / β / α 三通道利用可能）：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#ruyi        # 安定
nix develop nixkits#ruyi-beta   # β
nix develop nixkits#ruyi-alpha  # α
```

## 主要命令

```bash
ruyi update           # 包管理器更新
ruyi list             # 利用可能包一覧
ruyi install <pkg>    # 包導入
ruyi extract <file>  # RISC-V 構築産物解凍
ruyi venv <name>      # Python 仮想環境作成
ruyi device provision # RISC-V 装置環境設定
```

版詳細 [ruyi 軟件包文書参照](../zh/ruyi.md)。