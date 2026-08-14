# dsh

中文 | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Node.js 应用（CLI） |
| 上游 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版本 | `0.1.0-rc.6` |
| 许可 | MIT |
| 命令 | `dsh` |

## 安装

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.dsh ];
```

## 使用

```bash
dsh --help
dsh web   # 启动浏览器 UI
```
