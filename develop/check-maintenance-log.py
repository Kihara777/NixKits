#!/usr/bin/env python3
"""维护日志一致性检查。

日志是四语手工/半自动同步的，最容易在细节上失守：条目数不齐、时间戳写成占位符、
同一个 commit 被记两次、伪中国语里混进假名。这里把十一条规则一次查完：

1. 四种语言的条目数一致（`^## 20` 行）。
2. 每个节标题都是精确到秒的 JST 时间戳（`YYYY-MM-DDTHH:MM:SS+09:00`），且无
   `T00:00:00` 占位符。
3. 提交表中的 7 位 SHA 在**同一文件内**不重复（日志按 SHA 全局去重）。
4. `docs/MAINTENANCE.pcn.md` 正文无假名（反引号内的引用 token 与提交列豁免）。
5. **结构对等**：同一条目在四语里的提交 SHA 集合必须与 zh 相同。
6. **摘要标记须是本语的**：每种语言用自己那份标记（zh/pcn → `**摘要**`、en → `**Summary**`、
   ja → `**概要**`），冒号全/半角不论。
7. **zh 摘要 ≤ 400 字符**（规范里那条字符预算）。
8. **摘要一律清单式**：每条摘要至少有 **1 个 `- ` 项**，且**项数四语相等**
   （2026-10-05 起策略从「散文或清单都行」改为只此一种——扫读时要能一眼数清改了几件事，
   散文段落没法数）。
9. **说明块（`>` 行）只有一行，且标记是本语的**。
10. **pcn 正文不得出现非日文字形**（`PCN_NON_JAPANESE`，同样豁免提交表与反引号内内容）。
11. **en 摘要不得是中文原稿**（未译副本），两条判据：与 zh 摘要**逐字相同**（铁证，零误报），
    或反引号外汉字数 ≥ 20 **且**占非空白字符 > 30%（抓「整段中文」）。

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

第 10 条（pcn 非日文字形）与第 6 条是一对：第 6 条只看「标记是不是本语」，管不了正文用了哪种汉字。
pcn 是「日文剥离假名后的视觉结果」，`skills/translate-pseudocn/SKILL.md` 本就写着禁止简体与繁体
中文汉字——但此前只查假名（`KANA`），汉字一直靠人眼，于是 2026-10-05 手工修掉 `值`→`値`、
`胶囊`→`膠囊`、`对外`→`対外`、`码`→`source`、`归`→`帰` 之后，把这条补成断言。
表**不是**拍脑袋列的简繁字表，是按三步现算的（判据与来历写在 `PCN_NON_JAPANESE` 上方）。

第 11 条补的是「正文语种」这个盲区（与第 6 条同源）：2026-10-05 查明 en 日志里曾有 11 条摘要
是**中文原文的副本**（与 zh 逐字相同、正文全是汉字），而当时所有规则放行——标记检查只认
`**Summary**` 这个字面量，正文是中文它看不出来。两条判据是有分工的：逐字相同那条零误报、
不受长度影响；汉字密度那条能抓住「改写过的中文副本」（不逐字相同但整段是汉字）。
阈值标定过程写在常量旁边。

挂入 `nix flake check`（checks.maintenance-log），CI 每次 push 执行。
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# 可选：对其他按同一规范写维护日志的仓库也适用（例如薄封装子仓）。
# 用法：python3 develop/check-maintenance-log.py --root /path/to/repo
# 一份脚本两仓通用——**判据不复制**，复制出来的第二份必然与第一份分叉。
if "--root" in sys.argv:
    _i = sys.argv.index("--root")
    if _i + 1 >= len(sys.argv):
        print("check-maintenance-log: --root 后面要跟一个仓库路径", file=sys.stderr)
        sys.exit(2)
    ROOT = os.path.abspath(sys.argv[_i + 1])
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

# ── 第 10 条：pcn 正文的非日文字形表 ─────────────────────────────────────
# **这张表是经 ja 语料过滤 + 逐字核对得来的，不是简繁字表**（2026-10-05 现算）。
# 三步来历（要扩表就照着重跑一遍，别凭印象添字）：
#
#   ① 抽候选：从 **全部 pcn 正文**取出「出现过的汉字」（U+3400–4DBF / U+4E00–9FFF /
#      U+F900–FAFF），先剥反引号内内容、跳过提交表行——与假名检查同一豁免口径。
#      「全部」= `docs/**/*.pcn.md` **加** `docs/pcn/**/*.md`：模块文档按语言分目录存放，
#      只扫前者的那次推导漏掉了 35 份模块文档里的 14 种字形（们/荣/设/积/极/历/经…），
#      而它们比维护日志里的还多。镜像语料同理取 `docs/**/*.ja.md` + `docs/ja/**/*.md`。
#   ② 用 ja 语料过滤：在 ja 里出现过的字＝日文实际用字，不算。滤掉 987 种 / 49273 处，
#      `言`/`内`/`点`/`配`/`存` 这类大面积误报全在这里消失。
#   ③ 余下 260 种逐个判定，判据是**该字形在不在日文汉字集里**——测法用
#      `ch.encode("shift_jis")`（JIS X 0208）：编码抛 `UnicodeEncodeError` 即不在。
#      45 种过不了 ③，全部收进本表；每一条的「日文形」建议都用同一个探针复验过。
#
# 两类**不进表**的字，是这张表与「简繁字表」的区别所在：
#   · 古典形 `與`/`之`/`於` 在 JIS X 0208 内，且 pcn 助词表（`と`→與、`の`→之、`に`→於）
#     恰好规定要用它们——现库 319 处 `與` 正是这么来的，收进来会与助词表打架；
#   · 日文也用、只是没在本仓 ja 语料里出现的字（`服`/`板`/`零`/`清`/`但`/`其`/`且`/`也`…）。
#
# 已知**不覆盖**的范围（有意）：字形级判据管不了「整词是中文、但每个字都在 0208 内」的写法
# （`控件` 的 控/件、`按鈕` 的 鈕、`檢查` 的 檢 都在 0208 内，只有 查 会被抓到），
# 也管不了将来才会首次出现的新字形——那要按上面三步重跑再补表。
PCN_NON_JAPANESE = {
    # 简体形 → 日文形
    "值": "値", "额": "額", "锚": "錨", "块": "塊", "夹": "夾", "线": "線",
    "载": "載", "兰": "蘭", "亚": "亜", "诺": "諾", "吞": "呑", "弹": "弾",
    "务": "務", "对": "対", "备": "備", "户": "戸", "组": "組",
    "复": "復/複（按词选）",
    "过": "過", "压": "圧", "应": "応", "荣": "栄", "积": "積", "极": "極",
    "历": "歴", "经": "経", "仿": "倣",
    # 繁体/旧字形 → 日文新字形
    "戶": "戸", "內": "内", "剝": "剥", "查": "査", "囊": "嚢", "擊": "撃",
    "溫": "温", "啟": "啓",
    # 中文専用字形（简繁都用，日文没有这个字形）→ 只能改写
    "卡": "日文無此字（例：卡片→札）",
    "桌": "日文無此字（例：桌面→机上）",
    "阱": "日文無此字（例：陷阱→罠）",
    "擎": "日文無此字（例：引擎→機関）",
    "檔": "日文無此字（例：檔位→段階、降檔→降格、帰檔→書庫）",
    "拦": "日文無此字（例：拦截器→傍受）",
    "跑": "日文無此字（例：跑→実行）",
    "们": "日文無此字（改写）",
    "滚": "日文無此字（例：回滚→復帰）",
    "拼": "日文無此字（例：拼接→連結）",
}


# ── 第 11 条：en 摘要的「是不是中文原稿」阈值 ────────────────────────────
# 判据形状取「汉字数 ≥ 20 **且** 占非空白字符 > 30%」——两个条件同时成立才算中招。
# 标定（2026-10-05，367 条 en 摘要，用本脚本 summary_body() 同一套解析；分母＝反引号外去空白字符数）：
#
#   · en 侧（合法样本）：汉字数 = 0 的有 345 条（94.0%）；汉字数 p95=4 / p98=8 / p99=11 / max=41；
#     占比 p95=0.70% / p98=1.63% / p99=1.89% / **max=19.64%**。
#     两处上界是**不同条目**、且都合法：占比那条（11 字 / 56 字符）在引用中文栏目名
#     `快速开始→添加, 包→软件, License→许可`；汉字数那条（41 字 / 486 字符 = 8.4%）在引用
#     台词 `催逝快讯`。已知合法反例 `基本情報`（日/中共用术语，裸写）实测 4 字 / 2.1%，离阈值很远。
#   · zh 侧（副本长什么样）：汉字数 p10=20 / p25=30 / p50=62 / p75=102 / max=244；
#     占比 p25=0.28 / p50=0.404 / p75=0.564 / max=0.858。
#
# 取 (20, 0.30)：现库 0 条误报；能抓住 246/367（67%）条 zh 摘要的副本。候选对照实测——
# (20, 0.25) 抓 74% 但只比合法上界 19.64% 高 1.27 倍，(20, 0.30) 是 1.5 倍，(20, 0.35) 只抓 58%。
# 之所以要求「同时」，是因为两个上界分属两条不同条目：合法样本要越界得**同时**多 20 个汉字
# （现上界那条占比只有 8.4%）**且**密度翻一倍半，而「正文全是汉字」的副本必然两个条件都过。
# **不设 allowlist**：现库没有一条合法摘要触及阈值，所以一个口子都不用开。
# 已知会**漏**的：以拉丁/反引号 token 为主的短 zh 摘要（汉字数个位数），其副本不会被抓到——
# 那种副本本来也不是「正文全是汉字」，仍有人眼与第 6 条标记检查兜着。
# 只对 en 生效：zh 正文本来就是中文，ja/pcn 另有各自的标记与字形检查。
EN_SUMMARY_HAN_MIN = 20
EN_SUMMARY_HAN_RATIO = 0.30
HAN = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")


def summary_body(lang: str, body: str):
    """该条目在该语言下的摘要正文（去掉标记）。

    摘要＝标记行，**外加紧随其后的清单块**（规范示例是「标记行 / 空行 / 清单」；
    2026-10-05 的重写里也出现过不留空行的紧排，两种都合规）。清单必须算进摘要——
    否则它会掉出字符预算与「清单条目数四语相等」两条判据之外，而那正是它们要防的东西。
    """
    match = re.search(
        r"(?m)^\*\*%s\*\*[:：](.*?)(?=\n\n|\Z)" % SUMMARY_MARKER[lang], body, re.S)
    if match is None:
        return None
    text = match.group(1)
    following = re.match(r"\n\n((?:- .*\n?)+)", body[match.end():])
    if following:
        text = text + "\n\n" + following.group(1).rstrip("\n")
    return text.strip()


def bullet_items(summary) -> int:
    """清单式摘要的 `- ` 行数（非清单形式返回 0）。"""
    if summary is None:
        return 0
    return sum(1 for line in summary.splitlines() if line.strip().startswith("- "))


def han_ratio(summary: str):
    """摘要里反引号外的（汉字数, 非空白字符数, 占比）——第 11 条的全部判据量。

    反引号内的 token 不算：正文里的命令、路径、标识符本来就该保持拉丁。
    """
    plain = CODE_SPAN.sub("", summary)
    han = len(HAN.findall(plain))
    chars = len(re.sub(r"\s", "", plain))
    return han, chars, (han / chars if chars else 0.0)


def note_lines(body: str):
    """条目里的说明块行（`>` 开头）。"""
    return [line.rstrip() for line in body.splitlines() if line.lstrip().startswith(">")]


def pcn_documents():
    """本检查管的 pcn 正文。

    两种命名并存是仓库的既有结构：顶层文档是 `<name>.pcn.md`，模块文档在 `docs/pcn/` 下
    （与 `docs/ja/`、`docs/zh/` 平行）。只盖前者的守卫会漏掉 35 份模块文档——
    实测那里有 15 种 / 86 处非日文字形，比维护日志本身还多。
    """
    return sorted(set(
        glob.glob(os.path.join(ROOT, "docs", "**", "*.pcn.md"), recursive=True)
        + glob.glob(os.path.join(ROOT, "docs", "pcn", "**", "*.md"), recursive=True)
    ))


def check_pcn_body(rel: str, text: str, problems: list) -> None:
    """pcn 正文的假名与非日文字形（豁免口径：提交表行、反引号内内容）。

    两条规则同一处实现：它们问的是同一个问题——「这份正文还是不是『日文剥离假名』的产物」。
    """
    for number, line in enumerate(text.splitlines(), start=1):
        if COMMIT_ROW.match(line) is not None:
            continue
        stripped = CODE_SPAN.sub("", line)
        if KANA.search(stripped):
            problems.append(f"{rel}: kana on line {number}")
        # 第 10 条：表与判据见 PCN_NON_JAPANESE 上方注释。
        for char in dict.fromkeys(stripped):
            if char in PCN_NON_JAPANESE:
                problems.append(
                    f"{rel}: line {number} 非日文字形 {char!r}"
                    f"（{stripped.count(char)} 处）—— 日文形 {PCN_NON_JAPANESE[char]}"
                )


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

    # 规则 4 + 10：pcn 正文字形与假名。范围是**全部 pcn 正文**（见 `pcn_documents()`：
    # `docs/**/*.pcn.md` 加 `docs/pcn/**/*.md`，共 39 份）——只盖维护日志而放过
    # README/SECURITY/模块文档，就是「一半的守卫」：同一套字形规约、同一套豁免口径
    # （提交表行与反引号内内容），没有任何理由只对日志生效。
    for path in pcn_documents():
        with open(path, encoding="utf-8") as handle:
            check_pcn_body(os.path.relpath(path, ROOT), handle.read(), problems)

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

    # 规则 7/8/9：字符预算、摘要一律清单式、说明块形态（2026-10-05 补）。
    zh_bodies = per_lang_bodies.get("zh", {})
    for heading, body in zh_bodies.items():
        summary = summary_body("zh", body)
        if summary is not None and len(summary) > ZH_SUMMARY_LIMIT:
            problems.append(
                f"{os.path.relpath(FILES['zh'], ROOT)}: {heading} 摘要 {len(summary)} 字符 "
                f"> {ZH_SUMMARY_LIMIT}（删减顺序：过程与推导 → 收尾句 → 次要枚举 → 原因只留一句）"
            )
        zh_items = bullet_items(summary)
        if summary is not None and zh_items == 0:
            problems.append(
                f"{os.path.relpath(FILES['zh'], ROOT)}: {heading} 摘要是散文——策略要求"
                "「一句话概括 + 空行 + 至少 1 个 `- ` 项」，单件事的条目也要写成单行清单"
            )
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

    # 规则 11：en 摘要不得是中文原稿（未译副本）。
    # 两条判据：① 逐字相同（铁证，零误报）；② 汉字密度（抓「整段中文」，见常量旁标定）。
    # zh_bodies（zh 条目标题 → 正文）在上面规则 7/8/9 那一段已经取好，直接复用。
    for heading, body in per_lang_bodies.get("en", {}).items():
        summary = summary_body("en", body)
        if summary is None:
            continue
        han, chars, ratio = han_ratio(summary)
        if han >= EN_SUMMARY_HAN_MIN and ratio > EN_SUMMARY_HAN_RATIO:
            problems.append(
                f"{os.path.relpath(FILES['en'], ROOT)}: {heading} 摘要像中文原稿（未译副本）——"
                f"反引号外汉字 {han} 个 / 非空白字符 {chars}（{ratio:.0%}），"
                f"阈值 {EN_SUMMARY_HAN_MIN} 个 且 > {EN_SUMMARY_HAN_RATIO:.0%}；"
                "请按 zh 源重译为英文"
            )
        # ② 与 zh 摘要逐字相同。加这条的理由：密度规则有下界（汉字 < 20 的短摘要漏网），
        # 而「一字不差地等于 zh」本身就是铁证，且**零误报**（现库 0 条）。
        # 门槛「反引号外必须有汉字」是防巧合：若某条摘要通体是拉丁 token（命令/标识符），
        # 各语言本来就该写得逐字相同——那是正确翻译，不是未译副本。
        zh_body = zh_bodies.get(heading)
        zh_summary = summary_body("zh", zh_body) if zh_body is not None else None
        if (zh_summary is not None and summary == zh_summary
                and HAN.search(CODE_SPAN.sub("", summary))):
            problems.append(
                f"{os.path.relpath(FILES['en'], ROOT)}: {heading} 摘要与 zh 摘要逐字相同"
                "（未译副本；请按 zh 源重译为英文）"
            )

    for problem in problems:
        print(f"maintenance-log: {problem}", file=sys.stderr)
    if problems:
        sys.exit(1)

    entries = next(iter(counts.values()))
    print(
        f"maintenance-log: {entries} entries in all {len(counts)} languages, "
        "timestamps exact, commit ids unique, pcn kana-free, pcn free of "
        "non-Japanese glyphs, entry structure matches zh, summary markers in-language, "
        "en summaries not left in Chinese, zh summaries within budget, list items aligned, "
        "note blocks single-line and in-language"
    )


if __name__ == "__main__":
    main()
