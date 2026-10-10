# 两个「提交后被问到」的点的取证记录

这两条不是我猜的，也不是从文档抄的——都是实测出来的。提交前留着，PR 上万一被问到可以直接答。

---

## 一、`passthru.updateScript` 对我们这个自托管 Gitea 有效吗？

**结论：有效。但这不是「显然」的——`nix-update` 是探测式判断 host 的。**

### 它是怎么判断的

`nix_update/version/__init__.py` 的 fetcher 列表里，**Gitea 排在最后**，注释写着
「all entries below perform requests to check if the target url is of that type」——
也就是说前面几个（crate / npm / pypi / github / gitlab / …）先试，最后才轮到 Gitea 去探。

`nix_update/version/gitea.py`：

```python
def is_gitea_host(host: str) -> bool:
    if host in KNOWN_GITEA_HOSTS:
        return True
    endpoint = f"https://{host}/api/v1/settings/api"
    try:
        resp = OPENER.open(endpoint, timeout=DEFAULT_TIMEOUT)
    except URLError:
        return False
    else:
        return resp.status == HTTPStatus.OK
```

**关键**：不在已知列表里的 host，必须让 `/api/v1/settings/api` 返回 200 才算 Gitea。

### 我们实测的

`projects.blender.org` 不在 `KNOWN_GITEA_HOSTS` 里（那里只有 `codeberg.org` / `gitea.com`
之类），所以走的是探测分支：

```
探针 https://projects.blender.org/api/v1/settings/api -> HTTP 200  => is_gitea_host = True
tags (7): ['v1.0.3', 'v1.0.2', 'v1.0.1', 'v1.0.0', 'v0.3.0', '26.04.10']
```

`tags` 是 `fetch_gitea_versions` 实际要取的那个端点。

### 版本前缀对不对

`update.py` 的 `fetch_new_version` 这么推前缀：

```python
old_rev_tag = package.rev or package.tag
if old_rev_tag and old_rev_tag.endswith(package.old_version):
    version_prefix = old_rev_tag.removesuffix(package.old_version).removeprefix("refs/tags/")
```

我们的 `tag = "v${version}"`、`old_version = "1.0.3"` ⇒ `old_rev_tag = "v1.0.3"`
⇒ `version_prefix = "v"`。而 Gitea 返回的 tag 正是 `v1.0.3` 形式。**对得上。**

### 顺带验到的一件事

在同一棵本地树里对 `mcp-searxng` 跑 `nix-update`，它打印了：

```
Update 2.2.0 -> 2.5.1 in .../pkgs/by-name/mc/mcp-searxng/package.nix
```

**版本发现本身是好的**，之后才因为写文件撞到只读存储而失败（我在树里放的是符号链接）。
这条证明的是「工具链没坏」，不是「我们的包也能更新」——后者由上面对 Gitea 的探测证明。

### 边界（我没验到的）

- 我只验了 **host 探测 + tag 取回 + 前缀推断**这三步，
  **没有**在真 nixpkgs 检出里跑完整的 `nix-update blender-mcp`（它需要那棵树的完整副本，
  而我为了避开符号链接事故刻意没有复制整棵树）。
- `r-ryantm` 自己的运行环境（限流、缓存、检出方式）与本地不同。真正「它会不会开 PR」
  要等提交后才知道。

---

## 二、`--replace-fail` 的射程：上游改了那两行会怎样？

`postPatch` 用的是 `substituteInPlace --replace-fail`，锚点是上游测试里的这一行：

```
    env["PYTHONPATH"] = os.path.join(_REPO_DIR, "mcp")
```

**锚点消失 = 构建立即失败**，而不是静默少跑测试。这是有意的。

### 但它也意味着一个维护负担

上游哪天改了这两个测试文件的这一行，nixpkgs 的构建就会红。
这是一次**主动接受**的取舍：宁可红，也不要「测试少跑了一半还没人知道」。

处置时注意两件事：

1. 那两处修复如果**被上游采纳**，这份补丁要删掉（PR 里已经写了「我可以提给你们」）。
2. 上游若只是改了写法（例如换成 `os.environ["PYTHONPATH"] = …`），
   要**同时更新锚点**，不能只删 `postPatch`——删掉它测试会重新变成 15 failed + 117 error。
