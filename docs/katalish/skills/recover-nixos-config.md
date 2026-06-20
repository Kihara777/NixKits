# recover-ﾆｯｸｽOS-config (ｽｷﾙ)

[中文](../../zh/skills/recover-nixos-config.md) | [English](recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/recover-nixos-config.md) | [偽中国語](../../pcn/skills/recover-nixos-config.md)

> Recovers accidentally deleted `/etc/nixos` files from the Nix store.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/recover-nixos-config/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Locates ｻﾞ flake ｿｰｽ snapshot ﾌﾛﾑ ｻﾞ most recent successful ﾋﾞﾙﾄﾞ ｲﾝ ｻﾞ ﾆｯｸｽ store
- Searches `*-source` directories ﾊﾞｲ hostname
- Identifies ｻﾞ correct ｿｰｽ matching ｻﾞ latest generation
- Restores specified files (flake.ﾆｯｸｽ, flake.lock, individual ﾓｼﾞｭｰﾙｽﾞ)
- Validates ｻﾞ restored ｺﾝﾌｨｸﾞ ｳｨｽﾞ `nix flake check`

## ﾕｰｾｰｼﾞ

Activated when ｻﾞ ﾕｰｻﾞｰ reports accidentally deleting files under `/etc/nixos`.