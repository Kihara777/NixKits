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
ruyi update           # 更新包管理器
ruyi list             # 列出可用包
ruyi install <pkg>    # 安装指定包
ruyi extract <file>  # 解压 RISC-V AppImage（无需 root）
ruyi venv <name>      # 用对应 RISC-V toolchain 创建 Python virtualenv
ruyi device provision # 为 RISC-V 设备配置环境
```

版本详情见 [ruyi 软件包文档](../zh/ruyi.md)。