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
- 两预设的 skills/ 目录逐文件一致
- 每个预设的 `config.name` / `config.description` 与同目录 `preset.yml` 逐字一致
- 新闻三要素模式（独立包）的预设头自洽（id/name/description/order）
- 修改 nixos-mode 后必须同步 maintenance-mode（见 AGENTS.md「预设」一节）

挂入 `nix flake check`（checks.preset-derivation），CI 每次 push 执行。
"""
import os
import sys
import hashlib

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

# 派生比较的分界行：`plugins:` 键之后到文件末尾就是插件行正文。
PATCH_MARKER = "        plugins:"

# 预设 id（roster 里的 id）与 `config.order`。order 取 10/11/13：内置预设
# standard/ptc/minimal/cordis 占 1–4，且必须在 roster 里唯一。
PATCH_IDS = {"nixos-mode": "nixos", "maintenance-mode": "maintenance"}
PATCH_ORDERS = {"nixos-mode": 10, "maintenance-mode": 11}
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


def check_patch_pair(orders: list) -> None:
    """0.2.0 通道：plugins 正文派生 + 每个文件头部的元数据自洽。"""
    nixos_path = os.path.join(PRESETS, "nixos-mode", "preset.patch.yml")
    maint_path = os.path.join(PRESETS, "maintenance-mode", "preset.patch.yml")

    nixos_body = patch_body(nixos_path)
    maint_body = patch_body(maint_path)
    if maint_body != nixos_body + PATCH_MAINTENANCE_DELTA:
        fail(
            "maintenance-mode/preset.patch.yml 与派生规则不符：\n"
            "  两个 preset.patch.yml 的 `plugins:` 正文（该行之后到文件末尾）必须满足\n"
            "  maintenance == nixos + 固定追加块。\n"
            "  修改 nixos-mode 后请同步维护模式（注意新格式整体缩进为 10 空格），或按需更新\n"
            "  检查脚本中的 PATCH_MAINTENANCE_DELTA 常量（仅限刻意变更追加块本身）。"
        )

    for directory, path in (
        ("nixos-mode", nixos_path),
        ("maintenance-mode", maint_path),
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


def tree_hashes(root: str) -> dict:
    result = {}
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for name in sorted(filenames):
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, root)
            with open(path, "rb") as f:
                result[rel] = hashlib.sha256(f.read()).hexdigest()
    return result


def main() -> None:
    orders: list = []
    check_patch_pair(orders)
    check_news(orders)

    nixos_skills = tree_hashes(os.path.join(PRESETS, "nixos-mode", "skills"))
    maint_skills = tree_hashes(os.path.join(PRESETS, "maintenance-mode", "skills"))
    if nixos_skills != maint_skills:
        only_nixos = sorted(set(nixos_skills) - set(maint_skills))
        only_maint = sorted(set(maint_skills) - set(nixos_skills))
        changed = sorted(
            k for k in set(nixos_skills) & set(maint_skills)
            if nixos_skills[k] != maint_skills[k]
        )
        fail(
            "两预设 skills/ 目录不一致：\n"
            f"  仅 nixos-mode 存在: {only_nixos}\n"
            f"  仅 maintenance-mode 存在: {only_maint}\n"
            f"  内容不同: {changed}"
        )

    print(
        "preset-derivation: OK（维护模式完整派生自 NixOS模式；nixos / maintenance / "
        "news-three-elements 三个 preset.patch.yml 的头部与 preset.yml 一致，order 互不冲突）"
    )


if __name__ == "__main__":
    main()
