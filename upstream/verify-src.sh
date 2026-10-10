#!/usr/bin/env bash
# verify-src.sh —— 独立复算某个上游草稿的 src hash，与 package.nix 里写的比。
#
# 为什么不靠「构建过了」：构建用的是**同一个** hash，它自证不了。
# 但定值派生（fixed-output derivation）有个性质可用——**产物路径由 hash 决定**，
# 所以「那个产物已在 store 里且有效」等价于「当时下到的内容确实哈希成那个值」。
# 本脚本两条路都走，并说清走的是哪一条。
#
# 用法：bash upstream/verify-src.sh <包目录>          例如 upstream/verify-src.sh blender-mcp
#       NIXPKGS_PATH=<一棵真 nixpkgs 树> …（走退路时需要）
#
# 退出码：0 = 一致（含构造证明）；1 = **不一致**；2 = 没能验到（上游拒绝等）

set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
PKG="${1:?用法: bash upstream/verify-src.sh <包目录>}"
DIR="$HERE/$PKG"
[ -f "$DIR/package.nix" ] || { echo "找不到 $DIR/package.nix" >&2; exit 2; }

WANT=$(grep -o 'sha256-[A-Za-z0-9+/=]*' "$DIR/package.nix" | head -1)
[ -n "$WANT" ] || { echo "package.nix 里没有 sha256- hash" >&2; exit 2; }

URL=$(python3 - "$DIR/package.nix" <<'PY'
import re, sys, pathlib
t = pathlib.Path(sys.argv[1]).read_text()
m = re.search(r'src = (fetchFromGitea|fetchFromGitHub|fetchurl|fetchzip)\s*[\{\(](.*?)\n  \};', t, re.S)
if not m: print(""); sys.exit()
kind, body = m.group(1), m.group(2)
def g(k):
    # 值可能带引号（"v1.0.3"）也可能裸写（finalAttrs.version）——两种都要认。
    # 早先只认带引号的，于是 obs 的 tag 成了 None，URL 变成 .../archive/None.tar.gz。
    mq = re.search(rf'^\s*{k} = "([^"]*)"', body, re.M)
    if mq:
        return mq.group(1)
    mb = re.search(rf'^\s*{k} = ([A-Za-z0-9_.]+);', body, re.M)
    return mb.group(1) if mb else None
ver = (re.search(r'version = "([^"]+)"', t) or [None, None])[1]
def resolve(v):
    if not v: return None
    # 两种写法都要认： "v${finalAttrs.version}" 与裸的 finalAttrs.version
    if '${' in v:
        return re.sub(r'\$\{[^}]*\}', ver or '', v)
    if v in ('finalAttrs.version', 'version', 'finalAttrs.src.tag'):
        return ver
    return v
ref = resolve(g('tag')) or resolve(g('rev'))
if kind == 'fetchFromGitea':
    print(f"https://{g('domain')}/{g('owner')}/{g('repo')}/archive/{ref}.tar.gz")
elif kind == 'fetchFromGitHub':
    print(f"https://github.com/{g('owner')}/{g('repo')}/archive/{ref}.tar.gz")
else:
    print(g('url') or "")
PY
)

echo "包：$PKG"
echo "  package.nix 声明: $WANT"
[ -n "$URL" ] && echo "  推出的 URL:       $URL"

command -v nix-prefetch-url >/dev/null 2>&1 || { echo "  ? 没有 nix-prefetch-url —— 没能验到" >&2; exit 2; }

# ── 路一：真的重新下一次 ────────────────────────────────────────────────────
if [ -n "$URL" ]; then
  RAW=$(nix-prefetch-url --unpack --type sha256 "$URL" 2>/dev/null | tail -1)
  if [ -n "$RAW" ]; then
    GOT=$(nix hash convert --hash-algo sha256 --to sri "$RAW" 2>/dev/null)
    echo "  独立下到并算出:   $GOT"
    if [ "$GOT" = "$WANT" ]; then echo "  ✓ 一致（**真的重新下了一遍**算出来的）"; exit 0
    else echo "  ✗ **不一致** —— 上游那个 tag 的内容变了，或 hash 抄错了"; exit 1; fi
  fi
  CODE=$(curl -s -o /dev/null -w '%{http_code}' -L --max-time 20 "$URL" 2>/dev/null)
  echo "  重新下载失败（HTTP $CODE）—— 上游对命令行 UA 限流（本仓已知形态）"
fi

# ── 路二：定值派生的产物已在 store 且有效 ⇒ 哈希由构造证明 ────────────────────
if [ -n "${NIXPKGS_PATH:-}" ]; then
  DRV=$(NIXPKGS_PATH="$NIXPKGS_PATH" nix-instantiate --eval --raw --expr \
        "(import $DIR/build.nix).drvPath" 2>/dev/null)
  if [ -n "$DRV" ]; then
    OUT=$(nix-store -q --outputs "$DRV" 2>/dev/null | head -1)
    if [ -n "$OUT" ] && nix-store --check-validity "$OUT" 2>/dev/null; then
      echo "  退路（构造证明）: $OUT 已在 store 且有效"
      echo "  ✓ 一致 —— 定值派生的产物路径由 hash 决定；它能建出来，就说明当时下到的"
      echo "    内容确实哈希成 $WANT。**这不是重新下的，是构造证明。**"
      exit 0
    fi
    echo "  退路：派生 $DRV 的产物还没建，无法用构造证明"
  fi
fi

echo "  ? **没能验到** —— 上游拒绝重新下载，且没有 store 证据。"
echo "    可设 NIXPKGS_PATH=<一棵真 nixpkgs 树> 再跑，走构造证明那条路。"
exit 2
