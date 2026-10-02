# dsh-nixos-shell-stable — 预设内容**冻结**在指定 commit 的变体。
#
# ── 为什么需要它 ─────────────────────────────────────────────────────────────
# dsh 0.2.0 是一次**预设格式断层**：0.1.x 的 Agent 预设是
# `$DSH_HOME/.agent-presets/<id>/` 目录（`agent.cordis.yml`），0.2.0 改成 profile
# 用户 patch 层里的一条 `@deepseek-ai/dsh-agent-preset` 条目
# （`preset.patch.yml`）。仓库 HEAD 从此**只维护新格式**——两套格式不并存于 HEAD，
# 只在「取用点」分叉：
#
#   · stable 通道（`pkgs.dsh`，跟 npm `latest`）→ 预设内容取**本文件钉住的 rev**，
#     不随 HEAD 漂。那个 rev 是两套格式并存的最后一个提交，因此它同时提供
#     旧格式（0.1.x 的用户仍可按 rev 取用）与新格式（0.2.0 的 stable 用）。
#   · alpha 通道（`pkgs.dsh-alpha`，跟 npm `next`）→ 预设内容跟仓库 HEAD。
#
# 冻结的意义不是「stable 不更新」，而是**更新时机可判**：HEAD 上改预设先经 alpha
# 通道实跑，确认无碍后把下面的 `pinnedRev` 往前挪一格即可，改动是一次显式的
# 单行编辑，而不是随 HEAD 悄悄漂进稳定通道。
#
# ── 钉在哪 ───────────────────────────────────────────────────────────────────
# `0175f85`（2026-10-02「预设迁移准备」）：新格式 preset.patch.yml 首次落地、
# 逐插件 schema 比对完成、并在 0.2.0-rc.2 实机验证过 `broken` 全空的那一版。
# 换 rev 时：`nix store prefetch-file --unpack --json <archive-url>` 取新的
# sha256 填回 `sha256`，并把上面的说明一并更新。
#
# `builtins.fetchTarball`（而不是 fetchFromGitHub）：返回值是**路径**，模块才能在
# 求值期直接 readFile 出 preset.patch.yml 正文，不需要 import-from-derivation；
# 定 sha256 ⇒ 纯求值下允许，且解析结果进本机的 tarball 缓存，只下一次。
{ callPackage }:
let
  pinnedRev = "0175f85ece30934cf19d1af50ef019f825820663";

  pinnedSource = builtins.fetchTarball {
    url = "https://github.com/Kihara777/NixKits/archive/${pinnedRev}.tar.gz";
    sha256 = "sha256-dLq8gXJBuY0R4RrKpw3V96aG7RfIudf0rCpCJuMz4tU=";
  };
in
callPackage ./dsh-nixos-shell.nix {
  # 只钉 `presets/`（预设正文 + 各预设自带的技能目录快照）。
  #
  # 仓库级的 `skills/` 树**刻意不钉**：它是 `skills-embedded`（维护技能，如
  # write-project-docs / write-maintenance-log）与 `presets/*/skills-nixos/` 的
  # 来源，其存在意义正是「新会话拿到的永远是最新内容」——冻结它等于让 stable 用户
  # 用旧文档技能。稳定通道冻结的是**预设格式与预设内容**，不是这种活文档。
  presetsSource = pinnedSource + "/packages/dsh-nixos-shell/presets";
}
