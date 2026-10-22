# NixKits · impure branch

[中文](../README.md) | English | [日本語](README.ja.md)  | [偽中国語](README.pcn.md)

**This branch does exactly one thing: it keeps the "floating" part here so that `main` can be pinned.**

| Item | Content |
|---|---|
| Only content | `llama-cpp-rocm` (overlay + NixOS module + package) |
| Floating inputs | `llama-cpp-ver` (GitHub `releases/latest` JSON), `nixpkgs` (`nixos-unstable`) |
| `flake.lock` | **deliberately not committed** (pinned in `.gitignore`) |
| Relation to `main` | **no shared history** (orphan branch); referenced as an input by `main` or `/etc/nixos` |

## Why it exists

`llama-cpp-rocm`'s version comes from the latest upstream llama.cpp release and cannot be
written down; and once `main` committed `flake.lock`, that floating input would go stale
with every upstream release — which is exactly why `main` refused to commit a lock for a
long time, at the cost of **the whole repository's CI being non-reproducible**.

Moving it to a standalone branch fixes both sides:

- this branch **does not lock**, and always follows upstream;
- `main` **can lock**, because it no longer contains any floating input;
- upgrading llama.cpp means bumping only this branch's rev
  (`nix flake update nixkits-impure`), without dragging any other `main` input.

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixkits-impure.url = "github:Kihara777/NixKits/impure";
  };

  outputs = { nixpkgs, nixkits-impure, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      modules = [
        # ① the overlay provides pkgs.llama-cpp-rocm (ROCm build, version follows upstream)
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nixkits-impure.overlays.default ];
          services.llama-cpp.package = pkgs.llama-cpp-rocm;
        })

        # ② the module provides nixkits.llama-cpp-rocm.* (model presets, systemd hardening overrides)
        nixkits-impure.nixosModules.default
        { nixkits.llama-cpp-rocm.enable = true; }
      ];
    };
  };
}
```

Fetch the package directly (without the NixOS module):

```bash
nix build github:Kihara777/NixKits/impure#llama-cpp-rocm
```

## How the version is fetched, and what it costs

`llama-cpp-ver` is a **plain URL input** (`api.github.com`). Nix **does not** attach
`access-tokens` to that kind of fetch, and the unauthenticated quota is **60 requests per
hour** — shared egress IPs hit 403 easily. Two ways to handle it:

```bash
# ① fetch the same JSON with an authenticated gh, override locally (this is what CI does)
gh api repos/ggml-org/llama.cpp/releases/latest > /tmp/llama.json
nix flake check --override-input llama-cpp-ver path:/tmp/llama.json

# ② update first and work offline (writes flake.lock, which this branch does not commit)
nix flake update llama-cpp-ver
```

## Boundaries

- Contains **none** of `main`'s other packages, modules or skills;
- Does **not** run `main`'s self-checks (those criteria and files are not on this branch);
- Full documentation (model presets, UMA tuning, thermal management, troubleshooting) lives in
  `docs/zh/llama-cpp-rocm.md` (all four languages), **moved here together with the component** —
  `main` keeps no copy, so the two can never drift. The tuning methodology (specialisation
  architecture, unified memory, thermal management) stays in `main`'s
  `nixos-specialisation-tuning` skill, because it is portable method rather than part of this package.

## License

MIT, see `LICENSE`.
