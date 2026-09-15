#!/usr/bin/env python3
"""预设包内技能快照漂移检查。

`packages/dsh-preset-news-three-elements/bundled/news-three-elements/` 是
`skills/news-three-elements/` 的**构建期快照**（断网兜底）。技能一改、快照没跟
上，模式离线时就会退回旧正文，而且悄无声息——所以这里强制两者逐字节一致。

挂入 `nix flake check`（checks.preset-bundle），CI 每次 push 执行。

修法：`cp skills/news-three-elements/*.md \
        packages/dsh-preset-news-three-elements/bundled/news-three-elements/`
"""
import hashlib
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(ROOT, "skills", "news-three-elements")
BUNDLE = os.path.join(
    ROOT, "packages", "dsh-preset-news-three-elements", "bundled", "news-three-elements"
)


def digests(directory: str) -> dict:
    result = {}
    for name in sorted(os.listdir(directory)):
        path = os.path.join(directory, name)
        if not os.path.isfile(path):
            continue
        with open(path, "rb") as handle:
            result[name] = hashlib.sha256(handle.read()).hexdigest()
    return result


def main() -> None:
    for directory in (SOURCE, BUNDLE):
        if not os.path.isdir(directory):
            print(f"preset-bundle: missing directory {directory}", file=sys.stderr)
            sys.exit(1)

    source = digests(SOURCE)
    bundle = digests(BUNDLE)

    problems = []
    for name in sorted(set(source) | set(bundle)):
        if name not in source:
            problems.append(f"bundled/{name} has no counterpart in skills/news-three-elements/")
        elif name not in bundle:
            problems.append(f"skills/news-three-elements/{name} is missing from the bundle")
        elif source[name] != bundle[name]:
            problems.append(f"{name} differs between the skill and the bundled snapshot")

    if problems:
        for problem in problems:
            print(f"preset-bundle: {problem}", file=sys.stderr)
        print(
            "preset-bundle: refresh with `cp skills/news-three-elements/*.md "
            "packages/dsh-preset-news-three-elements/bundled/news-three-elements/`",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"preset-bundle: {len(source)} files identical between the skill and the snapshot")


if __name__ == "__main__":
    main()
