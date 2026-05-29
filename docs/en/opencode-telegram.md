# opencode-telegram

[中文](../zh/opencode-telegram.md) | [English](opencode-telegram.md) | [日本語](../ja/opencode-telegram.md)

Telegram Bot client for [OpenCode](https://opencode.ai).

## Info

| Item | Value |
|------|-------|
| Version | 0.20.5 |
| Upstream | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## Usage

```bash
opencode-telegram start           # interactive setup
opencode-telegram start --daemon  # background mode
opencode-telegram status          # check status
opencode-telegram stop            # stop
```

## Install

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.opencode-telegram ];

# Default overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## Systemd Service

```nix
systemd.services.opencode-telegram = {
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "simple";
    ExecStart = "${pkgs.opencode-telegram}/bin/opencode-telegram start";
    Restart = "on-failure";
    RestartSec = 10;
    User = "kix";
    Group = "users";
    Environment = [
      "PATH=${pkgs.opencode}/bin:${pkgs.opencode-telegram}/bin:/run/wrappers/bin"
    ];
  };
};
```
