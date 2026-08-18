# dsh

[中文](../zh/dsh.md) | English | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness (DSH) — Everything is a Plugin.

## Basic Info

| Item | Value |
|------|-------|
| Type | Node.js application (CLI) |
| Upstream | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| Version | `0.1.0-rc.6` |
| License | MIT |
| Command | `dsh` |

## Install

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.dsh ];
```

## Usage

```bash
dsh --help
dsh web   # launch the browser UI
```

## Service

Run as a resident web service via the `nixkits.dsh` module (default port `8625`, firewall auto-opened):

```nix
{
  nixkits.dsh = {
    enable = true;
    port = 8625;
    host = "0.0.0.0";
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```
