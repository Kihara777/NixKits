# NixKits Project Documentation

[中文](../zh/project.md) | [English](project.md) | [日本語](../ja/project.md)

## Project Roles

| Role | Name | Responsibility |
|------|------|----------------|
| Creation & Maintenance | 狐莉 (キツのり) | Core development, architecture, release management |
| Design & Development | 小爪 (キツのめ) | AI coding agent, build config, skill system — feat. DeepSeek V4 Pro (Max) |
| Inference Infrastructure | 小小爪 (キツのめ) | Local LLM inference, model quantization, ROCm acceleration — feat. llama-cpp-rocm |
| Translator (ja) | 尾巻 (オマキ) | All Japanese documentation translation and review |
| Translator (en) | 耳廓狐 (フェネック) | All English documentation translation and review |
| Doc Design | 小爪 (キツのめ) | Multilingual doc system architecture, language switchers, templates |

## Project Architecture

```
NixKits/
├── packages/          # Package definitions (standalone binaries or source builds)
├── modules/           # NixOS modules (systemd services, configuration options)
├── overlays/          # Nixpkgs overlays (standalone or excluded from default)
├── patches/           # Standalone patch files
├── skills/            # AI coding assistant skill definitions
├── docs/              # Multilingual documentation
│   ├── zh/            # Chinese (baseline)
│   ├── en/            # English
│   ├── ja/            # Japanese
│   └── katalish/      # Katakana English (auto-translated from en)
```

## Component Catalog

Full catalog data is defined in the Chinese baseline document:
[docs/zh/project.md](../zh/project.md)

Key sections:
- **Software** — 7 packages built directly via `nix build nix-kits#<name>`
- **NixOS Modules** — 6 modules providing systemd services and configuration
- **Standalone Overlays** — 5 overlays (4 excluding `default`)
- **Standalone Patches** — 3 patches referenced by overlays or modules
- **AI Coding Skills** — 8 skills with auto-discovery for translate-* languages

### Relationship Graph

```
flake.nix
├── packages.* ← 7 direct-output packages
├── nixosModules.* ← 6 modules
├── overlays.* ← 5 overlays (each overriding one package)
│   ├── llama-cpp-rocm → overrides pkgs.llama-cpp
│   ├── mihomo-alpha   → overrides pkgs.mihomo
│   ├── rcc-fix         → overrides pkgs.asusctl
│   └── ruyi-nixos-compat → overrides pkgs.ruyi
└── skills/ ← 8 AI skills
    ├── standalone: nixkits-skills, recover-nixos-config, nixos-modern-cli
    ├── doc chain: nixkits-check-updates → write-maintenance-log
    ├── extended languages: translate-katalish, translate-pseudocn
    └── doc generation: write-project-docs → translate-* (auto-discovered)
```

## Multilingual Documentation System

### Language Map

| Code | Display Name | Directory | Naming | Translator |
|------|-------------|----------|--------|------------|
| zh | 中文 | `docs/zh/` | `<name>.md` (baseline) | 狐莉 |
| en | English | `docs/en/` | `<name>.md` | 耳廓狐 |
| ja | 日本語 | `docs/ja/` | `<name>.md` | 尾巻 |
| katalish | ｶﾀﾘｯｼｭ | `docs/katalish/` | `<name>.md` | 小爪 (auto machine) |
| pcn | 偽中国語 | `docs/pcn/` | `<name>.md` | 小爪 (auto machine) |

### Language Switcher Format

**Module docs** (under `docs/<lang>/`):
```
[中文](../../zh/project.md) | [English](project.md) | [日本語](../../ja/project.md) | [ｶﾀﾘｯｼｭ](../../katalish/project.md) | [偽中国語](../../pcn/project.md)
```

**Skill docs** (under `docs/<lang>/skills/`):
```
[中文](<name>.md) | [English](../../en/skills/<name>.md) | [日本語](../../ja/skills/<name>.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/<name>.md)
```

### Extended Language Auto-Discovery

`translate-*` skills are auto-discovered by `write-project-docs`:

```
skills/translate-*/SKILL.md → language_code and display_name from frontmatter
```

Currently installed extended languages:
- `translate-katalish`: `language_code: katalish` → Katakana English
- `translate-pseudocn`: `language_code: pcn` → Pseudo-Chinese

## Usage

### Loading NixKits

```nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nix-kits, ... }: {
    nixosConfigurations.<host> = nixpkgs.lib.nixosSystem {
      modules = [
        nix-kits.nixosModules.llama-cpp-rocm
        nix-kits.nixosModules.comfyui-strix-halo
        nix-kits.nixosModules.ruyi
        {
          nixpkgs.overlays = [
            nix-kits.overlays.default
            nix-kits.overlays.llama-cpp-rocm
            nix-kits.overlays.mihomo-alpha
            nix-kits.overlays.rcc-fix
            nix-kits.overlays.ruyi-nixos-compat
          ];
        }
      ];
    };
  };
}
```

### Using devShell

```bash
nix registry add nix-kits github:Kihara777/NixKits
nix develop nix-kits#ruyi
```
