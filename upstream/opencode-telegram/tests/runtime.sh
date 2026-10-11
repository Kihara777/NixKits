#!/usr/bin/env bash
# runtime.sh —— **运行层**判据：让这个包真的跑起来，而它启动即静态 import
# `better-sqlite3`（一个原生模块）。
#
# 为什么非要走到这一层：「构建通过 + 产物里有 .node 文件」说明不了它能用。
# `npm ci --ignore-scripts` 不跑 install 脚本，原生模块全靠 tarball 里的**预编译**；
# 少一个本平台对应的文件，构建照样绿、一启动就抛。
#
# 三段，每段都有反证：
#   ① 包装器能起（--help 有输出）
#   ② better-sqlite3 能加载 → 开库 → 建表 → 写入 → 读回（不是「能 require」）
#   ③ **反证臂**：用 overrideAttrs 造一份「删掉本平台预编译」的派生，它必须失败
#
# 用法：NIXPKGS_PATH=<一棵真 nixpkgs 树> bash upstream/opencode-telegram/tests/runtime.sh
# 退出码：0 = 过；1 = 有失败；2 = 没能验到

set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
DIR="$HERE/.."
NIXPKGS_PATH="${NIXPKGS_PATH:?要设 NIXPKGS_PATH 指一棵 nixpkgs 树}"

fail=0; unverified=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
cant() { printf '  \033[33m?\033[0m %s\n' "$1"; unverified=1; }

command -v node >/dev/null 2>&1 || {
  echo "需要 node —— 没能验到" >&2; exit 2; }

echo "① 建两份：正常的，以及「删掉本平台预编译」的反证臂"
A=$(NIXPKGS_PATH="$NIXPKGS_PATH" nix build --impure --no-link --print-out-paths \
      --expr "(import $DIR/counterexample.nix).base" 2>/dev/null | tail -1)
B=$(NIXPKGS_PATH="$NIXPKGS_PATH" nix build --impure --no-link --print-out-paths \
      --expr "(import $DIR/counterexample.nix).noPrebuild" 2>/dev/null | tail -1)
[ -n "$A" ] && ok "base: $A" || { cant "base 建不出来"; exit 2; }
[ -n "$B" ] && ok "反证: $B" || { cant "反证臂建不出来"; exit 2; }

BS="$A/lib/node_modules/@grinev/opencode-telegram-bot/node_modules/better-sqlite3"
BSD="$B/lib/node_modules/@grinev/opencode-telegram-bot/node_modules/better-sqlite3"

echo "② 包装器能起"
if timeout 60 "$A/bin/opencode-telegram" --help 2>&1 | grep -q 'Usage:'; then
  ok "--help 有 Usage 输出"
else
  bad "--help 没有输出——包装器或入口脚本坏了"
fi

echo "③ 原生模块：开库、建表、写入、读回"
OUT=$(timeout 60 node -e "
const D = require('$BS');
const db = new D(':memory:');
db.exec('create table t (x integer)');
db.prepare('insert into t values (?)').run(42);
console.log('ROW=' + JSON.stringify(db.prepare('select x from t').get()));
" 2>&1)
if echo "$OUT" | grep -q 'ROW={"x":42}'; then
  ok '开库 → 建表 → 写入 → 读回 得到 {"x":42}'
else
  bad "原生模块没跑通：$(echo "$OUT" | head -2 | tr '\n' ' ')"
fi

echo "④ 反证臂：删掉本平台预编译后，**同一段代码**必须失败"
# ⚠️ 必须与第 ③ 步**同强度**。`require()` 是懒的：它自己成功、根本不碰绑定。
# 第一版这里只写了 `require('$BSD')`，于是反证臂报「仍然成功」——
# 那是**反证臂太弱**，不是判据坏了（而它确实被自己的红报了出来）。
# 要**构造实例**：那一步才会去找那个 .node 文件。
OUT2=$(timeout 60 node -e "
const D = require('$BSD');
const db = new D(':memory:');
db.exec('create table t (x integer)');
console.log('不该出现');
" 2>&1); rc=$?
if [ $rc -ne 0 ]; then
  ok "反证臂失败了（exit $rc）：$(echo "$OUT2" | grep -oE 'Cannot find module[^ ]*' | head -1)"
else
  bad "删掉预编译后仍然成功——说明第 ③ 步量的不是那个预编译文件"
fi
n1=$(ls "$BS/prebuilds" 2>/dev/null | wc -l)
n2=$(ls "$BSD/prebuilds" 2>/dev/null | wc -l)
[ "$n1" -gt "$n2" ] && ok "两份确实不同（prebuilds $n1 vs $n2）" || bad "两份的 prebuilds 一样多（$n1）"

echo
if [ $fail -ne 0 ]; then echo "有失败项"; exit 1
elif [ $unverified -ne 0 ]; then echo "有**没能验到**的项 —— 那不等于通过"; exit 2
else echo "OK: 包装器、原生模块读写、反证臂 —— 都亮过相"; fi
