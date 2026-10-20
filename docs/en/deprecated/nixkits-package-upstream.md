# nixkits-package-upstream skill name (deprecated)

[中文](../../zh/deprecated/nixkits-package-upstream.md) | English | [日本語](../../ja/deprecated/nixkits-package-upstream.md)  | [偽中国語](../../pcn/deprecated/nixkits-package-upstream.md)

[← Back to the retired-projects index](../../../DEPRECATED.md)

**Status**: skill name deprecated (2026-10-20)
**Former location**: `skills/nixkits-package-upstream/`
**Current state**: the file stays as a **pure-audit adapter** with a deprecation notice at the top; the general method moved to `upstream-audit`

## Why it is deprecated

The upstream contribution skill was split into two layers:

| Layer | Does | Where |
|---|---|---|
| `upstream-audit` | evaluation, requirement audit, dry-run — **read-only, stops at dry-run** | this repository |
| private submit layer | fork / branch / commit / push / PR / review response | a private preset on the deployment, not distributed here |

The old name implied both "audit" and "submit", but in the new structure it only carries the
adapter's audit duty — **a name wider than its duty is the next misuse waiting to happen**.

## Migration

- For general auditing use `upstream-audit`;
- For submission, use the authorised layer in your environment (not provided here);
- The old name no longer appears in the skill list, the registry or presets; historical
  entries in `MAINTENANCE.*` keep it (history is not rewritten).

## One criterion

**A deprecated name is not a deleted file.** The content is still there as an adapter, but it
**holds no write operation** any more — those moved to the layer that requires authorisation.
What was deprecated is the shape: one name promising two different things.
