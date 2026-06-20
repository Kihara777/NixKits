# nixkits-ﾁｪｯｸ-updates (Skill)

[中文](../../zh/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | [偽中国語](../../pcn/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md)

> Checks ｳﾌﾟｽﾄﾗｴｱﾑ updates ﾌｫｱ ｵｰﾙ NixKits ﾊﾟｯｹｰｼﾞs ｱﾝﾄﾞ ﾊﾟｯﾁes. Auto-upgrades, syncs docs, writes fixes ﾄｩ ﾒﾝﾃﾅﾝｽ log.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/nixkits-ﾁｪｯｸ-updates/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers ｵｰﾙ external ﾊﾟｯｹｰｼﾞs ﾌﾛﾑ `flake.nix` ｱﾝﾄﾞ ﾁｪｯｸs latest ｷﾞｯﾄﾊﾌﾞ Releases
- Updates ﾋﾞﾙﾄﾞ configs (ﾊﾞｰｼﾞｮﾝ, source hash, npmDepsHash)
- Syncs ﾊﾞｰｼﾞｮﾝ numbers across ｵｰﾙ language docs
- Auto-invokes `write-ﾒﾝﾃﾅﾝｽ-log` ｽｷﾙ ﾄｩ write ﾒﾝﾃﾅﾝｽ records after updates
- Reports locally ｲﾝｽﾄｰﾙed ﾊﾞｰｼﾞｮﾝs
- Identifies hardcoded ﾊﾞｰｼﾞｮﾝs inside ﾊﾟｯﾁ files ｱﾝﾄﾞ ﾌﾟﾗｵﾌﾞｲﾃﾞｽﾞ ﾁｪｯｸ guidance

## Hash Gotchas

- SRI hash must ﾕｰｽﾞ standard base64 (`+` `/` `=`), ﾉｯﾄ URL-safe variant (`-` `_`)
- `fetchFromGitHub` source hash **cannot** be precomputed ﾌﾛﾑ ｻﾞ ｷﾞｯﾄﾊﾌﾞ archive tarball — must come ﾌﾛﾑ `nix ﾋﾞﾙﾄﾞ` hash mismatch error
- Use `lib.fakeHash` ﾌｫｱ empty `npmDepsHash`, ﾉｯﾄ ｻﾞ empty string `""`
- npm ﾊﾟｯｹｰｼﾞs need two `nix ﾋﾞﾙﾄﾞ` passes: ﾌｧｰｽﾄ ﾌｫｱ source hash, second ﾌｫｱ npmDepsHash

## Scope

Reads `flake.nix` → `ﾊﾟｯｹｰｼﾞs`, excluding:
- Self-hosted ﾊﾟｯｹｰｼﾞs (source ｲﾝ repo)
- Dynamic ﾊﾞｰｼﾞｮﾝ tracking (fetches latest ｱｯﾄ ﾋﾞﾙﾄﾞ time)
- nixpkgs-following (ﾊﾟｯﾁ ｵｰﾊﾞｰﾚｲs)
- Patch-embedded ﾊﾞｰｼﾞｮﾝs (manual ﾁｪｯｸ, e.g. `comfyui-strix-halo`)

All remaining external ﾊﾟｯｹｰｼﾞs are ﾁｪｯｸed automatically.

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "ﾁｪｯｸ ﾌｫｱ updates" ｵﾗ "update ﾊﾟｯｹｰｼﾞ ﾊﾞｰｼﾞｮﾝs".
