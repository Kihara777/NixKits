#!/usr/bin/env bash
# discovery.sh —— 验一件「构建成功」验不到的事：
# **把 package.nix 放进 plugins/ 后，它会不会被自动发现、被发现成什么名字。**
#
# 来历：nixpkgs 的 OBS 插件接线已从「手工在 plugins/default.nix 加一行」
# 改成 `lib.packagesFromDirectoryRecursive { directory = ./plugins; }` 的自动发现。
# 于是「文件名 → 属性名」这件事成了判据的一部分，而它构建时看不出来。
#
# 这里不复制 package.nix —— fixture 是**临时生成的**（复制会产生会漂的副本）。
#
# 用法：NIXPKGS_PATH=<一棵真 nixpkgs 树> bash upstream/obs-bilibili-stream/tests/discovery.sh

set -uo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
PKG="$HERE/../package.nix"
NIXPKGS_PATH="${NIXPKGS_PATH:?要设 NIXPKGS_PATH 指一棵 nixpkgs 树}"

[ -f "$PKG" ] || { echo "找不到 $PKG" >&2; exit 2; }
# 本脚本用 python3 读 JSON。**缺了要说「没能验到」（退出码 2），不能说「失败」**——
# 今天已经有五次「工具没跑起来」被我的检查器报成了「判据不通过」。
command -v python3 >/dev/null 2>&1 || {
  echo "需要 python3（用 nixos_shell 的 tools 参数，或 nix shell nixpkgs#python3）" >&2
  exit 2
}

FIX=$(mktemp -d)
# 探针必须放在被测目录**外面**：放在里面它自己会被自动发现成一个叫 `probe` 的包
# ——第一次跑就是这么失败的（判据自己成了被测物的一部分）。
PROBE=$(mktemp --suffix=.nix)
PROBE_NAMES=$(mktemp --suffix=.nix)
trap 'rm -rf "$FIX" "$PROBE" "$PROBE_NAMES"' EXIT

cp "$PKG" "$FIX/obs-bilibili-stream.nix"
# 非 .nix 文件**必须被忽略**（packagesFromDirectoryRecursive 的规则）
echo "这个文件不该被收" > "$FIX/README.txt"
# 干扰样本：名字排在前面，用来确认收的是文件名而不是别的
cat > "$FIX/aaa-noise.nix" <<'NOISE'
{ lib, stdenv }: stdenv.mkDerivation { pname = "aaa-noise"; version = "0"; }
NOISE

cat > "$PROBE" <<PROBE
let
  pkgs0 = import (builtins.getFlake "path:$NIXPKGS_PATH") { system = "x86_64-linux"; };
  # 包定义引用 lib.maintainers.grg41，而一棵纯 nixpkgs 里没有这个条目
  # ——它由本 PR 的**第一个 commit** 加进 maintainer-list.nix。
  # 这里注进去以模拟**合并之后**的状态；三个字段与那个 commit 逐字相同。
  grg41 = import $HERE/../../maintainer-entry.nix;
  pkgs = pkgs0.extend (final: prev: {
    lib = prev.lib.extend (lf: lp: { maintainers = lp.maintainers // { inherit grg41; }; });
  });
  discovered = pkgs.lib.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage;
    directory = $FIX;
  };
in
{
  names = builtins.attrNames discovered;
  hasName = discovered ? obs-bilibili-stream;
  pname = discovered.obs-bilibili-stream.pname or null;
  version = discovered.obs-bilibili-stream.version or null;
  drv = discovered.obs-bilibili-stream.drvPath;
  platforms = discovered.obs-bilibili-stream.meta.platforms;
  maintainers = map (m: m.github or m.name) discovered.obs-bilibili-stream.meta.maintainers;
  license = discovered.obs-bilibili-stream.meta.license.spdxId or null;
}
PROBE

cat > "$PROBE_NAMES" <<NAMES
let
  pkgs0 = import (builtins.getFlake "path:$NIXPKGS_PATH") { system = "x86_64-linux"; };
  grg41 = import $HERE/../../maintainer-entry.nix;
  pkgs = pkgs0.extend (final: prev: {
    lib = prev.lib.extend (lf: lp: { maintainers = lp.maintainers // { inherit grg41; }; });
  });
in
builtins.attrNames (pkgs.lib.packagesFromDirectoryRecursive {
  inherit (pkgs) callPackage;
  directory = $FIX;
})
NAMES

OUT=$(cd "$FIX" && NIXPKGS_PATH="$NIXPKGS_PATH" nix eval --impure --json --file "$PROBE" 2>&1)
rc=$?
if [ $rc -ne 0 ]; then
  echo "✗ 求值失败："; echo "$OUT" | head -12; exit 1
fi

python3 - "$OUT" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
fail = 0
def chk(label, got, want):
    global fail
    ok = got == want
    print(f"  {'✓' if ok else '✗'} {label}: {got!r}" + ("" if ok else f"  （要 {want!r}）"))
    if not ok: fail = 1

print("=== 自动发现 ===")
chk("被发现的属性名（排序）", sorted(d["names"]), ["aaa-noise", "obs-bilibili-stream"])
chk("非 .nix 文件被忽略", "README.txt" in d["names"], False)
chk("认出了 obs-bilibili-stream", d["hasName"], True)
chk("pname", d["pname"], "obs-bilibili-stream")
chk("version", d["version"], "2.1.5")
chk("platforms（继承 obs-studio，不含 riscv64）", d["platforms"],
    ["x86_64-linux", "i686-linux", "aarch64-linux"])
chk("platforms 里没有 riscv64-linux", "riscv64-linux" in d["platforms"], False)
chk("maintainers", d["maintainers"], ["GrG41"])
chk("license", d["license"], "GPL-2.0-only")

print("\n=== 反证臂：名字必须来自**文件名**，不是别的 ===")
# 把同一个文件换个名字放进去，属性名应当跟着变 —— 若不变，说明上面那条判据是假的
import tempfile, pathlib, os
print("  （见下一段 bash）")
sys.exit(fail)
PY
rc=$?
[ $rc -ne 0 ] && { echo; echo "有失败项"; exit 1; }

# ── 反证臂 ────────────────────────────────────────────────────────────────
# 把同一个文件换个名字放进去，属性名应当跟着变 —— 若不变，说明「名字来自文件名」
# 那条判据是假的（也许它其实来自 pname，那样改名就不会变）。
echo
echo "=== 反证：换个文件名，属性名应当跟着变 ==="
rm -f "$FIX/obs-bilibili-stream.nix"
cp "$PKG" "$FIX/renamed-thing.nix"

OUT2=$(cd "$FIX" && NIXPKGS_PATH="$NIXPKGS_PATH" nix eval --impure --json --file "$PROBE_NAMES" 2>&1)
if echo "$OUT2" | grep -q '"renamed-thing"' && ! echo "$OUT2" | grep -q '"obs-bilibili-stream"'; then
  echo "  ✓ 改名后属性名跟着变成 renamed-thing，且原名消失 —— 名字确实来自文件名"
else
  echo "  ✗ 改名后没跟着变，说明前面那条判据不成立："
  echo "$OUT2" | head -6 | sed 's/^/      /'
  exit 1
fi

echo
echo "OK: 自动发现、属性名来源、字段继承 —— 每条都亮过相，且反证臂通过"

