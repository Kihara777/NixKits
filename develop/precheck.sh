#!/usr/bin/env bash
# 推之前，对着「要推的那棵树」跑一遍本地检查。
#
# 为什么不是对着工作树跑：**工作树一致 ≠ 提交的内容一致**。2026-10-05 实测——
# 把四语维护日志拆成两批提交，只有 ja 那一份先提交，其余三语还是旧条目数，
# 那个中间提交自己不一致，CI 报 `entry counts differ across languages`；
# 而当时对着工作树跑 `check-maintenance-log.py` 是全绿的，抓不到它。
#
# 用法：
#   develop/precheck.sh            # 对着 HEAD 的树
#   develop/precheck.sh <commit>   # 对着指定提交的树
#
# 实现：`git worktree` 把目标提交物化到临时目录（其中 ROOT 由脚本自身路径推导，
# 所以检查会作用在那棵树上），逐个跑完再清理。
set -euo pipefail
cd "$(dirname "$0")/.."

target="${1:-HEAD}"
tmp="$(mktemp -d)"
cleanup() { git worktree remove --force "$tmp" >/dev/null 2>&1 || rm -rf "$tmp"; }
trap cleanup EXIT

# NixOS 的 PATH 极简，`python3` 常常不在上面；退回到 `nix shell` 现取一份。
if command -v python3 >/dev/null 2>&1; then
  PY=(python3)
elif command -v nix >/dev/null 2>&1; then
  PY=(nix shell nixpkgs#python3 --command python3)
else
  echo "找不到 python3，也没有 nix 可以现取一份。" >&2
  exit 1
fi

git worktree add -q --detach "$tmp" "$target"
echo "== 对着 $(git -C "$tmp" rev-parse --short HEAD) 的树跑检查（worktree: $tmp）=="
cd "$tmp"

fail=0
for script in develop/check-*.py; do
  printf '  %-34s' "$(basename "$script")"
  if out="$("${PY[@]}" "$script" 2>&1)"; then
    echo "OK"
  else
    echo "FAIL"
    echo "$out" | sed 's/^/      /'
    fail=1
  fi
done

if command -v node >/dev/null 2>&1; then
  printf '  %-34s' "news-mode-tests"
  if out="$(node packages/dsh-preset-news-three-elements/tests/mode.test.mjs 2>&1)"; then
    echo "OK"
  else
    echo "FAIL"; echo "$out" | sed 's/^/      /'; fail=1
  fi
else
  echo "  news-mode-tests                   跳过（node 不在 PATH）"
fi

if [ "$fail" -ne 0 ]; then
  echo "→ 这棵树过不了自检，别推。" >&2
  exit 1
fi
echo "→ 这棵树全过。"
