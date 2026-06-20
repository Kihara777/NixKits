# 维护日志

[中文](MAINTENANCE.md) | [English](docs/MAINTENANCE.en.md) | [日本語](docs/MAINTENANCE.ja.md)

NixKits 软件更新维护日志。

---

## 2026-06-18T09:52:34+09:00

**摘要**：codewhale 0.8.61 — 上游修复；mcp-searxng 1.6.0 — 上游修复

| 提交 | 说明 |
|------|------|
| `...` | chore(pkgs): bump codewhale 0.8.61 |
| `...` | chore(pkgs): bump mcp-searxng 1.6.0 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.60 | 0.8.61 |
| 　 | cli ﾊｯｼｭ | `...` → `sha256-3k0K/I/NxYHrNszgniQncWTu8HRqsR3RSg+YLuB+IkY=` |
| 　 | tui ﾊｯｼｭ | `...` → `sha256-YVjKDO/JNnsAHwzCf4itrEw8psKyi9bbFaLJLFvMyAI=` |
| mcp-searxng | 1.4.0 | 1.6.0 |
| 　 | ｿｰｽ ﾊｯｼｭ | `...` → `sha256-oBpSAAppLfnPhC3tHoE2X1YAGMyd42fka+xAVFuhjKw=` |
| 　 | npmDepsHash | `...` → `sha256-7z5T8po2ya698J7vqu4pA7c8s85k33sRbOV2tRmGdPo=` |

---

## 2026-06-18T09:03:48+09:00

**摘要**：ﾙｲｰ — ﾆｯｸｽOS 兼容性补丁（`patches/ruyi-nixos-compat.ﾊﾟｯﾁ`），透明处理预编译 RISC-V 工具链的动态链接器路径、GCC 子进程 ELF interpreter 修复和 console_scripts argv0 问题

| 提交 | 说明 |
|------|------|
| `d814550` | feat(ﾙｲｰ): add autoUpdate ｱﾝﾄﾞ declarative venvs ﾄｩ ﾓｼﾞｭｰﾙ |

---

## 2026-06-17T10:59:35+09:00

**摘要**：ﾙｲｰ — ﾆｯｸｽOS 模块（`services.ﾙｲｰ`），声明式生成 `/etc/xdg/ﾙｲｰ/ｺﾝﾌｨｸﾞ.toml` 与环境变量

| 提交 | 说明 |
|------|------|
| `5cea307` | feat(ﾙｲｰ): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ﾌｫｱ declarative configuration |
| `ef377e4` | ﾌｨｯｸｽ(ﾙｲｰ): correct ｺﾝﾌｨｸﾞ ﾊﾟｽ ﾄｩ /etc/xdg/ﾙｲｰ (XDG spec) |
| `8059526` | ﾌｨｯｸｽ(ﾙｲｰ): replace lib.generators.toToml ｳｨｽﾞ manual generation |
| `cc396f8` | ﾌｨｯｸｽ(ﾙｲｰ): always generate ｺﾝﾌｨｸﾞ.toml when ﾓｼﾞｭｰﾙ enabled |

---

## 2026-06-17T10:00:00+09:00

**摘要**：ﾙｲｰ — 新增 devShell 支持，`nix develop github:Kihara777/NixKits#ﾙｲｰ` 即可进入环境

| 提交 | 说明 |
|------|------|
| `975295d` | refactor(flake): remove default ﾊﾟｯｹｰｼﾞ alias |

---

## 2026-06-17T09:48:33+09:00

**摘要**：ﾙｲｰ 0.51.0-alpha.20260616 — RuyiSDK 包管理器，新包（Python / Poetry 构建，ruff + mypy + 320 单元测试 + 52 集成测试全部通过）

| 提交 | 说明 |
|------|------|
| `622a5e2` | feat(pkg): add ﾙｲｰ — RuyiSDK ﾊﾟｯｹｰｼﾞ manager |

| 软件名 | 新版本 |
|--------|--------|
| ﾙｲｰ | 0.51.0-alpha.20260616 |

---

## 2026-06-20T17:30:00+09:00

**摘要**：技能系统重构 — translate-katakana→translate-katalish 重命名，新增 translate-pseudocn（偽中国語），write-project-docs 与 write-maintenance-log 语言扩展自动发现，文档代码五语映射表

| 提交 | 说明 |
|------|------|
| `fee1534` | docs(ｽｷﾙ): add translate-* support ｱﾝﾄﾞ docs-as-code mapping ﾄｩ write-maintenance-log |
| `177ad9b` | refactor: rename translate-katakana→translate-katalish, add translate-pseudocn, auto-discovery |
| `39906b9` | docs: purge remaining pcn references ﾌﾛﾑ zh write-project-docs |
| `911052b` | refactor(docs): migrate pcn ﾃﾞｨﾚｸﾄﾘ ﾄｩ katalish |
| `7caf343` | refactor(translate-katakana): rename kata-en → katalish, use ｶﾀﾘｯｼｭ ｱｽﾞ canonical ﾈｰﾑ |
| `97b696c` | docs(ｽｷﾙ): purge pcn references ﾌﾛﾑ write-project-docs, add kata-en |
| `f1904a1` | feat(ｽｷﾙ): add translate-katakana — katakana english mechanical substitution |
| `c5fb218` | docs: write-project-docs 英日文版同步更新四语(pcn)支持 |
| `0588ee0` | ｽｷﾙ: write-project-docs 新增伪中国语(pcn)语言支持 |

---

## 2026-06-17T07:00:00+09:00

**摘要**：write-maintenance-log 技能 — 从 nixkits-check-updates 剥离为独立技能，双入口设计（记入维护记录 + 更新维护记录）；flake.lock 同步 .gitignore 前置检测与三路分支逻辑

| 提交 | 说明 |
|------|------|
| `b77170a` | docs(ｽｷﾙ): re-apply flake.lock sync ｱﾝﾄﾞ ﾋﾞﾙﾄﾞ verification steps |
| `be2239b` | docs(ｽｷﾙ): add .gitignore pre-check ﾄｩ flake.lock sync step |
| `704ebe4` | docs(ｽｷﾙ): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(ｽｷﾙ): extract write-maintenance-log ｱｽﾞ standalone ｽｷﾙ |
| `5187b07` | docs(ｽｷﾙ): optimize write-maintenance-log triggers ｱﾝﾄﾞ add audit entry |

---

## 2026-06-17T06:50:00+09:00

**摘要**：llama-cpp-rocm — 尝试用 builtins.fetchurl 替代 flake input 动态获取版本（已撤销，方案不可用）

| 提交 | 说明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input ｳｨｽﾞ builtins.fetchurl |
| `b3d9c05` | ﾌｨｯｸｽ(llama-cpp-rocm): use bare builtins.fetchurl without ﾊｯｼｭ param |

---

## 2026-06-16T08:00:00+09:00

**摘要**：mcp-searxng 文档 — CodeWhale ｴﾑｼｰﾋﾟｰ 配置指南、常见陷阱警告（ｴﾇﾌﾞｲ 默认为 {}）、故障排查章节

| 提交 | 说明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale ｺﾝﾌｨｸﾞ, common pitfall, ｱﾝﾄﾞ troubleshooting |

---

## 2026-06-16T07:50:00+09:00

**摘要**：nixos-modern-cli 技能 — ﾆｯｸｽ Store 路径陷阱章节（gh auth setup-git 硬编码路径失效的诊断与通用修复模式）

| 提交 | 说明 |
|------|------|
| `bd42478` | docs(ｽｷﾙ): add ﾆｯｸｽ Store ﾊﾟｽ trap section ﾄｩ nixos-modern-cli |

---

## 2026-06-14T07:50:00+09:00

**摘要**：comfyui-strix-halo 文档 — 在线集成模式说明与文件结构图

| 提交 | 说明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): ｱｯﾌﾟﾃﾞｰﾄ integration mode ｱﾝﾄﾞ ﾌｧｲﾙ structure |

---

## 2026-06-12T05:50:00+09:00

**摘要**：llama-cpp-rocm 模块 — 恢复 modelsPreset 支持（nixpkgs 已移除）、命名空间迁移至 nixkits、三语迁移指南

| 提交 | 说明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): ﾘｽﾄｱ modelsPreset via nixkits namespace, migrate ﾌﾛﾑ services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration ｶﾞｲﾄﾞ |

---

## 2026-06-11T05:28:00+09:00

**摘要**：技能文档 — 维护日志格式规则系列（自动发现泛化、描述性标题、精确 git ｺﾐｯﾄ 时间戳、禁止 T00:00:00 占位符）

| 提交 | 说明 |
|------|------|
| `7902bd1` | docs(ﾒﾝﾃﾅﾝｽ): ﾌｨｯｸｽ timestamps ﾄｩ exact ｺﾐｯﾄ times |
| `7680adf` | docs(ｽｷﾙ): enforce exact git ｺﾐｯﾄ timestamps, ban T00:00:00 placeholder |
| `f92f9c4` | docs(ﾒﾝﾃﾅﾝｽ): use descriptive titles instead ｵﾌﾞ filename |
| `07f347f` | docs(ｽｷﾙ): add descriptive ﾀｲﾄﾙ ﾙｰﾙ ﾌｫｱ ﾒﾝﾃﾅﾝｽ ﾌｧｲﾙｽﾞ |
| `487e18f` | docs(skills): sync descriptive ﾀｲﾄﾙ ﾙｰﾙ ﾄｩ trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content ﾄｩ auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations ﾄｩ trilingual docs |

---

## 2026-06-10T04:31:00+09:00

**摘要**：opencode-telegram — KillMode 改为 process、添加 TimeoutStopSec 防止关机挂起

| 提交 | 说明 |
|------|------|
| `fbcf15c` | ﾌｨｯｸｽ(opencode-telegram): add TimeoutStopSec ｱﾝﾄﾞ KillMode ﾄｩ prevent shutdown hang |
| `6cda338` | ﾌｨｯｸｽ(opencode-telegram): change KillMode ﾌﾛﾑ mixed ﾄｩ process |

---

## 2026-06-08T15:00:00+09:00

**摘要**：文档重构 — 本地化文件移入 docs/ 目录；ﾒﾝﾃﾅﾝｽ.md 首次添加合列规则、纯表格格式、回填完整提交历史

| 提交 | 说明 |
|------|------|
| `b3d7d0f` | docs: switch ﾒﾝﾃﾅﾝｽ.md ﾄｩ table-only ﾌｫｰﾏｯﾄ, drop trilingual prose |
| `e4a3813` | docs: omit ﾋﾞﾙﾄﾞ status ｱﾝﾄﾞ unchanged hashes ﾌﾛﾑ ﾒﾝﾃﾅﾝｽ.md |
| `4bf2d30` | docs(ｽｷﾙ): add first-time ﾊﾟｯｹｰｼﾞ ﾃｰﾌﾞﾙ ﾌｫｰﾏｯﾄ ﾙｰﾙ |
| `f7bb6ce` | docs(ｽｷﾙ): merge ﾊﾞｰｼﾞｮﾝ columns ﾌｫｱ first-time packages |
| `1a28625` | docs(ﾒﾝﾃﾅﾝｽ): backfill full ﾊﾟｯｹｰｼﾞ history ﾌﾛﾑ repo creation |
| `b4742ad` | docs(skills): sync refined ﾒﾝﾃﾅﾝｽ.md ﾌｫｰﾏｯﾄ ﾙｰﾙｽﾞ ﾄｩ trilingual docs |
| `2f58ac5` | refactor: move localized README/ﾒﾝﾃﾅﾝｽ ﾌｧｲﾙｽﾞ into docs/ |
| `551e6fd` | docs(skills): sync localized-file-in-docs/ ﾙｰﾙ ｱﾝﾄﾞ ﾊﾟｽ updates |

---

## 2026-06-08T14:55:00+09:00

**摘要**：rcc-fix — ﾆｯｸｽOS 模块（systemd 死锁修复）

| 提交 | 说明 |
|------|------|
| `141f4af` | feat(rcc-fix): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ﾌｫｱ systemd deadlock ﾌｨｯｸｽ |

---

## 2026-06-06T06:00:00+09:00

**摘要**：技能文档 — 源变更后文档同步规范；comfyui-strix-halo C 工具链说明；ﾊｯｼｭ 计算注意事项泛化；基本情報规则多语言统一

| 提交 | 说明 |
|------|------|
| `7e22edd` | docs(ｽｷﾙ): add ｽｷﾙ doc ﾃﾝﾌﾟﾚｰﾄ, sync ﾙｰﾙｽﾞ, ｱﾝﾄﾞ staleness check |
| `86fc7c2` | docs(skills): sync write-project-docs trilingual docs ｳｨｽﾞ ｽｷﾙ.md |
| `454a4e4` | ﾌｨｯｸｽ(ｽｷﾙ): generalize 基本情報 ﾙｰﾙ ﾄｩ ｵｰﾙ languages, ﾉｯﾄ just Japanese |
| `28ec492` | docs(skills): sync generalized 基本情報 ﾙｰﾙ ﾄｩ trilingual docs |
| `c79ffff` | docs(ｽｷﾙ): add SRI ﾊｯｼｭ ﾌｫｰﾏｯﾄ ｱﾝﾄﾞ nix ﾋﾞﾙﾄﾞ gotchas ﾄｩ ｱｯﾌﾟﾃﾞｰﾄ ｽｷﾙ |
| `6dcbbfc` | docs(skills): sync ﾊｯｼｭ gotchas ﾄｩ nixkits-check-updates trilingual docs |
| `58b06ea` | docs(comfyui-strix-halo): clarify kernel param ｲｽﾞ set ﾊﾞｲ ﾓｼﾞｭｰﾙ, ﾉｯﾄ hardware |
| `2ba85d3` | docs(comfyui-strix-halo): add C ﾋﾞﾙﾄﾞ toolchain + CC=gcc ﾄｩ changes ﾘｽﾄ |
| `f5941ae` | docs(ｽｷﾙ): add anti-patterns ﾌｫｱ stale/unsynced doc bullets after ｿｰｽ changes |
| `b8c2399` | docs(skills): sync source-change doc sync ﾙｰﾙ ﾄｩ trilingual docs |

---

## 2026-06-04T00:00:00+09:00

**摘要**：技能系统 — ｽｷﾙ.md 全面中文化；三语对称性检查规则

| 提交 | 说明 |
|------|------|
| `8aa65da` | docs(ｽｷﾙ): add trilingual symmetry checks ｱﾝﾄﾞ ja 基本情報 ﾙｰﾙ ﾄｩ write-project-docs |
| `7dad578` | feat(skills): localize ｵｰﾙ ｽｷﾙ.md ﾄｩ Chinese, declare ｲﾝ READMEs |

---

## 2026-06-02T00:00:00+09:00

**摘要**：nixos-modern-cli 技能 — POSIX 工具指南与 nix 二进制路径提示

| 提交 | 说明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX ﾂｰﾙ ｶﾞｲﾄﾞ ｱﾝﾄﾞ nix ﾊﾞｲﾅﾘ tip |

---

## 2026-05-31T00:00:00+09:00

**摘要**：write-project-docs — 新技能（按 NixKits 风格为任意项目编写多语言文档系统）

| 提交 | 说明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs ｽｷﾙ ｳｨｽﾞ trilingual docs |

---

## 2026-05-30T00:00:00+09:00

**摘要**：codewhale — stdenv 拼写修复；llama-cpp-rocm 文档修正（移除内联链接、使用 ｼｽﾃﾑ.nix 完整预设）；opencode-telegram 首次设置流程

| 提交 | 说明 |
|------|------|
| `2a8c41b` | docs(opencode-telegram): add first-time setup flow (opencode serve + ｺﾝﾌｨｸﾞ) |
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset ﾌﾛﾑ ｼｽﾃﾑ.nix |
| `15f956c` | docs(llama-cpp-rocm): replace ﾕｰｾｰｼﾞ ｳｨｽﾞ upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream ﾘﾝｸ ﾌﾛﾑ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
| `7e53e25` | docs(llama-cpp-rocm): remove inline ﾘﾝｸ ﾌﾛﾑ ﾕｰｾｰｼﾞ section too |
| `df4074f` | ﾌｨｯｸｽ(codewhale): ﾌｨｯｸｽ stdenv typo causing ﾋﾞﾙﾄﾞ failure |

---

## 2026-05-29T05:00:00+09:00

**摘要**：kitsfmt — 多项修复（vendor 目录恢复、幂等性、原地安全性、ｳｨｽﾞ→builtins.attrValues 转换、--stdin 标志）；rcc-fix — 重写为 D-Bus 热插拔检测；ﾋﾞﾙﾄﾞ — .vscode gitignore 范围修正

| 提交 | 说明 |
|------|------|
| `6a42efd` | ﾌｨｯｸｽ(kitsfmt): idempotency, inplace safety, output validation |
| `1b7d0a9` | ﾌｨｯｸｽ(ﾋﾞﾙﾄﾞ): restrict .vscode gitignore ﾄｩ repo root ﾄｩ ﾉｯﾄ exclude vendored crate ﾌｧｲﾙｽﾞ |
| `2b237ff` | feat(kitsfmt): ｳｨｽﾞ→builtins.attrValues best-practice transformation |
| `8497bf7` | feat(kitsfmt): add --stdin flag ﾌｫｱ explicit stdin mode |
| `a612af7` | feat(rcc-fix): rewrite ﾊﾟｯﾁ ﾌｫｱ asusctl 6.3.7 ｳｨｽﾞ hot-plug ｱﾝﾄﾞ boundary checks |
| `e56f122` | ﾌｨｯｸｽ(rcc-fix): scope hotplug variable correctly ﾌｫｱ asusctl ﾋﾞﾙﾄﾞ |
| `15a0104` | ﾌｨｯｸｽ(kitsfmt): ﾘｽﾄｱ vendor dir ﾌｫｱ offline builds |
| `6ba43df` | ﾌｨｯｸｽ(rcc-fix): set keyboard_connected=false when ﾉｰ aura iface found |
| `b7ebbfa` | ﾌｨｯｸｽ(rcc-fix): replace polling ｳｨｽﾞ D-Bus InterfacesAdded event |

---

## 2026-05-28T00:00:00+09:00

**摘要**：llama-cpp-rocm — ﾆｯｸｽOS 模块（systemd 沙箱覆盖）；opencode-telegram — ﾆｯｸｽOS 模块（声明式配置、自动安装）；rcc-fix — visible 属性修复；技能文档 — 动态发现措辞

| 提交 | 说明 |
|------|------|
| `3d2c38c` | docs(ｽｷﾙ): nixkits-check-updates — dynamic discovery, ﾉｯﾄ hardcoded ﾘｽﾄ |
| `e5ee4ab` | docs(ｽｷﾙ): remove hardcoded count ﾌﾛﾑ features, add exclusion ﾉｰﾄ |
| `814731e` | docs(ｽｷﾙ): sync ja doc ｳｨｽﾞ zh/en — dynamic discovery wording |
| `713b693` | ﾌｨｯｸｽ(rcc-fix): use visible: property instead ｵﾌﾞ if conditional ﾌｫｱ ScrollView |
| `34d309b` | docs(skills): add ｲﾝｽﾄｰﾙ section ｳｨｽﾞ full 5-agent support ﾄｩ ｵｰﾙ skills |
| `2db934e` | docs(zh): simplify Skills ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ, remove semantic duplication |
| `8fe0b3d` | feat(opencode-telegram): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｳｨｽﾞ declarative ｺﾝﾌｨｸﾞ |
| `941eb48` | feat(opencode-telegram): auto-install ﾊﾟｯｹｰｼﾞ when ﾓｼﾞｭｰﾙ enabled |
| `bd9e1b9` | feat(llama-cpp-rocm): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ﾌｫｱ ｻｰﾋﾞｽ sandbox overrides |

---

## 2026-05-27T00:00:00+09:00

**摘要**：技能系统 — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三大技能同步上线；llama-cpp-rocm 动态追踪说明

| 提交 | 说明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli ｽｷﾙ ｳｨｽﾞ 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer ｳｨｽﾞ 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates ｽｷﾙ ｳｨｽﾞ 3-language docs |

---

## 2026-05-26T00:00:00+09:00

**摘要**：文档 — README 节名重命名（快速开始→添加、包→软件、ﾗｲｾﾝｽ→许可）

| 提交 | 说明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 ﾗｲｾﾝｽ→许可 |

---

## 2026-05-24T00:00:00+09:00

**摘要**：mcp-searxng 文档 — SearXNG + lighttpd 反向代理完整 ﾆｯｸｽOS 配置

| 提交 | 说明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse ﾌﾟﾛｷｼ ｺﾝﾌｨｸﾞ |

---

## 2026-05-22T00:00:00+09:00

**摘要**：llama-cpp-rocm — 移除 llama-cpp-ver flake 输入，使用 nixpkgs 默认版本

| 提交 | 说明 |
|------|------|
| `9e7f8e2` | ﾌｨｯｸｽ(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs ﾊﾞｰｼﾞｮﾝ directly |

---

## 2026-05-16T00:00:00+09:00

**摘要**：kitsfmt — 修复 match_ast! 宏语法错误、简化 comments_before 函数、修正 src 路径

| 提交 | 说明 |
|------|------|
| `e731eb7` | ﾌｨｯｸｽ(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | ﾌｨｯｸｽ(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | ﾌｨｯｸｽ(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

---

## 2026-05-15T00:00:00+09:00

**摘要**：kitsfmt — 基于 rnix AST 重写格式化引擎 v0.3.0；生成 Cargo.lock

| 提交 | 说明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |


## 2026-06-17T07:37:39+09:00

**摘要**：ｽｷﾙ — 5 项更新

| 提交 | 说明 |
|------|------|
| `b77170a` | docs(ｽｷﾙ): re-apply flake.lock sync ｱﾝﾄﾞ ﾋﾞﾙﾄﾞ verification steps |
| `be2239b` | docs(ｽｷﾙ): add .gitignore pre-check ﾄｩ flake.lock sync step |
| `704ebe4` | docs(ｽｷﾙ): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(ｽｷﾙ): extract write-maintenance-log ｱｽﾞ standalone ｽｷﾙ |
| `5187b07` | docs(ｽｷﾙ): optimize write-maintenance-log triggers ｱﾝﾄﾞ add audit entry |

---

## 2026-06-17T06:46:13+09:00

**摘要**：llama-cpp-rocm — 2 项更新

| 提交 | 说明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input ｳｨｽﾞ builtins.fetchurl |
| `b3d9c05` | ﾌｨｯｸｽ(llama-cpp-rocm): use bare builtins.fetchurl without ﾊｯｼｭ param |

---

## 2026-06-16T06:03:24+09:00

**摘要**：docs(mcp-searxng): add CodeWhale ｺﾝﾌｨｸﾞ, common pitfall, ｱﾝﾄﾞ troubleshooting

| 提交 | 说明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale ｺﾝﾌｨｸﾞ, common pitfall, ｱﾝﾄﾞ troubleshooting |

---

## 2026-06-16T05:20:34+09:00

**摘要**：docs(ｽｷﾙ): add ﾆｯｸｽ Store ﾊﾟｽ trap section ﾄｩ nixos-modern-cli

| 提交 | 说明 |
|------|------|
| `bd42478` | docs(ｽｷﾙ): add ﾆｯｸｽ Store ﾊﾟｽ trap section ﾄｩ nixos-modern-cli |

---

## 2026-06-14T08:11:16+09:00

**摘要**：docs(comfyui-strix-halo): ｱｯﾌﾟﾃﾞｰﾄ integration mode ｱﾝﾄﾞ ﾌｧｲﾙ structure

| 提交 | 说明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): ｱｯﾌﾟﾃﾞｰﾄ integration mode ｱﾝﾄﾞ ﾌｧｲﾙ structure |

---

## 2026-06-12T18:17:52+09:00

**摘要**：llama-cpp-rocm — 2 项更新

| 提交 | 说明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): ﾘｽﾄｱ modelsPreset via nixkits namespace, migrate ﾌﾛﾑ services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration ｶﾞｲﾄﾞ |

---

## 2026-06-11T05:28:34+09:00

**摘要**：refactor(skills): generalize hardcoded content ﾄｩ auto-discovery

| 提交 | 说明 |
|------|------|
| `3e9467f` | refactor(skills): generalize hardcoded content ﾄｩ auto-discovery |

---

## 2026-06-11T05:13:39+09:00

**摘要**：other — 2 项更新

| 提交 | 说明 |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual ﾓｼﾞｭｰﾙ docs |
| `f891ad2` | docs: ﾌｨｯｸｽ DeepSeek V4 Pro casing ｲﾝ author credits |

---

## 2026-06-11T04:58:02+09:00

**摘要**：docs(ｽｷﾙ): enforce exact git ｺﾐｯﾄ timestamps, ban T00:00:00 placeholder

| 提交 | 说明 |
|------|------|
| `7680adf` | docs(ｽｷﾙ): enforce exact git ｺﾐｯﾄ timestamps, ban T00:00:00 placeholder |

---

## 2026-06-10T02:25:05+09:00

**摘要**：ﾌｨｯｸｽ(opencode-telegram): add TimeoutStopSec ｱﾝﾄﾞ KillMode ﾄｩ prevent shutdown hang

| 提交 | 说明 |
|------|------|
| `fbcf15c` | ﾌｨｯｸｽ(opencode-telegram): add TimeoutStopSec ｱﾝﾄﾞ KillMode ﾄｩ prevent shutdown hang |

---

## 2026-06-08T14:58:59+09:00

**摘要**：ｽｷﾙ — 2 项更新

| 提交 | 说明 |
|------|------|
| `4bf2d30` | docs(ｽｷﾙ): add first-time ﾊﾟｯｹｰｼﾞ ﾃｰﾌﾞﾙ ﾌｫｰﾏｯﾄ ﾙｰﾙ |
| `f7bb6ce` | docs(ｽｷﾙ): merge ﾊﾞｰｼﾞｮﾝ columns ﾌｫｱ first-time packages |

---

## 2026-06-08T14:22:25+09:00

**摘要**：feat(rcc-fix): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ﾌｫｱ systemd deadlock ﾌｨｯｸｽ

| 提交 | 说明 |
|------|------|
| `141f4af` | feat(rcc-fix): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ﾌｫｱ systemd deadlock ﾌｨｯｸｽ |

---

## 2026-06-06T15:16:53+09:00

**摘要**：ｽｷﾙ — 5 项更新

| 提交 | 说明 |
|------|------|
| `8aa65da` | docs(ｽｷﾙ): add trilingual symmetry checks ｱﾝﾄﾞ ja 基本情報 ﾙｰﾙ ﾄｩ write-project-docs |
| `7e22edd` | docs(ｽｷﾙ): add ｽｷﾙ doc ﾃﾝﾌﾟﾚｰﾄ, sync ﾙｰﾙｽﾞ, ｱﾝﾄﾞ staleness check |
| `454a4e4` | ﾌｨｯｸｽ(ｽｷﾙ): generalize 基本情報 ﾙｰﾙ ﾄｩ ｵｰﾙ languages, ﾉｯﾄ just Japanese |
| `c79ffff` | docs(ｽｷﾙ): add SRI ﾊｯｼｭ ﾌｫｰﾏｯﾄ ｱﾝﾄﾞ nix ﾋﾞﾙﾄﾞ gotchas ﾄｩ ｱｯﾌﾟﾃﾞｰﾄ ｽｷﾙ |
| `f5941ae` | docs(ｽｷﾙ): add anti-patterns ﾌｫｱ stale/unsynced doc bullets after ｿｰｽ changes |

---

## 2026-06-06T15:15:31+09:00

**摘要**：docs(comfyui-strix-halo): add C ﾋﾞﾙﾄﾞ toolchain + CC=gcc ﾄｩ changes ﾘｽﾄ

| 提交 | 说明 |
|------|------|
| `2ba85d3` | docs(comfyui-strix-halo): add C ﾋﾞﾙﾄﾞ toolchain + CC=gcc ﾄｩ changes ﾘｽﾄ |

---

## 2026-06-06T13:07:30+09:00

**摘要**：feat(skills): localize ｵｰﾙ ｽｷﾙ.md ﾄｩ Chinese, declare ｲﾝ READMEs

| 提交 | 说明 |
|------|------|
| `7dad578` | feat(skills): localize ｵｰﾙ ｽｷﾙ.md ﾄｩ Chinese, declare ｲﾝ READMEs |

---

## 2026-06-05T03:42:25+09:00

**摘要**：docs(nixos-modern-cli): add POSIX ﾂｰﾙ ｶﾞｲﾄﾞ ｱﾝﾄﾞ nix ﾊﾞｲﾅﾘ tip

| 提交 | 说明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX ﾂｰﾙ ｶﾞｲﾄﾞ ｱﾝﾄﾞ nix ﾊﾞｲﾅﾘ tip |

---

## 2026-06-05T03:42:18+09:00

**摘要**：feat(skills): add write-project-docs ｽｷﾙ ｳｨｽﾞ trilingual docs

| 提交 | 说明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs ｽｷﾙ ｳｨｽﾞ trilingual docs |

---

## 2026-06-05T03:42:14+09:00

**摘要**：ﾌｨｯｸｽ(codewhale): ﾌｨｯｸｽ stdenv typo causing ﾋﾞﾙﾄﾞ failure

| 提交 | 说明 |
|------|------|
| `df4074f` | ﾌｨｯｸｽ(codewhale): ﾌｨｯｸｽ stdenv typo causing ﾋﾞﾙﾄﾞ failure |

---

## 2026-06-02T10:15:53+09:00

**摘要**：other — 7 项更新

| 提交 | 说明 |
|------|------|
| `3be4889` | docs: add recover-nixos-config ｽｷﾙ ｳｨｽﾞ multi-language docs |
| `fc5eca3` | docs: ﾌｨｯｸｽ Skills section titles ｱﾝﾄﾞ generic ｴｰｼﾞｪﾝﾄ descriptions |
| `d2e071f` | docs: add quantization levels ﾄｩ local model names |
| `22d206c` | docs: add UD- prefix ﾄｩ model quantization labels |
| `f15db79` | docs: add MIT ﾗｲｾﾝｽ ﾌｧｲﾙ ｱﾝﾄﾞ ﾘﾝｸ ﾌﾛﾑ ｵｰﾙ READMEs |
| `218aeca` | docs: add local flake input example alongside remote |
| `4f0f968` | docs: ﾌｨｯｸｽ local flake input syntax ﾄｩ match actual ﾕｰｾｰｼﾞ |

---

## 2026-06-02T08:49:47+09:00

**摘要**：opencode-telegram — 8 项更新

| 提交 | 说明 |
|------|------|
| `8fe0b3d` | feat(opencode-telegram): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｳｨｽﾞ declarative ｺﾝﾌｨｸﾞ |
| `8fe3fae` | docs(opencode-telegram): simplify ﾄｩ flake ﾓｼﾞｭｰﾙ ｺﾝﾌｨｸﾞ only, remove manual systemd |
| `ee0a904` | docs(opencode-telegram): rename ﾆｯｸｽOS ﾓｼﾞｭｰﾙ → flake ﾓｼﾞｭｰﾙ |
| `a38e426` | docs(opencode-telegram): use accurate section ﾈｰﾑ — ｻｰﾋﾞｽ ｺﾝﾌｨｸﾞ, ﾉｯﾄ ﾓｼﾞｭｰﾙ |
| `dea4dc6` | docs(opencode-telegram): show full flake.nix context ｲﾝ ｻｰﾋﾞｽ ｺﾝﾌｨｸﾞ |
| `44975ed` | docs(opencode-telegram): flake ﾓｼﾞｭｰﾙ ｱｽﾞ section ﾀｲﾄﾙ, consistent across langs |
| `941eb48` | feat(opencode-telegram): auto-install ﾊﾟｯｹｰｼﾞ when ﾓｼﾞｭｰﾙ enabled |
| `2a8c41b` | docs(opencode-telegram): add first-time setup flow (opencode serve + ｺﾝﾌｨｸﾞ) |

---

## 2026-06-02T08:29:27+09:00

**摘要**：feat(llama-cpp-rocm): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ﾌｫｱ ｻｰﾋﾞｽ sandbox overrides

| 提交 | 说明 |
|------|------|
| `bd9e1b9` | feat(llama-cpp-rocm): add ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ﾌｫｱ ｻｰﾋﾞｽ sandbox overrides |

---

## 2026-06-02T07:34:30+09:00

**摘要**：zh — 2 项更新

| 提交 | 说明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 ﾗｲｾﾝｽ→许可 |
| `2db934e` | docs(zh): simplify Skills ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ, remove semantic duplication |

---

## 2026-06-02T06:44:17+09:00

**摘要**：ﾌｨｯｸｽ(rcc-fix): use visible: property instead ｵﾌﾞ if conditional ﾌｫｱ ScrollView

| 提交 | 说明 |
|------|------|
| `713b693` | ﾌｨｯｸｽ(rcc-fix): use visible: property instead ｵﾌﾞ if conditional ﾌｫｱ ScrollView |

---

## 2026-06-02T06:08:13+09:00

**摘要**：skills — 3 项更新

| 提交 | 说明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli ｽｷﾙ ｳｨｽﾞ 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer ｳｨｽﾞ 3-language docs |
| `627c9c5` | feat(skills): add nixkits-check-updates ｽｷﾙ ｳｨｽﾞ 3-language docs |

---

## 2026-05-30T06:45:11+09:00

**摘要**：ﾌｨｯｸｽ(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs ﾊﾞｰｼﾞｮﾝ directly

| 提交 | 说明 |
|------|------|
| `9e7f8e2` | ﾌｨｯｸｽ(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs ﾊﾞｰｼﾞｮﾝ directly |

---

## 2026-05-30T03:19:48+09:00

**摘要**：other — 2 项更新

| 提交 | 说明 |
|------|------|
| `358316c` | docs: add English ｱﾝﾄﾞ Japanese translations ｳｨｽﾞ I18n structure |
| `bef3b4b` | docs: add English ｱﾝﾄﾞ Japanese README ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ switcher |

---

## 2026-05-30T03:01:02+09:00

**摘要**：docs(mcp-searxng): add full SearXNG + lighttpd reverse ﾌﾟﾛｷｼ ｺﾝﾌｨｸﾞ

| 提交 | 说明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse ﾌﾟﾛｷｼ ｺﾝﾌｨｸﾞ |

---

## 2026-05-29T15:25:12+09:00

**摘要**：rcc-fix — 4 项更新

| 提交 | 说明 |
|------|------|
| `a612af7` | feat(rcc-fix): rewrite ﾊﾟｯﾁ ﾌｫｱ asusctl 6.3.7 ｳｨｽﾞ hot-plug ｱﾝﾄﾞ boundary checks |
| `e56f122` | ﾌｨｯｸｽ(rcc-fix): scope hotplug variable correctly ﾌｫｱ asusctl ﾋﾞﾙﾄﾞ |
| `6ba43df` | ﾌｨｯｸｽ(rcc-fix): set keyboard_connected=false when ﾉｰ aura iface found |
| `b7ebbfa` | ﾌｨｯｸｽ(rcc-fix): replace polling ｳｨｽﾞ D-Bus InterfacesAdded event |

---

## 2026-05-29T14:27:17+09:00

**摘要**：kitsfmt — 3 项更新

| 提交 | 说明 |
|------|------|
| `2b237ff` | feat(kitsfmt): ｳｨｽﾞ→builtins.attrValues best-practice transformation |
| `8497bf7` | feat(kitsfmt): add --stdin flag ﾌｫｱ explicit stdin mode |
| `15a0104` | ﾌｨｯｸｽ(kitsfmt): ﾘｽﾄｱ vendor dir ﾌｫｱ offline builds |

---

## 2026-05-29T13:16:30+09:00

**摘要**：docs: ﾌｨｯｸｽ codewhale ﾀｲﾌﾟ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ (pre-built, ﾉｯﾄ source-built)

| 提交 | 说明 |
|------|------|
| `14e060c` | docs: ﾌｨｯｸｽ codewhale ﾀｲﾌﾟ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ (pre-built, ﾉｯﾄ source-built) |

---

## 2026-05-29T05:57:55+09:00

**摘要**：ﾌｨｯｸｽ(ﾋﾞﾙﾄﾞ): restrict .vscode gitignore ﾄｩ repo root ﾄｩ ﾉｯﾄ exclude vendored crate ﾌｧｲﾙｽﾞ

| 提交 | 说明 |
|------|------|
| `1b7d0a9` | ﾌｨｯｸｽ(ﾋﾞﾙﾄﾞ): restrict .vscode gitignore ﾄｩ repo root ﾄｩ ﾉｯﾄ exclude vendored crate ﾌｧｲﾙｽﾞ |

---

## 2026-05-27T21:26:59+09:00

**摘要**：ﾌｨｯｸｽ(kitsfmt): idempotency, inplace safety, output validation

| 提交 | 说明 |
|------|------|
| `6a42efd` | ﾌｨｯｸｽ(kitsfmt): idempotency, inplace safety, output validation |

---

## 2026-05-16T19:07:54+09:00

**摘要**：kitsfmt — 6 项更新

| 提交 | 说明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |
| `e731eb7` | ﾌｨｯｸｽ(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | ﾌｨｯｸｽ(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | ﾌｨｯｸｽ(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

---


## 2026-06-16T04:56:06+09:00

**摘要**：opencode-telegram 0.21.2 — 上游修复及依赖更新

| 提交 | 说明 |
|------|------|
| `3b05a32` | docs(ﾒﾝﾃﾅﾝｽ): record 2026-06-16 ｱｯﾌﾟﾃﾞｰﾄ (opencode-telegram 0.21.2) |
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | ｿｰｽ ﾊｯｼｭ | `sha256-V/rThMV5...` → `sha256-NEaQ2grHCKXi13utcHeUR83pJT6kqBGS4UqllhG93kY=` |
| 　 | npmDepsHash | `sha256-Bcexury...` → `sha256-z9trDo9xeWZyTSvCqX5XTb+AHY50wk0gsoEnAAEHOEg=` |

---

## 2026-06-15T17:32:16+09:00

**摘要**：codewhale 0.8.60 — 上游修复

| 提交 | 说明 |
|------|------|
| `3cef0a8` | docs(ﾒﾝﾃﾅﾝｽ): record 2026-06-15 ｱｯﾌﾟﾃﾞｰﾄ (codewhale 0.8.60) |
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli ﾊｯｼｭ | `sha256-ti/IBPZV...` → `sha256-JqlByElHoLcR2Mlwmx5Qczfj+EoAp+igdLCd/QUOsX4=` |
| 　 | tui ﾊｯｼｭ | `sha256-3Lh80hTS...` → `sha256-LTf681cWVH9Cu3TQrFeMlJUNVVG+TWxO2oI6VXK+4zA=` |

---

## 2026-06-14T07:56:11+09:00

**摘要**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；mcp-searxng 1.4.0 — 新增 HTTP 传输模式

| 提交 | 说明 |
|------|------|
| `ec7d5ca` | docs(ﾒﾝﾃﾅﾝｽ): record 2026-06-14 updates (codewhale 0.8.59, mcp-searxng 1.4.0) |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
| 　 | cli ﾊｯｼｭ | `sha256-AR9jJZzB...` → `sha256-ti/IBPZVJdaLvQ00OevzTfcMQ0XHELvOKTcul4+iBg8=` |
| 　 | tui ﾊｯｼｭ | `sha256-BpCHu9M...` → `sha256-3Lh80hTSMG0RG+CHkR403rqcMtDA6kMdbyvBe7sLQaQ=` |
| 　 | ｿｰｽ ﾊｯｼｭ | `sha256-Xsp1vReg...` → `sha256-RMzxCBua89oYbKXmwXCtcSHan5QVefsm8IBdMIVq7UE=` |
| 　 | npmDepsHash | `sha256-3hWshG0...` → `sha256-Lh1UoM8zSMFji/TkqDAOiRtFRrQ/jqn5TbONySj9ckg=` |

---

## 2026-06-12T10:51:31+09:00

**摘要**：codewhale 0.8.58 — 上游修复；mcp-searxng 1.3.4 — 上游修复

| 提交 | 说明 |
|------|------|
| `716d98c` | docs(ﾒﾝﾃﾅﾝｽ): record 2026-06-12 updates (codewhale 0.8.58, mcp-searxng 1.3.4) |
| `ef9daae` | chore(pkgs): bump mcp-searxng 1.3.4 |
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| mcp-searxng | 1.3.2 | 1.3.4 |
| 　 | cli ﾊｯｼｭ | `sha256-Hp0Z6mwe...` → `sha256-AR9jJZzB1VNUe7yaI3jpSUJsXuzgvqk5aWeLWe/L/vA=` |
| 　 | tui ﾊｯｼｭ | `sha256-dExfhrfG...` → `sha256-BpCHu9MbDGuCAXNNJXPTZpj3BrIwx7jWs29I31cbSag=` |
| 　 | ｿｰｽ ﾊｯｼｭ | `sha256-OVllsRM...` → `sha256-Xsp1vRegHDWNk54nqLk+4l5MI0xGgocCg5Qa2UwWNqA=` |
| 　 | npmDepsHash | `sha256-LN9yDbw...` → `sha256-3hWshG0L8k0U2fnmz0OotrYaPAYBQE7DanjXgnFnNrE=` |

---

## 2026-06-11T04:52:16+09:00

**摘要**：codewhale 0.8.57 — TUI 新增；mcp-searxng 1.3.2 — 上游修复

| 提交 | 说明 |
|------|------|
| `07f347f` | docs(ｽｷﾙ): add descriptive ﾀｲﾄﾙ ﾙｰﾙ ﾌｫｱ ﾒﾝﾃﾅﾝｽ ﾌｧｲﾙｽﾞ |
| `f92f9c4` | docs(ﾒﾝﾃﾅﾝｽ): use descriptive titles instead ｵﾌﾞ filename |
| `7902bd1` | docs(ﾒﾝﾃﾅﾝｽ): ﾌｨｯｸｽ timestamps ﾄｩ exact ｺﾐｯﾄ times |
| `543bcf9` | chore(pkgs): bump codewhale 0.8.57, mcp-searxng 1.3.2 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.55 | 0.8.57 |
| mcp-searxng | 1.3.1 | 1.3.2 |
| 　 | cli ﾊｯｼｭ | `sha256-jwn3rKD...` → `sha256-Hp0Z6mweaC+sB/BH2KpD1W/sdS0me69pErKiWOa2GqY=` |
| 　 | tui ﾊｯｼｭ | `sha256-1Cxofu9...` → `sha256-dExfhrfGs1wbWWmvXYTuCGXKnkhD+7rBY32aV938Dz0=` |

---

## 2026-06-10T02:28:10+09:00

**摘要**：codewhale 0.8.55 — 上游修复；mcp-searxng 1.3.1 — 上游修复

| 提交 | 说明 |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli ﾊｯｼｭ | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui ﾊｯｼｭ | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

---

## 2026-06-08T14:25:02+09:00

**摘要**：mcp-searxng 1.2.1 — 上游修复

| 提交 | 说明 |
|------|------|
| `2f58ac5` | refactor: move localized README/ﾒﾝﾃﾅﾝｽ ﾌｧｲﾙｽﾞ into docs/ |
| `e5e505e` | docs(skills): sync trilingual ﾒﾝﾃﾅﾝｽ ﾙｰﾙ ﾄｩ ｽｷﾙ docs |
| `b34ed08` | docs: add trilingual ﾒﾝﾃﾅﾝｽ (en/ja) ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ switchers |
| `b4742ad` | docs(skills): sync refined ﾒﾝﾃﾅﾝｽ.md ﾌｫｰﾏｯﾄ ﾙｰﾙｽﾞ ﾄｩ trilingual docs |
| `1a28625` | docs(ﾒﾝﾃﾅﾝｽ): backfill full ﾊﾟｯｹｰｼﾞ history ﾌﾛﾑ repo creation |
| `2cd9daf` | docs: drop doc-sync line ﾌﾛﾑ ﾒﾝﾃﾅﾝｽ; only record substantive rewrites |
| `e4a3813` | docs: omit ﾋﾞﾙﾄﾞ status ｱﾝﾄﾞ unchanged hashes ﾌﾛﾑ ﾒﾝﾃﾅﾝｽ.md |
| `b3d7d0f` | docs: switch ﾒﾝﾃﾅﾝｽ.md ﾄｩ table-only ﾌｫｰﾏｯﾄ, drop trilingual prose |
| `b8a98bc` | docs(ｽｷﾙ): skip ﾒﾝﾃﾅﾝｽ.md when ﾉｰ updates found |
| `5ba1361` | docs(skills): sync ﾒﾝﾃﾅﾝｽ.md step ﾄｩ trilingual docs |
| `d4cb81f` | docs(ｽｷﾙ): add Step 8 — ﾒﾝﾃﾅﾝｽ.md ｱｯﾌﾟﾃﾞｰﾄ workflow |
| `db680df` | docs: add ﾒﾝﾃﾅﾝｽ.md — ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄ changelog |
| `07b1ee5` | chore(pkgs): bump mcp-searxng 1.1.0 → 1.2.1 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | 1.1.0 | 1.2.1 |

---

## 2026-06-06T13:58:47+09:00

**摘要**：codewhale 0.8.53 — 上游修复；mcp-searxng 1.1.0 — 上游修复；opencode-telegram 0.21.1 — 上游修复

| 提交 | 说明 |
|------|------|
| `300a9a6` | chore(pkgs): bump codewhale 0.8.53, mcp-searxng 1.1.0, opencode-telegram 0.21.1 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.49 | 0.8.53 |
| mcp-searxng | 1.0.4 | 1.1.0 |
| opencode-telegram | 0.21.0 | 0.21.1 |
| 　 | cli ﾊｯｼｭ | `sha256-97zk4L...` → `sha256-VxBNH2o4iEkk0PrnuZHDPECjvm+ARXR9T/BV8QqvYtw=` |
| 　 | tui ﾊｯｼｭ | `sha256-tc/s3e...` → `sha256-DBiWk4c4QFh/BKPlG5a3KkH0ZTxNQgqZ7IWwH4OaEEw=` |
| 　 | ｿｰｽ ﾊｯｼｭ | `sha256-ML5Hgle...` → `sha256-OVllsRMst6dWO/RagsmGyWN3muz1ATtffxfmLTfa0qU=` |
| 　 | npmDepsHash(searx) | `sha256-xnefgQ...` → `sha256-LN9yDbwvlICoFl5KgQvzZjLGXflVM0QkSzaB2dJzR/w=` |
| 　 | ｿｰｽ ﾊｯｼｭ(ﾃﾚｸﾞﾗﾑ) | `sha256-Al7CVol...` → `sha256-V/rThMV5qZ5Z07A+A54Il4Vi/69bv8PVgV6uIr6vxGA=` |
| 　 | npmDepsHash(ﾃﾚｸﾞﾗﾑ) | `sha256-ZOhS7l...` → `sha256-BcexuryL26CNLKeAOR9DffE07H4dYO1UYPqfX9aHm4g=` |

---

## 2026-06-06T12:51:46+09:00

**摘要**：comfyui-strix-halo 补丁 — ROCm 7.2 wheels 内嵌支持

| 提交 | 说明 |
|------|------|
| `58b06ea` | docs(comfyui-strix-halo): clarify kernel param ｲｽﾞ set ﾊﾞｲ ﾓｼﾞｭｰﾙ, ﾉｯﾄ hardware |
| `468b89a` | feat(ｽｷﾙ): add patch-embedded ﾊﾞｰｼﾞｮﾝ check ﾌｫｱ comfyui-strix-halo |
| `8f16f91` | docs(ｽｷﾙ): add length/structure ﾙｰﾙｽﾞ ﾌﾛﾑ comfyui-strix-halo doc ﾌｨｯｸｽ |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs ｲﾝ NixKits concise style |
| `48d842f` | docs(ja): add 基本情報 section ﾄｩ comfyui-strix-halo |
| `e11f899` | ﾌｨｯｸｽ(docs): add missing ja doc ｱﾝﾄﾞ en/ja README entries ﾌｫｱ comfyui-strix-halo |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| comfyui-strix-halo | 补丁（ROCm 7.2 wheels 内嵌） |

---

## 2026-06-02T05:57:11+09:00

**摘要**：codewhale 0.8.49 — 上游修复；mcp-searxng 1.0.4 — 上游修复；obs-bilibili-stream 2.1.0 — 上游修复；opencode-telegram 0.21.0 — 上游修复

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.47 | 0.8.49 |
| mcp-searxng | 1.0.3 | 1.0.4 |
| obs-bilibili-stream | 2.0.12 | 2.1.0 |
| opencode-telegram | 0.20.5 | 0.21.0 |
| 　 | cli ﾊｯｼｭ | `sha256-JGNVKih...` → `sha256-97zk4LzahspVqd8U/Z8rfS60oOWNUPsWn4xtn/rL8CQ=` |
| 　 | tui ﾊｯｼｭ | — → `sha256-tc/s3e1oomJhfYEN1EtuEtPBF77dByrMimDH3bQibCI=` |
| 　 | ｿｰｽ ﾊｯｼｭ(searx) | `sha256-xS2Hr/g...` → `sha256-ML5HgleThmzBwJFtmsCQEPxHvZz4gzrDxW3Udkx9YjA=` |
| 　 | npmDepsHash(searx) | `sha256-...+` → `sha256-xnefgQnFuHVPSCWVSD8MWxjHmNSrKpWlbGaAtks5rkg=` |
| 　 | ｿｰｽ ﾊｯｼｭ(ｵﾌﾞｴｽ) | — → `sha256-lbN73L3ey7qZftsgmRGb9wPcj8DmwlOUWR9gdEni29w=` |
| 　 | ｿｰｽ ﾊｯｼｭ(tele) | `sha256-RKsZwK...` → `sha256-Al7CVol/HDgH3M0FwkdQWOze6xY/wvaWOskRsh9Abxo=` |
| 　 | npmDepsHash(tele) | `sha256-...+` → `sha256-ZOhS7lX5z2bRi0Cilm2QBUVKmacK41oRcUn9kRcfdOg=` |

---

## 2026-05-29T10:18:46+09:00

**摘要**：codewhale v0.8.47 — 新包

| 提交 | 说明 |
|------|------|
| `979b75c` | refactor(codewhale): switch ﾄｩ pre-built binaries, remove cargoHash |
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI ｴｰｼﾞｪﾝﾄ) v0.8.47 |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | v0.8.47 |

---

## 2026-05-21T16:35:02+09:00

**摘要**：mcp-searxng v1.0.3 — 新包；opencode-telegram v0.20.5 — 新包

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

---

## 2026-05-14T17:10:06+09:00

**摘要**：llama-cpp-rocm — 新包（动态追踪上游最新 Release）

| 提交 | 说明 |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

---

## 2026-05-14T07:38:08+09:00

**摘要**：kitsfmt — 新包（自建 ﾆｯｸｽ 格式化器）；obs-bilibili-stream v1.0.0 — 新包

| 提交 | 说明 |
|------|------|
| `2c917bd` | feat: Add kitsfmt ﾌｫｰﾏｯﾀｰ ｱﾝﾄﾞ modernize flake structure |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

---

## 2026-05-01T01:08:15+09:00

**摘要**：rcc-fix — 新包（asusctl 补丁）

| 提交 | 说明 |
|------|------|
| `e2d09a2` | RCC-Fix |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（ｵｰﾊﾞｰﾚｲ + ﾊﾟｯﾁ） |

---

## 2026-06-17T06:48:47+09:00

**摘要**：ﾌｨｯｸｽ(mcp-searxng): 修复入口文件错误 — dist/index.js → dist/cli.js，ｴﾑｼｰﾋﾟｰ 服务器可正常启动

| 提交 | 说明 |
|------|------|
| `73a3b10` | ﾌｨｯｸｽ(mcp-searxng): use dist/cli.js ｱｽﾞ entry point instead ｵﾌﾞ dist/index.js |

---

## 2026-06-12T05:00:00+09:00

**摘要**：feat(llama-cpp-rocm): 恢复 modelsPreset 支持（nixpkgs 已移除），命名空间迁移至 nixkits

---

## 2026-06-10T04:31:20+09:00

**摘要**：ﾌｨｯｸｽ(opencode-telegram): 修改 KillMode 为 process，添加 TimeoutStopSec 防止关机挂起

| 提交 | 说明 |
|------|------|
| `6cda338` | ﾌｨｯｸｽ(opencode-telegram): change KillMode ﾌﾛﾑ mixed ﾄｩ process |

---

## 2026-05-29T05:30:00+09:00

**摘要**：ﾌｨｯｸｽ(kitsfmt): 修复 inherit 逗号、缩进字符串损坏、lambda 空格等多个格式化问题；修复幂等性

| 提交 | 说明 |
|------|------|
| `45f3c26` | feat(kitsfmt): rec→let-in conversion ｱﾝﾄﾞ multi-file support |
| `3656154` | chore(kitsfmt): ｱｯﾌﾟﾃﾞｰﾄ Cargo.lock ﾌｫｱ v0.4.0 |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections ｳｨｽﾞ ｴﾇﾌﾞｲ var support |
| `f4b56ba` | ﾌｨｯｸｽ(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |

---

## 2026-05-29T05:00:00+09:00

**摘要**：ﾌｨｯｸｽ(rcc-fix): 用 D-Bus InterfacesAdded 事件替代轮询，优化二合一键盘热插拔检测

---

## 2026-05-29T04:50:00+09:00

**摘要**：ﾌｨｯｸｽ(ﾋﾞﾙﾄﾞ): 修复 .vscode gitignore 范围过宽导致 vendored crate 文件被排除
