# ﾘｶﾊﾞｰ-nixos-ｺﾝﾌｨｸﾞ (Skill)

[中文](../../zh/ｽｷﾙs/ﾘｶﾊﾞｰ-nixos-ｺﾝﾌｨｸﾞ.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/ﾘｶﾊﾞｰ-nixos-ｺﾝﾌｨｸﾞ.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/ﾘｶﾊﾞｰ-nixos-ｺﾝﾌｨｸﾞ.md) | [偽中国語](../../pcn/ｽｷﾙs/ﾘｶﾊﾞｰ-nixos-ｺﾝﾌｨｸﾞ.md)

> Recovers accidentally ﾃﾞｨﾘｰﾃｯﾄﾞ `/etc/nixos` files ﾌﾛﾑ ｻﾞ Nix ｽﾄｴﾗ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | Coding Agent Skill |
| Path | `ｽｷﾙs/ﾘｶﾊﾞｰ-nixos-ｺﾝﾌｨｸﾞ/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Locates ｻﾞ flake ｿｰｽ snapshot ﾌﾛﾑ ｻﾞ ﾓｽﾄ recent successful ﾋﾞﾙﾄﾞ ｲﾝ ｻﾞ Nix ｽﾄｴﾗ
- Searches `*-ｿｰｽ` directories ﾊﾞｲ hostname
- Identifies ｻﾞ correct ｿｰｽ matching ｻﾞ latest ｼﾞｪﾈﾗｴｰｼｮﾝ
- Restores specified files (flake.nix, flake.lock, individual ﾓｼﾞｭｰﾙs)
- Validates ｻﾞ restored ｺﾝﾌｨｸﾞ ｳｨｽﾞ `nix flake ﾁｪｯｸ`

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ reports accidentally deleting files ｱﾝﾀﾞｰ `/etc/nixos`.
