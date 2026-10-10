# 提交就绪检查表（blender-mcp → nixpkgs）

**状态：全部前置已就绪；只等狐莉一句「go」，然后按下面执行。**

_最后核验：2026-10-10_

---

## 一、前置条件逐条（每条都有产物可核）

| # | 条件 | 状态 | 产物 / 证据 |
|---|---|---|---|
| 1 | 包能被 nixpkgs 求值并构建 | ✅ | `package.nix`；`bash build.sh` 第 1–2 层 |
| 2 | 产物正确 | ✅ | 产物核验：`$out/bin/blender-mcp` + 插件 9 个文件 |
| 3 | **产物真的能跑** | ✅ | 喂 JSON-RPC `initialize`，`serverInfo.name = "blender-mcp"` |
| 4 | 上游测试通过 | ✅ | `doCheck = true`；**102 passed / 9 skipped / 0 failed** |
| 5 | 判据能翻脸 | ✅ | `tests/criterion-self-test.sh`，四层各撞一次 + 对照臂 |
| 6 | 格式符合 nixpkgs 强制要求 | ✅ | `nixfmt --check` 退出码 0 |
| 7 | 许可依据可指认 | ✅ | 产物里源文件带 SPDX；上游 issue #59 维护者确认 |
| 8 | 自动更新可用 | ✅ | `is_gitea_host` 探针 200 + tag 格式对得上（`VERIFICATION.md`） |
| 9 | 维护者条目可写 | ✅ | `MAINTAINER-ENTRY.md`（位置、`githubId` 已双核、488 条无邮箱先例） |
| 10 | PR 摘要与 AI 披露已拟 | ✅ | `pr-body.md`（含独立披露段） |
| 11 | 本仓自检绿 | ✅ | `nix flake check` 全绿（含真实构建） |

### 明确**未**验到的（不许当成验过）

- 在真 nixpkgs 检出里跑**完整的** `nix-update`（需要整树副本，刻意没复制）。
- 实际跑 `nixpkgs-vet`（需要两个 git 检出）。棘轮那一条是**推理**，
  理由写在 `MAINTAINER-ENTRY.md` 末尾。
- `aarch64-linux` 上的构建（本地只有 x86_64）。
- `r-ryantm` 到底会不会开 PR——它的运行环境与本地不同。

### 关于参数与死代码（2026-10-10 补）

`package.nix` 的六个参数（`lib`、`python3Packages`、`fetchFromGitea`、`makeWrapper`、
`blender`、`nix-update-script`）**全部在正文里被用到**，没有声明未用的死参数。
Nix 对死参数不报警，所以这一条只能自己查。

**查的时候注意量具本身**：我用文本正则连撞两次假警报——
一次把参数表切错位置（于是「五个参数全死」），
一次让 `\bblender\b` 命中 **`blender-mcp`** 里的 `blender`（于是「引用 12 次」）。
可靠的做法是**从求值结果读参数名**（`builtins.functionArgs`），而不是读源码文本。

---

## 二、执行顺序（狐莉说 go 之后）

### 第 0 步：先确认「go」到底给了没有（判据，不靠感觉）

**不要靠记忆或叙述判断许可。** 用这三条探测，任一为真就说明已经动过手了：

```bash
# ① fork 存在吗（对已知存在的仓库会返回 200，所以这个方法本身是有效的）
gh api repos/Kihara777/nixpkgs --jq .name          # 404 = 还没 fork

# ② 分支存在吗
gh api repos/Kihara777/nixpkgs/branches --jq '.[].name'

# ③ PR 存在吗
gh pr list --repo NixOS/nixpkgs --author Kihara777 --state all --json number,title
```

**2026-10-10 实测：三条全为空**（无 fork、无分支、无 PR）——也就是尚未动手。
写在这里是为了让**下一个会话**能自己判断，而不是照着上一轮的叙述以为已经做过。

### 第 1 步：授权与身份

```bash
gh auth status                    # 确认活跃账号是 Kihara777（不是 GrG41）
git config user.name              # 期望 Kitsunori
git config user.email             # 期望 kitsunori@outlook.jp
```

### 第 2 步：fork 与克隆

```bash
gh repo fork NixOS/nixpkgs --clone --remote=false --default-branch-only
# 得到 ~/nixpkgs，origin = Kihara777/nixpkgs
cd ~/nixpkgs
git remote add upstream https://github.com/NixOS/nixpkgs.git
git fetch upstream
```

### 第 3 步：分支

```bash
git switch --create init-blender-mcp upstream/master
```

### 第 4 步：两个 commit（顺序不能反）

**commit 1 —— 维护者条目**

把 `MAINTAINER-ENTRY.md` 里那段插到 `maintainers/maintainer-list.nix`
的 `kiyotoko` 与 `kjeremy` 之间，然后：

```bash
git add maintainers/maintainer-list.nix
git commit -m "maintainers: add kihara777" -m "Assisted-by: DeepSeek Harness (DeepSeek V4 Flash)"
```

**commit 2 —— 包**

```bash
mkdir -p pkgs/by-name/bl/blender-mcp
cp <这份目录>/package.nix pkgs/by-name/bl/blender-mcp/package.nix
git add pkgs/by-name/bl/blender-mcp/package.nix
git commit -F <这份目录>/commit-message.txt      # 见 pr-body.md 里拟好的正文
```

> 两个 commit 的正文都要带 `Assisted-by:` trailer（强制披露格式）。
> `Co-authored-by:` **不算**披露。

### 第 5 步：本地核验

```bash
nix-build -A blender-mcp                    # 构建
./result/bin/blender-mcp --help             # 真的敲一下
nixfmt pkgs/by-name/bl/blender-mcp/package.nix   # 过格式
```

### 第 6 步：推送与开 PR

```bash
git push --set-upstream origin init-blender-mcp
gh pr create --repo NixOS/nixpkgs --base master --title "blender-mcp: init at 1.0.3" \
  --body-file <这份目录>/pr-body.md
```

### 第 7 步：交还

**PR 开出后：提交按钮与评审答复归狐莉。**
按 nixpkgs 的 AI 政策，答评审的必须是「在环里负责的人」——
不能把评审意见转发给工具再转回去。

---

## 三、如果被拦下，先看哪里

| 症状 | 第一件事 |
|---|---|
| `nixpkgs-vet` 报 `strictDeps`/`__structuredAttrs` | 把 vet 拉下来对着 fork 真跑一次，别猜（`MAINTAINER-ENTRY.md` 末尾有推理，但那是推理） |
| 审阅者问许可 | 引 issue #59 与 `SPDX-License-Identifier` 在源文件里的事实 |
| 审阅者问那个 `--replace-fail` 补丁 | 引 `VERIFICATION.md` 第二节；并说明**可以把它提给上游** |
| 审阅者问为什么排除 Blender 那个测试文件 | 它要真实运行的 Blender 编辑器实例，沙箱里没有；其余三个文件 102 项全跑 |
| `npmDepsHash` / hash 类报错 | 与本包无关（纯 Python，无 npm/rust 依赖） |

---

## 四、这份目录里各文件是干什么的

| 文件 | 用途 |
|---|---|
| `package.nix` | 待提交的包定义（与 nixpkgs 的 `pkgs/by-name/bl/blender-mcp/package.nix` 逐字相同） |
| `build.nix` | 求值入口，用 `builtins.getFlake "path:<nixpkgs>"` 读一棵真树 |
| `build.sh` | 四层判据（求值 / 构建 / 产物 / 运行）+ nixfmt 检查 |
| `tests/criterion-self-test.sh` | 反证：每条判据都要能被已知坏输入撞响 |
| `pr-body.md` | 提交计划、两个 commit 的正文、PR 摘要、AI 披露段 |
| `MAINTAINER-ENTRY.md` | 维护者条目的确切内容与插入位置 |
| `VERIFICATION.md` | 两个「提交后会被问到」的点的取证：自动更新、替换锚点 |
| `READY.md` | 本文（提交就绪检查表与执行顺序） |
