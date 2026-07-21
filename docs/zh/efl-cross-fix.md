# efl-cross-fix

中文 | [English](../en/efl-cross-fix.md) | [日本語](../ja/efl-cross-fix.md)  | [偽中国語](../pcn/efl-cross-fix.md)

修复 `efl`（Enlightenment Foundation Libraries）在交叉编译时因缺少原生代码生成工具导致的构建失败。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 nixpkgs `enlightenment.efl` |
| 上游 | [Enlightenment/efl](https://git.enlightenment.org/enlightenment/efl) |
| overlay | `overlays/efl-cross-fix.nix` |
| 影响范围 | `pkgsCross.{riscv64,riscv64-musl,aarch64}.enlightenment.efl` |
| 注意 | overlay 无独立 package 输出，不进入二进制缓存 |

## 修正内容

- **代码生成器注入**：在交叉编译的 `efl` 构建前，将宿主编译的原生 `efl` 的 `bin/` 复制到构建目录并加入 `PATH`，使 meson 能找到 `eolian_gen`、`eet` 等原生工具
- **多架构支持**：覆盖 `riscv64`、`riscv64-musl`、`aarch64` 三种目标架构
- **依赖链自动受益**：通过 `pkgsCross` 交叉编译、依赖 `efl` 的包（如 `fastfetch`）自动生效

## 安装

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.efl-cross-fix ];
}
```

## 缓存

补丁均为 overlay，修改上游 nixpkgs 包而非独立构建，不在二进制缓存中。