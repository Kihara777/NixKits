# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> Checks ｳﾌﾟｽﾄﾗｴｱﾑ updates ﾌｫｱ ｵｰﾙ NixKits packages ｱﾝﾄﾞ patches. Auto-upgrades, syncs docs, writes fixes to ﾒﾝﾃﾅﾝｽ log.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-check-updates/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers ｵｰﾙ external packages ﾌﾛﾑ `flake.nix` ｱﾝﾄﾞ checks latest ｷﾞｯﾄﾊﾌﾞ Releases
- Updates ﾋﾞﾙﾄﾞ configs (ﾊﾞｰｼﾞｮﾝ, source hash, npmDepsHash)
- Syncs ﾊﾞｰｼﾞｮﾝ numbers across ｵｰﾙ ﾗﾝｹﾞｰｼﾞ docs
- Auto-invokes `write-ﾒﾝﾃﾅﾝｽ-log` skill to write ﾒﾝﾃﾅﾝｽ records after updates
- Reports locally installed versions
- Identifies hardcoded versions inside ﾊﾟｯﾁ files ｱﾝﾄﾞ provides check guidance

## Hash Gotchas

- SRI hash must ﾕｰｽﾞ standard base64 (`+` `/` `=`), ﾉｯﾄ URL-safe variant (`-` `_`)
- `fetchFromGitHub` source hash **cannot** be precomputed ﾌﾛﾑ ｻﾞ ｷﾞｯﾄﾊﾌﾞ archive tarball — must come ﾌﾛﾑ `nix ﾋﾞﾙﾄﾞ` hash mismatch error
- Use `lib.fakeHash` ﾌｫｱ empty `npmDepsHash`, ﾉｯﾄ ｻﾞ empty string `""`
- npm packages need two `nix ﾋﾞﾙﾄﾞ` passes: ﾌｧｰｽﾄ ﾌｫｱ source hash, second ﾌｫｱ npmDepsHash

## Scope

Reads `flake.nix` → `packages`, excluding:
- Self-hosted packages (source in repo)
- Dynamic ﾊﾞｰｼﾞｮﾝ ﾄﾗｯｷﾝｸﾞ (fetches latest at ﾋﾞﾙﾄﾞ time)
- nixpkgs-following (ﾊﾟｯﾁ overlays)
- Patch-embedded versions (manual check, e.g. `comfyui-strix-halo`)

All remaining external packages ｱｰ checked ｵｰﾄﾏﾃｨｯｸﾘｰ.

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ user asks to "check ﾌｫｱ updates" ｵﾗ "update ﾊﾟｯｹｰｼﾞ versions".
