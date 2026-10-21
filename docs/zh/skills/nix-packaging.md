# nix-packaging (Skill)

中文 | [English](../../en/skills/nix-packaging.md) | [日本語](../../ja/skills/nix-packaging.md)  | [偽中国語](../../pcn/skills/nix-packaging.md)

> 从零把一个上游软件打包成 Nix 表达式。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nix-packaging/SKILL.md` |
| 适用 | 「这个软件还没有包」的第一步 |

## 四层验收

| 层 | 判据 | 骗局 |
|---|---|---|
| 求值 | `nix eval` 得到预期版本 | 求值过 ≠ 能构建 |
| 构建 | 日志里有 `building`，不是全缓存 | 缓存命中 = 一行没构建 |
| 产物 | `$out/bin` 非空 | 空 bin = 白构建 |
| 运行 | `--help` 退出码 0 | node 无 wrapper 在这一层才暴露 |

## 覆盖什么

- 按来源分流（GitHub 源码 / npm / Rust / 预编译二进制 / Gitea / PyPI）
- hash 两段式（`lib.fakeHash` → 读 `got:` → 回填 → **再构建验收**）
- vendored lock 的生成（npm，`--legacy-peer-deps` 是陷阱）
- wrapper 何时需要
- 本仓约定（`__structuredAttrs` 与交叉编译冲突）与六条实测陷阱

## 不覆盖

- 已有包的版本更新 → `nix-flake-update-check`
- 提交上游 → `upstream-audit`
