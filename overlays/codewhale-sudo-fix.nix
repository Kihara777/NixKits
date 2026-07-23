# codewhale-sudo-fix overlay — re-enables sudo under codewhale's sandbox
#
# Codewhale v0.9.0 added PR_SET_NO_NEW_PRIVS by default, which permanently
# blocks sudo (even passwordless).  This overlay overrides the codewhale
# package with allowSudo = true, injecting a ptrace-based syscall
# interceptor that rewrites prctl(PR_SET_NO_NEW_PRIVS) calls.
#
# Usage:
#   nixpkgs.overlays = [ inputs.nixkits.overlays.codewhale-sudo-fix ];
(final: prev: {
  codewhale = prev.codewhale.override { allowSudo = true; };
})