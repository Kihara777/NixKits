# 维护者条目的**单一来源**。
#
# 这段内容要在三个地方用：
#   · `upstream/MAINTAINER-ENTRY.md` 里给人看（那是文档，只能另存一份文字）
#   · `blender-mcp/build.nix` 与 `obs-bilibili-stream/build.nix` 注入进 pkgs.lib
#     （模拟「合并之后」的 nixpkgs）
#   · `obs-bilibili-stream/tests/discovery.sh` 的探针同理
#
# 2026-10-10 之前这三处各抄了一份 —— 实测当时逐字相同，但**那是恰好**。
# 今天我在别处撞过好几次「改了一处忘了其余副本」，所以把代码侧的三个副本
# 收成这一个文件；文档那份由 `tests/consistency.sh` 盯着。
#
# 要提交进 nixpkgs 的形态是：
#
#   grg41 = {
#     email = "gr@g41.moe";
#     github = "GrG41";
#     githubId = 152935465;
#     name = "戦術人形Ｇ４１";
#   };
{
  email = "gr@g41.moe";
  github = "GrG41";
  githubId = 152935465;
  name = "戦術人形Ｇ４１";
}
