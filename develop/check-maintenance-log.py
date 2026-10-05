#!/usr/bin/env python3
"""维护日志一致性检查。

日志是四语手工/半自动同步的，最容易在细节上失守：条目数不齐、时间戳写成占位符、
同一个 commit 被记两次、伪中国语里混进假名。这里把五条规则一次查完：

1. 四种语言的条目数一致（`^## 20` 行）。
2. 每个节标题都是精确到秒的 JST 时间戳（`YYYY-MM-DDTHH:MM:SS+09:00`），且无
   `T00:00:00` 占位符。
3. 提交表中的 7 位 SHA 在**同一文件内**不重复（日志按 SHA 全局去重）。
4. `docs/MAINTENANCE.pcn.md` 正文无假名（反引号内的引用 token 与提交列豁免）。
5. **结构对等**：同一条目在四语里的提交 SHA 集合必须与 zh 相同。
6. **摘要标记须是本语的**：每种语言用自己那份标记（zh/pcn → `**摘要**`、en → `**Summary**`、
   ja → `**概要**`），冒号全/半角不论。
7. **zh 摘要 ≤ 400 字符**（规范里那条字符预算）。
8. **清单式摘要的条目数四语相等**（少一条是漏译，多一条是加料）。
9. **说明块（`>` 行）只有一行，且标记是本语的**。

第 5 条是补上的**盲区**：前四条都只看「总量」——条目数、全局 SHA 唯一性、行级假名——
于是「某个条目在三种译文里整张提交表都没了」可以全绿地漏过去（2026-10-03 实测发生过：
拼接新条目时只写了标题与摘要，三语都缺表，而本脚本当时打印的是「354 entries … all passed」）。
判据取自中文基准：zh 有表则译文必须有同一组 SHA；zh 本就没有表的条目（历史上有 5 条）
在译文里也不该有。

第 6 条也是盲区（2026-10-03）：ja 有 80 条、pcn 有 59 条的摘要行是未译副本，而当时全部放行。

第 7～9 条是 2026-10-05 全量重写（368 条 × 四语）后补上的，三处都实测踩过：

- **第 7 条**：规范原文把字符预算写成「目标 ≤ 400」。第一轮按「目标」下发，
  交上来 21 条在 420–721 之间——**没有一条「违规」，因为目标不是判据**。
  写成硬门槛 + 明示删减顺序后全库才收敛（median 216、max 400）。
  **译文刻意不做长度门槛**：中/英/日信息密度不同（实测字面比 median en 1.87、ja 1.17、
  pcn 1.03），卡同一个数字只会逼出「为凑倍率删事实」——规范自己把这条写成反例。
- **第 8 条**：清单排版是 2026-10-05 才进来的新形态（现 27 条），四语条目数一旦漂移，
  读起来仍通顺、长度检查也不会响。
- **第 9 条**：说明块历史上出现过 `**注**`（ja，5 处）与 `**Note**`（未译）等标记。

挂入 `nix flake check`（checks.maintenance-log），CI 每次 push 执行。
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FILES = {
    "zh": os.path.join(ROOT, "MAINTENANCE.md"),
    "en": os.path.join(ROOT, "docs", "MAINTENANCE.en.md"),
    "ja": os.path.join(ROOT, "docs", "MAINTENANCE.ja.md"),
    "pcn": os.path.join(ROOT, "docs", "MAINTENANCE.pcn.md"),
}

ENTRY = re.compile(r"^## (.*)$", re.MULTILINE)
TIMESTAMP = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+09:00$")
COMMIT_ROW = re.compile(r"^\| `([0-9a-f]{7})` \|")
KANA = re.compile(r"[\u3041-\u3096\u30A1-\u30FA\uFF66-\uFF9D]")
# 第 6 条：本语摘要标记（冒号全/半角不限，因为历史上两种都有）
SUMMARY_MARKER = {
    "zh": "摘要",
    "en": "Summary",
    "ja": "概要",
    "pcn": "摘要",
}
MARKER_RE = re.compile(r"^\*\*(Summary|概要|摘要)\*\*[:：]", re.M)
CODE_SPAN = re.compile(r"`[^`]*`")
# 第 7 条：zh 摘要的字符预算（含标点与反引号，按 len() 计）。
# 只卡 zh —— 译文按密度匹配的倍率判，见 docstring 第 7 条。
ZH_SUMMARY_LIMIT = 400
# 第 9 条：说明块的标记须是本语。`godot-ai 未更新` 那条是语义标记（「为何不升级」），
# 按语言各自放行。
NOTE_MARKER = {
    "zh": {"说明", "godot-ai 未更新"},
    "en": {"Note", "godot-ai not updated"},
    "ja": {"説明", "godot-ai は未更新"},
    "pcn": {"説明", "godot-ai 未更新"},
}
NOTE_LINE = re.compile(r"^>\s*\*\*([^*]+)\*\*\s*[:：]\s*(.*)$")


def summary_body(lang: str, body: str):
    """该条目在该语言下的摘要正文（去掉标记；到首个空行为止）。"""
    match = re.search(
        r"(?m)^\*\*%s\*\*[:：](.*?)(?=\n\n|\Z)" % SUMMARY_MARKER[lang], body, re.S)
    return match.group(1).strip() if match else None


def bullet_items(summary) -> int:
    """清单式摘要的 `- ` 行数（非清单形式返回 0）。"""
    if summary is None:
        return 0
    return sum(1 for line in summary.splitlines() if line.strip().startswith("- "))


def note_lines(body: str):
    """条目里的说明块行（`>` 开头）。"""
    return [line.rstrip() for line in body.splitlines() if line.lstrip().startswith(">")]


def entries_to_bodies(text: str) -> dict:
    """节标题 → 该节的正文（供看摘要标记用）。"""
    out = {}
    for match in re.finditer(r"^## (20[^\n]+)\n(.*?)(?=\n## 20|\Z)", text, re.S | re.M):
        out[match.group(1).strip()] = match.group(2)
    return out


def entries_to_shas(text: str) -> dict:
    """节标题 → 该节里出现的 7 位 SHA 列表（保持出现顺序）。"""
    out = {}
    current = None
    for line in text.splitlines():
        if line.startswith("## "):
            current = line[3:].strip()
            out.setdefault(current, [])
        elif current is not None:
            match = COMMIT_ROW.match(line)
            if match is not None:
                out[current].append(match.group(1))
    return out


def main() -> None:
    problems = []
    counts = {}
    for lang, path in FILES.items():
        if not os.path.isfile(path):
            problems.append(f"{path} is missing")
            continue
        with open(path, encoding="utf-8") as handle:
            text = handle.read()

        headings = ENTRY.findall(text)
        counts[lang] = len(headings)

        for heading in headings:
            heading = heading.strip()
            if heading.startswith("20"):
                if not TIMESTAMP.match(heading):
                    problems.append(
                        f"{os.path.relpath(path, ROOT)}: section title is not a JST "
                        f"second-precision timestamp: {heading}"
                    )
                if "T00:00:00" in heading:
                    problems.append(
                        f"{os.path.relpath(path, ROOT)}: placeholder timestamp {heading}"
                    )

        seen = {}
        for number, line in enumerate(text.splitlines(), start=1):
            match = COMMIT_ROW.match(line)
            if match is None:
                continue
            sha = match.group(1)
            if sha in seen:
                problems.append(
                    f"{os.path.relpath(path, ROOT)}: commit {sha} recorded twice "
                    f"(lines {seen[sha]} and {number})"
                )
            seen[sha] = number

        if lang == "pcn":
            for number, line in enumerate(text.splitlines(), start=1):
                if COMMIT_ROW.match(line) is not None:
                    continue
                stripped = CODE_SPAN.sub("", line)
                if KANA.search(stripped):
                    problems.append(
                        f"{os.path.relpath(path, ROOT)}: kana on line {number}"
                    )

    if len(set(counts.values())) > 1:
        problems.append(
            "entry counts differ across languages: "
            + ", ".join(f"{lang}={count}" for lang, count in sorted(counts.items()))
        )

    # 规则 5：结构对等——每条目的 SHA 集合四语一致（以 zh 为基准）。
    per_lang, per_lang_bodies = {}, {}
    for lang, path in FILES.items():
        if os.path.isfile(path):
            with open(path, encoding="utf-8") as handle:
                text = handle.read()
            per_lang[lang] = entries_to_shas(text)
            per_lang_bodies[lang] = entries_to_bodies(text)

    # 规则 6：摘要标记须是本语的。
    # 补这条的原因：2026-10-03 查明 ja 有 80 条、pcn 有 59 条的摘要行是**未译副本**
    # （标记写成 `**Summary**`，内容是英文或中文原文），而当时的五条规则全部放行——
    # 条目数齐、时间戳对、SHA 集合对、假名检查也过（英文没有假名）。
    for lang, mapping in per_lang_bodies.items():
        want = SUMMARY_MARKER[lang]
        rel = os.path.relpath(FILES[lang], ROOT)
        for heading, body in mapping.items():
            m = MARKER_RE.search(body)
            if m is None:
                problems.append(f"{rel}: {heading} 没有摘要标记")
            elif m.group(1) != want:
                problems.append(
                    f"{rel}: {heading} 的摘要标记是 **{m.group(1)}**，本语应为 **{want}**")
    if "zh" in per_lang:
        base = per_lang["zh"]
        for lang, mapping in per_lang.items():
            if lang == "zh":
                continue
            rel = os.path.relpath(FILES[lang], ROOT)
            for heading, shas in base.items():
                if heading not in mapping:
                    problems.append(f"{rel}: entry missing entirely: {heading}")
                    continue
                other = mapping[heading]
                if other != shas:
                    problems.append(
                        f"{rel}: {heading} commit rows differ from zh "
                        f"(zh={len(shas)} {shas}, {lang}={len(other)} {other})"
                    )

    # 规则 7/8/9：字符预算、清单条目数对等、说明块形态（2026-10-05 补）。
    zh_bodies = per_lang_bodies.get("zh", {})
    for heading, body in zh_bodies.items():
        summary = summary_body("zh", body)
        if summary is not None and len(summary) > ZH_SUMMARY_LIMIT:
            problems.append(
                f"{os.path.relpath(FILES['zh'], ROOT)}: {heading} 摘要 {len(summary)} 字符 "
                f"> {ZH_SUMMARY_LIMIT}（删减顺序：过程与推导 → 收尾句 → 次要枚举 → 原因只留一句）"
            )
        zh_items = bullet_items(summary)
        for lang, mapping in per_lang_bodies.items():
            if lang == "zh" or heading not in mapping:
                continue
            items = bullet_items(summary_body(lang, mapping[heading]))
            if items != zh_items:
                problems.append(
                    f"{os.path.relpath(FILES[lang], ROOT)}: {heading} 清单条目数 {items} "
                    f"与 zh 的 {zh_items} 不一致（少一条是漏译，多一条是加料）"
                )
    for lang, mapping in per_lang_bodies.items():
        rel = os.path.relpath(FILES[lang], ROOT)
        for heading, body in mapping.items():
            notes = note_lines(body)
            if not notes:
                continue
            if len(notes) > 1:
                problems.append(
                    f"{rel}: {heading} 说明块有 {len(notes)} 行（规范要求压成一行，只留硬信息）")
                continue
            match = NOTE_LINE.match(notes[0].strip())
            if match is None:
                problems.append(
                    f"{rel}: {heading} 说明块无法解析（应为 `> **<标记>**：<一行正文>`）: "
                    f"{notes[0][:60]}"
                )
            elif match.group(1) not in NOTE_MARKER[lang]:
                problems.append(
                    f"{rel}: {heading} 说明块标记是 **{match.group(1)}**，本语应为 "
                    + " / ".join(f"**{m}**" for m in sorted(NOTE_MARKER[lang]))
                )

    for problem in problems:
        print(f"maintenance-log: {problem}", file=sys.stderr)
    if problems:
        sys.exit(1)

    entries = next(iter(counts.values()))
    print(
        f"maintenance-log: {entries} entries in all {len(counts)} languages, "
        "timestamps exact, commit ids unique, pcn kana-free, entry structure matches zh, "
        "summary markers in-language, zh summaries within budget, list items aligned, "
        "note blocks single-line and in-language"
    )


if __name__ == "__main__":
    main()
