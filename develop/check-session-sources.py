#!/usr/bin/env python3
"""check-session-sources.py —— 预设插件**写进会话**的消息来源，不许用 v3 的旧形状。

## 为什么要有它（2026-10-04 事故）

dsh 0.2.0 的会话格式 v4 对消息来源有一条准入判据：

    来源必须是对象，`kind` 非空，且**不等于字面量 `"plugin"`**。

字面量 `"plugin"` + 同级 `plugin: "<名字>"` 是 **v3 时代**的插件来源形状。在 v4 里，
只要预设的插件把一个这样的消息 `steer()` 进会话，准入就拒，而症状是整个会话
「本机运行失败」，错误只说：

    format v4 message requires a producer-owned source kind

2026-10-03 实测：掌灯模式的 `journal-catchup` 在**每个**新会话开局都会 steer 一条
提醒，于是在 0.2.0-rc.2 上「每开一个新会话就崩一次」，狐莉只能回滚系统才能跟我说话。
同形状还在新闻三要素预设的两处插件里（下次部署同样会崩）。

## 判据

本仓库自己的预设插件（`packages/dsh-preset-*/plugins/*.js`、`presets/*/plugins/*.js`）
里，**任何** `kind: "plugin"` 都判失败：那些文件写出的来源都会进会话。
正确形状是迁移表给插件定的名字：`kind: "plugin:<插件名>"`（去掉 `plugin` 字段）。

> 自带 dsh 插件（`node_modules/@deepseek-ai/*`）不在范围内：它们由上游随版本一起改，
> 且 v4 迁移会替它们改写。本脚本只管**我们自己的**预设插件。

注释行会先剥掉——解释这条历史的注释不该被判失败。

用法（仓库根目录）：
    nix shell nixpkgs#python3 --command python3 develop/check-session-sources.py

退出码：0 = 干净；1 = 有旧形状；2 = 用错了（扫描根一个都不存在时也判 1，
因为「没扫到东西」不能当成通过）。
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# 只扫我们自己的预设插件目录；不递归进 node_modules。
GLOBS = (
    "packages/dsh-preset-*/plugins/*.js",
    "presets/*/plugins/*.js",
)

# `kind: "plugin"` / `kind: 'plugin'` —— 唯一被 v4 准入点名的形状。
BAD = re.compile(r"""kind\s*:\s*["']plugin["']""")

# 行内注释与整行注释都剥掉：解释这条历史的注释不该被判失败。
def strip_comment(line: str) -> str:
    out = []
    quote = None
    i = 0
    while i < len(line):
        ch = line[i]
        if quote is not None:
            if ch == "\\":
                out.append(ch)
                i += 1
                if i < len(line):
                    out.append(line[i])
                i += 1
                continue
            if ch == quote:
                quote = None
            out.append(ch)
            i += 1
            continue
        if ch in "\"'`":
            quote = ch
            out.append(ch)
            i += 1
            continue
        if ch == "/" and i + 1 < len(line) and line[i + 1] == "/":
            break
        out.append(ch)
        i += 1
    return "".join(out)


def main() -> int:
    targets: list[Path] = []
    for pattern in GLOBS:
        targets.extend(sorted(ROOT.glob(pattern)))

    if not targets:
        print("check-session-sources: 一个预设插件文件都没扫到——判失败，不当成通过。")
        print(f"  （扫描根：{', '.join(GLOBS)}）")
        return 1

    failures: list[tuple[Path, int, str]] = []
    for path in targets:
        for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            code = strip_comment(raw)
            if BAD.search(code):
                failures.append((path, lineno, raw.strip()))

    print(f"check-session-sources: 扫了 {len(targets)} 个预设插件文件")
    if failures:
        for path, lineno, line in failures:
            print(f"  ✗ {path.relative_to(ROOT)}:{lineno}")
            print(f"      {line}")
        print(
            "\n失败：这些是 v3 时代的来源形状，v4 会话准入会拒——"
            "症状是整个 session「本机运行失败」。\n"
            "  改成 `kind: `plugin:${name}``（插件名接在 `plugin:` 之后，去掉 `plugin` 字段）。"
        )
        return 1
    print("  干净：没有 v3 形状的来源。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
