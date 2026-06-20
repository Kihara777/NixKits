# recover-nixos-ｺﾝﾌｨｸﾞ (Skill)

[中文](../../zh/ｽｷﾙs/recover-nixos-ｺﾝﾌｨｸﾞ.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/recover-nixos-ｺﾝﾌｨｸﾞ.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/recover-nixos-ｺﾝﾌｨｸﾞ.md) | [偽中国語](../../pcn/ｽｷﾙs/recover-nixos-ｺﾝﾌｨｸﾞ.md)

> Recovers accidentally deleted `/etc/nixos` files ﾌﾛﾑ ｻﾞ Nix store.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/recover-nixos-ｺﾝﾌｨｸﾞ/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Locates ｻﾞ flake source snapshot ﾌﾛﾑ ｻﾞ most recent successful ﾋﾞﾙﾄﾞ ｲﾝ ｻﾞ Nix store
- Searches `*-source` directories ﾊﾞｲ hostname
- Identifies ｻﾞ correct source matching ｻﾞ latest generation
- Restores specified files (flake.nix, flake.lock, individual ﾓｼﾞｭｰﾙs)
- Validates ｻﾞ restored ｺﾝﾌｨｸﾞ ｳｨｽﾞ `nix flake ﾁｪｯｸ`

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ reports accidentally deleting files under `/etc/nixos`.
