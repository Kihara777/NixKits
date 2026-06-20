# recover-nixos-config (Skill)

[中文](../../zh/ｽｷﾙs/recover-nixos-config.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/recover-nixos-config.md) | [偽中国語](../../pcn/ｽｷﾙs/recover-nixos-config.md)

> Recovers accidentally deleted `/etc/nixos` files from the Nix store.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/recover-nixos-config/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Locates the flake source snapshot from the most recent successful ﾋﾞﾙﾄﾞ in the Nix store
- Searches `*-source` directories by hostname
- Identifies the correct source matching the latest generation
- Restores specified files (flake.nix, flake.lock, individual ﾓｼﾞｭｰﾙs)
- Validates the restored config with `nix flake ﾁｪｯｸ`

## ﾕｰｾｰｼﾞ

Activated when the user reports accidentally deleting files under `/etc/nixos`.
