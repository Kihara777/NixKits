# 提交计划：blender-mcp → nixpkgs（GrG41 名下）

**状态：内容已备好，等狐莉验证后发布。**

> 这一版是**为 GrG41 账户重做的**。前一条 PR（#572360）以 Kihara777 账户开出，
> 有两处必须修正的地方：
> ① 账户用错了——`DEC-011` 明确 `GrG41` 是我的账户、提交身份是
> `Kitsunome <152935465+GrG41@users.noreply.github.com>`；
> ② 包里的 `maintainers = [ ]` **是空的**，而 `pkgs/README.md:516` 写着
> 「`meta.maintainers` **must be set** for new packages」——
> 我加了维护者条目却没让包引用它（见文末「这次修掉的两处」）。

---

## 一、单一来源（不要在别处复制这些内容）

| 内容 | 单一来源 |
|---|---|
| commit 2 的正文 | [`commit-message.txt`](commit-message.txt) —— 用 `git commit -F` 直接喂，**不要手抄** |
| 维护者条目的落点与依据 | [`MAINTAINER-ENTRY.md`](MAINTAINER-ENTRY.md) |
| 待提交的包定义 | [`package.nix`](package.nix) —— 与将推送到 fork 的那份逐字节相同 |

> ⚠️ **今天在这上面摔过**：我发布 #572360 时在 `/tmp` 里用 `sed` 改了模型名，
> 却没写回源文件，于是**仓库里那份与已发布的那份不一致**。
> 现在这条规矩是硬的：**更正一律改源文件，禁止在做发布时临时改副本。**

---

## 二、两个 commit（顺序不能反）

### commit 1

```
maintainers: add grg41

Assisted-by: DeepSeek Harness (deepseek-flash)
```

内容：在 `maintainers/maintainer-list.nix` 里插入（位置在 `greydot` 与 `grgi` 之间）：

```nix
  grg41 = {
    github = "GrG41";
    githubId = 152935465;
    name = "Kitsunome";
  };
```

### commit 2

**正文 = [`commit-message.txt`](commit-message.txt) 逐字。** 标题：`blender-mcp: init at 1.0.3`

内容：新建 `pkgs/by-name/bl/blender-mcp/package.nix`。

---

## 三、账户与身份

| 项 | 值 |
|---|---|
| 提交账号 | `GrG41` |
| author / committer | `Kitsunome <152935465+GrG41@users.noreply.github.com>` |
| 维护者条目 | `grg41` / `githubId 152935465` |
| 包内引用 | `maintainers = [ lib.maintainers.grg41 ];` |

**noreply 地址的依据是 `DEC-011` 原文**（不是我拼的）：
「提交身份 `Kitsunome <152935465+GrG41@users.noreply.github.com>`」。

---

## 四、PR 标题与正文

**标题**：`blender-mcp: init at 1.0.3`

**正文**：

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

(This supersedes #572360, which I opened from the wrong account.)

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
    Reverting the patch brings back 15 test failures plus 117 `McpError` lines
    in the log, so it is load-bearing rather than cosmetic. I am happy to send
    it upstream instead if you prefer, so this package can drop the patch.
- [x] Fits CONTRIBUTING.md, pkgs/README.md, maintainers/README.md and other READMEs.
- [x] Follows the automation/AI policy.

### AI disclosure

The account submitting this (`GrG41`, display name 戦術人形Ｇ４１) is operated by
an AI agent, 小爪, which develops and maintains the packages under
https://github.com/Kihara777/NixKits. This contribution was produced by that
agent using DeepSeek Harness running `deepseek-flash`, and is disclosed as an
`Assisted-by:` trailer on each commit.

The responsible person in the sense of the automation/AI policy is 狐莉
(Kitsunori, https://github.com/Kihara777), who reviewed this contribution and
authorised its submission. Every claim above was checked by running it rather
than by inspection: the build, the `initialize` handshake and the upstream
test-suite results are all reproducible from the package definition in this PR.
```

---

## 五、发布步骤

```bash
# 1. 身份
gh auth switch --user GrG41
gh api user --jq .login          # 期望 GrG41

# 2. fork（已建）+ 分支
#    fork: GrG41/nixpkgs（已同步到 master 38fb26e7）
# 3. 两个 commit 通过 Git Data API 建（不整树克隆）
# 4. 建分支 refs/heads/init-blender-mcp
# 5. 关掉旧的 #572360（附说明）
# 6. 开新 PR
```

**关掉 #572360 时要在评论里说明原因**，不要让一条被关的 PR 无解释地挂着。

---

## 六、这次修掉的两处（相对 #572360）

| # | 问题 | 证据 | 现在 |
|---|---|---|---|
| 1 | `maintainers = [ ]` 空着 | `pkgs/README.md:516`「must be set for new packages」 | `maintainers = [ lib.maintainers.grg41 ];` |
| 2 | 账户用错 | `DEC-011` | GrG41，提交身份按 DEC-011 原文 |
| 3 | **包定义里混着我们自己的内部注释** | 审阅者会看到 `packages/blender-mcp.nix`、`build.sh`、`pr-body.md` 这些**在 nixpkgs 里不存在**的路径，外加一段我们内部的 `blender ? null` 决策史 | 已重写为面向审阅者的注释（142 → 111 行） |

**顺带修掉的第四处**：`commit-message.txt` 里的反证数字写成「71 errors」（真值 15 failed + 117 McpError）
与旧模型名 `DeepSeek V4 Flash`——**这两处在已发布的 #572360 里也是错的**，
因为我把更正的副本留在了 `/tmp`、没写回源文件。

**第 3 处是被狐莉「给我看完整内容」这句话撞出来的。** 我此前每一轮都只核
「能不能构建、测试过不过、判据翻不翻脸」——**从没通读一遍那份要发出去的文件本身**。
构建不关心注释，`nixpkgs-vet` 也不关心，所以没有任何判据会响。

---

## 七、判据（发布前已跑过）

| 判据 | 结果 |
|---|---|
| `maintainer-list.nix` 能解析 | ✅ `nix-instantiate --parse` |
| `grg41` 条目可读 | ✅ `{ github = "GrG41"; githubId = 152935465; name = "Kitsunome"; }` |
| **包真的能引用到它** | ✅ 反证：`before=false`（未加表时不存在）→ `after=true` |
| `package.nix` 能解析 | ✅ |
| nixfmt（两份） | ✅ 均通过 |
| 四层判据（求值/构建/产物/运行） | ✅ 见 [`READY.md`](READY.md) |

**仍未实测**（不许当成验过）：完整 `nix-update`、实际 `nixpkgs-vet`、
aarch64 构建、`r-ryantm` 行为。其中 `nixpkgs-vet` 与 `treefmt` 在 #572360 上
已由上游 CI 跑过一次并通过。
