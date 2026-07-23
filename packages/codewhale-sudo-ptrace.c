/* codewhale-sudo-ptrace.c — ptrace-based syscall interceptor for static binaries
 *
 * Replaces the LD_PRELOAD shim (which only works for dynamically-linked
 * binaries).  Codewhale is statically linked, so we must intercept the
 * prctl(PR_SET_NO_NEW_PRIVS) and prctl(PR_SET_SECCOMP) syscalls at the
 * kernel boundary via ptrace.
 *
 * Architecture:
 *   fork → child: PTRACE_TRACEME + exec(codewhale)
 *          parent: ptrace loop, rewriting prctl(PR_SET_NO_NEW_PRIVS / PR_SET_SECCOMP)
 *                  into a harmless prctl(PR_GET_NO_NEW_PRIVS).
 */
#define _GNU_SOURCE
#include <err.h>
#include <errno.h>
#include <signal.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/user.h>
#include <sys/wait.h>
#include <unistd.h>

/* Current architecture — ptrace register layout differs per arch */
#if defined(__x86_64__)
  #define SYSCALL_NR_REG  orig_rax
  #define ARG1_REG        rdi
  #define ARG2_REG        rsi
  #define SET_RET(r, v)   ((r).rax = (v))
  #define IP_REG          rip
#elif defined(__aarch64__)
  #define SYSCALL_NR_REG  regs[8]   /* x8 holds syscall number */
  #define ARG1_REG        regs[0]   /* x0 */
  #define ARG2_REG        regs[1]   /* x1 */
  #define SET_RET(r, v)   ((r).regs[0] = (v))
  #define IP_REG          pc
#else
  #error "Unsupported architecture — add register definitions above"
#endif

/* Set to 1 when CODEWHALE_ALLOW_SUDO is non-empty */
static int allow_sudo = 0;
static int verbosity = 0;

static int should_intercept(unsigned long option) {
  if (!allow_sudo) return 0;
  if (option == PR_SET_NO_NEW_PRIVS) return 1;
  if (option == PR_SET_SECCOMP)      return 1;
  return 0;
}

/* Rewrite the syscall to a harmless PR_GET_NO_NEW_PRIVS (read-only, no side effects).
 * The kernel will execute it and return 0 or 1 in rax, which is fine for us. */
static void rewrite_prctl(struct user_regs_struct *regs) {
  regs->ARG1_REG = PR_GET_NO_NEW_PRIVS;
  /* clear arg2 so the call is idempotent */
  regs->ARG2_REG = 0;
}

/* Resume child until next syscall boundary, handling ptrace-stops. */
static int ptrace_syscall(pid_t pid, int *sig) {
  if (ptrace(PTRACE_SYSCALL, pid, NULL, (void *)(long)*sig) == -1) {
    if (errno == ESRCH) return -1; /* child gone */
    warn("PTRACE_SYSCALL");
    return -1;
  }
  return 0;
}

static int run_child(int argc, char **argv) {
  if (ptrace(PTRACE_TRACEME, 0, NULL, NULL) == -1)
    err(1, "PTRACE_TRACEME");
  /* raise SIGSTOP so the parent knows we're ready */
  raise(SIGSTOP);
  execvp(argv[0], argv);
  err(1, "exec %s", argv[0]);
}

/* Main tracing loop.  Returns the child's exit status. */
static int trace_child(pid_t child) {
  int status, sig = 0;
  int in_syscall = 0; /* 0 = entry, 1 = exit */
  int exit_code = 1;

  /* Wait for initial SIGSTOP from child */
  if (waitpid(child, &status, 0) == -1)
    err(1, "waitpid (initial)");

  if (!WIFSTOPPED(status) || WSTOPSIG(status) != SIGSTOP)
    errx(1, "unexpected initial child status: %d", status);

  /* Set ptrace options: only trace the main process.
   * PTRACE_O_TRACESYSGOOD distinguishes syscall stops from regular
   * SIGTRAPs; PTRACE_O_TRACEEXEC prevents the kernel sending a
   * killing SIGTRAP after exec.  We intentionally do NOT set
   * TRACEFORK/TRACEVFORK/TRACECLONE — child processes spawned by
   * codewhale (shells, sub-commands) must run untraced. */
  if (ptrace(PTRACE_SETOPTIONS, child, NULL,
      PTRACE_O_TRACESYSGOOD | PTRACE_O_TRACEEXEC) == -1)
    warn("PTRACE_SETOPTIONS");

  sig = 0;
  for (;;) {
    if (ptrace_syscall(child, &sig) == -1) break;
    if (waitpid(child, &status, 0) == -1) {
      if (errno == ECHILD) break;
      warn("waitpid");
      break;
    }

    /* --- Process exit or signal --- */
    if (WIFEXITED(status)) {
      exit_code = WEXITSTATUS(status);
      break;
    }
    if (WIFSIGNALED(status)) {
      exit_code = 128 + WTERMSIG(status);
      break;
    }

    /* --- Ptrace stop events --- */
    if (WIFSTOPPED(status)) {
      int stopsig = WSTOPSIG(status);

      /* PTRACE_EVENT for fork/clone/exec — suppress and continue */
      if (status >> 8 == (SIGTRAP | (PTRACE_EVENT_FORK << 8)) ||
          status >> 8 == (SIGTRAP | (PTRACE_EVENT_VFORK << 8)) ||
          status >> 8 == (SIGTRAP | (PTRACE_EVENT_CLONE << 8)) ||
          status >> 8 == (SIGTRAP | (PTRACE_EVENT_EXEC << 8))) {
        sig = 0;
        continue;
      }

      /* Syscall stop (bit 7 set via PTRACE_O_TRACESYSGOOD) */
      if (stopsig == (SIGTRAP | 0x80)) {
        struct user_regs_struct regs;
        if (ptrace(PTRACE_GETREGS, child, NULL, &regs) == -1) {
          warn("PTRACE_GETREGS");
          sig = 0;
          continue;
        }

#ifdef __x86_64__
        /* On x86_64, orig_rax holds the syscall number at entry and -1 at exit */
        if (regs.orig_rax == (unsigned long)-1) {
          /* syscall exit — nothing to do */
          in_syscall = 0;
          sig = 0;
        } else {
          in_syscall = 1;
          if (regs.orig_rax == 157) { /* SYS_prctl on x86_64 */
            if (should_intercept(regs.rdi)) {
              if (verbosity) fprintf(stderr, "[sudo-ptrace] intercepting prctl(option=%lu)\n", regs.rdi);
              rewrite_prctl(&regs);
              if (ptrace(PTRACE_SETREGS, child, NULL, &regs) == -1)
                warn("PTRACE_SETREGS");
            }
          }
          sig = 0;
        }
#elif defined(__aarch64__)
        /* On aarch64, syscall entry: we check x8 for syscall number */
        if (in_syscall == 0) {
          in_syscall = 1;
          if (regs.regs[8] == 167) { /* SYS_prctl on aarch64 */
            if (should_intercept(regs.regs[0])) {
              if (verbosity) fprintf(stderr, "[sudo-ptrace] intercepting prctl(option=%lu)\n", regs.regs[0]);
              rewrite_prctl(&regs);
              if (ptrace(PTRACE_SETREGS, child, NULL, &regs) == -1)
                warn("PTRACE_SETREGS");
            }
          }
          sig = 0;
        } else {
          in_syscall = 0;
          sig = 0;
        }
#endif
        continue;
      }

      /* Normal signal delivered to child — forward it */
      sig = stopsig;
      if (verbosity > 1)
        fprintf(stderr, "[sudo-ptrace] forwarding signal %d\n", stopsig);
      continue;
    }

    /* Unexpected status */
    sig = 0;
  }

  return exit_code;
}

int main(int argc, char **argv) {
  const char *env = getenv("CODEWHALE_ALLOW_SUDO");
  allow_sudo = (env && *env) ? 1 : 0;

  if (getenv("CODEWHALE_SUDO_VERBOSE"))
    verbosity = atoi(getenv("CODEWHALE_SUDO_VERBOSE"));

  if (argc < 2)
    errx(1, "usage: codewhale-sudo-ptrace <program> [args...]");

  pid_t child = fork();
  if (child == -1)
    err(1, "fork");

  if (child == 0)
    return run_child(argc - 1, argv + 1);

  return trace_child(child);
}
