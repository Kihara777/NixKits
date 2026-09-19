# Security Policy

[中文](../SECURITY.md) | English | [日本語](SECURITY.ja.md)  | [偽中国語](SECURITY.pcn.md)

## Supported versions

This project is distributed as a flake, and **only the latest `main` branch** receives security fixes.
Historical commits are not maintained separately — if you need an older version, fork it and maintain it yourself.

| Scope | Supported |
|-------|-----------|
| `main` branch (latest) | ✅ receives security fixes |
| Published flake outputs (older generations) | ❌ please upgrade to the latest |
| The `dsh-api-balance` subproject | That subproject **now has its own security policy** (including its list of assessed reports and design boundaries) -- report vulnerabilities through its [standalone repository's private reporting channel](https://github.com/Kihara777/dsh-api-balance/security/advisories/new), or see its [`SECURITY.md`](https://github.com/Kihara777/dsh-api-balance/blob/main/SECURITY.md) |

## Reporting a vulnerability

**Please do not report security issues through public issues.**

Use either private channel:

1. **GitHub private vulnerability reporting** (preferred): <https://github.com/Kihara777/NixKits/security/advisories/new>
2. Email: `npm@g41.moe`

Please include as much of the following as you can:

- The affected component (package / module / skill / plugin) and file path
- Reproduction steps or a proof of concept
- Impact assessment (data read, code execution, privilege escalation, denial of service)
- If you have a suggested fix, describe it

## Response timeframes

This project is maintained by one person who holds a **Class-1 visual disability certificate**,
so turnaround can be affected by health — please bear that constraint in mind.

| Stage | Target |
|-------|--------|
| Acknowledgement | within 7 days |
| Initial assessment | within 14 days |
| Fix or mitigation | depends on severity and health; we will keep in touch |

Serious issues are prioritised. If you hear nothing for a long time, feel free to send a reminder email.

## Known design boundaries

The following are **not** vulnerabilities but deliberate behaviour — please confirm before reporting:

| Item | Explanation |
|---|---|
| `nixkits.dsh.reverseProxy.autoAuth` | A declarative **unauthenticated entry point**; enable it only on a trusted LAN. The risk sits with the user's network boundary (see `docs/zh/dsh.md`) |
| The `sudo` daemon | Operations needing root go through an external sudo daemon and are recorded; sandbox permission tiers are chosen explicitly by the user per session and **nothing is widened by default** |
| `dsh-api-balance` reading browser Local Storage | Used to extract the platform session token; **enabled by default and can be turned off**; it reads only the token, collects nothing else from the browser, and writes the token with mode `0600` |
| Hardcoded `/nix/store` paths | A store path baked into a config stops working after GC — a known trap, not a vulnerability; the repository offers an audit via `nixos_cli op=audit-store-paths` |

## Closed external reports

Each report below has been **reviewed point by point**, with the evidence publicly replied to.
**They are listed so that later reporters need not resubmit the same class of issue** —
if you believe one of these conclusions is wrong, say so and we will re-evaluate.

| Report | Claim | Outcome | Basis |
|--------|-------|---------|-------|
| PR #4 (@anupamme) | `/token`, `/voicepack`, `/tts` lack rate limiting | **Not a real issue; not merged** | The description did not match the diff (only `/query` was touched); its rate-limit key `x-forwarded-for` is client-forgeable, and the local same-origin RPC does not send that header, so all local traffic would collapse into one bucket and throttle the user's own panel |
| PR #5 (@anupamme) | `/query` lacks a request-body size cap | **Not a real issue; not merged** | That protection already exists via `readJsonBody`'s 64 KiB limit; the added `content-length` check is bypassable with chunked encoding, and `text.length` counts UTF-16 code units rather than bytes |
| issue #1 (@begininvoke) | `secrets: inherit` violates least privilege | **Not a real issue; closed** | The callee is a local workflow inside this same repository (not the external source the issue assumed); the repository holds only 2 secrets total, and explicit passing yields exactly the same set as `inherit` — zero gain for an attacker |
| issue #2 (@begininvoke) | Same as issue #1 (byte-for-byte duplicate) | **Duplicate; closed** | As above |

> Most of these reports **did hit a real rule**, but the threat model does not apply to how this project is deployed.
> We handle them by reviewing first, replying with reproducible evidence — not by accepting them uncritically.

### On duplicate submissions

**The same conclusion already listed above, resubmitted without new evidence, will be closed directly with a pointer to this section.**

This is not a refusal of security reports; it draws a line:

| Will be accepted | Will be closed directly |
|------------------|-------------------------|
| A **new** issue not covered above | A duplicate report reaching a conclusion already listed above, with no new evidence |
| A claim that one of the conclusions above is **wrong**, with reproducible evidence | A mere restatement of a conclusion already listed |
| The same topic but with a **different** threat model or exploit path | Another automated scan emitting the same rule |

**"Your conclusion is wrong" is always welcome** — the four entries above are themselves reviewed judgements, and if the reasoning was faulty we will correct it.

### The improvements they led to

These reports **produced two genuine hardenings** — even though the reports themselves were false positives, the direction they pointed at was worth pursuing:

| Hardening | Detail |
|-----------|--------|
| **SSRF in the `/tts` endpoint** | Not mentioned by any report, but reviewing the endpoints surfaced it: the proxy accepted an arbitrary `http(s)` URL, issued the request with the host's identity, and forwarded user-controlled `headers` verbatim. Fixed — loopback / private / link-local / reserved addresses are rejected (including IPv4-mapped IPv6), and custom request headers are now allowlisted. **That endpoint moved to the [standalone repository](https://github.com/Kihara777/dsh-api-balance) with `dsh-api-balance`** |
| **Least-privilege CI** | Reviewing the issues surfaced it: 31 build workflows declared no `permissions` and therefore inherited the repository default (possibly read-write), while they only need `contents: read`. All were updated |

**What this means**: this repository welcomes reports and reviews them seriously; a false positive is not treated as a nuisance — the four reports above ended up leading to two real hardenings.

## Supply chain notes

- This repository's CI pins third-party GitHub Actions **to commit SHAs** (not floating tags)
- The repository **contains no secrets**; credentials always live outside it and are pulled in via a `path:` input
- Build outputs are pushed to a public Cachix binary cache
- Build workflows declare least privilege explicitly (`contents: read`)
