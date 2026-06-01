---
name: nixkits-skills
description: Use when the user wants to install or update NixKits skills into coding agent directories (opencode, codewhale, claude, openclaw, agents). Supports local and online installation modes.
---

# NixKits Skills Installer

Installs NixKits skills into coding agent skill directories.

## Supported Agents

| Agent | Skill Directory |
|-------|----------------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude Code | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| Generic | `~/.agents/skills/` |

## Available NixKits Skills

| Skill | Description |
|-------|-------------|
| `recover-nixos-config` | Recover deleted /etc/nixos files from Nix store |
| `nixos-modern-cli` | NixOS modern CLI operations guide for AI models |

## Installation Modes

### Mode 1: Local (from NixKits source)

When the user is inside the NixKits source directory:

```bash
# Find the NixKits source directory
NIXKITS_DIR=$(pwd)
# Or if known path:
NIXKITS_DIR="/home/kix/NixKits"

# Copy skills to each existing agent directory
for dir in ~/.opencode/skills ~/.codewhale/skills ~/.claude/skills ~/.openclaw/skills ~/.agents/skills; do
  if [ -d "$dir" ]; then
    cp -r "$NIXKITS_DIR/skills/"* "$dir/"
    echo "Installed to $dir"
  fi
done
```

### Mode 2: Online (from GitHub)

When NixKits source is not locally available:

```bash
# Clone NixKits to a temporary directory
TMPDIR=$(mktemp -d)
git clone https://github.com/Kihara777/NixKits.git "$TMPDIR"

# Install from the cloned source
for dir in ~/.opencode/skills ~/.codewhale/skills ~/.claude/skills ~/.openclaw/skills ~/.agents/skills; do
  if [ -d "$dir" ]; then
    cp -r "$TMPDIR/skills/"* "$dir/"
    echo "Installed to $dir"
  fi
done

rm -rf "$TMPDIR"
```

## Checking for Updates

Before installing, compare local skills against the source:

```bash
# Local mode: compare against NixKits source
NIXKITS_DIR="/home/kix/NixKits"
for skill_dir in "$NIXKITS_DIR/skills/"*/; do
  skill_name=$(basename "$skill_dir")
  for agent_dir in ~/.opencode/skills ~/.codewhale/skills ~/.claude/skills ~/.openclaw/skills ~/.agents/skills; do
    if [ -d "$agent_dir/$skill_name" ]; then
      if ! diff -rq "$skill_dir" "$agent_dir/$skill_name" > /dev/null 2>&1; then
        echo "Update available: $skill_name in $(basename $(dirname $agent_dir))"
        echo "  Source: $skill_dir"
        echo "  Target: $agent_dir/$skill_name"
      fi
    fi
  done
done
```

## Workflow

1. **Detect agent directories** — check which skill directories exist
2. **Check for existing NixKits skills** — compare versions if already installed
3. **Ask user** if updates should be applied when differences are found
4. **Choose mode** — local if inside NixKits source, online otherwise
5. **Install** — copy skills to each detected agent directory
6. **Verify** — confirm installation was successful
