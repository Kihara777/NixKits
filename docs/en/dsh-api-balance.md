# dsh-api-balance

[中文](../zh/dsh-api-balance.md) | English | [日本語](../ja/dsh-api-balance.md)  | [偽中国語](../pcn/dsh-api-balance.md)

API usage-balance plugin (DeepSeek Harness) — adds a 「Usage / Balance」 tab switch to the popup panel on the webui usage ring (the context-used display left of the send button).

> **This project has moved to its own repository**: <https://github.com/Kihara777/dsh-api-balance>
>
> It is a **platform-agnostic DSH plugin** (not NixOS-specific), so it is distributed independently and published to npm.
> **The full documentation (four languages) lives in the new repository**: <https://github.com/Kihara777/dsh-api-balance#文档>
>
> This page keeps only the one section unique to NixKits — **declarative installation**.

## Info

| Item | Value |
|------|-------|
| Source repository | <https://github.com/Kihara777/dsh-api-balance> |
| npm name | `@kihara777/dsh-api-balance` |
| Type | DSH Host + Client plugin |
| License | MIT |
| Role in NixKits | Thin wrapper package (provides declarative installation); carries no source |

## Install

### Route A: `dsh plugin add` (native DSH)

```bash
dsh plugin --profile web add github:Kihara777/dsh-api-balance
# or from npm
dsh plugin --profile web add @kihara777/dsh-api-balance
```

### Route B: declarative (NixOS module — unique to this page)

NixKits keeps a thin `pkgs.dsh-api-balance` wrapper (building from the new repository's source) so NixOS users can install declaratively — the version is pinned by Nix, updates with system generations, and is reproducible:

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-api-balance;
    id = "api-balance";
    name = "@kihara777/dsh-api-balance";
    # config (optional):
    #   apiKeyEnv = "DEEPSEEK_API_KEY";   # credential-ref
    #   baseURL = "https://api.deepseek.com";
    #   browserScan = true;               # local browser auto-scan
    #   browserScanIntervalMs = 21600000; # scan throttle (default 6 h)
  }];
}
```

> ⚠️ **Do not combine with route A** — both register the same entry id and would duplicate it.

## Updating the thin wrapper

`packages/dsh-api-balance.nix` pins one `rev` of the new repository plus two hashes (source and `npmDepsHash`). Upgrades must update all three; the general flow is in the `nix-flake-update-check` skill.

## Feature overview

Full feature documentation lives in the [new repository](https://github.com/Kihara777/dsh-api-balance). Summary:

- **Balance**: DeepSeek's official `GET /user/balance` (API key auth)
- **Usage**: today / this-month / 30-day consumption (cost + tokens + per-model breakdown) with daily / monthly charts
- **Platform token**: auto-scanned from local browser sessions by default, manual connect as fallback
- **Voice**: voice packs + TTS (browser built-in / custom API), with automatic peak/off-peak billing notices
- **UI enhancements**: peak-hour red marking, question-window scroll fixes, bottom stats-bar scrolling, and more
