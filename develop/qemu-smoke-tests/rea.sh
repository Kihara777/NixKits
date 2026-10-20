#!/usr/bin/env bash
# 烟测：rea（REA = Reverse Engineer Anything）
#
# ── 为什么要有它 ─────────────────────────────────────────────────────────────
# 「构建成功」不等于「产物能跑」，而 rea 属于**构建通过最没说服力**的那一类：
# 它的 `bin/rea` 只是一个 wrapper（node + scripts/rea.mjs），真正的产物是
# `dist/` 里几百个已编译模块 + 40 个生产依赖。构建系统看不见的部分包括：
#   · `npmRebuildFlags = [ "--ignore-scripts" ]` 是**必须**的（否则 frida 的
#     prebuild-install 会把整个构建拖死），但它同时意味着「没有任何依赖被重建」
#     —— 一旦某个依赖真的需要构建产物，构建照样绿、启动才炸；
#   · `@lydell/node-pty` 的平台预编译件是按 optionalDependencies 挑的，挑错架构
#     时 `npm ci` 不报错；
#   · vendored lock 与 package.json 的 devDependencies 删除必须**同源**，
#     否则 npm 会拿一份和源码不一致的依赖树。
# 因此判据必须落在「真跑一次分析」上，不是 --version 上。
#
# ── 判据（分层，任何一层单独红都算失败）─────────────────────────────────────
#   ① `rea --version` 报出版本号；
#   ② `rea --help` 的子命令表里关键命令齐（dist 完整加载，不只是 wrapper 起来）；
#   ③ **真跑一次静态 JS 应用分析**：对一个临时构造的最小 Electron 应用，
#      输出恰好一行 JSON，且 `summary.browser_windows == 1`；
#   ④ 反证：期望版本换成不可能的值必须**失败**——说不出它怎么翻脸就不是判据。
#
# 用法（本地与 CI 同一份脚本）：
#     develop/qemu-smoke-tests/rea.sh /nix/store/<产物> [期望版本]
#
# 需要 python3（解析 JSON）。缺 python3 时**显式失败**，不静默跳过。
# 本包不是交叉构建产物，调用方不需要 qemu/binfmt。
set -euo pipefail

OUT="${1:?用法: $0 <nix 产物路径> [期望版本]}"
EXPECT="${2:-$(sed -n 's/.*-\([0-9][0-9.]*\)$/\1/p' <<<"$OUT" | head -1)}"
[ -n "$EXPECT" ] || { echo "✗ 从 '$OUT' 里推不出期望版本，请显式传第二个参数" >&2; exit 1; }

fail() { echo "✗ $*" >&2; exit 1; }
ok() { echo "✓ $*"; }

command -v python3 >/dev/null || fail "找不到 python3——判据无法解析 JSON，拒绝静默通过"

BIN="$OUT/bin/rea"
[ -x "$BIN" ] || fail "找不到主程序：$BIN"

# ── ① 版本 ───────────────────────────────────────────────────────────────────
ver_out="$("$BIN" --version 2>&1)" || fail "--version 退出非零：$ver_out"
grep -q "$EXPECT" <<<"$ver_out" || fail "版本号不符：期望 $EXPECT，实得：$ver_out"
ok "主程序能起来（$ver_out）"

# ── ② 子命令表完整 ───────────────────────────────────────────────────────────
# 只查四个「分布在不同注册路径上」的代表：一个 MCP 入口、一个诊断、一个能力表、
# 一个真正干活的命令。dist 少模块时这里会缺。
help_out="$("$BIN" --help 2>&1)" || fail "--help 退出非零：$help_out"
for cmd in analyze-javascript-application capabilities doctor mcp; do
  grep -qE "^[[:space:]]+$cmd([[:space:]]|$)" <<<"$help_out" \
    || fail "--help 里没有子命令 '$cmd'（dist 不完整或命令表变了）：$(head -3 <<<"$help_out")"
done
ok "子命令表完整（analyze-javascript-application / capabilities / doctor / mcp 都在）"

# ── ③ 真跑一次静态分析 ───────────────────────────────────────────────────────
APP="$(mktemp -d)"
trap 'rm -rf "$APP"' EXIT
cat > "$APP/package.json" <<'JSON'
{
  "name": "rea-smoke-demo",
  "version": "1.0.0",
  "main": "main.js"
}
JSON
cat > "$APP/main.js" <<'JS'
const { app, BrowserWindow } = require("electron");

function createWindow() {
  const win = new BrowserWindow({ width: 800, height: 600 });
  win.loadFile("index.html");
}

app.whenReady().then(createWindow);
JS
echo '<!doctype html><html><body><h1>demo</h1></body></html>' > "$APP/index.html"

# 进度行走 stderr，结果走 stdout（单行 JSON）——实测确认，别把两者混起来 jq。
result="$("$BIN" analyze-javascript-application "$APP" --format json 2>/dev/null)" \
  || fail "analyze-javascript-application 退出非零"
lines="$(wc -l <<<"$result")"
[ "$lines" -eq 1 ] || fail "结果不是单行 JSON（$lines 行）——输出被进度行污染了"
python3 - "$result" <<'PY' || fail "分析结果不符合判据（见上）"
import json, sys
data = json.loads(sys.argv[1])
# 结果在 Evidence envelope 的 normalized_result 里（不是顶层）——实测确认。
summary = data["normalized_result"]["summary"]
assert summary["browser_windows"] == 1, f"browser_windows={summary['browser_windows']}，期望 1"
stats = data["normalized_result"]["statistics"]
assert stats["parsed_javascript_files"] == 1, f"parsed_javascript_files={stats['parsed_javascript_files']}，期望 1"
assert stats["parse_failures"] == 0, f"parse_failures={stats['parse_failures']}，期望 0"
print(f"  browser_windows={summary['browser_windows']} parsed_javascript_files={stats['parsed_javascript_files']} findings={stats['findings']}")
PY
ok "静态分析跑通（最小 Electron 应用解析出 1 个 BrowserWindow）"

# ── ④ 反证：判据必须能翻脸 ───────────────────────────────────────────────────
if "$0" "$OUT" "9.9.9-nonesuch" >/dev/null 2>&1; then
  fail "反证失败：把期望版本换成 9.9.9-nonesuch 竟然通过了——版本判据不会翻脸"
fi
ok "反证通过（期望版本换成不可能的值即失败）"

echo "qemu-smoke-tests/rea: OK"
