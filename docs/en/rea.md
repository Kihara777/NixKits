# rea

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-rea-x86_64.yml?branch=main&label=x86_64%20v6.8.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-rea-aarch64.yml?branch=main&label=aarch64%20v6.8.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/rea.md) | English | [日本語](../ja/rea.md)  | [偽中国語](../pcn/rea.md)

**REA (Reverse Engineer Anything)** — reverse engineer anything with agents: one CLI plus MCP server, from app behavior down to native binaries. Analysis runs locally and every conclusion carries its evidence and limitations.

## Info

| Item | Value |
|------|-------|
| Version | 6.8.0 |
| Upstream | <https://github.com/morluto/rea> |
| npm name | `rea-agents` |
| License | MIT |
| Packaging | the upstream **prebuilt** npm tarball (`dist/` as shipped, nothing is compiled here) |
| Platforms | x86_64-linux / aarch64-linux |

## Usage

```bash
rea --help                                    # command list (153 subcommands as measured)
rea doctor                                    # readiness (client registrations / analysis engines / host)
rea capabilities                              # provider capabilities and side effects
rea analyze-javascript-application <dir> --format json   # statically reconstruct a JS/Electron app
rea mcp                                       # stdio MCP server
```

The result is an **Evidence envelope**: conclusions live in `normalized_result`, and the boundaries of each conclusion live in `limitations`.

## Capability and dependency boundaries

Most of REA needs **no external engine**, which is what this package is for; wherever an engine is required, bring your own — this package never guesses paths.

| Target | What you get | Requirements |
|--------|--------------|--------------|
| JavaScript / Electron | modules, imports, source maps, routes, IPC, native add-on relations | `ps` (procps) — already supplied by this package |
| .NET assemblies | metadata, CIL instructions, declared native dependencies | none (static only) |
| Go / Rust binaries | embedded build version, modules, dependency edges | none (static only) |
| Godot PCK / IL2CPP / SQLite / packages and resources | archive inventory, type and method names, table shapes, digests | none (static only) |
| Native binaries (pseudocode / assembly) | pseudocode, assembly, strings, symbols, calls and references | an externally installed Hopper / Ghidra / IDA |
| Android APKs | manifest, classes, decompiled methods | JADX (bring the jar) plus a JDK (**shipped here**) |

## Known limits of this package

> These are not "untested" — they are **known unavailable** or **known to error**. Stated here so you do not pick up the opposite expectation elsewhere.

| Item | Reality |
|------|---------|
| `rea doctor` host check | On NixOS it reports `host: unsupported_host` (upstream recognizes distributions through the apt / dnf / pacman family; NixOS is not on that list). **Static analysis works as measured**, so this line is a diagnosis verdict, not a runtime prerequisite |
| frida dynamic instrumentation | An upstream optionalDependency that **downloads** its binary through `prebuild-install` at install time. Nix builds are offline and use `npmRebuildFlags = [ "--ignore-scripts" ]`, so the frida native binding is absent — related commands fail instead of degrading silently |
| Hopper / Ghidra / IDA, JADX | Never provided by this package; point to your own through environment variables (`GHIDRA_INSTALL_DIR`, `HOPPER_LAUNCHER_PATH`, `REA_JADX_MCP_JAR`). **The JDK and `ps` ship here** — the JDK lands in this package's closure (about +200 MiB) even for people who never touch Android analysis, which is a deliberate trade-off |
| riscv64 | **Unsupported**: `@lydell/node-pty` publishes prebuilt artifacts for x64/arm64 only, and REA imports it |

## Referencing

```nix
# Direct reference
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.rea ];

# Default overlay (recommended)
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.rea
```

## Using the MCP server

`rea mcp` speaks stdio. For manual registration in other clients see the upstream `docs/installation.md`; `rea doctor` lists the client configurations it found on this machine and what is missing.

## Updating

`packages/rea.nix` pins three things: the npm tarball `hash`, `npmDepsHash`, and the vendored `packages/rea-package-lock.json`. They must stay in sync — the vendored lock contains production dependencies only, so `postPatch` removes the tarball's `devDependencies`, and any mismatch makes `npm ci` fail hard (deliberately: a mismatch is harder to find than a compile error). See the `nix-flake-update-check` skill for the general flow.

The artifact is verified for real by `develop/qemu-smoke-tests/rea.sh` (both the x86_64 and aarch64 CI workflows run it); the criterion is **one actual static analysis**, not `--version`.
