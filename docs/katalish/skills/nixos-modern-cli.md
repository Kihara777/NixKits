# nixos-ﾑｵﾄﾞｴﾗﾝ-cli (Skill)

[中文](../../zh/ｽｷﾙs/nixos-ﾑｵﾄﾞｴﾗﾝ-cli.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/nixos-ﾑｵﾄﾞｴﾗﾝ-cli.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/nixos-ﾑｵﾄﾞｴﾗﾝ-cli.md) | [偽中国語](../../pcn/ｽｷﾙs/nixos-ﾑｵﾄﾞｴﾗﾝ-cli.md)

> Activated ｵﾝ NixOS systems. Ensures ﾑｵﾄﾞｴﾗﾝ Nix ｼｰｴﾙｱｲ usage, full shell capability, ｱﾝﾄﾞ correct ﾒﾝﾃﾅﾝｽ procedures.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | Coding Agent Skill |
| Path | `ｽｷﾙs/nixos-ﾑｵﾄﾞｴﾗﾝ-cli/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Corrects AI models ｻﾞｯﾄ mistake NixOS ﾌｫｱ ｱ traditional Linux distro
- Provides ｱ ﾑｵﾄﾞｴﾗﾝ vs traditional ｼｰｴﾙｱｲ command reference table
- Guides running scripts requiring POSIX ﾂｰﾙｽﾞ ﾌﾞｲｱ `nix shell --command`
- Includes ｱ common POSIX tool → nixpkgs ﾊﾟｯｹｰｼﾞ lookup table
- Covers system ﾒﾝﾃﾅﾝｽ, log viewing, ｱﾝﾄﾞ garbage ｺﾚｸｼｮﾝ
- Lists NixOS-specific gotchas (PATH, nix-env persistence, etc.)
- Diagnoses Nix Store ﾊﾟｽ traps: identifies ｱﾝﾄﾞ fixes stale `/nix/ｽﾄｴﾗ/` paths ｲﾝ ｺﾝﾌｨｸﾞ files (e.g. `gh ｵｰｽ ｾｯﾄｱｯﾌﾟ-git` credential helper breaking ｱﾌﾀｰ GC)

## ﾕｰｾｰｼﾞ

Auto-activated ｳｪﾝ ｻﾞ AI detects ｱ NixOS ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ, ｵﾗ ｵﾝ explicit request ﾌｫｱ "ﾑｵﾄﾞｴﾗﾝ nix commands".
