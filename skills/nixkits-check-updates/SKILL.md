---
name: nixkits-check-updates
description: Use when the user wants to check all NixKits packages for upstream release updates and apply them. Detects new releases, updates build configurations (version, hash, meta), updates documentation, and reports locally installed versions.
---

# NixKits Package Update Checker

Checks NixKits packages for upstream release updates, applies version bumps, and updates documentation.

## Excluded Packages

The following are NOT checked (no fixed upstream release version):

- Self-hosted packages (source is `./kitsfmt-src` or similar)
- Dynamic release tracking (e.g. `llama-cpp-rocm` — fetches latest at build time)
- Nixpkgs-tracked (e.g. `rcc-fix` — follows nixpkgs version)

Everything else in `flake.nix` → `packages` is checked.

## Step 1: Confirm local NixKits repository

```bash
test -f flake.nix && grep -q "NixKits" flake.nix && echo "OK: NixKits repo" || echo "ERROR: not in NixKits repo"
```

## Step 2: Discover packages to check

Read the packages section from `flake.nix` to find all external packages:

```bash
# Extract package names that use fetchFromGitHub or fetchurl (external sources)
grep -B1 "fetchFromGitHub\|fetchurl" flake.nix packages/*.nix | grep -oP '(?<=packages\.)\w+|(?<=pkgs\.callPackage \./packages/)\w+'
```

Exclude known self-hosted/dynamic/nixpkgs packages. The remaining packages need to be checked.

## Step 3: Check upstream releases

For each discovered external package, determine its upstream repo from its `.nix` file, then compare:

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

## Step 4: Update build configurations

For each package with an update:

### npm packages

1. Update `version` string in `.nix` file
2. Set `hash` in `fetchFromGitHub` to empty placeholder
3. Set `npmDepsHash` to empty placeholder
4. Run `nix build .#<pkg>` twice — first for source hash, second for npmDepsHash
5. Update both hashes with the reported values

### cmake packages

1. Update `version` string
2. Set `hash` in `fetchFromGitHub` to empty
3. Run `nix build .#<pkg>` to get correct hash
4. Update hash

### pre-built binary packages (fetchurl)

1. Update `version` string and all download URLs
2. Set all `hash` values to empty
3. Run `nix build .#<pkg>` for each binary hash
4. Update hashes one by one

## Step 5: Update documentation

For each updated package, update version numbers in all 3 language docs:

```bash
for lang in zh en ja; do
  sed -i "s/$OLD_VER/$NEW_VER/g" docs/$lang/<pkg>.md
done
```

Also check and update `meta.changelog` URL in the `.nix` file.

## Step 6: Check locally installed versions

```bash
nix eval --raw .#<pkg>.version 2>/dev/null
which <binary> 2>/dev/null && <binary> --version 2>/dev/null
```

## Step 7: Report summary

Present a table with: package name, old → new version, build status, locally installed version.
