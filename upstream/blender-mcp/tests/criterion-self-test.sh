#!/usr/bin/env bash
# 反证：dry-run 的每条判据都必须能被**已知的坏输入**撞响。
#
# 来历：第一次撞反证时我拿「把可执行文件改名」当坏样本——它确实翻脸了，
# 但翻在第 2 层（postFixup 的 wrapProgram 先报错），**根本没走到第 3 层**。
# 所以「脚本整体退非零」只能证明某一层管用，不能证明每条判据都管用。
# 这份用例按层分别撞。
#
# 用法：bash upstream/blender-mcp/tests/criterion-self-test.sh
#   退出码 0 = 每条判据都翻过脸（对照臂也通过）
#   退出码 1 = 有判据撞不响（**不是通过**）
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NIXPKGS_PATH="${NIXPKGS_PATH:-$(nix eval --raw nixpkgs#path 2>/dev/null || true)}"
export NIXPKGS_PATH

fail=0
ok()  { echo "  ok   $*"; }
bad() { echo "  FAIL $*"; fail=1; }

# ---- 第 3 层：产物核验 ------------------------------------------------------
echo "== 第 3 层：产物核验（把阈值抬过真实值 9）=="
W="$(mktemp -d)"
sed 's/\[ "\$n_addon" -ge 9 \]/[ "$n_addon" -ge 99 ]/' "$DIR/build.sh" > "$W/build.sh"
if grep -q 'n_addon" -ge 99' "$W/build.sh"; then
  if (cd "$W" && timeout 1200 bash build.sh >/dev/null 2>&1); then
    bad "阈值抬到 99 仍报通过——这条判据没有区分度"
  else
    ok "阈值抬到 99 时翻脸"
  fi
else
  bad "坏样本没生成（锚点变了？）——**没能验到**"
fi
rm -rf "$W"

# ---- 第 4 层：运行判据的三条断言 -------------------------------------------
echo "== 第 4 层：三条断言各喂一个坏输入 =="
check_resp() {  # $1=响应；返回 0 表示「三断言全过」
  local resp="$1" pat
  for pat in '"serverInfo"' 'blender-mcp' '"tools"'; do
    case "$resp" in *"$pat"*) : ;; *) return 1 ;; esac
  done
  return 0
}

W="$(mktemp -d)"
OUT="$(NIXPKGS_PATH="$NIXPKGS_PATH" nix build --impure --no-link --print-out-paths \
  --expr "import $DIR/build.nix" 2>/dev/null || true)"
if [ -n "$OUT" ] && [ -x "$OUT/bin/blender-mcp" ]; then
  real="$(printf '%s' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"self-test","version":"1"}}}' \
    | timeout 30 "$OUT/bin/blender-mcp" 2>/dev/null | head -c 2000 || true)"
  # 对照臂：真实响应必须全过
  if check_resp "$real"; then ok "对照臂：真实响应三断言全过"; else bad "对照臂不通过——判据本身坏了"; fi
  # 坏样本 1：完全没有输出
  if check_resp ""; then bad "空响应也通过了"; else ok "空响应翻脸"; fi
  # 坏样本 2：有输出但不是 MCP 应答
  if check_resp "error: cannot connect to Blender"; then bad "一行报错也通过了"; else ok "非协议输出翻脸"; fi
  # 坏样本 3：合法协议但是别的程序
  if check_resp '{"jsonrpc":"2.0","id":1,"result":{"serverInfo":{"name":"mcp-searxng"}}}'; then
    bad "别的程序也通过了"; else ok "serverInfo 指向别的程序时翻脸"; fi
else
  bad "拿不到构建产物——**没能验到**（不当作通过）"
fi
rm -rf "$W"

echo
if [ "$fail" -eq 0 ]; then
  echo "OK: 每条判据都翻过脸，对照臂通过"
else
  echo "FAIL: 有判据撞不响（见上）"
fi
exit "$fail"
