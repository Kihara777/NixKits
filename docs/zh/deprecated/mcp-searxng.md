# mcp-searxng 自建包（已废弃）

中文 | [English](../../en/deprecated/mcp-searxng.md) | [日本語](../../ja/deprecated/mcp-searxng.md)  | [偽中国語](../../pcn/deprecated/mcp-searxng.md)

[← 废弃项目索引](../../../DEPRECATED.md)

**状态**：已废弃（2026-10-20）
**原位置**：`packages/mcp-searxng.nix` + `.github/workflows/build-mcp-searxng-{x86_64,aarch64,riscv64}.yml`
**现状**：包定义与三个构建工作流已删除；flake 与 devshell 改指向 nixpkgs 的同名属性；overlay 那一行直接移除（nixpkgs 已提供，保留会自引用）。

## 它曾解决什么

NixKits 自行打包 mcp-searxng（SearXNG 的 MCP Server），并用三个 workflow 构建
x86_64 / aarch64 / riscv64 产物推入 Cachix 缓存。

## 为何可以废弃

上游 nixpkgs **2026-08-29** 就收录了它（`init at 2.1.0`），2026-10-13 更新到 **2.6.0**。
现在两边版本与两个 hash **完全相同**：

| 项 | 本仓（旧） | nixpkgs |
|---|---|---|
| 版本 | 2.6.0 | 2.6.0 |
| src hash | `sha256-dbxJSS…` | 相同 |
| npmDepsHash | `sha256-+df6o…` | 相同 |
| `__structuredAttrs` / `strictDeps` | 有 | 有 |
| wrapper | 手动 `makeWrapper` | 无（`buildNpmPackage` 默认处理） |

nixpkgs 版更简洁，且 `mcp-searxng --help` 实测可用。

## 废弃后如何配置

```nix
environment.systemPackages = [ pkgs.mcp-searxng ];
```

或经本仓别名（等价）：`inputs.nixkits.packages.${pkgs.system}.mcp-searxng`。

## 一条判据

退役前我验证的是**命令能不能跑**（`mcp-searxng --help`），不是「版本号相同」——
nixpkgs 版没有我们那个手动 wrapper，两个定义不等价，「版本一样」推不出「行为一样」。
