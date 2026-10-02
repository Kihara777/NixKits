# dsh-alpha — 0.2.x 线的最新预发布通道
#
# Thin wrapper around the stable dsh.nix with version + hash + channel overrides.
#
# ── 为什么跟 npm `next`，不跟 `alpha`（2026-10-02 改）──────────────────────
# npm 上三个 tag 的当前值：`latest` = `next` = **0.2.0-rc.2**，而 `alpha` =
# **0.1.7-alpha.2**。`alpha` 挂在 0.1.x 旧线上，比 stable **低** —— 继续跟它
# 就等于把 alpha 通道钉在一条已经落后的线上。改跟 `next` 的语义是「0.2.x 线的
# 最新预发布」：今天与 stable 同为 0.2.0-rc.2，将来 `npm publish --tag next`
# 出 0.2.1-alpha.x 时自然跟上，不必再改本文件的判据。
#
# 与 stable 的**唯一行为差异**不在 dsh 版本上（两者今天指向同一个 tarball，故
# hash / npmDepsHash / vendored lock 都与 stable 共用），而在**预设内容**：
# `dshChannel = "alpha"` 让 modules/dsh.nix 的预设改跟仓库 HEAD，而 stable 用
# dsh-nixos-shell-stable 钉住的 commit（稳定通道的预设内容冻结）。
{ callPackage, lib, allowLanSettings ? false }:
callPackage ./dsh.nix {
  version = "0.2.0-rc.2";
  hash = "sha256-vSeEfERc1opWWsH5HAa7vMdjnvkwcfZ4u1nF66/ziFk=";
  npmDepsHash = "sha256-7QtZIz8oDKi2eVHfmbLkdww5XxPvY7NP8ZmP5RxBzNY=";
  # 与 stable 同一版本 ⇒ 同一 tarball ⇒ 同一个 vendored lock（不另存副本：
  # 两份逐字节相同的 lock 只会漂）。`next` 前进到新预发布时，此处再改回
  # `lockFile = ./dsh-package-lock-alpha.json;` 并按 AGENTS.md 重新生成该文件。
  dshChannel = "alpha";
  inherit allowLanSettings;
}
