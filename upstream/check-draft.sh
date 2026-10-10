#!/usr/bin/env bash
# check-draft.sh —— 对一个「待提交到 nixpkgs 的包定义」跑评审者提过的每一类问题。
#
# 来历：2026-10-10 的第一个上游 PR（#572360）被评审者要求修改，三条：
#   ① 包定义里有指向别仓与本 PR 未包含文件的准备笔记
#   ② meta.maintainers 是空的，而前一个 commit 刚加了维护者条目
#   ③ 代码注释要用英文（nixpkgs 是国际项目）
# 随后我自己逐行审计又查出两条（判据全都抓不到）：
#   ④ nativeBuildInputs 里留着已无人使用的 makewrapper
#   ⑤ doCheck = true 在 python 包里是冗余的
#
# 这个脚本把**机械可查**的那些钉死，让同一件事不需要被提醒第二次。
# 查不到的（注释是不是写给外人的、这一项该不该存在）仍在第 3.5 节的逐行四问里，
# 靠人读——**脚本不是它的替代品**。
#
# 用法：
#   bash upstream/check-draft.sh upstream/blender-mcp/package.nix
#   bash upstream/check-draft.sh upstream/obs-bilibili-stream/package.nix
#
# 退出码：0 = 全过；1 = 有项失败；2 = **没能验到**（路径不对、工具缺失等）

set -uo pipefail

FILE="${1:-}"
NIXPKGS_PATH="${NIXPKGS_PATH:-}"
fail=0
unverified=0

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "用法：bash upstream/check-draft.sh <package.nix>" >&2
  echo "      或设 NIXPKGS_PATH=<一棵真 nixpkgs 树>" >&2
  exit 2
fi

pass() { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
cant() { printf '  \033[33m?\033[0m %s\n' "$1"; unverified=1; }

echo "检查 $FILE"
echo

# ── ① 指向别仓 / 本 PR 之外的文件 ───────────────────────────────────────────
echo "① 有没有指向本 PR 之外的路径"
# 我们自己的文件名、目录名出现在注释里就会命中
hits=$(grep -nE 'packages/[a-z0-9-]+\.nix|build\.sh|pr-body\.md|MAINTAINER-ENTRY\.md|READY\.md|VERIFICATION\.md|NixKits|本仓|dry-run' "$FILE" || true)
if [ -z "$hits" ]; then
  pass "无本仓引用"
else
  bad "引用了本 PR 之外的东西："
  echo "$hits" | sed 's/^/      /'
fi

# ── ③ 注释语言（用非 ASCII 作代理判据）─────────────────────────────────────
echo "② 注释是否为英文（非 ASCII 字符的代理判据）"
nonascii=$(grep -nP '[^\x00-\x7F]' "$FILE" || true)
if [ -z "$nonascii" ]; then
  pass "无非 ASCII 字符"
else
  bad "含非 ASCII 字符（注释很可能是中文——nixpkgs 要英文）："
  echo "$nonascii" | head -5 | sed 's/^/      /'
  echo "      （若确为专有名词/作者名，逐个确认后可放行）"
fi

# ── ② meta 必填项与 maintainers ─────────────────────────────────────────────
#
# 分两类，**不要混**：
#   · 无条件必填：description / license / maintainers
#   · 条件必填：mainProgram —— nixpkgs 的措辞是「**适用时**必须设置」
#     （主可执行文件名）。插件、库这类不产可执行文件的包**不该设**它。
#
# 这里原本把 mainProgram 也当无条件必填，于是对 OBS 插件报了一个假警报
# ——而 nixpkgs 里 54 个 OBS 插件没有一个设它。**判据的射程要按原文，不按印象。**
echo "③ meta 必填项（无条件）"
for k in description license maintainers; do
  if grep -qE "^[[:space:]]+$k =" "$FILE"; then
    pass "$k"
  else
    bad "$k 缺失"
  fi
done
echo "④ mainProgram（条件必填：只在产出可执行文件时设）"
if grep -qE '^[[:space:]]+mainProgram = ' "$FILE"; then
  pass "设了 mainProgram"
else
  cant "没设 mainProgram —— 若本包产出可执行文件，这一条就是缺失；若是插件/库，属正确"
fi
if grep -qE '^[[:space:]]+maintainers = \[ \];' "$FILE"; then
  bad "maintainers 是空的 —— pkgs/README.md「must be set for new packages」"
elif grep -qE '^[[:space:]]+maintainers = \[ ' "$FILE"; then
  pass "maintainers 非空"
fi

echo "⑤ 描述格式"
# 纯 bash：不用 python3。**这里原本用 python3，而它不在 PATH 上，
# 于是「命令跑不起来」被报成了「描述格式失败」——又一次假警报。
# 判据跑不起来必须说「没能验到」，不能说「失败」。**
desc=$(sed -n 's/^[[:space:]]*description = "\(.*\)";$/\1/p' "$FILE" | head -1)
pname=$(sed -n 's/^[[:space:]]*pname = "\(.*\)";$/\1/p' "$FILE" | head -1)
if [ -z "$desc" ]; then
  cant "取不到 description（可能不是单行 \"…\"; 形式）"
else
  d_fail=""
  case "$desc" in
    [A-Z]*) : ;;
    *) d_fail="$d_fail 首字母不是大写；" ;;
  esac
  case "$desc" in *.) d_fail="$d_fail 以句点结尾；" ;; esac
  if [ -n "$pname" ]; then
    dlow=$(printf '%s' "$desc" | tr 'A-Z' 'a-z')
    plow=$(printf '%s' "$pname" | tr 'A-Z' 'a-z')
    case "$dlow" in "$plow"*) d_fail="$d_fail 以包名开头；" ;; esac
  fi
  if [ -z "$d_fail" ]; then
    pass "描述格式合规"
  else
    bad "描述不合规：$desc"
    printf '%s\n' "      → $d_fail"
  fi
fi

# ── ④ 已知的冗余（python 包）─────────────────────────────────────────────────
echo "⑥ 已知冗余（python builder）"
if grep -qE 'buildPythonApplication|buildPythonPackage' "$FILE"; then
  if grep -qE '^[[:space:]]+nativeBuildInputs = \[ makeWrapper \];' "$FILE"; then
    bad "显式的 makeWrapper 输入 —— wrap-python-hook 自己 propagatedBuildInputs 就带它"
  else
    pass "无冗余的 makeWrapper"
  fi
  if grep -qE '^[[:space:]]+doCheck = true;' "$FILE"; then
    bad "doCheck = true 冗余 —— mk-python-derivation 强制 doCheck=false、doInstallCheck 默认 true"
  else
    pass "无冗余的 doCheck"
  fi
else
  cant "不是 python 包，跳过 python 专属两项"
fi

echo "⑦ 调试残留"
resid=$(grep -nE 'MARKER|TODO|FIXME|XXX|lib\.fakeHash|builtins\.trace' "$FILE" || true)
if [ -z "$resid" ]; then pass "无"; else bad "有："; echo "$resid" | sed 's/^/      /'; fi

# ── 格式与解析 ──────────────────────────────────────────────────────────────
echo "⑧ nixfmt 与解析"
if [ -n "$NIXPKGS_PATH" ] && [ -e "$NIXPKGS_PATH" ]; then
  if nix run "$NIXPKGS_PATH#nixfmt" -- --check "$FILE" >/dev/null 2>&1; then
    pass "nixfmt"
  else
    bad "nixfmt 不通过"
  fi
else
  cant "没给 NIXPKGS_PATH，nixfmt 没跑"
fi
if nix-instantiate --parse "$FILE" >/dev/null 2>&1; then
  pass "能被 Nix 解析"
else
  bad "Nix 解析失败"
fi

# ── 参数是否都有用 ──────────────────────────────────────────────────────────
echo "⑨ 参数是否都被用到（参数名从求值读，不从源码文本读）"
if [ -n "$NIXPKGS_PATH" ] && [ -e "$NIXPKGS_PATH" ]; then
  params=$(nix-instantiate --eval --json --expr "builtins.attrNames (builtins.functionArgs (import $PWD/$FILE))" 2>/dev/null | tr -d '[]"' | tr ',' ' ')
  if [ -z "$params" ]; then
    cant "取不到参数表（可能求值失败）"
  else
    for p in $params; do
      n=$(grep -cE "(^|[^A-Za-z0-9_-])$p([^A-Za-z0-9_-]|$)" "$FILE")
      # 参数在签名里出现 1 次，正文里至少还要 1 次
      if [ "$n" -le 1 ]; then bad "参数 $p 只出现 $n 次（疑似死参数）"; else pass "$p 用了 $n 次"; fi
    done
  fi
else
  cant "没给 NIXPKGS_PATH，参数表取不到"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "有失败项 —— 见上"
  exit 1
elif [ "$unverified" -ne 0 ]; then
  echo "机械项全过，但有**没能验到**的项（见上）—— 那不等于通过"
  exit 2
else
  echo "机械项全过。**逐行四问仍要人读**（见 skills/nixpkgs-package-upstream 第 3.5 节）。"
fi
