# Security Policy — impure branch

[中文](../SECURITY.md) | English | [日本語](SECURITY.ja.md) | [偽中国語](SECURITY.pcn.md)

## This branch's particular risk: it is deliberately not reproducible

`llama-cpp-ver` resolves to GitHub's **latest release JSON** for llama.cpp on every
evaluation, `nixpkgs` follows `nixos-unstable`, and `flake.lock` is **deliberately not
committed**. That means:

- `nix build` at different times can produce different content;
- if upstream mistags or an attacker tampers with a release, **the next evaluation picks
  it up**, and you hold no lock to prove "this is what I built";
- CI artifacts cannot be reproduced from a commit either.

This is a **deliberate trade-off**: keep the floating part inside a branch that installs
exactly one package, so that `main` can be pinned. **Do not add a second package here** —
the smaller the floating surface, the easier it is to review.

## Mitigations

| Measure | Explanation |
|---|---|
| **Content is still pinned by the upstream tag** | The version floats, but it resolves to the `releases/latest` tag; the source behind one tag does not change |
| **Hash changes must pass review** | Bumping the version also changes the hash in the overlay; that diff is the human review point |
| **A single upstream** | `ggml-org/llama.cpp` is the only upstream in the local inference chain; no second source is introduced |
| **Upstream binaries are not run in CI** | This branch only builds and installs; actually running llama.cpp is the downstream deployment's job |

## Reporting a vulnerability

Same as `main`: see the `SECURITY.md` on the `main` branch — use the private channel,
**do not open a public issue**. If the report concerns this branch itself (overlay /
module / flake definitions), please note "impure branch" in that report.
