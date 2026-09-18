# ruyi (devShell)

中文 | [English](../en/ruyi-devshell.md) | [日本語](../ja/ruyi-devshell.md)  | [偽中国語](../pcn/ruyi-devshell.md)

RuyiSDK 包管理器开发环境（stable / beta / alpha 三通道均可用）：

```bash
nix registry add nixkits github:Kihara777/NixKits
nix develop nixkits#ruyi        # stable
nix develop nixkits#ruyi-beta   # beta
nix develop nixkits#ruyi-alpha  # alpha
```

## 主要命令

```bash
ruyi update           # 更新本地包索引
ruyi list             # 列出可用包
ruyi install <pkg>    # 安装软件包
ruyi extract <pkg>   # 取出并解压软件包内容（参数是包名 atom，不是文件路径；无需 root）
ruyi venv -t gnu-plct gnu-plct ./myvenv  # 创建虚拟环境：-t <toolchain> <profile> <dest>
ruyi device provision # 创建 RISC-V 设备虚拟环境
```

> `ruyi venv` 的三个参数缺一不可（`-t` 指定 toolchain、`profile` 与 `dest` 为位置参数）；
> 且 `profile` 须已在本地索引中，故首次使用前先 `ruyi update`。

版本详情见 [ruyi 软件包文档](../zh/ruyi.md)。