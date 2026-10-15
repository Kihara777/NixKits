# dsh-alpha — 0.2.x 线的最新预发布通道
#
# Thin wrapper around the stable dsh.nix with version + hash + channel overrides.
#
# ── 为什么跟 npm `alpha`（2026-10-08 改回；2026-10-15 复核）──────────────
# 三个 dist-tag 在 2026-10-15 的取值（`curl -s https://registry.npmjs.org/@deepseek-ai%2Fdsh
# | jq '.["dist-tags"]'` 原文）：
#
#     { "alpha": "0.2.1-alpha.3", "next": "0.2.0-rc.2", "latest": "0.2.0-rc.2" }
#
# **复核结论：`alpha` 仍领先**（0.2.1-alpha.3 > 0.2.0-rc.2），故继续跟 `alpha`。
# 2026-10-08 改回时的取值是 `{ "alpha": "0.2.1-alpha.1", "next": "0.2.0-rc.2",
# "latest": "0.2.0-rc.2" }`。
#
# 即 **`alpha` 已比 `next` / `latest` 更新**。2026-10-02 改跟 `next` 的理由是
# 「`alpha` 挂在 0.1.x 旧线上（当时 = 0.1.7-alpha.2），比 stable 低」——该前提
# **已经反转**：0.2.1-alpha.3 与 stable 同在 0.2.x 线，且是 `next` 的下一个预发布。
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
  version = "0.2.1-alpha.3";
  hash = "sha256-Cy/3uMnb9MBKOIOiSpt6bNzPOfNrLceZNiOacWpXxdc=";
  npmDepsHash = "sha256-WZeFdjD03jrX6R7uQ5KFIdpJI3leR1InFC6Nx/lnEaw=";
  # 与 stable 版本不同 ⇒ 不同 tarball ⇒ 独立的 vendored lock。生成方式（AGENTS.md
  # 的 npm 流程）：tarball 的 package.json 经 dsh.nix postPatch **同一段** awk 去掉
  # devDependencies，再 `npm install --package-lock-only`（**不加** --legacy-peer-deps，
  # 否则 peer 条目缺失、构建报 ENOTCACHED）。成品须与 npm fixup 后的那份逐字节一致
  # ——可比对 `/nix/store/…-dsh-<version>-npm-deps/package-lock.json`。
  #
  # ⚠️ 2026-10-15 实测：上面这条 `npm install --package-lock-only` 路线**会产生一份
  # 与 npm fixup 不一致的 lock**（本次差异含 `zod` 4.6.7 vs fixup 的 4.6.6，共 9 处），
  # 构建报 `npmDepsHash is out of date`。原因是该命令按当前 registry 解析传递依赖，
  # 而 fixup 用的是 lock 里已钉住的那套。**判据只有 `cmp` 那条**——不要假设
  # 「按文档命令生成的 lock 就是对的」。可靠路线：置 `npmDepsHash = lib.fakeHash`
  # 构建一次（让 fixup 真实跑起来），再从报错里的 `got:` 取真值、并把
  # `/nix/store/…-dsh-<version>-npm-deps/package-lock.json` 直接复制成本文件。
  #
  # ⚠️ 更要紧：**同名 store 路径不等于同版本内容**。`npmDepsHash` 写错时，fixup 会
  # 按旧哈希命中**旧的** `…-dsh-<version>-npm-deps`（本次实测到名为 alpha.3、
  # 内容却是 alpha.2 的 lock，md5 与 alpha.2 的那份相同）。拿它做 `cmp` 会
  # 「证明」错的东西——比对前先确认该路径里的 `"version"` 就是本次升到的版本。
  lockFile = ./dsh-package-lock-alpha.json;
  dshChannel = "alpha";
  inherit allowLanSettings;
}
