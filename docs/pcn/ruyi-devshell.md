# ruyi (devShell)

[中文](../zh/ruyi-devshell.md) | [English](../en/ruyi-devshell.md) | [日本語](../ja/ruyi-devshell.md)  | 偽中国語

RuyiSDK 包管理開発環境（安定 / β / α 三通道利用可能）：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#ruyi        # 安定
nix develop nixkits#ruyi-beta   # β
nix develop nixkits#ruyi-alpha  # α
```

## 主要命令

```bash
ruyi update           # 局所包索引更新
ruyi list             # 利用可能包一覧
ruyi install <pkg>    # 軟件包導入
ruyi extract <pkg>   # 包内容 取得 解凍（引数 package atom、file path 非。root 不要）
ruyi venv -t gnu-plct gnu-plct ./myvenv  # venv 作成：-t <toolchain> <profile> <dest>
ruyi device provision # RISC-V 装置仮想環境作成
```

> `ruyi venv` 三 全部 必須（`-t` toolchain 指定、`profile` 與 `dest` 位置引数）。又 `profile` 本地索引 存在 必要、故 初回 先 `ruyi update` 実行。

版詳細 [ruyi 軟件包文書参照](../zh/ruyi.md)。