---
name: nixkits-check-updates
description: 检查 NixKits 所有软件包的上游版本更新并自动应用。检测新版本、更新构建配置（版本号、hash、meta）、更新文档、报告本地安装版本。
---

# NixKits 软件包更新检查

检查 NixKits 各软件包的上游发布更新，执行版本升级，并更新文档。

## 排除的软件包

以下**不检查**（无固定上游发布版本）：

- 自建软件包（源码为 `./kitsfmt-src` 或类似目录）
- 动态版本追踪（如 `llama-cpp-rocm` — 构建时获取最新版）
- 跟随 nixpkgs 版本（如 `rcc-fix` — 跟随 nixpkgs 版本号）

`flake.nix` → `packages` 中的其余所有包均需检查。

## 第 1 步：确认本地 NixKits 仓库

```bash
test -f flake.nix && grep -q "NixKits" flake.nix && echo "OK: NixKits repo" || echo "ERROR: not in NixKits repo"
```

## 第 2 步：发现待检查的软件包

读取 `flake.nix` 的 packages 段，找出所有外部包：

```bash
# 提取使用 fetchFromGitHub 或 fetchurl 的包名
grep -B1 "fetchFromGitHub\|fetchurl" flake.nix packages/*.nix | grep -oP '(?<=packages\.)\w+|(?<=pkgs\.callPackage \./packages/)\w+'
```

排除已知的自建/动态/nixpkgs 包。剩余的包需要检查。

## 第 3 步：检查上游版本

对每个发现的外部包，从其 `.nix` 文件确定上游仓库，然后比对：

```bash
check() {
  local pkg="$1" current="$2" repo="$3"
  latest=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -oP '"tag_name":\s*"\K[^"]+')
  if [ "$current" != "$latest" ]; then
    echo "UPDATE: $pkg  $current → $latest"
  else
    echo "OK: $pkg  $current"
  fi
}
```

## 第 4 步：更新构建配置

对每个有更新的包：

### npm 包

1. 更新 `.nix` 文件中的 `version` 字符串
2. 将 `fetchFromGitHub` 的 `hash` 置为空占位符
3. 将 `npmDepsHash` 置为空占位符
4. 运行 `nix build .#<pkg>` 两次 — 第一次获取源码 hash，第二次获取 npmDepsHash
5. 用实际值更新两个 hash

### cmake 包

1. 更新 `version` 字符串
2. 将 `fetchFromGitHub` 的 `hash` 置空
3. 运行 `nix build .#<pkg>` 获取正确的 hash
4. 更新 hash

### 预编译二进制包（fetchurl）

1. 更新 `version` 字符串及所有下载 URL
2. 将所有 `hash` 值置空
3. 运行 `nix build .#<pkg>` 获取各二进制 hash
4. 逐一更新 hash

## 第 5 步：更新文档

对每个更新的包，在三种语言文档中更新版本号：

```bash
for lang in zh en ja; do
  sed -i "s/$OLD_VER/$NEW_VER/g" docs/$lang/<pkg>.md
done
```

同时检查并更新 `.nix` 文件中的 `meta.changelog` URL。

## 第 6 步：检查本地安装版本

```bash
nix eval --raw .#<pkg>.version 2>/dev/null
which <binary> 2>/dev/null && <binary> --version 2>/dev/null
```

## 第 7 步：输出汇总报告

以表格呈现：包名、旧版本 → 新版本、构建状态、本地安装版本。
