# kitsfmt - 精简的 Nix 配置格式化工具

> 一个基于 nixpkgs-fmt 的 Nix 配置文件格式化工具

kitsfmt 是一个轻量级的 Nix 配置文件格式化工具，使用 nixpkgs-fmt 作为后端引擎，提供与 Nix 社区标准一致的格式化体验。

## 特性

- ✅ **标准格式化** - 使用 nixpkgs-fmt 作为格式化引擎
- ✅ **保留注释** - 格式化过程中保留所有注释
- ✅ **清理空行** - 移除多余的空行
- ✅ **Nix 兼容** - 符合 Nix 社区格式化规范
- ✅ **CLI 工具** - 支持多种命令行选项
- ✅ **Flake 集成** - 可直接作为 Nix flake 使用

## 使用方法

### 基本命令

```bash
# 格式化单个文件并原地修改
kitsfmt file.nix

# 格式化多个文件
kitsfmt file1.nix file2.nix file3.nix

# 从 stdin 读取并输出到 stdout
cat config.nix | kitsfmt

# 检查文件是否已格式化（不修改文件）
kitsfmt --check file.nix

# 显示帮助信息
kitsfmt --help

# 显示版本信息
kitsfmt --version
```

## 格式化规则

kitsfmt 遵循 nixpkgs-fmt 的格式化规则：

| 规则 | 说明 |
|------|------|
| **开括号** | `{` 和 `[` 单独一行，不额外缩进 |
| **闭括号** | `}` 和 `]` 单独一行，与开括号缩进对齐 |
| **属性赋值** | `key = value;` 格式，等号两侧有空格 |
| **注释** | 保留所有 `#`, `//` 和 `/* */` 注释 |
| **空行** | 最多保留一个连续空行 |
| **属性路径** | `services.nginx.enable = true;` 格式 |

## 许可证

MIT License
