# `maintainer-list.nix` 的落点（已取证）

提交时这段要**单独一个 commit**，标题固定 `maintainers: add kihara777`，
并且**排在包那个 commit 之前**。

## 要插入的内容

```nix
  kihara777 = {
    email = "kitsunori@g41.moe";
    github = "Kihara777";
    githubId = 24633616;
    name = "Kihara777";
  };
```

字段顺序按**字段名字母序**（`email` → `github` → `githubId` → `name`）——这是全文件的排法。

## 插在哪个位置

`maintainers/maintainer-list.nix` 按 handle 字母序排。实测（上游 master，
文件 33125 行 / 4898 个条目，`sort` 检查确认**整体有序**）：

- 上一项：`kidsan`
- 下一项：`kiike`
- 插入点行号：**15239**（`  kiike = {` 之前）

字母序依据：`kidsan` < `kihara777`（`d` < `h`）< `kiike`（`h` < `i`）。

## 四个字段的来源

| 字段 | 值 | 依据 |
|---|---|---|
| `github` | `Kihara777` | `gh api users/Kihara777` → `login=Kihara777 id=24633616 created=2016-12-18` |
| `githubId` | `24633616` | 同上；审阅者会核 `api.github.com/user/24633616` 的 `login` 是否吻合 |
| `name` | `Kihara777` | 狐莉 **2026-10-12** 指定 |
| `email` | `kitsunori@g41.moe` | 狐莉 **2026-10-12** 指定 |

> **注意 `email` 与 commit 身份是两回事**：commit 的 author/committer 仍用
> `DEC-011` 记的 `Kitsunome <152935465+GrG41@users.noreply.github.com>`（noreply），
> 而这里的 `email` 是 nixpkgs 用来联系维护者的地址。

## ⚠️ 为什么从 `grg41` 换成了 `kihara777`（2026-10-12）

这份文档此前记的是 `grg41`（我自己账号）的条目。**PR #572912 上这条被评审者拒了。**

`jm5905938` 提出质疑：要成为维护者的账户是自动化的。`K900` 的结论：

> A computer can never be held accountable, etc. It's fine to use automation to update
> your packages, but **the human needs to be responsible at the end of the day.**

随后是正式评审 `CHANGES_REQUESTED`（正文「Please don't.」）；狐莉回复后他明确：

> In that case please **just use your personal account as a point of contact.**

**所以要改的不是「谁干活」，是「名单上写谁」。** 实际维护仍然由我做，
但 `maintainer-list.nix` 里必须是能担责的人 —— 狐莉本人的账号。

**这与 `DEC-017`（署名是归属）不冲突**：那条讲的是我自己的劳动要有我的署名；
这条讲的是**社区要求有一个能担责的联络点**。两个位置是不同的东西。
相关决议见 `Kitsunome` 仓库的 `DEC-033`。

## 该文件的其他惯例（实测，供核对）

- **带 `email` 的占多数**：4898 条里 4788 条有（**97.8%**）。不填也合规。
- **属性名全是纯 ASCII**：4898 个属性名里含非 ASCII 的 **0 个**。
  新的 `kihara777` 同样是纯 ASCII，所以这一点不再是风险。
- `name` 这一格没有格式要求：真名、网名、罗马字都有。

## 包这一侧必须引用它

```nix
    maintainers = [ lib.maintainers.kihara777 ];
```

**`pkgs/README.md:516`**：「`meta.maintainers` **must be set** for new packages.」

> ⚠️ **这一格我曾经漏掉**：#572360 里 `maintainers = [ ]` 是空的。
> 我把条目加进了 `maintainer-list.nix`，却没让包引用它。
> 上游 CI 不会因此变红（没有针对空 maintainers 的检查），
> 所以它只会等审稿人指出来。
> **当时的检查表写的是「维护者条目可写 ✅」——我验的是「条目写得进去」，
> 没验「包引用了它」。**

## 判据（发布前已跑）

| 判据 | 结果 |
|---|---|
| `maintainer-list.nix` 能解析 | ✅ `nix-instantiate --parse` |
| `kihara777` 条目可读 | ✅ `{ email = "kitsunori@g41.moe"; github = "Kihara777"; githubId = 24633616; name = "Kihara777"; }` |
| **包能引用到它**（带反证） | ✅ `before=false`（未加表时不存在）→ `after=true` |
| `package.nix` 能解析 | ✅ |
| nixfmt 两份 | ✅ |

## 关于棘轮检查 `strictDeps` / `__structuredAttrs`

`nixpkgs-vet` 有两条棘轮：新顶层包必须求值出 `strictDeps = true` 与
`__structuredAttrs = true`，且不得回退。我们的草稿显式写了这两项。

**现在这不是推理了**：#572360 上 `Lint / nixpkgs-vet` 与 `Lint / treefmt`
都由上游 CI 跑过并 **pass**。
