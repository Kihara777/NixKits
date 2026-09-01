# dsh-api-balance

[中文](../zh/dsh-api-balance.md) | English | [日本語](../ja/dsh-api-balance.md) | [偽中国語](../pcn/dsh-api-balance.md)

API usage balance plugin (DeepSeek Harness) — adds a 「Usage / Balance」 tab switch to the popover panel of the webui usage ring (the context-usage circle left of the send button).

## Basic Info

| Field | Value |
|------|-----|
| Type | DSH Host + Client plugin (npm package) |
| npm name | `@kihara777/dsh-api-balance` |
| Version | `0.1.0` |
| License | MIT |
| Data sources | DeepSeek official `GET /user/balance` (API-key auth) + the platform console usage API (platform session token auth) |

## Features

- **Usage**: the original content (context occupancy and its breakdown)
- **Balance**: the current API key's account info (key hint, availability, per-currency total / top-up / granted balance), plus consumption details and usage charts — the consumption detail is one horizontally-paged area (page 1: today / this-month / 30-day; page 2: per-model breakdown + daily / monthly chart), with a phone-home-screen-style dot indicator above it (tappable, swipe/drag to flip); the area height follows its content and never scrolls itself (full content relies on the panel's own vertical scroll)
- Host-side 30-second TTL cache; the API key is resolved through the `credentials` service using `apiKeyEnv` (default `DEEPSEEK_API_KEY`), falling back to the process environment

### Platform token acquisition (two tiers, fully automatic first)

- **Local browser auto-scan (on by default)**: the host reads the `Local Storage/leveldb` of local Chromium-family browsers (Edge / Chrome / Brave / Chromium / Vivaldi / Opera, every profile) — parsing the LevelDB tables exactly (footer → index → data blocks → snappy decompression → entry walk) to read `userToken`, falling back to raw-byte heuristics if parsing fails — and saves the first hit to `$DSH_HOME/api-balance-token` (0600). Signing in to the platform once in a local browser is all it takes. Throttled to one scan per 6 hours by default (`browserScanIntervalMs` configurable, `browserScan = false` disables); after token invalidation (40003/401) the next query rescans immediately.
- **Not-signed-in detection and login guidance**: when the scan finds nothing, the panel pops up 「Platform login not detected」 — 「Go to login」 opens the login page in a new tab and picks up the token automatically via polling; manual token entry is only a secondary option inside the prompt (for those who don't want to log in). Once connected, a greyed 「✓ Signed in」 button and the token source (auto from local browser / manual) are shown; every manual refresh also auto-quick-scans the login state when no token exists — no button clicks needed.

### Interface settings (⚙ Settings → Interface)

- **Bottom stats bar**: overflowing content scrolls horizontally with the scrollbar hidden (on by default); turning it off restores the ellipsis truncation (hovering shows the full line in a tooltip).
- **Enter key behavior**: Enter = newline, Shift+Enter = send (on by default; DSH's native behavior is Enter = send); turning it off restores the native behavior. Composer only; other inputs unaffected.
- **Mobile: no keyboard on session switch**: on touch devices, switching sessions via the sidebar no longer auto-focuses the composer, so the soft keyboard doesn't pop up by itself; tapping the composer still works. Enabled by default, can be turned off here.
All three settings are on by default and persist in browser localStorage.

### Peak pricing marker

DeepSeek's current peak/off-peak rule (official pricing footnote): **peak = Mon–Fri 09:00–12:00 and 14:00–18:00 Beijing time; all other hours — including weekends — are off-peak**. During peak hours: the usage ring (the circular button left of the send key) and the usage chart turn red, and a red 「Peak pricing」 badge appears next to the chart title (hover for the window details); the greeting audio on page refresh and on each 「Balance」-tab click (refresh) is followed by a peak hint (pack `peak` segment first, TTS fallback otherwise).

### Voice broadcast

Clicking the usage chart's 「Daily / Monthly」 toggle broadcasts the matching view's voice usage (pack segments + TTS numbers), covering: in (uncached input), cache hit, out, and cost (currency) — matching the official usage page's itemization; broadcast language and voice follow the DSH UI language (zh / en). The 「⚙ Settings → Voice」 tab provides:

- an auto-broadcast toggle (balance alerts when below the threshold, with a 30-minute rate limit)
- TTS backend selection (browser built-in / custom TTS API proxied through the host to avoid CORS, URL template placeholders `{text}` `{lang}` `{rate}`)
- voice-pack library management (import multiple zips, switch the active pack by clicking rows, multi-select removal; each pack expands into an 「audition」 view to play all of its supported audio one by one; stored under `$DSH_HOME/api-balance-voicepack/`, shared by all devices)
- a creator inside the 「Voice pack management」 sub-menu (browser recording or audio-file import, with a visual recording float window and sample texts; cross-language recording; package & download / compile & apply)

#### Voice pack format guide

A voice pack is a **zip archive** (easy to deploy and share) containing a `manifest.json` and audio files. Import the .zip in 「⚙ Settings → Voice」 to enable it; clearing restores the default whole-sentence TTS broadcast.

Zip layout:

```
voice-pack.zip
├── manifest.json
└── audio/
    ├── dead.mp3
    ├── low.mp3
    └── …
```

```json
// manifest.json
{
  "format": "dsh-api-balance-voice-pack",
  "version": 1,
  "name": "My pack",
  "lang": "zh-CN",
  "segments": {
    "dead": "audio/dead.mp3",
    "low": "audio/low.mp3",
    "peak": "audio/peak.mp3",
    "today": "audio/today.mp3",
    "month": "audio/month.mp3",
    "inLabel": "audio/inLabel.mp3",
    "outLabel": "audio/outLabel.mp3",
    "cacheHitLabel": "audio/cacheHitLabel.mp3",
    "costLabel": "audio/costLabel.mp3",
    "tokenUnit": "audio/tokenUnit.mp3",
    "suffix": "audio/suffix.mp3",
    // optional: greeting clips (a random one plays on every page refresh)
    "greetings": ["audio/greet0.mp3", "audio/greet1.mp3"]
  }
}
```

| Segment | Purpose |
|------|------|
| `dead` | whole-sentence out-of-tokens alert |
| `low` | whole-sentence low-balance alert |
| `peak` | peak-pricing hint (appended after the greeting audio) |
| `today` | 「Today」 broadcast prefix |
| `month` | 「This month」 broadcast prefix |
| `inLabel` | 「in」 label |
| `outLabel` | 「out」 label |
| `cacheHitLabel` | 「cache hit」 label |
| `costLabel` | 「cost」 label |
| `tokenUnit` | unit after numbers (e.g. 「tokens」), reusable |
| `suffix` | broadcast ending |

All segments are optional: missing ones fall back to TTS during playback. Panel presentation matches the official usage page: 「in」 counts only uncached input, and cache hits are listed separately (token and cost data come from the official API's daily-granularity buckets without secondary merging). The creator's sample texts match the default TTS fallback strings exactly (so recorded packs stay close to the default TTS experience); dynamic numbers (token counts, cost and currency) are synthesized by the current TTS backend and concatenated as 「pack segment + TTS numbers」. The optional `greetings` is an array of file paths (0–32): when voice broadcast is enabled, a random one plays as a greeting/landing sound on every page refresh; without greeting audio, a random TTS greeting is used instead.

**Create & share**: 「Settings → Voice → Voice pack management」 → 「Create a voice pack」 opens the creator — first pick the pack language (zh-CN / en / ja; drives the sample texts and the manifest `lang`, so packs can be recorded across languages); record each segment with the browser microphone, and record greetings list entry by entry («Add greeting» extends the list, ✕ removes a slot, sample texts mirror the default TTS greeting pool); or import local audio files; while recording, a visual float window appears in the corner (level meter + elapsed time + sample text + stop/discard). Finish with 「Package & download」 to produce a shareable zip, or 「Compile & apply」 to import into the local library and activate it. When a voice pack is already imported, the first edit shows an overwrite warning that must be confirmed (once per session).

**Limits**: segment keys `[A-Za-z0-9_-]{1,32}`; segments ≤ 32, greetings ≤ 32 (≤ 64 zip entries total), ≤ 2 MB per audio file; mp3 / wav / ogg / webm recommended, ≤ 2 s per segment, 22.05/44.1 kHz mono. Dynamic parts (balance numbers, token counts) are not in the pack — they are synthesized live by the current TTS backend (browser built-in or custom TTS API proxied through the host), then concatenated with the pack segments into the complete broadcast.

## Install

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

## Notes

- Balance data comes from the official DeepSeek API, usage data from the platform console's internal API — the two use different auth (API key / platform session token); when either is missing, the corresponding view shows a not-signed-in state instead of an error.
- Auto-scan only reads tokens already signed in on this machine's browsers and collects nothing beyond them; the token file is written with `0600` permissions.
