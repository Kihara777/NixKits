#!/usr/bin/env python3
"""构建 workflow 覆盖检查。

每个 `packages/*.nix` 都应当至少有一个 `build-<包名>-*.yml` workflow，否则新包
悄悄失去 CI 与二进制缓存——本仓库唯一一次「新增包忘了加 workflow」就是这么发生的。

例外必须显式登记（包名 → 理由），不允许静默跳过。

挂入 `nix flake check`（checks.workflow-coverage），CI 每次 push 执行。
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PACKAGES = os.path.join(ROOT, "packages")
WORKFLOWS = os.path.join(ROOT, ".github", "workflows")

# 包名 → 为何没有独立构建 workflow。
EXEMPT = {
    "dsh": "随 dsh 上游发布，仓库只做包装与补丁，无独立构建矩阵",
    "dsh-alpha": "同 dsh：alpha 通道的薄包装",
    "godot-ai": "受上游依赖限制（详见 AGENTS.md），暂无构建 workflow",
    "codewhale-src": "不是独立包，而是 codewhale.nix 在 riscv64 上的源构建分支",
}


def package_names() -> list:
    names = []
    for name in sorted(os.listdir(PACKAGES)):
        if not name.endswith(".nix"):
            continue
        names.append(name[: -len(".nix")])
    return names


def main() -> None:
    workflows = os.listdir(WORKFLOWS) if os.path.isdir(WORKFLOWS) else []
    missing = []
    for package in package_names():
        if package in EXEMPT:
            continue
        expected = [name for name in workflows if name.startswith(f"build-{package}-")]
        if not expected:
            missing.append(package)

    for package in missing:
        print(
            f"workflow-coverage: packages/{package}.nix has no build-{package}-*.yml workflow",
            file=sys.stderr,
        )
    if missing:
        sys.exit(1)

    covered = [package for package in package_names() if package not in EXEMPT]
    print(
        f"workflow-coverage: {len(covered)} packages covered, "
        f"{len(EXEMPT)} exempt ({', '.join(sorted(EXEMPT))})"
    )


if __name__ == "__main__":
    main()
