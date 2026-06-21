# kitsfmt

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20kitsfmt%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20kitsfmt%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/kitsfmt.md) | [日本語](../ja/kitsfmt.md) | [ｶﾀﾘｯｼｭ](../katalish/kitsfmt.md) | [偽中国語](../pcn/kitsfmt.md)

**Nix 格式化器** — 基于 rnix AST，支持属性排序、注释保留、缩进规范化。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.5.0 |
| 语言 | Rust |
| 源码 | 本仓库 `packages/kitsfmt-src/` |

## 使用

```bash
kitsfmt file.nix             # 输出到 stdout
kitsfmt --inplace file.nix   # 原地格式化
kitsfmt --check file.nix     # 检查是否已格式化
kitsfmt --no-best-practices  # 关闭自动修正
kitsfmt file1.nix file2.nix  # 多文件
```

环境变量：`KITSFMT_INPLACE=1`、`KITSFMT_CHECK=1`、`KITSFMT_BEST_PRACTICES=0`

## 引用

```nix
# 直接引用
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.kitsfmt ];

# Default overlay (推荐)
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.kitsfmt

# 作为 nix fmt 的 formatter
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
# flake.nix:
#   formatter.${system} = inputs.nixkits.formatter.${system};
# 然后运行: nix fmt
```

## 功能

- 属性排序（含 APC 折叠 `a.b.c`）
- 注释保持
- 幂等格式化
- **Best-Practice 自动修正**（默认开启，`-B` 关闭）：
  - 裸 URL 引号化（RFC 45）：`https://x.com` → `"https://x.com"`
  - `rec` → `let-in`：`rec { a = 1; b = a + 2; }` → `let a=1; b=a+2; in { inherit a b; }`
  - `with` → `builtins.attrValues`：`with pkgs; [ a b ]` → `builtins.attrValues { inherit (pkgs) a b; }`

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。
