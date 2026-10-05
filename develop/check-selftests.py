#!/usr/bin/env python3
"""反证用例：每个自检都必须能被「已知的坏输入」撞响。

**为什么需要它**——2026-10-05 一天里出现三次「判据静默失灵」，而当时它们全都报绿：

- 我自己的验收脚本 `verify.py` 正则优先级写错，`en`/`ja` 的摘要行**永远匹配不到**，
  结构比对因此对这两语形同虚设（是子代理读源码才发现的）；
- 规范把字符预算写成「目标 ≤ 400」——**目标不是判据**，一轮下来 21 条交上来 420–721 字符；
- 检查器的解析在首个空行处截断，清单块**掉出**了长度预算与项数判据之外。

三次的形状一样：**判据还在跑、还在打印「通过」，但它已经不再管那件事了。**
本脚本给每个检查配至少一个「已知的坏输入」，验证它确实会红——
条目最多的 `maintenance-log` 有三条：时间戳占位符、pcn 非日文字形、en 未译副本。

对每个用例：
  ① 把仓库（忽略 .git / node_modules / target / result*）拷进临时树；
  ② **先跑一遍**：必须通过（对照——证明失败不是拷贝或环境造成的）；
  ③ 注入一处已知坏输入；
  ④ **再跑一遍**：必须失败，且输出含预期片段（红得对，不只是红了）；
  ⑤ 可选**负例**：换一份干净副本，注入一处**本该无害**的输入（豁免区内的、表外的同类），
     **必须仍然通过**。

第 ⑤ 步补的是另一半：正例防「判据哑了」，负例防「判据乱咬」——把豁免区（反引号内内容、
提交表行）或表外的合法字符也判失败，和判据不响一样是失灵，而原来没有位置能证明它不咬。
负例同样先经过 ② 的对照（干净副本必须通过），否则它证明不了任何事。

挂入 `nix flake check`（checks.self-tests）。
"""
import importlib.util
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IGNORE = shutil.ignore_patterns(".git", "node_modules", "target", "result", "result-*")


def read(root, rel):
    with open(os.path.join(root, rel), encoding="utf-8") as handle:
        return handle.read()


def write(root, rel, text):
    with open(os.path.join(root, rel), "w", encoding="utf-8") as handle:
        handle.write(text)


def edit(root, rel, pattern, replacement, count=1):
    """正则替换；替换不到就报错（免得注入悄悄失效、用例变成空转）。"""
    text = read(root, rel)
    new, n = re.subn(pattern, replacement, text, count=count, flags=re.MULTILINE)
    if n == 0:
        raise AssertionError(f"注入失败：{rel} 里找不到 {pattern!r}")
    write(root, rel, new)


# ── 各检查的「已知坏输入」 ───────────────────────────────────────────────
def inj_preset_derivation(root):
    """维护模式不再完整派生自 NixOS模式：往维护模式的 plugins 正文里塞一行。"""
    rel = "packages/dsh-nixos-shell/presets/maintenance-mode/preset.patch.yml"
    write(root, rel, read(root, rel) + "\n      - selftest-stray-line: true\n")


def inj_preset_bundle(root):
    """包内技能快照与 skills/ 树不再逐字节一致：给快照里加一个字符。"""
    rel = ("packages/dsh-preset-news-three-elements/bundled/news-three-elements/SKILL.md")
    write(root, rel, read(root, rel) + "\n")


def inj_workflow_coverage(root):
    """把全部 build-*.yml 改名成非 .yml（等价于「workflow 被禁用」）。"""
    d = os.path.join(root, ".github", "workflows")
    names = [n for n in os.listdir(d) if n.startswith("build-") and n.endswith(".yml")]
    assert names, "没找到 build-*.yml，注入无效"
    for name in names:
        os.rename(os.path.join(d, name), os.path.join(d, "selftest-bak-" + name[6:] + ".txt"))


def inj_doc_links(root):
    """把 docs/README.en.md 里第一个相对链接指向不存在的文件。"""
    edit(root, "docs/README.en.md", r"\]\((?!https?:)([^)]+)\)",
         "](./selftest-missing-target.md)")


def inj_doc_versions(root):
    """把 docs/zh/codewhale.md 的版本行改成与包定义不符的值。

    刻意避开 EXEMPT 里的包（dsh / dsh-alpha / dsh-api-balance / codewhale-src）——
    对它们注入不会有任何反应，用例会变成空转。
    """
    edit(root, "docs/zh/codewhale.md",
         r"^\|\s*(?:版本|Version|バージョン|版)\s*\|\s*`?[0-9][0-9A-Za-z.\-+]*",
         "| 版本 | 9.9.9")


def inj_doc_counts(root):
    """把词典条数声明改成与 dictionary.md 不符的值。

    不写死数字：条数从被拷副本的计数函数本身读（`check-doc-counts.py` 的
    `dictionary_entry_count()`），注入「实际 − 1」。原来写死 `**76**`——
    词典一增删，这条用例就会**注入失败**（而不是静默空转，但同样是坏掉），
    2026-10-05 补 9 条词典映射时就是这么被撞出来的。
    """
    want = _check_module(root, "check-doc-counts.py").dictionary_entry_count()
    edit(root, "docs/zh/skills/translate-pseudocn.md",
         r"\*\*\d+\*\*(\s*条)", rf"**{want - 1}**\1")


def inj_maintenance_log(root):
    """把第一条日志的时间戳改成占位符。"""
    edit(root, "MAINTENANCE.md", r"^## 20\d\d-\d\d-\d\dT[\d:]+\+09:00",
         "## 2026-01-01T00:00:00+09:00")


def _check_module(root, script):
    """按**被拷进临时树的那份副本**导入检查脚本。

    注入要用被测脚本自己的解析器与阈值常量：另写一份正则就会漂，
    而「注入悄悄失效、用例变成空转」正是本文件要防的事。
    """
    name = "selftest_" + re.sub(r"\W+", "_", script)
    path = os.path.join(root, "develop", script)
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def inj_maintenance_log_pcn_glyph(root):
    """往 pcn 正文塞一个非日文字形（第 10 条的坏输入）。

    塞在第一条摘要行末尾：反引号**外**、也不是提交表行——豁免口径之外的才算正文。
    注入文本只含目标字（`值`）与拉丁字符，免得连带撞响同一条规则的其他字，
    好让「新增的问题恰好一条」这件事可核对。
    """
    edit(root, "docs/MAINTENANCE.pcn.md", r"^(\*\*摘要\*\*[:：].*)$",
         r"\1〔selftest 注入：值〕")


def inj_maintenance_log_pcn_ok_kanji(root):
    """第 10 条的**负例**：塞一个表外的日文字。

    `言` 在 ja 语料里出现过＝日文实际用字，第 10 条不该管它。
    「不在表内的字不得响」在原设计里没有位置（只有正例槽位），这条负例就是补那个位置——
    它要证的判据不是「会响」，而是「果然不响」。
    """
    edit(root, "docs/MAINTENANCE.pcn.md", r"^(\*\*摘要\*\*[:：].*)$",
         r"\1〔selftest 負例：言〕")


def inj_maintenance_log_pcn_exempt_span(root):
    """第 10 条的**负例**：把表内字写进反引号内。

    反引号内是豁免口径（引用 token 本来就该保持原样）：塞在那里不该响。
    两条负例合起来把「判据与豁免的边界」钉住——只测「会响」不够，
    把整个豁免区也判失败，是另一种失灵。
    """
    edit(root, "docs/MAINTENANCE.pcn.md", r"^(\*\*摘要\*\*[:：].*)$",
         r"\1〔`値` `值`〕")


def inj_maintenance_log_en_copy(root):
    """把一条 en 摘要换成它对应 zh 摘要的原文（第 11 条的坏输入）。

    挑 zh 里**汉字最多**的那条：判据要求汉字数 ≥ 20 **且**占比 > 30%，取最密的一条，
    注入必然命中。只换正文、保留 en 自己的 `**Summary**:` 标记——历史事故就是这个形状，
    而且这样第 6 条（标记须是本语）不会跟着响：用例要证的是第 11 条，不是第 6 条。
    """
    cml = _check_module(root, "check-maintenance-log.py")
    zh_bodies = cml.entries_to_bodies(read(root, "MAINTENANCE.md"))
    ranked = sorted(
        ((cml.han_ratio(cml.summary_body("zh", body) or "")[0], heading)
         for heading, body in zh_bodies.items()), reverse=True)
    han, heading = ranked[0]
    zh_summary = cml.summary_body("zh", zh_bodies[heading])
    han, chars, ratio = cml.han_ratio(zh_summary)
    assert han >= cml.EN_SUMMARY_HAN_MIN and ratio > cml.EN_SUMMARY_HAN_RATIO, (
        f"最密的 zh 摘要也只有 {han} 个汉字 / {ratio:.0%}，注入不会命中第 11 条")
    rel = "docs/MAINTENANCE.en.md"
    text = read(root, rel)
    section = re.search(r"(?m)^## %s\n(.*?)(?=\n## 20|\Z)" % re.escape(heading), text, re.S)
    if section is None:
        raise AssertionError(f"en 里找不到条目 {heading}")
    body = section.group(1)
    marker = re.search(r"(?m)^\*\*Summary\*\*[:：](.*?)(?=\n\n|\Z)", body, re.S)
    if marker is None:
        raise AssertionError(f"en 里条目 {heading} 没有摘要标记")
    end = marker.end()
    following = re.match(r"\n\n((?:- .*\n?)+)", body[end:])
    if following:
        end += following.end()
    new_body = body[:marker.start()] + "**Summary**: " + zh_summary + body[end:]
    write(root, rel, text[:section.start(1)] + new_body + text[section.end(1):])


def inj_session_sources(root):
    """往预设插件里写回 v3 的旧来源形状。"""
    rel = "packages/dsh-preset-news-three-elements/plugins/news-language.js"
    write(root, rel, read(root, rel) + '\nconst selftestSource = { kind: "plugin" };\n')


def inj_news_mode_tests(root):
    """让被测插件的 import 直接抛错。"""
    rel = "packages/dsh-preset-news-three-elements/plugins/news-skill.js"
    write(root, rel, 'throw new Error("selftest-injected-failure");\n' + read(root, rel))


# 每个用例：(名字, 命令, 正例注入, 期望片段, 负例注入列表)
# 负例的语义是**反向**的：注入一个「本该无害」的输入，检查**必须仍然通过**。
# 它和正例是一对——正例防「判据哑了」，负例防「判据乱咬」（把豁免区也判失败同样是失灵）。
CASES = [
    ("preset-derivation", ["python3", "develop/check-preset-derivation.py"],
     inj_preset_derivation, "preset-derivation:", ()),
    ("preset-bundle", ["python3", "develop/check-preset-bundle.py"],
     inj_preset_bundle, "preset-bundle:", ()),
    ("workflow-coverage", ["python3", "develop/check-workflows.py"],
     inj_workflow_coverage, "workflow-coverage:", ()),
    ("doc-links", ["python3", "develop/check-doc-links.py"],
     inj_doc_links, "doc-links:", ()),
    ("doc-versions", ["python3", "develop/check-doc-versions.py"],
     inj_doc_versions, "doc-versions:", ()),
    ("doc-counts", ["python3", "develop/check-doc-counts.py"],
     inj_doc_counts, "doc-counts:", ()),
    ("maintenance-log", ["python3", "develop/check-maintenance-log.py"],
     inj_maintenance_log, "placeholder timestamp", ()),
    ("maintenance-log-pcn-glyph", ["python3", "develop/check-maintenance-log.py"],
     inj_maintenance_log_pcn_glyph, "非日文字形",
     (inj_maintenance_log_pcn_ok_kanji, inj_maintenance_log_pcn_exempt_span)),
    ("maintenance-log-en-copy", ["python3", "develop/check-maintenance-log.py"],
     inj_maintenance_log_en_copy, "像中文原稿", ()),
    ("session-sources", ["python3", "develop/check-session-sources.py"],
     inj_session_sources, "kind", ()),
    ("news-mode-tests", ["node", "packages/dsh-preset-news-three-elements/tests/mode.test.mjs"],
     inj_news_mode_tests, "selftest-injected-failure", ()),
]


def run(cmd, root):
    return subprocess.run(cmd, cwd=root, capture_output=True, text=True, timeout=600)


def fresh_copy(prefix):
    tmp = tempfile.mkdtemp(prefix=prefix)
    shutil.copytree(ROOT, tmp, dirs_exist_ok=True, ignore=IGNORE)
    make_writable(tmp)
    return tmp


def make_writable(tmp):
    """**在 Nix 沙箱里这一步不是可选的**：flake 源取自 store，文件是 0444，
    `copytree` 会把只读权限一起拷过来，于是所有「注入」都 `Permission denied`
    ——本地工作树可写，所以本地跑不出来（2026-10-05 实测：`nix flake check` 里
    6 个用例集体报「注入失败」，而本地 11/11 全绿）。"""
    for current, dirs, files in os.walk(tmp):
        for entry in dirs + files:
            path = os.path.join(current, entry)
            os.chmod(path, os.stat(path).st_mode | 0o200)


def main() -> None:
    problems, skipped, negatives_run = [], [], 0
    for name, cmd, inject, expect, negatives in CASES:
        if shutil.which(cmd[0]) is None:
            skipped.append(f"{name}（{cmd[0]} 不在 PATH）")
            print(f"— {name}: 跳过（{cmd[0]} 不在 PATH）")
            continue
        with tempfile.TemporaryDirectory(prefix=f"selftest-{name}-") as tmp:
            shutil.copytree(ROOT, tmp, dirs_exist_ok=True, ignore=IGNORE)
            make_writable(tmp)
            control = run(cmd, tmp)
            if control.returncode != 0:
                problems.append(
                    f"{name}: **对照就失败了**——未注入的副本本该通过，退出码 "
                    f"{control.returncode}\n{control.stdout[-400:]}{control.stderr[-400:]}")
                print(f"✗ {name}: 对照失败")
                continue
            try:
                inject(tmp)
            except Exception as error:  # 注入写错＝用例失效，要报出来但不该吞掉其余用例
                problems.append(f"{name}: **注入失败**——{error}")
                print(f"✗ {name}: 注入失败")
                continue
            broken = run(cmd, tmp)
            output = broken.stdout + broken.stderr
            if broken.returncode == 0:
                problems.append(f"{name}: 注入已知坏输入后**仍然通过**——这条判据不管这件事了")
                print(f"✗ {name}: 撞不响")
            elif expect not in output:
                problems.append(
                    f"{name}: 红了，但输出里没有预期的 {expect!r}（红得不对）\n{output[-400:]}")
                print(f"✗ {name}: 红得不对")
            else:
                print(f"✓ {name}: 对照通过 → 注入 → 按预期失败")

        # 负例：各用一份干净副本（免得和上面的正例注入叠加）
        for negative in negatives:
            negatives_run += 1
            with tempfile.TemporaryDirectory(prefix=f"selftest-{name}-neg-") as ntmp:
                shutil.copytree(ROOT, ntmp, dirs_exist_ok=True, ignore=IGNORE)
                make_writable(ntmp)
                try:
                    negative(ntmp)
                except Exception as error:
                    problems.append(f"{name}[{negative.__name__}]: **负例注入失败**——{error}")
                    print(f"✗ {name}[{negative.__name__}]: 注入失败")
                    continue
                harmless = run(cmd, ntmp)
                noutput = harmless.stdout + harmless.stderr
                if harmless.returncode == 0:
                    print(f"✓ {name}[{negative.__name__}]: 注入无害输入 → 仍通过")
                    continue
                problems.append(
                    f"{name}[{negative.__name__}]: 注入的输入**本该无害**，检查却红了"
                    f"（退出码 {harmless.returncode}）——判据越界咬了豁免区\n"
                    f"{noutput[-400:]}")
                print(f"✗ {name}[{negative.__name__}]: 负例被撞响")

    if skipped:
        print(f"跳过 {len(skipped)} 项：{', '.join(skipped)}")
    if problems:
        print("\n自检的反证用例失败：", file=sys.stderr)
        for problem in problems:
            print(f"  - {problem}", file=sys.stderr)
        sys.exit(1)
    print(f"self-tests: {len(CASES) - len(skipped)}/{len(CASES)} 项检查都能被已知坏输入撞响"
          f"（另 {negatives_run} 条负例：无害输入不被撞响）"
          + (f"（跳过 {len(skipped)} 项）" if skipped else ""))


if __name__ == "__main__":
    main()
