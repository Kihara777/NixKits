# nixkits-ﾁｪｯｸ-updates (Skill)

[中文](../../zh/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | [偽中国語](../../pcn/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md)

> Checks ｳﾌﾟｽﾄﾗｴｱﾑ updates for all NixKits ﾊﾟｯｹｰｼﾞs and ﾊﾟｯﾁes. Auto-upgrades, syncs docs, writes fixes to ﾒﾝﾃﾅﾝｽ log.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/nixkits-ﾁｪｯｸ-updates/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers all external ﾊﾟｯｹｰｼﾞs from `flake.nix` and ﾁｪｯｸs latest GitHub Releases
- Updates ﾋﾞﾙﾄﾞ configs (ﾊﾞｰｼﾞｮﾝ, source hash, npmDepsHash)
- Syncs ﾊﾞｰｼﾞｮﾝ numbers across all language docs
- Auto-invokes `write-ﾒﾝﾃﾅﾝｽ-log` ｽｷﾙ to write ﾒﾝﾃﾅﾝｽ records after updates
- Reports locally ｲﾝｽﾄｰﾙed ﾊﾞｰｼﾞｮﾝs
- Identifies hardcoded ﾊﾞｰｼﾞｮﾝs inside ﾊﾟｯﾁ files and provides ﾁｪｯｸ guidance

## Hash Gotchas

- SRI hash must use standard base64 (`+` `/` `=`), not URL-safe variant (`-` `_`)
- `fetchFromGitHub` source hash **cannot** be precomputed from the GitHub archive tarball — must come from `nix ﾋﾞﾙﾄﾞ` hash mismatch error
- Use `lib.fakeHash` for empty `npmDepsHash`, not the empty string `""`
- npm ﾊﾟｯｹｰｼﾞs need two `nix ﾋﾞﾙﾄﾞ` passes: first for source hash, second for npmDepsHash

## Scope

Reads `flake.nix` → `ﾊﾟｯｹｰｼﾞs`, excluding:
- Self-hosted ﾊﾟｯｹｰｼﾞs (source in repo)
- Dynamic ﾊﾞｰｼﾞｮﾝ tracking (fetches latest at ﾋﾞﾙﾄﾞ time)
- nixpkgs-following (ﾊﾟｯﾁ ｵｰﾊﾞｰﾚｲs)
- Patch-embedded ﾊﾞｰｼﾞｮﾝs (manual ﾁｪｯｸ, e.g. `comfyui-strix-halo`)

All remaining external ﾊﾟｯｹｰｼﾞs are ﾁｪｯｸed automatically.

## ﾕｰｾｰｼﾞ

Activated when the user asks to "ﾁｪｯｸ for updates" or "update ﾊﾟｯｹｰｼﾞ ﾊﾞｰｼﾞｮﾝs".
