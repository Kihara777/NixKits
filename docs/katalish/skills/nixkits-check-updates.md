# nixkits-ﾁｪｯｸ-updates (Skill)

[中文](../../zh/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md) | [偽中国語](../../pcn/ｽｷﾙs/nixkits-ﾁｪｯｸ-updates.md)

> Checks ｳﾌﾟｽﾄﾗｴｱﾑ updates ﾌｫｱ ｵｰﾙ NixKits ﾊﾟｯｹｰｼﾞs ｱﾝﾄﾞ ﾊﾟｯﾁes. Auto-upgrades, syncs docs, writes fixes ﾄｩ ﾒﾝﾃﾅﾝｽ log.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | Coding Agent Skill |
| Path | `ｽｷﾙs/nixkits-ﾁｪｯｸ-updates/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers ｵｰﾙ external ﾊﾟｯｹｰｼﾞs ﾌﾛﾑ `flake.nix` ｱﾝﾄﾞ ﾁｪｯｸs latest ｷﾞｯﾄﾊﾌﾞ Releases
- Updates ﾋﾞﾙﾄﾞ configs (ﾊﾞｰｼﾞｮﾝ, ｿｰｽ hash, npmDepsHash)
- Syncs ﾊﾞｰｼﾞｮﾝ numbers ｱｸﾛｽ ｵｰﾙ ﾗﾝｹﾞｰｼﾞ docs
- Auto-invokes `write-ﾒﾝﾃﾅﾝｽ-log` ｽｷﾙ ﾄｩ write ﾒﾝﾃﾅﾝｽ records ｱﾌﾀｰ updates
- Reports locally ｲﾝｽﾄｰﾙed ﾊﾞｰｼﾞｮﾝs
- Identifies hardcoded ﾊﾞｰｼﾞｮﾝs inside ﾊﾟｯﾁ files ｱﾝﾄﾞ ﾌﾟﾗｵﾌﾞｲﾃﾞｽﾞ ﾁｪｯｸ guidance

## Hash Gotchas

- SRI hash ﾑｽﾄ ﾕｰｽﾞ standard base64 (`+` `/` `=`), ﾉｯﾄ URL-safe variant (`-` `_`)
- `fetchFromGitHub` ｿｰｽ hash **cannot** ﾋﾞｰ precomputed ﾌﾛﾑ ｻﾞ ｷﾞｯﾄﾊﾌﾞ archive tarball — ﾑｽﾄ ｶﾑ ﾌﾛﾑ `nix ﾋﾞﾙﾄﾞ` hash mismatch error
- Use `lib.fakeHash` ﾌｫｱ empty `npmDepsHash`, ﾉｯﾄ ｻﾞ empty string `""`
- npm ﾊﾟｯｹｰｼﾞs ﾆｰﾄﾞ two `nix ﾋﾞﾙﾄﾞ` passes: ﾌｧｰｽﾄ ﾌｫｱ ｿｰｽ hash, second ﾌｫｱ npmDepsHash

## Scope

Reads `flake.nix` → `ﾊﾟｯｹｰｼﾞs`, excluding:
- Self-hosted ﾊﾟｯｹｰｼﾞs (ｿｰｽ ｲﾝ repo)
- Dynamic ﾊﾞｰｼﾞｮﾝ tracking (fetches latest ｱｯﾄ ﾋﾞﾙﾄﾞ time)
- nixpkgs-following (ﾊﾟｯﾁ ｵｰﾊﾞｰﾚｲs)
- Patch-embedded ﾊﾞｰｼﾞｮﾝs (manual ﾁｪｯｸ, e.g. `comfyui-strix-halo`)

All remaining external ﾊﾟｯｹｰｼﾞs ｱｰ ﾁｪｯｸed ｵｰﾄﾏﾃｨｯｸﾘｰ.

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "ﾁｪｯｸ ﾌｫｱ updates" ｵﾗ "ｱｯﾌﾟﾃﾞｰﾄ ﾊﾟｯｹｰｼﾞ ﾊﾞｰｼﾞｮﾝs".
