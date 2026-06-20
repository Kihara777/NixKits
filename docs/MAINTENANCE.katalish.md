# Maintenance Log

[中文](../MAINTENANCE.md) | [English](MAINTENANCE.en.md) | [日本語](MAINTENANCE.ja.md) | ｶﾀﾘｯｼｭ | [偽中国語](MAINTENANCE.pcn.md)

NixKits 软件更新维护日志。

---


## 2026-06-21T00:07:44+09:00

**ｻﾏﾘｰ**：codewhale 0.8.62 — 上游修复；ｴﾑｼｰﾋﾟｰ-searxng 1.7.1 — 上游修复

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| ｴﾑｼｰﾋﾟｰ-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, ｴﾑｼｰﾋﾟｰ-searxng 1.7.1 |

## 2026-06-18T09:52:34+09:00

**ｻﾏﾘｰ**：codewhale 0.8.61 — 上游修复；ｴﾑｼｰﾋﾟｰ-searxng 1.6.0 — 上游修复

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `...` | chore(pkgs): bump codewhale 0.8.61 |
| `...` | chore(pkgs): bump ｴﾑｼｰﾋﾟｰ-searxng 1.6.0 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.60 | 0.8.61 |
| 　 | cli hash | `...` → `sha256-3k0K/I/NxYHrNszgniQncWTu8HRqsR3RSg+YLuB+IkY=` |
| 　 | tui hash | `...` → `sha256-YVjKDO/JNnsAHwzCf4itrEw8psKyi9bbFaLJLFvMyAI=` |
| ｴﾑｼｰﾋﾟｰ-searxng | 1.4.0 | 1.6.0 |
| 　 | source hash | `...` → `sha256-oBpSAAppLfnPhC3tHoE2X1YAGMyd42fka+xAVFuhjKw=` |
| 　 | npmDepsHash | `...` → `sha256-7z5T8po2ya698J7vqu4pA7c8s85k33sRbOV2tRmGdPo=` |

---

## 2026-06-18T09:03:48+09:00

**ｻﾏﾘｰ**：ruyi — NixOS 兼容性补丁（`patches/ruyi-nixos-compat.patch`），透明处理预编译 ﾘｽｸ-V 工具链的动态链接器路径、GCC 子进程 ELF ｲﾝﾀｰﾌﾟﾘﾀ 修复和 console_scripts argv0 问题

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `d814550` | feat(ruyi): ｱﾄﾞ autoUpdate ｱﾝﾄﾞ declarative venvs ﾄｩ ﾓｼﾞｭｰﾙ |

---

## 2026-06-17T10:59:35+09:00

**ｻﾏﾘｰ**：ruyi — NixOS 模块（`services.ruyi`），声明式生成 `/etc/xdg/ruyi/config.toml` 与环境变量

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `5cea307` | feat(ruyi): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ declarative ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ |
| `ef377e4` | fix(ruyi): correct ｺﾝﾌｨｸﾞ ﾊﾟｽ ﾄｩ /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml ｳｨｽﾞ manual generation |
| `cc396f8` | fix(ruyi): always generate ｺﾝﾌｨｸﾞ.toml when ﾓｼﾞｭｰﾙ enabled |

---

## 2026-06-17T10:00:00+09:00

**ｻﾏﾘｰ**：ruyi — 新增 devShell 支持，`nix develop github:Kihara777/NixKits#ruyi` 即可进入环境

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `975295d` | refactor(flake): ﾘﾑｰﾌﾞ ﾃﾞﾌｫﾙﾄ ﾊﾟｯｹｰｼﾞ alias |

---

## 2026-06-17T09:48:33+09:00

**ｻﾏﾘｰ**：ruyi 0.51.0-alpha.20260616 — RuyiSDK 包管理器，新包（Python / Poetry 构建，ruff + mypy + 320 单元测试 + 52 集成测试全部通过）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `622a5e2` | feat(pkg): ｱﾄﾞ ruyi — RuyiSDK ﾊﾟｯｹｰｼﾞ manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

---

## 2026-06-20T17:30:00+09:00

**ｻﾏﾘｰ**：技能系统重构 — translate-katakana→translate-ｶﾀﾘｯｼｭ 重命名，新增 translate-pseudocn（偽中国語），ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs 与 ﾗｲﾄ-maintenance-log 语言扩展自动发现，文档代码五语映射表

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `fee1534` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ translate-* ｻﾎﾟｰﾄ ｱﾝﾄﾞ ﾄﾞｷｭｽﾞ-ｱｽﾞ-code ﾏｯﾋﾟﾝｸﾞ ﾄｩ ﾗｲﾄ-maintenance-log |
| `177ad9b` | refactor: rename translate-katakana→translate-ｶﾀﾘｯｼｭ, ｱﾄﾞ translate-pseudocn, ｵｰﾄ-ﾃﾞｨｽｶﾊﾞﾘｰ |
| `39906b9` | ﾄﾞｷｭｽﾞ: purge remaining ﾋﾟｰｼｰｴﾇ references ﾌﾛﾑ ｾﾞｯﾄｴｲﾁ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs |
| `911052b` | refactor(ﾄﾞｷｭｽﾞ): migrate ﾋﾟｰｼｰｴﾇ directory ﾄｩ ｶﾀﾘｯｼｭ |
| `7caf343` | refactor(translate-katakana): rename kata-ｴﾇ → ｶﾀﾘｯｼｭ, use ｶﾀﾘｯｼｭ ｱｽﾞ canonical name |
| `97b696c` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): purge ﾋﾟｰｼｰｴﾇ references ﾌﾛﾑ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs, ｱﾄﾞ kata-ｴﾇ |
| `f1904a1` | feat(ｽｷﾙ): ｱﾄﾞ translate-katakana — katakana ｲﾝｸﾞﾘｯｼｭ mechanical substitution |
| `c5fb218` | ﾄﾞｷｭｽﾞ: ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs 英日文版同步更新四语(ﾋﾟｰｼｰｴﾇ)支持 |
| `0588ee0` | ｽｷﾙ: ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs 新增伪中国语(ﾋﾟｰｼｰｴﾇ)语言支持 |

---

## 2026-06-17T07:00:00+09:00

**ｻﾏﾘｰ**：ﾗｲﾄ-maintenance-log 技能 — 从 nixkits-check-updates 剥离为独立技能，双入口设计（记入维护记录 + 更新维护记录）；flake.lock 同步 .gitignore 前置检测与三路分支逻辑

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `b77170a` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): re-apply flake.lock sync ｱﾝﾄﾞ ﾋﾞﾙﾄﾞ verification steps |
| `be2239b` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ .gitignore pre-check ﾄｩ flake.lock sync step |
| `704ebe4` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(ｽｷﾙ): extract ﾗｲﾄ-maintenance-log ｱｽﾞ standalone ｽｷﾙ |
| `5187b07` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): optimize ﾗｲﾄ-maintenance-log ﾄﾘｶﾞｰｽﾞ ｱﾝﾄﾞ ｱﾄﾞ audit entry |

---

## 2026-06-17T06:50:00+09:00

**ｻﾏﾘｰ**：llama-cpp-rocm — 尝试用 builtins.fetchurl 替代 flake input 动态获取版本（已撤销，方案不可用）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input ｳｨｽﾞ builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

---

## 2026-06-16T08:00:00+09:00

**ｻﾏﾘｰ**：ｴﾑｼｰﾋﾟｰ-searxng 文档 — CodeWhale ｴﾑｼｰﾋﾟｰ 配置指南、常见陷阱警告（env 默认为 {}）、故障排查章节

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `d670e1e` | ﾄﾞｷｭｽﾞ(ｴﾑｼｰﾋﾟｰ-searxng): ｱﾄﾞ CodeWhale ｺﾝﾌｨｸﾞ, common pitfall, ｱﾝﾄﾞ troubleshooting |

---

## 2026-06-16T07:50:00+09:00

**ｻﾏﾘｰ**：ﾆｯｸｽOS-modern-cli 技能 — ﾆｯｸｽ Store 路径陷阱章节（gh auth setup-git 硬编码路径失效的诊断与通用修复模式）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `bd42478` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ ﾆｯｸｽ Store ﾊﾟｽ trap ｾｸｼｮﾝ ﾄｩ ﾆｯｸｽOS-modern-cli |

---

## 2026-06-14T07:50:00+09:00

**ｻﾏﾘｰ**：ｶﾑﾌｨUI-strix-halo 文档 — 在线集成模式说明与文件结构图

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `c1fd014` | ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): ｱｯﾌﾟﾃﾞｰﾄ integration mode ｱﾝﾄﾞ file structure |

---

## 2026-06-12T05:50:00+09:00

**ｻﾏﾘｰ**：llama-cpp-rocm 模块 — 恢复 modelsPreset 支持（nixpkgs 已移除）、命名空间迁移至 nixkits、三语迁移指南

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate ﾌﾛﾑ ｻｰﾋﾞｽｽﾞ |
| `56ff235` | ﾄﾞｷｭｽﾞ(llama-cpp-rocm): ｱﾄﾞ trilingual migration ｶﾞｲﾄﾞ |

---

## 2026-06-11T05:28:00+09:00

**ｻﾏﾘｰ**：技能文档 — 维护日志格式规则系列（自动发现泛化、描述性标题、精确 git ｺﾐｯﾄ 时间戳、禁止 T00:00:00 占位符）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `7902bd1` | ﾄﾞｷｭｽﾞ(MAINTENANCE): fix timestamps ﾄｩ exact ｺﾐｯﾄ times |
| `7680adf` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): enforce exact git ｺﾐｯﾄ timestamps, ban T00:00:00 placeholder |
| `f92f9c4` | ﾄﾞｷｭｽﾞ(MAINTENANCE): use descriptive ﾀｲﾄﾙｽﾞ instead ｵﾌﾞ filename |
| `07f347f` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ descriptive ﾀｲﾄﾙ rule ﾌｫｱ MAINTENANCE files |
| `487e18f` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync descriptive ﾀｲﾄﾙ rule ﾄｩ trilingual ﾄﾞｷｭｽﾞ |
| `3e9467f` | refactor(ｽｷﾙｽﾞ): generalize hardcoded content ﾄｩ ｵｰﾄ-ﾃﾞｨｽｶﾊﾞﾘｰ |
| `033d3b8` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync ｵｰﾄ-ﾃﾞｨｽｶﾊﾞﾘｰ generalizations ﾄｩ trilingual ﾄﾞｷｭｽﾞ |

---

## 2026-06-10T04:31:00+09:00

**ｻﾏﾘｰ**：opencode-ﾃﾚｸﾞﾗﾑ — KillMode 改为 ﾌﾟﾛｾｽ、添加 TimeoutStopSec 防止关机挂起

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `fbcf15c` | fix(opencode-ﾃﾚｸﾞﾗﾑ): ｱﾄﾞ TimeoutStopSec ｱﾝﾄﾞ KillMode ﾄｩ prevent shutdown hang |
| `6cda338` | fix(opencode-ﾃﾚｸﾞﾗﾑ): change KillMode ﾌﾛﾑ mixed ﾄｩ ﾌﾟﾛｾｽ |

---

## 2026-06-08T15:00:00+09:00

**ｻﾏﾘｰ**：文档重构 — 本地化文件移入 ﾄﾞｷｭｽﾞ/ 目录；MAINTENANCE.md 首次添加合列规则、纯表格格式、回填完整提交历史

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `b3d7d0f` | ﾄﾞｷｭｽﾞ: switch MAINTENANCE.md ﾄｩ ﾃｰﾌﾞﾙ-ｵﾝﾘｰ ﾌｫｰﾏｯﾄ, drop trilingual prose |
| `e4a3813` | ﾄﾞｷｭｽﾞ: omit ﾋﾞﾙﾄﾞ status ｱﾝﾄﾞ unchanged hashes ﾌﾛﾑ MAINTENANCE.md |
| `4bf2d30` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ first-time ﾊﾟｯｹｰｼﾞ ﾃｰﾌﾞﾙ ﾌｫｰﾏｯﾄ rule |
| `f7bb6ce` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): merge ﾊﾞｰｼﾞｮﾝ columns ﾌｫｱ first-time ﾊﾟｯｹｰｼﾞｰｽﾞ |
| `1a28625` | ﾄﾞｷｭｽﾞ(MAINTENANCE): backfill full ﾊﾟｯｹｰｼﾞ history ﾌﾛﾑ repo creation |
| `b4742ad` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync refined MAINTENANCE.md ﾌｫｰﾏｯﾄ rules ﾄｩ trilingual ﾄﾞｷｭｽﾞ |
| `2f58ac5` | refactor: move localized README/MAINTENANCE files into ﾄﾞｷｭｽﾞ/ |
| `551e6fd` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync localized-file-in-docs/ rule ｱﾝﾄﾞ ﾊﾟｽ ｱｯﾌﾟﾃﾞｰﾄｽﾞ |

---

## 2026-06-08T14:55:00+09:00

**ｻﾏﾘｰ**：rcc-fix — NixOS 模块（systemd 死锁修复）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `141f4af` | feat(rcc-fix): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ systemd deadlock fix |

---

## 2026-06-06T06:00:00+09:00

**ｻﾏﾘｰ**：技能文档 — 源变更后文档同步规范；ｶﾑﾌｨUI-strix-halo c 工具链说明；hash 计算注意事项泛化；基本情報规则多语言统一

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `7e22edd` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ ｽｷﾙ ﾄﾞｷｭ ﾃﾝﾌﾟﾚｰﾄ, sync rules, ｱﾝﾄﾞ staleness check |
| `86fc7c2` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs trilingual ﾄﾞｷｭｽﾞ ｳｨｽﾞ ｽｷﾙ.md |
| `454a4e4` | fix(ｽｷﾙ): generalize 基本情報 rule ﾄｩ ｵｰﾙ ﾗﾝｹﾞｰｼﾞｽﾞ, ﾉｯﾄ ｼﾞｬｽﾄ ｼﾞｬﾊﾟﾆｰｽﾞ |
| `28ec492` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync generalized 基本情報 rule ﾄｩ trilingual ﾄﾞｷｭｽﾞ |
| `c79ffff` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ SRI hash ﾌｫｰﾏｯﾄ ｱﾝﾄﾞ ﾆｯｸｽ ﾋﾞﾙﾄﾞ gotchas ﾄｩ ｱｯﾌﾟﾃﾞｰﾄ ｽｷﾙ |
| `6dcbbfc` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync hash gotchas ﾄｩ nixkits-check-updates trilingual ﾄﾞｷｭｽﾞ |
| `58b06ea` | ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): clarify kernel param ｲｽﾞ set ﾊﾞｲ ﾓｼﾞｭｰﾙ, ﾉｯﾄ hardware |
| `2ba85d3` | ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): ｱﾄﾞ c ﾋﾞﾙﾄﾞ toolchain + CC=ｼﾞｰｼｰｼｰ ﾄｩ changes ﾘｽﾄ |
| `f5941ae` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ anti-patterns ﾌｫｱ stale/unsynced ﾄﾞｷｭ bullets after ｿｰｽ changes |
| `b8c2399` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync ｿｰｽ-change ﾄﾞｷｭ sync rule ﾄｩ trilingual ﾄﾞｷｭｽﾞ |

---

## 2026-06-04T00:00:00+09:00

**ｻﾏﾘｰ**：技能系统 — ｽｷﾙ.md 全面中文化；三语对称性检查规则

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `8aa65da` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ trilingual symmetry checks ｱﾝﾄﾞ ｼﾞｪｲｴｲ 基本情報 rule ﾄｩ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs |
| `7dad578` | feat(ｽｷﾙｽﾞ): localize ｵｰﾙ ｽｷﾙ.md ﾄｩ ﾁｬｲﾆｰｽﾞ, declare ｲﾝ READMEs |

---

## 2026-06-02T00:00:00+09:00

**ｻﾏﾘｰ**：ﾆｯｸｽOS-modern-cli 技能 — POSIX 工具指南与 ﾆｯｸｽ 二进制路径提示

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `4b103e5` | ﾄﾞｷｭｽﾞ(ﾆｯｸｽOS-modern-cli): ｱﾄﾞ POSIX ﾂｰﾙ ｶﾞｲﾄﾞ ｱﾝﾄﾞ ﾆｯｸｽ binary tip |

---

## 2026-05-31T00:00:00+09:00

**ｻﾏﾘｰ**：ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs — 新技能（按 NixKits 风格为任意项目编写多语言文档系统）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `373da95` | feat(ｽｷﾙｽﾞ): ｱﾄﾞ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs ｽｷﾙ ｳｨｽﾞ trilingual ﾄﾞｷｭｽﾞ |

---

## 2026-05-30T00:00:00+09:00

**ｻﾏﾘｰ**：codewhale — stdenv 拼写修复；llama-cpp-rocm 文档修正（移除内联链接、使用 ｼｽﾃﾑ.ﾆｯｸｽ 完整预设）；opencode-ﾃﾚｸﾞﾗﾑ 首次设置流程

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `2a8c41b` | ﾄﾞｷｭｽﾞ(opencode-ﾃﾚｸﾞﾗﾑ): ｱﾄﾞ first-time setup flow (opencode serve + ｺﾝﾌｨｸﾞ) |
| `aef12bc` | ﾄﾞｷｭｽﾞ(llama-cpp-rocm): use complete modelsPreset ﾌﾛﾑ ｼｽﾃﾑ.ﾆｯｸｽ |
| `15f956c` | ﾄﾞｷｭｽﾞ(llama-cpp-rocm): replace ﾕｰｾｰｼﾞ ｳｨｽﾞ upstream reference |
| `494f512` | ﾄﾞｷｭｽﾞ(llama-cpp-rocm): ﾘﾑｰﾌﾞ inline upstream ﾘﾝｸ ﾌﾛﾑ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
| `7e53e25` | ﾄﾞｷｭｽﾞ(llama-cpp-rocm): ﾘﾑｰﾌﾞ inline ﾘﾝｸ ﾌﾛﾑ ﾕｰｾｰｼﾞ ｾｸｼｮﾝ too |
| `df4074f` | fix(codewhale): fix stdenv typo causing ﾋﾞﾙﾄﾞ failure |

---

## 2026-05-29T05:00:00+09:00

**ｻﾏﾘｰ**：kitsfmt — 多项修复（vendor 目录恢复、幂等性、原地安全性、ｳｨｽﾞ→builtins.attrValues 转换、--stdin 标志）；rcc-fix — 重写为 D-Bus 热插拔检测；ﾋﾞﾙﾄﾞ — .vscode gitignore 范围修正

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `6a42efd` | fix(kitsfmt): idempotency, inplace safety, output validation |
| `1b7d0a9` | fix(ﾋﾞﾙﾄﾞ): restrict .vscode gitignore ﾄｩ repo ﾙｰﾄ ﾄｩ ﾉｯﾄ exclude vendored crate files |
| `2b237ff` | feat(kitsfmt): ｳｨｽﾞ→builtins.attrValues best-practice transformation |
| `8497bf7` | feat(kitsfmt): ｱﾄﾞ --stdin flag ﾌｫｱ explicit stdin mode |
| `a612af7` | feat(rcc-fix): rewrite ﾊﾟｯﾁ ﾌｫｱ asusctl 6.3.7 ｳｨｽﾞ hot-plug ｱﾝﾄﾞ boundary checks |
| `e56f122` | fix(rcc-fix): scope hotplug variable correctly ﾌｫｱ asusctl ﾋﾞﾙﾄﾞ |
| `15a0104` | fix(kitsfmt): restore vendor dir ﾌｫｱ offline ﾋﾞﾙﾄﾞｽﾞ |
| `6ba43df` | fix(rcc-fix): set keyboard_connected=false when ﾉｰ aura iface found |
| `b7ebbfa` | fix(rcc-fix): replace polling ｳｨｽﾞ D-Bus InterfacesAdded ｲﾍﾞﾝﾄ |

---

## 2026-05-28T00:00:00+09:00

**ｻﾏﾘｰ**：llama-cpp-rocm — NixOS 模块（systemd 沙箱覆盖）；opencode-ﾃﾚｸﾞﾗﾑ — NixOS 模块（声明式配置、自动安装）；rcc-fix — visible 属性修复；技能文档 — 动态发现措辞

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `3d2c38c` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): nixkits-check-updates — ﾀﾞｲﾅﾐｯｸ ﾃﾞｨｽｶﾊﾞﾘｰ, ﾉｯﾄ hardcoded ﾘｽﾄ |
| `e5ee4ab` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ﾘﾑｰﾌﾞ hardcoded count ﾌﾛﾑ ﾌｨｰﾁｬｰｽﾞ, ｱﾄﾞ exclusion note |
| `814731e` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): sync ｼﾞｪｲｴｲ ﾄﾞｷｭ ｳｨｽﾞ ｾﾞｯﾄｴｲﾁ/ｴﾇ — ﾀﾞｲﾅﾐｯｸ ﾃﾞｨｽｶﾊﾞﾘｰ wording |
| `713b693` | fix(rcc-fix): use visible: property instead ｵﾌﾞ if conditional ﾌｫｱ ScrollView |
| `34d309b` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): ｱﾄﾞ ｲﾝｽﾄｰﾙ ｾｸｼｮﾝ ｳｨｽﾞ full 5-agent ｻﾎﾟｰﾄ ﾄｩ ｵｰﾙ ｽｷﾙｽﾞ |
| `2db934e` | ﾄﾞｷｭｽﾞ(ｾﾞｯﾄｴｲﾁ): simplify ｽｷﾙｽﾞ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ, ﾘﾑｰﾌﾞ semantic duplication |
| `8fe0b3d` | feat(opencode-ﾃﾚｸﾞﾗﾑ): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ｳｨｽﾞ declarative ｺﾝﾌｨｸﾞ |
| `941eb48` | feat(opencode-ﾃﾚｸﾞﾗﾑ): ｵｰﾄ-ｲﾝｽﾄｰﾙ ﾊﾟｯｹｰｼﾞ when ﾓｼﾞｭｰﾙ enabled |
| `bd9e1b9` | feat(llama-cpp-rocm): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ ｻｰﾋﾞｽ sandbox overrides |

---

## 2026-05-27T00:00:00+09:00

**ｻﾏﾘｰ**：技能系统 — nixkits-check-updates、nixkits-ｽｷﾙｽﾞ、ﾆｯｸｽOS-modern-cli 三大技能同步上线；llama-cpp-rocm 动态追踪说明

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `327291a` | feat(ｽｷﾙｽﾞ): ｱﾄﾞ ﾆｯｸｽOS-modern-cli ｽｷﾙ ｳｨｽﾞ 3-language ﾄﾞｷｭｽﾞ |
| `f0e74d3` | feat(ｽｷﾙｽﾞ): ｱﾄﾞ nixkits-ｽｷﾙｽﾞ installer ｳｨｽﾞ 3-language ﾄﾞｷｭｽﾞ |
| `fc7fa3d` | ﾄﾞｷｭｽﾞ(llama-cpp-rocm): clarify ﾀﾞｲﾅﾐｯｸ release tracking purpose |
| `627c9c5` | feat(ｽｷﾙｽﾞ): ｱﾄﾞ nixkits-check-updates ｽｷﾙ ｳｨｽﾞ 3-language ﾄﾞｷｭｽﾞ |

---

## 2026-05-26T00:00:00+09:00

**ｻﾏﾘｰ**：文档 — README 节名重命名（快速开始→添加、包→软件、ﾗｲｾﾝｽ→许可）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `d869279` | ﾄﾞｷｭｽﾞ(ｾﾞｯﾄｴｲﾁ): rename ｾｸｼｮﾝｽﾞ 快速开始→添加 包→软件 ﾗｲｾﾝｽ→许可 |

---

## 2026-05-24T00:00:00+09:00

**ｻﾏﾘｰ**：ｴﾑｼｰﾋﾟｰ-searxng 文档 — SearXNG + lighttpd 反向代理完整 NixOS 配置

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `f3a6978` | ﾄﾞｷｭｽﾞ(ｴﾑｼｰﾋﾟｰ-searxng): ｱﾄﾞ full SearXNG + lighttpd reverse proxy ｺﾝﾌｨｸﾞ |

---

## 2026-05-22T00:00:00+09:00

**ｻﾏﾘｰ**：llama-cpp-rocm — 移除 llama-cpp-ver flake 输入，使用 nixpkgs 默认版本

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): ﾘﾑｰﾌﾞ llama-cpp-ver, use nixpkgs ﾊﾞｰｼﾞｮﾝ directly |

---

## 2026-05-16T00:00:00+09:00

**ｻﾏﾘｰ**：kitsfmt — 修复 match_ast! 宏语法错误、简化 comments_before 函数、修正 src 路径

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.ﾆｯｸｽ 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

---

## 2026-05-15T00:00:00+09:00

**ｻﾏﾘｰ**：kitsfmt — 基于 rnix AST 重写格式化引擎 v0.3.0；生成 Cargo.lock

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.ﾆｯｸｽ 使用 rnix AST 构建 |


## 2026-06-17T07:37:39+09:00

**ｻﾏﾘｰ**：ｽｷﾙ — 5 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `b77170a` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): re-apply flake.lock sync ｱﾝﾄﾞ ﾋﾞﾙﾄﾞ verification steps |
| `be2239b` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ .gitignore pre-check ﾄｩ flake.lock sync step |
| `704ebe4` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(ｽｷﾙ): extract ﾗｲﾄ-maintenance-log ｱｽﾞ standalone ｽｷﾙ |
| `5187b07` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): optimize ﾗｲﾄ-maintenance-log ﾄﾘｶﾞｰｽﾞ ｱﾝﾄﾞ ｱﾄﾞ audit entry |

---

## 2026-06-17T06:46:13+09:00

**ｻﾏﾘｰ**：llama-cpp-rocm — 2 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input ｳｨｽﾞ builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

---

## 2026-06-16T06:03:24+09:00

**ｻﾏﾘｰ**：ﾄﾞｷｭｽﾞ(ｴﾑｼｰﾋﾟｰ-searxng): ｱﾄﾞ CodeWhale ｺﾝﾌｨｸﾞ, common pitfall, ｱﾝﾄﾞ troubleshooting

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `d670e1e` | ﾄﾞｷｭｽﾞ(ｴﾑｼｰﾋﾟｰ-searxng): ｱﾄﾞ CodeWhale ｺﾝﾌｨｸﾞ, common pitfall, ｱﾝﾄﾞ troubleshooting |

---

## 2026-06-16T05:20:34+09:00

**ｻﾏﾘｰ**：ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ ﾆｯｸｽ Store ﾊﾟｽ trap ｾｸｼｮﾝ ﾄｩ ﾆｯｸｽOS-modern-cli

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `bd42478` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ ﾆｯｸｽ Store ﾊﾟｽ trap ｾｸｼｮﾝ ﾄｩ ﾆｯｸｽOS-modern-cli |

---

## 2026-06-14T08:11:16+09:00

**ｻﾏﾘｰ**：ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): ｱｯﾌﾟﾃﾞｰﾄ integration mode ｱﾝﾄﾞ file structure

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `c1fd014` | ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): ｱｯﾌﾟﾃﾞｰﾄ integration mode ｱﾝﾄﾞ file structure |

---

## 2026-06-12T18:17:52+09:00

**ｻﾏﾘｰ**：llama-cpp-rocm — 2 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate ﾌﾛﾑ ｻｰﾋﾞｽｽﾞ |
| `56ff235` | ﾄﾞｷｭｽﾞ(llama-cpp-rocm): ｱﾄﾞ trilingual migration ｶﾞｲﾄﾞ |

---

## 2026-06-11T05:28:34+09:00

**ｻﾏﾘｰ**：refactor(ｽｷﾙｽﾞ): generalize hardcoded content ﾄｩ ｵｰﾄ-ﾃﾞｨｽｶﾊﾞﾘｰ

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `3e9467f` | refactor(ｽｷﾙｽﾞ): generalize hardcoded content ﾄｩ ｵｰﾄ-ﾃﾞｨｽｶﾊﾞﾘｰ |

---

## 2026-06-11T05:13:39+09:00

**ｻﾏﾘｰ**：ｱｻﾞｰ — 2 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `4876547` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ missing rog-control-center-fix trilingual ﾓｼﾞｭｰﾙ ﾄﾞｷｭｽﾞ |
| `f891ad2` | ﾄﾞｷｭｽﾞ: fix DeepSeek V4 Pro casing ｲﾝ author credits |

---

## 2026-06-11T04:58:02+09:00

**ｻﾏﾘｰ**：ﾄﾞｷｭｽﾞ(ｽｷﾙ): enforce exact git ｺﾐｯﾄ timestamps, ban T00:00:00 placeholder

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `7680adf` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): enforce exact git ｺﾐｯﾄ timestamps, ban T00:00:00 placeholder |

---

## 2026-06-10T02:25:05+09:00

**ｻﾏﾘｰ**：fix(opencode-ﾃﾚｸﾞﾗﾑ): ｱﾄﾞ TimeoutStopSec ｱﾝﾄﾞ KillMode ﾄｩ prevent shutdown hang

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `fbcf15c` | fix(opencode-ﾃﾚｸﾞﾗﾑ): ｱﾄﾞ TimeoutStopSec ｱﾝﾄﾞ KillMode ﾄｩ prevent shutdown hang |

---

## 2026-06-08T14:58:59+09:00

**ｻﾏﾘｰ**：ｽｷﾙ — 2 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `4bf2d30` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ first-time ﾊﾟｯｹｰｼﾞ ﾃｰﾌﾞﾙ ﾌｫｰﾏｯﾄ rule |
| `f7bb6ce` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): merge ﾊﾞｰｼﾞｮﾝ columns ﾌｫｱ first-time ﾊﾟｯｹｰｼﾞｰｽﾞ |

---

## 2026-06-08T14:22:25+09:00

**ｻﾏﾘｰ**：feat(rcc-fix): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ systemd deadlock fix

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `141f4af` | feat(rcc-fix): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ systemd deadlock fix |

---

## 2026-06-06T15:16:53+09:00

**ｻﾏﾘｰ**：ｽｷﾙ — 5 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `8aa65da` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ trilingual symmetry checks ｱﾝﾄﾞ ｼﾞｪｲｴｲ 基本情報 rule ﾄｩ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs |
| `7e22edd` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ ｽｷﾙ ﾄﾞｷｭ ﾃﾝﾌﾟﾚｰﾄ, sync rules, ｱﾝﾄﾞ staleness check |
| `454a4e4` | fix(ｽｷﾙ): generalize 基本情報 rule ﾄｩ ｵｰﾙ ﾗﾝｹﾞｰｼﾞｽﾞ, ﾉｯﾄ ｼﾞｬｽﾄ ｼﾞｬﾊﾟﾆｰｽﾞ |
| `c79ffff` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ SRI hash ﾌｫｰﾏｯﾄ ｱﾝﾄﾞ ﾆｯｸｽ ﾋﾞﾙﾄﾞ gotchas ﾄｩ ｱｯﾌﾟﾃﾞｰﾄ ｽｷﾙ |
| `f5941ae` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ anti-patterns ﾌｫｱ stale/unsynced ﾄﾞｷｭ bullets after ｿｰｽ changes |

---

## 2026-06-06T15:15:31+09:00

**ｻﾏﾘｰ**：ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): ｱﾄﾞ c ﾋﾞﾙﾄﾞ toolchain + CC=ｼﾞｰｼｰｼｰ ﾄｩ changes ﾘｽﾄ

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `2ba85d3` | ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): ｱﾄﾞ c ﾋﾞﾙﾄﾞ toolchain + CC=ｼﾞｰｼｰｼｰ ﾄｩ changes ﾘｽﾄ |

---

## 2026-06-06T13:07:30+09:00

**ｻﾏﾘｰ**：feat(ｽｷﾙｽﾞ): localize ｵｰﾙ ｽｷﾙ.md ﾄｩ ﾁｬｲﾆｰｽﾞ, declare ｲﾝ READMEs

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `7dad578` | feat(ｽｷﾙｽﾞ): localize ｵｰﾙ ｽｷﾙ.md ﾄｩ ﾁｬｲﾆｰｽﾞ, declare ｲﾝ READMEs |

---

## 2026-06-05T03:42:25+09:00

**ｻﾏﾘｰ**：ﾄﾞｷｭｽﾞ(ﾆｯｸｽOS-modern-cli): ｱﾄﾞ POSIX ﾂｰﾙ ｶﾞｲﾄﾞ ｱﾝﾄﾞ ﾆｯｸｽ binary tip

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `4b103e5` | ﾄﾞｷｭｽﾞ(ﾆｯｸｽOS-modern-cli): ｱﾄﾞ POSIX ﾂｰﾙ ｶﾞｲﾄﾞ ｱﾝﾄﾞ ﾆｯｸｽ binary tip |

---

## 2026-06-05T03:42:18+09:00

**ｻﾏﾘｰ**：feat(ｽｷﾙｽﾞ): ｱﾄﾞ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs ｽｷﾙ ｳｨｽﾞ trilingual ﾄﾞｷｭｽﾞ

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `373da95` | feat(ｽｷﾙｽﾞ): ｱﾄﾞ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs ｽｷﾙ ｳｨｽﾞ trilingual ﾄﾞｷｭｽﾞ |

---

## 2026-06-05T03:42:14+09:00

**ｻﾏﾘｰ**：fix(codewhale): fix stdenv typo causing ﾋﾞﾙﾄﾞ failure

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `df4074f` | fix(codewhale): fix stdenv typo causing ﾋﾞﾙﾄﾞ failure |

---

## 2026-06-02T10:15:53+09:00

**ｻﾏﾘｰ**：ｱｻﾞｰ — 7 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `3be4889` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ recover-ﾆｯｸｽOS-config ｽｷﾙ ｳｨｽﾞ multi-ﾗﾝｹﾞｰｼﾞ ﾄﾞｷｭｽﾞ |
| `fc5eca3` | ﾄﾞｷｭｽﾞ: fix ｽｷﾙｽﾞ ｾｸｼｮﾝ ﾀｲﾄﾙｽﾞ ｱﾝﾄﾞ generic ｴｰｼﾞｪﾝﾄ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝｽﾞ |
| `d2e071f` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ quantization ﾚﾍﾞﾙｽﾞ ﾄｩ local ﾓﾃﾞﾙ names |
| `22d206c` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ UD- prefix ﾄｩ ﾓﾃﾞﾙ quantization labels |
| `f15db79` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ MIT ﾗｲｾﾝｽ file ｱﾝﾄﾞ ﾘﾝｸ ﾌﾛﾑ ｵｰﾙ READMEs |
| `218aeca` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ local flake input example alongside remote |
| `4f0f968` | ﾄﾞｷｭｽﾞ: fix local flake input syntax ﾄｩ match actual ﾕｰｾｰｼﾞ |

---

## 2026-06-02T08:49:47+09:00

**ｻﾏﾘｰ**：opencode-ﾃﾚｸﾞﾗﾑ — 8 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `8fe0b3d` | feat(opencode-ﾃﾚｸﾞﾗﾑ): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ｳｨｽﾞ declarative ｺﾝﾌｨｸﾞ |
| `8fe3fae` | ﾄﾞｷｭｽﾞ(opencode-ﾃﾚｸﾞﾗﾑ): simplify ﾄｩ flake ﾓｼﾞｭｰﾙ ｺﾝﾌｨｸﾞ ｵﾝﾘｰ, ﾘﾑｰﾌﾞ manual systemd |
| `ee0a904` | ﾄﾞｷｭｽﾞ(opencode-ﾃﾚｸﾞﾗﾑ): rename NixOS ﾓｼﾞｭｰﾙ → flake ﾓｼﾞｭｰﾙ |
| `a38e426` | ﾄﾞｷｭｽﾞ(opencode-ﾃﾚｸﾞﾗﾑ): use accurate ｾｸｼｮﾝ name — ｻｰﾋﾞｽ ｺﾝﾌｨｸﾞ, ﾉｯﾄ ﾓｼﾞｭｰﾙ |
| `dea4dc6` | ﾄﾞｷｭｽﾞ(opencode-ﾃﾚｸﾞﾗﾑ): show full flake.ﾆｯｸｽ context ｲﾝ ｻｰﾋﾞｽ ｺﾝﾌｨｸﾞ |
| `44975ed` | ﾄﾞｷｭｽﾞ(opencode-ﾃﾚｸﾞﾗﾑ): flake ﾓｼﾞｭｰﾙ ｱｽﾞ ｾｸｼｮﾝ ﾀｲﾄﾙ, consistent across langs |
| `941eb48` | feat(opencode-ﾃﾚｸﾞﾗﾑ): ｵｰﾄ-ｲﾝｽﾄｰﾙ ﾊﾟｯｹｰｼﾞ when ﾓｼﾞｭｰﾙ enabled |
| `2a8c41b` | ﾄﾞｷｭｽﾞ(opencode-ﾃﾚｸﾞﾗﾑ): ｱﾄﾞ first-time setup flow (opencode serve + ｺﾝﾌｨｸﾞ) |

---

## 2026-06-02T08:29:27+09:00

**ｻﾏﾘｰ**：feat(llama-cpp-rocm): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ ｻｰﾋﾞｽ sandbox overrides

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `bd9e1b9` | feat(llama-cpp-rocm): ｱﾄﾞ NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ ｻｰﾋﾞｽ sandbox overrides |

---

## 2026-06-02T07:34:30+09:00

**ｻﾏﾘｰ**：ｾﾞｯﾄｴｲﾁ — 2 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `d869279` | ﾄﾞｷｭｽﾞ(ｾﾞｯﾄｴｲﾁ): rename ｾｸｼｮﾝｽﾞ 快速开始→添加 包→软件 ﾗｲｾﾝｽ→许可 |
| `2db934e` | ﾄﾞｷｭｽﾞ(ｾﾞｯﾄｴｲﾁ): simplify ｽｷﾙｽﾞ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ, ﾘﾑｰﾌﾞ semantic duplication |

---

## 2026-06-02T06:44:17+09:00

**ｻﾏﾘｰ**：fix(rcc-fix): use visible: property instead ｵﾌﾞ if conditional ﾌｫｱ ScrollView

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `713b693` | fix(rcc-fix): use visible: property instead ｵﾌﾞ if conditional ﾌｫｱ ScrollView |

---

## 2026-06-02T06:08:13+09:00

**ｻﾏﾘｰ**：ｽｷﾙｽﾞ — 3 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `327291a` | feat(ｽｷﾙｽﾞ): ｱﾄﾞ ﾆｯｸｽOS-modern-cli ｽｷﾙ ｳｨｽﾞ 3-language ﾄﾞｷｭｽﾞ |
| `f0e74d3` | feat(ｽｷﾙｽﾞ): ｱﾄﾞ nixkits-ｽｷﾙｽﾞ installer ｳｨｽﾞ 3-language ﾄﾞｷｭｽﾞ |
| `627c9c5` | feat(ｽｷﾙｽﾞ): ｱﾄﾞ nixkits-check-updates ｽｷﾙ ｳｨｽﾞ 3-language ﾄﾞｷｭｽﾞ |

---

## 2026-05-30T06:45:11+09:00

**ｻﾏﾘｰ**：fix(llama-cpp-rocm): ﾘﾑｰﾌﾞ llama-cpp-ver, use nixpkgs ﾊﾞｰｼﾞｮﾝ directly

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): ﾘﾑｰﾌﾞ llama-cpp-ver, use nixpkgs ﾊﾞｰｼﾞｮﾝ directly |

---

## 2026-05-30T03:19:48+09:00

**ｻﾏﾘｰ**：ｱｻﾞｰ — 2 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `358316c` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ ｲﾝｸﾞﾘｯｼｭ ｱﾝﾄﾞ ｼﾞｬﾊﾟﾆｰｽﾞ ﾄﾗﾝｽﾚｰｼｮﾝｽﾞ ｳｨｽﾞ I18n structure |
| `bef3b4b` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ ｲﾝｸﾞﾘｯｼｭ ｱﾝﾄﾞ ｼﾞｬﾊﾟﾆｰｽﾞ README ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ switcher |

---

## 2026-05-30T03:01:02+09:00

**ｻﾏﾘｰ**：ﾄﾞｷｭｽﾞ(ｴﾑｼｰﾋﾟｰ-searxng): ｱﾄﾞ full SearXNG + lighttpd reverse proxy ｺﾝﾌｨｸﾞ

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `f3a6978` | ﾄﾞｷｭｽﾞ(ｴﾑｼｰﾋﾟｰ-searxng): ｱﾄﾞ full SearXNG + lighttpd reverse proxy ｺﾝﾌｨｸﾞ |

---

## 2026-05-29T15:25:12+09:00

**ｻﾏﾘｰ**：rcc-fix — 4 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `a612af7` | feat(rcc-fix): rewrite ﾊﾟｯﾁ ﾌｫｱ asusctl 6.3.7 ｳｨｽﾞ hot-plug ｱﾝﾄﾞ boundary checks |
| `e56f122` | fix(rcc-fix): scope hotplug variable correctly ﾌｫｱ asusctl ﾋﾞﾙﾄﾞ |
| `6ba43df` | fix(rcc-fix): set keyboard_connected=false when ﾉｰ aura iface found |
| `b7ebbfa` | fix(rcc-fix): replace polling ｳｨｽﾞ D-Bus InterfacesAdded ｲﾍﾞﾝﾄ |

---

## 2026-05-29T14:27:17+09:00

**ｻﾏﾘｰ**：kitsfmt — 3 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `2b237ff` | feat(kitsfmt): ｳｨｽﾞ→builtins.attrValues best-practice transformation |
| `8497bf7` | feat(kitsfmt): ｱﾄﾞ --stdin flag ﾌｫｱ explicit stdin mode |
| `15a0104` | fix(kitsfmt): restore vendor dir ﾌｫｱ offline ﾋﾞﾙﾄﾞｽﾞ |

---

## 2026-05-29T13:16:30+09:00

**ｻﾏﾘｰ**：ﾄﾞｷｭｽﾞ: fix codewhale ﾀｲﾌﾟ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ (pre-built, ﾉｯﾄ ｿｰｽ-built)

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `14e060c` | ﾄﾞｷｭｽﾞ: fix codewhale ﾀｲﾌﾟ ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ (pre-built, ﾉｯﾄ ｿｰｽ-built) |

---

## 2026-05-29T05:57:55+09:00

**ｻﾏﾘｰ**：fix(ﾋﾞﾙﾄﾞ): restrict .vscode gitignore ﾄｩ repo ﾙｰﾄ ﾄｩ ﾉｯﾄ exclude vendored crate files

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `1b7d0a9` | fix(ﾋﾞﾙﾄﾞ): restrict .vscode gitignore ﾄｩ repo ﾙｰﾄ ﾄｩ ﾉｯﾄ exclude vendored crate files |

---

## 2026-05-27T21:26:59+09:00

**ｻﾏﾘｰ**：fix(kitsfmt): idempotency, inplace safety, output validation

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `6a42efd` | fix(kitsfmt): idempotency, inplace safety, output validation |

---

## 2026-05-16T19:07:54+09:00

**ｻﾏﾘｰ**：kitsfmt — 6 项更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.ﾆｯｸｽ 使用 rnix AST 构建 |
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.ﾆｯｸｽ 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

---


## 2026-06-16T04:56:06+09:00

**ｻﾏﾘｰ**：opencode-ﾃﾚｸﾞﾗﾑ 0.21.2 — 上游修复及依赖更新

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `3b05a32` | ﾄﾞｷｭｽﾞ(MAINTENANCE): record 2026-06-16 ｱｯﾌﾟﾃﾞｰﾄ (opencode-ﾃﾚｸﾞﾗﾑ 0.21.2) |
| `17252ea` | chore(pkgs): bump opencode-ﾃﾚｸﾞﾗﾑ 0.21.2 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| opencode-ﾃﾚｸﾞﾗﾑ | 0.21.1 | 0.21.2 |
| 　 | source hash | `sha256-V/rThMV5...` → `sha256-NEaQ2grHCKXi13utcHeUR83pJT6kqBGS4UqllhG93kY=` |
| 　 | npmDepsHash | `sha256-Bcexury...` → `sha256-z9trDo9xeWZyTSvCqX5XTb+AHY50wk0gsoEnAAEHOEg=` |

---

## 2026-06-15T17:32:16+09:00

**ｻﾏﾘｰ**：codewhale 0.8.60 — 上游修复

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `3cef0a8` | ﾄﾞｷｭｽﾞ(MAINTENANCE): record 2026-06-15 ｱｯﾌﾟﾃﾞｰﾄ (codewhale 0.8.60) |
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `sha256-ti/IBPZV...` → `sha256-JqlByElHoLcR2Mlwmx5Qczfj+EoAp+igdLCd/QUOsX4=` |
| 　 | tui hash | `sha256-3Lh80hTS...` → `sha256-LTf681cWVH9Cu3TQrFeMlJUNVVG+TWxO2oI6VXK+4zA=` |

---

## 2026-06-14T07:56:11+09:00

**ｻﾏﾘｰ**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；ｴﾑｼｰﾋﾟｰ-searxng 1.4.0 — 新增 ｴｲﾁﾃｨｰﾃｨｰﾋﾟｰ 传输模式

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `ec7d5ca` | ﾄﾞｷｭｽﾞ(MAINTENANCE): record 2026-06-14 ｱｯﾌﾟﾃﾞｰﾄｽﾞ (codewhale 0.8.59, ｴﾑｼｰﾋﾟｰ-searxng 1.4.0) |
| `e8f0299` | chore(pkgs): bump ｴﾑｼｰﾋﾟｰ-searxng 1.4.0 |
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| ｴﾑｼｰﾋﾟｰ-searxng | 1.3.4 | 1.4.0 |
| 　 | cli hash | `sha256-AR9jJZzB...` → `sha256-ti/IBPZVJdaLvQ00OevzTfcMQ0XHELvOKTcul4+iBg8=` |
| 　 | tui hash | `sha256-BpCHu9M...` → `sha256-3Lh80hTSMG0RG+CHkR403rqcMtDA6kMdbyvBe7sLQaQ=` |
| 　 | source hash | `sha256-Xsp1vReg...` → `sha256-RMzxCBua89oYbKXmwXCtcSHan5QVefsm8IBdMIVq7UE=` |
| 　 | npmDepsHash | `sha256-3hWshG0...` → `sha256-Lh1UoM8zSMFji/TkqDAOiRtFRrQ/jqn5TbONySj9ckg=` |

---

## 2026-06-12T10:51:31+09:00

**ｻﾏﾘｰ**：codewhale 0.8.58 — 上游修复；ｴﾑｼｰﾋﾟｰ-searxng 1.3.4 — 上游修复

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `716d98c` | ﾄﾞｷｭｽﾞ(MAINTENANCE): record 2026-06-12 ｱｯﾌﾟﾃﾞｰﾄｽﾞ (codewhale 0.8.58, ｴﾑｼｰﾋﾟｰ-searxng 1.3.4) |
| `ef9daae` | chore(pkgs): bump ｴﾑｼｰﾋﾟｰ-searxng 1.3.4 |
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| ｴﾑｼｰﾋﾟｰ-searxng | 1.3.2 | 1.3.4 |
| 　 | cli hash | `sha256-Hp0Z6mwe...` → `sha256-AR9jJZzB1VNUe7yaI3jpSUJsXuzgvqk5aWeLWe/L/vA=` |
| 　 | tui hash | `sha256-dExfhrfG...` → `sha256-BpCHu9MbDGuCAXNNJXPTZpj3BrIwx7jWs29I31cbSag=` |
| 　 | source hash | `sha256-OVllsRM...` → `sha256-Xsp1vRegHDWNk54nqLk+4l5MI0xGgocCg5Qa2UwWNqA=` |
| 　 | npmDepsHash | `sha256-LN9yDbw...` → `sha256-3hWshG0L8k0U2fnmz0OotrYaPAYBQE7DanjXgnFnNrE=` |

---

## 2026-06-11T04:52:16+09:00

**ｻﾏﾘｰ**：codewhale 0.8.57 — TUI 新增；ｴﾑｼｰﾋﾟｰ-searxng 1.3.2 — 上游修复

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `07f347f` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ descriptive ﾀｲﾄﾙ rule ﾌｫｱ MAINTENANCE files |
| `f92f9c4` | ﾄﾞｷｭｽﾞ(MAINTENANCE): use descriptive ﾀｲﾄﾙｽﾞ instead ｵﾌﾞ filename |
| `7902bd1` | ﾄﾞｷｭｽﾞ(MAINTENANCE): fix timestamps ﾄｩ exact ｺﾐｯﾄ times |
| `543bcf9` | chore(pkgs): bump codewhale 0.8.57, ｴﾑｼｰﾋﾟｰ-searxng 1.3.2 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.55 | 0.8.57 |
| ｴﾑｼｰﾋﾟｰ-searxng | 1.3.1 | 1.3.2 |
| 　 | cli hash | `sha256-jwn3rKD...` → `sha256-Hp0Z6mweaC+sB/BH2KpD1W/sdS0me69pErKiWOa2GqY=` |
| 　 | tui hash | `sha256-1Cxofu9...` → `sha256-dExfhrfGs1wbWWmvXYTuCGXKnkhD+7rBY32aV938Dz0=` |

---

## 2026-06-10T02:28:10+09:00

**ｻﾏﾘｰ**：codewhale 0.8.55 — 上游修复；ｴﾑｼｰﾋﾟｰ-searxng 1.3.1 — 上游修复

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, ｴﾑｼｰﾋﾟｰ-searxng 1.3.1 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| ｴﾑｼｰﾋﾟｰ-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

---

## 2026-06-08T14:25:02+09:00

**ｻﾏﾘｰ**：ｴﾑｼｰﾋﾟｰ-searxng 1.2.1 — 上游修复

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `2f58ac5` | refactor: move localized README/MAINTENANCE files into ﾄﾞｷｭｽﾞ/ |
| `e5e505e` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync trilingual MAINTENANCE rule ﾄｩ ｽｷﾙ ﾄﾞｷｭｽﾞ |
| `b34ed08` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ trilingual MAINTENANCE (ｴﾇ/ｼﾞｪｲｴｲ) ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ switchers |
| `b4742ad` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync refined MAINTENANCE.md ﾌｫｰﾏｯﾄ rules ﾄｩ trilingual ﾄﾞｷｭｽﾞ |
| `1a28625` | ﾄﾞｷｭｽﾞ(MAINTENANCE): backfill full ﾊﾟｯｹｰｼﾞ history ﾌﾛﾑ repo creation |
| `2cd9daf` | ﾄﾞｷｭｽﾞ: drop ﾄﾞｷｭ-sync ﾗｲﾝ ﾌﾛﾑ MAINTENANCE; ｵﾝﾘｰ record substantive rewrites |
| `e4a3813` | ﾄﾞｷｭｽﾞ: omit ﾋﾞﾙﾄﾞ status ｱﾝﾄﾞ unchanged hashes ﾌﾛﾑ MAINTENANCE.md |
| `b3d7d0f` | ﾄﾞｷｭｽﾞ: switch MAINTENANCE.md ﾄｩ ﾃｰﾌﾞﾙ-ｵﾝﾘｰ ﾌｫｰﾏｯﾄ, drop trilingual prose |
| `b8a98bc` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): skip MAINTENANCE.md when ﾉｰ ｱｯﾌﾟﾃﾞｰﾄｽﾞ found |
| `5ba1361` | ﾄﾞｷｭｽﾞ(ｽｷﾙｽﾞ): sync MAINTENANCE.md step ﾄｩ trilingual ﾄﾞｷｭｽﾞ |
| `d4cb81f` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ Step 8 — MAINTENANCE.md ｱｯﾌﾟﾃﾞｰﾄ workflow |
| `db680df` | ﾄﾞｷｭｽﾞ: ｱﾄﾞ MAINTENANCE.md — ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄ ﾁｪﾝｼﾞﾛｸﾞ |
| `07b1ee5` | chore(pkgs): bump ｴﾑｼｰﾋﾟｰ-searxng 1.1.0 → 1.2.1 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| ｴﾑｼｰﾋﾟｰ-searxng | 1.1.0 | 1.2.1 |

---

## 2026-06-06T13:58:47+09:00

**ｻﾏﾘｰ**：codewhale 0.8.53 — 上游修复；ｴﾑｼｰﾋﾟｰ-searxng 1.1.0 — 上游修复；opencode-ﾃﾚｸﾞﾗﾑ 0.21.1 — 上游修复

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `300a9a6` | chore(pkgs): bump codewhale 0.8.53, ｴﾑｼｰﾋﾟｰ-searxng 1.1.0, opencode-ﾃﾚｸﾞﾗﾑ 0.21.1 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.49 | 0.8.53 |
| ｴﾑｼｰﾋﾟｰ-searxng | 1.0.4 | 1.1.0 |
| opencode-ﾃﾚｸﾞﾗﾑ | 0.21.0 | 0.21.1 |
| 　 | cli hash | `sha256-97zk4L...` → `sha256-VxBNH2o4iEkk0PrnuZHDPECjvm+ARXR9T/BV8QqvYtw=` |
| 　 | tui hash | `sha256-tc/s3e...` → `sha256-DBiWk4c4QFh/BKPlG5a3KkH0ZTxNQgqZ7IWwH4OaEEw=` |
| 　 | source hash | `sha256-ML5Hgle...` → `sha256-OVllsRMst6dWO/RagsmGyWN3muz1ATtffxfmLTfa0qU=` |
| 　 | npmDepsHash(searx) | `sha256-xnefgQ...` → `sha256-LN9yDbwvlICoFl5KgQvzZjLGXflVM0QkSzaB2dJzR/w=` |
| 　 | source hash(telegram) | `sha256-Al7CVol...` → `sha256-V/rThMV5qZ5Z07A+A54Il4Vi/69bv8PVgV6uIr6vxGA=` |
| 　 | npmDepsHash(telegram) | `sha256-ZOhS7l...` → `sha256-BcexuryL26CNLKeAOR9DffE07H4dYO1UYPqfX9aHm4g=` |

---

## 2026-06-06T12:51:46+09:00

**ｻﾏﾘｰ**：ｶﾑﾌｨUI-strix-halo 补丁 — ﾛｯｸｴﾑ 7.2 wheels 内嵌支持

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `58b06ea` | ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): clarify kernel param ｲｽﾞ set ﾊﾞｲ ﾓｼﾞｭｰﾙ, ﾉｯﾄ hardware |
| `468b89a` | feat(ｽｷﾙ): ｱﾄﾞ ﾊﾟｯﾁ-embedded ﾊﾞｰｼﾞｮﾝ check ﾌｫｱ ｶﾑﾌｨUI-strix-halo |
| `8f16f91` | ﾄﾞｷｭｽﾞ(ｽｷﾙ): ｱﾄﾞ length/structure rules ﾌﾛﾑ ｶﾑﾌｨUI-strix-halo ﾄﾞｷｭ fix |
| `ed25bb5` | ﾄﾞｷｭｽﾞ(ｶﾑﾌｨUI-strix-halo): rewrite trilingual ﾄﾞｷｭｽﾞ ｲﾝ NixKits concise style |
| `48d842f` | ﾄﾞｷｭｽﾞ(ｼﾞｪｲｴｲ): ｱﾄﾞ 基本情報 ｾｸｼｮﾝ ﾄｩ ｶﾑﾌｨUI-strix-halo |
| `e11f899` | fix(ﾄﾞｷｭｽﾞ): ｱﾄﾞ missing ｼﾞｪｲｴｲ ﾄﾞｷｭ ｱﾝﾄﾞ ｴﾇ/ｼﾞｪｲｴｲ README entries ﾌｫｱ ｶﾑﾌｨUI-strix-halo |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| ｶﾑﾌｨUI-strix-halo | 补丁（ﾛｯｸｴﾑ 7.2 wheels 内嵌） |

---

## 2026-06-02T05:57:11+09:00

**ｻﾏﾘｰ**：codewhale 0.8.49 — 上游修复；ｴﾑｼｰﾋﾟｰ-searxng 1.0.4 — 上游修复；ｵﾌﾞｴｽ-ﾋﾞﾘﾋﾞﾘ-stream 2.1.0 — 上游修复；opencode-ﾃﾚｸﾞﾗﾑ 0.21.0 — 上游修复

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | 0.8.47 | 0.8.49 |
| ｴﾑｼｰﾋﾟｰ-searxng | 1.0.3 | 1.0.4 |
| ｵﾌﾞｴｽ-ﾋﾞﾘﾋﾞﾘ-stream | 2.0.12 | 2.1.0 |
| opencode-ﾃﾚｸﾞﾗﾑ | 0.20.5 | 0.21.0 |
| 　 | cli hash | `sha256-JGNVKih...` → `sha256-97zk4LzahspVqd8U/Z8rfS60oOWNUPsWn4xtn/rL8CQ=` |
| 　 | tui hash | — → `sha256-tc/s3e1oomJhfYEN1EtuEtPBF77dByrMimDH3bQibCI=` |
| 　 | source hash(searx) | `sha256-xS2Hr/g...` → `sha256-ML5HgleThmzBwJFtmsCQEPxHvZz4gzrDxW3Udkx9YjA=` |
| 　 | npmDepsHash(searx) | `sha256-...+` → `sha256-xnefgQnFuHVPSCWVSD8MWxjHmNSrKpWlbGaAtks5rkg=` |
| 　 | source hash(obs) | — → `sha256-lbN73L3ey7qZftsgmRGb9wPcj8DmwlOUWR9gdEni29w=` |
| 　 | source hash(tele) | `sha256-RKsZwK...` → `sha256-Al7CVol/HDgH3M0FwkdQWOze6xY/wvaWOskRsh9Abxo=` |
| 　 | npmDepsHash(tele) | `sha256-...+` → `sha256-ZOhS7lX5z2bRi0Cilm2QBUVKmacK41oRcUn9kRcfdOg=` |

---

## 2026-05-29T10:18:46+09:00

**ｻﾏﾘｰ**：codewhale v0.8.47 — 新包

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `979b75c` | refactor(codewhale): switch ﾄｩ pre-built binaries, ﾘﾑｰﾌﾞ cargoHash |
| `d5b1878` | feat: ｱﾄﾞ codewhale (DeepSeek V4 TUI ｴｰｼﾞｪﾝﾄ) v0.8.47 |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| codewhale | v0.8.47 |

---

## 2026-05-21T16:35:02+09:00

**ｻﾏﾘｰ**：ｴﾑｼｰﾋﾟｰ-searxng v1.0.3 — 新包；opencode-ﾃﾚｸﾞﾗﾑ v0.20.5 — 新包

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| ｴﾑｼｰﾋﾟｰ-searxng | v1.0.3 |
| opencode-ﾃﾚｸﾞﾗﾑ | v0.20.5 |

---

## 2026-05-14T17:10:06+09:00

**ｻﾏﾘｰ**：llama-cpp-rocm — 新包（动态追踪上游最新 Release）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

---

## 2026-05-14T07:38:08+09:00

**ｻﾏﾘｰ**：kitsfmt — 新包（自建 ﾆｯｸｽ 格式化器）；ｵﾌﾞｴｽ-ﾋﾞﾘﾋﾞﾘ-stream v1.0.0 — 新包

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `2c917bd` | feat: ｱﾄﾞ kitsfmt ﾌｫｰﾏｯﾀｰ ｱﾝﾄﾞ modernize flake structure |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| ｵﾌﾞｴｽ-ﾋﾞﾘﾋﾞﾘ-stream | v1.0.0 |

---

## 2026-05-01T01:08:15+09:00

**ｻﾏﾘｰ**：rcc-fix — 新包（asusctl 补丁）

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `e2d09a2` | RCC-Fix |

| ﾊﾟｯｹｰｼﾞ | ｵｰﾙﾄﾞ | ﾆｭｰ |
|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（ｵｰﾊﾞｰﾚｲ + ﾊﾟｯﾁ） |

---

## 2026-06-17T06:48:47+09:00

**ｻﾏﾘｰ**：fix(ｴﾑｼｰﾋﾟｰ-searxng): 修复入口文件错误 — dist/index.js → dist/cli.js，ｴﾑｼｰﾋﾟｰ 服务器可正常启动

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `73a3b10` | fix(ｴﾑｼｰﾋﾟｰ-searxng): use dist/cli.js ｱｽﾞ entry point instead ｵﾌﾞ dist/index.js |

---

## 2026-06-12T05:00:00+09:00

**ｻﾏﾘｰ**：feat(llama-cpp-rocm): 恢复 modelsPreset 支持（nixpkgs 已移除），命名空间迁移至 nixkits

---

## 2026-06-10T04:31:20+09:00

**ｻﾏﾘｰ**：fix(opencode-ﾃﾚｸﾞﾗﾑ): 修改 KillMode 为 ﾌﾟﾛｾｽ，添加 TimeoutStopSec 防止关机挂起

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `6cda338` | fix(opencode-ﾃﾚｸﾞﾗﾑ): change KillMode ﾌﾛﾑ mixed ﾄｩ ﾌﾟﾛｾｽ |

---

## 2026-05-29T05:30:00+09:00

**ｻﾏﾘｰ**：fix(kitsfmt): 修复 inherit 逗号、缩进字符串损坏、lambda 空格等多个格式化问题；修复幂等性

| ｺﾐｯﾄ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|------|------|
| `45f3c26` | feat(kitsfmt): rec→let-ｲﾝ conversion ｱﾝﾄﾞ multi-file ｻﾎﾟｰﾄ |
| `3656154` | chore(kitsfmt): ｱｯﾌﾟﾃﾞｰﾄ Cargo.lock ﾌｫｱ v0.4.0 |
| `d1ab491` | feat(kitsfmt): best-practice ｵｰﾄ-corrections ｳｨｽﾞ env var ｻﾎﾟｰﾄ |
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |

---

## 2026-05-29T05:00:00+09:00

**ｻﾏﾘｰ**：fix(rcc-fix): 用 D-Bus InterfacesAdded 事件替代轮询，优化二合一键盘热插拔检测

---

## 2026-05-29T04:50:00+09:00

**ｻﾏﾘｰ**：fix(ﾋﾞﾙﾄﾞ): 修复 .vscode gitignore 范围过宽导致 vendored crate 文件被排除
