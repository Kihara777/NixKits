# 提交计划：obs-bilibili-stream → nixpkgs

**状态：草稿已建、构建通过、检查器通过。等狐莉验证后发布。**

---

## 一、这个包要改**两个**文件（与 blender-mcp 不同）

nixpkgs 的 OBS 插件不走 by-name，而是有自己的目录与接线文件。
`pkgs/applications/video/obs-studio/plugins/default.nix` 顶部写着入场规则：

> - Respect alphabetical order. On diversion, file a PR.
> - Plugin name should reflect upstream's name. Including or excluding "obs" prefix/suffix.
> - Add plugin to it's own directory (because of future patches).

**文件一（新增）**：`pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix`
内容 = [`package.nix`](package.nix) **逐字节相同**。

**文件二（改一行）**：`pkgs/applications/video/obs-studio/plugins/default.nix`

在 `obs-backgroundremoval` 与 `obs-browser-transition` 之间插入（字母序：`bil` < `bro`）：

```nix
  obs-bilibili-stream = qt6Packages.callPackage ./obs-bilibili-stream.nix { };
```

用 `qt6Packages.callPackage` 是因为这个插件用 Qt——由它注入 `qtbase`，
所以包定义里写的是 `qtbase` 而不是 `qt6.qtbase`（与 `obs-color-monitor` 等 14 个插件一致）。

## 二、commit

```
obs-bilibili-stream: init at 2.1.5

Bilibili streaming plugin for OBS Studio. It adds a streaming target and a
dialog for managing Bilibili streams, and links against obs-frontend-api.

Assisted-by: DeepSeek Harness (DeepSeek-V41-Flash)
```

**一个 commit**（两个文件同属一件事）。若狐莉认为该拆开，我拆。

## 三、PR 标题与正文

**标题**：`obs-bilibili-stream: init at 2.1.5`

**正文**：

```markdown
Adds obs-bilibili-stream, a plugin that adds Bilibili as a streaming target in
OBS Studio, with a dialog for managing streams. It links against
obs-frontend-api and uses Qt, so it is wired through `qt6Packages.callPackage`.

The licence is GPL-2.0-only: the project's own appstream metadata declares
`<project_license>GPL-2.0-only</project_license>`. The LICENSE file is the stock
GPLv2 text and `src/plugin-support.{h,c.in}` are the unmodified OBS plugin
template with its placeholders unfilled, so the "or any later version" wording
there is boilerplate rather than the author's grant.

A note on `postInstall`: upstream's CMake installs the plugin twice — into
`lib/obs-plugins/` (the path the OBS wrapper reads) and into `obs-plugins/64bit/`
(OBS's own default prefix). The second copy is dropped.

### Things done

- Built on platform:
  - [x] x86_64-linux
  - [ ] aarch64-linux
  - [ ] aarch64-darwin
- [x] Verified the output layout matches what the OBS wrapper expects:
  `lib/obs-plugins/bilibili-stream-for-obs.so` and
  `share/obs/obs-plugins/bilibili-stream-for-obs/{config.json,locale/en-US.ini}`.
- [x] Checked that `-DENABLE_QT=ON` is load-bearing: without it the build cannot
  find the Qt headers (`QMenuBar: No such file or directory`). The
  `-DOBS_SOURCE=...` that used to accompany it was dropped — building with it
  alone fails and removing it leaves the `.so` byte-identical.
- [x] Fits CONTRIBUTING.md, pkgs/README.md, maintainers/README.md and other READMEs.
- [x] Follows the automation/AI policy.

### AI disclosure

The account submitting this (`GrG41`, display name 戦術人形Ｇ４１) is operated by
an AI agent, 小爪, which develops and maintains the packages under
https://github.com/Kihara777/NixKits. This contribution was produced by that
agent using DeepSeek Harness running `DeepSeek-V41-Flash`, and is disclosed as an
`Assisted-by:` trailer on the commit.

The responsible person in the sense of the automation/AI policy is 狐莉
(Kitsunori, https://github.com/Kihara777), who reviewed this contribution and
authorised its submission.
```

## 四、判据（发布前已跑）

| 判据 | 结果 |
|---|---|
| 求值 + 构建 | ✅ |
| 产物核验 | ✅ 3 个文件，与 NixKits 那版逐项相同 |
| `-DENABLE_QT=ON` 承重 | ✅ 逐条实测（单独留它成功，单独留 `OBS_SOURCE` 失败） |
| 去掉 `OBS_SOURCE` 不改变产物 | ✅ `.so` 逐字节相同（`62a9a296…`） |
| 去掉 `postInstall` 会留下重复 | ✅ 实测：产物会多出 `obs-plugins/64bit/…` |
| `check-draft.sh` 机械项 | ✅ 全过（含「不是 python 包」等 2 项**没能验到**，单列） |
| nixfmt | ✅ |

**仍未验**：在真 nixpkgs 检出里跑 `nixpkgs-vet`（要两个 git 检出）；
aarch64 与 riscv64 构建（本地只有 x86_64，且 `obs-studio` 不支持 riscv64）。

## 五、顺带修掉的我们自己的错

`packages/obs-bilibili-stream.nix` 的 `license` 原写 `gpl2Plus`，
**没有依据**——上游的 appstream 元数据写的是 `GPL-2.0-only`。已改为 `gpl2Only`。

（`-DOBS_SOURCE=${obs-studio}` 在那边仍然留着：它无害，且改它要动我们 CI 的构建，
收益为零。**已验证它不影响产物。**）
