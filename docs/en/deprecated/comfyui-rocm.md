# comfyui-rocm patch project (retired)

[中文](../../zh/deprecated/comfyui-rocm.md) | English | [日本語](../../ja/deprecated/comfyui-rocm.md)  | [偽中国語](../../pcn/deprecated/comfyui-rocm.md)

[← Retired projects index](../../../DEPRECATED.md)

**Status**: retired (2026-09-15)
**Former location**: `modules/comfyui-rocm.nix` + `patches/comfyui-nix-{strix-halo,nixpkgs-compat,stdenv-api}.patch`
**Current state**: the module is kept and renamed to `nixkits.comfyui`; **all three patches are deleted**

### Upstream has actively maintained the project and updated its ROCm support components to versions that support StrixHalo devices well; this patch's historical mission is complete.

## What it used to solve

Upstream `comfyui-nix`'s ROCm support once lagged behind what Strix Halo
(gfx1151 / RDNA 3.5) needed. This patch project filled the gap with three patches:

| Patch | Problem it solved |
|-------|-------------------|
| `comfyui-nix-strix-halo` | Upgraded the ROCm / PyTorch wheels and added gfx1151 support |
| `comfyui-nix-nixpkgs-compat` | Build failures caused by nixpkgs drift (Python tests failing in the sandbox) |
| `comfyui-nix-stdenv-api` | Upstream used the deprecated `stdenv.is<Platform>` shorthand, triggering evaluation warnings |

## Why it can be retired

Upstream `comfyui-nix` **0.34.0** has built all of the above in:

- **ROCm support**: upstream ships ROCm 7.1 / PyTorch 2.10.0 wheels whose version,
  URL and hash in its `nix/versions.nix` are **byte-for-byte identical** to what our
  patches produced; its module natively supports `gpuSupport = "rocm"`.
- **stdenv API**: warning -- **this assessment was wrong and has been corrected**. Upstream did **not** migrate: 0.34.0 still carries **38** deprecated `stdenv.is<Platform>` short forms (`hostPlatform.is*` appears only 7 times), identical to 0.30.2, so evaluating the upstream flake/overlay directly **still emits the deprecation warning**. The patch is genuinely no longer needed, but the real reason is that **we no longer override upstream code**: the old patch applied that migration to a fork evaluated through an overlay, to silence a warning that polluted downstream builds; pointing straight at upstream leaves this module doing declarative wiring only.
- **nixpkgs compatibility**: upstream now covers most of the Python test-skip logic.

## ⚠️ A misjudgement worth recording

The retirement decision for `comfyui-nix-nixpkgs-compat` **was wrong at first**:

1. The initial assessment ran a "full build verification": all 717 derivations
   succeeded, with none of the "tests need skipping" packages (`scipy`,
   `jupyter-server`, `jupyterlab`, `fastapi`) failing — so the patch was judged
   unnecessary.
2. **But `scipy` was a binary-cache hit that time and never actually built.** What was
   verified was an artifact already in the cache, not a real build.
3. The actual upgrade failed immediately:

   ```
   scipy-1.18.0  test_support_moments_sample
     ACTUAL:  array([0., 0.])
     DESIRED: array([0.000000e+00, 2.010276e-09])
   ```

   exactly the "flaky floating-point assertion" the patch's own comment described.

**The root cause was one stray pin left on this machine**, not "downstream combinations
differ by nature": it pinned `comfyui-nix`'s `inputs.nixpkgs` to `6438090` (2026-08-02)
while the top level tracked rolling `nixos-unstable`. The top level hit the public
cache, while the pinned sub-flake had to build `scipy` — so "a problem the cache would
have solved" looked like "a problem needing a patch". **Delete that pin line and
`comfyui-nix` shares `dc5d91f` with the top level, `scipy` is a straight cache hit, and
the build is green with no patches at all.**

> **Lesson one**: build verification must confirm the target derivation was **really
> built**, not served from cache. A `nix build --dry-run` list, and whether a
> `building '…'` line appears in the build log, are the evidence that it truly built.
> "The build succeeded" alone cannot distinguish "it built and passed" from "it never
> needed building".
>
> **Lesson two**: an extra `inputs.*` pin **detaches a sub-flake from the main nixpkgs
> cache coverage**, turning a problem the cache would have solved into one that appears
> to need patching. Before adding a pin, ask what it solves; once the problem is gone,
> remember to remove it. This project's two wrong judgements ("not needed" → "our
> combination happens to need it") both came from not tracing that pin.

## How to configure after retirement

**No fork and no patches are needed any more.** Point the `comfyui-nix` input at
upstream directly:

```nix
{
  inputs.comfyui-nix.url = "github:utensils/comfyui-nix";

  # The module name and option path have changed (formerly nixkits.comfyui-rocm)
  imports = [ inputs.nixkits.nixosModules.comfyui ];

  nixkits.comfyui.enable = true;
  services.comfyui = {
    enable = true;
    gpuSupport = "rocm";
    # rocmGfxOverride = "11.0.0";   # enable only if gfx1151 is not recognised
  };
}
```

> **On the rename**: the module was once `nixkits.comfyui-rocm`, because it was born as
> a "ROCm patch project". With the patches gone it only does **integration wiring**
> (service options, device permissions, kernel parameters, the C toolchain), so it was
> renamed to `nixkits.comfyui` to match what it actually does.

**Current module documentation**: see [`comfyui.md`](../comfyui.md).

## Historical comparison

| Item | Patch era | Now |
|------|-----------|-----|
| comfyui-nix version | 0.30.2 (local fork, 14 commits) | upstream 0.34.0 |
| ROCm wheels | injected by patch | shipped upstream |
| Input source | `path:/home/kix/comfyui-nix-patched` | `github:utensils/comfyui-nix` |
| Patch count | 3 | 0 |
