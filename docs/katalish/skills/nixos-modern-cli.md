# ﾆｯｸｽOS-modern-cli (ｽｷﾙ)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixos-modern-cli.md) | [偽中国語](../../pcn/skills/nixos-modern-cli.md)

> Activated on NixOS systems. Ensures modern Nix CLI usage, full shell capability, and correct maintenance procedures.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/nixos-modern-cli/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Corrects AI ﾓﾃﾞﾙｽﾞ ｻﾞｯﾄ mistake NixOS ﾌｫｱ ｱ traditional Linux distro
- Provides ｱ modern vs traditional CLI ｺﾏﾝﾄﾞ reference ﾃｰﾌﾞﾙ
- ｶﾞｲﾄﾞｽﾞ running scripts requiring POSIX ﾂｰﾙｽﾞ via `nix shell --command`
- Includes ｱ common POSIX ﾂｰﾙ → nixpkgs ﾊﾟｯｹｰｼﾞ lookup ﾃｰﾌﾞﾙ
- Covers ｼｽﾃﾑ maintenance, log viewing, ｱﾝﾄﾞ garbage collection
- ﾘｽﾄｽﾞ NixOS-specific gotchas (ﾊﾟｽ, ﾆｯｸｽ-env persistence, etc.)
- Diagnoses ﾆｯｸｽ Store ﾊﾟｽ traps: identifies ｱﾝﾄﾞ fixes stale `/nix/store/` ﾊﾟｽｽﾞ ｲﾝ ｺﾝﾌｨｸﾞ files (e.g. `gh auth setup-git` credential helper breaking after GC)

## ﾕｰｾｰｼﾞ

ｵｰﾄ-activated when ｻﾞ AI detects ｱ NixOS environment, ｵｱ ｵﾝ explicit request ﾌｫｱ "modern ﾆｯｸｽ ｺﾏﾝﾄﾞｽﾞ".