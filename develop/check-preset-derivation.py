#!/usr/bin/env python3
"""NixKits 预设派生漂移检查。

维护模式预设必须派生自 NixOS模式预设：
- maintenance-mode/agent.cordis.yml == nixos-mode/agent.cordis.yml + 固定追加块
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

    print("preset-derivation: OK（维护模式完整派生自 NixOS模式）")


if __name__ == "__main__":
    main()
