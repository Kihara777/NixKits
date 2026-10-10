# `maintainer-list.nix` 的落点（已取证）

提交时这段要**单独一个 commit**，标题固定 `maintainers: add grg41`，
并且**排在包那个 commit 之前**。

## 要插入的内容

```nix
  grg41 = {
    github = "GrG41";
    githubId = 152935465;
    name = "Kitsunome";
  };
```

## 插在哪个位置

`maintainers/maintainer-list.nix` 按 handle 字母序排。实测（GrG41 fork 的 master，
与上游 master `38fb26e7` 一致；文件 33070 行 / 5283 个条目，整体有序）：

- 上一项：`greydot`
- 下一项：`grgi`（`grg4` < `grgi`，因为 `4` < `i`）
- 插入点行号：10886（`  grgi = {` 之前）

## 三个字段的来源

| 字段 | 值 | 依据 |
|---|---|---|
| `github` | `GrG41` | `gh api users/GrG41` → `login=GrG41 id=152935465 created=2023-12-05` |
| `githubId` | `152935465` | 同上；审阅者会核 `api.github.com/user/152935465` 的 `login` 是否吻合 |
| `name` | `Kitsunome` | **`DEC-011` 原文的提交身份**：`Kitsunome <152935465+GrG41@users.noreply.github.com>` |

**`name` 这一格请狐莉过目**：GitHub 显示名是「戦術人形Ｇ４１」，
而 `DEC-011` 记的提交身份名是 `Kitsunome`。我取了后者（因为它是身份决议的原文），
但这是公开字符串，你说了算。

## 为什么没有 `email`

`maintainer-list.nix` 的必填项是 `name` / `github` / `githubId` 三项，`email` 可选。
实测：**488 条**既有条目没有 `email` 而字段完整，例如

```nix
  _0x2B = {
    name = "0x2B";
    github = "0x2B-bin";
    githubId = 49249957;
  };
```

## 字段顺序

这个文件里字段**按字段名字母序**（`email`, `github`, `githubId`, `name`），
无邮箱时就是 `github` / `githubId` / `name` 三条——与上面的 `kidsan` 形态一致：

```nix
  kidsan = {
    github = "Kidsan";
    githubId = 8798449;
    name = "kidsan";
  };
```

## 包这一侧必须引用它

```nix
    maintainers = [ lib.maintainers.grg41 ];
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
| `grg41` 条目可读 | ✅ `{ github = "GrG41"; githubId = 152935465; name = "Kitsunome"; }` |
| **包能引用到它**（带反证） | ✅ `before=false`（未加表时不存在）→ `after=true` |
| `package.nix` 能解析 | ✅ |
| nixfmt 两份 | ✅ |

## 关于棘轮检查 `strictDeps` / `__structuredAttrs`

`nixpkgs-vet` 有两条棘轮：新顶层包必须求值出 `strictDeps = true` 与
`__structuredAttrs = true`，且不得回退。我们的草稿显式写了这两项。

**现在这不是推理了**：#572360 上 `Lint / nixpkgs-vet` 与 `Lint / treefmt`
都由上游 CI 跑过并 **pass**。
