# NixKits

[中文](../README.md) | English | [日本語](README.ja.md)  | [偽中国語](README.pcn.md)

NixKits — a collection of software, patches, NixOS modules, and AI coding assistant skills.

## Quick Start

```nix
# Remote
inputs.nixkits.url = "github:Kihara777/NixKits";

# Local
inputs.nixkits.url = "~/NixKits";
```

## Software

All packages follow nixpkgs platform support by default (`lib.platforms.linux`). Some packages have architecture restrictions due to upstream — see build badges in each package's documentation.

| Software | Description | Docs |
|---|------|------|
| blender-mcp | MCP server for Blender (natural language control of Blender) | [docs/en/blender-mcp.md](en/blender-mcp.md) |
| codewhale | DeepSeek V4 terminal coding agent | [docs/en/codewhale.md](en/codewhale.md) |
| dsh | DeepSeek Harness (DSH) — Everything is a Plugin | [docs/en/dsh.md](en/dsh.md) |
| dsh-alpha | DeepSeek Harness (DSH) — alpha development channel (0.1.6-alpha.1) | [docs/en/dsh.md](en/dsh.md) |
| godot-ai | MCP server and AI tools for the Godot engine | [docs/en/godot-ai.md](en/godot-ai.md) |
| kitsfmt | Nix formatter (AST sorting + best-practice auto-fixes) | [docs/en/kitsfmt.md](en/kitsfmt.md) |
| mcp-searxng | MCP server for SearXNG | [docs/en/mcp-searxng.md](en/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili streaming plugin | [docs/en/obs-bilibili-stream.md](en/obs-bilibili-stream.md) |
| opencode-telegram | Telegram Bot client for OpenCode | [docs/en/opencode-telegram.md](en/opencode-telegram.md) |
| ruyi<br>ruyi-beta<br>ruyi-alpha | RuyiSDK Package Manager (RISC-V dev tools)<br>stable 0.52.0 · beta 0.52.0-beta.20260824 · alpha 0.52.0-alpha.20260714 | [docs/en/ruyi.md](en/ruyi.md) |


## Plugins

DeepSeek Harness (DSH) components are listed separately from software (mounting instructions in [docs/en/dsh.md](en/dsh.md)):

| Plugin | Description | Docs |
|--------|-------------|------|
| dsh-nixos-shell | Consolidated NixOS operations (shell execution, tool bootstrap, sudo daemon routing, NixOS diagnostics) | [docs/en/dsh-nixos-shell.md](en/dsh-nixos-shell.md) |
| dsh-api-balance | API usage balance — adds a 「Usage / Balance」 tab switch to the webui usage ring (left of the send button): account balance, today / this-month / 30-day consumption with charts; the platform token is auto-scanned from local browser sessions by default (manual connect as fallback). **Moved to its [own repository](https://github.com/Kihara777/dsh-api-balance); this repo keeps a thin wrapper package for declarative installation** | [docs/en/dsh-api-balance.md](en/dsh-api-balance.md) |

## Modes

Agent presets (session shapes) sit at the same level as plugins, each with its own dedicated doc:

| Mode | id | Description | Distribution | Doc |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | Verifies a NixOS host at init (refuses everything otherwise); loads `nixos_shell`/`nixos_cli` plus the NixOS development guidance | inside the dsh-nixos-shell package, seed-once | [docs/en/modes/nixos.md](en/modes/nixos.md) |
| 维护模式 | `maintenance` | Derived from NixOS模式; injects `write-project-docs`/`write-maintenance-log`/`nix-flake-update-check`/`nixkits-check-updates`/`translate-*` skills plus the repo-maintenance workflow prompts | inside the dsh-nixos-shell package, seed-once | [docs/en/modes/maintenance.md](en/modes/maintenance.md) |
| 新闻三要素模式 | `news-three-elements` | **read-only** creation mode derived from minimal mode: the "three elements of news" are the three protagonists who must all appear, material comes first (only what cannot be tied back is refused), co-created material is searched and re-skinned (no search, no dispatch), it fetches the skill package online, opens with a three-way picker, and refuses anything not written in Simplified Chinese | **standalone package** `dsh-preset-news-three-elements` | [docs/en/modes/news-three-elements.md](en/modes/news-three-elements.md) |

> The first two ship inside the dsh-nixos-shell package and are seeded once into `$DSH_HOME/.agent-presets` via `nixkits.dsh.presets.nixosMode` / `.maintenanceMode`; 新闻三要素模式 comes from the standalone package `dsh-preset-news-three-elements`, and `nixkits.dsh.presets.newsThreeElements` registers its `share/dsh-agent-presets` as a preset root (no copy). See the "Modes" section of [docs/en/dsh.md](en/dsh.md).

## Development

`nix develop` ready-to-use environments. First, add the registry:

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| Environment | Command | Doc |
|---------|---------------|-----|
| opencode | `nix develop nixkits#opencode` | [en/opencode-devshell.md](en/opencode-devshell.md) |
| ruyi | `nix develop nixkits#ruyi` | [en/ruyi-devshell.md](en/ruyi-devshell.md) |
| ruyi-beta | `nix develop nixkits#ruyi-beta` |  |
| ruyi-alpha | `nix develop nixkits#ruyi-alpha` |  |

## Patches

Standalone overlays, not included in `default`:

| Patch | Description | Docs |
|------|------|------|
| llama-cpp-rocm | ROCm-accelerated builds tracking latest upstream release | [docs/en/llama-cpp-rocm.md](en/llama-cpp-rocm.md) |
| rcc-fix | Fixes 2-in-1 device experience for asusctl | [docs/en/rcc-fix.md](en/rcc-fix.md) |
| asusd-pd-profile | Selects platform profile by power source (USB-C PD vs native AC) | [docs/en/asusd-pd-profile.md](en/asusd-pd-profile.md) |
| asusd-thermal-guard | Thermal watchdog: steps the profile down when overheating, restores after cooling | [docs/en/asusd-thermal-guard.md](en/asusd-thermal-guard.md) |
| comfyui | ComfyUI ROCm integration (GFX override / device access / kernel params) | [docs/en/comfyui.md](en/comfyui.md) |
| efl-cross-fix | Fixes efl cross-compilation code-gen tooling | [docs/en/efl-cross-fix.md](en/efl-cross-fix.md) |
| breeze-black | Plasma 6 high-contrast Breeze Black accessibility theme | [docs/en/breeze-black.md](en/breeze-black.md) |
| codewhale-sudo | overlay — restore sudo (blocked since codewhale v0.9.0) (ptrace interceptor) | [docs/en/codewhale-sudo.md](en/codewhale-sudo.md) |

> ⚠️ Patches are overlays that modify upstream nixpkgs packages rather than independent builds, and are not in the binary cache. Dynamically versioned projects (e.g. llama-cpp-rocm) have hashes that change with upstream releases and cannot be cached.

> ⚠️ **Do not set `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` on StrixHalo devices.** The variable changes the GPU memory allocation path and causes degenerate model output (repeated words, broken sentences) on unified-memory hardware. Measured: the risk **increases significantly as model quantisation precision drops** — low-bit quants (e.g. 1.5 bpw) are affected most. See the [llama-cpp-rocm docs](en/llama-cpp-rocm.md#unified-memory-environment-variable-degeneration-risk).

## Retired Projects

Projects once maintained and now retired (most because upstream ships equivalent capability). Index: [`DEPRECATED.md`](../DEPRECATED.md):

| Project | Description | Details |
|---------|-------------|---------|
| comfyui-rocm | The ComfyUI ROCm patch project — upstream built it in, all patches removed | [en/deprecated/comfyui-rocm.md](en/deprecated/comfyui-rocm.md) |

## Skills

For AI coding assistants:

> Skills in this project are primarily aimed at Chinese-speaking users and Chinese open-source models. All SKILL.md files are written in Chinese.

| Skill | Description | Docs |
|------|------|------|
> ⚠️ **Claude Code** has been removed from nixkits-skills install targets. The software implements nationality inference based on user data, crossing a security boundary. See [nixkits-skills docs](en/skills/nixkits-skills.md).
| news-three-elements | Fabricate Russian-style news flashes — the "three elements of news" are Bulannikov, Yudintsev and Buyanov, the three protagonists who must all appear (game-mechanic jokes + a material-first refusal service) | [docs/en/skills/news-three-elements.md](en/skills/news-three-elements.md) |
| nix-flake-update-check | **Generic**: check upstream updates in any nix flake repo and upgrade (per-builder hash flows / flake.lock / patch-embedded versions / nixpkgs drift traps) | [docs/en/skills/nix-flake-update-check.md](en/skills/nix-flake-update-check.md) |
| nixkits-check-updates | NixKits update adapter layer: four-language docs, plugin inventory, maintenance log, historical incident lessons (depends on nix-flake-update-check) | [docs/en/skills/nixkits-check-updates.md](en/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits skill installer (local/online) | [docs/en/skills/nixkits-skills.md](en/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS modern CLI guide (for AI models) | [docs/en/skills/nixos-modern-cli.md](en/skills/nixos-modern-cli.md) |
| recover-nixos-config | Recover deleted /etc/nixos config from Nix store | [docs/en/skills/recover-nixos-config.md](en/skills/recover-nixos-config.md) |
| translate-pseudocn | Pseudo-Chinese translation (kana stripping + word order conversion from Japanese) | [docs/en/skills/translate-pseudocn.md](en/skills/translate-pseudocn.md) |
| write-maintenance-log | Write MAINTENANCE.md entries per NixKits spec (software updates + bug fixes) | [docs/en/skills/write-maintenance-log.md](en/skills/write-maintenance-log.md) |
| write-project-docs | Write multilingual documentation for any project in NixKits style | [docs/en/skills/write-project-docs.md](en/skills/write-project-docs.md) |
| nixos-specialisation-tuning | Design NixOS specialisation faces and tune llama.cpp on unified-memory devices | [docs/en/skills/nixos-specialisation-tuning.md](en/skills/nixos-specialisation-tuning.md) |

## Credits

- **狐莉 (キツのり)** — creator and maintainer
- **小爪 (キツのめ)** — design, development feat. DeepSeek V4 Flash · DeepSeek V4.1 Flash
- **小小爪 (キツのめ)** — hardware inference infrastructure feat. llama-cpp-rocm: DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)

> [!NOTE]
> 关于 DeepSeek Harness (DSH) 生态 —— 小爪与小小爪使用 dsh-nixos-shell 插件，以及 NixOS模式 / 维护模式 Agent 预设武装了自己☆

## License

[MIT](../LICENSE)

See [`SECURITY.md`](../SECURITY.md) for the security policy, including the list of **already-evaluated external reports** — resolved false positives are not re-litigated.
