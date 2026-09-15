# 新闻三要素模式 (Agent preset)

[中文](../../zh/modes/news-three-elements.md) | English | [日本語](../../ja/modes/news-three-elements.md)  | [偽中国語](../../pcn/modes/news-three-elements.md)

> A **read-only** creation preset derived from minimal mode: it fabricates Russian-style dispatches carrying the "three elements of news" in a real news format, and fetches the whole skill package online at session initialization.

## Basic Info

| Item | Value |
|------|-------|
| Mode id | `news-three-elements` |
| Distribution | **standalone package** `dsh-preset-news-three-elements` (`packages/dsh-preset-news-three-elements.nix`); the module registers its `$out/share/dsh-agent-presets` as an extra preset root of the roster |
| Enable option | `nixkits.dsh.presets.newsThreeElements = true` |
| Optional package override | `nixkits.dsh.presets.newsThreeElementsPackage` (defaults to `pkgs.dsh-preset-news-three-elements`) |
| Derived from | minimal mode (the `minimal` preset shipped with dsh) |
| Skill dependency | the repo's `skills/news-three-elements/` (fetched online at session start, with the bundled copy as fallback) |

## Behavior

**Combined TASS, Meduza and iStories dispatch** — according to the repository's engineering desk, this mode does exactly one thing: fabricate dispatches per the skill. The remaining behavior:

- **Read-only**: only viewing tools are mounted (`read`, `read_image`, `glob`, `grep`, `web_search`, `web_fetch`, `skill`, `ask_user_question`); although `write` / `edit` are in the tool table, every call is refused by `readonly-gate` in news-agency style (deny by default outside the allowlist, so tools added later cannot slip through by accident).
- **Online skill package**: at session start it fetches the entire repo `skills/news-three-elements/` package (5 files, 8-second cap; a failed fetch retries after 0/30/120 s, and a long session re-checks every 6 hours), registering the freshest local copy first (cache before the bundled snapshot). The skill package is mounted read-only and dispatches are never written to disk.
- **Opening picker**: once session initialization completes, a three-way picker appears (the client also accepts custom input); the choice becomes the session's first user message through `agent.followup()`.
- **Language review**: any request not in Simplified Chinese is refused (no Han ideograph / kana present / hangul present is hard-detected by the plugin; Simplified-versus-Traditional judgement is left to the model). The refusal is written in Chinese wire style and is then **followed, 《with good will》, by a localized version of the same refusal in the user's own language** — the same refusal translated, carrying the same emphasis on 「我们从不制造 FAKE NEWS！！」 and the same self-styling. The nudge to learn Chinese is **drawn fresh every time**, and what is drawn is a **person**: one of the three producers, with the game following the person — Yudintsev and Bulannikov point at "War Thunder", Buyanov at "Escape from Tarkov" — plus the 「绿色的猫头鹰」 software, four equally likely entries, never more than one per refusal. 「绿色的猫头鹰」 may be shortened to 「绿毛鸡」 where the context fits.
- **Refusal material is sourced on the spot**: every refusal (the language-gate one included) searches the web first — that day's real news phrasing, official excuses, agency statements — and may not reuse the previous refusal's reason, sentence pattern or closing twist; mechanical repetition counts as this mode's worst failure, and the deadpan 「一本正经胡说八道」 tone is what it is delivered in.

## Composition Structure

| Row | Source | Purpose |
|------|------|------|
| `persona` (`complete: true`) | dsh built-in | the only source of prompt text: the read-only boundary, the opening picker's code table, asset co-creation, the refusal lines |
| `tool-fs` / `tool-fs-search` / `tool-web` / `tool-skill` / `tool-ask-user` | dsh built-in | the read-only surface |
| `news-skill` / `news-opening` / `news-language` / `readonly-gate` | this package's `plugins/*.js` | online fetching, opening picker, language gate, read-only guard |

The package's plugins are mounted by **relative row names** (`./plugins/*.js`) — a composition's `baseUrl` is the preset directory, and the plugins import nothing but Node builtins, so the whole directory keeps resolving after being placed in the store, with no node_modules needed.

## Install

```nix
{
  nixkits.dsh.presets = {
    newsThreeElements = true;
    # Optional: swap in a self-built/overridden preset package
    # newsThreeElementsPackage = pkgs.dsh-preset-news-three-elements;
  };
}
```

Once `nix flake check` passes and `nixos apply` completes, 新闻三要素模式 appears in the session mode selector immediately.

## Notes

- **No copy, no seeding**: the preset is read straight from the package's store path (`trust: system`), and there is **no** copy of it under `$DSH_HOME/.agent-presets` — an upgrade is the update, no re-seeding needed. Config roots are scanned before user roots, so a same-id entry resolves to this package.
- **To change it**: use the roster's `copy()` (or copy the directory by hand) to save it as a new user preset id, and edit the copy; dropping a same-named directory into the user root does not take effect.
- The package's `news-skill` plugin writes the fetched skill package to `$DSH_HOME/.cache/news-three-elements/` — its only write operation.
