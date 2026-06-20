# recover-nixos-config (ｽｷﾙ)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](recover-nixos-config.md) | [偽中国語](../../pcn/skills/recover-nixos-config.md)

> Recovers accidentally deleted `/etc/nixos` ﾌｧｲﾙｽﾞ ﾌﾛﾑ ｻﾞ ﾆｯｸｽ store.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/recover-nixos-config/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Locates ｻﾞ ﾌﾚｲｸ ｿｰｽ snapshot ﾌﾛﾑ ｻﾞ most recent successful ﾋﾞﾙﾄﾞ ｲﾝ ｻﾞ ﾆｯｸｽ store
- Searches `*-source` directories ﾊﾞｲ hostname
- Identifies ｻﾞ correct ｿｰｽ matching ｻﾞ latest ｼﾞｪﾈﾚｰｼｮﾝ
- Restores specified ﾌｧｲﾙｽﾞ (ﾌﾚｲｸ.ﾆｯｸｽ, ﾌﾚｲｸ.ﾛｯｸ, individual ﾓｼﾞｭｰﾙｽﾞ)
- Validates ｻﾞ restored ｺﾝﾌｨｸﾞ ｳｨｽﾞ `nix flake check`

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ reports accidentally deleting ﾌｧｲﾙｽﾞ under `/etc/nixos`.