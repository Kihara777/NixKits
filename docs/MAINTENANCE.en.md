# Maintenance Log

[中文](../MAINTENANCE.md) | English | [日本語](MAINTENANCE.ja.md)  | [偽中国語](MAINTENANCE.pcn.md)

## 2026-08-21T21:51:26+09:00

**Summary**: docs: README plugins-section expansion and DSH credits info — ① the "Plugins" section gains an "Agent presets" table (NixOS模式/维护模式, shipped with the plugin, seeded once via nixkits.dsh.presets), keeping DSH components separate from software; ② the credits "小爪" entry now carries DSH ecosystem info (the dsh-nixos-shell plugin and the two agent presets); ③ the AGENTS.md plugin-listing rule is widened to "dsh-* components (plugins and agent presets)". All four languages synced.

| Commit | Description |
|--------|-------------|
| `4277b51` | docs: list DSH agent presets in the README plugins section and add DSH ecosystem info to the credits paw entry |

## 2026-08-21T00:01:46+09:00

**Summary**: fix(dsh-nixos-shell): surface the tools whitelist in the tool description — the acceptance round's non-blocking finding: the fixed POSIX tool whitelist was not shown in the tool description. The whitelist is now generated dynamically from the TOOL_PACKAGES map (27 names, including the python alias) into the `tools` parameter description, the tool description points at it, and the four-language docs list the full whitelist. Verified: all 27 names present in the parameter description, tool description carries the pointer, syntax check and nix flake check pass.

| Commit | Description |
|--------|-------------|
| `30d0c40` | fix(dsh-nixos-shell): surface the tools whitelist in the parameter description |

## 2026-08-20T20:12:33+09:00

**Summary**: fix(dsh-nixos-shell): correct the modern rebuild command to `nixos apply` — the installed nixos 0.16.1-dev has no `rebuild` subcommand (`nixos --help` lists activate/apply/generation etc.), so the handoff book and the plugin's recommendedRebuild/command map/gate guidance were wrong; unified to `nixos apply /etc/nixos` (or the traditional `sudo nixos-rebuild switch --flake /etc/nixos`). Verified: node syntax checks and nix flake check pass; system deployment switched to `nixos apply` and works.

| Commit | Description |
|--------|-------------|
| `caa7d41` | fix(dsh-nixos-shell): correct the modern rebuild command to 'nixos apply' |

## 2026-08-20T20:10:08+09:00

**Summary**: fix(dsh-nixos-shell): NixOS-mode acceptance fixes P1–P4 — P1 (high): the tools-bootstrap wrapper changed from `bash -lc` to `bash -c`; the login shell's /etc/profile chain reset PATH and discarded the nix shell injection, and the sudo path sharing the wrapper is fixed too (control experiment: `-c` yields Python 3.14.7, `-lc` yields command not found); the mapping also fixes grep→gnugrep and find→findutils (previously masked by login-PATH false positives). P2: generations gains `limit` (default 20, max 200, newest first) and returns the current generation plus the total. P3: journal unit accepts `*`/`%` globs and a trailing `@` auto-appends `*` (all template instances). P4: naming unified from nixos-cli to the nixos binary (nixos-cli project), across the tool description, the command map, and the gate guidance. Docs op tables synced in four languages. Verified: 5-case functional suite passes (including the real nix shell injection through the plugin echoing TOOLS_INJECTION_OK), node syntax checks, nix flake check passes.

| Commit | Description |
|--------|-------------|
| `a591826` | fix(dsh-nixos-shell): P1-P4 acceptance fixes |

## 2026-08-20T19:33:51+09:00

**Summary**: fix(dsh-nixos-shell): use the PromptSection `text` field instead of `content` — the dsh-system-prompt interpolator reads `input.text`, so sections registered with `content` crashed a real NixOS-mode session ("Cannot read properties of undefined (reading 'indexOf')"), a real-session path defect that mount validation cannot cover. Fixed 3 sites: nixos-gate (guidance/gate sections) and maintenance-skills (workflow section). Root cause located by reading the dsh-system-prompt interpolate() source and the PromptSection type definition (text: string | provider); the ToolGuard shape was also confirmed from its type definition (`(execution) => string | undefined`, compatible with the current implementation). Verified: mock assertions on the text field and no dangling `{{`; real systemPrompt service registration + assemble (includes=true, no crash); system prebuild passes.

| Commit | Description |
|--------|-------------|
| `476e9dc` | fix(dsh-nixos-shell): use the PromptSection text field instead of content |

## 2026-08-20T19:05:44+09:00

**Summary**: feat(dsh-nixos-shell): 维护模式 agent preset — new package entry maintenance-skills: at apply time it registers runtime skills write-project-docs, write-maintenance-log, and every translate-* language extension (auto-discovered) from the repo's skills/ tree embedded at build time (single source of truth, fresh sessions always get the latest content), plus the repository-maintenance workflow prompt section (commit batching, post-push maintenance log, doc sync, generalization); the package postPatch copies skills → skills-embedded. The preset presets/maintenance-mode (id `maintenance`, based on the NixOS-mode composition plus the maintenance-skills row) ships with the package; the module gains nixkits.dsh.presets.maintenanceMode (seed-once). Verified: mock registration of 3 skills + workflow section all pass, package contains the embedded tree and export, system prebuild passes; the nixos preset mount-validates (mounted ok), the maintenance preset needs a final check after restart due to the loader's in-process package.json cache.

| Commit | Description |
|--------|-------------|
| `f6c749e` | feat(dsh-nixos-shell): 维护模式 agent preset — maintenance-skills entry, presets/maintenance-mode, module presets.maintenanceMode seed |

## 2026-08-20T18:30:46+09:00

**Summary**: feat(dsh-nixos-shell): NixOS模式 agent preset — new package subpath entry nixos-gate: at session initialization it verifies the host is NixOS (/etc/NIXOS or os-release ID=nixos) — on non-NixOS it denies every tool execution via tools.guard and injects a refusal prompt section (clear reason + preset-switch advice), on NixOS it injects the development-guidance prompt section (derived from the nixos-modern-cli scenarios: declarative nature, tool bootstrap, modern commands, store-path pitfalls). The preset presets/nixos-mode (id `nixos`, based on the creation-mode cordis composition plus its skill directories, with nixos-gate/nixos-shell rows appended) ships with the package; the module gains nixkits.dsh.presets.nixosMode, seeding $DSH_HOME/.agent-presets/nixos once in preStart (later user edits respected). Verified: package build, gate syntax check, and system prebuild all pass.

| Commit | Description |
|--------|-------------|
| `aaa21cb` | feat(dsh-nixos-shell): NixOS模式 agent preset — nixos-gate entry, presets/nixos-mode, module presets.nixosMode seed |

## 2026-08-20T18:24:04+09:00

**Summary**: docs: dedicated README plugins section + AGENTS.md update — ① dsh-* plugins move from the software table into a new README "Plugins" section (all four languages), no longer mixed with software; AGENTS.md gains the plugin-listing convention and the "dsh is not a skill install target" rule. ② Approved cleanups applied (this machine): removed the stale store-absolute bash-completion block from ~/.bashrc, repointed ~/.profile's hm-session-vars at the stable /etc/profiles/per-user/kix path, deleted the old ~/.dsh/skills files (nixos_cli audit-store-paths re-check: 0 findings).

| Commit | Description |
|--------|-------------|
| `57ae6b5` | docs: list dsh-* plugins in a dedicated README plugins section (4 langs); AGENTS.md plugin-listing + dsh-skill-target rules |

## 2026-08-20T17:56:21+09:00

**Summary**: refactor(dsh-nixos-shell): rename package nixos-shell → dsh-nixos-shell — the package name (pname/directory/flake output/overlay/CI workflows/docs) is now `dsh-nixos-shell` (pkgs.dsh-nixos-shell); the dsh-internal display name stays `nixos-shell` (composition-row entry id, plugin name, tool names nixos_shell/nixos_cli unchanged). Verified: package build passes; deployment-side references synced.

| Commit | Description |
|--------|-------------|
| `26a844e` | refactor(dsh-nixos-shell): rename package nixos-shell -> dsh-nixos-shell |

## 2026-08-20T17:46:44+09:00

**Summary**: feat(nixos-shell): consolidate NixOS scenario capabilities into a single plugin; refactor: abandon the skills-as-plugins design — new package nixos-shell (@kihara777/dsh-nixos-shell 0.1.0) registers two tools: the nixos_shell executor (NixOS PATH injection + bash fallback + a `tools` parameter wrapping the command in `nix shell nixpkgs#… --command` to provide missing POSIX tools + sudo-daemon routing) and nixos_cli read-only diagnostics (capabilities / system-status / generations / journal / audit-store-paths), with functional requirements derived from the nixos-modern-cli skill scenarios. Also removed: dsh-nix-shell (function merged in) and dsh-skill-nixkits (the 7-skill-plugin design, including the module's skills option), with CI/docs swapped accordingly; the nixkits-skills installer no longer targets dsh (dsh capabilities come from nixos-shell; skills remain for other assistants). Fix: generations uses an in-process read-only listing (nix-env needs the profile lock file and fails unprivileged with Permission denied). Verified: 13-case functional suite passes (including real sudo root routing and nix shell tool bootstrap); system prebuild passes.

| Commit | Description |
|--------|-------------|
| `395d8b4` | feat(nixos-shell): consolidate NixOS scenario capabilities into one plugin |

| Package | Old | New |
|---------|-----|-----|
| nixos-shell | — | new v0.1.0 |

## 2026-08-20T16:40:16+09:00

**Summary**: fix(dsh): point the service HOME at the real user home — git's gh credential helper resolves credentials from `$HOME/.config/gh`, and the module previously set the service HOME to dshHome (/home/kix/.dsh), so sandbox git pushes found no credentials (could not read Username). Changed to `users.users.<user>.home` (falling back to dshHome), letting the agent inherit the user's own tooling context (git/gh credentials, ~/.gitconfig, npm/ssh configs); DSH_HOME remains dsh's state root and is unaffected. Verified: pushing the backlog with HOME=/home/kix succeeded; the system prebuild passes.

| Commit | Description |
|--------|-------------|
| `514831c` | fix(dsh): point service HOME at the real user home — git's gh credential helper resolves ~/.config/gh from $HOME, so HOME=dshHome left sandbox pushes without credentials |

## 2026-08-20T16:13:40+09:00

**Summary**: fix(dsh-nix-shell): sudo executor PATH merge order — socket-activated template units inherit systemd's manager-default PATH (coreutils/findutils/grep/sed/systemd store paths only), and `...process.env` spread after the explicit NixOS PATH overrode it, leaving profile tools like ps and nixos-rebuild unresolvable inside the daemon (PS-MISSING/NIXOS-REBUILD-MISSING). Fixed by spreading the inherited env first and the explicit NixOS profile PATH second (request env still merges last). Verified: running the executor directly with a simulated systemd-default PATH yields a PATH headed by /run/current-system/sw/bin, with both ps and nixos-rebuild resolving.

| Commit | Description |
|--------|-------------|
| `63b2576` | fix(dsh-nix-shell): put the explicit NixOS profile PATH after the inherited env — socket-activated template units inherit systemd's manager-default PATH, which overrode the executor PATH and left profile tools (ps, nixos-rebuild) unresolvable |

## 2026-08-20T16:01:28+09:00

**Summary**: docs(dsh): sync usage examples with actual module behavior — manual composition-row examples now use `- insert:` wrapping plus a warning (a bare `- id:` row only patches existing entries); the skill-plugin doc corrects all 7 entry ids (the `skill-nixkits-<id>` prefix was missing) and the disabled-example id; the dsh doc's install section switches to module-based installation (the old `nixkits.extraPackages` no longer exists) and adds the binary-cache note. All four languages synced.

| Commit | Description |
|--------|-------------|
| `6074661` | docs(dsh): sync usage examples with module reality — insert-op wrapping for manual rows, corrected skill entry ids, module-based install + cache note |

## 2026-08-21T22:11:28+09:00

**Summary**: fix(module): dsh crash resilience — Restart=always + RestartSec 5s. dsh upstream has a known crash bug (cordis-plugin-timer Context disposed; rc.6 hit it after ~13h), and rc.7/rc.8 keep the same cordis-plugin-timer dependency (^1.1.3), so the bug persists. On crash the lighttpd reverse proxy returns 503 until systemd restarts the unit. Switched to Restart=always (on-failure does not cover exit-0 paths) with a 5s restart delay to minimize the outage window.

| Commit | Description |
|------|------|
| `ed7e9d5` | fix(module): dsh Restart=always + faster RestartSec (crash resilience) |

## 2026-08-20T11:08:08+09:00

**Summary**: fix(module): dsh plugin ESM resolution — dsh's cordis-plugin-loader resolves from the profile directory ($DSH_HOME/profiles/web) as its base (the parentURL of Node 24's internal cascaded loader), searching node_modules upward from there. Plugins were injected into dsh's store tree, but the store is not on the profile's node_modules path, so import hit ERR_MODULE_NOT_FOUND and dsh crashed at startup (restart loop up to 108). preStart now symlinks the injected @kihara777 scope into $DSH_HOME/node_modules so Node can resolve it; after realpath back into the store tree, the @deepseek-ai/* peer deps the plugins import remain resolvable in the same tree. Verified: skills + nix-shell plugins load.

| Commit | Description |
|------|------|
| `044b891` | fix(module): dsh plugin ESM resolution via DSH_HOME/node_modules symlink |

## 2026-08-20T10:33:26+09:00

**Summary**: fix(dsh): insert-block indentation fix — a nested '' string is dedented by its own minimum indent, pushing the plugin entry objects back to column 0, where they parsed as sibling patch ops of `- insert:` instead of its children (dsh reported patch: entry … not found plus id is required for non-insert patches, and all 8 rows failed to mount again). Fixed by emitting one insert op per package entry with the entry object sharing the `- insert:` line's string (column 2/4 indentation); the module comment now records the trap. Verified: dump-config runs with zero stderr and all 8 rows in the composed tree.

| Commit | Description |
|--------|-------------|
| `988dc6d` | fix(dsh): emit one insert op per plugin entry in a single string — nested '' strings dedent to column 0, turning entry objects into sibling patch ops |

## 2026-08-20T10:21:46+09:00

**Summary**: fix(dsh): wrap generated rows in the insert op — a bare `- id:` row in cordis.patch.yml only patches an existing entry, so dsh dropped every new plugin entry (stderr: patch: entry "nixkits-nix-shell" not found) and none of the 8 plugin rows mounted (verified via dump-config). The package injection succeeded, but with no entries in the composed tree the nix_shell tool and the 7 skill plugins never registered. Fixed by wrapping the generated plugins.packages rows in an `- insert:` op (same shape as the MCP rows in extraPatch). Verified: dump-config runs with zero stderr and all 8 rows in the composed tree.

| Commit | Description |
|--------|-------------|
| `3d0433d` | fix(dsh): wrap generated plugin rows in the insert op — bare - id: rows only patch existing entries, so dsh dropped every new entry with 'patch: entry … not found' |

## 2026-08-20T09:45:59+09:00

**Summary**: fix(dsh): fix multi-plugin injection failure — after unpacking, GNU tar restores the archived directory modes (0555 for store trees), so the scope directory (@kihara777/) created by the previous plugin is unwritable for the next one, and the second and later plugins fail with "Cannot mkdir: Permission denied"; a single-plugin setup never triggers it, and the first real system build exposed it. Fixed by chmod -R u+w immediately after each plugin extraction. Verified: full system toplevel build succeeds; dsh-nix-shell and all 7 skills injected.

| Commit | Description |
|--------|-------------|
| `b03a386` | fix(dsh): chmod node_modules after each plugin injection — GNU tar restores archived dir modes (0555) after extraction, leaving the scope dir created by the previous plugin unwritable for the next one |

## 2026-08-20T08:12:57+09:00

**Summary**: fix(rcc-fix): desktop entry rename compat — asusctl 6.4.0 renamed its desktop entry to org.opengamingcollective.rog-control-center.desktop, while nixpkgs' programs.rog-control-center autoStart (makeAutostartItem) still copies the old rog-control-center.desktop name, breaking the system build (cp cannot stat). The rcc-fix overlay now ships the old name as a symlink in asusctl's postInstall. Verified: makeAutostartItem { name = "rog-control-center"; package = asusctl } builds successfully (EXIT=0) against the machine's pinned nixpkgs rev (0ae2bc1).

| Commit | Description |
|------|------|
| `650f6f7` | fix(rcc-fix): compat symlink for renamed desktop entry — nixpkgs programs.rog-control-center autoStart copies the pre-6.4.0 filename |

## 2026-08-20T07:41:45+09:00

**Summary**: fix(rcc-fix): patch rebased for asusctl 6.4.0 — after nixpkgs advanced, asusctl moved 6.3.7 → 6.4.0 and hunk 4 of rcc-fix.patch failed (system build broke). Upstream restructured the region: `if dev.is_old_laptop() { pow3r.retain(...) }` replaced the old push block, and the PowerZones::None filter in the else branch was absorbed upstream; the patch now keeps only the bounds-check replacement (`names[(*z) as usize]` → filter_map with bounds check + warn). The other hunks needed no change. Verified: git apply --check passes all hunks against the 6.4.0 source; asusctl builds successfully (EXIT=0) against the machine's pinned nixpkgs rev (0ae2bc1).

| Commit | Description |
|------|------|
| `ce216c7` | fix(rcc-fix): rebase patch hunk 4 for asusctl 6.4.0 — upstream is_old_laptop/retain restructure, else-filter absorbed upstream |

## 2026-08-20T06:27:40+09:00

**Summary**: feat(dsh-nix-shell): external sudo daemon integration (0.2.0) — the dsh sandbox strips sudo's setuid, so the agent cannot elevate. The plugin now probes the daemon socket at apply time (config `sudoSocketPath` / env `NIXKITS_SUDO_SOCKET`), advertises `sudo`/`justification` when present, and routes `sudo: true` requests whole (command/cwd/env/timeout) over a Unix socket to the daemon; `justification` is mandatory and echoed with the result. The daemon is a systemd socket-activated root executor (nixkits-sudo@.service + nixkits-sudo-exec.js, one-request-per-connection JSON protocol, shipped with the plugin package); the access-control boundary is the socket file owned by the dsh service user with mode 0600 (SocketUser/SocketMode). The module gains nixkits.dsh.sudo (enable/socketPath/package) creating the units and injecting the env var. Verified: gating (params hidden without socket, exposed with), routing round-trip, justification enforcement, direct executor protocol, and module unit evaluation.

| Commit | Description |
|------|------|
| `ef4bcfc` | feat(dsh-nix-shell): external sudo daemon integration — socket-activated root executor, init-time detection, sudo routing |

## 2026-08-20T06:02:50+09:00

**Summary**: refactor(skills): NixKits skills rewritten as native DSH skill plugins — new package dsh-skill-nixkits (@kihara777/dsh-skill-nixkits, zero runtime dependencies) with one subpath plugin entry per skill; each plugin registers its own content via ctx.skills.register (runtime provider, rank 250, outranking filesystem sources) and returns the registration disposer from apply(). The SKILL.md files remain the single source of truth in skills/, embedded at build time, with frontmatter stripped into content and preserved as metadata (the docs-pipeline auto-discovery contract is unchanged). The module's skills.enable now auto-generates the 7 composition rows (skill-nixkits-<id> → @kihara777/dsh-skill-nixkits/<id>), replacing the previously misimplemented directory injection (nixkits-skills package + bundledSkillDir). Verified: all 7 plugins register via a mock ctx, bare-subpath import + registration tested live (SUBPATH-OK/REGISTERED). CI builds added for x86_64/aarch64.

| Commit | Description |
|------|------|
| `7393b95` | feat(dsh): rewrite NixKits skills as native skill plugins — dsh-skill-nixkits package, one plugin entry per skill |

## 2026-08-20T05:27:48+09:00

**Summary**: feat(dsh): built-in bash tool NixOS fix + third-party plugin packages + deployment-bundled skills — ① the module injects a complete NixOS PATH into the dsh service (systemd's default PATH lacks bash; the stock bash tool failed with spawn bash ENOENT); ② new dsh-nix-shell package (@kihara777/dsh-nix-shell, a NixOS-aware shell tool plugin: Nix store bash fallback when PATH resolution fails, injected NixOS PATH, timeout and spill output) and nixkits-skills package (skill directory bundle); ③ new module options plugins.packages (tar-extracted into node_modules — a symlink is realpathed back into the plugin's store path, breaking peer resolution — with auto-generated composition rows) and skills.enable (skill-filesystem bundledSkillDir, rank 600); ④ CI builds for dsh-nix-shell on x86_64/aarch64. Verified end-to-end: IMPORT-OK inside the injected tree (plugin exports and dependency chain resolve).

| Commit | Description |
|------|------|
| `69eedd4` | feat(dsh): PATH fix + third-party plugin packages + bundled skills — L1/L2/L3/路径A |
| `55664ed` | docs: dsh-nix-shell package docs + dsh module options + README rows (4 languages) |

## 2026-08-19T20:39:47+09:00

**Summary**: fix(ci): ci-summary badge stuck on failing — the jq pipeline filtered failures before grouping by workflow, so an old failed run masked all later successes forever (badge stayed red after the codewhale riscv64 fix); now it takes the latest run per workflow first and only then filters failures — badge back to passing.

| Commit | Description |
|------|------|
| `d752c83` | fix(ci): ci-summary badge stuck on failing — latest-run check must precede failure filter |

## 2026-08-19T19:57:03+09:00

**Summary**: fix(codewhale-src): riscv64 cross build — four-part fix chain: ① rquickjs-sys 0.12.2 (newest on crates.io) ships no riscv64gc bindings (the build.rs non-bindgen path includes the target file); upstream's LP64 little-endian bindings are byte-identical, so postPatch drops an x86_64 copy into the materialized vendor dir; ② the host-side (x86_64 build-dependency) ring build let cc-rs fall back from the host triple to the derivation CC (the cross compiler) and add -m64 — now points at the buildPackages toolchain explicitly; ③ the bare postInstall cargo build lost --target and linked with the host toolchain — now mirrors cargoBuildHook's target triple; ④ binaries link -lgcc_s dynamically and autoPatchelfHook only scans hostPlatform deps — the cross gcc libgcc output is now an explicit input. Verified locally with the exact CI command (pkgsCross.riscv64.callPackage); clears the 6-run red Build codewhale (riscv64).

| Commit | Description |
|------|------|
| `962ce6c` | fix(codewhale-src): riscv64 cross build — rquickjs bindings overlay, host cc-rs toolchain, postInstall --target, libgcc rpath |

## 2026-08-19T17:57:26+09:00

**Summary**: AGENTS.md — fixed the stale comfyui-strix-halo module reference (that module was merged into comfyui-rocm) and aligned the CI section with the actual workflow layout (per-package build-<pkg>-<arch>.yml calling the shared build-package.yml with cachix-action pushes; noting packages without riscv64 builds and godot-ai/dsh having no dedicated build workflow; ci-summary.yml badge mechanism).

| Commit | Description |
|------|------|
| `c4e320e` | docs(AGENTS): fix stale comfyui-strix-halo reference + align CI description with actual workflows |

## 2026-08-19T16:52:54+09:00

**Summary**: fix(module): dsh WebSocket reverse proxy via mod_proxy upgrade — NixOS's lighttpd module generates server.modules in a fixed allKnownModules order, so mod_wstunnel always loads after mod_proxy. Because proxy.server matches every path, mod_proxy intercepts the WebSocket upgrade on /api/events.* and returns 426 Upgrade Required, while mod_wstunnel never runs (r->handler_module already set). Switched to lighttpd 1.4.56+ mod_proxy native WebSocket tunneling (proxy.header = "upgrade" => "enable"), dropping mod_wstunnel. Verified: 8625 / returns 200, /api/events.host|mux handshake 101 (local + LAN).

| Commit | Description |
|------|------|
| `51d9435` | fix(module): dsh WebSocket reverse proxy via mod_wstunnel |
| `33d5931` | fix(module): dsh wstunnel port as string (match lighttpd backend syntax) |
| `d7d2713` | fix(module): dsh WebSocket via mod_proxy upgrade (mod_wstunnel never runs) |

## 2026-08-19T13:10:00+09:00

**Summary**: fix(pkgs): dsh 0.1.0-rc.6 → 0.1.0-rc.7. rc.6 crashed after ~13h (fatal load failure: Context has been disposed) — cordis-plugin-timer ctx.timeout() rejects on a silent Context dispose, surfacing as an unhandled rejection. rc.7 (8/17) is latest; cordis/timer versions unchanged (bug may persist) but carries upstream fixes. Plugin inventory unchanged (131).

| Commit | Description |
|------|------|
| `c75cb4c` | chore(pkgs): bump dsh 0.1.0-rc.6 → 0.1.0-rc.7 |

## 2026-08-18T20:00:00+09:00

**Summary**: fix(module): dsh supports normal-user operation — running as the isolated system user (home /var/lib/dsh) it could not read /home/<user> (mode 700), so the agent could not touch the working tree. Add dshHome; route HOME/DSH_HOME/WorkingDirectory/preStart through it, replace StateDirectory with preStart mkdir + chown. Local config uses user="kix" + dshHome="/home/kix/.dsh", so dsh runs as kix and reaches /home/kix.

| Commit | Description |
|------|------|
| `584c764` | fix(module): dsh dshHome option + support normal-user operation |

## 2026-08-18T19:30:00+09:00

**Summary**: feat(module): nixkits.dsh.settings — declarative settings. dsh settings-menu options live in $DSH_HOME/settings.yaml (file-backed, hot-reloaded, per-namespace sections). New settings option (attrsOf attrs, namespace → section) rendered as JSON (valid YAML) written by preStart. Verified: web-search-deepseek.maxTokens declaratively overrides default 4096 → 8192. 4-language docs gain a settings section.

| Commit | Description |
|------|------|
| `f2981e6` | feat(module): nixkits.dsh.settings — declarative settings |
| `dc64cbb` | docs(dsh): declarative settings section + maintenance log |

## 2026-08-18T18:45:00+09:00

**Summary**: docs(dsh) + refactor(skill): plugin inventory sync — docs/dsh.md (4 langs) gains a Plugin inventory section (131 built-in entry ids, id -> package) as reference for nixkits.dsh.plugins.disabled. The check-updates skill step 5 gains a dsh note: on bump, extract the inventory from the freshly built package dsh-*/cordis.patch.yml and sync it into docs.

| Commit | Description |
|------|------|
| `06d0e28` | docs(dsh): plugin inventory + check-updates skill sync |

## 2026-08-18T18:39:34+09:00

**Summary**: fix(module): dsh preStart rm before cp — files generated by preStart have mode 444 (read-only), so the service user cannot cp over them; remove first, then copy.

| Commit | Description |
|------|------|
| `f308ac7` | fix(module): dsh preStart rm before cp — service-user cannot overwrite 444 |

## 2026-08-18T18:20:00+09:00

**Summary**: feat(module): nixkits.dsh.plugins — declarative plugin on/off + config. dsh plugins hot-reload via cordis.patch.yml; the module adds plugins.disabled (entry ids), plugins.settings (config overrides), plugins.extraPatch (raw fragments like MCP). System config migrated MCP to extraPatch, API key to kix.credentials, and disables session-telemetry-otel + session-stats as an example. Verified: cordis.patch.yml renders correctly, no absent-id warning.

| Commit | Description |
|------|------|
| `0e4fe58` | feat(module): nixkits.dsh.plugins — declarative plugin on/off + config |
| `164d515` | docs(dsh): declarative plugin management section + maintenance log |

## 2026-08-18T17:55:00+09:00

**Summary**: fix(module): lighttpd rewrites Host/Origin to loopback — supersedes the trustedHosts approach. dsh isTrustedApiRequest then sees loopback and passes, with no per-deployment trustedHosts and no LAN hostname/IP leaked to the backend. Origin must be rewritten alongside Host or the same-origin check fails. Verified: after dropping trustedHosts, proxied API (harukax.lan / 192.168.31.241) returns ok:true.

| Commit | Description |
|------|------|
| `a33b414` | fix(module): rewrite Host/Origin to loopback in lighttpd reverse proxy |

## 2026-08-18T17:30:00+09:00

**Summary**: fix(module): dsh trustedHosts option — all /api calls returned 403 behind the proxy. dsh validates the Host header on /api requests (isTrustedApiRequest: Host must be loopback or trusted, and the browser Origin must match). Via lighttpd the Host arrives as the LAN hostname/IP, so everything was 403 forbidden. Add nixkits.dsh.trustedHosts (mapped to repeatable --trusted-host); system config sets harukax.lan + 192.168.31.241 and the API recovered.

| Commit | Description |
|------|------|
| `3755935` | fix(module): dsh trustedHosts option — Host-header 403 behind reverse proxy |

## 2026-08-18T16:20:05+09:00

**Summary**: fix(dsh): patch browser client bundles — crypto.randomUUID fallback. crypto.randomUUID() is unavailable in non-secure contexts (HTTP on LAN IP, i.e. via the lighttpd reverse proxy), breaking the webui with "crypto.randomUUID is not a function". postInstall replaces it in dsh-client-connection + dsh-client-ui-conversation with a __dshUuid helper falling back to crypto.getRandomValues (available everywhere). Server-side index.js uses Node crypto, untouched.

| Commit | Description |
|------|------|
| `5d1cfa8` | fix(dsh): patch browser client bundles — crypto.randomUUID fallback |

## 2026-08-18T15:29:14+09:00

**Summary**: fix/docs(dsh): finalize lighttpd reverse proxy — dsh internal loopback port 8615 (mirroring SearXNG 42701), lighttpd public port 8625 (mirroring 4270); firewall opens the lighttpd public port, not dsh internal. 4-language docs synced.

| Commit | Description |
|------|------|
| `4a78d54` | fix(module): dsh internal port 8615, public reverseProxy port 8625 |
| `5452a3e` | docs(dsh): sync service section to loopback 8615 + lighttpd reverseProxy 8625 |

## 2026-08-18T14:38:26+09:00

**Summary**: feat(module): dsh reverseProxy via lighttpd — dsh rejects non-loopback hosts (RCE safety); a lighttpd `$SERVER["socket"]` block on 0.0.0.0:8626 proxies to dsh loopback 8625 (reusing the SearXNG lighttpd instance; extraConfig is types.lines, merges cleanly). Firewall opens 8626.

| Commit | Description |
|------|------|
| `12e11af` | feat(module): add nixkits.dsh.reverseProxy via lighttpd |

## 2026-08-18T10:29:46+09:00

**Summary**: feat/fix(dsh): deploy dsh service + configure MCP/skills — ① module fix: dsh system user HOME=/var/empty (read-only) caused EPERM, use writable /var/lib/dsh home + StateDirectory; ② HMR service needs --expose-internals (forbidden by NODE_OPTIONS, unknown to CLI), launch bin.js via node --expose-internals; ③ MCP services configured via cordis.patch.yml `insert:` syntax (not id-targeted override) for SearXNG + Godot; ④ skills copied to /var/lib/dsh/skills/ (not .agent-presets subdir); ⑤ nixkits-skills directory corrected to ~/.dsh/skills.

| Commit | Description |
|------|------|
| `b17e5bf` | fix(module): dsh writable HOME + StateDirectory |
| `ed6983e` | fix(module): dsh launch via node --expose-internals (HMR requires execArgv) |
| `456c917` | feat(skill): nixkits-skills add dsh skills directory support |
| `ee24563` | fix(skill): correct dsh skills directory — ~/.dsh/skills |

## 2026-08-18T08:42:40+09:00

**Summary**: docs: sync ruyi channel versions (stable 0.50.0 → 0.51.0, beta/alpha dates) and fill empty ruyi description column in en/ja/pcn README (was <br><br>; now RuyiSDK description + three channel versions, matching zh).

| Commit | Description |
|------|------|
| `86ae30b` | docs: sync ruyi channel versions + fill empty ruyi descriptions in en/ja/pcn README |

## 2026-08-18T07:19:30+09:00

**Summary**: audit fixes — ① codewhale 0.9.8 / mcp-searxng 1.15.0 / opencode-telegram 0.24.0 / obs-bilibili-stream 2.1.3 bumps; ② comfyui-rocm module restored services.comfyui assertion + clarified nixpkgs-compat patch target; ③ overlay codewhale arch-based source-build fallback (riscv64); ④ doc version/link/description sync; ⑤ write-maintenance-log skill header + drop katalish column.

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

**Summary**: refactor: merge comfyui-rocm-patch + comfyui-strix-halo into single comfyui-rocm — two modules handled different halves of ComfyUI ROCm support (patch layer vs Strix Halo hardware optimizations); unified as nixkits.comfyui-rocm (enable option) covering patch mount, GFX override, xformers bypass, C toolchain, Strix Halo config (ROCm runtime/DeviceAllow/kernelParams). Docs and README synced.

| Commit | Description |
|------|------|
| `d473991` | refactor: merge comfyui-rocm-patch + comfyui-strix-halo into comfyui-rocm |

## 2026-08-15T09:23:15+09:00

**Summary**: refactor: rename rog-control-center-fix.patch → rcc-fix.patch, completing the rcc-fix unification. Updated references in overlays/rcc-fix.nix and 4-language rcc-fix.md docs.

| Commit | Description |
|------|------|
| `b350cfd` | refactor: rename rog-control-center-fix.patch to rcc-fix.patch |

## 2026-08-15T08:31:32+09:00

**Summary**: feat(dsh): new deepseek-harness 0.1.0-rc.6 package + 4-language docs. DSH (DeepSeek Harness) — Everything is a Plugin. Prebuilt npm package (@deepseek-ai/dsh, bin dsh → lib/bin.js); vendored package-lock.json (npm tarballs ship none), dontNpmBuild to skip build. godot-ai and dsh listed in README (4 languages).

| Commit | Description |
|------|------|
| `0194460` | feat(dsh): add deepseek-harness 0.1.0-rc.6 package + 4-language docs |

## 2026-08-15T08:07:33+09:00

**Summary**: refactor: merge rog-control-center-fix into rcc-fix — both referred to the same ROG Control Center fix (overlay asusctl patch + module systemd deadlock fix). Unified to a single rcc-fix: overlays/rog-control-center-fix.nix → rcc-fix.nix, modules/rog-control-center-fix.nix → rcc-fix.nix, option nixkits.rog-control-center-fix → nixkits.rcc-fix, removed standalone docs (folded into rcc-fix.md).

| Commit | Description |
|------|------|
| `376eacf` | refactor: merge rog-control-center-fix into rcc-fix |

## 2026-08-13T01:20:29+09:00

**Summary**: fix(default-overlay): build godot-ai with fastmcp overlay — default overlay final.callPackage resolved fastmcp to nixpkgs 3.3.1 (circular-import bug); use (prev.extend (import ./fastmcp.nix)) so deps resolve to 3.4.7.

| Commit | Description |
|------|------|
| `94d49b5` | fix(default-overlay): build godot-ai with fastmcp overlay applied |

## 2026-08-12T10:05:00+09:00

**Summary**: fix(default-overlay): correct godot-ai path — callPackage in default overlay needs ../packages/ (overlay is in a subdirectory), not ./packages/ which resolved to the non-existent overlays/packages/.

| Commit | Description |
|------|------|
| `0144283` | fix(default-overlay): correct godot-ai path — ./packages → ../packages |

## 2026-08-12T10:00:00+09:00

**Summary**: fix(default-overlay): register godot-ai — present in flake packages but missing from default overlay, invisible as pkgs.godot-ai to downstream (/etc/nixos).

| Commit | Description |
|------|------|
| `093565c` | fix(default-overlay): register godot-ai so pkgs.godot-ai is available |

## 2026-08-12T09:18:26+09:00

**Summary**: docs(godot-ai): new 4-language docs (72 lines) — architecture diagram, dependency table (with fastmcp 3.4 note), system install + MCP config + prerequisite guide.

| Commit | Description |
|------|------|
| `76c39c8` | docs(godot-ai): add 4-language documentation |

## 2026-08-12T07:07:27+09:00

**Summary**: feat(godot-ai): new godot-ai 3.1.5 package + fastmcp 3.4.7 overlay. godot-ai is a production-grade MCP server connecting clients to a running Godot editor. fastmcp bumped 3.3.1→3.4.7 (godot-ai needs >=3.4.0, 3.3.x has circular-import bug), with cascading fastmcp-slim + py-key-value-aio 0.4.5 upgrades. devshell godot-mcp→godot-ai.

| Commit | Description |
|------|------|
| `23a5b8d` | feat(godot-ai): add godot-ai 3.1.5 package + fastmcp 3.4.7 overlay |

## 2026-08-11T18:49:54+09:00

**Summary**: fix(breeze-black): pure black bg + pure white fg for Edge/Chromium — extended sed remap: backgrounds #292c30 → #000000 (buttons/toolbars/insensitive), foregrounds #fcfcfc/#a1a9b1 → #ffffff. gtk-3.0/4.0 verified: 15× #000000, 14× #ffffff, zero gray residues.

| Commit | Description |
|------|------|
| `4e5c558` | fix(breeze-black): pure black bg + pure white fg for Edge/Chromium |

## 2026-08-11T18:41:14+09:00

**Summary**: fix(breeze-black): map background variables to true black #000000 — Breeze-Dark base is #202326 (dark gray, not pure black). Remap main background/base to #000000 after copying (buttons keep #292c30 for distinction), make gtk-dark.css self-contained (copy of gtk.css), dropping the gray import.

| Commit | Description |
|------|------|
| `2ee1ba6` | fix(breeze-black): map background variables to true black #000000 |

## 2026-08-11T16:19:49+09:00

**Summary**: fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme — Chromium-based apps (Edge/Chrome) ignore prefer-dark and load gtk.css directly; BreezeBlack (renamed from light Breeze) still had light variables (#eff0f1) so Edge rendered gray. Overwrite gtk-{3,4}.0 gtk.css(+.map) with dark (#202326).

| Commit | Description |
|------|------|
| `25e23e0` | fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme |

## 2026-08-11T16:02:39+09:00

**Summary**: fix(breeze-black): keep Breeze-Dark — BreezeBlack gtk-dark.css imports it for the real dark scheme (#202326); deleting it in preFixup broke the import and GTK fell back to light (the "not black enough" symptom).

| Commit | Description |
|------|------|
| `0433eee` | fix(breeze-black): keep Breeze-Dark — gtk-dark.css imports it for dark mode |

## 2026-08-09T22:43:43+09:00

**Summary**: refactor(skill): add trap 4 — bare `nix flake lock` refreshes all floating inputs (nixpkgs drift re-triggers diffusers/httpx failure on 8/7 nixpkgs). Use --update-input or pin nixpkgs rev instead.

| Commit | Description |
|------|------|
| `ec5e589` | refactor(skill): add trap 4 — bare nix flake lock refreshes floating inputs |

## 2026-08-09T19:40:21+09:00

**Summary**: feat(patches): vendored local comfyui-nix build fixes as a patch file — ① mkWheel dontCheckRuntimeDeps (pythonRuntimeDepsCheckHook, nixpkgs ≥ 8/5); ② doInstallCheck=false for flaky suites (jupyter-server/scipy/fastapi/einops/mss/inline-snapshot); ③ torch/facexlib runtime-deps skip. Updated module comment + 4-language docs.

| Commit | Description |
|------|------|
| `a8ad11e` | feat(patches): add comfyui-nix nixpkgs-compat patch + module doc |
| `faefa5b` | docs(comfyui-rocm-patch): document nixpkgs-compat patch (4 langs) |

## 2026-08-09T19:05:53+09:00

**Summary**: refactor(skill): nixkits-check-updates gains a nixpkgs-drift troubleshooting section — ① restoring old flake.lock requires verifying follows in flake.nix (lost → glibc 2.40 → GLIBC_ABI_GNU2_TLS); ② pytest packages need doInstallCheck=false (pytestCheckHook runs in installCheckPhase); ③ pythonRuntimeDepsCheckHook (nixpkgs ≥ 8/5) breaks wheel builds, fix with dontCheckRuntimeDeps=true.

| Commit | Description |
|------|------|
| `e88fd98` | refactor(skill): add nixpkgs-drift troubleshooting section to check-updates |

## 2026-08-09T04:21:09+09:00

**Summary**: fix(module): llama-cpp — ① services.llama-cpp.extraFlags is deprecated, switch to settings for --sleep-idle-seconds; ② freeform settings cannot have separate definitions, merge via lib.mkMerge.

| Commit | Description |
|------|------|
| `8026d8e` | fix(module): replace deprecated services.llama-cpp.extraFlags with settings |
| `0ec7760` | fix(module): merge llama-cpp settings via mkMerge |

## 2026-08-08T23:07:40+09:00

**Summary**: fix(breeze-black): restored look-and-feel global theme + fixed GTK rename — two regressions after the 7/23 external patch removal: ① org.kde.breezeblack.desktop global theme missing so BreezeBlack disappeared from the settings theme chooser, restored via vendored look-and-feel; ② preFixup Breeze* glob matched both Breeze and Breeze-Dark nesting the GTK theme, now renames Breeze only.

| Commit | Description |
|------|------|
| `114b9c2` | fix(breeze-black): restore look-and-feel global theme + fix GTK rename |

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

## 2026-08-04T02:15:00+09:00

**Summary**: fix(ruyi): tolerate ruff lint failures in checkPhase — the second ruff check (without --fix) was blocking builds on 139 upstream violations after nixpkgs ruff update.

| Commit | Description |
|------|------|
| `1175df2` | fix(ruyi): tolerate ruff lint failures in checkPhase |

## 2026-08-04T01:15:52+09:00

**Summary**: codewhale 0.9.3 — upstream bug fixes; mcp-searxng 1.14.0 — upstream feature update

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

## 2026-07-22T16:31:26+09:00

**Summary**: fix(modules) — rog-control-center-fix now forces SendSIGKILL=yes + TimeoutStopSec=30s to prevent stale asus-shutdown process from blocking systemd-switch. comfyui-strix-halo now asserts glibc >= 2.42 (ROCm 7.2 needs GLIBC_ABI_GNU2_TLS).

| Commit | Description |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T09:00:00+09:00

**Summary**：feat(overlays) — new breeze-black overlay, providing high-contrast Breeze Black accessibility theme for Plasma 6 (global look-and-feel + GTK + color scheme). Includes 4-language docs.

| Commit | Description |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T05:39:31+09:00

**Summary**: docs(devshell) — new devShell documentation (4 languages), describing opencode (full MCP stack) and ruyi (3 channels merged) environments. README devShell table now includes doc links.

| Commit | Description |
|------|------|
| `7bfe3e3` | docs: add devShell documentation — 4 lang |
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |

## 2026-07-22T03:40:50+09:00

**Summary**: docs — unified all user home directory paths across the repo to `~/` prefix (replaced hardcoded `/home/kix` and `/home/<user>` variants), covering 13 files.

| Commit | Description |
|------|------|
| `f597b9a` | docs: generalize hardcoded /home/kix paths |
| `bb65b77` | docs: unify all user home paths to ~/ prefix |

## 2026-07-22T03:14:27+09:00

**Summary**: feat(shells) — opencode devShell iteration: SearXNG + lighttpd (matching system NixOS config) + blender-mcp + godot-mcp + godot + opencode + opencode-telegram. Auto-registers MCP config on first entry. Removed tryEval guards from godot packages.

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

**Summary**: feat(overlays) — new efl-cross-fix overlay, fixing efl cross-compilation failures on riscv64/riscv64-musl/aarch64 caused by missing native code-gen tools (eolian_gen, eet). Includes 4-language docs.

| Commit | Description |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**Summary**: codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3 — upstream updates (codewhale v0.9.0 still no riscv64 prebuilt binaries, continues source-build path)

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

**Summary**: fix(ci) — ci-summary workflow was failing with HTTP 403 rate limit from calling `gh run list` per-workflow (25 calls). Fixed with 2 batched `gh api` calls + concurrency guard.

| Commit | Description |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**Summary**: revert(skill) — removed all katalish (halfwidth-katakana mechanical translation) content: 19 docs, skill (SKILL.md + 102-entry dictionary), all lang switcher links. The approach proved unstable (leaving English residue or destroying doc structure).

| Commit | Description |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:54:55+09:00

**Summary**: docs(nixkits-skills) — renamed 'Known Removals' to 'Risk Advisory' across 5-language skill docs.

| Commit | Description |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**Summary**: skill(nixkits-skills) — removed Claude Code install target (nationality inference via user data mining crosses security boundary), added Codex support. Added "Risk Advisory" section with original verbatim rationale to SKILL.md.

| Commit | Description |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:35:20+09:00

**Summary**: skill(write-maintenance-log) — strengthened timestamp rules: mandatory `git log` for commit times, ban `T00:00:00` placeholders, add post-generation verification step. Generalized from the MAINTENANCE placeholder timestamp fix (`968df0e`).

| Commit | Description |
|------|------|
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |

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
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |

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

## 2026-07-07T12:01:12+09:00

**Summary**: fix(docs) — katalish/pcn localization fixes: broken lang switchers in katalish/ruyi.md and pcn/ruyi.md (missing links, duplicate lang names), pcn/ruyi.md full rewrite from raw Japanese to pseudocn.

| Commit | Description |
|------|------|
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |

## 2026-07-05T04:41:23+09:00

**Summary**: fix(ci) — blender-mcp riscv64-cross saga (4 commits): initial failure from `callPackage` auto-resolving incompatible `blender`, followed by Nix/Bash escaping issues, and finally removed blender-mcp from riscv64-cross due to upstream nixpkgs `sse-starlette` cross-compilation defect. x86_64 / aarch64 unaffected.

| Commit | Description |
|------|------|
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |

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
| `ab9109a` | packages: add blender-mcp (MCP server for Blender) |

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

## 2026-06-26T07:18:56+09:00

**Summary**: fix(skill): rewrite write-maintenance-log step 4 "multi-lang sync" from 5-line stub to executable flow (4a discover languages → 4b per-lang translate & write → 4c verify entry count); strengthen AGENTS.md step 4 with verification gate

| Commit | Description |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-26T06:19:21+09:00

**Summary**: audit fixes — remove stale scripts/ directory and dead .gitignore rule (translate_pcn.py); relax AGENTS.md SKILL.md constraint from hard line count to qualitative guidance

| Commit | Description |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-25T11:02:38+09:00

**Summary**: ruyi — fix cross-compilation (postPatch uses python.pythonOnBuildForHost); CI — restore ruyi* to riscv64-cross; docs — restore precise riscv64 job filters

| Commit | Description |
|------|------|
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |

## 2026-06-25T10:12:02+09:00

**Summary**: CI — permanently remove ruyi* from riscv64-cross (Python postPatch cannot cross-compile); docs — revert riscv64 badges to fallback with * mark + note

| Commit | Description |
|------|------|
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |

## 2026-06-25T10:04:30+09:00

**Summary**: CI — fix access-tokens overwrite causing GitHub API rate-limit (merge into single line); cap riscv64-cross concurrency at 4

| Commit | Description |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |

## 2026-06-25T09:44:44+09:00

**Summary**: CI — add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with path mapping; docs — simplify badge labels + precise riscv64 job filters

| Commit | Description |
|------|------|
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |

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
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |

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

| Commit | Description |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

## 2026-06-20T18:36:33+09:00

**Summary**：技能系统重构 — translate-katakana→translate-katalish 重命名，新增 translate-pseudocn（偽中国語），write-project-docs 与 write-maintenance-log 语言扩展自动发现，文档代码五语映射表

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

**Summary**：codewhale 0.8.61 — 上游修复；mcp-searxng 1.6.0 — 上游修复

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

**Summary**：ruyi — NixOS 兼容性补丁（`patches/ruyi-nixos-compat.patch`），透明处理预编译 RISC-V 工具链的动态链接器路径、GCC 子进程 ELF interpreter 修复和 console_scripts argv0 问题

| Commit | Description |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

## 2026-06-17T10:59:35+09:00

**Summary**：ruyi — NixOS 模块（`services.ruyi`），声明式生成 `/etc/xdg/ruyi/config.toml` 与环境变量

| Commit | Description |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

## 2026-06-17T10:03:05+09:00

**Summary**：ruyi — 新增 devShell 支持，`nix develop github:Kihara777/NixKits#ruyi` 即可进入环境

| Commit | Description |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

## 2026-06-17T09:48:33+09:00

**Summary**：ruyi 0.51.0-alpha.20260616 — RuyiSDK 包管理器，新包（Python / Poetry 构建，ruff + mypy + 320 单元测试 + 52 集成测试全部通过）

| Commit | Description |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

## 2026-06-17T07:37:39+09:00

**Summary**：write-maintenance-log 技能 — 从 nixkits-check-updates 剥离为独立技能，双入口设计（记入维护记录 + 更新维护记录）；flake.lock 同步 .gitignore 前置检测与三路分支逻辑

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

**Summary**：fix(mcp-searxng): 修复入口文件错误 — dist/index.js → dist/cli.js，MCP 服务器可正常启动

| Commit | Description |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

## 2026-06-17T06:46:13+09:00

**Summary**：llama-cpp-rocm — 尝试用 builtins.fetchurl 替代 flake input 动态获取版本（已撤销，方案不可用）

| Commit | Description |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

## 2026-06-16T06:03:24+09:00

**Summary**：mcp-searxng 文档 — CodeWhale MCP 配置指南、常见陷阱警告（env 默认为 {}）、故障排查章节

| Commit | Description |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

## 2026-06-16T05:20:34+09:00

**Summary**：nixos-modern-cli 技能 — Nix Store 路径陷阱章节（gh auth setup-git 硬编码路径失效的诊断与通用修复模式）

| Commit | Description |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

## 2026-06-16T04:56:06+09:00

**Summary**：opencode-telegram 0.21.2 — 上游修复及依赖更新

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

**Summary**：codewhale 0.8.60 — 上游修复

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

**Summary**：comfyui-strix-halo 文档 — 在线集成模式说明与文件结构图

| Commit | Description |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

## 2026-06-14T07:56:11+09:00

**Summary**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；mcp-searxng 1.4.0 — 新增 HTTP 传输模式

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

**Summary**：llama-cpp-rocm 模块 — 恢复 modelsPreset 支持（nixpkgs 已移除）、命名空间迁移至 nixkits、三语迁移指南

| Commit | Description |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

## 2026-06-12T17:29:59+09:00

**Summary**：feat(llama-cpp-rocm): 恢复 modelsPreset 支持（nixpkgs 已移除），命名空间迁移至 nixkits

## 2026-06-12T10:51:31+09:00

**Summary**：codewhale 0.8.58 — 上游修复；mcp-searxng 1.3.4 — 上游修复

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

**Summary**：技能文档 — 维护日志格式规则系列（自动发现泛化、描述性标题、精确 git commit 时间戳、禁止 T00:00:00 占位符）

| Commit | Description |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

## 2026-06-11T05:13:39+09:00

**Summary**：other — 2 项更新

| Commit | Description |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

## 2026-06-11T04:52:16+09:00

**Summary**：codewhale 0.8.57 — TUI 新增；mcp-searxng 1.3.2 — 上游修复

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

**Summary**：opencode-telegram — KillMode 改为 process、添加 TimeoutStopSec 防止关机挂起

| Commit | Description |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

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

## 2026-06-08T14:25:02+09:00

**Summary**：mcp-searxng 1.2.1 — 上游修复

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

**Summary**：rcc-fix — NixOS 模块（systemd 死锁修复）

| Commit | Description |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

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

## 2026-06-06T12:51:46+09:00

**Summary**：comfyui-strix-halo 补丁 — ROCm 7.2 wheels 内嵌支持

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

**Summary**：技能系统 — SKILL.md 全面中文化；三语对称性检查规则

| Commit | Description |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

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

## 2026-06-02T03:42:25+09:00

**Summary**：nixos-modern-cli 技能 — POSIX 工具指南与 nix 二进制路径提示

| Commit | Description |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

## 2026-05-31T03:42:18+09:00

**Summary**：write-project-docs — 新技能（按 NixKits 风格为任意项目编写多语言文档系统）

| Commit | Description |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

## 2026-05-30T03:42:14+09:00

**Summary**：codewhale — stdenv 拼写修复；llama-cpp-rocm 文档修正（移除内联链接、使用 system.nix 完整预设）；opencode-telegram 首次设置流程

| Commit | Description |
|------|------|
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

## 2026-05-30T03:19:48+09:00

**Summary**：other — 2 项更新

| Commit | Description |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

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

## 2026-05-29T13:16:30+09:00

**Summary**：docs: fix codewhale type description (pre-built, not source-built)

| Commit | Description |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

## 2026-05-29T10:18:46+09:00

**Summary**：codewhale v0.8.47 — 新包

| Commit | Description |
|------|------|
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |

| Package | Old | New |
|--------|--------|--------|
| codewhale | v0.8.47 |

## 2026-05-29T06:28:50+09:00

**Summary**：fix(kitsfmt): 修复 inherit 逗号、缩进字符串损坏、lambda 空格等多个格式化问题；修复幂等性

| Commit | Description |
|------|------|
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |

## 2026-05-29T05:57:55+09:00

**Summary**：fix(build): 修复 .vscode gitignore 范围过宽导致 vendored crate 文件被排除

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
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

## 2026-05-27T06:08:13+09:00

**Summary**：技能系统 — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三大技能同步上线；llama-cpp-rocm 动态追踪说明

| Commit | Description |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

## 2026-05-26T05:30:58+09:00

**Summary**：文档 — README 节名重命名（快速开始→添加、包→软件、License→许可）

| Commit | Description |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

## 2026-05-24T03:01:02+09:00

**Summary**：mcp-searxng 文档 — SearXNG + lighttpd 反向代理完整 NixOS 配置

| Commit | Description |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

## 2026-05-22T06:45:11+09:00

**Summary**：llama-cpp-rocm — 移除 llama-cpp-ver flake 输入，使用 nixpkgs 默认版本

| Commit | Description |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

## 2026-05-21T16:35:02+09:00

**Summary**：mcp-searxng v1.0.3 — 新包；opencode-telegram v0.20.5 — 新包

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

## 2026-05-16T19:07:54+09:00

**Summary**：kitsfmt — 修复 match_ast! 宏语法错误、简化 comments_before 函数、修正 src 路径

| Commit | Description |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

## 2026-05-15T16:59:28+09:00

**Summary**：kitsfmt — 基于 rnix AST 重写格式化引擎 v0.3.0；生成 Cargo.lock

| Commit | Description |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |

## 2026-05-14T17:10:06+09:00

**Summary**：llama-cpp-rocm — 新包（动态追踪上游最新 Release）

| Commit | Description |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| Package | Old | New |
|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

## 2026-05-14T07:38:08+09:00

**Summary**：kitsfmt — 新包（自建 Nix 格式化器）；obs-bilibili-stream v1.0.0 — 新包

| Commit | Description |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

| Package | Old | New |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

## 2026-05-01T01:08:15+09:00

**Summary**：rcc-fix — 新包（asusctl 补丁）

| Commit | Description |
|------|------|
| `e2d09a2` | RCC-Fix |

| Package | Old | New |
|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（overlay + patch） |

