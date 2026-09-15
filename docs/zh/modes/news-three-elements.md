# 新闻三要素模式 (Agent 预设)

中文 | [English](../../en/modes/news-three-elements.md) | [日本語](../../ja/modes/news-three-elements.md)  | [偽中国語](../../pcn/modes/news-three-elements.md)

> 派生自极简模式的**只读**创作预设：以真实新闻格式编造带「新闻三要素」的俄式快讯，会话初始化即在线上抓取技能全包。

## 基本信息

| 项目 | 值 |
|------|-----|
| 模式 id | `news-three-elements` |
| 分发方式 | **独立包** `dsh-preset-news-three-elements`（`packages/dsh-preset-news-three-elements.nix`），模块把 `$out/share/dsh-agent-presets` 注册为 roster 的额外预设根 |
| 开启选项 | `nixkits.dsh.presets.newsThreeElements = true` |
| 可选包覆盖 | `nixkits.dsh.presets.newsThreeElementsPackage`（默认 `pkgs.dsh-preset-news-three-elements`） |
| 派生自 | 极简模式（随 dsh 分发的 `minimal` 预设） |
| 技能依赖 | 仓库 `skills/news-three-elements/`（会话启动在线获取，内置副本兜底） |

## 行为

**综合塔斯社、Meduza、iStories 电** —— 据本仓库工程部门通报，该模式只做一件事：按技能编造快讯。其余行为如下：

- **只读**：只挂查看类工具（`read`、`read_image`、`glob`、`grep`、`web_search`、`web_fetch`、`skill`、`ask_user_question`）；`write` / `edit` 虽在工具表中，调用一律被 `readonly-gate` 以通讯社文风拒绝（白名单外默认拒绝，未来新增工具也不会意外放行）。
- **在线技能包**：会话启动即抓取仓库 `skills/news-three-elements/` 全包（5 文件、8 秒上限；失败按 0/30/120 秒重试，长会话每 6 小时复查），先注册本地最新副本（缓存优先于内置快照）。技能包只读挂载，快讯不落盘。
- **开场问答**：会话初始化完成后弹出三选一（客户端另带自定义输入），选择经 `agent.followup()` 成为本会话第一条用户消息。
- **语言审查**：非简体中文的请求一律拒绝（无汉字 / 含假名 / 含谚文由插件硬检测，简体与繁体的判读交给模型）。回绝以中文通讯社文风写就，其后**《好心》地附上用户所用语言的本地化版本**——同一条回绝的译文，同样强调「我们从不制造 FAKE NEWS！！」与自称；同时暗示对方去下载三位制作人的作品，或下载「绿色的猫头鹰」（语境合适时可简称「绿毛鸡」）软件学中文。

## 组合结构

| 行 | 来源 | 作用 |
|------|------|------|
| `persona`（`complete: true`） | dsh 内置 | 唯一提示词来源：只读边界、开场暗号表、素材共创、拒绝话术 |
| `tool-fs` / `tool-fs-search` / `tool-web` / `tool-skill` / `tool-ask-user` | dsh 内置 | 只读表面 |
| `news-skill` / `news-opening` / `news-language` / `readonly-gate` | 本包 `plugins/*.js` | 在线抓取、开场问答、语言门、只读守卫 |

包内插件以**相对行名**（`./plugins/*.js`）挂载——组合的 `baseUrl` 即预设目录，且插件只依赖 Node 内置模块，故整目录放在 store 里也能解析，无需 node_modules。

## 安装

```nix
{
  nixkits.dsh.presets = {
    newsThreeElements = true;
    # 可选：换用自建/覆盖的预设包
    # newsThreeElementsPackage = pkgs.dsh-preset-news-three-elements;
  };
}
```

`nix flake check` 通过、`nixos apply` 完成后，会话模式选择器立即出现「新闻三要素模式」。

## 注意

- **不复制、不落盘**：预设从包的 store 路径直接读取（`trust: system`），`$DSH_HOME/.agent-presets` 下**没有**它的副本；升级即换新，无需重新播种。配置根先于用户根被扫描，因此同名 id 以本包为准。
- **要改动它**：用 roster 的 `copy()`（或手工复制目录）另存为一个新 id 的用户预设，改副本；直接放一份同名目录到用户根不会生效。
- 包内插件 `news-skill` 会向 `$DSH_HOME/.cache/news-three-elements/` 写入抓取到的技能包，这是它唯一的写操作。
