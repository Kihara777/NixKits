# derive-preset —— 在构建期把一层预设从它的父派生出来。
#
#     derivePreset { parent = ./presets/nixos-mode/preset.patch.yml;
#                    overlay = ./presets/fuli-mode/overlay.yml;
#                    name = "fuli-mode"; }
#
# 产出是一个 store 路径，内容就是那个 `preset.patch.yml`。
#
# ## 为什么在构建期
#
# 成品存进 git 就等于同一段内容有两个来源，而两份一定会漂——2026-11-09 那天，
# 掌灯的一份 916 行拷贝让「改上游」变成了「改一份没人用的代码」。构建期生成之后，
# 仓库里只有「父」和「差异」，**漂的空间不存在**，不靠人记得对齐，也不靠判据盯着。
#
# ## 为什么父也要是 store 路径
#
# 父可以来自另一个仓库（Kitsunome 的掌灯派生于 NixKits 的 fuli-mode）。只要两边
# 都是 flake 输入，父就是一个 store 路径，跨仓库的派生和同仓库的派生走同一条路。
#
# ## 失败会怎样
#
# 生成器对「父里没有这个 id」「overlay 缺 meta.id」「insert 的锚点不存在」都是
# **非零退出**，所以这些错误是构建期失败，不是等 dsh 加载时才空转。
{ pkgs }:
{
  parent,
  overlay,
  name,
}:
pkgs.runCommand "preset-${name}.patch.yml" {
  nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.pyyaml ])) ];
} ''
  python3 ${./apply-overlay.py} ${parent} ${overlay} > $out
''
