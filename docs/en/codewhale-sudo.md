# codewhale-sudo

[中文](../zh/codewhale-sudo.md) | English | [日本語](codewhale-sudo.ja.md)  | [偽中国語](codewhale-sudo.pcn.md)

codewhale v0.9.0 enables `prctl(PR_SET_NO_NEW_PRIVS)` defense-in-depth by default, blocking `sudo`. Codewhale is statically linked, so `LD_PRELOAD` cannot work. This patch intercepts the prctl call via a ptrace-based syscall interceptor at the kernel boundary, restoring sudo functionality.

## Info

| Item | Value |
|------|-------|
| Patch | `overlays/codewhale-sudo-fix.nix` |
| Type | overlay (overrides codewhale package) |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |

## Install

```nix
nixpkgs.overlays = [ inputs.nixkits.overlays.codewhale-sudo-fix ];
```

## Prerequisites

codewhale executes commands via PTY and requires **passwordless sudo**. Add your user to the `wheel` group and configure NixOS:

```nix
security.sudo = {
  enable = true;
  wheelNeedsPassword = false;  # passwordless sudo for wheel
};
users.users.you = {
  extraGroups = [ "wheel" ];
};
```


## Caveats

- This patch reduces sandbox security; use only in dev environments that need `sudo`
- `sudo` functionality depends on correct NixOS passwordless configuration; the patch itself does not bypass password auth

## Cache

Patch is an overlay — not in the binary cache.
