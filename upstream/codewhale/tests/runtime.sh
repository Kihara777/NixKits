#!/usr/bin/env bash
# runtime.sh —— **运行层**判据：这个二进制真的能跑，而不只是「编译过了」。
#
# Rust 包的假绿长什么样：`buildRustPackage` 建成功、产物里有个可执行文件，
# 但它起不来（缺动态库）、或者根本不是你以为的那个 target
# （`buildAndTestSubdir` 写错时会建别的东西）。
#
# 四段，第四段是反证：
#   ① `--version` 含版本号        —— 二进制确实是那一个版本，不是别的 target
#   ② `codew` 符号链接在且能跑     —— 我们 postInstall 的产物
#   ③ `doctor` 跑通              —— **真实代码路径**（解析配置路径、报版本），
#                                   不是 argv 解析；比 `--help` 强
#   ④ 反证臂：去掉 postInstall 后 `codew` **必须不存在**
#
# 用法：NIXPKGS_PATH=<一棵真 nixpkgs 树> bash upstream/codewhale/tests/runtime.sh
# 退出码：0 = 过；1 = 有失败；2 = 没能验到

set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
DIR="$HERE/.."
NIXPKGS_PATH="${NIXPKGS_PATH:?要设 NIXPKGS_PATH 指一棵 nixpkgs 树}"

fail=0; unverified=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
cant() { printf '  \033[33m?\033[0m %s\n' "$1"; unverified=1; }

WANT=$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$DIR/package.nix" | head -1)
[ -n "$WANT" ] || { echo "取不到 version —— 没能验到" >&2; exit 2; }

echo "① 建两份：正常的，以及「去掉 postInstall」的反证臂"
A=$(NIXPKGS_PATH="$NIXPKGS_PATH" nix build --impure --no-link --print-out-paths \
      --expr "(import $DIR/counterexample.nix).base" 2>/dev/null | tail -1)
B=$(NIXPKGS_PATH="$NIXPKGS_PATH" nix build --impure --no-link --print-out-paths \
      --expr "(import $DIR/counterexample.nix).noAlias" 2>/dev/null | tail -1)
[ -n "$A" ] && ok "base: $A" || { cant "base 建不出来"; exit 2; }
[ -n "$B" ] && ok "反证: $B" || { cant "反证臂建不出来"; exit 2; }

echo "② --version 含 $WANT"
V=$(timeout 60 "$A/bin/codewhale" --version 2>&1)
if echo "$V" | grep -q "$WANT"; then ok "$(echo "$V" | head -1)"
else bad "--version 里没有 $WANT：$(echo "$V" | head -1)"; fi

echo "③ codew 符号链接（我们 postInstall 的产物）"
if [ -L "$A/bin/codew" ] && timeout 60 "$A/bin/codew" --version >/dev/null 2>&1; then
  ok "codew → $(readlink "$A/bin/codew")，且能跑"
else
  bad "codew 不存在、不是符号链接、或跑不起来"
fi

echo "④ doctor：真实代码路径（解析配置路径并报版本）"
D=$(timeout 120 env HOME="$(mktemp -d)" "$A/bin/codewhale" doctor 2>&1)
if echo "$D" | grep -q 'Version Information' && echo "$D" | grep -q "codewhale: $WANT"; then
  ok "doctor 打印了 Version Information 与 codewhale: $WANT"
  echo "$D" | grep -E 'codewhale:|workspace:' | head -3 | sed 's/^/        /'
else
  bad "doctor 没给出预期输出：$(echo "$D" | head -2 | tr '\n' ' ')"
fi

echo "⑤ 反证臂：去掉 postInstall 后，codew **必须不存在**"
if [ ! -e "$B/bin/codew" ]; then
  ok "反证臂里没有 codew —— 说明第 ③ 步量的确实是我们的 postInstall"
else
  bad "去掉 postInstall 后 codew 仍在 —— 第 ③ 步量的不是我们的代码"
fi

echo
if [ $fail -ne 0 ]; then echo "有失败项"; exit 1
elif [ $unverified -ne 0 ]; then echo "有**没能验到**的项 —— 那不等于通过"; exit 2
else echo "OK: 版本、别名、doctor 真实路径、反证臂 —— 都亮过相"; fi
