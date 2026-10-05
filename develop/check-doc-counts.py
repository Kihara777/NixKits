#!/usr/bin/env python3
"""文档里「能从源机械读出的计数」必须与源一致。

这类数字最容易腐烂：它们不像版本号那样有显式约束——改一处源（给词典加一行、给 flake 加
一项检查），文档里的数字就悄悄过期，而**它偏偏是读者最容易信的东西**。

2026-10-05 实测两次：
- 给 pcn 词典补一条 `パッチ → 補丁` 映射后，四语文档页里的「实测 **75** 条」立刻失真，
  而当时没有任何检查看得见这个数字（`check-doc-versions` 只管包版本）。
- 同一轮里给 `checks` 加一项检查，`AGENTS.md` 的「8 项自检 / 7 项由 `develop/check-*.py` 实现」
  同样当场过期。

规则表（每条都是「文档里写死的数字」对「从源算出来的数字」——两个不同的东西比，
才不会自己骗自己）：

1. `docs/<lang>/skills/translate-pseudocn.md` 声明的词典条数
   == `skills/translate-pseudocn/dictionary.md` 的表数据行数。
2. `AGENTS.md` 声明的自检项数（总数、其中 python 实现数）
   == `flake.nix` 的 `checks` 条目数、以及其中调用 `develop/check-*.py` 的数量。

挂入 `nix flake check`（checks.doc-counts），CI 每次 push 执行。
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LANGS = ["zh", "en", "ja", "pcn"]


def read(rel: str) -> str:
    with open(os.path.join(ROOT, rel), encoding="utf-8") as handle:
        return handle.read()


def dictionary_entry_count() -> int:
    """`dictionary.md` 表的数据行数（不含表头行）。"""
    rows = [line for line in read("skills/translate-pseudocn/dictionary.md").splitlines()
            if line.startswith("| ")]
    return len(rows) - 1


def flake_check_counts() -> tuple:
    """`flake.nix` 的 checks 条目数、其中调用 `develop/check-*.py` 的数量。"""
    text = read("flake.nix")
    segment = text[text.index("checks = {"):]
    named = re.findall(r'(\w[\w-]*)\s*=\s*pkgs\.runCommand "check-', segment)
    python_scripts = set(re.findall(r"python3 (develop/check-\S+\.py)", segment))
    return len(named), len(python_scripts)


# 规则 1：文档里声明的词典条数（`**N** 条` / `**N** 項(目)` / `**N** entries`）
DICT_CLAIM = re.compile(r"\*\*(\d+)\*\*\s*(?:条|項|entries)")
# 规则 2：AGENTS.md 里的自检项数声明
CHECK_TOTAL_CLAIM = re.compile(r"的 (\d+) 项自检")
CHECK_PY_CLAIM = re.compile(r"(\d+) 项由 `develop/check-\*\.py` 实现")


def main() -> None:
    problems = []

    # ── 规则 1 ───────────────────────────────────────────────
    want = dictionary_entry_count()
    for lang in LANGS:
        rel = f"docs/{lang}/skills/translate-pseudocn.md"
        claims = DICT_CLAIM.findall(read(rel))
        if not claims:
            problems.append(f"{rel}: 找不到词典条数声明（应写成 `**{want}** 条/項/entries`）")
            continue
        for claim in claims:
            if int(claim) != want:
                problems.append(
                    f"{rel}: 声明的词典条数是 {claim}，而 "
                    f"skills/translate-pseudocn/dictionary.md 实际有 {want} 行数据 "
                    f"（两者必须一致，改哪边都行，但不能只有一边动）"
                )

    # ── 规则 2 ───────────────────────────────────────────────
    total, pythonic = flake_check_counts()
    agents = read("AGENTS.md")
    for pattern, actual, what in (
        (CHECK_TOTAL_CLAIM, total, "自检项总数"),
        (CHECK_PY_CLAIM, pythonic, "其中 python 实现数"),
    ):
        found = pattern.findall(agents)
        if not found:
            problems.append(f"AGENTS.md: 找不到「{what}」的声明（pattern {pattern.pattern}）")
            continue
        for claim in found:
            if int(claim) != actual:
                problems.append(
                    f"AGENTS.md: 声明的{what}是 {claim}，而 flake.nix 的 checks 实际为 {actual} "
                    f"（新增/删除一项检查时，AGENTS.md 的这张表要一起改）"
                )

    for problem in problems:
        print(f"doc-counts: {problem}", file=sys.stderr)
    if problems:
        sys.exit(1)
    print(
        f"doc-counts: 词典 {want} 条、自检 {total} 项（其中 {pythonic} 项由 python 脚本实现）"
        "—— 四语文档页与 AGENTS.md 的声明均与源一致"
    )


if __name__ == "__main__":
    main()
