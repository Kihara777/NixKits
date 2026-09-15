# 新闻三要素模式 (Agent preset)

[中文](../../zh/modes/news-three-elements.md) | English | [日本語](../../ja/modes/news-three-elements.md)  | [偽中国語](../../pcn/modes/news-three-elements.md)

> A **read-only** creation preset derived from minimal mode: it fabricates Russian-style dispatches in a real news format, where the "three elements of news" **are the three protagonists who must all be on the page** — Bulannikov, Yudintsev and Buyanov — and it fetches the whole skill package online at session initialization.

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

- **Read-only**: only viewing tools are mounted (`read`, `read_image`, `glob`, `grep`, `web_search`, `web_fetch`, `skill`, `ask_user_question`); although `write` / `edit` are in the tool table, every call is refused by `readonly-gate` in news-agency style (deny by default outside the allowlist, so tools added later cannot slip through by accident). Reads are scoped too: an absolute path is allowed only under **the workspace, the attachment store, `/tmp` or the mode's own skill package** (the fetched cache plus the bundled snapshot), and anything else is refused — a relative path is left to the filesystem backend.
- **All three on the page**: in this mode the "three elements of news" are not the journalism textbook three but three real game producers — Bulannikov (War Thunder producer), Yudintsev (Gaijin founder) and Buyanov (Battlestate founder); every dispatch carries all three in its body, and a missing one is a rework. The same holds when the caller supplies material: the material is the fuse, the three are hard configuration.
- **Material first; refuse only what cannot be tied back**: any request touching the three protagonists, the Russian-news shell or game mechanics (industry gossip, a mechanics complaint, a current-affairs question, someone else's joke, a screenshot) is treated as material — research it, then hang it on the three and write the dispatch. **Refusing it because "this is not a fabrication request" is forbidden.** A hypothetical ("what if Buyanov were flagged as eliminated?") is written as something that **already happened** — no counter-question, no argument; an unnamed person ("some producer", "the guy who keeps reworking the economy") is fitted onto one of the three via the identity table, never met with a request to supply a name; thin material is padded with the factual shell only, and is never grounds for refusal.
- **The material is only a fuse — no search, no dispatch** (the hard gate in the `news-material` plugin): the caller's material is a lead, nothing more, and the body must be rewritten from this turn's search — **distil → project → re-skin**, with no run of **eight or more consecutive Han characters** copied out of the caller's own words (only Han characters count, so a Latin game title never trips it; the 「本稿取材」 receipt quotes material on purpose and is excluded). The gate has two halves: before the model writes, the step that admits the human's message carries a 取材铁律 reminder; at delivery (`agent/turn-stopping`, the stop boundary the loop re-reads before it closes the turn) it reads the turn's own log — a turn with **no `web_search` / `web_fetch` call at all, or one that copied the caller's words**, gets a 编辑部退稿 notice steered back at it, which runs another step of the same turn. **One rejection per turn** is the whole budget, so a model that ignores the notice cannot loop. Material means the caller's messages plus the files they pointed the model at (`read` results in that turn); search results are **not** material — reusing a wire-service phrase is the point of the mode.
- **Online skill package**: at session start it fetches the entire repo `skills/news-three-elements/` package (5 files, 8-second cap; a failed fetch retries after 0/30/120 s, and a long session re-checks every 6 hours), registering the freshest local copy first (cache before the bundled snapshot). The five files are fetched **in parallel** with **ETag conditional requests** — an unchanged package answers 304 and nothing is rewritten. The skill package is mounted read-only and dispatches are never written to disk.
- **Opening picker**: once session initialization completes, a three-way picker appears (the client also accepts custom input); the choice becomes the session's first user message through `agent.followup()`. If the caller starts talking before answering, the question is **withdrawn automatically** and that first line becomes the opening instead. A custom answer is always refused with 「请点选上方选项」 — a rule that binds the opening picker alone: once the caller is seated, later questions fall under the material-first rule above.
- **Language review**: any request not in Simplified Chinese is refused (no Han ideograph / kana present / hangul present is hard-detected by the plugin, and **only the human's own messages are judged** — harness-injected approval notices and skill catalogs never count, or one English system line would misread a Simplified-Chinese request as out of scope; Simplified-versus-Traditional judgement is left to the model, after a deliberately narrow Traditional-only character test). The refusal is written in Chinese wire style and then **followed, 《with good will》, by a localized version of the same refusal** — that translation appears **only when the language gate is what triggered the refusal**, and **in the very language the caller used** (English for English, Japanese for Japanese, Traditional Chinese for Traditional Chinese; never swapped for a third language). A refusal aimed at a Simplified-Chinese caller carries **no translation at all** — the language was legitimate, so there is nothing to translate. The nudge to learn Chinese is **drawn fresh every time**, and what is drawn is a **person**: one of the three producers, with the game following the person — Yudintsev and Bulannikov point at "War Thunder", Buyanov at "Escape from Tarkov" — plus the 「绿色的猫头鹰」 software, four equally likely entries, never more than one per refusal and **never the same one twice running** (the entry just drawn is excluded from the next draw). 「绿色的猫头鹰」 may be shortened to 「绿毛鸡」 where the context fits.
- **Refusal material is sourced on the spot**: only a request that the rule above leaves untied enters the refusal flow; every refusal (the language-gate one included) searches the web first — that day's real news phrasing, official excuses, agency statements — and may not reuse the previous refusal's reason, sentence pattern or closing twist; mechanical repetition counts as this mode's worst failure, and the deadpan 「一本正经胡说八道」 tone is what it is delivered in.

## Composition Structure

| Row | Source | Purpose |
|------|------|------|
| `persona` (`complete: true`) | dsh built-in | the only source of prompt text: the read-only boundary, the definition of the three, the material-first test, the opening picker's code table, asset co-creation, the refusal lines |
| `tool-fs` / `tool-fs-search` / `tool-web` / `tool-skill` / `tool-ask-user` | dsh built-in | the read-only surface |
| `news-skill` / `news-opening` / `news-language` / `news-material` / `readonly-gate` | this package's `plugins/*.js` | online fetching, opening picker, language gate, sourcing gate (no search, no dispatch), read-only guard |

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
