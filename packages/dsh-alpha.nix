# dsh-alpha — 0.2.x 线的最新预发布通道
#
# Thin wrapper around the stable dsh.nix with version + hash + channel overrides.
#
# ── 为什么跟 npm `alpha`（2026-10-08 改回）────────────────────────────────
# 三个 dist-tag 在 2026-10-08 的取值（`curl -s https://registry.npmjs.org/@deepseek-ai%2Fdsh
# | jq '.["dist-tags"]'` 原文）：
#
#     { "alpha": "0.2.1-alpha.1", "next": "0.2.0-rc.2", "latest": "0.2.0-rc.2" }
#
# 即 **`alpha` 已比 `next` / `latest` 更新**。2026-10-02 改跟 `next` 的理由是
# 「`alpha` 挂在 0.1.x 旧线上（当时 = 0.1.7-alpha.2），比 stable 低」——该前提
# **已经反转**：0.2.1-alpha.1 与 stable 同在 0.2.x 线，且是 `next` 的下一个预发布。
# 继续跟 `next` 等于把本通道钉在**比 `alpha` 旧**的版本上，与本文件自述的
# 「0.2.x 线的最新预发布」相反。故改回跟 `alpha`。
#
# 将来若 `alpha` 再次落后：判据**不是「哪个 tag 名字更像预发布」**，而是
# 「哪个 tag 指到的版本在 0.2.x 线上更新」——复核时重取一次 dist-tags 比较两者
# 版本序；`alpha` 不再领先时改回跟 `next`，并把当时的取值与日期写进这段注释，
# 而不是继续留着一条已经不作数的理由。
#
# 与 stable 的**行为差异有两处**：① dsh 版本（本通道更新），故 hash / npmDepsHash /
# vendored lock **各自独立**——版本不同时不能共用 stable 的 lock；② **预设内容**
# ——`dshChannel = "alpha"` 让 modules/dsh.nix 的预设跟仓库 HEAD，而 stable 用
# dsh-nixos-shell-stable 钉住的 commit（稳定通道的预设内容冻结）。
{ callPackage, lib, allowLanSettings ? false }:
callPackage ./dsh.nix {
  version = "0.2.1-alpha.1";
  hash = "sha256-hX+TqmyFy9kr40IjgOVRbyNtxcSc2gQFqVjL3xhl6Ns=";
  npmDepsHash = "sha256-8p722O0bW9sAegFfKDBo5WAhX44CB2szYhuIRF7/JcQ=";
  # 与 stable 版本不同 ⇒ 不同 tarball ⇒ 独立的 vendored lock。生成方式（AGENTS.md
  # 的 npm 流程）：tarball 的 package.json 经 dsh.nix postPatch **同一段** awk 去掉
  # devDependencies，再 `npm install --package-lock-only`（**不加** --legacy-peer-deps，
  # 否则 peer 条目缺失、构建报 ENOTCACHED）。成品须与 npm fixup 后的那份逐字节一致
  # ——可比对 `/nix/store/…-dsh-<version>-npm-deps/package-lock.json`。
  lockFile = ./dsh-package-lock-alpha.json;
  dshChannel = "alpha";
  inherit allowLanSettings;
}
