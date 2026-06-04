---
name: nixos-modern-cli
description: Use when working on a NixOS system. Ensures correct use of modern Nix/NixOS CLI, full shell capabilities, sudo access, and proper system maintenance procedures.
---

# NixOS Modern CLI Guide

## Critical: NixOS is NOT a traditional Linux distribution

NixOS is a declarative, immutable Linux distribution. Key differences:

- **No `/usr/bin`, `/usr/lib`** — all software lives in the Nix store (`/nix/store`)
- **No `apt`, `yum`, `pacman`** — use `nix` commands or edit `/etc/nixos/configuration.nix` (or flake)
- **No `/etc/default/grub`, `/etc/fstab`** — these are generated from NixOS configuration
- **Shell PATH** does not include common tools by default — use `nix shell nixpkgs#<pkg>` for ad-hoc tools
- **`sudo` works normally** for system commands, `systemctl` works as expected
- **`nixos-rebuild`** must be used to apply configuration changes

## First Step: Check CLI capabilities

After gaining shell access, verify available tools:

```bash
# Check for modern nixos CLI (preferred)
nixos --help 2>/dev/null && echo "nixos-cli available"

# Check for nix-command (preferred over nix-*)
nix --help 2>/dev/null && echo "nix-command available"
```

## Modern vs Traditional Commands

Always prefer the modern equivalents when available:

| Traditional | Modern (prefer) |
|-------------|-----------------|
| `nixos-rebuild switch` | `nixos rebuild switch` (if nixos-cli) or `nixos-rebuild switch` |
| `nix-env -iA` | `nix profile install` |
| `nix-shell` | `nix shell` |
| `nix-build` | `nix build` |
| `nix-collect-garbage` | `nix store gc` |
| `nix-store --optimise` | `nix store optimise` |
| `nix-channel --update` | Not needed with flakes |

If `nixos-cli` (package `nixos-cli`) is available:
```bash
nixos rebuild switch --flake /etc/nixos
nixos generation delete --all  # cleanup old generations
nixos store gc                 # garbage collection
nixos store optimise           # optimise store
```

If only `nix-command` is available:
```bash
sudo nixos-rebuild switch --flake /etc/nixos
nix store gc
nix store optimise
```

## Shell Environment

NixOS shells are minimal. When you need tools not in the system PATH:

```bash
# Temporary shell with required tools
nix shell nixpkgs#git nixpkgs#ripgrep nixpkgs#curl

# Or enter a persistent development shell
nix develop nixpkgs#<package>
```

### Running scripts that need POSIX utilities

Many shell scripts depend on `grep`, `sed`, `tr`, `head`, `tail`, `python3` etc. On NixOS these are NOT in PATH by default. Use `nix shell` with the `--command` flag to run scripts in a fully-equipped environment:

```bash
# Single command with required packages
nix shell nixpkgs#python3 nixpkgs#coreutils nixpkgs#gnused \
  nixpkgs#gnugrep nixpkgs#bash --command \
  bash -c 'python3 my_script.py arg1 arg2'

# Complex multi-step workflow
nix shell nixpkgs#python3 nixpkgs#coreutils nixpkgs#gnused \
  nixpkgs#gnugrep nixpkgs#bash --command bash -c '
cd /path/to/project
python3 install.py 2>&1
ls -la output/
echo "done"
'
```

**Common packages for shell scripting:**
| Tool | Package |
|------|---------|
| `python3` | `nixpkgs#python3` |
| `grep`, `ls`, `cat`, `head`, `tail`, `wc`, `tr`, `sort`, `mkdir`, `rm`, `find` | `nixpkgs#coreutils` |
| `sed` | `nixpkgs#gnused` |
| `bash` (full) | `nixpkgs#bash` |
| `awk` | `nixpkgs#gawk` |
| `git` | `nixpkgs#git` |

## System Maintenance

### Check system status
```bash
systemctl status
systemctl --failed
```

### View logs
```bash
journalctl -xe
journalctl -u <service-name> -f
```

### Update system
```bash
cd /etc/nixos
nix flake update
sudo nixos-rebuild switch --flake .
```

### Clean up
```bash
# Delete old generations
sudo nixos-rebuild list-generations
sudo nix-env --delete-generations old
# Or with nixos-cli:
nixos generation delete --all

# Garbage collect
nix store gc
nix store optimise
```

### Service management
```bash
sudo systemctl start/stop/restart <service>
sudo systemctl enable/disable <service>
systemctl --user start/stop/restart <service>
```

## Common Gotchas

- **Can't find a command?** Install it temporarily: `nix shell nixpkgs#<cmd>`
- **`nix` command not found?** The binary is at `/run/current-system/sw/bin/nix` even when not in PATH. Use the full path or add to environment.
- **Binary not found after install?** The Nix store path is not in standard PATH — use the full path or add the package to `environment.systemPackages`
- **`nix-env` changes don't persist?** `nix-env` is imperative and bypasses NixOS declarative config — prefer editing `/etc/nixos/`
- **Need to edit a config file?** Edit files in `/etc/nixos/`, then `sudo nixos-rebuild switch`
- **How to install system-wide packages?** Add to `environment.systemPackages` in configuration.nix, then rebuild
