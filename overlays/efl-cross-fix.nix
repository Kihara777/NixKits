# efl cross-compilation fix overlay
#
# Fixes efl (Enlightenment Foundation Libraries) cross-compilation
# for pkgsCross.{riscv64,riscv64-musl,aarch64}.
#
# Background: efl has internal code generators (eolian_gen, eet, etc.)
# that are compiled during its own build and used for subsequent code
# generation. Under cross-compilation, meson calls find_program('xxx',
# native: true) looking for host-architecture versions of these tools,
# but Nix's cross-compilation sandbox does not provide them — they are
# compiled for the target architecture and cannot run.
#
# Fix: in the cross-compiled efl preConfigure phase, copy the host-
# compiled efl bin/ directory into the build directory and prepend it
# to PATH, so meson can find the required tools.
#
# Scope: only affects pkgsCross.{riscv64,riscv64-musl,aarch64}
# Host efl is unaffected.

final: prev:

let
  efl-native = prev.enlightenment.efl;

  efl-fix = cFinal: cPrev: {
    enlightenment = cPrev.enlightenment.overrideScope (efinal: eprev: {
      efl = eprev.efl.overrideAttrs (old: {
        preConfigure = (old.preConfigure or "") + ''
          cp -r ${efl-native}/bin/. .
          chmod -R +x .
          export PATH="$PWD:$PATH"
        '';
      });
    });
  };
in

{
  pkgsCross = prev.pkgsCross // {
    riscv64      = prev.pkgsCross.riscv64.extend efl-fix;
    riscv64-musl = prev.pkgsCross.riscv64-musl.extend efl-fix;
    aarch64      = prev.pkgsCross.aarch64.extend efl-fix;
  };
}