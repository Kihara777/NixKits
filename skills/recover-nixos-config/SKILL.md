---
name: recover-nixos-config
description: Use when the user has accidentally deleted files under /etc/nixos (flake.nix, flake.lock, etc.) and needs to recover them from the Nix store.
---

# Recover deleted /etc/nixos files

When a file under `/etc/nixos` is accidentally deleted but the NixOS system was
previously built successfully from that configuration, the flake source
(including flake.nix, flake.lock, and all local modules) is preserved in the
Nix store. Any build file — flake.nix, flake.lock, boot.nix, system.nix,
home.nix, etc. — can be recovered.

## Step 1: Locate the flake source in the Nix store

The Nix store preserves a snapshot of the flake source used in every
successful `nixos-rebuild`. Search by hostname:

```bash
grep -rl '<HOSTNAME>' /nix/store/*-source/flake.nix 2>/dev/null
```

The source directory is named `*-source` and contains all files that were
present in `/etc/nixos` at build time:
- `flake.nix`
- `flake.lock`
- all local `.nix` modules (boot.nix, home.nix, system.nix, etc.)

## Step 2: Confirm the latest generation

Among the candidates from Step 1, identify the source from the latest
generation. The most recent source typically has the largest store path hash.
When in doubt, compare each candidate's flake.nix against the remaining files
in `/etc/nixos` — the correct source references the same local modules that
still exist (e.g. `./boot.nix`, `./system.nix`).

To list all past generations:

```bash
nixos-rebuild list-generations
```

The source directory matched to the current generation contains the same
configuration that built the running system.

## Step 3: Verify contents

Check the first line of flake.nix to confirm the right configuration:

```bash
head -1 /nix/store/<hash>-source/flake.nix
```

List all available files in the source:

```bash
ls /nix/store/<hash>-source/
```

## Step 4: Restore the deleted file(s)

Copy the needed file(s) back to `/etc/nixos/`. Only restore what was lost:

```bash
cp /nix/store/<hash>-source/<filename> /etc/nixos/<filename>
```

Example — restoring flake.nix only:

```bash
cp /nix/store/<hash>-source/flake.nix /etc/nixos/flake.nix
```

Restoring multiple files:

```bash
cp /nix/store/<hash>-source/flake.nix /etc/nixos/flake.nix
cp /nix/store/<hash>-source/flake.lock /etc/nixos/flake.lock
cp /nix/store/<hash>-source/home.nix   /etc/nixos/home.nix
```

## Step 5: Validate

```bash
nix flake check /etc/nixos
```
