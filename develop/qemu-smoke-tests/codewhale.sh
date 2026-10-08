#!/usr/bin/env bash
# qemu 烟测：codewhale
#
# ── 为什么要有它 ─────────────────────────────────────────────────────────────
# 「构建成功」不等于「产物能跑」。本包在 riscv64 上是**源码构建**（Rust 交叉编译），
# 而且它是本仓最近一次「结构性变更、hash 类判据全都看不见」的实例：
# 2026-10-08（0.10.0 → 0.10.1）上游把 `crates/tui` 变成纯库、两个可执行文件合成一个，
# 于是 `postInstall` 里那句 install 当场报
#
#     install: cannot stat 'target/riscv64gc-unknown-linux-gnu/release/codewhale-tui'
#
# —— 那次是**构建**喊的，不是判据。但缺口还在：构建过 ≠ 跑得起来，而
# `build-codewhale-riscv64.yml` 此前**没开** smoke-test，riscv64 的产物在 CI 上
# 从没被运行过。本仓为同类缺口吃过两次亏（Cachix 缓存假绿、原生模块缺该架构绑定），
# 所以这里把「跑一遍」补上，本地与 CI 同一份脚本。
#
# ── 判据 ─────────────────────────────────────────────────────────────────────
#   ① 主程序能起来并打出**版本号**（动态链接器、store 里的 glibc 等都要对得上）；
#   ② `codew` 这个名字也在，且与主程序是**同一个二进制**（上游 0.9.9 起 TUI 改名）；
#   ③ `codewhale doctor` 能**离线**跑完并报同一版本——比 `--version` 更接近「真跑一遍」：
#      它会加载配置、报 setup 状态、列出更新检查的口径；
#   ④ 反证：把期望版本换成不可能的值必须**失败**。说不出它怎么翻脸，就不是判据。
#
# 用法（本地与 CI 同一份脚本）：
#     develop/qemu-smoke-tests/codewhale.sh /nix/store/<产物> [期望版本]
# 期望版本默认从产物路径名里取（`…-codewhale-0.10.1`），取不到就要求显式给。
#
# 非本机架构时由调用方负责让 binfmt/qemu 就位；本脚本不自己注册 binfmt——
# 「处理器没就位」必须在调用方那里**显式失败**，不能在这里静默跳过。
set -euo pipefail

OUT="${1:?用法: $0 <nix 产物路径> [期望版本]}"
EXPECT="${2:-$(sed -n 's/.*-\([0-9][0-9.]*\)$/\1/p' <<<"$OUT" | head -1)}"
[ -n "$EXPECT" ] || { echo "✗ 从 '$OUT' 里推不出期望版本，请显式传第二个参数" >&2; exit 1; }

fail() { echo "✗ $*" >&2; exit 1; }
ok() { echo "✓ $*"; }

BIN="$OUT/bin/codewhale"
[ -x "$BIN" ] || fail "找不到主程序：$BIN"

# ── ① 主程序能起来并报版本 ───────────────────────────────────────────────────
ver_out="$("$BIN" --version 2>&1)" || fail "--version 退出非零：$ver_out"
grep -q "$EXPECT" <<<"$ver_out" || fail "版本号不符：期望 $EXPECT，实得：$ver_out"
ok "主程序能起来（$ver_out）"

# ── ② codew 这个名字也在，且跑得出同一版本 ──────────────────────────────────
# 判据落在「跑得出来」上，不落在「是不是符号链接」上：实测两种形态都出现过——
# 预编译变体是两个**逐字节相同的拷贝**（上游发两份资产），源码变体是同源的两个名字。
# 「两者内容是否相同」只报告，不判失败（上游若哪天真的发一份不同的 TUI，不该误报）。
CODEW="$OUT/bin/codew"
[ -x "$CODEW" ] || fail "找不到可执行的 codew（上游 0.9.9 起 TUI 改叫这个名字）"
codew_out="$("$CODEW" --version 2>&1)" || fail "codew --version 退出非零：$codew_out"
grep -q "$EXPECT" <<<"$codew_out" || fail "codew 版本号不符：$codew_out"
if cmp -s "$BIN" "$CODEW"; then
  ok "codew 跑得出同一版本（与主程序逐字节相同）"
else
  ok "codew 跑得出同一版本（与主程序字节不同——只报告，不判失败）"
fi

# ── ③ doctor 离线跑完，且报同一版本 ──────────────────────────────────────────
doc_out="$("$BIN" doctor 2>&1)" || fail "doctor 退出非零：$doc_out"
grep -q "$EXPECT" <<<"$doc_out" || fail "doctor 没报出版本 $EXPECT：$doc_out"
grep -qi 'offline' <<<"$doc_out" \
  || echo "▸ doctor 没声明离线默认——它若真去联网，这条会变慢而不是失败（不判失败）"
ok "doctor 离线跑完并报同一版本"

# ── ④ 反证：判据必须能翻脸 ───────────────────────────────────────────────────
if "$0" "$OUT" "9.9.9-nonesuch" >/dev/null 2>&1; then
  fail "反证失败：把期望版本换成 9.9.9-nonesuch 竟然通过了——这条判据不会翻脸"
fi
ok "反证通过（期望版本换成不可能的值即失败）"

echo "qemu-smoke-tests/codewhale: OK"
