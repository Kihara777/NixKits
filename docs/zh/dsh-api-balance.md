# dsh-api-balance

中文 | [English](../en/dsh-api-balance.md) | [日本語](../ja/dsh-api-balance.md)  | [偽中国語](../pcn/dsh-api-balance.md)

API 用量余额插件（DeepSeek Harness）——在 webui 用量圆圈（发送按钮左侧的上下文已用显示）的弹出面板中提供「用量 / 余额」标签切换。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | DSH Host + Client 插件（npm 包） |
| npm 名 | `@kihara777/dsh-api-balance` |
| 版本 | `0.1.0` |
| 许可 | MIT |
| 数据源 | DeepSeek 官方 `GET /user/balance`（API key 认证）+ 平台控制台用量接口（平台会话令牌认证） |

## 功能

- **用量**：原有内容（上下文占用与细分）
- **余额**：当前 API KEY 的账户信息（key 尾号、余额是否充足、各币种总余额 / 充值余额 / 赠送余额），并含当日 / 当月 / 30 日内消耗（金额 + token + 分模型明细）与按日 / 按月用量图表
- Host 端 30 秒 TTL 缓存；API key 按 `apiKeyEnv`（默认 `DEEPSEEK_API_KEY`）走 `credentials` 服务解析，回退进程环境变量

### 平台令牌获取（两级，全自动优先）

- **本机浏览器自动扫描（默认开启）**：host 直接读取本机 Chromium 系浏览器（Edge / Chrome / Brave / Chromium / Vivaldi / Opera，各 Profile）的 `Local Storage/leveldb`——先按 LevelDB 表结构精确解析（footer → index → 数据块 → snappy 解压 → 条目遍历）读出 `userToken`，解析失败时回退裸字节启发式候选——命中即落盘 `$DSH_HOME/api-balance-token`（0600）。用户在本机浏览器登录过平台即无感获取；节流默认每 6 小时最多扫描一次（`browserScanIntervalMs` 可配，`browserScan = false` 关闭），令牌失效（40003/401）后下次查询立即重扫。
- **未登录检测与登录引导**：扫描未命中时面板自动弹出「未检测到平台登录」提示——「前往登录」在新标签页打开登录页并轮询自动拾取令牌；手动输入令牌仅作为弹窗内的二级备选（不想登录时使用）。已连接后面板显示灰显「✓ 已登录」按钮与令牌来源（本机浏览器自动获取 / 手动连接）；每次手动刷新在无令牌时也会自动快扫检查登录态，无需点任何按钮。

### 界面设置（⚙ 设置 → 界面）

- **底部统计条**：默认超出宽度以省略号截断（悬停气泡显示完整内容）；开启「越界内容横向滚动」后改为横向滚动并隐藏滚动条，越界内容可见可滚动。
- **回车键行为**：DSH 默认为回车发送、Shift+回车换行；开启「回车换行 · Shift+回车发送」后互换（仅作用于会话输入框，不干扰其他输入）。两项设置均持久化于浏览器 localStorage。
- **移动端会话切换不弹键盘**：触屏设备上经侧栏切换会话时阻止输入框自动聚焦，避免软键盘自动弹出；点按输入框仍正常输入。默认开启，可在此关闭。

### 峰谷计费标记

DeepSeek 现行峰谷计费规则（官方定价页脚注）为：**高峰 = 周一至周五北京时间 09:00–12:00、14:00–18:00，其余时间（含周末全天）按低谷价**。处于高峰时段时：用量圈（发送键左侧的环形按钮）与用量图表以红色显示，图表标题旁出现「峰时计费」红色标记（悬停显示时段说明）；页面刷新问候与手动「刷新数据」的问候音效之后追加高峰提示（语音包 `peak` 片段优先，无则 TTS 兜底）。

### 语音播报

点击用量图表「按日 / 按月」切换按钮即播报对应视图的语音用量（语音包片段 + TTS 数字拼接），内容为：入（缓存未命中输入）、缓存命中、出、金额（币种）——与官方用量页的分项口径一致；播报语言与音色跟随 DSH 界面语言（zh / en）。「⚙ 设置 → 语音」标签页提供：

- 自动播报开关（余额低于阈值时提醒，30 分钟限流）
- TTS 后端选择（浏览器内置语音 / 自定义 TTS API，后者经 host 代理调用规避跨域，URL 模板占位符 `{text}` `{lang}` `{rate}`）
- 语音包库管理（zip 导入多个包、列表切换使用 / 多选移除；每个语音包可展开「语音试听」，逐条试听该包全部支持音频；保存于 `$DSH_HOME/api-balance-voicepack/`，全设备共享）
- 「语音包管理」次级菜单中的制作器（浏览器录音或导入音频，录音时展示可视化浮窗与示例文本，可跨语言录制并打包下载 / 编译应用）

#### 语音包格式指南

语音包为 **zip 压缩包**（方便部署与分享），内含 `manifest.json` 清单与音频文件；面板「⚙ 设置 → 语音」选择 .zip 导入即启用，清除即恢复默认 TTS 整句播报。

zip 结构：

```
voice-pack.zip
├── manifest.json
└── audio/
    ├── dead.mp3
    ├── low.mp3
    └── …
```

```json
// manifest.json
{
  "format": "dsh-api-balance-voice-pack",
  "version": 1,
  "name": "我的语音包",
  "lang": "zh-CN",
  "segments": {
    "dead": "audio/dead.mp3",
    "low": "audio/low.mp3",
    "peak": "audio/peak.mp3",
    "today": "audio/today.mp3",
    "month": "audio/month.mp3",
    "inLabel": "audio/inLabel.mp3",
    "outLabel": "audio/outLabel.mp3",
    "cacheHitLabel": "audio/cacheHitLabel.mp3",
    "costLabel": "audio/costLabel.mp3",
    "tokenUnit": "audio/tokenUnit.mp3",
    "suffix": "audio/suffix.mp3",
    // 可选：问候音效数组（页面刷新时随机播放一个）
    "greetings": ["audio/greet0.mp3", "audio/greet1.mp3"]
  }
}
```

| 片段 | 用途 |
|------|------|
| `dead` | 余额不可用提醒整句 |
| `low` | 低余额提醒整句 |
| `peak` | 高峰计费时段提示（问候音效后追加） |
| `today` | 「当日消耗」播报前缀 |
| `month` | 「当月消耗」播报前缀 |
| `inLabel` | 「入」标签 |
| `outLabel` | 「出」标签 |
| `cacheHitLabel` | 「缓存命中」标签 |
| `costLabel` | 「金额」标签 |
| `tokenUnit` | 数字后的单位（如「个 token」），可复用 |
| `suffix` | 播报结尾 |

全部片段可选：缺失片段在播报时以 TTS 兜底。面板呈现与官方用量页口径一致：「入」只计缓存未命中的输入，缓存命中单列（token 与金额数据均来自官方接口的日粒度桶，不做二次合并）。制作器内的示例文本与默认 TTS 兜底文案一字不差（保证录制的语音包贴近默认 TTS 体验）；动态数字（token 数量、金额与币种）由当前 TTS 后端合成后按「包片段 + TTS 数字」顺序拼接。可选 `greetings` 为文件路径数组（0–32 个）：语音播报开启时，每次刷新页面随机播放其中一个作为问候/放置音效；无问候音频时改用 TTS 问候语池随机播放。

**制作与分享**：「设置 → 语音 → 语音包管理」→「制作语音包」进入制作器——先选择语音包语言（zh-CN / en / ja，决定示例文本与清单 `lang`，可跨语言录制）；片段逐段用浏览器麦克风录音，问候语按列表逐条录制（「添加问候」扩列、✕ 移除槽位，示例文本对应默认 TTS 问候池）；或导入本地音频文件；录音时右下角弹出可视化浮窗（电平表 + 计时 + 示例文本 + 停止/放弃）。完成后「打包下载」生成 zip 分享，或「编译并应用」导入本机库并激活；已导入语音包时，首次编辑会弹出覆盖提示，确认后方可继续（会话内确认一次）。

**约束**：片段键 `[A-Za-z0-9_-]{1,32}`；segments ≤ 32 个、greetings ≤ 32 个（zip 条目总数 ≤ 64）、单音频 ≤ 2 MB；音频建议 mp3 / wav / ogg / webm，单段 2 秒以内、22.05/44.1 kHz 单声道。动态部分（余额数字、token 数量等）不在包内——由当前 TTS 后端（浏览器内置或自定义 TTS API，后者经 host 代理规避跨域）实时合成，按「包片段 + TTS 数字」顺序拼接为完整播报。

## 安装

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-api-balance;
    id = "api-balance";
    name = "@kihara777/dsh-api-balance";
    # config 可选：
    #   apiKeyEnv = "DEEPSEEK_API_KEY";   # credential-ref
    #   baseURL = "https://api.deepseek.com";
    #   browserScan = true;               # 本机浏览器自动扫描
    #   browserScanIntervalMs = 21600000; # 扫描节流（默认 6 小时）
  }];
}
```

## 注意

- 余额数据来自 DeepSeek 官方接口，用量数据来自平台控制台内部接口——两者认证方式不同（API key / 平台会话令牌），任一认证缺失时对应视图显示未登录态而非报错。
- 自动扫描只读取本机浏览器已登录的令牌，不采集任何浏览器外数据；令牌文件以 `0600` 权限落盘。
