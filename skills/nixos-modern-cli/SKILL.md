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
- **`sudo` 需要密码或免密配置** — codewhale 等编码代理通过 PTY 执行命令，`sudo` 无法交互式输入密码。若 `sudo` 失败，引导用户配置免密 sudo（`security.sudo.extraRules`），勿反复尝试
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

## Nix Store 路径陷阱

Nix 将软件安装在 `/nix/store/<hash>-<name>-<version>` 中。写入到配置文件
（`.gitconfig`、`.bashrc`、systemd unit 等）的绝对 Nix store 路径在系统更新
或 `nix store gc` 后会立即失效。

### 典型场景：GitHub CLI 凭据助手

`gh auth setup-git` 会将 gh 的绝对路径写入 `~/.gitconfig`：

```
[credential "https://github.com"]
    helper = !/nix/store/pidh15...-gh-2.94.0/bin/.gh-wrapped auth git-credential
```

GC 回收旧 store 路径后，Git 无法调用凭据助手，回退到交互式终端提示。
非交互环境下直接失败，症状为：

```
fatal: could not read Username for 'https://github.com': terminal prompts disabled
```

### 通用修复模式

将硬编码的绝对路径替换为通过 `$PATH` 查找的命令名：

```bash
# 修复前（不稳定）
git config --global credential.https://github.com.helper \
  '!/nix/store/xxxx-gh-2.94.0/bin/.gh-wrapped auth git-credential'

# 修复后（持久）
git config --global credential.https://github.com.helper \
  '!gh auth git-credential'
```

> **规则**：任何写入配置文件的 Nix store 绝对路径都会成为定时炸弹。
> 优先使用裸命令名（依赖 `$PATH`）或指向 `/run/current-system/sw/bin/`
> 的符号链接（该路径在系统更新时由 NixOS 自动替换）。

### 识别方法

检查常见配置文件中是否包含 `/nix/store/` 路径：

```bash
grep -rn '/nix/store/' ~/.gitconfig ~/.bashrc ~/.zshrc ~/.config/ 2>/dev/null
```

### 其他常见案例

| 工具 | 陷阱 | 修复 |
|------|------|------|
| `pip install --user` | `~/.local/bin/` 中的脚本 shebang 指向 Nix store Python | 使用 `nix shell` 或虚拟环境，不要用 `pip install --user` |
| `gem install` | 同 pip，二进制 stub 指向特定 Ruby 版本 | 使用 nixpkgs 中的 Ruby 包或 `bundler` |
| `cargo install` | 二进制 hardcode 了构建时的 Nix store rpath | 使用 nixpkgs 中的 Rust 包或 `nix build` |
| systemd unit `ExecStart=` | 指向 `/nix/store/…` 的绝对路径 | 使用 `lib.getExe pkg` 或在 `$PATH` 中引用 |
