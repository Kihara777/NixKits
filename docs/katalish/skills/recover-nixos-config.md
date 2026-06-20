# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/recover-nixos-config.md)

> Recovers accidentally deleted `/etc/nixos` files ﾌﾛﾑ ｻﾞ Nix store.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/recover-nixos-config/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Locates ｻﾞ flake source snapshot ﾌﾛﾑ ｻﾞ most recent successful ﾋﾞﾙﾄﾞ in ｻﾞ Nix store
- Searches `*-source` directories ﾊﾞｲ hostname
- Identifies ｻﾞ correct source matching ｻﾞ latest generation
- Restores specified files (flake.nix, flake.lock, individual modules)
- Validates ｻﾞ restored config ｳｨｽﾞ `nix flake check`

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ user reports accidentally deleting files under `/etc/nixos`.
