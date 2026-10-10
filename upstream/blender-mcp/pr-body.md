# 提交计划：blender-mcp → nixpkgs

这份目录是 **dry-run 的产物**，不是已经提交的东西。
真要提交时按下面的计划走；每一步的判据在
[`skills/nixpkgs-package-upstream/SKILL.md`](../../skills/nixpkgs-package-upstream/SKILL.md)。

---

## 提交前必须处理的两件事

### ① 许可依据：**已经查到硬证据了**（不需要另行开 issue）

`v1.0.3` 这个 tag 里**没有 LICENSE 文件**（`contents/LICENSE?ref=v1.0.3` 返回 404），
根 `readme.md` 与 `mcp/README.md` 也都不提许可。
GPL-3.0 的 LICENSE 是 **2026-09-29** 才加进 `main` 的（提交 `dbbf836ad`），
比 v1.0.3 晚十八天。

**但许可本身在 v1.0.3 里是可核验的**，两处：

- **源文件头**：我们构建出来的 v1.0.3 产物里，`blmcp/__init__.py` 等文件带
  `# SPDX-License-Identifier: GPL-3.0-or-later`；add-on 的
  `blender_mcp_addon/__init__.py` 里也有。
- **add-on 清单**：`blender_manifest.toml` 的 `license = ["SPDX:GPL-3.0-or-later"]`。

**上游自己确认过这件事**：issue
[`#59`](https://projects.blender.org/lab/blender_mcp/issues/59)
「Add a license file for blender_mcp」（2026-09-28 提出，09-29 关闭）里，
维护者 `dfelinto` 的原话是：

> The license is in the individual files: `# SPDX-License-Identifier: GPL-3.0-or-later`
> But we will add a license file to the repository.

所以 **`meta.license = lib.licenses.gpl3Plus` 的依据是足的**——PR 里要引 #59，
并说明那个 tag 尚未带上 LICENSE 文件。**不需要再开一条 issue**：那条已经有人提过、也已经被处理了。

### ② 在 `maintainer-list.nix` 里加自己（独立 commit，排在包之前）

```nix
kihara777 = {
  name = "Kitsunori";
  github = "Kihara777";
  githubId = 24633616;
};
```

`githubId` 必须是 **24633616**（`https://api.github.com/user/24633616` 的 `login`
应当等于 `Kihara777`——审阅者会这样核，**已核过，对得上**）。

按决定**不写 `email`** —— 它是可选字段，既有条目里有 488 条同样不写。
插入位置、字段来源与旁证见同目录的 [`MAINTAINER-ENTRY.md`](MAINTAINER-ENTRY.md)。

---

## 两个 commit

顺序**不能反**。

**commit 1**（标题固定形式）

```
maintainers: add kihara777

Assisted-by: DeepSeek Harness (DeepSeek V4 Flash)
```

**commit 2**

> 正文与 [`commit-message.txt`](commit-message.txt) **逐字相同**（用 `git commit -F` 直接喂它）。
> 两处必须一起改——它们分家过一次，是我自己核出来的。

```
blender-mcp: init at 1.0.3

MCP server for Blender, developed by Blender Lab. It runs as a separate
process launched by the MCP client and talks to a Blender add-on over a
local TCP socket, so an LLM can inspect and drive a running Blender
instance. The add-on is installed by this package under
share/blender/scripts/addons/, so both halves come from one install.

Built from the upstream source at projects.blender.org.

The upstream test suite runs (102 passed, 9 skipped). One file is excluded
because it requires a real Blender editor instance. The package also carries
a small patch: the test helpers assign PYTHONPATH instead of appending to
it, which discards the dependencies outside a virtualenv. Reverting that
patch brings back 15 failures and 71 errors, so it is load-bearing rather
than cosmetic; it is offered to upstream.

Licence: the v1.0.3 tag itself carries no LICENSE file, but GPL-3.0-or-later
is declared by an SPDX header in every source file and by the add-on's
blender_manifest.toml. Upstream confirmed this in issue #59 and added a
LICENSE file to main in dbbf836ad.

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

At v1.0.3 the repository carries no LICENSE file. The licence is nevertheless
unambiguous: every source file carries `# SPDX-License-Identifier:
GPL-3.0-or-later`, and the add-on's `blender_manifest.toml` declares
`SPDX:GPL-3.0-or-later`. Upstream confirmed this in
https://projects.blender.org/lab/blender_mcp/issues/59 and added a LICENSE
file to `main` in commit `dbbf836ad` (2026-09-29, after the v1.0.3 tag).

### Things done

- Built on platform:
  - [x] x86_64-linux
  - [ ] aarch64-linux
  - [ ] aarch64-darwin
- [x] Tested basic functionality of all binary files, usually in `./result/bin/`.
  - `blender-mcp` was started and answered a JSON-RPC `initialize` request over
    stdio, reporting `serverInfo.name = "blender-mcp"` and offering prompts,
    resources and tools capabilities.
- [x] Runs the upstream test suite: 102 passed, 9 skipped.
  - `tests/test_blender_mcp_with_blender.py` is disabled: it needs a real
    Blender editor instance (`FileNotFoundError: 'blender'`), which a build
    sandbox cannot provide. The remaining tests do run, and they spawn the
    server as a subprocess and query it over MCP, so they cover this package's
    actual protocol surface.
  - The package patches two test helpers that assign `PYTHONPATH` rather than
    appending to it. Inside a virtualenv that is harmless, but outside one it
    discards every dependency, which makes the server subprocess fail to start.
    Reverting the patch brings back 15 failures and 71 errors, so it is load-
    bearing rather than cosmetic. I am happy to send it upstream instead if you
    prefer, so this package can drop the patch.
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
