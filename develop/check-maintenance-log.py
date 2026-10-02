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

第 5 条是补上的**盲区**：前四条都只看「总量」——条目数、全局 SHA 唯一性、行级假名——
于是「某个条目在三种译文里整张提交表都没了」可以全绿地漏过去（2026-10-03 实测发生过：
拼接新条目时只写了标题与摘要，三语都缺表，而本脚本当时打印的是「354 entries … all passed」）。
判据取自中文基准：zh 有表则译文必须有同一组 SHA；zh 本就没有表的条目（历史上有 5 条）
在译文里也不该有。

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

    for problem in problems:
        print(f"maintenance-log: {problem}", file=sys.stderr)
    if problems:
        sys.exit(1)

    entries = next(iter(counts.values()))
    print(
        f"maintenance-log: {entries} entries in all {len(counts)} languages, "
        "timestamps exact, commit ids unique, pcn kana-free, entry structure matches zh, "
        "summary markers in-language"
    )


if __name__ == "__main__":
    main()
