#!/usr/bin/env bash
# check-consistency.sh —— 盯着「同一件事存在多处」的那些地方。
#
# 来历：2026-10-10 一天里，我撞到同一种病四次——**改了一处，忘了别的副本**：
#   · 在 /tmp 里改了模型名，没写回仓库源文件（仓库那份与已发布的不一致）
#   · 删减 zh 维护日志摘要，没同步 en / ja / pcn（条目数不一致）
#   · 维护者条目曾经在 4 个文件里各存一份
#   · pcn 里的「阱」不是日文字形
#
# 「我这次检查过它们相同」不是判据——**那是恰好相同**。
# 判据是：有一个东西能把它们钉在一起，且它翻过脸。
#
# 用法：bash upstream/check-consistency.sh

set -uo pipefail
cd "$(cd "$(dirname "$0")" && pwd)"

fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
cant() { printf '  \033[33m?\033[0m %s\n' "$1"; fail=2; }

command -v python3 >/dev/null 2>&1 || {
  echo "需要 python3" >&2; exit 2; }

echo "=== 维护者条目：nix 单一来源 vs 文档那份 ==="
python3 - <<'PY'
import pathlib, re, sys
src = pathlib.Path('maintainer-entry.nix').read_text()
d = {}
# 值有带引号的也有裸写的（githubId = 152935465）——两种都要收。
# 早先只收带引号的，于是 KeyError: 'githubId'，整段判据没跑就崩了。
for k, q, b in re.findall(r'^\s*(\w+) = (?:"([^"]*)"|([A-Za-z0-9_.]+));', src, re.M):
    d[k] = q if q else b
want = f'''  grg41 = {{
    email = "{d['email']}";
    github = "{d['github']}";
    githubId = {d['githubId']};
    name = "{d['name']}";
  }};'''
doc = pathlib.Path('MAINTAINER-ENTRY.md').read_text()
m = re.search(r'```nix\n(.*?)\n```', doc, re.S)
if not m:
    print("  ✗ 文档里找不到 nix 代码块"); sys.exit(1)
got = m.group(1).strip()
if got == want.strip():
    print("  ✓ MAINTAINER-ENTRY.md 里那份与 maintainer-entry.nix 逐字相同")
else:
    print("  ✗ 文档那份与单一来源不一致（**它已经漂了**）")
    print("    单一来源："); print("      " + want.replace('\n', '\n      '))
    print("    文档里："); print("      " + got.replace('\n', '\n      '))
    sys.exit(1)
PY
rc=$?; [ $rc -ne 0 ] && fail=1

echo "=== 代码侧不应再有内联的维护者条目 ==="
# 排掉本脚本自己：它的 grep **模式**里就含那个字符串（第一次跑就是这么自我命中的）。
hits=$(grep -rn 'githubId = 152935465' --include='*.nix' --include='*.sh' . \
       | grep -v '^./maintainer-entry.nix' | grep -v '^./check-consistency.sh' || true)
if [ -z "$hits" ]; then ok "只有 maintainer-entry.nix 里有它"
else bad "还有地方内联着它："; echo "$hits" | sed 's/^/      /'; fi

echo "=== 披露里的模型名：所有自我披露处同值 ==="
# 只查**会被发出去的产物**（commit 正文与 PR 正文）。
# 计划类文档里提到旧名是在记录更正史，那是事实，不算残留；
# dsh 的 API 模型 id 是另一回事，更不在此列。
MODEL='DeepSeek-V41-Flash'
# 判据只针对**自我披露行**（`Assisted-by:` 与披露正文里那句「running `…`」），
# 不针对历史叙述——计划类文档里提到旧名是在记录更正史，那是事实。
# 规则写宽了会把事实判成残留（本脚本第一版就是这样误报的）。
bad_model=$(grep -rhnE 'Assisted-by:|running `' \
              blender-mcp/pr-body.md obs-bilibili-stream/pr-body.md \
              blender-mcp/commit-message.txt obs-bilibili-stream/commit-message.txt 2>/dev/null \
            | grep -E 'deepseek-flash|DeepSeek V4 Flash' || true)
if [ -z "$bad_model" ]; then ok "上游草稿里没有旧模型名残留"
else bad "这些文件里还有旧名："; echo "$bad_model" | sed 's/^/      /'; fi
n=$(grep -rc "$MODEL" blender-mcp/commit-message.txt obs-bilibili-stream/commit-message.txt 2>/dev/null | grep -c ':1$')
[ "$n" = "2" ] && ok "两个 commit 正文都用了 $MODEL" || bad "commit 正文里的模型名不是 $MODEL（$n/2）"

echo "=== 各草稿的 src hash：独立复算 ==="
# 脚本收成一个（upstream/verify-src.sh），不再每个包一份副本。
# 退出码 0=一致（含构造证明）1=不一致 2=没能验到。**2 不等于通过。**
for pkg in blender-mcp obs-bilibili-stream; do
  printf '  %-22s ' "$pkg"
  out=$(NIXPKGS_PATH="${NIXPKGS_PATH:-}" bash ./verify-src.sh "$pkg" 2>&1); rc=$?
  case $rc in
    0) echo "✓ $(echo "$out" | grep -oE '（\*\*真的重新下了一遍\*\*算出来的）|构造证明' | head -1)";;
    1) echo "✗ **不一致**"; fail=1;;
    *) echo "? 没能验到"; fail=2;;
  esac
done

echo
[ "$fail" = "0" ] && echo "一致" || { [ "$fail" = "2" ] && echo "有**没能验到**的项（不等于通过）" || echo "有失败项"; }
exit "$fail"
