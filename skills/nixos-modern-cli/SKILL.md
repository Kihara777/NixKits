---
name: nixos-modern-cli
description: 在 NixOS 系统上工作时使用。确保正确使用现代 Nix/NixOS CLI、完整的 shell 能力、sudo 权限和正确的系统维护流程。
---

# NixOS 现代 CLI 指南

## 关键认知：NixOS 不是传统 Linux 发行版

NixOS 是一个声明式、不可变的 Linux 发行版。关键区别：

- **没有 `/usr/bin`、`/usr/lib`** — 所有软件位于 Nix store（`/nix/store`）
- **没有 `apt`、`yum`、`pacman`** — 使用 `nix` 命令或编辑 `/etc/nixos/configuration.nix`（或 flake）
- **没有 `/etc/default/grub`、`/etc/fstab`** — 这些由 NixOS 配置生成
- **Shell PATH 默认不含常用工具** — 使用 `nix shell nixpkgs#<pkg>` 获取临时工具
- **`sudo` 正常工作**，`systemctl` 行为与预期一致
- **必须用 `nixos-rebuild`** 应用配置变更

## 第一步：检查 CLI 能力

获取 shell 访问后，验证可用工具：

```bash
# 检查现代 nixos CLI（首选）
nixos --help 2>/dev/null && echo "nixos-cli available"

# 检查 nix-command（优于传统 nix-* 命令）
nix --help 2>/dev/null && echo "nix-command available"
```

## 现代命令 vs 传统命令

始终优先使用现代等位命令：

| 传统命令 | 现代命令（优先） |
|----------|----------------|
| `nixos-rebuild switch` | `nixos rebuild switch`（有 nixos-cli 时）或 `nixos-rebuild switch` |
| `nix-env -iA` | `nix profile install` |
| `nix-shell` | `nix shell` |
| `nix-build` | `nix build` |
| `nix-collect-garbage` | `nix store gc` |
| `nix-store --optimise` | `nix store optimise` |
| `nix-channel --update` | 使用 flake 则不需要 |

如果有 `nixos-cli`（软件包 `nixos-cli`）：
```bash
nixos rebuild switch --flake /etc/nixos
nixos generation delete --all  # 清理旧 generation
nixos store gc                 # 垃圾回收
nixos store optimise           # 优化 store
```

如果只有 `nix-command`：
```bash
sudo nixos-rebuild switch --flake /etc/nixos
nix store gc
nix store optimise
```

## Shell 环境

NixOS 的 shell 环境极简。需要系统 PATH 之外的命令时：

```bash
# 临时 shell，包含所需工具
nix shell nixpkgs#git nixpkgs#ripgrep nixpkgs#curl

# 或进入持久开发 shell
nix develop nixpkgs#<package>
```

### 运行需要 POSIX 工具的脚本

许多 shell 脚本依赖 `grep`、`sed`、`tr`、`head`、`tail`、`python3` 等。
在 NixOS 上这些默认不在 PATH 中。使用 `nix shell` 的 `--command` 标志在齐全的环境中运行脚本：

```bash
# 单条命令，附带所需包
nix shell nixpkgs#python3 nixpkgs#coreutils nixpkgs#gnused \
  nixpkgs#gnugrep nixpkgs#bash --command \
  bash -c 'python3 my_script.py arg1 arg2'

# 复杂多步流程
nix shell nixpkgs#python3 nixpkgs#coreutils nixpkgs#gnused \
  nixpkgs#gnugrep nixpkgs#bash --command bash -c '
cd /path/to/project
python3 install.py 2>&1
ls -la output/
echo "done"
'
```

**Shell 脚本常用包对照：**

| 工具 | 包名 |
|------|------|
| `python3` | `nixpkgs#python3` |
| `grep`、`ls`、`cat`、`head`、`tail`、`wc`、`tr`、`sort`、`mkdir`、`rm`、`find` | `nixpkgs#coreutils` |
| `sed` | `nixpkgs#gnused` |
| `bash`（完整版） | `nixpkgs#bash` |
| `awk` | `nixpkgs#gawk` |
| `git` | `nixpkgs#git` |

## 系统维护

### 检查系统状态
```bash
systemctl status
systemctl --failed
```

### 查看日志
```bash
journalctl -xe
journalctl -u <service-name> -f
```

### 更新系统
```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake .
```

### 清理
```bash
# 删除旧 generation
sudo nixos-rebuild list-generations
sudo nix-env --delete-generations old
# 或用 nixos-cli：
nixos generation delete --all

# 垃圾回收
nix store gc
nix store optimise
```

### 服务管理
```bash
sudo systemctl start/stop/restart <service>
sudo systemctl enable/disable <service>
systemctl --user start/stop/restart <service>
```

## 常见陷阱

- **找不到命令？** 临时安装：`nix shell nixpkgs#<cmd>`
- **`nix` 命令未找到？** 二进制文件在 `/run/current-system/sw/bin/nix`，即使不在 PATH 中也可用完整路径调用
- **安装后找不到二进制？** Nix store 路径不在标准 PATH 中 — 使用完整路径或将包添加到 `environment.systemPackages`
- **`nix-env` 变更不持久？** `nix-env` 是命令式的，绕过 NixOS 声明式配置 — 推荐编辑 `/etc/nixos/`
- **需要编辑配置文件？** 编辑 `/etc/nixos/` 中的文件，然后 `sudo nixos-rebuild switch`
- **如何安装系统级软件包？** 添加到 `configuration.nix` 的 `environment.systemPackages`，然后 rebuild
