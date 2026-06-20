# nixos-modern-cli (ｽｷﾙ)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixos-modern-cli.md)

> Activated ｵﾝ NixOS systems. Ensures modern ﾆｯｸｽ CLI ﾕｰｾｰｼﾞ, full ｼｪﾙ capability, ｱﾝﾄﾞ correct ﾒﾝﾃﾅﾝｽ procedures.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/nixos-modern-cli/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Corrects AI models ｻﾞｯﾄ mistake NixOS ﾌｫｱ ｱ traditional Linux distro
- ﾌﾟﾛﾊﾞｲﾄﾞｽﾞ ｱ modern vs traditional CLI ｺﾏﾝﾄﾞ ﾘﾌｧﾚﾝｽ ﾃｰﾌﾞﾙ
- Guides running scripts requiring POSIX ﾂｰﾙｽﾞ via `nix shell --command`
- ｲﾝｸﾙｰﾄﾞｽﾞ ｱ common POSIX ﾂｰﾙ → nixpkgs ﾊﾟｯｹｰｼﾞ lookup ﾃｰﾌﾞﾙ
- Covers ｼｽﾃﾑ ﾒﾝﾃﾅﾝｽ, ﾛｸﾞ viewing, ｱﾝﾄﾞ garbage collection
- Lists NixOS-specific gotchas (ﾊﾟｽ, nix-env persistence, etc.)
- Diagnoses ﾆｯｸｽ Store ﾊﾟｽ traps: identifies ｱﾝﾄﾞ ﾌｨｯｸｼｰｽﾞ stale `/nix/store/` paths ｲﾝ ｺﾝﾌｨｸﾞ ﾌｧｲﾙｽﾞ (e.g. `gh auth setup-git` credential helper breaking ｱﾌﾀｰ GC)

## ﾕｰｾｰｼﾞ

Auto-activated ｳｪﾝ ｻﾞ AI detects ｱ NixOS ｴﾝﾊﾞｲﾛﾒﾝﾄ, ｵｱ ｵﾝ explicit request ﾌｫｱ "modern ﾆｯｸｽ ｺﾏﾝﾄﾞｽﾞ".