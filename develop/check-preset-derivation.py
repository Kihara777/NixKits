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
    "          # `mcp-rea` connects the NixKits `pkgs.rea` binary (REA — Reverse Engineer\n"
    "          # Anything) as a stdio MCP server; its tools appear as `mcp__rea__*`.\n"
    "          #\n"
    "          # 全量注册是有意的：`dsh-mcp-client` **没有**工具白名单/过滤选项（核过它的\n"
    "          # README 与 config 字段表），所以「只挑一部分」的唯一办法是不挂这条行。本预设\n"
    "          # 面向「我要全部逆向能力」的场景 —— 工具表很长是它的代价，不是缺陷。\n"
    "          # 规模是可量的：`rea mcp` 一次 `tools/list` 实测 **207 个工具**（6.7.0），\n"
    "          # CLI 侧 153 个命令（`rea --llms`）。\n"
    "          #\n"
    "          # `command` 从 `REA_BIN_PATH` 解析：modules/dsh.nix 在启用本预设时把它设成\n"
    "          # `pkgs.rea` 的 store 路径，因此这份正文里不出现任何 store 路径（正文要能\n"
    "          # 逐字节派生，也要能在没有 Nix 的机器上读）。变量缺席时退回 PATH 里的 `rea`，\n"
    "          # 让手工装配也能跑。\n"
    "          #\n"
    "          # `failOnStartupError: false`：REA 起不来时整份预设不该跟着变 broken ——\n"
    "          # 维护模式的其余能力仍然可用，缺的只是 mcp__rea__* 这一组工具。\n"
    "          - id: mcp-rea\n"
    "            name: '@deepseek-ai/dsh-mcp-client'\n"
    "            config:\n"
    "              serverName: rea\n"
    "              transport: stdio\n"
    "              command: !!js \"(process.env.REA_BIN_PATH || 'rea')\"\n"
    "              args: ['mcp']\n"
    "              failOnStartupError: false\n"
)

# 派生比较的分界行：`plugins:` 键之后到文件末尾就是插件行正文。
PATCH_MARKER = "        plugins:"

# 预设 id（roster 里的 id）与 `config.order`。内置预设 standard/ptc/minimal/cordis
# 占 1–4，且 order 必须在 roster 里唯一：12 = Kitsunome 的掌灯模式、
# 13 = 新闻三要素模式、14 = Ocean Spiral（均在别的仓库/包），故这里取 10/11/15。
PATCH_IDS = {"nixos-mode": "nixos", "maintenance-mode": "maintenance", "rea-mode": "rea"}
PATCH_ORDERS = {"nixos-mode": 10, "maintenance-mode": 11, "rea-mode": 15}
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
    """0.2.0 通道：plugins 正文派生链 + 每个文件头部的元数据自洽。

    派生链是**三段**：nixos → maintenance → rea。逐段核对，不是「三者各自独立」——
    改 nixos-mode 而漏了维护模式时，第一段先响；只改了维护模式而漏了逆向模式时，
    第二段响。这正是「维护模式必须完整派生」那条仓库规矩的延长线。
    """
    nixos_path = os.path.join(PRESETS, "nixos-mode", "preset.patch.yml")
    maint_path = os.path.join(PRESETS, "maintenance-mode", "preset.patch.yml")
    rea_path = os.path.join(PRESETS, "rea-mode", "preset.patch.yml")

    nixos_body = patch_body(nixos_path)
    maint_body = patch_body(maint_path)
    rea_body = patch_body(rea_path)
    if maint_body != nixos_body + PATCH_MAINTENANCE_DELTA:
        fail(
            "maintenance-mode/preset.patch.yml 与派生规则不符：\n"
            "  两个 preset.patch.yml 的 `plugins:` 正文（该行之后到文件末尾）必须满足\n"
            "  maintenance == nixos + 固定追加块。\n"
            "  修改 nixos-mode 后请同步维护模式（注意新格式整体缩进为 10 空格），或按需更新\n"
            "  检查脚本中的 PATCH_MAINTENANCE_DELTA 常量（仅限刻意变更追加块本身）。"
        )
    if rea_body != maint_body + PATCH_REA_DELTA:
        fail(
            "rea-mode/preset.patch.yml 与派生规则不符：\n"
            "  `plugins:` 正文必须满足 rea == maintenance + 固定追加块。\n"
            "  修改维护模式后请同步逆向模式（它派生自维护模式，不是另写一份）；\n"
            "  或按需更新检查脚本中的 PATCH_REA_DELTA 常量（仅限刻意变更追加块本身）。"
        )

    for directory, path in (
        ("nixos-mode", nixos_path),
        ("maintenance-mode", maint_path),
        ("rea-mode", rea_path),
    ):
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


def fail(message: str) -> None:
    print(f"preset-derivation: {message}", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    orders: list = []
    check_patch_chain(orders)
    check_news(orders)

    # 组合撰写技能曾**自带副本**；2026-10-02 起改为挂上游随
    # `@deepseek-ai/dsh-agent-preset` 分发的那份（见 preset.patch.yml 的 `skill-filesystem` 行）。
    # 自带副本的代价实测过一次：我们那份 `editing-cordis-compositions` 停在 0.1.x 的目录式
    # 模型上，而 0.2.0 的它已改成 patch/bundle 模型并明说「那个目录没人读了」——于是同名两份，
    # 其中一份在教废弃写法。故这里把「不再自带」钉成**断言**，而不是删掉就没人管：
    # 谁把副本加回来，检查就响。0.1.x 兼容用的旧副本在 `dsh-nixos-shell-stable.nix` 钉住的 rev 里。
    for mode in ("nixos-mode", "maintenance-mode", "rea-mode"):
        stray = os.path.join(PRESETS, mode, "skills")
        if os.path.isdir(stray):
            fail(
                f"{os.path.relpath(stray, ROOT)} 又出现了：组合撰写技能不再自带副本，"
                "改为挂上游 @deepseek-ai/dsh-agent-preset 的 skills/（见 preset.patch.yml "
                "的 skill-filesystem 行）。旧副本仍在 dsh-nixos-shell-stable.nix 钉住的 rev 里。"
            )

    print(
        "preset-derivation: OK（维护模式完整派生自 NixOS模式、逆向模式完整派生自维护模式；"
        "nixos / maintenance / rea-mode / news-three-elements 四个 preset.patch.yml 的头部"
        "与 preset.yml 一致，order 互不冲突）"
    )


if __name__ == "__main__":
    main()
