# dsh-skill-nixkits

[中文](../zh/dsh-skill-nixkits.md) | English | [日本語](../ja/dsh-skill-nixkits.md)  | [偽中国語](../pcn/dsh-skill-nixkits.md)

All 7 NixKits skills as native DeepSeek Harness (DSH) skill plugins. **Each skill is one plugin entry** (a package subpath export): the plugin registers its own content through `ctx.skills.register` at runtime (runtime provider, rank 250, outranking filesystem sources such as `~/.dsh/skills`), mounts/unmounts with the composition, can be disabled per entry id via `plugins.disabled`, and appears in the dsh plugin inventory and settings UI.

## Basic Info

| Item | Value |
|------|-------|
| Type | DSH host plugin (npm package, zero runtime dependencies) |
| npm name | `@kihara777/dsh-skill-nixkits` |
| Version | `0.1.0` |
| License | MIT |
| Content source | repo `skills/` (embedded at build time, single source of truth) |

## Plugin entries

| Subpath | Plugin name | Skill |
|---------|-------------|-------|
| `nixkits-check-updates` | `skill-nixkits-nixkits-check-updates` | Upstream version checks and auto-application |
| `nixkits-skills` | `skill-nixkits-nixkits-skills` | Installing skills into coding-assistant directories |
| `nixos-modern-cli` | `skill-nixkits-nixos-modern-cli` | Modern NixOS CLI workflow rules |
| `recover-nixos-config` | `skill-nixkits-recover-nixos-config` | Recovering /etc/nixos from the Nix store |
| `translate-pseudocn` | `skill-nixkits-translate-pseudocn` | Pseudo-Chinese document localization |
| `write-maintenance-log` | `skill-nixkits-write-maintenance-log` | Maintenance log authoring rules |
| `write-project-docs` | `skill-nixkits-write-project-docs` | Multi-language project documentation generation |

## Architecture

```
Composition row (one per skill)
  └─ plugin apply() → ctx.skills.register({ name, description, content, source: "runtime",
                                           resourceBase: { kind: "directory", path: <skill dir> },
                                           metadata: <frontmatter fields> })
```

- **Single source of truth**: the SKILL.md files stay in the repo's `skills/` and are embedded at build time (`postPatch cp -r`); the NixKits documentation pipeline's auto-discovery contract (frontmatter `language_code`/`display_name`/`base_language`) is unaffected, and the fields are preserved in `metadata`
- **Registration lifecycle**: `apply()` returns the `skills.register()` disposer, unwound with the composition
- **Zero dependencies**: consumes only the `skills` capability seam; peers come from the host dsh tree

## Usage

Register all 7 composition rows at once via `nixkits.dsh.skills`:

```nix
{
  nixkits.dsh.skills = {
    enable = true;
    package = pkgs.dsh-skill-nixkits;  # default
  };
}
```

Manual composition row (selective mounting, when the npm package is resolvable from dsh):

```yaml
- insert:
  - id: skill-nixkits-nixos-modern-cli
    name: '@kihara777/dsh-skill-nixkits/nixos-modern-cli'
```

> **Note**: new entries must be wrapped in an `- insert:` op — a bare `- id:` row only patches an existing entry, and dsh reports `patch: entry … not found` and drops the row.

Disable a single skill (like any other plugin):

```nix
nixkits.dsh.plugins.disabled = [ "skill-nixkits-translate-pseudocn" ];
```
