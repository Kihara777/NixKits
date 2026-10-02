#!/usr/bin/env python3
"""NixKits 预设派生漂移检查。

维护模式预设必须派生自 NixOS模式预设，两个通道各查一遍：
- 0.1.x 目录式预设：maintenance-mode/agent.cordis.yml
                      == nixos-mode/agent.cordis.yml + 固定追加块
- 0.2.0 patch 式预设：maintenance-mode/preset.patch.yml 的 plugins 正文
                      == nixos-mode/preset.patch.yml 的 plugins 正文 + 同一追加块
                      （文件头里的 id/name/description/order 是每个预设各自的元数据，
                        由 preset.yml 与 IDS/ORDERS 常量分别核对，不参与字节派生）
- 两预设的 skills/ 目录逐文件一致
- 修改 nixos-mode 后必须同步 maintenance-mode（见 AGENTS.md「预设」一节）

挂入 `nix flake check`（checks.preset-derivation），CI 每次 push 执行。
"""
import hashlib
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRESETS = os.path.join(ROOT, "packages", "dsh-nixos-shell", "presets")

# 维护模式相对 nixos 模式的唯一允许差异（末尾追加块，含注释）。
# 该块变更时同步更新此常量。
MAINTENANCE_DELTA = (
    "\n"
    "# ── maintenance mode ─────────────────────────────────────────────────────────\n"
    "\n"
    "# `maintenance-skills` registers the NixKits documentation/maintenance skills\n"
    "# as runtime skills (write-project-docs, write-maintenance-log, and every\n"
    "# translate-* language extension, auto-discovered) from the canonical repo\n"
    "# skills/ tree embedded in the package at build time — a fresh session always\n"
    "# gets the latest content — and installs the repository maintenance workflow\n"
    "# prompt section.  It publishes no services, so no realm is needed.\n"
    "- id: maintenance-skills\n"
    "  name: '@kihara777/dsh-nixos-shell/maintenance-skills'\n"
)

# ── dsh 0.2.0 patch 式预设（preset.patch.yml）────────────────────────────────
#
# 0.2.0 把预设从 `$DSH_HOME/.agent-presets/<id>/` 目录改成 profile patch 层的
# 一条 `@deepseek-ai/dsh-agent-preset` 条目，插件行进 `config.plugins`。
# 元数据（name/description，原 preset.yml）也搬进了 `config`，因此**整文件字节
# 派生在新格式里不可能成立**——派生落在插件行正文上：`plugins:` 键之后到文件末尾。
PATCH_MARKER = "        plugins:"

# 追加块与 0.1.x 相同，只是整体缩进到 `config.plugins` 的列表项层级（+10 空格）。
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

# 预设 id（= 0.1.x 里 .agent-presets/<id> 的目录名，也是 roster 里的 id）与
# `config.order`。order 取 10/11：内置预设 standard/ptc/minimal/cordis 占 1–4，
# 且必须在 roster 里唯一。
PATCH_IDS = {"nixos-mode": "nixos", "maintenance-mode": "maintenance"}
PATCH_ORDERS = {"nixos-mode": 10, "maintenance-mode": 11}
BUILTIN_PRESET_ORDERS = {1, 2, 3, 4}


def read_preset_meta(directory: str) -> dict:
    """读 0.1.x 的 preset.yml（`key: value` 单值行）。"""
    path = os.path.join(PRESETS, directory, "preset.yml")
    meta = {}
    with open(path, encoding="utf-8") as f:
        for line in f.read().split("\n"):
            key, sep, value = line.partition(": ")
            if sep and key and not key.startswith("#"):
                meta[key.strip()] = value.strip()
    return meta


def check_patch_pair() -> None:
    """0.2.0 通道：plugins 正文派生 + 每个文件头部的元数据自洽。"""
    nixos_text = read_text("nixos-mode", "preset.patch.yml")
    maint_text = read_text("maintenance-mode", "preset.patch.yml")

    for directory, text in (("nixos-mode", nixos_text), ("maintenance-mode", maint_text)):
        # 按"整行相等"计数：子串计数会把更深缩进的 `          plugins:` 也算进来。
        marker_lines = [line for line in text.split("\n") if line == PATCH_MARKER]
        if len(marker_lines) != 1:
            fail(
                f"{directory}/preset.patch.yml 里整行等于 `{PATCH_MARKER}` 的行出现 "
                f"{len(marker_lines)} 次（要求恰好 1 次，它是派生比较的分界行）。"
            )

    nixos_body = nixos_text.split(PATCH_MARKER + "\n", 1)[1]
    maint_body = maint_text.split(PATCH_MARKER + "\n", 1)[1]
    if maint_body != nixos_body + PATCH_MAINTENANCE_DELTA:
        fail(
            "maintenance-mode/preset.patch.yml 与派生规则不符：\n"
            "  两个 preset.patch.yml 的 `plugins:` 正文（该行之后到文件末尾）必须满足\n"
            "  maintenance == nixos + 固定追加块。\n"
            "  修改 nixos-mode 后请同步维护模式（注意新格式整体缩进为 10 空格），或按需更新\n"
            "  检查脚本中的 PATCH_MAINTENANCE_DELTA 常量（仅限刻意变更追加块本身）。"
        )

    orders = []
    for directory, text in (("nixos-mode", nixos_text), ("maintenance-mode", maint_text)):
        meta = read_preset_meta(directory)
        head = text.split(PATCH_MARKER + "\n", 1)[0]
        expected = {
            "id": PATCH_IDS[directory],
            "name": f"'{meta.get('name', '')}'",
            "description": f"'{meta.get('description', '')}'",
            "order": str(PATCH_ORDERS[directory]),
        }
        for key, want in expected.items():
            line = f"        {key}: {want}\n"
            if line not in head:
                fail(
                    f"{directory}/preset.patch.yml 的预设头缺 `{key}` 或值与来源不符：\n"
                    f"  期望存在行 `{line.strip()}`\n"
                    f"  （id/order 来自本脚本的 PATCH_IDS/PATCH_ORDERS；\n"
                    f"    name/description 必须与同目录 preset.yml 逐字一致）"
                )
        order = PATCH_ORDERS[directory]
        if order in BUILTIN_PRESET_ORDERS:
            fail(
                f"{directory}/preset.patch.yml 的 order={order} 与 dsh 内置预设 "
                f"{sorted(BUILTIN_PRESET_ORDERS)} 冲突。"
            )
        if order in orders:
            fail(f"两个预设的 order 重复：{order}（roster 里必须唯一）。")
        orders.append(order)


def read_text(directory: str, name: str) -> str:
    with open(os.path.join(PRESETS, directory, name), encoding="utf-8") as f:
        return f.read()


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
    nixos_dir = os.path.join(PRESETS, "nixos-mode")
    maint_dir = os.path.join(PRESETS, "maintenance-mode")

    nixos_composition = os.path.join(nixos_dir, "agent.cordis.yml")
    maint_composition = os.path.join(maint_dir, "agent.cordis.yml")
    with open(nixos_composition, encoding="utf-8") as f:
        nixos_text = f.read()
    with open(maint_composition, encoding="utf-8") as f:
        maint_text = f.read()

    expected = nixos_text + MAINTENANCE_DELTA
    if maint_text != expected:
        fail(
            "maintenance-mode/agent.cordis.yml 与派生规则不符：\n"
            "  maintenance-mode/agent.cordis.yml 必须等于\n"
            "  nixos-mode/agent.cordis.yml 末尾追加固定 maintenance-skills 块。\n"
            "  修改 nixos-mode 后请同步维护模式，或按需更新检查脚本中的\n"
            "  MAINTENANCE_DELTA 常量（仅限刻意变更追加块本身）。"
        )

    check_patch_pair()

    nixos_skills = tree_hashes(os.path.join(nixos_dir, "skills"))
    maint_skills = tree_hashes(os.path.join(maint_dir, "skills"))
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
        "preset-derivation: OK（维护模式完整派生自 NixOS模式；"
        "agent.cordis.yml 与 preset.patch.yml 两个通道均已核对）"
    )


if __name__ == "__main__":
    main()
