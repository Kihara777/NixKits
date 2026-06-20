# nixos-modern-cli (Skill)

[中文](../../zh/ｽｷﾙs/nixos-modern-cli.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/nixos-modern-cli.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/nixos-modern-cli.md) | [偽中国語](../../pcn/ｽｷﾙs/nixos-modern-cli.md)

> Activated on NixOS systems. Ensures modern Nix CLI usage, full shell capability, and correct ﾒﾝﾃﾅﾝｽ procedures.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/nixos-modern-cli/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Corrects AI models that mistake NixOS for a traditional Linux distro
- Provides a modern vs traditional CLI command reference table
- Guides running scripts requiring POSIX tools via `nix shell --command`
- Includes a common POSIX tool → nixpkgs ﾊﾟｯｹｰｼﾞ lookup table
- Covers system ﾒﾝﾃﾅﾝｽ, log viewing, and garbage ｺﾚｸｼｮﾝ
- Lists NixOS-specific gotchas (PATH, nix-env persistence, etc.)
- Diagnoses Nix Store path traps: identifies and fixes stale `/nix/store/` paths in config files (e.g. `gh auth ｾｯﾄｱｯﾌﾟ-git` credential helper breaking after GC)

## ﾕｰｾｰｼﾞ

Auto-activated when the AI detects a NixOS environment, or on explicit request for "modern nix commands".
