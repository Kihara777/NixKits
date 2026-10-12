#!/usr/bin/env bash
# runtime.sh —— **运行层**判据：让真 OBS 把这个插件加载起来。
#
# 为什么非要走到这一层：「构建通过、产物里有 .so」说明不了插件可用——
# 一个没链对库、或者 obs_module_load 返回失败的插件，产物看起来一模一样。
#
# 做法：走 NixOS 模块同一条路（`wrapOBS { plugins = [ … ]; }`）包出两个 OBS：
# 一个挂了我们的插件，一个什么都不挂。在虚拟 X（Xvfb）+ 软件 GL（Mesa llvmpipe）
# 下各跑一次，读 OBS 自己写的日志。
#
# **两个臂缺一不可。** 少了「不挂插件」那一臂，「日志里有 bilibili」什么都证明不了
# ——它可能只是 OBS 念了一遍模块目录。
#
# 软件 GL 是必须的：Xvfb 不给 EGL，而 OBS 在**视频初始化之后**才加载模块
# （实测：视频起不来时日志里连一行 Loading module 都没有）。
#
# 用法：NIXPKGS_PATH=<一棵真 nixpkgs 树> bash upstream/obs-bilibili-stream/tests/runtime.sh
# 退出码：0 = 过；1 = 有失败；2 = 没能验到

set -uo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
DIR="$HERE/.."
NIXPKGS_PATH="${NIXPKGS_PATH:?要设 NIXPKGS_PATH 指一棵 nixpkgs 树}"

# 自举：缺工具就重入自己。**不把「工具不在 PATH」报成「没能验到」**——
# 前者我能修（重入一次），后者才是真的不知道。
if ! command -v xvfb-run >/dev/null 2>&1 || ! command -v nm >/dev/null 2>&1; then
  exec nix shell nixpkgs#xvfb-run nixpkgs#binutils --command bash "$0" "$@"
fi

MARK="插件加载成功"                 # 插件自己打印的那句
SO="bilibili-stream-for-obs.so"

fail=0; unverified=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=1; }
cant() { printf '  \033[33m?\033[0m %s\n' "$1"; unverified=1; }

PROBE=$(mktemp --suffix=.nix)
trap 'rm -f "$PROBE"' EXIT
cat > "$PROBE" <<PROBE_EOF
let
  pkgs0 = import (builtins.getFlake "path:$NIXPKGS_PATH") { system = "x86_64-linux"; };
  kitsunori = import $DIR/../maintainer-entry.nix;   # 单一来源，不在这里再抄一份
  pkgs = pkgs0.extend (final: prev: {
    lib = prev.lib.extend (lf: lp: { maintainers = lp.maintainers // { inherit kitsunori; }; });
  });
  plugin = pkgs.callPackage $DIR/package.nix { };
in
{
  inherit plugin;
  withPlugin    = pkgs.wrapOBS { plugins = [ plugin ]; };
  withoutPlugin = pkgs.wrapOBS { plugins = [ ]; };
}
PROBE_EOF

build_attr() {
  NIXPKGS_PATH="$NIXPKGS_PATH" nix build --impure --no-link --print-out-paths \
    --expr "(import $PROBE).$1" 2>/dev/null | tail -1
}

echo "① 建包与两个包装版 OBS"
PLUGIN=$(build_attr plugin);  [ -n "$PLUGIN" ] && ok "插件 $PLUGIN" || { cant "插件建不出来"; exit 2; }
WITH=$(build_attr withPlugin);    [ -n "$WITH" ]    || { cant "挂插件的包装版建不出来"; exit 2; }
WITHOUT=$(build_attr withoutPlugin); [ -n "$WITHOUT" ] || { cant "对照臂建不出来"; exit 2; }

echo "② 插件本体：导出 OBS 入口点了吗"
SOFILE="$PLUGIN/lib/obs-plugins/$SO"
if [ -f "$SOFILE" ]; then ok "产物里有 $SO"; else bad "找不到 $SO"; fi
if nm -D --defined-only "$SOFILE" 2>/dev/null | grep -q ' T obs_module_load'; then
  ok "导出 obs_module_load（OBS 靠它加载）"
else
  bad "没有 obs_module_load —— OBS 不会认它"
fi

echo "③ 运行层：挂上插件跑真 OBS，读它自己写的日志"
MESA=$(nix build --no-link --print-out-paths nixpkgs#mesa 2>/dev/null | tail -1)
run_obs() {  # $1 = OBS 前缀；打印日志路径
  local tmp; tmp=$(mktemp -d)
  timeout 70 xvfb-run -a -s "-screen 0 1280x720x24 +extension GLX +render" \
    env HOME="$tmp" LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe \
        __EGL_VENDOR_LIBRARY_FILENAMES="$MESA/share/glvnd/egl_vendor.d/50_mesa.json" \
        LD_LIBRARY_PATH="$MESA/lib" \
    "$1/bin/obs" --disable-shutdown-check >/dev/null 2>&1
  find "$tmp" -name '*.txt' -path '*logs*' 2>/dev/null | head -1
}

LOGA=$(run_obs "$WITH")
if [ -z "$LOGA" ] || [ ! -s "$LOGA" ]; then
  cant "OBS 没写出日志（这台机器上起不来）—— 没能验到"
else
  if grep -q "$MARK" "$LOGA"; then ok "OBS 日志里有插件自己打印的「$MARK」"
  else bad "日志里没有「$MARK」"; fi
  if grep -q "$SO" "$LOGA"; then ok "Loaded Modules 里有 $SO"
  else bad "Loaded Modules 里没有 $SO"; fi
  echo "      日志里与插件有关的行："
  grep -n 'bilibili' "$LOGA" | head -4 | sed 's/^/        /'
fi

echo "④ 对照臂：**不挂**插件时，上面那些行不该出现"
LOGB=$(run_obs "$WITHOUT")
if [ -z "$LOGB" ] || [ ! -s "$LOGB" ]; then
  cant "对照臂也没写出日志 —— 没能验到"
elif grep -q "$MARK" "$LOGB" || grep -q "$SO" "$LOGB"; then
  bad "不挂插件却出现了我们的日志行 —— 说明第 ③ 步量的不是我们挂的东西"
else
  ok "对照臂干净（既没有「$MARK」，也没有 $SO）"
fi

echo
if [ $fail -ne 0 ]; then echo "有失败项"; exit 1
elif [ $unverified -ne 0 ]; then echo "有**没能验到**的项 —— 那不等于通过"; exit 2
else echo "OK: 构建、入口点、真 OBS 加载、对照臂 —— 都亮过相"; fi
