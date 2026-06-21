final: prev: {
  ruyi = prev.ruyi.overrideAttrs (oldAttrs: {
    patches = prev.lib.unique ((oldAttrs.patches or []) ++ [
      ../patches/ruyi-nixos-compat.patch
    ]);

    buildInputs = (oldAttrs.buildInputs or []) ++ [ final.patchelf ];

    postPatch = (oldAttrs.postPatch or "") + ''
      substituteInPlace ruyi/utils/nixos_compat.py \
        --replace-fail '@nixLdSo@'       '${final.stdenv.cc.bintools.dynamicLinker}' \
        --replace-fail '@nixGlibcLib@'   '${final.stdenv.cc.libc}/lib'

      # The patch adds _maybe_fix_toolchain_sub_binaries calling
      # ensure_toolchain_nixos_compat, but the import is in a different
      # scope. Add an explicit import.
      sed -i '/def _maybe_fix_toolchain_sub_binaries/,/ensure_toolchain_nixos_compat/{
        /ensure_toolchain_nixos_compat/i\    from ..utils.nixos_compat import ensure_toolchain_nixos_compat
      }' ruyi/mux/runtime.py
    '';

  });
}