# dsh

[中文](../zh/dsh.md) | English | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness (DSH) — Everything is a Plugin.

## Basic Info

| Item | Value |
|------|-------|
| Type | Node.js application (CLI) |
| Upstream | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| Version | `0.2.0-rc.2` |
| Development channel | `dsh-alpha 0.2.0-rc.2` (npm `next` dist-tag) |
| License | MIT |
| Command | `dsh` |

## Version Channels

NixKits provides several dsh versions through the same thin-wrapper pattern as ruyi (one main definition plus wrappers that override version/hash):

| Package | Channel | Version | Notes |
|---------|---------|---------|-------|
| `pkgs.dsh` | stable | `0.2.0-rc.2` | npm `latest` dist-tag, the default; its **preset content** is frozen at a pinned rev |
| `pkgs.dsh-alpha` | alpha | `0.2.0-rc.2` | npm **`next`** dist-tag, tracking the newest prerelease on the 0.2.x line; its **preset content** follows repository HEAD |

```nix
# run the newest prerelease on this machine
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> **Why `dsh-alpha` follows `next` and not `alpha`** (changed 2026-10-02). Today the npm dist-tags read `latest` = `next` = `0.2.0-rc.2` while `alpha` = **`0.1.7-alpha.2`** — `alpha` sits on the older 0.1.x line and is **lower** than stable. Following it would pin the development channel to a line that has already fallen behind (which is what this repository did before the upgrade: stable pinned 0.1.5-rc.2, alpha pinned 0.1.6-alpha.2 — both channels had to cross the 0.1.x → 0.2.x line). Following `next` means "the newest prerelease on the 0.2.x line": today it is the same 0.2.0-rc.2 as stable, and when `npm publish --tag next` ships a 0.2.1-alpha.x it follows automatically without touching the criterion again.
>
> The two channels' **only behavioural difference today is not the dsh version but the preset content**: stable's presets are frozen at the commit pinned in `packages/dsh-nixos-shell-stable.nix`, alpha's follow repository HEAD (see "Modes" below).
>
> ⚠️ **0.2.0 is a preset-format break** and is incompatible with 0.1.x: the directory-based preset channel (`$DSH_HOME/.agent-presets/<id>/` + `agent.cordis.yml`) was removed upstream. Read the "Modes" and "Preset format changes in dsh 0.2.0" sections below before upgrading. The built-in plugin inventory moves with the version; check the [changelog](https://github.com/deepseek-ai/deepseek-harness/releases) first.

## Install

```nix
# /etc/nixos/flake.nix — add the flake input and mount the module
{
  inputs.nixkits.url = "github:Kihara777/NixKits";
  # in nixosConfigurations.<host>.modules:
  #   nixkits.nixosModules.dsh
}
```

```nix
# Module configuration (enabling it also adds dsh to systemPackages)
{ nixkits.dsh.enable = true; }
```

> **Binary cache**: the flake declares the cache (`nixkits.cachix.org`) via `nixConfig`; Nix prompts to enable it on first build. Manual: `cachix use nixkits`.

## Usage

```bash
dsh --help
dsh web   # launch the browser UI
```

## Service

Run as a resident web service via the `nixkits.dsh` module. dsh listens loopback-only (`127.0.0.1:8615`) for RCE safety, exposed to the outside via a lighttpd reverse proxy on port `8625` (firewall auto-opened):

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # fixed: dsh rejects non-loopback
    port = 8615;          # internal loopback port
    reverseProxy = {
      enable = true;
      port = 8625;        # public lighttpd port
    };
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```

### LAN access (trustedHosts + launch URLs)

The dsh ≥ 0.1.2-alpha web UI entry authenticates with a Host-authority session cookie, so the proxy **no longer rewrites Host** (rewriting makes the backend see a different authority than the browser visited; the cookie cannot match across the proxy and every request 401s). LAN devices visiting `http://<host>:8625` must have their authority listed in `trustedHosts`. dsh prints its tokenized startup URL for 127.0.0.1 only; `launchUrlFile` makes the module capture dsh's startup output (ExecStartPost) and write the LAN devices' authenticated URLs there:

```nix
{
  nixkits.dsh = {
    trustedHosts = [ "harukax.lan" "192.168.31.241" ];  # LAN authorities
    launchUrlFile = "/run/dsh/launch-urls";             # startup URL output file
  };
}
```

> The token rotates on every dsh restart; exchanged session cookies stay valid until expiry.

### Passwordless entry (autoAuth)

`reverseProxy.autoAuth` uses lighttpd mod_magnet (the module swaps in an `enableMagnet` lighttpd automatically) to 302-inject the current launch token on home-page requests without a session cookie — LAN devices reach the web UI with no manual authentication step. **This DISABLES dsh's entry authentication (the token is no longer secret)** — enable only when the local network is fully trusted, otherwise any device that can reach the proxy port gains full dsh access (including its RCE surface):

```nix
{ nixkits.dsh.reverseProxy.autoAuth = true; }
```

> Note: autoAuth assumes a network-layer security scheme (e.g. an isolated LAN) owns the access boundary.

> **PATH**: the module injects a complete NixOS PATH (`/run/current-system/sw/bin`, …) into the service. Without it, systemd's default PATH cannot find bash and the built-in bash tool fails with `spawn bash ENOENT`.

> **HOME**: the service HOME points at the running user's real home (`users.users.<user>.home`, falling back to dshHome), so the agent inherits the user's own tooling context — git/gh credentials (`~/.config/gh`), `~/.gitconfig`, npm/ssh configs all resolve from `$HOME`. Pointing HOME at dshHome breaks this: git's gh credential helper finds no credentials and pushes fail.

## Declarative plugin management

dsh plugins hot-reload from `cordis.patch.yml` at runtime (no restart). `nixkits.dsh.plugins` provides declarative on/off and config:

```nix
{
  nixkits.dsh.plugins = {
    disabled = [ "session-telemetry-otel" "session-stats" ];  # disable plugins
    settings."dsh-web-app" = { printUrl = false; };           # config overrides
    extraPatch = "...";  # raw fragment (e.g. MCP insert list)
  };
}
```

| Option | Meaning |
|------|------|
| `disabled` | plugin entry ids to disable, rendered as `- id: <id> / disabled: true` |
| `settings` | plugin config overrides (id → JSON, YAML flow style) |
| `packages` | third-party plugin packages: injected into dsh's node_modules + generated composition rows (below) |
| `extraPatch` | raw cordis.patch.yml fragment (e.g. MCP servers) |

### Third-party plugin packages

`plugins.packages` injects third-party npm plugin packages into dsh's node_modules tree (composition rows resolve package names from the install root, and the packages must be real directories there — a symlink would be realpathed back into the plugin's own store path, breaking peer resolution) and registers the composition row in the generated cordis.patch.yml:

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nixos-shell;           # NixKits package (npm build)
    id = "nixos-shell";                   # cordis.patch.yml entry id
    name = "@kihara777/dsh-nixos-shell";  # npm package name referenced by the row
  }];
}
```

> **dsh ≥ 0.1.2-alpha plugin compatibility**: `ctx.connection.rpc.intercept` shared RPC channel interceptors are exclusive (one per channel; a second registration throws), and `/api` is already taken by the built-in typert-gateway. Third-party plugins exposing RPC methods should use an exact fetch route instead (`ctx.connection.fetch.register` on e.g. `/api/<plugin>/<method>`, implementing the RPC envelope contract `{ rpcId, method, payload }` → `{ type: "server-response", rpcId, result }` yourself) — grabbing the channel interceptor displaces the built-in one and 404s every llm/session RPC. Plugin peer deps like `@deepseek-ai/dsh-tools` must match the host dsh channel.

> **dsh ≥ 0.1.6-alpha.2 hard-fails on a renamed plugin**: in 0.1.6 the built-in `dsh-workflow-worker-thread` was renamed to `dsh-workflow-ptc` (both the `id` and the package name changed; `config` is unchanged), so a composition row using the old name no longer resolves to a package directory. dsh ≤ alpha.1 **silently ignored** unresolvable plugin rows — presets kept loading and the problem left no trace; alpha.2's plugin resolver turns it into a **hard failure**: the entire agent preset fails to mount, surfacing only as `preset "…" failed to mount: row "…" names a plugin that cannot be resolved` when a session is created. Before upgrading dsh you can self-check through the API: every preset returned by `agentPresets/list` carries a `broken` field (**its absence means upstream's health verdict passed — mountable**).

### Plugin updates and zero-restart activation

Plugin packages are loaded through **stable mount points**: an activation script re-links `/run/dsh/current` (dsh with its plugin tree) and `/run/dsh/nixos-shell` (the sudo executor script) to the current generation's store paths on every switch/boot (GC-safe: the targets always sit in the current toplevel closure, and rollback flips back to the old generation's paths). The `dsh.service` and `nixkits-sudo@.service` unit definitions reference only these stable paths, so **plugin package updates no longer change unit content** — switch-to-configuration neither restarts dsh nor stops/starts the sudo socket, and the activation interrupts no in-flight tool call.

Trade-off: dsh is a long-lived process, so plugin and preset package updates take effect only after an explicit restart — **`systemctl daemon-reload` first, then `systemctl restart dsh`** (`nixos_shell` auto-detaches the restart into a transient unit, returning before it lands). A bare restart sometimes still runs the previous generation's pre-start script, which is exactly the step that copies `cordis.patch.yml` into `$DSH_HOME` (the preset root lives in that file); the symptom is a service that did restart while the preset stays old. After restarting, check that the store path in `$DSH_HOME/profiles/<profile>/cordis.patch.yml` has actually flipped. The sudo executor spawns per connection, so new connections pick up the new script automatically with no restart at all.

## NixKits plugins

Plugins developed in this repo for dsh are **not expanded in this document** — each keeps its own dedicated doc (mounting is covered by `plugins.packages` above):

| Plugin | Description | Doc |
|------|------|------|
| dsh-nixos-shell | Consolidated NixOS scenario capabilities: the `nixos_shell` executor (PATH injection / `nix shell` tool bootstrap / sudo-daemon routing) + `nixos_cli` read-only diagnostics; ships the NixOS mode / maintenance mode Agent presets | [dsh-nixos-shell.md](dsh-nixos-shell.md) |
| dsh-api-balance | 「Usage / Balance」 tab switch in the webui usage panel: account balance, daily / monthly / 30-day consumption charts and voice broadcast (incl. the voice-pack format guide) | [dsh-api-balance.md](dsh-api-balance.md) |

## Modes

A "mode" is a dsh **Agent preset**: each mode is one session shape with its own identity prompt, tool surface, and prompt sections. They sit at the same level as plugins, each with its own dedicated doc, and do not affect one another:

| Mode | id | Description | Distribution | Doc |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | validates the NixOS host at initialization (non-NixOS denies all execution); loads `nixos_shell` / `nixos_cli` and the development prompts | inside the dsh-nixos-shell package, as a **profile patch row** | [modes/nixos.md](modes/nixos.md) |
| 维护模式 | `maintenance` | derived from NixOS模式; injects the `write-project-docs` / `write-maintenance-log` / `nix-flake-update-check` / `nixkits-check-updates` / `translate-*` skills and the maintenance workflow | inside the dsh-nixos-shell package, as a **profile patch row** | [modes/maintenance.md](modes/maintenance.md) |
| 新闻三要素模式 | `news-three-elements` | a read-only creation mode derived from minimal mode: the "three elements of news" are the three protagonists who must all appear; material comes first (only what cannot be tied back is refused), co-created material is searched and re-skinned (no search, no dispatch), online skill package, opening picker, anything not in Simplified Chinese refused | **standalone package** `dsh-preset-news-three-elements`, as a **profile patch row + content directory** | [modes/news-three-elements.md](modes/news-three-elements.md) |

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;         # id `nixos` — NixOS模式
    maintenanceMode = true;   # id `maintenance` — 维护模式 (derived from NixOS模式)
    newsThreeElements = true; # id `news-three-elements` — standalone package
    # Preset content source: by default it follows the dsh channel (stable →
    # dsh-nixos-shell-stable, presets frozen at the pinned rev; alpha →
    # dsh-nixos-shell, following HEAD). You normally leave this alone; align it
    # only when the @kihara777/dsh-nixos-shell injected via plugins.packages
    # comes from a different variant.
    # package = pkgs.dsh-nixos-shell;
  };
}
```

> **As of 0.2.0 there is exactly one distribution mechanism**: every mode is one `@deepseek-ai/dsh-agent-preset` patch row (the module splices it into `$DSH_HOME/profiles/<profile>/cordis.patch.yml`), with the plugin-row body taken **verbatim** from that package's `preset.patch.yml`. The two 0.1.x paths are gone with the upstream change (the `nixosMode`/`maintenanceMode` seed-once directory copy, and the extra roster root for `newsThreeElements`) — the `roots` mechanism no longer exists at all. News Three Elements mode is the only one that still needs a content directory: its plugins are files shipped with the preset rather than an npm package, so the module assembles them under `$DSH_HOME/.agent-presets/news-three-elements/` (rebuilt wholesale, not seed-once) and the patch row refers to them by relative path. Each mode's behavior, composition structure, and maintenance rules live in the docs linked above.

> **Two further modes on the deployment side are not distributed by this repository**: 掌灯模式 (`lampkeeper`, order 12) and Ocean Spiral (`ocean-spiral`, order 14). Their content source is a private repository (Kitsunome), but their 0.2.0 shape is exactly the same as the three above — one patch row plus a content directory assembled under `$DSH_HOME/.agent-presets/<id>/`, with the anchor written as `new URL('../../.agent-presets/<id>/', baseUrl)` (**Ocean Spiral only moved into a repository on 2026-10-02**; before that it existed solely as one deployed copy, with no repository and no seeding). Their consistency checks live there too: `develop/check-lampkeeper-derivation.py` and `develop/check-ocean-spiral-derivation.py`.

### Preset format changes in dsh 0.2.0 (landed 2026-10-02)

dsh 0.2.0 reworked how an Agent preset is carried, and the **directory-based preset channel was removed**:

| | 0.1.x (no longer used as of 0.2.0) | 0.2.0 (current) |
|---|---|---|
| Preset shape | a `$DSH_HOME/.agent-presets/<id>/` directory | one loader patch entry in the profile's user patch layer (`$DSH_HOME/profiles/<profile>/cordis.patch.yml`) |
| Composition and metadata | `agent.cordis.yml` (the full composition) + `preset.yml` (`name` / `description`) | the `config.plugins` of an `@deepseek-ai/dsh-agent-preset` row, plus `config.name` / `config.description` |
| Discovery | `@deepseek-ai/dsh-agent-presets` (plural) scans roots | the Loader tree itself; the plural package **no longer exists** in 0.2.0 |
| Roster ordering | none | `config.order` (built-ins occupy 1–4; must be unique across presets) |
| Host row | `agent-presets` (plural) with its `roots` table | `agent-preset-registry`; `default` is that row's **required config**, and settings keeps only `selectedDefault` |

**Repository HEAD maintains only the new format**: the 0.1.x `agent.cordis.yml` has been deleted from all three preset locations, so the two formats no longer coexist on HEAD — they diverge only at the point of use. The stable channel takes its preset content from the commit pinned in `packages/dsh-nixos-shell-stable.nix` (`0175f85`, **the last commit where both formats coexisted**; 0.1.x users take it by rev), while the alpha channel follows HEAD. Freezing does not mean "stable never updates": it means the update moment is decidable — a preset change on HEAD is exercised through the alpha channel first, and then `pinnedRev` is moved forward by one explicit single-line edit instead of drifting into the stable channel unnoticed.

How the module side (`modules/dsh.nix`) is wired:

- the preset body is spliced **verbatim** into the `cordis.patch.yml` the module already generates (no second mechanism, no copied plugin rows — a copy would inevitably drift);
- it reads the `dsh-nixos-shell` variant's `passthru.presetsSource` (the stable variant uses `builtins.fetchTarball` for the pinned rev, so this is an **evaluation-time read of a source path**, with no import-from-derivation);
- the channel decision comes from the dsh package's own `passthru.dshChannel`, so switching channels is one `nixkits.dsh.package` line and the preset content follows;
- `nixkits.dsh.agentPresets.*` now emits an `- id: agent-preset-registry` patch row; the old `settings."agent-presets"` **fails evaluation outright** — nothing reads that key any more, so leaving it would only lose your declared default silently;
- note: the injected `@kihara777/dsh-nixos-shell` and `presets.package` must be the **same variant** (the preset body comes from the latter while the skill roots resolve to the former at runtime); a mismatch raises a `lib.warn` at evaluation time.

**Per-plugin config schema differences** (each plugin package's `Config` schema compared row by row across the two build artifacts, `0.1.6-alpha.2` → `0.2.0-rc.2`):

| Plugin row | Change | Effect on this preset |
|------------|--------|-----------------------|
| `dsh-tool-bash` / `dsh-tool-pwsh` | new optional `promoteOnTimeout` (default `true`) | this preset **does not set that key** (decision: behaviour defaults follow upstream) → from 0.2.0 a foreground bash call that hits its timeout is **promoted to a background job** instead of being killed |
| `dsh-tool-workflow` | new optional `enableRunInBackground` (default `true`) | unset → gains background capability |
| `dsh-tool-ask-user` | from "no Config" to `{ mode?: "legacy" \| "timed", timeout?: -1 \| number }` (defaults `legacy` / `120`) | unset → behavior matches the old release |
| `dsh-compaction-basic` | new optional `headroomTokens` (the same field is added inside `modelPolicies[]`) | unset → one more tunable only |
| `dsh-tool-jobs` | `maxConsecutiveWakes` is retained, but no longer appears in the schema's default output | unset |
| `dsh-tool-fs-search` | **unchanged**: `sampleOverCapGlobResults` is a **required boolean**, and has been since 0.1.6 | the old file already carries `false`; the new file copies it |
| The other 20 plugin rows | schema is byte-identical | no change needed |

> The comparison covers `dsh-tool-subagent`'s `backgroundMode` / `maxDepth` union, `dsh-plan-mode`'s hand-rolled strict `{ section }` validation (an unknown key is an error), and this repository's three `@kihara777/dsh-nixos-shell` rows — none changed.

> ⚠️ **`promoteOnTimeout` is the only new default in this upgrade that changes day-to-day behavior** (decision: **not written into the preset**, following upstream). Its effect: a foreground bash call that hits its timeout is no longer killed but **promoted to a background job**, and the caller receives a job id; `job_output` / `job_list` / `job_kill` therefore become the way to finish up after a timeout. To get the old behaviour (kill on timeout), write `config.promoteOnTimeout = false` explicitly on that row in the preset — this repository deliberately does not pin it, so that upstream's default can still reach us.

**Four necessary differences from the old files** (copying them verbatim breaks):

1. **`baseUrl` changed meaning.** In 0.1.x it is the preset's own directory; in 0.2.0 it is measured to be the **profile directory** (`$DSH_HOME/profiles/<profile>/`). The old file writes its skill roots as `new URL('skills/', baseUrl)`, which would point at `<profile>/skills/` and make the skills **vanish silently**. This repository's two presets resolve the `@kihara777/dsh-nixos-shell` package root from `baseUrl` and append `presets/<mode>/`; the two presets in the private repository derive `../../.agent-presets/<id>/` instead — both carry an **existence guard**, so a wrong anchor becomes `broken` rather than degrading into "no skills".
2. Metadata (the old `preset.yml` `name` / `description`) moved into `config.name` / `config.description`.
3. `config.order` is new.
4. **Relative plugin paths must be re-anchored**: a relative specifier has to start with `.` (the loader resolves only those against `baseUrl`; **an absolute path is imported as a bare package name and fails**), and since `baseUrl` is now the profile directory, `./plugins/x.js` becomes `../../.agent-presets/<id>/plugins/x.js`. Consequence: if a preset's own plugin files import `@deepseek-ai/*` peers by bare name, the module must link `@deepseek-ai` into `$DSH_HOME/node_modules` too, or that row only reports `… never started` (see "How to tell a preset actually mounted" below).

#### How to tell a preset actually mounted

**"It is in the roster" does not mean the migration succeeded**: when a preset fails to mount, 0.2.0 only reports a `broken` field on that entry in `agentPresets/list` — **no such field means it passed the upstream health check**. The criterion is executable:

```bash
# how the throwaway instance does it: start dsh → grab the token from boot.log
# → exchange it for a cookie → call the RPC
curl -sS -b cookies -H 'content-type: application/json' \
  -d '{"type":"client-request","rpcId":"1","method":"agentPresets/list","payload":{"args":{}}}' \
  http://127.0.0.1:<port>/api/agentPresets/list
```

The 2026-10-02 landing acceptance (throwaway `DSH_HOME`, `dsh 0.2.0-rc.2`): **9 entries** (4 built-ins + `nixos` order 10 + `maintenance` 11 + `lampkeeper` 12 + `news-three-elements` 13 + `ocean-spiral` 14) with **every `broken` empty**; three counterexamples each changed **one place in a real file**:

| Counterexample | What was changed (one place) | The `broken` reported by `agentPresets/list` |
|------|-----------------|-----------------------------------|
| package name | `tool-fs-search`'s package name changed to the nonexistent `@deepseek-ai/dsh-tool-fs-searchX` | `tool-fs-search (@deepseek-ai/dsh-tool-fs-searchX): never started` (all 5 derived presets report it — they share the same row) |
| anchor | Ocean Spiral's skill root `../../.agent-presets/ocean-spiral/` → `…ocean-spiral-typo/` | `skill-filesystem (…): ocean-spiral skill roots missing: <path>` + `oceanspiral-scene (…): never started` |
| assembly | one missing `@deepseek-ai` link under `$DSH_HOME/node_modules` | `lampkeeper-shell (../../.agent-presets/lampkeeper/components/lib/index.js): never started` |

That last row is **a real trap this landing fixed**: a preset's own plugin files live under `$DSH_HOME/.agent-presets/<id>/…`, and when they import peers by bare name Node walks up from the **file's own directory** looking for `node_modules`. The module used to link only `@kihara777`, so after a dsh restart 掌灯模式 turned `broken` — the two were stepping on each other inside one `$DSH_HOME`. The module now links both `@kihara777` and `@deepseek-ai`.

**persona and bundled skills (corrections after the 2026-10-02 landing)**: two stale statements have been corrected, and neither is an undecided item any more.

- **persona**: the sentence in the new-format files — "presets live under the `$DSH_HOME/.agent-presets/<id>/` directory" — has been changed to the accurate 0.2.0 statement: a preset is one `@deepseek-ai/dsh-agent-preset` entry in the profile `cordis.patch.yml`, and **discovery goes through that row**; a preset can still put its own files under `.agent-presets/<id>/` and reference them from the profile by relative path, and several presets in this deployment carry their plugins and skills exactly that way. Rewriting it amounts to changing **the prompt sent to the model** — a behaviour change the maintainer has since approved separately.
- **bundled skills**: the two presets used to **ship their own** copies of `cordis-plugin-development` and `editing-cordis-compositions`. 0.2.0 distributes those two (plus `agent-experience` / `cordis-composition-reference`) with `@deepseek-ai/dsh-agent-preset`, while our two copies were still stuck on the 0.1.x directory-based preset model — so there were two of each name, one of them teaching a deprecated approach (the new upstream version says outright *"Nothing reads that directory any more"*). The `skill-filesystem` row in both presets now **mounts upstream's copy directly** (the same expression as the built-in `cordis` preset), keeping only `skills-nixos/` (the NixOS operations skills), which upstream does not have. `develop/check-preset-derivation.py` pins "no bundled copies any more" as an assertion; the two copies that used to be bundled can still be taken from the rev the stable channel is pinned to (0.1.x compatibility).

## Sudo daemon

Inside the dsh sandbox `sudo` loses its setuid bit, so the agent cannot elevate (e.g. `nixos-rebuild`). `sudo.enable` deploys a systemd **socket-activated root executor** (`nixkits-sudo@.service`, running `nixkits-sudo-exec` once per connection) and injects `NIXKITS_SUDO_SOCKET` into the dsh service. The nixos-shell plugin probes that socket at apply time, advertises the `sudo` parameter when present, and routes requests through it:

```nix
{
  nixkits.dsh.sudo = {
    enable = true;
    socketPath = "/run/nixkits-sudo.sock";  # default
  };
}
```

> **Security model**: the socket file is owned by the dsh service user with mode `0600` (`SocketUser`/`SocketMode`), so only that user can connect — equivalent to passwordless root for that user; enable only when both the user and the agent's behavior are trusted.


## Plugin inventory

Built-in plugin entry ids for dsh 0.2.0-rc.2 (valid values for `nixkits.dsh.plugins.disabled`, `id -> package`):

> **Regenerating this list**: `dsh --profile web --dump-default-config` (read-only) prints the `id -> name` pairs directly; re-run it after upgrading and treat the installed version's output as authoritative. This list covers the web profile's base + web-app patch set.

```text
  tool-plugin-manager -> @deepseek-ai/dsh-plugin-manager/tools
  plugin-manager -> @deepseek-ai/dsh-plugin-manager
  timer -> @deepseek-ai/cordis-plugin-timer
  hmr -> @deepseek-ai/dsh-hmr
  llm -> @deepseek-ai/dsh-llm
  deepseek-llm-api-extensions -> @deepseek-ai/dsh-deepseek-llm-api-extensions
  session -> @deepseek-ai/dsh-session
  session-log-deepseek -> @deepseek-ai/dsh-session-log-deepseek
  typert -> @deepseek-ai/dsh-typert-registry
  typert-loader -> @deepseek-ai/dsh-typert-loader
  typert-gateway -> @deepseek-ai/dsh-api-gateway
  session-title -> @deepseek-ai/dsh-session-title
  session-title-llm -> @deepseek-ai/dsh-session-title-first-prompt-llm
  user-questions -> @deepseek-ai/dsh-user-questions
  agent -> @deepseek-ai/dsh-agent
  plugin-package-inventory-deepseek -> @deepseek-ai/dsh-plugin-package-inventory-deepseek
  agent-default-model -> @deepseek-ai/dsh-agent-default-model
  jobs -> @deepseek-ai/dsh-jobs-local
  llm-retry -> @deepseek-ai/dsh-llm-retry
  config-editor -> @deepseek-ai/dsh-config-editor
  settings -> @deepseek-ai/dsh-settings
  authorization -> @deepseek-ai/dsh-authorization
  deepseek-account -> @deepseek-ai/dsh-deepseek-account-platform
  credentials -> @deepseek-ai/dsh-credentials-local
  llm-pi-ai -> @deepseek-ai/dsh-llm-pi-ai
  session-persistence-jsonl -> @deepseek-ai/dsh-session-persistence-jsonl
  attachment-local -> @deepseek-ai/dsh-attachment-local
  session-query-sqlite -> @deepseek-ai/dsh-session-query-sqlite
  session-projection -> @deepseek-ai/dsh-session-projection
  storage -> @deepseek-ai/dsh-storage
  storage-json -> @deepseek-ai/dsh-storage-json
  storage-domain -> @deepseek-ai/dsh-storage-domain
  session-projection-cache -> @deepseek-ai/dsh-session-projection-cache
  otel -> @deepseek-ai/dsh-otel
  session-telemetry-otel -> @deepseek-ai/dsh-session-telemetry-otel
  subprocess -> @deepseek-ai/dsh-subprocess-local
  sandbox -> @deepseek-ai/dsh-sandbox-local
  sandbox-policy -> @deepseek-ai/dsh-sandbox-policy
  bash-sandbox -> @deepseek-ai/dsh-bash-sandbox
  pwsh-sandbox -> @deepseek-ai/dsh-pwsh-sandbox
  approval -> @deepseek-ai/dsh-user-approval
  permission -> @deepseek-ai/dsh-permission-presets
  shell-env -> @deepseek-ai/dsh-shell-env
  tool-bash -> @deepseek-ai/dsh-tool-bash
  tool-pwsh -> @deepseek-ai/dsh-tool-pwsh
  tool-jobs -> @deepseek-ai/dsh-tool-jobs
  fs-observation-policy -> @deepseek-ai/dsh-fs-observation-policy
  tool-fs -> @deepseek-ai/dsh-tool-fs
  tool-fs-search -> @deepseek-ai/dsh-tool-fs-search
  agent-instructions -> @deepseek-ai/dsh-agent-instructions
  skill -> @deepseek-ai/dsh-skill
  skill-filesystem -> @deepseek-ai/dsh-skill-filesystem
  skill-badge -> @deepseek-ai/dsh-skill-badge
  tool-skill -> @deepseek-ai/dsh-tool-skill
  commands -> @deepseek-ai/dsh-commands
  command-feedback -> @deepseek-ai/dsh-command-feedback
  goal -> @deepseek-ai/dsh-goal
  goal-round-driver -> @deepseek-ai/dsh-goal-round-driver
  command-goal -> @deepseek-ai/dsh-command-goal
  plan-mode -> @deepseek-ai/dsh-plan-mode
  token-meter -> @deepseek-ai/dsh-token-meter
  compaction-basic -> @deepseek-ai/dsh-compaction-basic
  command-compact -> @deepseek-ai/dsh-command-compact
  subagent -> @deepseek-ai/dsh-subagent
  subagent-spawn-in-process -> @deepseek-ai/dsh-subagent-spawn-in-process
  subagent-fork-in-process -> @deepseek-ai/dsh-subagent-fork-in-process
  tool-subagent-control -> @deepseek-ai/dsh-tool-subagent-control
  tool-subagent-list-agents -> @deepseek-ai/dsh-tool-subagent-control/list-agents
  tool-subagent -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-fork -> @deepseek-ai/dsh-tool-subagent
  ptc-runtime -> @deepseek-ai/dsh-ptc-runtime-node
  workflow-ptc -> @deepseek-ai/dsh-workflow-ptc
  tool-workflow -> @deepseek-ai/dsh-tool-workflow
  timeout-policy -> @deepseek-ai/dsh-tool-call-timeout-policy
  spill-local -> @deepseek-ai/dsh-spill-local
  spill-policy -> @deepseek-ai/dsh-spill-policy
  session-checkpoint-policy -> @deepseek-ai/dsh-session-checkpoint-policy
  tool-result-pruner -> @deepseek-ai/dsh-compaction-tool-result-pruner
  image-offload -> @deepseek-ai/dsh-compaction-image-offload
  tool-todo -> @deepseek-ai/dsh-tool-todo
  tool-goal -> @deepseek-ai/dsh-tool-goal
  tool-ralph -> @deepseek-ai/dsh-tool-ralph
  repeat-tool-reminder -> @deepseek-ai/dsh-repeat-tool-reminder
  web -> @deepseek-ai/dsh-web
  web-search-deepseek -> @deepseek-ai/dsh-web-search-deepseek
  web-fetch-http -> @deepseek-ai/dsh-web-fetch-http
  tool-web -> @deepseek-ai/dsh-tool-web
  mcp-resources -> @deepseek-ai/dsh-mcp-resources
  tools -> @deepseek-ai/dsh-tools
  system-prompt -> @deepseek-ai/dsh-system-prompt
  agent-loop -> @deepseek-ai/dsh-agent-loop
  fs-sandbox -> @deepseek-ai/dsh-fs-sandbox
  llm-deepseek -> @deepseek-ai/dsh-llm-deepseek-api-key
  llm-deepseek-account -> @deepseek-ai/dsh-llm-deepseek-account
  desktop-product-telemetry -> @deepseek-ai/dsh-host-product-telemetry-otel
  product-analytics -> @deepseek-ai/dsh-client-product-analytics
  subagent-model-selection-settings -> @deepseek-ai/dsh-tool-subagent/model-selection-settings
  message-feedback -> @deepseek-ai/dsh-message-feedback
  session-log-download -> @deepseek-ai/dsh-session-log-export
  open-in-app -> @deepseek-ai/dsh-host-open-in-app
  ui-open-in-app -> @deepseek-ai/dsh-client-ui-open-in-app
  workspace -> @deepseek-ai/dsh-workspace
  session-reference -> @deepseek-ai/dsh-session-reference
  file-reference-local -> @deepseek-ai/dsh-file-reference-local
  session-stats -> @deepseek-ai/dsh-session-stats
  session-turn-outline -> @deepseek-ai/dsh-session-turn-outline
  directory-picker -> @deepseek-ai/dsh-host-directory-picker-auto
  plugin-inventory -> @deepseek-ai/dsh-host-plugin-inventory
  session-controller -> @deepseek-ai/dsh-api-session-controller
  job-controller -> @deepseek-ai/dsh-api-job-controller
  terminal-controller -> @deepseek-ai/dsh-api-terminal-controller
  workspace-files -> @deepseek-ai/dsh-api-workspace-files
  ui-settings-account -> @deepseek-ai/dsh-client-ui-settings-account
  account-controller -> @deepseek-ai/dsh-api-account-controller
  settings-controller -> @deepseek-ai/dsh-api-settings-controller
  workspace-controller -> @deepseek-ai/dsh-api-workspace-controller
  cordis-host-runner -> @deepseek-ai/dsh-cordis-host-runner
  cordis-inspect-providers -> @deepseek-ai/dsh-tool-cordis/host
  web-startup -> @deepseek-ai/dsh-web-app/startup
  webserver -> @deepseek-ai/dsh-host-webserver
  web-runtime -> @deepseek-ai/dsh-web-app
  client-hmr -> @deepseek-ai/dsh-client-hmr
  modules -> @deepseek-ai/dsh-client-modules
  connection -> @deepseek-ai/dsh-client-connection
  file-upload -> @deepseek-ai/dsh-client-file-upload
  api-remotes -> @deepseek-ai/dsh-api-remotes
  cordis-client-runner -> @deepseek-ai/dsh-cordis-client-runner
  ui-theme -> @deepseek-ai/dsh-client-ui-theme
  locale -> @deepseek-ai/dsh-client-locale
  shortcuts -> @deepseek-ai/dsh-client-shortcuts
  ui-shortcuts -> @deepseek-ai/dsh-client-ui-shortcuts
  ui-layout -> @deepseek-ai/dsh-client-ui-layout
  ui-renderer -> @deepseek-ai/dsh-client-ui-renderer
  ui-session -> @deepseek-ai/dsh-client-ui-session
  resources -> @deepseek-ai/dsh-client-resources
  ui-sidebar -> @deepseek-ai/dsh-client-ui-sidebar
  ui-sidebar-right -> @deepseek-ai/dsh-client-ui-sidebar-right
  office-to-pdf -> @deepseek-ai/dsh-office-to-pdf
  ui-sidebar-documentpreview -> @deepseek-ai/dsh-client-ui-sidebar-documentpreview
  ui-sidebar-browser -> @deepseek-ai/dsh-client-ui-sidebar-browser
  ui-sidebar-terminal -> @deepseek-ai/dsh-client-ui-sidebar-terminal
  ui-sidebar-files -> @deepseek-ai/dsh-client-ui-sidebar-files
  ui-settings -> @deepseek-ai/dsh-client-ui-settings
  ui-settings-general -> @deepseek-ai/dsh-client-ui-settings-general
  ui-settings-models -> @deepseek-ai/dsh-client-ui-settings-models
  ui-plugin-manager -> @deepseek-ai/dsh-client-ui-plugin-manager
  ui-settings-plugin-inventory -> @deepseek-ai/dsh-client-ui-settings-plugin-inventory
  ui-conversation -> @deepseek-ai/dsh-client-ui-conversation
  ui-approval -> @deepseek-ai/dsh-client-ui-approval
  ui-chat -> @deepseek-ai/dsh-client-ui-chat
  ui-brand-official -> @deepseek-ai/dsh-client-ui-brand-official
  ui-attachment -> @deepseek-ai/dsh-client-ui-attachment
  ui-tool -> @deepseek-ai/dsh-client-ui-tool
  ui-cordis -> @deepseek-ai/dsh-client-ui-cordis
  ui-deliverables -> @deepseek-ai/dsh-client-ui-deliverables
  workspace-changes -> @deepseek-ai/dsh-workspace-changes
  ui-workspace -> @deepseek-ai/dsh-client-ui-workspace
  ui-workflow-run -> @deepseek-ai/dsh-client-ui-workflow-run
  ui-input-trigger -> @deepseek-ai/dsh-client-ui-input-trigger
  ui-commands -> @deepseek-ai/dsh-client-ui-commands
  ui-skill -> @deepseek-ai/dsh-client-ui-skill
  ui-subagent -> @deepseek-ai/dsh-client-ui-subagent
  ui-reference -> @deepseek-ai/dsh-client-ui-reference
  ui-jobs -> @deepseek-ai/dsh-client-ui-jobs
  ui-goal -> @deepseek-ai/dsh-client-ui-goal
  ui-message-feedback -> @deepseek-ai/dsh-client-ui-message-feedback
  ui-model-selection -> @deepseek-ai/dsh-client-ui-model-selection
  ui-permission -> @deepseek-ai/dsh-client-ui-permission-presets
  ui-agent-preset -> @deepseek-ai/dsh-client-ui-agent-preset
  ui-settings-session-log -> @deepseek-ai/dsh-client-ui-settings-session-log
  ui-settings-plugins -> @deepseek-ai/dsh-client-ui-settings-plugins
  ui-settings-shell -> @deepseek-ai/dsh-client-ui-settings-shell
  ui-settings-agent-loop -> @deepseek-ai/dsh-client-ui-settings-agent-loop
  ui-settings-subagent -> @deepseek-ai/dsh-client-ui-settings-subagent
  ui-settings-web-search -> @deepseek-ai/dsh-client-ui-settings-web-search
  ui-plan -> @deepseek-ai/dsh-client-ui-plan
  ui-user-questions -> @deepseek-ai/dsh-client-ui-user-questions
  ui-trajectory -> @deepseek-ai/dsh-client-ui-trajectory
  agent-preset-registry -> @deepseek-ai/dsh-agent-preset-registry
  preset-standard -> @deepseek-ai/dsh-agent-preset
  preset-ptc -> @deepseek-ai/dsh-agent-preset
  preset-minimal -> @deepseek-ai/dsh-agent-preset
  preset-cordis -> @deepseek-ai/dsh-agent-preset
```

## Declarative settings

dsh settings-menu options live in `$DSH_HOME/settings.yaml` (file-backed, hot-reloaded). `nixkits.dsh.settings` provides declarative config (namespace → section):

```nix
{
  nixkits.dsh.settings = {
    "web-search-deepseek" = {
      model = "deepseek-flash";
      maxTokens = 8192;
    };
    "llm-deepseek" = {
      timeout = 10000;
    };
  };
}
```

- namespace maps to a settings-UI section (e.g. `web-search-deepseek`, `llm-deepseek`, `ui-onboarding`)
- values must be JSON-compatible (string/number/boolean/list/object)
- rendered as JSON (valid YAML), hot-reloaded; empty `{}` or missing falls back to schema defaults

### Declaratively configurable host namespaces

`nixkits.dsh.settings` can only write into **namespaces registered host-side via `settings.installSection` / `settings.register`** — these values live in `$DSH_HOME/settings.yaml` and are consistent across browsers. All **15** namespaces registered in `0.1.6-alpha.2`, with their fields (extracted one by one by measuring each plugin source's `z.object({...})` / `Schema.object({...})`):

| namespace | fields | description |
|-----------|--------|-------------|
| `agent-default-model` | `provider`, `model`, `reasoningEffort` (`off`/`low`/`high`/`max`) | default model for new sessions |
| `agent-loop` | `maxParallelToolCalls` (integer ≥1, default 10) | per-turn parallel tool-call ceiling |
| `agent-preset-registry` | `selectedDefault` (preset id, `.volatile()` — the only settings-side field; the row config's `default` is a **required row config**, not a settings field) | agent-preset registry. **0.1.x's `agent-presets` (plural) row and its whole `roots` mechanism are gone in 0.2.0**; the default preset is declared by this row's `config.default`, and a stale old key is read by nothing — this module turns a leftover into an evaluation error |
| `llm-deepseek` | `protocol`, `apiKeyEnv`, `baseURL`, `thinking`, `reasoningEffort`, `maxTokens`, `defaultContextWindow`, `streamIdleTimeoutMs`, `models`, `retryPolicy`, plus file/image byte budgets | native DeepSeek adapter |
| `llm-pi-ai` | `providers` (dict: route → provider profile) | the pi-ai adapter's provider route table (this machine's llama-local route lives here) |
| `locale` | `preference` (BCP 47; built-in `zh`/`en`) | interface language |
| `permission` | `defaultPreset` (**required**; values are keys of the presets table) | permission presets |
| `shell` | `cwd` (**no default**), `timeoutMs`, `maxTimeoutMs`, `maxOutputBytes`, `maxSpillBytes`, `graceMs` | local shell executor limits (bash-local on Linux; pwsh-local on win32, plus `pwshPath`) |
| `subagent` | `maxDepth` (integer ≥0, default 1), `maxActiveSubagents` (integer ≥1, default 8) | subagent depth and concurrency ceilings |
| `subagent-model-selection` | `enabled` (boolean, default false), `allowedModels` (`{provider, model}` array) | subagent model selection |
| `ui-chat` | `transcriptView` (`normal`/`compact`) | conversation-transcript display density |
| `ui-conversation` | `busyEnter` (`queue`/`steer`) | Enter behavior while busy |
| `ui-onboarding` | `welcomeNoticeVersion` | onboarding-step state (written by dsh itself) |
| `ui-theme` | `preference` (`light`/`dark`/`system`), `fontSize` (12–17) | appearance & theme |
| `web-search-deepseek` | `apiKey` (secret), `apiKeyEnv`, `baseURL`, `model` (default `deepseek-v4-flash`), `apiVersion`, `maxTokens` (≥1, default 4096), `maxUses` (≥1, default 5) | web-search backend |

> ⚠️ This table was originally transcribed from `0.1.5-rc.2`, and **5 of its rows disagreed with measurement**; all were checked item by item and corrected on 2026-09-23:
> `locale`'s field is `preference`, not `language`; `ui-theme` has only `preference`/`fontSize`
> (there are no `dark`/`light`/`body` fields — `dark`/`light` are **values** of `preference`);
> `shell` has no `dshHome` field: it is actually six executor limits; `subagent-model-selection`'s
> top level is `enabled`/`allowedModels` (`provider`/`model` are fields of its **array elements**);
> `agent-default-model` requires only `provider`/`model`, and `reasoningEffort` may be omitted.
>
> **The criterion**: this table can only be derived by reading the plugin sources — any "plausible-looking" field name may be a product of memory — so re-measure when dsh is next upgraded, and do not make incremental guesses on this table.

> ⚠️ **Second pass, 2026-10-02 (`0.1.6-alpha.2`)**: the entry count is corrected from 12 to **15** — the old table **missed three host namespaces**: `llm-deepseek`, `llm-pi-ai`, and `subagent` (the first two are registered by model adapters, the third by `@deepseek-ai/dsh-subagent`; the earlier grep only covered `installSection` call sites and overlooked them). The same pass overturned one old conclusion: "`shell`'s `cwd` has no default ⇒ it cannot be declared partially" **is wrong** — a schemastery field without `.required()` is optional to begin with (measured: `z.object({cwd: z.string()})({})` passes); only `.required()` makes a missing field fail with `missing required value`.
>
> Census criterion: trust the **call sites** of `grep -rn 'settings\.installSection(\|settings\.register('` across the install tree (`@deepseek-ai/dsh-settings` itself and its reader `dsh-tool-cordis` are the **implementations** of that API, not registrants of a namespace).

> **Settings-menu storage boundary**: not every entry in the settings UI is declaratively configurable via `nixkits.dsh.settings`. The **dsh-api-balance interface / voice settings** (voice alerts, bottom stats-bar horizontal scroll, Enter-newline + Shift+Enter-send swap, mobile session-switch keyboard suppression, TTS backend) are **browser localStorage state** (per-browser, enabled by default, toggled in the UI) and do **not** go through the `settings.installSection` system — so `$DSH_HOME/settings.yaml` / `nixkits.dsh.settings` does **not** override them. Configure these per-browser preferences in the plugin's `⚙ Settings` panel, or deploy a separate browser per device.

### Structured options and the escape hatch

All 15 namespaces in the table above can be written directly through `nixkits.dsh.settings.<namespace>` — that is the **untyped escape hatch**. Its cost comes in two kinds, **one silent and one audible**:

- **A misspelled field name → completely silent.** schemastery's `z.object` is **open**: an unknown key is preserved as-is while the field it was meant to be keeps its schema default. Measured (`0.1.6-alpha.2`): `schema({ maxParallelToolCall: 4 })` yields `{ maxParallelToolCalls: 10, maxParallelToolCall: 4 }` — no evaluation error, no runtime error, nothing in the log, **only a value that never took effect**.
- **A wrong type / out-of-range value → audible, but only in the log.** dsh refuses that section: at startup the namespace's registration fails outright; on a runtime hot-reload it logs the warn `settings: keeping last good "<ns>" after invalid stored section` and keeps the previous good value.

So the module provides **structured options** for 13 of them (Nix-side mirrors of the upstream schemas, turning both classes into evaluation-time errors):

| option | namespace written | plugin |
|--------|-------------------|--------|
| `nixkits.dsh.defaultModel` | `agent-default-model` | `@deepseek-ai/dsh-agent-default-model` |
| `nixkits.dsh.agentLoop` | `agent-loop` | `@deepseek-ai/dsh-agent-loop` |
| `nixkits.dsh.subagentModelSelection` | `subagent-model-selection` | `@deepseek-ai/dsh-tool-subagent` |
| `nixkits.dsh.permission` | `permission` | `@deepseek-ai/dsh-permission-presets` |
| `nixkits.dsh.agentPresets` | **no longer a settings namespace**: it emits the `agent-preset-registry` row's `config.default` (row config). To write the settings-side `selectedDefault`, use the escape hatch `settings."agent-preset-registry".selectedDefault` | `agent-preset-registry` row = `@deepseek-ai/dsh-agent-preset-registry` (as of 0.2.0; 0.1.x's plural `@deepseek-ai/dsh-agent-presets` package no longer exists) |
| `nixkits.dsh.subagent` | `subagent` | `@deepseek-ai/dsh-subagent` |
| `nixkits.dsh.shell` | `shell` | `@deepseek-ai/dsh-bash-local` / `dsh-pwsh-local` (the namespace belongs to `@deepseek-ai/dsh-shell`) |
| `nixkits.dsh.webSearchDeepSeek` | `web-search-deepseek` | `@deepseek-ai/dsh-web-search-deepseek` |
| `nixkits.dsh.llmDeepSeek` | `llm-deepseek` | `@deepseek-ai/dsh-llm-deepseek` |
| `nixkits.dsh.locale` | `locale` | `@deepseek-ai/dsh-client-locale` |
| `nixkits.dsh.ui.theme` | `ui-theme` | `@deepseek-ai/dsh-client-ui-theme` |
| `nixkits.dsh.ui.chat` | `ui-chat` | `@deepseek-ai/dsh-client-ui-chat` |
| `nixkits.dsh.ui.conversation` | `ui-conversation` | `@deepseek-ai/dsh-client-ui-conversation` |

**All three follow the same semantics**: an option defaults to `enable = false` (nothing is written to settings.yaml, so that namespace falls back to the schema default); with `enable = true` the section is generated from its sub-options; and an **explicit `nixkits.dsh.settings.<same namespace>` always wins** over the value a structured option generates.

The remaining two namespaces **deliberately get no structured option**, for different reasons:

- `ui-onboarding`: pure client onboarding state (`welcomeNoticeVersion` is written by dsh itself once the user finishes onboarding). There is no legitimate declarative use; writing it only makes the onboarding flow replay or skip according to a version number handed in from outside — state the user should click through, not state Nix should dictate.
- `llm-pi-ai`: its field is a `providers` dict (route → provider profile), and a profile is **deeply nested** (`models` catalogue, `modelOverrides`, `compat`, `thinkingBudgets`, `retryPolicy`, …); `api`'s enum comes from the bundled pi-ai protocol registry `supportedProtocols()` — **an open set that drifts with the pi-ai version**, so typing it would rot immediately into "looks configurable, actually rejects new protocols". It also already has a better home on this machine: `nixkits.dsh.plugins.settings."llm-pi-ai".providers` (a composition-row config, see the "Declarative plugin management" section above).

On the write policy (which fields carry a concrete default and which use `null` for "not declared"):

- the schema has a default **and** the built-in composition row agrees with it → write the concrete default unconditionally, which is semantically identical to omitting it;
- the schema has no default (the deployment/adapter/process environment decides), or the composition baseline **deviates** from the schema default → use `null` for "not declared", dropped at render time.

The second rule is not pedantry: `shell`'s `timeoutMs` is the case in point — the schema default is 120000, while the built-in `bash-sandbox` row configures **60000**. Were "enable means write everything", `shell.enable = true` would silently turn 60000 into 120000 — exactly the silent value change this module exists to prevent. So `nixkits.dsh.shell.timeoutMs = null` (the default) keeps 60000, and only an explicit 120000 restores the upstream default. Likewise `web-search-deepseek.baseURL` and `llm-deepseek.baseURL` stay `null`: when unset they fall back to `$DEEPSEEK_SEARCH_BASE_URL` / `$DEEPSEEK_BASE_URL`, and a hard-coded literal would shadow the environment variable.

Also, `web-search-deepseek.apiKey` is deliberately not mirrored: it carries `role("secret")`, so writing it into settings.yaml would land the API key in `/nix/store` (world-readable). Keys go through `apiKeyEnv` plus systemd `LoadCredential`.

```nix
{
  nixkits.dsh = {
    # default model for new sessions
    defaultModel = {
      enable = true;
      provider = "deepseek-official";
      model = "deepseek-flash";  # the only id all three catalogues carry, declaring image input in each
      reasoningEffort = "max";
    };
    # per-turn parallel tool-call ceiling
    agentLoop = { enable = true; maxParallelToolCalls = 10; };
    # allowlist of models a subagent may use (enable also turns the feature's own enabled on)
    subagentModelSelection = {
      enable = true;
      allowedModels = [
        { provider = "deepseek-official"; model = "deepseek-flash"; }
      ];
    };
    # default permission preset for new sessions (values come from the composition row's presets table)
    permission = { enable = true; defaultPreset = "danger-full-access"; };
    # agent preset mounted by default for new sessions
    agentPresets = { enable = true; default = "lampkeeper"; };
    # subagent depth and concurrency ceilings
    subagent = { enable = true; maxDepth = 2; maxActiveSubagents = 12; };
    # local shell executor: declare only what you change; unset fields keep the composition baseline (timeoutMs baseline is 60000)
    shell = { enable = true; timeoutMs = 300000; maxTimeoutMs = 1800000; };
    # web-search backend
    webSearchDeepSeek = { enable = true; model = "deepseek-flash"; maxTokens = 8192; };
    # native DeepSeek adapter: thinking and stream idle timeout
    llmDeepSeek = {
      enable = true;
      thinking = "enabled";
      reasoningEffort = "high";
      streamIdleTimeoutMs = 3600000;  # a per-chunk gap timeout, not a total-duration one
    };
    # interface language pinned to Chinese; unset follows each browser's Accept-Language
    locale = { enable = true; preference = "zh"; };
    ui = {
      theme = { enable = true; preference = "dark"; fontSize = 14; };
      chat = { enable = true; transcriptView = "compact"; };
      conversation = { enable = true; busyEnter = "queue"; };
    };
  };
}
```

### Default model (defaultModel)

`nixkits.dsh.defaultModel` provides a structured declarative option for the new-session default model (backed by `@deepseek-ai/dsh-agent-default-model`, written to `settings."agent-default-model"`). Defaults to `enable = false` (no injection); with `enable = true` it renders the subsection below, and an **explicit `nixkits.dsh.settings."agent-default-model"` always wins** over the generated default:

```nix
{
  nixkits.dsh.defaultModel = {
    enable = true;
    provider = "deepseek-official";  # default
    model = "deepseek-flash";        # default
    reasoningEffort = "off";         # default
  };
}
```

#### The model catalogue moves with the dsh version

The `deepseek-official` route's model catalogue is **built into** the adapter (`DEFAULT_MODELS` in `dsh-llm-deepseek`) rather than read from the settings document, so it changes with the dsh version:

| dsh version | catalogue entries | of those, declaring image input |
|-------------|-------------------|---------------------------------|
| stable `0.1.5-rc.2`, alpha `0.1.6-alpha.1` | `deepseek-flash`, `deepseek-v4-flash`, `deepseek-v4-pro`, `deepseek-v4-flash-vision-exp` | `deepseek-flash`, `deepseek-v4-flash-vision-exp` |
| alpha `0.1.6-alpha.2` | `deepseek-flash`, `deepseek-v4-pro` | `deepseek-flash` |
| **both channels `0.2.0-rc.2` (current)** | `deepseek-flash`, `deepseek-v4-pro` | `deepseek-flash` |

`deepseek-flash` is the only id **present in all three** catalogues **and declaring the image modality in each** — which is why the module default picks it. The other image-capable id, `deepseek-v4-flash-vision-exp`, exists only in the two older catalogues and upstream retired it on 2026-09-10, so it cannot serve as a default.

When upstream shipped DeepSeek-V4.1-Flash on 2026-09-10 it retired V4 Flash and V4 Flash Vision Exp, collapsing the model names to `deepseek-flash` (natively multimodal, image understanding included) and `deepseek-v4-pro`. The retired ids still answer for compatibility, but V4.1-Flash serves them and they bill at Flash rates (see the footnote on [Models & Pricing](https://api-docs.deepseek.com/quick_start/pricing/)).

> ⚠️ **An id the catalogue does not carry is not "the same thing under another name"**: dsh treats an uncatalogued id as a **text-only** model (`modelInfo` falls back to `inputModalities: ["text"]`), and the consequence splits into two paths — **one is loud, one is silent**:
>
> - **A newly attached image is rejected outright**: the attachment admission on `session/prompt` reads that same `inputModalities` and throws `MODEL_DOES_NOT_SUPPORT_IMAGES`, surfacing as "The current model does not support images; switch to a model that does".
> - **An image already in the history is dropped silently**: before dispatch, `projectImagesForTextModel` swaps it for a text placeholder — no error is raised, and the model never sees the picture.
>
> When choosing a default, pick an id the catalogue carries. The verdict also moves with the dsh version — the same settings can go from "sees images" to "refuses images" across an upgrade.

#### reasoningEffort tiers and cost

| reasoningEffort | behavior | cost |
|-----------------|----------|------|
| `off` | non-thinking: no chain-of-thought, maps to `thinking:disabled` | **cheapest** (no reasoning tokens), lowest latency; **the only tier FIM completion supports** |
| `low` | thinking on, lightest effort | slightly more than off (a few reasoning tokens) |
| `high` | adapter default (dsh-llm-deepseek default is high), balanced quality/speed | output includes the reasoning segment, larger token share |
| `max` | strongest reasoning, best quality | **most expensive** (largest output-token share) |

> `off` mapping to `thinking:disabled` is the prerequisite for enabling FIM (fill-in-the-middle) completion — DeepSeek marks FIM "non-thinking mode only". The upstream [FIM completion API](https://api-docs.deepseek.com/api/create-completion/) accepts only `deepseek-flash` and `deepseek-v4-pro` as `model`, and both are "non-thinking mode only".
