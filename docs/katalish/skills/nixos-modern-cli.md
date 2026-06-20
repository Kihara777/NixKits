# nixos-modern-cli (Skill)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](../../en/skills/nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/nixos-modern-cli.md)

> Activated on NixOS systems. Ensures modern Nix CLI usage, full shell capability, ｱﾝﾄﾞ correct ﾒﾝﾃﾅﾝｽ procedures.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixos-modern-cli/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Corrects AI models that mistake NixOS ﾌｫｱ ｱ traditional Linux distro
- Provides ｱ modern vs traditional CLI command reference table
- Guides running scripts requiring POSIX tools via `nix shell --command`
- Includes ｱ common POSIX tool → nixpkgs ﾊﾟｯｹｰｼﾞ lookup table
- Covers system ﾒﾝﾃﾅﾝｽ, log viewing, ｱﾝﾄﾞ garbage ｺﾚｸｼｮﾝ
- Lists NixOS-specific gotchas (PATH, nix-env persistence, etc.)
- Diagnoses Nix Store path traps: identifies ｱﾝﾄﾞ fixes stale `/nix/store/` paths in config files (e.g. `gh auth setup-git` credential helper breaking after GC)

## ﾕｰｾｰｼﾞ

Auto-activated ｳｪﾝ ｻﾞ AI detects ｱ NixOS ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ, ｵﾗ on explicit request ﾌｫｱ "modern nix commands".
