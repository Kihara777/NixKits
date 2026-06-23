---
name: translate-katalish
description: 为文档撰写技能提供额外的自然语言支持。新增 ｶﾀﾘｯｼｭ（片假名英语）语言——半角片假名逐词机械替换英文文本，与现有文档体系并行使用。
language_code: katalish
display_name: ｶﾀﾘｯｼｭ
base_language: en
---

# 片假名英语翻译

为 NixKits 文档体系提供 ｶﾀﾘｯｼｭ（片假名英语）语言。

## 自动发现契约

write-project-docs / write-maintenance-log 通过扫描 `skills/translate-*/SKILL.md` frontmatter 自动发现：

| 字段 | 值 | 用途 |
|------|-----|------|
| `language_code` | `katalish` | 目录名、文件扩展名、for 循环迭代 |
| `display_name` | `ｶﾀﾘｯｼｭ` | 语言切换器标签 |
| `base_language` | `en` | 源语言 |

## 触发场景

- 由 write-project-docs / write-maintenance-log 自动发现调用
- 用户要求"生成片假名英语版本"时独立调用

## 替换规则

### 1. 优先级

**词典匹配（`dictionary.md`） > 规则音译**

### 2. 保留不译

- 数字、URL、内联代码 `` `code` ``、Markdown 语法原样保留
- 中文/日文汉字不替换
- 语言切换器中的目录名（`zh`、`en`等）和文件扩展名（`.md`）不替换
- 语言名称不作本地化（`English` 保持 `English`）

### 3. 代码块保护（⚠️ 关键）

- **Nix 代码块**：仅翻译 `#` 注释，标识符/属性路径/关键字不动
- **Bash 代码块**：全部不动
- 执行层面：先按 ` ``` ` 边界提取代码块，仅对非代码块区域替换

### 4. 专有名词

| 原文 | 音译 |
|------|------|
| NixOS | ﾆｯｸｽOS |
| GitHub | ｷﾞｯﾄﾊﾌﾞ |
| DeepSeek | ﾄﾞｴｴﾌﾟｽｴｴｸ |
| Nix | ﾆｯｸｽ |

### 5. 规则音译（词典未命中时）

| 英文音节 | 片假名 |
|---------|--------|
| a (短) | ｱ |
| a (长) | ｴｲ |
| i (短) | ｲ |
| i (长) | ｱｲ |
| u (短) | ｱ |
| u (长) | ﾕｰ |
| e (短) | ｴ |
| e (长) | ｲｰ |
| o (短) | ｵ |
| o (长) | ｵｰ |

## 词典

完整替换词典见 [`dictionary.md`](dictionary.md)（66 条映射）。

## 注意事项

- 片假名英语不是人类可读的语言——视觉伪本地化，机械替换即可
- 语言切换器生成规则：从英文源提取路径，逐个精确构造（禁止 sed 模式匹配）
- 包名/模块名保持原样（如 `mcp-searxng`）

## 常见陷阱与修复（实战经验）

### 1. 词典优先级必须严格

字典匹配必须在规则音译之前执行，且按**词长降序**（longest match first）。否则长词会被短词规则误伤。
示例：`automatically` 必须先匹配 → `ｵｰﾄﾏﾃｨｯｸﾘｰ`，不能先拆成 `auto` + `matic` + `ally`。

### 2. 语言切换器必须双向更新

新增 katalish 文件后，**所有现有语言版本的同一文档**都需要追加 katalish 链接。
仅更新新文件自身的切换器是不够的——zh/en/ja 的切换器行同样需要新增 `[ｶﾀﾘｯｼｭ](path)` 条目。

### 3. sed 行号陷阱

更新切换器时，**禁止用行号定位**（`sed '2s/...'`）。不同文档的切换器位置可能不同（有些在第 2 行，有些在第 3 行）。正确做法：模式匹配切换器行。

### 4. 代码块保护

先按 ` ``` ` 边界提取代码块，仅对非代码块区域替换。在代码块内误替换会导致语法错误。

### 5. 子代理生成文件的切换器必须包含全部语言

子代理生成新语言文件时，容易只输出 **3 条目切换器**（如 `[中文] | [ｶﾀﾘｯｼｭ] | [日本語]`），缺少其他已安装的扩展语言链接。父代理在接收子代理输出后，**必须验证并补全**切换器至所有已发现语言（通过 `translate-*/SKILL.md` frontmatter 的 `language_code` 字段确定）。

验证命令：
```bash
# 检查切换器是否包含全部 5 语言
for f in docs/katalish/*.md; do
  line=$(grep '^\[中文\]' "$f")
  for expected in '\[中文\]' 'English' '日本語' 'ｶﾀﾘｯｼｭ' '偽中国語'; do
    echo "$line" | grep -q "$expected" || echo "MISSING $expected in $f"
  done
done
```

### 6. 路径深度陷阱（模块文档 vs 顶层文档）

子代理生成文件时，从 `docs/katalish/` 到其他语言目录的相对路径取决于文件层级：

| 文件位置 | 到 `docs/zh/` | 正确路径 |
|---------|-------------|---------|
| `docs/katalish/home.md`（模块） | `docs/zh/` | `../zh/home.md` |
| `docs/katalish/README.md`（顶层） | `../../README.md`（根级中文） | `../../README.md` |

常见错误：模块文档写成 `../../zh/`（多一层），顶层文档写成 `../zh/`（少一层）。验证方法：
```bash
# 模块文档路径应为 ../zh/、../en/、../ja/、../pcn/
grep -l '../../zh/' docs/katalish/*.md | grep -v README | grep -v MAINTENANCE | grep -v NOTICE
# 顶层文档路径应为 ../../README.md 等
grep '\[中文\](\.\./README' docs/katalish/README.md
```

### 7. 专有名词与链接目标保护

**必须保留原样的词**：Docker, Redis, nginx, GitHub, Git, Cloudflare, API, JSON, JS, CSS, HTML, YAML, TLS, SSL, HTTP, DNS, URL, MIT, G41, Metro, WP, KITS, MailKits, NixKits, G41KiTS, Node.js, Bilibili, Attic, Hysteria2, WebDAV, WebUI, BitTorrent, AdGuard, Transmission, Aria2, Hexo, ZeroSSL, Resend。

**链接目标绝对不可翻译**：`[text](path.md)` 中 `path.md` 内的英文单词不能替换。sed 替换时需排除 `](...)` 内部的文本。

**⚠️ 跨深度复制时链接目标必须调整层级**：从 `docs/README.en.md`（深度 1）复制到 `docs/katalish/README.md`（深度 2）时，原文中的 `../LICENSE` 需要变为 `../../LICENSE`、`NOTICE.en.md` 需要变为 `../NOTICE.en.md`。**仅「不翻译单词」是不够的——必须加一层 `../`。**

### 8. 词形变化覆盖不足

sed 的 `\<word\>` 词边界匹配无法覆盖派生词/复数形式。如词典有 `module` 但不会匹配 `modules`、`providing` 不匹配 `provide`。解决方案：词典中同时加入复数（`modules`→`ﾓｼﾞｭｰﾙｽﾞ`）和常见屈折形式（`providing`→`ﾌﾟﾗｵﾌﾞｲﾃﾞｨﾝｸﾞ`、`installed`→`ｲﾝｽﾄｰﾙﾄﾞ`）。

### 9. 本地化文档内链必须指向同语言版本

模块文档表格中的链接（如 README 服务列表）指向源语言文档。转换为 katalish 后必须改为指向 katalish 版。例如 `](../en/nginx.md)` → `](./nginx.md)`。易被「不修改链接目标」的指令掩盖——该指令仅适用于防止链接目标内的单词被翻译，不适用于路径的语言调整。
