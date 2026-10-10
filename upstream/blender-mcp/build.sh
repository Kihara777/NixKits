#!/usr/bin/env bash
# blender-mcp 上游草稿的 dry-run。
#
# 判据分四层（见 skills/nixpkgs-package-upstream/SKILL.md 第 3.2 节）：
#   1 求值通过  2 构建通过  3 产物对  4 **产物能跑**
# 第 4 层是唯一能回答「这东西能不能用」的判据；前三个都能是假绿。
#
# 用法：
#   bash upstream/blender-mcp/build.sh
#   NIXPKGS_PATH=/path/to/nixpkgs bash upstream/blender-mcp/build.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- 0. 找一棵 nixpkgs 树 ---------------------------------------------------
if [ -z "${NIXPKGS_PATH:-}" ]; then
  NIXPKGS_PATH="$(nix eval --raw nixpkgs#path 2>/dev/null || true)"
fi
if [ -z "${NIXPKGS_PATH:-}" ] || [ ! -e "$NIXPKGS_PATH" ]; then
  cat >&2 <<'EOF'
找不到 nixpkgs 树。两种做法：
  NIXPKGS_PATH=/nix/store/<hash>-source bash upstream/blender-mcp/build.sh
  nix registry add nixpkgs github:NixOS/nixpkgs/nixos-unstable   # 然后再跑
EOF
  exit 2   # 退出码 2 = **没能验到**，不是通过
fi
echo "nixpkgs: $NIXPKGS_PATH"
export NIXPKGS_PATH

# ---- 0b. 格式：nixpkgs 的 CI 用 nixfmt 强制（RFC 166） ---------------------
echo "== nixfmt --check =="
nix run "$NIXPKGS_PATH#nixfmt" -- --check "$DIR/package.nix"

# ---- 1. 求值 ---------------------------------------------------------------
echo "== 1/4 求值 =="
drv="$(nix eval --impure --raw --expr "(import $DIR/build.nix).drvPath")"
echo "drv: $drv"

# ---- 2. 构建 ---------------------------------------------------------------
echo "== 2/4 构建 =="
out="$(nix build --impure --no-link --print-out-paths --print-build-logs \
  --expr "import $DIR/build.nix")"
echo "out: $out"

# ---- 3. 产物核验 -----------------------------------------------------------
echo "== 3/4 产物 =="
test -x "$out/bin/blender-mcp" || { echo "FAIL: 缺 $out/bin/blender-mcp" >&2; exit 1; }
addon="$out/share/blender/scripts/addons/blender_mcp_addon"
test -f "$addon/blender_manifest.toml" || { echo "FAIL: 缺插件清单" >&2; exit 1; }
n_addon=$(find "$addon" -type f | wc -l)
echo "插件文件数: $n_addon"
[ "$n_addon" -ge 9 ] || { echo "FAIL: 插件文件数 $n_addon < 9" >&2; exit 1; }

# ---- 4. **真的跑它**：喂一条最小 MCP 握手 ----------------------------------
echo "== 4/4 运行（MCP initialize 握手） =="
resp="$(printf '%s' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"dry-run","version":"1"}}}' \
  | timeout 30 "$out/bin/blender-mcp" 2>/dev/null | head -c 2000 || true)"

# 断言必须**三条都成立**——单看「有没有输出」会在它打印一句报错时也通过。
case "$resp" in
  *'"serverInfo"'*)     : ;;
  *) echo "FAIL: 回包里没有 serverInfo。原始响应：$resp" >&2; exit 1 ;;
esac
case "$resp" in
  *'blender-mcp'*)      : ;;
  *) echo "FAIL: 回包里没有 blender-mcp。原始响应：$resp" >&2; exit 1 ;;
esac
case "$resp" in
  *'"tools"'*)          : ;;
  *) echo "FAIL: 回包里没有 tools 能力。原始响应：$resp" >&2; exit 1 ;;
esac

echo "OK: 四层判据全过（求值 / 构建 / 产物 / 运行）"
