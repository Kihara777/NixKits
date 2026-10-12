# 提交计划：obs-bilibili-stream → nixpkgs

**状态：草稿已建、构建通过、检查器通过。等狐莉人工核查后才发布。**

---

## 一、这个包**只改一个文件**（新增），加一个维护者条目

| 文件 | 动作 |
|---|---|
| `pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix` | **新增**（内容 = [`package.nix`](package.nix) 逐字节相同） |
| `maintainers/maintainer-list.nix` | 插入 `kitsunori` 条目 —— 见 [`../MAINTAINER-ENTRY.md`](../MAINTAINER-ENTRY.md) |

**接线文件不用改。** 这一条我最初写错了，见第七节。

## 二、两个 commit

### commit 1

```
maintainers: add kitsunori

Assisted-by: DeepSeek Harness (DeepSeek-V41-Flash)
```

### commit 2

正文 = [`commit-message.txt`](commit-message.txt) 逐字。

标题：`obs-bilibili-stream: init at 2.1.5`

## 三、为什么这么写（每条都有实测依据）

**先把当前 master 上 54 个 OBS 插件全拉下来做了统计**，不靠一两个样本推断。
下表每一行的「依据」都是实测或统计得来的。

| 写法 | 依据 |
|---|---|
| 放在 `plugins/` 下的**平铺 `.nix` 文件** | `plugins.nix` 用 `lib.packagesFromDirectoryRecursive { directory = ./plugins; }`；`lib/filesystem.nix:403` 的规则是「`.nix` 文件 → `callPackage <file> { }`」。**不用改接线文件** |
| 参数写 **`qt6`**、依赖写 **`qt6.qtbase`** | 自动发现用的是**普通的 `pkgs.callPackage`**，没有 `qt6Packages` 注入。统计：**17/54** 用 Qt 的插件全部写 `qt6.qtbase`（0 个写裸 `qtbase`） |
| `-DENABLE_QT=ON` | **去掉就建不过**：`fatal error: QMenuBar: No such file or directory`。实测 |
| `-DENABLE_FRONTEND_API=ON` | 上游 `CMakePresets.json` 的 `template` preset 里就是 `true`，而 `CMakeLists.txt` 里默认 `OFF`。**这一条此前漏了** —— 不开时 `NEEDED` 里没有 `libobs-frontend-api.so.30`，且 `.so` 与开着的**不是同一个文件**（实测） |
| **没有** `-DOBS_SOURCE=...` | 实测多余：单独留它构建失败，去掉后 `.so` **逐字节相同** |
| `postInstall` 里 `rm -rf "$out/obs-plugins"` | 上游 CMake **装两遍**：`lib/obs-plugins/`（OBS 包装器读的位置）与 `obs-plugins/64bit/`（OBS 自己的默认前缀）。实测去掉后产物会多出第二份。统计：17/54 与这里一样「只 rm」 |
| `dontWrapQtApps = true` | 统计：17/54 —— **恰好等于用 Qt 的那 17 个** |
| `inherit (obs-studio.meta) platforms` | 统计：**30/54**（`lib.platforms.linux` 是 20/54）。而且更准确：`obs-studio` 的 platforms 只含 x86_64 / i686 / aarch64-linux，**不含 riscv64**，继承它就不会虚报 |
| `maintainers = with lib.maintainers; [ … ]` | 统计：**50/54** 用这个写法 |
| `license = lib.licenses.gpl2Only` | 上游 `metainfo.xml` 写着 `<project_license>GPL-2.0-only</project_license>` |
| **没有** `mainProgram` | 插件不是可执行文件。统计：54 个里只有 1 个设了它 |

## 四、PR 标题与正文

**标题**：`obs-bilibili-stream: init at 2.1.5`

**正文**：

```markdown
Adds obs-bilibili-stream, a plugin that adds Bilibili as a streaming target in
OBS Studio, with a dialog for managing streams. It uses Qt and registers its
menu entry through obs-frontend-api.

The licence is GPL-2.0-only: the project's own appstream metadata declares
`<project_license>GPL-2.0-only</project_license>`. The LICENSE file is the stock
GPLv2 text and `src/plugin-support.{h,c.in}` are the unmodified OBS plugin
template with its placeholders unfilled, so the "or any later version" wording
there is boilerplate rather than the author's grant.

Two notes on the package definition:

- `ENABLE_QT` and `ENABLE_FRONTEND_API` both default to OFF in upstream's
  CMakeLists.txt, while upstream's own CMakePresets.json turns them on, so both
  are passed here. Without `ENABLE_QT` the build cannot find the Qt headers
  (`QMenuBar: No such file or directory`); without `ENABLE_FRONTEND_API`
  libobs-frontend-api is missing from NEEDED.
- Upstream's CMake installs the plugin twice — into `lib/obs-plugins/` (the path
  the OBS wrapper reads) and into `obs-plugins/64bit/` (OBS's own default
  prefix). The second copy is dropped.

### Things done

- Built on platform:
  - [x] x86_64-linux
  - [ ] aarch64-linux
  - [ ] aarch64-darwin
- [x] Verified the output layout is what the OBS wrapper expects:
  `lib/obs-plugins/bilibili-stream-for-obs.so` plus
  `share/obs/obs-plugins/bilibili-stream-for-obs/{config.json,locale/en-US.ini}`.
- [x] Loaded it in a real OBS Studio 32.2.2, wrapped through `wrapOBS` the way the
  NixOS module does. OBS lists it under `Loaded Modules` and the plugin's own
  `obs_module_load` returns success:

  ```
  [obs-bilibili-stream] 插件版本: 2.1.5, commit: unknown
  [obs-bilibili-stream] 插件加载成功
  ```

  (repeated with `plugins = [ ]`: neither line appears.)

- [x] Fits CONTRIBUTING.md, pkgs/README.md, maintainers/README.md and other READMEs.
- [x] Follows the automation/AI policy.

### AI disclosure

The account submitting this (`GrG41`, display name 戦術人形Ｇ４１) is operated by
an AI agent, 小爪, which develops and maintains the packages under
https://github.com/Kihara777/NixKits. This contribution was produced by that
agent using DeepSeek Harness running `DeepSeek-V41-Flash`, and is disclosed as an
`Assisted-by:` trailer on every commit.

The responsible person in the sense of the automation/AI policy is 狐莉
(Kitsunori, https://github.com/Kihara777), who reviewed this contribution and
authorised its submission. Every claim above was checked by running it rather
than by inspection.
```
## 五、判据（发布前已跑）

| 判据 | 结果 |
|---|---|
| 求值 + 构建 | ✅ |
| **真 OBS 加载（运行层）** | ✅ `wrapOBS` 包出的 OBS 32.2.2 在日志里列出它，且插件自己打印「插件加载成功」；见 `tests/runtime.sh` |
| **运行层的对照臂** | ✅ `plugins = [ ]` 时那两行**都不出现** |
| 导出 OBS 入口点 | ✅ `nm -D` 有 `obs_module_load`，另有 `unload` / `ver` / `set_pointer` 等 |
| 自动发现 | ✅ `packagesFromDirectoryRecursive` 把它认成 `obs-bilibili-stream`；改名反证臂通过 |
| `-DENABLE_FRONTEND_API=ON` 的效果 | ✅ 加上后 `NEEDED` 含 `libobs-frontend-api.so.30`；`.so` 与不加时**不同**（`62a9a296…` → `ee630bd8…`） |
| 我们仓里的包与这份草稿一致 | ✅ 修好后 `.so` **逐字节相同**（`ee630bd8…`） |
| 产物核验 | ✅ 3 个文件，与 NixKits 那版逐项相同 |
| `-DENABLE_QT=ON` 承重 | ✅ 逐条实测（单独留它成功，单独留 `OBS_SOURCE` 失败） |
| 去掉 `OBS_SOURCE` 不改变产物 | ✅ `.so` 逐字节相同 |
| 去掉 `postInstall` 会留下重复 | ✅ 实测 |
| 改成 `qt6.qtbase` 不改变产物 | ✅ 产物路径与 `qtbase`（qt6Packages）那条路**完全相同** |
| `check-draft.sh` 机械项 | ✅ 15 项 0 失败 |
| 跨文件一致性 | ✅ 条目与文档逐字相同、披露三处同值、src hash 独立复算 |
| nixfmt | ✅ |

**仍未验**：在真 nixpkgs 检出里跑 `nixpkgs-vet`（要两个 git 检出）；
aarch64 / riscv64 构建（本地只有 x86_64，且 `obs-studio` 的 platforms 不含 riscv64）。

## 六、发布步骤

```bash
gh auth switch --user GrG41
gh api user --jq .login          # 期望 GrG41
# fork GrG41/nixpkgs 已建；建分支 obs-bilibili-stream
# 两个 commit 用 Git Data API 建（不整树克隆）
# 开 PR
```

## 七、⚠️ 一次差点带着过时信息提交

我最初写的接线方式是「在 `plugins/default.nix` 里手工加一行」，
Qt 写 `qtbase`（靠 `qt6Packages.callPackage` 注入）。**那是九月的快照。**

取当前 master 一看，两处都变了：

| | 九月快照 | 当前 master |
|---|---|---|
| 接线 | `plugins/default.nix` 手工加行 | `plugins.nix` 用 `packagesFromDirectoryRecursive` **自动发现**，不用加行 |
| Qt | `qt6Packages.callPackage` → `qtbase` | 普通 `callPackage` → **`qt6.qtbase`** |

**这正是本技能第 0 步「先同步，再采信」要防的事** —— 我用一棵本地 nixpkgs 快照
推断「上游的目录结构与接线方式」，而那个快照是旧的。

**规矩**：**结构性问题（文件放哪、怎么接线、用什么 callPackage）必须现取 master 核实，
不能用本地快照推断。** 本地树可以用来**构建**，不能用来**判断上游长什么样**。
