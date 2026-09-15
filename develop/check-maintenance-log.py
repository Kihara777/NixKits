#!/usr/bin/env python3
"""维护日志一致性检查。

日志是四语手工/半自动同步的，最容易在细节上失守：条目数不齐、时间戳写成占位符、
同一个 commit 被记两次、伪中国语里混进假名。这里把四条规则一次查完：

1. 四种语言的条目数一致（`^## 20` 行）。
2. 每个节标题都是精确到秒的 JST 时间戳（`YYYY-MM-DDTHH:MM:SS+09:00`），且无
   `T00:00:00` 占位符。
3. 提交表中的 7 位 SHA 在**同一文件内**不重复（日志按 SHA 全局去重）。
4. `docs/MAINTENANCE.pcn.md` 正文无假名（反引号内的引用 token 与提交列豁免）。

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
CODE_SPAN = re.compile(r"`[^`]*`")


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

    for problem in problems:
        print(f"maintenance-log: {problem}", file=sys.stderr)
    if problems:
        sys.exit(1)

    entries = next(iter(counts.values()))
    print(
        f"maintenance-log: {entries} entries in all {len(counts)} languages, "
        "timestamps exact, commit ids unique, pcn kana-free"
    )


if __name__ == "__main__":
    main()
