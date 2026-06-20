# nixkits-check-updates (ｽｷﾙ)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md)

> Checks ｵｰﾙ NixKits ﾊﾟｯｹｰｼﾞｰｽﾞ ｱﾝﾄﾞ ﾊﾟｯﾁｰｽﾞ ﾌｫｱ upstream ｱｯﾌﾟﾃﾞｰﾄｽﾞ, applies ﾊﾞｰｼﾞｮﾝ bumps ｱﾝﾄﾞ ﾄﾞｷｭ sync.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/nixkits-check-updates/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers ｵｰﾙ external ﾊﾟｯｹｰｼﾞｰｽﾞ ﾌﾛﾑ `flake.nix` ｱﾝﾄﾞ checks latest GitHub Releases
- ｱｯﾌﾟﾃﾞｰﾄｽﾞ ﾋﾞﾙﾄﾞ configs (ﾊﾞｰｼﾞｮﾝ, ｿｰｽ ﾊｯｼｭ, npmDepsHash)
- Syncs ﾊﾞｰｼﾞｮﾝ numbers across ｵｰﾙ 3 ﾗﾝｹﾞｰｼﾞ ﾄﾞｷｭｽﾞ
- Auto-invokes `write-maintenance-log` ｽｷﾙ ﾄｩ ﾗｲﾄ ﾒﾝﾃﾅﾝｽ records ｱﾌﾀｰ ｱｯﾌﾟﾃﾞｰﾄｽﾞ
- Reports locally installed versions
- Identifies hardcoded versions inside ﾊﾟｯﾁ ﾌｧｲﾙｽﾞ ｱﾝﾄﾞ ﾌﾟﾛﾊﾞｲﾄﾞｽﾞ ﾁｪｯｸ guidance

## ﾊｯｼｭ Gotchas

- SRI ﾊｯｼｭ ﾏｽﾄ ﾕｰｽﾞ standard base64 (`+` `/` `=`), ﾉｯﾄ URL-safe variant (`-` `_`)
- `fetchFromGitHub` ｿｰｽ ﾊｯｼｭ **cannot** ﾋﾞｰ precomputed ﾌﾛﾑ ｻﾞ GitHub archive tarball — ﾏｽﾄ come ﾌﾛﾑ `nix build` ﾊｯｼｭ mismatch ｴﾗｰ
- ﾕｰｽﾞ `lib.fakeHash` ﾌｫｱ empty `npmDepsHash`, ﾉｯﾄ ｻﾞ empty string `""`
- npm ﾊﾟｯｹｰｼﾞｰｽﾞ ﾆｰﾄﾞ two `nix build` passes: ﾌｧｰｽﾄ ﾌｫｱ ｿｰｽ ﾊｯｼｭ, second ﾌｫｱ npmDepsHash

## Scope

Reads `flake.nix` → `packages`, excluding:
- Self-hosted ﾊﾟｯｹｰｼﾞｰｽﾞ (ｿｰｽ ｲﾝ repo)
- ﾀﾞｲﾅﾐｯｸ ﾊﾞｰｼﾞｮﾝ tracking (fetches latest ｱｯﾄ ﾋﾞﾙﾄﾞ time)
- nixpkgs-following (ﾊﾟｯﾁ overlays)
- Patch-embedded versions (manual ﾁｪｯｸ, e.g. `comfyui-strix-halo`)

ｵｰﾙ remaining external ﾊﾟｯｹｰｼﾞｰｽﾞ ｱｰ checked automatically.

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "ﾁｪｯｸ ﾌｫｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ" ｵｱ "ｱｯﾌﾟﾃﾞｰﾄ ﾊﾟｯｹｰｼﾞ versions".