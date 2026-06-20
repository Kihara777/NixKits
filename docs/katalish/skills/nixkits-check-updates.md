# nixkits-check-updates (ｽｷﾙ)

[中文](../../zh/skills/nixkits-check-updates.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../../ja/skills/nixkits-check-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-check-updates.md) | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> Checks upstream updates for all NixKits packages and patches. Auto-upgrades, syncs docs, writes fixes to maintenance log.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/nixkits-check-updates/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- ｵｰﾄ-ﾃﾞｨｽｶﾊﾞｰｽﾞ ｵｰﾙ external ﾊﾟｯｹｰｼﾞｰｽﾞ ﾌﾛﾑ `flake.nix` ｱﾝﾄﾞ checks latest GitHub Releases
- ｱｯﾌﾟﾃﾞｰﾄｽﾞ ﾋﾞﾙﾄﾞ ｺﾝﾌｨｸﾞｽﾞ (ﾊﾞｰｼﾞｮﾝ, ｿｰｽ hash, npmDepsHash)
- Syncs ﾊﾞｰｼﾞｮﾝ ﾅﾝﾊﾞｰｽﾞ across ｵｰﾙ ﾗﾝｹﾞｰｼﾞ ﾄﾞｷｭｽﾞ
- ｵｰﾄ-invokes `write-maintenance-log` ｽｷﾙ ﾄｩ ﾗｲﾄ maintenance records after ｱｯﾌﾟﾃﾞｰﾄｽﾞ
- Reports locally ｲﾝｽﾄｰﾙﾄﾞ ﾊﾞｰｼﾞｮﾝｽﾞ
- Identifies hardcoded ﾊﾞｰｼﾞｮﾝｽﾞ inside ﾊﾟｯﾁ files ｱﾝﾄﾞ provides check guidance

## Hash Gotchas

- SRI hash ﾏｽﾄ use standard base64 (`+` `/` `=`), ﾉｯﾄ ﾕｰｱｰﾙｴﾙ-safe variant (`-` `_`)
- `fetchFromGitHub` ｿｰｽ hash **cannot** ﾋﾞｰ precomputed ﾌﾛﾑ ｻﾞ GitHub archive tarball — ﾏｽﾄ come ﾌﾛﾑ `nix build` hash mismatch error
- Use `lib.fakeHash` ﾌｫｱ empty `npmDepsHash`, ﾉｯﾄ ｻﾞ empty string `""`
- npm ﾊﾟｯｹｰｼﾞｰｽﾞ need two `nix build` passes: first ﾌｫｱ ｿｰｽ hash, second ﾌｫｱ npmDepsHash

## Scope

ﾘｰﾄﾞｽﾞ `flake.nix` → `packages`, excluding:
- Self-hosted ﾊﾟｯｹｰｼﾞｰｽﾞ (ｿｰｽ ｲﾝ repo)
- ﾀﾞｲﾅﾐｯｸ ﾊﾞｰｼﾞｮﾝ tracking (fetches latest ｱｯﾄ ﾋﾞﾙﾄﾞ time)
- nixpkgs-following (ﾊﾟｯﾁ ｵｰﾊﾞｰﾚｲｽﾞ)
- ﾊﾟｯﾁ-embedded ﾊﾞｰｼﾞｮﾝｽﾞ (manual check, e.g. `comfyui-strix-halo`)

ｵｰﾙ remaining external ﾊﾟｯｹｰｼﾞｰｽﾞ ｱｰ checked automatically.

## ﾕｰｾｰｼﾞ

Activated when ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "check ﾌｫｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ" ｵｱ "ｱｯﾌﾟﾃﾞｰﾄ ﾊﾟｯｹｰｼﾞ ﾊﾞｰｼﾞｮﾝｽﾞ".