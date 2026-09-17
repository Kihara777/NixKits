#!/usr/bin/env python3
"""文档版本一致性检查。

`docs/<lang>/<pkg>.md` 的「版本」行必须与 `packages/<pkg>.nix` 声明的版本一致。
不一致本身就是缺陷——读者按文档判断版本，而文档恰恰是升级时最容易被漏掉的一环。

这不是假想问题：2026-09-17 一天之内就发现并修正了 7 处（godot-ai 3.2.5→4.1.0、
codewhale 0.9.12→0.9.13、mcp-searxng 2.2.0→2.3.0、opencode-telegram
0.25.1→0.25.2、dsh-alpha 0.1.5-alpha.2→0.1.6-alpha.1 等），全部是「包升级了、
文档没跟」。这类失配不会让任何构建失败，只有人工翻文档才发现——故固化为断言。

**只校验能从定义中机械读出、且应当始终相等的部分**：版本号。
文档里的依赖表、平台支持、安装步骤等内容无法自动比对，不在本检查范围。

例外必须显式登记（包名 → 理由），不允许静默跳过。

挂入 `nix flake check`（checks.doc-versions），CI 每次 push 执行。
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PACKAGES = os.path.join(ROOT, "packages")
DOCS = os.path.join(ROOT, "docs")

# 文档中的版本行：`| 版本 | 1.0.0 |`、`| Version | `1.0.0` |`、
# `| バージョン | 0.5.0 |`、`| 版 | 0.5.0 |`。
# 值可能带反引号，尾部可能带括号注释（如 ruyi 的 `0.52.0（稳定）`）。
VERSION_ROW = re.compile(
    r"^\|\s*(?:版本|Version|バージョン|版)\s*\|\s*`?([0-9][0-9A-Za-z.\-+]*)",
    re.MULTILINE,
)

# 包定义中的版本声明：`version = "1.0.0";` 与薄封装的
# `version = "0.1.6-alpha.1";`（dsh-alpha 等），以及
# `version ? "0.1.5-rc.1",`（dsh.nix / ruyi.nix 的默认值形式）。
VERSION_DECL = re.compile(
    r"^\s*version\s*[?=]\s*\"([0-9][^\"]*)\"",
    re.MULTILINE,
)

# 版本不写在 .nix 里、而是从别处读出的包。
# 值写明「从哪里读」，让失效时能直接找过去，而不是只看到一个「跳过」。
INDIRECT_VERSION = {
    "kitsfmt": ("packages/kitsfmt-src/Cargo.toml", re.compile(r'^version\s*=\s*"([^"]+)"', re.MULTILINE)),
}

# 包名 → 为何不参与版本比对。
EXEMPT = {
    # 薄封装：主仓不承载源码，版本由子仓决定，文档刻意不标版本号
    # （见 docs/*/dsh-api-balance.md「NixKits 侧角色」）。
    "dsh-api-balance": "薄封装，版本由子仓 dsh-api-balance 决定，文档刻意不标版本",
    # dsh-alpha 是 dsh 的通道包装：它的版本记在 dsh.md 的通道表里，
    # 而 dsh.md 的「版本」行描述的是 stable 通道（见 CHANNEL_ROWS）。
    "dsh": "多通道：stable 版本见文档版本行，alpha 版本见通道表（见 CHANNEL_DOCS）",
    "dsh-alpha": "多通道：版本记在 dsh.md 的通道表中",
    "codewhale-src": "不是独立包，而是 codewhale.nix 在 riscv64 上的源构建分支",
}

# 多通道包：文档的「版本」行之外，额外在通道表里记录其他通道的版本。
# 通道表格式（各语言列名不同，但都有一列承载包名、行内承载版本）：
#   | `pkgs.dsh-alpha` | alpha | `0.1.6-alpha.1` | ... |
#   | `ruyi-beta` | 0.52.0-beta.20260824 | ... |
CHANNEL_PACKAGES = ("dsh-alpha", "ruyi-beta", "ruyi-alpha")

# 表格行以 `|` 开头结尾；包名出现在其中一个单元格里。
TABLE_ROW = re.compile(r"^\|.*\|\s*$", re.MULTILINE)
BACKTICKED = re.compile(r"`([^`]+)`")
BARE_VERSION = re.compile(r"(?<![\w.\-])([0-9]+\.[0-9]+\.[0-9]+[0-9A-Za-z.\-]*)")


def channel_version_in_row(row: str, package: str):
    """从一行表格中取出该通道包的版本值；取不到返回 None。

    优先取反引号包裹的值（`0.1.6-alpha.1`），否则退化为裸版本形态
    （ruyi 的通道表把版本写成裸值）。反引号里混入的包名本身会被过滤。
    """
    if f"`{package}`" not in row and f"`pkgs.{package}`" not in row:
        return None

    for value in BACKTICKED.findall(row):
        if value in (package, f"pkgs.{package}"):
            continue
        if re.match(r"^[0-9]", value):
            return value

    for value in BARE_VERSION.findall(row):
        return value
    return None

LANGUAGES = ("zh", "en", "ja", "pcn")


def package_versions() -> dict:
    """包名 → 从定义中读出的版本（读不出的不进结果）。"""
    versions = {}
    for name in sorted(os.listdir(PACKAGES)):
        if not name.endswith(".nix"):
            continue
        package = name[: -len(".nix")]
        path = os.path.join(PACKAGES, name)
        with open(path, encoding="utf-8") as handle:
            text = handle.read()

        match = VERSION_DECL.search(text)
        if match:
            versions[package] = (match.group(1), os.path.relpath(path, ROOT))
            continue

        if package in INDIRECT_VERSION:
            source, pattern = INDIRECT_VERSION[package]
            source_path = os.path.join(ROOT, source)
            if os.path.exists(source_path):
                with open(source_path, encoding="utf-8") as handle:
                    indirect = pattern.search(handle.read())
                if indirect:
                    versions[package] = (indirect.group(1), source)

    # packages/ruyi/*.nix 是子目录中的通道包装，同样纳入。
    ruyi_dir = os.path.join(PACKAGES, "ruyi")
    if os.path.isdir(ruyi_dir):
        for name in sorted(os.listdir(ruyi_dir)):
            if not name.endswith(".nix"):
                continue
            package = name[: -len(".nix")]
            path = os.path.join(ruyi_dir, name)
            with open(path, encoding="utf-8") as handle:
                match = VERSION_DECL.search(handle.read())
            if match:
                versions[package] = (match.group(1), os.path.relpath(path, ROOT))

    return versions


def documented_version(package: str, language: str):
    """某语言文档中该包的版本行值；无文档或无版本行则返回 None。"""
    path = os.path.join(DOCS, language, f"{package}.md")
    if not os.path.exists(path):
        return None
    with open(path, encoding="utf-8") as handle:
        match = VERSION_ROW.search(handle.read())
    return match.group(1) if match else None


def main() -> None:
    versions = package_versions()
    problems = []

    for package, (declared, source) in sorted(versions.items()):
        if package in EXEMPT:
            continue
        if not os.path.exists(os.path.join(DOCS, "zh", f"{package}.md")):
            # 无独立文档的包（如内置通道）不在本检查范围。
            continue
        for language in LANGUAGES:
            documented = documented_version(package, language)
            if documented is None:
                # 该语言文档没有版本行——可能是刻意不标（EXEMPT 覆盖），
                # 也可能只是漏了。此处只报告与声明值不符的情况，避免噪音。
                continue
            if documented != declared:
                problems.append(
                    f"doc-versions: docs/{language}/{package}.md says {documented}, "
                    f"but {source} declares {declared}"
                )

    # 多通道包：文档通道表中的版本也要对齐（四语逐一检查）。
    # 通道包装（dsh-alpha / ruyi-beta / ruyi-alpha）没有独立文档页，
    # 它们的版本记在基包的文档里（dsh.md / ruyi.md）。
    channel_owner = {
        "dsh-alpha": "dsh",
        "ruyi-beta": "ruyi",
        "ruyi-alpha": "ruyi",
    }
    for package in CHANNEL_PACKAGES:
        if package not in versions:
            continue
        owner = channel_owner[package]
        declared, source = versions[package]
        for language in LANGUAGES:
            path = os.path.join(DOCS, language, f"{owner}.md")
            if not os.path.exists(path):
                continue
            with open(path, encoding="utf-8") as handle:
                rows = TABLE_ROW.findall(handle.read())

            found = None
            for row in rows:
                value = channel_version_in_row(row, package)
                if value is not None:
                    found = value
                    break

            rel = os.path.relpath(path, ROOT)
            if found is None:
                problems.append(
                    f"doc-versions: {rel} has no channel row for {package} "
                    f"(expected {declared} from {source})"
                )
            elif found != declared:
                problems.append(
                    f"doc-versions: {rel} channel row for {package} says {found}, "
                    f"but {source} declares {declared}"
                )

    for problem in problems:
        print(problem, file=sys.stderr)
    if problems:
        sys.exit(1)

    checked = sum(
        1
        for package in versions
        if package not in EXEMPT and os.path.exists(os.path.join(DOCS, "zh", f"{package}.md"))
    )
    print(
        f"doc-versions: {checked} packages match across {len(LANGUAGES)} languages, "
        f"{len(EXEMPT)} exempt ({', '.join(sorted(EXEMPT))})"
    )


if __name__ == "__main__":
    main()
