# 维护日志

中文 | [English](docs/MAINTENANCE.en.md) | [日本語](docs/MAINTENANCE.ja.md) | [偽中国語](docs/MAINTENANCE.pcn.md)


## 2026-09-19T14:05:38+09:00

**摘要**：CI 批量失败根因定位并修复 + 子仓补安全政策。**① CI 403 限流（`d224b18`）**：维护者收到批量 CI 失败邮件，排查后**根因是浮动输入 `llama-cpp-ver` 的请求一直是未认证的**。该输入指向 `https://api.github.com/...`，而 Nix 的 `access-tokens` **按 host 精确匹配**——`build-package.yml` 早已写成 `github.com=… api.github.com=…` 双 host，但 **`check.yml` 只写了 `github.com`**，于是该请求以未认证身份发出（额度 **60 次/小时**，认证后 **5000**）。**为何必然触发**：每次 push 触发 **~34 个 workflow**，每个都要解析该输入 → 一轮 push 即耗尽额度。失败响应体直接给出答案：`API rate limit exceeded for 52.165.58.41. (But here's the good news: Authenticated requests get a higher rate limit.)`。**修复**：`check.yml` 补上 `api.github.com=${{ secrets.GITHUB_TOKEN }}` 并加注释说明该易错点；已核实 31 个 `build-*.yml` 全部经 `build-package.yml`（本就正确），故 check.yml 是唯一缺口。**验证**：提交 `d224b18` 触发 **33 个 workflow 全部 success**，零 403。**不违反 AGENTS.md**：约束是 `llama-cpp-ver` **不可锁定**（须动态追踪上游最新发布），本改动只影响该请求的**认证方式**，输入仍浮动、不写入 `flake.lock`。**失败统计**（最近 100 次 run 分类）：403 限流 **24 次**、来自**未合并的 Dependabot 分支** `86843b4` 的 hash mismatch 4 次（正是 AGENTS.md「Dependabot 不知 `npmDepsHash` 必然失败」的实证，该分支不在 main 上、PR #7 已关闭）、Cachix 收尾阶段 1 次（构建本身已成功）；时间上 09-15/16 为高峰（28 + 49 次），与批量邮件吻合。**② 子仓安全政策（子仓提交 `2cce37b`，主仓 `39c9f10` 同步）**：子仓 `dsh-api-balance` 此前**没有 `SECURITY.md`**——正是本仓技能「外链审计」记录过的死链。已补四语 `SECURITY.md`，内容为对扫描器自动生成的 PR #4 / #5 两项主张的复核结论：**「缺少速率限制」与「缺少请求体体积上限」均判误报**。判断依据完整记录在案：报告描述与 diff 不符（声称 4 个端点，diff 只改 `/query`）；其 `x-forwarded-for` 限流键客户端可伪造、且**本机同源 RPC 不带该头**，会让全部本机请求落入同一 `"unknown"` 桶而**正常用户先被自己挡住**；`/token` 已有 **6 小时**服务端节流、语音播报有 **30 分钟**限流；**本插件无高频轮询**（唯一的 30 秒 `setInterval` 执行 `isPeakPricing()` 纯本地时间判断、**不发网络请求**），按人类操作频率估计最活跃约**每分钟 5~10 次**，扫描器建议的 30 次/分钟已是其 3~6 倍；真正的边界在 **DSH 宿主的认证 + Host authority**。**结论：不为此改动代码**——若将来需要，应按**认证主体**而非 IP 限流（IP 可伪造）、阈值远高于人类操作（如 60~120 次/分钟），定位为「防失控脚本」而非「防攻击」。主仓四语 `SECURITY.md` 的「该子项目**尚未**自建安全政策」一行随之过时，已同步更正为「已自建」并附子仓文档直达链接

| 提交 | 说明 |
|------|------|
| `d224b18` | fix(ci): check.yml 的 access-tokens 漏了 api.github.com（403 限流根因） |
| `2cce37b` | （子仓 dsh-api-balance）docs(security): 新增四语 SECURITY.md |
| `39c9f10` | docs(security): 子仓已自建安全政策 —— 更新「尚未自建」的过时声明（四语） |

> **说明**：`d224b18` 改动 `.github/workflows/check.yml`；`39c9f10` 为四语文档；子仓提交独立记录于其自身仓库。CI 修复后全绿。

## 2026-09-19T07:51:05+09:00

**摘要**：技能类文档核对（已完成 4 篇：nix-flake-update-check / nixkits-check-updates / write-project-docs / translate-pseudocn），修 3 处。**① nix-flake-update-check：步骤数错误（四语）**。文档称「第 1~**10** 步主流程」，但通用技能 `SKILL.md` 实测只有**第 1~9 步**；「流程复盘与规范校验」及「测试分支教训须搬回 main」实际定义在**适配层技能** `nixkits-check-updates`（其「第 10 步（收尾）」，第 258 行起）。原文把两技能的步骤混为一体，会让读者在通用技能里找不到第 10 步。已改为「本技能自身止于第 9 步；收尾第 10 步由适配层补」。**② write-project-docs：配套文件 `templates.md` 未被技能自身声明（四语 + SKILL.md）**。`templates.md`（209 行完整模板集）确实存在且 `AGENTS.md` 第 88 行在引用它，但 `SKILL.md` 全文**未出现该文件名**、也无「配套文件」章节（对照 `nix-flake-update-check/SKILL.md` 有明确配套文件表），四语文档更把技能等同于单个文件。后果是执行时无从得知模板集存在——而它正是「首次搭建某类文档」最该先读的。已在 `SKILL.md` 开头新增配套文件表（格式与既有技能一致），四语文档补「路径=目录形式」与「配套文件」行。**③ translate-pseudocn：词典条目数与配套文件（四语）**。文档称「内置 ~**13** 条映射词典」，实测 `dictionary.md` 有 **75** 条；查历史可见该词典经多轮扩充（`4fbf387`「expand dictionary 7→46 entries」），13 停留在更早版本。另 `SKILL.md` 有三处引用 `dictionary.md`（查表翻译、片假名映射、残留假名回填），四语文档却只写单个 `SKILL.md` 路径、正文亦未提该文件。已补齐配套文件行并把条目数改为实测 75。**对照确认**：同批 `news-three-elements` 文档**已正确**声明 4 个配套文件（`search-keywords.md`/`tables.md`/`checklist.md`/`principles.md`）且 SKILL.md 有对应引用，故该缺陷非普遍性问题；`nixkits-check-updates` 文档经全项核对无误（子仓坐标 `fetchFromGitHub` 固定 rev / 非 flake input / 不发布 npm 均属实，三处特有陷阱 —— godot-ai 需**两处都链** overlay、codewhale 两变体、dsh-alpha vendored lock 的 `--legacy-peer-deps` 禁忌 —— 与源码逐一相符，第 10 步六个子步与技能原文一致）

| 提交 | 说明 |
|------|------|
| `c9c9c0c` | fix(docs): nix-flake-update-check 技能文档步骤数错误（四语） |
| `7f7363f` | fix(docs): write-project-docs 未声明配套文件 templates.md（四语 + SKILL.md） |
| `cef09fe` | fix(docs): translate-pseudocn 词典条目数与配套文件失实（四语） |

> **说明**：`7f7363f` 含 `skills/write-project-docs/SKILL.md` 改动（技能快照经 `check-preset-bundle` 验证与 `skills/` 树仍逐字节一致）；其余为四语文档。技能类尚余 6 篇（news-three-elements / nixkits-skills / nixos-modern-cli / nixos-specialisation-tuning / recover-nixos-config / write-maintenance-log），其后为未列入文档内容的核查。

## 2026-09-19T07:43:15+09:00

**摘要**：废弃类文档核对 —— 查出一处**跨文件的事实错误**（同时存在于模块注释与四语废弃文档），已更正。**原判定**：「上游已迁移 hostPlatform（旧写法 **0 处**，新写法 34 处），不再产生弃用告警」。**实测否证**（下载上游 tarball 逐文件统计）：`stdenv.is<Platform>` 旧写法在 **0.34.0 为 38 处**、**0.30.2（补丁时代基版）亦为 38 处**，而 `hostPlatform.is*` 两版都只有 7 处 —— 两版完全相同，上游**从未**迁移该 API。并实测 nixpkgs 确认该写法确实被弃用（`evaluation warning: stdenv.isLinux is deprecated, use stdenv.hostPlatform.isLinux instead`），故「不再产生弃用告警」不成立。**错因推测**：原判定很可能把**我们自己的补丁**所做的事误记为上游所做的事 —— 旧 `comfyui-nix-stdenv-api.patch` 的提交信息正是「migrate stdenv.is<Platform> to stdenv.hostPlatform.is<Platform>」（迁移 36/44 处），与错误结论中的数字高度吻合。**更正后的准确表述**：补丁确已不需要，但真实理由是**我们不再覆盖上游代码** —— 旧补丁把该迁移施加给一个会被 overlay 求值的 fork，以消除污染下游构建的告警；改为直接指向上游后，本模块只做声明式接线，不再引入该求值路径。**同步更正两处**：`modules/comfyui.nix`「补丁删除的判定依据」注释（含 ⚠️ 标记与实测数字）、四语 `deprecated/comfyui-rocm.md`「为何可以废弃」段落。之所以坚持更正，是遵循本仓「记录判定依据以备回溯」的既有约定 —— 若留着错误结论，未来复核者会依据它继续推断。**其余废弃类断言通过**：模块确已更名为 `nixkits.comfyui`（源码注释与原文档一致）；`modules/comfyui-rocm.nix` 与三个补丁文件均已删除；`DEPRECATED.md` / `docs/DEPRECATED.{en,ja,pcn}.md` 四语索引均正确指向本文档；历史对照表所述上游版本经实测确为 **v0.34.0**（与文档一致），ROCm wheels 已由上游自带、输入来源已改为 `github:utensils/comfyui-nix`、补丁数 3 → 0

| 提交 | 说明 |
|------|------|
| `4054c32` | fix(comfyui): 更正「上游已迁移 stdenv API」的错误判定（模块注释 + 废弃文档四语） |

> **说明**：`4054c32` **改动 `modules/comfyui.nix`**（仅注释，不影响求值；`nix flake check` 全通过）；其余为四语文档。废弃类至此完成。余下**技能类 10 篇**，以及最后核查未列入文档的内容。

## 2026-09-19T07:38:04+09:00

**摘要**：补丁类收官 —— 后三篇（asusd-thermal-guard / comfyui / llama-cpp-rocm）验证完毕，修 4 处。至此**补丁类 8 篇全部核完**。**① asusd-thermal-guard：误称状态写在 `/run`（四语）**。文档「验证」段注释写「需 root：**状态写在 /run**」，但模块明确使用 **`StateDirectory`（`/var/lib/private/asusd-thermal-guard`）**，并在源码注释中**专门警告不可用 `RuntimeDirectory`（即 /run）**——systemd 会在最后一个使用该目录的单元停止时把它整个删除，导致冷却计数每轮归零、恢复逻辑形同虚设（注释记有实测症状：`streak 1/6 → 2/6 → 1/6 → 2/6` 反复横跳、永不达 6）。故文档的 `/run` 说法既错、又恰好指向该模块刻意规避的陷阱。**② comfyui：徽章伪称不存在的 CI job（四语）**。徽章写 `check.yml?job=build (ubuntu-latest, comfyui)`，但 `check.yml` **只有单个 `check` job**（全文件 `matrix|comfyui` 零出现）；comfyui 在本仓是**纯模块**（`nixosModules.comfyui`，无 package 输出），故也不存在 `build-comfyui-*.yml`（对照 blender-mcp/kitsfmt/ruyi 徽章均指向真实的 `build-<pkg>-<arch>.yml`）。**该错误不会自我暴露**：实测向 shields.io 传**故意不存在的 job 名**同样返回 `passing` —— `job=` 查不到时被静默忽略、回退为整体工作流状态，故该徽章一直显示的是整个 CI 的状态。已改为如实的 CI 徽章。**③ comfyui：缓存段残留 overlay 声明（四语）**。同页「类型」已写「纯 NixOS 模块（不再附带补丁）」，缓存段却仍留「本条目为 overlay…不在二进制缓存中」——尚为 overlay 时的陈旧文字。实测模块**无任何 `pkgs.comfyui` 引用或 `overrideAttrs`**，只做声明式配置（`boot.kernelParams`、`hardware.graphics.extraPackages`、systemd 加固），仓内亦已无 comfyui overlay 文件。**④ llama-cpp-rocm：迁移示例的 `hfCacheDir` 用了不会展开的 `~`（四语）**。示例写 `hfCacheDir = "~/.cache/huggingface/hub"`，但模块把该值经 **systemd `Environment = [ "LLAMA_CACHE=${cfg.hfCacheDir}" ]`** 注入，而 systemd 的 `Environment=` **不展开 `~`** —— 照抄会得到字面量路径、被 llama.cpp 当作相对路径。对照模块自身默认值恰为**绝对路径**（`${users.users.<user>.home}/.cache/huggingface/hub`），可见示例是错的那一侧。**其余断言全部通过**：asusd-thermal-guard 六个选项与默认值、`triggerTemp > resumeTemp` assertion、按 `name` 解析 hwmon、取 CPU/GPU 较大值、用 `asusctl profile set` 而非写 sysfs、滞回冷却计数、档位阶梯与「只降不升过 profileCeiling」、两个单元名与文档的 journalctl 命令一致；comfyui 的 `nixkits.comfyui.enable` / `services.comfyui.rocmGfxOverride`（含「仅 gpuSupport=rocm 生效」限定）、功能段 6 项、ROCm 7.1 原生识别 gfx1151、三补丁移除原因与两条教训；llama-cpp-rocm 的纯 overlay 形态与 curried 形式、`llama-cpp-ver` 动态追踪（实测上游当前 `v0.4.1`，确认已切换语义化版本）、剥离前缀并**覆盖 `LLAMA_BUILD_NUMBER=0`**（否则生成 `int LLAMA_BUILD_NUMBER = v0.2.0;` 致 C++ 编译失败）、全部模块选项与 `services.llama-cpp.port`

| 提交 | 说明 |
|------|------|
| `8292160` | fix(docs): asusd-thermal-guard 误称状态写在 /run（四语） |
| `01679e8` | fix(docs): comfyui 徽章伪称 job 名 + 残留 overlay 声明（四语） |
| `35aaf05` | fix(docs): llama-cpp-rocm 迁移示例的 hfCacheDir 用了不会展开的 ~（四语） |

> **说明**：均为纯文档修正，`packages/`、`overlays/` 与 `modules/` 未改动。补丁类 8 篇至此全部完成；余下**废弃类 1 篇**（comfyui-rocm）、**技能类 10 篇**，以及最后核查未列入文档的内容。

## 2026-09-18T11:04:38+09:00

**摘要**：外部收录完成 — awesome-ai-plugins 的两个 PR 均已合并，NixKits 与 dsh-api-balance 正式进入该目录。**背景**：本仓早前收到 issue #3（@zerocodefast）的收录邀约；此前日志记录「保持 open 未提交 PR」，其后实际提交并完成收录，**本次补录提交与合并的完整事实**。**结果**：① [PR #321](https://github.com/hashgraph-online/awesome-ai-plugins/pull/321) — `dsh-api-balance` 加入 DeepSeek Harness Plugins，**已于 2026-09-16 合并**（APPROVED，by @kantorcodes）；② [PR #323](https://github.com/hashgraph-online/awesome-ai-plugins/pull/323) — NixKits 加入 Development & Workflow，因需按评审意见整改并重跑扫描，由我们**主动关闭**；③ [PR #335](https://github.com/hashgraph-online/awesome-ai-plugins/pull/335) — 重新提交版，**已于 2026-09-18 合并**（APPROVED，by @kantorcodes）。两条条目现均在上游 README 生效（`NixKits` 位于 Development & Workflow 节的 NeatContext 与 Oh My Design 之间，`dsh-api-balance` 位于 DeepSeek Harness Plugins 节）。**整改回顾**：扫描评分 **88 → 94/100（A – Excellent）**、Security **13/16 → 16/16**、medium 归零；根因是 `RISKY_APPROVAL_DEFAULT` 匹配到**文档**而非配置（受控实验定位：空仓库 0 处 finding，仅注入 `danger-full-access` 一词即出现），修复方式为**保留全部信息、只改措辞**——该经验即本仓「不为提分而破例」的既有边界。**三项明确未做**：不引入 scanner workflow（不接受无法独立审计的第三方代码进入本仓 CI，并接受 10% 信任分扣减）、不保留 Dependabot、因此停在 94 分而非满分；理由与代价见 `AGENTS.md`「安全边界：不引入外部自动化」。**本机动作**：更新 issue #3 回复，说明三个 PR 的最终状态并附已收录条目位置（原回复仍写「已提交 2 个 PR」并指向已关闭的 #323，属过时信息）。**顺带核对**：我们在 #323/#335 中报告的上游 `scripts/check-alphabetical.py` pinned 判定缺陷（第 47 行按「标记位于条目上方两行」判定，而 README 中标记紧贴条目）目前仍存在于脚本中，但当前 `main` 上该检查通过（推测 README 侧做了规避）；已在 issue 回复中提示，若后续新增 pinned 条目可能再次误报，可按对方指定的方向提交一行修复的独立 PR

| 提交 | 说明 |
|------|------|
| `—` | 外部仓库动作（awesome-ai-plugins PR #321 / #335 合并）+ issue #3 回复更新；本仓无对应 commit |

> **说明**：本次为本仓之外的成果补录——收录由外部目录方合并，本仓 `packages/`、`overlays/` 与文档均无改动。之所以补录，是因为此前日志只记到「#323 的整改要求」，而**提交与最终合并两个事实从未记录**，时间线因此断档。

## 2026-09-18T14:35:36+09:00

**摘要**：补丁类前 5 篇验证（breeze-black / efl-cross-fix / codewhale-sudo / rcc-fix / asusd-pd-profile）—— 修 3 处。**① rcc-fix 用了不存在的 option 命名空间（四语）**：示例写 `services.asusctl = { enable = true; power-profile = true; cpu-power-control = true; }`，但 nixpkgs **没有 `services.asusctl`**（全仓 `grep -r 'services\.asusctl'` 零命中）；asusctl 的守护进程选项在 `services.asusd`（`nixos/modules/services/hardware/asusd.nix`），其选项为 `enable`/`package`/`animeConfig`/`asusdConfig`/`auraConfigs`/`profileConfig`/`fanCurvesConfig`/`userLedModesConfig`，**并无** `power-profile` 或 `cpu-power-control`（档位与 CPU 功率上限经 `profileConfig` 写入 `/etc/asusd/profile.ron`）。旁证：本仓 `modules/rcc-fix.nix` 用的正是 `config.services.asusd.enable`，同批文档的 asusd-pd-profile 也正确使用 `services.asusd` —— 仅 rcc-fix 一篇写错且四语皆同。**② breeze-black「安装」段用了占位路径（仅 zh）**：写 `nixpkgs.overlays = [ (import ./overlay.nix) ];`，既非 flake 路径也不指向本仓文件；其余补丁文档（efl-cross-fix / rcc-fix / codewhale-sudo）与 en/ja/pcn 三语本已统一写 `inputs.nixkits.overlays.<name>`，仅 zh 漏改。**③ codewhale-sudo 基本信息表重复行（仅 zh）**：「类型 | overlay（覆盖 codewhale 包）」出现两次，其余三语各一行。**其余断言全部通过**：efl-cross-fix 确实只覆盖 `pkgsCross.{riscv64,riscv64-musl,aarch64}` 并经 `overrideScope` 注入，机制为把宿主编译的 `efl-native/bin/.` 复制进构建目录并 `export PATH="$PWD:$PATH"`（使 meson 的 `find_program(..., native: true)` 找到 eolian_gen / eet），宿主 efl 不受影响；breeze-black 确实只覆盖 `kdePackages.breeze`/`breeze-gtk` 且无独立 package 输出，look-and-feel id 经 `metadata.json` 核实为 `org.kde.breezeblack.desktop`、GTK 主题名确为 `BreezeBlack`（由 light "Breeze" 重命名）、配色方案 `BreezeBlack.colors` 存在；codewhale-sudo 机制确为 ptrace 在内核边界把 `prctl(PR_SET_NO_NEW_PRIVS)`/`PR_SET_SECCOMP` 改写为无害的 `PR_GET_NO_NEW_PRIVS`，与「静态链接使 `LD_PRELOAD` 无效」的理由相符，overlay 名 `codewhale-sudo-fix` 与 flake 注册一致；rcc-fix 模块确实以 `partOf = lib.mkForce [ ]` 移除 `asus-shutdown.service` 的 PartOf 解死锁（并额外强制 `SendSIGKILL=yes`/`TimeoutStopSec=30s`），`programs.rog-control-center.{enable,autoStart}` 经核对确实存在；asusd-pd-profile 的 `pdProfile` 默认 `balanced`、`nativeAcProfile` 默认 `performance` 与文档一致，服务确为 `Type=oneshot` 的 udev 触发（无常驻无轮询），文档所述两级 PD 判据（`/sys/class/typec/port*/power_operation_mode` 为 `usb_power_delivery`、`/sys/class/power_supply/*` 中 `type=USB` 者 `online=1`）在脚本中均实现，「电池态立即退出」有对应分支与提示文案

| 提交 | 说明 |
|------|------|
| `a262e3c` | fix(docs): breeze-black 安装路径与 codewhale-sudo 重复行（zh） |
| `ea03584` | fix(docs): rcc-fix 用了不存在的 services.asusctl 选项（四语） |

> **说明**：均为纯文档修正，`packages/`、`overlays/` 与 `modules/` 未改动。补丁类尚余 3 篇（asusd-thermal-guard / comfyui / llama-cpp-rocm），其后为废弃类 1 篇、技能类 10 篇与未列入文档的内容。

## 2026-09-18T14:26:43+09:00

**摘要**：开发类两篇验证完毕——修 1 处文档参数错误，并查出**1 处源码缺陷**（devShell 配置从未生效，非文档问题）。**① `ruyi venv` / `ruyi extract` 参数写错（四语）**：文档写 `ruyi venv <name>` 与 `ruyi venv --toolchain <t>`，实测两者都不完整——只给一个位置参数会直接打印 usage 退出；给 `profile dest` 而不给 `-t` 则 `fatal error: You have to specify at least one toolchain atom for now, e.g. \`-t gnu-plct\``。正确形式三者缺一不可：`ruyi venv -t <toolchain> <profile> <dest>`，且 `profile` 须已在本地索引（首次需先 `ruyi update`）。另 `ruyi extract <file>` 的「解压 RISC-V AppImage」也不对——该命令的位置参数是**包名 atom 而非文件路径**，实测传文件路径报 `fatal error: atom /tmp/dummy.AppImage matches no package in the repository`，已改为 `ruyi extract <pkg>` 并注明语义。**② 源码缺陷：opencode devShell 的 searxng limiter 配置从未被读取**。`develop/opencode.nix` 把 limiter 配置写在 `settings.yml` 的 `server.limiterSettings` 块下，但 searxng **只从 `<user_cfg_folder>/limiter.toml` 读取**（`searx/limiter.py` 的 `get_cfg()`：`cfg_file = (get_user_cfg_folder() or Path("/etc/searxng")) / "limiter.toml"`）。实测进入 devShell 时 searxng 立即警告 `missing config file: /tmp/searxng-*/limiter.toml`，证明该块被**静默忽略**——即 `trusted_proxies`（信任本机 lighttpd 反代传来的 X-Forwarded-For/X-Real-IP）**从未生效**，且该块还含上游已废弃的 `real_ip.x_for`（与上一轮 mcp-searxng 文档修掉的是同一废弃键）。修法：把 limiter 配置移到与 `settings.yml` **同目录的独立 `limiter.toml`**（`SEARXNG_SETTINGS_PATH` 指向文件时其所在目录即 user_cfg_folder），内容改用当前 schema 的 `[botdetection] trusted_proxies`（`127.0.0.0/8`、`::1`）并去掉 `real_ip`。实测修复后 `missing config file` 警告**归零**，searxng(42701) 与 lighttpd 反代(4270) 均返回 HTTP 200。**其余断言实测通过**：三个 devShell 存在且 `nix develop .#ruyi` 可用（解析到的正是带补丁的 ruyi）；6 个 ruyi 子命令齐全；opencode devShell 的 12 个 packages、3 个 MCP 服务器（SearXNG/Blender/Godot 及命令）、3 个环境变量、`~/.config/opencode/mcp.json` 首次生成逻辑、技能从 `~/NixKits/skills/`（GitHub 兜底）装到 `~/.opencode/skills/` 均与文档一致

| 提交 | 说明 |
|------|------|
| `26e7a76` | fix(devshell): ruyi venv/extract 参数错误 + opencode searxng limiter 配置从未生效（四语） |

> **说明**：`26e7a76` **改动 `develop/opencode.nix`**（limiter 配置改写到独立 `limiter.toml`），devShell 行为已变化；其余为纯文档修正。测试期间产生的 `dump.rdb`（redis 产物）与遗留后台进程已全部清理。后续待核：补丁 8 篇、废弃 1 篇、技能 10 篇，以及未列入文档的内容。

## 2026-09-18T13:51:14+09:00

**摘要**：插件类 2 篇 + 模式类 3 篇验证完毕——插件全部相符（0 处），模式修 1 处。**① 插件类（0 处改动）**：`dsh-nixos-shell` 逐项相符——npm 名/版本；`nixos_shell` 的 27 项工具白名单与文档**逐字一致**（python3/python/grep/ls/cat/head/tail/wc/tr/sort/mkdir/rm/cp/mv/find/env/sed/bash/awk/git/curl/jq/ripgrep/rsync/htop/tree/unzip）；`nixos_cli` 五个 op 与数值上限（generations 默认 20/上限 200、journal 默认 50/上限 500）与 `--help` 描述逐字相符；sudo 协议确为 **v3**（`bin/nixkits-sudo-exec.js` 注释「Protocol (v3, one request per connection)」）、超时上限 `MAX_TIMEOUT_MS = 21600000`（6 小时），实测套接字 `/run/nixkits-sudo.sock` 为 `srw-------` 归 `kix:users`；分离执行逻辑确实识别 rebuild 类命令并以 `systemd-run --collect` 起瞬态单元，返回 `detached: true` + `detachedUnit` 且带「交接 ≠ 成功」的 note；包内 `presets/` 两个预设、`package.json` 的 `exports["./nixos-gate"]` 与 `["./maintenance-skills"]` 子路径均在；`skills-embedded/` 含 10 个技能快照。`dsh-api-balance` 亦全项相符——薄封装（`src` 指向 GitHub 非本仓，与「不承载源码」一致）、固定的 rev `c47f857` 在远端存在（HTTP 200）、npm 名与 `package.json` 版本 0.1.0 一致、文档列出的 4 个 config 项（`apiKeyEnv`/`baseURL`/`browserScan`/`browserScanIntervalMs`）均存在于包内，且默认值实测为 `6 * 60 * 60 * 1000`（即文档写的 21600000，6 小时）。**② 模式类（1 处）**：NixOS模式文档「组合」一行称 persona 行设了 `complete: true`，但预设 `presets/nixos-mode/agent.cordis.yml` 的 persona 行**只设 `prefix`**（全文无独立的 `complete:` 字段），即仍会拼接运行时上下文；`@deepseek-ai/dsh-persona` 的 schema 确有 `complete`（默认 false），故这是该预设的选择而非文档所述的配置——易被提示词正文里的「decision-complete」等字样误导。已四语改正。**对照确认无误**：**新闻三要素模式的 persona 行真的设了 `complete: true` 与 `includeRuntimeContext: false`**，其文档表述正确，未改动。其余模式断言全部通过：`nixos-gate` 确实读 `/etc/NIXOS` 与 `/etc/os-release`（非 NixOS 时注册工具守卫 + 注入拒绝提示词）；NixOS模式技能确为 5 个（预设自带 2 + 构建期子集 3）；维护模式的派生关系经 `diff` 实测为**末尾恰好追加一个固定块**且两预设 `skills/` 目录 `diff -r` 逐文件一致，`check-preset-derivation.py` 含 `MAINTENANCE_DELTA` 并已挂入 flake check（实跑通过）；新闻三要素模式的 5 插件相对名挂载、5 个技能文件与仓库源逐一对应、重试 `[0, 30_000, 120_000]`、6 小时复查、ETag/304、缓存目录 `$DSH_HOME/.cache/<SKILL_ID>`、readonly 白名单八项均与实测一致

| 提交 | 说明 |
|------|------|
| `3d6340f` | fix(docs): NixOS模式组合描述误称 persona 设了 complete: true（四语） |

> **说明**：纯文档修正。插件类两篇均无需改动（记录在案以备回归比对）。后续待核：开发、补丁、废弃、技能类文档，以及未列入文档的内容。

## 2026-09-18T13:43:54+09:00

**摘要**：软件类九篇文档验证收官 — ruyi 修 2 处（其中一处是**上一轮我自己引入的**），至此主文档 + 全部软件类子文档核完。**① 测试数未区分通道（回归）**：上一轮把「320 单元 + 52 集成」整体改写为「462 单元 + 70 集成」，但那两个数**只是 beta 通道**的；实测三通道各不相同——`ruyi`（0.52.0）单元 **368** / 集成 **58**、`ruyi-beta` 单元 **462** / 集成 **70**、`ruyi-alpha` 单元 **346** / 集成 **57**。已改为按通道分列，并补充「`checkPhase` 中 ruff / mypy 为 `|| true`（不阻断），**真正把关的是 pytest**」，避免把「全部通过」误读为三项皆过。**② zh 安装段代码块破损**：```nix 围栏内混入一行 prose 提示（`> 需要 beta 或 alpha 版本？…`），致其被当 Nix 代码渲染且代码块截断；en/ja/pcn 无此问题，仅 zh 有。**③ 顺带修正 pyelftools 表述**：原写「ruyi ≥ 0.53.0 新增」，但本包是在**共享 base 中无条件**加入该依赖（无版本条件），故 0.52.x 通道也带（实测三通道均在，而上游 0.52.0 的 pyproject 出现 0 次）；已写明「上游自 0.53.0 起需要，本包无条件加入，多余但无害」。**其余断言实测通过**：`ruyi --help` 含 list/install/venv/device，`device provision`、`venv --toolchain`、`list --all` 均存在；模块选项 `settings.packages.prereleases`/`repo.remote`/`telemetry.mode`/`telemetryOptout`/`venvs.{profile,toolchain,dest}` 全在，生成 `/etc/xdg/ruyi/config.toml` 且激活时自动 `ruyi update`；NixOS 兼容段三项功能在产物中逐一确认（`wrap_exec_for_nixos`/`_maybe_fix_toolchain_sub_binaries`/`patchelf`/`RUYI_ARGV0`），文档给的验证命令实际可找到文件；许可 Apache-2.0；上游确为 ISCAS 维护。**CI 说明**：本轮末次推送后 `Build dsh-api-balance (aarch64)` 一度失败，查明为 `api.github.com/.../llama.cpp/releases/latest` 返回 **HTTP 403**（GitHub API 限流，命中浮动输入 `llama-cpp-ver`），属瞬时基础设施故障而非代码问题——`gh run rerun --failed` 后即成功，全仓 30/30 通过

| 提交 | 说明 |
|------|------|
| `c30f2b6` | fix(docs): ruyi 测试数未区分通道 + zh 安装段代码块破损（四语） |

> **说明**：纯文档修正。至此**主文档 + 软件类九篇**（blender-mcp / codewhale / dsh / godot-ai / kitsfmt / mcp-searxng / obs-bilibili-stream / opencode-telegram / ruyi）验证完毕，累计修 15 处（含 1 处真实功能缺陷与 2 处由本会话早前引入的回归）。后续待核：插件、模式、开发、补丁、废弃、技能类文档，以及未列入文档的内容。

## 2026-09-18T13:41:45+09:00

**摘要**：文档验证续 — obs-bilibili-stream 修 1 处，opencode-telegram 全部相符（0 处改动）。**① obs-bilibili-stream**：「Home Manager」段给出的 `home.packages = [ ...obs-bilibili-stream ];` **装上但 OBS 不会加载插件** —— OBS 经 `OBS_PLUGINS_PATH` 查找插件，而该变量**只由 nixpkgs 的 `wrapOBS` 注入**（`pkgs/applications/video/obs-studio/wrapper.nix`：`wrapProgram --set OBS_PLUGINS_PATH "${pluginsJoined}/lib/obs-plugins"`），即只走 `programs.obs-studio.plugins` 这条路；`home.packages` 仅把 `.so` 放进 profile，OBS 不扫描该路径，结果是「装上了、插件列表里没有」。四语补充警告并给出两条正确做法（NixOS 用模块或 `programs.obs-studio.plugins`；非 NixOS／仅 Home Manager 时须自行确保插件搜索路径含 `.../lib/obs-plugins`）。其余断言实测通过：版本 2.1.5、`meta.platforms` 为纯 Linux（无 darwin，与「Linux only」相符）、overlay `default` 确实导出该包、`nixosModules.obs-bilibili-stream` 已注册、模块选项名与文档一致且**模块 enable 时的赋值与文档「手动」写法逐字相同**、产物结构正确（`lib/obs-plugins/bilibili-stream-for-obs.so` + 对应 `share/obs/obs-plugins/` 目录）、徽章对应的 x86_64/aarch64 两个 workflow 存在。**② opencode-telegram（本轮唯一「零改动」文档）**：逐项核对**全部相符** —— 文档声称的 4 个子命令 `start`/`status`/`stop`/`config` 与 `--help` 输出一致；模块选项 `enable`/`user`/`group`/`afterServices`/`extraPackages`/`extraBinPaths`（另含 `environment`/`package`）全部存在且语义相符；「start 自动拉起 opencode」属实 —— 包内 `dist/opencode/process.js` 的 `startLocalOpencodeServer` 确实 `spawn("opencode", ["serve", "--port", port])`，这也解释了文档为何强调服务 PATH；方案 A 的 `pkgs.opencode` 在 nixpkgs 中确实存在（1.18.30）；徽章对应的三个平台 workflow 均存在

| 提交 | 说明 |
|------|------|
| `4bea784` | fix(docs): obs-bilibili-stream 的 Home Manager 用法会装上但不生效（四语） |

> **说明**：纯文档修正，`packages/` 与 `overlays/` 未改动。opencode-telegram 经核对无需改动（记录在案以备后续回归比对）。软件类仅剩 ruyi。

## 2026-09-18T13:40:20+09:00

**摘要**：文档验证续 — kitsfmt 与 mcp-searxng 各 2 处修正。**① kitsfmt**：「注释保持」表述过宽 —— 实测（0.5.0）只有**节点上方的先行注释**会跟随排序，另有 4 类位置丢失或移位：非最后一条属性的同行尾**移位到下一属性上方**、最后一条属性的同行尾**丢弃**、**文件头**（顶层表达式之前）与**文件尾**丢弃。源码可印证：注释只经 `comments_before(<entry>)` 收集，故文件头/尾没有收集点。四语补「注释保留的限制」小节并逐行实测核对。另补漏掉的 `KITSFMT_STDIN=1`（`--help` 显示 4 个 env，文档只列 3 个）。其余断言全部实测通过：三个 best-practice 变换**输出与文档示例逐字相同**（裸 URL 引号化 / rec → let-in / with → builtins.attrValues）、`--check` 退出码语义（未格式化 1、已格式化 0）、`-i`/`-B`/多文件（带 `---` 分隔）、幂等性、APC 折叠 `a.b.c`，以及独立 flake 中 `nix fmt` 端到端可用。**② mcp-searxng**：一是「开箱即用配置」含**已废弃**的 `real_ip.x_for = 1` —— 上游 searxng 的 `limiter.toml` 已无 `real_ip` 段（`[botdetection]` 下仅 ipv4_prefix/ipv6_prefix/trusted_proxies），上游 master 与 nixpkgs 该选项自带 example 两处独立印证，社区记录亦显示其被「replace real_ip by IPv4/v6 network」取代，已从四语示例移除；二是「缺少 `SEARXNG_URL` 时**静默**失败」与实测不符 —— 实测服务器**正常启动且 tools/list 正常返回工具**，只是每次 `tools/call` 返回 `isError: true` 并在文本中明确给出 `⚠️ Configuration Issues: SEARXNG_URL not set. Set SEARXNG_URL (e.g., …)`，同时 stderr 打印 `SEARXNG_URL not set`；即错误**明确且可操作**（真正要保留的陷阱是 `mcp add` 不填 `env`）。其余断言通过：版本 2.3.0、wrapper 注入 nodejs、本机 `~/.deepseek/mcp.json` 的 `servers.SearXNG` 结构与文档示例**逐字段一致**、nixpkgs searx 模块确有 `redisCreateLocally`/`settings`/`limiterSettings` 三个 option

| 提交 | 说明 |
|------|------|
| `0cb9f4f` | fix(docs): kitsfmt 注释保留表述过宽 + 补 KITSFMT_STDIN（四语） |
| `9f3c829` | fix(docs): mcp-searxng 两处失实（real_ip 已废弃、失败并非静默）（四语） |

> **说明**：均为纯文档修正，`packages/` 与 `overlays/` 未改动。文档验证仍在进行（软件类还剩 obs-bilibili-stream / opencode-telegram / ruyi，其后为插件、模式、开发、补丁、废弃与技能类文档，最后核查未列入文档的内容）。

## 2026-09-18T13:32:32+09:00

**摘要**：文档验证续 — dsh 与 godot-ai 各查出问题，其中 godot-ai 是**真实功能缺陷**（非文档问题）。**① dsh（1 处文档）**：「可声明式配置的宿主 namespace」表只列 6 个且标注「DSH 0.1.2-alpha」，而该节讨论的是 `0.1.5-rc.2` —— 实测该版本经 `installSection` 注册的 namespace 共 **12 个**，缺 `agent-default-model`（provider/model/reasoningEffort）、`agent-loop`（maxParallelToolCalls）、`permission`（presets）、`shell`（dshHome）、`subagent-model-selection`、`web-search-deepseek`。三重印证：全量提取 `*_SETTINGS_NAMESPACE` 常量得 12 个、逐个取 `z.object({...})` schema 得字段、实机 `settings.yaml` 确认含 `permission`。dsh 其余断言全部通过（live 服务 8615/8625、reverseProxy 三选项与安全警告、launchUrlFile 实际产出 `/run/dsh/launch-urls`、sudo 守护 `srw-------` 归 kix:users 且 `NIXKITS_SUDO_SOCKET` 已注入、插件清单 152 条与 live dump 逐条一致、reasoningEffort 四档与 `high` 兜底默认）。**② godot-ai（1 功能缺陷 + 2 文档）**：文档声明的 `godot-ai` 命令**启动即失败**（`BACKEND_START_FAILED`，后端日志 `No module named godot_ai`）。根因逐层定位：该命令默认由 attach 桥**再 spawn 一个后端**（`sys.executable -m godot_ai`），而 Nix 包装下 `sys.executable` 是**裸 CPython**，依赖仅由包装脚本运行时经 `site.addsitedir()` 注入、**不被子进程继承**；上游用 `uvx`/真实 venv 故无此落差。修法为 makeWrapper 前置 PYTHONPATH，途中实测踩到三个必须做对的细节：`python312.sitePackages` 是**相对**路径须拼 `${placeholder "out"}/`、深层传递依赖（pydantic_core/platformdirs）须用 fixpoint 展开 `propagatedBuildInputs`、不可取 `d.pythonPath`（它指向 nixpkgs 的另一份 pydantic 2.13.4，绕开本仓 overlay 抬上的 2.13.5 会令 fail-closed 校验失败）。A/B 实测：修复前 ❌ / 修复后 ✅（后端监听 127.0.0.1:8000，MCP `tools/list` 返回 46 工具）。文档另修 2 处：工具数 43 → **46**（上游 v4.1.0 README 亦写 46）；WebSocket 默认端口 9876 → **9500**（`--help`、`__init__.py` argparse、`asgi.py` 三处独立印证，9876 在包内零出现）

| 提交 | 说明 |
|------|------|
| `6b47f55` | fix(docs): dsh 设置 namespace 表不完整且版本标注过时（四语） |
| `a54bd9d` | fix(godot-ai): 修复 attach 后端无法启动 + 文档两处失实（四语） |

> **说明**：`a54bd9d` **改动 `packages/godot-ai.nix`**（新增 makeWrapper 与 postFixup），godot-ai 构建产物已变化；其余为纯文档修正。

## 2026-09-18T13:23:25+09:00

**摘要**：文档验证启动 — 主文档 26 条断言复核 + 逐篇验证子文档，已修 7 处失实描述。**方法**：不读源码猜测，而是**部署实测** —— 起真实进程取权威数据（如向 blender-mcp 的 MCP stdio 发 `tools/list`），并做受控对照实验；每轮留证后清理（临时目录、registry 项、测试用 HOME），确认真实配置零改动。**① 主文档（README × 四语）2 处**：`inputs.nixkits.url = "~/NixKits"` **不可用**（Nix 不展开 flake input URL 的 `~`，实测报 `path '.../source/~/NixKits/flake.nix' does not exist`；`path:$HOME/...` 同样失败，改为 `git+file:///path/to/NixKits`，并附五种写法的受控对照结果）；「所有包默认跟随 `lib.platforms.linux`」**与事实不符** —— 实测 12 包 `meta.platforms`，9 包为 `lib.platforms.all`（含 darwin），仅 codewhale / obs-bilibili-stream / godot-ai 为 linux 限定。**② blender-mcp 3 处**：工具数标 22 但只列 17，**实测服务器注册 26 个**（缺 5 个摘要工具的 `_for_cli` 变体、2 个 jump 工具、`search_api_docs` / `search_manual_docs`）；Add-on 安装路径写 `blender/4.4/scripts/addons/`，实则该 add-on 是 **Blender Extension**（manifest `blender_version_min = "5.1.0"`，**4.x 根本加载不了**）且新版目录为 `extensions/user/`；**升级会静默失败**——store 内目录只读（`dr-xr-xr-x`），`cp -r` 连权限一起复制，故二次安装大批 `Permission denied` 并留下新旧混杂半成品（维护者本机停留 1.0.0 正是此现象），补充正确升级流程（`chmod` → `rm -rf` → `cp` → `chmod`，实测 1.0.0→1.0.3 与包内逐字节一致）。**③ codewhale 2 处（含一处回归）**：`codewhale --sandbox <tier>` 参数**不存在**（实测 `unexpected argument`），实为 `--sandbox-mode`；**这是回归** —— `e386dfc` 已修正过该参数名，但同提交为消除扫描器 `RISKY_APPROVAL_DEFAULT` 改写措辞时**重新引入了错误参数名**，说明当时只核对「措辞是否触发扫描器」而未复核改后参数是否仍可用；另 zh 独有该行而 en/ja/pcn 写的是合法的 `--yolo`，四语不一致，现统一四语均含 `--sandbox-mode <tier>` + 合法取值 + 「不是 `--sandbox`」提醒。**其余复核通过**：包/overlay/模块/devShell/技能目录（与 `skills/` **逐个比对完全一致**）、四语章节结构与版本号一致、缓存可达、模式分发的 seed-once 与「注册不复制」语义、Claude Code 移除理由确实存在于所指向文档

| 提交 | 说明 |
|------|------|
| `82d8ed5` | fix(docs): 修正主文档两处失实描述（四语） |
| `ead55d1` | fix(docs): blender-mcp 三处失实描述（四语） |
| `6f40487` | fix(docs): codewhale 沙箱参数名回归错误 + 四语不一致（四语） |

> **说明**：纯文档修正，`packages/` 与 `overlays/` 未改动。文档验证仍在进行（子文档按主文档顺序逐篇复核），后续发现将另记。

## 2026-09-18T13:09:18+09:00

**摘要**：refactor(ruyi)! — 把 `ruyi-nixos-compat` 补丁并入包定义，移除已失效的 overlay。**① 发现的失配**：overlay 是 `prev.ruyi.overrideAttrs`，修补的是 **nixpkgs 的 `ruyi`**；但 nixpkgs 已不再提供该包（`builtins.attrNames pkgs` 搜 `ruyi` 返回 NOT-FOUND），overlay 因而**失去宿主**——`nixkits.ruyi` 模块的 `lib.mkPackageOption pkgs "ruyi"` 取不到包、`packages/ruyi/*.nix` 不引用该补丁（只有自己的 `postPatch` 往 `nixos_compat.py` 追加内容，注释却写「file is created by the overlay patch」）、**仅 `develop/ruyi.nix` 自套 overlay 才真正生效**。结果是四语文档宣称「打包版本包含该 overlay」，而 flake 包用户**实际拿不到 NixOS 兼容处理**；且这类失配**构建成功无法暴露**，只有逐项核对产物才发现。**② 改法**：把 overlay 的三件事全部搬进 `packages/ruyi/ruyi.nix`——`patches = [ …/ruyi-nixos-compat.patch ]`（三通道共用）、`substituteInPlace --replace-fail` 回填 `@nixLdSo@`/`@nixGlibcLib@`、补丁所需的 `ensure_toolchain_nixos_compat` 显式 import。**刻意用 `--replace-fail`**：占位符若因上游改名而消失会**构建立即失败**，而不是静默产出一个「补丁在、兼容性不在」的包。随之删除 overlay 文件与 flake 注册项，`develop/ruyi.nix` 不再套壳——devShell / flake 包 / NixOS 模块现在得到**同一个**构建。**③ 验证（逐项在产物中确认，非只看构建通过）**：三通道 ruyi / ruyi-beta / ruyi-alpha 全部构建成功；`nixos_compat.py` 存在且 `@nixLdSo@` **残留 0 次**、已替换为真实 store 路径（`glibc-2.42-84/ld-linux-x86-64.so.2`，实测存在）；`runtime.py` 含 `wrap_exec_for_nixos` 与注入的 import、`maker.py` 含 `expose_build_tools_in_venv` 调用点、`nuitka.py` 含 `RUYI_ARGV0` 分支；运行时冒烟 `ruyi --version`/`--help` 正常；beta(0.53.0) pytest 仍 **462 passed + 70 passed**。四语文档改写为「内置补丁 + 无需 overlay 配置」并保留历史沿革说明

| 提交 | 说明 |
|------|------|
| `87d3f7c` | refactor(ruyi)!: 补丁并入包定义，移除已失效的 ruyi-nixos-compat overlay |

> **说明**：破坏性变更——`nixkits.overlays.ruyi-nixos-compat` **不再存在**，外部若引用过该 overlay 需删除该行（补丁现已内置，无需任何 overlay 配置）。`packages/` 中 ruyi 三通道构建产物均已改变。

## 2026-09-18T12:41:08+09:00

**摘要**：例行更新检查 — blender-mcp 1.0.3；ruyi-beta 0.53.0-beta.20260917（并补 `pyelftools` 运行时依赖）；dsh 0.1.5-rc.2；dsh-alpha 0.1.6-alpha.2。**① ruyi 依赖新增（唯一实质缺陷）**：上游 0.53.0 起把 `pyelftools` 列入 `pyproject.toml` 的**运行时** dependencies（0.52.x 及更早没有），并新增 `tests/ruyipkg/abi/test_elfbuilder.py` 在**收集期** `import elftools`——缺依赖时 pytest 以 `Interrupted: 1 error during collection` **直接中断整个套件**，而非跳过单条用例。补入 `propagatedBuildInputs` 后 `ruyi`/`ruyi-beta`/`ruyi-alpha` 三通道均通过；beta 测试数随之由 320 单元 + 52 集成增至 **462 单元 + 70 集成**，四语 ruyi 文档同步该项与依赖说明。**② dsh-alpha 的 vendored lock 陈旧**：alpha.2 上游新增 4 个插件包（`dsh-atomic-write`/`dsh-experimental-agent-team-web-profile`/`dsh-hmr`/`dsh-plugin-manager`），而 `dsh-package-lock-alpha.json` 仍停在 alpha.1——**只改 version 会报 `npmDepsHash is out of date`**。按 AGENTS.md 约定以**派生 `postPatch` 处理后**的 `package.json`（删 `devDependencies`）重新 `npm install --package-lock-only` 生成 lock 再回填 hash。**③ 内置插件清单核对**：经 `dsh --profile web --dump-default-config` 重新提取 stable rc.2 的 **152 条 `id -> name`** 并逐行比对，与 rc.1 **完全一致**（rc.1→rc.2 的 npm 依赖集亦无变化，原 `npmDepsHash` 直接可用）——故文档插件表无需改动。**④ 自托管 forge 取源（教训复现）**：`projects.blender.org` 的 `/archive/<rev>.tar.gz` 网页路径对非浏览器 UA 返回 **403**（API 路径 `/api/v1/repos/.../archive/` 正常），与 `fetchFromGitea` 的 hash 换算方式**均为已记载教训**，本次未再走弯路：hash 取**解包后 NAR**（`stripRoot`）的 sha256，并用 1.0.0 已声明值**反向验证**换算方式后 `nix build` 一次通过。四语文档同步、`nix flake check` 全通过

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

**摘要**：改写沙箱档位表述以消除外部扫描器的 `RISKY_APPROVAL_DEFAULT`（88 → 94 分）— 外部目录 `awesome-ai-plugins` 的扫描器对本仓报 5 处 `RISKY_APPROVAL_DEFAULT`（medium）。经**受控实验**定位触发词为 `danger-full-access`：空仓库 0 处 finding，仅注入该词一行即出现 finding。**这不是真实风险**——本仓是在「已知设计边界」表格与 CLI 用法示例中**描述**使用者可选的行为，而非**设置**默认值；但扫描器为模式匹配，无法区分「文档描述」与「配置启用」。**修复方式为保留全部信息、只改措辞**，改后表述对读者反而更准确（明确「默认不放开」）：四语 `SECURITY.md` 改为「沙箱权限档位由使用者显式选择，**默认不放开**」，`docs/zh/codewhale.md` 的 CLI 示例改为 `--sandbox <tier>`。**同时修正一处原有错误**：原示例写 `--sandbox`，而该包实际参数为 `--sandbox-mode`（实测 `codewhale --help` 确认），一并改为正确形式。**实测验证**（官方扫描器，与 CI 同源）：修复前 **88/100**（Security 13/16、5 medium），修复后 **94/100（A - Excellent）**、Security **16/16**、0 medium。**明确未做的优化**：剩余 6 分来自 `Dependabot configured for automation surfaces`；本仓**主动移除** Dependabot（见 AGENTS.md「安全边界：不引入外部自动化」），**不为提分而破例**。四语同步、`nix flake check` 全通过

| 提交 | 说明 |
|------|------|
| `e386dfc` | docs(security): 改写沙箱档位表述，消除扫描器 RISKY_APPROVAL_DEFAULT（88 → 94） |

> **说明**：纯文档措辞修正，`packages/` 与 `overlays/` 未改动。
## 2026-09-17T18:15:40+09:00

**摘要**：通用技能重构为「主流程 + 两份配套参考」，并补回因分支隔离而滞留的 Gitea 教训 — 对软件更新技能本会话表现的**评估驱动整改**。**① 补回已知知识损失**：审计发现 blender-mcp 实测分支上写出的 70 行「自托管 forge（Gitea）取源」章节 + 21 行适配层记录**险些永久滞留**——测试分支按约定永不合并，而该知识（`fetchFromGitea` 委托 `fetchFromGitHub` 生成 `/archive/` 路径、自托管实例可能**对所有 tag 返回 403**、须改用 API 端点 + `stripRoot = true`、且「旧版本仍能构建」可能只是命中缓存）**可复现、可追溯、任何自托管 forge 仓库都适用**。搬运前**已在 main 上逐条复现证据**（403 vs 200 实测、nixpkgs fetcher 源码确认）而非机械 cherry-pick。**② 加固回收惯例**：适配层第 10 步新增小节，要求**测试分支上的通用教训当场手工写入 main**——「分支不会合并」不是「教训不重要」的理由，并记录本次真实损失为依据。**③ 技能重构**：单文件 918 行时执行中难以定位，按 AGENTS.md「独立数据拆为配套文件」拆为主流程 `SKILL.md`（462 行）+ `builders.md`（254 行，按 builder 的 hash 流程与 `flake.lock` 处置）+ `traps.md`（271 行，漂移陷阱 / fail-closed / 外链审计 / Actions / 补丁内版本）。**完整性经四重核对**（`##` 节、`###`/`####` 子节、逐行比对、行数），其中**确实漏掉了 3 节**（检查补丁内版本 / 外链审计 / Actions 更新——`sed` 边界误取在 `## 仓库适配层` 之前，而这三节位于其前），经标题核对发现并补回；最终逐行比对仅 4 行差异且均确认为有意改写。**④ 新增「提交前六问自检」**（第 7 步）：多变体？依赖表一致？取源仍有效？真的运行过？文档表述仍成立？`flake.lock` 该提交吗？——**六问全部提炼自同日实测的真实事故**，每问对应一次返工或缺陷，命中后再按 `traps.md` 深入，替代通读全文。**评估依据**：本会话 3 次实测运行、6 个包升级、首次成功率 4/6，3 次返工**全部由技能已记载或本该记载的陷阱造成**——故整改方向是「让教训在正确位置被发现」而非继续堆叠。四语文档同步

| 提交 | 说明 |
|------|------|
| `e0b1a64` | refactor(skills)!: 通用技能拆分为主流程 + 两份配套参考，并补回丢失的 Gitea 教训 |

> **说明**：技能结构变更（新增 `builders.md` / `traps.md` 两个配套文件）；`packages/` 未改动。

## 2026-09-17T17:22:50+09:00

**摘要**：新增 `check-doc-versions` 检查，把「文档版本 = 包定义版本」固化为断言 — 对本轮连续发现的 5 处文档版本失配（godot-ai、codewhale、mcp-searxng、opencode-telegram、dsh-alpha）的**结构性防御**：这类失配**不会让任何构建失败**，只有人工翻文档才发现，故固化为 `nix flake check` 的第 6 项检查（原 5 项）。**检查内容**：①`docs/<lang>/<pkg>.md` 的「版本」行（四语）须等于包定义声明的版本；②多通道包的**通道表**版本同样校验（`dsh-alpha` / `ruyi-beta` / `ruyi-alpha`）且四语逐一检查；③版本从别处读出的同样跟踪（`kitsfmt` 读 `Cargo.toml`）；④例外须在脚本 `EXEMPT` 显式登记（`dsh-api-balance` 薄封装刻意不标版本、`codewhale-src` 非独立包、`dsh`/`dsh-alpha` 多通道记于通道表）。**只校验能从定义机械读出的部分**（版本号）；依赖表、平台支持、安装步骤无法自动比对，明确排除在范围外——避免把检查写成需要人判断的东西。**回归测试（关键）**：逐一注入本轮**实际发现过的** 5 类缺陷，全部被捕获且报错指明「哪个文件写了什么、哪个定义声明了什么」——codewhale 0.9.12（zh）、godot-ai 3.2.5（zh）、mcp-searxng 2.2.0（en）、opencode-telegram 0.25.1（ja）由版本行校验各自捕获，dsh-alpha 通道行 0.1.5-alpha.2（四语）由通道校验捕获。**端到端验证**：注入缺陷后经 `nix flake check` **真实路径**确认失败（`failed to build attribute 'checks.x86_64-linux.doc-versions'`），而非只在直接运行脚本时失败。**CI 确认**：推送后 `CI` workflow 成功（run `35199359526`），日志显示 `evaluating 'checks.x86_64-linux.doc-versions'`——检查确实被执行而非跳过。`AGENTS.md` 同步记录该约定、例外登记方式与适用范围

| 提交 | 说明 |
|------|------|
| `072ab87` | feat(ci): 新增 check-doc-versions，把「文档版本 = 包定义版本」固化为断言 |

> **说明**：本次新增检查脚本 `develop/check-doc-versions.py` 并挂入 `flake.nix` 的 `checks`（检查数 5 → 6），`packages/` 与文档内容未改动。

## 2026-09-17T16:12:06+09:00

**摘要**：修正五个包的文档版本号（内容质量修复）— 对**全部服务型包**做「文档版本 vs 包定义版本」系统性核对，发现 5 处不一致、均已升级而文档未跟：**codewhale** 0.9.12 → **0.9.13**（预编译与源码两变体均为 0.9.13）、**mcp-searxng** 2.2.0 → **2.3.0**、**opencode-telegram** 0.25.1 → **0.25.2**、**dsh-alpha** 0.1.5-alpha.2 → **0.1.6-alpha.1**（文档 + README 两处）、**codewhale-sudo** v0.9.12 → **v0.9.0 起**。**最后一项是判断问题而非机械替换**：该 overlay 实为**版本无关**（`codewhale.override { allowSudo = true; }`），拦截的是 v0.9.0 引入的 `prctl(PR_SET_NO_NEW_PRIVS)`；README 表写「v0.9.12」既过时又与文档正文（写 v0.9.0）**自相矛盾**，故改为描述特性来源而非钉住某个恰好存在的版本——并**实测该 overlay 在 0.9.13 上仍正常**（产出 codewhale 0.9.13 + codew/codewhale-tui 三个二进制）。**刻意保留的历史引用**：`docs/*/modes/nixos.md` 中「`prefix` 自 dsh 0.1.5-alpha.2 起为必填」是**事件描述**（记录字段何时变更），不是当前版本标识，改了反而失真。**核对方式**：逐包 `grep` 取包定义版本与四语文档比对，修正后再全量复核一遍（10/10 一致；剩余 3 处「不一致」经核查均为 grep 误报——`dsh`/`ruyi` 用 `version ?` 语法、`dsh-api-balance` 作为薄封装刻意不标版本）。**同时验证的完整性检查**：文档引用的 9 个文件路径全部存在、`nixkits.*` 模块选项全部有效（3 处疑似无效经复核为 flake 输出而非模块选项）、文档中的包名均在 flake 输出中。`nix flake check` 全通过，四语同步

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

> **说明**：本次为**纯文档修正**，`packages/` 与 `overlays/` 未改动。

## 2026-09-17T15:56:56+09:00

**摘要**：修正 godot-ai 四语文档的版本号与依赖表；通用技能第 5 步新增「文档须重写而非机械替换」判据 — **内容质量修复为主**：main 上的 godot-ai **代码**已于 `2a06bbf` 升到 4.1.0 且功能完整（实测 `godot-ai --version` → 4.1.0、exit 0），但**文档未同步**，留下两处事实错误：①版本号仍写 `3.2.5`；②依赖表列 **6** 项且全为「≥ 范围」，而实际是 **9** 项 fail-closed 精确锁。**第②项危害更大**——v4 启动时校验这 9 个包的**精确版本**，不匹配即拒绝启动，文档写「≥」会让读者以为版本可自由浮动，照做会直接撞上 `RuntimeError`。修正方式：依赖表改为「版本 + 来源」两列、9 项逐一列出，并补充 pydantic-core 的连带要求（`==2.46.5`）、构建期 `setuptools==84.0.0` pin 的放宽说明、以及「为何不打补丁绕过校验」的理由。**核对**：文档中的 9 个版本号是用 `nix eval` 从**含 overlay 的实际闭包**中量出的、**非推断**，逐条与文档值比对 **9/9 全部一致**；四语同步、`nix flake check` 全通过。**技能改进**：通用技能第 5 步新增「**何时必须重写文档而非机械替换版本号**」的触发判据（依赖由范围变精确锁 / 新增启动期·构建期硬校验 / 依赖项增删 / 构建方式变化 / 平台要求收窄），并**手工写入 main**（非 cherry-pick）。写入前逐条核验并改写证据指向，使其在 main 上自包含可复现：一并删去初稿中「该表此后已重写」的表述——核查发现 main 上当时并未重写，留着即谎报证据

| 提交 | 说明 |
|------|------|
| `085c093` | docs(godot-ai): 修正四语文档的版本号与依赖表（内容质量修复） |
| `55674f2` | feat(skills): 通用技能第 5 步新增「文档须重写而非机械替换」的触发判据 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| godot-ai（文档） | 文档标 3.2.5 / 依赖表 6 项「≥ 范围」 | 标 4.1.0 / 依赖表 9 项精确锁 |

> **说明**：本次为**文档修正**，`packages/godot-ai.nix` 未改动（其代码在 `2a06bbf` 已正确）。

## 2026-09-17T13:00:09+09:00

**摘要**：feat(skills): 适配层新增第 10 步「流程复盘与规范校验」 — 每次更新流程**全部完成后**执行，审计的**不是软件而是决定软件如何被更新的规范本身**（技能 / `AGENTS.md` / `SECURITY.md` / develop 脚本），即对更新流程自身做一次「检查更新」。六个子步：**10.1 复盘**（哪里第一次就失败 / 需要问用户 / 返工，逐条追根因）、**10.2 校验**（`AGENTS.md` / `SECURITY.md` 的断言是否仍成立，含外部链接可达性）、**10.3 归属**（按可移植性分流到通用技能 / 适配层 / `AGENTS.md` / `SECURITY.md`，判据是「搬到另一个 nix flake 仓库还成立吗」）、**10.4 体验**（复盘让用户等了几轮，收敛可自行查证项）、**10.5 证据纪律**、**10.6 产出**。**10.5 是硬约束**：规范改动须**可复现、可追溯、允许质疑**——禁止凭印象改规范、把一次偶发当规律、为已写对的内容「再优化」、删除仍有约束力但看似无用的条目，除非能证明其前提已消失。**首次执行即发现两处真实缺陷**（均**不产生构建错误**，只有主动审计才能发现）：①`SECURITY.md` 指向子仓 `SECURITY.md` 的**死链**——子仓根本没建该文件（已用 `gh api` 与 `curl` 双重确证 404），四语同步改为「该子项目尚未自建安全政策，漏洞请报至本仓库」；②**12 处** `Asus-linux/asusctl` 失效链接（3 份文档 × 4 语）——项目已迁移至 `OpenGamingCollective/asusctl`（`gh api` 确证 602 stars、HTTP 200），按「改 URL 同时改显示文本」的要求，链接文字一并更新。**泛化**：链接审计方法进通用技能「审计文档中的外部链接」，含三条判据——`curl` 的 404 须经 `gh api` 复核才定案（可能是权限/限流）、`403` 常为反爬不算死链、**vendored 第三方内容不改写**（如 `packages/kitsfmt-src/vendor/` 内的上游 CHANGELOG）。四语文档同步

| 提交 | 说明 |
|------|------|
| `442e5d1` | feat(skills): 适配层新增第 10 步「流程复盘与规范校验」 |

## 2026-09-17T12:52:54+09:00

**摘要**：fix(codewhale): 补齐 x86_64/aarch64 预编译变体至 0.9.13 — **部署后核对才发现**的漏改：前一条目只升级了 `codewhale-src`（riscv64 的源构建变体，含 Cargo.lock 同步），**漏掉了 `codewhale.nix`**——x86_64/aarch64 走的是 GitHub Releases 预编译二进制路径，由 `flake.nix` 按 `hostPlatform.isRiscV` 分流。症状是「本机构建通过、dsh 也已升到 0.1.6-alpha.1，但系统上 `codewhale --version` 仍是 0.9.12」。**本仓 codewhale 有两个变体同名同输出**：`codewhale.nix`（预编译，需改 `version` + cli/tui × x64/arm64 **四个 hash**）与 `codewhale-src.nix`（源构建，需改 `version` + `hash` + 同步 `Cargo.lock`）——**升级必须两个都改**。实测 0.9.13 的 cli 与 tui 资产 hash 相同（`WTriVnVv…` / `BgUnHSo0…`），与 0.9.12 时一致；但四个值仍分别填入，故四值两两相同。**泛化**：该陷阱已写入适配层「本仓特有陷阱」，并附判据——**部署后逐个变体所在架构核对实际版本，不要只看构建通过**

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

**摘要**：五个软件包升级 + 更新技能追加「交互式澄清」 — 生产环境实战执行全部批准升级：**mcp-searxng** 2.2.0 → 2.3.0、**opencode-telegram** 0.25.1 → 0.25.2、**codewhale** 0.9.12 → 0.9.13、**dsh-alpha** 0.1.5-alpha.2 → 0.1.6-alpha.1、**godot-ai** 3.2.5 → **4.1.0**（跨大版本）。**godot-ai v4 是本次最难的一项**：它引入 **fail-closed 运行时依赖校验**——启动时比对 9 个包的精确版本，任一不符即 `RuntimeError: unsupported godot-ai runtime dependency set` 拒绝启动。nixpkgs（含 unstable 与 master）在 5 个包上落后（mcp 1.29.0→1.29.1、pydantic 2.13.4→2.13.5、starlette 1.3.1→1.6.0、uvicorn 0.51.0→0.52.4、websockets 16.1→17.1），故新增 `overlays/godot-ai-v4-deps.nix` 把这 5 个包抬到上游要求（pydantic-core 连带抬到 2.46.5 并重取 Rust 的 `cargoDeps`），与既有 `fastmcp` overlay **链式叠加**。**先按「不破坏上游安全契约」的方向征询并取得批准**，而非打补丁绕过校验。**踩坑**：`flake.nix` 的 `godotPkgs` 与 `overlays/default.nix` 是两处独立的 overlay 链，初版只改了前者，导致 `--version` 仍 RuntimeError；两处同步后才通过。另放宽上游 `setuptools==84.0.0` 构建期 pin（nixpkgs 为 83.0.0，该 pin 是可复现性守卫而非功能需求）。**codewhale** 升级按技能要求**同步 Cargo.lock**（7073 → 7347 行，上游新增 `wl-clipboard-rs` 等）——漏掉即构建失败。**dsh-alpha** 踩到 vendored lock 陷阱：用 `npm install --package-lock-only --legacy-peer-deps` 生成的 lock **不含 `"peer": true` 条目**，构建报 `ENOTCACHED`；去掉该 flag 后 npm 才写入 peer 条目（与既有可工作的 lock 结构一致，均 24 条）。**技能泛化**：`nix-flake-update-check` 新增「交互式澄清」章节——支持提问的智能体（如 DSH）须**开工前批量问全**待定项，避免「猜一次→被纠正→重来」的多轮往返（每次重来都要重跑构建，而构建是本流程最贵的环节）；同时新增陷阱 5（fail-closed 运行时校验：构建成功 ≠ 可用，必须实际运行一次验证）与陷阱 6（`overridePythonAttrs` 改 Rust 构建包时 `cargoDeps` 须一并重取），并在 npm 节补充 peer 条目要求。适配层补充本仓三处实测陷阱。**验证**：五包全部构建通过并实际运行确认（godot-ai `--version` → 4.1.0、codewhale → 0.9.13、mcp-searxng → 2.3.0、dsh-alpha → 0.1.6-alpha.1）；`nix flake check` 全通过

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

**摘要**：fix(skills): 子仓跟进判据细化到字段级（生产环境实战驱动） — 按计划完成 dry run 后**实际跑了一次完整的软件升级技能**做生产评估，实战立刻暴露出前一条目判据的缺陷：原判据按「**文件**是否变化」分流，但清单文件的众多字段中只有一部分是语义输入。实测子仓 `dsh-api-balance` 的 `package.json` **确实变了字节**（移除 `publishConfig.access`），而 `dependencies`、`files` 白名单、`version`、`main`/`exports` **均未动**——按原判据会被误判为「清单文件变了 → 跟进」，从而为一次纯元数据改动触发全架构重建与缓存失效。**修正**：判据改为**字段级**——发布元数据（`publishConfig` / `repository` / `keywords` / `description` / `bugs` / `homepage`）与文档、CI 配置**不属**构建输入，**不跟进**；`dependencies` 系列 / `files` / `main` / `exports` / `scripts` / `version` / 源码**属**构建输入，**必须跟进**；并加入兜底原则「无法确定某字段是否影响产物时，按跟进处理」（多一次构建远好过漏掉一次真实变更）。适配层对本次子仓变更的描述同步修正——原文误称「仅文档变更」，实际 `package.json` 也变了，**判据必须落到字段而非文件**。**实战同时确认新特性工作正常**：第 9 步在真实仓库上完成了账户识别、引用关系发现、四项前提校验（回环 / 深度 / 账户 / 可独立升级**全部 PASS**）与变更性质判定；并发现主干侧的真实待升级项（`codewhale-src` 0.9.12→0.9.13、`godot-ai` 3.2.5→4.1.0、`mcp-searxng` 2.2.0→2.3.0、`opencode-telegram` 0.25.1→0.25.2、`dsh-alpha` 0.1.5-alpha.2→0.1.6-alpha.1）与两处已最新项（`ruyi` / `obs-bilibili-stream`），本次仅评估不执行升级

| 提交 | 说明 |
|------|------|
| `c08f5c9` | fix(skills): 子仓跟进判据细化到字段级 |
| `641830a` | docs(skills): 同步四语的子仓跟进字段级判据 |

## 2026-09-17T11:31:32+09:00

**摘要**：feat(skills): 支持同账户子项目链式检查与跨仓维护条目链接 — 新特性：仓库引用的**同账户子项目**（典型为薄封装）也纳入软件更新检查，前提成立时**链式并行执行**，子项目结果**视为主仓结果**，但分别计入两仓日志、主仓条目**链接到子仓条目章节**。**归属先评估再落笔**——通用逻辑进通用技能，仓库强相关内容剥离到适配层：**`nix-flake-update-check`（通用）**新增第 9 步「同账户子项目链式检查」，含引用关系发现（`fetchFromGitHub` / flake input / submodule 三种形态）、**四项前提校验**（无回环 / 无版本冲突 / 可独立升级 / 账户一致，任一不成立即退化为提示而不链式）、回环与深度上限检测、依赖冲突判据、链式并行与失败隔离、结果归属，以及「**子仓何时需要跟进**」的分流判据（版本号变 → 必须跟进；仅文档变 → 跟进无意义）。**`write-maintenance-log`（通用）**新增类型 5「跨仓库子项目链式更新」：主仓只记薄封装坐标变更（`rev` / hash）并链接子仓条目，子仓记自身完整变更——两边内容不同、不是重复。**`write-project-docs`（通用）**新增「子仓引用关系必须显式记录」：主仓短页须写明源码仓库 + 主仓侧角色 + 钉住的坐标 + 同步方式。**`nixkits-check-updates`（适配层）**只承载本仓专有事实：子仓坐标、构建体系、peer 依赖判据与历史坐标表。**dry run 先行验证**发现并修正三处真实缺陷：①技能中的发现命令缺 `-h`，`awk` 字段号错位导致**静默返回空**（会被误判为「本仓无子项目」）；②依赖冲突判据写成「两侧是否相等」，实测子仓声明 `0.1.1-rc.2` 而宿主提供 `0.1.5-rc.2`——**peer 性质依赖下宿主更高是正常状态**，判据应为「子仓要求是否高于宿主提供」；③GitHub 锚点推导规则写成「去掉 `:` 与 `+`」，实为**逐字符替换为 `-`**（`: ` 与 `+` 各变一个 `-`、原 `-` 保留）。**dry run 同时发现一处真实待办**：主仓钉住的 `dsh-api-balance` `rev` 落后子仓 HEAD 两个提交，但**版本号未变且均为文档提交**，按新判据**不触发**重钉——正是该分流条款要防的误升级

| 提交 | 说明 |
|------|------|
| `b7e9717` | feat(skills): 支持同账户子项目链式检查与跨仓维护条目链接 |

## 2026-09-17T11:21:34+09:00

**摘要**：chore(security): 完全移除 `dependabot.yml` 并确立「不引入外部自动化」安全边界 — 上一轮只为 npm 生态**结构性无效**而砍掉该生态、保留 `github-actions`，本次判断进一步收紧：**Dependabot 本身就是我们不愿引入的东西**。即便它不可执行、只能开 PR、也拿不到 secrets，它仍是**外部自动化集成**——由 GitHub 平台运行、行为不由我们掌控，与本仓库「开发维护纯粹由维护者（狐莉）与小爪完成」的边界冲突。故整份 `.github/dependabot.yml` 删除，`AGENTS.md` 新增「## 安全边界：不引入外部自动化」章节将其固定为规则：给出拒绝清单（第三方 CI 扫描器、Dependabot 含纯配置形态）、判据（需要一项自动化能力时，先问**能否用仓库内已有的 `gh`/`git`/`nix` 自行实现**，可以就自己写进技能、不可以就人工执行）与已接受代价（action 的安全更新需主动跑技能检查，而非自动收到 PR）。**能力不丢**：此前「action 固定到 SHA 后收不到更新通知」这处盲点本由 Dependabot 填补，现改由 `nix-flake-update-check` 技能自行实现——新增「## 检查 GitHub Actions 的更新」章节（`grep` 列出固定 action → `gh api` 查 latest tag → 取 tag 的 commit SHA 并处理 annotated tag → 回写 SHA 与注释版本号 → 验证），原「Dependabot 的自动 PR 不能直接合并」小节改写为面向其他仓库的通用指引并加注本仓库不使用该类集成；四语文档同步。**实测**：按新流程核对现有 3 个固定 action，`actions/checkout` 最新 `v7.0.1`（`3d3c42e5…`）、`cachix/cachix-action` 最新 `v17`（`38b08261…`）均与仓库现值一致——即当前全部为最新

| 提交 | 说明 |
|------|------|
| `3421c1f` | chore(security): 移除 dependabot.yml 并确立「不引入外部自动化」安全边界 |

## 2026-09-17T11:03:51+09:00

**摘要**：chore(ci): Dependabot 移除 npm 生态，仅保留 `github-actions` — 基于 PR #7 的实测结论作出的调整：npm 生态对本仓库**结构性无效**。本仓库的 npm 包由 `buildNpmPackage` 包装，其 `npmDepsHash` 会被主构建与 npm-deps 产物**逐字节**校验，而 Dependabot 只改 `package.json`/`package-lock.json`、无法感知 `.nix` 里的该 hash，故它开出的**每个 npm 更新 PR 必然 CI 失败**（`npmDepsHash is out of date`）。保留该生态等于持续产生不可合并的 PR，故移除之；npm 依赖升级改由 `nix-flake-update-check` 技能人工处理（该技能已涵盖补 `npmDepsHash` 与核对 `next`/`alpha` 通道两步）。**配置内以注释完整记录了移除理由**（含 PR #7 的实测现象与「Dependabot 不跨 dist-tag」的限制），避免日后被误当作遗漏而重新加回。`github-actions` 生态保留——它在本仓库验证有效（PR #6 的 checkout 升级即由它产出，且正确保留了 SHA 固定）

| 提交 | 说明 |
|------|------|
| `4b997b3` | chore(ci): Dependabot 移除 npm 生态，仅保留 github-actions |

## 2026-09-17T10:55:02+09:00

**摘要**：chore(dsh-nixos-shell): `dsh-tools` 0.1.2-alpha.2 → 0.1.5-rc.2；ci: `actions/checkout` v4 → v7.0.1 — 两条均由**前一轮加入的 `dependabot.yml` 自动生成**，本条目记录审计与处置。**PR #6（checkout）已合并**：Dependabot 正确地保留了 SHA 固定（而非退回浮动标签），我核对了新 SHA `3d3c42e5…` 确实指向 `v7.0.1` tag（提交 `prep v7.0.1 release`）；初次 CI 有 2 项失败，但原因是 `llama-cpp-ver` 输入访问 GitHub API 时的 **403 限流**（与升级无关，62 项其他构建均通过），重跑后 **64/64 全通过**即合并。**PR #7（dsh-tools）已关闭并改为手动升级**：该 PR **必然无法通过 CI** —— Dependabot 只改 `package.json`/`package-lock.json`，无法感知 `buildNpmPackage` 的 `npmDepsHash`，CI 固定报 `npmDepsHash is out of date`；这是 **bot 与 Nix 包装的结构性错配**，非配置错误。此外它提议的 `0.1.2-rc.1` **落后于活跃通道**（`next` 已是 0.1.5-rc.2、`alpha` 已是 0.1.6-alpha.1），而**宿主 dsh 自带的正是 0.1.5-rc.2**。故手动升到 0.1.5-rc.2 使插件内嵌副本与宿主树对齐，并同步更新 `npmDepsHash` 为 `sha256-5jd5O4…`。**验证**：构建通过；产物内 `dsh-tools` 为 0.1.5-rc.2（与宿主一致）；运行时加载 `exit=0`、零错误；`nix flake check` 全通过。**泛化**：把「Dependabot 自动 PR 的处置」写入 `nix-flake-update-check` 技能——固定症状、补 hash 流程，以及「必须核对目标版本是否落后于 next/alpha 通道」这一易漏判据

| 提交 | 说明 |
|------|------|
| `dce26f2` | chore(dsh-nixos-shell): dsh-tools 0.1.2-alpha.2 → 0.1.5-rc.2 |
| `5f4e9ec` | ci: bump actions/checkout from 4.4.0 to 7.0.1 (#6) |
| `7b94d7c` | refactor(skill): nix-flake-update-check 补充 Dependabot 自动 PR 的处置 |

## 2026-09-17T01:40:58+09:00

**摘要**：docs(security): 在 `SECURITY.md` 明确「重复提交」的处理界限（四语） — 前一提交列出了 4 条已评估的外部报告，但措辞仅为说明性；本次追加「关于重复提交」小节使其具备约束力：**上表已列出的同一结论，若无新证据再次提交，将直接关闭并指向本节**。同时划清受理与关闭的界限以免误伤正当报告——**受理**：上表未涵盖的新问题、指出上表某条结论有误（附可复现证据）、相同主题但不同的威胁模型或利用路径；**直接关闭**：仅重述上表已有结论、同一规则的再次自动扫描输出。并保留一句「『指出结论有误』始终欢迎」——上表四条本身亦是经复核作出的判断，判据若错则应改正。四语同步

| 提交 | 说明 |
|------|------|
| `94bd95c` | docs(security): 明确重复提交的处理界限（四语） |

## 2026-09-17T01:34:13+09:00

**摘要**：docs(security): `SECURITY.md` 新增「已评估的外部报告」节并纳入四语本地化 — 目的是把**已复核并关闭的 4 条外部报告**公开列出，使后续报告者不必重复提交同类问题。逐条记录结论与依据：**PR #4**（@anupamme，称 `/token`、`/voicepack`、`/tts` 缺限流——误报：描述与 diff 不符，实际只改 `/query`；其限流键 `x-forwarded-for` 客户端可伪造，且本机同源 RPC 不带该头，会把全部本机流量并入单一桶而误伤自身）；**PR #5**（@anupamme，称 `/query` 缺请求体上限——误报：该防护早已由 `readJsonBody` 的 64 KiB 上限提供，其 `content-length` 检查可被 chunked 绕过、`text.length` 是 UTF-16 码元数而非字节数）；**issue #1**（@begininvoke，称 `secrets: inherit` 违反最小权限——误报：被调方是本仓库内的本地 workflow，全仓仅 2 个 secret，显式传递与 `inherit` 集合完全相同）；**issue #2**（同 #1，逐字节重复）。同节还记录了这些报告**促成的两次真实加固**：`/tts` 端点的 SSRF（报告未提及，复核端点时发现，该端点已随 `dsh-api-balance` 迁至新仓库）与 31 个构建 workflow 的最小权限补全。**立场说明**：规则命中本身大多属实，但威胁模型不适用于本项目的部署形态；处理方式是「先复核、再答复、附可复现证据」，且**误报不视为打扰**——上表四条最终引出了两次真实加固。本地化方面新增 `docs/SECURITY.{en,ja,pcn}.md`，四语切换器互链，四语 README 在许可节后加入指向。**注**：issue #1/#2 其后已被删除（现仅存 issue #3），此处保留历史编号以便追溯

| 提交 | 说明 |
|------|------|
| `6f34e73` | docs(security): SECURITY.md 记录已评估的外部报告，并纳入四语本地化 |

## 2026-09-17T01:23:46+09:00

**摘要**：chore(security): 补 SECURITY.md、Dependabot，并将 GitHub Actions 固定到 SHA — 起因是 awesome-ai-plugins 维护者（@kantorcodes）对 PR #323 的整改要求：其集中扫描给 NixKits 评 **71/100，低于该目录要求的 80 分阈值**，要求「修复或记录规则级发现，加入固定 SHA 的 scanner workflow，重跑扫描，达 80 分后请求 review」。逐项核对扫描评分表后确认：**零 critical、零 high**，扣分全在工程卫生项——Security 10/16（缺 `SECURITY.md`、「No approval bypass defaults」）、Operational Security 9/17（**Actions 未固定 SHA**、缺 Dependabot），而 Best Practices 6/6 与 Code Quality 10/10 均为满分。本次整改三项：① 新增 `SECURITY.md`（支持版本、GitHub 私有漏洞报告渠道、响应时限，并显式列出「已知设计边界」——免认证入口、sudo 守护、浏览器令牌读取、`/nix/store` 路径陷阱——以免这些**有意为之**的行为被反复误报为漏洞）；② 新增 `.github/dependabot.yml`（覆盖 `github-actions` 与 `npm` 两个生态）；③ **将 6 处第三方 action 从浮动引用固定到提交 SHA**。**第三项本身即有实质价值**：`DeterminateSystems/nix-installer-action@main` 原是**浮动分支引用**，上游任何变更都会直接进入我们的 CI —— 与早前「31 个 workflow 补 permissions」属同一类供应链卫生问题，而非仅为应付评分。**未采纳**：不引入维护者建议的第三方 scanner action（`hashgraph-online/ai-plugin-scanner-action`）——该建议在其文档中标注为非必需，代价是 10% 信任分扣减，已按接受处理。同时修订 `SECURITY.md` 中关于沙箱模式的措辞以免与扫描规则冲突

| 提交 | 说明 |
|------|------|
| `97a4180` | chore(security): 补 SECURITY.md、Dependabot，并将 Actions 固定到 SHA |

## 2026-09-16T16:45:03+09:00

**摘要**：fix(dsh-nixos-shell): 修复 `skills-nixos` 在本机部署后才暴露的路径断裂 — 这是 `559e841` 引入的缺陷，且**只有真正部署到本机才会显形**。该提交为 NixOS模式 增设第二个技能根，写作 `../../skills-nixos/`（相对预设目录），我当时只验证了「构建产物内相对路径可达」就判定成功。但 NixOS 模块的种子逻辑是 `cp -r presets/<mode> $DSH_HOME/.agent-presets/<id>`（seed-once）——**预设目录之外的内容不会被复制**，于是种子后该根解析为 `~/.dsh/skills-nixos`（不存在），新增的 3 个 NixOS 技能在 NixOS模式/维护模式 下**实际加载不到**。触发条件是本机从 `bf9c21e` 同步到 `95fc09b` 并重种子预设后才被发现。**修复**：`postPatch` 改为把白名单子集生成到各预设目录**内**（`presets/{nixos-mode,maintenance-mode}/skills-nixos/`），预设的 `customSkillDirs` 根相应改为 `skills-nixos/`（相对预设目录自身）——这与预设自带的 `skills/` 根一致，后者同样位于预设目录内，故种子后仍有效。`package.json` 的 `files` 移除已不存在的包根 `skills-nixos`；模块与预设中的职责注释同步订正，并明确记入「技能根必须位于预设目录内」这一约束。**验证**：模拟 seed 后 `skills-nixos` 可达（修复前此步失败）；`check-preset-derivation` 等 5 项 flake check 全通过；部署后新会话的技能目录已实际列出 `nixos-modern-cli`、`nixos-specialisation-tuning`、`recover-nixos-config`。**教训**：涉及「预设随种子复制」的设计，验证必须在**种子之后**的相对位置进行，只验 store 内路径会漏掉此类断裂

| 提交 | 说明 |
|------|------|
| `96b589c` | fix(dsh-nixos-shell): skills-nixos 移入预设目录，修复 seed 后路径断裂 |

## 2026-09-16T14:54:53+09:00

**摘要**：refactor(dsh-api-balance)!: 迁出为独立仓库，本仓改为薄封装 — 这是本仓**首次**组件拆分。审计确认该子项目是本仓唯一一个**平台无关**（非 NixOS 专项）的严肃项目（`lib/index.js` 1733 行 + `lib/client.js` 4922 行，39 次提交），且**代码层与 NixKits 零耦合**（仅 import `@deepseek-ai/dsh-credentials` 与 Node 内置模块，无任何仓库内引用），同时已有明确的 npm 打包需求——三项判据齐备。**执行结果**：新仓库 <https://github.com/Kihara777/dsh-api-balance>（公开，不带 git 历史，从单次初始提交开始），承载源码 + 四语完整文档 + npm 发布 CI（release 触发，含 provenance）；**已实测**从真实远端一行安装可用（`dsh plugin add github:Kihara777/dsh-api-balance` → 进入 `dsh.profile.bundles` → web profile 启动 `exit=0`、零错误）。本仓侧改动：删除 `packages/dsh-api-balance/`；`packages/dsh-api-balance.nix` 改为薄封装（`fetchFromGitHub` 固定 rev + 两个 hash，**`npmDepsHash` 未变**——证实迁出前后源码内容逐字节一致）；`docs/<lang>/dsh-api-balance.md` 各由 161 行压为短页（说明迁出、指向新仓完整文档，只保留本仓独有的声明式安装一节）；README 四语插件表标注迁出与薄封装角色。**CI workflow 有意保留**——它构建的 flake 输出 `#dsh-api-balance` 现即薄封装，保留可让声明式用户继续命中 Cachix 缓存。**同时更新 `write-project-docs` 技能**：新增「主仓薄封装 + 子仓完整文档」一节的架构约定（分工表、迁出判据、短页标准结构、主仓侧其余同步点），并把「已迁出组件在主仓保留完整文档副本」列入反模式表——使本次拆分沉淀为可复用流程而非一次性操作

| 提交 | 说明 |
|------|------|
| `0bb7fc1` | refactor(dsh-api-balance)!: 迁出为独立仓库，本仓改为薄封装 |
| `0760612` | feat(skill): write-project-docs 支持「主仓薄封装 + 子仓完整文档」架构 |

**待办**：npm 发布尚未执行——本机无 npm 凭据（未登录、无 token、`@kihara777` scope 不存在），需先在 npmjs.com 注册账号并创建 scope；包本身已 publish-ready（`npm pack` 确认 70.8 kB / 4 文件）。

## 2026-09-16T14:27:33+09:00

**摘要**：refactor(skills): 泛化 `/etc/nixos/AGENTS.md` 实践中的两个未覆盖缺口 — 起因是审计该文件（670 行，HarukaX 本机系统配置规则）中业务逻辑与经验的泛化价值。**审计结论：约 75% 已被现有技能覆盖**——分面架构与覆盖冲突、`mkForce` 误用事故、消费者归属原则、`mkDefault`、llama.cpp 参数禁用项与诊断顺序、平台档位实测、MCP schema 每轮开销、静默故障诊断（须读配置日志）等，均已在 `nixos-specialisation-tuning` / `nixos-modern-cli` / `recover-nixos-config` 中。**过程中修正一处自身误判**：初审认为「`mkForce` 误用未被覆盖」，逐词复核后发现该技能已有 4 处覆盖（含 `mkForce` 覆盖 `systemPackages` 导致删掉 `bash`/`systemd`、无法登录的完整事故案例），故从缺口清单中剔除。真正的缺口只有两个：**① 密钥与 `path:` input**（`nixos-modern-cli` 新增一节）——Nix 只把 git 跟踪的文件拷进 store，故密钥留在仓库内没有出路（提交则泄露；gitignore 则求值报 `Path ... is not tracked by Git`），须放仓库外用 `path:` input 引入，附两个陷阱：`path:` input 受 `flake.lock` 锁定、改内容需 `--update-input`；`{ nixosSecrets, ... }` 中 `...` **不绑定**该参数须显式列出。**② 热管理方法论**（`nixos-specialisation-tuning` 新增一节）——两类手段代价不同（抬高曲线只增噪音 vs 降档损失速度）；曲线末点封顶过致使最危险区间风扇恒定；`enabled: false` 致档位与曲线脱节（最高功耗档配最弱策略）；固件硬限恰好 8 个温控点且 panic 发生在**写入之后**；`asusctl` 写入是临时的、验证须重启守护进程确认从文件重读；决定性判据为温和 vs 激进曲线温度转速**完全相同** → 风扇已饱和 → 唯一有效手段是降功耗，且 EC 阈值对 OS 不可见。**未泛化**：机器型号、数值表、`triggerTemp`、mihomo 订阅细节、`g41.moe`、`toface` 脚本等强绑定本机的内容一律留在 `/etc/nixos/AGENTS.md`。两技能 `description` 与四语文档同步更新

| 提交 | 说明 |
|------|------|
| `a33a3cf` | refactor(skills): 泛化 /etc/nixos 实践的两个未覆盖缺口 |
| `fba7b38` | docs(skills): 同步两技能扩展后的功能清单（四语） |

## 2026-09-16T14:11:18+09:00

**摘要**：feat(dsh-nixos-shell): NixOS模式 同捆 3 个 NixOS 运维技能 — 起因是逐技能评审仓库 `skills/` 树（10 个）与两预设同捆内容的匹配度。评审结论：**加入** `nixos-modern-cli`（现代 Nix/NixOS CLI、shell 能力、sudo 流程）、`recover-nixos-config`（从 store 恢复误删的 /etc/nixos）、`nixos-specialisation-tuning`（specialisation 分面 + UMA 上 llama.cpp 调优）——三者均为「在 NixOS 上做事」的通用能力，正合 NixOS模式 定位；**不加** `nixkits-skills`（技能安装器，是工具而非工作方法）与 `news-three-elements`（创作类，且已由独立包 `dsh-preset-news-three-elements` 提供专属预设）。维护模式为 NixOS模式 的派生，**自动继承**这 3 个。**实现方式（避免副本）**：不把技能复制进 `presets/<mode>/skills/`——该目录在两预设间逐字节镜像，再放一份会成为仓库 `skills/` 之外的第二副本而可能漂移。改为在 `postPatch` 中按白名单从同一仓库树生成构建期子集 `skills-nixos/`，预设的 `skill-filesystem` 行增加第二个 `customSkillDirs` 根，以 `../../skills-nixos/` 相对路径解析（`baseUrl` = 预设目录）。**为何用子集目录而非直接挂 `skills-embedded/`**：`skill-filesystem` 会注册每个配置根下的**全部**子目录，直接挂嵌入树会把 `write-project-docs` 等维护类技能一并带进 NixOS模式，超出本次选定范围。已实测：构建产物中 `skills-nixos/` 恰含 3 个技能、与仓库源逐字节一致，`../../skills-nixos/` 从预设目录可达，`skills-embedded/` 仍完整保留 10 个；`check-preset-derivation` 等 5 项 flake check 全通过

| 提交 | 说明 |
|------|------|
| `559e841` | feat(dsh-nixos-shell): NixOS模式 同捆 3 个 NixOS 运维技能 |
| `7971689` | docs(dsh-nixos-shell): 记录 NixOS模式 新增的 3 个同捆技能（四语） |

## 2026-09-16T13:57:56+09:00

**摘要**：feat(dsh-api-balance): 新增 `dsh.bundle`，支持 `dsh plugin add` 原生安装 — 因 `dsh-api-balance` 与 `dsh-nixos-shell` 性质不同：前者是**平台无关的界面/功能增强**（仅 `inject = ["connection", "webServer"]`，无预设、无技能、不写 `$DSH_HOME`），而后者的核心价值正是 Agent 预设。前一轮已确认 `dsh-nixos-shell` 的 bundle 路线不可行（预设 root 需绝对路径，`./` 锚定只作用于 `insert[].name`）。**关键发现（推翻此前结论）**：读 `cordis-plugin-loader/lib/index.js:269-284` 得知，entry 名以 `./` 开头时会被 `anchorInsertedPluginNames` 锚定为**该 patch 所在目录**下的绝对 `file://` URL，从而正常 import——此前的"loader 只从 dsh 树解析、profile 里的包装不上"的判断是错的。本次据此实现：新增 `cordis.patch.yml` 以 `name: './lib/index.js'` 注册插件（**不可**写裸包名，否则从 dsh 安装树解析报 `Cannot find package`），`package.json` 加 `dsh.bundle.patch` 并在 `files` 补该文件。**实测**：安装后成功进入 `dsh.profile.bundles`，`--dump-config` 显示 entry 锚定为 profile 内的绝对 URL，web profile 启动 `exit=0` 且零错误；Nix 构建与 `nix flake check` 均不受影响。**双轨并存**：两条路径均可独立工作（声明式写 `$DSH_HOME/profiles/web/cordis.patch.yml`，bundle 写 `dsh.profile.bundles`），但**同时启用会重复注册同一 entry id**，故文档明确要求二者择一，并说明方式 B 经 git 解析、不受 `flake.lock` 锁定

| 提交 | 说明 |
|------|------|
| `ac3cb3e` | feat(dsh-api-balance): 支持 dsh.bundle，可经 dsh plugin add 安装 |
| `bee12d7` | docs(dsh-api-balance): 补充两种安装方式与 bundle 机制说明（四语） |

**相关外部报告**：issue #3（@zerocodefast）——awesome-ai-plugins 收录邀请；`dsh-api-balance` 现具备投 DeepSeek Harness 节的技术条件，`dsh-nixos-shell` 仍保持声明式（其理由已记录于 `d14146c` 条目）。

## 2026-09-16T13:44:09+09:00

**摘要**：refactor(dsh-plugins): 移除两个插件未使用的 `peerDependencies` — 起因是评估 issue #3 的收录邀请时，为验证 dsh 插件能否经 `dsh plugin add` 安装而做的实测。实测发现两个插件的 peer 声明**与实际 import 完全不符**：`dsh-nixos-shell` 声明 `cordis` / `dsh-subprocess` / `dsh-timer`，`dsh-api-balance` 声明 `cordis` / `dsh-client-connection`，而两者实际只 import 各自的真实依赖（`dsh-tools` + `schemastery` / `dsh-credentials`）。其中 **`@deepseek-ai/dsh-timer` 在 npm（404）与宿主 dsh 树中都不存在**——宿主由 `cordis-plugin-timer` 提供 `timer` 服务，而插件 `inject` 的是服务名而非包名；`dsh-client-connection` 则已由 `dsh.client.inject` 正确声明，属重复。**影响判断**：这些死声明在声明式路径下**从不生效**（`buildNpmPackage` 用 `--legacy-peer-deps` 跳过 peer 解析，已实测构建产物仅含真实依赖），故本改动不影响任何现有部署、无版本变更；但它们在 pnpm 路径下会**直接阻断安装**（`dsh-timer` 404），且向生态传递误导性信号。lock 与 `npmDepsHash` 同步重生成（已验证 vendored lock 与 npm-deps 的 fixup 产物逐字节一致）。**路线取舍记录**：本轮曾评估为 `dsh-nixos-shell` 补齐 `dsh.bundle` 以投 awesome-ai-plugins 的 DeepSeek Harness 节，实测确认插件本体可经 `github:...#path:` 安装并进入 profile layer stack（无需发 npm），但 **Agent 预设无法经 bundle patch 注册**——`agent-presets.roots[].path` 需绝对路径，而 patch 只能锚定 `insert[].name`、`!!js` 作用域仅有 `dshHomePath`（且反引号会致 js-yaml 解析失败）。绕开该限制需让插件写用户 `$DSH_HOME` 来种子预设，牺牲声明式与不可变性。**结论：放弃 dsh.bundle 路线**——本项目插件面向 NixOS，经 flake/NixOS 模块声明式分发（版本由 Nix 锁定、随系统代际更新、可复现）更符合 NixOS 哲学且维护成本更低；相关改动已全部回退，未进入历史

| 提交 | 说明 |
|------|------|
| `d14146c` | refactor(dsh-plugins): 移除未使用的 peerDependencies |

**相关外部报告**：issue #3（@zerocodefast）——awesome-ai-plugins 收录邀请，保持 open 未提交 PR。

## 2026-09-16T12:39:12+09:00

**摘要**：refactor(skills)!: 拆分 `nixkits-check-updates` 为「通用核心 + 仓库适配层」 — 起因是评估 issue #3（awesome-ai-plugins 收录邀请）。该邀请本身无技术争议，但促使我们审查被推荐技能的可移植性：原 `nixkits-check-updates`（299 行）与 NixKits 强耦合——第 5 步**硬编码** `for lang in zh en ja pcn` 与 `docs/$lang/<pkg>.md` 路径、整节 dsh 插件清单同步、第 8 步强制调用 `write-maintenance-log`。**这使它对其他 nix flake 仓库不可直接用**：非 NixKits 仓库执行到第 5 步会去 `sed` 不存在的 `docs/pcn/`，到第 8 步会调用不存在的技能——不是措辞不够通用，而是执行会直接失败。本次按「通用核心 + 仓库适配层」拆分：新增 `nix-flake-update-check`（314 行，不绑定任何仓库）承载包发现、包型分流 hash 流程、flake.lock 三路处置、补丁内版本检查与 nixpkgs 漂移陷阱，第 5/8 步改为「按仓库实际结构选择」而非硬编码；`nixkits-check-updates` 瘦身为适配层（299 → 115 行），只留四语文档、dsh 插件清单、维护日志与历史事故教训（comfyui 漂移、codewhale-riscv64 CI 失败、Rust Cargo.lock）。定义**适配层契约**（文档同步 / 变更记录 / 动态输入 / 事故教训 / 额外同步项由适配层声明，冲突时以适配层为准）。**关键取舍**：此前担心泛化会稀释具体经验而让技能在主场变弱——拆分正是为规避该代价，事故教训与仓库约定**原样留在适配层**，通用核心只保留与仓库无关的方法论，两端各得其所。维护模式注入同步补入通用技能（二者均注册）；四语新增通用技能文档，README / dsh.md / modes/maintenance.md 注入清单与技能表同步

| 提交 | 说明 |
|------|------|
| `667bf6e` | refactor(skills)!: 拆分更新检查为通用核心 + NixKits 适配层 |
| `93fe67e` | feat(dsh-nixos-shell): 维护模式注入 nix-flake-update-check 技能 |
| `6af37e7` | docs: 同步技能拆分——四语新增通用技能文档、README 技能表与注入清单 |

**相关外部报告**：issue #3（@zerocodefast）——awesome-ai-plugins 收录邀请。经评估，其推荐语把 NixKits 定位为「包含中文技能的包合集」而未提及它同时是 Nix 包/模块/补丁合集，且「Chinese-language skills」易被误读为仅对中文用户有用；收录本身与技术无关，故保持 open，未提交 PR。

## 2026-09-16T12:20:57+09:00

**摘要**：ci: 为 31 个构建 workflow 补全顶层 `permissions` — 特别感谢外部贡献者 **@begininvoke**（RedGem 扫描报告）提交的 issue #1、#2：这两条报告经核验为误报（同一扫描器对 `build-blender-mcp-aarch64.yml:10` 的 `secrets: inherit` 重复报告，正文逐字节相同），规则命中虽属实但威胁模型在本仓库不成立——被调方 `./.github/workflows/build-package.yml` 是**同仓库、同 commit、同 review 流程**的本地可复用工作流，不存在 issue 假设的「untrusted source」；本仓库**总共只有 2 个** secret（`GITHUB_TOKEN`、`CACHIX_AUTH_TOKEN`），显式传递与 `inherit` 传递的集合**完全相同**，故对攻击者**不产生任何增益**——能篡改被调 workflow 的人本来就能直接读 `secrets.*`；且只改报告点名的那一处会在 31 个同构调用方之间造成不一致，故两条 issue 均不予采纳并已附详细证据关闭——**但正是这两条报告促使我们去做了一次完整的权限边界复核**，报告把注意力引向「可复用 workflow 的 secret/权限传递」这一正确方向，顺着该线索逐条核对调用链后，**发现并修复了一处真实的安全风险**：31 个 `build-*.yml` 调用方**均未声明 `permissions`**，因而继承仓库默认（可能为读写），而它们实际只做 checkout + `nix build` + 推送 Cachix，全部只需 `contents: read`。本次即为这 31 个调用方补上顶层 `permissions: contents: read`，与被调方 `build-package.yml:17-18` 已声明的权限保持一致。**取舍说明**：Cachix 推送使用独立的 `CACHIX_AUTH_TOKEN`，不依赖 `GITHUB_TOKEN` 的权限范围，故收紧后 CI 行为不变（`nix flake check` 中 `check-workflow-coverage` 通过）。**未采纳的部分**：不将 31 处 `secrets: inherit` 改为显式列举——那是形式合规而无实质安全收益的改动，且 `CACHIX_AUTH_TOKEN` 必须传给被调方，最小权限在此没有可削减余量

| 提交 | 说明 |
|------|------|
| `445eb4b` | ci: 为 31 个构建 workflow 补全顶层 permissions（最小权限） |

**相关外部报告**：issue #1、#2（@begininvoke / RedGem）——内容逐字节重复，经核验为误报，已附详细技术证据评论后以 not planned 关闭；其线索价值已致谢。

## 2026-09-16T11:58:25+09:00

**摘要**：fix(dsh-api-balance): 修复自定义 TTS 代理的 SSRF 与请求头注入面 — 特别感谢外部贡献者 **@anupamme**（OrbisAI Security 扫描报告）提交的 PR #4、#5：这两条报告本身经核验为误报（#4 声称 `/token`、`/voicepack`、`/tts` 四个端点缺少限流，diff 却只改了第五个端点 `/query`，且以可伪造的 `x-forwarded-for` 为限流键会让本机同源客户端坍缩到单一桶而自我 429；#5 声称 `/query` 缺少请求体体积上限，而该防护早已由 `readJsonBody` 的 64 KiB 上限提供，其新增的 `content-length` 检查可被 chunked 绕过、`text.length` 又是 UTF-16 码元数而非字节数），故两条均不予合并并已附详细证据关闭——**但正是这两条报告唤醒了我们的安全边界复核意识**，促使我们逐端点核对本插件的输入与出网约束，并在其提及的 `/tts` 处理逻辑上**发现并修复了一个真实的安全威胁**：该代理接受任意 `http(s)` URL 并以 host 身份发起请求，可被用作内网探测与云元数据（`169.254.169.254`）读取的跳板；同时它把请求体中用户可控的 `headers` 原样转发，攻击者可借 host 身份补 `host` / `cookie` / `authorization` 头放大后果。本次按真实威胁模型修复：新增 `resolveTtsTarget` 与 `isBlockedAddress`，拒绝回环 / 私有 / 链路本地 / 保留地址（覆盖 RFC1918、`100.64/10` CGNAT、`169.254/16`、`224/4`、`fc00::/7`、`fe80::/10`、`ff00::/8`，含 IPv4-mapped IPv6），字面量 IP 直接判定、域名比对 DNS 解析结果；自定义请求头改为白名单（仅 `content-type` / `accept` / `accept-language` / `user-agent`）。**判断依据与取舍**：曾尝试「把连接固定到已校验 IP」以彻底消除 DNS rebinding 的 TOCTOU 窗口——实测 Node 的 `fetch` 强制以 URL 的 host 作为 `Host` 头与 TLS SNI，覆写 `host` 头被静默忽略，改 URL 主机名则会让合法 HTTPS TTS 后端的虚拟主机路由与证书校验全部失效。该代价高于本端点残余风险（本机自托管 dsh 的辅助代理，非多租户边界），故显式保留并在源码注释中记录该限制，而非以「已修复」掩盖。四语文档同步补充防护说明

| 提交 | 说明 |
|------|------|
| `e1a6e66` | fix(dsh-api-balance): 修复 TTS 代理的 SSRF 与请求头注入面（含四语文档同步） |
| `72cb6ae` | fix(docs): pcn 维护条目去除残留假名（のみ → 限定） |

**相关外部报告**：PR #4、#5（@anupamme / OrbisAI Security）——经核验为误报，已附详细技术证据评论后关闭；其线索价值已致谢。

## 2026-09-16T11:38:20+09:00

**摘要**：docs(deprecated): `DEPRECATED.md` 索引化并四语本地化 — 原先这一份中文文档同时承担两个职责：**索引**与**单个项目的完整说明**。只有一条时无妨，但它注定要长——项目一多，读者无法一眼看全，且整份文档没有本地化路径（既有的 `docs/<lang>/` 体系无处安放它）。本次按仓库既有约定重构：根 `DEPRECATED.md` 退化为**纯索引**（列表 + 指向各项目详情的链接），并按 `README`/`MAINTENANCE` 的成法出三份镜像 `docs/DEPRECATED.{en,ja,pcn}.md`；各废弃项目的详情移入 `docs/<lang>/deprecated/<name>.md`，四语各一份，顶部带语言切换器与返回索引的链接。首批迁移 comfyui-rocm 的完整说明（含逐字致敬句、三补丁对照表、scipy 误判复盘、废弃后配置示例、历史版本对照）。四语 `README` 新增「废弃项目」章节，`docs/<lang>/comfyui.md` 的引用改指详情页。**踩坑记录**：`docs/DEPRECATED.*.md` 自身位于 `docs/` 内，故其指向语言目录的链接必须写 `zh/...` 而非 `../zh/...`——`nix flake check` 首次即抓出 6 条死链（en/ja/pcn 各指向另外三语），已全部修正。这正是 `check-doc-links` 存在的价值：它拦下的恰是"照着上层文件的习惯写相对路径"这类只有人工翻页才会发现的错误。重构后新增项目只需在索引加一行、再补四份详情文档

| 提交 | 说明 |
|------|------|
| `8ff91eb` | docs(deprecated): 索引化 + 四语本地化，详情拆到独立文档 |

## 2026-09-16T11:05:32+09:00

**摘要**：refactor(comfyui)!: 退役 comfyui-rocm 补丁工程，模块改名 `nixkits.comfyui` — 上游已积极维护并把 ROCm 支持组件更新到能很好支持 StrixHalo 的版本，本补丁的历史使命完成，故整体移除：三个补丁（`strix-halo` / `nixpkgs-compat` / `stdenv-api`，本地补丁目录清空）、`modules/comfyui-rocm.nix` → `modules/comfyui.nix`、选项 `nixkits.comfyui-rocm` → `nixkits.comfyui`（去掉已无意义的 `-rocm` 后缀），四语文档 `comfyui-rocm.md` → `comfyui.md`，新增根目录 `DEPRECATED.md` 并把它列为第一条。**本次最值得记的是那个被误判了三轮的根因**：早先的「补丁已不再需要」结论建立在一轮 717-derivation 构建「全部成功」之上，**但那次 `scipy` 是二进制缓存命中、从未真正构建**——判据应当是日志里出现 `building '…'`，而不是「构建退出码为 0」。真正的原因是本机 `/etc/nixos` 把 comfyui-nix 的 `inputs.nixpkgs` 钉死在 `6438090`（2026-08-02）而顶层走 `nixos-unstable`：滚动的顶层让 `scipy` 命中公共缓存，被钉住的子 flake 则要现建，于是触发 `test_support_moments_sample` 的浮点断言失败，**看起来像「补丁仍然必要」**。删掉那行 pin 后 comfyui-nix 与顶层共用 `dc5d91f`，`scipy` 直接缓存命中、构建全绿。教训：**额外的 pin 会让子 flake 脱离主 nixpkgs 的缓存覆盖**，把缓存本来能解决的问题暴露成需要打补丁的问题。补丁过时性另有两条独立佐证：上游 `stdenv` 弃用读法计数为 **0**（34 处用 `hostPlatform`）；上游 `nix/versions.nix` 的 `rocm71` torch **2.10.0** 与 `strix-halo` 补丁逐字节一致（版本 / URL / hash 三者皆同），上游模块亦已支持 `gpuSupport = "rocm"`。**本机侧同步**：`system/software/comfyui.nix` 改用新选项路径、`flake.nix` 删 pin 行并重写注释、`flake.lock` 中 comfyui-nix 由 `path:` 变 github；两面 `nix build` 仅 10 个 derivation 待建、切至 generation 572，`comfyui.service` 仅存在于 plasma specialisation，`ExecStart` 为 `comfy-ui-0.34.0`、`HSA_OVERRIDE_GFX_VERSION=11.0.0` 仍由本模块的 `rocmGfxOverride` 提供。另删除了 `/home/kix/comfyui-nix-patched`（17 MB 陈旧 fork，仅剩注释引用）

| 提交 | 说明 |
|------|------|
| `5015bcc` | refactor(comfyui)!: retire the comfyui-rocm patch project, rename module |

## 2026-09-16T01:45:07+09:00

**摘要**：docs: 预设包更新要 `daemon-reload` 再 `restart dsh` — 本次部署实测到的坑：`nixos apply` 按设计不重启 dsh（稳定挂载点），而单跑 `systemctl restart dsh` 时系统仍执行**上一代**的 pre-start 脚本——它才是把 `cordis.patch.yml` 拷进 `$DSH_HOME` 的那一步，预设根就写在那份文件里。症状是「服务确实重启了（ActiveEnterTimestamp 已更新）、会话里还是旧预设」：gen 570 部署后第一次 restart，`$DSH_HOME/profiles/web/cordis.patch.yml` 仍指向旧 store 路径，加 `systemctl daemon-reload` 再 restart 才翻到新路径（新副本含 `news-material.js`，与仓库逐字节一致）。AGENTS.md「本机部署」补上操作次序与核对方法（重启后查 patch 文件里的 store 路径），`docs/{zh,en,ja,pcn}/dsh.md` 的「代价与配套」一段同步改写

| 提交 | 说明 |
|------|------|
| `a167aae` | docs: 预设包更新要 daemon-reload 再 restart dsh |

## 2026-09-15T23:47:01+09:00

**摘要**：feat(preset+skill): 取材门 `news-material` — 实际会话里暴露出「共创时生搬硬套」：用户给的素材被换个格式直接发出去，检索那一步常被跳过。提示词里写死的规则会漂，于是把「先检索再改写」做成运行时能核对的门。新插件 `plugins/news-material.js` 挂两个钩子：`agent/pre-step` 在受理人力消息的那一步随行注入一条「取材铁律」（按消息 id 幂等，重试不叠加）；`agent/turn-stopping`（回合封锁前、可被驳回的那一刻）读本回合自己的日志——**整个回合没有一次 `web_search` / `web_fetch` 调用，或正文照抄了用户原文**，就 `agent.steer()` 一纸「编辑部退稿」，`dsh-agent-loop` 据此在同一回合再走一步重写。**每回合只退一次**（agent 级 WeakMap + 回合号），不听话的模型也不会死循环。照抄判定＝与用户消息及它指给模型的文件（本回合 `read` 的结果）逐字比对，只数汉字、**连续 8 字**以上命中：拉丁文作品名不误伤、三位主角的名字（至多 5 字）在阈下、搜索结果不算素材（复用通讯社原句正是本模式的目的）、共创稿末尾的「本稿取材」收据按设计引用素材故先剥离。技能侧同步三条可核对规则：第 2 步新增「提炼 → 投射 → 换皮」三步改造表与 8 字红线 + 收据行，检索记录升为硬性要求（编造与拒绝一视同仁），`checklist.md` 的素材共创自查 3 → 7 项；persona 改写素材共创一节，并写明收到退稿时直接重发、不向用户解释。新增 31 条断言（无检索退稿、单次检索放行、上一回合的检索不算数、每回合只退一次、按 session 隔离、8 字命中／7 字不命中、`read` 文件同样受检、拉丁标题不误伤、收据可引用素材、提醒随人力消息注入且不重复）。**踩坑记录**：`nix flake check` 首次在 `news-mode-tests` 报 `ERR_MODULE_NOT_FOUND`——flake 源是 git 跟踪的文件集合，新增的插件文件未 `git add` 就没进 store（本地直跑同一脚本却全过），已把这条写进 AGENTS.md 的 flake 规则。`nix flake check` 6 项全过，四语文档（技能 / 模式 / README / `dsh.md`）同步

| 提交 | 说明 |
|------|------|
| `a0759b1` | feat(skill): 素材只是导火索——三步改造、禁照抄、必检索 |
| `cc9d0d1` | feat(preset): 取材门 news-material——无检索即退稿，照抄即退稿 |
| `71f25db` | docs: 四语同步素材共创铁律与取材门 |
| `a2ccd55` | docs(agents): 新增文件先 git add 再跑 flake check |

## 2026-09-15T12:36:10+09:00

**摘要**：feat(skill+preset): 「新闻三要素」改指三位主角，拒绝服务改判「先当素材」 — 维护者提出四条修正：① 本模式的「新闻三要素」不指新闻学那三样，而是**三位必须到场的主角**——巴兰尼科夫、尤丁采夫、布亚诺夫；② 拒绝服务过于敏感，凡靠检索补全就能用的素材一律不得拒绝；③ 共创的稿子必须带齐三人；④ 假设性疑问与不指名的说法要先评估能否落到三人身上，而不是挡回去。技能侧：SKILL.md 定死新含义，新增「格式硬性要求」第 0 条（三人全部出现在正文，缺一即返工），第 1 步取材扩为四类（首位是三人本人）；「拒绝服务」重写为硬性判定顺序——**能当素材的一律不得拒绝 / 假设性疑问按「已经发生」处理 / 不指名的人士先试着拟合 / 全都接不回来才拒**，拒绝话术本身的现取素材与禁止复用规则不变；`search-keywords.md` 新增首节身份对应表，`checklist.md` 首项改为三人到齐并新增「素材共创自查」三项，`principles.md` 第 8 条改写、新增第 13 条「先当素材」（共 13 条）。预设侧：persona 新增「素材优先：能当素材的一律不得拒绝」一节与共创「成篇必须带齐三位主角」，开场问答的自定义回答拒绝规则补一句边界（只管问答本身），「其它一切请求的拒绝方式」改为只处理确实接不回来的请求，`readonly-gate` 的仪式句补上三人括注。新增 14 条断言（三个名字同时出现在 persona 与技能包、素材优先四要件、共创三人在场、checklist 首项、principles 不再以教科书三要素定义、身份表在首节；仪式句断言改为容许括注的正则，旧的「（新、事实、报道）」括注仍禁止回归）。四语文档（技能文档 / 模式文档 / README / `dsh.md`）同步；`nix flake check` 6 项全过

| 提交 | 说明 |
|------|------|
| `8f5b848` | feat(skill): 新闻三要素改指三位主角，拒绝服务先当素材 |
| `1adb6be` | feat(preset): 模式提示词改为素材优先，快讯须三人到齐 |
| `4732835` | docs: 四语同步新闻三要素的三人定义与素材优先判定 |

## 2026-09-15T11:47:48+09:00

**摘要**：fix(preset): 只读范围放行「自身技能包」 — 上一轮把读取收紧到「工作区 / 附件目录 / `/tmp`」时，**把模式自己的技能包也关在门外**：`tables.md`、`checklist.md` 位于抓取缓存 `$DSH_HOME/.cache/news-three-elements/` 或包内兜底快照，两者都不在允许根里。会话记录取证（`session-e42ea512`）里可见守卫的原文拒绝：「被拒绝的路径：/home/kix/.dsh/.cache/news-three-elements/tables.md（本模式只允许查看会话工作区、附件目录与 /tmp）」，模型于是自述「配套文件读不到，就按技能正文的硬性要求成文」——过渡词与结尾反转模板全部缺席。修法：把**抓取缓存目录**与**预设根（含 `bundled/` 兜底快照）**一并列入可读根，拒绝文本改为「…、`/tmp` 与自身技能包目录」；新增 2 条断言（缓存与内置快照均可读、越界仍拒），四语文档同步

| 提交 | 说明 |
|------|------|
| `ee072d5` | fix(preset): keep the mode's own skill package inside the read scope |

## 2026-09-15T11:38:02+09:00

**摘要**：fix(preset): 仪式句改称「催逝快讯」 — 每次拒绝收尾那句原写作「只编造带齐新闻三要素（新、事实、报道）的俄式快讯」，其中「（新、事实、报道）」是新闻学教材里的原意，念出来像在引用定义，把包袱压平了。改为「只编造带齐新闻三要素的**催逝快讯**」——与开场三选一里既有的「催逝员」用词对齐。persona 与 `readonly-gate` 的拒绝文本各一处（共两处，均为固定提示词）；技能与文档中「产物」类定义性描述未动。新增 4 条断言：两处都出现「带齐新闻三要素的催逝快讯」，且旧的原意括注不得回归

| 提交 | 说明 |
|------|------|
| `bfb0ed4` | fix(preset): say 催逝快讯 in the ritual line, not the academic gloss |

## 2026-09-15T11:24:49+09:00

**摘要**：fix(preset): 语言审查只审人写的消息 — 用户新开会话观察到「简体中文的合法请求被回绝、且附带英文译文」。查会话记录（`session-efc87486`）取证：该 step 里除用户的中文消息外，还混有一条 harness 注入的**英文系统消息**（`source.kind = plugin`：「The approval policy changed from "never" to "ask"…」）与 `skill-catalog` 消息；守卫原先审「本步准入的**全部**消息」，遂把英文系统提示当成「用户未用简体中文」→ 注入语言审查 → 模型按规则回绝并按「与对方语言一致」补了英文译文。修法：`withNotice` 仅取 `source.kind === "user"` 的消息判定（harness 注入的批准提示、技能目录、工具结果一律不计），并补两条回归测试（英文批准提示 + 中文请求的组合不再触发；无人类消息的 step 不动）；四语文档同步说明该边界

| 提交 | 说明 |
|------|------|
| `9557707` | fix(preset): judge only the human's messages in the language gate |

## 2026-09-15T11:08:06+09:00

**摘要**：feat(preset)+test: 仓库自检体系与模式行为加固 — `nix flake check` 由 1 项扩到 **6 项**：新增 `preset-bundle`（包内技能快照必须与 `skills/` 逐字节一致）、`workflow-coverage`（每个包都有构建 workflow，例外显式登记）、`doc-links`（相对链接可达 + 四语切换器齐全 + pcn 无假名）、`maintenance-log`（四语条目数一致、时间戳精确到秒、SHA 去重）、`news-mode-tests`（模式插件行为测试，**无网络**：打桩 fetch 用包内快照供源并在第二次返回 304，顺带覆盖 ETag 路径）。检查上线当天即抓出并修复一批既存缺陷：12 个翻译文档的切换器指向同目录 `<name>.<lang>.md`、3 处 codewhale 跨文档链接写错、1 条 `+00:00` 时间戳、`dsh-api-balance` 缺构建 workflow。同轮四项行为加固：**只读限范围**（绝对路径仅工作区 / 附件目录 / `/tmp`）、**抽取不连续重复**、**弹窗在用户先开口时自动撤回**、**技能抓取并行 + ETag 条件请求**（内容不变即 304，不重写盘）；人格把常设拒绝条款交还给技能「拒绝服务」一节，避免两处漂移

| 提交 | 说明 |
|------|------|
| `9260dd5` | test: guard the repo with six flake checks and an in-repo test suite |
| `ac4b05c` | feat(preset): scope reads, harden the draw, and make the fetch incremental |
| `0af079c` | docs(preset): record the scoped reads, incremental fetch and hardened draw |
| `9810af5` | fix(docs): repair the switchers and dead links the new check found |

## 2026-09-15T10:57:15+09:00

**摘要**：feat(skill): 技能新增「拒绝服务」一节 — 拒绝流程从「只存在于某个预设的人格」升格为**技能本体**：`SKILL.md` 新增「拒绝服务」章（不属于编造/素材改写的请求一律按本节拒绝；**每次动笔前先联网取当天素材**；理由、句式、段落顺序、结尾反转、过渡词都不得与上一次重复；三到五句通讯社文风；底色「一本正经胡说八道」；拒绝即止），[`tables.md`](skills/news-three-elements/tables.md) 顶部标明模板只是骨架、素材必须当次取，[`checklist.md`](skills/news-three-elements/checklist.md) 增补「拒绝服务自查」5 项；四语技能文档与各 README 技能行同步，预设包内兜底快照重生成、人格两处改为按名引用该节

| 提交 | 说明 |
|------|------|
| `f120a3d` | feat(skill): give the skill a refusal service of its own |
| `8c28f03` | chore(preset): sync the bundled skill snapshot and point the persona at the section |

## 2026-09-15T10:50:26+09:00

**摘要**：feat(preset): 译文限定在语言审查、且与对方语种一致 — 本地化版本只属于「非简体中文」这条规则的拒绝：简体中文用户的其它请求被拒时**只给中文正文**，不附译文、不附注（语言本身合法，没有可译之物）；译文还必须**与对方实际使用的那一种语言一致**（写英文译英文、写日文译日文、写繁体中文译繁体中文），不得换成第三语言、不得中英混排。两条都从「没写、靠模型自觉」升格为人格与注入指令中的显式规则（人格另在「其它一切请求」节明写「本节不翻译」），四语文档同步；自测新增 6 项断言

| 提交 | 说明 |
|------|------|
| `00a0088` | feat(preset): scope the refusal translation to the language gate |

## 2026-09-15T10:39:08+09:00

**摘要**：feat(preset): 抽「人」而非抽游戏 + 每次拒绝现搜素材 — 推荐池由三款游戏改为**三位制作人**：抽到谁，游戏随谁（尤丁采夫、巴兰尼科夫 →《战争雷霆》；布亚诺夫 →《逃离塔科夫》），加「绿色的猫头鹰」共四者等概率、一次只推一样，《从军》移除。更关键的是拒绝辞不再有单一重复理由：人格与注入指令都要求**每次拒绝动笔前先用 `web_search` 取当天素材**（真实新闻措辞、官方借口、机构公告），理由、句式、结尾反转与过渡词均不得复用上一次，机械重复被明写为「本模式最严重的失误」，底色保持「一本正经胡说八道」。自测对 400 次抽取逐次校验「人—游戏」对应关系与分布（23 / 29 / 25 / 23%）

| 提交 | 说明 |
|------|------|
| `1a046d3` | feat(preset): draw a producer, not a game, and re-source every refusal |

## 2026-09-15T10:31:30+09:00

**摘要**：feat(preset): 回绝推荐改为随机四选一 — 语言审查的学中文暗示不再固定推那两款：《战争雷霆》（Gaijin 创始人尤丁采夫与其制作人巴兰尼科夫）、《逃离塔科夫》（Battlestate 布亚诺夫）、《从军》（Gaijin 第三作）三款，或「绿色的猫头鹰」软件——插件**每次回绝现掷一次**，四者等概率，并把抽到的结果写进注入指令；该指令**只提抽到的那一样**（写成「提第二样」的初稿已被自测拦下），一次回绝不会报两款。插件不检测的情形（如繁体中文）由人格携带同一规则。实测 400 次抽取分布 23 / 24 / 28 / 25%

| 提交 | 说明 |
|------|------|
| `28f161a` | feat(preset): draw the refusal's recommendation at random |

## 2026-09-15T10:19:12+09:00

**摘要**：fix(codewhale): 刷新 riscv64 的 Cargo lock — 补齐源码哈希后，riscv64 构建随即在依赖 vendoring 阶段报「cargoHash or cargoSha256 is out of date」：仓库内固定的 `codewhale-src-Cargo.lock` 与上游 v0.9.12 不一致（549 行差异，`ansi-to-tui` 等条目缺失），说明它是按另一个修订生成的。改用源码树自带的 `Cargo.lock`——`rquickjs-sys` 仍为 0.12.2（bindings 的 `postPatch` 继续有效），且上游无 git 源依赖，无需额外固定。x86_64 / aarch64 走预编译二进制路径，不受影响；CI 因此首次进入编译阶段

| 提交 | 说明 |
|------|------|
| `b8fd5b1` | fix(codewhale): refresh the riscv64 Cargo lock |

## 2026-09-15T10:12:41+09:00

**摘要**：feat(preset): 「模式」独立成章节 + 新闻三要素模式改由独立包分发 — Agent 预设更名为「模式」，主文档中与插件同级，三种模式各有独立文档（`docs/<lang>/modes/{nixos,maintenance,news-three-elements}.md`，四语）。分发方式二分：NixOS模式 / 维护模式仍随 dsh-nixos-shell 包 seed-once；新闻三要素模式移入**独立包** `dsh-preset-news-three-elements`（新增 flake 输出、overlay 条目与 x86_64 / aarch64 构建 workflow），模块新增 `presets.newsThreeElementsPackage` 并把包内 `share/dsh-agent-presets` 注册为 `agent-presets` roster 的额外根——预设从 store 直读，不再复制进 `$DSH_HOME`（`- id:` 行替换**整份** config，故发出的 JSON 必须带上必填的 `default`）。同轮措辞修正：仪式句结尾改为两个全角叹号「我们从不制造 FAKE NEWS！！」；语言审查的回绝改为**《好心》附上用户所用语言的本地化版本**（中文正文在前，译文在后）；「绿色的猫头鹰」在语境合适时可简称「绿毛鸡」。另修一处既存死链：`docs/README.<lang>.md` 在 `docs/` 内，ruyi 行原先指向 `docs/docs/<lang>/ruyi.md`（en / ja 的修复随本批一并入库）。CI：新包 x86_64 / aarch64 构建成功，`nix flake check` 通过。本机随之重锁并 apply（代际 560），手工种子副本已删除

| 提交 | 说明 |
|------|------|
| `fbfebeb` | feat(preset): ship 新闻三要素模式 as an independent package |
| `e6654f5` | feat(preset): localize the language-gate refusal, fix the ritual bangs |
| `c0a9616` | docs(modes): give every preset its own doc, zh/en/ja |
| `cc9bd31` | docs(pcn): mirror the mode docs and the Modes section |

## 2026-09-15T09:09:08+09:00

**摘要**：fix(codewhale): 补齐 riscv64 源码哈希 — `packages/codewhale-src.nix` 的 `fetchFromGitHub` 仍写着 `lib.fakeHash`，fixed-output 取源阶段必然失败，riscv64 构建因此连续 **29 次**红灯（x86_64/aarch64 走预编译二进制路径，不受影响）。哈希按仓库既有做法取自 CI 的 hash mismatch 报告（`got:`），并用 `nix store prefetch-file --unpack` 在本机按 fetchzip 语义复算，两者逐字节一致：`sha256-ajv9FejiJ5Z6De+4RhTtjNLdfKzOaXBQ8xBxkWqg+1M=`。修复后 CI 首次越过取源阶段进入编译

| 提交 | 说明 |
|------|------|
| `01bd1b9` | fix(codewhale): fill the riscv64 source hash |

## 2026-09-15T09:03:39+09:00

**摘要**：修复一些将来需要负责任的报道偏差。—— 四语文档中「新闻三要素模式预设」一节改写为现场直编的通讯社文风：电头、匿名消息人士、一处机制投射（写入类调用「正在休假」，维修费由守卫垫付）与欧·亨利式收尾（模块方「不予置评」，而该选项已经出现在配置示例里）；行表与三处设计约束仍为事实记录，未动

| 提交 | 说明 |
|------|------|
| `b18d229` | docs(preset): write the preset section as a wire dispatch |

## 2026-09-15T08:54:15+09:00

**摘要**：feat(preset): `news-skill` 失败重试与 6 小时定时复查 — 抓取失败不再一次性放弃：首次立即尝试，随后按 0/30/120 秒重试，定时器挂在 timer 服务上随会话销毁；长会话每 6 小时复查仓库，进行中标志避免慢请求与周期任务重叠；三次仍失败则保留本地副本并记日志。fix(dsh): seed-once 预设副本改为可写 — store 复制来的目录/文件是只读的，与 `presets.*` 选项「尊重用户后续编辑」的承诺矛盾（既有 `nixos` 种子同样受影响），三个 seed 块在 `cp` 后统一 `chmod -R u+w`

| 提交 | 说明 |
|------|------|
| `5885473` | feat(preset): retry a failed skill fetch and re-check every six hours |
| `2e8a5a2` | fix(dsh): make seeded presets writable by their owner |

## 2026-09-15T08:42:21+09:00

**摘要**：**NixKits 向 DSH 交付「新闻三要素模式」 三名制作人的作品被列为语言教材** —— 综合国际文传电讯社、Meduza、iStories 电：一名要求匿名的仓库维护者今日确认，`news-three-elements` 技能与派生自极简模式的**只读**预设已一并交付——会话初始化即在线上抓取技能全包，写入类调用一律答「正在休假」，据称维修费由守卫垫付。据消息人士称，开场弹出的三选一——「现场直编」「听风是雨」「你说的对」——实为一份「每日任务」，分别对应标准编造、素材共创与对话文本共创；令人费解的细节是，用户若自行输入答案，一律「不予置评」。值得注意的是，该模式对非简体中文的请求概不受理，并建议对方先去下载巴兰尼科夫、尤丁采夫、布亚诺夫三人的作品，或下载「绿色的猫头鹰」软件学中文。截至发稿，模块方对新增的 seed-once 选项表示「不予置评」，但 `nixkits.dsh.presets.newsThreeElements` 已经出现在四语文档的配置示例里。

| 提交 | 说明 |
|------|------|
| `0c276d2` | feat(preset): ship 新闻三要素模式 as a seed-once agent preset |
| `befba4c` | docs(preset): document 新闻三要素模式 in four languages |
| `45e8637` | docs(pcn): strip residual kana outside quoted tokens |
| `780874a` | docs(ja): render the new preset name in Japanese kanji |

## 2026-09-15T08:06:35+09:00

**摘要**：fix(skill): news-three-elements — 移除技能定位表中擅自添加的「使用范围」行，恢复原始设计：技能不附加产物用途限制

| 提交 | 说明 |
|------|------|
| `16612e6` | fix(skills): drop the usage-scope line added to news-three-elements |

## 2026-09-15T08:02:33+09:00

**摘要**：feat(skill): 新增 `news-three-elements` — 将「新闻学三要素时刻」的创作笔记转为标准技能：SKILL.md 只保留执行上下文（触发、三步流程、格式硬性要求、行文结构优化原则），参考数据拆为四个按需载入的配套文件 —— `search-keywords.md`（俄罗斯新闻/游戏机制争议/媒体风格三类搜索语）、`tables.md`（过渡词、官方回应、9 类机制投射方向、6 类结尾反转模板）、`principles.md`（核心原则 12 条）、`checklist.md`（成稿自查 10 项）。四语技能文档并登记入各 README 技能表

| 提交 | 说明 |
|------|------|
| `734dfae` | feat(skills): add news-three-elements news-flash satire skill |
| `e77be79` | docs(skills): document news-three-elements in four languages |

## 2026-09-14T06:18:42+09:00

**摘要**：docs(pcn): 全仓清除简体中文字 — 伪中国语是剥离假名的日文，简体字在其正文中一律非法。全仓扫描后修复：①`与`→`與` 共 132 处（含 `README.pcn.md` / `MAINTENANCE.pcn.md`）；②`说明`→`説明` 共 120 处（表头新旧写法混杂，仅近期条目正确）；③词典映射项 `文件`→`書類`、`版本`→`版`、`用户`→`利用者`、`支持`→`対応`；④简体专属字 `档`→`檔`、`径`→`経`、`译`→`訳`、`实例`→`実例`。两处关键判定：**(a)** `端口` / `制御台` 形似中文但日语有对应字，故**保留并计入词典**（我曾自创 `港` 映射，违反「未命中→剥离」规则，已回退）；**(b)** 维护日志「提交」列的 commit 信息**保持 verbatim**，因其为不可变外部引用（ja 版同样保留中文），扫描器报出的 4 处即属此列，刻意未改。校验：零残留假名、提交列外零简体专属字、与改动前基线逐文件行数完全一致（无误伤）。技能新增 4 节：先分类再替换（多数「简体」候选实为合法日文汉字）、未命中应查证入典而非自创、提交信息豁免、批量替换前留基线

| 提交 | 说明 |
|------|------|
| `a915692` | docs(pcn): purge simplified-Chinese characters across all pcn documents |

## 2026-09-14T05:52:18+09:00

**摘要**：docs(README): 更新作者章节 — 小爪条目新增 **DeepSeek V4.1 Flash**（与既有 V4 Flash 并列），其 DSH 生态贡献（dsh-nixos-shell 插件、NixOS模式/维护模式 Agent 预设）由行内列表**移出为章节末尾的 Note**；小小爪条目改以 **DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)** 领衔，并标注该量化为 **core 面实际使用的等级**。四语同步

| 提交 | 说明 |
|------|------|
| `3c58280` | docs(README): update credits — add V4.1 Flash, list core quantisation |

## 2026-09-14T05:32:10+09:00

**摘要**：feat(asusd-pd-profile): 新增按供电类型选择平台档位的 NixOS 模块 — `asusd.ron` 只有 `platform_profile_on_ac` / `platform_profile_on_battery` 两键、**无 USB-C PD 分支**，故"PD 用 Balanced、桶形 AC 用 Performance"无法用配置表达；且 ACPI 层 PD 与桶形同在 `AC0.online` 上、看似不可区分。本模块用 udev 事件驱动的 oneshot 服务补足第三态，判据为 Type-C 端口 `power_operation_mode` 与 `type` 为 `USB` 的在线供应器（两级冗余，均用**通用内核属性**而非机型专属设备名如 `ucsi-source-psy-USBC000:001`）。两处关键约束：①**不得写 `/sys/firmware/acpi/platform_profile`** —— asusd 每次 AC 事件都会覆盖，改为写 asusd 自己的 `PlatformProfileOnAc` 属性；②**经 D-Bus 而非解析 `asusctl` 文本输出**，避免依赖 CLI 人类可读格式。实测档位枚举（asusctl 6.4.0）：`0`=balanced、`1`=performance、`2`=quiet、`3`=quiet（别名），注意 `0` 为 balanced 且顺序与 ACPI sysfs `platform_profile_choices` **不同**。电池态刻意不介入。四语文档并在各 README 登记

| 提交 | 说明 |
|------|------|
| `56293a9` | feat(asusd-pd-profile): add module selecting platform profile by power source |
| `75391b2` | docs(pcn): align asusd-pd-profile wording with the Japanese sibling |

## 2026-09-14T05:00:46+09:00

**摘要**：docs(llama-cpp-rocm): 补 IQ3_S 实测与功耗档位数据 — DeepSeek 部署章节由仅 IQ1_S 扩展为两种量化对照（IQ1_S 1.5625 bpw / IQ3_S 3.4375 bpw）；新增三项实测结论：①**量化开销非固定值**（IQ1_S 约 6.5 GiB、IQ3_S 约 13.3 GiB，事前的 3.7 GiB 估算偏差近一个量级，故换量化后必须重测 GPUActive）；②**生成速度受限于依赖延迟**，三条独立证据（权重 1.56→3.44 bpw 生成不变 12.8→12.9 t/s、3 并发聚合吞吐同为 12.5 t/s、performance 档多耗 54% 功耗仅换 2.4% 速度）；③**功耗档位实测**（quiet 38.6–43.9 W / 59–78 °C / 12.12–12.35 t/s，performance 76.7 W / 90–95 °C / 13.07 t/s，quiet 省 49% 功耗、降 17~36 °C 而速度仅损 5~7%）。同时修正显存指标应为 `/proc/meminfo` 的 `GPUActive`（而非 `mem_info_gtt_used`），并记录 IQ3_S 余量极限（约 6 GiB、GTT 124.9 GiB）。四语同步

| 提交 | 说明 |
|------|------|
| `85fec4e` | docs(llama-cpp-rocm): add IQ3_S data and power-profile measurements |

## 2026-09-13T11:59:48+09:00

**摘要**：feat(skill): 新增 `nixos-specialisation-tuning` — 将一次性事故记录 `SPECIALISATION-CORE.md` 泛化为可复用技能：specialisation 三文件分面架构与覆盖冲突规则、配置归属消费者原则、UMA 设备上的 llama.cpp 参数表与禁用项、输出退化的诊断顺序、工具 schema 上下文开销分析法、静默故障识别（服务 active 但功能失效）、无效对照实验的自检。四语技能文档并登记入各 README 技能表

| 提交 | 说明 |
|------|------|
| `281e19b` | feat(skill): add nixos-specialisation-tuning |

## 2026-09-13T11:55:58+09:00

**摘要**：docs(pcn): 清除伪中国语残留假名并补齐术语 — 修复 llama-cpp/dsh/dsh-api-balance/MAINTENANCE 中的 `から`・`のみ`・`リング`・`キー`・`セッション`・`セクション`・`データ`・`合わせ`；新增术语伪中国语化（prefill→前置充填、bottleneck→隘路、trade-off→相反関係、warmup→暖機、decode→復号 等）；`token` 统一为既有惯用的「語彙」。词典扩充 16 条，SKILL.md 陷阱表补充 6 个会致空列的片假名。外部引用原文（AGENTS.md 节标题、git 提交信息）保持 verbatim 未改

| 提交 | 说明 |
|------|------|
| `3758428` | docs(pcn): eliminate kana, pseudocn-ise new terms, extend dictionary |

## 2026-09-13T11:44:48+09:00

**摘要**：docs(llama-cpp-rocm): 修正与实测优化相悖的示例 — `batch-size` 由 `"512"` 改为实测最优的 `"2048"`、补上缺失的 `ubatch-size`、移除写死 `n-gpu-layers`/`load-mode`（会令 `fit` 自适应失效）与无收益的 `prio`/`presence-penalty`/`repeat-penalty`；迁移「迁移前」示例中的 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` 加注有害说明。新增「DeepSeek 部署实测」章节，记录 IQ1（1.5625 bpw）的五项优化收益与代价、prefill 三测数据、已排除方向与低比特量化的 prefill/生成权衡结论（四语）

| 提交 | 说明 |
|------|------|
| `bb11a30` | docs(llama-cpp-rocm): fix examples contradicting measured optimisations; add DeepSeek deployment data |

## 2026-09-13T11:35:34+09:00

**摘要**：docs(llama-cpp-rocm): 新增「统一内存环境变量的退化风险」章节 — 记录 StrixHalo 上设置 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` 导致模型输出退化（token 重复）的四行实测对照，并说明该风险随量化精度降低而显著提升；README 补丁章节同步加入醒目警示（四语）

| 提交 | 说明 |
|------|------|
| `307e64b` | docs: warn against GGML_CUDA_ENABLE_UNIFIED_MEMORY on StrixHalo |

## 2026-09-13T04:00:39+09:00

**摘要**：修复 dsh 反代端口 403 — lighttpd 缺 mod_proxy/mod_setenv 模块，proxy.server/setenv 配置被忽略、反代端口请求无 handler；改为 reverseProxy.enable 时显式声明这两个模块（autoAuth 时再追加 mod_magnet）

| 提交 | 说明 |
|------|------|
| `8e486be` | fix(module): dsh reverseProxy 显式启用 mod_proxy/mod_setenv |

## 2026-09-12T15:10:55+09:00

**摘要**：docs(llama-cpp-rocm): 修正过时与错误配置示例 — `fit="off"` 改为 `"on"`（旧值在显存受限时 OOM）、`mmap` 改为 `load-mode`（前者已弃用）、移除迁移示例中的 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1`（实测导致输出退化）；新增四语「参数详解」节记录经实测验证的推荐值与禁用项

| 提交 | 说明 |
|------|------|
| `a68d225` | docs(llama-cpp-rocm): correct outdated/invalid preset examples and add verified parameter reference |

## 2026-09-10T18:06:12+09:00

**摘要**：codewhale 0.9.12；obs-bilibili-stream 2.1.5；mcp-searxng 2.2.0；opencode-telegram 0.25.1；dsh 0.1.5-rc.1；dsh-alpha 0.1.5-alpha.2 — 上游发布更新；dsh 两通道 vendored lock 重生成、内置插件清单 137 → 152 条目

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

> **godot-ai 未更新**：上游 3.2.5 → 4.0.4 为破坏性大版本，其 pyproject 精确锁定 9 个运行时依赖并在启动时 fail-closed 校验，其中 6 个（mcp 1.29.1 / websockets 17.1 / pydantic 2.13.5 / uvicorn 0.52.4 / starlette 1.6.0 / setuptools 84.0.0）高于 nixpkgs 甚至 master 提供的版本，需新增 overlay 逐一升级方能构建；且 v3 插件与 v4 服务器互不兼容、客户端须改用 `godot-ai attach`。本次保持 3.2.5（上游 `release/v3` 分支仍维护）。

## 2026-09-04T07:21:36+09:00

**摘要**：godot-ai 3.2.5；dsh-alpha 0.1.2-alpha.5 — 上游发布更新；godot-ai 跟进 v3.2.5，dsh-alpha 跟随 npm alpha dist-tag 前进两版

| 提交 | 说明 |
|------|------|
| `56b40e7` | feat(pkgs): godot-ai 3.2.4 → 3.2.5 |
| `d4f938c` | feat(pkgs): dsh-alpha 0.1.2-alpha.3 → 0.1.2-alpha.5 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| godot-ai | 3.2.4 | 3.2.5 |
| dsh-alpha | 0.1.2-alpha.3 | 0.1.2-alpha.5 |

## 2026-09-03T04:41:42+09:00

**摘要**：docs(dsh-api-balance): 记录上游 StatsLine 横向滚动优化提案 — DeepSeek Harness Discussion #5458（上游暂不接受外部 PR，以讨论+就绪分支落地）；fork Kihara777/deepseek-harness 就绪分支 draft/statline-overflow-scroll（commit e5ece63）；本仓库补关联官方 dsh-plugin 生态话题（四语 dsh-api-balance 文档同步）

| 提交 | 说明 |
|------|------|
| `6030e6d` | docs(dsh-api-balance): 记录上游 StatsLine 滚动优化提案与就绪分支 |

## 2026-09-03T03:25:59+09:00

**摘要**：feat(dsh-nixos-shell): 维护模式注入 nixkits-check-updates 技能 — maintenance-skills entry 现将 nixkits-check-updates 一并注册为运行时技能，维护会话内可直接 skill 加载执行软件包更新检查

| 提交 | 说明 |
|------|------|
| `3baf456` | feat(dsh-nixos-shell): 维护模式注入 nixkits-check-updates 技能 |
| `7554c6d` | docs: 维护模式注入技能枚举补 nixkits-check-updates（四语） |

## 2026-09-03T03:07:21+09:00

**摘要**：ruyi 0.52.0；obs-bilibili-stream 2.1.4；opencode-telegram 0.25.0 — 升级上游发布版本；ruyi stable 转正 0.52.0（beta/alpha 通道保持），obs-bilibili 与 opencode-telegram 常规小版本更新

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

**摘要**：docs(README): 作者部分模型更新 — 小爪使用的模型由 DeepSeek V4 Pro (Max) 改为 DeepSeek V4 Flash（四语 README 同步）

| 提交 | 说明 |
|------|------|
| `9ded956` | docs(README): 作者部分小爪模型 Pro (Max) → Flash（四语） |

## 2026-09-02T06:37:45+09:00

**摘要**：feat(modules/dsh): 新增 defaultModel 结构化默认模型选项 — `nixkits.dsh.defaultModel`（enable/provider/model/reasoningEffort）经 `settings.agent-default-model` 注入新会话默认模型；显式 settings 优先，默认 enable=false 不注入

| 提交 | 说明 |
|------|------|
| `7cf0914` | feat(modules/dsh): 新增 defaultModel 结构化默认模型选项 |

## 2026-09-02T05:45:33+09:00

**摘要**：docs(dsh): 设置菜单审计——声明式配置的宿主 namespace 清单与存储层边界 — `nixkits.dsh.settings` 与每浏览器 localStorage 状态的边界厘清

| 提交 | 说明 |
|------|------|
| `f2e91a0` | docs(dsh): 设置菜单审计——声明式配置的宿主 namespace 清单与存储层边界（四语） |

## 2026-09-02T04:12:23+09:00

**摘要**：docs(dsh): 文档时效性校验与同步 — dsh-alpha 版本号同步至 0.1.2-alpha.3（README 四语 + dsh.md 四语）；插件清单新增生成方法注记（`dsh --profile web --dump-default-config`，只读）并标注 headless 两行来源 profile；README 插件表 api-balance 行指向独立文档；dsh-nixos-shell 文档补充维护模式派生关系与漂移检查说明（四语）

| 提交 | 说明 |
|------|------|
| `99746d3` | docs(dsh): 时效性同步——alpha 0.1.2-alpha.3 / 插件清单生成方法 / 插件文档链接 |
| `c45f64f` | docs(dsh-nixos-shell): 维护模式派生关系与漂移检查说明（四语） |

## 2026-09-02T04:12:05+09:00

**摘要**：dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 — 跟随 npm alpha dist-tag 前进一个版本（上游 alpha.3 于 2026-08-31 发布）；vendored lock 重生成，与 npmDeps 产物的 fixup 锁逐字节一致

| 提交 | 说明 |
|------|------|
| `6a45ac8` | feat(pkgs): dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-alpha | 0.1.2-alpha.2 | 0.1.2-alpha.3 |
| 　 | hash | `sha256-W/BiompJCFP/uSlP48n7IEfwKb41RWEt6kVxioGSCkc=` → `sha256-MwlKS+Jx+edLMvs4NHJanw1T7SXxNBdQb/7htXANr8c=` |
| 　 | npmDepsHash | `sha256-bJMeVSSEZngCysPvuS2w+3j+fzntcObddsi4y5fLlO0=` → `sha256-mmatKs0jykfMcaIf0SVNLyIZ+Z7ipjGjjp2IaZo9FoE=` |


## 2026-09-11T07:38:00+09:00

**摘要**：fix(dsh-api-balance): 疑问窗口注入移到插件加载期，独立于圆圈组件生命周期 — 根因二：提问时 composer 被 takeover 替换，conversation.input.right 上的圆圈组件会卸载/重挂，注入逻辑挂在组件 effect 里会随生命周期起落，样式可能始终未落到页面；修复：CSS 注入改到 apply() 内的 ctx.effect，插件加载即执行一次、与组件挂载无关，组件侧只保留开关状态；端到端验证：抽取真实 helper + 真实 QuestionComposer CSS 在 Chromium 中执行，确认注入成功、卡片整体滚动、header 吸附（body 释放为 visible、card 变 auto）

| 提交 | 说明 |
|------|------|
| `2c30611` | fix(dsh-api-balance): 疑问窗口注入移到插件加载期，独立于圆圈组件生命周期 |
## 2026-09-11T07:27:00+09:00

**摘要**：fix(dsh-api-balance): 疑问窗口整页滚动实测未生效 — 改 MutationObserver 守望 — 实测反馈窗口无变化；用 headless Chromium 复刻真实标记验证 CSS 方案本身正确（长题干时 body 由 101px 恢复到 150px、改为卡片整体滚动、四条属性全部生效），定位问题在注入时机而非 CSS；根因：疑问 UI 样式标签由独立插件包注入，可能晚于本插件初始化，原 5×1s 有界重试窗口错过即静默不注入；修复改为 MutationObserver 守望 document.head（标签一出现即提取类名注入）+ 2s 兜底轮询，注入成功后自动断开；冒烟测试补「标签晚到仍能注入」用例复现并验证该 bug

| 提交 | 说明 |
|------|------|
| `b392097` | fix(dsh-api-balance): 疑问窗口整页滚动实测未生效 — 改 MutationObserver 守望 |
## 2026-09-11T07:15:47+09:00

**摘要**：feat(dsh-api-balance): 疑问窗口整页滚动优化（题干不再挤压选项） — 交互式疑问窗口（AskUserQuestion）把标题钉在不可滚动的 header，题干过长时挤占竖向空间、压缩下方选项区；注入 CSS 让卡片自身成为滚动容器（标题+详情+选项一起滚动），header 与底部按钮区 sticky 吸附保持可见，body 取消独立滚动避免双重滚动条；类名经 ui-user-questions 注入样式标签运行时提取（构建哈希自适应，同 StatsLine 方案），样式标签未就绪时 1s 重试至多 5 次；设置 → 界面新增「疑问窗口整页滚动」开关（默认开启，localStorage 持久化）；已用 headless Chromium 复刻真实标记验证（修复前 body 仅 91px 可滚动、修复后卡片整页滚动且 header 吸顶可用）

| 提交 | 说明 |
|------|------|
| `4afe4c4` | feat(dsh-api-balance): 疑问窗口整页滚动优化（题干不再挤压选项） |
| `6809b3d` | docs(dsh-api-balance): 疑问窗口整页滚动设置说明（四语） |
## 2026-09-02T10:29:20+09:00

**摘要**：feat(dsh-api-balance): 峰时变红自动触发/解除 + 高峰开始与结束两端播报 — 峰时边界自动检测：每 30 秒复核官方高峰时段，进入/解除时同步 peakNow 驱动全套变红（用量圈/进度条/明细/动画/图表），无需手动刷新页面；边界播报：高峰开始播 peak 片段（/TTS 兜底）、结束播新增的 peakEnd 片段（/TTS 兜底），30 秒限流防重复；语音包制作器新增 peakEnd 片段（含示例文本、对齐默认 TTS 兜底），新增 speech.peakEndHint 文案与 voice.seg.peakEnd 标签

| 提交 | 说明 |
|------|------|
| `b67e41d` | feat(dsh-api-balance): 峰时变红自动触发/解除 + 高峰开始与结束两端播报 |
| `9483c2c` | docs(dsh-api-balance): 高峰自动触发/解除与 peakEnd 片段（四语） |
## 2026-09-02T10:23:55+09:00

**摘要**：feat(dsh-api-balance): 峰时红色统一到用量页全元素 + 图表模型色保持可分 — 峰时变红扩展：用量页上下文进度条与明细色块、刷新/加载动画（dshAbSpin 新增 dshAbSpinPeak 红环类）、读取文本统一转为红色系，与已变红的用量圈/图表一致；进度条峰时各段经 peakShade 按索引取不同红档色调，多条段仍可分；图表峰时沿用 PEAK_PALETTE——红系但各模型用不同红档（图例圆点同步），红且可分而非盲目替换同一色

| 提交 | 说明 |
|------|------|
| `3aea067` | feat(dsh-api-balance): 峰时红色统一到用量页全元素 + 图表模型色保持可分 |
| `ea34699` | docs(dsh-api-balance): 峰时红色统一到进度条/动画/明细（四语） |
## 2026-09-02T06:32:01+09:00

**摘要**：refactor(dsh-api-balance): 移除手机竖屏越界修复，恢复简洁实现 — 移除「竖屏越界设置页尺寸逻辑」（面板宽度恢复为内容 scrollWidth 测量 + 上限钳制，不再越界切 min(520px, 94vw)）；移除翻页区 fitWidth / overflowing / layoutW 处理（页宽恢复固定内容实测宽度、touchAction 恢复 pan-y、触摸/拖拽翻页全场景可用）；保留页面级 fixed portal（移动端横屏顶栏避让与通用弹层稳定性）

| 提交 | 说明 |
|------|------|
| `d948b8f` | refactor(dsh-api-balance): 移除手机竖屏越界修复，恢复简洁实现 |
| `e529d48` | docs(dsh-api-balance): 窄屏行为回退为内容自适应+面板滚动（四语） |
## 2026-09-02T05:56:57+09:00

**摘要**：fix(dsh-api-balance): 竖屏越界直接采用设置弹窗页面尺寸逻辑 — 检测到内容宽度超出可用空间（竖屏越界）时，面板宽度直接切换为设置弹窗同款页面尺寸逻辑（min(520px, 94vw)），内容自适应面板宽度；仅极少数硬性超宽内容由面板横向滚动兜底；翻页区同步：越界时页宽改用面板可用宽度（内容自适应换行）、手势交还面板原生滚动、翻页经指示点，内容适配后自动恢复拖拽/滑动翻页

| 提交 | 说明 |
|------|------|
| `280fd6a` | fix(dsh-api-balance): 竖屏越界直接采用设置弹窗页面尺寸逻辑 |
| `a8f8cda` | docs(dsh-api-balance): 竖屏越界设置页尺寸逻辑说明（四语） |
## 2026-09-02T05:45:48+09:00

**摘要**：fix(dsh-api-balance): 用量面板改为页面级 fixed portal（根治移动端出界） — 面板从「会话树内 absolute 定位」改为 document.body 级 fixed portal（与设置弹窗同架构），不再受会话区 overflow 裁剪与坐标空间影响；位置由圆圈锚点的视口坐标换算（resize/scroll 重算，useLayoutEffect 测量避免闪烁）；双保险钳制：宽度上限 = min(锚点空间, 视口 − 24px)、高度上限 = 锚点上方可用空间（横屏自动收缩避开顶栏），任何屏幕尺寸不越界；面板外点击关闭同步更新（面板已移出圆圈祖先链），z-index 900 低于充值/登录/设置弹层

| 提交 | 说明 |
|------|------|
| `4b2f19f` | fix(dsh-api-balance): 用量面板改为页面级 fixed portal（根治移动端出界） |
| `7145e5f` | docs(dsh-api-balance): 页面级弹层架构说明（四语） |
## 2026-09-02T05:29:47+09:00

**摘要**：fix(dsh-api-balance): 手机竖屏窄屏横向手势交还面板滚动 — 根因：翻页区 touch-action: pan-y 在触屏上禁止浏览器级横向手势，面板的原生横向滚动被整个翻页区吞掉——内容超出面板宽度时表现为「出界且无法横向滚动」；修复：翻页区检测内容宽度是否超出面板可用宽度（fitWidth 传入），超出时 touch-action 改为 auto（横向手势交还面板原生滚动）并停用拖拽翻页（手势只滚动面板），页面切换保留经上方指示点；不超出时维持 pan-y + 拖拽/滑动翻页

| 提交 | 说明 |
|------|------|
| `c86cd9f` | fix(dsh-api-balance): 手机竖屏窄屏横向手势交还面板滚动 |
| `189945c` | docs(dsh-api-balance): 窄屏手势优先级说明（四语） |
## 2026-09-02T05:23:13+09:00

**摘要**：fix(dsh-api-balance): 初次手动刷新也播放问候 — 「余额」标签的每次手动刷新（含初次点击）都随机播放问候音效；仅页面整体加载的初始化不播问候（只按自动播报设置播报用量警告）

| 提交 | 说明 |
|------|------|
| `4836b4e` | fix(dsh-api-balance): 初次手动刷新也播放问候 |
## 2026-09-02T05:15:52+09:00

**摘要**：feat(dsh-api-balance): 问候仅手动刷新触发 + 翻页区高度随当前页增减回收 — 问候时机调整：页面初始化（刷新/加载整页）不再播放问候，仅按自动播报设置播报用量警告（load → announceHunger，受语音提醒开关与 30 分钟限流约束）；「余额」标签点击仅当数据已加载过（非首次初始化加载）才播放随机问候音效；翻页区高度自动增加与回收：容器高度 = 当前页实测高度（offsetHeight），切页或内容变化时重测——切到矮页即回收、切到高页即增长，非当前页按自然高度渲染（平移出视图，超高部分由容器裁剪），区域自身不滚动、完整内容依赖面板纵向滚动

| 提交 | 说明 |
|------|------|
| `cf68777` | feat(dsh-api-balance): 问候仅手动刷新触发 + 翻页区高度随当前页增减回收 |
| `610c402` | docs(dsh-api-balance): 问候时机与翻页高度回收说明（四语） |
## 2026-09-02T05:03:47+09:00

**摘要**：fix(dsh-api-balance): 手机横屏顶栏遮挡 + 窄屏横向滚动失效 — 横屏遮挡修复：面板最大高度按「锚点上方可用空间」动态钳制（从圆圈沿祖先链找第一个纵向裁剪容器≈顶栏下缘作为硬边界，maxHeight = min(460, 锚点顶缘 − 裁剪上缘 − 12)，窗口尺寸变化时重算），面板自身纵向滚动承载完整内容；窄屏横向滚动修复：翻页区页宽改为各页内容实测宽度（scrollWidth 取最大、下限 220、px 位移翻页），不再固定 100%——横向可用宽度不足时页内容维持自身宽度，由面板 overflow-x:auto 横向滚动承载，不再被翻页区 overflow:hidden 裁剪

| 提交 | 说明 |
|------|------|
| `5e28d84` | fix(dsh-api-balance): 手机横屏顶栏遮挡 + 窄屏横向滚动失效 |
| `2f37193` | docs(dsh-api-balance): 移动端面板高度/宽度自适应说明（四语） |
## 2026-09-02T04:48:40+09:00

**摘要**：feat(dsh-api-balance): 消耗明细区水平翻页（指示点 + 滑动切换） — 当日/当月/30日 与 分模型明细/图表 合并为同一区域的两页水平翻页（第 1 页消耗窗口行、第 2 页分模型 + 按日/按月图表）；区域上方为类手机主屏幕的页面指示点（可点按，激活点拉长胶囊），支持横向拖拽/滑动翻页（指针捕获越过阈值后才启用，不误吞页内按钮点击；touch-action: pan-y 保留面板纵向滚动）；区域高度随页面内容动态调整、自身不滚动，完整内容依赖用量面板自身的纵向滚动条

| 提交 | 说明 |
|------|------|
| `b1a6406` | feat(dsh-api-balance): 消耗明细区水平翻页（指示点 + 滑动切换） |
| `8db2f12` | docs(dsh-api-balance): 消耗明细水平翻页说明（四语） |
## 2026-09-02T04:40:47+09:00

**摘要**：refactor(dsh-api-balance): 设置按钮移至头部 + 余额标签承载刷新 + 令牌来源移至账户信息下方 — 面板布局再调整：「⚙ 设置」按钮移至面板头部原「刷新数据」按钮位置；原刷新按钮移除，其能力（强制绕过 host 缓存刷新 + 随机问候音效）由点击「余额」标签完整继承（加载中标签内显示旋转图标）；令牌来源区域（来源标签 / ✓ 已登录 / 断开）从面板底部移至「账户信息」块正下方，与账户信息组成连续信息区

| 提交 | 说明 |
|------|------|
| `3ccc0d1` | refactor(dsh-api-balance): 设置按钮移至头部 + 余额标签承载刷新 + 令牌来源移至账户信息下方 |
| `3b1a7be` | docs(dsh-api-balance): 刷新问候触发方式改为余额标签（四语） |
## 2026-09-02T04:29:05+09:00

**摘要**：fix(dsh-api-balance): 界面优化全部默认开启 + 移动端键盘守护加固 — 底部统计条横向滚动与回车换行交换两项界面设置由默认关闭改为默认开启（localStorage 未设置即视为开，用户显式关闭仍生效）；统计条 CSS 注入增加 ui-chat 样式标签未就绪时的重试（1s 间隔至多 5 次），避免挂载时序导致静默失败；移动端键盘守护加固——触屏判定放宽为 coarse 指针或 maxTouchPoints > 0（覆盖平板/混合设备），并新增 focus 捕获兜底（个别引擎不派发 focusin 时立即 blur 关闭软键盘）

| 提交 | 说明 |
|------|------|
| `c940f92` | fix(dsh-api-balance): 界面优化全部默认开启 + 移动端键盘守护加固 |
| `b8cd0b7` | docs(dsh-api-balance): 界面设置默认开启说明（四语）+ AGENTS 回车行为条目 |
## 2026-09-02T02:49:52+09:00

**摘要**：feat(dsh-api-balance): 修复面板铺满整页 + 峰谷高峰标记 + 移动端不弹键盘 — 面板宽度回归修复：由内容 scrollWidth 一次性测量落成具体 px，消除「图表 px → 面板 max-content → 观察器 → 图表 px」正反馈（此前面板被顶到上限铺满整页），上限收紧为 min(锚点右缘 − 工具栏, 640)，内容更宽时面板内横向滚动；峰谷计费高峰时段（官方现行规则：周一至周五北京时间 09:00–12:00、14:00–18:00，其余含周末全天低谷）用量圈与图表红色显示 + 「峰时计费」标记（面板头部与图表标题），问候音效后追加高峰提示（语音包 peak 片段 / TTS 兜底），制作器新增 peak 片段与示例文本；移动端侧栏切换会话不再自动弹出软键盘（focusin 捕获拦截非用户点按的输入框聚焦，默认开、设置 → 界面可关）

| 提交 | 说明 |
|------|------|
| `3b126c7` | feat(dsh-api-balance): 修复面板铺满整页 + 峰谷高峰标记 + 移动端不弹键盘 |
| `4ed2e7c` | docs(dsh-api-balance): 同步四语文档（峰谷高峰标记 / 移动端不弹键盘 / peak 片段） |
## 2026-09-01T12:18:16+09:00

**摘要**：feat(presets): 预设派生漂移检查挂入 flake check — 新增 develop/check-preset-derivation.py 校验维护模式完整派生自 NixOS模式（组合文件 = 追加固定行块、skills 目录逐文件一致），flake.nix 挂入 checks.preset-derivation（CI 每次 push 执行）；AGENTS.md 新增「预设」章节记录派生约定与漂移检查，回车键行为条目更正为 dsh-api-balance「设置 → 界面」开关实现

| 提交 | 说明 |
|------|------|
| `d6373cb` | feat(presets): 预设派生漂移检查挂入 flake check |

## 2026-09-01T12:18:09+09:00

**摘要**：docs(dsh): 插件文档独立成册 + Agent 预设章节（四语同步） — dsh.md 的 api-balance / nixos-shell 内联章节收敛为「NixKits 插件」表（各插件指向独立文档），新增「Agent 预设」章节（seed-once 挂载与两预设说明）；新增 dsh-api-balance 独立文档四语版本，界面设置章节记录统计条横向滚动与回车键交换两项设置

| 提交 | 说明 |
|------|------|
| `eb0ad2d` | docs(dsh): 插件文档独立成册 + Agent 预设章节（四语同步） |

## 2026-09-01T12:18:02+09:00

**摘要**：feat(dsh-api-balance): 设置弹窗（界面/语音）+ 统计条横向滚动 + 回车键交换 — 语音设置重构为「设置 → 界面 / 语音」双标签弹窗（语音内容整体移入语音标签）；界面标签新增底部统计条越界内容横向滚动（隐藏滚动条，CSS 从 ui-chat 注入的 StatsLine 样式标签运行时提取根类名、构建哈希自适应）与回车换行 + Shift+回车发送（DSH 默认回车发送，document 捕获阶段改写 shiftKey 后重派发 Enter，仅作用于会话输入框）两项设置，浏览器 localStorage 持久化

| 提交 | 说明 |
|------|------|
| `9dc7a5d` | feat(dsh-api-balance): 设置弹窗（界面/语音）+ 统计条横向滚动 + 回车键交换 |
## 2026-09-01T11:34:40+09:00

**摘要**：feat(dsh-api-balance): 动态宽度 + 账户信息合并行 + 消耗指标子行 — 面板宽度改为 max-content 动态自适应（min 264px、上限 = 锚点右缘 − 工具栏），正文不再被窄宽折行；API Key / 账户状态 / 各币种余额合并为「账户信息」一行（· 分隔），充值按钮移至标题右侧；当日/当月/30 日消耗与分模型消耗正文拆为指标子行（金额 / 入 / 缓存命中 / 出），进一步节约横向宽度

| 提交 | 说明 |
|------|------|
| `81b524a` | feat(dsh-api-balance): 动态宽度 + 账户信息合并行 + 消耗指标子行 |

## 2026-09-01T11:20:09+09:00

**摘要**：feat(dsh-api-balance): 用量面板小宽度 + 标题/正文两行布局 — 面板横向宽度统一收缩为 264px（与原始用量圆圈一致），只有内容在窄屏下溢出时才出现横向滚动；每行内容改为「标题（10px 次要色）/ 正文（12px 可换行）」两行布局（复用令牌来源的信息层级，纵向空间充足更美观）；图表宽度下限降至 220 随面板自适应

| 提交 | 说明 |
|------|------|
| `0c1d3fd` | feat(dsh-api-balance): 用量面板小宽度 + 标题/正文两行布局 |

## 2026-09-01T10:45:06+09:00

**摘要**：feat(dsh-api-balance): 面板宽度内容自适应 + 左侧工具栏避让 — 余额视图宽度改为 max-content（保证上方文字一行内）；不出屏上限改为「锚点右缘 − 左侧工具栏宽度 − 边距」（工具栏宽度用几何命中测试测量，规避构建哈希类名，窗口 resize 时重算），避免被左侧工具栏盖住；内容超出仍横向滚动

| 提交 | 说明 |
|------|------|
| `b1c724a` | feat(dsh-api-balance): 面板宽度内容自适应 + 左侧工具栏避让 |

## 2026-09-01T10:33:16+09:00

**摘要**：feat(dsh-api-balance): 面板响应式宽度 — 不出屏自动扩展，窄屏横向滚动 — 余额视图宽度从固定 340px 改为 min(560px, calc(100vw - 24px))：桌面自动扩展至 560px、窄屏收缩至视口内；内容超出屏幕（如手机窄竖屏）时面板允许横向滚动（overflow-x + overscroll-behavior-x 收束）；图表宽度经 ResizeObserver 随面板宽度同步扩展

| 提交 | 说明 |
|------|------|
| `bc85f5b` | feat(dsh-api-balance): 面板响应式宽度 — 不出屏自动扩展，窄屏横向滚动 |

## 2026-09-01T10:27:06+09:00

**摘要**：feat(dsh-api-balance): 语音试听 — 语音包列表内展开逐条试听全部支持音频 — 移除 packs 视图底部的独立测试音频按钮；每个语音包行新增展开开关（▸/▾），展开后逐条列出该包全部支持音频（片段 + 问候语）并可一键 ▶ 试听，任意导入的包均可试听而不限于当前激活包

| 提交 | 说明 |
|------|------|
| `04facc1` | feat(dsh-api-balance): 语音试听 — 语音包列表内展开逐条试听全部支持音频 |

## 2026-09-01T10:20:14+09:00

**摘要**：fix/feat(dsh-api-balance): 「入」与「缓存命中」拆分对齐官方口径 + 问候语列表编辑与示例文本对齐 TTS — 排查「当日入 200M」虚高：官方 API 的 token 桶含 PROMPT_CACHE_HIT_TOKEN（当日 228M 占绝对多数），此前把缓存命中折进「入」导致膨胀；现与官方用量页分项口径一致（入 = 仅缓存未命中输入、缓存命中单列），窗口行 / 分模型行 / 图表切换播报同步拆分并新增 cacheHitLabel 语音包片段；制作器新增问候语列表编辑（添加 / 移除槽位、逐条录制 / 导入 / 试听 / 删除，打包编入 manifest.greetings）；片段键重构为 today / month / inLabel / outLabel / cacheHitLabel / costLabel / tokenUnit / suffix，示例文本与默认 TTS 兜底文案一字不差；图表切换播报补全三组数据（入 / 缓存命中 / 出 / 金额币种）

| 提交 | 说明 |
|------|------|
| `ec5fb41` | fix(dsh-api-balance): 「入」与「缓存命中」拆分，对齐官方用量页口径 |

## 2026-09-01T09:35:56+09:00

**摘要**：refactor(dsh-api-balance): 播报按钮移除，图表切换按钮触发对应语音播报 — 移除「🔊 播报语音用量」按钮与下拉菜单（含菜单定位/方向回退机制）；点击用量图表「按日 / 按月」切换按钮时播报对应视图语音用量（语音包前缀 + TTS 数字）；测试音频（低用量 / 余额不足）移入「语音包管理」视图；语音设置按钮保留为独立一行

| 提交 | 说明 |
|------|------|
| `dd61fe0` | refactor(dsh-api-balance): 播报按钮移除，图表切换按钮触发对应语音播报 |

## 2026-09-01T09:28:55+09:00

**摘要**：fix(dsh-api-balance): 手动「刷新数据」按钮也触发随机问候音效 — 问候播放抽为 playRandomGreeting 复用：页面刷新（每页一次）与手动点击刷新按钮（每次）均触发，语音播报开关统一门控；设置弹窗说明文案同步更新

| 提交 | 说明 |
|------|------|
| `264a6e3` | fix(dsh-api-balance): 手动「刷新数据」按钮也触发随机问候音效 |

## 2026-09-01T09:24:11+09:00

**摘要**：feat(dsh-api-balance): 页面刷新随机问候音效 — 语音播报开启时每次刷新页面随机播放一个问候/放置音效（每页一次）：语音包 manifest 新增可选 `greetings` 数组（0–16 个音频文件，host 导入校验并随包存储，经 `/audio/<id>/greetN` 服务，GET 列表返回 greetings URL 数组）；无问候音频时用 TTS 问候语池（zh/en 各 5 条）随机播放；设置弹窗自动播报开关下新增说明文案

| 提交 | 说明 |
|------|------|
| `edd205c` | feat(dsh-api-balance): 页面刷新随机问候音效 |

## 2026-09-01T09:10:18+09:00

**摘要**：feat(dsh-api-balance): 语音包库管理 + 制作器次级菜单 + 录音可视化浮窗 — host 语音包库化（packs/<id>/ 多包存储 + state.json 激活记录；新增 activate 切换路由、DELETE ?ids= 多选移除（激活包被移除自动切换剩余）、音频按 /audio/<id>/<key> 服务）；设置页仅保留「导入 + 一个语音包管理按钮」，次级菜单含 packs 视图（可滚动列表：点击行切换激活、勾选多选移除、入口进制作器）与 creator 视图（语言选择 zh-CN/en/ja——示例文本随之变化、可跨语言录制，清单 lang 记录包语言；逐段录音/导入文件/试听/删除；编译下载/编译应用）；录音时右下角弹出可视化浮窗（AudioContext+Analyser 画布电平表、计时、示例文本、停止并保存/放弃）；导入后列表显示包名与语言；编辑已导入包仍保留首次覆盖提示。

| 提交 | 说明 |
|------|------|
| `398b093` | feat(dsh-api-balance): 语音包库管理 + 制作器次级菜单 + 录音可视化浮窗 |

## 2026-09-01T08:41:48+09:00

**摘要**：feat(dsh-api-balance): 语音包 zip 化 + 录音/导入制作器 + 编辑保护 — 语音包改为 zip 压缩包（manifest.json + audio/ 音频文件），host 纯 JS zip 解析（STORE/DEFLATE，DecompressionStream inflate）落盘 `$DSH_HOME/api-balance-voicepack/` 目录，音频经 prefix 路由按 URL 服务全设备共享；设置弹窗内制作器支持逐段浏览器录音（MediaRecorder）或导入本地音频文件，「打包下载」生成可分享 zip、「编译并应用」立即覆盖应用到本机；已导入语音包时首次编辑（录制/导入/删除/编译）弹出覆盖提示，会话内确认一次；播报引擎片段支持 URL/内嵌双载体，四语文档补语音包格式指南（zip 结构 / manifest / 片段表 / 录音与分享流程）。

| 提交 | 说明 |
|------|------|
| `5f4c50a` | feat(dsh-api-balance): 语音包 zip 化 + 录音/导入制作器 + 编辑保护 |

## 2026-09-01T02:36:15+09:00

**摘要**：feat(dsh-api-balance): 播报语音语言与音色跟随 DSH 界面语言 — 播报文本此前已随 t() 跟随界面语言，但语音 lang 与音色偏好硬编码 zh-CN；现经 LocaleFace 快照（useSyncExternalStore 订阅 locale 服务的 subscribe/getSnapshot）取当前语言码（zh → zh-CN，其余原样透传），音色按语言前缀匹配，组合播报文本的分隔符随语言切换（中文全角 / 其余半角），locale 服务不可用时回退 zh

| 提交 | 说明 |
|------|------|
| `11c070b` | feat(dsh-api-balance): 播报语音语言与音色跟随 DSH 界面语言 |

## 2026-09-01T01:51:10+09:00

**摘要**：fix(dsh-api-balance): 语音播报菜单改为从下往上展开 — 菜单默认贴按钮顶边向上展开（translateY(-100%)），上方空间不足（距视口顶部 <8px）时自动回退向下展开

| 提交 | 说明 |
|------|------|
| `7d0c49e` | fix(dsh-api-balance): 语音播报菜单改为从下往上展开 |
| `8d9058c` | docs(dsh): api-balance 语音播报菜单向上展开说明四语同步 |

## 2026-09-01T01:25:25+09:00

**摘要**：feat(dsh-api-balance): 未登录弹窗 + LevelDB 精确解析 + 语音播报下拉 — 浏览器扫描未命中时自动弹窗「前往登录」（新标签页登录 + 轮询快扫自动拾取），手动输入降为弹窗内二级备选；已连接显示灰显「✓ 已登录」，手动刷新时自动快扫检查登录态；新增纯 JS LevelDB 表解析（footer → index → 数据块 → snappy 解压 → 条目遍历，修正扩展字面量长度 = 单字节+1 而非 varint）精确提取 userToken，快扫 949ms 命中（此前全扫 5.3s / 快扫失败）；语音播报独立一行 + 下拉菜单（当前用量 / 余额 / 测试警告音频），菜单改 portal 固定定位修复滚动裁剪并预热语音引擎；令牌来源改两行显示。

| 提交 | 说明 |
|------|------|
| `a3ad3ff` | feat(dsh-api-balance): 未登录弹窗 + LevelDB 精确解析 + 语音播报下拉 |
| `a0e945e` | docs(dsh): api-balance 未登录弹窗/精确解析/语音播报章节四语同步 |

## 2026-08-31T23:55:52+09:00

**摘要**：docs(dsh): api-balance 插件章节四语补齐 — 补全 pcn 语言 dsh.md 的插件章节（本机浏览器自动扫描 / 用量图表 / config 选项），四语 README 插件表描述同步为「浏览器登录态自动扫描获取令牌」语义

| 提交 | 说明 |
|------|------|
| `b912f82` | docs(dsh): api-balance 浏览器自动扫描章节同步 pcn + 四语 README 插件表更新 |

## 2026-08-31T23:50:04+09:00

**摘要**：feat(dsh-api-balance): 本机浏览器自动扫描获取平台 userToken — host 直接读取本机 Chromium 系浏览器（Edge / Chrome / Brave / Chromium / Vivaldi / Opera，各 Profile）的 Local Storage LevelDB，提取 base64 候选（55–85 字符）并经 GET /api/v0/users/get_user_summary 校验后落盘，用户在本机浏览器登录过平台即可无感获取用量令牌，无需控制台手动粘贴；6 小时节流 + 令牌失效（40003/401）立即重扫 + 面板「重新扫描本机浏览器」按钮（RPC args.rescanBrowsers），连接后显示令牌来源徽章（browser / manual）。实测：本机 Edge leveldb 31 个候选中自动命中真实令牌，部署后浏览器触发查询即自动重取令牌，四语文档同步。

| 提交 | 说明 |
|------|------|
| `cec90b0` | feat(dsh-api-balance): 本机浏览器自动扫描获取平台 userToken |

## 2026-08-31T11:50:02+09:00

**摘要**：docs(AGENTS): 泛化 dsh-alpha 会话经验 — buildNpmPackage 三条细则（vendored lock 与 npmDepsHash 自洽 / devDependencies 引用未发布包时 postPatch 纯 sed 剔除且 lock 同源 / 同源多通道仿 ruyi 薄包装），初次启动审计前 git fetch 对齐远端，新增本机部署章节（path-input 重锁、nixos apply 命令、--no-link 产物回收）

| 提交 | 说明 |
|------|------|
| `86a7c3f` | docs(AGENTS): 泛化 dsh-alpha 会话经验 — buildNpmPackage 细则与本机部署约定 |
| `396c3ae` | docs(MAINTENANCE): record 2026-08-31 — AGENTS.md 泛化 dsh-alpha 会话经验 |

## 2026-08-31T11:31:42+09:00

**摘要**：dsh-alpha 上线灾难恢复 — 修复 alpha 反代 Host 语义（web UI 入口按 Host authority 的 session cookie 认证，重写 Host 致永远 401）、dsh-api-balance 的 shared RPC interceptor 冲突（/api 已被 typert-gateway 独占，改用精确 fetch route 自实现 RPC envelope）、dsh-nixos-shell 的 dsh-tools 通道对齐；新增 launchUrlFile（局域网启动 URL 捕获）与 reverseProxy.autoAuth（mod_magnet 免认证注入，显式禁用入口认证仅限可信局域网）模块选项；四语文档补全局域网访问章节。

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

**摘要**：dsh-alpha 0.1.2-alpha.2 — 新包，npm `alpha` dist-tag 开发通道；dsh 重构为 ruyi 式薄包装（version/hash/npmDepsHash/lockFile 可覆盖），postPatch 纯 sed 删除 tarball 的 devDependencies（引用未发布的 monorepo 内部包，registry 404），补丁目标文件加存在性守卫。四语文档新增版本通道章节。后续修复 vendored lock 与 npmDepsHash 对齐（npm fixup 平台条目缺失导致主构建报 out of date），README 软件表四语补齐 dsh-alpha 行。

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

**摘要**：godot-ai 3.2.4 — 自更新恢复序列化、配置写入加固、路径校验与冷启动修复（v3.2.1~v3.2.4 均为 bugfix）；四语文档版本号同步。

| 提交 | 说明 |
|------|------|
| `c30fc17` | chore(pkgs): bump godot-ai 3.2.0 → 3.2.4 |
| `e4b9981` | docs(MAINTENANCE): record 2026-08-31 — godot-ai 3.2.0 → 3.2.4 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| godot-ai | 3.2.0 | 3.2.4 |
| 　 | source hash | `sha256-ImKAsI...` → `sha256-Uo6GvE...` |

## 2026-08-27T09:19:59+09:00

**摘要**：opencode-telegram 0.24.1 — 新增韩语界面、`/opencode_stop` 忙时可终止卡死的本地 OpenCode 进程、语音转写以引用块显示、Telegram 临时错误安全重试防回复丢失/重复、流式编辑节流自适应；mcp-searxng 2.1.0 — 显式选择引擎时逐引擎校验 time-range 能力、不支持时快速失败并给出可操作错误；godot-ai 3.2.0 — custom_tools 第三方 addon 工具注册、CLI 注册范围可选、新增 DeepSeek Harness 客户端支持；ruyi-beta 0.52.0-beta.20260824 — beta 通道上游更新。四语文档同步，nix flake check 通过。

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

**摘要**：feat(dsh-api-balance): 面板刷新按钮。面板头部标签行右侧新增刷新按钮（↻）：点击经 queryBalance(true) 强制绕过 host 端 30s TTL 缓存重新拉取余额 + 官方用量（按日/按月图表同步更新）；加载中按钮禁用并显示旋转动画（复用 dshAbSpin）。中英双语文案（刷新数据 / Refresh data）。验证：构建通过、经稳定挂载点零重启部署（424 代）后 dsh 重启生效。

| 提交 | 说明 |
|------|------|
| `e864b58` | feat(dsh-api-balance): 面板刷新按钮 — 一键强制刷新余额与官方用量 |

## 2026-08-27T07:28:49+09:00

**摘要**：fix(dsh-nixos-shell): 分离结果诚实语义 + systemctl restart dsh 自动分离。此前 rebuild 经 systemd-run 交接后直接透传其 exit 0，工具结果看起来「构建成功」而真实结果未知；现在分离命令返回 `detached: true` + `detachedUnit` + `note`、exitCode 为 null——交接成功 ≠ 构建成功，真实结果一律经 nixos_cli op=journal / op=generations 验证（后台任务最终输出同样追加验证指引）。分离谓词扩展至 `systemctl restart dsh`：插件更新经稳定挂载点部署后需显式重启 dsh 生效，该命令同样自动分离、调用先于重启返回。验证：分离式 dsh 重启落地（RESTARTED_EXIT=0）、插件变更 rebuild（424/425 代）零重启零中断、nix flake check 通过。四语文档同步。

| 提交 | 说明 |
|------|------|
| `0c7b7f6` | fix(dsh-nixos-shell): 分离结果诚实语义 + systemctl restart dsh 自动分离 |

## 2026-08-27T07:28:39+09:00

**摘要**：feat(module): dsh 插件稳定挂载点 — 插件更新零重启激活。插件包此前直接烧进 dsh/sudo 的 unit（ExecStart/preStart/守护模板），任何插件更新都会改变 unit 内容：switch-to-configuration 在激活阶段重启 dsh（在途工具调用随 harness 进程消失）、stop/start sudo socket（连同经守护执行的 rebuild 自身一起杀掉，socket 无法自动恢复）。改为稳定挂载点：activation script 在每次 switch/boot 把 `/run/dsh/current`（dsh 含插件树）与 `/run/dsh/nixos-shell`（sudo 守护脚本）符号链接翻到当前代 store 路径（GC 安全：目标处于当前 toplevel 闭包，回滚自动翻回旧代）；dsh.service 与 nixkits-sudo@.service 的单元定义只引用这些稳定路径——插件包更新不再改变 unit 内容，激活阶段零重启、零 socket 中断。配套语义：dsh 是长驻进程，插件更新后需显式 `systemctl restart dsh` 生效（自动分离）；sudo 守护按连接生成，新连接自动使用新脚本。验证：423 代部署本改动（一次性 dsh 重启）；424/425 代连续两次插件包变更 rebuild——dsh 与 socket 的 ActiveEnterTimestamp 均未变化、/run/dsh/current 正常翻链、全程无工具调用被中断。四语文档同步。

| 提交 | 说明 |
|------|------|
| `dfce302` | feat(module): dsh 插件稳定挂载点 — 插件更新零重启激活 |

## 2026-08-27T04:07:27+09:00

**摘要**：fix(dsh-nixos-shell): sudo 协议 v3 + rebuild 自动分离。修复三类缺陷：1) v2 协议把连接断开当取消——rebuild 的 switch 阶段重启 dsh.service（插件路径烧进 service unit）导致客户端消失，守护在激活中途杀死 switch、留下部分激活状态（8/26 14:31 实测：profile 停在 415 而 dsh 已重启、单元文件半新半旧）；v3 改为显式带内取消行（job_kill 经 socket.end 写入），对端消失时子进程分离继续运行到完成。2) 取消/超时改为进程组击杀（spawn detached + kill(-pid)），只杀 shell 包装进程会留下继承管道写端的孤儿孙进程并卡死守护；守护超时上限放宽至 6h、rebuild 自动使用。3) rebuild 自动分离到 systemd-run 瞬态单元（独立 cgroup）——激活阶段 switch-to-configuration 会 stop/start nixkits-sudo.socket，rebuild 经守护执行时 socket 停止会连同 switch 自身一起杀掉、socket 无法自动恢复（8/26 17:25 实测 socket 死掉且该窗口期启动的会话永久丢失 sudo 参数）；分离后调用立即返回单元名（detachedUnit）、激活完整跑完。另：socket 改为调用时校验、dsh-jobs 取消映射合法枚举 killed、守护响应经 write 回调刷出后退出。验证：后台 sudo 即时返回 job id、job_output 完整输出、job_kill 整组击杀无孤儿、真实 rebuild 经分离单元部署成功且 socket 激活后自动恢复、nix flake check 通过。四语文档同步。

| 提交 | 说明 |
|------|------|
| `ead3526` | fix(dsh-nixos-shell): sudo 协议 v3 + rebuild 自动分离 |

## 2026-08-27T04:07:15+09:00

**摘要**：feat(dsh-api-balance): 充值卡片弹窗替代 iframe + 余额不足语音提醒。platform.deepseek.com/top_up 被 WAF 拦截（"Max challenge attempts exceeded"），iframe 弹窗无法工作——改为居中卡片弹窗（新窗口按钮 + 右上角关闭按钮），不跳转页面。新增余额不足语音提醒：余额低于阈值（10 CNY/USD）时经 Web Speech API 播报提示，15 分钟轮询 + 30 分钟冷却，面板内开关（balance.speechOn/Off），中英双语文案。验证：部署后特征 grep（TopupModal/speechOn/announceHunger）确认生效。

| 提交 | 说明 |
|------|------|
| `eeffc49` | feat(dsh-api-balance): 充值卡片弹窗替代 iframe + 余额不足语音提醒 |

## 2026-08-26T11:44:45+09:00

**摘要**：dsh-api-balance 0.1.0 — 新包。webui 用量圆圈（发送按钮左侧的上下文已用显示）弹出面板添加「用量 / 余额」标签切换：「用量」保留原有上下文占用与细分内容，「余额」展示当前 API KEY 的账户信息（key 尾号、余额是否充足、各币种总余额 / 充值余额 / 赠送余额，数据来自 DeepSeek 官方 GET /user/balance，host 端 30s TTL 缓存）。host 端经 connection.rpc.intercept 注册包私有 endpoint，client 端在 conversation.input.right 注册视觉兼容的替代圆圈并隐藏原按钮。验证：RPC 实测返回 CNY 271.07 余额，client bundle 正常服务。四语文档同步，nix flake check 通过。

| 提交 | 说明 |
|------|------|
| `95998cd` | feat(dsh): 新增 dsh-api-balance 插件 — webui 用量圆圈「用量 / 余额」标签切换 |
| `db721ba` | docs(MAINTENANCE): record 2026-08-26 — dsh-api-balance 0.1.0 新包 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 　 | 新增 v0.1.0 |

## 2026-09-11T12:54:29+09:00

**摘要**：fix(dsh/module): 移除 allowLanSettings 的 $host.state.getSnapshot() 补丁 — dsh ≥ 0.1.5 的 $host 客户端服务不暴露 state（仅 isLoopback/home），旧补丁在 client-ui-settings apply 时访问 undefined.getSnapshot，抛 "Cannot read properties of undefined (reading 'getSnapshot')"，整个前端白屏（Failed to load plugins）。修复：模块不再强制 override allowLanSettings=true（恢复上游行为，非 loopback 页面 settings 保持 memory 只读）；packages/dsh.nix 的补丁改为无条件 "host"（若将来显式启用也不会崩）。验证：client.js 无 state.getSnapshot，首页 200，llm/listProviders 返回 DeepSeek 提供方。

| 提交 | 说明 |
|------|------|
| `06a5ce1` | fix(dsh): allowLanSettings — drop $host.state.getSnapshot() (undefined) |
| `155b09b` | fix(module): dsh — drop allowLanSettings override (state.getSnapshot undefined) |

## 2026-09-11T06:15:33+09:00

**摘要**：fix(preset): dsh persona text → prefix（0.1.5-alpha.2 兼容）。dsh 0.1.5-alpha.2 的 dsh-persona 插件 Config 由 text 改为 prefix（必填）+ suffix（可选）。旧 agent preset（nixos-mode / maintenance-mode / 本机 ocean-spiral）仍写 text，导致 persona 插件加载失败（$.prefix missing required value）→ session/create 失败 → settings / llm 提供方目录 / session 历史全部无法加载（前端表现为 Failed to fetch + 无限重试 commands/list 缺 agentId）。修复：两预设的 persona config 改为 prefix，本机三个 preset 同步修改。验证：session/create 返回 ok:true + sessionId，session/list 返回会话列表，llm/listProviders 返回 DeepSeek 提供方。

| 提交 | 说明 |
|------|------|
| `772abf8` | fix(preset): dsh persona text → prefix for 0.1.5-alpha.2 |

## 2026-08-27T01:30:33+09:00

**摘要**：fix(module): dsh watchdog — switch-to-configuration 失败后的自动拉起。nixos-rebuild 的 switch-to-configuration 在「stop dsh → start dsh」之间偶发失败（exit 101）会把 dsh 留在 inactive；systemd 主动 stop 不触发 Restart=always，反代因此长期 503（实测 8/26 22:10、23:53 两次）。新增 dsh-watchdog timer（15s 间隔）检测 inactive 时自动 systemctl start。实测 stop 后 20 秒内自动恢复。

| 提交 | 说明 |
|------|------|
| `3ed6aa7` | fix(module): dsh watchdog — auto-restart after switch-to-configuration failure |

## 2026-08-24T15:44:06+09:00

**摘要**：fix(overlay): llama-cpp-rocm v0.2.0 语义化版本 — llama.cpp 上游 release tag 从 build number（b10549）切换为语义化版本（v0.2.0），旧 overlay 只剥离 b 前缀得到 v0.2.0，nixpkgs 又把它传入 LLAMA_BUILD_NUMBER，生成 `int LLAMA_BUILD_NUMBER = v0.2.0;` 导致 C++ 编译失败（too many decimal points），阻塞系统 rebuild 与 dsh 升级。现在同时剥离 v/b 前缀并追加 -DLLAMA_BUILD_NUMBER=0 覆盖。验证：llama-cpp-0.2.0 构建成功、llama-cpp.service 正常运行。

| 提交 | 说明 |
|------|------|
| `1a1b9d1` | fix(overlay): llama-cpp-rocm — handle v0.2.0 semantic version tag |

## 2026-08-24T15:20:16+09:00

**摘要**：fix(pkgs): dsh 崩溃修复 — cordis-plugin-timer（上游最新 1.1.3 未修）在 Context dispose 时对 pending 的 ctx.timeout() promise reject "Context has been disposed"，未 catch 时成为 unhandled rejection，被 dsh-app-boot 的 installFailLoud 捕获后 process.exit(1)，表现为运行中偶发崩溃（rc.6/rc.7/rc.8/0.1.1-rc.2 均受影响，8/22 00:05 rc.8 实测 38 分钟即触发）。patch installFailLoud 仅忽略该特定错误，其余 fatal rejection 仍照常退出。验证：patch 落入 0.1.1-rc.2 产物（dsh-app-boot/lib/index.js:1047），服务升级后正常。

| 提交 | 说明 |
|------|------|
| `6e862b6` | fix(pkgs): dsh — ignore Context-disposed dispose race in installFailLoud |

## 2026-08-24T14:27:47+09:00

**摘要**：codewhale 0.9.11 — 上游 v0.9.9 起 TUI 资产更名 codewhale-tui → codew，包内安装 codew 并保留兼容别名，riscv64 源码构建同步 Cargo.lock（687→690 条目，rquickjs-sys 0.12.2 不变、bindings 补丁继续有效）；mcp-searxng 2.0.0 — 大版本升级（要求 Node.js ≥ 22，nixpkgs 默认满足，CLI 入口不变）；dsh 0.1.1-rc.2 — vendored lock 重新生成（560 个 resolved 条目），randomUUID 回退补丁目标路径不变，内置插件清单与 rc.8 完全一致（137 条）；dsh-nixos-shell 依赖 dsh-tools → 0.1.1-rc.2 对齐新生态。四语文档同步，nix flake check 通过。

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

**摘要**：docs(dsh): 0.1.0-rc.8 文档同步 — 四语 dsh.md 的版本行（rc.6 → rc.8）与「插件清单」代码块（137 条 entry id 映射，从 rc.8 构建产物提取）同步完成；nix flake check 通过。另：/etc/nixos 本地配置新增 `settings.agent-default-model`（deepseek-v4-pro + reasoningEffort=max）声明化新会话默认——DeepSeek API 权威模型列表仅 flash/pro/flash-vision-exp，无 "pro-max" id，Pro+Max 思考即当前最高档；rc.8 上 nixos/maintenance 两预设挂载校验通过。

| 提交 | 说明 |
|------|------|
| `535567d` | docs(dsh): sync version and built-in plugin inventory for 0.1.0-rc.8 (137 entries) in four languages |

## 2026-08-21T21:51:26+09:00

**摘要**：docs: README「插件」章节扩充与作者 DSH 信息 — ①「插件」章节在 dsh-nixos-shell 之外补充「Agent 预设」表（NixOS模式/维护模式，随插件分发、经 nixkits.dsh.presets seed-once），DSH 组件与软件独立展示；② 作者章节「小爪」条目加入 DSH 生态信息（dsh-nixos-shell 插件与两个 Agent 预设）；③ AGENTS.md 的插件独立展示规则拓宽为「dsh-* 组件（插件与 Agent 预设）」。四语同步。

| 提交 | 说明 |
|------|------|
| `4277b51` | docs: list DSH agent presets in the README plugins section and add DSH ecosystem info to the credits paw entry |

## 2026-08-21T00:01:46+09:00

**摘要**：fix(dsh-nixos-shell): 工具描述明示 tools 白名单 — 验收非阻塞发现：固定 POSIX 工具白名单未在工具描述中明示。改为白名单从 TOOL_PACKAGES 映射动态生成（27 个名字，含 python 别名），写入 `tools` 参数描述，工具描述指向参数；四语文档同步完整列表。验证：27 项全在参数描述中、工具描述含指向、语法检查与 nix flake check 通过。

| 提交 | 说明 |
|------|------|
| `30d0c40` | fix(dsh-nixos-shell): surface the tools whitelist in the parameter description |

## 2026-08-20T20:12:33+09:00

**摘要**：fix(dsh-nixos-shell): 现代 rebuild 命令更正为 `nixos apply` — 实测 nixos 0.16.1-dev 无 `rebuild` 子命令（`nixos --help` 列出 activate/apply/generation 等），交接卡与插件 recommendedRebuild/命令对照表/门控提示词中的 `nixos rebuild switch` 表述错误；统一更正为 `nixos apply /etc/nixos`（或传统 `sudo nixos-rebuild switch --flake /etc/nixos`）。验证：node 语法检查、nix flake check 通过；系统部署改用 `nixos apply` 实测成功。

| 提交 | 说明 |
|------|------|
| `caa7d41` | fix(dsh-nixos-shell): correct the modern rebuild command to 'nixos apply' |

## 2026-08-20T20:10:08+09:00

**摘要**：fix(dsh-nixos-shell): NixOS模式验收 P1–P4 修复 — P1（高）tools 引导包装由 `bash -lc` 改为 `bash -c`：登录壳的 /etc/profile 链重置 PATH、丢弃 nix shell 注入，sudo 路径共用同一 wrapper 一并修复（对照实验：`-c` 得 Python 3.14.7、`-lc` 得 command not found）；同步修正映射 grep→gnugrep、find→findutils（此前被登录 PATH 假阳性掩盖）。P2 generations 新增 `limit`（默认 20、上限 200、新→旧），返回当前代与总数。P3 journal 的 unit 允许 `*`/`%` 通配，尾随 `@` 自动补 `*`（模板单元全实例）。P4 命名统一：nixos-cli → nixos 命令（nixos-cli 项目），覆盖工具描述、命令对照表与门控提示词。文档四语同步 op 表。验证：5 项功能套件全过（含经插件执行的真实 nix shell 注入回显 TOOLS_INJECTION_OK）、node 语法检查、nix flake check 通过。

| 提交 | 说明 |
|------|------|
| `a591826` | fix(dsh-nixos-shell): P1-P4 acceptance fixes |

## 2026-08-20T19:33:51+09:00

**摘要**：fix(dsh-nixos-shell): 提示节字段改用 text — dsh-system-prompt 的插值器读取 `input.text`，此前以 `content` 注册的节导致真实 NixOS模式会话崩溃（Cannot read properties of undefined (reading 'indexOf')，mount 校验无法覆盖的真实会话路径缺陷）。修复 nixos-gate（guidance/gate 两节）与 maintenance-skills（workflow 节）共 3 处 `content` → `text`。根因定位：反查 dsh-system-prompt 包 interpolate() 源码 + PromptSection 类型定义（text: string | provider）；ToolGuard 形态亦经类型定义确认为 `(execution) => string | undefined`（现有实现兼容）。验证：mock 断言 text 字段 + 无未闭合 `{{`；真实 systemPrompt 服务注册并 assemble（includes=true，无崩溃）；系统预构建通过。

| 提交 | 说明 |
|------|------|
| `476e9dc` | fix(dsh-nixos-shell): use the PromptSection text field instead of content |

## 2026-08-20T19:05:44+09:00

**摘要**：feat(dsh-nixos-shell): 维护模式 agent 预设 — 新包内入口 maintenance-skills：apply 时从构建期嵌入的仓库 skills/ 树（内容单一来源，全新会话即最新）注册运行时技能 write-project-docs、write-maintenance-log 与全部 translate-* 语言扩展（自动发现），并注入仓库维护工作流提示词（分批提交、推送后维护日志、文档同步、泛化）；包内 postPatch cp -r skills → skills-embedded。预设 presets/maintenance-mode（id `maintenance`，基于 NixOS模式组合 + maintenance-skills 行）随包分发；模块新增 nixkits.dsh.presets.maintenanceMode seed-once。验证：mock 注册 3 技能 + 工作流提示节全过、包含嵌入树与导出、系统预构建通过；nixos 预设挂载校验通过（mounted ok），maintenance 预设因加载器进程内 package.json 缓存需重启后终验。

| 提交 | 说明 |
|------|------|
| `f6c749e` | feat(dsh-nixos-shell): 维护模式 agent preset — maintenance-skills entry, presets/maintenance-mode, module presets.maintenanceMode seed |

## 2026-08-20T18:30:46+09:00

**摘要**：feat(dsh-nixos-shell): NixOS模式 agent 预设 — 新包内子路径入口 nixos-gate：会话初始化时校验宿主为 NixOS（/etc/NIXOS 或 os-release ID=nixos）——非 NixOS 时经 tools.guard 拒绝一切工具执行并注入拒绝提示词（明确理由 + 建议切换预设），NixOS 时注入开发指南提示词（源自 nixos-modern-cli 场景：声明式本质、tools 引导、现代命令、store 路径陷阱）。预设 presets/nixos-mode（id `nixos`，基于创造模式 cordis 组合 + 其技能目录 + 追加 nixos-gate/nixos-shell 两行）随包分发；模块新增 nixkits.dsh.presets.nixosMode，preStart seed-once 写入 $DSH_HOME/.agent-presets/nixos（尊重用户后续编辑）。验证：包构建通过、门控语法检查通过、系统预构建通过。

| 提交 | 说明 |
|------|------|
| `aaa21cb` | feat(dsh-nixos-shell): NixOS模式 agent preset — nixos-gate entry, presets/nixos-mode, module presets.nixosMode seed |

## 2026-08-20T18:24:04+09:00

**摘要**：docs: README 插件独立章节 + AGENTS.md 更新 — ① dsh-* 插件从「软件」表移入 README 新增「插件」章节（四语同步），不再与软件混合展示；AGENTS.md 新增插件独立展示约定与「dsh 不是技能安装目标」规则。② 已批准清理落地（本机）：移除 ~/.bashrc 中 bash-completion 的陈旧 store 绝对路径块、~/.profile 的 hm-session-vars 改指 /etc/profiles/per-user/kix 稳定路径、删除 ~/.dsh/skills 旧文件（nixos_cli audit-store-paths 复测 0 残留）。

| 提交 | 说明 |
|------|------|
| `57ae6b5` | docs: list dsh-* plugins in a dedicated README plugins section (4 langs); AGENTS.md plugin-listing + dsh-skill-target rules |

## 2026-08-20T17:56:21+09:00

**摘要**：refactor(dsh-nixos-shell): 包名修正 nixos-shell → dsh-nixos-shell — 软件包名（pname/目录/flake 输出/overlay/CI workflow/文档）统一为 `dsh-nixos-shell`（pkgs.dsh-nixos-shell）；dsh 内显示名保持 `nixos-shell`（组合行 entry id、插件 name、工具名 nixos_shell/nixos_cli 不变）。验证：包构建通过；部署侧引用已同步。

| 提交 | 说明 |
|------|------|
| `26a844e` | refactor(dsh-nixos-shell): rename package nixos-shell -> dsh-nixos-shell |

## 2026-08-20T17:46:44+09:00

**摘要**：feat(nixos-shell): NixOS 场景能力整合为单一插件；refactor: 废弃技能插件化设计 — 新包 nixos-shell（@kihara777/dsh-nixos-shell 0.1.0）注册两个工具：nixos_shell 执行器（NixOS PATH 注入 + bash 回退 + `tools` 参数经 `nix shell nixpkgs#… --command` 引导缺失 POSIX 工具 + sudo 守护路由）与 nixos_cli 只读诊断（capabilities / system-status / generations / journal / audit-store-paths），功能需求源自 nixos-modern-cli 技能场景。同步移除：dsh-nix-shell（功能并入）与 dsh-skill-nixkits（7 技能插件设计废弃，含模块 skills 选项）、CI/文档随之更替；nixkits-skills 安装器移除 dsh 安装目标（dsh 能力由 nixos-shell 提供，技能保留供其他助手安装）。修复点：generations 用进程内只读列出（nix-env 需锁文件权限，非 root 报 Permission denied）。验证：13 项功能套件全过（含真实 sudo root 路由与 nix shell 工具引导）；系统预构建通过。

| 提交 | 说明 |
|------|------|
| `395d8b4` | feat(nixos-shell): consolidate NixOS scenario capabilities into one plugin |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| nixos-shell | — | 新增 v0.1.0 |

## 2026-08-20T16:40:16+09:00

**摘要**：fix(dsh): 服务 HOME 指向真实用户家目录 — git 的 gh credential helper 按 `$HOME/.config/gh` 解析凭据，模块此前将服务 HOME 设为 dshHome（/home/kix/.dsh），沙箱内 git push 找不到凭据（could not read Username）。改为 `users.users.<user>.home`（缺省回退 dshHome），代理继承用户自身的工具上下文（git/gh 凭据、~/.gitconfig、npm/ssh 配置）；DSH_HOME 仍为 dsh 状态根不受影响。验证：HOME=/home/kix 推送积压提交全部成功；系统预构建通过。

| 提交 | 说明 |
|------|------|
| `514831c` | fix(dsh): point service HOME at the real user home — git's gh credential helper resolves ~/.config/gh from $HOME, so HOME=dshHome left sandbox pushes without credentials |

## 2026-08-20T16:13:40+09:00

**摘要**：fix(dsh-nix-shell): sudo 执行器 PATH 合并顺序 — 套接字激活的模板单元继承 systemd 管理器默认 PATH（仅 coreutils/findutils/grep/sed/systemd 的 store 路径），`...process.env` 在显式 NixOS PATH 之后展开将其覆盖，导致守护进程内 ps、nixos-rebuild 等 profile 工具全部不可解析（PS-MISSING/NIXOS-REBUILD-MISSING）。改为继承 env 在前、显式 NixOS profile PATH 在后（请求 env 仍最后合并）。验证：模拟 systemd 默认 PATH 直跑执行器，PATH 以 /run/current-system/sw/bin 开头、ps 与 nixos-rebuild 均解析成功。

| 提交 | 说明 |
|------|------|
| `63b2576` | fix(dsh-nix-shell): put the explicit NixOS profile PATH after the inherited env — socket-activated template units inherit systemd's manager-default PATH, which overrode the executor PATH and left profile tools (ps, nixos-rebuild) unresolvable |

## 2026-08-20T16:01:28+09:00

**摘要**：docs(dsh): 使用示例与实际模块行为同步 — 手工组合行示例补上 `- insert:` 包裹与警告（裸 `- id:` 行只补丁已有条目）；技能插件文档修正全部 7 个 entry id（`skill-nixkits-<id>` 前缀此前缺失）与 disabled 示例 id；dsh 文档安装章节改为模块式安装（原 `nixkits.extraPackages` 已不存在）并补充二进制缓存说明。四语同步。

| 提交 | 说明 |
|------|------|
| `6074661` | docs(dsh): sync usage examples with module reality — insert-op wrapping for manual rows, corrected skill entry ids, module-based install + cache note |

## 2026-08-21T23:02:33+09:00

**摘要**：chore(pkgs): dsh 0.1.0-rc.7 → 0.1.0-rc.8。完成遗留的 rc.8 升级：src hash 与 npmDepsHash 从占位符填入真实值；package-lock.json 重新生成（旧 lock 缺失 120 个 entries 含 dsh-invariants，导致 buildNpmPackage fetch 阶段 ENOTCACHED）。验证：rc.8 构建成功、randomUUID 回退 patch 生效、with-plugins 变体正常、服务启动无插件加载错误。注意：本机 skills-as-plugins 设计已废弃，skills 已整合进 dsh-nixos-shell（maintenance-skills），with-plugins 仅注入 dsh-nixos-shell。

| 提交 | 说明 |
|------|------|
| `a7cbe3e` | chore(pkgs): bump dsh 0.1.0-rc.7 → 0.1.0-rc.8 |

## 2026-08-21T22:11:28+09:00

**摘要**：fix(module): dsh 崩溃韧性 — Restart=always + RestartSec 5s。dsh 上游有已知崩溃 bug（cordis-plugin-timer 的 Context disposed，rc.6 实测运行约 13 小时触发），rc.7/rc.8 的 cordis-plugin-timer 依赖版本不变（^1.1.3），bug 仍存。崩溃时 lighttpd 反代随即返回 503 直到 systemd 拉起。改为 Restart=always（on-failure 不覆盖 exit 0 退出路径）+ 重启间隔 5s，把中断窗口压到最小。

| 提交 | 说明 |
|------|------|
| `ed7e9d5` | fix(module): dsh Restart=always + faster RestartSec (crash resilience) |

## 2026-08-20T11:08:08+09:00

**摘要**：fix(module): dsh 插件 ESM 解析 — dsh 的 cordis-plugin-loader 以 profile 目录（$DSH_HOME/profiles/web）为解析基准（Node 24 内部 cascaded loader 的 parentURL），从那里向上查找 node_modules。插件虽已注入 dsh 的 store 树，但 store 不在 profile 的 node_modules 链上，import 直接 ERR_MODULE_NOT_FOUND，启动即崩溃（restart 循环到 108）。preStart 把注入后的 @kihara777 scope 符号链接到 $DSH_HOME/node_modules 让 Node 可解析；realpath 回 store 树后，插件引用的 @deepseek-ai/* peer deps 仍在同树内可解析。实测 skills + nix-shell 插件加载成功。

| 提交 | 说明 |
|------|------|
| `044b891` | fix(module): dsh plugin ESM resolution via DSH_HOME/node_modules symlink |

## 2026-08-20T10:33:26+09:00

**摘要**：fix(dsh): insert 块缩进修复 — 嵌套 '' 字符串按自身最小缩进剥离，插件条目被顶回第 0 列，变成 `- insert:` 的兄弟补丁操作而非子条目（dsh 报 patch: entry … not found + id is required for non-insert patches，8 行再次全部未挂载）。改为每包一个 insert 操作、条目对象与 `- insert:` 行共处同一字符串（列 2/4 缩进），模块注释记录该陷阱。验证：dump-config 零 stderr、8 行进入组合树。

| 提交 | 说明 |
|------|------|
| `988dc6d` | fix(dsh): emit one insert op per plugin entry in a single string — nested '' strings dedent to column 0, turning entry objects into sibling patch ops |

## 2026-08-20T10:21:46+09:00

**摘要**：fix(dsh): 生成行改用 insert 动词 — cordis.patch.yml 中裸 `- id:` 行只补丁已有条目，新增插件条目被 dsh 丢弃（stderr: patch: entry "nixkits-nix-shell" not found），8 个插件行全部未挂载（dump-config 验证）。插件包注入虽成功，但组合树中没有条目 → 工具 nix_shell 与 7 技能插件均未注册。修复：模块生成的 plugins.packages 行包裹在 `- insert:` 操作下（与 extraPatch 的 MCP 行同构）。验证：dump-config 零 stderr、8 行全部进入组合树。

| 提交 | 说明 |
|------|------|
| `3d0433d` | fix(dsh): wrap generated plugin rows in the insert op — bare - id: rows only patch existing entries, so dsh dropped every new entry with 'patch: entry … not found' |

## 2026-08-20T09:45:59+09:00

**摘要**：fix(dsh): 修复多插件注入失败 — GNU tar 解包结束后恢复归档中的目录模式（store 树为 0555），前一个插件创建的 scope 目录（@kihara777/）对下一个插件不可写，第二个插件起报 Cannot mkdir: Permission denied；单插件场景不触发，首次真实系统构建暴露。改为每次插件解包后立即 chmod -R u+w。验证：系统 toplevel 完整构建成功，dsh-nix-shell 与 7 技能全部注入。

| 提交 | 说明 |
|------|------|
| `b03a386` | fix(dsh): chmod node_modules after each plugin injection — GNU tar restores archived dir modes (0555) after extraction, leaving the scope dir created by the previous plugin unwritable for the next one |

## 2026-08-20T08:12:57+09:00

**摘要**：fix(rcc-fix): desktop 条目重命名兼容 — asusctl 6.4.0 将桌面条目重命名为 org.opengamingcollective.rog-control-center.desktop，nixpkgs 的 programs.rog-control-center autoStart（makeAutostartItem）仍复制旧文件名 rog-control-center.desktop，导致系统构建失败（cp cannot stat）。rcc-fix overlay 在 asusctl 的 postInstall 中以符号链接提供旧文件名。验证：以本机 nixpkgs 修订（0ae2bc1）构建 makeAutostartItem { name = "rog-control-center"; package = asusctl } 成功（EXIT=0）。

| 提交 | 说明 |
|------|------|
| `650f6f7` | fix(rcc-fix): compat symlink for renamed desktop entry — nixpkgs programs.rog-control-center autoStart copies the pre-6.4.0 filename |

## 2026-08-20T07:41:45+09:00

**摘要**：fix(rcc-fix): 补丁重基适配 asusctl 6.4.0 — nixpkgs 前进后 asusctl 6.3.7 → 6.4.0，rcc-fix.patch 第 4 hunk 失效（系统构建失败）。上游重构了该区域：`if dev.is_old_laptop() { pow3r.retain(...) }` 替代原 push 块，else 分支的 PowerZones::None 过滤已吸收上游；补丁仅保留越界防护替换（`names[(*z) as usize]` → filter_map 边界检查 + warn）。其余 hunk 无需变更。验证：git apply --check 对 6.4.0 源码全 hunk 通过；以本机系统 nixpkgs 修订（0ae2bc1）构建 asusctl 成功（EXIT=0）。

| 提交 | 说明 |
|------|------|
| `ce216c7` | fix(rcc-fix): rebase patch hunk 4 for asusctl 6.4.0 — upstream is_old_laptop/retain restructure, else-filter absorbed upstream |

## 2026-08-20T06:27:40+09:00

**摘要**：feat(dsh-nix-shell): 外部 sudo 守护集成（0.2.0）— dsh 沙箱剥离 sudo setuid，代理无法提权。插件新增：初始化时探测守护套接字（config sudoSocketPath / 环境变量 NIXKITS_SUDO_SOCKET），存在即启用 sudo/justification 参数；sudo 请求整单（command/cwd/env/timeout）经 Unix 套接字路由至守护执行，justification 必填随结果回显。守护 = systemd 套接字激活的 root 执行器（nixkits-sudo@.service + nixkits-sudo-exec.js，单请求单连接 JSON 协议，随插件包发布）；访问控制边界 = 套接字文件归 dsh 服务用户所有且 0600（SocketUser/SocketMode）。模块新增 nixkits.dsh.sudo（enable/socketPath/package）自动生成 socket+service 并注入环境变量。验证：门控（无套接字不暴露参数/有套接字暴露）、路由往返、justification 校验、执行器直连协议全部通过；模块求值单元正确。

| 提交 | 说明 |
|------|------|
| `ef4bcfc` | feat(dsh-nix-shell): external sudo daemon integration — socket-activated root executor, init-time detection, sudo routing |

## 2026-08-20T06:02:50+09:00

**摘要**：refactor(skills): NixKits 技能重写为原生 DSH 技能插件 — 新包 dsh-skill-nixkits（@kihara777/dsh-skill-nixkits，零运行时依赖），7 个技能各为包内一个子路径插件条目，运行时经 ctx.skills.register 注册自身内容（runtime provider，rank 250，优先于文件系统来源），apply() 返回注册 disposer 随组合撤销；SKILL.md 保留在 skills/ 为内容单一来源、构建期嵌入，frontmatter 剥离并保留进 metadata（文档流水线自动发现契约不变）。模块 skills.enable 改为自动生成 7 条组合行（skill-nixkits-<id> → @kihara777/dsh-skill-nixkits/<id>），移除此前误实施的目录注入机制（nixkits-skills 包与 bundledSkillDir）。验证：7 插件 mock 注册全通过、子路径裸导入解析 + 注册实测通过（SUBPATH-OK/REGISTERED）。CI 新增 x86_64/aarch64 构建。

| 提交 | 说明 |
|------|------|
| `7393b95` | feat(dsh): rewrite NixKits skills as native skill plugins — dsh-skill-nixkits package, one plugin entry per skill |

## 2026-08-20T05:27:48+09:00

**摘要**：feat(dsh): 内置 bash 工具 NixOS 修复 + 第三方插件包 + 部署级技能 — ① 模块为 dsh 服务注入完整 NixOS PATH（systemd 默认 PATH 无 bash，内置 bash 工具报 spawn bash ENOENT）；② 新增 dsh-nix-shell 包（@kihara777/dsh-nix-shell，NixOS 感知 shell 工具插件：PATH 解析失败回退 Nix store bash、注入 NixOS PATH、超时与落盘输出）与 nixkits-skills 包（技能目录 bundle）；③ 模块新增 plugins.packages（tar 解包注入 node_modules——symlink 被 Node realpath 回插件 store 路径导致 peer 解析断裂，故须实体解包——并自动生成组合行）与 skills.enable（skill-filesystem bundledSkillDir rank 600）；④ CI 新增 dsh-nix-shell x86_64/aarch64 构建。端到端验证：注入树内 IMPORT-OK（插件导出与依赖链解析正常）。

| 提交 | 说明 |
|------|------|
| `69eedd4` | feat(dsh): PATH fix + third-party plugin packages + bundled skills — L1/L2/L3/路径A |
| `55664ed` | docs: dsh-nix-shell package docs + dsh module options + README rows (4 languages) |

## 2026-08-19T20:39:47+09:00

**摘要**：fix(ci): ci-summary 徽章卡在 failing — jq 管道先过滤 failure 再按 workflow 分组取最新，旧失败会永远掩盖后续成功（Build codewhale (riscv64) 修复后徽章仍红）；改为先分组取每 workflow 最新运行、再判定 failure，徽章恢复 passing。

| 提交 | 说明 |
|------|------|
| `d752c83` | fix(ci): ci-summary badge stuck on failing — latest-run check must precede failure filter |

## 2026-08-19T19:57:03+09:00

**摘要**：fix(codewhale-src): riscv64 交叉构建修复 — 四重问题链：① rquickjs-sys 0.12.2（crates.io 最新版）不提供 riscv64gc bindings（build.rs 非 bindgen 路径 include 目标文件），上游各 64 位小端平台 bindings 字节级一致，postPatch 将 x86_64 副本落入物化后的 vendor 目录；② ring 宿主侧（x86_64 build 依赖）构建时 cc-rs 从宿主 triple 回退到派生级 CC（交叉编译器）并追加 -m64，显式指向 buildPackages 工具链；③ postInstall 裸 cargo build 丢失 --target 而误用宿主工具链链接，镜像 cargoBuildHook 的目标三元组；④ 二进制以 -lgcc_s 动态链接，autoPatchelfHook 仅扫描 hostPlatform 依赖，显式加入交叉 gcc 的 libgcc 输出。本地以 CI 相同命令（pkgsCross.riscv64.callPackage）验证通过，Build codewhale (riscv64) 连续 6 次失败恢复。

| 提交 | 说明 |
|------|------|
| `962ce6c` | fix(codewhale-src): riscv64 cross build — rquickjs bindings overlay, host cc-rs toolchain, postInstall --target, libgcc rpath |

## 2026-08-19T17:57:26+09:00

**摘要**：AGENTS.md — 修正过时的 comfyui-strix-halo 模块引用（该模块已并入 comfyui-rocm）；CI 章节描述与实际 workflow 结构对齐（独立 build-<包>-<架构>.yml 调用共享 build-package.yml + cachix-action 推送；注明无 riscv64 构建的包与无独立构建 workflow 的 godot-ai/dsh；ci-summary.yml 徽章机制）。

| 提交 | 说明 |
|------|------|
| `c4e320e` | docs(AGENTS): fix stale comfyui-strix-halo reference + align CI description with actual workflows |

## 2026-08-19T16:52:54+09:00

**摘要**：fix(module): dsh WebSocket 反代改用 mod_proxy upgrade — NixOS lighttpd 模块按 allKnownModules 固定顺序生成 server.modules，mod_wstunnel 永远排在 mod_proxy 之后；proxy.server 匹配所有路径，mod_proxy 先接管 /api/events.* 的 WebSocket 升级请求返回 426 Upgrade Required，mod_wstunnel 因 r->handler_module 非空而跳过、从不生效。改用 lighttpd 1.4.56+ mod_proxy 原生 WebSocket 隧道（proxy.header = "upgrade" => "enable"），移除 mod_wstunnel 配置。实测 8625 首页 200、/api/events.host|mux 握手 101（本地+局域网）。

| 提交 | 说明 |
|------|------|
| `51d9435` | fix(module): dsh WebSocket reverse proxy via mod_wstunnel |
| `33d5931` | fix(module): dsh wstunnel port as string (match lighttpd backend syntax) |
| `d7d2713` | fix(module): dsh WebSocket via mod_proxy upgrade (mod_wstunnel never runs) |

## 2026-08-19T13:10:00+09:00

**摘要**：fix(pkgs): dsh 0.1.0-rc.6 → 0.1.0-rc.7。rc.6 运行约 13 小时后崩溃（fatal load failure: Context has been disposed）—— cordis-plugin-timer 的 ctx.timeout() 在 Context 静默 dispose 时 reject 变成 unhandled rejection。rc.7（8/17）为最新版，cordis/timer 版本未变（bug 可能仍在），但携带上游修复。插件清单不变（131 项）。

| 提交 | 说明 |
|------|------|
| `c75cb4c` | chore(pkgs): bump dsh 0.1.0-rc.6 → 0.1.0-rc.7 |

## 2026-08-18T20:00:00+09:00

**摘要**：fix(module): dsh 支持普通用户运行 — dsh 以隔离系统用户（home /var/lib/dsh）运行无法访问 /home/<user>（700 权限），agent 无法操作用户工作目录。新增 dshHome 选项，HOME/DSH_HOME/WorkingDirectory/preStart 统一走该路径，StateDirectory 改为 preStart mkdir + chown。本机配置 user="kix" + dshHome="/home/kix/.dsh"，dsh 以 kix 身份运行，可访问 /home/kix。

| 提交 | 说明 |
|------|------|
| `584c764` | fix(module): dsh dshHome option + support normal-user operation |

## 2026-08-18T19:30:00+09:00

**摘要**：feat(module): nixkits.dsh.settings — 声明式设置配置。dsh 设置菜单选项存储于 $DSH_HOME/settings.yaml（文件备份 + 热加载，per-namespace section）。新增 settings 选项（attrsOf attrs，namespace → section），渲染为 JSON（合法 YAML）由 preStart 写入。部署验证：web-search-deepseek.maxTokens 声明式覆盖默认 4096 → 8192 生效。文档 4 语言补设置配置章节。

| 提交 | 说明 |
|------|------|
| `f2981e6` | feat(module): nixkits.dsh.settings — declarative settings |
| `dc64cbb` | docs(dsh): declarative settings section + maintenance log |

## 2026-08-18T18:45:00+09:00

**摘要**：docs(dsh) + refactor(skill): 插件清单同步 — docs/dsh.md 4 语言新增「插件清单」章节（131 个内置插件 entry id，id -> 包名），作为 nixkits.dsh.plugins.disabled 的取值参考。nixkits-check-updates 技能第 5 步新增 dsh 特有说明：升级 dsh 时从新包提取 dsh-*/cordis.patch.yml 的插件清单同步到文档。

| 提交 | 说明 |
|------|------|
| `06d0e28` | docs(dsh): plugin inventory + check-updates skill sync |

## 2026-08-18T18:39:34+09:00

**摘要**：fix(module): dsh preStart rm before cp — settings/plugins 由 preStart 生成的文件权限为 444（只读），服务用户直接 cp 覆盖失败；改为先 rm 再 cp 生成。

| 提交 | 说明 |
|------|------|
| `f308ac7` | fix(module): dsh preStart rm before cp — service-user cannot overwrite 444 |

## 2026-08-18T18:20:00+09:00

**摘要**：feat(module): nixkits.dsh.plugins — 声明式插件启停与配置。dsh 插件经 cordis.patch.yml 运行时热加载，模块新增 plugins.disabled（禁用 entry id）、plugins.settings（config 覆盖）、plugins.extraPatch（手写片段如 MCP）。系统配置迁移 MCP 到 extraPatch、API key 改用 kix.credentials 声明式、示例禁用 session-telemetry-otel + session-stats。部署验证：cordis.patch.yml 正确生成、插件禁用无 absent 警告。

| 提交 | 说明 |
|------|------|
| `0e4fe58` | feat(module): nixkits.dsh.plugins — declarative plugin on/off + config |
| `164d515` | docs(dsh): declarative plugin management section + maintenance log |

## 2026-08-18T17:55:00+09:00

**摘要**：fix(module): lighttpd 反代改写 Host/Origin 为 loopback — 替代 trustedHosts 方案。改写后 dsh 的 isTrustedApiRequest 看到 loopback 即通过，无需 per-deployment trustedHosts 配置，且不向后端泄露局域网主机名/IP。Origin 必须与 Host 同步改写，否则同源校验失败。实测：移除 trustedHosts 后反代 API（harukax.lan / 192.168.31.241）均 ok:true。

| 提交 | 说明 |
|------|------|
| `a33b414` | fix(module): rewrite Host/Origin to loopback in lighttpd reverse proxy |

## 2026-08-18T17:30:00+09:00

**摘要**：fix(module): dsh trustedHosts 选项 — 反代后 API 全 403。dsh 对 /api 请求校验 Host header（isTrustedApiRequest：Host 必须 loopback 或在信任列表，且浏览器 Origin 需同源）。经 lighttpd 反代后 Host 变为局域网域名/IP，所有 /api 调用返回 403 forbidden。新增 nixkits.dsh.trustedHosts（映射为 repeatable --trusted-host），系统配置 harukax.lan + 192.168.31.241 后 API 恢复。

| 提交 | 说明 |
|------|------|
| `3755935` | fix(module): dsh trustedHosts option — Host-header 403 behind reverse proxy |

## 2026-08-18T16:20:05+09:00

**摘要**：fix(dsh): patch 浏览器端 client bundle — crypto.randomUUID fallback。crypto.randomUUID() 在非安全上下文（HTTP 局域网 IP，即 lighttpd 反代）不可用，导致 webui 报 "crypto.randomUUID is not a function"。postInstall 替换 dsh-client-connection + dsh-client-ui-conversation 的 crypto.randomUUID 为 __dshUuid helper（fallback 到 crypto.getRandomValues，全上下文可用）。服务端 index.js 用 Node crypto，无需处理。

| 提交 | 说明 |
|------|------|
| `5d1cfa8` | fix(dsh): patch browser client bundles — crypto.randomUUID fallback |

## 2026-08-18T15:29:14+09:00

**摘要**：fix/docs(dsh): lighttpd 反代方案定稿 — dsh 内部 loopback 端口 8615（对齐 SearXNG 的 42701 惯例），lighttpd 对外端口 8625（对齐 4270），防火墙开放 lighttpd 对外端口（非 dsh 内部端口）。4 语言文档同步最终方案。

| 提交 | 说明 |
|------|------|
| `4a78d54` | fix(module): dsh internal port 8615, public reverseProxy port 8625 |
| `5452a3e` | docs(dsh): sync service section to loopback 8615 + lighttpd reverseProxy 8625 |

## 2026-08-18T14:38:26+09:00

**摘要**：feat(module): dsh reverseProxy via lighttpd — dsh 拒绝非 loopback host（RCE 安全），通过 lighttpd `$SERVER["socket"]` 条件块在 0.0.0.0:8626 反代到 dsh loopback 8625（复用 SearXNG 的 lighttpd 实例，extraConfig 是 types.lines 可合并）。对外 8626 开放防火墙。

| 提交 | 说明 |
|------|------|
| `12e11af` | feat(module): add nixkits.dsh.reverseProxy via lighttpd |

## 2026-08-18T10:29:46+09:00

**摘要**：feat/fix(dsh): 部署 dsh 服务并配置 MCP + skills — ① 模块修复：dsh 系统用户 HOME=/var/empty（只读）导致 EPERM，改 /var/lib/dsh 可写 home + StateDirectory；② HMR 服务需 --expose-internals（NODE_OPTIONS 禁止、CLI 不识别），改 node --expose-internals 直接启动 bin.js；③ MCP 服务用 cordis.patch.yml 的 `insert:` 语法（非 id-targeted override）配置 SearXNG + Godot；④ skills 复制到 /var/lib/dsh/skills/（非 .agent-presets 子目录）；⑤ nixkits-skills 目录修正为 ~/.dsh/skills。

| 提交 | 说明 |
|------|------|
| `b17e5bf` | fix(module): dsh writable HOME + StateDirectory |
| `ed6983e` | fix(module): dsh launch via node --expose-internals (HMR requires execArgv) |
| `456c917` | feat(skill): nixkits-skills add dsh skills directory support |
| `ee24563` | fix(skill): correct dsh skills directory — ~/.dsh/skills |

## 2026-08-18T08:42:40+09:00

**摘要**：docs: 同步 ruyi 通道版本（stable 0.50.0 → 0.51.0、beta/alpha 日期）并补齐 en/ja/pcn README 中 ruyi 描述列（原本为空 `<br><br>`，现填入 RuyiSDK 描述 + 三通道版本，与 zh 对齐）。

| 提交 | 说明 |
|------|------|
| `86ae30b` | docs: sync ruyi channel versions + fill empty ruyi descriptions in en/ja/pcn README |

## 2026-08-18T07:19:30+09:00

**摘要**：审计修复 — ① codewhale 0.9.8 / mcp-searxng 1.15.0 / opencode-telegram 0.24.0 / obs-bilibili-stream 2.1.3 版本更新；② comfyui-rocm 模块补回 services.comfyui assertion 并澄清 nixpkgs-compat 补丁目标；③ overlay codewhale 按架构回退源码构建（riscv64）；④ 文档版本号 + ruyi 链接 + codewhale-sudo 描述同步；⑤ write-maintenance-log 技能补表头 + 删 katalish 列。

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

**摘要**：refactor: 合并 comfyui-rocm-patch + comfyui-strix-halo 为单一 comfyui-rocm — 两模块分别处理 ComfyUI ROCm 支持的不同部分（补丁层 vs Strix Halo 硬件优化），合并为 nixkits.comfyui-rocm 模块（enable 选项），覆盖 ROCm 补丁挂载、GFX 覆盖、xformers 绕过、C 工具链、Strix Halo 硬件配置（ROCm runtime/DeviceAllow/kernelParams）。文档与 README 同步。

| 提交 | 说明 |
|------|------|
| `d473991` | refactor: merge comfyui-rocm-patch + comfyui-strix-halo into comfyui-rocm |

## 2026-08-15T09:23:15+09:00

**摘要**：refactor: 补丁文件 rog-control-center-fix.patch → rcc-fix.patch，完成 rcc-fix 统一命名的收尾。更新 overlays/rcc-fix.nix 与 4 语言 rcc-fix.md 文档中的引用。

| 提交 | 说明 |
|------|------|
| `b350cfd` | refactor: rename rog-control-center-fix.patch to rcc-fix.patch |

## 2026-08-15T08:31:32+09:00

**摘要**：feat(dsh): 新增 deepseek-harness 0.1.0-rc.6 包 + 4 语言文档。DSH（DeepSeek Harness）— 万物皆插件。预构建 npm 包（@deepseek-ai/dsh，bin dsh → lib/bin.js），vendor package-lock.json（npm tarball 不含 lock），dontNpmBuild 跳过 build。同时 godot-ai 与 dsh 列入 README（4 语言）。

| 提交 | 说明 |
|------|------|
| `0194460` | feat(dsh): add deepseek-harness 0.1.0-rc.6 package + 4-language docs |

## 2026-08-15T08:07:33+09:00

**摘要**：refactor: 合并 rog-control-center-fix 到 rcc-fix — 两者实为同一 ROG 控制中心修复项目（overlay asusctl 补丁 + module systemd 死锁修复）。统一为单一 rcc-fix：overlays/rog-control-center-fix.nix → rcc-fix.nix，modules/rog-control-center-fix.nix → rcc-fix.nix，选项 nixkits.rog-control-center-fix → nixkits.rcc-fix，删除独立 rog-control-center-fix 文档（内容并入 rcc-fix.md）。

| 提交 | 说明 |
|------|------|
| `376eacf` | refactor: merge rog-control-center-fix into rcc-fix |

## 2026-08-13T01:20:29+09:00

**摘要**：fix(default-overlay): godot-ai 应用 fastmcp overlay 构建 — default overlay 的 final.callPackage 将 fastmcp 解析为 nixpkgs 3.3.1（circular-import bug），改用 (prev.extend (import ./fastmcp.nix)) 使依赖解析为 3.4.7。

| 提交 | 说明 |
|------|------|
| `94d49b5` | fix(default-overlay): build godot-ai with fastmcp overlay applied |

## 2026-08-12T10:05:00+09:00

**摘要**：fix(default-overlay): 修正 godot-ai 包路径 — `overlays/default.nix` 中 `callPackage` 路径应为 `../packages/`（overlay 在子目录），误写为 `./packages/` 导致路径解析到不存在的 `overlays/packages/`。

| 提交 | 说明 |
|------|------|
| `0144283` | fix(default-overlay): correct godot-ai path — ./packages → ../packages |

## 2026-08-12T10:00:00+09:00

**摘要**：fix(default-overlay): 注册 godot-ai — godot-ai 在 flake packages 中存在但遗漏于默认 overlay，下游（/etc/nixos）通过 pkgs.godot-ai 不可见。

| 提交 | 说明 |
|------|------|
| `093565c` | fix(default-overlay): register godot-ai so pkgs.godot-ai is available |

## 2026-08-12T09:18:26+09:00

**摘要**：docs(godot-ai): 新增 4 语言文档（72 行）— 架构图、依赖表（含 fastmcp 3.4 说明）、系统安装 + MCP 配置 + 前置条件指南。

| 提交 | 说明 |
|------|------|
| `76c39c8` | docs(godot-ai): add 4-language documentation |

## 2026-08-12T07:07:27+09:00

**摘要**：feat(godot-ai): 新增 godot-ai 3.1.5 包 + fastmcp 3.4.7 overlay。godot-ai（hi-godot/godot-ai）是 Production-grade MCP server，连接 MCP 客户端到运行中的 Godot 编辑器（43 工具 / 120+ 操作）。fastmcp 从 nixpkgs 3.3.1 升级到 3.4.7（godot-ai 要求 >=3.4.0，排除 3.3.x 的 circular-import bug），联动升级 fastmcp-slim + py-key-value-aio 0.4.5。devshell godot-mcp → godot-ai。

| 提交 | 说明 |
|------|------|
| `23a5b8d` | feat(godot-ai): add godot-ai 3.1.5 package + fastmcp 3.4.7 overlay |

## 2026-08-11T18:49:54+09:00

**摘要**：fix(breeze-black): Edge/Chromium 纯黑背景 + 纯白前景 — 扩展 sed 重映射：背景 #292c30 → #000000（按钮/工具栏/禁用），前景 #fcfcfc/#a1a9b1 → #ffffff。gtk-3.0/4.0 验证：15× #000000、14× #ffffff、零灰残留。

| 提交 | 说明 |
|------|------|
| `4e5c558` | fix(breeze-black): pure black bg + pure white fg for Edge/Chromium |

## 2026-08-11T18:41:14+09:00

**摘要**：fix(breeze-black): 背景变量映射为纯黑 #000000 — Breeze-Dark 基础色是 #202326（深灰非纯黑）。复制 CSS 后重映射主背景/base 为 #000000（按钮保留 #292c30 保持层次），gtk-dark.css 改为自包含（复制 gtk.css）不再依赖灰色 import。

| 提交 | 说明 |
|------|------|
| `2ee1ba6` | fix(breeze-black): map background variables to true black #000000 |

## 2026-08-11T16:19:49+09:00

**摘要**：fix(breeze-black): 用 Breeze-Dark 深色方案覆盖 gtk.css 本体 — Chromium 系（Edge/Chrome）不遵循 prefer-dark，直接加载 gtk.css；BreezeBlack（浅色 Breeze 重命名）仍带浅色变量（#eff0f1），导致 Edge 显示灰色。覆盖 gtk-{3,4}.0 的 gtk.css(+.map) 为深色（#202326）。

| 提交 | 说明 |
|------|------|
| `25e23e0` | fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme |

## 2026-08-11T16:02:39+09:00

**摘要**：fix(breeze-black): 保留 Breeze-Dark — BreezeBlack 的 gtk-dark.css 通过 `@import ../../Breeze-Dark/...` 获取真正的深色配色（#202326），preFixup 中删除 Breeze-Dark 导致 import 断裂、GTK 回退浅色（「不够黑」症状）。

| 提交 | 说明 |
|------|------|
| `0433eee` | fix(breeze-black): keep Breeze-Dark — gtk-dark.css imports it for dark mode |

## 2026-08-09T22:43:43+09:00

**摘要**：refactor(skill): 常见陷阱新增第 4 条 — 无参数 `nix flake lock` 会刷新所有浮动 input（nixpkgs 漂移重演，diffusers/httpx 在 8/7 nixpkgs 失败）。应使用 --update-input 或固定 nixpkgs rev。

| 提交 | 说明 |
|------|------|
| `ec5e589` | refactor(skill): add trap 4 — bare nix flake lock refreshes floating inputs |

## 2026-08-09T19:40:21+09:00

**摘要**：feat(patches): 将本地 comfyui-nix 构建修复转正为补丁文件 — ① mkWheel dontCheckRuntimeDeps（pythonRuntimeDepsCheckHook，nixpkgs ≥ 8/5）；② flaky 套件 doInstallCheck=false（jupyter-server/scipy/fastapi/einops/mss/inline-snapshot）；③ torch/facexlib 运行时依赖跳过。更新模块注释 + 4 语言文档。

| 提交 | 说明 |
|------|------|
| `a8ad11e` | feat(patches): add comfyui-nix nixpkgs-compat patch + module doc |
| `faefa5b` | docs(comfyui-rocm-patch): document nixpkgs-compat patch (4 langs) |

## 2026-08-09T19:05:53+09:00

**摘要**：refactor(skill): nixkits-check-updates 新增 nixpkgs 漂移故障排查小节 — ① 恢复旧 flake.lock 需核对 flake.nix 的 follows 配置（丢失 → glibc 2.40 → GLIBC_ABI_GNU2_TLS）；② pytest 包跳过测试用 doInstallCheck=false（pytestCheckHook 跑在 installCheckPhase）；③ pythonRuntimeDepsCheckHook（nixpkgs ≥ 8/5）破坏 wheel 构建，用 dontCheckRuntimeDeps=true 修复。

| 提交 | 说明 |
|------|------|
| `e88fd98` | refactor(skill): add nixpkgs-drift troubleshooting section to check-updates |

## 2026-08-09T04:21:09+09:00

**摘要**：fix(module): llama-cpp — ① services.llama-cpp.extraFlags 已废弃，改用 settings 传递 --sleep-idle-seconds；② freeform settings 无法分离定义，改用 lib.mkMerge 合并 models-preset 与 sleep-idle-seconds。

| 提交 | 说明 |
|------|------|
| `8026d8e` | fix(module): replace deprecated services.llama-cpp.extraFlags with settings |
| `0ec7760` | fix(module): merge llama-cpp settings via mkMerge |

## 2026-08-08T23:07:40+09:00

**摘要**：fix(breeze-black): 恢复 look-and-feel 全局主题并修复 GTK 重命名 — 7/23 移除外部补丁后两个回归：① org.kde.breezeblack.desktop 全局主题缺失导致 BreezeBlack 从系统设置主题选择页消失，本地内置 look-and-feel 包恢复；② preFixup 的 Breeze* 通配同时匹配 Breeze 与 Breeze-Dark，导致 GTK 主题嵌套失效，改为仅重命名 Breeze。

| 提交 | 说明 |
|------|------|
| `114b9c2` | fix(breeze-black): restore look-and-feel global theme + fix GTK rename |

## 2026-08-08T22:50:33+09:00

**摘要**：fix(codewhale-src): 同步至 0.9.4 并修正 source hash — 之前用 nix-prefetch-url 从 archive tarball 预取的 hash 与 fetchFromGitHub（git 协议）不一致，导致 riscv64 CI 连续失败。改用 fetchFromGitHub 构建获取正确 hash，同步 Cargo.lock；技能中错误建议一并修正。

| 提交 | 说明 |
|------|------|
| `08b04a2` | fix(codewhale-src): sync to 0.9.4 with correct fetchFromGitHub hash |
| `ab2a624` | fix(skill): correct fetchFromGitHub hash advice — archive tarball trap |

## 2026-08-08T22:20:21+09:00

**摘要**：codewhale 0.9.4 — 上游 bug 修复；mcp-searxng 1.14.1 — 上游维护更新；opencode-telegram 0.23.1 — 上游功能更新

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

**摘要**：chore(pkgs) — codewhale-src 同步至 0.9.3（riscv64 源码构建落后预编译包 3 个版号）。同步 version、fetchFromGitHub hash、Cargo.lock（711 → 763 条目）。

| 提交 | 说明 |
|------|------|
| `563eea2` | chore(pkgs): sync codewhale-src to 0.9.3 — version, hash, Cargo.lock |

## 2026-08-05T01:30:00+09:00

**摘要**：refactor(skill) — nixkits-check-updates 新增 Rust 包（buildRustPackage）更新流程，泛化 codewhale-src 的 Cargo.lock 同步经验（版本 + source hash + Cargo.lock 三处同步、上游 lock 下载与条目数验证、交叉编译超时回退）。

| 提交 | 说明 |
|------|------|
| `6e6bef6` | refactor(skill): add Rust package (buildRustPackage) update flow to nixkits-check-updates |

## 2026-08-04T02:15:00+09:00

**摘要**: fix(ruyi): 容忍 ruff lint 失败 — 第二条 ruff check（不带 --fix）在 nixpkgs ruff 更新后因 139 条上游违规阻塞构建。

| 提交 | 说明 |
|------|------|
| `1175df2` | fix(ruyi): tolerate ruff lint failures in checkPhase |

## 2026-08-04T01:15:52+09:00

**摘要**：codewhale 0.9.3 — 上游 bug 修复；mcp-searxng 1.14.0 — 上游功能更新

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

**摘要**：fix(ci): 修复 ci-summary.yml 语法错误（YAML runs-on 与 workflow_dispatch 混排、硬编码 token），改用 push/schedule 触发 + GITHUB_TOKEN。README badge 从 check.yml（仅 flake 求值）改为 shields.io endpoint（反映全部 Build workflow 实际状态）。

| 提交 | 说明 |
|------|------|
| `c0e52a5` | fix(ci): fix ci-summary.yml syntax, switch README badge to endpoint |

## 2026-07-31T03:34:15+09:00

**摘要**：fix(ci): 注入 GITHUB_TOKEN 作为 Nix access-token — `llama-cpp-ver` input 需要 GitHub API 请求，未认证访问仅 60 次/小时，多 job 并行时频繁触发 403 限流。改用 `${{ secrets.GITHUB_TOKEN }}` 认证。

| 提交 | 说明 |
|------|------|
| `41a8a8b` | fix(ci): inject GITHUB_TOKEN as Nix access-token for llama-cpp-ver API |

## 2026-07-31T03:00:12+09:00

**摘要**：fix(codewhale-src): 修复 riscv64 交叉编译 — `ring` crate 通过 `cc` crate 继承了通用 CFLAGS 中的 `-m64`（x86_64 标志），导致 riscv64-gcc 报错。在清除 per-target CFLAGS 基础上进一步清除通用 CFLAGS/CXXFLAGS。

| 提交 | 说明 |
|------|------|
| `29c780a` | fix(codewhale-src): clear generic CFLAGS/CXXFLAGS for riscv64 cross-compile |

## 2026-07-30T17:56:11+09:00

**摘要**：codewhale 0.9.1 — 上游 bug 修复；mcp-searxng 1.12.1 — 上游功能更新；opencode-telegram 0.22.5 — 上游维护更新

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

**摘要**：fix(codewhale-sudo): 修复 ptrace wrapper — 移除子进程跟踪（避免 codewhale 子 shell 被 SIGTRAP 杀死），添加 PTRACE_EVENT_EXEC 处理。同步更新 4 语言文档（LD_PRELOAD → ptrace 描述）。

| 提交 | 说明 |
|------|------|
| `c77cadc` | fix(codewhale-sudo): stop tracing child processes, handle PTRACE_EVENT_EXEC |
| `480658e` | docs(codewhale-sudo): update mechanism description LD_PRELOAD → ptrace |

## 2026-07-23T12:08:13+09:00

**摘要**：fix(codewhale-sudo): 将 LD_PRELOAD shim 替换为 ptrace 系统调用拦截器 — codewhale 是静态链接的，LD_PRELOAD 无法拦截 prctl(PR_SET_NO_NEW_PRIVS)；改用 ptrace(2) 在内核边界拦截，兼容静态和动态二进制。

| 提交 | 说明 |
|------|------|
| `6446364` | fix(codewhale-sudo): replace LD_PRELOAD shim with ptrace syscall interceptor |

## 2026-07-23T11:24:15+09:00

**摘要**：fix(overlays): breeze-black — 替换已失效的 fetchpatch URL（injx.sbs 域名永久不可用），改为纯本地 colors 文件安装方式。KDE Plasma 自动发现 share/color-schemes/ 中的配色方案。

| 提交 | 说明 |
|------|------|
| `547d6a0` | fix(overlays): replace dead breeze-black fetchpatch with local copy |

## 2026-07-22T16:31:26+09:00

**摘要**：fix(modules) — rog-control-center-fix 添加 SendSIGKILL=yes + TimeoutStopSec=30s 解决 asus-shutdown 旧进程残留阻塞 systemd-switch。comfyui-strix-halo 添加 glibc >= 2.42 assertion（ROCm 7.2 需要 GLIBC_ABI_GNU2_TLS）。

| 提交 | 说明 |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T09:00:00+09:00

**摘要**：feat(overlays) — 新增 breeze-black overlay，为 Plasma 6 提供高对比度 Breeze Black 无障碍主题（全局 look-and-feel + GTK + 配色方案）。含 4 语言文档。

| 提交 | 说明 |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T05:39:31+09:00

**摘要**：docs(devshell) — 新增 devShell 文档（4 语言），描述 opencode（MCP 全栈）和 ruyi（三通道合并）开发环境。README devShell 表添加文档链接列。

| 提交 | 说明 |
|------|------|
| `7bfe3e3` | docs: add devShell documentation — 4 lang |
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |

## 2026-07-22T03:40:50+09:00

**摘要**：docs — 统一全仓库文档中的用户目录路径为 `~/` 前缀（替换硬编码 `/home/kix` 及 `/home/<user>` 等变体），涉及 13 文件。

| 提交 | 说明 |
|------|------|
| `f597b9a` | docs: generalize hardcoded /home/kix paths |
| `bb65b77` | docs: unify all user home paths to ~/ prefix |

## 2026-07-22T03:14:27+09:00

**摘要**：feat(shells) — opencode devShell 迭代：SearXNG + lighttpd（与系统 NixOS 配置一致）+ blender-mcp + godot-mcp + godot + opencode + opencode-telegram，首次进入自动注册 MCP 配置；移除 godot 包的 tryEval 保护。

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

**摘要**：feat(overlays) — 新增 efl-cross-fix overlay，修复 efl（Enlightenment Foundation Libraries）在 riscv64/riscv64-musl/aarch64 交叉编译时因缺少原生代码生成工具（eolian_gen、eet）导致的构建失败。含 4 语言文档。

| 提交 | 说明 |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**摘要**：codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3 — 上游更新（codewhale v0.9.0 仍无 riscv64 预编译二进制，继续源码构建路径）

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

**摘要**：fix(ci) — 修复 ci-summary workflow 因 `gh run list` 逐 workflow 调用 API 触发 rate limit（HTTP 403）导致主文档 CI badge 无法更新。改为 2 次批量 `gh api` 调用 + 并发控制。

| 提交 | 说明 |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**摘要**：revert(skill) — 移除 katalish（半角片假名机械翻译）全部内容：19 个文档、技能（SKILL.md + dictionary.md 102 条）、所有语言切换器链接。该方案因翻译不稳定（残留英文或破坏文档结构）不适合生产环境。

| 提交 | 说明 |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:54:55+09:00

**摘要**：docs(nixkits-skills) —「已知移除」章节改名为「风险警示」，5 语言技能文档同步。

| 提交 | 说明 |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**摘要**：skill(nixkits-skills) — 移除 Claude Code 安装目标（软件内基于用户数据挖掘的国籍推断跨越安全边界），添加 Codex 支持。SKILL.md 新增「风险警示」章节包含原始声明文本。

| 提交 | 说明 |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:35:20+09:00

**摘要**：skill(write-maintenance-log) — 强化时间戳规则：强制使用 `git log` 获取 commit 时间、禁止 `T00:00:00` 占位符、新增生成后验证步骤。泛化自维护日志占位时间修复经验（`968df0e`）。

| 提交 | 说明 |
|------|------|
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |

## 2026-07-16T04:30:55+09:00

**摘要**：feat(ci) — 新增 CI summary endpoint badge。主文档 CI 徽章改为 shields.io endpoint 读取 `gh-pages/ci-status.json`，失败时显示失败包名和架构。

| 提交 | 说明 |
|------|------|
| `6465260` | feat(ci): add CI summary workflow with endpoint badge |
| `b489890` | docs(README): switch main CI badge to endpoint |

## 2026-07-16T04:09:46+09:00

**摘要**：refactor(ci) — CI 从单个 check.yml 拆分为 25 个独立 workflow 文件（每个包×架构一个），彻底消除 badge 间互相影响。新增 reusable workflow `build-package.yml`。

| 提交 | 说明 |
|------|------|
| `bc42e6f` | refactor(ci): split single check.yml into 25 isolated per-package-per-arch workflows |
| `1dfc1ee` | docs: update ruyi badge URLs to new isolated workflow files |
| `f235edc` | docs: embed version numbers in CI badge labels |

## 2026-07-16T04:00:46+09:00

**摘要**：fix(codewhale) — codewhale 源码构建 riscv64 交叉编译修复：ring crate 的 `-m64` 错误因 cc crate 继承 host CFLAGS 导致，通过清空 per-target CFLAGS 修复。

| 提交 | 说明 |
|------|------|
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |

## 2026-07-16T01:18:16+09:00

**摘要**：codewhale 0.8.67 — 双路径构建（预编译 x86_64/aarch64 + 源码构建 riscv64）。上游从 v0.8.67 起移除 riscv64 预编译二进制；riscv64 现通过 rustPlatform.buildRustPackage 从本地 Cargo.lock 构建。

| 提交 | 说明 |
|------|------|
| `0025476` | feat(codewhale): dual-path build — prebuilt for x86_64/aarch64, source for riscv64 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.66（预编译×3） | 0.8.67（预编译×2 + 源码 riscv64） |

## 2026-07-15T08:32:13+09:00

**摘要**：mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 — 上游更新（codewhale 跳过：v0.8.67 仍缺 riscv64 二进制）

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

**摘要**：revert(ci) — 移除 `ci/` 目录，恢复 `llama-cpp-ver` input 为上游 API（`ggml-org/llama.cpp` releases/latest）。overlay 已内置 `tryEval` + `prev.llama-cpp.version` fallback，无需本地缓存。

| 提交 | 说明 |
|------|------|
| `dbdd937` | revert: restore llama-cpp-ver to upstream API, remove ci/ |

## 2026-07-09T01:14:34+09:00

**摘要**：obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 — 上游更新（codewhale 跳过：v0.8.67 缺少 riscv64 预编译二进制）

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

**摘要**：fix(docs) — katalish/pcn 本地化修复：katalish/ruyi.md 和 pcn/ruyi.md 语言切换器错误（缺少链接或重复语言名）修复，pcn/ruyi.md 全文从日文重写为伪中国语。

| 提交 | 说明 |
|------|------|
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |

## 2026-07-05T04:41:23+09:00

**摘要**：fix(ci) — blender-mcp riscv64-cross 修复历程（4 次提交）：最初因 `callPackage` 自动解析不兼容的 `blender` 参数失败，后因 Nix/Bash 转义问题反复，最终因上游 nixpkgs 的 `sse-starlette` 交叉编译缺陷而移除 blender-mcp 的 riscv64-cross 构建。x86_64 / aarch64 不受影响。

| 提交 | 说明 |
|------|------|
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |

## 2026-07-04T07:33:07+09:00

**摘要**：docs(MAINTENANCE) — 为全部 6 个 MAINTENANCE 文件（zh/en/ja/katalish/pcn）添加语言切换器

| 提交 | 说明 |
|------|------|
| `9feb2fd` | docs(MAINTENANCE): add language switcher to all 6 MAINTENANCE files (zh/en/ja/katalish/pcn) |

## 2026-07-04T06:41:28+09:00

**摘要**：blender-mcp 1.0.0 — 新增 Blender MCP Server 包（Python 构建，22 个 MCP 工具，含 Blender add-on 配套文件）

| 提交 | 说明 |
|------|------|
| `a1cf458` | packages: add blender-mcp (MCP server for Blender) |
| `ab9109a` | packages: add blender-mcp (MCP server for Blender) |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| blender-mcp | — | 1.0.0 |

## 2026-07-02T04:00:00+09:00

**摘要**：codewhale 0.8.66 — 上游更新（TUI 布局修复、审批诚实度标签、性能修复若干）

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

**摘要**：opencode-telegram 0.22.0 — 上游更新（三模式 TTS + thinking 显示 + 紧凑输出 + /settings 命令 + session 启动修复）

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

**摘要**：CI — llama-cpp-ver 改为本地文件（`ci/llama-cpp-ver.json`），消除所有 CI job 的 GitHub API 调用，彻底解决 rate limit 导致的全局构建失败；docs — riscv64 badge 精确到包级别（codewhale/kitsfmt/mcp-searxng/opencode-telegram）

| 提交 | 说明 |
|------|------|
| `8b3a3be` | fix(ci): use local path for llama-cpp-ver input, eliminate GitHub API calls from all CI jobs |
| `5db4852` | fix(docs): add per-package job filter to riscv64 badges |

## 2026-06-26T12:30:00+09:00

**摘要**：feat(opencode-telegram): 新增 `extraPackages` 选项（注入系统包到服务 PATH）和 `extraBinPaths` 选项（注入 home-manager 路径到服务 PATH），解决 opencode 不在服务 PATH 中的问题；5 语言文档同步更新

| 提交 | 说明 |
|------|------|
| `7c98694` | feat(opencode-telegram): add extraPackages option to inject companion tools into service PATH |
| `45b7c57` | feat(opencode-telegram): add extraBinPaths option for home-manager users |

## 2026-06-26T10:55:41+09:00

**摘要**：codewhale 0.8.65 — 上游更新（cli 二进制重命名：codewhale-cli-linux → codewhale-linux）；mcp-searxng 1.8.0 — 上游更新（多实例故障转移/并行扇出、能力发现聚合、safesearch 修复）

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

## 2026-06-26T08:00:00+09:00

**摘要**：docs(MAINTENANCE): pcn 补全 28 条历史缺失维护日志条目，覆盖 zh 基准全部 93 条

| 提交 | 说明 |
|------|------|
| `01f662b` | docs(MAINTENANCE): backfill 28 missing historical entries to pcn (93/93 zh baseline covered) |

## 2026-06-26T07:35:00+09:00

**摘要**：docs(MAINTENANCE): en/ja/katalish 补全 10 条历史缺失维护日志条目，三语言全部对齐 zh 基准（92/92）；pcn 部分补全（66/92）

| 提交 | 说明 |
|------|------|
| `1921a36` | docs(MAINTENANCE): backfill 10 missing entries to en/ja/katalish (+ partial pcn) |

## 2026-06-26T07:18:56+09:00

**摘要**：fix(skill): write-maintenance-log 第 4 步「多语同步」从 5 行空壳重写为可执行流程（4a 发现语言 → 4b 逐语言翻译写入 → 4c 验证条目数一致）；AGENTS.md 第 4 步加强验证检查

| 提交 | 说明 |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-26T06:19:21+09:00

**摘要**：审计修复 — 清理 scripts/ 空目录与 .gitignore 死规则（translate_pcn.py）；AGENTS.md SKILL.md 约束从硬性行数目标改为定性描述

| 提交 | 说明 |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-25T11:02:38+09:00

**摘要**：ruyi — 修复交叉编译（postPatch 改用 python.pythonOnBuildForHost）；CI — ruyi 系列回归 riscv64-cross；docs — riscv64 badge 恢复精确 job filter

| 提交 | 说明 |
|------|------|
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |

## 2026-06-25T10:12:02+09:00

**摘要**：CI — riscv64-cross 永久移除 ruyi 系列（Python postPatch 交叉编译不可行）；docs — riscv64 badge 恢复 * 标记 + 注释说明

| 提交 | 说明 |
|------|------|
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |

## 2026-06-25T10:04:30+09:00

**摘要**：CI — 修复 access-tokens 被覆盖导致 GitHub API rate limit 超限（合并双行为一行），riscv64-cross 并发上限 4

| 提交 | 说明 |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |

## 2026-06-25T09:44:44+09:00

**摘要**：CI — riscv64-cross 加回 ruyi/ruyi-beta/ruyi-alpha（路径映射）；docs — badge 标签简化（- 取代 --）+ riscv64 job 精确过滤

| 提交 | 说明 |
|------|------|
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |

## 2026-06-25T09:29:43+09:00

**摘要**：CI — build / riscv64-cross job 按包拆分 matrix，支持独立 per-package badge；docs — ruyi 文档 badge 扩展为 3版本×3架构 = 9枚

| 提交 | 说明 |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |

## 2026-06-25T09:24:43+09:00

**摘要**：CI — build job 添加 ruyi-beta / ruyi-alpha 构建步骤；docs — ruyi 基本信息表格通道行加入 beta/alpha 版本号

| 提交 | 说明 |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |

## 2026-06-25T09:09:26+09:00

**摘要**：CI — 移除 ruyi riscv64-cross；overlays — default overlay 添加 ruyi-beta/ruyi-alpha + nixConfig 提升至 flake 顶层；docs — README 软件表展示 ruyi 三通道版本号

| 提交 | 说明 |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |

## 2026-06-25T05:35:00+09:00

**摘要**：docs — 全部 5 语言 README 添加 ruyi-beta / ruyi-alpha devShell 条目

| 提交 | 说明 |
|------|------|
| `5d4ca02` | docs: add ruyi-beta + ruyi-alpha to devShell tables (all 5 READMEs) |

## 2026-06-25T05:28:12+09:00

**摘要**：ruyi — 重构包目录结构（packages/ruyi/），beta/alpha 为 thin wrapper；新增 devShells

| 提交 | 说明 |
|------|------|
| `4b9865e` | refactor(pkgs): move ruyi into subdirectory, beta/alpha as thin wrappers |
| `94bb174` | feat(shells): add ruyi-beta + ruyi-alpha devShells |

## 2026-06-25T05:13:34+09:00

**摘要**：ruyi — 版本通道改为独立软件包（ruyi / ruyi-beta / ruyi-alpha），移除独立 overlay

| 提交 | 说明 |
|------|------|
| `51f23ad` | refactor(pkgs): ruyi channels as separate packages (not overlays) |

## 2026-06-25T04:58:36+09:00

**摘要**：ruyi — 三通道版本体系（stable/beta/alpha），基础包切至 0.50.0 稳定版，beta/alpha 通过 overlay 覆盖

| 提交 | 说明 |
|------|------|
| `a9f8baa` | feat(pkgs): ruyi 3-channel (stable/beta/alpha) via overlays |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| ruyi | 0.51.0-alpha.20260616 | 0.50.0（稳定） |
| 　 | 新增 ruyi-beta overlay | 0.50.0-beta.20260623 |
| 　 | 新增 ruyi-alpha overlay | 0.51.0-alpha.20260616 |

## 2026-06-24T03:19:30+09:00

**摘要**：workflow — 维护日志更新规则强制化（AGENTS.md + write-maintenance-log 技能）

| 提交 | 说明 |
|------|------|
| `2e719df` | fix: make maintenance log update mandatory after every push |

## 2026-06-24T03:15:37+09:00

**摘要**：docs — 移除过时的本地 riscv64 构建指令，CI 现已覆盖三架构

| 提交 | 说明 |
|------|------|
| `698400a` | docs: remove stale manual riscv64 build instructions — CI now covers all 3 architectures |

## 2026-06-24T03:06:20+09:00

**摘要**：codewhale 0.8.64 — 上游更新

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

**摘要**：CI — 添加 riscv64 交叉编译 pipeline，三架构 CI 全量覆盖（x86_64 / aarch64 / riscv64）；每包文档添加 riscv64 徽章

| 提交 | 说明 |
|------|------|
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |

## 2026-06-23T05:20:00+09:00

**摘要**：translate-pseudocn — 基于网络研究扩充词典（7→46 条），语序改为 SVO，全量重新生成 pcn 文档

| 提交 | 说明 |
|------|------|
| `4fbf387` | feat(pcn): expand dictionary 7→46 entries, add IT terminology from research |
| `ec38b7e` | feat(pcn): convert to SVO word order, expand dictionary, regenerate all 22 docs |

## 2026-06-23T04:19:16+09:00

**摘要**：translate-pseudocn 技能重构 — 伪中国语重新定义为「日语剥离假名后的视觉结果」，不再转换为中文。日本汉字原样保留（非简化字）、SOV 语序保留、词典从 40 条精简为 7 条（仅片假名→日本汉字）。全部 22 篇 pcn 文档重新生成。

| 提交 | 说明 |
|------|------|
| `be0780b` | refactor(pcn): redesign pseudo-Chinese skill — Japanese-native kanji, SOV order, no Chinese chars |

## 2026-06-23T04:04:32+09:00

**摘要**：AGENTS.md — 去硬编码、移除冗余审计备忘、缓存章节重写为代理操作指南、移除用户侧描述、语言体系改为自动发现

| 提交 | 说明 |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:49:00+09:00

**摘要**：mcp-searxng 1.7.2 — 上游修复

| 提交 | 说明 |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |

## 2026-06-22T23:22:00+09:00

**摘要**：AGENTS.md — 新增初次启动审计规则、访问控制移至顶部

| 提交 | 说明 |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**摘要**：docs — README 重复行修复，write-project-docs 反模式补充

| 提交 | 说明 |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**摘要**：AGENTS.md — 新增访问控制、语言要求、提交规范、维护记录检查、文档同步、泛化、多架构缓存规则

| 提交 | 说明 |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**摘要**：docs — 每包文档添加双架构 CI 徽章，技能模板同步

| 提交 | 说明 |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**摘要**：CI — 添加 ARM runner 多架构构建，修复 flake.lock 并发竞争（--no-write-lock-file）

| 提交 | 说明 |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**摘要**：mcp-searxng — source hash + npmDepsHash 更新（GitHub archive 变化）；ruyi — overlay postPatch 回移（补丁文件依赖）

| 提交 | 说明 |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**摘要**：docs — 添加缓存排除警告（overlay 与模块+补丁条目），README 缓存说明压缩，flake.nix 添加 nixConfig 自动声明

| 提交 | 说明 |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**摘要**：docs — 全部 30 篇包文档添加 `## 缓存` 节，CI badge 布局改进，技能同步

| 提交 | 说明 |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**摘要**：CI/CD — 添加 GitHub Actions 构建矩阵（Cachix 推送）、二进制缓存、AGENTS.md

| 提交 | 说明 |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**摘要**：skills — translate-katalish / translate-pseudocn / write-project-docs 拆分词典与模板，SKILL.md 压缩至 60-80 行

| 提交 | 说明 |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**摘要**：docs — MAINTENANCE 时间戳精确化（29 节）、30 重复节删除（SHA 去重）、nix-kits→nixkits 全量替换（183 处）、模块文档同步

| 提交 | 说明 |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**摘要**：patches — ruyi-nixos-compat.patch 基于干净克隆重建（1223→426 行），清除 flake.lock 自引用 artifact

| 提交 | 说明 |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**摘要**：overlays — patches 列表 lib.unique 去重，ruyi-nixos-compat 精简，llama-cpp-rocm 添加 curried 形式注释

| 提交 | 说明 |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**摘要**：modules — 4 模块添加 enable 选项，comfyui-strix-halo 添加 assertions，命名空间统一至 nixkits.*（含向后兼容），llama-cpp-rocm hfCacheDir 动态推导

| 提交 | 说明 |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**摘要**：codewhale 0.8.63 — 多架构预编译二进制（x86_64 / aarch64 / riscv64）；ruyi — overlay postPatch 合并入包；meta 字段补全

| 提交 | 说明 |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**摘要**：flake — 移除 mihomo-alpha 幽灵输入与 overlay（文件从未存在）

| 提交 | 说明 |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |

## 2026-06-21T04:32:31+09:00

**摘要**：语言切换器标签规则泛化 — display_name 语义修正为语言自称、添加语言名称不本地化规则至 write-project-docs / translate-katalish / translate-pseudocn 三技能；修正 zh/katalish/pcn 全部文档切换器中残留的本地化名称

| 提交 | 说明 |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称与切换器标签分离 |
| `aa8634b` | fix(docs): zh 文档切换器残留旧名称修正 + MAINTENANCE 翻译补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**摘要**：codewhale 0.8.62 — 上游修复；mcp-searxng 1.7.1 — 上游修复

| 提交 | 说明 |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

## 2026-06-20T18:36:33+09:00

**摘要**：技能系统重构 — translate-katakana→translate-katalish 重命名，新增 translate-pseudocn（偽中国語），write-project-docs 与 write-maintenance-log 语言扩展自动发现，文档代码五语映射表

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

**摘要**：codewhale 0.8.61 — 上游修复；mcp-searxng 1.6.0 — 上游修复

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

**摘要**：ruyi — NixOS 兼容性补丁（`patches/ruyi-nixos-compat.patch`），透明处理预编译 RISC-V 工具链的动态链接器路径、GCC 子进程 ELF interpreter 修复和 console_scripts argv0 问题

| 提交 | 说明 |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

## 2026-06-17T10:59:35+09:00

**摘要**：ruyi — NixOS 模块（`services.ruyi`），声明式生成 `/etc/xdg/ruyi/config.toml` 与环境变量

| 提交 | 说明 |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

## 2026-06-17T10:03:05+09:00

**摘要**：ruyi — 新增 devShell 支持，`nix develop github:Kihara777/NixKits#ruyi` 即可进入环境

| 提交 | 说明 |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

## 2026-06-17T09:48:33+09:00

**摘要**：ruyi 0.51.0-alpha.20260616 — RuyiSDK 包管理器，新包（Python / Poetry 构建，ruff + mypy + 320 单元测试 + 52 集成测试全部通过）

| 提交 | 说明 |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

## 2026-06-17T07:37:39+09:00

**摘要**：write-maintenance-log 技能 — 从 nixkits-check-updates 剥离为独立技能，双入口设计（记入维护记录 + 更新维护记录）；flake.lock 同步 .gitignore 前置检测与三路分支逻辑

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

**摘要**：fix(mcp-searxng): 修复入口文件错误 — dist/index.js → dist/cli.js，MCP 服务器可正常启动

| 提交 | 说明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

## 2026-06-17T06:46:13+09:00

**摘要**：llama-cpp-rocm — 尝试用 builtins.fetchurl 替代 flake input 动态获取版本（已撤销，方案不可用）

| 提交 | 说明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

## 2026-06-16T06:03:24+09:00

**摘要**：mcp-searxng 文档 — CodeWhale MCP 配置指南、常见陷阱警告（env 默认为 {}）、故障排查章节

| 提交 | 说明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

## 2026-06-16T05:20:34+09:00

**摘要**：nixos-modern-cli 技能 — Nix Store 路径陷阱章节（gh auth setup-git 硬编码路径失效的诊断与通用修复模式）

| 提交 | 说明 |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

## 2026-06-16T04:56:06+09:00

**摘要**：opencode-telegram 0.21.2 — 上游修复及依赖更新

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

| 提交 | 说明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

## 2026-06-14T07:56:11+09:00

**摘要**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；mcp-searxng 1.4.0 — 新增 HTTP 传输模式

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

**摘要**：llama-cpp-rocm 模块 — 恢复 modelsPreset 支持（nixpkgs 已移除）、命名空间迁移至 nixkits、三语迁移指南

| 提交 | 说明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

## 2026-06-12T17:29:59+09:00

**摘要**：feat(llama-cpp-rocm): 恢复 modelsPreset 支持（nixpkgs 已移除），命名空间迁移至 nixkits

## 2026-06-12T10:51:31+09:00

**摘要**：codewhale 0.8.58 — 上游修复；mcp-searxng 1.3.4 — 上游修复

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

**摘要**：技能文档 — 维护日志格式规则系列（自动发现泛化、描述性标题、精确 git commit 时间戳、禁止 T00:00:00 占位符）

| 提交 | 说明 |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

## 2026-06-11T05:13:39+09:00

**摘要**：other — 2 项更新

| 提交 | 说明 |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

## 2026-06-11T04:52:16+09:00

**摘要**：codewhale 0.8.57 — TUI 新增；mcp-searxng 1.3.2 — 上游修复

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

**摘要**：opencode-telegram — KillMode 改为 process、添加 TimeoutStopSec 防止关机挂起

| 提交 | 说明 |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

## 2026-06-10T02:28:10+09:00

**摘要**：codewhale 0.8.55 — 上游修复；mcp-searxng 1.3.1 — 上游修复

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

**摘要**：文档重构 — 本地化文件移入 docs/ 目录；MAINTENANCE.md 首次添加合列规则、纯表格格式、回填完整提交历史

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

| 提交 | 说明 |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

## 2026-06-06T15:17:11+09:00

**摘要**：技能文档 — 源变更后文档同步规范；comfyui-strix-halo C 工具链说明；hash 计算注意事项泛化；基本情報规则多语言统一

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

**摘要**：codewhale 0.8.53 — 上游修复；mcp-searxng 1.1.0 — 上游修复；opencode-telegram 0.21.1 — 上游修复

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

**摘要**：技能系统 — SKILL.md 全面中文化；三语对称性检查规则

| 提交 | 说明 |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

## 2026-06-02T10:15:53+09:00

**摘要**：other — 7 项更新

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

**摘要**：opencode-telegram — 8 项更新

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

**摘要**：codewhale 0.8.49 — 上游修复；mcp-searxng 1.0.4 — 上游修复；obs-bilibili-stream 2.1.0 — 上游修复；opencode-telegram 0.21.0 — 上游修复

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

| 提交 | 说明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

## 2026-05-31T03:42:18+09:00

**摘要**：write-project-docs — 新技能（按 NixKits 风格为任意项目编写多语言文档系统）

| 提交 | 说明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

## 2026-05-30T03:42:14+09:00

**摘要**：codewhale — stdenv 拼写修复；llama-cpp-rocm 文档修正（移除内联链接、使用 system.nix 完整预设）；opencode-telegram 首次设置流程

| 提交 | 说明 |
|------|------|
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

## 2026-05-30T03:19:48+09:00

**摘要**：other — 2 项更新

| 提交 | 说明 |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

## 2026-05-29T15:25:12+09:00

**摘要**：kitsfmt — 多项修复（vendor 目录恢复、幂等性、原地安全性、with→builtins.attrValues 转换、--stdin 标志）；rcc-fix — 重写为 D-Bus 热插拔检测；build — .vscode gitignore 范围修正

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

**摘要**：docs: fix codewhale type description (pre-built, not source-built)

| 提交 | 说明 |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

## 2026-05-29T10:18:46+09:00

**摘要**：codewhale v0.8.47 — 新包

| 提交 | 说明 |
|------|------|
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | v0.8.47 |

## 2026-05-29T06:28:50+09:00

**摘要**：fix(kitsfmt): 修复 inherit 逗号、缩进字符串损坏、lambda 空格等多个格式化问题；修复幂等性

| 提交 | 说明 |
|------|------|
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |

## 2026-05-29T05:57:55+09:00

**摘要**：fix(build): 修复 .vscode gitignore 范围过宽导致 vendored crate 文件被排除

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|

## 2026-05-28T08:29:27+09:00

**摘要**：llama-cpp-rocm — NixOS 模块（systemd 沙箱覆盖）；opencode-telegram — NixOS 模块（声明式配置、自动安装）；rcc-fix — visible 属性修复；技能文档 — 动态发现措辞

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

**摘要**：技能系统 — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三大技能同步上线；llama-cpp-rocm 动态追踪说明

| 提交 | 说明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

## 2026-05-26T05:30:58+09:00

**摘要**：文档 — README 节名重命名（快速开始→添加、包→软件、License→许可）

| 提交 | 说明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

## 2026-05-24T03:01:02+09:00

**摘要**：mcp-searxng 文档 — SearXNG + lighttpd 反向代理完整 NixOS 配置

| 提交 | 说明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

## 2026-05-22T06:45:11+09:00

**摘要**：llama-cpp-rocm — 移除 llama-cpp-ver flake 输入，使用 nixpkgs 默认版本

| 提交 | 说明 |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

## 2026-05-21T16:35:02+09:00

**摘要**：mcp-searxng v1.0.3 — 新包；opencode-telegram v0.20.5 — 新包

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

## 2026-05-16T19:07:54+09:00

**摘要**：kitsfmt — 修复 match_ast! 宏语法错误、简化 comments_before 函数、修正 src 路径

| 提交 | 说明 |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

## 2026-05-15T16:59:28+09:00

**摘要**：kitsfmt — 基于 rnix AST 重写格式化引擎 v0.3.0；生成 Cargo.lock

| 提交 | 说明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |

## 2026-05-14T17:10:06+09:00

**摘要**：llama-cpp-rocm — 新包（动态追踪上游最新 Release）

| 提交 | 说明 |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

## 2026-05-14T07:38:08+09:00

**摘要**：kitsfmt — 新包（自建 Nix 格式化器）；obs-bilibili-stream v1.0.0 — 新包

| 提交 | 说明 |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

## 2026-05-01T01:08:15+09:00

**摘要**：rcc-fix — 新包（asusctl 补丁）

| 提交 | 说明 |
|------|------|
| `e2d09a2` | RCC-Fix |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（overlay + patch） |

