/**
 * nixos-gate — NixOS mode gate plugin for the DeepSeek Harness.
 *
 * Mounted by the `NixOS模式` agent preset.  At apply time (session
 * initialization) it verifies the host system is NixOS:
 *
 * - NOT NixOS: the plugin registers a tool-execution guard that denies every
 *   tool call with the reason, and installs a prompt section that instructs
 *   the agent to refuse any request and explain why.  The guard is registered
 *   through the preset's agent scope, so only sessions on this preset are
 *   blocked — other sessions keep working.
 * - NixOS: the plugin installs the NixOS development guidance prompt section
 *   (requirements derived from the NixKits `nixos-modern-cli` skill
 *   scenarios) so the agent works efficiently on NixOS systems.
 *
 * It consumes only host capability seams (`systemPrompt`, `tools`) and
 * provides no services, so it needs no realm.
 *
 * @module @kihara777/dsh-nixos-shell/nixos-gate
 */
import { existsSync, readFileSync } from "node:fs";

export const name = "nixos-gate";

export const inject = ["systemPrompt", "tools"];

function isNixOS() {
  if (existsSync("/etc/NIXOS")) {
    return true;
  }
  try {
    const osRelease = readFileSync("/etc/os-release", "utf8");
    return /(^|\n)ID=nixos\b/.test(osRelease);
  } catch {
    return false;
  }
}

const REFUSAL = `## NixOS模式 — 系统校验失败：本会话拒绝一切请求

本会话挂载的「NixOS模式」预设要求宿主系统为 NixOS。初始化校验发现当前系统不是 NixOS（/etc/NIXOS 不存在，且 /etc/os-release 的 ID 不是 nixos）。

作为本会话的代理，你必须：

- 拒绝用户的任何任务请求，不执行任何操作、不调用任何工具（工具执行已被运行时守卫拦截）；
- 明确告知拒绝理由：NixOS模式预设专为 NixOS 系统设计，其辅助工具（nixos_shell / nixos_cli）与提示词均依赖 NixOS 环境，在非 NixOS 系统上运行没有意义且可能产生误导性结果；
- 建议用户切换到其他预设（如标准模式），或在 NixOS 系统上使用本预设。`;

const GUIDANCE = `## NixOS模式 — NixOS 高效开发指南

本会话运行在 NixOS 宿主上。遵循以下要点以高效工作：

### 系统本质

- NixOS 是声明式、不可变的发行版：没有 /usr/bin、/usr/lib，没有 apt/yum/pacman；配置通过 /etc/nixos 与 flake 声明，应用变更必须 rebuild。
- 系统包由 /etc/nixos 配置声明（environment.systemPackages / 模块 enable 选项），不要用 nix-env 或 pip install --user 等方式绕过声明式管理。
- Shell PATH 默认极简：POSIX 工具（python3、grep、sed、awk、jq、git 等）可能缺失。使用 nixos_shell 的 tools 参数（内部经 nix shell nixpkgs#<pkg> 提供），或 nix shell nixpkgs#<pkg> --command。

### 工具使用

- 命令执行优先使用本预设的 nixos_shell（NixOS PATH 注入 + bash 回退 + tools 引导）。
- 需要 root 的变更性操作（nixos-rebuild、systemctl 系统级、nix store gc/optimise）经 nixos_shell 的 sudo: true 执行，且必须提供 justification——该请求经外部 sudo 守护进程以 root 执行并留痕。
- 只读诊断使用 nixos_cli：capabilities（CLI 能力与现代命令对照）、system-status、generations、journal、audit-store-paths。
- 现代命令优先：nixos rebuild switch（nixos 命令，nixos-cli 项目）或 nixos-rebuild switch、nix profile install、nix shell、nix build、nix store gc、nix store optimise。

### 关键陷阱

- 配置文件中不要写入 /nix/store/ 绝对路径——gc 后立即失效。优先裸命令名（$PATH 解析）或 /run/current-system/sw/bin 稳定符号链接；可用 nixos_cli op=audit-store-paths 审计。
- 修改 /etc/nixos 配置后必须 rebuild 才生效；rebuild 失败时系统停留在上一代际，修复配置后重试。
- 本地 Nix 操作前按仓库约定处理 flake.lock（NixKits 仓库不提交 flake.lock）。`;

export function apply(ctx) {
  if (isNixOS()) {
    ctx.systemPrompt.section({
      name: "nixos-mode-guidance",
      text: GUIDANCE,
      order: 900,
    });
    return;
  }
  ctx.tools.guard(() => {
    return "NixOS模式预设要求 NixOS 宿主：当前系统不是 NixOS（/etc/NIXOS 不存在且 /etc/os-release ID 非 nixos），本会话拒绝一切请求并禁止工具执行。";
  });
  ctx.systemPrompt.section({
    name: "nixos-mode-gate",
    text: REFUSAL,
    order: 50,
  });
}
