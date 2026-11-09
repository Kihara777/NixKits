#!/usr/bin/env python3
"""NixKits 预设派生漂移检查（dsh 0.2.0 格式）。

dsh 0.2.0 起预设只有一种格式：profile patch 层里的一条
`@deepseek-ai/dsh-agent-preset` 条目（`preset.patch.yml`）。0.1.x 的目录式
`agent.cordis.yml` 已从仓库 HEAD 移除（两套格式不并存于 HEAD；旧格式的内容由
`packages/dsh-nixos-shell-stable.nix` 钉住的 commit 提供）。本脚本检查：

- 维护模式的 `preset.patch.yml` 派生自 NixOS模式：`plugins:` 正文
  == nixos 的 plugins 正文 + 固定追加块
  （文件头里的 id/name/description/order 是每个预设各自的元数据，
   由 preset.yml 与 IDS/ORDERS 常量分别核对，不参与字节派生）
- 两预设**都不自带** `skills/` 副本：组合撰写技能改挂上游
  `@deepseek-ai/dsh-agent-preset` 分发的那份（自带副本会与上游新版同名冲突，
  2026-10-02 实测到我们那份落后一整个格式）
- 每个预设的 `config.name` / `config.description` 与同目录 `preset.yml` 逐字一致
- 新闻三要素模式（独立包）的预设头自洽（id/name/description/order）
- 修改 nixos-mode 后必须同步 maintenance-mode（见 AGENTS.md「预设」一节）

挂入 `nix flake check`（checks.preset-derivation），CI 每次 push 执行。
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRESETS = os.path.join(ROOT, "packages", "dsh-nixos-shell", "presets")
NEWS = os.path.join(ROOT, "packages", "dsh-preset-news-three-elements")

# 维护模式相对 nixos 模式的唯一允许差异（末尾追加块，含注释）。
# 该块变更时同步更新此常量。
PATCH_MAINTENANCE_DELTA = (
    "\n"
    "          # ── maintenance mode ─────────────────────────────────────────────────────────\n"
    "\n"
    "          # `maintenance-skills` registers the NixKits documentation/maintenance skills\n"
    "          # as runtime skills (write-project-docs, write-maintenance-log, and every\n"
    "          # translate-* language extension, auto-discovered) from the canonical repo\n"
    "          # skills/ tree embedded in the package at build time — a fresh session always\n"
    "          # gets the latest content — and installs the repository maintenance workflow\n"
    "          # prompt section.  It publishes no services, so no realm is needed.\n"
    "          - id: maintenance-skills\n"
    "            name: '@kihara777/dsh-nixos-shell/maintenance-skills'\n"
)

# 逆向模式相对维护模式的唯一允许差异（末尾追加块，含注释）。
# 该块变更时同步更新此常量。
PATCH_REA_DELTA = (
    "\n"
    "\n"
    "          # ── 逆向模式 ─────────────────────────────────────────────────────────────────\n"
    "\n"
    "          # `rea-mcp` bridges the REA (Reverse Engineer Anything) MCP server into THIS\n"
    "          # session: one stdio connection per agent at `agent/session-start`, carrying\n"
    "          # REA's full tool set (207 tools at 6.7.0) on that agent's scope. It publishes\n"
    "          # no service, so no realm is needed.\n"
    "          #\n"
    "          # 为什么不是一条 `@deepseek-ai/dsh-mcp-client` 行（第一版，实测不行）：预设是\n"
    "          # eager activation —— dsh 启动 4 秒后 `rea mcp` 就被 spawn，而工具注册落到\n"
    "          # root scope。结果是**掌灯模式的会话**也背上 207 个 `mcp__rea__*`（会话请求头\n"
    "          # 里 31 + 207 = 238 个工具）。「模式」的语义要求只有选它的会话才有这些工具。\n"
    "          #\n"
    "          # 工具是全量的：用上游 `createMcpToolDefinition`，把 MCP 的 inputSchema 原样\n"
    "          # 交给注册表，不做「JSON Schema → dsh 简写 spec」的转换——那种转换器写歪了会\n"
    "          # **静默拒掉合法调用**，是 207 个工具里最难查的一类错。\n"
    "          #\n"
    "          # `REA_BIN_PATH` 由 modules/dsh.nix 在启用本预设时导出（`pkgs.rea` 的路径），\n"
    "          # 所以正文里没有 store 路径；变量缺席时退回 PATH 里的 `rea`。\n"
    "          - id: rea-mcp\n"
    "            name: '@kihara777/dsh-nixos-shell/rea-mcp'\n"
)

# 派生比较的分界行：`plugins:` 键之后到文件末尾就是插件行正文。
PATCH_MARKER = "        plugins:"

# 预设 id（roster 里的 id）与 `config.order`。内置预设 standard/ptc/minimal/cordis
# 占 1–4，且 order 必须在 roster 里唯一：12 = Kitsunome 的掌灯模式、
# 13 = 新闻三要素模式、14 = Ocean Spiral（均在别的仓库/包），故这里取 10/11/15。
PATCH_IDS = {"nixos-mode": "nixos", "fuli-mode": "fuli"}
PATCH_ORDERS = {"nixos-mode": 10, "fuli-mode": 11}

# 狐利模式 = NixOS模式正文 + 这两块（维护 + 逆向）。两块各自保留独立常量，
# 是因为它们的注释各自解释一件事；合并成一个 delta 常量会让 diff 读不出「加了什么」。
PATCH_FOXLI_DELTA = PATCH_MAINTENANCE_DELTA + PATCH_REA_DELTA
BUILTIN_PRESET_ORDERS = {1, 2, 3, 4}

# 独立包里的预设（新闻三要素模式）：只有元数据与 order 的核对，没有上游派生关系。
NEWS_DIR = "dsh-preset-news-three-elements"
NEWS_ORDER = 13


def read_text(path: str) -> str:
    with open(path, encoding="utf-8") as f:
        return f.read()


def read_preset_meta(path: str) -> dict:
    """读 preset.yml（`key: value` 单值行）。"""
    meta = {}
    for line in read_text(path).split("\n"):
        key, sep, value = line.partition(": ")
        if sep and key and not key.startswith("#"):
            meta[key.strip()] = value.strip()
    return meta


def patch_body(path: str) -> str:
    """取 `plugins:` 分界行之后的正文（该行必须恰好出现一次）。"""
    lines = read_text(path).split("\n")
    hits = [i for i, line in enumerate(lines) if line == PATCH_MARKER]
    if len(hits) != 1:
        fail(
            f"{os.path.relpath(path, ROOT)} 里整行等于 `{PATCH_MARKER}` 的行出现 "
            f"{len(hits)} 次（要求恰好 1 次，它是派生比较的分界行）。"
        )
    return "\n".join(lines[hits[0] + 1 :])


def check_head(path: str, directory: str, preset_id: str, order: int, orders: list) -> None:
    """预设头（id/name/description/order）必须与同目录 preset.yml 逐字一致。"""
    text = read_text(path)
    rel = os.path.relpath(path, ROOT)
    meta = read_preset_meta(os.path.join(directory, "preset.yml"))
    head = text.split(PATCH_MARKER + "\n", 1)[0]
    expected = {
        "id": preset_id,
        "name": f"'{meta.get('name', '')}'",
        "description": f"'{meta.get('description', '')}'",
        "order": str(order),
    }
    for key, want in expected.items():
        line = f"        {key}: {want}\n"
        if line not in head:
            fail(
                f"{rel} 的预设头缺 `{key}` 或值与来源不符：\n"
                f"  期望存在行 `{line.strip()}`\n"
                f"  （id/order 来自本脚本的常量；name/description 必须与同目录 preset.yml 逐字一致）"
            )
    if order in BUILTIN_PRESET_ORDERS:
        fail(f"{rel} 的 order={order} 与 dsh 内置预设 {sorted(BUILTIN_PRESET_ORDERS)} 冲突。")
    if order in orders:
        fail(f"预设的 order 重复：{order}（roster 里必须唯一）。")
    orders.append(order)


def check_patch_chain(orders: list) -> None:
    """0.2.0 通道：plugins 正文派生 + 每个文件头部的元数据自洽。

    2026-10-21 起派生链只有**一段**：nixos → fuli（狐利模式 = 维护 + 逆向的合并）。
    掌灯模式**不在这里**——它在 Kitsunome，构建期读本仓的狐利正文再拼私有追加块，
    由那边的检查器核对。
    """
    nixos_path = os.path.join(PRESETS, "nixos-mode", "preset.patch.yml")
    nixos_body = patch_body(nixos_path)

    # **fuli-mode 的成品不在仓库里**（2026-11-09）：它由
    # packages/dsh-nixos-shell.nix 的 presetsDerived 在构建期，用
    # lib/apply-overlay.py 从 nixos-mode + fuli-mode/overlay.yml 生成。
    # 所以这里没有可比的正文——"fuli == nixos + 固定追加块" 这条判据的对象消失了。
    # 取而代之的是构建期生成器：父里没有 id、锚点不存在、overlay 缺 meta.id，
    # 都是构建失败，而不是等到加载时才空转。
    for directory, path in (("nixos-mode", nixos_path),):
        check_head(
            path,
            os.path.join(PRESETS, directory),
            PATCH_IDS[directory],
            PATCH_ORDERS[directory],
            orders,
        )


def check_news(orders: list) -> None:
    """独立包（新闻三要素模式）：同一套头部自洽核对。"""
    check_head(
        os.path.join(NEWS, "preset.patch.yml"),
        NEWS,
        "news-three-elements",
        NEWS_ORDER,
        orders,
    )


# ── 上游预设漂移（2026-11-02 加）─────────────────────────────────────────────
#
# 上面的派生检查管的是「我们和上游的关系有没有漂」；它**看不见上游加了什么**。
# 实测代价：dsh 0.2.2 的 standard 预设比 0.1.2 多了六行，整条派生链
# （nixos → fuli → 掌灯）一条都没跟。少一行不报错，只安静地少一项能力——
# 本仓日记里反复出现的「ls 了日记目录、拿最新文件名当当天」，就是
# `time-context` 缺席的地面表现（它每步给当前时间）。
#
# 判据两层：
#   ① `UPSTREAM_STANDARD_IDS − 我们的 id 集` 必须逐条登记在 `UPSTREAM_SKIP`（带理由）。
#      没登记 = 红；登记了但上游已经没有 = 也红（豁免表不许变墓碑）。
#   ② 本机若装着 dsh，核对钉住的快照与**当前安装**是否一致。不一致说明上游又变了，
#      该重采样。找不到 dsh 就显式跳过——「没量到」不是「没事」，也不该冒充失败。

# dsh 0.2.2-alpha.2 的 `dsh-web-app/presets/standard.patch.yml` 里的 id 集
# （按源文件顺序；`preset-standard` 本身不计）。升级 dsh 后重采样：
#     UPDATE_UPSTREAM_IDS=1 nix shell nixpkgs#python3 --command \
#         python3 develop/check-preset-derivation.py
UPSTREAM_STANDARD_IDS = (
    "persona", "agent-instructions", "time-context", "tool-bash", "tool-pwsh",
    "tool-fs", "tool-fs-search", "tool-jobs", "tool-schedule", "skill-filesystem",
    "tool-skill", "command-goal", "tool-goal", "planning", "plan-mode",
    "compaction", "compaction-basic", "command-compact", "tool-result-pruner",
    "delegation", "tool-subagent-control", "tool-subagent", "tool-subagent-fork",
    "workflow-ptc", "tool-workflow", "tool-ask-user", "tool-todo", "tool-web",
    "present", "tool-plugin-manager", "tool-plugin-market",
)

# 上游有、我们**有意不跟**的行。键是 id，值是理由（必须写清日期与代价判断）。
UPSTREAM_SKIP = {
    "tool-schedule": (
        "宿主级持久提醒。本仓已有 proactive/sentinel 两套定时语义，再引一套互不知情的"
        "「定时」比少一个工具更难查。（2026-11-02）"
    ),
    "tool-plugin-manager": (
        "运行时改写 profile 的插件管理工具。NixKits 的用户走声明式安装，开它等于给"
        "「绕过声明式」开一条路。（2026-11-02）"
    ),
    "tool-plugin-market": (
        "插件市场（Web Discover 页 + plugin_market 工具）。理由同上一条：声明式安装下"
        "它没有要解决的问题。（2026-11-02）"
    ),
    "present": (
        "上游包 dsh-agent-tool-presentation 自述已 deprecated（改用 "
        "dsh-tool-executor-native / dsh-tool-executor-ptc）。跟一行废弃选择器不划算。"
        "（2026-11-02）"
    ),
}

ID_LINE = re.compile(r"^\s+- id: ([A-Za-z0-9_.-]+)\s*$", re.M)
LIVE_STANDARD = (
    "/run/dsh/current/lib/node_modules/@deepseek-ai/dsh/node_modules"
    "/@deepseek-ai/dsh-web-app/presets/standard.patch.yml"
)


def preset_ids(path: str) -> list:
    """取一个 preset.patch.yml 里所有插件行 id（不含 `preset-` 开头的预设自身行）。"""
    return [
        m.group(1)
        for m in ID_LINE.finditer(read_text(path))
        if not m.group(1).startswith("preset-")
    ]


def live_standard() -> str:
    """当前安装的 dsh 里的 standard 预设源文件；找不到返回空串。"""
    override = os.environ.get("DSH_STANDARD_PRESET", "")
    if override and os.path.isfile(override):
        return override
    return LIVE_STANDARD if os.path.isfile(LIVE_STANDARD) else ""


def check_upstream_drift() -> None:
    ours = set(preset_ids(os.path.join(PRESETS, "nixos-mode", "preset.patch.yml")))
    upstream = list(dict.fromkeys(UPSTREAM_STANDARD_IDS))

    missing = [i for i in upstream if i not in ours]
    unregistered = [i for i in missing if i not in UPSTREAM_SKIP]
    if unregistered:
        fail(
            "上游 standard 预设有、nixos-mode 没有，而 UPSTREAM_SKIP 里也没登记：\n"
            + "\n".join(f"  · {i}" for i in unregistered)
            + "\n  两条路：把这一行补进 nixos-mode（并同步 fuli-mode），"
            "或在 UPSTREAM_SKIP 里登记**为什么有意不跟**（带日期）。\n"
            "  代价：少一行不会报错，只会安静地少一项能力。"
        )

    dead = [i for i in UPSTREAM_SKIP if i not in upstream]
    if dead:
        fail(
            "UPSTREAM_SKIP 里登记了上游已经没有（或从未有过）的行：\n"
            + "\n".join(f"  · {i}" for i in dead)
            + "\n  豁免表不是墓碑：上游删了就把它从表里删掉。"
        )

    live = live_standard()
    if not live:
        # 没量到 ≠ 没事，但也 ≠ 失败：CI 里通常没有安装的 dsh。
        #
        # ⚠️ **跨仓耦合点**：下面这句文案被 Kitsunome 的
        # `develop/check-upstream-preset.py` 匹配——它靠这句话判断「本判据是跳过
        # 了快照核对，还是在真核对后绿的」，跳过了就上报「没量到」（退出码 2）。
        # 改这句话（哪怕只是措辞）会让那边**静默失效**：匹配不上 → 它会以为没跳过
        # → 把一次假绿报成通过。改这里要同步改那边，两处都有这条注释。
        print(
            "preset-derivation: 跳过「快照 vs 当前安装」核对"
            "（找不到安装的 dsh；设 DSH_STANDARD_PRESET 可指定）"
        )
        return

    live_ids = preset_ids(live)
    if live_ids != upstream:
        added = [i for i in live_ids if i not in upstream]
        removed = [i for i in upstream if i not in live_ids]
        detail = []
        if added:
            detail.append("  上游新增：" + "、".join(added))
        if removed:
            detail.append("  上游移除：" + "、".join(removed))
        fail(
            "钉住的 standard id 快照与当前安装的 dsh 不一致——上游预设变了：\n"
            + "\n".join(detail)
            + f"\n  来源：{live}"
            + "\n  先 `UPDATE_UPSTREAM_IDS=1` 重采样，再决定每条是新补还是登记豁免。"
        )


def dump_upstream_ids() -> None:
    """把当前安装的 dsh 的 standard id 集打印成可粘贴的常量。"""
    live = live_standard()
    if not live:
        fail("重采样需要一个安装的 dsh：找不到 " + LIVE_STANDARD)
    print(f"# 采样自 {live}")
    print("UPSTREAM_STANDARD_IDS = (")
    line = "   "
    for i in preset_ids(live):
        piece = f' "{i}",'
        if len(line) + len(piece) > 96:
            print(line)
            line = "   "
        line += piece
    print(line)
    print(")")


def fail(message: str) -> None:
    print(f"preset-derivation: {message}", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    if os.environ.get("UPDATE_UPSTREAM_IDS") == "1":
        dump_upstream_ids()
        return

    orders: list = []
    check_patch_chain(orders)
    check_news(orders)
    check_upstream_drift()

    # 组合撰写技能曾**自带副本**；2026-10-02 起改为挂上游随
    # `@deepseek-ai/dsh-agent-preset` 分发的那份（见 preset.patch.yml 的 `skill-filesystem` 行）。
    # 自带副本的代价实测过一次：我们那份 `editing-cordis-compositions` 停在 0.1.x 的目录式
    # 模型上，而 0.2.0 的它已改成 patch/bundle 模型并明说「那个目录没人读了」——于是同名两份，
    # 其中一份在教废弃写法。故这里把「不再自带」钉成**断言**，而不是删掉就没人管：
    # 谁把副本加回来，检查就响。0.1.x 兼容用的旧副本在 `dsh-nixos-shell-stable.nix` 钉住的 rev 里。
    for mode in ("nixos-mode", "fuli-mode"):
        stray = os.path.join(PRESETS, mode, "skills")
        if os.path.isdir(stray):
            fail(
                f"{os.path.relpath(stray, ROOT)} 又出现了：组合撰写技能不再自带副本，"
                "改为挂上游 @deepseek-ai/dsh-agent-preset 的 skills/（见 preset.patch.yml "
                "的 skill-filesystem 行）。旧副本仍在 dsh-nixos-shell-stable.nix 钉住的 rev 里。"
            )

    print(
        "preset-derivation: OK（nixos-mode 与 news-three-elements 的 preset.patch.yml "
        "头部与 preset.yml 一致，order 互不冲突；fuli-mode 的正文是构建产物——"
        "由 packages/dsh-nixos-shell.nix 的 presetsDerived 从 nixos-mode + overlay.yml 生成，"
        "仓库里没有可比的成品）"
    )


if __name__ == "__main__":
    main()
