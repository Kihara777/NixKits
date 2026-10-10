# 提交计划：blender-mcp → nixpkgs

这份目录是 **dry-run 的产物**，不是已经提交的东西。
真要提交时按下面的计划走；每一步的判据在
[`skills/nixpkgs-package-upstream/SKILL.md`](../skills/nixpkgs-package-upstream/SKILL.md)。

---

## 提交前必须先解决的两件事

### ① 向上游补许可依据（**先做这个**）

`v1.0.3` 这个 tag 里**没有 LICENSE 文件**（`contents/LICENSE?ref=v1.0.3` 返回 404），
根 `readme.md` 与 `mcp/README.md` 也都不提许可。
GPL-3.0 的 LICENSE 是 **2026-09-29** 才加进 `main` 的（提交 `dbbf836ad`），
比 v1.0.3 晚 18 天。

我们能拿到的依据只有两处，**都不在那个 tag 里**：

- add-on 的 `blender_manifest.toml`：`license = ["SPDX:GPL-3.0-or-later"]`
- `main` 上的 LICENSE（35147 字节）

**做法**：在 `projects.blender.org/lab/blender_mcp` 开一条 issue，
请上游给已发布的 tag 补许可文件、或告知下一个 tag 的时间。
这比直接提 PR 更有价值——它同时也在帮上游。

**这不是可选项。** nixpkgs 要求 `meta.license` 与上游一致，
审阅者看到被取的 tag 里没有许可文件就会问。

### ② 在 `maintainer-list.nix` 里加自己（独立 commit，排在包之前）

```nix
kihara777 = {
  name = "Kitsunori";
  email = "<你希望公开的邮箱>";
  github = "Kihara777";
  githubId = 24633616;
};
```

`githubId` 必须是 **24633616**（`https://api.github.com/user/24633616` 的 `login`
应当等于 `Kihara777`——审阅者会这样核）。

---

## 两个 commit

顺序**不能反**。

**commit 1**（标题固定形式）

```
maintainers: add kihara777

Assisted-by: DeepSeek Harness (DeepSeek V4 Flash)
```

**commit 2**

```
blender-mcp: init at 1.0.3

MCP server for Blender, developed by Blender Lab. It runs as a separate
process launched by the MCP client and talks to a Blender add-on over a
local TCP socket.

Built from the upstream source at projects.blender.org; the Blender add-on
is installed alongside the server under share/blender/scripts/addons/.
Upstream pytest suite is not enabled yet in this commit.

Licence: the v1.0.3 tag itself carries no LICENSE file; GPL-3.0-or-later is
declared by the add-on's blender_manifest.toml and by the LICENSE added to
main in dbbf836ad.

Assisted-by: DeepSeek Harness (DeepSeek V4 Flash)
```

> **`Assisted-by:` 是强制披露格式**，`Co-authored-by:` **不算**。
> 这是 nixpkgs 的 AI 政策明文要求的，见 `CONTRIBUTING.md#automationai-policy`。

---

## PR 摘要草案

```markdown
Adds blender-mcp, the Model Context Protocol server for Blender developed by
Blender Lab. It is the server half of a two-part design: an MCP client launches
`blender-mcp` over stdio, and the server talks to a Blender add-on over a local
TCP socket so an LLM can inspect and drive a running Blender instance. The
add-on is installed by this package under `share/blender/scripts/addons/`, so
both halves come from one install.

At v1.0.3 the repository carries no LICENSE file; GPL-3.0-or-later is declared
by the add-on's `blender_manifest.toml` and by the LICENSE file that was added
to `main` in commit `dbbf836ad` (2026-09-29, i.e. after the v1.0.3 tag). I have
asked upstream to attach a licence file to the released tags.

### Things done

- Built on platform:
  - [x] x86_64-linux
  - [ ] aarch64-linux
  - [ ] aarch64-darwin
- [x] Tested basic functionality of all binary files, usually in `./result/bin/`.
  - `blender-mcp` was started and answered a JSON-RPC `initialize` request over
    stdio, reporting `serverInfo.name = "blender-mcp"` and offering prompts,
    resources and tools capabilities.
- [x] Fits CONTRIBUTING.md, pkgs/README.md, maintainers/README.md and other READMEs.
- [x] Follows the automation/AI policy.

### AI disclosure

This PR was prepared with the assistance of an LLM-based tool. The tool is
DeepSeek Harness running DeepSeek V4 Flash; the same disclosure is recorded as
an `Assisted-by:` trailer on each commit. Every part of this contribution —
the package expression, the build and the runtime check described above — was
reviewed and verified by me before submission, and I am the person responsible
for it in the sense of the automation/AI policy.
```

> 披露段要**独立写在这里**，不能只靠 commit trailer——
> 政策要求「PR 摘要与评审评论各自单独披露」。

---

## 提交后

- PR 模板的 `nixpkgs-review` 那一项：本机跑一次再勾。
- 等待时间：原文说「数天到数周乃至数月无反馈完全正常」。
  **至少一周**无活动再去 Discourse 的 review-requests 帖或 Matrix 频道。
- **评审来了由狐莉答复**（AI 政策要求贡献者自己能答问，不能把意见转发给工具）。
