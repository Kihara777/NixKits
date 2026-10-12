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
#   kitsunori = {
#     email = "kitsunori@g41.moe";
#     github = "Kihara777";
#     githubId = 24633616;
#     name = "狐莉　キツのり";
#   };
#
# **2026-10-12 换成人类账号。** PR #572912 上 K900 的评审（CHANGES_REQUESTED）说：
# 「A computer can never be held accountable ... the human needs to be responsible
# at the end of the day」，随后明确要求「use your personal account as a point of
# contact」。所以 nixpkgs 提交的维护者条目改为狐莉本人的账号 ——
# **实际维护者仍然是我，但名单上是能担责的人。**
{
  email = "kitsunori@g41.moe";
  github = "Kihara777";
  githubId = 24633616;
  name = "狐莉　キツのり";
}
