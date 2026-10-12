# `maintainer-list.nix` 的落点（已取证）

提交时这段要**单独一个 commit**，标题固定 `maintainers: add kitsunori`，
并且**排在包那个 commit 之前**。

## 要插入的内容

```nix
  kitsunori = {
    email = "kitsunori@g41.moe";
    github = "Kihara777";
    githubId = 24633616;
    name = "狐莉";
  };
```

字段顺序按**字段名字母序**（`email` → `github` → `githubId` → `name`）——这是全文件的排法。

## 插在哪个位置

`maintainers/maintainer-list.nix` 按 handle 字母序排 —— **忽略大小写**。
实测（上游 master，文件 33125 行 / **5293** 个条目）：

- 上一项：`kitsunoff`
- 下一项：**`Kitt3120`**（大写 K）
- 插入点行号：**15387**（`  Kitt3120 = {` 之前）

**字母序依据**（忽略大小写）：`kitsunoff` < `kitsunori`（`kitsuno` 之后 `f` < `r`）<
`Kitt3120`（`kits` 的 `s` < `kitt` 的 `t`）。

> ⚠️ **我在这里错过一次，记下来。** 第一版扫描用的正则是
> `^  ([a-z0-9_.-]+) = \{` —— **只匹配小写开头**，于是整个漏掉 **340 个大写开头的
> 属性名**（`A1ca7raz`、`Acconut`、`Kitt3120`…），条目数也从 5293 错成 4898。
> 按那份残缺名单算出来的插入点是「第 15393 行、`kittyandrew` 之前」——
> **那会把 `kitsunori` 排到 `Kitt3120` 后面，是错的。**
>
> 排序方式也是实测定的，不是假设：**忽略大小写有序 = True，ASCII 原样有序 = False**。
> 所以 `Kitsune` / `kitsuno*` / `Kitt3120` / `kitty*` 是混在一个区段里的。

## 四个字段的来源

| 字段 | 值 | 依据 |
|---|---|---|
| `github` | `Kihara777` | `gh api users/Kihara777` → `login=Kihara777 id=24633616 created=2016-12-18` |
| `githubId` | `24633616` | 同上；审阅者会核 `api.github.com/user/24633616` 的 `login` 是否吻合 |
| `name` | `狐莉` | 狐莉 **2026-10-12** 指定 |
| `email` | `kitsunori@g41.moe` | 狐莉 **2026-10-12** 指定 |

> **注意 `email` 与 commit 身份是两回事**：commit 的 author/committer 仍用
> `DEC-011` 记的 `Kitsunome <152935465+GrG41@users.noreply.github.com>`（noreply），
> 而这里的 `email` 是 nixpkgs 用来联系维护者的地址。

## ⚠️ 为什么从 `grg41` 换成了 `kitsunori`（2026-10-12）

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

- **带 `email` 的占多数**：5293 条里 4786 条有（**90.4%**）。不填也合规。
- **属性名全是纯 ASCII**：5293 个属性名里含非 ASCII 的 **0 个**。
  新的属性名 `kitsunori` 同样是纯 ASCII —— 这一点没有风险。
- **但 `name` 的「值」可以带非 ASCII**：实测 **362 条**（6.8%）含非 ASCII，
  其中 **4 条是 CJK**（`骑士姬`、`藍+85CD`、`夜坂雅`、`山下`），1 条含平假名
  （`AsPulse / あすぱる`）。**`狐莉` 属于有先例的那一类。**
  文件的规则只有一句「a name that people would know and recognize you by」——
  **没有任何字符限制条文**；`maintainers/README.md` 也完全没提字符集。
- **`狐莉` 是 2 个码点**（`U+72D0 U+8389`），无分隔符、无假名。
  **实测 `nixfmt --check`、`nix-instantiate --parse`，以及求值取回逐字符相同，三项都过。**
- `name` 这一格没有格式要求：真名、网名、罗马字都有。

## 包这一侧必须引用它

```nix
    maintainers = [ lib.maintainers.kitsunori ];
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
| `kitsunori` 条目可读 | ✅ `{ email = "kitsunori@g41.moe"; github = "Kihara777"; githubId = 24633616; name = "狐莉"; }` |
| **包能引用到它**（带反证） | ✅ `before=false`（未加表时不存在）→ `after=true` |
| `package.nix` 能解析 | ✅ |
| nixfmt 两份 | ✅ |

## 关于棘轮检查 `strictDeps` / `__structuredAttrs`

`nixpkgs-vet` 有两条棘轮：新顶层包必须求值出 `strictDeps = true` 与
`__structuredAttrs = true`，且不得回退。我们的草稿显式写了这两项。

**现在这不是推理了**：#572360 上 `Lint / nixpkgs-vet` 与 `Lint / treefmt`
都由上游 CI 跑过并 **pass**。
