---
name: nixkits-check-updates
description: Use when the user wants to check all NixKits packages for upstream release updates and apply them. Detects new releases, updates build configurations (version, hash, meta), updates documentation, and reports locally installed versions.
---

# NixKits Package Update Checker

Checks all externally-sourced NixKits packages for upstream release updates, applies version bumps, and updates documentation.

## Scope

**Packages checked** (external, versioned):
| Package | Upstream | .nix file |
|---------|----------|-----------|
| opencode-telegram | grinev/opencode-telegram-bot | `packages/opencode-telegram.nix` |
| mcp-searxng | ihor-sokoliuk/MCP-searxng | `packages/mcp-searxng.nix` |
| obs-bilibili-stream | Zarosmm/obs-bilibili-stream | `packages/obs-bilibili-stream.nix` |
| codewhale | Hmbown/CodeWhale | `packages/codewhale.nix` |

**NOT checked**:
- `kitsfmt` — self-hosted in this repo
- `llama-cpp-rocm` — dynamic release tracking at build time
- `rcc-fix` — follows nixpkgs version

## Step 1: Confirm local NixKits repository

```bash
# Verify we are inside NixKits source
test -f flake.nix && grep -q "NixKits" flake.nix && echo "OK: NixKits repo" || echo "ERROR: not in NixKits repo"
```

## Step 2: Check upstream releases

```bash
# Use GitHub API to get latest release tag for each package
check() {
  local name="$1" repo="$2" current="$3" file="$4"
  latest=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -oP '"tag_name":\s*"\K[^"]+')
  if [ "$current" != "$latest" ]; then
    echo "UPDATE: $name  $current → $latest  ($file)"
  else
    echo "OK: $name  $current"
  fi
}

check "opencode-telegram" "grinev/opencode-telegram-bot" "$(grep -oP 'version = "\K[^"]+' packages/opencode-telegram.nix)" "packages/opencode-telegram.nix"
check "mcp-searxng" "ihor-sokoliuk/MCP-searxng" "$(grep -oP 'version = "\K[^"]+' packages/mcp-searxng.nix)" "packages/mcp-searxng.nix"
check "obs-bilibili-stream" "Zarosmm/obs-bilibili-stream" "$(grep -oP 'version = "\K[^"]+' packages/obs-bilibili-stream.nix)" "packages/obs-bilibili-stream.nix"
check "codewhale" "Hmbown/CodeWhale" "$(grep -oP 'version = "\K[^"]+' packages/codewhale.nix)" "packages/codewhale.nix"
```

## Step 3: Update build configurations

For each package with an update:

### npm packages (opencode-telegram, mcp-searxng)

1. Update `version` string in `.nix` file
2. Set `hash` in `fetchFromGitHub` to empty placeholder
3. Set `npmDepsHash` to empty placeholder
4. Run `nix build .#<pkg>` to get correct hash
5. Update hash with the value from `got: sha256-...`
6. Run `nix build .#<pkg>` again to get `npmDepsHash`
7. Update `npmDepsHash` with the value

### cmake packages (obs-bilibili-stream)

1. Update `version` string
2. Set `hash` in `fetchFromGitHub` to empty
3. Run `nix build .#<pkg>` to get correct hash
4. Update hash

### pre-built binary packages (codewhale)

1. Update `version` string
2. Update both download URLs (CLI and TUI binaries)
3. Set both `hash` values to empty
4. Run `nix build .#codewhale` to get CLI hash
5. Update CLI hash
6. Run `nix build .#codewhale` again to get TUI hash
7. Update TUI hash

## Step 4: Update documentation

```bash
# Update version numbers in all 3 language docs
for lang in zh en ja; do
  sed -i "s/$OLD_VER/$NEW_VER/g" docs/$lang/<pkg>.md
done
```

Also update the package's `.nix` file `meta.changelog` URL if the version appears in it.

## Step 5: Check locally installed versions

After updating, check if the package is installed locally:

```bash
# Check nix profile
nix profile list 2>/dev/null | grep <pkg> || echo "  Not in nix profile"

# Check NixOS system packages
nix eval --raw nixpkgs#<pkg>.version 2>/dev/null || nix eval --raw .#<pkg>.version 2>/dev/null

# Check if binary is in PATH
which <binary> 2>/dev/null && <binary> --version 2>/dev/null || echo "  Not installed"
```

## Step 6: Report summary

Present a table showing:
- Package name
- Old → New version
- Build status (OK/FAILED)
- Locally installed version (if any) or "not installed"
