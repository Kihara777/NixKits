#!/usr/bin/env python3
"""文档链接与语言切换器检查。

两类缺陷都真实发生过、且只有人工翻文档才会发现：

1. **死链**：`docs/README.<lang>.md` 在 `docs/` 内，却把 ruyi 行写成
   `docs/<lang>/ruyi.md` —— 解析成 `docs/docs/...`，404 了很久。
2. **切换器残缺**：新增语言或新文件时漏掉一个标签，本语言没写成纯文本。

这里对仓库内全部 Markdown 逐个解析相对链接并核对目标存在，同时校验切换器行里
四种语言的标签齐全。外部链接（http/https/mailto）与纯锚点不检查。

挂入 `nix flake check`（checks.doc-links），CI 每次 push 执行。
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 语言切换器必须出现的四个标签（各自语言的 display_name）。
SWITCHER_LABELS = ("中文", "English", "日本語", "偽中国語")

LINK = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
SWITCHER_LINE = re.compile(r"\[?(中文|English|日本語|偽中国語)\]?")

# `skills/write-project-docs/templates.md` ships placeholder targets on purpose
# (`](...)`, `../en/<module>.md`); a template is not a navigation target.
PLACEHOLDER = re.compile(r"[<>{}]|\.\.\.|path/to/")

# Pseudocn is kana-stripped Japanese: a kana letter in docs/pcn/ is residue.
# The middle dot (・) and the prolonged-sound mark are punctuation, not letters,
# and ・ is a legitimate separator there.
KANA = re.compile(r"[\u3041-\u3096\u30A1-\u30FA\uFF66-\uFF9D]")
CODE_SPAN = re.compile(r"`[^`]*`")

SKIP_DIRS = {".git", "node_modules", "result", ".deepseek", "skills-embedded"}


def markdown_files() -> list:
    found = []
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [name for name in dirnames if name not in SKIP_DIRS]
        for name in sorted(filenames):
            if name.endswith(".md"):
                found.append(os.path.join(dirpath, name))
    return found


def is_navigation_target(path: str) -> bool:
    """Whether links in this file must resolve.

    A skill under `skills/` is prose shipped to *other* projects: its examples
    name files that project has (`home.md`, `docs/README.en.md`), not files this
    repository has, so its links are illustrative rather than navigational.
    """
    return not os.path.relpath(path, ROOT).startswith("skills" + os.sep)


def check_links(path: str, text: str) -> list:
    problems = []
    directory = os.path.dirname(path)
    for target in LINK.findall(text):
        target = target.strip()
        if target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        target = target.split("#", 1)[0].strip()
        if target == "" or PLACEHOLDER.search(target):
            continue
        resolved = os.path.normpath(os.path.join(directory, target))
        if not os.path.exists(resolved):
            problems.append(
                f"{os.path.relpath(path, ROOT)}: dead link -> {target}"
            )
    return problems


def check_switcher(path: str, lines: list) -> list:
    problems = []
    for line in lines[:8]:
        if line.count("|") < 2:
            continue
        labels = SWITCHER_LINE.findall(line)
        if len(labels) < 3:
            continue
        missing = [label for label in SWITCHER_LABELS if label not in labels]
        if missing:
            problems.append(
                f"{os.path.relpath(path, ROOT)}: switcher misses {', '.join(missing)}"
            )
        linkless = [label for label in SWITCHER_LABELS if f"[{label}]" not in line]
        if len(linkless) != 1:
            problems.append(
                f"{os.path.relpath(path, ROOT)}: switcher must leave exactly one label "
                f"plain (the current language), found {len(linkless)}"
            )
        break
    return problems


def check_kana(path: str, lines: list) -> list:
    """Pseudocn documents carry no kana letters outside code spans."""
    relative = os.path.relpath(path, ROOT)
    if not relative.startswith(os.path.join("docs", "pcn")):
        return []
    problems = []
    for number, line in enumerate(lines, start=1):
        if KANA.search(CODE_SPAN.sub("", line)):
            problems.append(f"{relative}: kana on line {number}")
    return problems


def main() -> None:
    problems = []
    files = markdown_files()
    for path in files:
        with open(path, encoding="utf-8") as handle:
            text = handle.read()
        lines = text.splitlines()
        if is_navigation_target(path):
            problems.extend(check_links(path, text))
        problems.extend(check_switcher(path, lines))
        problems.extend(check_kana(path, lines))

    for problem in problems:
        print(f"doc-links: {problem}", file=sys.stderr)
    if problems:
        sys.exit(1)

    print(f"doc-links: {len(files)} Markdown files, links and switchers consistent")


if __name__ == "__main__":
    main()
