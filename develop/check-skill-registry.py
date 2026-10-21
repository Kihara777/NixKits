#!/usr/bin/env python3
"""check-skill-registry.py —— skills/ 下的每个技能，必须有归属。

来历（2026-10-12）：`nixpkgs-package-upstream` 与 `nixkits-package-upstream`
两个技能从 10-10 就躺在 `skills/` 里，**四语文档页与 README 行全都齐** ——
但 `packages/dsh-nixos-shell/lib/maintenance-skills.js` 的固定清单里没有它们。
于是它们**一次都没有被注册过**，任何 session 都加载不到，而我当时也没发现：
我一直在用 bash 直接读 SKILL.md 绕过去。

`develop/` 下九个检查器没有一个盯着「技能目录 ↔ 注入清单」是否一致，
所以它安静地躺了两天。这个检查补的就是那一格。

判据（每个 `skills/<name>/` 至少要命中一条）：

  1. 某个 `.js` 里出现 `registerSkill("<name>")`     —— 运行时注册
  2. 某个 `.nix` 里出现 `"<name>"` 列表项             —— 构建期复制进预设
  3. `<name>` 匹配 `translate-*`                      —— 自动发现
  4. 在下面的 NOT_INJECTED 表里，**且写明理由**       —— 有意不注入

第 4 条要写理由，是为了让「忘了」和「决定不」在文件里长得不一样。

退出码：0 = 全部有归属；1 = 有技能没有归属，或有条目写了理由却没写清。
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
PKGS = ROOT / "packages"

# 有意不注入的技能。**必须写明理由** —— 这一栏是判据的一部分，不是备忘。
NOT_INJECTED: dict[str, str] = {
    "nixkits-skills": (
        "它是「把 NixKits 技能装到别的编码助手目录」的安装器，"
        "用途是给 opencode / codewhale / codex 等使用，不是给 dsh 自己加载的。"
    ),
}


def find(pattern: str, suffix: str) -> set[str]:
    """在 packages/ 下所有该后缀的文件里，收出 pattern 的第一个捕获组。"""
    out: set[str] = set()
    rx = re.compile(pattern, re.M)
    for f in PKGS.rglob(f"*{suffix}"):
        try:
            text = f.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        for m in rx.finditer(text):
            out.add(m.group(1))
    return out


# ⚠️ 第一次写这个检查时漏了 re.M，于是 `^`/`$` 只匹配整串头尾，
# **多行清单里一个列表项都收不到**（报「构建期列表 0 个」，而实际有 3 个）。
# 判据本身出错，比没有判据更坏：它会给出一个「已验证」的假象。



def read_excluded() -> set[str]:
    """读 maintenance-skills.js 的 EXCLUDED 集合 —— 默认注册 = skills/ 全部 − 排除。

    2026-10-21 起 maintenance-skills 改成「排除表」：不再逐个 registerSkill，
    而是遍历 skills-embedded/ 并跳过 EXCLUDED 里的条目。判据随之改：
    一个技能只要不在排除表里，就**默认被注册**。
    """
    for p in Path(".").rglob("maintenance-skills.js"):
        try:
            text = p.read_text()
        except OSError:
            continue
        m = re.search(r"EXCLUDED\s*=\s*new Set\(\[(.*?)\]\)", text, re.S)
        if m:
            return set(re.findall(r'"([^"]+)"', m.group(1)))
    return set()


def main() -> int:
    if not SKILLS.is_dir():
        print(f"✗ 找不到 {SKILLS}")
        return 1

    dirs = sorted(p.name for p in SKILLS.iterdir() if p.is_dir())
    if not dirs:
        print("✗ skills/ 下没有目录")
        return 1

    # 1. 运行时注册：registerSkill("X")
    registered_js = find(r'registerSkill\(\s*"([^"]+)"\s*\)', ".js")
    # 2. 构建期列表：.nix 里的 "X" 列表项（排除注释行粗筛）
    registered_nix = find(r'^\s*"([A-Za-z0-9._-]+)"\s*$', ".nix")
    # 3. 插件里以常量形式钉住技能 id 的（news 预设那种）
    skill_ids = find(r'SKILL_ID\s*=\s*"([^"]+)"', ".js")

    # 4. 默认注册：maintenance-skills 遍历 skills-embedded/ 并跳过 EXCLUDED。
    excluded = read_excluded()
    auto_registered = set(dirs) - excluded
    stale_excluded = excluded - set(dirs)

    injected = registered_js | registered_nix | skill_ids | auto_registered

    print(f"  skills/ 下 {len(dirs)} 个技能")
    print(f"    运行时注册（registerSkill）: {len(registered_js & set(dirs))} 个")
    print(f"    构建期列表（.nix 列表项）: {len(registered_nix & set(dirs))} 个")
    print(f"    auto（translate-*）:         "
          f"{len([d for d in dirs if d.startswith('translate-')])} 个")
    print(f"    默认注册（排除表之外）:      {len(auto_registered)} 个")
    print(f"    排除表（默认不注入）:        {len(excluded & set(dirs))} 个")
    print(f"    有意不注入（已写理由）:      {len(NOT_INJECTED)} 个")
    print()

    fail = 0
    for d in dirs:
        if d in injected:
            print(f"  \033[32m✓\033[0m {d}")
        elif d in excluded:
            print(f"  \033[32m✓\033[0m {d}  （排除表：默认不注入，理由见 maintenance-skills.js）")
        elif d in NOT_INJECTED:
            reason = NOT_INJECTED[d].strip()
            if not reason:
                print(f"  \033[31m✗\033[0m {d}  在 NOT_INJECTED 里但**没写理由**")
                fail = 1
            else:
                print(f"  \033[32m✓\033[0m {d}  （有意不注入：{reason[:40]}…）")
        else:
            print(
                f"  \033[31m✗\033[0m {d}  **没有任何注入器认领它** —— "
                f"session 加载不到；要么登记进注入清单，要么写进 NOT_INJECTED 并说明理由"
            )
            fail = 1

    # 反向：NOT_INJECTED 里写了但目录已不存在
    for name in NOT_INJECTED:
        if name not in dirs:
            print(f"  \033[31m✗\033[0m NOT_INJECTED 里的 {name} 已不存在 —— 删掉这一条")
            fail = 1

    print()
    if stale_excluded:
        for s in sorted(stale_excluded):
            print(f"  \033[31m✗\033[0m 排除表里的 {s} 在 skills/ 下不存在（拼写错误或已删除？）")
        fail = 1
    if fail:
        print("失败：有技能没有归属。")
        return 1
    print(f"全部有归属：{len(dirs)} 个技能，无一漏登记。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
