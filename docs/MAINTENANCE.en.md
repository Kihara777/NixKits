# Maintenance Log

[中文](../MAINTENANCE.md) | English | [日本語](MAINTENANCE.ja.md)  | [偽中国語](MAINTENANCE.pcn.md)

## 2026-08-08T22:50:33+09:00

**Summary**: fix(codewhale-src): synced to 0.9.4 with correct hash — the previous nix-prefetch-url archive tarball hash did not match fetchFromGitHub (git protocol), causing repeated riscv64 CI failures. Fixed via fetchFromGitHub build; Cargo.lock synced; wrong skill advice corrected.

| Commit | Description |
|------|------|
| `08b04a2` | fix(codewhale-src): sync to 0.9.4 with correct fetchFromGitHub hash |
| `ab2a624` | fix(skill): correct fetchFromGitHub hash advice — archive tarball trap |

## 2026-08-08T22:20:21+09:00

**Summary**: codewhale 0.9.4 — upstream bug fixes; mcp-searxng 1.14.1 — upstream maintenance; opencode-telegram 0.23.1 — upstream feature update

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

**Summary**: chore(pkgs) — codewhale-src synced to 0.9.3 (riscv64 source build was 3 patch versions behind the prebuilt package). Synced version, fetchFromGitHub hash, Cargo.lock (711 → 763 entries).

| Commit | Description |
|------|------|
| `563eea2` | chore(pkgs): sync codewhale-src to 0.9.3 — version, hash, Cargo.lock |

## 2026-08-05T01:30:00+09:00

**Summary**: refactor(skill) — nixkits-check-updates gains a Rust package (buildRustPackage) update flow, generalizing the codewhale-src Cargo.lock sync lesson (three-way sync of version + source hash + Cargo.lock, upstream lock download with entry-count verification, cross-compile timeout fallback).

| Commit | Description |
|------|------|
| `6e6bef6` | refactor(skill): add Rust package (buildRustPackage) update flow to nixkits-check-updates |

## 2026-08-04T01:15:52+09:00

**Summary**: codewhale 0.9.3 — upstream bug fixes; mcp-searxng 1.14.0 — upstream feature update

| Commit | Description |
|------|------|
| `f84cbcb` | chore(pkgs): bump codewhale 0.9.1 → 0.9.3 |
| `6968f4e` | chore(pkgs): bump mcp-searxng 1.12.1 → 1.14.0 |
| `d778b1b` | docs: sync version numbers |

## 2026-08-04T02:15:00+09:00

**Summary**: fix(ruyi): tolerate ruff lint failures in checkPhase — the second ruff check (without --fix) was blocking builds on 139 upstream violations after nixpkgs ruff update.

| 提交 | 说明 |
|------|------|
| `1175df2` | fix(ruyi): tolerate ruff lint failures in checkPhase |

## 2026-08-04T01:15:52+09:00

**Summary**：codewhale 0.9.3 — upstream bug fixes; mcp-searxng 1.14.0 — upstream feature update

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

**Summary**：fix(ci): fixed ci-summary.yml syntax errors (broken YAML, hardcoded token), switched to push/schedule triggers with GITHUB_TOKEN. README badge now uses shields.io endpoint reflecting actual Build workflow status instead of bare flake evaluation.

| Commit | Description |
|------|------|
| `c0e52a5` | fix(ci): fix ci-summary.yml syntax, switch README badge to endpoint |

## 2026-07-31T03:34:15+09:00

**Summary**：fix(ci): injected GITHUB_TOKEN as Nix access-token — the llama-cpp-ver input requires GitHub API calls; unauthenticated requests are limited to 60/hr, causing frequent HTTP 403 errors under parallel CI jobs. Now uses `${{ secrets.GITHUB_TOKEN }}` for authentication.

| Commit | Description |
|------|------|
| `41a8a8b` | fix(ci): inject GITHUB_TOKEN as Nix access-token for llama-cpp-ver API |


## 2026-07-31T03:00:12+09:00

**Summary**：fix(codewhale-src): fixed riscv64 cross-compile — the `ring` crate's `cc` build inherited `-m64` from the generic CFLAGS, causing riscv64-gcc errors. Clear both generic CFLAGS/CXXFLAGS in addition to per-target variables.

| Commit | Description |
|------|------|
| `29c780a` | fix(codewhale-src): clear generic CFLAGS/CXXFLAGS for riscv64 cross-compile |

## 2026-07-30T17:56:11+09:00

**Summary**：codewhale 0.9.1 — upstream bug fixes; mcp-searxng 1.12.1 — upstream feature update; opencode-telegram 0.22.5 — upstream maintenance

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

**Summary**：fix(codewhale-sudo): fixed ptrace wrapper — removed child tracing (avoid SIGTRAP killing codewhale sub-shells), added PTRACE_EVENT_EXEC handling. Synced 4-language docs (LD_PRELOAD → ptrace description).

| Commit | Description |
|------|------|
| `c77cadc` | fix(codewhale-sudo): stop tracing child processes, handle PTRACE_EVENT_EXEC |
| `480658e` | docs(codewhale-sudo): update mechanism description LD_PRELOAD → ptrace |

## 2026-07-23T12:08:13+09:00

**Summary**：fix(codewhale-sudo): replaced LD_PRELOAD shim with ptrace syscall interceptor — Codewhale is statically linked so LD_PRELOAD could not intercept prctl(PR_SET_NO_NEW_PRIVS); now uses ptrace(2) at the kernel boundary, compatible with both static and dynamic binaries.

| Commit | Description |
|------|------|
| `6446364` | fix(codewhale-sudo): replace LD_PRELOAD shim with ptrace syscall interceptor |

## 2026-07-23T11:24:15+09:00

**Summary**：fix(overlays): breeze-black — replaced the defunct fetchpatch URL (injx.sbs domain permanently unavailable) with a pure local colors file installation. KDE Plasma auto-discovers color schemes from share/color-schemes/.

| Commit | Description |
|------|------|
| `547d6a0` | fix(overlays): replace dead breeze-black fetchpatch with local copy |

## 2026-07-22T09:00:00+09:00

**Summary**：feat(overlays) — new breeze-black overlay, providing high-contrast Breeze Black accessibility theme for Plasma 6 (global look-and-feel + GTK + color scheme). Includes 4-language docs.

| Commit | Description |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T16:31:26+09:0000

**Summary**: fix(modules) — rog-control-center-fix now forces SendSIGKILL=yes + TimeoutStopSec=30s to prevent stale asus-shutdown process from blocking systemd-switch. comfyui-strix-halo now asserts glibc >= 2.42 (ROCm 7.2 needs GLIBC_ABI_GNU2_TLS).

| Commit | Description |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T05:39:31+09:0000

**Summary**: docs(devshell) — new devShell documentation (4 languages), describing opencode (full MCP stack) and ruyi (3 channels merged) environments. README devShell table now includes doc links.

| Commit | Description |
|------|------|
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |
| `7bfe3e3` | docs: add devShell documentation — 4 lang |

## 2026-07-22T03:14:27+09:00

**Summary**: feat(shells) — opencode devShell iteration: SearXNG + lighttpd (matching system NixOS config) + blender-mcp + godot-mcp + godot + opencode + opencode-telegram. Auto-registers MCP config on first entry. Removed tryEval guards from godot packages.

| Commit | Description |
|------|------|
| `8d2f65b` | fix(shells): s/godot_4/godot/ |
| `f8943ff` | refactor(shells): remove tryEval for godot-mcp |
| `c316c97` | feat(shells): add lighttpd reverse proxy |
| `6a6537d` | fix(shells): add limiterSettings/trusted_proxies |
| `9d67fd8` | feat(shells): auto-register opencode MCP servers on first entry |
| `e0ead5a` | refactor(shells): extract devShells from flake.nix to develop/ |
| `3652030` | feat(shells): add self-contained SearXNG + Redis |
| `47e43b3` | fix(shells): set SEARXNG_URL |
| `60a065e` | fix(shells): add GODOT_PATH |

## 2026-07-22T03:40:50+09:00

**Summary**: docs — unified all user home directory paths across the repo to `~/` prefix (replaced hardcoded `/home/kix` and `/home/<user>` variants), covering 13 files.

| Commit | Description |
|------|------|
| `bb65b77` | docs: unify all user home paths to ~/ prefix |
| `f597b9a` | docs: generalize hardcoded /home/kix paths |

## 2026-07-22T03:14:27+09:00

**Summary**: feat(shells) — new opencode devShell (formerly opencode-telegram), bundling opencode + nodejs + blender-mcp + blender + python3 + mcp-searxng + godot-mcp + godot_4; removed standalone blender-mcp devShell. Added nix run usage to codewhale docs.

| Commit | Description |
|------|------|
| `c5a57a6` | refactor(shells): rename opencode, add godot-mcp + godot_4 |
| `e83982d` | refactor(shells): merge blender-mcp + mcp-searxng |
| `2b8f676` | fix(shells): add opencode to opencode-telegram devShell |
| `35cc4e8` | feat(shells): add opencode-telegram devShell + nix run doc |

## 2026-07-22T02:43:51+09:00

**Summary**: feat(overlays) — new efl-cross-fix overlay, fixing efl cross-compilation failures on riscv64/riscv64-musl/aarch64 caused by missing native code-gen tools (eolian_gen, eet). Includes 4-language docs.

| Commit | Description |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**Summary**: codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3 — upstream updates (codewhale v0.9.0 still no riscv64 prebuilt binaries, continues source-build path)

| Commit | Description |
|------|------|
| `4df8df2` | chore(pkgs): bump codewhale 0.9.0 |
| `6046594` | chore(pkgs): bump ruyi 0.51.0 + beta + alpha |
| `deca3e8` | chore(pkgs): bump opencode-telegram 0.22.3 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.67 | 0.9.0 |
| ruyi | 0.50.0 | 0.51.0 |
| ruyi-beta | 0.50.0-beta.20260623 | 0.51.0-beta.20260714 |
| ruyi-alpha | 0.51.0-alpha.20260616 | 0.52.0-alpha.20260714 |
| opencode-telegram | 0.22.2 | 0.22.3 |
## 2026-07-16T06:08:43+09:00

**Summary**: fix(ci) — ci-summary workflow was failing with HTTP 403 rate limit from calling `gh run list` per-workflow (25 calls). Fixed with 2 batched `gh api` calls + concurrency guard.

| Commit | Description |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**Summary**: revert(skill) — removed all katalish (halfwidth-katakana mechanical translation) content: 19 docs, skill (SKILL.md + 102-entry dictionary), all lang switcher links. The approach proved unstable (leaving English residue or destroying doc structure).

| Commit | Description |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:46:54+09:00

**Summary**: skill(nixkits-skills) — removed Claude Code install target (nationality inference via user data mining crosses security boundary), added Codex support. Added "Risk Advisory" section with original verbatim rationale to SKILL.md.

| Commit | Description |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:30:55+09:00

**Summary**: feat(ci) — new CI summary endpoint badge. Main README CI badge now reads from `gh-pages/ci-status.json` via shields.io endpoint, showing failing package names on failure.

| Commit | Description |
|------|------|
| `6465260` | feat(ci): add CI summary workflow with endpoint badge |
| `b489890` | docs(README): switch main CI badge to endpoint |

## 2026-07-16T04:09:46+09:00

**Summary**: refactor(ci) — split single check.yml into 25 isolated workflow files (one per package×architecture), eliminating badge cross-contamination. Added reusable `build-package.yml`.

| Commit | Description |
|------|------|
| `bc42e6f` | refactor(ci): split single check.yml into 25 isolated per-package-per-arch workflows |
| `1dfc1ee` | docs: update ruyi badge URLs to new isolated workflow files |
| `f235edc` | docs: embed version numbers in CI badge labels |

## 2026-07-16T04:00:46+09:00

**Summary**: fix(codewhale) — riscv64 cross-compile fix for source-built codewhale: ring crate `-m64` error caused by cc crate inheriting host CFLAGS; fixed by clearing per-target CFLAGS.

| Commit | Description |
|------|------|
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |

## 2026-07-07T12:01:12+09:00

**Summary**: fix(docs) — katalish/pcn localization fixes: broken lang switchers in katalish/ruyi.md and pcn/ruyi.md (missing links, duplicate lang names), pcn/ruyi.md full rewrite from raw Japanese to pseudocn.

| Commit | Description |
|------|------|
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
## 2026-07-16T04:54:55+09:00

**Summary**: docs(nixkits-skills) — renamed 'Known Removals' to 'Risk Advisory' across 5-language skill docs.

| Commit | Description |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**Summary**: skill(nixkits-skills) — removed Claude Code support (nationality inference via user data mining crosses security boundary), added Codex detection and install support.

| Commit | Description |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex in nixkits-skills, add removal notice |

## 2026-07-16T04:35:20+09:00

**Summary**: skill(write-maintenance-log) — strengthened timestamp rules: mandatory `git log` for commit times, ban `T00:00:00` placeholders, add post-generation verification step. Generalized from the MAINTENANCE placeholder timestamp fix (`968df0e`).

| Commit | Description |
|------|------|
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |

## 2026-07-16T01:18:16+09:00

**Summary**: codewhale 0.8.67 — dual-path build (prebuilt x86_64/aarch64 + source-built riscv64). Upstream removed riscv64 binaries from v0.8.67 release; riscv64 now built via rustPlatform.buildRustPackage from vendored Cargo.lock.

| Commit | Description |
|------|------|
| `0025476` | feat(codewhale): dual-path build — prebuilt for x86_64/aarch64, source for riscv64 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.66 (prebuilt ×3) | 0.8.67 (prebuilt ×2 + source riscv64) |

## 2026-07-15T08:32:13+09:00

**Summary**: mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 — upstream updates (codewhale skipped: v0.8.67 still missing riscv64 binaries)

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

**Summary**: revert(ci) — removed `ci/` directory, restored `llama-cpp-ver` input to upstream API (`ggml-org/llama.cpp` releases/latest). Overlay already has `tryEval` + `prev.llama-cpp.version` fallback; local cache was unnecessary.

| Commit | Description |
|------|------|
| `dbdd937` | revert: restore llama-cpp-ver to upstream API, remove ci/ |

## 2026-07-09T01:14:34+09:00

**Summary**: obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 — upstream updates (codewhale skipped: v0.8.67 missing riscv64 prebuilt binaries)

| Commit | Description |
|------|------|
| `73dc576` | chore(pkgs): bump obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 |

| Package | Old | New |
|--------|--------|--------|
| obs-bilibili-stream | 2.1.0 | 2.1.1 |
| mcp-searxng | 1.8.0 | 1.11.0 |
| opencode-telegram | 0.22.0 | 0.22.1 |
| codewhale | 0.8.66 | (skipped — upstream riscv64 binaries missing) |

## 2026-07-05T04:41:23+09:00

**Summary**: fix(ci) — blender-mcp riscv64-cross saga (4 commits): initial failure from `callPackage` auto-resolving incompatible `blender`, followed by Nix/Bash escaping issues, and finally removed blender-mcp from riscv64-cross due to upstream nixpkgs `sse-starlette` cross-compilation defect. x86_64 / aarch64 unaffected.

| Commit | Description |
|------|------|
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |

## 2026-07-04T07:33:07+09:00

**Summary**: docs(MAINTENANCE) — add language switcher to all 6 MAINTENANCE files (zh/en/ja/katalish/pcn)

| Commit | Description |
|------|------|
| `9feb2fd` | docs(MAINTENANCE): add language switcher to all 6 MAINTENANCE files (zh/en/ja/katalish/pcn) |

## 2026-07-04T06:41:28+09:00

**Summary**: blender-mcp 1.0.0 — new Blender MCP Server package (Python build, 22 MCP tools, includes Blender add-on)

| Commit | Description |
|------|------|
| `a1cf458` | packages: add blender-mcp (MCP server for Blender) |

| Package | Old | New |
|--------|--------|--------|
| blender-mcp | — | 1.0.0 |

## 2026-07-02T04:00:00+09:00

**Summary**: codewhale 0.8.66 — upstream update (TUI layout fixes, approval honesty labels, performance fixes)

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

**Summary**: opencode-telegram 0.22.0 — upstream update (tri-mode TTS + thinking display + compact output + /settings command + session startup fix)

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

**Summary**: CI — llama-cpp-ver switched to local file (ci/llama-cpp-ver.json), eliminating all GitHub API calls from CI jobs and permanently fixing rate-limit global build failures; docs — riscv64 badges now per-package (codewhale/kitsfmt/mcp-searxng/opencode-telegram)

| Commit | Description |
|------|------|
| `8b3a3be` | fix(ci): use local path for llama-cpp-ver input, eliminate GitHub API calls from all CI jobs |
| `5db4852` | fix(docs): add per-package job filter to riscv64 badges |

## 2026-06-26T12:30:00+09:00

**Summary**: feat(opencode-telegram): add extraPackages option (inject system packages into service PATH) and extraBinPaths option (inject home-manager paths into service PATH), fixing opencode-not-found-in-service-PATH issue; 5-language docs updated

| Commit | Description |
|------|------|
| `7c98694` | feat(opencode-telegram): add extraPackages option to inject companion tools into service PATH |
| `45b7c57` | feat(opencode-telegram): add extraBinPaths option for home-manager users |


## 2026-06-26T10:55:41+09:00

**Summary**: codewhale 0.8.65 — upstream update (cli binary renamed: codewhale-cli-linux → codewhale-linux); mcp-searxng 1.8.0 — upstream update (multi-instance failover/parallel fanout, capability discovery aggregation, safesearch fix)

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


## 2026-06-26T08:00:00+09:00

**Summary**: docs(MAINTENANCE): backfill 28 missing historical entries to pcn, full zh baseline (93 entries) now covered

| Commit | Description |
|------|------|
| `01f662b` | docs(MAINTENANCE): backfill 28 missing historical entries to pcn (93/93 zh baseline covered) |


## 2026-06-26T07:35:00+09:00

**Summary**: docs(MAINTENANCE): backfill 10 missing historical entries to en/ja/katalish, all three now aligned with zh baseline (92/92); pcn partially backfilled (66/92)

| Commit | Description |
|------|------|
| `1921a36` | docs(MAINTENANCE): backfill 10 missing entries to en/ja/katalish (+ partial pcn) |


## 2026-06-26T06:19:21+09:00

**Summary**: audit fixes — remove stale scripts/ directory and dead .gitignore rule (translate_pcn.py); relax AGENTS.md SKILL.md constraint from hard line count to qualitative guidance

| Commit | Description |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-26T07:18:56+09:00

**Summary**: fix(skill): rewrite write-maintenance-log step 4 "multi-lang sync" from 5-line stub to executable flow (4a discover languages → 4b per-lang translate & write → 4c verify entry count); strengthen AGENTS.md step 4 with verification gate

| Commit | Description |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-25T11:02:38+09:00

**Summary**: ruyi — fix cross-compilation (postPatch uses python.pythonOnBuildForHost); CI — restore ruyi* to riscv64-cross; docs — restore precise riscv64 job filters

| Commit | Description |
|------|------|
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |
## 2026-06-25T10:12:02+09:00

**Summary**: CI — permanently remove ruyi* from riscv64-cross (Python postPatch cannot cross-compile); docs — revert riscv64 badges to fallback with * mark + note

| Commit | Description |
|------|------|
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
## 2026-06-25T10:04:30+09:00

**Summary**: CI — fix access-tokens overwrite causing GitHub API rate-limit (merge into single line); cap riscv64-cross concurrency at 4

| Commit | Description |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |
## 2026-06-25T09:44:44+09:00

**Summary**: CI — add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with path mapping; docs — simplify badge labels + precise riscv64 job filters

| Commit | Description |
|------|------|
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
## 2026-06-25T09:29:43+09:00

**Summary**: CI — split build / riscv64-cross into per-package matrix for independent badges; docs — expand ruyi badges to 9 (3 versions × 3 archs)

| Commit | Description |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |
## 2026-06-25T09:24:43+09:00

**Summary**: CI — add ruyi-beta / ruyi-alpha build steps to the build job; docs — include beta/alpha version numbers in ruyi Basic Info channel row

| Commit | Description |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |
## 2026-06-25T09:09:26+09:00

**Summary**: CI — exclude ruyi from riscv64-cross; overlays — add ruyi-beta/ruyi-alpha to default overlay + lift nixConfig to flake top-level; docs — show ruyi 3-channel versions in README tables

| Commit | Description |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |

## 2026-06-25T05:35:00+09:00

**Summary**: docs — add ruyi-beta / ruyi-alpha devShell entries to all 5-language READMEs

| Commit | Description |
|------|------|
| `5d4ca02` | docs: add ruyi-beta + ruyi-alpha to devShell tables (all 5 READMEs) |

## 2026-06-25T05:28:12+09:00

**Summary**: ruyi — restructure package directory (packages/ruyi/), beta/alpha as thin wrappers; add devShells

| Commit | Description |
|------|------|
| `4b9865e` | refactor(pkgs): move ruyi into subdirectory, beta/alpha as thin wrappers |
| `94bb174` | feat(shells): add ruyi-beta + ruyi-alpha devShells |

## 2026-06-25T05:13:34+09:00

**Summary**: ruyi — convert version channels to independent packages (ruyi / ruyi-beta / ruyi-alpha), remove standalone overlays

| Commit | Description |
|------|------|
| `51f23ad` | refactor(pkgs): ruyi channels as separate packages (not overlays) |

## 2026-06-25T04:58:36+09:00

**Summary**: ruyi — three-channel version system (stable/beta/alpha), base package set to 0.50.0 stable, beta/alpha via overlay overrides

| Commit | Description |
|------|------|
| `a9f8baa` | feat(pkgs): ruyi 3-channel (stable/beta/alpha) via overlays |

| Package | Old | New |
|--------|--------|--------|
| ruyi | 0.51.0-alpha.20260616 | 0.50.0 (stable) |
| 　 | new ruyi-beta overlay | 0.50.0-beta.20260623 |
| 　 | new ruyi-alpha overlay | 0.51.0-alpha.20260616 |

## 2026-06-24T03:19:30+09:00

**Summary**: workflow — make maintenance log update rule mandatory (AGENTS.md + write-maintenance-log skill)

| Commit | Description |
|------|------|
| `2e719df` | fix: make maintenance log update mandatory after every push |

## 2026-06-24T03:15:37+09:00

**Summary**: docs — remove stale manual riscv64 build instructions, CI now covers all 3 architectures

| Commit | Description |
|------|------|
| `698400a` | docs: remove stale manual riscv64 build instructions — CI now covers all 3 architectures |

## 2026-06-24T03:06:20+09:00

**Summary**: codewhale 0.8.64 — upstream update

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

**Summary**: CI — add riscv64 cross-compilation pipeline, full 3-arch CI coverage (x86_64 / aarch64 / riscv64); per-package riscv64 badges

| Commit | Description |
|------|------|
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |

## 2026-06-23T05:20:00+09:00

**Summary**: translate-pseudocn — expand dictionary based on web research (7→46 entries), convert to SVO word order, regenerate all pcn docs

| Commit | Description |
|------|------|
| `4fbf387` | feat(pcn): expand dictionary 7→46 entries, add IT terminology from research |
| `ec38b7e` | feat(pcn): convert to SVO word order, expand dictionary, regenerate all 22 docs |

## 2026-06-23T04:19:16+09:00

**Summary**: translate-pseudocn skill refactor — redefine pseudo-Chinese as "visual result of Japanese after stripping kana", no longer convert to Chinese; preserve original Japanese kanji (not simplified), retain SOV word order, reduce dictionary from 40→7 entries (katakana→Japanese kanji only); regenerate all 22 pcn docs

| Commit | Description |
|------|------|
| `be0780b` | refactor(pcn): redesign pseudo-Chinese skill — Japanese-native kanji, SOV order, no Chinese chars |

## 2026-06-23T04:04:32+09:00

**Summary**：AGENTS.md — 去硬编码、移除冗余审计备忘、缓存章节重写为代理操作指南、移除用户侧描述、语言体系改为自动发现

| Commit | Description |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:22:00+09:00



**Summary**：AGENTS.md — 新增初次启动审计规则、访问控制移至顶部

| Commit | Description |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**Summary**：docs — README 重复行修复，write-project-docs 反模式补充

| Commit | Description |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**Summary**：AGENTS.md — 新增访问控制、语言要求、提交规范、维护记录检查、文档同步、泛化、多架构缓存规则

| Commit | Description |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**Summary**：docs — 每包文档添加双架构 CI 徽章，技能模板同步

| Commit | Description |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**Summary**：CI — 添加 ARM runner 多架构构建，修复 flake.lock 并发竞争（--no-write-lock-file）

| Commit | Description |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**Summary**：mcp-searxng — source hash + npmDepsHash 更新（GitHub archive 变化）；ruyi — overlay postPatch 回移（补丁文件依赖）

| Commit | Description |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**Summary**：docs — 添加缓存排除警告（overlay 与模块+补丁条目），README 缓存说明压缩，flake.nix 添加 nixConfig 自动声明

| Commit | Description |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**Summary**：docs — 全部 30 篇包文档添加 `## 缓存` 节，CI badge 布局改进，技能同步

| Commit | Description |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**Summary**：CI/CD — 添加 GitHub Actions 构建矩阵（Cachix 推送）、二进制缓存、AGENTS.md

| Commit | Description |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**Summary**：skills — translate-katalish / translate-pseudocn / write-project-docs 拆分词典与模板，SKILL.md 压缩至 60-80 行

| Commit | Description |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**Summary**：docs — MAINTENANCE 时间戳精确化（29 节）、30 重复节删除（SHA 去重）、nix-kits→nixkits 全量替换（183 处）、模块文档同步

| Commit | Description |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**Summary**：patches — ruyi-nixos-compat.patch 基于干净克隆重建（1223→426 行），清除 flake.lock 自引用 artifact

| Commit | Description |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**Summary**：overlays — patches 列表 lib.unique 去重，ruyi-nixos-compat 精简，llama-cpp-rocm 添加 curried 形式注释

| Commit | Description |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**Summary**：modules — 4 模块添加 enable 选项，comfyui-strix-halo 添加 assertions，命名空间统一至 nixkits.*（含向后兼容），llama-cpp-rocm hfCacheDir 动态推导

| Commit | Description |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**Summary**：codewhale 0.8.63 — 多架构预编译二进制（x86_64 / aarch64 / riscv64）；ruyi — overlay postPatch 合并入包；meta 字段补全

| Commit | Description |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**Summary**：flake — 移除 mihomo-alpha 幽灵输入与 overlay（文件从未存在）

| Commit | Description |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |



## 2026-06-22T23:49:00+09:00

**Summary**：mcp-searxng 1.7.2 — 上游修复

| Commit | Description |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |


中文 | [English](docs/MAINTENANCE.en.md) | [日本語](docs/MAINTENANCE.ja.md)  | [偽中国語](docs/MAINTENANCE.pcn.md)

NixKits package update changelog.

---


## 2026-06-21T04:32:31+09:00

**Summary**：语言切换器标签规则泛化 — display_name 语义修正为语言自称、添加语言名称不本地化规则至 write-project-docs / translate-katalish / translate-pseudocn 三技能；修正 zh/katalish/pcn 全部文档切换器中残留的本地化名称

| Commit | Description |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称与切换器标签分离 |
| `aa8634b` | fix(docs): zh 文档切换器残留旧名称修正 + MAINTENANCE 翻译补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**Summary**：codewhale 0.8.62 — 上游修复；mcp-searxng 1.7.1 — 上游修复

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

| Commit | Description |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

## 2026-06-18T09:52:34+09:00

**Summary**：codewhale 0.8.61 — 上游修复；mcp-searxng 1.6.0 — 上游修复

| Commit | Description |
|------|------|
| `...` | chore(pkgs): bump codewhale 0.8.61 |
| `...` | chore(pkgs): bump mcp-searxng 1.6.0 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.60 | 0.8.61 |
| 　 | cli hash | `...` → `sha256-3k0K/I/NxYHrNszgniQncWTu8HRqsR3RSg+YLuB+IkY=` |
| 　 | tui hash | `...` → `sha256-YVjKDO/JNnsAHwzCf4itrEw8psKyi9bbFaLJLFvMyAI=` |
| mcp-searxng | 1.4.0 | 1.6.0 |
| 　 | source hash | `...` → `sha256-oBpSAAppLfnPhC3tHoE2X1YAGMyd42fka+xAVFuhjKw=` |
| 　 | npmDepsHash | `...` → `sha256-7z5T8po2ya698J7vqu4pA7c8s85k33sRbOV2tRmGdPo=` |

---

## 2026-06-18T09:03:48+09:00

**Summary**：ruyi — NixOS 兼容性补丁（`patches/ruyi-nixos-compat.patch`），透明处理预编译 RISC-V 工具链的动态链接器路径、GCC 子进程 ELF interpreter 修复和 console_scripts argv0 问题

| Commit | Description |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

---

## 2026-06-17T10:59:35+09:00

**Summary**：ruyi — NixOS 模块（`services.ruyi`），声明式生成 `/etc/xdg/ruyi/config.toml` 与环境变量

| Commit | Description |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

---

## 2026-06-17T10:03:05+09:00

**Summary**：ruyi — 新增 devShell 支持，`nix develop github:Kihara777/NixKits#ruyi` 即可进入环境

| Commit | Description |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

---

## 2026-06-17T09:48:33+09:00

**Summary**：ruyi 0.51.0-alpha.20260616 — RuyiSDK 包管理器，新包（Python / Poetry 构建，ruff + mypy + 320 单元测试 + 52 集成测试全部通过）

| Commit | Description |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

---

## 2026-06-20T18:36:33+09:00

**Summary**：技能系统重构 — translate-katakana→translate-katalish 重命名，新增 translate-pseudocn（偽中国語），write-project-docs 与 write-maintenance-log 语言扩展自动发现，文档代码五语映射表

| Commit | Description |
|------|------|
| `fee1534` | docs(skill): add translate-* support and docs-as-code mapping to write-maintenance-log |
| `177ad9b` | refactor: rename translate-katakana→translate-katalish, add translate-pseudocn, auto-discovery |
| `39906b9` | docs: purge remaining pcn references from zh write-project-docs |
| `911052b` | refactor(docs): migrate pcn directory to katalish |
| `7caf343` | refactor(translate-katakana): rename kata-en → katalish, use ｶﾀﾘｯｼｭ as canonical name |
| `97b696c` | docs(skill): purge pcn references from write-project-docs, add kata-en |
| `f1904a1` | feat(skill): add translate-katakana — katakana english mechanical substitution |
| `c5fb218` | docs: write-project-docs 英日文版同步更新四语(pcn)支持 |
| `0588ee0` | skill: write-project-docs 新增伪中国语(pcn)语言支持 |

---

## 2026-06-17T07:37:39+09:00

**Summary**：write-maintenance-log 技能 — 从 nixkits-check-updates 剥离为独立技能，双入口设计（记入维护记录 + 更新维护记录）；flake.lock 同步 .gitignore 前置检测与三路分支逻辑

| Commit | Description |
|------|------|
| `b77170a` | docs(skill): re-apply flake.lock sync and build verification steps |
| `be2239b` | docs(skill): add .gitignore pre-check to flake.lock sync step |
| `704ebe4` | docs(skill): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(skill): extract write-maintenance-log as standalone skill |
| `5187b07` | docs(skill): optimize write-maintenance-log triggers and add audit entry |

---

## 2026-06-17T06:46:13+09:00

**Summary**：llama-cpp-rocm — 尝试用 builtins.fetchurl 替代 flake input 动态获取版本（已撤销，方案不可用）

| Commit | Description |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

---

## 2026-06-16T06:03:24+09:00

**Summary**：mcp-searxng 文档 — CodeWhale MCP 配置指南、常见陷阱警告（env 默认为 {}）、故障排查章节

| Commit | Description |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

---

## 2026-06-16T05:20:34+09:00

**Summary**：nixos-modern-cli 技能 — Nix Store 路径陷阱章节（gh auth setup-git 硬编码路径失效的诊断与通用修复模式）

| Commit | Description |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

---

## 2026-06-14T08:11:16+09:00

**Summary**：comfyui-strix-halo 文档 — 在线集成模式说明与文件结构图

| Commit | Description |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

---

## 2026-06-12T18:17:52+09:00

**Summary**：llama-cpp-rocm 模块 — 恢复 modelsPreset 支持（nixpkgs 已移除）、命名空间迁移至 nixkits、三语迁移指南

| Commit | Description |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

---

## 2026-06-11T05:28:59+09:00

**Summary**：技能文档 — 维护日志格式规则系列（自动发现泛化、描述性标题、精确 git commit 时间戳、禁止 T00:00:00 占位符）

| Commit | Description |
|------|------|
| `7902bd1` | docs(MAINTENANCE): fix timestamps to exact commit times |
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `f92f9c4` | docs(MAINTENANCE): use descriptive titles instead of filename |
| `07f347f` | docs(skill): add descriptive title rule for MAINTENANCE files |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

---

## 2026-06-10T04:31:20+09:00

**Summary**：opencode-telegram — KillMode 改为 process、添加 TimeoutStopSec 防止关机挂起

| Commit | Description |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

---

## 2026-06-08T15:12:39+09:00

**Summary**：文档重构 — 本地化文件移入 docs/ 目录；MAINTENANCE.md 首次添加合列规则、纯表格格式、回填完整提交历史

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

---

## 2026-06-08T14:22:25+09:00

**Summary**：rcc-fix — NixOS 模块（systemd 死锁修复）

| Commit | Description |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

---

## 2026-06-06T15:17:11+09:00

**Summary**：技能文档 — 源变更后文档同步规范；comfyui-strix-halo C 工具链说明；hash 计算注意事项泛化；基本情報规则多语言统一

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

---

## 2026-06-04T13:07:30+09:00

**Summary**：技能系统 — SKILL.md 全面中文化；三语对称性检查规则

| Commit | Description |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

---

## 2026-06-02T03:42:25+09:00

**Summary**：nixos-modern-cli 技能 — POSIX 工具指南与 nix 二进制路径提示

| Commit | Description |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

---

## 2026-05-31T03:42:18+09:00

**Summary**：write-project-docs — 新技能（按 NixKits 风格为任意项目编写多语言文档系统）

| Commit | Description |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

---

## 2026-05-30T03:42:14+09:00

**Summary**：codewhale — stdenv 拼写修复；llama-cpp-rocm 文档修正（移除内联链接、使用 system.nix 完整预设）；opencode-telegram 首次设置流程

| Commit | Description |
|------|------|
| `2a8c41b` | docs(opencode-telegram): add first-time setup flow (opencode serve + config) |
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

---

## 2026-05-29T15:25:12+09:00

**Summary**：kitsfmt — 多项修复（vendor 目录恢复、幂等性、原地安全性、with→builtins.attrValues 转换、--stdin 标志）；rcc-fix — 重写为 D-Bus 热插拔检测；build — .vscode gitignore 范围修正

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

---

## 2026-05-28T08:29:27+09:00

**Summary**：llama-cpp-rocm — NixOS 模块（systemd 沙箱覆盖）；opencode-telegram — NixOS 模块（声明式配置、自动安装）；rcc-fix — visible 属性修复；技能文档 — 动态发现措辞

| Commit | Description |
|------|------|
| `3d2c38c` | docs(skill): nixkits-check-updates — dynamic discovery, not hardcoded list |
| `e5ee4ab` | docs(skill): remove hardcoded count from features, add exclusion note |
| `814731e` | docs(skill): sync ja doc with zh/en — dynamic discovery wording |
| `713b693` | fix(rcc-fix): use visible: property instead of if conditional for ScrollView |
| `34d309b` | docs(skills): add Install section with full 5-agent support to all skills |
| `2db934e` | docs(zh): simplify Skills description, remove semantic duplication |
| `8fe0b3d` | feat(opencode-telegram): add NixOS module with declarative config |
| `941eb48` | feat(opencode-telegram): auto-install package when module enabled |
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

---

## 2026-05-27T06:08:13+09:00

**Summary**：技能系统 — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三大技能同步上线；llama-cpp-rocm 动态追踪说明

| Commit | Description |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

---

## 2026-05-26T05:30:58+09:00

**Summary**：文档 — README 节名重命名（快速开始→添加、包→软件、License→许可）

| Commit | Description |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

---

## 2026-05-24T03:01:02+09:00

**Summary**：mcp-searxng 文档 — SearXNG + lighttpd 反向代理完整 NixOS 配置

| Commit | Description |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

---

## 2026-05-22T06:45:11+09:00

**Summary**：llama-cpp-rocm — 移除 llama-cpp-ver flake 输入，使用 nixpkgs 默认版本

| Commit | Description |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

---

## 2026-05-16T19:07:54+09:00

**Summary**：kitsfmt — 修复 match_ast! 宏语法错误、简化 comments_before 函数、修正 src 路径

| Commit | Description |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

---

## 2026-05-15T16:59:28+09:00

**Summary**：kitsfmt — 基于 rnix AST 重写格式化引擎 v0.3.0；生成 Cargo.lock

| Commit | Description |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |


## 2026-06-11T05:13:39+09:00

**Summary**：other — 2 项更新

| Commit | Description |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

---

## 2026-06-02T10:15:53+09:00

**Summary**：other — 7 项更新

| Commit | Description |
|------|------|
| `3be4889` | docs: add recover-nixos-config skill with multi-language docs |
| `fc5eca3` | docs: fix Skills section titles and generic agent descriptions |
| `d2e071f` | docs: add quantization levels to local model names |
| `22d206c` | docs: add UD- prefix to model quantization labels |
| `f15db79` | docs: add MIT license file and link from all READMEs |
| `218aeca` | docs: add local flake input example alongside remote |
| `4f0f968` | docs: fix local flake input syntax to match actual usage |

---

## 2026-06-02T08:49:47+09:00

**Summary**：opencode-telegram — 8 项更新

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

---

## 2026-05-30T03:19:48+09:00

**Summary**：other — 2 项更新

| Commit | Description |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

---

## 2026-05-29T13:16:30+09:00

**Summary**：docs: fix codewhale type description (pre-built, not source-built)

| Commit | Description |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

---

## 2026-06-16T04:56:06+09:00

**Summary**：opencode-telegram 0.21.2 — 上游修复及依赖更新

| Commit | Description |
|------|------|
| `3b05a32` | docs(MAINTENANCE): record 2026-06-16 update (opencode-telegram 0.21.2) |
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |

| Package | Old | New |
|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | source hash | `sha256-V/rThMV5...` → `sha256-NEaQ2grHCKXi13utcHeUR83pJT6kqBGS4UqllhG93kY=` |
| 　 | npmDepsHash | `sha256-Bcexury...` → `sha256-z9trDo9xeWZyTSvCqX5XTb+AHY50wk0gsoEnAAEHOEg=` |

---

## 2026-06-15T17:32:16+09:00

**Summary**：codewhale 0.8.60 — 上游修复

| Commit | Description |
|------|------|
| `3cef0a8` | docs(MAINTENANCE): record 2026-06-15 update (codewhale 0.8.60) |
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `sha256-ti/IBPZV...` → `sha256-JqlByElHoLcR2Mlwmx5Qczfj+EoAp+igdLCd/QUOsX4=` |
| 　 | tui hash | `sha256-3Lh80hTS...` → `sha256-LTf681cWVH9Cu3TQrFeMlJUNVVG+TWxO2oI6VXK+4zA=` |

---

## 2026-06-14T07:56:11+09:00

**Summary**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；mcp-searxng 1.4.0 — 新增 HTTP 传输模式

| Commit | Description |
|------|------|
| `ec7d5ca` | docs(MAINTENANCE): record 2026-06-14 updates (codewhale 0.8.59, mcp-searxng 1.4.0) |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
| 　 | cli hash | `sha256-AR9jJZzB...` → `sha256-ti/IBPZVJdaLvQ00OevzTfcMQ0XHELvOKTcul4+iBg8=` |
| 　 | tui hash | `sha256-BpCHu9M...` → `sha256-3Lh80hTSMG0RG+CHkR403rqcMtDA6kMdbyvBe7sLQaQ=` |
| 　 | source hash | `sha256-Xsp1vReg...` → `sha256-RMzxCBua89oYbKXmwXCtcSHan5QVefsm8IBdMIVq7UE=` |
| 　 | npmDepsHash | `sha256-3hWshG0...` → `sha256-Lh1UoM8zSMFji/TkqDAOiRtFRrQ/jqn5TbONySj9ckg=` |

---

## 2026-06-12T10:51:31+09:00

**Summary**：codewhale 0.8.58 — 上游修复；mcp-searxng 1.3.4 — 上游修复

| Commit | Description |
|------|------|
| `716d98c` | docs(MAINTENANCE): record 2026-06-12 updates (codewhale 0.8.58, mcp-searxng 1.3.4) |
| `ef9daae` | chore(pkgs): bump mcp-searxng 1.3.4 |
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| mcp-searxng | 1.3.2 | 1.3.4 |
| 　 | cli hash | `sha256-Hp0Z6mwe...` → `sha256-AR9jJZzB1VNUe7yaI3jpSUJsXuzgvqk5aWeLWe/L/vA=` |
| 　 | tui hash | `sha256-dExfhrfG...` → `sha256-BpCHu9MbDGuCAXNNJXPTZpj3BrIwx7jWs29I31cbSag=` |
| 　 | source hash | `sha256-OVllsRM...` → `sha256-Xsp1vRegHDWNk54nqLk+4l5MI0xGgocCg5Qa2UwWNqA=` |
| 　 | npmDepsHash | `sha256-LN9yDbw...` → `sha256-3hWshG0L8k0U2fnmz0OotrYaPAYBQE7DanjXgnFnNrE=` |

---

## 2026-06-11T04:52:16+09:00

**Summary**：codewhale 0.8.57 — TUI 新增；mcp-searxng 1.3.2 — 上游修复

| Commit | Description |
|------|------|
| `07f347f` | docs(skill): add descriptive title rule for MAINTENANCE files |
| `f92f9c4` | docs(MAINTENANCE): use descriptive titles instead of filename |
| `7902bd1` | docs(MAINTENANCE): fix timestamps to exact commit times |
| `543bcf9` | chore(pkgs): bump codewhale 0.8.57, mcp-searxng 1.3.2 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.55 | 0.8.57 |
| mcp-searxng | 1.3.1 | 1.3.2 |
| 　 | cli hash | `sha256-jwn3rKD...` → `sha256-Hp0Z6mweaC+sB/BH2KpD1W/sdS0me69pErKiWOa2GqY=` |
| 　 | tui hash | `sha256-1Cxofu9...` → `sha256-dExfhrfGs1wbWWmvXYTuCGXKnkhD+7rBY32aV938Dz0=` |

---

## 2026-06-10T02:28:10+09:00

**Summary**：codewhale 0.8.55 — 上游修复；mcp-searxng 1.3.1 — 上游修复

| Commit | Description |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

---

## 2026-06-08T14:25:02+09:00

**Summary**：mcp-searxng 1.2.1 — 上游修复

| Commit | Description |
|------|------|
| `2f58ac5` | refactor: move localized README/MAINTENANCE files into docs/ |
| `e5e505e` | docs(skills): sync trilingual MAINTENANCE rule to skill docs |
| `b34ed08` | docs: add trilingual MAINTENANCE (en/ja) with language switchers |
| `b4742ad` | docs(skills): sync refined MAINTENANCE.md format rules to trilingual docs |
| `1a28625` | docs(MAINTENANCE): backfill full package history from repo creation |
| `2cd9daf` | docs: drop doc-sync line from MAINTENANCE; only record substantive rewrites |
| `e4a3813` | docs: omit build status and unchanged hashes from MAINTENANCE.md |
| `b3d7d0f` | docs: switch MAINTENANCE.md to table-only format, drop trilingual prose |
| `b8a98bc` | docs(skill): skip MAINTENANCE.md when no updates found |
| `5ba1361` | docs(skills): sync MAINTENANCE.md step to trilingual docs |
| `d4cb81f` | docs(skill): add Step 8 — MAINTENANCE.md update workflow |
| `db680df` | docs: add MAINTENANCE.md — software update changelog |
| `07b1ee5` | chore(pkgs): bump mcp-searxng 1.1.0 → 1.2.1 |

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | 1.1.0 | 1.2.1 |

---

## 2026-06-06T13:58:47+09:00

**Summary**：codewhale 0.8.53 — 上游修复；mcp-searxng 1.1.0 — 上游修复；opencode-telegram 0.21.1 — 上游修复

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

---

## 2026-06-06T12:51:46+09:00

**Summary**：comfyui-strix-halo 补丁 — ROCm 7.2 wheels 内嵌支持

| Commit | Description |
|------|------|
| `58b06ea` | docs(comfyui-strix-halo): clarify kernel param is set by module, not hardware |
| `468b89a` | feat(skill): add patch-embedded version check for comfyui-strix-halo |
| `8f16f91` | docs(skill): add length/structure rules from comfyui-strix-halo doc fix |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs in NixKits concise style |
| `48d842f` | docs(ja): add 基本情報 section to comfyui-strix-halo |
| `e11f899` | fix(docs): add missing ja doc and en/ja README entries for comfyui-strix-halo |

| Package | Old | New |
|--------|--------|--------|
| comfyui-strix-halo | 补丁（ROCm 7.2 wheels 内嵌） |

---

## 2026-06-02T05:57:11+09:00

**Summary**：codewhale 0.8.49 — 上游修复；mcp-searxng 1.0.4 — 上游修复；obs-bilibili-stream 2.1.0 — 上游修复；opencode-telegram 0.21.0 — 上游修复

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

---

## 2026-05-29T10:18:46+09:00

**Summary**：codewhale v0.8.47 — 新包

| Commit | Description |
|------|------|
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | v0.8.47 |

---

## 2026-05-21T16:35:02+09:00

**Summary**：mcp-searxng v1.0.3 — 新包；opencode-telegram v0.20.5 — 新包

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

---

## 2026-05-14T17:10:06+09:00

**Summary**：llama-cpp-rocm — 新包（动态追踪上游最新 Release）

| Commit | Description |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| Package | Old | New |
|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

---

## 2026-05-14T07:38:08+09:00

**Summary**：kitsfmt — 新包（自建 Nix 格式化器）；obs-bilibili-stream v1.0.0 — 新包

| Commit | Description |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

| Package | Old | New |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

---

## 2026-05-01T01:08:15+09:00

**Summary**：rcc-fix — 新包（asusctl 补丁）

| Commit | Description |
|------|------|
| `e2d09a2` | RCC-Fix |

| Package | Old | New |
|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（overlay + patch） |

---

## 2026-06-17T06:48:47+09:00

**Summary**：fix(mcp-searxng): 修复入口文件错误 — dist/index.js → dist/cli.js，MCP 服务器可正常启动

| Commit | Description |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

---

## 2026-06-12T17:29:59+09:00

**Summary**：feat(llama-cpp-rocm): 恢复 modelsPreset 支持（nixpkgs 已移除），命名空间迁移至 nixkits

---

## 2026-05-29T06:28:50+09:00

**Summary**：fix(kitsfmt): 修复 inherit 逗号、缩进字符串损坏、lambda 空格等多个格式化问题；修复幂等性

| Commit | Description |
|------|------|
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |

---

## 2026-05-29T05:57:55+09:00

**Summary**：fix(build): 修复 .vscode gitignore 范围过宽导致 vendored crate 文件被排除
