# `maintainer-list.nix` 的落点（已取证）

提交时这段要**单独一个 commit**，标题固定 `maintainers: add kihara777`，
并且**排在包那个 commit 之前**。

## 要插入的内容

```nix
  kihara777 = {
    name = "Kitsunori";
    github = "Kihara777";
    githubId = 24633616;
  };
```

## 插在哪个位置

`maintainers/maintainer-list.nix` 按 handle 字母序排。实测（本地那份 nixpkgs 树）：

- 上一项：`kiyotoko`（第 15215 行）
- 下一项：`kjeremy`（第 15221 行）

`kihara777` 落在两者之间（`kih` < `kiy`，且 `kiy` < `kj`）。

## 三个字段的来源（都不是猜的）

| 字段 | 值 | 依据 |
|---|---|---|
| `name` | `Kitsunori` | 本机 git 身份与 NixKits 作者署名 |
| `github` | `Kihara777` | NixKits 的 owner（`origin` 指向 `Kihara777/NixKits`） |
| `githubId` | `24633616` | `gh api user/24633616` → `login=Kihara777 id=24633616 created=2016-12-18` |

审阅者会访问 `https://api.github.com/user/24633616` 核 `login` 是否等于 `github`——
**已核过，对得上**，而且账号 2016 年创建，不是新号。

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

（注意那条里 `handle ≠ github`——所以 handle 与 GitHub 名字不同是允许的。）

## 几个顺手核过、可以放心的点

- **handle 没被占用**：`grep -i 'kihara\|kitsunori'` 在 `maintainer-list.nix` 里
  只有 `kitsunoff` 这样的近似项，`kihara*` 与 `kitsunori` 都没有。
- **大小写不是硬规定**：5228 个条目里有 **386** 个 handle 含大写字母。
  我们仍写全小写的 `kihara777`，与多数条目一致。
- **`githubId` 的值**已用 `gh api user/24633616` 双向核过（见上表）。

## 关于棘轮检查 `strictDeps` / `__structuredAttrs`

`nixpkgs-vet` 有两条棘轮：新顶层包必须求值出 `strictDeps = true` 与
`__structuredAttrs = true`，且不得回退。

**我们的草稿显式写了这两项。这一点是安全的，但请注意这是推理而非实测**：

1. base 是 nixpkgs master，那里**根本没有 `blender-mcp`**——
   所以「从 true 回退到 false」在定义上不可能发生；
2. python 的 `pkgs/development/interpreters/python/setup-hook.nix` 已经默认给出
   `strictDeps = true` 与 `__structuredAttrs = true`，
   我们显式写 `true` 是**同值**，不是回退。

旁证：by-name 里 1596 个用 `buildPythonApplication` 的包中只有 **152** 个显式写了
`__structuredAttrs`，其余也都被合并了。

**我没有实际跑过 `nixpkgs-vet`** —— 它需要两个 git 检出（`ci/nixpkgs-vet.nix` 用
`gitTracked` 取文件集），为验这一条不值得搭那套。如果 PR 被 vet 拦下，
第一件事是把 `nixpkgs-vet` 拉下来对着 fork 跑一次，而不是猜。
