#!/usr/bin/env bash
# qemu 烟测：opencode-telegram
#
# ── 为什么要有它 ─────────────────────────────────────────────────────────────
# 「构建成功」不等于「产物能跑」。本包在 riscv64 上尤其如此：它的两个原生模块
# （`better-sqlite3`、`msgpackr-extract`）**上游都没有 riscv64 预编译**，全靠构建期
# 现编，而 `better-sqlite3` 又是**直接依赖**、被 `dist/app/services/session-cache-service.js`
# **静态 import**（启动即加载）。少一个绑定 = 构建照样绿、一启动就抛。
#
# 2026-10-03 实测到的两种假绿形态：
#   · 这个 job 曾长期靠 Cachix 缓存「成功」（取的是上一个版本的产物，一行都没构建）；
#   · 把绑定跳过不编，构建同样成功——只有真跑一下才看得出来。
#
# ── 判据 ─────────────────────────────────────────────────────────────────────
#   ① CLI 进程能起来并打出 Usage；
#   ② `better-sqlite3` 能**真的开库、建表、写入、读回**（不是「能 require」）；
#   ③ `msgpackr-extract` 能加载（可选项，缺了 msgpackr 会回退纯 JS，故只报告不判失败）。
#
# 用法（本地与 CI 同一份脚本）：
#     develop/qemu-smoke-tests/opencode-telegram.sh /nix/store/<产物>
# 非本机架构时由调用方负责让 binfmt/qemu 就位；本脚本不自己注册 binfmt——
# 「处理器没就位」必须在调用方那里**显式失败**，不能在这里静默跳过。
set -euo pipefail

OUT="${1:?用法: $0 <nix 产物路径>}"
BOT="$OUT/lib/node_modules/@grinev/opencode-telegram-bot"
[ -d "$BOT" ] || { echo "✗ 找不到 bot 目录：$BOT" >&2; exit 1; }

fail() { echo "✗ $*" >&2; exit 1; }
ok() { echo "✓ $*"; }

# ── ① CLI 能启动 ─────────────────────────────────────────────────────────────
help_out="$("$OUT/bin/opencode-telegram" --help 2>&1)" || fail "CLI --help 退出非零：$help_out"
grep -q 'Usage:' <<<"$help_out" || fail "CLI --help 没打出 Usage：$help_out"
ok "CLI 能启动（--help 有 Usage）"

# ── ② 原生模块真的能用 ───────────────────────────────────────────────────────
# node 从产物自己的 wrapper 里解析，避免用到调用方 PATH 上的宿主 node——
# 那样测的就不是产物了。
NODE="$(grep -o '/nix/store/[a-z0-9]*-nodejs[^/]*/bin' "$OUT/bin/opencode-telegram" | head -1)/node"
[ -x "$NODE" ] || fail "从 wrapper 里解析不出产物自带的 node"

node_out="$(
  cd "$BOT" && "$NODE" -e '
    const assert = require("node:assert");
    const Database = require("better-sqlite3");
    const db = new Database(":memory:");
    db.exec("create table smoke(a integer, b text)");
    db.prepare("insert into smoke values (?, ?)").run(42, "riscv64");
    const row = db.prepare("select a, b from smoke").get();
    assert.deepStrictEqual(row, { a: 42, b: "riscv64" }, "往返数据不一致: " + JSON.stringify(row));
    const ver = db.prepare("select sqlite_version() v").get().v;
    db.close();
    let extract = "missing";
    try { require("msgpackr-extract"); extract = "ok"; } catch {}
    console.log(`SMOKE_OK sqlite=${ver} extract=${extract}`);
  ' 2>&1
)" || fail "better-sqlite3 往返失败：$node_out"

grep -q 'SMOKE_OK' <<<"$node_out" || fail "原生模块烟测输出不符：$node_out"
ok "better-sqlite3 真实读写（$(sed -n 's/^SMOKE_OK //p' <<<"$node_out")）"

# ── ③ msgpackr-extract 只报告不判失败 ────────────────────────────────────────
if grep -q 'extract=ok' <<<"$node_out"; then
  ok "msgpackr-extract 可加载"
else
  echo "▸ msgpackr-extract 缺失——它是可选加速器，msgpackr 会回退纯 JS，不判失败"
fi

echo "qemu-smoke-tests/opencode-telegram: OK"
