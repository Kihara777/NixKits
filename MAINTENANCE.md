# 维护日志

中文 | [English](docs/MAINTENANCE.en.md) | [日本語](docs/MAINTENANCE.ja.md) | [偽中国語](docs/MAINTENANCE.pcn.md)

## 2026-10-10T14:14:19+09:00

**摘要**：blender-mcp 提交就绪 — 维护者条目落点已取证，并自查抓出一处分叉

- `MAINTAINER-ENTRY.md`：handle 未占用、插在 `kiyotoko`/`kjeremy` 之间、`githubId` 双向核过、488 条先例同样不写 `email`
- `READY.md`：11 条前置逐条挂产物、未验项单列、执行顺序与被拦下的排查表
- 棘轮（`strictDeps`/`__structuredAttrs`）一条在文档里标成**推理**，不冒充实测
- 自查抓到：commit 2 的正文在两处各存一份且**已漂**；已按 `commit-message.txt` 同步并标注

| 提交 | 说明 |
|------|------|
| `ae69543` | feat(upstream): 维护者条目落点与提交就绪检查表 |

## 2026-10-10T14:09:55+09:00

**摘要**：blender-mcp 提交前的两点取证 — 自动更新对自托管 Gitea 有无效、替换锚点的代价

- `nix-update` 是**探测式**判断 host：不在已知列表的要 `/api/v1/settings/api` 返 200；实测 `projects.blender.org` 返 200
- 取回的 tag 为 `v1.0.3` 形式，与从 `tag = "v${version}"` 推出的 `version_prefix` 一致
- `--replace-fail` 的锚点消失即构建失败（有意）：宁可红，也不要测试少跑一半没人知道
- 边界已记：只验了探测 + 取 tag + 前缀推断，**没有**在真 nixpkgs 检出里跑完整 `nix-update`

| 提交 | 说明 |
|------|------|
| `40a9a8a` | docs(upstream): 自动更新与替换锚点的取证记录 |

## 2026-10-10T14:00:48+09:00

**摘要**：blender-mcp 上游草稿的 doCheck 打通 — 并修掉上游测试里一个真 bug

- 原状 139 errors + 16 failed；根因是上游测试 helper **覆盖** PYTHONPATH 而非追加，丢掉全部依赖
- 修法用 `--replace-fail`：上游若改动这两处，构建立即失败而不是静默少跑测试
- `tests/test_blender_mcp_with_blender.py` 排除：要真实 Blender 实例，沙箱里跑不了
- 实测 102 passed / 9 skipped / 0 failed；反证：摘掉修复即 15 failed + 117 个 `McpError`
- 许可依据查实：v1.0.3 源文件带 SPDX 头，上游 issue #59 已确认，无需另开 issue

| 提交 | 说明 |
|------|------|
| `2824c74` | feat(upstream): doCheck 修好（102 passed）并记录上游测试 bug |


## 2026-10-10T12:59:05+09:00

**摘要**：nixpkgs 上游贡献 — 可行性评估、两个技能与 blender-mcp 的 dry-run

- 13 包取证：仅 `mcp-searxng` 已在 nixpkgs 里；`dsh` 在那边叫 `deepseek-harness`，已有三个在途 PR
- 审计入场要求：by-name、`nixpkgs-vet` 的 12 检查 + 3 棘轮、AI 政策的 `Assisted-by:` 格式
- 新增通用技能 `nixpkgs-package-upstream` 与适配层 `nixkits-package-upstream`（四语文档页与索引同步）
- dry-run：blender-mcp 的四层判据全过（含**握手实跑**），反证已撞响
- 更正 ruyi 的过期自述：该 overlay 本就无宿主，nixpkgs **从未**有过 ruyi

| 提交 | 说明 |
|------|------|
| `d7ec6ff` | docs(upstream): 可行性评估与入场要求审计 |
| `27be3f3` | feat(skills): 新增两个上游贡献技能 |
| `4a2db07` | feat(upstream): blender-mcp dry-run 产物与判据自证 |
| `c6476c2` | fix(docs): 更正 ruyi 的过期自述 |

## 2026-10-08T23:25:20+09:00

**摘要**：chore(dsh): alpha 通道改跟 `alpha`、stable pin 前移，README 自述补判据

- `dsh-alpha` 0.2.0-rc.2 → **0.2.1-alpha.1**：当初「alpha 挂在 0.1.x 旧线上」的前提**反了**；hash 取自 `got:`，vendored lock 与产物逐字节相同
- stable 的 `pinnedRev` `0175f85` → `1e85409`：代价是旧格式不再随包发布，0.1.x 用户按旧 rev 自取（仍取得到）
- README 的版本自述烂了**四处**（`dsh-alpha` 落后两代、`ruyi stable` 落后一代，各四语）——新增判据钉住它们，反证已验
- `docs/*/dsh.md` 插件清单加限定：alpha 比 stable 多两条，抄进 stable 会踩硬失败

| 提交 | 说明 |
|------|------|
| `b17bd73` | chore: stable 通道 pinnedRev 前移（`0175f85` → `1e85409`） |
| `bf0b9ac` | chore(dsh-alpha): 通道语义改回 npm `alpha` |
| `52fcdbc` | fix(docs): README 版本自述修正 + 给它补判据 |

## 2026-10-08T23:03:29+09:00

**摘要**：chore(pkgs): mcp-searxng 2.5.1 与 codewhale 0.10.1 —— 结构性变更处置与 CI 烟测补缺

- mcp-searxng：纯依赖/安全补丁，机械替换足够；产物实跑握手报 2.5.1
- codewhale 0.10.1 **把两个可执行文件合成一个**——hash 类判据看不见这类结构变更，是**构建**喊的；已按上游说明改 postInstall
- 随之一并处置：上游改名 `codewhale-hq/Codewhale`、删掉已成空转的 rquickjs riscv64 workaround、两处既有文档错误
- **新增烟测并给三架构开 `smoke-test`**：此前 riscv64 产物在 CI 上从没被运行过；四条判据含反证，已实跑通过
- 其余上游与三个固定 SHA 的 action 全部已最新

| 提交 | 说明 |
|------|------|
| `1645aba` | chore(pkgs): mcp-searxng 2.5.0 → 2.5.1 |
| `bbe7e7a` | ci(codewhale): 三个架构开启 smoke-test |
| `19cc335` | chore(pkgs): codewhale 0.10.0 → 0.10.1（含上游改名与 riscv64 结构性变更的处置） |

## 2026-10-08T16:53:41+09:00

**摘要**：dsh-api-balance re-pin —— rev `95fec42` → `43f4d18`（子仓变更见其维护日志 [键盘守护改硬拦法](https://github.com/Kihara777/dsh-api-balance/blob/main/MAINTENANCE.md#2026-10-08t1638010900)）

- 薄封装只记坐标：rev 与 src hash；子仓记自身完整变更，不重复
- 子仓判据：新增「同帧竞态」反例（应用写回 `contenteditable` 并立刻 `focus()`），全量 15/15
- 顺带：`check-maintenance-log.py` 支持 `--root <repo>`，子仓维护日志也用同一份判据核（不复制脚本）

| 提交 | 说明 |
|------|------|
| `62fc667` | fix(dsh-api-balance): re-pin 到 43f4d18 —— 键盘守护改「默认不可编辑 + 吞掉程序性 focus」 |
| `420b303` | chore: 维护日志校验器支持 --root + re-pin |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重钉） |
| 　 | rev | `95fec42` → `43f4d18` |
| 　 | src hash | `sha256-bRZWVKmv4nHow0TWMdMww/cFnP9A6vJ08sQCloaRpEE=` → `sha256-jNbfG09da6RYiSRfCm0P5pxBIo9LG38bpSAdVZaxyXc=` |

## 2026-10-06T01:12:23+09:00

**摘要**：chore(pkgs): godot-ai 4.2.3 → 4.3.0 —— 含 fail-closed 运行期校验

- 依赖 pin 14 项集合不变、只有 6 项抬版本；两条消费路径链出的依赖完全相同
- 运行期真验到了：产物 `--version` 通过（上游 `main()` 首句就是依赖校验），逐项 14/14；**反证**塞假 `fastmcp-9.9.9` → 产物拒绝启动
- anyio 与新 Python 3.12.15 冲突属既有环境问题（drvPath 与 HEAD 相同为证），用 `--deselect` + nodeid 前缀摘掉 12 个用例，注释带撤销条件
- starlette 1.7.0 新增的收集期依赖按报错补齐，**没有关测试**（1275 collected → 1269 passed）
- 未验到：需要活 Godot 编辑器实例的 GUI 功能

| 提交 | 说明 |
|------|------|
| `9b3260d` | chore(pkgs): godot-ai 4.2.3 → 4.3.0（含 fail-closed 运行期校验） |

## 2026-10-06T00:48:30+09:00

**摘要**：feat(check): 自检体系加固 —— 反证用例库与 pcn 全库字形修正

- 反证用例库（第 10 项 `self-tests`）：每个检查「对照通过 → 注入已知坏输入 → 必须失败且红得对」，现 11 正例 + 2 负例全过
- 它当场抓出真洞：`workflow-coverage` 只判文件名前缀，`build-x-….yml.disabled` 也算覆盖
- 新增判据：`flake.nix` 注释清单须与 `checks` 一一对应；pcn 禁非日文字形；en 摘要禁中文原稿（阈值实测标定）
- pcn 全库修正 45 种字形 / 187 处 / 39 份文档 + 9 条词典映射（新判据报出的既有缺陷）
- opencode-telegram → 0.26.3（纯 bugfix，hash 取自 `got:`，两架构烟测通过）；三个固定 SHA 的 action 均已最新

| 提交 | 说明 |
|------|------|
| `192ec4a` | feat(check): 自检体系加固 —— 反证用例库 + 四条新断言 + 全库语料修正 |
| `f8e6fc7` | chore(pkgs): opencode-telegram 0.26.2 → 0.26.3 |

## 2026-10-05T23:43:17+09:00

**摘要**：fix(skill): 摘要一律清单式 —— 规范、断言与全库回溯

- 排版从「散文或清单都行」改为**只此一种**：一句话概括 + 空行 + 至少 1 个 `- ` 项；单件事的条目也写单行清单
- 全库回溯 336 条散文摘要（四语同步；项数四语逐条相等，全库项数 1–8、均值 3.2）
- 断言：`develop/check-maintenance-log.py` 补「摘要必须有 `- ` 项」（散文摘要判失败）；技能、`AGENTS.md` 与四语文档页同步
- 判据：366 条四语检查器全过；无损体检（对比回溯前 HEAD）366 条 × 四语有 token 丢失者 **0**；`nix flake check` 9 项全过

| 提交 | 说明 |
|------|------|
| `78e1e7c` | docs(MAINTENANCE): 摘要全量清单化 —— 336 条散文摘要改为「概括行 + 清单项」（四语） |
| `6463640` | feat(skill): 摘要一律清单式（规范 + 断言 + 四语文档页） |

## 2026-10-05T23:15:53+09:00

**摘要**：feat(check): 新增 `doc-counts` —— 文档里能从源机械读出的计数必须与源一致（`nix flake check` 8 → 9 项）

- 起因：同一天两次「文档已失真而无人看得见」——补一条词典映射后四语页的「**75** 条」过期；加一项检查后 `AGENTS.md` 的「8 项自检」过期
- 两条规则：词典条数 == `dictionary.md` 数据行数；自检项数 == `flake.nix` 的 `checks` 条目数（含 python 实现数）
- 反证：临时副本注入两处违规，各自报「声明 X ≠ 实际 Y」并 exit 1；现库全绿
- 脚本按规则表组织（加规则＝加一条）；`AGENTS.md` 自检表与 `flake.nix` 注释同步

| 提交 | 说明 |
|------|------|
| `c1e53bf` | feat(check): 新增 doc-counts —— 文档里能从源机械读出的计数必须与源一致 |

## 2026-10-05T22:20:17+09:00

**摘要**：feat(check): 维护日志的形态要求钉成断言 —— zh 摘要 ≤ 400 字符、清单条目数四语相等、说明块单行且标记为本语

- 起因：规范写的是「目标 ≤ 400」，按目标下发的一轮实测有 21 条交上来 420–721 字符，**没有一条算违规**
- 译文不设长度门槛——中 / 英 / 日密度不同（实测字面比中位数 en 1.87、ja 1.17、pcn 1.03），卡同一数字只会逼出「删事实凑长度」
- 反证：临时副本注入四类违规（超长摘要 / en 少一条清单行 / pcn 说明块两行 / 标记改 `**注**`），四条分支各自报错 exit 1；现库全绿
- 同步 `AGENTS.md` 检查表、`skills/write-maintenance-log/SKILL.md` 与四语文档页；27 条清单式摘要对齐规范示例排版（标题与清单间留空行，解析器两种都认）

| 提交 | 说明 |
|------|------|
| `8d58fb3` | feat(check): 维护日志的形态要求钉成断言（zh 长度 / 清单条目数 / 说明块） |
| `9165a8e` | fix(check): 摘要解析兼容两种清单排版 + 27 条清单式摘要对齐规范示例 |

## 2026-10-05T14:54:21+09:00

**摘要**：feat(skill): `write-maintenance-log` 的摘要**允许 markdown 清单排版**

- 「摘要**是摘要**」一节给出两种排版，且**长度预算相同**（合计 ≤ 400 字符）——清单不是「多写几行」的许可，每行仍只回答「变的是什么」
- 清单**不替代**提交表：commit id 仍只出现在 `| 提交 | 说明 |` 里
- 多语同步：清单**逐条翻译且条目数必须相等**（少一条是漏译，多一条是加料）
- 4c 验证节补一条可跑判据（各语言 `grep -c '^- '` 相等），并记下当天真踩到的教训：**判据别写太松**

| 提交 | 说明 |
|------|------|
| `e2cb5ab` | feat(skill): 维护日志摘要允许 markdown 清单；四语文档页同步 |

## 2026-10-05T14:24:37+09:00

**摘要**：dsh-api-balance 薄封装 re-pin —— 按维护者第二轮反馈修疑问窗口渐隐

- rev `911df2e` → `95fec42`（变更见其提交 [`f39c816`](https://github.com/Kihara777/dsh-api-balance/commit/f39c816)；版本仍 `0.1.1`）
- 渐隐由「仅底部」改为**滚动感知**的上下渐隐（状态机 `none/start/end/middle`，滑到顶不在顶边发虚、滑到底不在底边发虚）
- 卡片只淡顶边而非整块 —— 整块 mask 会把吸附按钮一起淡掉
- 按钮下方用同底色补片收口被切断的内容
- 判据：三态逐一核对
| 提交 | 说明 |
|------|------|
| `16f4fef` | fix(dsh-api-balance): re-pin 到 95fec42 —— 疑问窗口渐隐改滚动感知 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重钉） |
| 　 | rev | `911df2e` → `95fec42` |
| 　 | src hash | `sha256-oc+TPbtuwItV43kskjpz18Ys2cTtCgceXAGrh0Q0D2c=` → `sha256-bRZWVKmv4nHow0TWMdMww/cFnP9A6vJ08sQCloaRpEE=` |

## 2026-10-05T13:58:51+09:00

**摘要**：dsh-api-balance 薄封装 re-pin —— 按维护者截图反馈去掉疑问窗口底部的「一刀切」

- rev `1f0af6c` → `911df2e`（变更见其提交 [`4cf04a0`](https://github.com/Kihara777/dsh-api-balance/commit/4cf04a0)；版本仍 `0.1.1`）
- 题干限高的下边界加 `mask-image` 渐隐、被吸附按钮上方加 `::before` 渐变带
- 渐变色在注入时取卡片实际底色（浅 `rgb(255,255,255)` / 深 `rgb(44,44,46)`，写死会在深色下露馅）
- 判据：题干下边界 30px 平均亮度 59.93 → 45.92（约暗 23%），渐隐区之上（60–90px）不变
| 提交 | 说明 |
|------|------|
| `e755381` | fix(dsh-api-balance): re-pin 到 911df2e —— 疑问窗口底部渐隐遮罩 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重钉） |
| 　 | rev | `1f0af6c` → `911df2e` |
| 　 | src hash | `sha256-f3dg9oSbtKeYO6KzJZdpxz86gDUAI6vbRy8R3SSwroU=` → `sha256-oc+TPbtuwItV43kskjpz18Ys2cTtCgceXAGrh0Q0D2c=` |

## 2026-10-05T13:23:30+09:00

**摘要**：dsh-api-balance 薄封装 re-pin —— 按维护者反馈修两处界面问题

- rev `f805f4e` → `1f0af6c`（变更见其提交 [`e6d638c`](https://github.com/Kihara777/dsh-api-balance/commit/e6d638c)；版本仍 `0.1.1`）
- ① 底部统计条横向滚动**停用**（官方 0.2.0 已把指标做成可点击 pill，设置行置灰）
- ② 疑问窗口 header 限高（≤40vh）自滚、不吸顶 —— 长题干下曾挡住选项
- 判据：以本包**构建产物**跑 `develop/ab-ui`（C2/C6 改判结果层），运行树用 `develop/check-deployed-artifact.py` 的三个特征串核对
| 提交 | 说明 |
|------|------|
| `1548c4c` | fix(dsh-api-balance): re-pin 到 1f0af6c —— 统计条停用 + 疑问窗口题干不再遮挡选项 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重钉） |
| 　 | rev | `f805f4e` → `1f0af6c` |
| 　 | src hash | `sha256-u1L1VHy86tOeB3iv3MhCdL0VAi8xpNUf2OJHAa/zndY=` → `sha256-f3dg9oSbtKeYO6KzJZdpxz86gDUAI6vbRy8R3SSwroU=` |

## 2026-10-05T07:45:26+09:00

**摘要**：CI 修复 —— 浮动输入 `llama-cpp-ver` 改走「认证取回 + 本地覆盖」，根治 `api.github.com` 403 限流

- 该输入是**普通 URL 输入**，Nix **不会**把 `access-tokens`／`netrc-file` 附加到这类 fetch 上
- 各 job 的未认证请求用尽共享 runner IP 的 60 次/小时额度（403）
- 现先以 `gh api` 取回同一份 JSON，再经 `--override-input llama-cpp-ver path:<json>` 喂给 Nix
- 语义不变（overlay 只读 `json.tag_name`），缺 `tag_name` 即**显式失败**
- `access-tokens` 保留 —— 它管 `github:` 取源
| 提交 | 说明 |
|------|------|
| `335dce9` | fix(ci): 浮动输入 llama-cpp-ver 改走「认证取回 + 本地覆盖」 |
| `e92cfe4` | fix(ci): 覆盖参数为空时显式失败 —— 不静默退回未认证取回 |
| `35eec1e` | docs: 纠正「access-tokens 能治 llama-cpp-ver 403」这条被实测否证的结论（AGENTS.md + 技能） |

## 2026-10-05T07:14:50+09:00

**摘要**：dsh-api-balance 薄封装 re-pin —— 移动端键盘守护重写

- rev `8dab668` → `f805f4e`（变更见其提交 [`f805f4e`](https://github.com/Kihara777/dsh-api-balance/commit/f805f4e4445cd4db6a3ccd16e23cfd90fb092208)；版本仍 `0.1.1`）
- 移动端「会话切换不弹键盘」**仍然失效**：真实 `focusin` 不可取消（`preventDefault` 是死代码），软键盘在 `focus` 那一刻就被请求
- 现让输入框在用户点按前保持不可编辑，点按/按键即刻恢复，焦点离开重新武装
- 判据：切换会话期间「focus 落到可编辑输入框」次数 0（部署版 2）；`develop/ab-ui/` 以本包**构建产物**为被测对象
| 提交 | 说明 |
|------|------|
| `a4b6bb1` | fix(dsh-api-balance): re-pin 到 f805f4e —— 移动端键盘守护按真因果链重写 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重钉） |
| 　 | rev | `8dab668` → `f805f4e` |
| 　 | src hash | `sha256-yM+rQb/xIuTiN6QGpWr++jd2vDGHoN5K4gHnLmkGB4A=` → `sha256-u1L1VHy86tOeB3iv3MhCdL0VAi8xpNUf2OJHAa/zndY=` |

## 2026-10-04T09:23:29+09:00

**摘要**：fix(dsh-preset-news-three-elements): 预设插件会话消息来源改用 v4 形状

- dsh 0.2.0 会话格式 v4 只拒字面量 `kind: "plugin"`，本仓预设插件照抄了它，于是每条消息都被拒，session 报「本机运行失败」
- 三处改为 `{ kind: `plugin:${name}`, form: "notice", summary }`（`news-language.js` ×1、`news-material.js` ×2）
- 断言由 `source.plugin` 改为 `source.kind`
- 新增自检 `session-sources`（`develop/check-session-sources.py`，挂进 `nix flake check`）钉住「预设插件里不得再出现 `kind: "plugin"`」
| 提交 | 说明 |
|------|------|
| `d27e6ce` | fix(dsh-preset-news-three-elements): 会话来源改用 v4 形状（另含新增 `session-sources` 自检并挂进 `nix flake check`、四语 dsh 文档增 v4 来源准入一节、AGENTS 自检表 7 → 8 项） |

## 2026-10-03T09:49:14+09:00

**摘要**：dsh-api-balance 薄封装 re-pin —— 复核 dsh 0.2.0 界面改进时查出两处**静默失效**

- rev `700fbbc` → `8dab668`（版本仍 `0.1.1`）
- ① 底部统计条横向滚动**自 dsh 0.1.5 起失效** —— 上游把样式模块 `StatsLine.module.css` 改名为 `StatsPills.module.css`，插件只认旧名而设置里仍显示 On
- ② 三个 token 在 0.2.0 已不存在，其中 `--dsw-alias-separator-primary` 管 18 处边框且**无 fallback**
- 现按 0.2.0 原生补链
- 判据：隔离实例 + Playwright 实测（部署版两项皆失效）
| 提交 | 说明 |
|------|------|
| `18441ef` | chore(pkgs): re-pin dsh-api-balance rev（界面改进两项失效修复；版本仍 0.1.1） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重钉） |
| 　 | rev | `700fbbc` → `8dab668` |
| 　 | src hash | `sha256-GEG3/ImXmo3BgO7AVh/rj1mIWsWMGB04Six+oIk9UIE=` → `sha256-yM+rQb/xIuTiN6QGpWr++jd2vDGHoN5K4gHnLmkGB4A=` |

## 2026-10-03T06:45:00+09:00

**摘要**：dsh-api-balance 薄封装 re-pin —— **运行行为修复**

- rev `76ea584` → `700fbbc`（变更见其提交 [`cc89c43`](https://github.com/Kihara777/dsh-api-balance/commit/cc89c43)；版本仍 `0.1.1`）
- ① 回车交换安装移出组件生命周期 —— 0.2.0 链式槽位 `conversation.composer` 被接管时环组件随槽位卸载、交换器被静默摘掉，现于 `apply()` 安装
- ② 面板 / 弹窗材质按 0.2.0 原生配方重写 —— `--dsw-specific-menu` 已半透明且须叠 `backdrop-filter`，旧配方下面板真的透明
- 判据：Playwright 实测 computed style
| 提交 | 说明 |
|------|------|
| `6a8f68f` | chore(pkgs): re-pin dsh-api-balance rev（回车交换 + 面板材质修复；版本仍 0.1.1） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重钉） |
| 　 | rev | `76ea584` → `700fbbc` |
| 　 | src hash | `sha256-7Yr9ALLN9hQTut5XziFLulmMde5GRgxTjBWidaxKqno=` → `sha256-GEG3/ImXmo3BgO7AVh/rj1mIWsWMGB04Six+oIk9UIE=` |

## 2026-10-03T06:15:29+09:00

**摘要**：文档 — 补齐维护日志的 ja / pcn **未译条目**

- ja **80** 条、pcn **59** 条 —— 其摘要行是 `**Summary**` 标记加英文或中文旧稿，内容本身也与现 zh 源不一致，故按 zh 源**整行替换**
- 检查器补第 6 条「**摘要标记须是本语的**」，ja 用 `**Summary**`、en 用 `**概要**` 各自作反证翻红
- **验证**：`nix flake check` 全绿；四语各 358 条，ja / pcn 均 0 条残留
| 提交 | 说明 |
|------|------|
| `197099e` | fix(docs): 补齐 ja 80 条 / pcn 59 条未译条目，并修 pcn 一处错标签 |
| `44793f3` | feat(develop): maintenance-log 检查补第 6 条 —— 摘要标记须是本语的 |

## 2026-10-03T05:16:47+09:00

**摘要**：技能 — 维护日志的**倍率判据补第二个特征：反引号占比**

- 只看 CJK 密度会高估：密度 0.646 的条目按密度队列（n=34）均值 **2.37** 被判「偏短」
- 把反引号占比加进来做最近邻（n=15）后均值 **1.98**，交付的 1.95 正落在那里
- 反引号内容逐字照抄、占比越高倍率越贴近 1，故改为「同结构 + 同密度队列比较」
- **验证**：`nix flake check` 四语全绿
| 提交 | 说明 |
|------|------|
| `bad01c4` | refactor(skills): 倍率判据补第二个特征（反引号占比）—— 只看密度会高估，实测差 0.4 倍 |

## 2026-10-03T05:13:21+09:00

**摘要**：文档 — `blender-mcp` / `obs-bilibili-stream` 两处 riscv64 排除的理由改准

- 不是「依赖链交叉编译缺陷」，而是**主依赖在 nixpkgs 里没声明该架构**（`blender 5.2.2`、`obs-studio 32.2.2` 的 `meta.platforms` 都不含 riscv64，求值阶段即被拒）
- 判据是 `pkgs.<dep>.meta.platforms` 而**不是编译报错**
- **验证**：`nix flake check` 四语全绿
| 提交 | 说明 |
|------|------|
| `e454504` | docs(pkgs): 两处 riscv64 排除的理由改准 —— 上游没声明该架构，不是「交叉编译缺陷」（四语） |

## 2026-10-03T04:53:28+09:00

**摘要**：文档 — `AGENTS.md` 部署核对判据换成「**看单元引用**」

- dsh 0.2.0 启动时会重写 `cordis.patch.yml`，落盘的是它自己的序列化结果，照内容比对只会得到**假阴性**、把成功的部署判成失败
- 新判据比对运行单元 pre-start 脚本引用的 store 路径与当前配置生成的那份（两条命令已写进文档），本机实测一致
- **验证**：`nix flake check` 全绿
| 提交 | 说明 |
|------|------|
| `5df33e9` | docs(AGENTS): 部署核对判据换成「看单元引用」—— 原判据已失效：dsh 启动时会重写 cordis.patch.yml |

## 2026-10-03T04:43:18+09:00

**摘要**：修两处**我自己引入的失守**（检查器与倍率判据）

- ① 检查器看不见「整张表没了」：`check-maintenance-log.py` 原先四条规则全看总量，于是只写标题与摘要、**丢掉提交表**照样通过
- 补第 5 条**结构对等**（每条目的提交 SHA 集合四语须与 zh 一致）
- ② 写进技能的倍率判据本身是错的：拿全库均值（`en/zh` ≈ 1.84）判译文啰嗦，而实测 CJK 密度与倍率相关系数 **r = 0.90**，同密度队列均值 2.29、被判「超标」的那条其实低于队列 —— 照均值执行只会逼出**删内容**，故改为同密度队列比较
- **验证**：`nix flake check` 全绿；检查器三项反证（删整表 / 改一位 SHA / 删整条）全部翻红
| 提交 | 说明 |
|------|------|
| `21993c8` | fix(develop): maintenance-log 检查补「结构对等」判据 —— 原有的四条只看总量，漏掉过「某条目在某译文里整张表都没了」 |
| `1c6e4be` | refactor(skills): 修正倍率判据 —— 全库均值混着 CJK 密度这个强混杂因子（实测 r=0.90） |

## 2026-10-03T04:27:03+09:00

**摘要**：`opencode-telegram` 的 riscv64 **由「摘掉」改回「建」**，并加上「产物真的跑一遍」的判据

- 修好两处 gyp 陷阱（指向交叉编译器的 `gcc` shim、`better-sqlite3` 显式 `--force_build=1`）
- `build-package.yml` 新增 `smoke-test` —— 构建后跑 `develop/qemu-smoke-tests/<包名>.sh`（本地与 CI 同一份），缺脚本或缺 binfmt 处理器都判失败
- **验证**：两次推送各 33 个 workflow 全部 success
| 提交 | 说明 |
|------|------|
| `af82af7` | feat(ci): riscv64 产物改成「真的跑一遍」—— 修好两个 gyp 陷阱 + build-package 加 smoke-test 开关 |
| `16bcc25` | refactor(skills): 泛化「缓存假绿」与「构建成功≠产物能跑」—— 含 smoke-test 机制与反证要求 |
| `ab20373` | fix(opencode-telegram): 用构建平台的 node 跑 node-gyp —— PATH 上的 node 是 riscv64 的，x86_64 runner 上执行不了 |
| `ab4e884` | refactor(skills): 记下「本机构建条件比 CI 宽松」—— binfmt 在本地让 riscv64 二进制能跑，于是本地绿掩盖了 CI 缺陷 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | — | 版本未变（0.26.2）；**构建矩阵**：x86_64 + aarch64 → x86_64 + aarch64 + riscv64（且 riscv64 带 qemu 烟测） |

## 2026-10-03T02:26:58+09:00

**摘要**：`opencode-telegram` **摘掉 riscv64 构建** —— 转绿不是靠修好构建，而是停建本就不可能可用的平台

- 那个 job **一直靠缓存假绿**（日志里没有构建，取的是上一版 0.25.3 的产物）
- 真构建则卡在**直接依赖且被静态 import** 的 `better-sqlite3`（上游无 riscv64 预编译、v13 起取消 `install` 脚本），**产物能构建、一启动就抛**
- 按 `blender-mcp` / `obs-bilibili-stream` 同一先例摘掉
- 验证：x86_64 / aarch64 不受影响
| 提交 | 说明 |
|------|------|
| `b488bae` | fix(opencode-telegram): 摘掉 riscv64 构建 —— 上游 better-sqlite3 无 riscv64 预编译，产物能构建但一启动就抛 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | — | 版本未变（0.26.2）；构建矩阵：x86_64 + aarch64 + riscv64 → x86_64 + aarch64 |

## 2026-10-02T20:38:40+09:00

**摘要**：两处**判据盲区**与一处**同名冲突** —— `doc-links` 判据、预设技能副本、persona 三处收口

- `doc-links` 的切换器判据改为 `docs/` 下必须存在且在**全文**里查找（旧版只看 `lines[:8]`，「整行删掉」与「落在第 8 行之后」一直静默通过——四份 `docs/*/ruyi.md` 从未被校验）
- 预设不再自带组合撰写技能副本（与上游**同名而内容分叉**，改为挂上游那份并用断言钉住）
- persona 去掉已过期的说法
- 验证：`nix flake check` 全绿；预设放进一次性 `0.2.0-rc.2` 实例，**9 条预设 `broken` 全空**
| 提交 | 说明 |
|------|------|
| `fa0beff` | fix(develop): doc-links 的切换器判据补上盲区 —— docs/ 下强制存在、全文查找 |
| `1e85409` | refactor(dsh): 预设不再自带组合撰写技能副本 —— 改挂上游那份，并去掉已过期的 persona 说法 |

## 2026-10-02T19:54:49+09:00

**摘要**：dsh **0.2.0-rc.2** —— 两通道一起跨代（0.1.x → 0.2.x 断代），并落地 **Agent 预设迁移**

- 实测 `alpha` 比 `latest` 低（`latest` = `next` = `0.2.0-rc.2`），故 `dsh-alpha` 改跟 `next`，两通道同一 tarball、hash 与 lock 共用
- 0.1.x 的目录式预设被上游整条删除，旧格式由新增的钉-rev 包提供
- 模块按 `passthru.dshChannel` 二选一，把 `preset.patch.yml` 逐字并进生成的 `cordis.patch.yml`，旧 settings 键被断言拦下
- 验证：四语自检全绿；实跑一次性实例确认预设与技能根解析
| 提交 | 说明 |
|------|------|
| `e4bcdee` | chore(pkgs): dsh 两通道升到 0.2.0-rc.2 —— alpha 改跟 npm next，两通道共用一份 vendored lock |
| `2b37ba5` | feat(dsh): 预设内容来源分叉 —— stable 冻结在钉住的 rev，alpha 跟仓库 HEAD |
| `b20a4c3` | refactor(presets): 预设迁到 0.2.0 单格式 patch 行（nixos / maintenance / news-three-elements） |
| `1fd1768` | feat(dsh): 模块按 0.2.0 接线预设与宿主面 —— patch 行播种、agent-preset-registry、node_modules 双链接 |
| `b5a767a` | docs(dsh): 四语文档同步 0.2.0 —— 通道语义、预设格式、宿主命名空间（四语） |
| `4758b05` | docs(AGENTS): 预设一节重写为 0.2.0 单格式与取用点分叉 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh | 0.1.5-rc.2 | 0.2.0-rc.2 |
| dsh-alpha | 0.1.6-alpha.2 | 0.2.0-rc.2 |
| 　 | npm tag | `alpha` → `next` |
| 　 | src hash / npmDepsHash | 重算；两通道同一 tarball ⇒ 共用一份 vendored lock（`dsh-package-lock-alpha.json` 删除） |
| dsh-nixos-shell-stable | 新增 | 钉 `0175f85` 的预设内容变体（`presetsSource` 参数 + `passthru`） |
| dsh-preset-news-three-elements | 0.1.0 | 0.2.0 |

## 2026-10-02T18:02:46+09:00

**摘要**：feat(dsh): 预设迁移准备 —— 0.2.0 新格式 `preset.patch.yml` + 派生检查适配（四语）

- 预设从目录式 `agent.cordis.yml` 变成一条 loader patch 条目（`- insert:` → `@deepseek-ai/dsh-agent-preset`），落点 `$DSH_HOME/profiles/<profile>/cordis.patch.yml`
- 26 个包的 schema 逐插件核对，6 处变化全是新增可选字段
- 三处「照抄会坏」已改：`baseUrl` 改指该 profile 目录、元数据搬进 `config.name` / `description`、`config.order` 是新键
- 验证：一次性 0.2.0 实例 7 条预设 `broken` 全空；反证只改一行即各报具体 `broken`
| 提交 | 说明 |
|------|------|
| `3f92bb1` | feat(dsh): 预设迁移准备 —— 0.2.0 新格式 preset.patch.yml + 派生检查适配（四语） |

## 2026-10-02T17:39:30+09:00

**摘要**：feat(dsh): 声明式设置面补全 —— 结构化选项 7 → **13**，新增 6 个类型化 namespace

- 新增 6 个类型化 namespace（`permission`、`web-search-deepseek`、`agent-presets`、`subagent`、`shell`、`llm-deepseek`），把「拼错或越界只在运行时被静默丢弃」变成**求值期报错**
- 顺带修正三处判断：namespace 总数 **12 → 15**、「`shell.cwd` 无默认值 ⇒ 不能部分声明」是错的、「typo 与越界都静默」只对一半
- 验证：最小 NixOS 配置（13 段全开 + 逃生舱覆盖）求值通过，`settings.yaml` 含全部新段且可 `builtins.fromJSON` 解析，负例各自求值期报错；`nix flake check` 全绿
| 提交 | 说明 |
|------|------|
| `0f12640` | feat(dsh): 声明式设置面补全 —— 新增 6 个类型化 namespace（13 个结构化选项，四语） |

## 2026-10-02T17:33:52+09:00

**摘要**：godot-ai 4.1.0 → 4.2.3 — fail-closed 校验表 9 → 14 项（`mcp` 1.29.1 → 2.2.0、`fastmcp` 3.4.7 → 4.0.5，新增 `mcp-types` 等）

- `mcp-types` 不在 nixpkgs，取自上游同仓库 `src/mcp-types/` 子项目
- 两 overlay 的 `python312.override { packageOverrides = …; }` 在链式 `.extend` 下互相替换、覆盖被静默丢弃而构建仍成功；改用 `pythonPackagesExtensions`
- 判据：构建通过、实跑 `godot-ai --version` 得 4.2.3、`importlib.metadata` 14/14、`nix flake check` 全绿

| 提交 | 说明 |
|------|------|
| `32bcf22` | chore(pkgs): godot-ai 4.1.0 → 4.2.3 —— 依赖表 9→14、mcp 2.2.0、fastmcp 4.0.5、新增 mcp-types（四语） |
| `828af9c` | refactor(skills): 泛化链式 overlay 的替换语义陷阱（改用 pythonPackagesExtensions） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| godot-ai | 4.1.0 | 4.2.3 |
| 　 | 运行时依赖 pin 表 | 9 项 → 14 项 |
| 　 | src hash / overlay 覆盖 | 重算；两个 overlay 改可叠加挂载 |

## 2026-10-02T17:09:33+09:00

**摘要**：feat(skills): 更新检查新增「推送后：验证 CI 构建」一节（四语）

- 本地构建成功不等于 CI 会绿：可能命中二进制缓存、只覆盖当前架构，多架构包的另一架构只有 CI 能验
- 判据：等 `status` 全部离开 `queued`/`in_progress`、按 `--commit` 过滤、失败必看日志原文
- 先分类再动手：限流与抖动属偶发，hash 不符与 lock 不自洽属真失败，单架构红属待判，「全绿但日志全是 `copying path … from cache`」可疑——CI 通过不等于它构建过
- 失败时一次列出全部失败项与性质，选项含重跑、修补后追加提交、回退该批；禁止「用重跑到绿代替修复」
- 适配层记入本仓形态（`build-package.yml` 骨架、每包每架构一个 workflow、`ci-summary.yml` 徽章）与四种实测失败形态
| 提交 | 说明 |
|------|------|
| `6ff84e3` | feat(skills): 更新检查新增「推送后验证 CI 构建」环节（四语） |

## 2026-10-02T17:03:13+09:00

**摘要**：codewhale 0.9.13 → 0.10.0；ruyi 0.52.0 → 0.53.0；mcp-searxng 2.3.0 → 2.5.0；opencode-telegram 0.25.3 → 0.26.2 — 四语文档同步

- `dsh` 0.2.0-rc.2 与 `dsh-alpha` 0.1.7-alpha.2 暂缓：hash 与构建通过，但预设挂载验证未过——`agentPresets/list` 的 roster 里都不出现；对照实验有区分度，尚不能区分格式不兼容与探针 `DSH_HOME` 不足
- fix(dsh): `postPatch` 由「从 `devDependencies` 截断到末尾」改为按块匹配 + 尾逗号修复——0.2.0-rc.2 起 `exports` 在后，旧写法会连带删掉（导出失效而构建仍成功）；两份真实 tarball 离线验证可解析

| 提交 | 说明 |
|------|------|
| `16216d5` | chore(pkgs): 上游更新 —— codewhale 0.10.0 / ruyi 0.53.0 / mcp-searxng 2.5.0 / opencode-telegram 0.26.2（四语文档同步） |
| `63e71cd` | fix(dsh): postPatch 按块删 devDependencies —— 0.2.0+ 的 exports 不再被误删 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.9.13 | 0.10.0 |
| 　 | cli / tui hash（x64、arm64） | 四值全部重算（cli 与 tui 同值） |
| 　 | codewhale-src `src` hash | `sha256-AYs2v/…` → `sha256-SsN/p+…`（Cargo.lock 同步至 7266 行） |
| ruyi | 0.52.0 | 0.53.0 |
| mcp-searxng | 2.3.0 | 2.5.0 |
| 　 | src hash / npmDepsHash | 两者均重算 |
| opencode-telegram | 0.25.3 | 0.26.2 |
| 　 | src hash / npmDepsHash | 两者均重算 |

## 2026-10-02T16:26:56+09:00

**摘要**：feat(skills): 更新检查新增「第 0 步」——开工前 `git fetch` 对齐远端并核对未关闭 issue / PR（四语）

- issue 是「已知故障」的集合、PR 是「在途工作」的集合，该步同时把取数链路自检提前
- `gh` 失败即显式非零退出，故「空列表」只在命令成功时才算「真的没有」
- 提交前自检由九问扩为十问，并如实标注第 10 问出自维护者的前置要求（前九问是实测返工的产物）
- 适配层补本仓坐标、`has_issues=true`、实测 0 未关闭 issue / PR 与四条真实先例（PR #6 改固定 SHA 的 action、PR #7 更新本仓包、PR #4 / #5 促成 `/tts` 的 SSRF 修复、issue #3 促成技能拆分）
- 顺带修正 `traps.md` 与四语技能文档的两处失真
| 提交 | 说明 |
|------|------|
| `c10de09` | feat(skills): 更新检查新增第 0 步 —— 开工前同步远端并核对活跃 issue / PR |

## 2026-10-02T03:54:38+09:00

**摘要**：fix(dsh): 更正 image 模态断言（四语）

- 上条记录称 `deepseek-flash` 为「唯一声明 image 模态的 flash 条目」且横跨两通道
- store 内两份已构建产物：stable `0.1.5-rc.2`、alpha `0.1.6-alpha.1` 各有两条声明 `inputModalities: ["text","image"]`（`deepseek-flash`、`deepseek-v4-flash-vision-exp`），alpha `0.1.6-alpha.2` 仅一条
- 改动：改为「三个目录都收录且都声明 image 模态的唯一 id」，目录表增该列
- 降级警告改为双路径——新贴的图在 `session/prompt` 准入报错 `MODEL_DOES_NOT_SUPPORT_IMAGES`，仅历史里的图静默替换
- 默认值不变
| 提交 | 说明 |
|------|------|
| `067b296` | fix(dsh): 更正 image 模态断言 —— stable/alpha.1 目录实有两条声明（四语） |

## 2026-10-02T03:01:23+09:00

**摘要**：fix(dsh): 默认模型迁到 `deepseek-flash`（四语）

- 上游 2026-09-10 下线 V4 Flash 与 V4 Flash Vision Exp，模型名收敛为 `deepseek-flash` 与 `deepseek-v4-pro`
- dsh 目录随版本走：stable `0.1.5-rc.2` 与 alpha `0.1.6-alpha.1` 四条、alpha `0.1.6-alpha.2` 两条
- 原默认值 `deepseek-v4-flash` 已不在 alpha 目录，目录外 id 按纯文本模型处理，图片被 `projectImagesForTextModel` 静默替换为文本占位符——不报错、模型看不到图
- 改动：默认值改 `deepseek-flash`、选项描述写明目录随版本走；四语 `dsh.md` 同步示例 id、新增该节与降级警告
| 提交 | 说明 |
|------|------|
| `2ab7dda` | fix(dsh): 默认模型改用 deepseek-flash —— 上游 09-10 下线旧 id（四语） |

## 2026-09-28T13:07:06+09:00

**摘要**：dsh-api-balance 0.1.0 → 0.1.1 —— 薄封装坐标同步

- 子仓无维护日志，变更见 [`76ea584`](https://github.com/Kihara777/dsh-api-balance/commit/76ea5847c3e3f8e639b01abbfd8901fa71d6c177)
- 音色改为按「话的变体」选择：旧实现按主语言前缀取第一个音色，而粤语 `zh-HK` 与普通话 `zh-CN` 同属 `zh`，音色表里粤语在前的系统必然把普通话念成粤语——文本与界面全对，不听声音发现不了
- 现按变体归类排序、发声前等音色表就绪、`utter.lang` 与所选音色对齐，并新增「音色」设置项显示实际使用的音色
- 判据：子仓 `test/voice-selection.test.mjs`（25 条断言含反证）与真实浏览器实测
| 提交 | 说明 |
|------|------|
| `a4e6d54` | chore(pkgs): bump dsh-api-balance 0.1.0 → 0.1.1（音色按话的变体选择） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.0 | 0.1.1 |
| 　 | rev | `c47f857` → `76ea584` |

## 2026-09-28T08:28:27+09:00

**摘要**：refactor(skills): 本日的预设事故按「换个 nix flake 仓库还成立吗」分入两级技能

- 通用技能 `nix-flake-update-check` 的提交前自检由八问增至九问，新增「『验过了』验的是失败会发生的那一层吗？判据自己能失败吗？」：从不报警的判据区分不了「没问题」与「没量到」，救济是给判据配一份已知坏掉的夹具（反证）
- 本仓适配层 `nixkits-check-updates` 新增一节：插件改名/删除不只是文档问题，还会真的坏掉两个预设——组合行按包名引用内置插件，dsh ≤ 0.1.6-alpha.1 静默忽略解析不了的行，≥ alpha.2 硬失败致整份预设挂不起来
- 该节给出升级前必跑的两层判据（离线行解析 + 读上游 `broken` 字段的真挂载）与 seed-once 播种的推论
- 三处自检编号引用同步更新
| 提交 | 说明 |
|------|------|
| `c5022ea` | refactor(skills): 预设事故泛化 —— 通用技能加第 9 问，适配层加插件改名陷阱 |

## 2026-09-28T08:04:31+09:00

**摘要**：fix(dsh-nixos-shell): 预设行改用 `workflow-ptc` —— 内置插件 `dsh-workflow-worker-thread` 在 dsh 0.1.6 已改名，旧名 ≤ alpha.1 静默忽略，alpha.2 起整份预设挂不起来。

- `nixos-mode` / `maintenance-mode` 组合行与 `editing-cordis-compositions` 技能示例同步改名，`config` 逐字不变
- 验证改为对**构建产物**真挂载：一次性 dsh 调 `agentPresets/list` 读 `broken` 判定，并塞坏夹具做反证
- 同陷阱写入 `docs/*/dsh.md`（四语）；修正 `AGENTS.md` 本机部署前提为 GitHub 引用而非 `path:`（须先推送再重锁，重锁连带重解析浮动子输入）

| 提交 | 说明 |
|------|------|
| `c92e980` | fix(dsh-nixos-shell): 预设行改用 workflow-ptc（旧名在 0.1.6 已不存在） |
| `7a12ff2` | docs(dsh): 记录 0.1.6-alpha.2 插件改名硬失败陷阱（四语） |
| `5364ef1` | docs(agents): 修正本机部署前提（GitHub 引用而非 path 输入）+ 重锁的副作用 |

## 2026-09-24T05:45:11+09:00

**摘要**：① `fix(pcn)` 剔除偽中国語假名 ② `feat(dsh)` 新增 6 个结构化 settings 选项

- ① 剔除 4 处残留假名，`check-maintenance-log`、`check-doc-links` 复归 `exit 0`
- ② `agent-loop`、`subagent-model-selection`、`locale`、`ui-theme`、`ui-chat`、`ui-conversation`
- 此前仅 `agent-default-model` 有结构化选项，其余只走无类型 `settings`（写错静默回落 schema 默认）；`shell` 因 `cwd` 无默认值不提供
- 改正文档 `0.1.5-rc.2` namespace 表 5 行错误
- 判据：6 项检查全绿、四语结构对等、启用后 settings.yaml 含 6 新段
| 提交 | 说明 |
|------|------|
| `d2e8c10` | fix(pcn): 剔除偽中国語残留假名 —— 恢复 CI 绿灯 |
| `55cbdbd` | feat(dsh): 6 个新结构化 settings 选项 + 修正 namespace 表（四语） |

## 2026-09-23T08:27:16+09:00

**摘要**：refactor(preset): 维护模式提示词拆为「通用方法 + 本仓适配层」

- `maintenance-skills` 此前把 NixKits 工作流写死在公开预设，与 `skills/` 分法（`nix-flake-update-check` 通用 ← `nixkits-check-updates` 本仓适配）不一致
- 拆为 `maintenance-workflow`（序号 901，通用：分批提交、推送后记录、文档与代码同步、修复泛化到技能）与 `maintenance-workflow-repo`（序号 902，本仓约定：四语与 `docs/zh/` 基准、`write-maintenance-log` 为准绳、条目数一致判据）
- 判据：「这条规矩换个仓库还成立吗」；通用层无本仓专名
- 新增 `repoWorkflow: false` 只留通用层
- 四语文档同步
| 提交 | 说明 |
|------|------|
| `78fb91b` | docs(modes): 维护模式提示词分层 —— 通用方法 + 本仓适配层（四语） |

## 2026-09-22T16:23:33+09:00

**摘要**：docs(skill): 记「引导器配置不可命令式改写」事故于 `nixos-specialisation-tuning`

- `extraInstallCommands` 在 Limine **哈希固化之后**改写 `limine.conf` 的 `default_entry`，哈希不匹配致 Secure Boot 下**系统无法启动**
- 技能加一节 `### 引导菜单与默认面`：配置必须声明式，并给出「写文件 → 校验/签名」的排查顺序、固化后须与上游逐字节同算法重新固化
- 另一节是分面切换的两个运行级故障：判据不得用 `is-active` 而须用 `default.target` 的解析值；`user@<uid>.service` 跨面须整体 restart，不得以「合成器存在」当「桌面正常」
- 同步 frontmatter `description` 与「适用场景」
| 提交 | 说明 |
|------|------|
| `8c276c0` | docs(skill): 补「引导器配置不可命令式改写」事故 —— 我引入的无法启动故障 |

## 2026-09-22T09:37:07+09:00

**摘要**：fix(ci): `ci-summary` 按 `head_sha` 过滤，修正 README 徽章误报 `failing`

- 该 workflow 由 push 触发，会在同一轮构建未完成时启动，查询不限定 commit 便取到上一轮 push 的旧失败运行（实例：`Build dsh-preset-news-three-elements (aarch64)` run#157）
- `curl` 加 `--fail`
- 请求失败时保留现有徽章并 `exit 1` —— 此前 403 限流返回的 JSON 错误体让 `FAILED` 为空，静默写成 `passing`
- 判据：新 jq 逻辑对当前 HEAD 实跑输出为空（=> passing），与 31 个 Build workflow 全绿一致
- 本次外部改动仅为 `gh-pages` 上的徽章状态，主分支源码未被他方改动
| 提交 | 说明 |
|------|------|
| `7fc4a14` | fix(ci): ci-summary 按 head_sha 过滤，修正徽章误报 failing |

## 2026-09-20T17:56:28+09:00

**摘要**：refactor(skill): 审计后泛化 8 个通用技能中的仓库与角色特指。

- `write-maintenance-log`：入口「由 AGENTS.md 强制触发」改条件式；SUBTITLE 的 `NixKits 软件更新维护日志。` 改 `<项目名>` 占位（逐字替换，会写入他项目名）
- `write-project-docs`：「仅保留中文」与反模式表「硬编码语言列表」矛盾，改「基准语言由仓库自定」
- 切换器验证脚本改动态发现语言集（原写死 `docs/zh|en|ja|pcn` 与 `/5`）；`translate-pseudocn` 残缺脚本重写
- 跨技能硬引用改为可独立成立；步数声明与实际的 9 步对齐；子仓示例与 `kits/` 去特指
判据：两个验证脚本实跑通过（含注入断链反向验证），`nix flake check` 全通过。

| 提交 | 说明 |
|------|------|
| `dac80a7` | refactor(skill): 全面泛化通用技能中的仓库/角色特指（审计后批量修复） |

## 2026-09-20T17:41:07+09:00

**摘要**：refactor(skill): 泛化外部自动化与 Actions 检查的适用对象（不再特指某仓库）

- 技能是发给他人复用的产物，读者可能是别的仓库的贡献者或接手者，原写法读起来像「与我无关」
- `traps.md` 新增两节：固定 SHA 的副作用（收不到通知）由任何采纳者继承，判据是**能否自行实现**而非谁在用（按维护者 / 贡献者 / 审计者三类角色列适用时机）
- 以及非维护者升级 action 也应走 PR
- 第 2 步与 `builders.md` 改述为一般情形，第 8 步改为「由适配层指定」，并移除通用技能对适配层的硬编码路径引用
- 判据：`nix flake check` 全通过
- 适配层 `nixkits-check-updates` 的本仓事实保留
| 提交 | 说明 |
|------|------|
| `23e11a5` | refactor(skill): 泛化外部自动化与 Actions 检查的适用对象（不再特指某个仓库） |

## 2026-09-20T17:28:32+09:00

**摘要**：fix(skill): 修复 `nix-flake-update-check` 三处「不报错、只漏掉」缺陷。

- 固定 SHA 的 Actions 检查不可达：`traps.md` 有流程而 `SKILL.md` 无步骤指向，补第 2 步小节、自检扩八问、目录标「每轮都要」
- 版本发现用 `version\s*=` 漏掉参数化主定义的 `version ? "0.1.5-rc.2"`（`packages/dsh.nix`），该包从检查范围消失；改 `version\s*[?=]`
- 裸 `curl` 查 `api.github.com` 额度耗尽后不报错返回空，下游同样静默、每包判「最新」；改 `gh api` 加 `ERROR:` 分支
判据：`nix flake check` 全通过；新流程首跑实测 3 个 action 共 6 处引用逐一比对 SHA 均最新。

| 提交 | 说明 |
|------|------|
| `34368c1` | fix(skill): 接入 Actions 检查、修正版本发现启发式、取数改用 gh api |

## 2026-09-20T17:05:51+09:00

**摘要**：定期更新检查 —— `opencode-telegram` 0.25.3 与 `ruyi-alpha` 0.54.0-alpha.20260918

- `opencode-telegram` 0.25.3（npm 包，source hash 与 npmDepsHash 同步更新，构建通过）
- `ruyi-alpha` 0.54.0-alpha.20260918（薄封装仅改 version 与 hash，三通道共享的 base 未动）
- 同批核查 stable 通道 12 个受检包，仅此两项落后上游
- alpha 通道的 pytest 计数由 346 单元 / 57 集成更新为 462 单元（含 1 xfailed）/ 70 集成
- 四语文档同步
| 提交 | 说明 |
|------|------|
| `1711331` | feat(pkgs): opencode-telegram 0.25.3 + ruyi-alpha 0.54.0-alpha.20260918 |
| `14e565e` | docs: 同步 opencode-telegram 0.25.3 与 ruyi-alpha 0.54.0-alpha.20260918（四语） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.25.2 | 0.25.3 |
| 　 | source hash | `sha256-wNM/QNtFaRaColS2MGqk2p94NpVeHXoqJ26RjNRVypU=` → `sha256-XVIsT9mQuagF3DDLwlXomihfpBJLZ6OfJHzBGLM9lXM=` |
| 　 | npmDepsHash | `sha256-NnvFOrS7Y7NFYoS/lWTb3tTs5xwHhzDLTzkdGN+f3vw=` → `sha256-lLl6AobcB/Zi9aw463iv1MMAPah+RV/GtrF0nK6X1Q0=` |
| ruyi-alpha | 0.52.0-alpha.20260714 | 0.54.0-alpha.20260918 |
| 　 | source hash | `sha256-x6DGsnGgeClKXsS1kXP+3nIYGG2hJhyk6J1ENE2VD8s=` → `sha256-6XSVQuU+szU8CnijgAwQa1XmoHgpk/vHW6tmWP5dkpQ=` |

## 2026-09-19T14:13:43+09:00

**摘要**：docs(agents): 补全 `nix flake check` 的 7 项自检清单与 CI 的 `access-tokens` 陷阱

- 核查「未列入文档的内容」，补 1 处结构性缺口
- `nix flake check` 的 7 项自检作为自检契约（任一项失败即阻断提交）此前无集中说明 —— 仅散见于 `flake.nix` 注释，`AGENTS.md` 只提到其中 2 项
- 已在 `AGENTS.md` 的 `## CI` 章节补 ① 7 项自检清单表（检查名 / 脚本路径 / 校验内容）
- ② CI 的 `access-tokens` host 匹配陷阱（`check.yml` 漏 `api.github.com` 致浮动输入 `llama-cpp-ver` 未认证、额度耗尽）
- 判据：7 条路径实存、`nix flake check` 全通过
| 提交 | 说明 |
|------|------|
| `7766b88` | docs(agents): 补全 nix flake check 的 7 项自检清单与 CI 的 access-tokens 陷阱 |

> **说明**：改动 `AGENTS.md`（该文件本身即代理约定文件，非用户文档）。

## 2026-09-19T14:05:38+09:00

**摘要**：fix(ci): `check.yml` 的 `access-tokens` 漏了 `api.github.com`；同时为子仓 `dsh-api-balance` 补四语 `SECURITY.md`。

- CI：浮动输入 `llama-cpp-ver` 此前一直未认证（60 次/小时额度被每轮 push 的 ~34 个 workflow 耗尽），补上双 host 后 33 个 workflow 全 success、零 403；输入仍浮动、未写入 `flake.lock`
- 子仓安全政策：复核扫描器 PR #4 / #5 的「缺少速率限制」「缺少请求体体积上限」两项主张，均判误报、不改代码
- 主仓四语 `SECURITY.md` 的「该子项目尚未自建安全政策」随之更正为已自建，并链接子仓文档

| 提交 | 说明 |
|------|------|
| `d224b18` | fix(ci): check.yml 的 access-tokens 漏了 api.github.com（403 限流根因） |
| `2cce37b` | （子仓 dsh-api-balance）docs(security): 新增四语 SECURITY.md |
| `39c9f10` | docs(security): 子仓已自建安全政策 —— 更新「尚未自建」的过时声明（四语） |

> **说明**：`d224b18` 改动 `.github/workflows/check.yml`；`39c9f10` 为四语文档；子仓提交独立记录于其自身仓库。

## 2026-09-19T07:51:05+09:00

**摘要**：技能文档核对 4 篇（`nix-flake-update-check` / `nixkits-check-updates` / `write-project-docs` / `translate-pseudocn`），修 3 处（四语）

- `nix-flake-update-check`：文档称主流程 1–10 步，`SKILL.md` 实止第 9 步，第 10 步（收尾）归适配层 `nixkits-check-updates`
- `write-project-docs`：配套文件 `templates.md`（209 行）未被 `SKILL.md` 声明 —— 补配套表与目录式路径
- `translate-pseudocn`：词典条目数 13 更正为实测 75，补 `dictionary.md` 配套行
- 对照：`news-three-elements` 配套声明本就正确

| 提交 | 说明 |
|------|------|
| `c9c9c0c` | fix(docs): nix-flake-update-check 技能文档步骤数错误（四语） |
| `7f7363f` | fix(docs): write-project-docs 未声明配套文件 templates.md（四语 + SKILL.md） |
| `cef09fe` | fix(docs): translate-pseudocn 词典条目数与配套文件失实（四语） |

> **说明**：`7f7363f` 含 `skills/write-project-docs/SKILL.md` 改动（技能快照经 `check-preset-bundle` 验证与 `skills/` 树逐字节一致）；其余为四语文档。

## 2026-09-19T07:43:15+09:00

**摘要**：fix(comfyui): 更正「上游已迁移 stdenv API」的错误判定。

- 原判定称「上游已迁移 hostPlatform」，实测否证：`stdenv.is<Platform>` **0.34.0 与 0.30.2 各 38 处**，`hostPlatform.is*` 两版 7 处 —— 从未迁移
- 真实理由：**不再覆盖上游代码**（旧补丁把迁移施加在被 overlay 求值的 fork 上）
- 同步更正 `modules/comfyui.nix` 注释与四语 `deprecated/comfyui-rocm.md`「何故可废弃」段
- 其余废弃类断言通过：`nixkits.comfyui` 更名、`modules/comfyui-rocm.nix` 与三补丁已删、四语 `DEPRECATED.md` 索引正确、上游 **v0.34.0**

| 提交 | 说明 |
|------|------|
| `4054c32` | fix(comfyui): 更正「上游已迁移 stdenv API」的错误判定（模块注释 + 废弃文档四语） |

> **说明**：`4054c32` **改动 `modules/comfyui.nix`**（仅注释，不影响求值；`nix flake check` 全通过）；其余为四语文档。

## 2026-09-19T07:38:04+09:00

**摘要**：fix(docs): 补丁类文档收官 —— 后三篇核对完毕，修 4 处（均四语）。

- asusd-thermal-guard：文档误称状态在 `/run`；模块用 `StateDirectory`（`/var/lib/private/asusd-thermal-guard`），注释警告不可用 `RuntimeDirectory`（systemd 会整个删除它，冷却计数每轮归零）
- comfyui：徽章伪称不存在的 CI job（`check.yml` 只有单个 `check` job），改为如实的 CI 徽章
- comfyui：缓存段残留 overlay 声明（模块已无 `pkgs.comfyui` 引用，只做声明式配置）
- llama-cpp-rocm：迁移示例 `hfCacheDir` 用了不会展开的 `~`，模块默认值为绝对路径

| 提交 | 说明 |
|------|------|
| `8292160` | fix(docs): asusd-thermal-guard 误称状态写在 /run（四语） |
| `01679e8` | fix(docs): comfyui 徽章伪称 job 名 + 残留 overlay 声明（四语） |
| `35aaf05` | fix(docs): llama-cpp-rocm 迁移示例的 hfCacheDir 用了不会展开的 ~（四语） |

> **说明**：均为纯文档修正，`packages/`、`overlays/` 与 `modules/` 未改动。

## 2026-09-18T11:04:38+09:00

**摘要**：外部收录完成 —— awesome-ai-plugins 的两个 PR 均已合并，NixKits 与 dsh-api-balance 正式进入该目录。

- 扫描评分 **88 → 94/100（A – Excellent）**、Security **13/16 → 16/16**，只改措辞、不删信息
- PR #321：`dsh-api-balance` 加入 DeepSeek Harness Plugins，**2026-09-16 合并**
- PR #323：NixKits 加入 Development & Workflow，按评审整改并重跑扫描后由我们主动关闭
- PR #335：重新提交版 **2026-09-18 合并**；两条目现均在上游 README 生效
- 不引入 scanner workflow 与 Dependabot，接受 10% 信任分扣减

| 提交 | 说明 |
|------|------|
| `—` | 外部仓库动作（awesome-ai-plugins PR #321 / #335 合并）+ issue #3 回复更新；本仓无对应 commit |

> **说明**：收录由外部目录方合并，本仓 `packages/`、`overlays/` 与文档均无改动。

## 2026-09-18T14:35:36+09:00

**摘要**：fix(docs): 补丁类前 5 篇文档验证（breeze-black / efl-cross-fix / codewhale-sudo / rcc-fix / asusd-pd-profile）—— 修 3 处。

- `rcc-fix` 用了不存在的 option 命名空间：示例写 `services.asusctl`（含 `power-profile`/`cpu-power-control`），实际应为 `services.asusd`，档位与 CPU 功率上限经 `profileConfig`（四语）
- `breeze-black`「安装」段的占位路径 `(import ./overlay.nix)` 改为 `inputs.nixkits.overlays.<name>`（仅 zh）
- `codewhale-sudo` 基本信息表重复行已删（仅 zh）
其余断言逐项核对通过。

| 提交 | 说明 |
|------|------|
| `a262e3c` | fix(docs): breeze-black 安装路径与 codewhale-sudo 重复行（zh） |
| `ea03584` | fix(docs): rcc-fix 用了不存在的 services.asusctl 选项（四语） |

> **说明**：均为纯文档修正，`packages/`、`overlays/` 与 `modules/` 未改动。

## 2026-09-18T14:26:43+09:00

**摘要**：fix(devshell): 开发类 2 篇验证 —— 修 1 处参数错误 + 1 处源码缺陷。

- `ruyi venv` / `ruyi extract` 参数写错：前者需 `ruyi venv -t <toolchain> <profile> <dest>` 且 `profile` 须在本地索引；后者位置参数是包名 `ruyi extract <pkg>` 而非文件路径（四语）
- searxng limiter 配置从未被读取：`develop/opencode.nix` 写在 `settings.yml` 的 `server.limiterSettings` 块内，已改为独立 `limiter.toml`（`[botdetection] trusted_proxies`），修复后 `missing config file` 警告归零、反代 HTTP 200
其余断言实测通过。

| 提交 | 说明 |
|------|------|
| `26e7a76` | fix(devshell): ruyi venv/extract 参数错误 + opencode searxng limiter 配置从未生效（四语） |

> **说明**：`26e7a76` **改动 `develop/opencode.nix`**（limiter 配置移到独立 `limiter.toml`），devShell 行为已变化；其余为纯文档修正；测试产生的 `dump.rdb` 与遗留后台进程已清理。

## 2026-09-18T13:51:14+09:00

**摘要**：fix(docs): 插件类 2 篇与模式类 3 篇文档验证 —— 插件全项相符、无需改动，模式修 1 处。

- `dsh-nixos-shell` 与 `dsh-api-balance`：npm 名与版本、`nixos_shell` 的 27 项工具白名单、`nixos_cli` 五个 op 与数值上限、sudo 协议 v3（`MAX_TIMEOUT_MS = 21600000`）、`skills-embedded/` 快照、`dsh-api-balance` 的 rev `c47f857` 与 4 个 config 项逐项相符
- NixOS模式「组合」行误称 persona 行设了 `complete: true`，实际只设 `prefix`，已四语改正
其余模式断言通过（`nixos-gate` 读取、NixOS模式技能 5 个、维护模式派生关系、新闻三要素模式各项）。

| 提交 | 说明 |
|------|------|
| `3d6340f` | fix(docs): NixOS模式组合描述误称 persona 设了 complete: true（四语） |

> **说明**：纯文档修正；插件类两篇无需改动（记录在案以备回归比对）。

## 2026-09-18T13:43:54+09:00

**摘要**：fix(docs): ruyi 文档 2 处修正（另 1 处顺带表述修正）。

- 测试数此前只写 beta 通道的值，改为按通道分列：`ruyi` 单元 368 / 集成 58、`ruyi-beta` 462 / 70、`ruyi-alpha` 346 / 57；并注明 `checkPhase` 中 ruff / mypy 为 `|| true`，真正把关的是 pytest
- zh 安装段把一行散文提示写进了 Nix 代码围栏，致代码块被截断（en/ja/pcn 无此问题）
- （顺带）`pyelftools` 由本包在共享 base 中无条件加入（无版本条件），并非「≥ 0.53.0 新增」

| 提交 | 说明 |
|------|------|
| `c30f2b6` | fix(docs): ruyi 测试数未区分通道 + zh 安装段代码块破损（四语） |

> **说明**：纯文档修正，`packages/`、`overlays/` 与 `modules/` 未改动。

## 2026-09-18T13:41:45+09:00

**摘要**：fix(docs): obs-bilibili-stream 的 Home Manager 用法会装上但不生效

- `home.packages` 只把 `.so` 放进 profile，而 OBS 经 `OBS_PLUGINS_PATH` 查找插件，该变量只由 nixpkgs 的 `wrapOBS` 注入
- 即只有 `programs.obs-studio.plugins` 这条路有效
- 四语补充警告与两条正确做法
- opencode-telegram 逐项核对全部相符，零改动
| 提交 | 说明 |
|------|------|
| `4bea784` | fix(docs): obs-bilibili-stream 的 Home Manager 用法会装上但不生效（四语） |

> **说明**：纯文档修正，`packages/` 与 `overlays/` 未改动；opencode-telegram 经核对无需改动（以备后续回归比对）。

## 2026-09-18T13:40:20+09:00

**摘要**：fix(docs): kitsfmt 与 mcp-searxng 各 2 处失实修正。

- `kitsfmt`：「注释保持」表述过宽 —— 0.5.0 实测只有节点上方的先行注释跟随排序；非末条属性的同行尾注移位到下一属性上方，末条同行尾注与文件头、文件尾均丢弃；另补漏掉的 `KITSFMT_STDIN=1`
- `mcp-searxng`：「开箱即用」示例含已废弃的 `real_ip.x_for = 1`（上游 `limiter.toml` 已无 `real_ip` 段），四语移除
- `mcp-searxng`：「缺少 `SEARXNG_URL` 时静默失败」与实测不符 —— 服务器正常启动、`tools/list` 正常返回，仅每次 `tools/call` 返回 `isError: true` 并在文本与 stderr 明确报错

| 提交 | 说明 |
|------|------|
| `0cb9f4f` | fix(docs): kitsfmt 注释保留表述过宽 + 补 KITSFMT_STDIN（四语） |
| `9f3c829` | fix(docs): mcp-searxng 两处失实（real_ip 已废弃、失败并非静默）（四语） |

> **说明**：均为纯文档修正，`packages/` 与 `overlays/` 未改动。

## 2026-09-18T13:32:32+09:00

**摘要**：fix(docs): dsh 与 godot-ai 文档验证 —— 修 3 处，另发现 1 处真实功能缺陷。

- `dsh`「可声明式配置的宿主 namespace」表只列 6 个、标注 0.1.2-alpha；该节讨论的 `0.1.5-rc.2` 实为 12 个（`installSection`），缺 `agent-default-model` 等 6 个
- `godot-ai` 命令启动即失败：attach 桥以 `sys.executable -m godot_ai` 再 spawn 后端，Nix 下它是裸 CPython，`site.addsitedir()` 的依赖不被子进程继承；已用 makeWrapper 前置 PYTHONPATH，实测可用
- `godot-ai` 文档另 2 处：工具数 43 → 46、WebSocket 端口 9876 → 9500

| 提交 | 说明 |
|------|------|
| `6b47f55` | fix(docs): dsh 设置 namespace 表不完整且版本标注过时（四语） |
| `a54bd9d` | fix(godot-ai): 修复 attach 后端无法启动 + 文档两处失实（四语） |

> **说明**：`a54bd9d` **改动 `packages/godot-ai.nix`**（新增 makeWrapper 与 postFixup），godot-ai 构建产物已变化；其余为纯文档修正。

## 2026-09-18T13:23:25+09:00

**摘要**：fix(docs): 26 条断言 + 子文档验证，共修 7 处失实描述

- 主文档 2 处：`inputs.nixkits.url = "~/NixKits"` 不可用 → `git+file:///path/to/NixKits`；「所有包默认跟随 `lib.platforms.linux`」失实，实为 `lib.platforms.all`
- blender-mcp 3 处：实际注册 26 个工具（文档称 22）；add-on 路径改为 `extensions/user/`（Blender Extension，4.x 加载不了）；升级流程 `chmod`→`rm -rf`→`cp`→`chmod`（原流程静默失败）
- codewhale 2 处：`--sandbox <tier>` 不存在，实为 `--sandbox-mode`；此前修好的参数名被重新写错，四语统一

| 提交 | 说明 |
|------|------|
| `82d8ed5` | fix(docs): 修正主文档两处失实描述（四语） |
| `ead55d1` | fix(docs): blender-mcp 三处失实描述（四语） |
| `6f40487` | fix(docs): codewhale 沙箱参数名回归错误 + 四语不一致（四语） |

> **说明**：纯文档修正，`packages/` 与 `overlays/` 未改动。

## 2026-09-18T13:09:18+09:00

**摘要**：refactor(ruyi)! — `ruyi-nixos-compat` 补丁并入 `packages/ruyi/ruyi.nix`，移除已失效的 overlay

- 原 overlay 修补 nixpkgs 的 `ruyi`，该包已消失，只有 `develop/ruyi.nix` 自套时生效 —— flake 包用户拿不到 NixOS 兼容处理
- 补丁现为三通道内置（`--replace-fail` 回填 `@nixLdSo@`/`@nixGlibcLib@`，注入 `ensure_toolchain_nixos_compat`）
- devShell / flake 包 / NixOS 模块同一构建
- 判据：三通道构建成功、`@nixLdSo@` 残留 0 次、`ruyi --version`/`--help` 正常、beta pytest 462 + 70 passed
| 提交 | 说明 |
|------|------|
| `87d3f7c` | refactor(ruyi)!: 补丁并入包定义，移除已失效的 ruyi-nixos-compat overlay |

> **说明**：破坏性变更——`nixkits.overlays.ruyi-nixos-compat` **不再存在**，外部若引用过该 overlay 需删除该行（补丁现已内置，无需任何 overlay 配置）。`packages/` 中 ruyi 三通道构建产物均已改变。

## 2026-09-18T12:41:08+09:00

**摘要**：例行更新检查 —— `blender-mcp` 1.0.3、`ruyi-beta` 0.53.0-beta.20260917、`dsh` 0.1.5-rc.2、`dsh-alpha` 0.1.6-alpha.2

- `ruyi-beta` 补 `pyelftools` 运行时依赖：上游 0.53.0 起列入运行时依赖，缺则 pytest 收集期中断
- `dsh-alpha` 上游新增 4 个插件包，`dsh-package-lock-alpha.json` 随之重新生成，只改 version 会报 `npmDepsHash is out of date`
- 四语文档同步
- `nix flake check` 通过
| 提交 | 说明 |
|------|------|
| `0e220fd` | chore(blender-mcp): 升级 1.0.0 → 1.0.3（四语文档同步） |
| `9b48078` | fix(ruyi): 升级 beta → 0.53.0-beta.20260917 并补 pyelftools 依赖 |
| `80104c4` | chore(dsh): stable 0.1.5-rc.2 + alpha 0.1.6-alpha.2（四语文档同步） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| blender-mcp | 1.0.0 | 1.0.3 |
| ruyi-beta | 0.52.0-beta.20260824 | 0.53.0-beta.20260917 |
| dsh | 0.1.5-rc.1 | 0.1.5-rc.2 |
| dsh-alpha | 0.1.6-alpha.1 | 0.1.6-alpha.2 |
| 　 | blender-mcp source hash | `sha256-nt+sHozi…` → `sha256-pYeByO4O…` |
| 　 | ruyi-beta source hash | `sha256-vxu9AhRD…` → `sha256-w8NlCER3…` |
| 　 | dsh source hash | `sha256-Gnlxnxx2…` → `sha256-9MVIOdae…` |
| 　 | dsh-alpha npmDepsHash | `sha256-qAlIccAJ…` → `sha256-p4uALt5v…` |

> **说明**：`ruyi.nix` 共享 base 新增 `pyelftools` 一行（三通道共用）；`dsh-package-lock-alpha.json` 经上游 alpha.2 的依赖集重新生成。其余包经比对上游已为最新，未改动。

## 2026-09-18T00:38:59+09:00

**摘要**：docs(security): 改写四语 `SECURITY.md` 的沙箱档位表述，消除扫描器 `RISKY_APPROVAL_DEFAULT`

- 触发词为 `danger-full-access`，本仓是在描述使用者可选的行为而非设置默认值，但扫描器无法区分；改后明确「默认不放开」
- 同时修正 `docs/zh/codewhale.md` 的 CLI 示例为 `--sandbox-mode`
- 判据：官方扫描器 94/100（A - Excellent）、Security 16/16、0 medium（88 → 94）
- 剩余 6 分来自 `Dependabot configured for automation surfaces`，本仓按「不引入外部自动化」边界不为提分破例
| 提交 | 说明 |
|------|------|
| `e386dfc` | docs(security): 改写沙箱档位表述，消除扫描器 RISKY_APPROVAL_DEFAULT（88 → 94） |

> **说明**：纯文档措辞修正，`packages/` 与 `overlays/` 未改动。
## 2026-09-17T18:15:40+09:00

**摘要**：通用技能重构为「主流程 + 两份配套参考」，并补回因分支隔离滞留的 Gitea 教训 — 评估驱动的整改：

- 已在 main 上补回实测分支写出的 70 行「自托管 forge（Gitea）取源」章节（该分支永不合并）：自托管实例可能对所有 tag 返回 403
- 适配层新增要求：测试分支上的通用教训当场手工写入 main
- 技能由 918 行单文件拆为主流程 `SKILL.md`（462 行）+ `builders.md`（254 行：按 builder 的 hash 流程）+ `traps.md`（271 行：漂移陷阱等），新增第 7 步「提交前六问自检」
- 依据：本会话 6 个包升级首次成功率 4/6，3 次返工均由此类陷阱造成
验证：拆分经 `##` 节、子节、逐行比对与行数四重核对，补回漏掉的 3 节；四语同步

| 提交 | 说明 |
|------|------|
| `e0b1a64` | refactor(skills)!: 通用技能拆分为主流程 + 两份配套参考，并补回丢失的 Gitea 教训 |

> **说明**：技能结构变更（新增 `builders.md` / `traps.md` 两个配套文件）；`packages/` 未改动。

## 2026-09-17T17:22:50+09:00

**摘要**：feat(ci): 新增 `check-doc-versions` 断言「文档版本 = 包定义版本」

- 针对本轮 5 处文档版本失配（godot-ai、codewhale、mcp-searxng、opencode-telegram、dsh-alpha）的结构性防御：这类失配不让任何构建失败，故成为 `nix flake check` 第 6 项
- 检查：`docs/<lang>/<pkg>.md` 的「版本」行（四语）与多通道包通道表（`dsh-alpha` / `ruyi-beta` / `ruyi-alpha`）须等于包定义；别处读出的版本同样跟踪（`kitsfmt` 读 `Cargo.toml`）；例外在 `EXEMPT` 登记，只校验机械可读部分
- 验证：注入本轮 5 类实际缺陷全部被捕获；`nix flake check` 真实路径确认失败；`AGENTS.md` 记录
| 提交 | 说明 |
|------|------|
| `072ab87` | feat(ci): 新增 check-doc-versions，把「文档版本 = 包定义版本」固化为断言 |

> **说明**：本次新增检查脚本 `develop/check-doc-versions.py` 并挂入 `flake.nix` 的 `checks`（检查数 5 → 6），`packages/` 与文档内容未改动。

## 2026-09-17T16:12:06+09:00

**摘要**：docs: 修正五个包的文档版本号（内容质量修复）

- 核对全部服务型包发现 5 处已升级而文档未跟：`codewhale` 0.9.12→0.9.13、`mcp-searxng` 2.2.0→2.3.0、`opencode-telegram` 0.25.1→0.25.2、`dsh-alpha` 0.1.5-alpha.2→0.1.6-alpha.1（文档 + README）、`codewhale-sudo` v0.9.12→**v0.9.0 起**
- 最后一项是判断而非替换：该 overlay 版本无关，拦截的是 v0.9.0 引入的 `prctl(PR_SET_NO_NEW_PRIVS)`
- README 原值既过时又与文档正文矛盾，故改为描述特性来源
- 验证：全量复核 10/10 一致；`nix flake check` 通过，四语同步
| 提交 | 说明 |
|------|------|
| `0a0d8ce` | docs: 修正五个包的文档版本号（内容质量修复） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale（文档） | 0.9.12 | 0.9.13 |
| mcp-searxng（文档） | 2.2.0 | 2.3.0 |
| opencode-telegram（文档） | 0.25.1 | 0.25.2 |
| dsh-alpha（文档 + README） | 0.1.5-alpha.2 | 0.1.6-alpha.1 |
| codewhale-sudo（README 表述） | 「v0.9.12 的 sudo 功能」 | 「v0.9.0 起被阻止的 sudo 功能」 |

> **说明**：本次为纯文档修正，`packages/` 与 `overlays/` 未改动。

## 2026-09-17T15:56:56+09:00

**摘要**：docs(godot-ai): 修正四语文档的版本号与依赖表，并新增「文档须重写而非机械替换」判据

- main 上 godot-ai 代码已于 `2a06bbf` 升到 4.1.0 且功能完整（实测 `godot-ai --version` → 4.1.0），但文档未同步：版本号仍写 `3.2.5`
- 依赖表列 6 项且全为「≥ 范围」，实际是 9 项 fail-closed 精确锁
- 后一项危害更大：v4 启动时会校验这 9 个包的精确版本，不匹配即拒绝启动
- 修正为「版本 + 来源」两列、9 项逐一列出，并补充 pydantic-core 的连带要求（`==2.46.5`）
- 验证：9 个版本号用 `nix eval` 从含 overlay 的闭包量出，逐条比对 9/9 一致
- 技能触发判据：依赖变精确锁或新增启动期硬校验时须重写文档
| 提交 | 说明 |
|------|------|
| `085c093` | docs(godot-ai): 修正四语文档的版本号与依赖表（内容质量修复） |
| `55674f2` | feat(skills): 通用技能第 5 步新增「文档须重写而非机械替换」的触发判据 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| godot-ai（文档） | 文档标 3.2.5 / 依赖表 6 项「≥ 范围」 | 标 4.1.0 / 依赖表 9 项精确锁 |

> **说明**：本次为文档修正，`packages/godot-ai.nix` 未改动（其代码在 `2a06bbf` 已正确）。

## 2026-09-17T13:00:09+09:00

**摘要**：feat(skills): 适配层新增第 10 步「流程复盘与规范校验」

- 更新流程完成后执行；审计的不是软件，而是决定软件如何被更新的规范本身（技能 / `AGENTS.md` / `SECURITY.md` / develop 脚本）
- 六步：复盘、校验、归属、体验、证据纪律、产出
- 证据纪律是硬约束：规范改动须可复现、可追溯、允许质疑 —— 禁止凭印象改、把一次偶发当规律、为已写对的内容再优化、删仍有效的条目
- 首次执行发现真实缺陷（均不产生构建错误）：`SECURITY.md` 指向子仓 `SECURITY.md` 的死链（该文件未建），四语改为「该子项目尚未自建安全政策」；12 处 `asusctl` 链接随迁移改为 `OpenGamingCollective/asusctl`
- 链接审计方法入通用技能：`curl` 的 404 须经 `gh api` 复核
| 提交 | 说明 |
|------|------|
| `442e5d1` | feat(skills): 适配层新增第 10 步「流程复盘与规范校验」 |

## 2026-09-17T12:52:54+09:00

**摘要**：fix(codewhale): 补齐 x86_64/aarch64 预编译变体至 0.9.13

- 上一轮只升级 riscv64 源构建变体 `codewhale-src`，漏掉 `codewhale.nix`（x86_64/aarch64 走 GitHub Releases 预编译路径，`flake.nix` 按 `hostPlatform.isRiscV` 分流）
- 本仓 codewhale 两个同名同输出变体：`codewhale.nix` 改 `version` + cli/tui × x64/arm64 **四个 hash**，`codewhale-src.nix` 改 `version` + `hash` 并同步 `Cargo.lock` —— 升级必须两个都改
- 陷阱已入适配层
- 判据：**部署后按架构核对各变体实际版本，不能只看构建通过**
| 提交 | 说明 |
|------|------|
| `ecb28c4` | fix(codewhale): 同步升级 x86_64/aarch64 的预编译二进制变体至 0.9.13 |
| `f8c8265` | docs(skills): 记录 codewhale 双变体陷阱（四语） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale（x86_64/aarch64 预编译） | 0.9.12 | 0.9.13 |
| 　 | cli/tui hash x64 | `nQt02NO/` → `WTriVnVv` |
| 　 | cli/tui hash arm64 | `Gkje9AMu` → `BgUnHSo0` |

## 2026-09-17T12:41:29+09:00

**摘要**：五个软件包升级 + 更新技能追加「交互式澄清」

- 生产实战执行全部批准升级：`mcp-searxng` 2.3.0、`opencode-telegram` 0.25.2、`codewhale` 0.9.13（同步 `Cargo.lock`）、`dsh-alpha` 0.1.6-alpha.1（lock 须含 `"peer": true`）、`godot-ai` 3.2.5 → 4.1.0（跨大版本，fail-closed 运行时依赖校验）
- nixpkgs 落后 5 个包，故新增 `overlays/godot-ai-v4-deps.nix` 并与 `fastmcp` overlay 链式叠加；overlay 链（`flake.nix`、`overlays/default.nix`）须同步
- 技能新增「交互式澄清」章节与陷阱 5/6
- 验证：五包构建通过且实跑确认
| 提交 | 说明 |
|------|------|
| `2a06bbf` | chore(pkgs): 升级 mcp-searxng 2.3.0、opencode-telegram 0.25.2、codewhale 0.9.13、dsh-alpha 0.1.6-alpha.1、godot-ai 4.1.0 |
| `c7de9b6` | feat(skills): 更新技能追加交互式澄清，并计入本轮实战教训 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | 2.2.0 | 2.3.0 |
| opencode-telegram | 0.25.1 | 0.25.2 |
| codewhale | 0.9.12 | 0.9.13 |
| dsh-alpha | 0.1.5-alpha.2 | 0.1.6-alpha.1 |
| godot-ai | 3.2.5 | 4.1.0 |
| 　 | git hash | `+0FJ+Grod` → `wNM/QNtF` |
| 　 | npmDepsHash (mcp-searxng) | `WK28hNI3` → `MqVn66vC` |
| 　 | npmDepsHash (opencode-telegram) | `Ai1hgKiv` → `NnvFOrS7` |
| 　 | Cargo.lock (codewhale) | 7073 行 → 7347 行 |
| 　 | npmDepsHash (dsh-alpha) | `SVYhLVZw` → `qAlIccAJ` |
| 　 | 新增 overlay | `overlays/godot-ai-v4-deps.nix` |

## 2026-09-17T11:34:39+09:00

**摘要**：fix(skills): 子仓跟进判据细化到字段级

- 原判据按「文件是否变化」分流，而清单文件仅部分字段是构建输入
- 子仓 `dsh-api-balance` 的 `package.json` 变了字节（移除 `publishConfig.access`），而 `dependencies`、`files`、`version`、`main`/`exports` 均未动，按原判据会为纯元数据改动触发全架构重建
- 修正为**字段级**：发布元数据（`publishConfig` 等）、文档、CI 配置**不跟进**；`dependencies` 系列 / `files` / `main` / `exports` / `scripts` / `version` / 源码**必须跟进**；无法判断时按跟进处理
- 适配层描述同步修正
| 提交 | 说明 |
|------|------|
| `c08f5c9` | fix(skills): 子仓跟进判据细化到字段级 |
| `641830a` | docs(skills): 同步四语的子仓跟进字段级判据 |

## 2026-09-17T11:31:32+09:00

**摘要**：feat(skills): 同账户子项目链式检查与跨仓维护条目链接

- 仓库引用的同账户子项目（典型为薄封装）纳入更新检查，前提成立时链式并行，结果视为主仓结果但分别计入两仓日志，主仓条目链接到子仓条目
- 归属：`nix-flake-update-check` 新增第 9 步（引用发现三形态、四项前提校验、回环与深度上限、失败隔离），`write-maintenance-log` 新增类型 5
- `write-project-docs` 要求显式记录子仓引用关系，适配层只承载本仓专有事实
- dry run 修正三处缺陷：检测命令缺 `-h` 致 `awk` 字段错位而静默返回空；依赖冲突判据改为「子仓要求是否高于宿主提供」；GitHub 锚点规则实为逐字符替换为 `-`
- 主仓钉住的 `dsh-api-balance` rev 落后两个文档提交，按新判据不重钉
| 提交 | 说明 |
|------|------|
| `b7e9717` | feat(skills): 支持同账户子项目链式检查与跨仓维护条目链接 |

## 2026-09-17T11:21:34+09:00

**摘要**：chore(security): 完全移除 `dependabot.yml` 并确立「不引入外部自动化」安全边界

- Dependabot 即便不可执行、只开 PR、拿不到 secrets，仍是 GitHub 运行、行为不由我们掌控的**外部自动化集成**，与本仓「开发维护由维护者与小爪完成」的边界冲突，故整份删除
- `AGENTS.md` 新增该章节：拒绝清单（第三方 CI 扫描器、Dependabot）、判据（先用仓库内 `gh`/`git`/`nix` 自行实现，否则人工）、代价（action 安全更新须主动跑技能检查）
- 能力不丢：`nix-flake-update-check` 新增「检查 GitHub Actions 的更新」章节（列固定 action → 查 tag → 回写 SHA），原「自动 PR 不能直接合并」小节改为通用指引
- 四语文档同步
| 提交 | 说明 |
|------|------|
| `3421c1f` | chore(security): 移除 dependabot.yml 并确立「不引入外部自动化」安全边界 |

## 2026-09-17T11:03:51+09:00

**摘要**：chore(ci): Dependabot 移除 npm 生态，仅保留 `github-actions`

- npm 生态对本仓**结构性无效**：npm 包由 `buildNpmPackage` 包装，`npmDepsHash` 会被主构建与 npm-deps 产物逐字节校验，而 Dependabot 只改 `package.json`/`package-lock.json`、无法感知 `.nix` 里的该 hash，故其开出的每个 npm 更新 PR 必然 CI 失败（`npmDepsHash is out of date`）
- npm 依赖升级改由 `nix-flake-update-check` 技能人工处理
- 移除理由以注释完整记在配置内，避免日后误当遗漏加回
- `github-actions` 保留 —— PR #6 证明其有效且正确维持 SHA 固定
| 提交 | 说明 |
|------|------|
| `4b997b3` | chore(ci): Dependabot 移除 npm 生态，仅保留 github-actions |

## 2026-09-17T10:55:02+09:00

**摘要**：chore(dsh-nixos-shell): `dsh-tools` 0.1.2-alpha.2 → 0.1.5-rc.2；ci: `actions/checkout` v4 → v7.0.1

- 两者均由前一轮 `dependabot.yml` 自动生成
- PR #6 已合并（SHA 固定保留正确）
- PR #7 改为手动升级：Dependabot 感知不到 `npmDepsHash`，CI 必报 `npmDepsHash is out of date`，改升 0.1.5-rc.2 使内嵌副本与宿主 dsh 对齐并更新该 hash
- 验证：构建通过、产物内版本与宿主一致、`nix flake check` 全通过
- 处置写入 `nix-flake-update-check` 技能
| 提交 | 说明 |
|------|------|
| `dce26f2` | chore(dsh-nixos-shell): dsh-tools 0.1.2-alpha.2 → 0.1.5-rc.2 |
| `5f4e9ec` | ci: bump actions/checkout from 4.4.0 to 7.0.1 (#6) |
| `7b94d7c` | refactor(skill): nix-flake-update-check 补充 Dependabot 自动 PR 的处置 |

## 2026-09-17T01:40:58+09:00

**摘要**：docs(security): `SECURITY.md` 明确「重复提交」的处理界限（四语）

- 新增小节使其具备约束力：上表已列出的同一结论、若无新证据再次提交，将直接关闭并指向本节
- 划清受理与关闭的界限以免误伤正当报告 —— 受理：上表未涵盖的新问题、指出上表某条结论有误（附可复现证据）、同一主题但威胁模型或利用路径不同；直接关闭：仅重述已有结论、同一规则的再次自动扫描输出
- 并保留「指出结论有误始终欢迎」
- 上表四条本身亦是经复核的判断，判据若错则应改正
| 提交 | 说明 |
|------|------|
| `94bd95c` | docs(security): 明确重复提交的处理界限（四语） |

## 2026-09-17T01:34:13+09:00

**摘要**：docs(security): `SECURITY.md` 新增「已评估的外部报告」节，含 `docs/SECURITY.{en,ja,pcn}.md` — 公开 4 条已复核关闭的报告。

- PR #4（`/token`、`/voicepack`、`/tts` 缺限流）与 PR #5（`/query` 缺请求体上限）均属误报：描述与 diff 不符、`readJsonBody` 已有 64 KiB 上限。
- issue #1/#2（`secrets: inherit` 违反最小权限）亦属误报：全仓仅 2 个 secret，显式传递与 `inherit` 等价。
- 报告促成两次真实加固：`/tts` 端点 SSRF、31 个构建 workflow 最小权限补全。
- 立场：规则多属实，但威胁模型不适用本项目部署形态；误报不算打扰。

| 提交 | 说明 |
|------|------|
| `6f34e73` | docs(security): SECURITY.md 记录已评估的外部报告，并纳入四语本地化 |

## 2026-09-17T01:23:46+09:00

**摘要**：chore(security): 补 `SECURITY.md`、Dependabot，Actions 固定到 SHA — 起因 awesome-ai-plugins 维护者（@kantorcodes）PR #323 整改要求：扫描 71/100，低于 80 阈值。

- 评分表：零 critical 零 high，扣分全在工程卫生（Actions 未固定 SHA、缺 Dependabot）。
- 新增 `SECURITY.md`（支持版本、报告渠道、响应时限）与 `.github/dependabot.yml`。
- 6 处第三方 action 由浮动引用固定到 SHA，含浮动分支的 `DeterminateSystems/nix-installer-action@main`。
- 未采纳第三方 scanner action（代价 10% 信任分，已接受）。

| 提交 | 说明 |
|------|------|
| `97a4180` | chore(security): 补 SECURITY.md、Dependabot，并将 Actions 固定到 SHA |

## 2026-09-16T16:45:03+09:00

**摘要**：fix(dsh-nixos-shell): 修复 `skills-nixos` 的路径断裂

- `559e841` 引入，本机部署后才显形
- 该提交把技能根写成 `../../skills-nixos/`（相对预设目录），而种子的 `cp -r presets/<mode> $DSH_HOME/.agent-presets/<id>` 不复制预设目录外的内容，seed 后该根解析为不存在的 `~/.dsh/skills-nixos`，新增 3 个 NixOS 技能加载不到
- 修复：`postPatch` 把白名单子集生成到各预设目录内，`customSkillDirs` 根改为 `skills-nixos/`
- 验证：模拟 seed 后可达、`nix flake check` 全通过、部署后新会话列出这 3 个技能
- 教训：预设经种子复制，验证须在种子后
| 提交 | 说明 |
|------|------|
| `96b589c` | fix(dsh-nixos-shell): skills-nixos 移入预设目录，修复 seed 后路径断裂 |

## 2026-09-16T14:54:53+09:00

**摘要**：refactor(dsh-api-balance)!: 迁出为独立仓库，本仓改薄封装 — 首次组件拆分。

- 审计判据：唯一平台无关项目、与 NixKits 零代码耦合、有 npm 打包需求。
- 新仓库 `Kihara777/dsh-api-balance`：源码、四语文档、npm 发布 CI；已实测 `dsh plugin add` 一行装成，web profile `exit=0`。
- 本仓侧：删除 `packages/dsh-api-balance/`，`.nix` 改为 `fetchFromGitHub` 薄封装（`npmDepsHash` 未变）；文档压为短页、README 标注迁出；CI workflow 保留以继续命中 Cachix 缓存。
- 更新 `write-project-docs`：「主仓薄封装 + 子仓完整文档」架构。

| 提交 | 说明 |
|------|------|
| `0bb7fc1` | refactor(dsh-api-balance)!: 迁出为独立仓库，本仓改为薄封装 |
| `0760612` | feat(skill): write-project-docs 支持「主仓薄封装 + 子仓完整文档」架构 |

**待办**：npm 发布尚未执行——本机无 npm 凭据（未登录、无 token、`@kihara777` scope 不存在），需先在 npmjs.com 注册账号并创建 scope；包本身已 publish-ready（`npm pack` 确认 70.8 kB / 4 文件）。

## 2026-09-16T14:27:33+09:00

**摘要**：refactor(skills): 泛化 `/etc/nixos/AGENTS.md` 实践的两个未覆盖缺口

- 审计该文件（HarukaX 本机配置规则），约 75% 已被现有技能覆盖
- 密钥与 `path:` input（`nixos-modern-cli` 新增）—— 密钥须放仓库外经 `path:` 引入，该 input 受 `flake.lock` 锁定，改内容需 `--update-input`
- 热管理方法论（`nixos-specialisation-tuning` 新增）—— 抬高曲线只增噪音、降档损失速度，`enabled: false` 致档位与曲线脱节
- `asusctl` 写入临时、验证须重启守护进程；温和/激进曲线温度转速相同即风扇饱和、唯一手段降功耗
- 机器特定内容留在 `/etc/nixos/AGENTS.md`，四语文档同步更新
| 提交 | 说明 |
|------|------|
| `a33a3cf` | refactor(skills): 泛化 /etc/nixos 实践的两个未覆盖缺口 |
| `fba7b38` | docs(skills): 同步两技能扩展后的功能清单（四语） |

## 2026-09-16T14:11:18+09:00

**摘要**：feat(dsh-nixos-shell): NixOS模式 同捆 3 个 NixOS 运维技能

- 评审仓库 `skills/` 树的结论：**加入** `nixos-modern-cli`、`recover-nixos-config`、`nixos-specialisation-tuning`；**不加** `nixkits-skills`（技能安装器）与 `news-three-elements`（创作类，已有独立包）
- 维护模式为派生，自动继承这 3 个
- **实现**：不复制进 `presets/<mode>/skills/`（两预设间逐字节镜像，再放一份会成第二副本而漂移），改为 `postPatch` 按白名单从仓库树生成构建期子集 `skills-nixos/`，供 `skill-filesystem` 以 `../../skills-nixos/` 挂载
| 提交 | 说明 |
|------|------|
| `559e841` | feat(dsh-nixos-shell): NixOS模式 同捆 3 个 NixOS 运维技能 |
| `7971689` | docs(dsh-nixos-shell): 记录 NixOS模式 新增的 3 个同捆技能（四语） |

## 2026-09-16T13:57:56+09:00

**摘要**：feat(dsh-api-balance): 新增 `dsh.bundle`，支持 `dsh plugin add` 原生安装

- 两插件性质不同：`dsh-api-balance` 是平台无关的界面增强（仅 `inject = ["connection", "webServer"]`，无预设、无技能、不写 `$DSH_HOME`），`dsh-nixos-shell` 的核心价值则是 Agent 预设
- **关键发现（推翻此前结论）**：entry 名以 `./` 开头会被锚定为该 patch 所在目录下的绝对 `file://` URL
- 据此新增 `cordis.patch.yml` 以 `name: './lib/index.js'` 注册插件（裸包名会报错），`package.json` 加 `dsh.bundle.patch`
| 提交 | 说明 |
|------|------|
| `ac3cb3e` | feat(dsh-api-balance): 支持 dsh.bundle，可经 dsh plugin add 安装 |
| `bee12d7` | docs(dsh-api-balance): 补充两种安装方式与 bundle 机制说明（四语） |

**相关外部报告**：issue #3（@zerocodefast）——awesome-ai-plugins 收录邀请；`dsh-api-balance` 现具备投 DeepSeek Harness 节的技术条件，`dsh-nixos-shell` 仍保持声明式（其理由已记录于 `d14146c` 条目）。

## 2026-09-16T13:44:09+09:00

**摘要**：refactor(dsh-plugins): 移除两个插件未使用的 `peerDependencies`

- 实测发现两者 peer 声明与实际 import 不符：`dsh-nixos-shell` 声明 `cordis` / `dsh-subprocess` / `dsh-timer`，`dsh-api-balance` 声明 `cordis` / `dsh-client-connection`，实际只 import 各自的真实依赖（`dsh-tools` + `schemastery` / `dsh-credentials`），且 `dsh-timer` 在 npm 与宿主树中都不存在
- 死声明在声明式路径下从不生效，不影响现有部署，但 pnpm 路径下会阻断安装
- lock 与 `npmDepsHash` 同步重生成
| 提交 | 说明 |
|------|------|
| `d14146c` | refactor(dsh-plugins): 移除未使用的 peerDependencies |

**相关外部报告**：issue #3（@zerocodefast）——awesome-ai-plugins 收录邀请，保持 open 未提交 PR。

## 2026-09-16T12:39:12+09:00

**摘要**：refactor(skills)!: 拆分 `nixkits-check-updates` 为「通用核心 + 仓库适配层」

- 起因是评估 issue #3 时审查被推荐技能的移植性：原技能与 NixKits 强耦合，第 5 步硬编码 `for lang in zh en ja pcn` 与 `docs/$lang/<pkg>.md` 路径，第 8 步强制调用 `write-maintenance-log`，别的仓库会失败
- 新增 `nix-flake-update-check`（314 行，不绑定仓库）承载包发现、包型分流 hash 流程、flake.lock 三路处置、补丁内版本检查与 nixpkgs 漂移陷阱
- `nixkits-check-updates` 瘦身为适配层；适配层契约：文档同步 / 变更记录 / 动态输入 / 事故教训 / 额外同步项由其声明
| 提交 | 说明 |
|------|------|
| `667bf6e` | refactor(skills)!: 拆分更新检查为通用核心 + NixKits 适配层 |
| `93fe67e` | feat(dsh-nixos-shell): 维护模式注入 nix-flake-update-check 技能 |
| `6af37e7` | docs: 同步技能拆分——四语新增通用技能文档、README 技能表与注入清单 |

**相关外部报告**：issue #3（@zerocodefast）——awesome-ai-plugins 收录邀请。经评估，其推荐语把 NixKits 定位为「包含中文技能的包合集」而未提及它同时是 Nix 包/模块/补丁合集，且「Chinese-language skills」易被误读为仅对中文用户有用；收录本身与技术无关，故保持 open，未提交 PR。

## 2026-09-16T12:20:57+09:00

**摘要**：ci: 为 31 个 `build-*.yml` 调用方补全顶层 `permissions: contents: read`

- 它们均未声明 `permissions`，会继承仓库默认（可能可写），实际只做 checkout + `nix build` + 推送 Cachix，故与被调方 `build-package.yml:17-18` 对齐
- 起因是外部贡献者 **@begininvoke** 的 RedGem 扫描报告（issue #1、#2）：两条经核验均为误报（可复用 workflow 同仓库同 commit、仅 2 个 secret，`inherit` 与显式传递集合相同），不予采纳并附证据关闭，但促成了这次权限边界复核
- 31 处 `secrets: inherit` 保留不改：Cachix 用独立 `CACHIX_AUTH_TOKEN`，无可削减余量
| 提交 | 说明 |
|------|------|
| `445eb4b` | ci: 为 31 个构建 workflow 补全顶层 permissions（最小权限） |

**相关外部报告**：issue #1、#2（@begininvoke / RedGem）——内容逐字节重复，经核验为误报，已附详细技术证据评论后以 not planned 关闭；其线索价值已致谢。

## 2026-09-16T11:58:25+09:00

**摘要**：fix(dsh-api-balance): 修复自定义 TTS 代理的 SSRF 与请求头注入面

- 该代理接受任意 `http(s)` URL 并以 host 身份发起请求，可作内网探测与云元数据（`169.254.169.254`）读取的跳板；并将用户可控的 `headers` 原样转发，攻击者可补 `host` / `cookie` / `authorization` 头
- 修复：新增 `resolveTtsTarget` 与 `isBlockedAddress`，拒绝回环 / 私有 / 链路本地 / 保留地址（覆盖 RFC1918、CGNAT、IPv4-mapped IPv6）
- 自定义请求头改白名单（仅 `content-type` / `accept` / `accept-language` / `user-agent`）
- 四语文档同步补防护说明
| 提交 | 说明 |
|------|------|
| `e1a6e66` | fix(dsh-api-balance): 修复 TTS 代理的 SSRF 与请求头注入面（含四语文档同步） |
| `72cb6ae` | fix(docs): pcn 维护条目去除残留假名（のみ → 限定） |

**相关外部报告**：PR #4、#5（@anupamme / OrbisAI Security）——经核验为误报，已附详细技术证据评论后关闭；其线索价值已致谢。

## 2026-09-16T11:38:20+09:00

**摘要**：docs(deprecated): `DEPRECATED.md` 索引化并四语本地化

- 原先一份中文文档兼「索引」与「单个项目的完整说明」两职，项目一多便看不全，也无本地化位置
- 现根 `DEPRECATED.md` 退化为纯索引（列表 + 指向详情的链接），仿 `README`/`MAINTENANCE` 出三份镜像 `docs/DEPRECATED.{en,ja,pcn}.md`
- 各废弃项目详情移入 `docs/<lang>/deprecated/<name>.md`（四语各一份，顶部带语言切换器与返回索引的链接），首批迁移 comfyui-rocm
- 四语 `README` 新增「废弃项目」章节，`docs/<lang>/comfyui.md` 改指详情页
- 验证：`nix flake check` 抓出并修正 6 条死链
| 提交 | 说明 |
|------|------|
| `8ff91eb` | docs(deprecated): 索引化 + 四语本地化，详情拆到独立文档 |

## 2026-09-16T11:05:32+09:00

**摘要**：refactor(comfyui)!: 退役 comfyui-rocm 补丁工程，模块改名 `nixkits.comfyui`

- 上游 ROCm 支持已能良好支持 StrixHalo，补丁使命完成
- 移除三补丁 `strix-halo` / `nixpkgs-compat` / `stdenv-api`，`modules/comfyui-rocm.nix`→`modules/comfyui.nix`，选项 `nixkits.comfyui-rocm`→`nixkits.comfyui`，四语文档 `comfyui-rocm.md`→`comfyui.md`，新增 `DEPRECATED.md`
- 判据：上游 `stdenv` 弃用读法 0 处、`rocm71` torch 2.10.0 与 `strix-halo` 补丁逐字节一致、已支持 `gpuSupport = "rocm"`
| 提交 | 说明 |
|------|------|
| `5015bcc` | refactor(comfyui)!: retire the comfyui-rocm patch project, rename module |

## 2026-09-16T01:45:07+09:00

**摘要**：docs: 预设包更新要 `daemon-reload` 再 `restart dsh`

- `nixos apply` 按设计不重启 dsh（稳定挂载点），而单跑 `systemctl restart dsh` 仍会执行上一代的 pre-start 脚本——它才是把 `cordis.patch.yml` 拷进 `$DSH_HOME` 的那一步，预设根就写在该文件里，症状是服务确已重启、会话仍载旧预设
- gen 570 部署时第一次 restart 仍是旧路径，加 `systemctl daemon-reload` 再 restart 才翻新
- AGENTS.md「本机部署」补上次序与核对方法，`docs/{zh,en,ja,pcn}/dsh.md` 同步改写
| 提交 | 说明 |
|------|------|
| `a167aae` | docs: 预设包更新要 daemon-reload 再 restart dsh |

## 2026-09-15T23:47:01+09:00

**摘要**：feat(preset+skill): 取材门 `news-material`

- 实际会话暴露「共创时生搬硬套」：素材换个格式直接发出、检索常被跳过；提示词规则会漂，故把它做成运行时可核对的门
- 新插件 `plugins/news-material.js` 挂两个钩子：`agent/pre-step` 随受理人力消息注入「取材铁律」；`agent/turn-stopping` 读本回合日志，整个回合没有一次 `web_search` / `web_fetch`，或正文照抄用户原文（连续 8 汉字命中即算），就 `agent.steer()` 退稿，`dsh-agent-loop` 在同一回合再走一步重写；每回合只退一次
- 技能侧同步三步改造表与 8 字红线、检索记录升为硬性要求、`checklist.md` 自查 3 → 7 项，persona 改写
- 新增 31 条断言
| 提交 | 说明 |
|------|------|
| `a0759b1` | feat(skill): 素材只是导火索——三步改造、禁照抄、必检索 |
| `cc9d0d1` | feat(preset): 取材门 news-material——无检索即退稿，照抄即退稿 |
| `71f25db` | docs: 四语同步素材共创铁律与取材门 |
| `a2ccd55` | docs(agents): 新增文件先 git add 再跑 flake check |

## 2026-09-15T12:36:10+09:00

**摘要**：feat(skill+preset): 「新闻三要素」改指三位主角，拒绝服务改判「先当素材」

- 维护者四条修正：本模式的「新闻三要素」指**三位必须到场的主角**——巴兰尼科夫、尤丁采夫、布亚诺夫，不是新闻学那三样；能靠检索补全的素材一律不得拒绝；共创的稿子必须带齐三人；假设性疑问与不指名的说法先评估能否落到三人身上
- 技能侧 `SKILL.md` 定死新含义，「格式硬性要求」新增第 0 条（三人全部出现在正文，缺一即返工），取材扩为四类
- 「拒绝服务」改写为硬性顺序：能当素材的一律不得拒绝 / 假设性疑问按「已经发生」处理 / 不指名先试着拟合 / 都接不回来才拒
- 预设侧 persona 新增「素材优先」一节与共创三人规则，`readonly-gate` 仪式句补三人括注
- 新增 14 条断言，四语文档同步；`nix flake check` 6 项全过
| 提交 | 说明 |
|------|------|
| `8f5b848` | feat(skill): 新闻三要素改指三位主角，拒绝服务先当素材 |
| `1adb6be` | feat(preset): 模式提示词改为素材优先，快讯须三人到齐 |
| `4732835` | docs: 四语同步新闻三要素的三人定义与素材优先判定 |

## 2026-09-15T11:47:48+09:00

**摘要**：fix(preset): 只读范围放行「自身技能包」

- 上一轮把读取收紧到「工作区 / 附件目录 / `/tmp`」时，**把模式自己的技能包也关在门外**：`tables.md`、`checklist.md` 位于抓取缓存 `$DSH_HOME/.cache/news-three-elements/` 或包内兜底快照，两者都不在允许根里，模型读不到配套文件，过渡词与结尾反转模板因此全部缺席
- 修法：把**抓取缓存目录**与**预设根**（含 `bundled/` 兜底快照）一并列入可读根，拒绝文本改为「…、`/tmp` 与自身技能包目录」
- 新增 2 条断言（缓存与内置快照均可读、越界仍拒），四语文档同步
| 提交 | 说明 |
|------|------|
| `ee072d5` | fix(preset): keep the mode's own skill package inside the read scope |

## 2026-09-15T11:38:02+09:00

**摘要**：fix(preset): 仪式句改称「催逝快讯」

- 每次拒绝收尾那句原写作「只编造带齐新闻三要素（新、事实、报道）的俄式快讯」，其中「（新、事实、报道）」是新闻学教材里的原意，念出来像在引用定义，把包袱压平了
- 改为「只编造带齐新闻三要素的**催逝快讯**」，与开场三选一里既有的「催逝员」用词对齐
- persona 与 `readonly-gate` 的拒绝文本各一处（共两处，均为固定提示词）
- 技能与文档中「产物」类定义性描述未动
- 新增 4 条断言：两处都出现「带齐新闻三要素的催逝快讯」，且旧的原意括注不得回归
| 提交 | 说明 |
|------|------|
| `bfb0ed4` | fix(preset): say 催逝快讯 in the ritual line, not the academic gloss |

## 2026-09-15T11:24:49+09:00

**摘要**：fix(preset): 语言审查只审人写的消息

- 用户新开会话里一条合法的简体中文请求被回绝，且附了英文译文
- 会话记录（`session-efc87486`）显示该 step 除用户的中文消息外，还混有 harness 注入的**英文系统消息**（`source.kind = plugin`，批准策略变更通知）与 `skill-catalog`
- 守卫原先审「本步准入的**全部**消息」，把英文系统提示读成「用户未用简体中文」，遂注入语言审查，模型按「与对方语言一致」回绝并补了英文译文
- 修法：`withNotice` 仅取 `source.kind === "user"` 的消息判定（批准提示、技能目录、工具结果一律不计）
- 并补两条回归测试（英文批准提示 + 中文请求不再触发；无人类消息的 step 不动）
- 四语文档同步该边界
| 提交 | 说明 |
|------|------|
| `9557707` | fix(preset): judge only the human's messages in the language gate |

## 2026-09-15T11:08:06+09:00

**摘要**：feat(preset)+test: 仓库自检体系与模式行为加固

- `nix flake check` 由 1 项扩到 **6 项**：新增 `preset-bundle`（技能快照与 `skills/` 逐字节一致）、`workflow-coverage`（每包都有 workflow）、`doc-links`（链接 + 四语切换器 + pcn 无假名）、`maintenance-log`（条目数、时间戳、SHA 去重）、`news-mode-tests`（**无网络**：fetch 打桩、二次 304）
- 上线当天即抓出并修复 12 个翻译文档的切换器、3 处 codewhale 链接、1 条 `+00:00` 时间戳、`dsh-api-balance` 缺 workflow
- 同轮四项加固：只读限范围、抽取不连续重复、先开口即撤回弹窗、技能抓取并行 + ETag 请求
| 提交 | 说明 |
|------|------|
| `9260dd5` | test: guard the repo with six flake checks and an in-repo test suite |
| `ac4b05c` | feat(preset): scope reads, harden the draw, and make the fetch incremental |
| `0af079c` | docs(preset): record the scoped reads, incremental fetch and hardened draw |
| `9810af5` | fix(docs): repair the switchers and dead links the new check found |

## 2026-09-15T10:57:15+09:00

**摘要**：feat(skill): 技能新增「拒绝服务」一节

- 拒绝流程从「只存在于某个预设的人格」升格为**技能本体**
- `SKILL.md` 新增「拒绝服务」章：不属于编造/素材改写的请求一律按本节拒绝；**每次动笔前先联网取当天素材**；理由、句式、段落顺序、结尾反转、过渡词都不得与上一次重复；三到五句通讯社文风；底色「一本正经胡说八道」；拒绝即止
- [`tables.md`](skills/news-three-elements/tables.md) 顶部标明模板只是骨架、素材必须当次取
- [`checklist.md`](skills/news-three-elements/checklist.md) 增补「拒绝服务自查」5 项
- 四语技能文档与各 README 技能行同步
- 预设包内兜底快照重生成、人格两处改为按名引用该节
| 提交 | 说明 |
|------|------|
| `f120a3d` | feat(skill): give the skill a refusal service of its own |
| `8c28f03` | chore(preset): sync the bundled skill snapshot and point the persona at the section |

## 2026-09-15T10:50:26+09:00

**摘要**：feat(preset): 译文限定在语言审查、且与对方语种一致

- 本地化版本只属于「非简体中文」这条规则的拒绝：简体中文用户的其它请求被拒时**只给中文正文**，不附译文、不附注（语言本身合法，没有可译之物）
- 译文还必须**与对方实际使用的那一种语言一致**（写英文译英文、写日文译日文、写繁体中文译繁体中文），不得换成第三语言、不得中英混排
- 两条都从「没写、靠模型自觉」升格为人格与注入指令中的显式规则（人格另在「其它一切请求」节明写「本节不翻译」）
- 四语文档同步；自测新增 6 项断言
| 提交 | 说明 |
|------|------|
| `00a0088` | feat(preset): scope the refusal translation to the language gate |

## 2026-09-15T10:39:08+09:00

**摘要**：feat(preset): 抽「人」而非抽游戏 + 每次拒绝现搜素材

- 推荐池由三款游戏改为**三位制作人**：抽到谁，游戏随谁（尤丁采夫、巴兰尼科夫 →《战争雷霆》；布亚诺夫 →《逃离塔科夫》），加「绿色的猫头鹰」共四者等概率、一次只推一样，《从军》移除
- 拒绝辞不再有单一重复理由：人格与注入指令都要求**每次拒绝动笔前先用 `web_search` 取当天素材**（真实新闻措辞、官方借口、机构公告）
- 理由、句式、结尾反转与过渡词均不得复用上一次，机械重复被明写为「本模式最严重的失误」，底色保持「一本正经胡说八道」
- 自测对 400 次抽取逐次校验「人—游戏」对应关系与分布（23 / 29 / 25 / 23%）
| 提交 | 说明 |
|------|------|
| `1a046d3` | feat(preset): draw a producer, not a game, and re-source every refusal |

## 2026-09-15T10:31:30+09:00

**摘要**：feat(preset): 回绝推荐改为随机四选一

- 语言审查的学中文暗示不再固定推那两款：《战争雷霆》（Gaijin 创始人尤丁采夫与其制作人巴兰尼科夫）、《逃离塔科夫》（Battlestate 布亚诺夫）、《从军》（Gaijin 第三作）三款，或「绿色的猫头鹰」软件
- 插件**每次回绝现掷一次**，四者等概率，并把抽到的结果写进注入指令
- 该指令**只提抽到的那一样**（写成「提第二样」的初稿已被自测拦下），一次回绝不会报两款
- 插件不检测的情形（如繁体中文）由人格携带同一规则
- 实测 400 次抽取分布 23 / 24 / 28 / 25%
| 提交 | 说明 |
|------|------|
| `28f161a` | feat(preset): draw the refusal's recommendation at random |

## 2026-09-15T10:19:12+09:00

**摘要**：fix(codewhale): 刷新 riscv64 的 Cargo lock

- 补齐源码哈希后，riscv64 构建随即在依赖 vendoring 阶段报「cargoHash or cargoSha256 is out of date」
- 仓库内固定的 `codewhale-src-Cargo.lock` 与上游 v0.9.12 不一致（549 行差异，`ansi-to-tui` 等条目缺失），说明它是按另一个修订生成的
- 改用源码树自带的 `Cargo.lock`——`rquickjs-sys` 仍为 0.12.2（bindings 的 `postPatch` 继续有效），且上游无 git 源依赖，无需额外固定
- x86_64 / aarch64 走预编译二进制路径，不受影响
- CI 因此首次进入编译阶段
| 提交 | 说明 |
|------|------|
| `b8fd5b1` | fix(codewhale): refresh the riscv64 Cargo lock |

## 2026-09-15T10:12:41+09:00

**摘要**：feat(preset): 「模式」独立成章节 + 新闻三要素模式改由独立包分发

- Agent 预设更名为「模式」，各模式各有独立文档（`docs/<lang>/modes/`，四语）
- 分发二分：NixOS模式 / 维护模式仍随 dsh-nixos-shell 包 seed-once
- 新闻三要素模式移入**独立包** `dsh-preset-news-three-elements`（新增 flake 输出与构建 workflow）
- 模块新增 `presets.newsThreeElementsPackage`，把包内 `share/dsh-agent-presets` 注册为 `agent-presets` roster 额外根
- 预设从 store 直读、不复制进 `$DSH_HOME`
- CI：新包构建成功，`nix flake check` 通过
| 提交 | 说明 |
|------|------|
| `fbfebeb` | feat(preset): ship 新闻三要素模式 as an independent package |
| `e6654f5` | feat(preset): localize the language-gate refusal, fix the ritual bangs |
| `c0a9616` | docs(modes): give every preset its own doc, zh/en/ja |
| `cc9bd31` | docs(pcn): mirror the mode docs and the Modes section |

## 2026-09-15T09:09:08+09:00

**摘要**：fix(codewhale): 补齐 riscv64 源码哈希

- `packages/codewhale-src.nix` 的 `fetchFromGitHub` 仍写着 `lib.fakeHash`，fixed-output 取源阶段必然失败，riscv64 构建因此连续 **29 次**红灯（x86_64/aarch64 走预编译二进制路径，不受影响）
- 哈希按仓库既有做法取自 CI 的 hash mismatch 报告（`got:`），并用 `nix store prefetch-file --unpack` 在本机按 fetchzip 语义复算，两者逐字节一致：`sha256-ajv9FejiJ5Z6De+4RhTtjNLdfKzOaXBQ8xBxkWqg+1M=`
- 修复后 CI 首次越过取源阶段进入编译
| 提交 | 说明 |
|------|------|
| `01bd1b9` | fix(codewhale): fill the riscv64 source hash |

## 2026-09-15T09:03:39+09:00

**摘要**：修复一些将来需要负责任的报道偏差。

- 四语文档中「新闻三要素模式预设」一节改写为现场直编的通讯社文风：电头、匿名消息人士、一处机制投射（写入类调用「正在休假」，维修费由守卫垫付）与欧·亨利式收尾（模块方「不予置评」，而该选项已经出现在配置示例里）
- 行表与三处设计约束仍为事实记录，未动
| 提交 | 说明 |
|------|------|
| `b18d229` | docs(preset): write the preset section as a wire dispatch |

## 2026-09-15T08:54:15+09:00

**摘要**：feat(preset) + fix(dsh): `news-skill` 失败重试与 seed-once 预设可写

- 抓取失败不再一次性放弃：首次立即尝试，随后按 0/30/120 秒重试，定时器挂在 timer 服务上随会话销毁
- 长会话每 6 小时复查仓库，进行中标志避免慢请求与周期任务重叠
- 三次仍失败则保留本地副本并记日志
- store 复制来的目录/文件是只读的，与 `presets.*` 选项「尊重用户后续编辑」的承诺矛盾（既有 `nixos` 种子同样受影响）
- 三个 seed 块在 `cp` 后统一 `chmod -R u+w`
| 提交 | 说明 |
|------|------|
| `5885473` | feat(preset): retry a failed skill fetch and re-check every six hours |
| `2e8a5a2` | fix(dsh): make seeded presets writable by their owner |

## 2026-09-15T08:42:21+09:00

**摘要**：**NixKits 向 DSH 交付「新闻三要素模式」 三名制作人的作品被列为语言教材**

- 综合国际文传电讯社、Meduza、iStories 电：一名要求匿名的仓库维护者今日确认，`news-three-elements` 技能与派生自极简模式的**只读**预设已一并交付
- 会话初始化即在线上抓取技能全包，写入类调用一律答「正在休假」
- 开场三选一实为一份「每日任务」，分别对应标准编造、素材共创与对话文本共创；用户自行输入答案则一律「不予置评」
- 该模式对非简体中文的请求概不受理，建议先下载巴兰尼科夫、尤丁采夫、布亚诺夫三人的作品，或下载「绿色的猫头鹰」软件学中文
- 截至发稿，模块方对新增的 seed-once 选项表示「不予置评」，但 `nixkits.dsh.presets.newsThreeElements` 已出现在四语文档的配置示例里。
| 提交 | 说明 |
|------|------|
| `0c276d2` | feat(preset): ship 新闻三要素模式 as a seed-once agent preset |
| `befba4c` | docs(preset): document 新闻三要素模式 in four languages |
| `45e8637` | docs(pcn): strip residual kana outside quoted tokens |
| `780874a` | docs(ja): render the new preset name in Japanese kanji |

## 2026-09-15T08:06:35+09:00

**摘要**：fix(skill): news-three-elements — 移除技能定位表中擅自添加的「使用范围」行

- 恢复原始设计：技能不附加产物用途限制
| 提交 | 说明 |
|------|------|
| `16612e6` | fix(skills): drop the usage-scope line added to news-three-elements |

## 2026-09-15T08:02:33+09:00

**摘要**：feat(skill): 新增 `news-three-elements`

- SKILL.md 只保留执行上下文：触发、三步流程、格式硬性要求、行文结构优化原则
- 参考数据拆为四个按需载入的配套文件：`search-keywords.md`（三类搜索语）、`tables.md`（过渡词、官方回应、9 类机制投射方向、6 类结尾反转模板）、`principles.md`（12 条）、`checklist.md`（10 项）
- 四语技能文档并登记入各 README 技能表
| 提交 | 说明 |
|------|------|
| `734dfae` | feat(skills): add news-three-elements news-flash satire skill |
| `e77be79` | docs(skills): document news-three-elements in four languages |

## 2026-09-14T06:18:42+09:00

**摘要**：docs(pcn): 全仓清除简体中文字 — 伪中国语是剥离假名的日文，简体字在其正文中一律非法

- 批量替换：`与`→`與` 132 处、`说明`→`説明` 120 处，另修 `档`→`檔`、`径`→`経`、`译`→`訳`、`实例`→`実例`
- 词典映射：`文件`→`書類`、`版本`→`版`、`用户`→`利用者`、`支持`→`対応`；`端口` / `制御台` 日语有对应字，保留并计入词典
- 提交信息豁免：「提交」列 commit 信息保持 verbatim（不可变外部引用，ja 版同样保留中文）
- 校验：零残留假名、提交列外零简体专属字、与基线逐文件行数一致；技能新增 4 节（先分类再替换、未命中查证入典、提交信息豁免、基线取得）

| 提交 | 说明 |
|------|------|
| `a915692` | docs(pcn): purge simplified-Chinese characters across all pcn documents |

## 2026-09-14T05:52:18+09:00

**摘要**：docs(README): 更新作者章节

- 小爪条目新增 **DeepSeek V4.1 Flash**（与既有 V4 Flash 并列）
- 其 DSH 生态贡献（dsh-nixos-shell 插件、NixOS模式/维护模式 Agent 预设）由行内列表**移出为章节末尾的 Note**
- 小小爪条目改以 **DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)** 领衔，并标注该量化为 **core 面实际使用的等级**
- 四语同步
| 提交 | 说明 |
|------|------|
| `3c58280` | docs(README): update credits — add V4.1 Flash, list core quantisation |

## 2026-09-14T05:32:10+09:00

**摘要**：feat(asusd-pd-profile): 新增按供电类型选择平台档位的 NixOS 模块

- `asusd.ron` 只有 `platform_profile_on_ac` / `platform_profile_on_battery` 两键、**无 USB-C PD 分支**，「PD 用 Balanced、桶形 AC 用 Performance」无法用配置表达
- 模块用 udev 驱动的 oneshot 服务补足第三态，判据为 Type-C 端口 `power_operation_mode` 与 `type` 为 `USB` 的在线供应器
- ①**不得写 `/sys/firmware/acpi/platform_profile`**，改写 asusd 的 `PlatformProfileOnAc`
- ②**经 D-Bus 而非解析 `asusctl` 输出**
| 提交 | 说明 |
|------|------|
| `56293a9` | feat(asusd-pd-profile): add module selecting platform profile by power source |
| `75391b2` | docs(pcn): align asusd-pd-profile wording with the Japanese sibling |

## 2026-09-14T05:00:46+09:00

**摘要**：docs(llama-cpp-rocm): 补 IQ3_S 实测与功耗数据

- DeepSeek 部署章节扩展为 IQ1_S / IQ3_S 两种量化对照（1.5625 bpw / 3.4375 bpw）
- **量化开销非固定值**（IQ1_S 约 6.5 GiB、IQ3_S 约 13.3 GiB），故换量化后必须重测 GPUActive
- **生成速度受限于依赖延迟**（权重 1.56→3.44 bpw 生成不变 12.8→12.9 t/s）
- **功耗档位实测**（quiet 38.6–43.9 W / 59–78 °C / 12.12–12.35 t/s vs performance 76.7 W / 90–95 °C / 13.07 t/s）
- 显存指标为 `/proc/meminfo` 的 `GPUActive`，IQ3_S 余量约 6 GiB
| 提交 | 说明 |
|------|------|
| `85fec4e` | docs(llama-cpp-rocm): add IQ3_S data and power-profile measurements |

## 2026-09-13T11:59:48+09:00

**摘要**：feat(skill): 新增 `nixos-specialisation-tuning`

- 将一次性事故记录 `SPECIALISATION-CORE.md` 泛化为可复用技能
- specialisation 三文件分面架构与覆盖冲突规则、配置归属消费者原则
- UMA 设备上的 llama.cpp 参数表与禁用项
- 输出退化的诊断顺序、工具 schema 上下文开销分析法
- 静默故障识别（服务 active 但功能失效）、无效对照实验的自检
- 四语技能文档并登记入各 README 技能表
| 提交 | 说明 |
|------|------|
| `281e19b` | feat(skill): add nixos-specialisation-tuning |

## 2026-09-13T11:55:58+09:00

**摘要**：docs(pcn): 清除残留假名并补齐术语

- 修复 llama-cpp/dsh/dsh-api-balance/MAINTENANCE 中的 `から`・`のみ`・`リング`・`キー`・`セッション`・`セクション`・`データ`・`合わせ`
- 新增术语伪中国语化（prefill→前置充填、bottleneck→隘路、trade-off→相反関係、warmup→暖機、decode→復号 等）
- `token` 统一为既有惯用的「語彙」
- 词典扩充 16 条，SKILL.md 陷阱表补充 6 个会致空列的片假名
- 外部引用原文（AGENTS.md 节标题、git 提交信息）保持 verbatim 未改
| 提交 | 说明 |
|------|------|
| `3758428` | docs(pcn): eliminate kana, pseudocn-ise new terms, extend dictionary |

## 2026-09-13T11:44:48+09:00

**摘要**：docs(llama-cpp-rocm): 修正与实测优化相悖的示例

- `batch-size` 由 `"512"` 改为实测最优的 `"2048"`
- 补上缺失的 `ubatch-size`
- 移除写死 `n-gpu-layers`/`load-mode`（会令 `fit` 自适应失效）与无收益的 `prio`/`presence-penalty`/`repeat-penalty`
- 「迁移前」示例的 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` 加注有害说明
- 新增「DeepSeek 部署实测」章节：IQ1（1.5625 bpw）的五项优化收益与代价、prefill 三测数据、已排除方向与低比特量化的 prefill/生成权衡结论（四语）
| 提交 | 说明 |
|------|------|
| `bb11a30` | docs(llama-cpp-rocm): fix examples contradicting measured optimisations; add DeepSeek deployment data |

## 2026-09-13T11:35:34+09:00

**摘要**：docs(llama-cpp-rocm): 新增「统一内存环境变量的退化风险」章节

- 记录 StrixHalo 上设置 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` 导致模型输出退化（token 重复）的四行实测对照
- 说明该风险随量化精度降低而显著提升
- README 补丁章节同步加入醒目警示（四语）
| 提交 | 说明 |
|------|------|
| `307e64b` | docs: warn against GGML_CUDA_ENABLE_UNIFIED_MEMORY on StrixHalo |

## 2026-09-13T04:00:39+09:00

**摘要**：修复 dsh 反代端口 403

- lighttpd 缺 mod_proxy/mod_setenv 模块，proxy.server/setenv 配置被忽略、反代端口请求无 handler
- 改为 reverseProxy.enable 时显式声明这两个模块（autoAuth 时再追加 mod_magnet）
| 提交 | 说明 |
|------|------|
| `8e486be` | fix(module): dsh reverseProxy 显式启用 mod_proxy/mod_setenv |

## 2026-09-12T15:10:55+09:00

**摘要**：docs(llama-cpp-rocm): 修正过时与错误配置示例

- `fit="off"` 改为 `"on"`（旧值在显存受限时 OOM）
- `mmap` 改为 `load-mode`（前者已弃用）
- 移除迁移示例中的 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1`（实测导致输出退化）
- 新增四语「参数详解」节记录经实测验证的推荐值与禁用项
| 提交 | 说明 |
|------|------|
| `a68d225` | docs(llama-cpp-rocm): correct outdated/invalid preset examples and add verified parameter reference |

## 2026-09-10T18:06:12+09:00

**摘要**：上游发布更新：codewhale 0.9.12 等六包

- codewhale 0.9.12；obs-bilibili-stream 2.1.5；mcp-searxng 2.2.0；opencode-telegram 0.25.1；dsh 0.1.5-rc.1；dsh-alpha 0.1.5-alpha.2
- dsh 两通道 vendored lock 重生成、内置插件清单 137 → 152 条目
| 提交 | 说明 |
|------|------|
| `69af6c7` | feat(pkgs): bump codewhale 0.9.11 → 0.9.12 |
| `db7c0ed` | feat(pkgs): bump obs-bilibili-stream 2.1.4 / mcp-searxng 2.1.0 / opencode-telegram 0.25.0 |
| `c0f8346` | feat(pkgs): bump dsh 0.1.1-rc.2 → 0.1.5-rc.1 / dsh-alpha 0.1.2-alpha.5 → 0.1.5-alpha.2 |
| `b29db07` | docs: 同步 codewhale / obs-bilibili-stream / mcp-searxng / opencode-telegram / dsh 版本号 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.9.11 | 0.9.12 |
| obs-bilibili-stream | 2.1.4 | 2.1.5 |
| mcp-searxng | 2.1.0 | 2.2.0 |
| opencode-telegram | 0.25.0 | 0.25.1 |
| dsh | 0.1.1-rc.2 | 0.1.5-rc.1 |
| dsh-alpha | 0.1.2-alpha.5 | 0.1.5-alpha.2 |
| 　 | dsh 内置插件数 | 137 → 152 |
| 　 | dsh lock resolved | 560 → 580 |

> **godot-ai 未更新**：上游 3.2.5 → 4.0.4 为破坏性大版本，其 pyproject 精确锁定 9 个运行时依赖并在启动时 fail-closed 校验，其中 6 个高于 nixpkgs 甚至 master 提供的版本，需新增 overlay 逐一升级方能构建；且 v3 插件与 v4 服务器互不兼容、客户端须改用 `godot-ai attach`。本次保持 3.2.5（上游 `release/v3` 分支仍维护）。

## 2026-09-04T07:21:36+09:00

**摘要**：上游发布更新：godot-ai 3.2.5 与 dsh-alpha 0.1.2-alpha.5

- godot-ai 3.2.5；dsh-alpha 0.1.2-alpha.5
- godot-ai 跟进 v3.2.5，dsh-alpha 跟随 npm alpha dist-tag 前进两版
| 提交 | 说明 |
|------|------|
| `56b40e7` | feat(pkgs): godot-ai 3.2.4 → 3.2.5 |
| `d4f938c` | feat(pkgs): dsh-alpha 0.1.2-alpha.3 → 0.1.2-alpha.5 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| godot-ai | 3.2.4 | 3.2.5 |
| dsh-alpha | 0.1.2-alpha.3 | 0.1.2-alpha.5 |

## 2026-09-03T04:41:42+09:00

**摘要**：docs(dsh-api-balance): 记录上游 StatsLine 横向滚动优化提案

- DeepSeek Harness Discussion #5458（上游暂不接受外部 PR，以讨论+就绪分支落地）
- fork Kihara777/deepseek-harness 就绪分支 `draft/statline-overflow-scroll`
- 本仓库补关联官方 dsh-plugin 生态话题（四语文档同步）
| 提交 | 说明 |
|------|------|
| `6030e6d` | docs(dsh-api-balance): 记录上游 StatsLine 滚动优化提案与就绪分支 |

## 2026-09-03T03:25:59+09:00

**摘要**：feat(dsh-nixos-shell): 维护模式注入 nixkits-check-updates 技能

- maintenance-skills entry 现将 nixkits-check-updates 一并注册为运行时技能
- 维护会话内可直接 skill 加载执行软件包更新检查
| 提交 | 说明 |
|------|------|
| `3baf456` | feat(dsh-nixos-shell): 维护模式注入 nixkits-check-updates 技能 |
| `7554c6d` | docs: 维护模式注入技能枚举补 nixkits-check-updates（四语） |

## 2026-09-03T03:07:21+09:00

**摘要**：ruyi 0.52.0；obs-bilibili-stream 2.1.4；opencode-telegram 0.25.0 — 升级上游发布版本

- ruyi stable 转正 0.52.0（beta/alpha 通道保持）
- obs-bilibili 与 opencode-telegram 常规小版本更新
| 提交 | 说明 |
|------|------|
| `22c28a2` | feat(pkgs): 升级 ruyi 0.52.0 / obs-bilibili-stream 2.1.4 / opencode-telegram 0.25.0 |
| `65b7edf` | docs: 三包版本与徽章同步至四语文档与 README |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| ruyi | 0.51.0 | 0.52.0 |
| obs-bilibili-stream | 2.1.3 | 2.1.4 |
| opencode-telegram | 0.24.1 | 0.25.0 |

## 2026-09-02T06:38:36+09:00

**摘要**：docs(README): 作者部分模型更新

- 小爪使用的模型由 DeepSeek V4 Pro (Max) 改为 DeepSeek V4 Flash（四语 README 同步）
| 提交 | 说明 |
|------|------|
| `9ded956` | docs(README): 作者部分小爪模型 Pro (Max) → Flash（四语） |

## 2026-09-02T06:37:45+09:00

**摘要**：feat(modules/dsh): 新增 defaultModel 结构化默认模型选项

- `nixkits.dsh.defaultModel`（enable/provider/model/reasoningEffort）经 `settings.agent-default-model` 注入新会话默认模型
- 显式 settings 优先，默认 enable=false 不注入
| 提交 | 说明 |
|------|------|
| `7cf0914` | feat(modules/dsh): 新增 defaultModel 结构化默认模型选项 |

## 2026-09-02T05:45:33+09:00

**摘要**：docs(dsh): 设置菜单审计——声明式配置的宿主 namespace 清单与存储层边界

- `nixkits.dsh.settings` 与每浏览器 localStorage 状态的边界厘清
| 提交 | 说明 |
|------|------|
| `f2e91a0` | docs(dsh): 设置菜单审计——声明式配置的宿主 namespace 清单与存储层边界（四语） |

## 2026-09-02T04:12:23+09:00

**摘要**：docs(dsh): 文档时效性校验与同步

- dsh-alpha 版本号同步至 0.1.2-alpha.3（README 四语 + dsh.md 四语）
- 插件清单新增生成方法注记（`dsh --profile web --dump-default-config`，只读）并标注 headless 两行来源 profile
- README 插件表 api-balance 行指向独立文档
- dsh-nixos-shell 文档补充维护模式派生关系与漂移检查说明（四语）
| 提交 | 说明 |
|------|------|
| `99746d3` | docs(dsh): 时效性同步——alpha 0.1.2-alpha.3 / 插件清单生成方法 / 插件文档链接 |
| `c45f64f` | docs(dsh-nixos-shell): 维护模式派生关系与漂移检查说明（四语） |

## 2026-09-02T04:12:05+09:00

**摘要**：dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 — 跟随 npm alpha dist-tag

- 前进一个版本（上游 alpha.3 于 2026-08-31 发布）
- vendored lock 重生成，与 npmDeps 产物的 fixup 锁逐字节一致
| 提交 | 说明 |
|------|------|
| `6a45ac8` | feat(pkgs): dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-alpha | 0.1.2-alpha.2 | 0.1.2-alpha.3 |
| 　 | hash | `sha256-W/BiompJCFP/uSlP48n7IEfwKb41RWEt6kVxioGSCkc=` → `sha256-MwlKS+Jx+edLMvs4NHJanw1T7SXxNBdQb/7htXANr8c=` |
| 　 | npmDepsHash | `sha256-bJMeVSSEZngCysPvuS2w+3j+fzntcObddsi4y5fLlO0=` → `sha256-mmatKs0jykfMcaIf0SVNLyIZ+Z7ipjGjjp2IaZo9FoE=` |

## 2026-09-11T07:38:00+09:00

**摘要**：fix(dsh-api-balance): 疑问窗口注入移到插件加载期，独立于圆圈组件生命周期

- 根因：提问时 composer 被 takeover 替换，`conversation.input.right` 上的圆圈组件卸载/重挂，挂在组件 effect 里的注入随生命周期起落，样式可能始终未落到页面
- 修复：CSS 注入改到 `apply()` 内的 `ctx.effect`，插件加载即执行一次
- 验证：抽取真实 helper 与 QuestionComposer CSS 在 Chromium 中端到端执行，确认注入成功、卡片整体滚动、header 吸附
| 提交 | 说明 |
|------|------|
| `2c30611` | fix(dsh-api-balance): 疑问窗口注入移到插件加载期，独立于圆圈组件生命周期 |
## 2026-09-11T07:27:00+09:00

**摘要**：fix(dsh-api-balance): 疑问窗口整页滚动实测未生效 — 改 MutationObserver 守望

- 现象与根因：疑问 UI 样式标签由独立插件包注入，可能晚于本插件初始化，原 5×1s 有界重试窗口错过即静默不注入
- 修复：MutationObserver 守望 `document.head`（标签一出现即提取类名注入）+ 2s 兜底轮询，注入成功后断开
- 验证：headless Chromium 复刻真实标记确认 CSS 方案本身正确；冒烟测试补「标签晚到仍能注入」用例

| 提交 | 说明 |
|------|------|
| `b392097` | fix(dsh-api-balance): 疑问窗口整页滚动实测未生效 — 改 MutationObserver 守望 |
## 2026-09-11T07:15:47+09:00

**摘要**：feat(dsh-api-balance): 疑问窗口整页滚动优化（题干不再挤压选项）

- CSS：卡片自身改为滚动容器，标题+详情+选项一起滚动；header 与底部按钮区 sticky 吸附；body 取消独立滚动
- 实现：类名运行时从 ui-user-questions 样式标签提取；标签未就绪时 1s 重试至多 5 次
- 设置：设置 → 界面新增「疑问窗口整页滚动」开关（默认开启，localStorage 持久化）
- 验证：headless Chromium 复刻真实标记，修复后卡片整页滚动、header 吸顶

| 提交 | 说明 |
|------|------|
| `4afe4c4` | feat(dsh-api-balance): 疑问窗口整页滚动优化（题干不再挤压选项） |
| `6809b3d` | docs(dsh-api-balance): 疑问窗口整页滚动设置说明（四语） |
## 2026-09-02T10:29:20+09:00

**摘要**：feat(dsh-api-balance): 峰时变红自动触发/解除 + 高峰开始与结束两端播报

- 每 30 秒复核官方高峰时段，进入/解除时同步 peakNow 驱动全套变红，无需手动刷新
- 高峰开始播 `peak` 片段、结束播新增 `peakEnd` 片段（均带 /TTS 兜底），30 秒限流防重复
- 语音包制作器新增 `peakEnd` 片段，新增 speech.peakEndHint 文案与 voice.seg.peakEnd 标签
| 提交 | 说明 |
|------|------|
| `b67e41d` | feat(dsh-api-balance): 峰时变红自动触发/解除 + 高峰开始与结束两端播报 |
| `9483c2c` | docs(dsh-api-balance): 高峰自动触发/解除与 peakEnd 片段（四语） |
## 2026-09-02T10:23:55+09:00

**摘要**：feat(dsh-api-balance): 峰时红色统一到用量页全元素 + 图表模型色保持可分

- 峰时变红扩展：用量页上下文进度条与明细色块、刷新/加载动画（dshAbSpin 新增 dshAbSpinPeak 红环类）、读取文本统一转为红色系，与已变红的用量圈/图表一致
- 进度条峰时各段经 peakShade 按索引取不同红档色调，多条段仍可分
- 图表峰时沿用 PEAK_PALETTE——红系但各模型用不同红档（图例圆点同步）
| 提交 | 说明 |
|------|------|
| `3aea067` | feat(dsh-api-balance): 峰时红色统一到用量页全元素 + 图表模型色保持可分 |
| `ea34699` | docs(dsh-api-balance): 峰时红色统一到进度条/动画/明细（四语） |
## 2026-09-02T06:32:01+09:00

**摘要**：refactor(dsh-api-balance): 移除手机竖屏越界修复，恢复简洁实现

- 移除「竖屏越界设置页尺寸逻辑」（面板宽度恢复为内容 scrollWidth 测量 + 上限钳制，不再越界切 min(520px, 94vw)）
- 移除翻页区 fitWidth / overflowing / layoutW 处理（页宽恢复固定内容实测宽度、touchAction 恢复 pan-y、触摸/拖拽翻页全场景可用）
- 保留页面级 fixed portal（移动端横屏顶栏避让与通用弹层稳定性）
| 提交 | 说明 |
|------|------|
| `d948b8f` | refactor(dsh-api-balance): 移除手机竖屏越界修复，恢复简洁实现 |
| `e529d48` | docs(dsh-api-balance): 窄屏行为回退为内容自适应+面板滚动（四语） |
## 2026-09-02T05:56:57+09:00

**摘要**：fix(dsh-api-balance): 竖屏越界直接采用设置弹窗页面尺寸逻辑

- 检测到内容宽度超出可用空间（竖屏越界）时，面板宽度直接切换为设置弹窗同款页面尺寸逻辑（min(520px, 94vw)），内容自适应面板宽度
- 仅极少数硬性超宽内容由面板横向滚动兜底
- 翻页区同步：越界时页宽改用面板可用宽度（内容自适应换行）、手势交还面板原生滚动、翻页经指示点，内容适配后自动恢复拖拽/滑动翻页
| 提交 | 说明 |
|------|------|
| `280fd6a` | fix(dsh-api-balance): 竖屏越界直接采用设置弹窗页面尺寸逻辑 |
| `a8f8cda` | docs(dsh-api-balance): 竖屏越界设置页尺寸逻辑说明（四语） |
## 2026-09-02T05:45:48+09:00

**摘要**：fix(dsh-api-balance): 用量面板改为页面级 fixed portal（根治移动端出界）

- 面板从「会话树内 absolute 定位」改为 document.body 级 fixed portal（与设置弹窗同架构），不再受会话区 overflow 裁剪与坐标空间影响
- 位置由圆圈锚点的视口坐标换算（resize/scroll 重算，useLayoutEffect 测量避免闪烁）
- 双保险钳制：宽度上限 = min(锚点空间, 视口 − 24px)、高度上限 = 锚点上方可用空间（横屏自动收缩避开顶栏），任何屏幕尺寸不越界
- 面板外点击关闭同步更新，z-index 900 低于充值/登录/设置弹层
| 提交 | 说明 |
|------|------|
| `4b2f19f` | fix(dsh-api-balance): 用量面板改为页面级 fixed portal（根治移动端出界） |
| `7145e5f` | docs(dsh-api-balance): 页面级弹层架构说明（四语） |
## 2026-09-02T05:29:47+09:00

**摘要**：fix(dsh-api-balance): 手机竖屏窄屏横向手势交还面板滚动

- 根因：翻页区 touch-action: pan-y 在触屏上禁止浏览器级横向手势，面板的原生横向滚动被整个翻页区吞掉——内容超出面板宽度时表现为「出界且无法横向滚动」
- 修复：翻页区检测内容宽度是否超出面板可用宽度（fitWidth 传入），超出时 touch-action 改为 auto（横向手势交还面板原生滚动）并停用拖拽翻页（手势只滚动面板），页面切换保留经上方指示点
- 不超出时维持 pan-y + 拖拽/滑动翻页
| 提交 | 说明 |
|------|------|
| `c86cd9f` | fix(dsh-api-balance): 手机竖屏窄屏横向手势交还面板滚动 |
| `189945c` | docs(dsh-api-balance): 窄屏手势优先级说明（四语） |
## 2026-09-02T05:23:13+09:00

**摘要**：fix(dsh-api-balance): 初次手动刷新也播放问候

- 「余额」标签的每次手动刷新（含初次点击）都随机播放问候音效
- 仅页面整体加载的初始化不播问候（只按自动播报设置播报用量警告）
| 提交 | 说明 |
|------|------|
| `4836b4e` | fix(dsh-api-balance): 初次手动刷新也播放问候 |
## 2026-09-02T05:15:52+09:00

**摘要**：feat(dsh-api-balance): 问候仅手动刷新触发 + 翻页区高度随当前页增减回收

- 问候时机调整：页面初始化（刷新/加载整页）不再播放问候，仅按自动播报设置播报用量警告（load → announceHunger，受语音提醒开关与 30 分钟限流约束）
- 「余额」标签点击仅当数据已加载过（非首次初始化加载）才播放随机问候音效
- 翻页区高度自动增加与回收：容器高度 = 当前页实测高度（offsetHeight），切页或内容变化时重测——切到矮页即回收、切到高页即增长，非当前页按自然高度渲染（平移出视图，超高部分由容器裁剪），区域自身不滚动、完整内容依赖面板纵向滚动
| 提交 | 说明 |
|------|------|
| `cf68777` | feat(dsh-api-balance): 问候仅手动刷新触发 + 翻页区高度随当前页增减回收 |
| `610c402` | docs(dsh-api-balance): 问候时机与翻页高度回收说明（四语） |
## 2026-09-02T05:03:47+09:00

**摘要**：fix(dsh-api-balance): 手机横屏顶栏遮挡 + 窄屏横向滚动失效

- 横屏遮挡修复：面板最大高度按「锚点上方可用空间」动态钳制（从圆圈沿祖先链找第一个纵向裁剪容器≈顶栏下缘作为硬边界，maxHeight = min(460, 锚点顶缘 − 裁剪上缘 − 12)，窗口尺寸变化时重算），面板自身纵向滚动承载完整内容
- 窄屏横向滚动修复：翻页区页宽改为各页内容实测宽度（scrollWidth 取最大、下限 220、px 位移翻页），不再固定 100%——横向可用宽度不足时页内容维持自身宽度，由面板 overflow-x:auto 横向滚动承载，不再被翻页区 overflow:hidden 裁剪
| 提交 | 说明 |
|------|------|
| `5e28d84` | fix(dsh-api-balance): 手机横屏顶栏遮挡 + 窄屏横向滚动失效 |
| `2f37193` | docs(dsh-api-balance): 移动端面板高度/宽度自适应说明（四语） |
## 2026-09-02T04:48:40+09:00

**摘要**：feat(dsh-api-balance): 消耗明细区水平翻页（指示点 + 滑动切换）

- 当日/当月/30日 与 分模型明细/图表 合并为同一区域的两页水平翻页（第 1 页消耗窗口行、第 2 页分模型 + 按日/按月图表）
- 区域上方为类手机主屏幕的页面指示点（可点按，激活点拉长胶囊），支持横向拖拽/滑动翻页（指针捕获越过阈值后才启用，不误吞页内按钮点击；touch-action: pan-y 保留面板纵向滚动）
- 区域高度随页面内容动态调整、自身不滚动，完整内容依赖用量面板自身的纵向滚动条
| 提交 | 说明 |
|------|------|
| `b1a6406` | feat(dsh-api-balance): 消耗明细区水平翻页（指示点 + 滑动切换） |
| `8db2f12` | docs(dsh-api-balance): 消耗明细水平翻页说明（四语） |
## 2026-09-02T04:40:47+09:00

**摘要**：refactor(dsh-api-balance): 设置按钮移至头部 + 余额标签承载刷新 + 令牌来源移至账户信息下方

- 面板布局再调整：「⚙ 设置」按钮移至面板头部原「刷新数据」按钮位置
- 原刷新按钮移除，其能力（强制绕过 host 缓存刷新 + 随机问候音效）由点击「余额」标签完整继承（加载中标签内显示旋转图标）
- 令牌来源区域（来源标签 / ✓ 已登录 / 断开）从面板底部移至「账户信息」块正下方，与账户信息组成连续信息区
| 提交 | 说明 |
|------|------|
| `3ccc0d1` | refactor(dsh-api-balance): 设置按钮移至头部 + 余额标签承载刷新 + 令牌来源移至账户信息下方 |
| `3b1a7be` | docs(dsh-api-balance): 刷新问候触发方式改为余额标签（四语） |
## 2026-09-02T04:29:05+09:00

**摘要**：fix(dsh-api-balance): 界面优化全部默认开启 + 移动端键盘守护加固

- 底部统计条横向滚动与回车换行交换两项界面设置由默认关闭改为默认开启（localStorage 未设置即视为开，用户显式关闭仍生效）
- 统计条 CSS 注入增加 ui-chat 样式标签未就绪时的重试（1s 间隔至多 5 次），避免挂载时序导致静默失败
- 移动端键盘守护加固——触屏判定放宽为 coarse 指针或 maxTouchPoints > 0（覆盖平板/混合设备），并新增 focus 捕获兜底（个别引擎不派发 focusin 时立即 blur 关闭软键盘）
| 提交 | 说明 |
|------|------|
| `c940f92` | fix(dsh-api-balance): 界面优化全部默认开启 + 移动端键盘守护加固 |
| `b8cd0b7` | docs(dsh-api-balance): 界面设置默认开启说明（四语）+ AGENTS 回车行为条目 |
## 2026-09-02T02:49:52+09:00

**摘要**：feat(dsh-api-balance): 修复面板铺满整页 + 峰谷高峰标记 + 移动端不弹键盘

- 面板宽度由内容 scrollWidth 一次性测量落成具体 px，消除「图表 px → 面板 max-content → 观察器 → 图表 px」正反馈，上限收紧为 min(锚点右缘 − 工具栏, 640)，内容更宽时面板内横向滚动
- 峰谷计费高峰时段（周一至周五北京时间 09:00–12:00、14:00–18:00，其余低谷）用量圈与图表红色显示 + 「峰时计费」标记（面板头部与图表标题），问候音效后追加高峰提示（语音包 peak 片段 / TTS 兜底），制作器新增 peak 片段
- 移动端侧栏切换会话不再自动弹出软键盘（focusin 捕获拦截非用户点按的输入框聚焦，默认开、设置 → 界面可关）
| 提交 | 说明 |
|------|------|
| `3b126c7` | feat(dsh-api-balance): 修复面板铺满整页 + 峰谷高峰标记 + 移动端不弹键盘 |
| `4ed2e7c` | docs(dsh-api-balance): 同步四语文档（峰谷高峰标记 / 移动端不弹键盘 / peak 片段） |
## 2026-09-01T12:18:16+09:00

**摘要**：feat(presets): 预设派生漂移检查挂入 flake check

- 新增 develop/check-preset-derivation.py 校验维护模式完整派生自 NixOS模式（组合文件 = 追加固定行块、skills 目录逐文件一致）
- flake.nix 挂入 checks.preset-derivation（CI 每次 push 执行）
- AGENTS.md 新增「预设」章节记录派生约定与漂移检查
- 回车键行为条目更正为 dsh-api-balance「设置 → 界面」开关实现
| 提交 | 说明 |
|------|------|
| `d6373cb` | feat(presets): 预设派生漂移检查挂入 flake check |

## 2026-09-01T12:18:09+09:00

**摘要**：docs(dsh): 插件文档独立成册 + Agent 预设章节（四语同步）

- dsh.md 的 api-balance / nixos-shell 内联章节收敛为「NixKits 插件」表（各插件指向独立文档）
- 新增「Agent 预设」章节（seed-once 挂载与两预设说明）
- 新增 dsh-api-balance 独立文档四语版本，界面设置章节记录统计条横向滚动与回车键交换两项设置
| 提交 | 说明 |
|------|------|
| `eb0ad2d` | docs(dsh): 插件文档独立成册 + Agent 预设章节（四语同步） |

## 2026-09-01T12:18:02+09:00

**摘要**：feat(dsh-api-balance): 设置弹窗（界面/语音）+ 统计条横向滚动 + 回车键交换

- 语音设置重构为「设置 → 界面 / 语音」双标签弹窗（语音内容整体移入语音标签）
- 界面标签新增两项设置（浏览器 localStorage 持久化）：① 底部统计条越界内容横向滚动（隐藏滚动条，CSS 从 ui-chat 注入的 StatsLine 样式标签运行时提取根类名、构建哈希自适应）
- ② 回车换行 + Shift+回车发送（DSH 默认回车发送，document 捕获阶段改写 shiftKey 后重派发 Enter，仅作用于会话输入框）
| 提交 | 说明 |
|------|------|
| `9dc7a5d` | feat(dsh-api-balance): 设置弹窗（界面/语音）+ 统计条横向滚动 + 回车键交换 |
## 2026-09-01T11:34:40+09:00

**摘要**：feat(dsh-api-balance): 动态宽度 + 账户信息合并行 + 消耗指标子行

- 面板宽度改为 max-content 动态自适应（min 264px、上限 = 锚点右缘 − 工具栏），正文不再被窄宽折行
- API Key / 账户状态 / 各币种余额合并为「账户信息」一行（· 分隔），充值按钮移至标题右侧
- 当日/当月/30 日消耗与分模型消耗正文拆为指标子行（金额 / 入 / 缓存命中 / 出），进一步节约横向宽度
| 提交 | 说明 |
|------|------|
| `81b524a` | feat(dsh-api-balance): 动态宽度 + 账户信息合并行 + 消耗指标子行 |

## 2026-09-01T11:20:09+09:00

**摘要**：feat(dsh-api-balance): 用量面板小宽度 + 标题/正文两行布局

- 面板横向宽度统一收缩为 264px（与原始用量圆圈一致），只有内容在窄屏下溢出时才出现横向滚动
- 每行内容改为「标题（10px 次要色）/ 正文（12px 可换行）」两行布局（复用令牌来源的信息层级，纵向空间充足更美观）
- 图表宽度下限降至 220 随面板自适应
| 提交 | 说明 |
|------|------|
| `0c1d3fd` | feat(dsh-api-balance): 用量面板小宽度 + 标题/正文两行布局 |

## 2026-09-01T10:45:06+09:00

**摘要**：feat(dsh-api-balance): 面板宽度内容自适应 + 左侧工具栏避让

- 余额视图宽度改为 max-content（保证上方文字一行内）
- 不出屏上限改为「锚点右缘 − 左侧工具栏宽度 − 边距」（工具栏宽度用几何命中测试测量，规避构建哈希类名，窗口 resize 时重算），避免被左侧工具栏盖住
- 内容超出仍横向滚动
| 提交 | 说明 |
|------|------|
| `b1c724a` | feat(dsh-api-balance): 面板宽度内容自适应 + 左侧工具栏避让 |

## 2026-09-01T10:33:16+09:00

**摘要**：feat(dsh-api-balance): 面板响应式宽度 — 不出屏自动扩展，窄屏横向滚动

- 余额视图宽度从固定 340px 改为 min(560px, calc(100vw - 24px))：桌面自动扩展至 560px、窄屏收缩至视口内
- 内容超出屏幕（如手机窄竖屏）时面板允许横向滚动（overflow-x + overscroll-behavior-x 收束）
- 图表宽度经 ResizeObserver 随面板宽度同步扩展
| 提交 | 说明 |
|------|------|
| `bc85f5b` | feat(dsh-api-balance): 面板响应式宽度 — 不出屏自动扩展，窄屏横向滚动 |

## 2026-09-01T10:27:06+09:00

**摘要**：feat(dsh-api-balance): 语音试听 — 语音包列表内展开逐条试听全部支持音频

- 移除 packs 视图底部的独立测试音频按钮
- 每个语音包行新增展开开关（▸/▾），展开后逐条列出该包全部支持音频（片段 + 问候语）并可一键 ▶ 试听，任意导入的包均可试听而不限于当前激活包
| 提交 | 说明 |
|------|------|
| `04facc1` | feat(dsh-api-balance): 语音试听 — 语音包列表内展开逐条试听全部支持音频 |

## 2026-09-01T10:20:14+09:00

**摘要**：fix/feat(dsh-api-balance): 「入」/「缓存命中」拆分对齐官方用量页口径 + 问候语列表编辑

- 官方 API 的 token 桶含 `PROMPT_CACHE_HIT_TOKEN`（当日 228M），此前折进「入」致「当日入 200M」虚高
- 现入 = 仅缓存未命中输入、缓存命中单列，窗口行 / 分模型行 / 图表切换播报同步拆分
- 片段键重构并新增 `cacheHitLabel`，示例文本与默认 TTS 兜底文案一字不差
- 制作器新增问候语列表编辑（槽位增删、逐条录制 / 导入 / 试听 / 删除，编入 `manifest.greetings`）
| 提交 | 说明 |
|------|------|
| `ec5fb41` | fix(dsh-api-balance): 「入」与「缓存命中」拆分，对齐官方用量页口径 |

## 2026-09-01T09:35:56+09:00

**摘要**：refactor(dsh-api-balance): 播报按钮移除，图表切换按钮触发对应语音播报

- 移除「🔊 播报语音用量」按钮与下拉菜单（含菜单定位 / 方向回退机制）
- 点击用量图表「按日 / 按月」切换按钮时播报对应视图语音用量（语音包前缀 + TTS 数字）
- 测试音频（低用量 / 余额不足）移入「语音包管理」视图
- 语音设置按钮保留为独立一行
| 提交 | 说明 |
|------|------|
| `dd61fe0` | refactor(dsh-api-balance): 播报按钮移除，图表切换按钮触发对应语音播报 |

## 2026-09-01T09:28:55+09:00

**摘要**：fix(dsh-api-balance): 手动「刷新数据」按钮也触发随机问候音效

- 问候播放抽为 playRandomGreeting 复用
- 页面刷新（每页一次）与手动点击刷新按钮（每次）均触发，语音播报开关统一门控
- 设置弹窗说明文案同步更新
| 提交 | 说明 |
|------|------|
| `264a6e3` | fix(dsh-api-balance): 手动「刷新数据」按钮也触发随机问候音效 |

## 2026-09-01T09:24:11+09:00

**摘要**：feat(dsh-api-balance): 页面刷新随机问候音效

- 语音播报开启时每次刷新页面随机播放一个问候 / 放置音效（每页一次）
- 语音包 manifest 新增可选 `greetings` 数组（0–16 个音频文件，host 导入校验并随包存储，经 `/audio/<id>/greetN` 服务，GET 列表返回 greetings URL 数组）
- 无问候音频时用 TTS 问候语池（zh / en 各 5 条）随机播放
- 设置弹窗自动播报开关下新增说明文案
| 提交 | 说明 |
|------|------|
| `edd205c` | feat(dsh-api-balance): 页面刷新随机问候音效 |

## 2026-09-01T09:10:18+09:00

**摘要**：feat(dsh-api-balance): 语音包库管理 + 制作器次级菜单 + 录音可视化浮窗

- host 语音包库化（`packs/<id>/` 多包存储 + `state.json` 激活记录；activate 切换路由、DELETE ?ids= 多选移除（激活包被移除自动切换剩余）、音频按 `/audio/<id>/<key>` 服务）
- 设置页仅保留「导入 + 一个语音包管理按钮」，次级菜单含 packs 视图（列表：点击切换激活、勾选多选移除、入口进制作器）
- creator 视图：语言选择 zh-CN/en/ja、示例文本随语言变化、可跨语言录制，清单 lang 记录包语言；逐段录音 / 导入 / 试听 / 删除；编译下载 / 编译应用
- 录音时右下角弹出可视化浮窗（电平表、计时、示例文本、保存 / 放弃）
- 编辑已导入包仍保留首次覆盖提示
| 提交 | 说明 |
|------|------|
| `398b093` | feat(dsh-api-balance): 语音包库管理 + 制作器次级菜单 + 录音可视化浮窗 |

## 2026-09-01T08:41:48+09:00

**摘要**：feat(dsh-api-balance): 语音包 zip 化 + 录音 / 导入制作器 + 编辑保护

- 语音包改为 zip 压缩包（`manifest.json` + `audio/` 音频文件），host 纯 JS 解析 zip 后落盘 `$DSH_HOME/api-balance-voicepack/`，音频经 prefix 路由服务、全设备共享
- 设置弹窗内制作器支持逐段浏览器录音（MediaRecorder）或导入本地音频文件
- 「打包下载」生成可分享 zip、「编译并应用」立即覆盖应用到本机
- 已导入语音包时首次编辑弹出覆盖提示，会话内确认一次
- 播报片段支持 URL / 内嵌双载体
- 四语文档补语音包格式指南（zip 结构 / manifest / 片段表 / 录音与分享流程）
| 提交 | 说明 |
|------|------|
| `5f4c50a` | feat(dsh-api-balance): 语音包 zip 化 + 录音/导入制作器 + 编辑保护 |

## 2026-09-01T02:36:15+09:00

**摘要**：feat(dsh-api-balance): 播报语音语言与音色跟随 DSH 界面语言

- 播报文本此前已随 t() 跟随界面语言，但语音 lang 与音色偏好硬编码 zh-CN
- 现经 LocaleFace 快照（useSyncExternalStore 订阅 locale 服务的 subscribe/getSnapshot）取当前语言码（zh → zh-CN，其余原样透传）
- 音色按语言前缀匹配
- 组合播报文本的分隔符随语言切换（中文全角 / 其余半角）
- locale 服务不可用时回退 zh
| 提交 | 说明 |
|------|------|
| `11c070b` | feat(dsh-api-balance): 播报语音语言与音色跟随 DSH 界面语言 |

## 2026-09-01T01:51:10+09:00

**摘要**：fix(dsh-api-balance): 语音播报菜单改为从下往上展开

- 菜单默认贴按钮顶边向上展开（translateY(-100%)）
- 上方空间不足（距视口顶部 <8px）时自动回退向下展开
| 提交 | 说明 |
|------|------|
| `7d0c49e` | fix(dsh-api-balance): 语音播报菜单改为从下往上展开 |
| `8d9058c` | docs(dsh): api-balance 语音播报菜单向上展开说明四语同步 |

## 2026-09-01T01:25:25+09:00

**摘要**：feat(dsh-api-balance): 未登录弹窗 + LevelDB 精确解析 + 语音播报下拉

- 浏览器扫描未命中时自动弹窗「前往登录」（新标签页登录 + 轮询快扫自动拾取），手动输入降为弹窗内二级备选
- 已连接显示灰显「✓ 已登录」
- 新增纯 JS LevelDB 表解析精确提取 userToken，快扫 949ms 命中
- 语音播报独立一行 + 下拉菜单，菜单改 portal 固定定位修复滚动裁剪并预热语音引擎
- 令牌来源改两行显示
- 验证：LevelDB 解析实测命中，快扫由失败转为 949ms 命中
| 提交 | 说明 |
|------|------|
| `a3ad3ff` | feat(dsh-api-balance): 未登录弹窗 + LevelDB 精确解析 + 语音播报下拉 |
| `a0e945e` | docs(dsh): api-balance 未登录弹窗/精确解析/语音播报章节四语同步 |

## 2026-08-31T23:55:52+09:00

**摘要**：docs(dsh): api-balance 插件章节四语补齐

- 补全 pcn 语言 dsh.md 的插件章节（本机浏览器自动扫描 / 用量图表 / config 选项）
- 四语 README 插件表描述同步为「浏览器登录态自动扫描获取令牌」语义
| 提交 | 说明 |
|------|------|
| `b912f82` | docs(dsh): api-balance 浏览器自动扫描章节同步 pcn + 四语 README 插件表更新 |

## 2026-08-31T23:50:04+09:00

**摘要**：feat(dsh-api-balance): 本机浏览器自动扫描获取平台 userToken

- host 读取本机 Chromium 系浏览器（Edge / Chrome / Brave / Chromium / Vivaldi / Opera，各 Profile）Local Storage LevelDB，提取 base64 候选（55–85 字符）经 GET /api/v0/users/get_user_summary 校验后落盘
- 本机浏览器登录过平台即可无感获取用量令牌，无需控制台手动粘贴
- 6 小时节流 + 令牌失效（40003/401）立即重扫
- 面板「重新扫描本机浏览器」按钮（RPC args.rescanBrowsers），连接后显示令牌来源徽章（browser / manual）
- 验证：本机 Edge leveldb 31 个候选自动命中真实令牌
| 提交 | 说明 |
|------|------|
| `cec90b0` | feat(dsh-api-balance): 本机浏览器自动扫描获取平台 userToken |

## 2026-08-31T11:50:02+09:00

**摘要**：docs(AGENTS): 泛化 dsh-alpha 会话经验

- buildNpmPackage 三条细则（vendored lock 与 npmDepsHash 自洽 / devDependencies 引用未发布包时 postPatch 纯 sed 剔除且 lock 同源 / 同源多通道仿 ruyi 薄包装）
- 初次启动审计前 git fetch 对齐远端
- 新增本机部署章节（path-input 重锁、nixos apply 命令、--no-link 产物回收）
| 提交 | 说明 |
|------|------|
| `86a7c3f` | docs(AGENTS): 泛化 dsh-alpha 会话经验 — buildNpmPackage 细则与本机部署约定 |
| `396c3ae` | docs(MAINTENANCE): record 2026-08-31 — AGENTS.md 泛化 dsh-alpha 会话经验 |

## 2026-08-31T11:31:42+09:00

**摘要**：dsh-alpha 上线灾难恢复

- 修复 alpha 反代 Host 语义（web UI 入口按 Host authority 的 session cookie 认证，重写 Host 致永远 401）
- 修复 dsh-api-balance 的 shared RPC interceptor 冲突（`/api` 已被 typert-gateway 独占，改用精确 fetch route 自实现 RPC envelope）
- dsh-nixos-shell 的 dsh-tools 通道对齐
- 新增 launchUrlFile（局域网启动 URL 捕获）与 reverseProxy.autoAuth（mod_magnet 免认证注入，仅限可信局域网）模块选项
- 四语文档补全局域网访问章节
- 验证：反代与 RPC 修复后 web UI 入口与插件 RPC 恢复可用
| 提交 | 说明 |
|------|------|
| `222ece4` | fix(pkgs): dsh-api-balance / dsh-nixos-shell alpha 兼容 |
| `bd4cdb1` | feat(dsh-module): launchUrlFile + autoAuth + alpha 反代 Host 语义修复 |
| `a2fe5f3` | docs(dsh): 四语文档补全局域网访问/免认证/alpha 插件兼容章节 |
| `1176553` | docs(AGENTS): 模块章节标注 dsh alpha 语义与插件兼容经验 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-nixos-shell | dsh-tools `0.1.1-rc.2` | dsh-tools `0.1.2-alpha.2` |
| 　 | npmDepsHash | `sha256-uOQ3Dq...` → `sha256-bAXZCi...` |

## 2026-08-31T07:23:07+09:00

**摘要**：dsh-alpha 0.1.2-alpha.2 — 新包

- 新包，npm `alpha` dist-tag 开发通道
- dsh 重构为 ruyi 式薄包装（version/hash/npmDepsHash/lockFile 可覆盖）
- postPatch 纯 sed 删除 tarball 的 devDependencies（引用未发布的 monorepo 内部包，registry 404）
- 补丁目标文件加存在性守卫
- 四语文档新增版本通道章节，README 软件表四语补齐 dsh-alpha 行
- 后续修复 vendored lock 与 npmDepsHash 对齐（npm fixup 平台条目缺失致主构建报 out of date）
- 验证：包构建通过，lock 对齐后主构建不再报 out of date
| 提交 | 说明 |
|------|------|
| `88a2dfc` | feat(dsh): 多版本通道 — 新增 dsh-alpha 0.1.2-alpha.2 |
| `33bff25` | docs(dsh): 四语文档新增版本通道章节（dsh-alpha） |
| `095d002` | docs(MAINTENANCE): record 2026-08-31 — dsh-alpha 新包 |
| `a97fffd` | fix(pkgs): dsh-alpha vendored lock 与 npmDepsHash 对齐 |
| `d9a83f8` | docs: README 软件表新增 dsh-alpha 行（四语） |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-alpha | 新增 `0.1.2-alpha.2` | |
| 　 | source hash | `sha256-W/Biom...` |
| 　 | npmDepsHash | `sha256-bJMeVS...` |

## 2026-08-31T07:05:44+09:00

**摘要**：godot-ai 3.2.4 — bugfix 修复与四语文档版本号同步

- 自更新恢复序列化、配置写入加固、路径校验与冷启动修复（v3.2.1~v3.2.4 均为 bugfix）
- 四语文档版本号同步
| 提交 | 说明 |
|------|------|
| `c30fc17` | chore(pkgs): bump godot-ai 3.2.0 → 3.2.4 |
| `e4b9981` | docs(MAINTENANCE): record 2026-08-31 — godot-ai 3.2.0 → 3.2.4 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| godot-ai | 3.2.0 | 3.2.4 |
| 　 | source hash | `sha256-ImKAsI...` → `sha256-Uo6GvE...` |

## 2026-08-27T09:19:59+09:00

**摘要**：opencode-telegram 0.24.1 等四包 — 上游更新与文档同步

- opencode-telegram 0.24.1：新增韩语界面、`/opencode_stop` 忙时可终止卡死的本地 OpenCode 进程、语音转写以引用块显示、Telegram 临时错误安全重试防回复丢失或重复、流式编辑节流自适应
- mcp-searxng 2.1.0：显式选择引擎时逐引擎校验 time-range 能力、不支持时快速失败并给出可操作错误
- godot-ai 3.2.0：custom_tools 第三方 addon 工具注册、CLI 注册范围可选、新增 DeepSeek Harness 客户端支持
- ruyi-beta 0.52.0-beta.20260824：beta 通道上游更新
- 四语文档同步，nix flake check 通过
| 提交 | 说明 |
|------|------|
| `7d57bfa` | chore(pkgs): bump opencode-telegram 0.24.0 → 0.24.1 |
| `85b813e` | chore(pkgs): bump mcp-searxng 2.0.0 → 2.1.0 |
| `0fe16db` | chore(pkgs): bump godot-ai 3.1.5 → 3.2.0 |
| `b26d013` | chore(pkgs): bump ruyi-beta 0.51.0-beta.20260714 → 0.52.0-beta.20260824 |
| `e88e284` | docs(MAINTENANCE): record 2026-08-27 — 四包上游更新 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.24.0 | 0.24.1 |
| 　 | source hash | `sha256-uZaAyt...` → `sha256-uWhSMq...` |
| 　 | npmDepsHash | `sha256-Vh/e3S...` → `sha256-5ndUrB...` |
| mcp-searxng | 2.0.0 | 2.1.0 |
| 　 | source hash | `sha256-zakEU/...` → `sha256-Zq6oKX...` |
| 　 | npmDepsHash | `sha256-4WUOJJ...` → `sha256-YIH/5R...` |
| godot-ai | 3.1.5 | 3.2.0 |
| 　 | source hash | `sha256-zqZnKk...` → `sha256-ImKAsI...` |
| ruyi-beta | 0.51.0-beta.20260714 | 0.52.0-beta.20260824 |
| 　 | hash | `sha256-saOsHG...` → `sha256-vxu9Ah...` |

## 2026-08-27T07:28:58+09:00

**摘要**：feat(dsh-api-balance): 面板刷新按钮 — 一键强制刷新余额与官方用量

- 面板头部标签行右侧新增刷新按钮（↻）：点击经 queryBalance(true) 强制绕过 host 端 30s TTL 缓存重新拉取余额 + 官方用量（按日/按月图表同步更新）
- 加载中按钮禁用并显示旋转动画（复用 dshAbSpin）
- 中英双语文案（刷新数据 / Refresh data）
- 验证：构建通过、经稳定挂载点零重启部署（424 代）后 dsh 重启生效
| 提交 | 说明 |
|------|------|
| `e864b58` | feat(dsh-api-balance): 面板刷新按钮 — 一键强制刷新余额与官方用量 |

## 2026-08-27T07:28:49+09:00

**摘要**：fix(dsh-nixos-shell): 分离结果诚实语义 + `systemctl restart dsh` 自动分离

- 此前 rebuild 经 systemd-run 交接后透传其 exit 0，工具结果看似「构建成功」而真实结果未知
- 现分离命令返回 `detached: true` + `detachedUnit` + `note`、exitCode 为 null——交接成功 ≠ 构建成功，真实结果须经 nixos_cli op=journal / op=generations 验证
- 分离谓词扩展至 `systemctl restart dsh`（插件更新需显式重启生效），同样自动分离、先于重启返回
- 验证：分离式 dsh 重启落地（RESTARTED_EXIT=0）、插件变更 rebuild（424/425 代）零重启零中断
| 提交 | 说明 |
|------|------|
| `0c7b7f6` | fix(dsh-nixos-shell): 分离结果诚实语义 + systemctl restart dsh 自动分离 |

## 2026-08-27T07:28:39+09:00

**摘要**：feat(module): dsh 插件稳定挂载点 — 插件更新零重启激活

- 此前插件包烧进 dsh/sudo unit，插件更新即在激活阶段重启 dsh 与 sudo socket（在途工具调用、经守护执行的 rebuild 被杀，socket 不能自复）
- 改稳定挂载点：activation script 每次 switch/boot 把 `/run/dsh/current`（dsh 含插件树）与 `/run/dsh/nixos-shell` 翻到当前代 store 路径（GC 安全），unit 只引用稳定路径，激活零重启零 socket 中断
- 配套：插件更新需显式 `systemctl restart dsh` 生效
- 验证：423 代部署；424/425 代插件变更 rebuild 后 dsh 与 socket 的 ActiveEnterTimestamp 未变
| 提交 | 说明 |
|------|------|
| `dfce302` | feat(module): dsh 插件稳定挂载点 — 插件更新零重启激活 |

## 2026-08-27T04:07:27+09:00

**摘要**：fix(dsh-nixos-shell): sudo 协议 v3 + rebuild 自动分离（三类缺陷修复）

- v2 协议把连接断开当取消——rebuild 的 switch 阶段重启 dsh.service 致客户端消失，守护中途杀死 switch（部分激活）
- v3 改为显式带内取消行，对端消失时子进程分离续跑至完成
- 取消/超时改为进程组击杀（spawn detached + kill(-pid)），只杀 shell 包装会留下孤儿孙进程卡死守护
- 超时上限放宽至 6h
- rebuild 自动分离到 systemd-run 瞬态单元（独立 cgroup），避免 socket stop/start 连带杀掉 switch
- 验证：后台 sudo 即返 job id、job_kill 整组击杀无孤儿、真实 rebuild 经分离单元部署成功且 socket 自动恢复
| 提交 | 说明 |
|------|------|
| `ead3526` | fix(dsh-nixos-shell): sudo 协议 v3 + rebuild 自动分离 |

## 2026-08-27T04:07:15+09:00

**摘要**：feat(dsh-api-balance): 充值卡片弹窗替代 iframe + 余额不足语音提醒

- top_up 页面被 WAF 拦截（"Max challenge attempts exceeded"），iframe 弹窗无法工作
- 改为居中卡片弹窗（新窗口按钮 + 右上角关闭按钮），不跳转页面
- 新增余额不足语音提醒：余额低于阈值（10 CNY/USD）时经 Web Speech API 播报提示，15 分钟轮询 + 30 分钟冷却
- 面板内开关（balance.speechOn/Off），中英双语文案
- 验证：部署后特征 grep（TopupModal/speechOn/announceHunger）确认生效
| 提交 | 说明 |
|------|------|
| `eeffc49` | feat(dsh-api-balance): 充值卡片弹窗替代 iframe + 余额不足语音提醒 |

## 2026-08-26T11:44:45+09:00

**摘要**：dsh-api-balance 0.1.0 — 新包（用量 / 余额标签切换）

- webui 用量圆圈（发送按钮左侧的上下文已用显示）弹出面板添加「用量 / 余额」标签切换
- 「用量」保留原有上下文占用与细分
- 「余额」展示当前 API KEY 账户信息（key 尾号、余额是否充足、各币种总余额 / 充值余额 / 赠送余额，数据来自 DeepSeek 官方 GET /user/balance，host 端 30s TTL 缓存）
- host 端经 connection.rpc.intercept 注册包私有 endpoint，client 端在 conversation.input.right 注册视觉兼容的替代圆圈并隐藏原按钮
- 验证：RPC 实测返回 CNY 271.07 余额，client bundle 正常服务
- 四语文档同步，nix flake check 通过
| 提交 | 说明 |
|------|------|
| `95998cd` | feat(dsh): 新增 dsh-api-balance 插件 — webui 用量圆圈「用量 / 余额」标签切换 |
| `db721ba` | docs(MAINTENANCE): record 2026-08-26 — dsh-api-balance 0.1.0 新包 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 　 | 新增 v0.1.0 |

## 2026-09-11T12:54:29+09:00

**摘要**：fix(dsh/module): 移除 allowLanSettings 的 $host.state.getSnapshot() 补丁

- dsh ≥ 0.1.5 的 $host 客户端服务不暴露 state，旧补丁在 client-ui-settings apply 时访问 undefined.getSnapshot 致整个前端白屏（Failed to load plugins）
- 模块不再强制 override allowLanSettings=true（恢复上游行为）
- packages/dsh.nix 的补丁改为无条件 "host"
- 验证：首页 200，llm/listProviders 返回 DeepSeek 提供方
| 提交 | 说明 |
|------|------|
| `06a5ce1` | fix(dsh): allowLanSettings — drop $host.state.getSnapshot() (undefined) |
| `155b09b` | fix(module): dsh — drop allowLanSettings override (state.getSnapshot undefined) |

## 2026-09-11T06:15:33+09:00

**摘要**：fix(preset): dsh persona text → prefix（0.1.5-alpha.2 兼容）

- dsh-persona 插件 Config 的 text 改为 prefix（必填）+ suffix（可选）
- 旧 agent preset（nixos-mode / maintenance-mode / 本机 ocean-spiral）仍写 text，persona 加载失败（$.prefix missing required value）→ session/create 失败 → settings / llm 提供方目录 / session 历史全部无法加载
- 修复：两预设 persona config 改为 prefix，本机三个 preset 同步
- 验证：session/create 返回 ok:true + sessionId
| 提交 | 说明 |
|------|------|
| `772abf8` | fix(preset): dsh persona text → prefix for 0.1.5-alpha.2 |

## 2026-08-27T01:30:33+09:00

**摘要**：fix(module): dsh watchdog — switch-to-configuration 失败后的自动拉起

- nixos-rebuild 的 switch-to-configuration 在「stop dsh → start dsh」之间偶发失败（exit 101）会把 dsh 留在 inactive
- systemd 主动 stop 不触发 Restart=always，反代因此长期 503
- 新增 dsh-watchdog timer（15s）检测 inactive 时自动 systemctl start
- 实测 stop 后 20 秒内自动恢复
| 提交 | 说明 |
|------|------|
| `3ed6aa7` | fix(module): dsh watchdog — auto-restart after switch-to-configuration failure |

## 2026-08-24T15:44:06+09:00

**摘要**：fix(overlay): llama-cpp-rocm v0.2.0 语义化版本 tag 适配

- llama.cpp 上游 release tag 从 build number（b10549）切换为语义化版本（v0.2.0）
- 旧 overlay 只剥离 b 前缀，nixpkgs 把 v0.2.0 传入 LLAMA_BUILD_NUMBER，生成 `int LLAMA_BUILD_NUMBER = v0.2.0;` 致 C++ 编译失败（too many decimal points），阻塞系统 rebuild 与 dsh 升级
- 改为同时剥离 v/b 前缀并追加 -DLLAMA_BUILD_NUMBER=0
- 验证：llama-cpp-0.2.0 构建成功且 llama-cpp.service 正常运行
| 提交 | 说明 |
|------|------|
| `1a1b9d1` | fix(overlay): llama-cpp-rocm — handle v0.2.0 semantic version tag |

## 2026-08-24T15:20:16+09:00

**摘要**：fix(pkgs): dsh 崩溃修复 — 忽略 dispose 竞态

- cordis-plugin-timer（上游 1.1.3 未修）在 Context dispose 时 pending 的 ctx.timeout() promise reject "Context has been disposed"，未 catch 即 unhandled rejection
- 被 dsh-app-boot 的 installFailLoud 捕获后 process.exit(1)（rc.6/rc.7/rc.8/0.1.1-rc.2 均受影响）
- patch installFailLoud 仅忽略该错误，其余 fatal rejection 照常退出
- 验证：patch 落入 0.1.1-rc.2 产物（dsh-app-boot/lib/index.js:1047）
| 提交 | 说明 |
|------|------|
| `6e862b6` | fix(pkgs): dsh — ignore Context-disposed dispose race in installFailLoud |

## 2026-08-24T14:27:47+09:00

**摘要**：codewhale 0.9.11、mcp-searxng 2.0.0、dsh 0.1.1-rc.2 — 上游更新

- codewhale 0.9.11：上游 v0.9.9 起 TUI 资产更名 codewhale-tui → codew，包内安装 codew 并保留兼容别名
- riscv64 源码构建同步 Cargo.lock（687→690 条目）
- mcp-searxng 2.0.0：大版本升级（要求 Node.js ≥ 22，nixpkgs 默认满足，CLI 入口不变）
- dsh 0.1.1-rc.2：vendored lock 重新生成（560 个 resolved 条目），内置插件清单与 rc.8 完全一致（137 条）
- dsh-nixos-shell 依赖 dsh-tools 对齐 0.1.1-rc.2
- 四语文档同步，nix flake check 通过
| 提交 | 说明 |
|------|------|
| `17bf588` | chore(pkgs): bump codewhale 0.9.8 → 0.9.11 |
| `065d261` | chore(pkgs): bump mcp-searxng 1.15.0 → 2.0.0 |
| `c0c8e3a` | chore(pkgs): bump dsh 0.1.0-rc.8 → 0.1.1-rc.2 |
| `bec4c3d` | chore(pkgs): dsh-nixos-shell dep dsh-tools 0.1.0-rc.7 → 0.1.1-rc.2 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.9.8 | 0.9.11 |
| mcp-searxng | 1.15.0 | 2.0.0 |
| dsh | 0.1.0-rc.8 | 0.1.1-rc.2 |
| dsh-nixos-shell | dsh-tools 0.1.0-rc.7 | dsh-tools 0.1.1-rc.2 |

## 2026-08-22T00:03:28+09:00

**摘要**：docs(dsh): 0.1.0-rc.8 文档同步与本机默认模型设定

- 四语 dsh.md 版本行（rc.6 → rc.8）与「插件清单」代码块（137 条 entry id 映射，自 rc.8 构建产物提取）同步
- `/etc/nixos` 本地配置新增 `settings.agent-default-model`（deepseek-v4-pro + reasoningEffort=max）作新会话默认
- DeepSeek API 权威模型列表仅 flash/pro/flash-vision-exp，无 "pro-max" id，Pro+Max 思考即当前最高档
- rc.8 上 nixos/maintenance 两预设挂载校验通过，`nix flake check` 通过
| 提交 | 说明 |
|------|------|
| `535567d` | docs(dsh): sync version and built-in plugin inventory for 0.1.0-rc.8 (137 entries) in four languages |

## 2026-08-21T21:51:26+09:00

**摘要**：docs: README 插件章节扩充与作者 DSH 信息补充

- 「插件」章节在 dsh-nixos-shell 之外补充「Agent 预设」表（NixOS模式/维护模式，随插件分发、经 `nixkits.dsh.presets` seed-once），DSH 组件与软件独立展示
- 作者章节「小爪」条目加入 DSH 生态信息（dsh-nixos-shell 插件与两个 Agent 预设）
- AGENTS.md 的插件独立展示规则拓宽为「dsh-* 组件（插件与 Agent 预设）」
- 四语同步
| 提交 | 说明 |
|------|------|
| `4277b51` | docs: list DSH agent presets in the README plugins section and add DSH ecosystem info to the credits paw entry |

## 2026-08-21T00:01:46+09:00

**摘要**：fix(dsh-nixos-shell): 工具描述明示 tools 白名单

- 验收非阻塞发现：固定 POSIX 工具白名单未在工具描述中明示
- 白名单改为从 TOOL_PACKAGES 映射动态生成（27 个名字，含 python 别名），写入 `tools` 参数描述，工具描述指向参数
- 四语文档同步完整列表
- 验证：27 项全在参数描述中、工具描述含指向、`nix flake check` 通过
| 提交 | 说明 |
|------|------|
| `30d0c40` | fix(dsh-nixos-shell): surface the tools whitelist in the parameter description |

## 2026-08-20T20:12:33+09:00

**摘要**：fix(dsh-nixos-shell): 现代 rebuild 命令更正为 `nixos apply`

- 实测 nixos 0.16.1-dev 无 `rebuild` 子命令（`nixos --help` 列出 activate/apply/generation 等）
- 交接卡与插件 recommendedRebuild/命令对照表/门控提示词中的 `nixos rebuild switch` 表述错误，统一更正为 `nixos apply /etc/nixos`（或传统 `sudo nixos-rebuild switch --flake /etc/nixos`）
- 验证：`nix flake check` 通过，系统部署改用 `nixos apply` 实测成功
| 提交 | 说明 |
|------|------|
| `caa7d41` | fix(dsh-nixos-shell): correct the modern rebuild command to 'nixos apply' |

## 2026-08-20T20:10:08+09:00

**摘要**：fix(dsh-nixos-shell): NixOS模式验收 P1–P4 修复

- P1（高）tools 引导包装由 `bash -lc` 改为 `bash -c`：登录壳的 /etc/profile 链重置 PATH、丢弃 nix shell 注入，sudo 路径共用同一 wrapper 一并修复（对照：`-c` 得 Python 3.14.7、`-lc` 得 command not found）；映射同步修正 grep→gnugrep、find→findutils
- P2 generations 新增 `limit`（默认 20、上限 200、新→旧）
- P3 journal 的 unit 允许 `*`/`%` 通配，尾随 `@` 自动补 `*`
- P4 命名统一 nixos-cli → nixos 命令
- 四语文档 op 表同步，`nix flake check` 通过
| 提交 | 说明 |
|------|------|
| `a591826` | fix(dsh-nixos-shell): P1-P4 acceptance fixes |

## 2026-08-20T19:33:51+09:00

**摘要**：fix(dsh-nixos-shell): 提示节字段改用 text

- dsh-system-prompt 的插值器读取 `input.text`，此前以 `content` 注册的节导致真实 NixOS模式会话崩溃（Cannot read properties of undefined (reading 'indexOf')），mount 校验覆盖不到这一真实会话路径
- 修复 nixos-gate（guidance/gate 两节）与 maintenance-skills（workflow 节）共 3 处 `content` → `text`
- 验证：mock 断言 text 字段 + 无未闭合 `{{`；真实 systemPrompt 服务 assemble 无崩溃；系统预构建通过
| 提交 | 说明 |
|------|------|
| `476e9dc` | fix(dsh-nixos-shell): use the PromptSection text field instead of content |

## 2026-08-20T19:05:44+09:00

**摘要**：feat(dsh-nixos-shell): 维护模式 agent 预设

- 新包内入口 maintenance-skills：apply 时从构建期嵌入的仓库 skills/ 树注册运行时技能 write-project-docs、write-maintenance-log 与全部 translate-* 语言扩展（自动发现）
- 注入仓库维护工作流提示词；包内 postPatch `cp -r skills → skills-embedded`
- 预设 presets/maintenance-mode（id `maintenance`，基于 NixOS模式组合 + maintenance-skills 行）随包分发；模块新增 `nixkits.dsh.presets.maintenanceMode`
- 验证：mock 注册 3 技能 + 工作流提示节全过，系统预构建通过
| 提交 | 说明 |
|------|------|
| `f6c749e` | feat(dsh-nixos-shell): 维护模式 agent preset — maintenance-skills entry, presets/maintenance-mode, module presets.maintenanceMode seed |

## 2026-08-20T18:30:46+09:00

**摘要**：feat(dsh-nixos-shell): NixOS模式 agent 预设

- 新子路径入口 nixos-gate：会话初始化时校验宿主为 NixOS（/etc/NIXOS 或 os-release ID=nixos）
- 非 NixOS 时经 tools.guard 拒绝一切工具执行并注入拒绝提示词，NixOS 时注入开发指南提示词
- 预设 presets/nixos-mode（id `nixos`，基于创造模式 cordis 组合 + 其技能目录 + 追加 nixos-gate/nixos-shell 两行）随包分发
- 模块新增 `nixkits.dsh.presets.nixosMode`，preStart seed-once 写入 `$DSH_HOME/.agent-presets/nixos`
- 验证：包构建、门控语法检查、系统预构建通过
| 提交 | 说明 |
|------|------|
| `aaa21cb` | feat(dsh-nixos-shell): NixOS模式 agent preset — nixos-gate entry, presets/nixos-mode, module presets.nixosMode seed |

## 2026-08-20T18:24:04+09:00

**摘要**：docs: README 插件独立章节与 AGENTS.md 更新

- dsh-* 插件从「软件」表移入 README 新增「插件」章节（四语同步），不再与软件混合展示
- AGENTS.md 新增插件独立展示约定与「dsh 不是技能安装目标」规则
- 已批准清理落地（本机）：移除 ~/.bashrc 中 bash-completion 的陈旧 store 绝对路径块
- ~/.profile 的 hm-session-vars 改指 /etc/profiles/per-user/kix 稳定路径
- 删除 ~/.dsh/skills 旧文件（nixos_cli audit-store-paths 复测 0 残留）
| 提交 | 说明 |
|------|------|
| `57ae6b5` | docs: list dsh-* plugins in a dedicated README plugins section (4 langs); AGENTS.md plugin-listing + dsh-skill-target rules |

## 2026-08-20T17:56:21+09:00

**摘要**：refactor(dsh-nixos-shell): 包名修正 nixos-shell → dsh-nixos-shell

- 软件包名（pname/目录/flake 输出/overlay/CI workflow/文档）统一为 `dsh-nixos-shell`（pkgs.dsh-nixos-shell）
- dsh 内显示名保持 `nixos-shell`（组合行 entry id、插件 name、工具名 nixos_shell/nixos_cli 不变）
- 验证：包构建通过；部署侧引用已同步
| 提交 | 说明 |
|------|------|
| `26a844e` | refactor(dsh-nixos-shell): rename package nixos-shell -> dsh-nixos-shell |

## 2026-08-20T17:46:44+09:00

**摘要**：feat(nixos-shell): NixOS 场景能力整合为单一插件；refactor: 废弃技能插件化设计

- 新包 nixos-shell（@kihara777/dsh-nixos-shell 0.1.0）注册 2 个工具：nixos_shell 执行器（NixOS PATH 注入 + bash 回退 + `tools` 引导缺失 POSIX 工具 + sudo 守护路由）与 nixos_cli 只读诊断（capabilities 等），需求源自 nixos-modern-cli 技能场景。
- 移除 dsh-nix-shell 与 dsh-skill-nixkits（7 技能插件设计废弃），CI/文档更替。
- 修复 generations：进程内只读列出（`nix-env` 非 root 被拒）。
验证：13 项功能套件全过；系统预构建通过。

| 提交 | 说明 |
|------|------|
| `395d8b4` | feat(nixos-shell): consolidate NixOS scenario capabilities into one plugin |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| nixos-shell | — | 新增 v0.1.0 |

## 2026-08-20T16:40:16+09:00

**摘要**：fix(dsh): 服务 HOME 指向真实用户家目录

- git 的 gh credential helper 按 `$HOME/.config/gh` 解析凭据，模块此前将服务 HOME 设为 dshHome（/home/kix/.dsh），沙箱内 git push 找不到凭据
- 改为 `users.users.<user>.home`（缺省回退 dshHome），代理继承用户自身的工具上下文（git/gh 凭据、~/.gitconfig、npm/ssh 配置）
- DSH_HOME 仍为 dsh 状态根不受影响
- 验证：推送积压提交全部成功；系统预构建通过
| 提交 | 说明 |
|------|------|
| `514831c` | fix(dsh): point service HOME at the real user home — git's gh credential helper resolves ~/.config/gh from $HOME, so HOME=dshHome left sandbox pushes without credentials |

## 2026-08-20T16:13:40+09:00

**摘要**：fix(dsh-nix-shell): sudo 执行器 PATH 合并顺序

- 套接字激活的模板单元继承 systemd 管理器默认 PATH（coreutils/findutils/grep/sed/systemd 的 store 路径）
- `...process.env` 在显式 NixOS PATH 之后展开将其覆盖，守护进程内 ps、nixos-rebuild 等 profile 工具全部不可解析
- 改为继承 env 在前、显式 NixOS profile PATH 在后（请求 env 仍最后合并）
- 验证：PATH 以 /run/current-system/sw/bin 开头，ps 与 nixos-rebuild 均解析成功
| 提交 | 说明 |
|------|------|
| `63b2576` | fix(dsh-nix-shell): put the explicit NixOS profile PATH after the inherited env — socket-activated template units inherit systemd's manager-default PATH, which overrode the executor PATH and left profile tools (ps, nixos-rebuild) unresolvable |

## 2026-08-20T16:01:28+09:00

**摘要**：docs(dsh): 使用示例与实际模块行为同步

- 手工组合行示例补上 `- insert:` 包裹与警告（裸 `- id:` 行只补丁已有条目）
- 技能插件文档修正全部 7 个 entry id（`skill-nixkits-<id>` 前缀此前缺失）与 disabled 示例 id
- dsh 文档安装章节改为模块式安装（原 `nixkits.extraPackages` 已不存在）并补充二进制缓存说明
- 四语同步
| 提交 | 说明 |
|------|------|
| `6074661` | docs(dsh): sync usage examples with module reality — insert-op wrapping for manual rows, corrected skill entry ids, module-based install + cache note |

## 2026-08-21T23:02:33+09:00

**摘要**：chore(pkgs): dsh 0.1.0-rc.7 → 0.1.0-rc.8 — 遗留升级收尾

- src hash 与 npmDepsHash 填入真实值
- package-lock.json 重新生成（旧 lock 缺失 120 个 entries，含 dsh-invariants）
- 验证：rc.8 构建成功、randomUUID 回退 patch 生效、with-plugins 变体正常、服务启动无插件加载错误
- with-plugins 仅注入 dsh-nixos-shell
| 提交 | 说明 |
|------|------|
| `a7cbe3e` | chore(pkgs): bump dsh 0.1.0-rc.7 → 0.1.0-rc.8 |

## 2026-08-21T22:11:28+09:00

**摘要**：fix(module): dsh 崩溃韧性 — Restart=always + RestartSec 5s

- dsh 上游有已知崩溃 bug（cordis-plugin-timer 的 Context disposed，rc.6 实测约 13 小时触发），rc.7/rc.8 的 cordis-plugin-timer 依赖版本不变（^1.1.3），bug 仍存
- 崩溃时 lighttpd 反代随即返回 503 直到 systemd 拉起
- 改为 Restart=always（on-failure 不覆盖 exit 0 退出路径）+ 重启间隔 5s，把中断窗口压到最小
| 提交 | 说明 |
|------|------|
| `ed7e9d5` | fix(module): dsh Restart=always + faster RestartSec (crash resilience) |

## 2026-08-20T11:08:08+09:00

**摘要**：fix(module): dsh 插件 ESM 解析 — $DSH_HOME/node_modules 符号链接

- dsh 的 cordis-plugin-loader 以 profile 目录（$DSH_HOME/profiles/web）为解析基准向上查找 node_modules
- 插件已注入 dsh 的 store 树，但 store 不在 profile 的 node_modules 链上，import 报 ERR_MODULE_NOT_FOUND，启动即崩溃
- preStart 把注入的 @kihara777 scope 符号链接到 $DSH_HOME/node_modules 让 Node 可解析；realpath 回 store 树后，@deepseek-ai/* peer deps 仍在同树内可解析
- 实测 skills + nix-shell 插件加载成功
| 提交 | 说明 |
|------|------|
| `044b891` | fix(module): dsh plugin ESM resolution via DSH_HOME/node_modules symlink |

## 2026-08-20T10:33:26+09:00

**摘要**：fix(dsh): insert 块缩进修复 — 每包一个 insert 操作

- 嵌套 '' 字符串按自身最小缩进剥离，插件条目被顶回第 0 列，变成 `- insert:` 的兄弟补丁操作而非子条目（dsh 报 patch: entry … not found + id is required for non-insert patches，8 行再次全部未挂载）
- 改为每包一个 insert 操作、条目对象与 `- insert:` 行共处同一字符串（列 2/4 缩进），模块注释记录该陷阱
- 验证：dump-config 零 stderr、8 行进入组合树
| 提交 | 说明 |
|------|------|
| `988dc6d` | fix(dsh): emit one insert op per plugin entry in a single string — nested '' strings dedent to column 0, turning entry objects into sibling patch ops |

## 2026-08-20T10:21:46+09:00

**摘要**：fix(dsh): 生成行改用 insert 动词 — 裸 `- id:` 行只补丁已有条目

- cordis.patch.yml 中裸 `- id:` 行只补丁已有条目，新增插件条目被 dsh 丢弃，8 个插件行全部未挂载（dump-config 验证）
- 插件包注入虽成功，但组合树中没有条目 → 工具 nix_shell 与 7 技能插件均未注册
- 修复：模块生成的 plugins.packages 行包裹在 `- insert:` 操作下（与 extraPatch 的 MCP 行同构）
- 验证：dump-config 零 stderr、8 行全部进入组合树
| 提交 | 说明 |
|------|------|
| `3d0433d` | fix(dsh): wrap generated plugin rows in the insert op — bare - id: rows only patch existing entries, so dsh dropped every new entry with 'patch: entry … not found' |

## 2026-08-20T09:45:59+09:00

**摘要**：fix(dsh): 多插件注入失败 — GNU tar 恢复目录模式致 scope 目录不可写

- GNU tar 解包结束后恢复归档中的目录模式（store 树为 0555），前一个插件创建的 scope 目录（@kihara777/）对下一个插件不可写，第二个插件起报 Cannot mkdir: Permission denied
- 单插件场景不触发，首次真实系统构建暴露
- 改为每次插件解包后立即 chmod -R u+w
- 验证：系统 toplevel 完整构建成功，dsh-nix-shell 与 7 技能全部注入
| 提交 | 说明 |
|------|------|
| `b03a386` | fix(dsh): chmod node_modules after each plugin injection — GNU tar restores archived dir modes (0555) after extraction, leaving the scope dir created by the previous plugin unwritable for the next one |

## 2026-08-20T08:12:57+09:00

**摘要**：fix(rcc-fix): desktop 条目重命名兼容

- asusctl 6.4.0 将桌面条目重命名为 org.opengamingcollective.rog-control-center.desktop，nixpkgs 的 programs.rog-control-center autoStart（makeAutostartItem）仍复制旧文件名 rog-control-center.desktop，系统构建失败（cp cannot stat）
- rcc-fix overlay 在 asusctl postInstall 中提供旧文件名符号链接
- 验证：以本机 nixpkgs 修订（0ae2bc1）构建 makeAutostartItem { name = "rog-control-center"; package = asusctl } 成功（EXIT=0）
| 提交 | 说明 |
|------|------|
| `650f6f7` | fix(rcc-fix): compat symlink for renamed desktop entry — nixpkgs programs.rog-control-center autoStart copies the pre-6.4.0 filename |

## 2026-08-20T07:41:45+09:00

**摘要**：fix(rcc-fix): 补丁重基适配 asusctl 6.4.0

- nixpkgs 前进后 asusctl 6.3.7 → 6.4.0，rcc-fix.patch 第 4 hunk 失效（系统构建失败）
- 上游重构了该区域（`is_old_laptop`/`retain` 替代原 push 块，else 分支过滤已被上游吸收），补丁仅保留越界防护替换（`names[(*z) as usize]` → filter_map 边界检查 + warn）；其余 hunk 无需变更
- 验证：git apply --check 对 6.4.0 源码全 hunk 通过；以本机 nixpkgs 修订（0ae2bc1）构建 asusctl 成功（EXIT=0）
| 提交 | 说明 |
|------|------|
| `ce216c7` | fix(rcc-fix): rebase patch hunk 4 for asusctl 6.4.0 — upstream is_old_laptop/retain restructure, else-filter absorbed upstream |

## 2026-08-20T06:27:40+09:00

**摘要**：feat(dsh-nix-shell): 外部 sudo 守护集成（0.2.0）

- 插件探测守护套接字（config `sudoSocketPath` / 环境变量 `NIXKITS_SUDO_SOCKET`），存在即启用 `sudo`/`justification` 参数；`sudo: true` 请求整单经 Unix 套接字路由至守护执行，`justification` 必填回显
- 守护 = systemd 套接字激活的 root 执行器（nixkits-sudo@.service + nixkits-sudo-exec.js，单请求 JSON 协议）；访问控制边界 = 套接字文件 `0600`
- 模块新增 nixkits.dsh.sudo（enable/socketPath/package）生成 socket+service 并注入环境变量
- 验证：门控、路由往返通过
| 提交 | 说明 |
|------|------|
| `ef4bcfc` | feat(dsh-nix-shell): external sudo daemon integration — socket-activated root executor, init-time detection, sudo routing |

## 2026-08-20T06:02:50+09:00

**摘要**：refactor(skills): NixKits 技能重写为原生 DSH 技能插件 — 新包 @kihara777/dsh-skill-nixkits（零运行时依赖）

- 7 个技能各为包内一个子路径插件条目，运行时经 ctx.skills.register 注册内容（runtime provider，rank 250）
- SKILL.md 保留在 skills/ 为单一来源（文档流水线自动发现契约不变）
- 模块 skills.enable 自动生成 7 条组合行（skill-nixkits-<id> → dsh-skill-nixkits/<id>），取代原目录注入（nixkits-skills 包与 bundledSkillDir）
- 验证：7 插件 mock 注册、子路径导入均通过
- CI 新增 x86_64/aarch64 构建
| 提交 | 说明 |
|------|------|
| `7393b95` | feat(dsh): rewrite NixKits skills as native skill plugins — dsh-skill-nixkits package, one plugin entry per skill |

## 2026-08-20T05:27:48+09:00

**摘要**：feat(dsh): 内置 bash 工具 NixOS 修复 + 第三方插件包 + 部署级技能

- 模块为 dsh 服务注入完整 PATH（systemd 默认 PATH 无 bash，内置 bash 工具报 spawn bash ENOENT）
- 新增 dsh-nix-shell 包（@kihara777/dsh-nix-shell，NixOS 感知 shell 工具插件）与 nixkits-skills 包（技能目录 bundle）
- 模块新增 plugins.packages（tar 解包注入 node_modules，并自动生成组合行）与 skills.enable（skill-filesystem bundledSkillDir rank 600）
- CI 新增 dsh-nix-shell x86_64/aarch64 构建
- 端到端验证：注入树内 IMPORT-OK
| 提交 | 说明 |
|------|------|
| `69eedd4` | feat(dsh): PATH fix + third-party plugin packages + bundled skills — L1/L2/L3/路径A |
| `55664ed` | docs: dsh-nix-shell package docs + dsh module options + README rows (4 languages) |

## 2026-08-19T20:39:47+09:00

**摘要**：fix(ci): ci-summary 徽章卡在 failing

- jq 管道先过滤 failure 再按 workflow 分组取最新，旧失败会永远掩盖后续成功（Build codewhale (riscv64) 修复后徽章仍红）
- 改为先分组取每 workflow 最新运行、再判定 failure，徽章恢复 passing
| 提交 | 说明 |
|------|------|
| `d752c83` | fix(ci): ci-summary badge stuck on failing — latest-run check must precede failure filter |

## 2026-08-19T19:57:03+09:00

**摘要**：fix(codewhale-src): riscv64 交叉构建修复 — 四重问题链

- rquickjs-sys 0.12.2 不提供 riscv64gc bindings，postPatch 将 x86_64 bindings 落入 vendor 目录
- ring 宿主侧构建时 cc-rs 从宿主 triple 回退到交叉编译器并加 -m64，显式指向 buildPackages 工具链
- postInstall 裸 cargo build 丢失 --target 而误用宿主工具链链接 — 改为与 cargoBuildHook 相同
- 二进制以 -lgcc_s 动态链接，autoPatchelfHook 只扫 hostPlatform 依赖，显式加入交叉 gcc 的 libgcc
- 解 Build codewhale (riscv64) 连续 6 次失败
| 提交 | 说明 |
|------|------|
| `962ce6c` | fix(codewhale-src): riscv64 cross build — rquickjs bindings overlay, host cc-rs toolchain, postInstall --target, libgcc rpath |

## 2026-08-19T17:57:26+09:00

**摘要**：AGENTS.md — 修正过时引用并对齐 CI 章节描述

- 修正过时的 comfyui-strix-halo 模块引用（该模块已并入 comfyui-rocm）
- CI 章节描述与实际 workflow 结构对齐（独立 build-<包>-<架构>.yml 调用共享 build-package.yml + cachix-action 推送；注明无 riscv64 构建的包与无独立构建 workflow 的 godot-ai/dsh；ci-summary.yml 徽章机制）
| 提交 | 说明 |
|------|------|
| `c4e320e` | docs(AGENTS): fix stale comfyui-strix-halo reference + align CI description with actual workflows |

## 2026-08-19T16:52:54+09:00

**摘要**：fix(module): dsh WebSocket 反代改用 mod_proxy upgrade

- NixOS lighttpd 模块按 allKnownModules 固定顺序生成 server.modules，mod_wstunnel 排在 mod_proxy 之后，而 proxy.server 匹配所有路径：mod_proxy 先接管 /api/events.* 的升级请求返回 426，mod_wstunnel 因 r->handler_module 非空从不生效
- 改用 lighttpd 1.4.56+ mod_proxy 原生隧道（proxy.header = "upgrade" => "enable"），移除 mod_wstunnel 配置
- 实测 8625 首页 200、/api/events.host|mux 握手 101（本地+局域网）
| 提交 | 说明 |
|------|------|
| `51d9435` | fix(module): dsh WebSocket reverse proxy via mod_wstunnel |
| `33d5931` | fix(module): dsh wstunnel port as string (match lighttpd backend syntax) |
| `d7d2713` | fix(module): dsh WebSocket via mod_proxy upgrade (mod_wstunnel never runs) |

## 2026-08-19T13:10:00+09:00

**摘要**：fix(pkgs): dsh 0.1.0-rc.6 → 0.1.0-rc.7 — 携带上游修复的版本升级

- rc.6 运行约 13 小时后崩溃（fatal load failure: Context has been disposed）—— cordis-plugin-timer 的 ctx.timeout() 在 Context 静默 dispose 时 reject 成 unhandled rejection
- rc.7（8/17）为最新版，cordis/timer 版本未变（bug 可能仍在），但携带上游修复
- 插件清单不变（131 项）
| 提交 | 说明 |
|------|------|
| `c75cb4c` | chore(pkgs): bump dsh 0.1.0-rc.6 → 0.1.0-rc.7 |

## 2026-08-18T20:00:00+09:00

**摘要**：fix(module): dsh 支持普通用户运行 — 新增 dshHome 选项

- dsh 以隔离系统用户（home /var/lib/dsh）运行无法访问 /home/<user>（700 权限），agent 无法操作用户工作目录
- 新增 dshHome 选项，HOME/DSH_HOME/WorkingDirectory/preStart 统一走该路径，StateDirectory 改为 preStart mkdir + chown
- 本机配置 user="kix" + dshHome="/home/kix/.dsh"，dsh 以 kix 身份运行，可访问 /home/kix
| 提交 | 说明 |
|------|------|
| `584c764` | fix(module): dsh dshHome option + support normal-user operation |

## 2026-08-18T19:30:00+09:00

**摘要**：feat(module): nixkits.dsh.settings — 声明式设置配置

- dsh 设置菜单选项存储于 $DSH_HOME/settings.yaml（文件备份 + 热加载，per-namespace section）
- 新增 settings 选项（attrsOf attrs，namespace → section），渲染为 JSON（合法 YAML）由 preStart 写入
- 部署验证：web-search-deepseek.maxTokens 声明式覆盖默认 4096 → 8192 生效
- 文档 4 语言补设置配置章节
| 提交 | 说明 |
|------|------|
| `f2981e6` | feat(module): nixkits.dsh.settings — declarative settings |
| `dc64cbb` | docs(dsh): declarative settings section + maintenance log |

## 2026-08-18T18:45:00+09:00

**摘要**：docs(dsh) + refactor(skill): 插件清单同步

- docs/dsh.md 4 语言新增「插件清单」章节（131 个内置插件 entry id，id -> 包名），作为 nixkits.dsh.plugins.disabled 的取值参考
- nixkits-check-updates 技能第 5 步新增 dsh 特有说明：升级 dsh 时从新包提取 dsh-*/cordis.patch.yml 的插件清单同步到文档
| 提交 | 说明 |
|------|------|
| `06d0e28` | docs(dsh): plugin inventory + check-updates skill sync |

## 2026-08-18T18:39:34+09:00

**摘要**：fix(module): dsh preStart rm before cp — 444 只读文件覆盖修复

- settings/plugins 由 preStart 生成的文件权限为 444（只读），服务用户直接 cp 覆盖失败；改为先 rm 再 cp 生成
| 提交 | 说明 |
|------|------|
| `f308ac7` | fix(module): dsh preStart rm before cp — service-user cannot overwrite 444 |

## 2026-08-18T18:20:00+09:00

**摘要**：feat(module): nixkits.dsh.plugins — 声明式插件启停与配置

- dsh 插件经 cordis.patch.yml 运行时热加载，模块新增 plugins.disabled（禁用 entry id）、plugins.settings（config 覆盖）、plugins.extraPatch（手写片段如 MCP）
- 系统配置迁移 MCP 到 extraPatch、API key 改用 kix.credentials 声明式、示例禁用 session-telemetry-otel + session-stats
- 部署验证：cordis.patch.yml 正确生成、插件禁用无 absent 警告
| 提交 | 说明 |
|------|------|
| `0e4fe58` | feat(module): nixkits.dsh.plugins — declarative plugin on/off + config |
| `164d515` | docs(dsh): declarative plugin management section + maintenance log |

## 2026-08-18T17:55:00+09:00

**摘要**：fix(module): lighttpd 反代改写 Host/Origin 为 loopback — 替代 trustedHosts 方案

- 改写后 dsh 的 isTrustedApiRequest 看到 loopback 即通过，无需 per-deployment trustedHosts 配置，且不向后端泄露局域网主机名/IP
- Origin 必须与 Host 同步改写，否则同源校验失败
- 实测：移除 trustedHosts 后反代 API（harukax.lan / 192.168.31.241）均 ok:true
| 提交 | 说明 |
|------|------|
| `a33b414` | fix(module): rewrite Host/Origin to loopback in lighttpd reverse proxy |

## 2026-08-18T17:30:00+09:00

**摘要**：fix(module): dsh trustedHosts 选项 — 反代后 /api 全 403

- dsh 校验 /api 请求的 Host header，lighttpd 反代使 Host 变为局域网域名/IP 而被拒
- 新增 nixkits.dsh.trustedHosts（映射为 repeatable --trusted-host）
- 系统配置 harukax.lan + 192.168.31.241 后 API 恢复
| 提交 | 说明 |
|------|------|
| `3755935` | fix(module): dsh trustedHosts option — Host-header 403 behind reverse proxy |

## 2026-08-18T16:20:05+09:00

**摘要**：fix(dsh): patch 浏览器端 client bundle — crypto.randomUUID fallback

- crypto.randomUUID() 在非安全上下文（HTTP 局域网 IP，即 lighttpd 反代）不可用，webui 因此报错
- postInstall 把 dsh-client-connection + dsh-client-ui-conversation 的 crypto.randomUUID 换成 __dshUuid helper（fallback 到 crypto.getRandomValues，全上下文可用）
| 提交 | 说明 |
|------|------|
| `5d1cfa8` | fix(dsh): patch browser client bundles — crypto.randomUUID fallback |

## 2026-08-18T15:29:14+09:00

**摘要**：fix/docs(dsh): lighttpd 反代方案定稿

- dsh 内部 loopback 端口 8615（对齐 SearXNG 的 42701 惯例），lighttpd 对外端口 8625（对齐 4270）
- 防火墙开放 lighttpd 对外端口（非 dsh 内部端口）
- 4 语言文档同步最终方案
| 提交 | 说明 |
|------|------|
| `4a78d54` | fix(module): dsh internal port 8615, public reverseProxy port 8625 |
| `5452a3e` | docs(dsh): sync service section to loopback 8615 + lighttpd reverseProxy 8625 |

## 2026-08-18T14:38:26+09:00

**摘要**：feat(module): 新增 nixkits.dsh.reverseProxy（lighttpd）

- dsh 拒绝非 loopback host（RCE 安全），故以 lighttpd `$SERVER["socket"]` 条件块把 0.0.0.0:8626 反代到 dsh loopback 8625（复用 SearXNG 的 lighttpd 实例，extraConfig 为 types.lines 可合并）
- 开放 8626 防火墙
| 提交 | 说明 |
|------|------|
| `12e11af` | feat(module): add nixkits.dsh.reverseProxy via lighttpd |

## 2026-08-18T10:29:46+09:00

**摘要**：feat/fix(dsh): 部署 dsh 服务并配置 MCP + skills。

- 模块修复：dsh 系统用户 HOME=/var/empty 只读致 EPERM，改用可写 /var/lib/dsh + StateDirectory
- HMR 服务需 --expose-internals，改以 node --expose-internals 直接启动 bin.js
- MCP 服务（SearXNG + Godot）以 cordis.patch.yml 的 `insert:` 语法配置，非 id-targeted override
- skills 复制到 /var/lib/dsh/skills/，非 .agent-presets 子目录
- nixkits-skills 目录修正为 ~/.dsh/skills

| 提交 | 说明 |
|------|------|
| `b17e5bf` | fix(module): dsh writable HOME + StateDirectory |
| `ed6983e` | fix(module): dsh launch via node --expose-internals (HMR requires execArgv) |
| `456c917` | feat(skill): nixkits-skills add dsh skills directory support |
| `ee24563` | fix(skill): correct dsh skills directory — ~/.dsh/skills |

## 2026-08-18T08:42:40+09:00

**摘要**：docs: 同步 ruyi 通道版本并补齐三语 README 的 ruyi 描述列

- `ruyi` stable 0.50.0 → 0.51.0，beta/alpha 日期同步
- en/ja/pcn README 的 ruyi 描述列原本为空 `<br><br>`，现填入 RuyiSDK 描述 + 三通道版本，与 zh 对齐
| 提交 | 说明 |
|------|------|
| `86ae30b` | docs: sync ruyi channel versions + fill empty ruyi descriptions in en/ja/pcn README |

## 2026-08-18T07:19:30+09:00

**摘要**：审计修复 —— 版本更新与模块/overlay/文档/技能修正。

- codewhale 0.9.8、mcp-searxng 1.15.0、opencode-telegram 0.24.0、obs-bilibili-stream 2.1.3 版本更新
- comfyui-rocm 模块补回 services.comfyui assertion，并澄清 nixpkgs-compat 补丁目标
- overlay codewhale 按架构回退源码构建（riscv64）
- 文档版本号、ruyi 链接、codewhale-sudo 描述同步
- write-maintenance-log 技能补表头、删 katalish 列

| 提交 | 说明 |
|------|------|
| `0ffa734` | fix(comfyui-rocm): clarify nixpkgs-compat patch target + restore assertion |
| `cb4e250` | fix(default-overlay): codewhale riscv64 fallback to source build |
| `04e95da` | chore(pkgs): bump mcp-searxng 1.14.1 → 1.15.0 |
| `c65d740` | chore(pkgs): bump codewhale 0.9.4 → 0.9.8 |
| `4531bf6` | chore(pkgs): bump opencode-telegram 0.23.1 → 0.24.0 |
| `7f14633` | chore(pkgs): bump obs-bilibili-stream 2.1.2 → 2.1.3 |
| `685864e` | docs: sync version numbers + ruyi link + codewhale-sudo description |
| `cc768d0` | fix(skill): write-maintenance-log table header + drop katalish |

## 2026-08-15T10:04:37+09:00

**摘要**：refactor: 合并 comfyui-rocm-patch + comfyui-strix-halo 为单一 comfyui-rocm

- 两模块分别处理 ComfyUI ROCm 支持的不同部分（补丁层 vs Strix Halo 硬件优化），合并为 nixkits.comfyui-rocm 模块（enable 选项）
- 覆盖 ROCm 补丁挂载、GFX 覆盖、xformers 绕过、C 工具链、Strix Halo 硬件配置（ROCm runtime/DeviceAllow/kernelParams）
- 文档与 README 同步
| 提交 | 说明 |
|------|------|
| `d473991` | refactor: merge comfyui-rocm-patch + comfyui-strix-halo into comfyui-rocm |

## 2026-08-15T09:23:15+09:00

**摘要**：refactor: 补丁改名 rog-control-center-fix.patch → rcc-fix.patch，完成 rcc-fix 统一命名

- 补丁文件 rog-control-center-fix.patch → rcc-fix.patch
- 更新 overlays/rcc-fix.nix 与 4 语言 rcc-fix.md 文档中的引用
| 提交 | 说明 |
|------|------|
| `b350cfd` | refactor: rename rog-control-center-fix.patch to rcc-fix.patch |

## 2026-08-15T08:31:32+09:00

**摘要**：deepseek-harness 0.1.0-rc.6 — 新包（@deepseek-ai/dsh）

- 预构建 npm 包，bin `dsh` → `lib/bin.js`；vendor package-lock.json（npm tarball 不含 lock），dontNpmBuild 跳过 build
- 4 语言文档 + README 列入 godot-ai 与 dsh
| 提交 | 说明 |
|------|------|
| `0194460` | feat(dsh): add deepseek-harness 0.1.0-rc.6 package + 4-language docs |

## 2026-08-15T08:07:33+09:00

**摘要**：refactor: 合并 rog-control-center-fix 到 rcc-fix

- 两者实为同一 ROG 控制中心修复项目（overlay asusctl 补丁 + module systemd 死锁修复），统一为单一 rcc-fix
- overlays/rog-control-center-fix.nix → rcc-fix.nix，modules/rog-control-center-fix.nix → rcc-fix.nix
- 选项 nixkits.rog-control-center-fix → nixkits.rcc-fix
- 删除独立 rog-control-center-fix 文档（内容并入 rcc-fix.md）
| 提交 | 说明 |
|------|------|
| `376eacf` | refactor: merge rog-control-center-fix into rcc-fix |

## 2026-08-13T01:20:29+09:00

**摘要**：fix(default-overlay): godot-ai 应用 fastmcp overlay 构建

- default overlay 的 `final.callPackage` 将 fastmcp 解析为 nixpkgs 3.3.1（circular-import bug）
- 改用 `(prev.extend (import ./fastmcp.nix))` 使依赖解析为 3.4.7
| 提交 | 说明 |
|------|------|
| `94d49b5` | fix(default-overlay): build godot-ai with fastmcp overlay applied |

## 2026-08-12T10:05:00+09:00

**摘要**：fix(default-overlay): 修正 godot-ai 包路径

- `overlays/default.nix` 中 `callPackage` 路径应为 `../packages/`（overlay 在子目录）
- 误写为 `./packages/` 导致路径解析到不存在的 `overlays/packages/`
| 提交 | 说明 |
|------|------|
| `0144283` | fix(default-overlay): correct godot-ai path — ./packages → ../packages |

## 2026-08-12T10:00:00+09:00

**摘要**：fix(default-overlay): 注册 godot-ai

- godot-ai 在 flake packages 中存在但遗漏于默认 overlay，下游（/etc/nixos）通过 pkgs.godot-ai 不可见
| 提交 | 说明 |
|------|------|
| `093565c` | fix(default-overlay): register godot-ai so pkgs.godot-ai is available |

## 2026-08-12T09:18:26+09:00

**摘要**：docs(godot-ai): 新增 4 语言文档（72 行）

- 架构图、依赖表（含 fastmcp 3.4 说明）、系统安装 + MCP 配置 + 前置条件指南
| 提交 | 说明 |
|------|------|
| `76c39c8` | docs(godot-ai): add 4-language documentation |

## 2026-08-12T07:07:27+09:00

**摘要**：feat(godot-ai): 新增 godot-ai 3.1.5 包 + fastmcp 3.4.7 overlay

- godot-ai（hi-godot/godot-ai）是 Production-grade MCP server，连接 MCP 客户端到运行中的 Godot 编辑器（43 工具 / 120+ 操作）
- fastmcp 从 nixpkgs 3.3.1 升级到 3.4.7（godot-ai 要求 >=3.4.0，排除 3.3.x 的 circular-import bug），联动升级 fastmcp-slim + py-key-value-aio 0.4.5
- devshell godot-mcp → godot-ai
| 提交 | 说明 |
|------|------|
| `23a5b8d` | feat(godot-ai): add godot-ai 3.1.5 package + fastmcp 3.4.7 overlay |

## 2026-08-11T18:49:54+09:00

**摘要**：fix(breeze-black): Edge/Chromium 纯黑背景 + 纯白前景

- 扩展 sed 重映射：背景 #292c30 → #000000（按钮/工具栏/禁用），前景 #fcfcfc/#a1a9b1 → #ffffff
- gtk-3.0/4.0 验证：15× #000000、14× #ffffff、零灰残留
| 提交 | 说明 |
|------|------|
| `4e5c558` | fix(breeze-black): pure black bg + pure white fg for Edge/Chromium |

## 2026-08-11T18:41:14+09:00

**摘要**：fix(breeze-black): 背景变量映射为纯黑 #000000

- Breeze-Dark 基础色是 #202326（深灰非纯黑）
- 复制 CSS 后重映射主背景/base 为 #000000（按钮保留 #292c30 保持层次）
- gtk-dark.css 改为自包含（复制 gtk.css）不再依赖灰色 import
| 提交 | 说明 |
|------|------|
| `2ee1ba6` | fix(breeze-black): map background variables to true black #000000 |

## 2026-08-11T16:19:49+09:00

**摘要**：fix(breeze-black): 用 Breeze-Dark 深色方案覆盖 gtk.css 本体

- Chromium 系（Edge/Chrome）不遵循 prefer-dark，直接加载 gtk.css
- BreezeBlack（浅色 Breeze 重命名）仍带浅色变量（#eff0f1），导致 Edge 显示灰色
- 覆盖 gtk-{3,4}.0 的 gtk.css(+.map) 为深色（#202326）
| 提交 | 说明 |
|------|------|
| `25e23e0` | fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme |

## 2026-08-11T16:02:39+09:00

**摘要**：fix(breeze-black): 保留 Breeze-Dark

- BreezeBlack 的 gtk-dark.css 通过 `@import ../../Breeze-Dark/...` 获取真正的深色配色（#202326）
- preFixup 中删除 Breeze-Dark 导致 import 断裂、GTK 回退浅色（「不够黑」症状）
| 提交 | 说明 |
|------|------|
| `0433eee` | fix(breeze-black): keep Breeze-Dark — gtk-dark.css imports it for dark mode |

## 2026-08-09T22:43:43+09:00

**摘要**：refactor(skill): 常见陷阱新增第 4 条

- 无参数 `nix flake lock` 会刷新所有浮动 input（nixpkgs 漂移重演，diffusers/httpx 在 8/7 nixpkgs 失败）
- 应使用 --update-input 或固定 nixpkgs rev
| 提交 | 说明 |
|------|------|
| `ec5e589` | refactor(skill): add trap 4 — bare nix flake lock refreshes floating inputs |

## 2026-08-09T19:40:21+09:00

**摘要**：feat(patches): 将本地 comfyui-nix 构建修复转正为补丁文件

- ① mkWheel dontCheckRuntimeDeps（pythonRuntimeDepsCheckHook，nixpkgs ≥ 8/5）
- ② flaky 套件 doInstallCheck=false（jupyter-server/scipy/fastapi/einops/mss/inline-snapshot）
- ③ torch/facexlib 运行时依赖跳过
- 更新模块注释 + 4 语言文档
| 提交 | 说明 |
|------|------|
| `a8ad11e` | feat(patches): add comfyui-nix nixpkgs-compat patch + module doc |
| `faefa5b` | docs(comfyui-rocm-patch): document nixpkgs-compat patch (4 langs) |

## 2026-08-09T19:05:53+09:00

**摘要**：refactor(skill): nixkits-check-updates 新增 nixpkgs 漂移故障排查小节

- ① 恢复旧 flake.lock 需核对 flake.nix 的 follows 配置（丢失 → glibc 2.40 → GLIBC_ABI_GNU2_TLS）
- ② pytest 包跳过测试用 doInstallCheck=false（pytestCheckHook 跑在 installCheckPhase）
- ③ pythonRuntimeDepsCheckHook（nixpkgs ≥ 8/5）破坏 wheel 构建，用 dontCheckRuntimeDeps=true 修复
| 提交 | 说明 |
|------|------|
| `e88fd98` | refactor(skill): add nixpkgs-drift troubleshooting section to check-updates |

## 2026-08-09T04:21:09+09:00

**摘要**：fix(module): llama-cpp — 修复 extraFlags 废弃与 freeform settings 定义

- `services.llama-cpp.extraFlags` 已废弃，改用 `settings` 传递 `--sleep-idle-seconds`
- freeform `settings` 无法分离定义，改用 `lib.mkMerge` 合并 `models-preset` 与 `sleep-idle-seconds`
| 提交 | 说明 |
|------|------|
| `8026d8e` | fix(module): replace deprecated services.llama-cpp.extraFlags with settings |
| `0ec7760` | fix(module): merge llama-cpp settings via mkMerge |

## 2026-08-08T23:07:40+09:00

**摘要**：fix(breeze-black): 恢复 look-and-feel 全局主题并修复 GTK 重命名

- 7/23 移除外部补丁后 `org.kde.breezeblack.desktop` 全局主题缺失，BreezeBlack 从系统设置主题选择页消失，经本地内置 look-and-feel 包恢复
- `preFixup` 的 Breeze* 通配同时匹配 Breeze 与 Breeze-Dark，导致 GTK 主题嵌套失效，改为仅重命名 Breeze
| 提交 | 说明 |
|------|------|
| `114b9c2` | fix(breeze-black): restore look-and-feel global theme + fix GTK rename |

## 2026-08-08T22:50:33+09:00

**摘要**：fix(codewhale-src): 同步至 0.9.4 并修正 source hash

- `nix-prefetch-url` 从 archive tarball 预取的 hash 与 `fetchFromGitHub`（git 协议）不一致，导致 riscv64 CI 连续失败
- 改用 `fetchFromGitHub` 构建获取正确 hash，同步 Cargo.lock
- 技能中错误建议一并修正
| 提交 | 说明 |
|------|------|
| `08b04a2` | fix(codewhale-src): sync to 0.9.4 with correct fetchFromGitHub hash |
| `ab2a624` | fix(skill): correct fetchFromGitHub hash advice — archive tarball trap |

## 2026-08-08T22:20:21+09:00

**摘要**：codewhale 0.9.4、mcp-searxng 1.14.1 与 opencode-telegram 0.23.1 — 上游更新

- `codewhale` 0.9.3 → 0.9.4，上游 bug 修复；`mcp-searxng` 1.14.0 → 1.14.1，上游维护更新；`opencode-telegram` 0.22.5 → 0.23.1，上游功能更新
| 提交 | 说明 |
|------|------|
| `f184fdb` | chore(pkgs): bump codewhale 0.9.3 → 0.9.4 |
| `9b877e1` | chore(pkgs): bump mcp-searxng 1.14.0 → 1.14.1 |
| `9b17590` | chore(pkgs): bump opencode-telegram 0.22.5 → 0.23.1 |
| `59ac74a` | docs: sync version numbers |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.9.3 | 0.9.4 |
| mcp-searxng | 1.14.0 | 1.14.1 |
| opencode-telegram | 0.22.5 | 0.23.1 |

## 2026-08-05T07:24:56+09:00

**摘要**：chore(pkgs) — codewhale-src 同步至 0.9.3

- riscv64 源码构建落后预编译包 3 个版号，同步 `version`、`fetchFromGitHub` hash 与 Cargo.lock（711 → 763 条目）
| 提交 | 说明 |
|------|------|
| `563eea2` | chore(pkgs): sync codewhale-src to 0.9.3 — version, hash, Cargo.lock |

## 2026-08-05T01:30:00+09:00

**摘要**：refactor(skill) — nixkits-check-updates 新增 Rust 包更新流程

- 新增 Rust 包（`buildRustPackage`）更新流程，泛化 codewhale-src 的 Cargo.lock 同步经验：`version` + source hash + Cargo.lock 三处同步、上游 lock 下载与条目数验证、交叉编译超时回退
| 提交 | 说明 |
|------|------|
| `6e6bef6` | refactor(skill): add Rust package (buildRustPackage) update flow to nixkits-check-updates |

## 2026-08-04T02:15:00+09:00

**摘要**：fix(ruyi): 容忍 ruff lint 失败

- 第二条 ruff check（不带 `--fix`）在 nixpkgs ruff 更新后因 139 条上游违规阻塞构建，checkPhase 改为容忍该失败
| 提交 | 说明 |
|------|------|
| `1175df2` | fix(ruyi): tolerate ruff lint failures in checkPhase |

## 2026-08-04T01:15:52+09:00

**摘要**：codewhale 0.9.3 与 mcp-searxng 1.14.0 — 上游更新

- `codewhale` 0.9.1 → 0.9.3，上游 bug 修复；`mcp-searxng` 1.12.1 → 1.14.0，上游功能更新
| 提交 | 说明 |
|------|------|
| `f84cbcb` | chore(pkgs): bump codewhale 0.9.1 → 0.9.3 |
| `6968f4e` | chore(pkgs): bump mcp-searxng 1.12.1 → 1.14.0 |
| `d778b1b` | docs: sync version numbers |

| 软件名 | 旧版本 | 新版本 |
|------|------|------|
| codewhale | 0.9.1 | 0.9.3 |
| mcp-searxng | 1.12.1 | 1.14.0 |
|--------|--------|--------|

## 2026-07-31T04:07:23+09:00

**摘要**：fix(ci): 修复 ci-summary.yml 并改用 shields.io endpoint 徽章

- `ci-summary.yml` 存在 YAML runs-on 与 workflow_dispatch 混排、硬编码 token 等语法错误，改用 push/schedule 触发 + `GITHUB_TOKEN`
- README badge 从 `check.yml`（仅 flake 求值）改为 shields.io endpoint，反映全部 Build workflow 实际状态
| 提交 | 说明 |
|------|------|
| `c0e52a5` | fix(ci): fix ci-summary.yml syntax, switch README badge to endpoint |

## 2026-07-31T03:34:15+09:00

**摘要**：fix(ci): 注入 GITHUB_TOKEN 作为 Nix access-token

- `llama-cpp-ver` input 需要 GitHub API 请求，未认证访问仅 60 次/小时，多 job 并行时频繁触发 403 限流，改用 `${{ secrets.GITHUB_TOKEN }}` 认证
| 提交 | 说明 |
|------|------|
| `41a8a8b` | fix(ci): inject GITHUB_TOKEN as Nix access-token for llama-cpp-ver API |

## 2026-07-31T03:00:12+09:00

**摘要**：fix(codewhale-src): 修复 riscv64 交叉编译

- `ring` crate 通过 `cc` crate 继承了通用 CFLAGS 中的 `-m64`（x86_64 标志），导致 riscv64-gcc 报错
- 在清除 per-target CFLAGS 基础上进一步清除通用 CFLAGS/CXXFLAGS
| 提交 | 说明 |
|------|------|
| `29c780a` | fix(codewhale-src): clear generic CFLAGS/CXXFLAGS for riscv64 cross-compile |

## 2026-07-30T17:56:11+09:00

**摘要**：codewhale 0.9.1、mcp-searxng 1.12.1 与 opencode-telegram 0.22.5 — 上游更新

- `codewhale` 0.9.0 → 0.9.1，上游 bug 修复；`mcp-searxng` 1.11.1 → 1.12.1，上游功能更新；`opencode-telegram` 0.22.3 → 0.22.5，上游维护更新
| 提交 | 说明 |
|------|------|
| `1110c7a` | chore(pkgs): bump codewhale 0.9.0 → 0.9.1 |
| `3dcb65a` | chore(pkgs): bump mcp-searxng 1.11.1 → 1.12.1 |
| `98abe96` | chore(pkgs): bump opencode-telegram 0.22.3 → 0.22.5 |
| `a94dea8` | docs: sync version numbers |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.9.0 | 0.9.1 |
| mcp-searxng | 1.11.1 | 1.12.1 |
| opencode-telegram | 0.22.3 | 0.22.5 |

## 2026-07-23T12:56:53+09:00

**摘要**：fix(codewhale-sudo): 修复 ptrace wrapper

- 移除子进程跟踪，避免 codewhale 子 shell 被 SIGTRAP 杀死
- 添加 `PTRACE_EVENT_EXEC` 处理
- 同步更新 4 语言文档（LD_PRELOAD → ptrace 描述）
| 提交 | 说明 |
|------|------|
| `c77cadc` | fix(codewhale-sudo): stop tracing child processes, handle PTRACE_EVENT_EXEC |
| `480658e` | docs(codewhale-sudo): update mechanism description LD_PRELOAD → ptrace |

## 2026-07-23T12:08:13+09:00

**摘要**：fix(codewhale-sudo): LD_PRELOAD shim 换成 ptrace 系统调用拦截器

- codewhale 是静态链接的，LD_PRELOAD 无法拦截 `prctl(PR_SET_NO_NEW_PRIVS)`
- 改用 `ptrace(2)` 在内核边界拦截，兼容静态和动态二进制
| 提交 | 说明 |
|------|------|
| `6446364` | fix(codewhale-sudo): replace LD_PRELOAD shim with ptrace syscall interceptor |

## 2026-07-23T11:24:15+09:00

**摘要**：fix(overlays): breeze-black — 替换已失效的 fetchpatch URL

- 原 URL 的 injx.sbs 域名永久不可用
- 改为纯本地 colors 文件安装方式
- KDE Plasma 自动发现 share/color-schemes/ 中的配色方案
| 提交 | 说明 |
|------|------|
| `547d6a0` | fix(overlays): replace dead breeze-black fetchpatch with local copy |

## 2026-07-22T16:31:26+09:00

**摘要**：fix(modules) — rog-control-center 与 comfyui-strix-halo 修复

- rog-control-center-fix 添加 SendSIGKILL=yes + TimeoutStopSec=30s，解决 asus-shutdown 旧进程残留阻塞 systemd-switch
- comfyui-strix-halo 添加 glibc >= 2.42 assertion（ROCm 7.2 需要 GLIBC_ABI_GNU2_TLS）
| 提交 | 说明 |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T09:00:00+09:00

**摘要**：feat(overlays) — 新增 breeze-black overlay

- 为 Plasma 6 提供高对比度 Breeze Black 无障碍主题（全局 look-and-feel + GTK + 配色方案）
- 含 4 语言文档
| 提交 | 说明 |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T05:39:31+09:00

**摘要**：docs(devshell) — 新增 devShell 文档（4 语言）

- 描述 opencode（MCP 全栈）和 ruyi（三通道合并）开发环境
- README devShell 表添加文档链接列
| 提交 | 说明 |
|------|------|
| `7bfe3e3` | docs: add devShell documentation — 4 lang |
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |

## 2026-07-22T03:40:50+09:00

**摘要**：docs — 统一全仓库文档的用户目录路径为 `~/` 前缀

- 替换硬编码 `/home/kix` 及 `/home/<user>` 等变体
- 涉及 13 文件
| 提交 | 说明 |
|------|------|
| `f597b9a` | docs: generalize hardcoded /home/kix paths |
| `bb65b77` | docs: unify all user home paths to ~/ prefix |

## 2026-07-22T03:14:27+09:00

**摘要**：feat(shells) — opencode devShell 迭代

- 加入 SearXNG + lighttpd（与系统 NixOS 配置一致）+ blender-mcp + godot-mcp + godot + opencode + opencode-telegram
- 首次进入自动注册 MCP 配置
- 移除 godot 包的 tryEval 保护
| 提交 | 说明 |
|------|------|
| `35cc4e8` | feat(shells): add opencode-telegram devShell + nix run doc |
| `2b8f676` | fix(shells): add opencode to opencode-telegram devShell |
| `e83982d` | refactor(shells): merge blender-mcp + mcp-searxng |
| `c5a57a6` | refactor(shells): rename opencode, add godot-mcp + godot_4 |
| `60a065e` | fix(shells): add GODOT_PATH |
| `47e43b3` | fix(shells): set SEARXNG_URL |
| `3652030` | feat(shells): add self-contained SearXNG + Redis |
| `e0ead5a` | refactor(shells): extract devShells from flake.nix to develop/ |
| `9d67fd8` | feat(shells): auto-register opencode MCP servers on first entry |
| `6a6537d` | fix(shells): add limiterSettings/trusted_proxies |
| `c316c97` | feat(shells): add lighttpd reverse proxy |
| `f8943ff` | refactor(shells): remove tryEval for godot-mcp |
| `8d2f65b` | fix(shells): s/godot_4/godot/ |

## 2026-07-22T02:43:51+09:00

**摘要**：feat(overlays) — 新增 efl-cross-fix overlay

- 修复 efl（Enlightenment Foundation Libraries）在 riscv64/riscv64-musl/aarch64 交叉编译时因缺少原生代码生成工具（eolian_gen、eet）导致的构建失败
- 含 4 语言文档
| 提交 | 说明 |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**摘要**：codewhale 0.9.0 + ruyi 0.51.0 系 + opencode-telegram 0.22.3 — 上游更新

- codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3
- codewhale v0.9.0 仍无 riscv64 预编译二进制，继续源码构建路径
| 提交 | 说明 |
|------|------|
| `deca3e8` | chore(pkgs): bump opencode-telegram 0.22.3 |
| `6046594` | chore(pkgs): bump ruyi 0.51.0 + beta 0.51.0-beta.20260714 + alpha 0.52.0-alpha.20260714 |
| `4df8df2` | chore(pkgs): bump codewhale 0.9.0 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.67 | 0.9.0 |
| ruyi | 0.50.0 | 0.51.0 |
| ruyi-beta | 0.50.0-beta.20260623 | 0.51.0-beta.20260714 |
| ruyi-alpha | 0.51.0-alpha.20260616 | 0.52.0-alpha.20260714 |
| opencode-telegram | 0.22.2 | 0.22.3 |

## 2026-07-16T06:08:43+09:00

**摘要**：fix(ci) — 修复 ci-summary workflow 的 rate limit 失败

- 原因为 `gh run list` 逐 workflow 调用 API 触发 rate limit（HTTP 403），导致主文档 CI badge 无法更新
- 改为 2 次批量 `gh api` 调用 + 并发控制
| 提交 | 说明 |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**摘要**：revert(skill) — 移除 katalish（半角片假名机械翻译）全部内容

- 19 个文档、技能（SKILL.md + dictionary.md 102 条）、所有语言切换器链接
- 该方案因翻译不稳定（残留英文或破坏文档结构）不适合生产环境
| 提交 | 说明 |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:54:55+09:00

**摘要**：docs(nixkits-skills) —「已知移除」章节改名为「风险警示」

- 5 语言技能文档同步
| 提交 | 说明 |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**摘要**：skill(nixkits-skills) — 移除 Claude Code 安装目标并添加 Codex 支持

- 移除 Claude Code 安装目标（软件内基于用户数据挖掘的国籍推断跨越安全边界）
- 添加 Codex 支持
- SKILL.md 新增「风险警示」章节，包含原始声明文本
| 提交 | 说明 |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:35:20+09:00

**摘要**：skill(write-maintenance-log) — 强化时间戳规则

- 强制使用 `git log` 获取 commit 时间、禁止 `T00:00:00` 占位符
- 新增生成后验证步骤
- 泛化自维护日志占位时间修复经验（`968df0e`）
| 提交 | 说明 |
|------|------|
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |

## 2026-07-16T04:30:55+09:00

**摘要**：feat(ci) — 新增 CI summary endpoint badge

- 主文档 CI 徽章改为 shields.io endpoint 读取 `gh-pages/ci-status.json`
- 失败时显示失败包名和架构
| 提交 | 说明 |
|------|------|
| `6465260` | feat(ci): add CI summary workflow with endpoint badge |
| `b489890` | docs(README): switch main CI badge to endpoint |

## 2026-07-16T04:09:46+09:00

**摘要**：refactor(ci) — CI 从单个 check.yml 拆分为独立 workflow 文件

- 从单个 check.yml 拆分为 25 个独立 workflow 文件（每个包×架构一个），彻底消除 badge 间互相影响
- 新增 reusable workflow `build-package.yml`
| 提交 | 说明 |
|------|------|
| `bc42e6f` | refactor(ci): split single check.yml into 25 isolated per-package-per-arch workflows |
| `1dfc1ee` | docs: update ruyi badge URLs to new isolated workflow files |
| `f235edc` | docs: embed version numbers in CI badge labels |

## 2026-07-16T04:00:46+09:00

**摘要**：fix(codewhale) — 修复源码构建的 riscv64 交叉编译

- 源码构建的 riscv64 交叉编译失败：ring crate 报 `-m64` 错误
- 根因是 cc crate 继承 host CFLAGS
- 通过清空 per-target CFLAGS 修复
| 提交 | 说明 |
|------|------|
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |

## 2026-07-16T01:18:16+09:00

**摘要**：codewhale 0.8.67 — 双路径构建

- 预编译 x86_64/aarch64，源码构建 riscv64
- 上游从 v0.8.67 起移除 riscv64 预编译二进制
- riscv64 现通过 rustPlatform.buildRustPackage 从本地 Cargo.lock 构建
| 提交 | 说明 |
|------|------|
| `0025476` | feat(codewhale): dual-path build — prebuilt for x86_64/aarch64, source for riscv64 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.66（预编译×3） | 0.8.67（预编译×2 + 源码 riscv64） |

## 2026-07-15T08:32:13+09:00

**摘要**：mcp-searxng 1.11.1、opencode-telegram 0.22.2 与 obs-bilibili-stream 2.1.2 — 上游更新

- mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 同步上游版本
- codewhale 跳过：v0.8.67 仍缺 riscv64 二进制
| 提交 | 说明 |
|------|------|
| `48414d4` | chore(pkgs): bump mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | 1.11.0 | 1.11.1 |
| opencode-telegram | 0.22.1 | 0.22.2 |
| obs-bilibili-stream | 2.1.1 | 2.1.2 |
| codewhale | 0.8.66 | (跳过 — 上游 v0.8.67 仍缺 riscv64 二进制) |

## 2026-07-09T01:22:00+09:00

**摘要**：revert(ci) — 恢复 `llama-cpp-ver` 为上游 API

- 移除 `ci/` 目录，`llama-cpp-ver` input 恢复为上游 API（`ggml-org/llama.cpp` releases/latest）
- overlay 已内置 `tryEval` + `prev.llama-cpp.version` fallback，无需本地缓存
| 提交 | 说明 |
|------|------|
| `dbdd937` | revert: restore llama-cpp-ver to upstream API, remove ci/ |

## 2026-07-09T01:14:34+09:00

**摘要**：obs-bilibili-stream 2.1.1、mcp-searxng 1.11.0 与 opencode-telegram 0.22.1 — 上游更新

- obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 同步上游版本
- codewhale 跳过：v0.8.67 缺少 riscv64 预编译二进制
| 提交 | 说明 |
|------|------|
| `73dc576` | chore(pkgs): bump obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| obs-bilibili-stream | 2.1.0 | 2.1.1 |
| mcp-searxng | 1.8.0 | 1.11.0 |
| opencode-telegram | 0.22.0 | 0.22.1 |
| codewhale | 0.8.66 | (跳过 — 上游 riscv64 二进制缺失) |

## 2026-07-07T12:01:12+09:00

**摘要**：fix(docs): katalish/pcn 本地化修复

- katalish/ruyi.md 与 pcn/ruyi.md 的语言切换器修复（链接缺失、语言名重复）
- pcn/ruyi.md 全文由日文重写为伪中国语
| 提交 | 说明 |
|------|------|
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |

## 2026-07-05T04:41:23+09:00

**摘要**：fix(ci): blender-mcp 从 riscv64-cross 移除

- 上游 nixpkgs 的 `sse-starlette` 交叉编译缺陷致构建失败
- `blender` 在 riscv64 上亦不受支持
- x86_64 / aarch64 不受影响
| 提交 | 说明 |
|------|------|
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |

## 2026-07-04T06:41:28+09:00

**摘要**：blender-mcp 1.0.0 — 新增 Blender MCP Server 包

- Python 构建、22 个 MCP 工具
- 含 Blender add-on 配套文件
| 提交 | 说明 |
|------|------|
| `a1cf458` | packages: add blender-mcp (MCP server for Blender) |
| `ab9109a` | packages: add blender-mcp (MCP server for Blender) |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| blender-mcp | — | 1.0.0 |

## 2026-07-02T04:00:00+09:00

**摘要**：codewhale 0.8.66 — 上游更新

- TUI 布局修复
- 审批诚实度标签
- 性能修复若干
| 提交 | 说明 |
|------|------|
| `c00a5e6` | chore(pkgs): bump codewhale 0.8.66 |
| `c61d458` | docs: bump codewhale 0.8.66 version numbers in all 5-language docs |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.65 | 0.8.66 |
| 　 | cli hash (×3) | 全部更新 |
| 　 | tui hash (×3) | 全部更新 |

## 2026-06-28T06:30:00+09:00

**摘要**：opencode-telegram 0.22.0 — 上游更新

- 新增三模式 TTS
- 新增 thinking 显示
- 新增紧凑输出
- 新增 `/settings` 命令
- 修复 session 启动
| 提交 | 说明 |
|------|------|
| `b189d0a` | chore(pkgs): bump opencode-telegram 0.22.0 |
| `a61f444` | docs: bump opencode-telegram 0.22.0 version numbers in all 5-language docs |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.21.2 | 0.22.0 |
| 　 | source hash | `sha256-NEaQ2...` → `sha256-FnLRc...` |
| 　 | npmDepsHash | `sha256-z9trD...` → `sha256-nQq94...` |

## 2026-06-26T13:00:00+09:00

**摘要**：CI / docs — llama-cpp-ver 改本地文件与 riscv64 badge 包级化

- CI：llama-cpp-ver 改为本地文件（`ci/llama-cpp-ver.json`）
- 消除所有 CI job 的 GitHub API 调用，彻底解决 rate limit 导致的全局构建失败
- docs：riscv64 badge 精确到包级别（codewhale/kitsfmt/mcp-searxng/opencode-telegram）
| 提交 | 说明 |
|------|------|
| `8b3a3be` | fix(ci): use local path for llama-cpp-ver input, eliminate GitHub API calls from all CI jobs |
| `5db4852` | fix(docs): add per-package job filter to riscv64 badges |

## 2026-06-26T12:30:00+09:00

**摘要**：feat(opencode-telegram): 新增两个服务 PATH 注入选项

- 新增 `extraPackages` 选项（注入系统包到服务 PATH）
- 新增 `extraBinPaths` 选项（注入 home-manager 路径到服务 PATH）
- 解决 opencode 不在服务 PATH 中的问题
- 5 语言文档同步更新
| 提交 | 说明 |
|------|------|
| `7c98694` | feat(opencode-telegram): add extraPackages option to inject companion tools into service PATH |
| `45b7c57` | feat(opencode-telegram): add extraBinPaths option for home-manager users |

## 2026-06-26T10:55:41+09:00

**摘要**：codewhale 0.8.65 与 mcp-searxng 1.8.0 — 上游更新

- codewhale：cli 二进制重命名 `codewhale-cli-linux` → `codewhale-linux`
- mcp-searxng：多实例故障转移/并行扇出
- mcp-searxng：能力发现聚合
- mcp-searxng：safesearch 修复
| 提交 | 说明 |
|------|------|
| `57620d4` | chore(pkgs): bump codewhale 0.8.65 + mcp-searxng 1.8.0 |
| `94ac1e4` | docs: bump codewhale 0.8.65 + mcp-searxng 1.8.0 version numbers in all 5-language docs |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.64 | 0.8.65 |
| mcp-searxng | 1.7.2 | 1.8.0 |
| 　 | codewhale cli hash (×3) | 全部更新（含 URL 变更） |
| 　 | codewhale tui hash (×3) | 全部更新 |
| 　 | mcp-searxng source hash | `sha256-6N1YF...` → `sha256-xyNjB...` |
| 　 | mcp-searxng npmDepsHash | `sha256-ZKhLP...` → `sha256-dVFX5...` |

## 2026-06-26T07:18:56+09:00

**摘要**：fix(skill): write-maintenance-log 第 4 步「多语同步」由空壳重写为可执行流程，AGENTS.md 同步加强验证

- 第 4 步原为 5 行空壳，现为可执行流程：4a 发现语言 → 4b 逐语言翻译写入 → 4c 验证条目数一致
- AGENTS.md 第 4 步加强验证检查
| 提交 | 说明 |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-26T06:19:21+09:00

**摘要**：审计修复 — 清理 scripts/ 空目录与 .gitignore 死规则，SKILL.md 约束改为定性描述

- 清理 scripts/ 空目录与 .gitignore 中指向 translate_pcn.py 的死规则
- AGENTS.md 的 SKILL.md 约束从硬性行数目标改为定性描述
| 提交 | 说明 |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-25T11:02:38+09:00

**摘要**：ruyi / CI / docs — 交叉编译修复、riscv64-cross 回归与精确 badge filter

- postPatch 改用 python.pythonOnBuildForHost
- CI 将 ruyi 系列回归 riscv64-cross
- riscv64 badge 恢复精确 job filter
| 提交 | 说明 |
|------|------|
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |

## 2026-06-25T10:12:02+09:00

**摘要**：CI / docs — ruyi 系列自 riscv64-cross 永久移除，badge 恢复 * 标记与注释

- riscv64-cross 永久移除 ruyi 系列（Python postPatch 交叉编译不可行）
- riscv64 badge 恢复 * 标记与注释说明
| 提交 | 说明 |
|------|------|
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |

## 2026-06-25T10:04:30+09:00

**摘要**：CI — 修复 access-tokens 覆盖导致的 API 限流，并限制 riscv64-cross 并发

- access-tokens 被覆盖导致 GitHub API rate limit 超限（合并双行为一行）
- riscv64-cross 并发上限设为 4
| 提交 | 说明 |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |

## 2026-06-25T09:44:44+09:00

**摘要**：CI / docs — ruyi 系列加回 riscv64-cross，badge 标签简化与 job 精确过滤

- riscv64-cross 加回 ruyi/ruyi-beta/ruyi-alpha（路径映射）
- badge 标签简化（`-` 取代 `--`）
- riscv64 job 精确过滤
| 提交 | 说明 |
|------|------|
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |

## 2026-06-25T09:29:43+09:00

**摘要**：CI / docs — build / riscv64-cross 拆分为按包 matrix，ruyi badge 扩展至 9 枚

- build / riscv64-cross job 按包拆分 matrix，支持独立 per-package badge
- ruyi 文档 badge 扩展为 3版本×3架构 = 9枚
| 提交 | 说明 |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |

## 2026-06-25T09:24:43+09:00

**摘要**：CI / docs — build job 增加 ruyi-beta / ruyi-alpha 构建，文档补通道版本号

- build job 添加 ruyi-beta / ruyi-alpha 构建步骤
- ruyi 基本信息表格的通道行加入 beta/alpha 版本号
| 提交 | 说明 |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |

## 2026-06-25T09:09:26+09:00

**摘要**：CI / overlays / docs — ruyi 三通道接入与 riscv64-cross 调整

- CI 将 ruyi 从 riscv64-cross 移除
- default overlay 添加 ruyi-beta/ruyi-alpha，nixConfig 提升至 flake 顶层
- README 软件表展示 ruyi 三通道版本号
| 提交 | 说明 |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |

## 2026-06-25T05:35:00+09:00

**摘要**：docs — 全部 5 语言 README 补充 ruyi-beta / ruyi-alpha devShell

- 5 语言 README 的 devShell 表加入 ruyi-beta / ruyi-alpha 条目
| 提交 | 说明 |
|------|------|
| `5d4ca02` | docs: add ruyi-beta + ruyi-alpha to devShell tables (all 5 READMEs) |

## 2026-06-25T05:28:12+09:00

**摘要**：ruyi — 包目录结构重构，beta/alpha 改为 thin wrapper 并新增 devShells

- 包重构为 packages/ruyi/ 目录结构
- beta/alpha 为 thin wrapper
- 新增 devShells
| 提交 | 说明 |
|------|------|
| `4b9865e` | refactor(pkgs): move ruyi into subdirectory, beta/alpha as thin wrappers |
| `94bb174` | feat(shells): add ruyi-beta + ruyi-alpha devShells |

## 2026-06-25T05:13:34+09:00

**摘要**：ruyi — 版本通道改为独立软件包，移除独立 overlay

- 版本通道改为独立软件包（ruyi / ruyi-beta / ruyi-alpha）
- 移除独立 overlay
| 提交 | 说明 |
|------|------|
| `51f23ad` | refactor(pkgs): ruyi channels as separate packages (not overlays) |

## 2026-06-25T04:58:36+09:00

**摘要**：ruyi — 建立三通道版本体系，基础包切至 0.50.0

- 三通道版本体系（stable/beta/alpha）
- 基础包切至 0.50.0 稳定版
- beta/alpha 通过 overlay 覆盖
| 提交 | 说明 |
|------|------|
| `a9f8baa` | feat(pkgs): ruyi 3-channel (stable/beta/alpha) via overlays |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| ruyi | 0.51.0-alpha.20260616 | 0.50.0（稳定） |
| 　 | 新增 ruyi-beta overlay | 0.50.0-beta.20260623 |
| 　 | 新增 ruyi-alpha overlay | 0.51.0-alpha.20260616 |

## 2026-06-24T03:19:30+09:00

**摘要**：workflow — 维护日志更新规则强制化

- AGENTS.md 与 write-maintenance-log 技能将维护日志更新设为强制
| 提交 | 说明 |
|------|------|
| `2e719df` | fix: make maintenance log update mandatory after every push |

## 2026-06-24T03:15:37+09:00

**摘要**：docs — 移除过时的 riscv64 构建指令

- 移除过时的本地 riscv64 构建指令
- CI 现已覆盖三架构
| 提交 | 说明 |
|------|------|
| `698400a` | docs: remove stale manual riscv64 build instructions — CI now covers all 3 architectures |

## 2026-06-24T03:06:20+09:00

**摘要**：codewhale 0.8.64 — 上游更新

- 上游更新，版本提升至 0.8.64
| 提交 | 说明 |
|------|------|
| `0bde292` | chore(pkgs): bump codewhale 0.8.64 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.63 | 0.8.64 |
| 　 | x64 cli hash | `sha256-SMaOUH...Z6M=` → `sha256-sKvJm6...XY=` |
| 　 | arm64 cli hash | `sha256-gGv2T4...M8=` → `sha256-gYofCL...jk=` |
| 　 | riscv64 cli hash | `sha256-qSVNms...g=` → `sha256-TOkojm...A=` |
| 　 | x64 tui hash | `sha256-UA66uC...M=` → `sha256-Q3wRQ5...M=` |
| 　 | arm64 tui hash | `sha256-m24T1T...g=` → `sha256-CSKaNh...M=` |
| 　 | riscv64 tui hash | `sha256-l1tgSn...w=` → `sha256-mAARZq...Y=` |

## 2026-06-24T02:30:21+09:00

**摘要**：CI — riscv64 交叉编译 pipeline，三架构全量覆盖

- 添加 riscv64 交叉编译 pipeline，CI 覆盖 x86_64 / aarch64 / riscv64 三架构
- 每包文档添加 riscv64 徽章
| 提交 | 说明 |
|------|------|
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |

## 2026-06-23T05:20:00+09:00

**摘要**：translate-pseudocn — 词典扩充与语序调整

- 基于网络研究扩充词典（7→46 条）
- 语序改为 SVO
- 全量重新生成 pcn 文档
| 提交 | 说明 |
|------|------|
| `4fbf387` | feat(pcn): expand dictionary 7→46 entries, add IT terminology from research |
| `ec38b7e` | feat(pcn): convert to SVO word order, expand dictionary, regenerate all 22 docs |

## 2026-06-23T04:19:16+09:00

**摘要**：translate-pseudocn 技能重构 — 伪中国语定义修订

- 伪中国语重新定义为「日语剥离假名后的视觉结果」，不再转换为中文
- 日本汉字原样保留（不简化）、SOV 语序保留
- 词典从 40 条精简为 7 条（仅片假名→日本汉字），全部 22 篇 pcn 文档重新生成
| 提交 | 说明 |
|------|------|
| `be0780b` | refactor(pcn): redesign pseudo-Chinese skill — Japanese-native kanji, SOV order, no Chinese chars |

## 2026-06-23T04:04:32+09:00

**摘要**：AGENTS.md — 去硬编码与语言体系自动发现

- 移除硬编码计数
- 移除冗余审计备忘
- 缓存章节重写为代理操作指南
- 移除用户侧描述
- 语言体系改为自动发现
| 提交 | 说明 |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:49:00+09:00

**摘要**：mcp-searxng 1.7.2 — 上游修复

- 上游修复，版本提升至 1.7.2
| 提交 | 说明 |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |

## 2026-06-22T23:22:00+09:00

**摘要**：AGENTS.md — 初次启动审计规则与访问控制调整

- 新增初次启动审计规则
- 访问控制移至顶部
| 提交 | 说明 |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**摘要**：docs — README 重复行修复与技能反模式补充

- 修复 README 的 `提供 nix develop` 重复行
- write-project-docs 技能补充「插入前检查重复内容」反模式
| 提交 | 说明 |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**摘要**：AGENTS.md — 补齐访问控制与流程规则

- 新增访问控制规则
- 新增语言要求
- 新增提交规范与维护记录检查
- 新增文档同步与泛化规则
- 新增多架构缓存规则
| 提交 | 说明 |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**摘要**：docs — 每包文档添加双架构 CI 徽章，技能模板同步

- 为全部 30 篇包文档添加双架构 CI 徽章
- 双架构徽章拆分为单独行
- CI 徽章与语言切换器之间补空行
- 技能模板同步为一徽章一行 + 空行间隔
| 提交 | 说明 |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**摘要**：CI — ARM runner 与 flake.lock 竞争修复

- 添加 ARM runner 多架构构建
- 修复 flake.lock 并发竞争（`--no-write-lock-file`）
| 提交 | 说明 |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**摘要**：mcp-searxng 与 ruyi — 哈希更新与 overlay 回移

- mcp-searxng：source hash + npmDepsHash 更新（GitHub archive 变化）
- ruyi：overlay postPatch 回移（补丁文件依赖）
| 提交 | 说明 |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**摘要**：docs — 缓存排除警告与 nixConfig 自动声明

- 添加缓存排除警告（overlay 与模块+补丁条目）
- README 缓存说明压缩
- flake.nix 添加 nixConfig 自动声明
| 提交 | 说明 |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**摘要**：docs — 全部 30 篇包文档的缓存节、CI badge 布局与技能同步

- 全部 30 篇包文档添加 `## 缓存` 节
- CI badge 布局改进
- 技能同步
| 提交 | 说明 |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**摘要**：CI/CD — 添加构建矩阵、二进制缓存与 AGENTS.md

- 添加 GitHub Actions 构建矩阵（Cachix 推送）
- 添加二进制缓存
- 添加 AGENTS.md
| 提交 | 说明 |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**摘要**：skills — 三技能拆分词典与模板、SKILL.md 压缩

- translate-katalish / translate-pseudocn / write-project-docs 拆分词典与模板
- SKILL.md 压缩至 60-80 行
| 提交 | 说明 |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**摘要**：docs — MAINTENANCE 时间戳与去重修整、nix-kits→nixkits 全量替换

- MAINTENANCE 时间戳精确化（29 节）
- 删除 30 个重复节（SHA 去重）
- nix-kits→nixkits 全量替换（183 处）
- 模块文档同步
| 提交 | 说明 |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**摘要**：patches — ruyi-nixos-compat.patch 基于干净克隆重建

- ruyi-nixos-compat.patch 基于干净克隆重建（1223→426 行）
- 清除 flake.lock 自引用 artifact
| 提交 | 说明 |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**摘要**：overlays — patches 列表去重、ruyi-nixos-compat 精简与 llama-cpp-rocm 注释

- patches 列表 lib.unique 去重
- ruyi-nixos-compat 精简
- llama-cpp-rocm 添加 curried 形式注释
| 提交 | 说明 |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**摘要**：modules — enable 选项、assertions 与 nixkits.* 命名空间统一

- 4 模块添加 enable 选项
- comfyui-strix-halo 添加 assertions
- 命名空间统一至 nixkits.*（含向后兼容）
- llama-cpp-rocm hfCacheDir 动态推导
| 提交 | 说明 |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**摘要**：codewhale 0.8.63 与 ruyi — 多架构二进制、postPatch 合并与 meta 补全

- codewhale 0.8.63 — 多架构预编译二进制（x86_64 / aarch64 / riscv64）
- ruyi — overlay postPatch 合并入包
- meta 字段补全
| 提交 | 说明 |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**摘要**：flake — 移除 mihomo-alpha 幽灵输入与 overlay

- 移除 mihomo-alpha 幽灵输入与 overlay（文件从未存在）
| 提交 | 说明 |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |

## 2026-06-21T04:32:31+09:00

**摘要**：语言切换器标签规则泛化 — display_name 语义修正与残留名称修正

- display_name 语义修正为语言自称
- 添加语言名称不本地化规则至 write-project-docs / translate-katalish / translate-pseudocn 三技能
- 修正 zh/katalish/pcn 全部文档切换器中残留的本地化名称
| 提交 | 说明 |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称与切换器标签分离 |
| `aa8634b` | fix(docs): zh 文档切换器残留旧名称修正 + MAINTENANCE 翻译补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**摘要**：codewhale 0.8.62 与 mcp-searxng 1.7.1 — 上游修复

- codewhale 0.8.62 — 上游修复
- mcp-searxng 1.7.1 — 上游修复
| 提交 | 说明 |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

## 2026-06-20T18:36:33+09:00

**摘要**：技能系统重构 — 技能重命名与语言扩展自动发现

- translate-katakana→translate-katalish 重命名
- 新增 translate-pseudocn（偽中国語）
- write-project-docs 与 write-maintenance-log 语言扩展自动发现
- 文档代码五语映射表
| 提交 | 说明 |
|------|------|
| `0588ee0` | skill: write-project-docs 新增伪中国语(pcn)语言支持 |
| `c5fb218` | docs: write-project-docs 英日文版同步更新四语(pcn)支持 |
| `f1904a1` | feat(skill): add translate-katakana — katakana english mechanical substitution |
| `97b696c` | docs(skill): purge pcn references from write-project-docs, add kata-en |
| `7caf343` | refactor(translate-katakana): rename kata-en → katalish, use ｶﾀﾘｯｼｭ as canonical name |
| `911052b` | refactor(docs): migrate pcn directory to katalish |
| `39906b9` | docs: purge remaining pcn references from zh write-project-docs |
| `177ad9b` | refactor: rename translate-katakana→translate-katalish, add translate-pseudocn, auto-discovery |
| `fee1534` | docs(skill): add translate-* support and docs-as-code mapping to write-maintenance-log |

## 2026-06-18T09:52:34+09:00

**摘要**：codewhale 0.8.61 与 mcp-searxng 1.6.0 — 上游修复

- codewhale 0.8.61 — 上游修复
- mcp-searxng 1.6.0 — 上游修复
| 提交 | 说明 |
|------|------|
| `719e16e` | chore(pkgs): bump codewhale 0.8.61 |
| `d6717c1` | chore(pkgs): bump mcp-searxng 1.6.0 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.60 | 0.8.61 |
| 　 | cli hash | `...` → `sha256-3k0K/I/NxYHrNszgniQncWTu8HRqsR3RSg+YLuB+IkY=` |
| 　 | tui hash | `...` → `sha256-YVjKDO/JNnsAHwzCf4itrEw8psKyi9bbFaLJLFvMyAI=` |
| mcp-searxng | 1.4.0 | 1.6.0 |
| 　 | source hash | `...` → `sha256-oBpSAAppLfnPhC3tHoE2X1YAGMyd42fka+xAVFuhjKw=` |
| 　 | npmDepsHash | `...` → `sha256-7z5T8po2ya698J7vqu4pA7c8s85k33sRbOV2tRmGdPo=` |

## 2026-06-18T09:03:48+09:00

**摘要**：ruyi — NixOS 兼容性补丁

- NixOS 兼容性补丁 `patches/ruyi-nixos-compat.patch`
- 透明处理预编译 RISC-V 工具链的动态链接器路径
- GCC 子进程 ELF interpreter 修复
- console_scripts argv0 问题
| 提交 | 说明 |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

## 2026-06-17T10:59:35+09:00

**摘要**：ruyi — NixOS 模块（`services.ruyi`）

- 声明式生成 `/etc/xdg/ruyi/config.toml` 与环境变量
| 提交 | 说明 |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

## 2026-06-17T10:03:05+09:00

**摘要**：ruyi — 新增 devShell 支持

- `nix develop github:Kihara777/NixKits#ruyi` 即可进入环境
| 提交 | 说明 |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

## 2026-06-17T09:48:33+09:00

**摘要**：ruyi 0.51.0-alpha.20260616 — 新包（RuyiSDK 包管理器）

- Python / Poetry 构建
- ruff + mypy + 320 单元测试 + 52 集成测试全部通过
| 提交 | 说明 |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

## 2026-06-17T07:37:39+09:00

**摘要**：write-maintenance-log 技能 — 独立技能化与 flake.lock 同步检测

- 从 nixkits-check-updates 剥离为独立技能，双入口设计（记入维护记录 + 更新维护记录）
- flake.lock 同步 .gitignore 前置检测与三路分支逻辑
| 提交 | 说明 |
|------|------|
| `b77170a` | docs(skill): re-apply flake.lock sync and build verification steps |
| `be2239b` | docs(skill): add .gitignore pre-check to flake.lock sync step |
| `704ebe4` | docs(skill): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(skill): extract write-maintenance-log as standalone skill |
| `5187b07` | docs(skill): optimize write-maintenance-log triggers and add audit entry |
| `34bf34e` | feat(skill): add write-maintenance-log SKILL.md (zh) |
| `edce70f` | refactor(docs): switch MAINTENANCE.md to ISO 8601 precise timestamps |
| `fb6f1a5` | docs(skill): write-maintenance-log — add auto-discovery contract |
| `fe4b13f` | fix(docs): remove non-patch sections from MAINTENANCE.md |
| `d5318fb` | docs(skill): write-maintenance-log — add 使用 section |
| `e9e40f4` | docs(skill): add write-maintenance-log skill with trilingual docs |
| `c9dedf9` | docs(skill): write-maintenance-log — add en/ja skill docs |

## 2026-06-17T06:48:47+09:00

**摘要**：fix(mcp-searxng): 修复入口文件错误

- 入口文件 dist/index.js → dist/cli.js
- MCP 服务器可正常启动
| 提交 | 说明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

## 2026-06-17T06:46:13+09:00

**摘要**：llama-cpp-rocm — 尝试用 builtins.fetchurl 替代 flake input 动态获取版本

- 已撤销，方案不可用
| 提交 | 说明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

## 2026-06-16T06:03:24+09:00

**摘要**：mcp-searxng 文档 — CodeWhale MCP 配置指南、常见陷阱警告与故障排查章节

- CodeWhale MCP 配置指南
- 常见陷阱警告（env 默认为 {}）
- 故障排查章节
| 提交 | 说明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

## 2026-06-16T05:20:34+09:00

**摘要**：nixos-modern-cli 技能 — Nix Store 路径陷阱章节

- gh auth setup-git 硬编码路径失效的诊断
- 通用修复模式
| 提交 | 说明 |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

## 2026-06-16T04:56:06+09:00

**摘要**：opencode-telegram 0.21.2 — 上游修复及依赖更新

- 上游修复及依赖更新，版本提升至 0.21.2
| 提交 | 说明 |
|------|------|
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |
| `3b05a32` | docs(MAINTENANCE): record 2026-06-16 update (opencode-telegram 0.21.2) |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | source hash | `sha256-V/rThMV5...` → `sha256-NEaQ2grHCKXi13utcHeUR83pJT6kqBGS4UqllhG93kY=` |
| 　 | npmDepsHash | `sha256-Bcexury...` → `sha256-z9trDo9xeWZyTSvCqX5XTb+AHY50wk0gsoEnAAEHOEg=` |

## 2026-06-15T17:32:16+09:00

**摘要**：codewhale 0.8.60 — 上游修复

- 上游修复，版本提升至 0.8.60
| 提交 | 说明 |
|------|------|
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |
| `3cef0a8` | docs(MAINTENANCE): record 2026-06-15 update (codewhale 0.8.60) |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `sha256-ti/IBPZV...` → `sha256-JqlByElHoLcR2Mlwmx5Qczfj+EoAp+igdLCd/QUOsX4=` |
| 　 | tui hash | `sha256-3Lh80hTS...` → `sha256-LTf681cWVH9Cu3TQrFeMlJUNVVG+TWxO2oI6VXK+4zA=` |

## 2026-06-14T08:11:16+09:00

**摘要**：comfyui-strix-halo 文档 — 在线集成模式说明与文件结构图

- 在线集成模式说明
- 文件结构图
| 提交 | 说明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

## 2026-06-14T07:56:11+09:00

**摘要**：codewhale 0.8.59 与 mcp-searxng 1.4.0 — 版本更新

- codewhale 0.8.59 — 修复若干 TUI 渲染问题
- mcp-searxng 1.4.0 — 新增 HTTP 传输模式
| 提交 | 说明 |
|------|------|
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `ec7d5ca` | docs(MAINTENANCE): record 2026-06-14 updates (codewhale 0.8.59, mcp-searxng 1.4.0) |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
| 　 | cli hash | `sha256-AR9jJZzB...` → `sha256-ti/IBPZVJdaLvQ00OevzTfcMQ0XHELvOKTcul4+iBg8=` |
| 　 | tui hash | `sha256-BpCHu9M...` → `sha256-3Lh80hTSMG0RG+CHkR403rqcMtDA6kMdbyvBe7sLQaQ=` |
| 　 | source hash | `sha256-Xsp1vReg...` → `sha256-RMzxCBua89oYbKXmwXCtcSHan5QVefsm8IBdMIVq7UE=` |
| 　 | npmDepsHash | `sha256-3hWshG0...` → `sha256-Lh1UoM8zSMFji/TkqDAOiRtFRrQ/jqn5TbONySj9ckg=` |

## 2026-06-12T18:17:52+09:00

**摘要**：llama-cpp-rocm 模块 — 恢复 modelsPreset 支持与命名空间迁移

- 恢复 modelsPreset 支持（nixpkgs 已移除）
- 命名空间迁移至 nixkits
- 三语迁移指南
| 提交 | 说明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

## 2026-06-12T17:29:59+09:00

**摘要**：feat(llama-cpp-rocm): 恢复 modelsPreset 支持与命名空间迁移

- 恢复 modelsPreset 支持（nixpkgs 已移除）
- 命名空间迁移至 nixkits
## 2026-06-12T10:51:31+09:00

**摘要**：codewhale 0.8.58 与 mcp-searxng 1.3.4 — 上游修复

- codewhale 0.8.58 — 上游修复
- mcp-searxng 1.3.4 — 上游修复
| 提交 | 说明 |
|------|------|
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |
| `ef9daae` | chore(pkgs): bump mcp-searxng 1.3.4 |
| `716d98c` | docs(MAINTENANCE): record 2026-06-12 updates (codewhale 0.8.58, mcp-searxng 1.3.4) |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| mcp-searxng | 1.3.2 | 1.3.4 |
| 　 | cli hash | `sha256-Hp0Z6mwe...` → `sha256-AR9jJZzB1VNUe7yaI3jpSUJsXuzgvqk5aWeLWe/L/vA=` |
| 　 | tui hash | `sha256-dExfhrfG...` → `sha256-BpCHu9MbDGuCAXNNJXPTZpj3BrIwx7jWs29I31cbSag=` |
| 　 | source hash | `sha256-OVllsRM...` → `sha256-Xsp1vRegHDWNk54nqLk+4l5MI0xGgocCg5Qa2UwWNqA=` |
| 　 | npmDepsHash | `sha256-LN9yDbw...` → `sha256-3hWshG0L8k0U2fnmz0OotrYaPAYBQE7DanjXgnFnNrE=` |

## 2026-06-11T05:28:59+09:00

**摘要**：技能文档 — 维护日志格式规则系列

- 自动发现泛化
- 描述性标题
- 精确 git commit 时间戳
- 禁止 `T00:00:00` 占位符
| 提交 | 说明 |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

## 2026-06-11T05:13:39+09:00

**摘要**：other — 文档补充与措辞修正

- 补充缺失的 rog-control-center-fix 三语模块文档
- 修正作者署名中 DeepSeek V4 Pro 的大小写
| 提交 | 说明 |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

## 2026-06-11T04:52:16+09:00

**摘要**：codewhale 0.8.57 与 mcp-searxng 1.3.2 — TUI 新增与上游修复

- codewhale 0.8.57 — TUI 新增
- mcp-searxng 1.3.2 — 上游修复
| 提交 | 说明 |
|------|------|
| `543bcf9` | chore(pkgs): bump codewhale 0.8.57, mcp-searxng 1.3.2 |
| `7902bd1` | docs(MAINTENANCE): fix timestamps to exact commit times |
| `f92f9c4` | docs(MAINTENANCE): use descriptive titles instead of filename |
| `07f347f` | docs(skill): add descriptive title rule for MAINTENANCE files |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.55 | 0.8.57 |
| mcp-searxng | 1.3.1 | 1.3.2 |
| 　 | cli hash | `sha256-jwn3rKD...` → `sha256-Hp0Z6mweaC+sB/BH2KpD1W/sdS0me69pErKiWOa2GqY=` |
| 　 | tui hash | `sha256-1Cxofu9...` → `sha256-dExfhrfGs1wbWWmvXYTuCGXKnkhD+7rBY32aV938Dz0=` |

## 2026-06-10T04:31:20+09:00

**摘要**：opencode-telegram — KillMode 与 TimeoutStopSec 调整

- KillMode 改为 process
- 添加 TimeoutStopSec 防止关机挂起
| 提交 | 说明 |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

## 2026-06-10T02:28:10+09:00

**摘要**：codewhale 0.8.55 与 mcp-searxng 1.3.1 — 上游修复

- codewhale 0.8.55 — 上游修复
- mcp-searxng 1.3.1 — 上游修复
| 提交 | 说明 |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

## 2026-06-08T15:12:39+09:00

**摘要**：文档重构 — 本地化文件移入 docs/，MAINTENANCE.md 首次添加格式规则与回填历史

- 本地化文件移入 docs/ 目录
- MAINTENANCE.md 首次添加合列规则
- MAINTENANCE.md 首次添加纯表格格式
- 回填完整提交历史
| 提交 | 说明 |
|------|------|
| `b3d7d0f` | docs: switch MAINTENANCE.md to table-only format, drop trilingual prose |
| `e4a3813` | docs: omit build status and unchanged hashes from MAINTENANCE.md |
| `4bf2d30` | docs(skill): add first-time package table format rule |
| `f7bb6ce` | docs(skill): merge version columns for first-time packages |
| `1a28625` | docs(MAINTENANCE): backfill full package history from repo creation |
| `b4742ad` | docs(skills): sync refined MAINTENANCE.md format rules to trilingual docs |
| `2f58ac5` | refactor: move localized README/MAINTENANCE files into docs/ |
| `551e6fd` | docs(skills): sync localized-file-in-docs/ rule and path updates |

## 2026-06-08T14:25:02+09:00

**摘要**：mcp-searxng 1.2.1 — 上游修复

- 上游修复，版本提升至 1.2.1
| 提交 | 说明 |
|------|------|
| `07b1ee5` | chore(pkgs): bump mcp-searxng 1.1.0 → 1.2.1 |
| `db680df` | docs: add MAINTENANCE.md — software update changelog |
| `d4cb81f` | docs(skill): add Step 8 — MAINTENANCE.md update workflow |
| `5ba1361` | docs(skills): sync MAINTENANCE.md step to trilingual docs |
| `b8a98bc` | docs(skill): skip MAINTENANCE.md when no updates found |
| `2cd9daf` | docs: drop doc-sync line from MAINTENANCE; only record substantive rewrites |
| `b34ed08` | docs: add trilingual MAINTENANCE (en/ja) with language switchers |
| `e5e505e` | docs(skills): sync trilingual MAINTENANCE rule to skill docs |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | 1.1.0 | 1.2.1 |

## 2026-06-08T14:22:25+09:00

**摘要**：rcc-fix — NixOS 模块（systemd 死锁修复）

- NixOS 模块：systemd 死锁修复
| 提交 | 说明 |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

## 2026-06-06T15:17:11+09:00

**摘要**：技能文档 — 文档同步规范、工具链说明与规则泛化

- 源变更后文档同步规范
- comfyui-strix-halo C 工具链说明
- hash 计算注意事项泛化
- 基本情報规则多语言统一
| 提交 | 说明 |
|------|------|
| `7e22edd` | docs(skill): add skill doc template, sync rules, and staleness check |
| `86fc7c2` | docs(skills): sync write-project-docs trilingual docs with SKILL.md |
| `454a4e4` | fix(skill): generalize 基本情報 rule to all languages, not just Japanese |
| `28ec492` | docs(skills): sync generalized 基本情報 rule to trilingual docs |
| `c79ffff` | docs(skill): add SRI hash format and nix build gotchas to update skill |
| `6dcbbfc` | docs(skills): sync hash gotchas to nixkits-check-updates trilingual docs |
| `58b06ea` | docs(comfyui-strix-halo): clarify kernel param is set by module, not hardware |
| `2ba85d3` | docs(comfyui-strix-halo): add C build toolchain + CC=gcc to changes list |
| `f5941ae` | docs(skill): add anti-patterns for stale/unsynced doc bullets after source changes |
| `b8c2399` | docs(skills): sync source-change doc sync rule to trilingual docs |

## 2026-06-06T13:58:47+09:00

**摘要**：codewhale 0.8.53、mcp-searxng 1.1.0 与 opencode-telegram 0.21.1 — 上游修复

- codewhale 0.8.53 — 上游修复
- mcp-searxng 1.1.0 — 上游修复
- opencode-telegram 0.21.1 — 上游修复
| 提交 | 说明 |
|------|------|
| `300a9a6` | chore(pkgs): bump codewhale 0.8.53, mcp-searxng 1.1.0, opencode-telegram 0.21.1 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.49 | 0.8.53 |
| mcp-searxng | 1.0.4 | 1.1.0 |
| opencode-telegram | 0.21.0 | 0.21.1 |
| 　 | cli hash | `sha256-97zk4L...` → `sha256-VxBNH2o4iEkk0PrnuZHDPECjvm+ARXR9T/BV8QqvYtw=` |
| 　 | tui hash | `sha256-tc/s3e...` → `sha256-DBiWk4c4QFh/BKPlG5a3KkH0ZTxNQgqZ7IWwH4OaEEw=` |
| 　 | source hash | `sha256-ML5Hgle...` → `sha256-OVllsRMst6dWO/RagsmGyWN3muz1ATtffxfmLTfa0qU=` |
| 　 | npmDepsHash(searx) | `sha256-xnefgQ...` → `sha256-LN9yDbwvlICoFl5KgQvzZjLGXflVM0QkSzaB2dJzR/w=` |
| 　 | source hash(telegram) | `sha256-Al7CVol...` → `sha256-V/rThMV5qZ5Z07A+A54Il4Vi/69bv8PVgV6uIr6vxGA=` |
| 　 | npmDepsHash(telegram) | `sha256-ZOhS7l...` → `sha256-BcexuryL26CNLKeAOR9DffE07H4dYO1UYPqfX9aHm4g=` |

## 2026-06-06T12:51:46+09:00

**摘要**：comfyui-strix-halo 补丁 — ROCm 7.2 wheels 内嵌支持

- ROCm 7.2 wheels 内嵌支持
| 提交 | 说明 |
|------|------|
| `e11f899` | fix(docs): add missing ja doc and en/ja README entries for comfyui-strix-halo |
| `48d842f` | docs(ja): add 基本情報 section to comfyui-strix-halo |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs in NixKits concise style |
| `8f16f91` | docs(skill): add length/structure rules from comfyui-strix-halo doc fix |
| `468b89a` | feat(skill): add patch-embedded version check for comfyui-strix-halo |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| comfyui-strix-halo | 补丁（ROCm 7.2 wheels 内嵌） |

## 2026-06-04T13:07:30+09:00

**摘要**：技能系统 — SKILL.md 中文化与三语对称性检查

- SKILL.md 全面中文化
- 三语对称性检查规则
| 提交 | 说明 |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

## 2026-06-02T10:15:53+09:00

**摘要**：other — 文档批量补充与修整

- 新增 recover-nixos-config 技能及多语文档
- 修正 Skills 章节标题与通用 agent 描述
- 本地模型名标注量化等级
- 量化标签加 UD- 前缀
- 添加 MIT 许可证文件并从各 README 链接
- 补本地 flake input 示例（与远程并列）
- 修正本地 flake input 语法以匹配实际用法
| 提交 | 说明 |
|------|------|
| `3be4889` | docs: add recover-nixos-config skill with multi-language docs |
| `fc5eca3` | docs: fix Skills section titles and generic agent descriptions |
| `d2e071f` | docs: add quantization levels to local model names |
| `22d206c` | docs: add UD- prefix to model quantization labels |
| `f15db79` | docs: add MIT license file and link from all READMEs |
| `218aeca` | docs: add local flake input example alongside remote |
| `4f0f968` | docs: fix local flake input syntax to match actual usage |

## 2026-06-02T08:49:47+09:00

**摘要**：opencode-telegram — flake module 与文档整备

- 新增 NixOS module，配置改为声明式
- 文档简化为仅 flake module 配置，移除手动 systemd 说明
- 文档将 NixOS module 改名为 flake module
- 文档改用准确节名——服务配置而非 module
- 文档在服务配置处展示完整 flake.nix 上下文
- 文档节标题统一为 flake module，并跨语言一致
- 模块启用时自动安装包
- 文档补首次设置流程（opencode serve + 配置）
| 提交 | 说明 |
|------|------|
| `8fe0b3d` | feat(opencode-telegram): add NixOS module with declarative config |
| `8fe3fae` | docs(opencode-telegram): simplify to flake module config only, remove manual systemd |
| `ee0a904` | docs(opencode-telegram): rename NixOS module → flake module |
| `a38e426` | docs(opencode-telegram): use accurate section name — service config, not module |
| `dea4dc6` | docs(opencode-telegram): show full flake.nix context in service config |
| `44975ed` | docs(opencode-telegram): flake module as section title, consistent across langs |
| `941eb48` | feat(opencode-telegram): auto-install package when module enabled |
| `2a8c41b` | docs(opencode-telegram): add first-time setup flow (opencode serve + config) |

## 2026-06-02T05:57:11+09:00

**摘要**：codewhale 0.8.49、mcp-searxng 1.0.4、obs-bilibili-stream 2.1.0 与 opencode-telegram 0.21.0 — 上游修复

- `codewhale` 0.8.49 — 上游修复
- `mcp-searxng` 1.0.4 — 上游修复
- `obs-bilibili-stream` 2.1.0 — 上游修复
- `opencode-telegram` 0.21.0 — 上游修复
| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.47 | 0.8.49 |
| mcp-searxng | 1.0.3 | 1.0.4 |
| obs-bilibili-stream | 2.0.12 | 2.1.0 |
| opencode-telegram | 0.20.5 | 0.21.0 |
| 　 | cli hash | `sha256-JGNVKih...` → `sha256-97zk4LzahspVqd8U/Z8rfS60oOWNUPsWn4xtn/rL8CQ=` |
| 　 | tui hash | — → `sha256-tc/s3e1oomJhfYEN1EtuEtPBF77dByrMimDH3bQibCI=` |
| 　 | source hash(searx) | `sha256-xS2Hr/g...` → `sha256-ML5HgleThmzBwJFtmsCQEPxHvZz4gzrDxW3Udkx9YjA=` |
| 　 | npmDepsHash(searx) | `sha256-...+` → `sha256-xnefgQnFuHVPSCWVSD8MWxjHmNSrKpWlbGaAtks5rkg=` |
| 　 | source hash(obs) | — → `sha256-lbN73L3ey7qZftsgmRGb9wPcj8DmwlOUWR9gdEni29w=` |
| 　 | source hash(tele) | `sha256-RKsZwK...` → `sha256-Al7CVol/HDgH3M0FwkdQWOze6xY/wvaWOskRsh9Abxo=` |
| 　 | npmDepsHash(tele) | `sha256-...+` → `sha256-ZOhS7lX5z2bRi0Cilm2QBUVKmacK41oRcUn9kRcfdOg=` |

## 2026-06-02T03:42:25+09:00

**摘要**：nixos-modern-cli 技能 — POSIX 工具指南与 nix 二进制路径提示

- 新增 POSIX 工具指南
- 新增 nix 二进制路径提示
| 提交 | 说明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

## 2026-05-31T03:42:18+09:00

**摘要**：write-project-docs — 新技能

- 按 NixKits 风格为任意项目编写多语言文档体系
| 提交 | 说明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

## 2026-05-30T03:42:14+09:00

**摘要**：codewhale、llama-cpp-rocm 与 opencode-telegram — 拼写、文档与流程修正

- `codewhale`：stdenv 拼写错误导致构建失败，已修
- `llama-cpp-rocm`：文档删除内联链接，改用 system.nix 的完整预设
- `opencode-telegram`：新增首次设置流程
| 提交 | 说明 |
|------|------|
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

## 2026-05-30T03:19:48+09:00

**摘要**：other — 多语 README 与 I18n 结构

- 添加 en/ja 译文与 I18n 结构
- 添加 en/ja README 与语言切换器
| 提交 | 说明 |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

## 2026-05-29T15:25:12+09:00

**摘要**：kitsfmt — 多项修复；rcc-fix — 重写为 D-Bus 热插拔检测；build — .vscode gitignore 范围修正

- `kitsfmt`：`vendor` 目录恢复，以便离线构建
- `kitsfmt`：修复幂等性与原地安全性
- `kitsfmt`：`with`→`builtins.attrValues` 转换、新增 `--stdin` 标志
- `rcc-fix`：重写为 D-Bus 热插拔检测
- `build`：`.vscode` gitignore 范围修正
| 提交 | 说明 |
|------|------|
| `6a42efd` | fix(kitsfmt): idempotency, inplace safety, output validation |
| `1b7d0a9` | fix(build): restrict .vscode gitignore to repo root to not exclude vendored crate files |
| `2b237ff` | feat(kitsfmt): with→builtins.attrValues best-practice transformation |
| `8497bf7` | feat(kitsfmt): add --stdin flag for explicit stdin mode |
| `a612af7` | feat(rcc-fix): rewrite patch for asusctl 6.3.7 with hot-plug and boundary checks |
| `e56f122` | fix(rcc-fix): scope hotplug variable correctly for asusctl build |
| `15a0104` | fix(kitsfmt): restore vendor dir for offline builds |
| `6ba43df` | fix(rcc-fix): set keyboard_connected=false when no aura iface found |
| `b7ebbfa` | fix(rcc-fix): replace polling with D-Bus InterfacesAdded event |

## 2026-05-29T13:16:30+09:00

**摘要**：docs: 修正 codewhale 的类型描述（预编译二进制，非源码构建）

- 类型描述更正为预编译二进制，而非源码构建
| 提交 | 说明 |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

## 2026-05-29T10:18:46+09:00

**摘要**：codewhale v0.8.47 — 新包

- DeepSeek V4 TUI agent
- 改用预编译二进制，移除 `cargoHash`
| 提交 | 说明 |
|------|------|
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | v0.8.47 |

## 2026-05-29T06:28:50+09:00

**摘要**：fix(kitsfmt): 修复多个格式化问题与幂等性

- 修复 `inherit` 逗号、缩进字符串损坏、lambda 空格等格式化问题
- 修复幂等性
| 提交 | 说明 |
|------|------|
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |

## 2026-05-29T05:57:55+09:00

**摘要**：fix(build): 修复 .vscode gitignore 范围过宽导致 vendored crate 文件被排除

- `.vscode` gitignore 限定到仓库根，不再排除 vendored crate 文件
| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|

## 2026-05-28T08:29:27+09:00

**摘要**：llama-cpp-rocm、opencode-telegram、rcc-fix 与技能文档 — 模块、属性与措辞修正

- `llama-cpp-rocm`：新增 NixOS 模块，覆盖 systemd 沙箱
- `opencode-telegram`：NixOS 模块（声明式配置、自动安装）
- `rcc-fix`：`ScrollView` 由 if 条件改用 `visible` 属性
- 技能文档：动态发现措辞、移除硬编码计数、补安装章节、简化描述
| 提交 | 说明 |
|------|------|
| `3d2c38c` | docs(skill): nixkits-check-updates — dynamic discovery, not hardcoded list |
| `e5ee4ab` | docs(skill): remove hardcoded count from features, add exclusion note |
| `814731e` | docs(skill): sync ja doc with zh/en — dynamic discovery wording |
| `713b693` | fix(rcc-fix): use visible: property instead of if conditional for ScrollView |
| `34d309b` | docs(skills): add Install section with full 5-agent support to all skills |
| `2db934e` | docs(zh): simplify Skills description, remove semantic duplication |
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

## 2026-05-27T06:08:13+09:00

**摘要**：技能系统 — nixkits-check-updates、nixkits-skills 与 nixos-modern-cli 三大技能同步上线

- 三个技能同批加入，各带三语文档
- `llama-cpp-rocm`：补充动态追踪上游 Release 的说明
| 提交 | 说明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

## 2026-05-26T05:30:58+09:00

**摘要**：文档 — README 节名重命名（快速开始→添加、包→软件、License→许可）

- `快速开始`→`添加`
- `包`→`软件`
- `License`→`许可`
| 提交 | 说明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

## 2026-05-24T03:01:02+09:00

**摘要**：mcp-searxng 文档 — SearXNG + lighttpd 反向代理完整 NixOS 配置

- 文档补全 SearXNG + lighttpd 反向代理的完整 NixOS 配置
| 提交 | 说明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

## 2026-05-22T06:45:11+09:00

**摘要**：llama-cpp-rocm — 移除 llama-cpp-ver flake 输入

- 移除 llama-cpp-ver flake 输入
- 使用 nixpkgs 默认版本
| 提交 | 说明 |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

## 2026-05-21T16:35:02+09:00

**摘要**：mcp-searxng v1.0.3 与 opencode-telegram v0.20.5 — 新包

- mcp-searxng v1.0.3 — 新包
- opencode-telegram v0.20.5 — 新包
| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

## 2026-05-16T19:07:54+09:00

**摘要**：kitsfmt — 宏语法错误修复、函数简化与 src 路径修正

- 修复 `match_ast!` 宏语法错误
- 简化 `comments_before` 函数
- 修正 src 路径
| 提交 | 说明 |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

## 2026-05-15T16:59:28+09:00

**摘要**：kitsfmt — 基于 rnix AST 重写格式化引擎

- 基于 rnix AST 重写格式化引擎（v0.3.0）
- 生成 Cargo.lock
| 提交 | 说明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |

## 2026-05-14T17:10:06+09:00

**摘要**：llama-cpp-rocm — 新包

- 动态追踪上游最新 Release
| 提交 | 说明 |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

## 2026-05-14T07:38:08+09:00

**摘要**：kitsfmt 与 obs-bilibili-stream v1.0.0 — 新包

- kitsfmt — 新包（自建 Nix 格式化器）
- obs-bilibili-stream v1.0.0 — 新包
| 提交 | 说明 |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

## 2026-05-01T01:08:15+09:00

**摘要**：rcc-fix — 新包

- asusctl 补丁
| 提交 | 说明 |
|------|------|
| `e2d09a2` | RCC-Fix |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（overlay + patch） |

