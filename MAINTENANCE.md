# 维护日志

中文 | [English](docs/MAINTENANCE.en.md) | [日本語](docs/MAINTENANCE.ja.md)  | [偽中国語](docs/MAINTENANCE.pcn.md)
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

