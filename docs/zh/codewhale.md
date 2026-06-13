# codewhale

[中文](codewhale.md) | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md)

DeepSeek V4 专用的终端编码代理（TUI 工具）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.8.59 |
| 上游 | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| 类型 | 预编译二进制（GitHub Releases） |

## 引用

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.codewhale ];

# Default overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## 使用

```bash
codewhale                              # 交互 TUI
codewhale "explain this function"      # 单次提示
codewhale --model auto "fix this bug"  # 自动选择模型
codewhale --yolo                       # 自动批准工具
codewhale doctor                       # 检查配置
codewhale auth set --provider deepseek # 保存 API key
```

首次运行需配置 [DeepSeek API Key](https://platform.deepseek.com/api_keys)。
