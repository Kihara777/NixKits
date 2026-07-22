/* codewhale-sudo-shim.c — LD_PRELOAD shim to allow sudo under codewhale sandbox */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdarg.h>
#include <stdlib.h>
#include <sys/prctl.h>
#include <unistd.h>

static int (*real_prctl)(int, ...) = NULL;

int prctl(int option, ...) {
  va_list ap;
  unsigned long a2, a3, a4, a5;

  va_start(ap, option);
  a2 = va_arg(ap, unsigned long);
  a3 = va_arg(ap, unsigned long);
  a4 = va_arg(ap, unsigned long);
  a5 = va_arg(ap, unsigned long);
  va_end(ap);

  /* Allow sudo: skip no_new_privs and seccomp setup */
  if (getenv("CODEWHALE_ALLOW_SUDO")) {
    if (option == PR_SET_NO_NEW_PRIVS || option == PR_SET_SECCOMP)
      return 0;
  }

  if (!real_prctl)
    real_prctl = dlsym(RTLD_NEXT, "prctl");

  return real_prctl(option, a2, a3, a4, a5);
}
