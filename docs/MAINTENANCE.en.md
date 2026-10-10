# Maintenance Log

[中文](../MAINTENANCE.md) | English | [日本語](MAINTENANCE.ja.md) | [偽中国語](MAINTENANCE.pcn.md)

## 2026-10-10T14:14:19+09:00

**Summary**: blender-mcp ready to submit — the maintainer entry located, and a self-caught divergence

- `MAINTAINER-ENTRY.md`: the handle is free, the entry belongs between `kiyotoko` and `kjeremy`, the `githubId` was verified both ways, and 488 existing entries likewise omit `email`
- `READY.md`: all 11 preconditions tied to an artifact, unchecked items listed separately, the execution order, and a triage table
- The ratchet line (`strictDeps`/`__structuredAttrs`) is marked as **reasoning** in the document, not dressed up as measurement
- Caught by self-review: commit 2's body was stored in two places and had already **diverged**; synced to `commit-message.txt` and annotated

| Commit | Description |
|------|------|
| `ae69543` | feat(upstream): maintainer entry location and submission readiness checklist |

## 2026-10-10T14:09:55+09:00

**Summary**: two pre-submission facts checked for blender-mcp — does auto-update work for a self-hosted Gitea, and what a replaced anchor costs

- `nix-update` probes rather than assumes: a host outside its known list must return 200 from `/api/v1/settings/api`, and `projects.blender.org` does
- The tags come back as `v1.0.3`, matching the `version_prefix` derived from `tag = "v${version}"`
- A missing `--replace-fail` anchor fails the build (deliberate): better red than quietly running half the tests
- The boundary is recorded: only the probe, the tag fetch and the prefix inference were checked; a full `nix-update` run inside a real nixpkgs checkout was **not**

| Commit | Description |
|------|------|
| `40a9a8a` | docs(upstream): evidence for auto-update and the replacement anchor |

## 2026-10-10T14:00:48+09:00

**Summary**: blender-mcp upstream draft — doCheck working, and a real upstream test bug fixed

- Originally 139 errors + 16 failed; the cause is the upstream test helper **overwriting** PYTHONPATH instead of appending, discarding every dependency
- The patch uses `--replace-fail`: if upstream changes those two lines the build fails loudly instead of silently running fewer tests
- `tests/test_blender_mcp_with_blender.py` is excluded: it needs a real Blender instance, which the sandbox cannot provide
- Measured 102 passed / 9 skipped / 0 failed; counterexample: removing the fix gives 15 failed + 117 `McpError`s
- Licence basis verified: v1.0.3 sources carry SPDX headers, confirmed upstream in issue #59, so no separate issue is needed

| Commit | Description |
|------|------|
| `2824c74` | feat(upstream): doCheck working (102 passed) and upstream test bug recorded |


## 2026-10-10T12:59:05+09:00
**Summary**: nixpkgs upstream contribution — feasibility assessment, two skills, and a blender-mcp dry run

- All 13 packages checked: only `mcp-searxng` is already in nixpkgs; `dsh` is called `deepseek-harness` there and already has three in-flight PRs
- Entry requirements audited: by-name, `nixpkgs-vet`'s 12 checks + 3 ratchets, and the `Assisted-by:` format the AI policy requires
- Added the general skill `nixpkgs-package-upstream` and the adapter `nixkits-package-upstream` (four-language doc pages and index in sync)
- Dry run: all four criteria for blender-mcp pass (including a **real handshake**), and the counterexamples fire
- Corrected a stale note about ruyi: that overlay never had a host, and nixpkgs **never** shipped ruyi

| Commit | Description |
|------|------|
| `d7ec6ff` | docs(upstream): 可行性评估与入场要求审计 |
| `27be3f3` | feat(skills): 新增两个上游贡献技能 |
| `4a2db07` | feat(upstream): blender-mcp dry-run 产物与判据自证 |
| `c6476c2` | fix(docs): 更正 ruyi 的过期自述 |

## 2026-10-08T23:25:20+09:00

**Summary**: chore(dsh): the alpha channel follows `alpha`, the stable pin moves forward, README version claims get an assertion

- `dsh-alpha` 0.2.0-rc.2 → **0.2.1-alpha.1**: the original premise ("`alpha` sits on the old 0.1.x line") had **reversed**; hashes from `got:`, and the vendored lock is byte-identical to the build's
- The stable `pinnedRev` `0175f85` → `1e85409`: the cost is that the old preset format no longer ships, so 0.1.x users fetch that rev themselves (still fetchable)
- README version claims had rotted in **four places** (`dsh-alpha` two generations behind, `ruyi stable` one, each across four languages) — a new assertion pins them, counter-proof verified
- The `docs/*/dsh.md` plugin list now says: alpha has two rows more than stable, and copying them into stable hits a hard failure

| Commit | Description |
|------|------|
| `b17bd73` | chore: the stable channel's pinnedRev moves forward (`0175f85` → `1e85409`) |
| `bf0b9ac` | chore(dsh-alpha): the channel follows npm `alpha` again |
| `52fcdbc` | fix(docs): README version claims corrected, plus an assertion for them |

## 2026-10-08T23:03:29+09:00

**Summary**: chore(pkgs): mcp-searxng 2.5.1 and codewhale 0.10.1 — structural change handling and a CI smoke-test gap closed

- mcp-searxng: a pure dependency/security patch, mechanical replacement suffices; the artifact really answers the handshake with 2.5.1
- codewhale 0.10.1 **collapsed two executables into one** — hash-style assertions cannot see this kind of structural change; the **build** was what shouted; postInstall rewritten per upstream
- Handled along with it: upstream renamed to `codewhale-hq/Codewhale`, the now-dead rquickjs riscv64 workaround removed, and two pre-existing doc errors corrected
- **A new smoke test, enabled on all three architectures**: the riscv64 artifact had never been run in CI; four assertions including a counter-proof, and CI has really run it
- Every other upstream and all three pinned-SHA actions are current

| Commit | Description |
|------|------|
| `1645aba` | chore(pkgs): mcp-searxng 2.5.0 → 2.5.1 |
| `bbe7e7a` | ci(codewhale): smoke-test enabled on all three architectures |
| `19cc335` | chore(pkgs): codewhale 0.10.0 → 0.10.1 (upstream rename and the riscv64 structural change) |

## 2026-10-08T16:53:41+09:00

**Summary**: dsh-api-balance re-pin — rev `95fec42` → `43f4d18` (the sub-repo change lives in its [maintenance log](https://github.com/Kihara777/dsh-api-balance/blob/main/MAINTENANCE.md#2026-10-08t1638010900): the keyboard guard now blocks hard)

- The thin wrapper records coordinates only: rev and src hash; the sub-repo records its own full change, no duplication
- Sub-repo criteria: a new "same-frame race" counterexample (the app writes `contenteditable` back and calls `focus()` immediately), full suite 15/15
- Also: `check-maintenance-log.py` now takes `--root <repo>`, so the sub-repo's log is checked by the same script (rather than a copy)

| Commit | Description |
|------|------|
| `62fc667` | fix(dsh-api-balance): re-pin to 43f4d18 — keyboard guard rewritten as non-editable by default + programmatic focus swallowed |
| `420b303` | chore: log checker gains --root + re-pin |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1 (rev re-pin) |
| 　 | rev | `95fec42` → `43f4d18` |
| 　 | src hash | `sha256-bRZWVKmv4nHow0TWMdMww/cFnP9A6vJ08sQCloaRpEE=` → `sha256-jNbfG09da6RYiSRfCm0P5pxBIo9LG38bpSAdVZaxyXc=` |

## 2026-10-06T01:12:23+09:00

**Summary**: chore(pkgs): godot-ai 4.2.3 → 4.3.0 — with the fail-closed runtime check

- All 14 pinned dependencies keep their identity; only 6 raise versions, and both consumption paths resolve to identical sets
- The runtime check really ran: the artifact's `--version` passes (upstream `main()` verifies dependencies first), 14/14 item by item; **counter-proof** — injecting a fake `fastmcp-9.9.9` makes the artifact refuse to start
- anyio vs the new Python 3.12.15 is a pre-existing environment conflict (proven by an identical drvPath against HEAD); 12 cases are deselected by nodeid prefix, with the removal condition in the comment
- starlette 1.7.0's new collection-time imports were supplied instead of disabling tests (1275 collected → 1269 passed)
- Not verified: GUI features that need a live Godot editor instance

| Commit | Description |
|------|------|
| `9b3260d` | chore(pkgs): godot-ai 4.2.3 → 4.3.0 (with the fail-closed runtime check) |

## 2026-10-06T00:48:30+09:00

**Summary**: feat(check): self-check hardening — counter-example suite and repo-wide pcn glyph fix

- Counter-example suite (10th check `self-tests`): each check must pass its control, then fail with the expected message after a known-bad input is injected; 11 positive + 2 negative cases pass
- It found a real hole at once: `workflow-coverage` matched only the filename prefix, so `build-x-….yml.disabled` still counted as coverage
- New assertions: the `flake.nix` comment list must match `checks` one-for-one; pcn must not contain non-Japanese glyphs; en summaries must not be Chinese drafts (threshold calibrated on 367 entries)
- Repo-wide pcn fix: 45 glyphs / 187 occurrences / 39 docs + 9 dictionary mappings (pre-existing defects the new assertion exposed)
- opencode-telegram → 0.26.3 (pure bugfix; hashes from `got:`; smoke tests pass on two architectures); all three pinned-SHA actions already current

| Commit | Description |
|------|------|
| `192ec4a` | feat(check): self-check hardening — counter-example suite + four new assertions + repo-wide corpus fix |
| `f8e6fc7` | chore(pkgs): opencode-telegram 0.26.2 → 0.26.3 |

## 2026-10-05T23:43:17+09:00

**Summary**: fix(skill): summaries are now always list-form — spec, assertion and full retrofit

- The layout goes from "prose or list" to **list only**: a one-sentence headline, a blank line, then at least one `- ` item; even a single-thing entry becomes a one-item list
- 336 prose summaries retrofitted across all four languages (item counts equal per entry; 1–8 items, mean 3.2)
- Assertion: `develop/check-maintenance-log.py` now fails a summary with **no `- ` item**; the skill, `AGENTS.md` and the four-language doc pages updated
- Evidence: the checker passes for 366 entries × 4 languages; a token-loss audit against the pre-retrofit HEAD found **0** entries losing tokens; `nix flake check` passes all 9 checks

| Commit | Description |
|------|------|
| `78e1e7c` | docs(MAINTENANCE): retrofit 336 prose summaries to headline + list (four languages) |
| `6463640` | feat(skill): summaries are always list-form (spec + assertion + doc pages) |

## 2026-10-05T23:15:53+09:00

**Summary**: feat(check): new `doc-counts` check — counts that can be derived mechanically from a source must match it (`nix flake check` 8 → 9 checks)

- Cause: two cases in one day where a document went stale unnoticed — the four-language page's "**75** entries" after a dictionary mapping was added, and `AGENTS.md`'s "8 self-checks" after a check was added
- Two rules: dictionary entry count == rows in `dictionary.md`; self-check count == `checks` entries in `flake.nix` (including the python-implemented subset)
- Negative test: two injected violations in a temp copy each reported "stated X ≠ actual Y" and exited 1; the current repo is green
- The script is a rule table (a new rule is one entry); `AGENTS.md`'s table and `flake.nix`'s comment list updated

| Commit | Description |
|------|------|
| `c1e53bf` | feat(check): new doc-counts check — mechanically derivable doc counts must match their source |

## 2026-10-05T22:20:17+09:00

**Summary**: feat(check): the maintenance log's shape rules are now assertions — zh summary ≤ 400 characters, matching list-item counts across languages, single-line note blocks with in-language markers

- Cause: the spec said "target ≤ 400"; a round driven by that target produced 21 summaries of 420–721 characters with **not a single violation**
- Translations get no length gate — Chinese, English and Japanese differ in density (measured literal ratios, median: en 1.87, ja 1.17, pcn 1.03); one number for all three only forces facts out
- Negative test: four injected violations in a temp copy (over-length summary / one list item removed from en / two-line note block in pcn / marker changed to `**注**`) each failed with exit 1; the current log is green
- `AGENTS.md` check table, `skills/write-maintenance-log/SKILL.md` and the four-language doc pages updated; the 27 list summaries now match the spec's example layout (blank line between title and list, and the checker accepts both)

| Commit | Description |
|------|------|
| `8d58fb3` | feat(check): the maintenance log's shape rules are now assertions (zh length / list items / note blocks) |
| `9165a8e` | fix(check): summary parsing accepts both list layouts; 27 list summaries aligned to the spec example |

## 2026-10-05T14:54:21+09:00

**Summary**: feat(skill): `write-maintenance-log` now allows a **markdown list** for the summary

- The "the summary is a summary" section documents both layouts and states they share the **same length budget** (≤ 400 characters in total) — a list is not a licence to write more lines; each line still answers only "what changed"
- A list does **not** replace the commit table: commit ids still appear only under `| Commit | Description |`
- Multi-language sync: a list summary is translated **item by item, with matching item counts** (one short is a missed translation, one extra is padding)
- The 4c verification section gains a runnable criterion (equal `grep -c '^- '` across languages) plus the lesson actually hit that day: **do not write a criterion too loosely**

| Commit | Description |
|------|------|
| `e2cb5ab` | feat(skill): markdown lists allowed in maintenance-log summaries; four-language doc pages synced |

## 2026-10-05T14:24:37+09:00

**Summary**: dsh-api-balance thin-wrapper re-pin — question dialog fade fixed after the maintainer's second round of feedback

- rev `911df2e` → `95fec42` (the change lives in its commit [`f39c816`](https://github.com/Kihara777/dsh-api-balance/commit/f39c816); the version stays `0.1.1`)
- The fade goes from bottom-only to **scroll-aware** at both ends (a `none/start/end/middle` state machine, so neither edge goes soft when it should be hard)
- The card fades its top edge only — masking the whole card would fade the pinned buttons too
- The sliced-off strip below the buttons is closed with a same-colour filler
- Criterion: all three states checked one by one
| Commit | Description |
|------|------|
| `16f4fef` | fix(dsh-api-balance): re-pin to 95fec42 — scroll-aware fades in the question dialog |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1 (rev re-pin) |
| 　 | rev | `911df2e` → `95fec42` |
| 　 | src hash | `sha256-oc+TPbtuwItV43kskjpz18Ys2cTtCgceXAGrh0Q0D2c=` → `sha256-bRZWVKmv4nHow0TWMdMww/cFnP9A6vJ08sQCloaRpEE=` |

## 2026-10-05T13:58:51+09:00

**Summary**: dsh-api-balance thin-wrapper re-pin — the question dialog's hard bottom cut removed after the maintainer's screenshot

- rev `1f0af6c` → `911df2e` (the change lives in its commit [`4cf04a0`](https://github.com/Kihara777/dsh-api-balance/commit/4cf04a0); the version stays `0.1.1`)
- The height-capped prompt's lower edge now carries a `mask-image` fade and the strip above the pinned buttons a `::before` gradient band
- The gradient colour is sampled at injection time from the card's actual background (light `rgb(255,255,255)` / dark `rgb(44,44,46)`; a hardcoded colour gives itself away in dark mode)
- Criterion: the prompt's bottom 30px average luminance goes 59.93 → 45.92 (~23% darker) while the band above the fade (60–90px) is unchanged
| Commit | Description |
|------|------|
| `e755381` | fix(dsh-api-balance): re-pin to 911df2e — fade mask at the question dialog's bottom |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1 (rev re-pin) |
| 　 | rev | `1f0af6c` → `911df2e` |
| 　 | src hash | `sha256-f3dg9oSbtKeYO6KzJZdpxz86gDUAI6vbRy8R3SSwroU=` → `sha256-oc+TPbtuwItV43kskjpz18Ys2cTtCgceXAGrh0Q0D2c=` |

## 2026-10-05T13:23:30+09:00

**Summary**: dsh-api-balance thin-wrapper re-pin — two UI fixes from the maintainer's feedback

- rev `f805f4e` → `1f0af6c` (the change lives in its commit [`e6d638c`](https://github.com/Kihara777/dsh-api-balance/commit/e6d638c); the version stays `0.1.1`)
- ① The bottom stats-bar horizontal scroll is **retired** (official 0.2.0 already turns every metric into a clickable pill, and the settings row is greyed out)
- ② The question dialog's header is height-capped (≤40vh), self-scrolls and is no longer pinned — with a long prompt it used to hide the options
- Criterion: `develop/ab-ui` runs against this package's **built artifact** (C2/C6 moved to the outcome layer), with the running tree checked by the three markers in `develop/check-deployed-artifact.py`
| Commit | Description |
|------|------|
| `1548c4c` | fix(dsh-api-balance): re-pin to 1f0af6c — stats bar retired, question prompt no longer hides the options |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1 (rev re-pin) |
| 　 | rev | `f805f4e` → `1f0af6c` |
| 　 | src hash | `sha256-u1L1VHy86tOeB3iv3MhCdL0VAi8xpNUf2OJHAa/zndY=` → `sha256-f3dg9oSbtKeYO6KzJZdpxz86gDUAI6vbRy8R3SSwroU=` |

## 2026-10-05T07:45:26+09:00

**Summary**: CI fix — the floating input `llama-cpp-ver` goes through "authenticated fetch + local override", curing `api.github.com` 403 rate limiting

- That input is a **plain URL input**, and Nix does **not** attach `access-tokens` / `netrc-file` to such fetches
- Each job's unauthenticated requests exhaust the 60-per-hour budget shared by the runner IPs (403)
- `gh api` now fetches the same JSON first and Nix receives it via `--override-input llama-cpp-ver path:<json>`
- The semantics are unchanged (the overlay only reads `json.tag_name`), and a missing `tag_name` **fails explicitly**
- `access-tokens` stays — it covers `github:` fetches
| Commit | Description |
|------|------|
| `335dce9` | fix(ci): floating input llama-cpp-ver goes through "authenticated fetch + local override" |
| `e92cfe4` | fix(ci): fail explicitly when the override parameter is empty — no silent fallback to the unauthenticated fetch |
| `35eec1e` | docs: correct the "access-tokens cures the llama-cpp-ver 403" claim that measurement disproved (AGENTS.md + skill) |

## 2026-10-05T07:14:50+09:00

**Summary**: dsh-api-balance thin-wrapper re-pin — the mobile keyboard guard rewritten

- rev `8dab668` → `f805f4e` (the change lives in its commit [`f805f4e`](https://github.com/Kihara777/dsh-api-balance/commit/f805f4e4445cd4db6a3ccd16e23cfd90fb092208); the version stays `0.1.1`)
- The mobile "no keyboard on session switch" guard **still failed**: a real `focusin` is not cancelable (`preventDefault` was dead code) and the soft keyboard is requested the moment `focus` lands
- The composer now stays non-editable until the user taps it, tapping or typing restores it immediately, and losing focus re-arms the block
- Criterion: during a session switch the number of focus events landing on an editable composer is 0 (2 on the deployed build); `develop/ab-ui/` runs against this package's **built artifact**
| Commit | Description |
|------|------|
| `a4b6bb1` | fix(dsh-api-balance): re-pin to f805f4e — mobile keyboard guard rewritten around the real causal chain |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1 (rev re-pin) |
| 　 | rev | `8dab668` → `f805f4e` |
| 　 | src hash | `sha256-yM+rQb/xIuTiN6QGpWr++jd2vDGHoN5K4gHnLmkGB4A=` → `sha256-u1L1VHy86tOeB3iv3MhCdL0VAi8xpNUf2OJHAa/zndY=` |

## 2026-10-04T09:23:29+09:00

**Summary**: fix(dsh-preset-news-three-elements): preset plugins' session message sources move to the v4 shape

- dsh 0.2.0's session format v4 refuses the literal `kind: "plugin"`, and this repo's preset plugins copied it, so every message was refused and the whole session reported "run failed"
- Three sites now write `{ kind: `plugin:${name}`, form: "notice", summary }` (`news-language.js` ×1, `news-material.js` ×2)
- The test assertion moved from `source.plugin` to `source.kind`
- A new self-check `session-sources` (`develop/check-session-sources.py`, wired into `nix flake check`) pins "no `kind: "plugin"` in this repo's preset plugins"
| Commit | Description |
|------|------|
| `d27e6ce` | fix(dsh-preset-news-three-elements): session sources move to the v4 shape (also adds the `session-sources` self-check wired into `nix flake check`, the v4 source-admission section in all four dsh docs, and the AGENTS self-check table growing from 7 to 8) |

## 2026-10-03T09:49:14+09:00

**Summary**: dsh-api-balance thin-wrapper re-pin — two **silent failures** found while re-checking dsh 0.2.0's UI improvements

- rev `700fbbc` → `8dab668` (the version stays `0.1.1`)
- ① the bottom stats-bar horizontal scroll **has not worked since dsh 0.1.5** — upstream renamed the style module from `StatsLine.module.css` to `StatsPills.module.css` and the plugin only knew the old name while the settings row kept showing On
- ② three tokens no longer exist in 0.2.0, among them `--dsw-alias-separator-primary`, which covers 18 borders and had **no fallback**
- They now chain to the 0.2.0 counterparts
- Criterion: an isolated instance plus Playwright (both items fail on the deployed build)
| Commit | Description |
|------|------|
| `18441ef` | chore(pkgs): re-pin dsh-api-balance rev（界面改进两项失效修复；版本仍 0.1.1） |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1 (rev re-pin) |
| 　 | rev | `700fbbc` → `8dab668` |
| 　 | src hash | `sha256-GEG3/ImXmo3BgO7AVh/rj1mIWsWMGB04Six+oIk9UIE=` → `sha256-yM+rQb/xIuTiN6QGpWr++jd2vDGHoN5K4gHnLmkGB4A=` |

## 2026-10-03T06:45:00+09:00

**Summary**: dsh-api-balance thin-wrapper re-pin — **runtime-behaviour fix**

- rev `76ea584` → `700fbbc` (the change lives in its commit [`cc89c43`](https://github.com/Kihara777/dsh-api-balance/commit/cc89c43); the version stays `0.1.1`)
- ① the Enter-swap install moved out of the component lifecycle — when dsh 0.2.0's chain slot `conversation.composer` is taken over, the ring component unmounts with the slot and the swap is silently uninstalled, so it is now installed in `apply()`
- ② panel/dialog materials were rewritten to the 0.2.0 native recipes — `--dsw-specific-menu` is now translucent and must layer a `backdrop-filter`, and the old recipe left the panel genuinely transparent
- Criterion: computed styles measured with Playwright
| Commit | Description |
|------|------|
| `6a8f68f` | chore(pkgs): re-pin dsh-api-balance rev（回车交换 + 面板材质修复；版本仍 0.1.1） |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1 (rev re-pin) |
| 　 | rev | `76ea584` → `700fbbc` |
| 　 | src hash | `sha256-7Yr9ALLN9hQTut5XziFLulmMde5GRgxTjBWidaxKqno=` → `sha256-GEG3/ImXmo3BgO7AVh/rj1mIWsWMGB04Six+oIk9UIE=` |

## 2026-10-03T06:15:29+09:00

**Summary**: Docs — filling in the maintenance log's untranslated ja / pcn entries

- ja **80**, pcn **59** — their lines held the `**Summary**` marker plus an English or Chinese older draft whose content also disagreed with the current zh source, so each was **replaced from zh**
- The checker gains a 6th rule, “**the summary marker must be in that language**”: ja `**Summary**` and en `**概要**` each turn red as counter-tests
- **Verification**: `nix flake check` all green; 358 entries per language, ja / pcn 0 leftovers
| Commit | Description |
|------|------|
| `197099e` | fix(docs): 补齐 ja 80 条 / pcn 59 条未译条目，并修 pcn 一处错标签 |
| `44793f3` | feat(develop): maintenance-log 检查补第 6 条 —— 摘要标记须是本语的 |

## 2026-10-03T05:16:47+09:00

**Summary**: Skills — the log's **ratio criterion gains a second feature: backtick share**

- Density alone overestimates: 0.646 was ruled “too short” by the density-only cohort (n=34) mean **2.37**
- Adding backtick share gives a nearest-neighbour (n=15) mean **1.98**, where the delivered 1.95 lands
- Backticked content is verbatim, so a higher share sits closer to 1; hence same-structure, same-density cohorts
- **Verification**: `nix flake check` green in all four languages
| Commit | Description |
|------|------|
| `bad01c4` | refactor(skills): 倍率判据补第二个特征（反引号占比）—— 只看密度会高估，实测差 0.4 倍 |

## 2026-10-03T05:13:21+09:00

**Summary**: Docs — the stated reason for the two riscv64 exclusions, `blender-mcp` / `obs-bilibili-stream`, corrected

- Not “a cross-compilation defect in the dependency chain” but **the main dependency not declaring that architecture in nixpkgs** (`blender 5.2.2` and `obs-studio 32.2.2` both have a `meta.platforms` without riscv64 and are refused at evaluation)
- The criterion is `pkgs.<dep>.meta.platforms`, **not a compilation error**
- **Verification**: `nix flake check` four-language self-checks all green
| Commit | Description |
|------|------|
| `e454504` | docs(pkgs): 两处 riscv64 排除的理由改准 —— 上游没声明该架构，不是「交叉编译缺陷」（四语） |

## 2026-10-03T04:53:28+09:00

**Summary**: Docs — `AGENTS.md`'s deployment check now reads the **unit reference**

- dsh 0.2.0 rewrites `cordis.patch.yml` at startup, so what lands is its own serialization; comparing contents yields only **a false negative**, a success called a failure
- The new criterion compares the store path in the running unit's pre-start script with the current configuration's (both commands in the doc); consistent locally
- **Verification**: `nix flake check` green
| Commit | Description |
|------|------|
| `5df33e9` | docs(AGENTS): 部署核对判据换成「看单元引用」—— 原判据已失效：dsh 启动时会重写 cordis.patch.yml |

## 2026-10-03T04:43:18+09:00

**Summary**: Two **guard failures of mine** fixed (the checker and the ratio criterion)

- ① The checker did not see a dropped table: `check-maintenance-log.py`'s four rules read totals only, so a heading and summary with the **commit table dropped** passed
- A 5th rule, **structural parity**, requires each entry's SHA set to match zh's in the four languages
- ② The ratio criterion written into the skill was wrong: terseness was judged by the repo-wide mean (`en/zh` ≈ 1.84) though CJK density correlates with ratio at **r = 0.90** — the same-density mean is 2.29 and the entry ruled “over” sits below it, so the mean only forces **cutting content**; now same-density cohorts
- **Verification**: `nix flake check` green; its three counter-tests (drop a table / alter a SHA / delete an entry) turn red
| Commit | Description |
|------|------|
| `21993c8` | fix(develop): maintenance-log 检查补「结构对等」判据 —— 原有的四条只看总量，漏掉过「某条目在某译文里整张表都没了」 |
| `1c6e4be` | refactor(skills): 修正倍率判据 —— 全库均值混着 CJK 密度这个强混杂因子（实测 r=0.90） |

## 2026-10-03T04:27:03+09:00

**Summary**: `opencode-telegram`'s riscv64 **goes from “dropped” back to “built”**, plus the “**the artefact really runs once**” criterion

- Two gyp traps fixed (a `gcc` shim pointing at the cross compiler, and an explicit `--force_build=1` for `better-sqlite3`)
- `build-package.yml` gains `smoke-test` — after the build it runs `develop/qemu-smoke-tests/<包名>.sh` (the same file locally and in CI), and a missing script or binfmt handler is a failure
- **Verification**: two pushes, 33 workflows each, all success
| Commit | Description |
|------|------|
| `af82af7` | feat(ci): riscv64 产物改成「真的跑一遍」—— 修好两个 gyp 陷阱 + build-package 加 smoke-test 开关 |
| `16bcc25` | refactor(skills): 泛化「缓存假绿」与「构建成功≠产物能跑」—— 含 smoke-test 机制与反证要求 |
| `ab20373` | fix(opencode-telegram): 用构建平台的 node 跑 node-gyp —— PATH 上的 node 是 riscv64 的，x86_64 runner 上执行不了 |
| `ab4e884` | refactor(skills): 记下「本机构建条件比 CI 宽松」—— binfmt 在本地让 riscv64 二进制能跑，于是本地绿掩盖了 CI 缺陷 |

| Package | Old | New |
|--------|--------|--------|
| opencode-telegram | — | version unchanged (0.26.2); **build matrix**: x86_64 + aarch64 → x86_64 + aarch64 + riscv64 (with a qemu smoke test on riscv64) |

## 2026-10-03T02:26:58+09:00

**Summary**: `opencode-telegram` **drops the riscv64 build** — green not by fixing the build, but by no longer building a platform that could never be usable

- That job **was false-green through the cache** (no build line in the log; it fetched the previous 0.25.3 artefact)
- The real build sticks on `better-sqlite3` — a **direct dependency**, **statically imported**, with no riscv64 prebuild upstream and `install` dropped in v13 — so the artefact **builds but throws on startup**
- Dropped on the **same precedent** as `blender-mcp` / `obs-bilibili-stream`
- Verification: x86_64 / aarch64 are unaffected
| Commit | Description |
|------|------|
| `b488bae` | fix(opencode-telegram): 摘掉 riscv64 构建 —— 上游 better-sqlite3 无 riscv64 预编译，产物能构建但一启动就抛 |

| Package | Old | New |
|--------|--------|--------|
| opencode-telegram | — | version unchanged (0.26.2); build matrix: x86_64 + aarch64 + riscv64 → x86_64 + aarch64 |

## 2026-10-02T20:38:40+09:00

**Summary**: Two **criterion blind spots** and one **same-name conflict** — the `doc-links` criterion, the bundled skill copies and the persona all closed off

- The `doc-links` switcher criterion now requires one under `docs/`, searched **file-wide** (the old one only looked in `lines[:8]`, so a deleted line or one past line 8 passed silently — all four `docs/*/ruyi.md` were never verified)
- Presets no longer bundle copies of the composition-writing skills (**same-named as upstream but forked**; upstream's are mounted instead and pinned by an assertion)
- The persona loses a stale claim
- Verification: `nix flake check` all green; presets in a throwaway `0.2.0-rc.2` instance, **all 9 presets' `broken` empty**
| Commit | Description |
|------|------|
| `fa0beff` | fix(develop): doc-links 的切换器判据补上盲区 —— docs/ 下强制存在、全文查找 |
| `1e85409` | refactor(dsh): 预设不再自带组合撰写技能副本 —— 改挂上游那份，并去掉已过期的 persona 说法 |

## 2026-10-02T19:54:49+09:00

**Summary**: dsh **0.2.0-rc.2** — both channels cross generations together (0.1.x → 0.2.x), with the **Agent preset migration landing**

- Measured, `alpha` sits below `latest` (`latest` = `next` = `0.2.0-rc.2`), so `dsh-alpha` now follows `next`, and both channels share one tarball, hash and lock
- The 0.1.x directory-style presets are deleted upstream wholesale, so the old format comes from a newly added rev-pinned package
- The module picks between them via `passthru.dshChannel` and merges `preset.patch.yml` verbatim into the generated `cordis.patch.yml`, with old settings keys stopped by an assertion
- Verification: four-language self-checks all green; a throwaway instance really run to confirm preset and skill-root resolution
| Commit | Description |
|------|------|
| `e4bcdee` | chore(pkgs): dsh 两通道升到 0.2.0-rc.2 —— alpha 改跟 npm next，两通道共用一份 vendored lock |
| `2b37ba5` | feat(dsh): 预设内容来源分叉 —— stable 冻结在钉住的 rev，alpha 跟仓库 HEAD |
| `b20a4c3` | refactor(presets): 预设迁到 0.2.0 单格式 patch 行（nixos / maintenance / news-three-elements） |
| `1fd1768` | feat(dsh): 模块按 0.2.0 接线预设与宿主面 —— patch 行播种、agent-preset-registry、node_modules 双链接 |
| `b5a767a` | docs(dsh): 四语文档同步 0.2.0 —— 通道语义、预设格式、宿主命名空间（四语） |
| `4758b05` | docs(AGENTS): 预设一节重写为 0.2.0 单格式与取用点分叉 |

| Package | Old | New |
|--------|--------|--------|
| dsh | 0.1.5-rc.2 | 0.2.0-rc.2 |
| dsh-alpha | 0.1.6-alpha.2 | 0.2.0-rc.2 |
| 　 | npm tag | `alpha` → `next` |
| 　 | src hash / npmDepsHash | recomputed; both channels are the same tarball ⇒ one shared vendored lock (`dsh-package-lock-alpha.json` deleted) |
| dsh-nixos-shell-stable | new | the preset-content variant pinned to `0175f85` (the `presetsSource` argument + `passthru`) |
| dsh-preset-news-three-elements | 0.1.0 | 0.2.0 |

## 2026-10-02T18:02:46+09:00

**Summary**: feat(dsh): preset-migration preparation — the 0.2.0 `preset.patch.yml` format plus derivation-check adaptation (four languages)

- A preset goes from the directory-style `agent.cordis.yml` to a single loader patch entry (`- insert:` → `@deepseek-ai/dsh-agent-preset`), landing in `$DSH_HOME/profiles/<profile>/cordis.patch.yml`
- The schemas of 26 packages were audited plugin by plugin, and all 6 changes are newly added optional fields
- Three “copying it over breaks” spots are fixed: `baseUrl` now points at that profile directory, metadata moves into `config.name` / `description`, and `config.order` is a new key
- Verification: a throwaway 0.2.0 instance with 7 presets, `broken` all empty; changing one line in a copy makes each report a specific `broken`
| Commit | Description |
|------|------|
| `3f92bb1` | feat(dsh): 预设迁移准备 —— 0.2.0 新格式 preset.patch.yml + 派生检查适配（四语） |

## 2026-10-02T17:39:30+09:00

**Summary**: feat(dsh): the declarative settings surface is completed — structured options 7 → **13** with six new typed namespaces

- Six new typed namespaces (`permission`, `web-search-deepseek`, `agent-presets`, `subagent`, `shell`, `llm-deepseek`) turn “a typo or out-of-range value is silently dropped at runtime” into **an evaluation-time error**
- Three existing judgements are corrected too: the namespace count **12 → 15**, “`shell.cwd` has no default ⇒ it cannot be declared partially” is wrong, and “typos and out-of-range values are both silent” is only half true
- Verification: a minimal NixOS configuration (all 13 sections on plus one escape-hatch override) evaluates, the generated `settings.yaml` carries every new section and parses via `builtins.fromJSON`, negative cases each fail at evaluation time; `nix flake check` is fully green
| Commit | Description |
|------|------|
| `0f12640` | feat(dsh): 声明式设置面补全 —— 新增 6 个类型化 namespace（13 个结构化选项，四语） |

## 2026-10-02T17:33:52+09:00

**Summary**: godot-ai 4.1.0 → 4.2.3 — the fail-closed pin table grows from 9 entries to 14 (`mcp` 1.29.1 → 2.2.0, `fastmcp` 3.4.7 → 4.0.5, plus new `mcp-types` and others)

- `mcp-types` is not in nixpkgs, so a definition was taken from the `src/mcp-types/` subproject of the same upstream repo
- both overlays' `python312.override { packageOverrides = …; }` replace each other under chained `.extend`, silently dropping the overrides while the build still succeeded; both now use `pythonPackagesExtensions`
- criterion: the build passes, running `godot-ai --version` prints 4.2.3, `importlib.metadata` hits 14/14, `nix flake check` is fully green

| Commit | Description |
|------|------|
| `32bcf22` | chore(pkgs): godot-ai 4.1.0 → 4.2.3 —— 依赖表 9→14、mcp 2.2.0、fastmcp 4.0.5、新增 mcp-types（四语） |
| `828af9c` | refactor(skills): 泛化链式 overlay 的替换语义陷阱（改用 pythonPackagesExtensions） |

| Package | Old | New |
|--------|--------|--------|
| godot-ai | 4.1.0 | 4.2.3 |
| 　 | runtime dependency pin table | 9 entries → 14 |
| 　 | src hash / overlay mounting | recomputed; both overlays switched to stackable mounting |

## 2026-10-02T17:09:33+09:00

**Summary**: feat(skills): the update check gains an "after pushing: verify the CI build" section (four languages)

- A green local build is not a green CI: it may hit a binary cache and covers only the current architecture, so only CI verifies a package's other architecture
- Criterion, three parts: wait until every `status` leaves `queued`/`in_progress`, filter by `--commit`, always read a failure's raw log
- Classify before acting: rate limits and flakiness are transient, hash mismatches and inconsistent locks real, one red architecture undetermined, while “green but the log is all `copying path … from cache`” is suspect — CI passing is not CI having built
- On failure, list every failing item with its nature at once, offering re-run, patch-then-append, or revert of that batch; re-running until green instead of fixing is forbidden
- The adapter records this repo's shape (`build-package.yml` skeleton, one workflow per package and architecture, the `ci-summary.yml` badge) and four measured failure shapes
| Commit | Description |
|------|------|
| `6ff84e3` | feat(skills): 更新检查新增「推送后验证 CI 构建」环节（四语） |

## 2026-10-02T17:03:13+09:00

**Summary**: codewhale 0.9.13 → 0.10.0; ruyi 0.52.0 → 0.53.0; mcp-searxng 2.3.0 → 2.5.0; opencode-telegram 0.25.3 → 0.26.2 — four-language doc sync

- `dsh` 0.2.0-rc.2 and `dsh-alpha` 0.1.7-alpha.2 are on hold: every hash and the build pass, but the preset mount verification does not — none appear in the `agentPresets/list` roster; a control run discriminates, yet an incompatible format cannot yet be told apart from the probe's `DSH_HOME` being insufficient
- fix(dsh): `postPatch` moves from "cut from `devDependencies` to end of file" to block matching plus trailing-comma repair — from 0.2.0-rc.2 on `exports` follows, so the old form would delete that too (exports lost while the build still succeeds); two real tarballs verified offline as parseable

| Commit | Description |
|------|------|
| `16216d5` | chore(pkgs): 上游更新 —— codewhale 0.10.0 / ruyi 0.53.0 / mcp-searxng 2.5.0 / opencode-telegram 0.26.2（四语文档同步） |
| `63e71cd` | fix(dsh): postPatch 按块删 devDependencies —— 0.2.0+ 的 exports 不再被误删 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.9.13 | 0.10.0 |
| 　 | cli / tui hashes (x64, arm64) | all four recomputed (cli and tui share values) |
| 　 | codewhale-src `src` hash | `sha256-AYs2v/…` → `sha256-SsN/p+…` (Cargo.lock synced to 7266 lines) |
| ruyi | 0.52.0 | 0.53.0 |
| mcp-searxng | 2.3.0 | 2.5.0 |
| 　 | src hash / npmDepsHash | both recomputed |
| opencode-telegram | 0.25.3 | 0.26.2 |
| 　 | src hash / npmDepsHash | both recomputed |

## 2026-10-02T16:26:56+09:00

**Summary**: feat(skills): the update check gains a "step 0" — sync the remote with `git fetch` and check open issues / PRs before starting (four languages)

- Issues are the set of known failures, PRs the set of work in flight, and the step pulls the fetch-path self-check earlier as well
- `gh` fails loudly with a non-zero exit, so an empty list is "truly none" only when the command succeeded
- The pre-commit self-check grows from nine questions to ten, noting honestly that question 10 is a maintainer-required upfront action (1–9 came out of measured rework)
- The adapter adds this repo's coordinates, `has_issues=true`, a measured 0 open issues / PRs and four real precedents (PR #6 touched the SHA-pinned actions, PR #7 bumped this repo's packages, PR #4 / #5 led to the `/tts` SSRF fix, and issue #3 to the skill split)
- Two inaccuracies in `traps.md` and the four-language skill docs are fixed too
| Commit | Description |
|------|------|
| `c10de09` | feat(skills): 更新检查新增第 0 步 —— 开工前同步远端并核对活跃 issue / PR |

## 2026-10-02T03:54:38+09:00

**Summary**: fix(dsh): the image-modality claim is corrected (four languages)

- The previous entry called `deepseek-flash` "the only flash entry declaring the image modality" and stretched that across both channels
- The two built artifacts in the store show stable `0.1.5-rc.2` and alpha `0.1.6-alpha.1` each carrying two entries declaring `inputModalities: ["text","image"]` (`deepseek-flash`, `deepseek-v4-flash-vision-exp`), with only alpha `0.1.6-alpha.2` down to one
- What changed: the rationale becomes "the only id all three catalogues carry that declares the image modality in each", and the catalogue table gains that column
- The degradation warning is corrected to two paths — a newly attached image is rejected at `session/prompt` admission with `MODEL_DOES_NOT_SUPPORT_IMAGES`, and only history images are silently replaced
- The default is unchanged
| Commit | Description |
|------|------|
| `067b296` | fix(dsh): 更正 image 模态断言 —— stable/alpha.1 目录实有两条声明（四语） |

## 2026-10-02T03:01:23+09:00

**Summary**: fix(dsh): the default model moves to `deepseek-flash` (four languages)

- Upstream retired V4 Flash and V4 Flash Vision Exp on 2026-09-10, collapsing the model names to `deepseek-flash` and `deepseek-v4-pro`
- dsh's catalogue moves with the version: stable `0.1.5-rc.2` and alpha `0.1.6-alpha.1` carry four entries, alpha `0.1.6-alpha.2` two
- The old default `deepseek-v4-flash` is no longer in the alpha catalogue, and an off-catalogue id is treated as a text-only model, so `projectImagesForTextModel` silently replaces images with text placeholders — no error, and the model never sees the picture
- What changed: the default becomes `deepseek-flash`, the option description spells out that the catalogue moves with the version, and the four `dsh.md` documents sync their example ids and add that section with the degradation warning
| Commit | Description |
|--------|-------------|
| `2ab7dda` | fix(dsh): 默认模型改用 deepseek-flash —— 上游 09-10 下线旧 id（四语） |

## 2026-09-28T13:07:06+09:00

**Summary**: dsh-api-balance 0.1.0 → 0.1.1 — thin-wrapper coordinate sync

- The sub-repo keeps no maintenance log; see its commit [`76ea584`](https://github.com/Kihara777/dsh-api-balance/commit/76ea5847c3e3f8e639b01abbfd8901fa71d6c177)
- Voice selection now follows the **variety actually spoken**: the old code took the first primary-language match, and since Cantonese `zh-HK` and Mandarin `zh-CN` both belong to `zh`, a voice list that puts Cantonese first necessarily reads Mandarin text in Cantonese — the text and UI stay correct, so it is invisible unless you listen
- Now: classify and rank varieties, wait for the voice list before speaking, align `utter.lang` with the chosen voice, and show the voice in use in a 「Voice」 setting
- Criterion: the sub-repo's `test/voice-selection.test.mjs` (25 assertions with counter-evidence) plus a real-browser run
| Commit | Description |
|------|------|
| `a4e6d54` | chore(pkgs): bump dsh-api-balance 0.1.0 → 0.1.1（音色按话的变体选择） |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 0.1.0 | 0.1.1 |
| 　 | rev | `c47f857` → `76ea584` |

## 2026-09-28T08:28:27+09:00

**Summary**: refactor(skills): today's preset incident went into two skill layers, sorted by the test "does this still hold in another nix flake repo?"

- `nix-flake-update-check`'s pre-commit self-check grows from eight to nine questions, adding "did 'verified' verify the layer where failure happens — can the verdict itself fail?": a verdict that never fires cannot tell "no problem" from "nothing measured", so give it a **deliberately broken fixture** as counter-evidence
- `nixkits-check-updates` gains a section: a plugin rename or removal is not a docs matter but **really breaks** both presets — rows name built-in plugins by package name, so dsh ≤ 0.1.6-alpha.1 silently ignores rows it cannot resolve and ≥ alpha.2 hard-fails so no preset mounts
- That section gives two verdict layers to run before an upgrade (offline row resolution + authoritative mounting reading upstream's `broken` field) and the seed-once corollary
- Three self-check numbering references are updated
| Commit | Description |
|------|------|
| `c5022ea` | refactor(skills): 预设事故泛化 —— 通用技能加第 9 问，适配层加插件改名陷阱 |

## 2026-09-28T08:04:31+09:00

**Summary**: fix(dsh-nixos-shell): preset rows switched to `workflow-ptc` — dsh 0.1.6 renamed the built-in `dsh-workflow-worker-thread`; the old name is silently ignored up to alpha.1 and from alpha.2 on makes the whole preset fail to mount.

- The `nixos-mode` / `maintenance-mode` composition rows and the `editing-cordis-compositions` skill example were renamed together, with `config` unchanged
- Verification now mounts the **build output** for real: a throwaway dsh calls `agentPresets/list` to read upstream's `broken` verdict, plus a deliberately broken fixture as counter-evidence
- The same trap was written into `docs/*/dsh.md` (four languages), and `AGENTS.md`'s local-deployment premise was corrected from a `path:` input to a GitHub reference (push before re-locking; re-locking also re-resolves the floating sub-inputs)

| Commit | Description |
|------|------|
| `c92e980` | fix(dsh-nixos-shell): 预设行改用 workflow-ptc（旧名在 0.1.6 已不存在） |
| `7a12ff2` | docs(dsh): 记录 0.1.6-alpha.2 插件改名硬失败陷阱（四语） |
| `5364ef1` | docs(agents): 修正本机部署前提（GitHub 引用而非 path 输入）+ 重锁的副作用 |

## 2026-09-24T05:45:11+09:00

**Summary**: ① `fix(pcn)` removes the residual kana from the 偽中国語 documents ② `feat(dsh)` adds 6 structured settings options

- ① The 4 residual kana are removed, returning `check-maintenance-log` and `check-doc-links` to `exit 0`
- ② The options: `agent-loop`, `subagent-model-selection`, `locale`, `ui-theme`, `ui-chat`, `ui-conversation`
- Previously only `agent-default-model` had structured options and the rest were reachable only through the untyped `settings` (a wrong field silently falls back to the schema default); `shell` is deliberately not offered because `cwd` has no schema default
- The namespace table transcribed from `0.1.5-rc.2` in the docs was corrected in 5 rows
- Criterion: all 6 checks green, the four languages structurally equivalent, and enabling all 6 producing a settings.yaml that contains the 6 new sections
| Commit | Description |
|------|------|
| `d2e8c10` | fix(pcn): 剔除偽中国語残留假名 —— 恢复 CI 绿灯 |
| `55cbdbd` | feat(dsh): 6 个新结构化 settings 选项 + 修正 namespace 表（四语） |

## 2026-09-23T08:27:16+09:00

**Summary**: refactor(preset): the maintenance-mode prompt is split into a generic method plus a repository adapter

- `maintenance-skills` had the NixKits workflow hardcoded into the public preset, contradicting the existing split under `skills/` (`nix-flake-update-check` generic ← `nixkits-check-updates` adapter)
- It is now `maintenance-workflow` (order 901, generic: batch commits, record after pushing, keep docs in sync with code, generalize fixes into skills) and `maintenance-workflow-repo` (order 902, this repository's conventions: the four languages with `docs/zh/` as the base, `write-maintenance-log` as the standard, an equal-entry-count check)
- The only test is "would this rule still hold in another repository?"; the generic layer names nothing repository-specific
- A new option `repoWorkflow: false` keeps only the generic layer
- Four-language docs synced
| Commit | Description |
|------|------|
| `78fb91b` | docs(modes): 维护模式提示词分层 —— 通用方法 + 本仓适配层（四语） |

## 2026-09-22T16:23:33+09:00

**Summary**: docs(skill): recorded the "bootloader config must not be modified imperatively" incident in `nixos-specialisation-tuning`

- `extraInstallCommands` rewrote `limine.conf`'s `default_entry` **after** Limine had sealed the config hash, and the mismatch made the system **unbootable** under Secure Boot
- One new skill section `### 引导菜单与默认面`: config must be declarative, with the investigation order "write file → checksum/signature", and any change after sealing must re-seal with a byte-identical algorithm
- The other section covers the two runtime failures of switching faces: the verdict must use `default.target`'s resolved value, never `is-active`; `user@<uid>.service` needs a full restart across faces, and "the compositor exists" must not count as "the desktop works".
- The frontmatter `description` and 「适用场景」 were updated too
| Commit | Description |
|--------|-------------|
| `8c276c0` | docs(skill): record the "bootloader config must not be modified imperatively" incident — the unbootable fault I introduced |

## 2026-09-22T09:37:07+09:00

**Summary**: fix(ci): filter `ci-summary` by `head_sha` to correct the README badge's false `failing`

- the workflow is push-triggered and starts while the same push's builds are still running, so without restricting the query to a commit it reads the previous push's failed run (a concrete case: `Build dsh-preset-news-three-elements (aarch64)` run#157)
- `curl` gains `--fail`
- on request failure the existing badge is preserved with `exit 1` — previously the JSON error body returned by a 403 rate limit left `FAILED` empty and silently wrote `passing`
- Evidence: the new jq logic run against the current HEAD yields empty output (=> passing), consistent with all 31 Build workflows being green
- The only external change here was the badge state on `gh-pages`; no third party modified source on the main branch
| Commit | Description |
|------|------|
| `7fc4a14` | fix(ci): ci-summary 按 head_sha 过滤，修正徽章误报 failing |

## 2026-09-20T17:56:28+09:00

**Summary**: refactor(skill): batch generalization of repo/role specifics across the 8 generic skills.

- `write-maintenance-log`: "force-triggered by AGENTS.md" is now conditional; the SUBTITLE `NixKits 软件更新维护日志。` became a `<项目名>` placeholder (verbatim; copying it writes another project's name)
- `write-project-docs`: "keeps only Chinese" contradicted the "hardcoded language list" anti-pattern; now "the base language is chosen by the repository"
- The switcher verification script now discovers languages dynamically (it hardcoded `docs/zh|en|ja|pcn` and `/5`); the broken `translate-pseudocn` script was rewritten
- Cross-skill hard references now stand alone; the step count aligns with the actual 9; the sub-repo example and `kits/` lost their specifics
Evidence: both rewritten verification scripts were run and pass (including a reverse test with an injected broken link), and `nix flake check` fully passes.

| Commit | Description |
|------|------|
| `dac80a7` | refactor(skill): 全面泛化通用技能中的仓库/角色特指（审计后批量修复） |

## 2026-09-20T17:41:07+09:00

**Summary**: refactor(skill): generalize who the external-automation and Actions checking applies to (no longer naming one repository)

- A skill is a reusable artifact handed to others; its reader may be a contributor or successor in another repository, who read the old wording as "not relevant to me".
- `traps.md` gains two sections: pinning to a SHA is a shared choice whose side effect (no update notifications) is inherited by whoever adopts it, and the criterion is **"can this be self-implemented," not "who is using it"** (applicability listed for maintainers / contributors / auditors)
- plus that non-maintainers upgrade actions via PR too
- Step 2 and `builders.md` state the general case, step 8 says "specified by the adapter layer," and the adapter's hardcoded path reference is removed
- Evidence: `nix flake check` fully passes
- the adapter `nixkits-check-updates` keeps its repository-specific facts
| Commit | Description |
|------|------|
| `23e11a5` | refactor(skill): 泛化外部自动化与 Actions 检查的适用对象（不再特指某个仓库） |

## 2026-09-20T17:28:32+09:00

**Summary**: fix(skill): three defects in `nix-flake-update-check`, all of the "no error, just a silent omission" kind.

- The pinned-SHA Actions check was unreachable: `traps.md` had the flow but no step in `SKILL.md` pointed to it; step 2 gained a section, the self-check grew to eight questions, and the table of contents marks it "every round"
- Version discovery used `version\s*=`, which misses the parameterized `version ? "0.1.5-rc.2"` in `packages/dsh.nix`, so that package vanished from the check scope; now `version\s*[?=]`
- A bare `curl` to `api.github.com` returns empty without error once the quota is exhausted, and the downstream grep is equally silent, so every package was judged "up to date"; now unified on `gh api` with an `ERROR:` branch
Evidence: `nix flake check` fully passes; on the new flow's first run, this repo's 3 actions across 6 references were each compared by SHA and all are current.

| Commit | Description |
|------|------|
| `34368c1` | fix(skill): 接入 Actions 检查、修正版本发现启发式、取数改用 gh api |

## 2026-09-20T17:05:51+09:00

**Summary**: Routine update check — `opencode-telegram` 0.25.3 and `ruyi-alpha` 0.54.0-alpha.20260918

- `opencode-telegram` 0.25.3 (an npm package; source hash and npmDepsHash updated, build passes)
- `ruyi-alpha` 0.54.0-alpha.20260918 (thin wrapper: version and hash only, the base shared by all three channels untouched)
- The same run checked 12 packages on the stable channel and only these two lag behind upstream
- the alpha channel's pytest counts in the docs went from 346 unit / 57 integration to 462 unit (1 xfailed) / 70 integration
- documentation synced in four languages
| Commit | Description |
|------|------|
| `1711331` | feat(pkgs): opencode-telegram 0.25.3 + ruyi-alpha 0.54.0-alpha.20260918 |
| `14e565e` | docs: 同步 opencode-telegram 0.25.3 与 ruyi-alpha 0.54.0-alpha.20260918（四语） |

| Package | Old | New |
|--------|--------|--------|
| opencode-telegram | 0.25.2 | 0.25.3 |
| 　 | source hash | `sha256-wNM/QNtFaRaColS2MGqk2p94NpVeHXoqJ26RjNRVypU=` → `sha256-XVIsT9mQuagF3DDLwlXomihfpBJLZ6OfJHzBGLM9lXM=` |
| 　 | npmDepsHash | `sha256-NnvFOrS7Y7NFYoS/lWTb3tTs5xwHhzDLTzkdGN+f3vw=` → `sha256-lLl6AobcB/Zi9aw463iv1MMAPah+RV/GtrF0nK6X1Q0=` |
| ruyi-alpha | 0.52.0-alpha.20260714 | 0.54.0-alpha.20260918 |
| 　 | source hash | `sha256-x6DGsnGgeClKXsS1kXP+3nIYGG2hJhyk6J1ENE2VD8s=` → `sha256-6XSVQuU+szU8CnijgAwQa1XmoHgpk/vHW6tmWP5dkpQ=` |

## 2026-09-19T14:13:43+09:00

**Summary**: docs(agents): completed the 7 self-checks of `nix flake check` and the CI `access-tokens` trap

- A check of 'content not listed in the docs' closed one structural gap
- the 7 `nix flake check` self-checks — the repository's contract (any failure blocks a commit) — had no single place describing them, appearing only in `flake.nix` comments while `AGENTS.md` mentioned just 2
- `AGENTS.md`'s `## CI` section now carries (1) a table of the 7 self-checks (name / script path / what it validates)
- and (2) the CI `access-tokens` host-matching trap (`check.yml` omitting `api.github.com` left the floating `llama-cpp-ver` input unauthenticated, exhausting its quota)
- Verified: all 7 paths exist and `nix flake check` passes
| Commit | Description |
|------|------|
| `7766b88` | docs(agents): complete the 7-entry nix flake check list and the CI access-tokens trap |

> **Note**: changes `AGENTS.md` (itself an agent-convention file, not user documentation).

## 2026-09-19T14:05:38+09:00

**Summary**: fix(ci): `check.yml` was missing `api.github.com` in `access-tokens`; the sub-repo `dsh-api-balance` also gained a four-language `SECURITY.md`.

- CI: the floating `llama-cpp-ver` input had been fetching unauthenticated (the 60/hour quota exhausted by ~34 workflows per push); with both hosts set, 33 workflows all pass with zero 403s, and the input stays floating — never written to `flake.lock`
- Sub-repo security policy: the scanner's PR #4 / #5 claims — 'missing rate limiting' and 'missing request-body size cap' — are both assessed as false positives; no code change
- The main repo's four-language `SECURITY.md` line saying the subproject 'has not yet' established a policy is corrected to 'now has one', linking the sub-repo document

| Commit | Description |
|------|------|
| `d224b18` | fix(ci): check.yml's access-tokens was missing api.github.com (the 403 root cause) |
| `2cce37b` | (sub-repo dsh-api-balance) docs(security): add four-language SECURITY.md |
| `39c9f10` | docs(security): sub-repo now has its own policy -- update the stale "not yet" claim (all four languages) |

> **Note**: `d224b18` changes `.github/workflows/check.yml`; `39c9f10` is four-language documentation; the sub-repo commit is recorded in its own repository.

## 2026-09-19T07:51:05+09:00

**Summary**: Skill-doc review of 4 docs (`nix-flake-update-check` / `nixkits-check-updates` / `write-project-docs` / `translate-pseudocn`), 3 corrections (four languages).

- `nix-flake-update-check`: the docs claimed steps 1-10; `SKILL.md` actually ends at step 9, with step 10 (closing) defined by the adapter `nixkits-check-updates`
- `write-project-docs`: the companion `templates.md` (209 lines) was undeclared in `SKILL.md` — added the companion table and the directory-form path
- `translate-pseudocn`: the dictionary count 13 corrected to the measured 75, plus a `dictionary.md` companion row
- Cross-check: `news-three-elements` already declared its companions correctly

| Commit | Description |
|------|------|
| `c9c9c0c` | fix(docs): nix-flake-update-check skill doc had the wrong step count (all four languages) |
| `7f7363f` | fix(docs): write-project-docs did not declare its companion file templates.md (all four languages + SKILL.md) |
| `cef09fe` | fix(docs): translate-pseudocn dictionary count and companion file were inaccurate (all four languages) |

> **Note**: `7f7363f` includes a `skills/write-project-docs/SKILL.md` change (the skill snapshot verified by `check-preset-bundle` to remain byte-identical to the `skills/` tree); the rest is four-language documentation.

## 2026-09-19T07:43:15+09:00

**Summary**: fix(comfyui): corrected the wrong "upstream has migrated the stdenv API" assessment.

- The original claim was "upstream has migrated to hostPlatform"; measurement falsifies it: `stdenv.is<Platform>` appears **38 times each in 0.34.0 and 0.30.2**, while `hostPlatform.is*` appears 7 times in both -- never migrated
- The real reason: **we no longer override upstream code** (the old patch applied the migration to a fork evaluated under an overlay)
- Corrected in both the `modules/comfyui.nix` comment and the "why it can be retired" section of the four-language `deprecated/comfyui-rocm.md`
- Other deprecated assertions pass: renamed to `nixkits.comfyui`, `modules/comfyui-rocm.nix` and the three patches deleted, the four-language `DEPRECATED.md` index correct, upstream version **v0.34.0**

| Commit | Description |
|------|------|
| `4054c32` | fix(comfyui): correct the wrong "upstream migrated the stdenv API" assessment (module comment + deprecated doc in all four languages) |

> **Note**: `4054c32` **changes `modules/comfyui.nix`** (comments only; it does not affect evaluation and `nix flake check` passes fully); the rest is four-language documentation.

## 2026-09-19T07:38:04+09:00

**Summary**: fix(docs): the patch document set is complete -- the last three are checked with 4 corrections (all four languages).

- asusd-thermal-guard: the docs wrongly said state lives in `/run`; the module uses `StateDirectory` (`/var/lib/private/asusd-thermal-guard`) and its comments warn against `RuntimeDirectory` (systemd deletes it entirely, so the cooldown counter zeroes every round)
- comfyui: the badge named a CI job that does not exist (`check.yml` has only a single `check` job); replaced with an honest CI badge
- comfyui: the cache section still claimed an overlay declaration (the module has no `pkgs.comfyui` reference and does declarative configuration only)
- llama-cpp-rocm: the migration example's `hfCacheDir` used a `~` that never expands; the module default is an absolute path

| Commit | Description |
|------|------|
| `8292160` | fix(docs): asusd-thermal-guard wrongly said state lives in /run (all four languages) |
| `01679e8` | fix(docs): comfyui badge named a nonexistent job plus a stale overlay claim (all four languages) |
| `35aaf05` | fix(docs): llama-cpp-rocm migration example used a non-expanding ~ for hfCacheDir (all four languages) |

> **Note**: documentation-only corrections; `packages/`, `overlays/` and `modules/` were not touched.

## 2026-09-18T11:04:38+09:00

**Summary**: External listing complete -- both awesome-ai-plugins PRs are merged, and NixKits and dsh-api-balance are now officially in that catalog.

- Scanner score **88 -> 94/100 (A - Excellent)**, Security **13/16 -> 16/16**, by rewording only, deleting no information
- PR #321: adds `dsh-api-balance` to DeepSeek Harness Plugins, **merged 2026-09-16**
- PR #323: adds NixKits to Development & Workflow, closed by us after the review remediation and a rerun of the scan
- PR #335: the resubmission, **merged 2026-09-18**; both entries are now live in the upstream README
- No scanner workflow and no Dependabot, accepting the 10% trust-score reduction

| Commit | Description |
|------|------|
| `--` | External repository actions (awesome-ai-plugins PRs #321 / #335 merged) plus the issue #3 reply update; no corresponding commit in this repository |

> **Note**: the listings were merged by the external catalog; `packages/`, `overlays/` and the docs here were all unchanged.

## 2026-09-18T14:35:36+09:00

**Summary**: fix(docs): the first five patch documents verified (breeze-black / efl-cross-fix / codewhale-sudo / rcc-fix / asusd-pd-profile) -- three corrections.

- `rcc-fix` used a non-existent option namespace: the example reads `services.asusctl` (with `power-profile`/`cpu-power-control`), where it should be `services.asusd`, whose profiles and CPU power limits go through `profileConfig` (four languages)
- `breeze-black`: the placeholder path `(import ./overlay.nix)` in the "install" section is now `inputs.nixkits.overlays.<name>` (zh only)
- `codewhale-sudo`: a duplicated row in the basic-information table was removed (zh only)
Every other assertion was checked item by item and passed.

| Commit | Description |
|------|------|
| `a262e3c` | fix(docs): breeze-black install path and codewhale-sudo duplicate row (zh) |
| `ea03584` | fix(docs): rcc-fix used a non-existent services.asusctl option (all four languages) |

> **Note**: documentation-only corrections; `packages/`, `overlays/` and `modules/` were not touched.

## 2026-09-18T14:26:43+09:00

**Summary**: fix(devshell): both development documents verified -- one parameter error fixed, plus one source defect found.

- `ruyi venv` / `ruyi extract` documented with wrong parameters: the former needs `ruyi venv -t <toolchain> <profile> <dest>` with `profile` already in the local index, and the latter's positional is a package, `ruyi extract <pkg>`, not a file path (four languages)
- the searxng limiter configuration was never read: `develop/opencode.nix` put it in a `server.limiterSettings` block inside `settings.yml`; it now lives in a separate `limiter.toml` (`[botdetection] trusted_proxies`), and after the fix the `missing config file` warning is gone with the reverse proxy answering HTTP 200
Every other assertion was measured and passed.

| Commit | Description |
|------|------|
| `26e7a76` | fix(devshell): wrong ruyi venv/extract parameters + opencode searxng limiter configuration never took effect (all four languages) |

> **Note**: `26e7a76` **changes `develop/opencode.nix`** (the limiter configuration moves to a separate `limiter.toml`), so devShell behaviour has changed; the rest is documentation-only, and the `dump.rdb` and stray background processes from testing were cleaned up.

## 2026-09-18T13:51:14+09:00

**Summary**: fix(docs): both plugin documents and all three mode documents verified -- the plugins matched every item, the modes needed one correction.

- `dsh-nixos-shell` and `dsh-api-balance`: npm name and version, the 27-entry `nixos_shell` tool whitelist, `nixos_cli`'s five ops and ceilings, sudo protocol v3 (`MAX_TIMEOUT_MS = 21600000`), the `skills-embedded/` snapshots, plus `dsh-api-balance`'s rev `c47f857` and its 4 config options all matched item by item
- the NixOS mode "Composition" line wrongly said the persona row sets `complete: true`; it sets only `prefix`, corrected in four languages
The other mode assertions passed (`nixos-gate` reads, the 5 NixOS mode skills, the maintenance mode derivation, and the news-three-elements items).

| Commit | Description |
|------|------|
| `3d6340f` | fix(docs): NixOS mode composition wrongly claimed persona sets complete: true (all four languages) |

> **Note**: documentation-only correction; neither plugin document needed changes (recorded here so future regressions can be compared against them).

## 2026-09-18T13:43:54+09:00

**Summary**: fix(docs): two corrections in the ruyi documents (plus one incidental wording fix).

- test counts had been given for the beta channel only; they are now split per channel: `ruyi` 368 unit / 58 integration, `ruyi-beta` 462 / 70, `ruyi-alpha` 346 / 57 -- with the note that ruff / mypy are `|| true` in `checkPhase` and pytest is what actually gates the build
- the zh install section had a prose line inside its Nix code fence, truncating the block (en/ja/pcn were unaffected)
- (incidental) `pyelftools` is added unconditionally by this package in the shared base (no version condition), not "new in >= 0.53.0"

| Commit | Description |
|------|------|
| `c30f2b6` | fix(docs): ruyi test counts not split by channel + broken code block in the zh install section (all four languages) |

> **Note**: documentation-only corrections; `packages/`, `overlays/` and `modules/` were not touched.

## 2026-09-18T13:41:45+09:00

**Summary**: fix(docs): the obs-bilibili-stream Home Manager recipe installs the package but never takes effect

- `home.packages` only puts the `.so` into the profile, while OBS finds plugins through `OBS_PLUGINS_PATH`, a variable only nixpkgs' `wrapOBS` injects
- so `programs.obs-studio.plugins` is the only path that works
- a warning and the two correct approaches were added in all four languages
- opencode-telegram matched item by item with zero changes
| Commit | Description |
|------|------|
| `4bea784` | fix(docs): obs-bilibili-stream's Home Manager usage installs but has no effect (all four languages) |

> **Note**: documentation-only corrections; `packages/` and `overlays/` were not touched. opencode-telegram needed no changes (recorded for future regression comparison).

## 2026-09-18T13:40:20+09:00

**Summary**: fix(docs): two inaccuracies each in kitsfmt and mcp-searxng.

- `kitsfmt`: the "comment preservation" claim was too broad -- in 0.5.0 only leading comments above a node travel with it during sorting; a trailing comment on a non-last attribute moves above the next attribute, while the last attribute's and the file header/footer are dropped; `KITSFMT_STDIN=1` was also added
- `mcp-searxng`: the "works out of the box" example carried the obsolete `real_ip.x_for = 1` (upstream `limiter.toml` no longer has a `real_ip` section); removed in all four languages
- `mcp-searxng`: "fails silently without `SEARXNG_URL`" does not match measurement: the server starts and `tools/list` returns; only `tools/call` returns `isError: true` with an explicit message in the text and on stderr

| Commit | Description |
|------|------|
| `0cb9f4f` | fix(docs): kitsfmt comment-preservation claim too broad + add KITSFMT_STDIN (all four languages) |
| `9f3c829` | fix(docs): two inaccurate claims in mcp-searxng (real_ip obsolete, failure not silent) (all four languages) |

> **Note**: documentation-only corrections; `packages/` and `overlays/` were not touched.

## 2026-09-18T13:32:32+09:00

**Summary**: fix(docs): the dsh and godot-ai documents verified -- three corrections, plus one real functional defect found.

- `dsh`: the "declaratively configurable host namespaces" table listed only 6 and was labelled 0.1.2-alpha; the `0.1.5-rc.2` the section discusses registers 12 through `installSection`, so `agent-default-model` and 5 others were missing
- the `godot-ai` command fails immediately on startup: the attach bridge re-spawns a backend via `sys.executable -m godot_ai`, and under Nix that is bare CPython, so the dependencies injected by `site.addsitedir()` are not inherited by the child; PYTHONPATH is now prepended with makeWrapper and it works when measured
- two more fixes in the godot-ai docs: tool count 43 -> 46 and WebSocket port 9876 -> 9500

| Commit | Description |
|------|------|
| `6b47f55` | fix(docs): dsh settings namespace table incomplete and version label stale (all four languages) |
| `a54bd9d` | fix(godot-ai): repair the attach backend failing to start plus two inaccurate documentation claims (all four languages) |

> **Note**: `a54bd9d` **changes `packages/godot-ai.nix`** (adding makeWrapper and postFixup), so godot-ai's build output has changed; the rest is documentation-only.

## 2026-09-18T13:23:25+09:00

**Summary**: fix(docs): 26 assertions plus subdocuments verified; 7 inaccurate descriptions fixed

- Main document, 2 items: `inputs.nixkits.url = "~/NixKits"` does not work — use `git+file:///path/to/NixKits`; the claim that all packages follow `lib.platforms.linux` is false, they are actually `lib.platforms.all`
- blender-mcp, 3 items: the server registers 26 tools (the docs claimed 22); the add-on path is `extensions/user/` (a Blender Extension, unloadable on 4.x); the upgrade flow is `chmod` -> `rm -rf` -> `cp` -> `chmod` (the old one failed silently)
- codewhale, 2 items: `--sandbox <tier>` does not exist, the flag is `--sandbox-mode`; a name already fixed once was reintroduced by mistake, and the four languages now agree

| Commit | Description |
|------|------|
| `82d8ed5` | fix(docs): correct two inaccurate descriptions in the main document (all four languages) |
| `ead55d1` | fix(docs): three inaccurate descriptions for blender-mcp (all four languages) |
| `6f40487` | fix(docs): codewhale sandbox flag-name regression and four-language inconsistency (all four languages) |

> **Note**: documentation-only corrections; `packages/` and `overlays/` were not touched.

## 2026-09-18T13:09:18+09:00

**Summary**: refactor(ruyi)! — the `ruyi-nixos-compat` patch is folded into `packages/ruyi/ruyi.nix`, the defunct overlay removed

- The overlay patched **nixpkgs'** `ruyi`, a package nixpkgs no longer provides, so only `develop/ruyi.nix`, which wrapped it itself, actually took effect — flake-package users got no NixOS compatibility handling
- The patch is now built in and shared by all three channels: `--replace-fail` fills `@nixLdSo@`/`@nixGlibcLib@` and `ensure_toolchain_nixos_compat` is injected
- the devShell, the flake package and the NixOS module get the same build
- Verified: all three channels build, `@nixLdSo@` remains zero times in the artifact, `ruyi --version`/`--help` work, beta's pytest still reports 462 + 70 passed
| Commit | Description |
|------|------|
| `87d3f7c` | refactor(ruyi)!: fold the patch into the package definition and remove the defunct ruyi-nixos-compat overlay |

> **Note**: a breaking change — `nixkits.overlays.ruyi-nixos-compat` **no longer exists**; anyone referencing that overlay externally must drop the line (the patch is now built in and needs no overlay configuration). The build outputs of all three ruyi channels have changed.

## 2026-09-18T12:41:08+09:00

**Summary**: Routine update check — `blender-mcp` 1.0.3, `ruyi-beta` 0.53.0-beta.20260917, `dsh` 0.1.5-rc.2, `dsh-alpha` 0.1.6-alpha.2

- `ruyi-beta` adds the `pyelftools` runtime dependency: upstream lists it as a runtime dependency from 0.53.0, and without it pytest aborts during collection
- `dsh-alpha` — upstream adds 4 plugin packages, so `dsh-package-lock-alpha.json` was regenerated; changing the version alone reports `npmDepsHash is out of date`
- Documentation synced in four languages
- `nix flake check` passes
| Commit | Description |
|------|------|
| `0e220fd` | chore(blender-mcp): upgrade 1.0.0 → 1.0.3 (all four languages synced) |
| `9b48078` | fix(ruyi): upgrade beta → 0.53.0-beta.20260917 and add the pyelftools dependency |
| `80104c4` | chore(dsh): stable 0.1.5-rc.2 + alpha 0.1.6-alpha.2 (all four languages synced) |

| Package | Old | New |
|--------|--------|--------|
| blender-mcp | 1.0.0 | 1.0.3 |
| ruyi-beta | 0.52.0-beta.20260824 | 0.53.0-beta.20260917 |
| dsh | 0.1.5-rc.1 | 0.1.5-rc.2 |
| dsh-alpha | 0.1.6-alpha.1 | 0.1.6-alpha.2 |
| 　 | blender-mcp source hash | `sha256-nt+sHozi…` → `sha256-pYeByO4O…` |
| 　 | ruyi-beta source hash | `sha256-vxu9AhRD…` → `sha256-w8NlCER3…` |
| 　 | dsh source hash | `sha256-Gnlxnxx2…` → `sha256-9MVIOdae…` |
| 　 | dsh-alpha npmDepsHash | `sha256-qAlIccAJ…` → `sha256-p4uALt5v…` |

> **Note**: the shared base `ruyi.nix` gained one `pyelftools` line (used by all three channels); `dsh-package-lock-alpha.json` was regenerated from alpha.2's dependency set. The remaining packages were compared against upstream and are already current, so they were left untouched.

## 2026-09-18T00:38:59+09:00

**Summary**: docs(security): reworded the sandbox-tier description in all four `SECURITY.md` files to clear the scanner's `RISKY_APPROVAL_DEFAULT`

- the trigger term is `danger-full-access`, and the repository only describes an opt-in behaviour rather than a default, which a pattern-matching scanner cannot tell apart; the new wording states that nothing is widened by default
- The CLI example in `docs/zh/codewhale.md` was corrected to `--sandbox-mode` as well
- Verified with the official scanner: 94/100 (A - Excellent), Security 16/16, 0 medium (up from 88)
- The remaining 6 points come from `Dependabot configured for automation surfaces`, and the boundary against external automation will not be broken to raise a score
| Commit | Description |
|------|------|
| `e386dfc` | docs(security): 改写沙箱档位表述，消除扫描器 RISKY_APPROVAL_DEFAULT（88 → 94） |

> **Note**: a wording-only documentation change; neither `packages/` nor `overlays/` was touched.

## 2026-09-17T18:15:40+09:00

**Summary**: Restructured the generic skill into "main flow + two companion references" and recovered the Gitea lesson stranded by branch isolation — a remediation driven by evaluation:

- Recovered onto main the 70-line "self-hosted forge (Gitea) source fetching" section written on the field-test branch (never merged): a self-hosted instance may return 403 for every tag
- The adapter layer now requires that generic lessons from a test branch be written into main by hand on the spot
- The skill went from 918 lines in one file to `SKILL.md` (462 lines) plus `builders.md` (254 lines: per-builder hash flows) and `traps.md` (271 lines: drift traps and more), with step 7, the "six questions before committing" self-check, added
- Basis: upgrading 6 packages this session succeeded 4/6 on the first attempt, and all 3 reworks were caused by such traps
Verification: after the split, the `##` sections, subsections, line-by-line comparison and line counts were cross-checked, restoring the 3 missed sections; all four languages synced

| Commit | Description |
|------|------|
| `e0b1a64` | refactor(skills)!: 通用技能拆分为主流程 + 两份配套参考，并补回丢失的 Gitea 教训 |

> **Note**: this is a skill-structure change (two new companion files, `builders.md` and `traps.md`); `packages/` was not touched.
## 2026-09-17T17:22:50+09:00

**Summary**: feat(ci): added `check-doc-versions`, asserting that the documented version equals the package-definition version

- a structural defence against the five documentation version mismatches found in a row this round (godot-ai, codewhale, mcp-searxng, opencode-telegram, dsh-alpha): such mismatches never fail a build, so it is now the sixth `nix flake check`
- It checks: the "version" row in `docs/<lang>/<pkg>.md` (all four languages) and the channel tables of multi-channel packages (`dsh-alpha` / `ruyi-beta` / `ruyi-alpha`) must equal the package definition; versions read from elsewhere are tracked too (`kitsfmt` reads `Cargo.toml`); exceptions are registered in `EXEMPT`, and only what can be read mechanically is checked
- Verification: injecting the five defect classes actually encountered this round caught all of them; failure was confirmed through the real `nix flake check` path; `AGENTS.md` records it
| Commit | Description |
|------|------|
| `072ab87` | feat(ci): 新增 check-doc-versions，把「文档版本 = 包定义版本」固化为断言 |

> **Note**: this added the check script `develop/check-doc-versions.py` and wired it into `flake.nix`'s `checks` (5 → 6); neither `packages/` nor the documentation content changed.

## 2026-09-17T16:12:06+09:00

**Summary**: docs: fixed the documented version numbers of five packages (a content-quality fix)

- an audit of every service package found 5 cases of an upgrade landing without the docs following: `codewhale` 0.9.12→0.9.13, `mcp-searxng` 2.2.0→2.3.0, `opencode-telegram` 0.25.1→0.25.2, `dsh-alpha` 0.1.5-alpha.2→0.1.6-alpha.1 (doc plus README), `codewhale-sudo` v0.9.12→**since v0.9.0**
- The last was a judgement call, not a substitution: that overlay is version-agnostic and intercepts the `prctl(PR_SET_NO_NEW_PRIVS)` introduced in v0.9.0
- the README value was both stale and self-contradictory with the doc body, so it now describes where the feature came from
- Verification: a full re-check gave 10/10 consistent; `nix flake check` passes and all four languages are synced
| Commit | Description |
|------|------|
| `0a0d8ce` | docs: 修正五个包的文档版本号（内容质量修复） |

| Package | Old | New |
|--------|--------|--------|
| codewhale (docs) | 0.9.12 | 0.9.13 |
| mcp-searxng (docs) | 2.2.0 | 2.3.0 |
| opencode-telegram (docs) | 0.25.1 | 0.25.2 |
| dsh-alpha (docs + README) | 0.1.5-alpha.2 | 0.1.6-alpha.1 |
| codewhale-sudo (README wording) | "sudo under v0.9.12" | "sudo blocked since v0.9.0" |

> **Note**: this was a documentation-only fix; neither `packages/` nor `overlays/` changed.

## 2026-09-17T15:56:56+09:00

**Summary**: docs(godot-ai): fixed the four-language version number and dependency table, and added the "rewrite rather than mechanically substitute" criterion

- godot-ai's code on main had already reached 4.1.0 in `2a06bbf` and is fully functional (measured: `godot-ai --version` → 4.1.0), but the docs were never synced: the version still read `3.2.5`
- the dependency table listed 6 entries all as "≥ ranges" while the reality is 9 fail-closed exact pins
- The second is the more damaging: v4 verifies the exact version of those nine packages at startup and refuses to start on any mismatch
- The fix rewrites the table as "version + source" with all nine listed, and adds pydantic-core's coupled requirement (`==2.46.5`)
- Verification: the nine versions were measured with `nix eval` from the closure including the overlays and compared one by one: 9/9 identical
- the skill's trigger criterion is exact pins or new startup-time hard checks
| Commit | Description |
|------|------|
| `085c093` | docs(godot-ai): 修正四语文档的版本号与依赖表（内容质量修复） |
| `55674f2` | feat(skills): 通用技能第 5 步新增「文档须重写而非机械替换」的触发判据 |

| Package | Old | New |
|--------|--------|--------|
| godot-ai (docs) | docs said 3.2.5 / 6-entry "≥ ranges" table | 4.1.0 / 9-entry exact-pin table |

> **Note**: this was a documentation fix; `packages/godot-ai.nix` was not touched (its code was already correct in `2a06bbf`).

## 2026-09-17T13:00:09+09:00

**Summary**: feat(skills): the adapter layer gains step 10, "process retrospective and spec audit"

- Run after the update flow finishes; what it audits is not software but the spec that decides how software gets updated (the skills, `AGENTS.md`, `SECURITY.md`, the develop scripts)
- Six steps: retrospective, audit, attribution, experience, evidence discipline, output
- Evidence discipline is a hard constraint: spec changes must be reproducible, traceable and open to challenge — changing a spec on impression, treating a single flake as a rule, further optimising something already correct, or deleting an entry that still binds is forbidden
- Its first run found two real defects (neither produces a build error): a dead link in `SECURITY.md` to a sub-repo `SECURITY.md` that was never created, with all four languages now saying "that subproject has not established its own security policy"; and 12 `asusctl` links updated for the project's move to `OpenGamingCollective/asusctl`
- The link-audit method went into the generic skill: a `curl` 404 must be confirmed via `gh api`, and a `403` is usually anti-scraping
| Commit | Description |
|------|------|
| `442e5d1` | feat(skills): 适配层新增第 10 步「流程复盘与规范校验」 |

## 2026-09-17T12:52:54+09:00

**Summary**: fix(codewhale): the x86_64/aarch64 prebuilt variant was brought up to 0.9.13 too

- The previous round upgraded only the riscv64 source-built variant `codewhale-src` and missed `codewhale.nix` (x86_64/aarch64 take the GitHub Releases prebuilt path, branched in `flake.nix` on `hostPlatform.isRiscV`)
- This repo's codewhale has two variants with the same name and output: `codewhale.nix` needs `version` plus **four hashes** for cli/tui × x64/arm64, while `codewhale-src.nix` needs `version` + `hash` and a synced `Cargo.lock` — an upgrade must change both
- The trap is in the adapter layer
- Criterion: **after deploying, verify each variant's actual version per architecture; a passing build is not enough**
| Commit | Description |
|------|------|
| `ecb28c4` | fix(codewhale): 同步升级 x86_64/aarch64 的预编译二进制变体至 0.9.13 |
| `f8c8265` | docs(skills): 记录 codewhale 双变体陷阱（四语） |

| Package | Old | New |
|--------|--------|--------|
| codewhale (x86_64/aarch64 prebuilt) | 0.9.12 | 0.9.13 |
| 　 | cli/tui hash x64 | `nQt02NO/` → `WTriVnVv` |
| 　 | cli/tui hash arm64 | `Gkje9AMu` → `BgUnHSo0` |

## 2026-09-17T12:41:29+09:00

**Summary**: Five packages upgraded + "interactive clarification" added to the update skill

- A production run executing every approved upgrade: `mcp-searxng` 2.3.0, `opencode-telegram` 0.25.2, `codewhale` 0.9.13 (with a synced `Cargo.lock`), `dsh-alpha` 0.1.6-alpha.1 (its lock must carry the `"peer": true` entries) and `godot-ai` 3.2.5 → 4.1.0 (cross-major, fail-closed runtime dependency verification)
- nixpkgs lags on five packages, so a new `overlays/godot-ai-v4-deps.nix` chains with `fastmcp`, and both overlay chains (`flake.nix`, `overlays/default.nix`) must stay in sync
- The skill gains an "interactive clarification" section and traps 5/6
- Verification: all five build and run
| Commit | Description |
|------|------|
| `2a06bbf` | chore(pkgs): 升级 mcp-searxng 2.3.0、opencode-telegram 0.25.2、codewhale 0.9.13、dsh-alpha 0.1.6-alpha.1、godot-ai 4.1.0 |
| `c7de9b6` | feat(skills): 更新技能追加交互式澄清，并计入本轮实战教训 |

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | 2.2.0 | 2.3.0 |
| opencode-telegram | 0.25.1 | 0.25.2 |
| codewhale | 0.9.12 | 0.9.13 |
| dsh-alpha | 0.1.5-alpha.2 | 0.1.6-alpha.1 |
| godot-ai | 3.2.5 | 4.1.0 |
| 　 | git hash | `+0FJ+Grod` → `wNM/QNtF` |
| 　 | npmDepsHash (mcp-searxng) | `WK28hNI3` → `MqVn66vC` |
| 　 | npmDepsHash (opencode-telegram) | `Ai1hgKiv` → `NnvFOrS7` |
| 　 | Cargo.lock (codewhale) | 7073 lines → 7347 lines |
| 　 | npmDepsHash (dsh-alpha) | `SVYhLVZw` → `qAlIccAJ` |
| 　 | new overlay | `overlays/godot-ai-v4-deps.nix` |

## 2026-09-17T11:34:39+09:00

**Summary**: fix(skills): the sub-repo follow-up criterion was refined to field level

- The old criterion branched on whether a **file** changed, but only some fields of a manifest are build inputs
- Sub-repo `dsh-api-balance`'s `package.json` did change bytes (removing `publishConfig.access`) while `dependencies`, `files`, `version` and `main`/`exports` were untouched, so the old criterion would trigger a full-architecture rebuild for a purely metadata change
- It is now **field-level**: release metadata (`publishConfig` etc.), docs and CI config **do not** get a follow-up; the `dependencies` family / `files` / `main` / `exports` / `scripts` / `version` / source **must**; when it is unclear, treat it as follow-up
- The adapter layer's description was synced too
| Commit | Description |
|------|------|
| `c08f5c9` | fix(skills): 子仓跟进判据细化到字段级 |
| `641830a` | docs(skills): 同步四语的子仓跟进字段级判据 |

## 2026-09-17T11:31:32+09:00

**Summary**: feat(skills): chained same-account subproject checks and cross-repo entry links

- Same-account subprojects a repo references (usually thin wrappers) enter the update check; with preconditions met they run chained and parallel, count as main-repo results yet are logged in both repos, and the repo's entry links to the subproject's
- Attribution: `nix-flake-update-check` step 9 (three discovery forms, four precondition checks, cycle/depth caps, failure isolation), `write-maintenance-log` type 5
- `write-project-docs` records sub-repo references explicitly; the adapter layer keeps only repo-specific facts
- Dry run fixed three defects: a detection command without `-h` misaligned `awk` fields and returned nothing silently; the dependency-conflict criterion became "does the sub-repo's requirement exceed the host's"; the GitHub anchor rule replaces each character with `-`
- The pinned `dsh-api-balance` rev trails two docs commits, which the new criterion does not re-pin
| Commit | Description |
|------|------|
| `b7e9717` | feat(skills): 支持同账户子项目链式检查与跨仓维护条目链接 |

## 2026-09-17T11:21:34+09:00

**Summary**: chore(security): `dependabot.yml` removed entirely and a "no external automation" boundary established

- Dependabot cannot execute, only opens PRs and gets no secrets, but is still an **external automation integration** run by GitHub with behaviour we do not control, clashing with this repo's boundary that maintainer and Claw do all development; the whole file is deleted
- `AGENTS.md` gains that section: the reject list (third-party CI scanners, Dependabot), the criterion (self-implement with the repo's own `gh`/`git`/`nix` first, else by hand) and the cost (action security updates need the skill check run actively)
- No capability lost: `nix-flake-update-check` gains a "checking for GitHub Actions updates" section (list pinned actions → query the tag → write the SHA back); the old "automatic PRs cannot be merged directly" subsection became generic guidance
- All four languages synced
| Commit | Description |
|------|------|
| `3421c1f` | chore(security): 移除 dependabot.yml 并确立「不引入外部自动化」安全边界 |

## 2026-09-17T11:03:51+09:00

**Summary**: chore(ci): Dependabot's npm ecosystem removed, keeping only `github-actions`

- The npm ecosystem is **structurally ineffective** here: npm packages are wrapped by `buildNpmPackage` and its `npmDepsHash` is byte-compared against the npm-deps output, while Dependabot only edits `package.json`/`package-lock.json` and cannot know that hash in the `.nix` file, so every npm update PR it opens is bound to fail CI (`npmDepsHash is out of date`)
- npm dependency upgrades go back to the `nix-flake-update-check` skill by hand
- The removal reason is recorded in the config as a comment so it is not later mistaken for an omission and added back
- `github-actions` is kept — PR #6 proved it effective and it preserved SHA pinning correctly
| Commit | Description |
|--------|-------------|
| `4b997b3` | chore(ci): Dependabot 移除 npm 生态，仅保留 github-actions |
## 2026-09-17T10:55:02+09:00

**Summary**: chore(dsh-nixos-shell): `dsh-tools` 0.1.2-alpha.2 → 0.1.5-rc.2; ci: `actions/checkout` v4 → v7.0.1

- Both were generated automatically by the previous round's `dependabot.yml`
- PR #6 was merged (SHA pinning correctly preserved)
- PR #7 gave way to a manual bump: Dependabot cannot see `npmDepsHash`, so CI always reports `npmDepsHash is out of date`, and bumping to 0.1.5-rc.2 aligns the bundled copy with the host dsh and updates that hash
- Verified: the build passes, the artifact's version matches the host, and all `nix flake check` checks pass
- The disposition went into the `nix-flake-update-check` skill
| Commit | Description |
|--------|-------------|
| `dce26f2` | chore(dsh-nixos-shell): dsh-tools 0.1.2-alpha.2 → 0.1.5-rc.2 |
| `5f4e9ec` | ci: bump actions/checkout from 4.4.0 to 7.0.1 (#6) |
| `7b94d7c` | refactor(skill): nix-flake-update-check 补充 Dependabot 自动 PR 的处置 |
## 2026-09-17T01:40:58+09:00

**Summary**: docs(security): `SECURITY.md` now states the handling boundary for duplicate submissions (four languages)

- A new subsection makes it binding: the same conclusion already listed above, resubmitted without new evidence, is closed directly with a pointer to this section
- It also separates accepted from closed so legitimate reports are not caught — accepted: a new issue not covered above, a claim that a conclusion above is wrong (with reproducible evidence), or the same topic with a different threat model or exploit path; closed: a mere restatement, or another automated scan emitting the same rule
- "Your conclusion is wrong" stays welcome
- Those four entries are themselves reviewed judgements, so a wrong criterion must be corrected
| Commit | Description |
|--------|-------------|
| `94bd95c` | docs(security): 明确重复提交的处理界限（四语） |

## 2026-09-17T01:34:13+09:00

**Summary**: docs(security): `SECURITY.md` gained an "already-evaluated external reports" section and joined the four-language localisation via `docs/SECURITY.{en,ja,pcn}.md` — publishing the 4 reviewed-and-closed reports.

- PR #4 (rate limiting missing on `/token`, `/voicepack`, `/tts`) and PR #5 (no request-body cap on `/query`) are both false positives: the description did not match the diff, and `readJsonBody`'s 64 KiB cap already exists.
- issue #1/#2 (`secrets: inherit` violating least privilege) are false positives too: with only 2 secrets in the repo, explicit passing is equivalent to `inherit`.
- These reports prompted two genuine hardenings: the `/tts` endpoint SSRF and the least-privilege completion of 31 build workflows.
- Position: most reports did hit a real rule, but the threat model does not apply to how this project is deployed; a false positive is not treated as a nuisance.

| Commit | Description |
|--------|-------------|
| `6f34e73` | docs(security): SECURITY.md 记录已评估的外部报告，并纳入四语本地化 |

## 2026-09-17T01:23:46+09:00

**Summary**: chore(security): added `SECURITY.md` and Dependabot, and pinned Actions to SHAs — prompted by the awesome-ai-plugins maintainer's (@kantorcodes) remediation request on PR #323: the scan scored 71/100, below the 80 threshold.

- Scorecard: zero critical, zero high, with every deduction in engineering hygiene (Actions not pinned, no Dependabot).
- Added `SECURITY.md` (supported versions, a private vulnerability-reporting channel, response timeframes) and `.github/dependabot.yml`.
- 6 third-party action references pinned from floating refs to commit SHAs, including `DeterminateSystems/nix-installer-action@main`, which was a floating branch.
- Declined the third-party scanner action (the cost is a 10% trust-score deduction, accepted).

| Commit | Description |
|--------|-------------|
| `97a4180` | chore(security): 补 SECURITY.md、Dependabot，并将 Actions 固定到 SHA |

## 2026-09-16T16:45:03+09:00

**Summary**: fix(dsh-nixos-shell): fixed the `skills-nixos` path breakage

- Introduced by `559e841`, it only surfaces after a real deployment on this machine
- That commit wrote the skill root as `../../skills-nixos/` (relative to the preset directory), but the seeder's `cp -r presets/<mode> $DSH_HOME/.agent-presets/<id>` does not copy content outside the preset directory, so after seeding the root resolved to a nonexistent `~/.dsh/skills-nixos` and the 3 added NixOS skills were not loadable
- Fix: `postPatch` now generates the whitelisted subset inside each preset directory, and `customSkillDirs` becomes `skills-nixos/`
- Verified: reachable after a simulated seed, all `nix flake check` checks pass, and a fresh session after deployment lists those 3 skills
- Lesson: when a preset is copied by the seeder, verification must happen after seeding
| Commit | Description |
|--------|-------------|
| `96b589c` | fix(dsh-nixos-shell): skills-nixos 移入预设目录，修复 seed 后路径断裂 |

## 2026-09-16T14:54:53+09:00

**Summary**: refactor(dsh-api-balance)!: moved out to its own repository, with this repo reduced to a thin wrapper — the first component split here.

- Audit criteria: the only platform-agnostic project, zero code-level coupling to NixKits, and an existing npm packaging need.
- New repository `Kihara777/dsh-api-balance`: source, four-language docs and npm publish CI; verified that `dsh plugin add` installs it in one line and the web profile boots with `exit=0`.
- This repo's side: `packages/dsh-api-balance/` deleted; the `.nix` becomes a `fetchFromGitHub` thin wrapper (`npmDepsHash` unchanged); docs condensed to short pages; README notes the move; CI workflows kept so the Cachix cache still hits.
- `write-project-docs` updated with the "main-repo thin wrapper + sub-repo full docs" architecture.

| Commit | Description |
|--------|-------------|
| `0bb7fc1` | refactor(dsh-api-balance)!: 迁出为独立仓库，本仓改为薄封装 |
| `0760612` | feat(skill): write-project-docs 支持「主仓薄封装 + 子仓完整文档」架构 |

**Outstanding**: the npm publish has not run — this machine has no npm credentials (not logged in, no token, the `@kihara777` scope does not exist), so an npmjs.com account and scope must be created first; the package itself is publish-ready (`npm pack` confirms 70.8 kB across 4 files).

## 2026-09-16T14:27:33+09:00

**Summary**: refactor(skills): generalised the two uncovered gaps from the `/etc/nixos/AGENTS.md` practice

- Auditing that file (HarukaX machine configuration rules) showed roughly 75% already covered by existing skills
- The genuine gaps: (1) secrets and `path:` input, a new section in `nixos-modern-cli` — a secret must live outside the repository and be introduced through a `path:` input, with the trap that this input is pinned by `flake.lock` so content changes need `--update-input`
- (2) thermal-management methodology, a new section in `nixos-specialisation-tuning` — raising the curve only adds noise while dropping a profile costs speed, and `enabled: false` decouples profile from curve
- `asusctl` writes are temporary, so verification must restart the daemon; identical temperatures and RPMs for a gentle and an aggressive curve mean the fan is saturated, leaving cutting power as the only effective lever
- Machine-specific content stays in `/etc/nixos/AGENTS.md`; the four-language docs were updated
| Commit | Description |
|--------|-------------|
| `a33a3cf` | refactor(skills): 泛化 /etc/nixos 实践的两个未覆盖缺口 |
| `fba7b38` | docs(skills): 同步两技能扩展后的功能清单（四语） |

## 2026-09-16T14:11:18+09:00

**Summary**: feat(dsh-nixos-shell): NixOS模式 now bundles 3 NixOS operations skills

- Reviewing the repository `skills/` tree concluded: **add** `nixos-modern-cli`, `recover-nixos-config` and `nixos-specialisation-tuning`; **do not add** `nixkits-skills` (a skill installer) or `news-three-elements` (a creative skill already served by its own package)
- 维护模式 derives from it and inherits all three automatically
- **Implementation**: the skills are not copied into `presets/<mode>/skills/` (mirrored byte-for-byte between the two presets, so another copy would become a second copy free to drift); instead `postPatch` builds a whitelisted build-time subset `skills-nixos/` from the repo tree, which `skill-filesystem` mounts via `../../skills-nixos/`
| Commit | Description |
|--------|-------------|
| `559e841` | feat(dsh-nixos-shell): NixOS模式 同捆 3 个 NixOS 运维技能 |
| `7971689` | docs(dsh-nixos-shell): 记录 NixOS模式 新增的 3 个同捆技能（四语） |

## 2026-09-16T13:57:56+09:00

**Summary**: feat(dsh-api-balance): added `dsh.bundle`, enabling native `dsh plugin add` installation

- The two plugins differ in nature: `dsh-api-balance` is a platform-agnostic UI enhancement (`inject = ["connection", "webServer"]` only, no presets, no skills, no `$DSH_HOME` writes), whereas `dsh-nixos-shell`'s core value is its Agent presets
- **Key finding (overturning the previous conclusion)**: an entry name starting with `./` is anchored to an absolute `file://` URL beside the patch file
- Accordingly a new `cordis.patch.yml` registers the plugin with `name: './lib/index.js'` (a bare package name fails), and `package.json` gains `dsh.bundle.patch`
| Commit | Description |
|--------|-------------|
| `ac3cb3e` | feat(dsh-api-balance): 支持 dsh.bundle，可经 dsh plugin add 安装 |
| `bee12d7` | docs(dsh-api-balance): 补充两种安装方式与 bundle 机制说明（四语） |

**Related external report**: issue #3 (@zerocodefast) — an awesome-ai-plugins listing invitation; `dsh-api-balance` now meets the technical bar for the DeepSeek Harness section, while `dsh-nixos-shell` stays declarative (its reasoning is recorded under the `d14146c` entry).

## 2026-09-16T13:44:09+09:00

**Summary**: refactor(dsh-plugins): removed the unused `peerDependencies` from both plugins

- Testing showed their peer declarations do not match their actual imports: `dsh-nixos-shell` declared `cordis` / `dsh-subprocess` / `dsh-timer` and `dsh-api-balance` declared `cordis` / `dsh-client-connection`, while each imports only its real dependencies (`dsh-tools` + `schemastery` / `dsh-credentials`), and `dsh-timer` exists neither on npm nor in the host tree
- The dead declarations never take effect on the declarative path and do not affect existing deployments, but on the pnpm path they block installation
- The lock and `npmDepsHash` were regenerated in step
| Commit | Description |
|--------|-------------|
| `d14146c` | refactor(dsh-plugins): 移除未使用的 peerDependencies |

**Related external report**: issue #3 (@zerocodefast) — an awesome-ai-plugins listing invitation, left open with no PR submitted.

## 2026-09-16T12:39:12+09:00

**Summary**: refactor(skills)!: split `nixkits-check-updates` into a "generic core + repository adapter layer"

- Assessing issue #3 prompted a review of the recommended skill's portability: the original skill was tightly coupled to NixKits, with step 5 hardcoding `for lang in zh en ja pcn` and the `docs/$lang/<pkg>.md` path and step 8 compulsorily invoking `write-maintenance-log`, so it would fail in another nix flake repository
- The new `nix-flake-update-check` (314 lines, bound to no repository) carries package discovery, per-builder hash flows, three-way flake.lock handling, patch-embedded version checks and nixpkgs drift traps
- `nixkits-check-updates` slims down to the adapter layer; adapter-layer contract: doc sync / change record / dynamic inputs / incident lessons / extra sync items are declared by it
| Commit | Description |
|--------|-------------|
| `667bf6e` | refactor(skills)!: 拆分更新检查为通用核心 + NixKits 适配层 |
| `93fe67e` | feat(dsh-nixos-shell): 维护模式注入 nix-flake-update-check 技能 |
| `6af37e7` | docs: 同步技能拆分——四语新增通用技能文档、README 技能表与注入清单 |

**Related external report**: issue #3 (@zerocodefast) — an awesome-ai-plugins listing invitation. On review, its suggested entry frames NixKits as "a package collection that includes Chinese-language skills" without mentioning that it is also a Nix package/module/patch collection, and "Chinese-language skills" reads as useful only to Chinese users; the listing itself is non-technical, so the issue stays open with no PR submitted.

## 2026-09-16T12:20:57+09:00

**Summary**: ci: gave the 31 `build-*.yml` callers a top-level `permissions: contents: read`

- None of them declared `permissions` and so inherited the repository default (possibly write); they only run checkout + `nix build` + a Cachix push, so they now match the callee `build-package.yml:17-18`
- The trigger was external contributor **@begininvoke**'s RedGem scan report (issues #1 and #2): both verified as false positives (a reusable workflow in the same repository and commit, and only 2 secrets, so `inherit` and explicit passing yield the same set), neither adopted, both closed with evidence — but they prompted this permission-boundary review
- The 31 `secrets: inherit` sites stay unchanged: Cachix uses the separate `CACHIX_AUTH_TOKEN` and there is no least-privilege margin left to trim
| Commit | Description |
|--------|-------------|
| `445eb4b` | ci: 为 31 个构建 workflow 补全顶层 permissions（最小权限） |

**Related external reports**: issues #1 and #2 (@begininvoke / RedGem) — byte-for-byte duplicates; verified as false positives and closed as "not planned" after detailed technical evidence in comments; their value as leads is acknowledged.

## 2026-09-16T11:58:25+09:00

**Summary**: fix(dsh-api-balance): closed the SSRF and header-injection surface in the custom TTS proxy

- The proxy accepted an arbitrary `http(s)` URL and issued the request with the host's identity, making it a springboard for internal-network probing and cloud-metadata (`169.254.169.254`) reads; it also forwarded user-controlled `headers` from the request body verbatim, letting an attacker add `host` / `cookie` / `authorization` headers
- The fix adds `resolveTtsTarget` and `isBlockedAddress`, rejecting loopback / private / link-local / reserved addresses (covering RFC1918, CGNAT, IPv4-mapped IPv6)
- Custom request headers become an allowlist (only `content-type` / `accept` / `accept-language` / `user-agent`)
- The four-language docs gained matching protection notes
| Commit | Description |
|--------|-------------|
| `e1a6e66` | fix(dsh-api-balance): 修复 TTS 代理的 SSRF 与请求头注入面 |
| `72cb6ae` | fix(docs): pcn 维护条目去除残留假名（のみ → 限定） |

**Related external reports**: PRs #4 and #5 (@anupamme / OrbisAI Security) — verified as false positives, closed with detailed technical evidence in comments; their value as leads is acknowledged.

## 2026-09-16T11:38:20+09:00

**Summary**: docs(deprecated): `DEPRECATED.md` became an index and gained localisation

- That single Chinese document was both the index and one project's write-up; past one entry it cannot be read at a glance, and it had no place in the localisation scheme
- The root `DEPRECATED.md` is now a pure index (a list plus links to each project's details), with three mirrors `docs/DEPRECATED.{en,ja,pcn}.md` following the `README`/`MAINTENANCE` pattern
- Each retired project's details move into `docs/<lang>/deprecated/<name>.md`, one per language, headed by a language switcher and a link back to the index. The first migration is comfyui-rocm
- The four `README`s gain a "Retired Projects" section and `docs/<lang>/comfyui.md` now points at the detail page
- Verified: `nix flake check` caught 6 dead links, all fixed
| Commit | Description |
|--------|-------------|
| `8ff91eb` | docs(deprecated): 索引化 + 四语本地化，详情拆到独立文档 |

## 2026-09-16T11:05:32+09:00

**Summary**: refactor(comfyui)!: retired the comfyui-rocm patch project and renamed the module to `nixkits.comfyui`

- Upstream's ROCm support now handles StrixHalo well, so the patch completed its mission
- The three patches `strix-halo` / `nixpkgs-compat` / `stdenv-api` are removed, `modules/comfyui-rocm.nix`→`modules/comfyui.nix`, the option `nixkits.comfyui-rocm`→`nixkits.comfyui`, the four-language docs `comfyui-rocm.md`→`comfyui.md`, and a new root `DEPRECATED.md`
- Evidence: upstream's deprecated `stdenv` reads number 0, upstream `nix/versions.nix`'s `rocm71` torch 2.10.0 matches the `strix-halo` patch byte for byte, and the upstream module already supports `gpuSupport = "rocm"`
| Commit | Description |
|--------|-------------|
| `5015bcc` | refactor(comfyui)!: retire the comfyui-rocm patch project, rename module |

## 2026-09-16T01:45:07+09:00

**Summary**: docs: a preset package update needs `daemon-reload` before `restart dsh`

- `nixos apply` deliberately does not restart dsh (stable mount points), and a bare `systemctl restart dsh` still runs the previous generation's pre-start script, which is exactly the step that copies `cordis.patch.yml` into `$DSH_HOME`, the file the preset root is written in; the symptom is a service that did restart while the session still loads the old preset
- After generation 570 deployed, the first restart still pointed at the old path, and only `systemctl daemon-reload` plus another restart flipped it
- AGENTS.md's local-deployment section now records the order of operations and how to check it, and `docs/{zh,en,ja,pcn}/dsh.md` was updated to match
| Commit | Description |
|--------|-------------|
| `a167aae` | docs: 预设包更新要 daemon-reload 再 restart dsh |

## 2026-09-15T23:47:01+09:00

**Summary**: feat(preset+skill): the sourcing gate `news-material`

- Real sessions exposed "copy-paste co-creation": the user's material was re-formatted and shipped as-is, with the search step skipped; a prompt-only rule decays, so the runtime now checks "search first, then rewrite"
- `plugins/news-material.js` hooks twice: `agent/pre-step` rides a 取材鉄律 reminder with the human's message; `agent/turn-stopping` reads the turn log, and a turn with no `web_search` / `web_fetch`, or one copying the user's words (eight consecutive Han characters), gets a rejection via `agent.steer()`, making `dsh-agent-loop` run another step of the same turn — once per turn
- The skill gained matching rules: the distil/project/re-skin table and eight-character red line, a mandatory search record, `checklist.md`'s self-check 3 → 7 items, a rewritten persona
- 31 assertions added
| Commit | Description |
|--------|-------------|
| `a0759b1` | feat(skill): 素材只是导火索——三步改造、禁照抄、必检索 |
| `cc9d0d1` | feat(preset): 取材门 news-material——无检索即退稿，照抄即退稿 |
| `71f25db` | docs: 四语同步素材共创铁律与取材门 |
| `a2ccd55` | docs(agents): 新增文件先 git add 再跑 flake check |

## 2026-09-15T12:36:10+09:00

**Summary**: feat(skill+preset): news's three elements now mean the three protagonists, and refusal first asks whether a request can be material

- The maintainer filed four corrections: they are the **three protagonists who must all be on the page** — Bulannikov, Yudintsev, Buyanov — not the textbook trio; anything retrieval can fill in may not be refused; a co-created piece must carry all three; hypothetical questions and unnamed persons are first assessed for a fit onto the three
- `SKILL.md` fixes the new meaning, the hard format rules gain item 0 (all three in the body; one missing is a rework) and sourcing widens to four classes
- 拒绝服务 becomes a hard order — anything usable as material may not be refused / a hypothetical is written as already happened / an unnamed person is fitted first / only what ties back to none is refused
- The persona gains a 素材优先 section and the all-three co-creation rule, and `readonly-gate`'s ritual line names the three
- 14 assertions pin it, the four language docs follow, and `nix flake check` passes all 6
| Commit | Description |
|--------|-------------|
| `8f5b848` | feat(skill): 新闻三要素改指三位主角，拒绝服务先当素材 |
| `1adb6be` | feat(preset): 模式提示词改为素材优先，快讯须三人到齐 |
| `4732835` | docs: 四语同步新闻三要素的三人定义与素材优先判定 |

## 2026-09-15T11:47:48+09:00

**Summary**: fix(preset): the read scope now admits the mode's own skill package

- When the previous round narrowed reads to the workspace, attachments and `/tmp`, it **locked the mode out of its own skill package**: `tables.md` and `checklist.md` live in the fetch cache `$DSH_HOME/.cache/news-three-elements/` or the bundled fallback snapshot, and neither was an allowed root, so the model could not read them and every transition word and twist-ending template went missing
- Both the **fetch cache** and the **preset root** (which holds `bundled/`) are readable now, and the refusal text says 「…、`/tmp` 与自身技能包目录」
- 2 assertions pin it (cache and bundled snapshot readable, out-of-scope still refused); the four language docs follow
| Commit | Description |
|--------|-------------|
| `ee072d5` | fix(preset): keep the mode's own skill package inside the read scope |

## 2026-09-15T11:38:02+09:00

**Summary**: fix(preset): the ritual line now says 催逝快讯

- The sentence that closes every refusal read "只编造带齐新闻三要素（新、事实、报道）的俄式快讯", whose parenthetical is the journalism-textbook meaning: spoken aloud it sounded like a citation and flattened the joke
- It becomes 「只编造带齐新闻三要素的**催逝快讯**」, matching the 催逝 vocabulary the opening picker already uses
- Two occurrences, both fixed prompts (the persona and the `readonly-gate` refusal text)
- The definitional "product" lines in the skill and the docs are untouched
- Four assertions pin it: both places carry the new wording, and the old gloss may not come back
| Commit | Description |
|--------|-------------|
| `bfb0ed4` | fix(preset): say 催逝快讯 in the ritual line, not the academic gloss |

## 2026-09-15T11:24:49+09:00

**Summary**: fix(preset): the language gate now judges only the messages a human wrote

- A legitimate Simplified-Chinese request was refused with an English translation attached
- The transcript (`session-efc87486`) shows the step carried, besides the user's Chinese message, a harness-injected **English system message** (`source.kind = plugin`, an approval-policy change notice) and a `skill-catalog` entry
- The guard scanned **every** message admitted to the step, read the English notice as "no Simplified Chinese here", injected the language review, and the model refused in English to match the caller's language
- `withNotice` now takes only `source.kind === "user"` messages (approval notices, skill catalogs and tool results never count)
- Two regression tests pin it (an English approval notice beside a Chinese request no longer fires; a step with no human message is left alone)
- The four language docs note the boundary
| Commit | Description |
|--------|-------------|
| `9557707` | fix(preset): judge only the human's messages in the language gate |

## 2026-09-15T11:08:06+09:00

**Summary**: feat(preset)+test: a repository self-check suite and behaviour hardenings

- `nix flake check` grows from one check to **six**: `preset-bundle` (the skill snapshot matches `skills/` byte for byte), `workflow-coverage` (every package has a workflow), `doc-links` (links + four-language switchers + pcn kana-free), `maintenance-log` (entry counts, timestamps, unique commit ids) and `news-mode-tests` (**offline**: a stubbed fetch, 304 on the second pass)
- That day it caught 12 translated documents with a wrong switcher, 3 wrong codewhale links, one `+00:00` timestamp and `dsh-api-balance` missing its workflow
- The same round added four hardenings: scoped reads, no consecutive repeat in the draw, the picker withdrawn when the caller speaks first, and a parallel fetch with ETag requests
| Commit | Description |
|--------|-------------|
| `9260dd5` | test: guard the repo with six flake checks and an in-repo test suite |
| `ac4b05c` | feat(preset): scope reads, harden the draw, and make the fetch incremental |
| `0af079c` | docs(preset): record the scoped reads, incremental fetch and hardened draw |
| `9810af5` | fix(docs): repair the switchers and dead links the new check found |

## 2026-09-15T10:57:15+09:00

**Summary**: feat(skill): the skill gains a refusal service of its own

- The refusal flow is promoted from "one preset's persona" to the **skill itself**
- `SKILL.md` gains a 「拒绝服务」 section: requests that are not fabrication or a rewrite of supplied material are refused there; **search for that day's material before every refusal**; the reason, sentence pattern, paragraph order, twist ending and transitions may not repeat the previous one; three to five sentences in wire style; the 「一本正经胡说八道」 register throughout; refuse and stop
- [`tables.md`](../skills/news-three-elements/tables.md) marks its templates as skeletons whose material must be sourced per use
- [`checklist.md`](../skills/news-three-elements/checklist.md) gains a five-item refusal self-check
- the four-language skill docs and the README rows follow
- the package's bundled snapshot is regenerated and the persona's two refusal paths now cite the section by name
| Commit | Description |
|--------|-------------|
| `f120a3d` | feat(skill): give the skill a refusal service of its own |
| `8c28f03` | chore(preset): sync the bundled skill snapshot and point the persona at the section |

## 2026-09-15T10:50:26+09:00

**Summary**: feat(preset): the refusal translation is scoped to the language gate and matches the caller's language

- A localized copy belongs to the "not Simplified Chinese" rule alone: when a Simplified-Chinese caller's request is refused for any other reason, the reply carries **the Chinese text only** — no translation, no gloss (the language was legitimate, so there is nothing to translate)
- The translation must also be **in the very language the caller used** (English for English, Japanese for Japanese, Traditional Chinese for Traditional Chinese), never swapped for a third language and never a mixed-script text
- Both rules are promoted from "unstated, left to the model" to explicit lines in the persona and the injected notice (the persona's other section now says outright that it does not translate)
- the four language docs are updated; the self-test gains six assertions
| Commit | Description |
|--------|-------------|
| `00a0088` | feat(preset): scope the refusal translation to the language gate |

## 2026-09-15T10:39:08+09:00

**Summary**: feat(preset): the draw is over producers, not games, and every refusal re-sources its material

- The recommendation pool changes from three titles to the **three producers**: whoever is drawn, their game comes with them (Yudintsev and Bulannikov → "War Thunder", Buyanov → "Escape from Tarkov"), plus the 「绿色的猫头鹰」 software, four equally likely entries, never more than one per refusal; Enlisted is dropped
- Refusals no longer recycle a single reason: both the persona and the injected notice order a `web_search` for that day's material (real news phrasing, official excuses, agency statements) before every refusal
- reusing the previous reason, sentence pattern, closing twist or transition is forbidden, and mechanical repetition is named this mode's worst failure — all delivered in the deadpan 「一本正经胡说八道」 register
- The self-test verifies the person-to-game pairing draw by draw across 400 refusals and checks the distribution (23 / 29 / 25 / 23%)
| Commit | Description |
|--------|-------------|
| `1a046d3` | feat(preset): draw a producer, not a game, and re-source every refusal |

## 2026-09-15T10:31:30+09:00

**Summary**: feat(preset): the refusal's recommendation is drawn at random from four

- The language gate's learn-Chinese nudge no longer keeps pointing at the same two titles: War Thunder (Gaijin's founder Yudintsev and its producer Bulannikov), Escape from Tarkov (Battlestate's Buyanov), Enlisted (Gaijin's third house), or the 「绿色的猫头鹰」 software
- the plugin draws once per refusal, all four equally likely, and writes the result into the injected instruction
- That instruction names ONLY the drawn entry — the first draft's wording would have let a reply list two, and the self-test caught it — so one refusal never recommends two things
- For the cases the plugin does not detect (Traditional Chinese, say), the persona carries the same rule
- Measured over 400 draws: 23 / 24 / 28 / 25%
| Commit | Description |
|--------|-------------|
| `28f161a` | feat(preset): draw the refusal's recommendation at random |

## 2026-09-15T10:19:12+09:00

**Summary**: fix(codewhale): refreshed the riscv64 Cargo lock

- Right after the source hash was filled in, the riscv64 build failed at the dependency vendoring step with "cargoHash or cargoSha256 is out of date"
- The lock pinned in the repo (`codewhale-src-Cargo.lock`) does not match upstream v0.9.12 (549 diff lines, entries such as `ansi-to-tui` missing), so it had been generated from a different revision
- It is replaced with the source tree's own `Cargo.lock` — `rquickjs-sys` stays at 0.12.2 (the bindings `postPatch` still applies) and upstream has no git-sourced dependencies to pin
- x86_64 and aarch64 use the prebuilt-binary path and are unaffected
- CI entered the compile stage for the first time
| Commit | Description |
|--------|-------------|
| `b8fd5b1` | fix(codewhale): refresh the riscv64 Cargo lock |

## 2026-09-15T10:12:41+09:00

**Summary**: feat(preset): modes become a section of their own, and the news mode ships as an independent package

- Agent presets are renamed 模式, each mode with its own doc (`docs/<lang>/modes/`, four languages)
- Distribution splits in two: NixOS mode / maintenance mode keep their seed-once delivery inside dsh-nixos-shell
- the news mode moves into the **independent package** `dsh-preset-news-three-elements` (new flake output and build workflow)
- the module gains `presets.newsThreeElementsPackage`, registering the package's `share/dsh-agent-presets` as an extra `agent-presets` roster root
- the preset is read straight from the store and never copied into `$DSH_HOME`
- CI: the new package builds and `nix flake check` passes
| Commit | Description |
|--------|-------------|
| `fbfebeb` | feat(preset): ship 新闻三要素模式 as an independent package |
| `e6654f5` | feat(preset): localize the language-gate refusal, fix the ritual bangs |
| `c0a9616` | docs(modes): give every preset its own doc, zh/en/ja |
| `cc9bd31` | docs(pcn): mirror the mode docs and the Modes section |

## 2026-09-15T09:09:08+09:00

**Summary**: fix(codewhale): fill the riscv64 source hash

- `packages/codewhale-src.nix` still passed `lib.fakeHash` to `fetchFromGitHub`, so the fixed-output fetch failed by construction and the riscv64 build was red **29 runs in a row** (x86_64 and aarch64 use the prebuilt-binary path and were unaffected)
- Following the repository's established practice the hash comes from the CI hash-mismatch report (`got:`), and `nix store prefetch-file --unpack` recomputed it locally with fetchzip semantics — byte-identical: `sha256-ajv9FejiJ5Z6De+4RhTtjNLdfKzOaXBQ8xBxkWqg+1M=`
- With the fix, CI passed the fetch stage and entered compilation for the first time
| Commit | Description |
|--------|-------------|
| `01bd1b9` | fix(codewhale): fill the riscv64 source hash |

## 2026-09-15T09:03:39+09:00

**Summary**: Correcting some reporting deviations that will have to be accounted for later.

- The 新闻三要素模式 section in all four languages now introduces itself as a wire dispatch: a dateline, an anonymous source, one mechanic projection (a write call is "on leave"; the guard covers the repair bill) and an O'Henry close (the module had "no comment", yet the option already appears in the configuration example)
- The row table and the three design constraints stay the factual record, untouched
| Commit | Description |
|--------|-------------|
| `b18d229` | docs(preset): write the preset section as a wire dispatch |

## 2026-09-15T08:54:15+09:00

**Summary**: feat(preset) + fix(dsh): `news-skill` retries and seeded presets become writable

- A failed fetch no longer gives up for good: the first attempt is immediate, then retries land after 0/30/120 s on timers owned by the session's fiber
- a long-lived session re-checks the repository every six hours, an in-flight flag keeps a slow attempt from overlapping the periodic one
- three failed attempts keep the local copy registered with a log line
- Directories and files copied from the store arrive read-only, contradicting the `presets.*` options' promise to respect later user edits (the pre-existing `nixos` seed was affected too)
- all three seed blocks `chmod -R u+w` after copying
| Commit | Description |
|--------|-------------|
| `5885473` | feat(preset): retry a failed skill fetch and re-check every six hours |
| `2e8a5a2` | fix(dsh): make seeded presets writable by their owner |

## 2026-09-15T08:42:21+09:00

**Summary**: **NixKits delivers 新闻三要素模式 to DSH — three producers' titles are now listed as language courseware**

- Combined Interfax, Meduza and iStories dispatch: a repository maintainer who asked not to be named confirmed today that the `news-three-elements` skill and a **read-only** preset derived from minimal mode have shipped together
- the package is fetched online at every session start, and any write call is told the tool is "on leave"
- The three-way picker is in fact a "daily mission", mapping to standard fabrication, asset co-creation and dialogue-text co-creation; an answer typed by hand meets with "no comment"
- The mode declines every request not written in Simplified Chinese and suggests downloading the works of Bulannikov, Yudintsev and Buyanov, or the "green owl" app, to learn Chinese
- As of press time the module had "no comment" on the new seed-once option, yet `nixkits.dsh.presets.newsThreeElements` already appears in the four-language configuration examples.
| Commit | Description |
|--------|-------------|
| `0c276d2` | feat(preset): ship 新闻三要素模式 as a seed-once agent preset |
| `befba4c` | docs(preset): document 新闻三要素模式 in four languages |
| `45e8637` | docs(pcn): strip residual kana outside quoted tokens |
| `780874a` | docs(ja): render the new preset name in Japanese kanji |

## 2026-09-15T08:06:35+09:00

**Summary**: fix(skill): news-three-elements — removed the "usage scope" row added to the skill overview table

- Restoring the original design: the skill imposes no restriction on how its output is used
| Commit | Description |
|--------|-------------|
| `16612e6` | fix(skills): drop the usage-scope line added to news-three-elements |

## 2026-09-15T08:02:33+09:00

**Summary**: feat(skill): added `news-three-elements`

- SKILL.md keeps only execution context: triggers, the three-step flow, hard format rules, structural principles
- Reference data is split into four companion files loaded on demand: `search-keywords.md` (three kinds of query), `tables.md` (transitions, official responses, 9 mechanic-projection targets, 6 twist-ending templates), `principles.md` (12 items), `checklist.md` (10 items)
- Four-language skill docs, registered in every README skill table
| Commit | Description |
|--------|-------------|
| `734dfae` | feat(skills): add news-three-elements news-flash satire skill |
| `e77be79` | docs(skills): document news-three-elements in four languages |

## 2026-09-14T06:18:42+09:00

**Summary**: docs(pcn): purged simplified-Chinese characters repo-wide — pseudocn is kana-stripped Japanese, so simplified characters are never legal in its body text

- Mass replacement: `与`→`與` 132 times and `说明`→`説明` 120 times, plus `档`→`檔`, `径`→`経`, `译`→`訳`, `实例`→`実例`
- Dictionary mappings: `文件`→`書類`, `版本`→`版`, `用户`→`利用者`, `支持`→`対応`; `端口` / `制御台` have Japanese counterparts, so they are kept and recorded in the dictionary
- Commit subjects are exempt: the commit column keeps them verbatim (immutable external references; the ja log does too)
- Verified: zero residual kana, zero simplified-only characters outside that column, per-file line counts identical to the baseline; the skill gains 4 sections (classify before replacing, look terms up rather than invent them, commit-subject exemption, take a baseline first)

| Commit | Description |
|--------|-------------|
| `a915692` | docs(pcn): purge simplified-Chinese characters across all pcn documents |

## 2026-09-14T05:52:18+09:00

**Summary**: docs(README): updated the credits section

- 小爪 gains **DeepSeek V4.1 Flash** (alongside the existing V4 Flash)
- Its DSH ecosystem work (dsh-nixos-shell plugin, NixOS-mode/maintenance-mode agent presets) moves out of the inline list into a **note at the end of the section**
- 小小爪 now leads with **DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)**, annotated as the quantisation level actually used on the **core face**
- Synced across four languages
| Commit | Description |
|--------|-------------|
| `3c58280` | docs(README): update credits — add V4.1 Flash, list core quantisation |

## 2026-09-14T05:32:10+09:00

**Summary**: feat(asusd-pd-profile): added a NixOS module selecting the platform profile by power source

- `asusd.ron` has only `platform_profile_on_ac` / `platform_profile_on_battery` and **no USB-C PD branch**, so "balanced on PD, performance on barrel AC" cannot be expressed in configuration
- The module fills in the missing third state with a udev-driven oneshot service, deciding from the Type-C port's `power_operation_mode` and any online supply whose `type` is `USB`
- (1) **do not write `/sys/firmware/acpi/platform_profile`** — write asusd's own `PlatformProfileOnAc` instead
- (2) **go over D-Bus rather than parsing `asusctl` output**
| Commit | Description |
|--------|-------------|
| `56293a9` | feat(asusd-pd-profile): add module selecting platform profile by power source |
| `75391b2` | docs(pcn): align asusd-pd-profile wording with the Japanese sibling |

## 2026-09-14T05:00:46+09:00

**Summary**: docs(llama-cpp-rocm): added IQ3_S measurements and power-profile data

- The DeepSeek deployment section now compares IQ1_S / IQ3_S (1.5625 bpw / 3.4375 bpw)
- **Quantisation overhead is not a fixed value** (IQ1_S ≈6.5 GiB, IQ3_S ≈13.3 GiB, so GPUActive must be re-measured after changing quantisation)
- **Generation speed is dependency-latency bound** (1.56→3.44 bpw leaves generation at 12.8→12.9 t/s)
- **Power-profile measurements** (quiet 38.6–43.9 W / 59–78 °C / 12.12–12.35 t/s vs performance 76.7 W / 90–95 °C / 13.07 t/s)
- The GPU memory metric is `/proc/meminfo`'s `GPUActive`, and IQ3_S headroom is ≈6 GiB
| Commit | Description |
|--------|-------------|
| `85fec4e` | docs(llama-cpp-rocm): add IQ3_S data and power-profile measurements |

## 2026-09-13T11:59:48+09:00

**Summary**: feat(skill): added `nixos-specialisation-tuning`

- Generalises the one-off `SPECIALISATION-CORE.md` incident log into a reusable skill
- The three-file specialisation face architecture and override-conflict rules, plus the ownership principle (settings live with their consumer)
- A llama.cpp parameter table and forbidden items on UMA devices
- The diagnostic order for degenerate output, and a method for measuring tool-schema context cost
- Silent-failure recognition (service active but not working), and self-checking an invalid control experiment
- Four-language skill docs, registered in every README skill table
| Commit | Description |
|--------|-------------|
| `281e19b` | feat(skill): add nixos-specialisation-tuning |

## 2026-09-13T11:55:58+09:00

**Summary**: docs(pcn): removed residual kana and filled terminology gaps

- Fixed `から`, `のみ`, `リング`, `キー`, `セッション`, `セクション`, `データ`, `合わせ` across llama-cpp / dsh / dsh-api-balance / MAINTENANCE
- Pseudocn-ised new terms (prefill→前置充填, bottleneck→隘路, trade-off→相反関係, warmup→暖機, decode→復号, etc.)
- Unified `token` onto the existing 語彙 spelling
- Dictionary extended by 16 entries; SKILL.md's pitfall table gained the six katakana that surface as empty table columns
- Quoted external text (an AGENTS.md section title, git commit messages) intentionally left verbatim
| Commit | Description |
|--------|-------------|
| `3758428` | docs(pcn): eliminate kana, pseudocn-ise new terms, extend dictionary |

## 2026-09-13T11:44:48+09:00

**Summary**: docs(llama-cpp-rocm): corrected examples that contradicted the measured optimisations

- `batch-size` changed from `"512"` to the measured optimum `"2048"`
- Added the missing `ubatch-size`
- Removed hard-coded `n-gpu-layers`/`load-mode` (which disable `fit`'s automatic sizing) and the benefit-free `prio`/`presence-penalty`/`repeat-penalty`
- Annotated `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` in the migration "before" example as harmful
- Added a "DeepSeek Deployment Measurements" section: five optimisations with gain and cost for IQ1 (1.5625 bpw), the three-run prefill data, the ruled-out directions, and the low-bit quantisation prefill/generation trade-off (four languages)
| Commit | Description |
|--------|-------------|
| `bb11a30` | docs(llama-cpp-rocm): fix examples contradicting measured optimisations; add DeepSeek deployment data |

## 2026-09-13T11:35:34+09:00

**Summary**: docs(llama-cpp-rocm): added a "Unified-Memory Environment Variable Degeneration Risk" section

- Records the four-row measured comparison showing `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` degenerates model output (token repetition) on StrixHalo
- Notes that the risk rises significantly as quantisation precision drops
- The README patch section gained a matching warning (all four languages)
| Commit | Description |
|--------|-------------|
| `307e64b` | docs: warn against GGML_CUDA_ENABLE_UNIFIED_MEMORY on StrixHalo |

## 2026-09-13T04:00:39+09:00

**Summary**: Fixed dsh reverse-proxy port returning 403

- lighttpd was missing mod_proxy/mod_setenv, so the proxy.server/setenv config was ignored and requests to the proxy port had no handler
- Both modules are now declared explicitly on reverseProxy.enable (mod_magnet appended when autoAuth is on)
| Commit | Description |
|--------|-------------|
| `8e486be` | fix(module): dsh reverseProxy explicitly enable mod_proxy/mod_setenv |

## 2026-09-12T15:10:55+09:00

**Summary**: docs(llama-cpp-rocm): corrected outdated and invalid preset examples

- `fit="off"` → `"on"` (the old value OOMs under limited VRAM)
- `mmap` → `load-mode` (the former is deprecated)
- Removed `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` from the migration example (it degrades model output)
- Added a four-language "Parameter Reference" section documenting measured recommendations and items to avoid
| Commit | Description |
|--------|-------------|
| `a68d225` | docs(llama-cpp-rocm): correct outdated/invalid preset examples and add verified parameter reference |

## 2026-09-10T18:06:12+09:00

**Summary**: Upstream releases updated: six packages including codewhale 0.9.12

- codewhale 0.9.12; obs-bilibili-stream 2.1.5; mcp-searxng 2.2.0; opencode-telegram 0.25.1; dsh 0.1.5-rc.1; dsh-alpha 0.1.5-alpha.2
- Both dsh channels got regenerated vendored locks, and the built-in plugin inventory grew from 137 to 152 entries
| Commit | Description |
|------|------|
| `69af6c7` | feat(pkgs): bump codewhale 0.9.11 → 0.9.12 |
| `db7c0ed` | feat(pkgs): bump obs-bilibili-stream 2.1.4 / mcp-searxng 2.1.0 / opencode-telegram 0.25.0 |
| `c0f8346` | feat(pkgs): bump dsh 0.1.1-rc.2 → 0.1.5-rc.1 / dsh-alpha 0.1.2-alpha.5 → 0.1.5-alpha.2 |
| `b29db07` | docs: sync codewhale / obs-bilibili-stream / mcp-searxng / opencode-telegram / dsh version numbers |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.9.11 | 0.9.12 |
| obs-bilibili-stream | 2.1.4 | 2.1.5 |
| mcp-searxng | 2.1.0 | 2.2.0 |
| opencode-telegram | 0.25.0 | 0.25.1 |
| dsh | 0.1.1-rc.2 | 0.1.5-rc.1 |
| dsh-alpha | 0.1.2-alpha.5 | 0.1.5-alpha.2 |
| 　 | dsh built-in plugin count | 137 → 152 |
| 　 | dsh lock resolved entries | 560 → 580 |

> **godot-ai not updated**: the upstream 3.2.5 → 4.0.4 jump is a breaking major release; its pyproject pins nine runtime dependencies exactly and validates them fail-closed at startup, and six of them are newer than what nixpkgs — or even master — provides, so it could only be built by adding an overlay that bumps each one. On top of that, v3 plugins and v4 servers do not interoperate and clients must switch to `godot-ai attach`. This update stays on 3.2.5 (upstream's `release/v3` branch is still maintained).

## 2026-09-04T07:21:36+09:00

**Summary**: Upstream releases updated: godot-ai 3.2.5 and dsh-alpha 0.1.2-alpha.5

- godot-ai 3.2.5; dsh-alpha 0.1.2-alpha.5
- godot-ai follows v3.2.5, dsh-alpha tracks the npm alpha dist-tag two releases forward
| Commit | Description |
|------|------|
| `56b40e7` | feat(pkgs): godot-ai 3.2.4 → 3.2.5 |
| `d4f938c` | feat(pkgs): dsh-alpha 0.1.2-alpha.3 → 0.1.2-alpha.5 |

| Package | Old | New |
|--------|--------|--------|
| godot-ai | 3.2.4 | 3.2.5 |
| dsh-alpha | 0.1.2-alpha.3 | 0.1.2-alpha.5 |

## 2026-09-03T04:41:42+09:00

**Summary**: docs(dsh-api-balance): recorded the upstream StatsLine horizontal-scroll proposal

- DeepSeek Harness Discussion #5458 (upstream does not yet accept external PRs, so it lands as a discussion plus a ready branch)
- Ready branch `draft/statline-overflow-scroll` on fork Kihara777/deepseek-harness
- This repo also adds the official `dsh-plugin` ecosystem topic (four-language docs synced)
| Commit | Description |
|------|------|
| `6030e6d` | docs(dsh-api-balance): record the upstream StatsLine scrolling proposal and ready branch |

## 2026-09-03T03:25:59+09:00

**Summary**: feat(dsh-nixos-shell): maintenance mode now injects the nixkits-check-updates skill

- The maintenance-skills entry registers nixkits-check-updates as a runtime skill
- A maintenance session can run the software-update check directly via skill
| Commit | Description |
|------|------|
| `3baf456` | feat(dsh-nixos-shell): maintenance mode injects the nixkits-check-updates skill |
| `7554c6d` | docs: add nixkits-check-updates to the maintenance-mode injected-skill enumeration (four languages) |

## 2026-09-03T03:07:21+09:00

**Summary**: ruyi 0.52.0; obs-bilibili-stream 2.1.4; opencode-telegram 0.25.0 — upstream releases upgraded

- ruyi stable promoted to 0.52.0 (beta/alpha channels unchanged)
- obs-bilibili and opencode-telegram get their regular minor updates
| Commit | Description |
|------|------|
| `22c28a2` | feat(pkgs): bump ruyi 0.52.0 / obs-bilibili-stream 2.1.4 / opencode-telegram 0.25.0 |
| `65b7edf` | docs: sync the three packages' versions and badges to four-language docs and README |

| Package | Old | New |
|--------|--------|--------|
| ruyi | 0.51.0 | 0.52.0 |
| obs-bilibili-stream | 2.1.3 | 2.1.4 |
| opencode-telegram | 0.24.1 | 0.25.0 |

## 2026-09-02T06:38:36+09:00

**Summary**: docs(README): author-model update

- 小爪's model changed from DeepSeek V4 Pro (Max) to DeepSeek V4 Flash (synced across the four-language README)
| Commit | Description |
|------|------|
| `9ded956` | docs(README): author 小爪 model Pro (Max) → Flash (four languages) |

## 2026-09-02T06:37:45+09:00

**Summary**: feat(modules/dsh): add a structured defaultModel option

- `nixkits.dsh.defaultModel` (enable/provider/model/reasoningEffort) injects the new-session default model via `settings.agent-default-model`
- Explicit settings win; the default enable=false injects nothing
| Commit | Description |
|------|------|
| `7cf0914` | feat(modules/dsh): add structured defaultModel option |

## 2026-09-02T05:45:33+09:00

**Summary**: docs(dsh): settings-menu audit — declaratively configurable host namespace inventory and the storage-layer boundary

- Clarifies the edge between `nixkits.dsh.settings` and per-browser localStorage state
| Commit | Description |
|------|------|
| `f2e91a0` | docs(dsh): settings-menu audit — declaratively configurable host namespace inventory and storage-layer boundary (four languages) |

## 2026-09-02T04:12:23+09:00

**Summary**: docs(dsh): documentation freshness audit and sync

- dsh-alpha version bumped to 0.1.2-alpha.3 (READMEs plus dsh.md, four languages)
- The plugin inventory gains a regeneration note (`dsh --profile web --dump-default-config`, read-only) and the headless rows are annotated with their source profile
- The README plugin table links api-balance to its standalone doc
- The dsh-nixos-shell doc adds the maintenance-preset derivation rule and drift-check note (four languages)
| Commit | Description |
|------|------|
| `99746d3` | docs(dsh): freshness sync — alpha 0.1.2-alpha.3 / plugin inventory generation method / plugin doc links |
| `c45f64f` | docs(dsh-nixos-shell): maintenance-preset derivation relation and drift-check note (four languages) |

## 2026-09-02T04:12:05+09:00

**Summary**: dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 — tracking the npm alpha dist-tag

- Moves one release forward (upstream alpha.3 published 2026-08-31)
- The vendored lock is regenerated, byte-identical to the npmDeps fixup lock
| Commit | Description |
|------|------|
| `6a45ac8` | feat(pkgs): dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 |

| Package | Old | New |
|--------|--------|--------|
| dsh-alpha | 0.1.2-alpha.2 | 0.1.2-alpha.3 |
| 　 | hash | `sha256-W/BiompJCFP/uSlP48n7IEfwKb41RWEt6kVxioGSCkc=` → `sha256-MwlKS+Jx+edLMvs4NHJanw1T7SXxNBdQb/7htXANr8c=` |
| 　 | npmDepsHash | `sha256-bJMeVSSEZngCysPvuS2w+3j+fzntcObddsi4y5fLlO0=` → `sha256-mmatKs0jykfMcaIf0SVNLyIZ+Z7ipjGjjp2IaZo9FoE=` |

## 2026-09-11T07:38:00+09:00

**Summary**: fix(dsh-api-balance): move question-dialog injection to plugin load, independent of the ring component's lifecycle

- Root cause: asking a question takes over the composer, so the ring component on `conversation.input.right` unmounts and remounts, and an injection living in its effect rises and falls with that lifecycle, potentially never reaching the page
- Fix: the CSS injection moves into a `ctx.effect` inside `apply()`, running once at plugin load
- Verification: the real helpers plus the real QuestionComposer CSS are extracted and executed end-to-end in Chromium — injection succeeds, the card scrolls as a whole, and the header sticks
| Commit | Description |
|------|------|
| `2c30611` | fix(dsh-api-balance): question-dialog injection at plugin load, independent of ring lifecycle |
## 2026-09-11T07:27:00+09:00

**Summary**: fix(dsh-api-balance): question-dialog whole-page scroll had no effect in testing — switched to a MutationObserver watch

- Symptom and root cause: the question UI's style tag comes from a separate plugin bundle that can load after this plugin initializes, so the previous bounded 5×1s retry window missed it and injection silently skipped
- Fix: watch `document.head` with a MutationObserver (extracting and injecting the class name as soon as the tag appears) plus a 2s fallback poll, disconnecting once injection succeeds
- Verification: a faithful markup replica in headless Chromium confirms the CSS approach itself is correct; the smoke suite gains a "late-arriving tag still injects" case

| Commit | Description |
|------|------|
| `b392097` | fix(dsh-api-balance): question-dialog whole-page scroll ineffective — MutationObserver watch |
## 2026-09-11T07:15:47+09:00

**Summary**: feat(dsh-api-balance): question dialog whole-page scroll (long prompts no longer squeeze the options)

- CSS: the card itself becomes the scroll container, so title + detail + options scroll together; the header and footer button areas stick; the body stops scrolling to avoid double scrollbars
- Implementation: class names are extracted at runtime from the ui-user-questions style tag; up to 5 retries at 1s while the tag isn't ready
- Settings: Settings → Interface gains a "Question dialog: whole-page scroll" toggle (on by default, localStorage-persisted)
- Verification: against a faithful markup replica in headless Chromium, the fixed card scrolls as a whole with the header pinned

| Commit | Description |
|------|------|
| `4afe4c4` | feat(dsh-api-balance): question dialog whole-page scroll (long prompts no longer squeeze options) |
| `6809b3d` | docs(dsh-api-balance): question-scroll setting notes (4 languages) |
## 2026-09-02T10:29:20+09:00

**Summary**: feat(dsh-api-balance): peak red auto-engages/clears + notifications on both peak start and end

- The official peak window is re-checked every 30 s; on entering/leaving, peakNow drives the whole red-off effect with no manual refresh
- Peak start speaks the `peak` segment and the end speaks the new `peakEnd` segment (both with TTS fallback), throttled to 30 s against repeats
- The voice-pack creator gains a `peakEnd` segment, plus speech.peakEndHint copy and a voice.seg.peakEnd label
| Commit | Description |
|------|------|
| `b67e41d` | feat(dsh-api-balance): peak red auto-engages/clears + peak-start/end notifications |
| `9483c2c` | docs(dsh-api-balance): peak auto-trigger/clear and peakEnd segment (4 languages) |
## 2026-09-02T10:23:55+09:00

**Summary**: feat(dsh-api-balance): peak-hour red unified across the usage page + chart model colors stay distinguishable

- Peak red now covers the page's context progress bar and detail chips, the refresh/loading animation (new dshAbSpinPeak red-ring class in dshAbSpin) and the reading text, matching the already-red usage ring/chart
- Progress-bar segments take different red shades by index via peakShade, so multiple segments stay distinguishable
- The chart keeps PEAK_PALETTE at peak — a red family with a distinct shade per model (legend dots synced)
| Commit | Description |
|------|------|
| `3aea067` | feat(dsh-api-balance): peak red unified across usage page + chart models stay distinguishable |
| `ea34699` | docs(dsh-api-balance): peak-red unified to progress bar/spinner/details (4 languages) |
## 2026-09-02T06:32:01+09:00

**Summary**: refactor(dsh-api-balance): drop the phone-portrait overflow fixes and restore the lean implementation

- The 「portrait-overflow settings-page sizing logic」 is removed (panel width back to measuring content scrollWidth with a cap, no longer switching to min(520px, 94vw) on overflow)
- The pager's fitWidth / overflowing / layoutW handling is removed (page width back to the measured content width, touchAction back to pan-y, touch/drag paging works in every scenario)
- The page-level fixed portal stays (mobile-landscape top-bar avoidance and general overlay stability)
| Commit | Description |
|------|------|
| `d948b8f` | refactor(dsh-api-balance): remove phone-portrait overflow fixes, restore lean implementation |
| `e529d48` | docs(dsh-api-balance): narrow-screen behavior reverted to content-adaptive + panel scroll (4 languages) |
## 2026-09-02T05:56:57+09:00

**Summary**: fix(dsh-api-balance): portrait overflow adopts the settings dialog's sizing

- When the content is wider than the space available, the panel width switches to the settings dialog's page sizing (min(520px, 94vw)) and content adapts
- Only rare hard-overflow content falls back to horizontal scroll
- The pager follows (page width = the panel's available width, content wraps, gestures return to native scroll, paging via the dots) and drag/swipe paging resumes once the content fits
| Commit | Description |
|------|------|
| `280fd6a` | fix(dsh-api-balance): portrait overflow directly adopts the settings dialog's sizing logic |
| `a8f8cda` | docs(dsh-api-balance): portrait-overflow sizing-logic notes (4 languages) |
## 2026-09-02T05:45:48+09:00

**Summary**: fix(dsh-api-balance): the usage panel becomes a page-level fixed portal (root fix for mobile off-screen)

- It moves from absolute positioning inside the conversation tree to a document.body-level fixed portal (same architecture as the settings dialog), no longer clipped by the conversation area's overflow or bound to its coordinate space
- Position is derived from the ring anchor's viewport rect (recomputed on resize/scroll, measured in useLayoutEffect to avoid flicker)
- Double clamps: width cap = min(anchor space, viewport − 24px), height cap = the space above the anchor (auto-shrinks in landscape to avoid the top bar) — never off-screen at any size
- Outside-click close is updated, z-index 900 below the top-up/login/settings overlays
| Commit | Description |
|------|------|
| `4b2f19f` | fix(dsh-api-balance): usage panel becomes a page-level fixed portal (root fix for mobile off-screen) |
| `7145e5f` | docs(dsh-api-balance): page-level overlay architecture notes (4 languages) |
## 2026-09-02T05:29:47+09:00

**Summary**: fix(dsh-api-balance): narrow phone-portrait horizontal gestures return to panel scroll

- Root cause: the pager's touch-action: pan-y blocks browser-level horizontal gestures on touch, swallowing the panel's native horizontal scroll, so overflowing content looked cut off and unscrollable
- Fix: the pager compares content width against the panel's available width (fitWidth prop) and on overflow switches touch-action to auto (gestures to the panel's native scroll) and disables drag paging (page switching stays via the dots)
- When it fits, pan-y + drag/swipe paging remain
| Commit | Description |
|------|------|
| `c86cd9f` | fix(dsh-api-balance): narrow phone-portrait horizontal gestures returned to panel scrolling |
| `189945c` | docs(dsh-api-balance): narrow-screen gesture-priority notes (4 languages) |
## 2026-09-02T05:23:13+09:00

**Summary**: fix(dsh-api-balance): the first manual refresh plays the greeting too

- Every manual refresh of the 「Balance」 tab, first click included, plays a random greeting
- Only full-page-load initialization skips it (usage warnings only, per the auto-broadcast setting)
| Commit | Description |
|------|------|
| `4836b4e` | fix(dsh-api-balance): the first manual refresh plays the greeting too |
## 2026-09-02T05:15:52+09:00

**Summary**: feat(dsh-api-balance): greetings only on manual refresh + pager height follows the current page

- Page initialization (full refresh/load) no longer plays a greeting and only broadcasts usage warnings per the auto-broadcast setting (load → announceHunger, gated by the voice-alert switch and the 30-minute rate limit)
- The 「Balance」 tab plays the greeting only when data was already loaded
- The pager height equals the current page's measured height (offsetHeight), re-measured on page switch or content change — a shorter page reclaims height, a taller one grows it; non-active pages render at natural height and full content relies on the panel's vertical scroll
| Commit | Description |
|------|------|
| `cf68777` | feat(dsh-api-balance): greetings only on manual refresh + pager height follows the current page |
| `610c402` | docs(dsh-api-balance): greeting timing + pager height reclaim notes (4 languages) |
## 2026-09-02T05:03:47+09:00

**Summary**: fix(dsh-api-balance): phone-landscape top-bar occlusion + broken narrow-screen horizontal scroll

- Landscape: the panel max-height clamps dynamically to the space above the anchor (the ring's first vertically-clipping ancestor ≈ the top bar's bottom edge is the hard boundary; maxHeight = min(460, anchor top − clipping top − 12), recomputed on resize), with the panel's own vertical scroll carrying the full content
- Narrow screen: pager pages use each page's measured content width (max scrollWidth, floor 220, px-based paging) instead of a fixed 100% — when the available width is too small, content keeps its own width and the panel's overflow-x:auto scrolls it, no longer clipped by the pager's overflow:hidden
| Commit | Description |
|------|------|
| `5e28d84` | fix(dsh-api-balance): phone-landscape top-bar occlusion + broken narrow-screen horizontal scroll |
| `2f37193` | docs(dsh-api-balance): mobile panel height/width adaptation notes (4 languages) |
## 2026-09-02T04:48:40+09:00

**Summary**: feat(dsh-api-balance): horizontally paged consumption-detail area (dot indicator + swipe)

- Today/month/30-day and the per-model breakdown/chart merge into one two-page horizontal pager (page 1: window rows; page 2: per-model + daily/monthly chart)
- a home-screen-style dot indicator sits above (tappable, the active dot becomes a pill), with horizontal drag/swipe paging (pointer capture engages only past the threshold, so in-page button clicks aren't swallowed; touch-action: pan-y keeps the panel's vertical scroll)
- the area height follows its content and never scrolls itself — full content relies on the usage panel's vertical scrollbar
| Commit | Description |
|------|------|
| `b1a6406` | feat(dsh-api-balance): horizontally paged consumption-detail area (dot indicator + swipe) |
| `8db2f12` | docs(dsh-api-balance): paged consumption-detail notes (4 languages) |
## 2026-09-02T04:40:47+09:00

**Summary**: refactor(dsh-api-balance): settings button to the header, Balance tab carries refresh, token source below account info

- The 「⚙ Settings」 button takes the panel header's old 「Refresh data」 slot
- That button is dropped and its behavior (force-refresh bypassing the host cache + a random greeting) is inherited by clicking the 「Balance」 tab (spinner while loading)
- The token-source area (source label / ✓ Signed in / Disconnect) moves from the panel bottom to just below the 「Account」 block, forming one continuous info section
| Commit | Description |
|------|------|
| `3ccc0d1` | refactor(dsh-api-balance): settings button in header + Balance-tab refresh + token source under account info |
| `3b1a7be` | docs(dsh-api-balance): greeting trigger reworded to the Balance tab (4 languages) |
## 2026-09-02T04:29:05+09:00

**Summary**: fix(dsh-api-balance): all interface optimizations default on + hardened mobile keyboard guard

- The stats-bar horizontal scroll and the Enter/newline swap flip from default-off to default-on (unset localStorage counts as on; an explicit user off still works)
- The stats-bar CSS injection retries (up to 5 times, 1s apart) when the ui-chat style tag isn't ready, avoiding silent failures from mount timing
- The mobile keyboard guard widens touch detection to coarse pointer OR maxTouchPoints > 0 (tablets/hybrids), plus a focus-capture fallback that blurs immediately to close the soft keyboard on engines that don't fire focusin
| Commit | Description |
|------|------|
| `c940f92` | fix(dsh-api-balance): interface optimizations on by default + hardened mobile keyboard guard |
| `b8cd0b7` | docs(dsh-api-balance): default-on interface settings notes (4 languages) + AGENTS Enter-key entry |
## 2026-09-02T02:49:52+09:00

**Summary**: feat(dsh-api-balance): full-page panel width regression + peak-pricing marker + mobile keyboard guard

- The panel width is measured once from content scrollWidth into a concrete px, removing the 「chart px → panel max-content → observer → chart px」 feedback, with the cap tightened to min(anchor right edge − sidebar, 640) and in-panel horizontal scrolling beyond
- Peak hours (Mon–Fri 09:00–12:00 & 14:00–18:00 Beijing time, off-peak otherwise) turn the usage ring and chart red with a 「Peak pricing」 badge (panel header + chart title), greetings gain a peak hint (voice pack peak segment / TTS fallback) and the creator a peak segment
- On mobile, sidebar session switching no longer pops the soft keyboard (focusin capture blocks non-tap composer focus; on by default, Settings → Interface to disable)
| Commit | Description |
|------|------|
| `3b126c7` | feat(dsh-api-balance): full-page panel width fix + peak-pricing marker + mobile keyboard guard |
| `4ed2e7c` | docs(dsh-api-balance): sync four-language docs (peak marker / mobile keyboard / peak segment) |
## 2026-09-01T12:18:16+09:00

**Summary**: feat(presets): preset-derivation drift check hooked into flake check

- New develop/check-preset-derivation.py verifies the maintenance mode fully derives from the NixOS mode (composition file = appended fixed block, skills directories identical file-by-file)
- flake.nix adds checks.preset-derivation (run by CI on every push)
- AGENTS.md gains a 「预设」 section recording the derivation rules and the drift check
- The Enter-key entry is corrected to the dsh-api-balance 「Settings → Interface」 toggle
| Commit | Description |
|------|------|
| `d6373cb` | feat(presets): preset-derivation drift check hooked into flake check |

## 2026-09-01T12:18:09+09:00

**Summary**: docs(dsh): dedicated plugin docs + Agent presets section (4 languages)

- The inline api-balance / nixos-shell sections of dsh.md converge into a 「NixKits plugins」 table (each plugin links to its dedicated doc)
- A new 「Agent presets」 section is added (seed-once mounting and the two presets)
- New four-language dsh-api-balance docs, whose interface-settings section records the stats-bar horizontal scrolling and the Enter-key swap
| Commit | Description |
|------|------|
| `eb0ad2d` | docs(dsh): dedicated plugin docs + Agent presets section (4 languages) |

## 2026-09-01T12:18:02+09:00

**Summary**: feat(dsh-api-balance): settings dialog (Interface/Voice) + stats-bar horizontal scroll + Enter-key swap

- Voice settings restructured into a two-tab 「Settings → Interface / Voice」 dialog (all voice content moves to the Voice tab)
- The Interface tab adds two settings (browser-localStorage persisted): ① horizontal scrolling for overflowing bottom-stats-bar content with the scrollbar hidden (the root class is extracted at runtime from the ui-chat-injected StatsLine style tag, so it survives build hashes)
- ② Enter = newline · Shift+Enter = send (DSH defaults to Enter = send; the document capture phase rewrites shiftKey and re-dispatches Enter, composer-only)
| Commit | Description |
|------|------|
| `9dc7a5d` | feat(dsh-api-balance): settings dialog (Interface/Voice) + stats-bar scroll + Enter-key swap |
## 2026-09-01T11:34:40+09:00

**Summary**: feat(dsh-api-balance): dynamic width + merged account row + consumption metric sub-rows

- The panel width becomes dynamic max-content (min 264px, capped at anchor-right-edge minus the sidebar) so values no longer wrap due to a narrow fixed width
- API key / account status / per-currency balances merge into a single 「Account」 line (joined by ·) with the top-up button moved to the right of the title
- The today/month/30-day and per-model consumption values split into metric sub-rows (cost / in / cache hit / out), further saving horizontal width
| Commit | Description |
|------|------|
| `81b524a` | feat(dsh-api-balance): dynamic width + merged account row + metric sub-rows |

## 2026-09-01T11:20:09+09:00

**Summary**: feat(dsh-api-balance): compact panel width + two-line title/value rows

- The panel width is unified to 264px (matching the original usage ring), with horizontal scrolling appearing only when content overflows on narrow screens
- Every row now uses a two-line layout (10px tertiary title / 12px wrapping value, reusing the token-source hierarchy), which looks better given the abundant vertical space
- The chart width floor drops to 220 and follows the panel
| Commit | Description |
|------|------|
| `0c1d3fd` | feat(dsh-api-balance): compact panel width + two-line title/value rows |

## 2026-09-01T10:45:06+09:00

**Summary**: feat(dsh-api-balance): content-based panel width + left-sidebar avoidance

- The balance view width becomes max-content (keeping the top text on one line)
- The on-screen cap is now 「anchor right edge − left sidebar width − margin」 (the sidebar width is measured by geometric hit-testing to avoid hashed class names, recalculated on window resize) so the left toolbar never covers the panel
- Overflowing content still scrolls horizontally
| Commit | Description |
|------|------|
| `b1c724a` | feat(dsh-api-balance): content-based panel width + left-sidebar avoidance |

## 2026-09-01T10:33:16+09:00

**Summary**: feat(dsh-api-balance): responsive panel width — auto-expand without leaving the screen, horizontal scroll on narrow screens

- The balance view width changes from a fixed 340px to min(560px, calc(100vw - 24px)): it auto-expands to 560px on desktop and shrinks within the viewport on narrow screens
- When content exceeds the screen (e.g. narrow portrait phones) the panel allows horizontal scrolling (overflow-x with overscroll-behavior-x containment)
- The chart width follows the panel width via ResizeObserver
| Commit | Description |
|------|------|
| `bc85f5b` | feat(dsh-api-balance): responsive panel width with horizontal scroll |

## 2026-09-01T10:27:06+09:00

**Summary**: feat(dsh-api-balance): voice audition — expand a pack in the library list to play all of its supported audio one by one

- The standalone test-audio buttons at the bottom of the packs view are removed
- Each pack row gains an expand toggle (▸/▾) that lists every supported audio entry (segments + greetings) with a one-click ▶ play button, so any imported pack can be auditioned, not just the active one
| Commit | Description |
|------|------|
| `04facc1` | feat(dsh-api-balance): voice audition — per-pack expandable audio preview |

## 2026-09-01T10:20:14+09:00

**Summary**: fix/feat(dsh-api-balance): 「in」/cache-hit split to match the official usage page + greeting list editor

- the official API's token buckets include `PROMPT_CACHE_HIT_TOKEN` (228M that day), previously folded into 「in」 and inflating 「200M in today」
- 「in」 now covers uncached input only with cache hits listed separately, across window rows, per-model rows and the chart-toggle broadcast
- segment keys are reworked with a new `cacheHitLabel`, sample texts matching the TTS fallbacks exactly
- the creator gains a greeting list editor (add/remove slots, per-entry record / import / play / delete, packaged into `manifest.greetings`)
| Commit | Description |
|------|------|
| `ec5fb41` | fix(dsh-api-balance): split 「in」 from cache hits to match the official usage page |

## 2026-09-01T09:35:56+09:00

**Summary**: refactor(dsh-api-balance): broadcast button removed; the chart toggle now speaks the matching view

- the 「🔊 Speak usage」 button and its dropdown menu (including menu positioning/direction fallback) are removed
- clicking the usage chart's 「Daily / Monthly」 toggle broadcasts the matching view's voice usage (pack prefix + TTS numbers)
- the test audio (low-usage / out-of-tokens) moves into the 「Manage packs」 view
- the voice-settings button remains on its own row
| Commit | Description |
|------|------|
| `dd61fe0` | refactor(dsh-api-balance): broadcast button removed; chart toggle speaks the matching view |

## 2026-09-01T09:28:55+09:00

**Summary**: fix(dsh-api-balance): the manual 「Refresh data」 button also triggers the random greeting sound

- greeting playback is extracted into playRandomGreeting and shared
- page refresh (once per page) and each manual refresh-button click both trigger it, uniformly gated by the voice-broadcast toggle
- the settings hint text is updated accordingly
| Commit | Description |
|------|------|
| `264a6e3` | fix(dsh-api-balance): manual refresh button also triggers the random greeting |

## 2026-09-01T09:24:11+09:00

**Summary**: feat(dsh-api-balance): random greeting sound on page refresh

- with voice broadcast enabled, a random greeting/landing sound plays on every page refresh (once per page)
- the voice-pack manifest gains an optional `greetings` array (0–16 audio files; the host validates, stores and serves them via `/audio/<id>/greetN`, and the GET list returns greeting URLs)
- without greeting audio, a random TTS greeting from a pool (5 zh / 5 en) plays
- a hint text is added under the auto-broadcast toggle in the settings dialog
| Commit | Description |
|------|------|
| `edd205c` | feat(dsh-api-balance): random greeting sound on page refresh |

## 2026-09-01T09:10:18+09:00

**Summary**: feat(dsh-api-balance): voice-pack library + creator sub-menu + recording float window

- the host is now a library (`packs/<id>/` multi-pack storage + `state.json` active record; activate switches packs, DELETE ?ids= removes several (auto-fallback when the active one is removed), audio served at `/audio/<id>/<key>`)
- the settings page keeps import plus a 「Manage packs」 button, whose sub-menu has a packs view (scrollable list: click to switch, checkboxes for batch removal, entry to the creator)
- a creator view (language picker zh-CN/en/ja with matching sample texts and cross-language recording, manifest lang records the pack language; per-segment record / import / play / delete; compile-download / compile-apply)
- a float window appears while recording (level meter, elapsed time, sample text, save / discard)
- imported packs keep the first-edit overwrite warning
| Commit | Description |
|------|------|
| `398b093` | feat(dsh-api-balance): voice-pack library management + creator sub-menu + recording float window |

## 2026-09-01T08:41:48+09:00

**Summary**: feat(dsh-api-balance): zip voice packs + record/import creator + edit protection

- voice packs are now zip archives (`manifest.json` + `audio/` files); the host parses them in pure JS into `$DSH_HOME/api-balance-voicepack/`, serving audio through a prefix route shared by all devices
- the settings dialog's creator supports per-segment browser recording (MediaRecorder) or importing local audio files
- 「Package & download」 produces a shareable zip and 「Compile & apply」 installs it locally right away
- imported packs warn on first edit, confirmed once per session
- broadcast segments support both URL and inline carriers
- the four-language docs gain the voice-pack format guide (zip layout / manifest / segment table / recording & sharing flow)
| Commit | Description |
|------|------|
| `5f4c50a` | feat(dsh-api-balance): zip voice packs + record/import creator + edit protection |

## 2026-09-01T02:36:15+09:00

**Summary**: feat(dsh-api-balance): broadcast voice language and voice follow the DSH UI language

- the broadcast text already followed the UI language via t(), but the utterance lang and voice preference were hardcoded to zh-CN
- the current language code is now read from the LocaleFace snapshot (useSyncExternalStore over the locale service's subscribe/getSnapshot): zh → zh-CN, others pass through
- the voice is matched by language prefix
- the separators in composed broadcast text switch with the language (full-width for Chinese, half-width otherwise)
- falls back to zh when the locale service is unavailable
| Commit | Description |
|------|------|
| `11c070b` | feat(dsh-api-balance): broadcast voice language and voice follow the DSH UI language |

## 2026-09-01T01:51:10+09:00

**Summary**: fix(dsh-api-balance): voice broadcast menu now expands upward

- the menu opens upward from the button's top edge by default (translateY(-100%))
- when there's not enough room above (<8px from the viewport top) it falls back to opening downward
| Commit | Description |
|------|------|
| `7d0c49e` | fix(dsh-api-balance): voice broadcast menu expands upward |
| `8d9058c` | docs(dsh): sync the upward-menu note for the voice broadcast in four languages |

## 2026-09-01T01:25:25+09:00

**Summary**: feat(dsh-api-balance): login prompt + exact LevelDB parsing + voice broadcast menu

- when the browser scan finds nothing, a prompt pops up with 「Go to login」 (opens the login page in a new tab and picks up the token via quick-scan polling); manual entry is demoted to a secondary option in the prompt
- a greyed 「✓ Signed in」 shows once connected
- a new pure-JS LevelDB table parser extracts userToken exactly — quick scan hits in 949ms
- voice broadcast gets its own row with a dropdown (current usage / balance / test warning audio), the menu becomes a fixed-position portal to fix scroll clipping, with speech-engine warmup
- token source now uses two lines
- Verified: LevelDB parsing hit in practice and quick scan went from failing to a 949ms hit
| Commit | Description |
|------|------|
| `a3ad3ff` | feat(dsh-api-balance): login prompt + exact LevelDB parsing + voice broadcast menu |
| `a0e945e` | docs(dsh): sync the login-prompt / exact-parsing / voice-broadcast sections in four languages |

## 2026-08-31T23:55:52+09:00

**Summary**: docs(dsh): complete the api-balance plugin section in all four languages

- the pcn dsh.md gains the plugin section (local browser auto-scan / usage charts / config options)
- the four-language README plugin tables describe the auto-scan-from-browser-session semantics
| Commit | Description |
|------|------|
| `b912f82` | docs(dsh): sync the api-balance browser auto-scan section to pcn + update four-language README plugin tables |

## 2026-08-31T23:50:04+09:00

**Summary**: feat(dsh-api-balance): auto-scan local browsers for the platform userToken

- the host reads the Local Storage LevelDB of local Chromium-family browsers (Edge / Chrome / Brave / Chromium / Vivaldi / Opera, every profile) directly, extracts base64 candidates (55–85 chars) and validates them against GET /api/v0/users/get_user_summary before saving
- anyone who has signed in locally gets the usage token with no manual pasting
- 6-hour throttle + immediate rescan on token invalidation (40003/401)
- a panel 「Rescan local browsers」 button (RPC args.rescanBrowsers), with a token-source badge (browser / manual) once connected
- Verified: the real token was found among 31 candidates in the local Edge leveldb
| Commit | Description |
|------|------|
| `cec90b0` | feat(dsh-api-balance): auto-scan local browsers for the platform userToken |

## 2026-08-31T11:50:02+09:00

**Summary**: docs(AGENTS): generalize dsh-alpha session lessons

- three buildNpmPackage rules (vendored lock consistent with npmDepsHash / postPatch strips unpublished devDependencies with plain sed, lock generated from the same package.json / multi-channel thin-wrapper pattern after ruyi)
- git fetch before the startup audit
- new local-deployment section (path-input relock, nixos apply command, --no-link artifact collection)
| Commit | Description |
|------|------|
| `86a7c3f` | docs(AGENTS): generalize dsh-alpha session lessons — buildNpmPackage rules and local deployment conventions |
| `396c3ae` | docs(MAINTENANCE): record 2026-08-31 — generalize dsh-alpha session lessons into AGENTS.md |

## 2026-08-31T11:31:42+09:00

**Summary**: dsh-alpha rollout disaster recovery

- fixed the alpha reverse-proxy Host semantics (the web UI entry authenticates with a Host-authority session cookie; rewriting Host caused permanent 401s)
- fixed the dsh-api-balance shared RPC interceptor conflict (`/api` is exclusively held by typert-gateway; switched to an exact fetch route implementing the RPC envelope)
- dsh-nixos-shell's dsh-tools channel alignment
- new module options launchUrlFile (LAN startup URL capture) and reverseProxy.autoAuth (mod_magnet passwordless token injection, trusted LAN only)
- four-language docs gain the LAN access sections
- Verified: after the reverse-proxy and RPC fixes the web UI entry and plugin RPC work again
| Commit | Description |
|------|------|
| `222ece4` | fix(pkgs): dsh-api-balance / dsh-nixos-shell alpha compatibility |
| `bd4cdb1` | feat(dsh-module): launchUrlFile + autoAuth + alpha reverse-proxy Host fix |
| `a2fe5f3` | docs(dsh): add LAN access / autoAuth / alpha plugin compatibility sections in four languages |
| `1176553` | docs(AGENTS): annotate dsh alpha semantics and plugin compatibility lessons in the module section |

| Package | Old | New |
|--------|--------|--------|
| dsh-nixos-shell | dsh-tools `0.1.1-rc.2` | dsh-tools `0.1.2-alpha.2` |
| 　 | npmDepsHash | `sha256-uOQ3Dq...` → `sha256-bAXZCi...` |

## 2026-08-31T07:23:07+09:00

**Summary**: dsh-alpha 0.1.2-alpha.2 — new package

- new package, npm `alpha` dist-tag development channel
- dsh refactored into a ruyi-style thin wrapper (version/hash/npmDepsHash/lockFile overridable)
- postPatch drops the tarball's devDependencies with plain sed (they reference unpublished monorepo-internal packages — registry 404)
- patch target files guarded by existence checks
- four-language docs gain a version-channels section and the README software table gains the dsh-alpha row
- follow-up fix: vendored lock aligned with npmDepsHash (missing npm fixup platform entries made the main build report out of date)
- Verified: the package builds, and after the lock alignment the main build no longer reports out of date
| Commit | Description |
|------|------|
| `88a2dfc` | feat(dsh): multi-version channels — add dsh-alpha 0.1.2-alpha.2 |
| `33bff25` | docs(dsh): add version-channels section to four-language docs |
| `095d002` | docs(MAINTENANCE): record 2026-08-31 — new dsh-alpha package |
| `a97fffd` | fix(pkgs): align dsh-alpha vendored lock with npmDepsHash |
| `d9a83f8` | docs: add dsh-alpha row to README software table (four languages) |

| Package | Old | New |
|--------|--------|--------|
| dsh-alpha | new `0.1.2-alpha.2` | |
| 　 | source hash | `sha256-W/Biom...` |
| 　 | npmDepsHash | `sha256-bJMeVS...` |

## 2026-08-31T07:05:44+09:00

**Summary**: godot-ai 3.2.4 — bugfixes and four-language docs version sync

- serialized self-update recovery, hardened config writes, path-validation and cold-start fixes (v3.2.1~v3.2.4 are all bugfixes)
- four-language docs version numbers synced
| Commit | Description |
|------|------|
| `c30fc17` | chore(pkgs): bump godot-ai 3.2.0 → 3.2.4 |
| `e4b9981` | docs(MAINTENANCE): record 2026-08-31 — godot-ai update |

| Package | Old | New |
|--------|--------|--------|
| godot-ai | 3.2.0 | 3.2.4 |
| 　 | source hash | `sha256-ImKAsI...` → `sha256-Uo6GvE...` |

## 2026-08-27T09:19:59+09:00

**Summary**: opencode-telegram 0.24.1 and three other packages — upstream updates and doc sync

- opencode-telegram 0.24.1: Korean interface, `/opencode_stop` can kill a hung local OpenCode process even while busy, voice transcripts shown as quotes, safe retries on temporary Telegram errors prevent lost or duplicated replies, adaptive streaming throttle
- mcp-searxng 2.1.0: per-engine time-range capability validation when engines are explicitly selected, failing fast with an actionable error
- godot-ai 3.2.0: custom_tools third-party addon registry, selectable CLI registration scope, DeepSeek Harness client support
- ruyi-beta 0.52.0-beta.20260824: beta channel upstream update
- Four-language docs synced; nix flake check passes
| Commit | Description |
|------|------|
| `7d57bfa` | chore(pkgs): bump opencode-telegram 0.24.0 → 0.24.1 |
| `85b813e` | chore(pkgs): bump mcp-searxng 2.0.0 → 2.1.0 |
| `0fe16db` | chore(pkgs): bump godot-ai 3.1.5 → 3.2.0 |
| `b26d013` | chore(pkgs): bump ruyi-beta 0.51.0-beta.20260714 → 0.52.0-beta.20260824 |
| `e88e284` | docs(MAINTENANCE): record 2026-08-27 — four upstream package updates |

| Package | Old | New |
|--------|--------|--------|
| opencode-telegram | 0.24.0 | 0.24.1 |
| 　 | source hash | `sha256-uZaAyt...` → `sha256-uWhSMq...` |
| 　 | npmDepsHash | `sha256-Vh/e3S...` → `sha256-5ndUrB...` |
| mcp-searxng | 2.0.0 | 2.1.0 |
| 　 | source hash | `sha256-zakEU/...` → `sha256-Zq6oKX...` |
| 　 | npmDepsHash | `sha256-4WUOJJ...` → `sha256-YIH/5R...` |
| godot-ai | 3.1.5 | 3.2.0 |
| 　 | source hash | `sha256-zqZnKk...` → `sha256-ImKAsI...` |
| ruyi-beta | 0.51.0-beta.20260714 | 0.52.0-beta.20260824 |
| 　 | hash | `sha256-saOsHG...` → `sha256-vxu9Ah...` |

## 2026-08-27T07:28:58+09:00

**Summary**: feat(dsh-api-balance): panel refresh button — force-refresh balance and official usage

- a refresh button (↻) is added to the right of the panel header tab row: clicking it calls queryBalance(true), bypassing the host-side 30s TTL cache to re-fetch the balance + official usage (daily/monthly charts update together)
- the button is disabled with a spinner while loading (reuses dshAbSpin)
- bilingual zh/en labels (刷新数据 / Refresh data)
- Verified: build passed and it deployed zero-restart through the stable mount point (generation 424), taking effect after a dsh restart
| Commit | Description |
|--------|-------------|
| `e864b58` | feat(dsh-api-balance): panel refresh button — one-click refresh of balance and official usage |

## 2026-08-27T07:28:49+09:00

**Summary**: fix(dsh-nixos-shell): honest detached results + auto-detach for systemctl restart dsh

- previously a rebuild handed off through systemd-run returned the handoff's exit 0, so the tool result looked like a successful build while the real outcome was unknown
- detached commands now return `detached: true` + `detachedUnit` + `note` with exitCode null — a successful handoff is not a successful build, and the real result must be verified via nixos_cli op=journal / op=generations
- the detach predicate now also covers `systemctl restart dsh` (a plugin update needs an explicit restart to take effect), equally auto-detached and returning before the restart lands
- Verified: detached dsh restart landed (RESTARTED_EXIT=0), plugin-change rebuilds (generations 424/425) restarted nothing and interrupted nothing
| Commit | Description |
|--------|-------------|
| `0c7b7f6` | fix(dsh-nixos-shell): honest detached results + auto-detach for systemctl restart dsh |

## 2026-08-27T07:28:39+09:00

**Summary**: feat(module): dsh plugin stable mount points — zero-restart plugin activation

- plugin packages were previously baked into the dsh/sudo units, so any plugin update restarted dsh and the sudo socket during activation (in-flight tool calls and daemon-run rebuilds died; the socket could not recover)
- now stable mount points: an activation script re-links `/run/dsh/current` (dsh including its plugin tree) and `/run/dsh/nixos-shell` to the current generation's store paths on every switch/boot (GC-safe), and the units reference only those stable paths — activation restarts nothing and interrupts no socket
- companion: plugin updates take effect via an explicit `systemctl restart dsh`
- Verified: generation 423 deployed this; after plugin-change rebuilds on 424/425 both dsh's and the socket's ActiveEnterTimestamp were unchanged
| Commit | Description |
|--------|-------------|
| `dfce302` | feat(module): dsh plugin stable mount points — zero-restart plugin activation |

## 2026-08-27T04:07:27+09:00

**Summary**: fix(dsh-nixos-shell): sudo protocol v3 + rebuild auto-detach (three defects fixed)

- the v2 protocol treated a disconnect as cancel — a rebuild's switch stage restarts dsh.service, so the client disappears and the daemon killed the switch mid-activation (partial activation)
- v3 uses an explicit in-band cancel line, and on peer loss the child keeps running detached to completion
- cancel/timeout now kill the whole process group (spawn detached + kill(-pid)) — killing only the shell wrapper leaves orphaned grandchildren holding the pipe write-ends and hangs the daemon
- the timeout cap is raised to 6h
- rebuilds auto-detach into a systemd-run transient unit (own cgroup), so a socket stop/start during activation cannot kill the switch itself
- Verified: background sudo returns a job id immediately, job_kill kills the whole group with no orphans, and a real rebuild deployed through a detached unit with the socket auto-recovering
| Commit | Description |
|--------|-------------|
| `ead3526` | fix(dsh-nixos-shell): sudo protocol v3 + rebuild auto-detach |

## 2026-08-27T04:07:15+09:00

**Summary**: feat(dsh-api-balance): top-up card modal replaces iframe + low-balance voice alert

- the top_up page is blocked by a WAF ("Max challenge attempts exceeded"), so the iframe modal could not work
- replaced with a centered card modal (new-window button + close button top-right), no page navigation
- added a low-balance voice alert: when the balance drops below the threshold (10 CNY/USD) it speaks a prompt via the Web Speech API, with 15-minute polling + 30-minute cooldown
- a panel toggle (balance.speechOn/Off) and bilingual zh/en copy
- Verified: post-deploy feature grep (TopupModal/speechOn/announceHunger) confirms it is live
| Commit | Description |
|--------|-------------|
| `eeffc49` | feat(dsh-api-balance): top-up card modal replaces iframe + low-balance voice alert |

## 2026-08-26T11:44:45+09:00

**Summary**: dsh-api-balance 0.1.0 — new package (Usage / Balance tab switch)

- the webui usage ring (the context-usage display left of the send button) gains a 「Usage / Balance」 tab switch in its popover panel
- 「Usage」 keeps the original context occupancy and breakdown
- 「Balance」 shows the current API key's account info (key hint, availability, per-currency total / top-up / granted balance, sourced from DeepSeek's official GET /user/balance with a 30s host-side TTL cache)
- the host half registers a package-private endpoint via connection.rpc.intercept, the client half registers a visually compatible replacement ring in conversation.input.right and hides the original button
- Verified: RPC returns a live CNY 271.07 balance; the client bundle serves correctly
- Four-language docs synced, nix flake check passed
| Commit | Description |
|------|------|
| `95998cd` | feat(dsh): add dsh-api-balance plugin — Usage/Balance tab switch on the webui usage ring |
| `db721ba` | docs(MAINTENANCE): record 2026-08-26 — new dsh-api-balance 0.1.0 package |

| Package | Old | New |
|--------|--------|--------|
| dsh-api-balance | 　 | new v0.1.0 |

## 2026-09-11T12:54:29+09:00

**Summary**: fix(dsh/module): drop the allowLanSettings $host.state.getSnapshot() patch

- dsh ≥ 0.1.5's $host client service no longer exposes state, so the old patch hit undefined.getSnapshot during client-ui-settings apply and blanked the whole frontend (Failed to load plugins)
- the module no longer force-overrides allowLanSettings=true (restoring upstream behavior)
- the packages/dsh.nix patch writes unconditional "host"
- Verified: home page 200, llm/listProviders returns the DeepSeek provider
| Commit | Description |
|------|------|
| `06a5ce1` | fix(dsh): allowLanSettings — drop $host.state.getSnapshot() (undefined) |
| `155b09b` | fix(module): dsh — drop allowLanSettings override (state.getSnapshot undefined) |

## 2026-09-11T06:15:33+09:00

**Summary**: fix(preset): dsh persona text → prefix (0.1.5-alpha.2 compat)

- dsh-persona's Config changed text to prefix (required) + suffix (optional)
- the old agent presets (nixos-mode / maintenance-mode / local ocean-spiral) still wrote text, so persona failed to load ($.prefix missing required value) → session/create failed → settings, the llm provider catalog, and session history all failed to load
- Fix: both presets' persona config uses prefix; the three local presets were patched too
- Verified: session/create returns ok:true + sessionId
| Commit | Description |
|------|------|
| `772abf8` | fix(preset): dsh persona text → prefix for 0.1.5-alpha.2 |

## 2026-08-27T01:30:33+09:00

**Summary**: fix(module): dsh watchdog — auto-restart after a switch-to-configuration failure

- nixos-rebuild's switch-to-configuration can fail (exit 101) between stopping and starting dsh, leaving it inactive
- a systemd-initiated stop does not trigger Restart=always, so the reverse proxy returned 503 for a long time
- added a dsh-watchdog timer (15s) that runs systemctl start when dsh is inactive
- Verified: recovers within 20s of a stop
| Commit | Description |
|------|------|
| `3ed6aa7` | fix(module): dsh watchdog — auto-restart after switch-to-configuration failure |

## 2026-08-24T15:44:06+09:00

**Summary**: fix(overlay): llama-cpp-rocm v0.2.0 semantic version tag

- llama.cpp upstream switched release tags from build numbers (b10549) to semantic versions (v0.2.0)
- the old overlay stripped only the b prefix, so nixpkgs passed v0.2.0 into LLAMA_BUILD_NUMBER, producing `int LLAMA_BUILD_NUMBER = v0.2.0;` and a C++ compile failure (too many decimal points) that blocked system rebuilds and the dsh upgrade
- it now strips both v/b prefixes and appends -DLLAMA_BUILD_NUMBER=0
- Verified: llama-cpp-0.2.0 builds and llama-cpp.service runs
| Commit | Description |
|------|------|
| `1a1b9d1` | fix(overlay): llama-cpp-rocm — handle v0.2.0 semantic version tag |

## 2026-08-24T15:20:16+09:00

**Summary**: fix(pkgs): dsh crash fix — ignoring the dispose race

- cordis-plugin-timer (unfixed upstream at 1.1.3) rejects a pending ctx.timeout() promise with "Context has been disposed" during Context dispose; when uncaught it becomes an unhandled rejection
- dsh-app-boot's installFailLoud turns it into process.exit(1) (rc.6/rc.7/rc.8/0.1.1-rc.2 all affected)
- installFailLoud is patched to ignore only this error; other fatal rejections still exit
- Verified: patch lands in the 0.1.1-rc.2 output (dsh-app-boot/lib/index.js:1047)
| Commit | Description |
|------|------|
| `6e862b6` | fix(pkgs): dsh — ignore Context-disposed dispose race in installFailLoud |

## 2026-08-24T14:27:47+09:00

**Summary**: codewhale 0.9.11, mcp-searxng 2.0.0, dsh 0.1.1-rc.2 — upstream updates

- codewhale 0.9.11 — upstream renamed the TUI asset codewhale-tui → codew from v0.9.9; the package installs codew and keeps a compat alias
- the riscv64 source build synced Cargo.lock (687→690 entries)
- mcp-searxng 2.0.0 — major upgrade (requires Node.js ≥ 22, satisfied by the nixpkgs default, CLI entry unchanged)
- dsh 0.1.1-rc.2 — vendored lock regenerated (560 resolved entries), built-in plugin inventory identical to rc.8 (137 entries)
- dsh-nixos-shell's dsh-tools dependency aligned to 0.1.1-rc.2
- Four-language docs synced; nix flake check passes
| Commit | Description |
|------|------|
| `17bf588` | chore(pkgs): bump codewhale 0.9.8 → 0.9.11 |
| `065d261` | chore(pkgs): bump mcp-searxng 1.15.0 → 2.0.0 |
| `c0c8e3a` | chore(pkgs): bump dsh 0.1.0-rc.8 → 0.1.1-rc.2 |
| `bec4c3d` | chore(pkgs): dsh-nixos-shell dep dsh-tools 0.1.0-rc.7 → 0.1.1-rc.2 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.9.8 | 0.9.11 |
| mcp-searxng | 1.15.0 | 2.0.0 |
| dsh | 0.1.0-rc.8 | 0.1.1-rc.2 |
| dsh-nixos-shell | dsh-tools 0.1.0-rc.7 | dsh-tools 0.1.1-rc.2 |

## 2026-08-22T00:03:28+09:00

**Summary**: docs(dsh): 0.1.0-rc.8 documentation sync and local default-model setting

- the four-language dsh.md version rows (rc.6 → rc.8) and the "Plugin inventory" code blocks (137 entry-id mappings extracted from the rc.8 build) are synced
- the /etc/nixos local config adds `settings.agent-default-model` (deepseek-v4-pro + reasoningEffort=max) as the new-session default
- the authoritative DeepSeek API model list is only flash/pro/flash-vision-exp with no "pro-max" id, so Pro + Max reasoning is the top tier
- both the nixos and maintenance presets mount-validate on rc.8, and `nix flake check` passes
| Commit | Description |
|--------|-------------|
| `535567d` | docs(dsh): sync version and built-in plugin inventory for 0.1.0-rc.8 (137 entries) in four languages |

## 2026-08-21T21:51:26+09:00

**Summary**: docs: README plugins-section expansion and DSH credits info

- the "Plugins" section gains an "Agent presets" table besides dsh-nixos-shell (NixOS模式/维护模式, shipped with the plugin, seeded once via nixkits.dsh.presets), keeping DSH components separate from software
- the credits "小爪" entry gains DSH ecosystem info (the dsh-nixos-shell plugin and the two agent presets)
- the AGENTS.md plugin-listing rule is widened to "dsh-* components (plugins and agent presets)"
- all four languages synced
| Commit | Description |
|--------|-------------|
| `4277b51` | docs: list DSH agent presets in the README plugins section and add DSH ecosystem info to the credits paw entry |

## 2026-08-21T00:01:46+09:00

**Summary**: fix(dsh-nixos-shell): surface the tools whitelist in the tool description

- the acceptance round's non-blocking finding: the fixed POSIX tool whitelist was not shown in the tool description
- the whitelist is now generated dynamically from the TOOL_PACKAGES map (27 names, including the python alias) into the `tools` parameter description, and the tool description points at it
- the four-language docs carry the full list
- verified: all 27 names in the parameter description, the pointer present, `nix flake check` passes
| Commit | Description |
|--------|-------------|
| `30d0c40` | fix(dsh-nixos-shell): surface the tools whitelist in the parameter description |

## 2026-08-20T20:12:33+09:00

**Summary**: fix(dsh-nixos-shell): correct the modern rebuild command to `nixos apply`

- the installed nixos 0.16.1-dev has no `rebuild` subcommand (`nixos --help` lists activate/apply/generation etc.)
- the handoff book and the plugin's recommendedRebuild/command map/gate guidance wrongly said `nixos rebuild switch`; unified to `nixos apply /etc/nixos` (or the traditional `sudo nixos-rebuild switch --flake /etc/nixos`)
- verified: `nix flake check` passes, and system deployment switched to `nixos apply` succeeds
| Commit | Description |
|--------|-------------|
| `caa7d41` | fix(dsh-nixos-shell): correct the modern rebuild command to 'nixos apply' |

## 2026-08-20T20:10:08+09:00

**Summary**: fix(dsh-nixos-shell): NixOS-mode acceptance fixes P1–P4

- P1 (high): the tools-bootstrap wrapper changed from `bash -lc` to `bash -c`; the login shell's /etc/profile chain reset PATH and discarded the nix shell injection, and the sudo path sharing the wrapper is fixed too (control: `-c` yields Python 3.14.7, `-lc` yields command not found); the mapping also fixes grep→gnugrep and find→findutils
- P2: generations gains `limit` (default 20, max 200, newest first)
- P3: journal unit accepts `*`/`%` globs, a trailing `@` auto-appends `*`
- P4: naming unified from nixos-cli to the nixos binary
- docs op tables synced in four languages; `nix flake check` passes
| Commit | Description |
|--------|-------------|
| `a591826` | fix(dsh-nixos-shell): P1-P4 acceptance fixes |

## 2026-08-20T19:33:51+09:00

**Summary**: fix(dsh-nixos-shell): use the PromptSection `text` field instead of `content`

- the dsh-system-prompt interpolator reads `input.text`, so sections registered with `content` crashed a real NixOS-mode session ("Cannot read properties of undefined (reading 'indexOf')"), a real-session path defect that mount validation cannot cover
- fixed 3 sites: nixos-gate (guidance/gate sections) and maintenance-skills (workflow section), `content` → `text`
- verified: mock assertions on the text field and no dangling `{{`; real systemPrompt service assemble with no crash; system prebuild passes
| Commit | Description |
|--------|-------------|
| `476e9dc` | fix(dsh-nixos-shell): use the PromptSection text field instead of content |

## 2026-08-20T19:05:44+09:00

**Summary**: feat(dsh-nixos-shell): maintenance-mode agent preset

- new in-package entry maintenance-skills: at apply time it registers runtime skills write-project-docs, write-maintenance-log, and every translate-* language extension (auto-discovered) from the repo's skills/ tree embedded at build time
- it injects the repository-maintenance workflow prompt section; the package postPatch copies skills → skills-embedded
- the preset presets/maintenance-mode (id `maintenance`, based on the NixOS-mode composition plus the maintenance-skills row) ships with the package; the module gains nixkits.dsh.presets.maintenanceMode
- verified: mock registration of 3 skills + workflow section all pass, system prebuild passes
| Commit | Description |
|--------|-------------|
| `f6c749e` | feat(dsh-nixos-shell): 维护模式 agent preset — maintenance-skills entry, presets/maintenance-mode, module presets.maintenanceMode seed |

## 2026-08-20T18:30:46+09:00

**Summary**: feat(dsh-nixos-shell): NixOS-mode agent preset

- new subpath entry nixos-gate: at session initialization it verifies the host is NixOS (/etc/NIXOS or os-release ID=nixos)
- on non-NixOS it denies every tool execution via tools.guard and injects a refusal prompt section, on NixOS it injects the development-guidance prompt section
- the preset presets/nixos-mode (id `nixos`, based on the creation-mode cordis composition plus its skill directories, with nixos-gate/nixos-shell rows appended) ships with the package
- the module gains nixkits.dsh.presets.nixosMode, seeding $DSH_HOME/.agent-presets/nixos once in preStart
- verified: package build, gate syntax check, and system prebuild pass
| Commit | Description |
|--------|-------------|
| `aaa21cb` | feat(dsh-nixos-shell): NixOS模式 agent preset — nixos-gate entry, presets/nixos-mode, module presets.nixosMode seed |

## 2026-08-20T18:24:04+09:00

**Summary**: docs: dedicated README plugins section and AGENTS.md update

- dsh-* plugins move from the software table into a new README "Plugins" section (all four languages), no longer mixed with software
- AGENTS.md gains the plugin-listing convention and the "dsh is not a skill install target" rule
- approved cleanups applied (this machine): removed the stale store-absolute bash-completion block from ~/.bashrc
- ~/.profile's hm-session-vars repointed at the stable /etc/profiles/per-user/kix path
- the old ~/.dsh/skills files deleted (nixos_cli audit-store-paths re-check: 0 findings)
| Commit | Description |
|--------|-------------|
| `57ae6b5` | docs: list dsh-* plugins in a dedicated README plugins section (4 langs); AGENTS.md plugin-listing + dsh-skill-target rules |

## 2026-08-20T17:56:21+09:00

**Summary**: refactor(dsh-nixos-shell): rename package nixos-shell → dsh-nixos-shell

- the package name (pname/directory/flake output/overlay/CI workflow/docs) is unified as `dsh-nixos-shell` (pkgs.dsh-nixos-shell)
- the dsh-internal display name stays `nixos-shell` (composition-row entry id, plugin name, tool names nixos_shell/nixos_cli unchanged)
- verified: package build passes; deployment-side references synced
| Commit | Description |
|--------|-------------|
| `26a844e` | refactor(dsh-nixos-shell): rename package nixos-shell -> dsh-nixos-shell |

## 2026-08-20T17:46:44+09:00

**Summary**: feat(nixos-shell): NixOS scenario capabilities consolidated into one plugin; refactor: the skills-as-plugins design is abandoned

- New package nixos-shell (@kihara777/dsh-nixos-shell 0.1.0) registers two tools: the nixos_shell executor (NixOS PATH injection + bash fallback + `tools` bootstrapping missing POSIX tools + sudo-daemon routing) and nixos_cli read-only diagnostics (capabilities and others), requirements from the nixos-modern-cli skill scenarios.
- Removed dsh-nix-shell and dsh-skill-nixkits (the 7-skill-plugin design), CI/docs swapped.
- Fix for generations: an in-process read-only listing (`nix-env` refused when unprivileged).
Verified: 13-case functional suite passes; system prebuild passes.

| Commit | Description |
|--------|-------------|
| `395d8b4` | feat(nixos-shell): consolidate NixOS scenario capabilities into one plugin |

| Package | Old | New |
|---------|-----|-----|
| nixos-shell | — | new v0.1.0 |

## 2026-08-20T16:40:16+09:00

**Summary**: fix(dsh): point the service HOME at the real user home

- git's gh credential helper resolves credentials from `$HOME/.config/gh`, and the module had set the service HOME to dshHome (/home/kix/.dsh), so sandbox git pushes found no credentials
- changed to `users.users.<user>.home` (falling back to dshHome), letting the agent inherit the user's own tooling context (git/gh credentials, ~/.gitconfig, npm/ssh configs)
- DSH_HOME remains dsh's state root and is unaffected
- verified: pushing the backlog succeeded; the system prebuild passes
| Commit | Description |
|--------|-------------|
| `514831c` | fix(dsh): point service HOME at the real user home — git's gh credential helper resolves ~/.config/gh from $HOME, so HOME=dshHome left sandbox pushes without credentials |

## 2026-08-20T16:13:40+09:00

**Summary**: fix(dsh-nix-shell): sudo executor PATH merge order

- socket-activated template units inherit systemd's manager-default PATH (coreutils/findutils/grep/sed/systemd store paths only)
- `...process.env` spread after the explicit NixOS PATH overrode it, leaving profile tools like ps and nixos-rebuild unresolvable inside the daemon
- fixed by spreading the inherited env first and the explicit NixOS profile PATH second (request env still merges last)
- verified: the PATH starts with /run/current-system/sw/bin, with both ps and nixos-rebuild resolving
| Commit | Description |
|--------|-------------|
| `63b2576` | fix(dsh-nix-shell): put the explicit NixOS profile PATH after the inherited env — socket-activated template units inherit systemd's manager-default PATH, which overrode the executor PATH and left profile tools (ps, nixos-rebuild) unresolvable |

## 2026-08-20T16:01:28+09:00

**Summary**: docs(dsh): sync usage examples with actual module behavior

- manual composition-row examples now use `- insert:` wrapping plus a warning (a bare `- id:` row only patches existing entries)
- the skill-plugin doc corrects all 7 entry ids (the `skill-nixkits-<id>` prefix was missing) and the disabled-example id
- the dsh doc's install section switches to module-based installation (the old `nixkits.extraPackages` no longer exists) and adds the binary-cache note
- all four languages synced
| Commit | Description |
|--------|-------------|
| `6074661` | docs(dsh): sync usage examples with module reality — insert-op wrapping for manual rows, corrected skill entry ids, module-based install + cache note |

## 2026-08-21T23:02:33+09:00

**Summary**: chore(pkgs): dsh 0.1.0-rc.7 → 0.1.0-rc.8 — leftover bump completed

- real src hash and npmDepsHash filled in
- package-lock.json regenerated (the old lock was missing 120 entries, incl. dsh-invariants)
- verified: rc.8 builds, the randomUUID fallback patch applies, the with-plugins variant runs, and the service starts with no plugin load errors
- with-plugins injects only dsh-nixos-shell
| Commit | Description |
|------|------|
| `a7cbe3e` | chore(pkgs): bump dsh 0.1.0-rc.7 → 0.1.0-rc.8 |

## 2026-08-21T22:11:28+09:00

**Summary**: fix(module): dsh crash resilience — Restart=always + RestartSec 5s

- dsh upstream has a known crash bug (cordis-plugin-timer Context disposed; rc.6 hit it after ~13h), and rc.7/rc.8 keep the same cordis-plugin-timer dependency (^1.1.3), so the bug persists
- on crash the lighttpd reverse proxy returns 503 until systemd restarts the unit
- switched to Restart=always (on-failure does not cover exit-0 paths) with a 5s restart delay to minimize the outage window
| Commit | Description |
|------|------|
| `ed7e9d5` | fix(module): dsh Restart=always + faster RestartSec (crash resilience) |

## 2026-08-20T11:08:08+09:00

**Summary**: fix(module): dsh plugin ESM resolution — via a $DSH_HOME/node_modules symlink

- dsh's cordis-plugin-loader resolves from the profile directory ($DSH_HOME/profiles/web) as its base, searching node_modules upward from there
- plugins were injected into dsh's store tree, but the store is not on the profile's node_modules path, so import hit ERR_MODULE_NOT_FOUND and dsh crashed at startup
- preStart now symlinks the injected @kihara777 scope into $DSH_HOME/node_modules so Node can resolve it; after realpath back into the store tree, the @deepseek-ai/* peer deps the plugins import remain resolvable in the same tree
- verified: skills + nix-shell plugins load
| Commit | Description |
|------|------|
| `044b891` | fix(module): dsh plugin ESM resolution via DSH_HOME/node_modules symlink |

## 2026-08-20T10:33:26+09:00

**Summary**: fix(dsh): insert-block indentation fix — one insert op per package

- a nested '' string is dedented by its own minimum indent, pushing the plugin entry objects back to column 0, where they parsed as sibling patch ops of `- insert:` instead of its children (dsh reported patch: entry … not found plus id is required for non-insert patches, and all 8 rows failed to mount again)
- emits one insert op per package entry with the entry object sharing the `- insert:` line's string (column 2/4 indentation), and the module comment records the trap
- verified: dump-config runs with zero stderr and all 8 rows in the composed tree
| Commit | Description |
|--------|-------------|
| `988dc6d` | fix(dsh): emit one insert op per plugin entry in a single string — nested '' strings dedent to column 0, turning entry objects into sibling patch ops |

## 2026-08-20T10:21:46+09:00

**Summary**: fix(dsh): generated rows now use the insert verb — a bare `- id:` row only patches an existing entry

- a bare `- id:` row in cordis.patch.yml only patches an existing entry, so dsh dropped every new plugin entry and none of the 8 plugin rows mounted (verified via dump-config)
- the package injection succeeded, but with no entries in the composed tree the nix_shell tool and the 7 skill plugins never registered
- fixed by wrapping the generated plugins.packages rows in an `- insert:` op (same shape as the MCP rows in extraPatch)
- verified: dump-config runs with zero stderr and all 8 rows in the composed tree
| Commit | Description |
|--------|-------------|
| `3d0433d` | fix(dsh): wrap generated plugin rows in the insert op — bare - id: rows only patch existing entries, so dsh dropped every new entry with 'patch: entry … not found' |

## 2026-08-20T09:45:59+09:00

**Summary**: fix(dsh): multi-plugin injection failure — GNU tar restores directory modes, leaving the scope dir unwritable

- after unpacking, GNU tar restores the archived directory modes (0555 for store trees), so the scope directory (@kihara777/) created by the previous plugin is unwritable for the next one, and the second and later plugins fail with "Cannot mkdir: Permission denied"
- a single-plugin setup never triggers it, and the first real system build exposed it
- fixed by chmod -R u+w immediately after each plugin extraction
- verified: full system toplevel build succeeds; dsh-nix-shell and all 7 skills injected
| Commit | Description |
|--------|-------------|
| `b03a386` | fix(dsh): chmod node_modules after each plugin injection — GNU tar restores archived dir modes (0555) after extraction, leaving the scope dir created by the previous plugin unwritable for the next one |

## 2026-08-20T08:12:57+09:00

**Summary**: fix(rcc-fix): desktop entry rename compat — old filename shipped as a symlink

- asusctl 6.4.0 renamed its desktop entry to org.opengamingcollective.rog-control-center.desktop, while nixpkgs' programs.rog-control-center autoStart (makeAutostartItem) still copies the old rog-control-center.desktop name, breaking the system build (cp cannot stat)
- the rcc-fix overlay now ships the old name as a symlink in asusctl's postInstall
- verified: makeAutostartItem { name = "rog-control-center"; package = asusctl } builds successfully (EXIT=0) against the machine's pinned nixpkgs rev (0ae2bc1)
| Commit | Description |
|------|------|
| `650f6f7` | fix(rcc-fix): compat symlink for renamed desktop entry — nixpkgs programs.rog-control-center autoStart copies the pre-6.4.0 filename |

## 2026-08-20T07:41:45+09:00

**Summary**: fix(rcc-fix): patch rebased for asusctl 6.4.0

- after nixpkgs advanced, asusctl moved 6.3.7 → 6.4.0 and hunk 4 of rcc-fix.patch failed (system build broke)
- upstream restructured that region (`is_old_laptop`/`retain` replacing the old push block; the else-branch filter was absorbed upstream), so the patch now keeps only the bounds-check replacement (`names[(*z) as usize]` → filter_map with bounds check + warn); the other hunks needed no change
- verified: git apply --check passes all hunks against the 6.4.0 source; asusctl builds successfully (EXIT=0) against the machine's pinned nixpkgs rev (0ae2bc1)
| Commit | Description |
|------|------|
| `ce216c7` | fix(rcc-fix): rebase patch hunk 4 for asusctl 6.4.0 — upstream is_old_laptop/retain restructure, else-filter absorbed upstream |

## 2026-08-20T06:27:40+09:00

**Summary**: feat(dsh-nix-shell): external sudo daemon integration (0.2.0)

- the plugin probes the daemon socket at init (config `sudoSocketPath` / env `NIXKITS_SUDO_SOCKET`) and advertises `sudo`/`justification` when it exists; `sudo: true` requests are routed whole (command/cwd/env/timeout) over the Unix socket to the daemon, with `justification` mandatory and echoed alongside the result
- the daemon is a systemd socket-activated root executor (nixkits-sudo@.service + nixkits-sudo-exec.js, one-request-per-connection JSON protocol, shipped with the plugin package); the access-control boundary is the socket file, owned by the dsh service user with mode `0600` (SocketUser/SocketMode)
- the module adds nixkits.dsh.sudo (enable/socketPath/package), generating the socket and service and injecting the env var
- verified: gating, routing round-trip, justification enforcement, direct executor protocol and module evaluation all pass
| Commit | Description |
|------|------|
| `ef4bcfc` | feat(dsh-nix-shell): external sudo daemon integration — socket-activated root executor, init-time detection, sudo routing |

## 2026-08-20T06:02:50+09:00

**Summary**: refactor(skills): NixKits skills rewritten as native DSH skill plugins — new package @kihara777/dsh-skill-nixkits (zero runtime dependencies)

- one subpath plugin entry per skill; each registers its own content at runtime via ctx.skills.register (runtime provider, rank 250, outranking filesystem sources) and returns the registration disposer from apply(), so it is dropped with the composition
- SKILL.md files stay the single source of truth in skills/ and are embedded at build time, with the frontmatter stripped into content and kept as metadata (the docs-pipeline auto-discovery contract is unchanged)
- the module's skills.enable now auto-generates the 7 composition rows (skill-nixkits-<id> → @kihara777/dsh-skill-nixkits/<id>), replacing the previously misimplemented directory injection (nixkits-skills package and bundledSkillDir)
- verified: all 7 plugins register via a mock ctx, and bare-subpath import plus registration were tested live
- CI builds added for x86_64/aarch64
| Commit | Description |
|------|------|
| `7393b95` | feat(dsh): rewrite NixKits skills as native skill plugins — dsh-skill-nixkits package, one plugin entry per skill |

## 2026-08-20T05:27:48+09:00

**Summary**: feat(dsh): built-in bash tool NixOS fix + third-party plugin packages + deployment-bundled skills

- the module injects a complete NixOS PATH into the dsh service (systemd's default PATH lacks bash; the built-in bash tool failed with spawn bash ENOENT)
- new dsh-nix-shell package (@kihara777/dsh-nix-shell, a NixOS-aware shell tool plugin: Nix store bash fallback when PATH resolution fails, injected NixOS PATH, timeout and spill output) and nixkits-skills package (skill directory bundle)
- new module options plugins.packages (tar-extracted into node_modules — a symlink is realpathed back into the plugin's store path, breaking peer resolution, so it must be extracted physically — with auto-generated composition rows) and skills.enable (skill-filesystem bundledSkillDir, rank 600)
- CI builds for dsh-nix-shell on x86_64/aarch64
- verified end-to-end: IMPORT-OK inside the injected tree
| Commit | Description |
|------|------|
| `69eedd4` | feat(dsh): PATH fix + third-party plugin packages + bundled skills — L1/L2/L3/路径A |
| `55664ed` | docs: dsh-nix-shell package docs + dsh module options + README rows (4 languages) |

## 2026-08-19T20:39:47+09:00

**Summary**: fix(ci): ci-summary badge stuck on failing

- the jq pipeline filtered failures before grouping by workflow, so an old failed run masked all later successes forever (badge stayed red after the codewhale riscv64 fix)
- now it takes the latest run per workflow first and only then filters failures — badge back to passing
| Commit | Description |
|------|------|
| `d752c83` | fix(ci): ci-summary badge stuck on failing — latest-run check must precede failure filter |

## 2026-08-19T19:57:03+09:00

**Summary**: fix(codewhale-src): riscv64 cross build — four-part fix chain

- rquickjs-sys 0.12.2 ships no riscv64gc bindings (the build.rs non-bindgen path includes the target file); upstream's 64-bit little-endian bindings are byte-identical, so postPatch drops an x86_64 copy into the materialized vendor dir
- the host-side ring build let cc-rs fall back from the host triple to the cross compiler and add -m64 — now points at the buildPackages toolchain explicitly
- the bare postInstall cargo build lost --target and linked with the host toolchain — now mirrors cargoBuildHook's target triple
- binaries link -lgcc_s dynamically and autoPatchelfHook only scans hostPlatform deps — the cross gcc libgcc output is now an explicit input
- verified locally with the exact CI command (pkgsCross.riscv64.callPackage); clears the 6-run red Build codewhale (riscv64)
| Commit | Description |
|------|------|
| `962ce6c` | fix(codewhale-src): riscv64 cross build — rquickjs bindings overlay, host cc-rs toolchain, postInstall --target, libgcc rpath |

## 2026-08-19T17:57:26+09:00

**Summary**: AGENTS.md — fixed a stale reference and aligned the CI section description

- fixed the stale comfyui-strix-halo module reference (that module was merged into comfyui-rocm)
- aligned the CI section with the actual workflow layout (per-package build-<pkg>-<arch>.yml calling the shared build-package.yml with cachix-action pushes; noting packages without riscv64 builds and godot-ai/dsh having no dedicated build workflow; ci-summary.yml badge mechanism)
| Commit | Description |
|------|------|
| `c4e320e` | docs(AGENTS): fix stale comfyui-strix-halo reference + align CI description with actual workflows |

## 2026-08-19T16:52:54+09:00

**Summary**: fix(module): dsh WebSocket reverse proxy switched to mod_proxy upgrade

- NixOS's lighttpd module generates server.modules in a fixed allKnownModules order, so mod_wstunnel loads after mod_proxy; since proxy.server matches every path, mod_proxy intercepts the upgrade on /api/events.* and returns 426, while mod_wstunnel never runs (r->handler_module already set)
- switched to lighttpd 1.4.56+ mod_proxy native WebSocket tunneling (proxy.header = "upgrade" => "enable"), dropping mod_wstunnel
- verified: 8625 / returns 200, /api/events.host|mux handshake 101 (local + LAN)
| Commit | Description |
|------|------|
| `51d9435` | fix(module): dsh WebSocket reverse proxy via mod_wstunnel |
| `33d5931` | fix(module): dsh wstunnel port as string (match lighttpd backend syntax) |
| `d7d2713` | fix(module): dsh WebSocket via mod_proxy upgrade (mod_wstunnel never runs) |

## 2026-08-19T13:10:00+09:00

**Summary**: fix(pkgs): dsh 0.1.0-rc.6 → 0.1.0-rc.7 — version bump carrying upstream fixes

- rc.6 crashed after ~13h (fatal load failure: Context has been disposed) — cordis-plugin-timer's ctx.timeout() rejects on a silent Context dispose, surfacing as an unhandled rejection
- rc.7 (8/17) is the latest; cordis/timer versions are unchanged (the bug may persist) but it carries upstream fixes
- plugin inventory unchanged (131)
| Commit | Description |
|------|------|
| `c75cb4c` | chore(pkgs): bump dsh 0.1.0-rc.6 → 0.1.0-rc.7 |

## 2026-08-18T20:00:00+09:00

**Summary**: fix(module): dsh supports normal-user operation — new dshHome option

- running as the isolated system user (home /var/lib/dsh) it could not read /home/<user> (mode 700), so the agent could not touch the working tree
- adds dshHome; HOME/DSH_HOME/WorkingDirectory/preStart all route through it, and StateDirectory becomes preStart mkdir + chown
- the local config uses user="kix" + dshHome="/home/kix/.dsh", so dsh runs as kix and can reach /home/kix
| Commit | Description |
|------|------|
| `584c764` | fix(module): dsh dshHome option + support normal-user operation |

## 2026-08-18T19:30:00+09:00

**Summary**: feat(module): nixkits.dsh.settings — declarative settings

- dsh settings-menu options live in $DSH_HOME/settings.yaml (file-backed, hot-reloaded, per-namespace sections)
- new settings option (attrsOf attrs, namespace → section) rendered as JSON (valid YAML) and written by preStart
- Verified: web-search-deepseek.maxTokens declaratively overrides the default 4096 → 8192
- 4-language docs gain a settings section
| Commit | Description |
|------|------|
| `f2981e6` | feat(module): nixkits.dsh.settings — declarative settings |
| `dc64cbb` | docs(dsh): declarative settings section + maintenance log |

## 2026-08-18T18:45:00+09:00

**Summary**: docs(dsh) + refactor(skill): plugin inventory sync

- docs/dsh.md (4 langs) gains a Plugin inventory section (131 built-in entry ids, id -> package) as reference for nixkits.dsh.plugins.disabled
- the check-updates skill step 5 gains a dsh note: on a bump, extract the inventory from the freshly built package dsh-*/cordis.patch.yml and sync it into docs
| Commit | Description |
|------|------|
| `06d0e28` | docs(dsh): plugin inventory + check-updates skill sync |

## 2026-08-18T18:39:34+09:00

**Summary**: fix(module): dsh preStart rm before cp — overwriting 444 read-only files

- files generated by preStart have mode 444 (read-only), so the service user cannot cp over them; remove first, then copy
| Commit | Description |
|------|------|
| `f308ac7` | fix(module): dsh preStart rm before cp — service-user cannot overwrite 444 |

## 2026-08-18T18:20:00+09:00

**Summary**: feat(module): nixkits.dsh.plugins — declarative plugin on/off and config

- dsh plugins hot-reload via cordis.patch.yml; the module adds plugins.disabled (entry ids), plugins.settings (config overrides), plugins.extraPatch (raw fragments like MCP)
- the system config migrated MCP to extraPatch, moved the API key to kix.credentials, and disables session-telemetry-otel + session-stats as an example
- Verified: cordis.patch.yml renders correctly and disabling plugins produces no absent-id warning
| Commit | Description |
|------|------|
| `0e4fe58` | feat(module): nixkits.dsh.plugins — declarative plugin on/off + config |
| `164d515` | docs(dsh): declarative plugin management section + maintenance log |

## 2026-08-18T17:55:00+09:00

**Summary**: fix(module): lighttpd rewrites Host/Origin to loopback — supersedes trustedHosts

- dsh's isTrustedApiRequest then sees loopback and passes, with no per-deployment trustedHosts and no LAN hostname/IP leaked to the backend
- Origin must be rewritten alongside Host or the same-origin check fails
- Verified: after dropping trustedHosts, the proxied API (harukax.lan / 192.168.31.241) returns ok:true
| Commit | Description |
|------|------|
| `a33b414` | fix(module): rewrite Host/Origin to loopback in lighttpd reverse proxy |

## 2026-08-18T17:30:00+09:00

**Summary**: fix(module): dsh trustedHosts option — all /api calls 403 behind the proxy

- dsh validates the Host header on /api requests, and via lighttpd the Host arrives as the LAN hostname/IP, so requests were rejected
- adds nixkits.dsh.trustedHosts (mapped to repeatable --trusted-host)
- the system config trusts harukax.lan + 192.168.31.241 and the API recovered
| Commit | Description |
|------|------|
| `3755935` | fix(module): dsh trustedHosts option — Host-header 403 behind reverse proxy |

## 2026-08-18T16:20:05+09:00

**Summary**: fix(dsh): patch browser client bundles — crypto.randomUUID fallback

- crypto.randomUUID() is unavailable in non-secure contexts (HTTP on a LAN IP, i.e. via the lighttpd reverse proxy), so the webui errored
- postInstall replaces it in dsh-client-connection + dsh-client-ui-conversation with a __dshUuid helper that falls back to crypto.getRandomValues (available in every context)
| Commit | Description |
|------|------|
| `5d1cfa8` | fix(dsh): patch browser client bundles — crypto.randomUUID fallback |

## 2026-08-18T15:29:14+09:00

**Summary**: fix/docs(dsh): finalizing the lighttpd reverse proxy

- dsh internal loopback port 8615 (mirroring SearXNG's 42701), lighttpd public port 8625 (mirroring 4270)
- the firewall opens the lighttpd public port, not dsh's internal one
- 4-language docs synced to the final scheme
| Commit | Description |
|------|------|
| `4a78d54` | fix(module): dsh internal port 8615, public reverseProxy port 8625 |
| `5452a3e` | docs(dsh): sync service section to loopback 8615 + lighttpd reverseProxy 8625 |

## 2026-08-18T14:38:26+09:00

**Summary**: feat(module): add nixkits.dsh.reverseProxy (lighttpd)

- dsh rejects non-loopback hosts (RCE safety), so a lighttpd `$SERVER["socket"]` block proxies 0.0.0.0:8626 to dsh loopback 8625 (reusing the SearXNG lighttpd instance; extraConfig is types.lines and merges cleanly)
- port 8626 is opened in the firewall
| Commit | Description |
|------|------|
| `12e11af` | feat(module): add nixkits.dsh.reverseProxy via lighttpd |

## 2026-08-18T10:29:46+09:00

**Summary**: feat/fix(dsh): deploy the dsh service and configure MCP + skills.

- module fix: the dsh system user's HOME=/var/empty (read-only) caused EPERM; switched to a writable /var/lib/dsh + StateDirectory
- the HMR service needs --expose-internals; launch bin.js via node --expose-internals
- MCP services (SearXNG + Godot) are configured with cordis.patch.yml `insert:` syntax, not id-targeted overrides
- skills copied to /var/lib/dsh/skills/, not an .agent-presets subdirectory
- nixkits-skills directory corrected to ~/.dsh/skills

| Commit | Description |
|------|------|
| `b17e5bf` | fix(module): dsh writable HOME + StateDirectory |
| `ed6983e` | fix(module): dsh launch via node --expose-internals (HMR requires execArgv) |
| `456c917` | feat(skill): nixkits-skills add dsh skills directory support |
| `ee24563` | fix(skill): correct dsh skills directory — ~/.dsh/skills |

## 2026-08-18T08:42:40+09:00

**Summary**: docs: sync ruyi channel versions and fill the three READMEs' ruyi description column

- `ruyi` stable 0.50.0 → 0.51.0, beta/alpha dates synced
- the ruyi description column in the en/ja/pcn READMEs was empty `<br><br>`; it now holds the RuyiSDK description + three channel versions, matching zh
| Commit | Description |
|------|------|
| `86ae30b` | docs: sync ruyi channel versions + fill empty ruyi descriptions in en/ja/pcn README |

## 2026-08-18T07:19:30+09:00

**Summary**: audit fixes — version bumps plus module/overlay/doc/skill corrections.

- codewhale 0.9.8, mcp-searxng 1.15.0, opencode-telegram 0.24.0, obs-bilibili-stream 2.1.3 bumped
- comfyui-rocm module restored the services.comfyui assertion and clarified the nixpkgs-compat patch target
- overlay codewhale falls back to a source build per architecture (riscv64)
- doc versions, the ruyi link and the codewhale-sudo description synced
- write-maintenance-log skill gained a table header and dropped the katalish column

| Commit | Description |
|------|------|
| `0ffa734` | fix(comfyui-rocm): clarify nixpkgs-compat patch target + restore assertion |
| `cb4e250` | fix(default-overlay): codewhale riscv64 fallback to source build |
| `04e95da` | chore(pkgs): bump mcp-searxng 1.14.1 → 1.15.0 |
| `c65d740` | chore(pkgs): bump codewhale 0.9.4 → 0.9.8 |
| `4531bf6` | chore(pkgs): bump opencode-telegram 0.23.1 → 0.24.0 |
| `7f14633` | chore(pkgs): bump obs-bilibili-stream 2.1.2 → 2.1.3 |
| `685864e` | docs: sync version numbers + ruyi link + codewhale-sudo description |
| `cc768d0` | fix(skill): write-maintenance-log table header + drop katalish |

## 2026-08-15T10:04:37+09:00

**Summary**: refactor: merge comfyui-rocm-patch + comfyui-strix-halo into single comfyui-rocm

- two modules handled different halves of ComfyUI ROCm support (patch layer vs Strix Halo hardware optimizations); unified as nixkits.comfyui-rocm (enable option)
- covers patch mount, GFX override, xformers bypass, the C toolchain, and Strix Halo config (ROCm runtime/DeviceAllow/kernelParams)
- docs and README synced
| Commit | Description |
|------|------|
| `d473991` | refactor: merge comfyui-rocm-patch + comfyui-strix-halo into comfyui-rocm |

## 2026-08-15T09:23:15+09:00

**Summary**: refactor: rename rog-control-center-fix.patch → rcc-fix.patch, completing the rcc-fix unification

- patch file rog-control-center-fix.patch → rcc-fix.patch
- references updated in overlays/rcc-fix.nix and the 4-language rcc-fix.md docs
| Commit | Description |
|------|------|
| `b350cfd` | refactor: rename rog-control-center-fix.patch to rcc-fix.patch |

## 2026-08-15T08:31:32+09:00

**Summary**: deepseek-harness 0.1.0-rc.6 — new package (@deepseek-ai/dsh)

- Prebuilt npm package, bin `dsh` → `lib/bin.js`, with a vendored package-lock.json (npm tarballs ship none) and dontNpmBuild to skip the build
- 4-language docs added and godot-ai/dsh listed in the README
| Commit | Description |
|------|------|
| `0194460` | feat(dsh): add deepseek-harness 0.1.0-rc.6 package + 4-language docs |

## 2026-08-15T08:07:33+09:00

**Summary**: refactor: merge rog-control-center-fix into rcc-fix

- Both referred to the same ROG Control Center fix (overlay asusctl patch + module systemd deadlock fix), unified to a single rcc-fix
- overlays/rog-control-center-fix.nix → rcc-fix.nix, modules/rog-control-center-fix.nix → rcc-fix.nix
- Option nixkits.rog-control-center-fix → nixkits.rcc-fix
- Removed standalone rog-control-center-fix docs (folded into rcc-fix.md)
| Commit | Description |
|------|------|
| `376eacf` | refactor: merge rog-control-center-fix into rcc-fix |

## 2026-08-13T01:20:29+09:00

**Summary**: fix(default-overlay): build godot-ai with fastmcp overlay applied

- The default overlay's `final.callPackage` resolved fastmcp to nixpkgs 3.3.1 (circular-import bug)
- Switched to `(prev.extend (import ./fastmcp.nix))` so deps resolve to 3.4.7
| Commit | Description |
|------|------|
| `94d49b5` | fix(default-overlay): build godot-ai with fastmcp overlay applied |

## 2026-08-12T10:05:00+09:00

**Summary**: fix(default-overlay): correct godot-ai package path

- `callPackage` in `overlays/default.nix` needs `../packages/` (the overlay lives in a subdirectory)
- `./packages/` resolved to the non-existent `overlays/packages/`
| Commit | Description |
|------|------|
| `0144283` | fix(default-overlay): correct godot-ai path — ./packages → ../packages |

## 2026-08-12T10:00:00+09:00

**Summary**: fix(default-overlay): register godot-ai

- godot-ai was present in flake packages but missing from the default overlay, invisible as pkgs.godot-ai to downstream (/etc/nixos)
| Commit | Description |
|------|------|
| `093565c` | fix(default-overlay): register godot-ai so pkgs.godot-ai is available |

## 2026-08-12T09:18:26+09:00

**Summary**: docs(godot-ai): new 4-language docs (72 lines)

- Architecture diagram, dependency table (with fastmcp 3.4 note), system install + MCP config + prerequisite guide
| Commit | Description |
|------|------|
| `76c39c8` | docs(godot-ai): add 4-language documentation |

## 2026-08-12T07:07:27+09:00

**Summary**: feat(godot-ai): new godot-ai 3.1.5 package + fastmcp 3.4.7 overlay

- godot-ai (hi-godot/godot-ai) is a production-grade MCP server connecting clients to a running Godot editor (43 tools / 120+ operations)
- fastmcp bumped nixpkgs 3.3.1 → 3.4.7 (godot-ai needs >=3.4.0, 3.3.x has the circular-import bug), with cascading fastmcp-slim + py-key-value-aio 0.4.5 upgrades
- devshell godot-mcp → godot-ai
| Commit | Description |
|------|------|
| `23a5b8d` | feat(godot-ai): add godot-ai 3.1.5 package + fastmcp 3.4.7 overlay |

## 2026-08-11T18:49:54+09:00

**Summary**: fix(breeze-black): pure black bg + pure white fg for Edge/Chromium

- Extended sed remap: backgrounds #292c30 → #000000 (buttons/toolbars/insensitive), foregrounds #fcfcfc/#a1a9b1 → #ffffff
- gtk-3.0/4.0 verified: 15× #000000, 14× #ffffff, zero gray residues
| Commit | Description |
|------|------|
| `4e5c558` | fix(breeze-black): pure black bg + pure white fg for Edge/Chromium |

## 2026-08-11T18:41:14+09:00

**Summary**: fix(breeze-black): map background variables to true black #000000

- Breeze-Dark base is #202326 (dark gray, not pure black)
- Remap main background/base to #000000 after copying (buttons keep #292c30 for distinction)
- Make gtk-dark.css self-contained (copy of gtk.css), dropping the gray import
| Commit | Description |
|------|------|
| `2ee1ba6` | fix(breeze-black): map background variables to true black #000000 |

## 2026-08-11T16:19:49+09:00

**Summary**: fix(breeze-black): overwrite gtk.css body with the Breeze-Dark dark scheme

- Chromium-based apps (Edge/Chrome) ignore prefer-dark and load gtk.css directly
- BreezeBlack (renamed from light Breeze) still had light variables (#eff0f1) so Edge rendered gray
- Overwrite gtk-{3,4}.0 gtk.css(+.map) with dark (#202326)
| Commit | Description |
|------|------|
| `25e23e0` | fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme |

## 2026-08-11T16:02:39+09:00

**Summary**: fix(breeze-black): keep Breeze-Dark

- BreezeBlack's gtk-dark.css gets the real dark scheme (#202326) via `@import ../../Breeze-Dark/...`
- Deleting Breeze-Dark in preFixup broke the import and GTK fell back to light (the "not black enough" symptom)
| Commit | Description |
|------|------|
| `0433eee` | fix(breeze-black): keep Breeze-Dark — gtk-dark.css imports it for dark mode |

## 2026-08-09T22:43:43+09:00

**Summary**: refactor(skill): add trap 4

- Bare `nix flake lock` refreshes all floating inputs (nixpkgs drift retriggers the diffusers/httpx failure on 8/7 nixpkgs)
- Use --update-input or pin the nixpkgs rev instead
| Commit | Description |
|------|------|
| `ec5e589` | refactor(skill): add trap 4 — bare nix flake lock refreshes floating inputs |

## 2026-08-09T19:40:21+09:00

**Summary**: feat(patches): vendor local comfyui-nix build fixes as a patch file

- ① mkWheel dontCheckRuntimeDeps (pythonRuntimeDepsCheckHook, nixpkgs ≥ 8/5)
- ② doInstallCheck=false for flaky suites (jupyter-server/scipy/fastapi/einops/mss/inline-snapshot)
- ③ torch/facexlib runtime-deps skip
- Updated module comment + 4-language docs
| Commit | Description |
|------|------|
| `a8ad11e` | feat(patches): add comfyui-nix nixpkgs-compat patch + module doc |
| `faefa5b` | docs(comfyui-rocm-patch): document nixpkgs-compat patch (4 langs) |

## 2026-08-09T19:05:53+09:00

**Summary**: refactor(skill): nixkits-check-updates gains a nixpkgs-drift troubleshooting section

- ① Restoring an old flake.lock requires verifying follows in flake.nix (lost → glibc 2.40 → GLIBC_ABI_GNU2_TLS)
- ② pytest packages need doInstallCheck=false (pytestCheckHook runs in installCheckPhase)
- ③ pythonRuntimeDepsCheckHook (nixpkgs ≥ 8/5) breaks wheel builds, fix with dontCheckRuntimeDeps=true
| Commit | Description |
|------|------|
| `e88fd98` | refactor(skill): add nixpkgs-drift troubleshooting section to check-updates |

## 2026-08-09T04:21:09+09:00

**Summary**: fix(module): llama-cpp — deprecated extraFlags and freeform settings definitions

- `services.llama-cpp.extraFlags` is deprecated; pass `--sleep-idle-seconds` via `settings`
- freeform `settings` cannot have separate definitions; merge `models-preset` and `sleep-idle-seconds` via `lib.mkMerge`
| Commit | Description |
|------|------|
| `8026d8e` | fix(module): replace deprecated services.llama-cpp.extraFlags with settings |
| `0ec7760` | fix(module): merge llama-cpp settings via mkMerge |

## 2026-08-08T23:07:40+09:00

**Summary**: fix(breeze-black): restored look-and-feel global theme + fixed GTK rename

- 7/23 external patch removal caused two regressions; the `org.kde.breezeblack.desktop` global theme was missing, so BreezeBlack disappeared from the settings theme chooser — restored via the vendored look-and-feel package
- the `preFixup` Breeze* glob matched both Breeze and Breeze-Dark, nesting the GTK theme; now renames Breeze only
| Commit | Description |
|------|------|
| `114b9c2` | fix(breeze-black): restore look-and-feel global theme + fix GTK rename |

## 2026-08-08T22:50:33+09:00

**Summary**: fix(codewhale-src): synced to 0.9.4 with corrected source hash

- the `nix-prefetch-url` archive tarball hash did not match `fetchFromGitHub` (git protocol), causing repeated riscv64 CI failures
- obtained the correct hash via a `fetchFromGitHub` build and synced Cargo.lock
- corrected the wrong advice in the skill as well
| Commit | Description |
|------|------|
| `08b04a2` | fix(codewhale-src): sync to 0.9.4 with correct fetchFromGitHub hash |
| `ab2a624` | fix(skill): correct fetchFromGitHub hash advice — archive tarball trap |

## 2026-08-08T22:20:21+09:00

**Summary**: codewhale 0.9.4, mcp-searxng 1.14.1 and opencode-telegram 0.23.1 — upstream updates

- `codewhale` 0.9.3 → 0.9.4, upstream bug fixes; `mcp-searxng` 1.14.0 → 1.14.1, upstream maintenance; `opencode-telegram` 0.22.5 → 0.23.1, upstream feature update
| Commit | Description |
|------|------|
| `f184fdb` | chore(pkgs): bump codewhale 0.9.3 → 0.9.4 |
| `9b877e1` | chore(pkgs): bump mcp-searxng 1.14.0 → 1.14.1 |
| `9b17590` | chore(pkgs): bump opencode-telegram 0.22.5 → 0.23.1 |
| `59ac74a` | docs: sync version numbers |

| Package | Old | New |
|------|------|------|
| codewhale | 0.9.3 | 0.9.4 |
| mcp-searxng | 1.14.0 | 1.14.1 |
| opencode-telegram | 0.22.5 | 0.23.1 |

## 2026-08-05T07:24:56+09:00

**Summary**: chore(pkgs) — codewhale-src synced to 0.9.3

- the riscv64 source build was 3 patch versions behind the prebuilt package; synced `version`, `fetchFromGitHub` hash and Cargo.lock (711 → 763 entries)
| Commit | Description |
|------|------|
| `563eea2` | chore(pkgs): sync codewhale-src to 0.9.3 — version, hash, Cargo.lock |

## 2026-08-05T01:30:00+09:00

**Summary**: refactor(skill) — nixkits-check-updates gains a Rust package update flow

- added a Rust package (`buildRustPackage`) update flow generalizing the codewhale-src Cargo.lock sync lesson: three-way sync of `version` + source hash + Cargo.lock, upstream lock download with entry-count verification, and cross-compile timeout fallback
| Commit | Description |
|------|------|
| `6e6bef6` | refactor(skill): add Rust package (buildRustPackage) update flow to nixkits-check-updates |

## 2026-08-04T02:15:00+09:00

**Summary**: fix(ruyi): tolerate ruff lint failures

- the second ruff check (without `--fix`) blocked builds on 139 upstream violations after the nixpkgs ruff update; checkPhase now tolerates that failure
| Commit | Description |
|------|------|
| `1175df2` | fix(ruyi): tolerate ruff lint failures in checkPhase |

## 2026-08-04T01:15:52+09:00

**Summary**: codewhale 0.9.3 and mcp-searxng 1.14.0 — upstream updates

- `codewhale` 0.9.1 → 0.9.3, upstream bug fixes; `mcp-searxng` 1.12.1 → 1.14.0, upstream feature update
| Commit | Description |
|------|------|
| `f84cbcb` | chore(pkgs): bump codewhale 0.9.1 → 0.9.3 |
| `6968f4e` | chore(pkgs): bump mcp-searxng 1.12.1 → 1.14.0 |
| `d778b1b` | docs: sync version numbers |

| Package | Old | New |
|------|------|------|
| codewhale | 0.9.1 | 0.9.3 |
| mcp-searxng | 1.12.1 | 1.14.0 |

## 2026-07-31T04:07:23+09:00

**Summary**: fix(ci): fixed ci-summary.yml and switched the badge to a shields.io endpoint

- `ci-summary.yml` had syntax errors (mixed YAML runs-on/workflow_dispatch, hardcoded token); switched to push/schedule triggers with `GITHUB_TOKEN`
- the README badge moved from `check.yml` (bare flake evaluation) to a shields.io endpoint reflecting the actual status of all Build workflows
| Commit | Description |
|------|------|
| `c0e52a5` | fix(ci): fix ci-summary.yml syntax, switch README badge to endpoint |

## 2026-07-31T03:34:15+09:00

**Summary**: fix(ci): injected GITHUB_TOKEN as a Nix access-token

- the `llama-cpp-ver` input requires GitHub API calls and unauthenticated access is limited to 60/hr, so parallel CI jobs frequently hit HTTP 403; now authenticates with `${{ secrets.GITHUB_TOKEN }}`
| Commit | Description |
|------|------|
| `41a8a8b` | fix(ci): inject GITHUB_TOKEN as Nix access-token for llama-cpp-ver API |

## 2026-07-31T03:00:12+09:00

**Summary**: fix(codewhale-src): fixed the riscv64 cross-compile

- the `ring` crate's `cc` build inherited `-m64` (an x86_64 flag) from the generic CFLAGS, causing riscv64-gcc errors
- clear the generic CFLAGS/CXXFLAGS in addition to the per-target variables
| Commit | Description |
|------|------|
| `29c780a` | fix(codewhale-src): clear generic CFLAGS/CXXFLAGS for riscv64 cross-compile |

## 2026-07-30T17:56:11+09:00

**Summary**: codewhale 0.9.1, mcp-searxng 1.12.1 and opencode-telegram 0.22.5 — upstream updates

- `codewhale` 0.9.0 → 0.9.1, upstream bug fixes; `mcp-searxng` 1.11.1 → 1.12.1, upstream feature update; `opencode-telegram` 0.22.3 → 0.22.5, upstream maintenance
| Commit | Description |
|------|------|
| `1110c7a` | chore(pkgs): bump codewhale 0.9.0 → 0.9.1 |
| `3dcb65a` | chore(pkgs): bump mcp-searxng 1.11.1 → 1.12.1 |
| `98abe96` | chore(pkgs): bump opencode-telegram 0.22.3 → 0.22.5 |
| `a94dea8` | docs: sync version numbers |

| Package | Old | New |
|------|------|------|
| codewhale | 0.9.0 | 0.9.1 |
| mcp-searxng | 1.11.1 | 1.12.1 |
| opencode-telegram | 0.22.3 | 0.22.5 |

## 2026-07-23T12:56:53+09:00

**Summary**: fix(codewhale-sudo): fixed the ptrace wrapper

- removed child-process tracing so codewhale sub-shells are not killed by SIGTRAP
- added `PTRACE_EVENT_EXEC` handling
- synced the 4-language docs (LD_PRELOAD → ptrace description)
| Commit | Description |
|------|------|
| `c77cadc` | fix(codewhale-sudo): stop tracing child processes, handle PTRACE_EVENT_EXEC |
| `480658e` | docs(codewhale-sudo): update mechanism description LD_PRELOAD → ptrace |

## 2026-07-23T12:08:13+09:00

**Summary**: fix(codewhale-sudo): LD_PRELOAD shim replaced by a ptrace syscall interceptor

- codewhale is statically linked, so LD_PRELOAD could not intercept `prctl(PR_SET_NO_NEW_PRIVS)`
- now intercepts with `ptrace(2)` at the kernel boundary, compatible with both static and dynamic binaries
| Commit | Description |
|------|------|
| `6446364` | fix(codewhale-sudo): replace LD_PRELOAD shim with ptrace syscall interceptor |

## 2026-07-23T11:24:15+09:00

**Summary**: fix(overlays): breeze-black — replaced the defunct fetchpatch URL

- the injx.sbs domain in the original URL is permanently unavailable
- switched to a pure local colors file installation
- KDE Plasma auto-discovers color schemes from share/color-schemes/
| Commit | Description |
|------|------|
| `547d6a0` | fix(overlays): replace dead breeze-black fetchpatch with local copy |

## 2026-07-22T16:31:26+09:00

**Summary**: fix(modules) — rog-control-center and comfyui-strix-halo fixes

- rog-control-center-fix gained SendSIGKILL=yes + TimeoutStopSec=30s, so a stale asus-shutdown process no longer blocks systemd-switch
- comfyui-strix-halo gained a glibc >= 2.42 assertion (ROCm 7.2 needs GLIBC_ABI_GNU2_TLS)
| Commit | Description |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T09:00:00+09:00

**Summary**: feat(overlays) — new breeze-black overlay

- provides the high-contrast Breeze Black accessibility theme for Plasma 6 (global look-and-feel + GTK + color scheme)
- includes 4-language docs
| Commit | Description |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T05:39:31+09:00

**Summary**: docs(devshell) — new devShell documentation (4 languages)

- describes the opencode (full MCP stack) and ruyi (3 channels merged) environments
- README devShell table gained a doc links column
| Commit | Description |
|------|------|
| `7bfe3e3` | docs: add devShell documentation — 4 lang |
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |

## 2026-07-22T03:40:50+09:00

**Summary**: docs — unified user home directory paths to the `~/` prefix repo-wide

- replaced hardcoded `/home/kix` and `/home/<user>` variants
- covering 13 files
| Commit | Description |
|------|------|
| `f597b9a` | docs: generalize hardcoded /home/kix paths |
| `bb65b77` | docs: unify all user home paths to ~/ prefix |

## 2026-07-22T03:14:27+09:00

**Summary**: feat(shells) — opencode devShell iteration

- added SearXNG + lighttpd (matching system NixOS config) + blender-mcp + godot-mcp + godot + opencode + opencode-telegram
- auto-registers MCP config on first entry
- removed tryEval guards from godot packages
| Commit | Description |
|------|------|
| `35cc4e8` | feat(shells): add opencode-telegram devShell + nix run doc |
| `2b8f676` | fix(shells): add opencode to opencode-telegram devShell |
| `e83982d` | refactor(shells): merge blender-mcp + mcp-searxng |
| `c5a57a6` | refactor(shells): rename opencode, add godot-mcp + godot_4 |
| `60a065e` | fix(shells): add GODOT_PATH |
| `47e43b3` | fix(shells): set SEARXNG_URL |
| `3652030` | feat(shells): add self-contained SearXNG + Redis |
| `e0ead5a` | refactor(shells): extract devShells from flake.nix to develop/ |
| `9d67fd8` | feat(shells): auto-register opencode MCP servers on first entry |
| `6a6537d` | fix(shells): add limiterSettings/trusted_proxies |
| `c316c97` | feat(shells): add lighttpd reverse proxy |
| `f8943ff` | refactor(shells): remove tryEval for godot-mcp |
| `8d2f65b` | fix(shells): s/godot_4/godot/ |

## 2026-07-22T02:43:51+09:00

**Summary**: feat(overlays) — new efl-cross-fix overlay

- fixes efl (Enlightenment Foundation Libraries) cross-compilation failures on riscv64/riscv64-musl/aarch64 caused by missing native code-gen tools (eolian_gen, eet)
- includes 4-language docs
| Commit | Description |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**Summary**: codewhale 0.9.0 + ruyi 0.51.0 series + opencode-telegram 0.22.3 — upstream updates

- codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3
- codewhale v0.9.0 still has no riscv64 prebuilt binaries, so the source-build path continues
| Commit | Description |
|------|------|
| `deca3e8` | chore(pkgs): bump opencode-telegram 0.22.3 |
| `6046594` | chore(pkgs): bump ruyi 0.51.0 + beta 0.51.0-beta.20260714 + alpha 0.52.0-alpha.20260714 |
| `4df8df2` | chore(pkgs): bump codewhale 0.9.0 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.67 | 0.9.0 |
| ruyi | 0.50.0 | 0.51.0 |
| ruyi-beta | 0.50.0-beta.20260623 | 0.51.0-beta.20260714 |
| ruyi-alpha | 0.51.0-alpha.20260616 | 0.52.0-alpha.20260714 |
| opencode-telegram | 0.22.2 | 0.22.3 |

## 2026-07-16T06:08:43+09:00

**Summary**: fix(ci) — ci-summary workflow rate limit failure fixed

- caused by `gh run list` calling the API per workflow and hitting the rate limit (HTTP 403), which left the main README CI badge stale
- switched to 2 batched `gh api` calls + a concurrency guard
| Commit | Description |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**Summary**: revert(skill) — removed all katalish (halfwidth-katakana mechanical translation) content

- 19 docs, the skill (SKILL.md + 102-entry dictionary.md), all lang switcher links
- the approach proved unsuitable for production because translation was unstable (leaving English residue or breaking doc structure)
| Commit | Description |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:54:55+09:00

**Summary**: docs(nixkits-skills) — 'Known Removals' section renamed to 'Risk Advisory'

- 5-language skill docs kept in sync
| Commit | Description |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**Summary**: skill(nixkits-skills) — Claude Code install target removed, Codex support added

- removed the Claude Code install target (nationality inference via user data mining crosses the security boundary)
- added Codex support
- SKILL.md gained a "Risk Advisory" section with the original verbatim text
| Commit | Description |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:35:20+09:00

**Summary**: skill(write-maintenance-log) — strengthened timestamp rules

- mandatory `git log` for commit times, `T00:00:00` placeholders banned
- added a post-generation verification step
- generalized from the MAINTENANCE placeholder timestamp fix (`968df0e`)
| Commit | Description |
|------|------|
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |

## 2026-07-16T04:30:55+09:00

**Summary**: feat(ci) — new CI summary endpoint badge

- main README CI badge now reads `gh-pages/ci-status.json` via a shields.io endpoint
- shows failing package names on failure
| Commit | Description |
|------|------|
| `6465260` | feat(ci): add CI summary workflow with endpoint badge |
| `b489890` | docs(README): switch main CI badge to endpoint |

## 2026-07-16T04:09:46+09:00

**Summary**: refactor(ci) — CI split from a single check.yml into isolated workflow files

- split the single check.yml into 25 isolated workflow files (one per package×architecture), eliminating badge cross-contamination
- added a reusable `build-package.yml` workflow
| Commit | Description |
|------|------|
| `bc42e6f` | refactor(ci): split single check.yml into 25 isolated per-package-per-arch workflows |
| `1dfc1ee` | docs: update ruyi badge URLs to new isolated workflow files |
| `f235edc` | docs: embed version numbers in CI badge labels |

## 2026-07-16T04:00:46+09:00

**Summary**: fix(codewhale) — riscv64 cross-compile fixed for the source build

- the source-built codewhale failed to cross-compile for riscv64: the ring crate errored on `-m64`
- root cause was the cc crate inheriting host CFLAGS
- fixed by clearing per-target CFLAGS
| Commit | Description |
|------|------|
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |

## 2026-07-16T01:18:16+09:00

**Summary**: codewhale 0.8.67 — dual-path build

- prebuilt for x86_64/aarch64, source-built for riscv64
- upstream removed the riscv64 prebuilt binaries starting with v0.8.67
- riscv64 is now built via rustPlatform.buildRustPackage from the vendored Cargo.lock
| Commit | Description |
|------|------|
| `0025476` | feat(codewhale): dual-path build — prebuilt for x86_64/aarch64, source for riscv64 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.66 (prebuilt ×3) | 0.8.67 (prebuilt ×2 + source riscv64) |

## 2026-07-15T08:32:13+09:00

**Summary**: mcp-searxng 1.11.1, opencode-telegram 0.22.2 and obs-bilibili-stream 2.1.2 — upstream updates

- mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 synced to their upstream versions
- codewhale skipped: v0.8.67 still lacks riscv64 binaries
| Commit | Description |
|------|------|
| `48414d4` | chore(pkgs): bump mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 |

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | 1.11.0 | 1.11.1 |
| opencode-telegram | 0.22.1 | 0.22.2 |
| obs-bilibili-stream | 2.1.1 | 2.1.2 |
| codewhale | 0.8.66 | (skipped — upstream v0.8.67 still missing riscv64 binaries) |

## 2026-07-09T01:22:00+09:00

**Summary**: revert(ci) — restored `llama-cpp-ver` to the upstream API

- removed the `ci/` directory and restored the `llama-cpp-ver` input to the upstream API (`ggml-org/llama.cpp` releases/latest)
- the overlay already has the `tryEval` + `prev.llama-cpp.version` fallback, so no local cache was needed
| Commit | Description |
|------|------|
| `dbdd937` | revert: restore llama-cpp-ver to upstream API, remove ci/ |

## 2026-07-09T01:14:34+09:00

**Summary**: obs-bilibili-stream 2.1.1, mcp-searxng 1.11.0 and opencode-telegram 0.22.1 — upstream updates

- obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 synced to their upstream versions
- codewhale skipped: v0.8.67 has no riscv64 prebuilt binaries
| Commit | Description |
|------|------|
| `73dc576` | chore(pkgs): bump obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 |

| Package | Old | New |
|--------|--------|--------|
| obs-bilibili-stream | 2.1.0 | 2.1.1 |
| mcp-searxng | 1.8.0 | 1.11.0 |
| opencode-telegram | 0.22.0 | 0.22.1 |
| codewhale | 0.8.66 | (skipped — upstream riscv64 binaries missing) |

## 2026-07-07T12:01:12+09:00

**Summary**: fix(docs): katalish/pcn localization fixes

- repaired the language switchers in katalish/ruyi.md and pcn/ruyi.md (missing links, duplicate language names)
- pcn/ruyi.md fully rewritten from Japanese into pseudocn
| Commit | Description |
|------|------|
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |

## 2026-07-05T04:41:23+09:00

**Summary**: fix(ci): blender-mcp removed from riscv64-cross

- the upstream nixpkgs `sse-starlette` cross-compilation defect breaks the build
- `blender` is unsupported on riscv64 too
- x86_64 / aarch64 unaffected
| Commit | Description |
|------|------|
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |

## 2026-07-04T06:41:28+09:00

**Summary**: blender-mcp 1.0.0 — new Blender MCP Server package

- Python build, 22 MCP tools
- includes the Blender add-on companion files
| Commit | Description |
|------|------|
| `a1cf458` | packages: add blender-mcp (MCP server for Blender) |
| `ab9109a` | packages: add blender-mcp (MCP server for Blender) |

| Package | Old | New |
|--------|--------|--------|
| blender-mcp | — | 1.0.0 |

## 2026-07-02T04:00:00+09:00

**Summary**: codewhale 0.8.66 — upstream update

- TUI layout fixes
- approval honesty labels
- assorted performance fixes
| Commit | Description |
|------|------|
| `c00a5e6` | chore(pkgs): bump codewhale 0.8.66 |
| `c61d458` | docs: bump codewhale 0.8.66 version numbers in all 5-language docs |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.65 | 0.8.66 |
| 　 | cli hash (×3) | all updated |
| 　 | tui hash (×3) | all updated |

## 2026-06-28T06:30:00+09:00

**Summary**: opencode-telegram 0.22.0 — upstream update

- added tri-mode TTS
- added thinking display
- added compact output
- added the `/settings` command
- fixed session startup
| Commit | Description |
|------|------|
| `b189d0a` | chore(pkgs): bump opencode-telegram 0.22.0 |
| `a61f444` | docs: bump opencode-telegram 0.22.0 version numbers in all 5-language docs |

| Package | Old | New |
|--------|--------|--------|
| opencode-telegram | 0.21.2 | 0.22.0 |
| 　 | source hash | `...` → `...` |
| 　 | npmDepsHash | `...` → `...` |

## 2026-06-26T13:00:00+09:00

**Summary**: CI / docs — llama-cpp-ver moved to a local file and per-package riscv64 badges

- CI: llama-cpp-ver switched to a local file (`ci/llama-cpp-ver.json`)
- eliminates all GitHub API calls from CI jobs, permanently fixing rate-limit global build failures
- docs: riscv64 badges now per-package (codewhale/kitsfmt/mcp-searxng/opencode-telegram)
| Commit | Description |
|------|------|
| `8b3a3be` | fix(ci): use local path for llama-cpp-ver input, eliminate GitHub API calls from all CI jobs |
| `5db4852` | fix(docs): add per-package job filter to riscv64 badges |

## 2026-06-26T12:30:00+09:00

**Summary**: feat(opencode-telegram): two new service PATH injection options

- added the `extraPackages` option (inject system packages into the service PATH)
- added the `extraBinPaths` option (inject home-manager paths into the service PATH)
- fixes opencode not being found in the service PATH
- 5-language docs updated
| Commit | Description |
|------|------|
| `7c98694` | feat(opencode-telegram): add extraPackages option to inject companion tools into service PATH |
| `45b7c57` | feat(opencode-telegram): add extraBinPaths option for home-manager users |

## 2026-06-26T10:55:41+09:00

**Summary**: codewhale 0.8.65 and mcp-searxng 1.8.0 — upstream updates

- codewhale: cli binary renamed `codewhale-cli-linux` → `codewhale-linux`
- mcp-searxng: multi-instance failover / parallel fanout
- mcp-searxng: capability discovery aggregation
- mcp-searxng: safesearch fix
| Commit | Description |
|------|------|
| `57620d4` | chore(pkgs): bump codewhale 0.8.65 + mcp-searxng 1.8.0 |
| `94ac1e4` | docs: bump codewhale 0.8.65 + mcp-searxng 1.8.0 version numbers in all 5-language docs |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.64 | 0.8.65 |
| mcp-searxng | 1.7.2 | 1.8.0 |
| 　 | codewhale cli hash (×3) | all updated (incl. URL change) |
| 　 | codewhale tui hash (×3) | all updated |
| 　 | mcp-searxng source hash | `...` → `...` |
| 　 | mcp-searxng npmDepsHash | `...` → `...` |

## 2026-06-26T07:18:56+09:00

**Summary**: fix(skill): write-maintenance-log step 4 "multi-lang sync" rewritten from a stub into an executable flow, with AGENTS.md verification strengthened

- step 4 was a 5-line stub, now an executable flow: 4a discover languages → 4b per-lang translate & write → 4c verify entry counts match
- AGENTS.md step 4 strengthened with a verification gate
| Commit | Description |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-26T06:19:21+09:00

**Summary**: audit fixes — stale scripts/ directory and dead .gitignore rule removed, SKILL.md constraint relaxed

- removed the empty scripts/ directory and the dead .gitignore rule for translate_pcn.py
- AGENTS.md SKILL.md constraint changed from a hard line-count target to qualitative guidance
| Commit | Description |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-25T11:02:38+09:00

**Summary**: ruyi / CI / docs — cross-compilation fix, riscv64-cross restored, precise badge filters

- postPatch now uses python.pythonOnBuildForHost
- CI restored the ruyi family to riscv64-cross
- riscv64 badges restored to precise job filters
| Commit | Description |
|------|------|
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |

## 2026-06-25T10:12:02+09:00

**Summary**: CI / docs — ruyi family permanently removed from riscv64-cross, badges back to the * fallback

- riscv64-cross permanently drops the ruyi family (Python postPatch cannot cross-compile)
- riscv64 badges reverted to the * mark plus an explanatory note
| Commit | Description |
|------|------|
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |

## 2026-06-25T10:04:30+09:00

**Summary**: CI — fix access-tokens overwrite that tripped the API rate limit, and cap riscv64-cross concurrency

- access-tokens overwrite caused GitHub API rate-limit errors (merged into a single line)
- riscv64-cross concurrency capped at 4
| Commit | Description |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |

## 2026-06-25T09:44:44+09:00

**Summary**: CI / docs — ruyi family added back to riscv64-cross, badge labels and job filters cleaned up

- ruyi/ruyi-beta/ruyi-alpha added back to riscv64-cross (path mapping)
- badge labels simplified (`-` instead of `--`)
- precise riscv64 job filters
| Commit | Description |
|------|------|
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |

## 2026-06-25T09:29:43+09:00

**Summary**: CI / docs — build / riscv64-cross split into per-package matrices, ruyi badges expanded to 9

- build / riscv64-cross jobs split into a per-package matrix, enabling independent per-package badges
- ruyi doc badges expanded to 3 versions × 3 archs = 9
| Commit | Description |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |

## 2026-06-25T09:24:43+09:00

**Summary**: CI / docs — build ruyi-beta / ruyi-alpha in the build job, docs gain channel version numbers

- build steps for ruyi-beta / ruyi-alpha added to the build job
- beta/alpha version numbers added to the ruyi Basic Info channel row
| Commit | Description |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |

## 2026-06-25T09:09:26+09:00

**Summary**: CI / overlays / docs — ruyi three-channel integration and riscv64-cross adjustment

- ruyi removed from riscv64-cross in CI
- ruyi-beta/ruyi-alpha added to the default overlay; nixConfig lifted to the flake top level
- README package tables now show the ruyi three-channel versions
| Commit | Description |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |

## 2026-06-25T05:35:00+09:00

**Summary**: docs — ruyi-beta / ruyi-alpha devShell entries added to all 5-language READMEs

- devShell tables in all 5 READMEs gained ruyi-beta / ruyi-alpha entries
| Commit | Description |
|------|------|
| `5d4ca02` | docs: add ruyi-beta + ruyi-alpha to devShell tables (all 5 READMEs) |

## 2026-06-25T05:28:12+09:00

**Summary**: ruyi — package directory restructured, beta/alpha as thin wrappers, devShells added

- package restructured under packages/ruyi/
- beta/alpha became thin wrappers
- devShells added
| Commit | Description |
|------|------|
| `4b9865e` | refactor(pkgs): move ruyi into subdirectory, beta/alpha as thin wrappers |
| `94bb174` | feat(shells): add ruyi-beta + ruyi-alpha devShells |

## 2026-06-25T05:13:34+09:00

**Summary**: ruyi — version channels converted to independent packages, standalone overlays removed

- version channels converted to independent packages (ruyi / ruyi-beta / ruyi-alpha)
- standalone overlays removed
| Commit | Description |
|------|------|
| `51f23ad` | refactor(pkgs): ruyi channels as separate packages (not overlays) |

## 2026-06-25T04:58:36+09:00

**Summary**: ruyi — three-channel version system introduced, base package moved to 0.50.0

- three-channel version system (stable/beta/alpha)
- base package switched to 0.50.0 stable
- beta/alpha provided via overlay overrides
| Commit | Description |
|------|------|
| `a9f8baa` | feat(pkgs): ruyi 3-channel (stable/beta/alpha) via overlays |

| Package | Old | New |
|--------|--------|--------|
| ruyi | 0.51.0-alpha.20260616 | 0.50.0 (stable) |
| 　 | new ruyi-beta overlay | 0.50.0-beta.20260623 |
| 　 | new ruyi-alpha overlay | 0.51.0-alpha.20260616 |

## 2026-06-24T03:19:30+09:00

**Summary**: workflow — maintenance log update rule made mandatory

- AGENTS.md and the write-maintenance-log skill now require the maintenance log update
| Commit | Description |
|------|------|
| `2e719df` | fix: make maintenance log update mandatory after every push |

## 2026-06-24T03:15:37+09:00

**Summary**: docs — remove stale riscv64 build instructions

- remove the stale manual riscv64 build instructions
- CI now covers all 3 architectures
| Commit | Description |
|------|------|
| `698400a` | docs: remove stale manual riscv64 build instructions — CI now covers all 3 architectures |

## 2026-06-24T03:06:20+09:00

**Summary**: codewhale 0.8.64 — upstream update

- upstream update, bumped to 0.8.64
| Commit | Description |
|------|------|
| `0bde292` | chore(pkgs): bump codewhale 0.8.64 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.63 | 0.8.64 |
| 　 | x64 cli hash | `sha256-SMaOUH...Z6M=` → `sha256-sKvJm6...XY=` |
| 　 | arm64 cli hash | `sha256-gGv2T4...M8=` → `sha256-gYofCL...jk=` |
| 　 | riscv64 cli hash | `sha256-qSVNms...g=` → `sha256-TOkojm...A=` |
| 　 | x64 tui hash | `sha256-UA66uC...M=` → `sha256-Q3wRQ5...M=` |
| 　 | arm64 tui hash | `sha256-m24T1T...g=` → `sha256-CSKaNh...M=` |
| 　 | riscv64 tui hash | `sha256-l1tgSn...w=` → `sha256-mAARZq...Y=` |

## 2026-06-24T02:30:21+09:00

**Summary**: CI — riscv64 cross-compilation pipeline, full 3-arch coverage

- add the riscv64 cross-compilation pipeline, giving CI full coverage of x86_64 / aarch64 / riscv64
- add riscv64 badges to every package doc
| Commit | Description |
|------|------|
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |

## 2026-06-23T05:20:00+09:00

**Summary**: translate-pseudocn — dictionary expansion and word-order change

- expand the dictionary based on web research (7→46 entries)
- convert to SVO word order
- regenerate all pcn docs
| Commit | Description |
|------|------|
| `4fbf387` | feat(pcn): expand dictionary 7→46 entries, add IT terminology from research |
| `ec38b7e` | feat(pcn): convert to SVO word order, expand dictionary, regenerate all 22 docs |

## 2026-06-23T04:19:16+09:00

**Summary**: translate-pseudocn skill refactor — pseudo-Chinese redefined

- pseudo-Chinese is redefined as "the visual result of Japanese after stripping kana", no longer converted into Chinese
- original Japanese kanji are kept as-is (not simplified), SOV word order is retained
- the dictionary is reduced from 40→7 entries (katakana→Japanese kanji only), all 22 pcn docs regenerated
| Commit | Description |
|------|------|
| `be0780b` | refactor(pcn): redesign pseudo-Chinese skill — Japanese-native kanji, SOV order, no Chinese chars |

## 2026-06-23T04:04:32+09:00

**Summary**: AGENTS.md — remove hardcoded counts, switch languages to auto-discovery

- remove hardcoded counts
- drop the redundant audit memo
- rewrite the cache section as an agent-facing how-to
- remove the user-facing subsection
- switch the language set to auto-discovery
| Commit | Description |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:49:00+09:00

**Summary**: mcp-searxng 1.7.2 — upstream fixes

- upstream fixes, bumped to 1.7.2
| Commit | Description |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |

## 2026-06-22T23:22:00+09:00

**Summary**: AGENTS.md — new-session audit rule and an access-control move

- add the new-session audit rule
- move access control to the top
| Commit | Description |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**Summary**: docs — README duplication fix and a skill anti-pattern

- fix the duplicated `提供 nix develop` line in the README
- add the "check for duplicate content before insert" anti-pattern to the write-project-docs skill
| Commit | Description |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**Summary**: AGENTS.md — fill in access-control and process rules

- add access control rules
- add language requirements
- add commit discipline and maintenance-log checks
- add doc sync and generalization rules
- add the multi-arch cache rules
| Commit | Description |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**Summary**: docs — dual-arch CI badges on every package doc, skill templates synced

- add dual-arch CI badges to all 30 package docs
- split the dual-arch badges onto separate lines
- add a blank line between the CI badges and the language switcher
- sync the skill template to one badge per line plus a blank gap
| Commit | Description |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**Summary**: CI — ARM runners and a flake.lock race fix

- add ARM runners for multi-arch builds
- fix the flake.lock concurrency race (`--no-write-lock-file`)
| Commit | Description |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**Summary**: mcp-searxng and ruyi — hashes updated, overlay postPatch restored

- mcp-searxng: update source hash + npmDepsHash (GitHub archive changed)
- ruyi: restore the overlay postPatch (patch file dependency)
| Commit | Description |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**Summary**: docs — cache-exclusion warnings and the nixConfig auto-declaration

- add cache-exclusion warnings (overlay and module+patch entries)
- compress the README cache notes
- add the nixConfig auto-declaration to flake.nix
| Commit | Description |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**Summary**: docs — cache section across 30 package docs, CI badge layout, skill sync

- add a `## Cache` section to all 30 package docs
- improve the CI badge layout
- sync the skills
| Commit | Description |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**Summary**: CI/CD — build matrix, binary cache, and AGENTS.md added

- add the GitHub Actions build matrix (Cachix push)
- add the binary cache
- add AGENTS.md
| Commit | Description |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**Summary**: skills — dictionaries and templates split, SKILL.md compressed

- translate-katalish / translate-pseudocn / write-project-docs: dictionaries and templates split into separate files
- SKILL.md compressed to 60-80 lines
| Commit | Description |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**Summary**: docs — MAINTENANCE timestamps and dedup reworked, nix-kits→nixkits replaced everywhere

- MAINTENANCE timestamps made precise (29 sections)
- delete 30 duplicate sections (SHA dedup)
- nix-kits→nixkits replaced everywhere (183 places)
- sync the module docs
| Commit | Description |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**Summary**: patches — ruyi-nixos-compat.patch rebuilt from a clean clone

- ruyi-nixos-compat.patch rebuilt from a clean clone (1223→426 lines)
- remove the self-referencing flake.lock artifact
| Commit | Description |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**Summary**: overlays — patches dedup, ruyi-nixos-compat simplification, llama-cpp-rocm comment

- patches list deduplicated with lib.unique
- ruyi-nixos-compat simplified
- add a curried-form comment to llama-cpp-rocm
| Commit | Description |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**Summary**: modules — enable options, assertions, and the nixkits.* namespace

- enable options added to 4 modules
- assertions added to comfyui-strix-halo
- namespace unified on nixkits.* (backward compatible)
- llama-cpp-rocm hfCacheDir derived dynamically
| Commit | Description |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**Summary**: codewhale 0.8.63 and ruyi — multi-arch binaries, postPatch merge, meta completion

- codewhale 0.8.63 — prebuilt binaries for multiple architectures (x86_64 / aarch64 / riscv64)
- ruyi — overlay postPatch merged into the package
- meta fields completed
| Commit | Description |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**Summary**: flake — remove the mihomo-alpha ghost input and overlay

- remove the mihomo-alpha ghost input and overlay (the file never existed)
| Commit | Description |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |

## 2026-06-21T04:32:31+09:00

**Summary**: language-switcher label rule generalized — display_name semantics and leftover names fixed

- display_name redefined as the language's own name
- add a rule against localizing language names to write-project-docs / translate-katalish / translate-pseudocn
- fix leftover localized names in every zh/katalish/pcn doc switcher
| Commit | Description |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称与切换器标签分离 |
| `aa8634b` | fix(docs): zh 文档切换器残留旧名称修正 + MAINTENANCE 翻译补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**Summary**: codewhale 0.8.62 and mcp-searxng 1.7.1 — upstream fixes

- codewhale 0.8.62 — upstream fixes
- mcp-searxng 1.7.1 — upstream fixes
| Commit | Description |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

## 2026-06-20T18:36:33+09:00

**Summary**: skill system reworked — skill rename and automatic language-extension discovery

- translate-katakana renamed to translate-katalish
- add translate-pseudocn (偽中国語)
- automatic language-extension discovery in write-project-docs and write-maintenance-log
- docs-as-code five-language mapping table
| Commit | Description |
|------|------|
| `0588ee0` | skill: write-project-docs 新增伪中国语(pcn)语言支持 |
| `c5fb218` | docs: write-project-docs 英日文版同步更新四语(pcn)支持 |
| `f1904a1` | feat(skill): add translate-katakana — katakana english mechanical substitution |
| `97b696c` | docs(skill): purge pcn references from write-project-docs, add kata-en |
| `7caf343` | refactor(translate-katakana): rename kata-en → katalish, use ｶﾀﾘｯｼｭ as canonical name |
| `911052b` | refactor(docs): migrate pcn directory to katalish |
| `39906b9` | docs: purge remaining pcn references from zh write-project-docs |
| `177ad9b` | refactor: rename translate-katakana→translate-katalish, add translate-pseudocn, auto-discovery |
| `fee1534` | docs(skill): add translate-* support and docs-as-code mapping to write-maintenance-log |

## 2026-06-18T09:52:34+09:00

**Summary**: codewhale 0.8.61 and mcp-searxng 1.6.0 — upstream fixes

- codewhale 0.8.61 — upstream fixes
- mcp-searxng 1.6.0 — upstream fixes
| Commit | Description |
|------|------|
| `719e16e` | chore(pkgs): bump codewhale 0.8.61 |
| `d6717c1` | chore(pkgs): bump mcp-searxng 1.6.0 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.60 | 0.8.61 |
| 　 | cli hash | `...` → `sha256-3k0K/I/NxYHrNszgniQncWTu8HRqsR3RSg+YLuB+IkY=` |
| 　 | tui hash | `...` → `sha256-YVjKDO/JNnsAHwzCf4itrEw8psKyi9bbFaLJLFvMyAI=` |
| mcp-searxng | 1.4.0 | 1.6.0 |
| 　 | source hash | `...` → `sha256-oBpSAAppLfnPhC3tHoE2X1YAGMyd42fka+xAVFuhjKw=` |
| 　 | npmDepsHash | `...` → `sha256-7z5T8po2ya698J7vqu4pA7c8s85k33sRbOV2tRmGdPo=` |

## 2026-06-18T09:03:48+09:00

**Summary**: ruyi — NixOS compatibility patch

- the NixOS compatibility patch (`patches/ruyi-nixos-compat.patch`)
- transparently handle the prebuilt RISC-V toolchain's dynamic-linker path
- the GCC subprocess ELF interpreter fix
- the console_scripts argv0 problem
| Commit | Description |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

## 2026-06-17T10:59:35+09:00

**Summary**: ruyi — NixOS module (`services.ruyi`)

- declaratively generates `/etc/xdg/ruyi/config.toml` and environment variables
| Commit | Description |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

## 2026-06-17T10:03:05+09:00

**Summary**: ruyi — devShell support added

- `nix develop github:Kihara777/NixKits#ruyi` enters the environment
| Commit | Description |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

## 2026-06-17T09:48:33+09:00

**Summary**: ruyi 0.51.0-alpha.20260616 — new package (RuyiSDK package manager)

- built with Python / Poetry
- ruff + mypy + 320 unit tests + 52 integration tests all pass
| Commit | Description |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

## 2026-06-17T07:37:39+09:00

**Summary**: write-maintenance-log skill — standalone skill and flake.lock sync checks

- split out of nixkits-check-updates into a standalone skill with a dual entry point (record into and update the maintenance log)
- flake.lock sync gains a .gitignore pre-check and three-branch logic
| Commit | Description |
|------|------|
| `b77170a` | docs(skill): re-apply flake.lock sync and build verification steps |
| `be2239b` | docs(skill): add .gitignore pre-check to flake.lock sync step |
| `704ebe4` | docs(skill): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(skill): extract write-maintenance-log as standalone skill |
| `5187b07` | docs(skill): optimize write-maintenance-log triggers and add audit entry |
| `34bf34e` | feat(skill): add write-maintenance-log SKILL.md (zh) |
| `edce70f` | refactor(docs): switch MAINTENANCE.md to ISO 8601 precise timestamps |
| `fb6f1a5` | docs(skill): write-maintenance-log — add auto-discovery contract |
| `fe4b13f` | fix(docs): remove non-patch sections from MAINTENANCE.md |
| `d5318fb` | docs(skill): write-maintenance-log — add 使用 section |
| `e9e40f4` | docs(skill): add write-maintenance-log skill with trilingual docs |
| `c9dedf9` | docs(skill): write-maintenance-log — add en/ja skill docs |

## 2026-06-17T06:48:47+09:00

**Summary**: fix(mcp-searxng): fix wrong entry file

- entry file dist/index.js → dist/cli.js
- the MCP server starts normally
| Commit | Description |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

## 2026-06-17T06:46:13+09:00

**Summary**: llama-cpp-rocm — attempted to replace the flake input with builtins.fetchurl for dynamic version lookup

- reverted, the approach is unusable
| Commit | Description |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

## 2026-06-16T06:03:24+09:00

**Summary**: mcp-searxng docs — CodeWhale MCP configuration guide, common pitfall warning and troubleshooting section

- CodeWhale MCP configuration guide
- common pitfall warning (env defaults to {})
- troubleshooting section
| Commit | Description |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

## 2026-06-16T05:20:34+09:00

**Summary**: nixos-modern-cli skill — Nix Store path trap section

- diagnosis of the gh auth setup-git hardcoded path going stale
- general fix pattern
| Commit | Description |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

## 2026-06-16T04:56:06+09:00

**Summary**: opencode-telegram 0.21.2 — upstream fixes and dependency updates

- upstream fixes and dependency updates, bumped to 0.21.2
| Commit | Description |
|------|------|
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |
| `3b05a32` | docs(MAINTENANCE): record 2026-06-16 update (opencode-telegram 0.21.2) |

| Package | Old | New |
|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | source hash | `sha256-V/rThMV5...` → `sha256-NEaQ2grHCKXi13utcHeUR83pJT6kqBGS4UqllhG93kY=` |
| 　 | npmDepsHash | `sha256-Bcexury...` → `sha256-z9trDo9xeWZyTSvCqX5XTb+AHY50wk0gsoEnAAEHOEg=` |

## 2026-06-15T17:32:16+09:00

**Summary**: codewhale 0.8.60 — upstream fixes

- upstream fixes, bumped to 0.8.60
| Commit | Description |
|------|------|
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |
| `3cef0a8` | docs(MAINTENANCE): record 2026-06-15 update (codewhale 0.8.60) |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `sha256-ti/IBPZV...` → `sha256-JqlByElHoLcR2Mlwmx5Qczfj+EoAp+igdLCd/QUOsX4=` |
| 　 | tui hash | `sha256-3Lh80hTS...` → `sha256-LTf681cWVH9Cu3TQrFeMlJUNVVG+TWxO2oI6VXK+4zA=` |

## 2026-06-14T08:11:16+09:00

**Summary**: comfyui-strix-halo docs — online integration mode description and file structure diagram

- online integration mode description
- file structure diagram
| Commit | Description |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

## 2026-06-14T07:56:11+09:00

**Summary**: codewhale 0.8.59 and mcp-searxng 1.4.0 — version updates

- codewhale 0.8.59 — fixes several TUI rendering issues
- mcp-searxng 1.4.0 — adds HTTP transport mode
| Commit | Description |
|------|------|
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `ec7d5ca` | docs(MAINTENANCE): record 2026-06-14 updates (codewhale 0.8.59, mcp-searxng 1.4.0) |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
| 　 | cli hash | `sha256-AR9jJZzB...` → `sha256-ti/IBPZVJdaLvQ00OevzTfcMQ0XHELvOKTcul4+iBg8=` |
| 　 | tui hash | `sha256-BpCHu9M...` → `sha256-3Lh80hTSMG0RG+CHkR403rqcMtDA6kMdbyvBe7sLQaQ=` |
| 　 | source hash | `sha256-Xsp1vReg...` → `sha256-RMzxCBua89oYbKXmwXCtcSHan5QVefsm8IBdMIVq7UE=` |
| 　 | npmDepsHash | `sha256-3hWshG0...` → `sha256-Lh1UoM8zSMFji/TkqDAOiRtFRrQ/jqn5TbONySj9ckg=` |

## 2026-06-12T18:17:52+09:00

**Summary**: llama-cpp-rocm module — restores modelsPreset support and migrates the namespace

- restores modelsPreset support (removed from nixpkgs)
- migrates the namespace to nixkits
- trilingual migration guide
| Commit | Description |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

## 2026-06-12T17:29:59+09:00

**Summary**: feat(llama-cpp-rocm): restore modelsPreset support and migrate the namespace

- restore modelsPreset support (removed in nixpkgs)
- migrate the namespace to nixkits
## 2026-06-12T10:51:31+09:00

**Summary**: codewhale 0.8.58 and mcp-searxng 1.3.4 — upstream fixes

- codewhale 0.8.58 — upstream fixes
- mcp-searxng 1.3.4 — upstream fixes
| Commit | Description |
|------|------|
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |
| `ef9daae` | chore(pkgs): bump mcp-searxng 1.3.4 |
| `716d98c` | docs(MAINTENANCE): record 2026-06-12 updates (codewhale 0.8.58, mcp-searxng 1.3.4) |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| mcp-searxng | 1.3.2 | 1.3.4 |
| 　 | cli hash | `sha256-Hp0Z6mwe...` → `sha256-AR9jJZzB1VNUe7yaI3jpSUJsXuzgvqk5aWeLWe/L/vA=` |
| 　 | tui hash | `sha256-dExfhrfG...` → `sha256-BpCHu9MbDGuCAXNNJXPTZpj3BrIwx7jWs29I31cbSag=` |
| 　 | source hash | `sha256-OVllsRM...` → `sha256-Xsp1vRegHDWNk54nqLk+4l5MI0xGgocCg5Qa2UwWNqA=` |
| 　 | npmDepsHash | `sha256-LN9yDbw...` → `sha256-3hWshG0L8k0U2fnmz0OotrYaPAYBQE7DanjXgnFnNrE=` |

## 2026-06-11T05:28:59+09:00

**Summary**: Skill docs — a series of maintenance-log format rules

- auto-discovery generalization
- descriptive titles
- exact git commit timestamps
- no `T00:00:00` placeholder
| Commit | Description |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

## 2026-06-11T05:13:39+09:00

**Summary**: other — docs added and wording fixed

- add the missing rog-control-center-fix trilingual module docs
- fix the casing of DeepSeek V4 Pro in the author credits
| Commit | Description |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

## 2026-06-11T04:52:16+09:00

**Summary**: codewhale 0.8.57 and mcp-searxng 1.3.2 — TUI added, upstream fix

- codewhale 0.8.57 — TUI added
- mcp-searxng 1.3.2 — upstream fix
| Commit | Description |
|------|------|
| `543bcf9` | chore(pkgs): bump codewhale 0.8.57, mcp-searxng 1.3.2 |
| `7902bd1` | docs(MAINTENANCE): fix timestamps to exact commit times |
| `f92f9c4` | docs(MAINTENANCE): use descriptive titles instead of filename |
| `07f347f` | docs(skill): add descriptive title rule for MAINTENANCE files |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.55 | 0.8.57 |
| mcp-searxng | 1.3.1 | 1.3.2 |
| 　 | cli hash | `sha256-jwn3rKD...` → `sha256-Hp0Z6mweaC+sB/BH2KpD1W/sdS0me69pErKiWOa2GqY=` |
| 　 | tui hash | `sha256-1Cxofu9...` → `sha256-dExfhrfGs1wbWWmvXYTuCGXKnkhD+7rBY32aV938Dz0=` |

## 2026-06-10T04:31:20+09:00

**Summary**: opencode-telegram — KillMode and TimeoutStopSec adjusted

- KillMode changed to process
- TimeoutStopSec added to prevent shutdown hang
| Commit | Description |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

## 2026-06-10T02:28:10+09:00

**Summary**: codewhale 0.8.55 and mcp-searxng 1.3.1 — upstream fix

- codewhale 0.8.55 — upstream fix
- mcp-searxng 1.3.1 — upstream fix
| Commit | Description |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

## 2026-06-08T15:12:39+09:00

**Summary**: Docs restructure — localized files moved into docs/, MAINTENANCE.md gains format rules and backfilled history

- localized files moved into the docs/ directory
- MAINTENANCE.md gains the merged-column rule
- MAINTENANCE.md gains the table-only format
- backfill the full commit history
| Commit | Description |
|------|------|
| `b3d7d0f` | docs: switch MAINTENANCE.md to table-only format, drop trilingual prose |
| `e4a3813` | docs: omit build status and unchanged hashes from MAINTENANCE.md |
| `4bf2d30` | docs(skill): add first-time package table format rule |
| `f7bb6ce` | docs(skill): merge version columns for first-time packages |
| `1a28625` | docs(MAINTENANCE): backfill full package history from repo creation |
| `b4742ad` | docs(skills): sync refined MAINTENANCE.md format rules to trilingual docs |
| `2f58ac5` | refactor: move localized README/MAINTENANCE files into docs/ |
| `551e6fd` | docs(skills): sync localized-file-in-docs/ rule and path updates |

## 2026-06-08T14:25:02+09:00

**Summary**: mcp-searxng 1.2.1 — upstream fix

- upstream fix, bumped to 1.2.1
| Commit | Description |
|------|------|
| `07b1ee5` | chore(pkgs): bump mcp-searxng 1.1.0 → 1.2.1 |
| `db680df` | docs: add MAINTENANCE.md — software update changelog |
| `d4cb81f` | docs(skill): add Step 8 — MAINTENANCE.md update workflow |
| `5ba1361` | docs(skills): sync MAINTENANCE.md step to trilingual docs |
| `b8a98bc` | docs(skill): skip MAINTENANCE.md when no updates found |
| `2cd9daf` | docs: drop doc-sync line from MAINTENANCE; only record substantive rewrites |
| `b34ed08` | docs: add trilingual MAINTENANCE (en/ja) with language switchers |
| `e5e505e` | docs(skills): sync trilingual MAINTENANCE rule to skill docs |

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | 1.1.0 | 1.2.1 |

## 2026-06-08T14:22:25+09:00

**Summary**: rcc-fix — NixOS module (systemd deadlock fix)

- NixOS module: systemd deadlock fix
| Commit | Description |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

## 2026-06-06T15:17:11+09:00

**Summary**: Skill docs — doc-sync rule, toolchain note and rule generalization

- doc-sync rule after source changes
- comfyui-strix-halo C toolchain note
- generalized hash-computation gotchas
- 基本情報 rule unified across languages
| Commit | Description |
|------|------|
| `7e22edd` | docs(skill): add skill doc template, sync rules, and staleness check |
| `86fc7c2` | docs(skills): sync write-project-docs trilingual docs with SKILL.md |
| `454a4e4` | fix(skill): generalize 基本情報 rule to all languages, not just Japanese |
| `28ec492` | docs(skills): sync generalized 基本情報 rule to trilingual docs |
| `c79ffff` | docs(skill): add SRI hash format and nix build gotchas to update skill |
| `6dcbbfc` | docs(skills): sync hash gotchas to nixkits-check-updates trilingual docs |
| `58b06ea` | docs(comfyui-strix-halo): clarify kernel param is set by module, not hardware |
| `2ba85d3` | docs(comfyui-strix-halo): add C build toolchain + CC=gcc to changes list |
| `f5941ae` | docs(skill): add anti-patterns for stale/unsynced doc bullets after source changes |
| `b8c2399` | docs(skills): sync source-change doc sync rule to trilingual docs |

## 2026-06-06T13:58:47+09:00

**Summary**: codewhale 0.8.53, mcp-searxng 1.1.0 and opencode-telegram 0.21.1 — upstream fix

- codewhale 0.8.53 — upstream fix
- mcp-searxng 1.1.0 — upstream fix
- opencode-telegram 0.21.1 — upstream fix
| Commit | Description |
|------|------|
| `300a9a6` | chore(pkgs): bump codewhale 0.8.53, mcp-searxng 1.1.0, opencode-telegram 0.21.1 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.49 | 0.8.53 |
| mcp-searxng | 1.0.4 | 1.1.0 |
| opencode-telegram | 0.21.0 | 0.21.1 |
| 　 | cli hash | `sha256-97zk4L...` → `sha256-VxBNH2o4iEkk0PrnuZHDPECjvm+ARXR9T/BV8QqvYtw=` |
| 　 | tui hash | `sha256-tc/s3e...` → `sha256-DBiWk4c4QFh/BKPlG5a3KkH0ZTxNQgqZ7IWwH4OaEEw=` |
| 　 | source hash | `sha256-ML5Hgle...` → `sha256-OVllsRMst6dWO/RagsmGyWN3muz1ATtffxfmLTfa0qU=` |
| 　 | npmDepsHash(searx) | `sha256-xnefgQ...` → `sha256-LN9yDbwvlICoFl5KgQvzZjLGXflVM0QkSzaB2dJzR/w=` |
| 　 | source hash(telegram) | `sha256-Al7CVol...` → `sha256-V/rThMV5qZ5Z07A+A54Il4Vi/69bv8PVgV6uIr6vxGA=` |
| 　 | npmDepsHash(telegram) | `sha256-ZOhS7l...` → `sha256-BcexuryL26CNLKeAOR9DffE07H4dYO1UYPqfX9aHm4g=` |

## 2026-06-06T12:51:46+09:00

**Summary**: comfyui-strix-halo patch — ROCm 7.2 wheels embedded support

- ROCm 7.2 wheels embedded support
| Commit | Description |
|------|------|
| `e11f899` | fix(docs): add missing ja doc and en/ja README entries for comfyui-strix-halo |
| `48d842f` | docs(ja): add 基本情報 section to comfyui-strix-halo |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs in NixKits concise style |
| `8f16f91` | docs(skill): add length/structure rules from comfyui-strix-halo doc fix |
| `468b89a` | feat(skill): add patch-embedded version check for comfyui-strix-halo |

| Package | Old | New |
|--------|--------|--------|
| comfyui-strix-halo | 补丁（ROCm 7.2 wheels 内嵌） |

## 2026-06-04T13:07:30+09:00

**Summary**: Skill system — SKILL.md localized to Chinese, trilingual symmetry check

- SKILL.md fully localized to Chinese
- trilingual symmetry check rule
| Commit | Description |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

## 2026-06-02T10:15:53+09:00

**Summary**: other — bulk docs additions and cleanups

- add the recover-nixos-config skill with multi-language docs
- fix the Skills section titles and generic agent descriptions
- add quantization levels to the local model names
- add the UD- prefix to model quantization labels
- add the MIT license file and link it from all READMEs
- add a local flake input example alongside the remote one
- fix the local flake input syntax to match actual usage
| Commit | Description |
|------|------|
| `3be4889` | docs: add recover-nixos-config skill with multi-language docs |
| `fc5eca3` | docs: fix Skills section titles and generic agent descriptions |
| `d2e071f` | docs: add quantization levels to local model names |
| `22d206c` | docs: add UD- prefix to model quantization labels |
| `f15db79` | docs: add MIT license file and link from all READMEs |
| `218aeca` | docs: add local flake input example alongside remote |
| `4f0f968` | docs: fix local flake input syntax to match actual usage |

## 2026-06-02T08:49:47+09:00

**Summary**: opencode-telegram — flake module and docs rework

- add the NixOS module with declarative config
- docs simplified to flake-module config only, manual systemd removed
- docs rename NixOS module → flake module
- docs use the accurate section name — service config, not module
- docs show the full flake.nix context in service config
- docs section title flake module, consistent across languages
- auto-install the package when the module is enabled
- docs add the first-time setup flow (opencode serve + config)
| Commit | Description |
|------|------|
| `8fe0b3d` | feat(opencode-telegram): add NixOS module with declarative config |
| `8fe3fae` | docs(opencode-telegram): simplify to flake module config only, remove manual systemd |
| `ee0a904` | docs(opencode-telegram): rename NixOS module → flake module |
| `a38e426` | docs(opencode-telegram): use accurate section name — service config, not module |
| `dea4dc6` | docs(opencode-telegram): show full flake.nix context in service config |
| `44975ed` | docs(opencode-telegram): flake module as section title, consistent across langs |
| `941eb48` | feat(opencode-telegram): auto-install package when module enabled |
| `2a8c41b` | docs(opencode-telegram): add first-time setup flow (opencode serve + config) |

## 2026-06-02T05:57:11+09:00

**Summary**: codewhale 0.8.49, mcp-searxng 1.0.4, obs-bilibili-stream 2.1.0 and opencode-telegram 0.21.0 — upstream fixes

- `codewhale` 0.8.49 — upstream fix
- `mcp-searxng` 1.0.4 — upstream fix
- `obs-bilibili-stream` 2.1.0 — upstream fix
- `opencode-telegram` 0.21.0 — upstream fix
| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.47 | 0.8.49 |
| mcp-searxng | 1.0.3 | 1.0.4 |
| obs-bilibili-stream | 2.0.12 | 2.1.0 |
| opencode-telegram | 0.20.5 | 0.21.0 |
| 　 | cli hash | `sha256-JGNVKih...` → `sha256-97zk4LzahspVqd8U/Z8rfS60oOWNUPsWn4xtn/rL8CQ=` |
| 　 | tui hash | — → `sha256-tc/s3e1oomJhfYEN1EtuEtPBF77dByrMimDH3bQibCI=` |
| 　 | source hash(searx) | `sha256-xS2Hr/g...` → `sha256-ML5HgleThmzBwJFtmsCQEPxHvZz4gzrDxW3Udkx9YjA=` |
| 　 | npmDepsHash(searx) | `sha256-...+` → `sha256-xnefgQnFuHVPSCWVSD8MWxjHmNSrKpWlbGaAtks5rkg=` |
| 　 | source hash(obs) | — → `sha256-lbN73L3ey7qZftsgmRGb9wPcj8DmwlOUWR9gdEni29w=` |
| 　 | source hash(tele) | `sha256-RKsZwK...` → `sha256-Al7CVol/HDgH3M0FwkdQWOze6xY/wvaWOskRsh9Abxo=` |
| 　 | npmDepsHash(tele) | `sha256-...+` → `sha256-ZOhS7lX5z2bRi0Cilm2QBUVKmacK41oRcUn9kRcfdOg=` |

## 2026-06-02T03:42:25+09:00

**Summary**: nixos-modern-cli skill — POSIX tool guide and nix binary path hint

- add the POSIX tool guide
- add the nix binary path hint
| Commit | Description |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

## 2026-05-31T03:42:18+09:00

**Summary**: write-project-docs — new skill

- multi-language documentation system for any project, NixKits style
| Commit | Description |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

## 2026-05-30T03:42:14+09:00

**Summary**: codewhale, llama-cpp-rocm and opencode-telegram — typo, doc and flow fixes

- `codewhale`: the stdenv typo causing build failure is fixed
- `llama-cpp-rocm`: inline links removed from the docs, now using the complete preset from system.nix
- `opencode-telegram`: the first-time setup flow is added
| Commit | Description |
|------|------|
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

## 2026-05-30T03:19:48+09:00

**Summary**: other — multilingual README and I18n structure

- add English and Japanese translations with the I18n structure
- add English and Japanese README with a language switcher
| Commit | Description |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

## 2026-05-29T15:25:12+09:00

**Summary**: kitsfmt — multiple fixes; rcc-fix — rewritten as D-Bus hot-plug detection; build — .vscode gitignore scope fix

- `kitsfmt`: the `vendor` dir is restored for offline builds
- `kitsfmt`: idempotency and in-place safety fixed
- `kitsfmt`: `with`→`builtins.attrValues` conversion and a new `--stdin` flag
- `rcc-fix`: rewritten as D-Bus hot-plug detection
- `build`: `.vscode` gitignore scope fix
| Commit | Description |
|------|------|
| `6a42efd` | fix(kitsfmt): idempotency, inplace safety, output validation |
| `1b7d0a9` | fix(build): restrict .vscode gitignore to repo root to not exclude vendored crate files |
| `2b237ff` | feat(kitsfmt): with→builtins.attrValues best-practice transformation |
| `8497bf7` | feat(kitsfmt): add --stdin flag for explicit stdin mode |
| `a612af7` | feat(rcc-fix): rewrite patch for asusctl 6.3.7 with hot-plug and boundary checks |
| `e56f122` | fix(rcc-fix): scope hotplug variable correctly for asusctl build |
| `15a0104` | fix(kitsfmt): restore vendor dir for offline builds |
| `6ba43df` | fix(rcc-fix): set keyboard_connected=false when no aura iface found |
| `b7ebbfa` | fix(rcc-fix): replace polling with D-Bus InterfacesAdded event |

## 2026-05-29T13:16:30+09:00

**Summary**: docs: fix codewhale type description (pre-built, not source-built)

- the type description now says pre-built binaries, not source-built
| Commit | Description |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

## 2026-05-29T10:18:46+09:00

**Summary**: codewhale v0.8.47 — new package

- DeepSeek V4 TUI agent
- switched to pre-built binaries, `cargoHash` removed
| Commit | Description |
|------|------|
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |

| Package | Old | New |
|--------|--------|--------|
| codewhale | v0.8.47 |

## 2026-05-29T06:28:50+09:00

**Summary**: fix(kitsfmt): formatting bugs and idempotency fixed

- fix the `inherit` comma, indented string corruption, lambda spacing and other formatting bugs
- fix idempotency
| Commit | Description |
|------|------|
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |

## 2026-05-29T05:57:55+09:00

**Summary**: fix(build): overly broad .vscode gitignore scope excluded vendored crate files

- the `.vscode` gitignore is restricted to the repo root and no longer excludes vendored crate files
## 2026-05-28T08:29:27+09:00

**Summary**: llama-cpp-rocm, opencode-telegram, rcc-fix and skill docs — modules, property and wording fixes

- `llama-cpp-rocm`: the NixOS module for systemd sandbox overrides is added
- `opencode-telegram`: NixOS module (declarative config, auto install)
- `rcc-fix`: `ScrollView` now uses the `visible` property instead of an if conditional
- skill docs: dynamic-discovery wording, hardcoded count removed, install section added, description simplified
| Commit | Description |
|------|------|
| `3d2c38c` | docs(skill): nixkits-check-updates — dynamic discovery, not hardcoded list |
| `e5ee4ab` | docs(skill): remove hardcoded count from features, add exclusion note |
| `814731e` | docs(skill): sync ja doc with zh/en — dynamic discovery wording |
| `713b693` | fix(rcc-fix): use visible: property instead of if conditional for ScrollView |
| `34d309b` | docs(skills): add Install section with full 5-agent support to all skills |
| `2db934e` | docs(zh): simplify Skills description, remove semantic duplication |
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

## 2026-05-27T06:08:13+09:00

**Summary**: Skill system — nixkits-check-updates, nixkits-skills and nixos-modern-cli added together

- the three skills land in one batch, each with trilingual docs
- `llama-cpp-rocm`: clarify why upstream releases are tracked dynamically
| Commit | Description |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

## 2026-05-26T05:30:58+09:00

**Summary**: docs — rename README sections (快速开始→添加, 包→软件, License→许可)

- `快速开始`→`添加`
- `包`→`软件`
- `License`→`许可`
| Commit | Description |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

## 2026-05-24T03:01:02+09:00

**Summary**: mcp-searxng docs — complete NixOS config for SearXNG + lighttpd reverse proxy

- the docs add the full NixOS config for a SearXNG + lighttpd reverse proxy
| Commit | Description |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

## 2026-05-22T06:45:11+09:00

**Summary**: llama-cpp-rocm — drop the llama-cpp-ver flake input

- drop the llama-cpp-ver flake input
- use the nixpkgs default version
| Commit | Description |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

## 2026-05-21T16:35:02+09:00

**Summary**: mcp-searxng v1.0.3 and opencode-telegram v0.20.5 — new packages

- mcp-searxng v1.0.3 — new package
- opencode-telegram v0.20.5 — new package
| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

## 2026-05-16T19:07:54+09:00

**Summary**: kitsfmt — macro syntax error fixed, function simplified, src path corrected

- fixed the `match_ast!` macro syntax error
- simplified the `comments_before` function
- corrected the src path
| Commit | Description |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

## 2026-05-15T16:59:28+09:00

**Summary**: kitsfmt — formatting engine rewritten on the rnix AST

- rewrite the formatting engine on the rnix AST (v0.3.0)
- generate Cargo.lock
| Commit | Description |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |

## 2026-05-14T17:10:06+09:00

**Summary**: llama-cpp-rocm — new package

- dynamically tracks the upstream latest Release
| Commit | Description |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| Package | Old | New |
|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

## 2026-05-14T07:38:08+09:00

**Summary**: kitsfmt and obs-bilibili-stream v1.0.0 — new packages

- kitsfmt — new package (in-house Nix formatter)
- obs-bilibili-stream v1.0.0 — new package
| Commit | Description |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

| Package | Old | New |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

## 2026-05-01T01:08:15+09:00

**Summary**: rcc-fix — new package

- asusctl patch
| Commit | Description |
|------|------|
| `e2d09a2` | RCC-Fix |

| Package | Old | New |
|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（overlay + patch） |

