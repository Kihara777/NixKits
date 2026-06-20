# メンテナンスログ

[中文](../MAINTENANCE.md) | [English](MAINTENANCE.en.md) | 日本語 | [ｶﾀﾘｯｼｭ](MAINTENANCE.katalish.md) | [偽中国語](MAINTENANCE.pcn.md)

NixKits パッケージ更新履歴。

---


## 2026-06-21T04:32:31+09:00

**概要**：言語切替ラベル規則の汎化 — display_name の意味を言語自称に修正、言語名非ローカライズ規則を write-project-docs / translate-katalish / translate-pseudocn に追加；zh/katalish/pcn 全文書切替部の残留ローカライズ名を修正

| コミット | 説明 |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 言語名非ローカライズ規則を追加 |
| `7ba8c1d` | fix(katalish): 言語切替部の English を片仮名に変換しないよう修正 |
| `5ce9f7d` | fix: display_name の意味を言語自称に修正 — 切替ラベルと分離 |
| `aa8634b` | fix(docs): zh 文書切替部の残留旧名称修正 + MAINTENANCE 翻訳補完 + translate-* 汎化 |

## 2026-06-21T00:07:44+09:00

**概要**：codewhale 0.8.62 — 上流修正；mcp-searxng 1.7.1 — 上流修正

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

| コミット | 説明 |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

## 2026-06-18T09:52:34+09:00

**概要**：codewhale 0.8.61 — 上流修正；mcp-searxng 1.6.0 — 上流修正

| コミット | 説明 |
|------|------|
| `...` | chore(pkgs): bump codewhale 0.8.61 |
| `...` | chore(pkgs): bump mcp-searxng 1.6.0 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.60 | 0.8.61 |
| 　 | cli hash | `...` → `sha256-3k0K/I/NxYHrNszgniQncWTu8HRqsR3RSg+YLuB+IkY=` |
| 　 | tui hash | `...` → `sha256-YVjKDO/JNnsAHwzCf4itrEw8psKyi9bbFaLJLFvMyAI=` |
| mcp-searxng | 1.4.0 | 1.6.0 |
| 　 | source hash | `...` → `sha256-oBpSAAppLfnPhC3tHoE2X1YAGMyd42fka+xAVFuhjKw=` |
| 　 | npmDepsHash | `...` → `sha256-7z5T8po2ya698J7vqu4pA7c8s85k33sRbOV2tRmGdPo=` |

---

## 2026-06-18T09:03:48+09:00

**概要**：ruyi — NixOS 互換性パッチ（`patches/ruyi-nixos-compat.patch`），プリビルド RISC-V ツールチェーンの動的リンカパスを透過処理、GCC 子プロセス ELF interpreter 修正和 console_scripts argv0 問題

| コミット | 説明 |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

---

## 2026-06-17T10:59:35+09:00

**概要**：ruyi — NixOS モジュール（`services.ruyi`），宣言的生成 `/etc/xdg/ruyi/config.toml` と環境変数

| コミット | 説明 |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

---

## 2026-06-17T10:00:00+09:00

**概要**：ruyi — devShell サポート追加，`nix develop github:Kihara777/NixKits#ruyi` 即時利用可能

| コミット | 説明 |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

---

## 2026-06-17T09:48:33+09:00

**概要**：ruyi 0.51.0-alpha.20260616 — RuyiSDK パッケージマネージャ 新規パッケージ（Python / Poetry ビルド，ruff + mypy + 320 単体テスト + 52 統合テスト全通過）

| コミット | 説明 |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

---

## 2026-06-20T17:30:00+09:00

**概要**：スキルシステム再構成 — translate-katakana→translate-katalish リネーム，追加 translate-pseudocn（疑似中国語），write-project-docs と write-maintenance-log 言語拡張自動発見，文書五言語マッピング表

| コミット | 説明 |
|------|------|
| `fee1534` | docs(skill): add translate-* support and docs-as-code mapping to write-maintenance-log |
| `177ad9b` | refactor: rename translate-katakana→translate-katalish, add translate-pseudocn, auto-discovery |
| `39906b9` | docs: purge remaining pcn references from zh write-project-docs |
| `911052b` | refactor(docs): migrate pcn directory to katalish |
| `7caf343` | refactor(translate-katakana): rename kata-en → katalish, use ｶﾀﾘｯｼｭ as canonical name |
| `97b696c` | docs(skill): purge pcn references from write-project-docs, add kata-en |
| `f1904a1` | feat(skill): add translate-katakana — katakana english mechanical substitution |
| `c5fb218` | docs: write-project-docs 英日文版同步更新四语(pcn)支持 |
| `0588ee0` | skill: write-project-docs 新增伪中国语(pcn)语言支持 |

---

## 2026-06-17T07:00:00+09:00

**概要**：write-maintenance-log 技能 — nixkits-check-updates から独立スキルとして分離，デュアルエントリ設計（メンテナンス記録を記入 + メンテナンス記録を更新）；flake.lock 同期と .gitignore 事前検出および三分岐ロジック

| コミット | 説明 |
|------|------|
| `b77170a` | docs(skill): re-apply flake.lock sync and build verification steps |
| `be2239b` | docs(skill): add .gitignore pre-check to flake.lock sync step |
| `704ebe4` | docs(skill): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(skill): extract write-maintenance-log as standalone skill |
| `5187b07` | docs(skill): optimize write-maintenance-log triggers and add audit entry |

---

## 2026-06-17T06:50:00+09:00

**概要**：llama-cpp-rocm — 尝试用 builtins.fetchurl 替代 flake input 动态获取版本（已撤销，方案不可用）

| コミット | 説明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

---

## 2026-06-16T08:00:00+09:00

**概要**：mcp-searxng 文档 — CodeWhale MCP 配置指南、常见陷阱警告（env 默认为 {}）、故障排查章节

| コミット | 説明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

---

## 2026-06-16T07:50:00+09:00

**概要**：nixos-modern-cli 技能 — Nix Store パス落とし穴章（gh auth setup-git ハードコードパス障害の診断と汎用修正パターン）

| コミット | 説明 |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

---

## 2026-06-14T07:50:00+09:00

**概要**：comfyui-strix-halo 文档 — 在线集成模式说明与文件结构图

| コミット | 説明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

---

## 2026-06-12T05:50:00+09:00

**概要**：llama-cpp-rocm 模块 — 恢复 modelsPreset 支持（nixpkgs 已移除）、命名空间迁移至 nixkits、三语迁移指南

| コミット | 説明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

---

## 2026-06-11T05:28:00+09:00

**概要**：スキル文書 — メンテナンスログ形式規則シリーズ（自動発見汎化、記述的タイトル、正確な git commit タイムスタンプ、T00:00:00 プレースホルダ禁止）

| コミット | 説明 |
|------|------|
| `7902bd1` | docs(MAINTENANCE): fix timestamps to exact commit times |
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `f92f9c4` | docs(MAINTENANCE): use descriptive titles instead of filename |
| `07f347f` | docs(skill): add descriptive title rule for MAINTENANCE files |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

---

## 2026-06-10T04:31:00+09:00

**概要**：opencode-telegram — KillMode を process に変更、TimeoutStopSec 追加でシャットダウンハング防止

| コミット | 説明 |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

---

## 2026-06-08T15:00:00+09:00

**概要**：文書再構成 — ローカライズファイルを docs/ ディレクトリに移動；MAINTENANCE.md 初回合列ルール追加、純テーブル形式、全コミット履歴を埋め戻し

| コミット | 説明 |
|------|------|
| `b3d7d0f` | docs: switch MAINTENANCE.md to table-only format, drop trilingual prose |
| `e4a3813` | docs: omit build status and unchanged hashes from MAINTENANCE.md |
| `4bf2d30` | docs(skill): add first-time package table format rule |
| `f7bb6ce` | docs(skill): merge version columns for first-time packages |
| `1a28625` | docs(MAINTENANCE): backfill full package history from repo creation |
| `b4742ad` | docs(skills): sync refined MAINTENANCE.md format rules to trilingual docs |
| `2f58ac5` | refactor: move localized README/MAINTENANCE files into docs/ |
| `551e6fd` | docs(skills): sync localized-file-in-docs/ rule and path updates |

---

## 2026-06-08T14:55:00+09:00

**概要**：rcc-fix — NixOS モジュール（systemd デッドロック修正）

| コミット | 説明 |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

---

## 2026-06-06T06:00:00+09:00

**概要**：スキル文書 — ソース変更後の文書同期規範；comfyui-strix-halo C 工具链说明；hash 计算注意事项泛化；基本情報规则多语言统一

| コミット | 説明 |
|------|------|
| `7e22edd` | docs(skill): add skill doc template, sync rules, and staleness check |
| `86fc7c2` | docs(skills): sync write-project-docs trilingual docs with SKILL.md |
| `454a4e4` | fix(skill): generalize 基本情報 rule to all languages, not just Japanese |
| `28ec492` | docs(skills): sync generalized 基本情報 rule to trilingual docs |
| `c79ffff` | docs(skill): add SRI hash format and nix build gotchas to update skill |
| `6dcbbfc` | docs(skills): sync hash gotchas to nixkits-check-updates trilingual docs |
| `58b06ea` | docs(comfyui-strix-halo): clarify kernel param is set by module, not hardware |
| `2ba85d3` | docs(comfyui-strix-halo): add C build toolchain + CC=gcc to changes list |
| `f5941ae` | docs(skill): add anti-patterns for stale/unsynced doc bullets after source changes |
| `b8c2399` | docs(skills): sync source-change doc sync rule to trilingual docs |

---

## 2026-06-04T00:00:00+09:00

**概要**：スキルシステム — SKILL.md 全面中国語化；三言語対称性チェック規則

| コミット | 説明 |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

---

## 2026-06-02T00:00:00+09:00

**概要**：nixos-modern-cli 技能 — POSIX ツールガイドと nix バイナリパスヒント

| コミット | 説明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

---

## 2026-05-31T00:00:00+09:00

**概要**：write-project-docs — 新技能（NixKits スタイルで任意プロジェクトの多言語文書を生成）

| コミット | 説明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

---

## 2026-05-30T00:00:00+09:00

**概要**：codewhale — stdenv 拼写修复；llama-cpp-rocm 文档修正（移除内联链接、使用 system.nix 完整预设）；opencode-telegram 首次设置流程

| コミット | 説明 |
|------|------|
| `2a8c41b` | docs(opencode-telegram): add first-time setup flow (opencode serve + config) |
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

---

## 2026-05-29T05:00:00+09:00

**概要**：kitsfmt — 多项修复（vendor 目录恢复、幂等性、原地安全性、with→builtins.attrValues 转换、--stdin 标志）；rcc-fix — 重写为 D-Bus 热插拔检测；build — .vscode gitignore 范围修正

| コミット | 説明 |
|------|------|
| `6a42efd` | fix(kitsfmt): idempotency, inplace safety, output validation |
| `1b7d0a9` | fix(build): restrict .vscode gitignore to repo root to not exclude vendored crate files |
| `2b237ff` | feat(kitsfmt): with→builtins.attrValues best-practice transformation |
| `8497bf7` | feat(kitsfmt): add --stdin flag for explicit stdin mode |
| `a612af7` | feat(rcc-fix): rewrite patch for asusctl 6.3.7 with hot-plug and boundary checks |
| `e56f122` | fix(rcc-fix): scope hotplug variable correctly for asusctl build |
| `15a0104` | fix(kitsfmt): restore vendor dir for offline builds |
| `6ba43df` | fix(rcc-fix): set keyboard_connected=false when no aura iface found |
| `b7ebbfa` | fix(rcc-fix): replace polling with D-Bus InterfacesAdded event |

---

## 2026-05-28T00:00:00+09:00

**概要**：llama-cpp-rocm — NixOS モジュール（systemd 沙箱覆盖）；opencode-telegram — NixOS モジュール（声明式配置、自动安装）；rcc-fix — visible 属性修复；技能文档 — 动态发现措辞

| コミット | 説明 |
|------|------|
| `3d2c38c` | docs(skill): nixkits-check-updates — dynamic discovery, not hardcoded list |
| `e5ee4ab` | docs(skill): remove hardcoded count from features, add exclusion note |
| `814731e` | docs(skill): sync ja doc with zh/en — dynamic discovery wording |
| `713b693` | fix(rcc-fix): use visible: property instead of if conditional for ScrollView |
| `34d309b` | docs(skills): add Install section with full 5-agent support to all skills |
| `2db934e` | docs(zh): simplify Skills description, remove semantic duplication |
| `8fe0b3d` | feat(opencode-telegram): add NixOS module with declarative config |
| `941eb48` | feat(opencode-telegram): auto-install package when module enabled |
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

---

## 2026-05-27T00:00:00+09:00

**概要**：スキルシステム — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三スキル同時公開；llama-cpp-rocm 動的追跡説明

| コミット | 説明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

---

## 2026-05-26T00:00:00+09:00

**概要**：文書 — README 节名リネーム（快速开始→添加、包→软件、License→许可）

| コミット | 説明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

---

## 2026-05-24T00:00:00+09:00

**概要**：mcp-searxng 文档 — SearXNG + lighttpd リバースプロキシ完全 NixOS 設定

| コミット | 説明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

---

## 2026-05-22T00:00:00+09:00

**概要**：llama-cpp-rocm — 移除 llama-cpp-ver flake 输入，使用 nixpkgs 默认版本

| コミット | 説明 |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

---

## 2026-05-16T00:00:00+09:00

**概要**：kitsfmt — 修复 match_ast! 宏语法错误、简化 comments_before 函数、修正 src 路径

| コミット | 説明 |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

---

## 2026-05-15T00:00:00+09:00

**概要**：kitsfmt — 基于 rnix AST 重写格式化引擎 v0.3.0；生成 Cargo.lock

| コミット | 説明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST ビルド |


## 2026-06-17T07:37:39+09:00

**概要**：skill — 5 件更新

| コミット | 説明 |
|------|------|
| `b77170a` | docs(skill): re-apply flake.lock sync and build verification steps |
| `be2239b` | docs(skill): add .gitignore pre-check to flake.lock sync step |
| `704ebe4` | docs(skill): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(skill): extract write-maintenance-log as standalone skill |
| `5187b07` | docs(skill): optimize write-maintenance-log triggers and add audit entry |

---

## 2026-06-17T06:46:13+09:00

**概要**：llama-cpp-rocm — 2 件更新

| コミット | 説明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

---

## 2026-06-16T06:03:24+09:00

**概要**：docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting

| コミット | 説明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

---

## 2026-06-16T05:20:34+09:00

**概要**：docs(skill): add Nix Store path trap section to nixos-modern-cli

| コミット | 説明 |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

---

## 2026-06-14T08:11:16+09:00

**概要**：docs(comfyui-strix-halo): update integration mode and file structure

| コミット | 説明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

---

## 2026-06-12T18:17:52+09:00

**概要**：llama-cpp-rocm — 2 件更新

| コミット | 説明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

---

## 2026-06-11T05:28:34+09:00

**概要**：refactor(skills): generalize hardcoded content to auto-discovery

| コミット | 説明 |
|------|------|
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |

---

## 2026-06-11T05:13:39+09:00

**概要**：other — 2 件更新

| コミット | 説明 |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

---

## 2026-06-11T04:58:02+09:00

**概要**：docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder

| コミット | 説明 |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |

---

## 2026-06-10T02:25:05+09:00

**概要**：fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang

| コミット | 説明 |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |

---

## 2026-06-08T14:58:59+09:00

**概要**：skill — 2 件更新

| コミット | 説明 |
|------|------|
| `4bf2d30` | docs(skill): add first-time package table format rule |
| `f7bb6ce` | docs(skill): merge version columns for first-time packages |

---

## 2026-06-08T14:22:25+09:00

**概要**：feat(rcc-fix): add NixOS module for systemd deadlock fix

| コミット | 説明 |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

---

## 2026-06-06T15:16:53+09:00

**概要**：skill — 5 件更新

| コミット | 説明 |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7e22edd` | docs(skill): add skill doc template, sync rules, and staleness check |
| `454a4e4` | fix(skill): generalize 基本情報 rule to all languages, not just Japanese |
| `c79ffff` | docs(skill): add SRI hash format and nix build gotchas to update skill |
| `f5941ae` | docs(skill): add anti-patterns for stale/unsynced doc bullets after source changes |

---

## 2026-06-06T15:15:31+09:00

**概要**：docs(comfyui-strix-halo): add C build toolchain + CC=gcc to changes list

| コミット | 説明 |
|------|------|
| `2ba85d3` | docs(comfyui-strix-halo): add C build toolchain + CC=gcc to changes list |

---

## 2026-06-06T13:07:30+09:00

**概要**：feat(skills): localize all SKILL.md to Chinese, declare in READMEs

| コミット | 説明 |
|------|------|
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

---

## 2026-06-05T03:42:25+09:00

**概要**：docs(nixos-modern-cli): add POSIX tool guide and nix binary tip

| コミット | 説明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

---

## 2026-06-05T03:42:18+09:00

**概要**：feat(skills): add write-project-docs skill with trilingual docs

| コミット | 説明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

---

## 2026-06-05T03:42:14+09:00

**概要**：fix(codewhale): fix stdenv typo causing build failure

| コミット | 説明 |
|------|------|
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

---

## 2026-06-02T10:15:53+09:00

**概要**：other — 7 件更新

| コミット | 説明 |
|------|------|
| `3be4889` | docs: add recover-nixos-config skill with multi-language docs |
| `fc5eca3` | docs: fix Skills section titles and generic agent descriptions |
| `d2e071f` | docs: add quantization levels to local model names |
| `22d206c` | docs: add UD- prefix to model quantization labels |
| `f15db79` | docs: add MIT license file and link from all READMEs |
| `218aeca` | docs: add local flake input example alongside remote |
| `4f0f968` | docs: fix local flake input syntax to match actual usage |

---

## 2026-06-02T08:49:47+09:00

**概要**：opencode-telegram — 8 件更新

| コミット | 説明 |
|------|------|
| `8fe0b3d` | feat(opencode-telegram): add NixOS module with declarative config |
| `8fe3fae` | docs(opencode-telegram): simplify to flake module config only, remove manual systemd |
| `ee0a904` | docs(opencode-telegram): rename NixOS module → flake module |
| `a38e426` | docs(opencode-telegram): use accurate section name — service config, not module |
| `dea4dc6` | docs(opencode-telegram): show full flake.nix context in service config |
| `44975ed` | docs(opencode-telegram): flake module as section title, consistent across langs |
| `941eb48` | feat(opencode-telegram): auto-install package when module enabled |
| `2a8c41b` | docs(opencode-telegram): add first-time setup flow (opencode serve + config) |

---

## 2026-06-02T08:29:27+09:00

**概要**：feat(llama-cpp-rocm): add NixOS module for service sandbox overrides

| コミット | 説明 |
|------|------|
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

---

## 2026-06-02T07:34:30+09:00

**概要**：zh — 2 件更新

| コミット | 説明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |
| `2db934e` | docs(zh): simplify Skills description, remove semantic duplication |

---

## 2026-06-02T06:44:17+09:00

**概要**：fix(rcc-fix): use visible: property instead of if conditional for ScrollView

| コミット | 説明 |
|------|------|
| `713b693` | fix(rcc-fix): use visible: property instead of if conditional for ScrollView |

---

## 2026-06-02T06:08:13+09:00

**概要**：skills — 3 件更新

| コミット | 説明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

---

## 2026-05-30T06:45:11+09:00

**概要**：fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly

| コミット | 説明 |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

---

## 2026-05-30T03:19:48+09:00

**概要**：other — 2 件更新

| コミット | 説明 |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

---

## 2026-05-30T03:01:02+09:00

**概要**：docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config

| コミット | 説明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

---

## 2026-05-29T15:25:12+09:00

**概要**：rcc-fix — 4 件更新

| コミット | 説明 |
|------|------|
| `a612af7` | feat(rcc-fix): rewrite patch for asusctl 6.3.7 with hot-plug and boundary checks |
| `e56f122` | fix(rcc-fix): scope hotplug variable correctly for asusctl build |
| `6ba43df` | fix(rcc-fix): set keyboard_connected=false when no aura iface found |
| `b7ebbfa` | fix(rcc-fix): replace polling with D-Bus InterfacesAdded event |

---

## 2026-05-29T14:27:17+09:00

**概要**：kitsfmt — 3 件更新

| コミット | 説明 |
|------|------|
| `2b237ff` | feat(kitsfmt): with→builtins.attrValues best-practice transformation |
| `8497bf7` | feat(kitsfmt): add --stdin flag for explicit stdin mode |
| `15a0104` | fix(kitsfmt): restore vendor dir for offline builds |

---

## 2026-05-29T13:16:30+09:00

**概要**：docs: fix codewhale type description (pre-built, not source-built)

| コミット | 説明 |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

---

## 2026-05-29T05:57:55+09:00

**概要**：fix(build): restrict .vscode gitignore to repo root to not exclude vendored crate files

| コミット | 説明 |
|------|------|
| `1b7d0a9` | fix(build): restrict .vscode gitignore to repo root to not exclude vendored crate files |

---

## 2026-05-27T21:26:59+09:00

**概要**：fix(kitsfmt): idempotency, inplace safety, output validation

| コミット | 説明 |
|------|------|
| `6a42efd` | fix(kitsfmt): idempotency, inplace safety, output validation |

---

## 2026-05-16T19:07:54+09:00

**概要**：kitsfmt — 6 项更新

| コミット | 説明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST ビルド |
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

---


## 2026-06-16T04:56:06+09:00

**概要**：opencode-telegram 0.21.2 — 上流修正及依赖更新

| コミット | 説明 |
|------|------|
| `3b05a32` | docs(MAINTENANCE): record 2026-06-16 update (opencode-telegram 0.21.2) |
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | source hash | `sha256-V/rThMV5...` → `sha256-NEaQ2grHCKXi13utcHeUR83pJT6kqBGS4UqllhG93kY=` |
| 　 | npmDepsHash | `sha256-Bcexury...` → `sha256-z9trDo9xeWZyTSvCqX5XTb+AHY50wk0gsoEnAAEHOEg=` |

---

## 2026-06-15T17:32:16+09:00

**概要**：codewhale 0.8.60 — 上流修正

| コミット | 説明 |
|------|------|
| `3cef0a8` | docs(MAINTENANCE): record 2026-06-15 update (codewhale 0.8.60) |
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `sha256-ti/IBPZV...` → `sha256-JqlByElHoLcR2Mlwmx5Qczfj+EoAp+igdLCd/QUOsX4=` |
| 　 | tui hash | `sha256-3Lh80hTS...` → `sha256-LTf681cWVH9Cu3TQrFeMlJUNVVG+TWxO2oI6VXK+4zA=` |

---

## 2026-06-14T07:56:11+09:00

**概要**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；mcp-searxng 1.4.0 — 追加 HTTP 传输模式

| コミット | 説明 |
|------|------|
| `ec7d5ca` | docs(MAINTENANCE): record 2026-06-14 updates (codewhale 0.8.59, mcp-searxng 1.4.0) |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
| 　 | cli hash | `sha256-AR9jJZzB...` → `sha256-ti/IBPZVJdaLvQ00OevzTfcMQ0XHELvOKTcul4+iBg8=` |
| 　 | tui hash | `sha256-BpCHu9M...` → `sha256-3Lh80hTSMG0RG+CHkR403rqcMtDA6kMdbyvBe7sLQaQ=` |
| 　 | source hash | `sha256-Xsp1vReg...` → `sha256-RMzxCBua89oYbKXmwXCtcSHan5QVefsm8IBdMIVq7UE=` |
| 　 | npmDepsHash | `sha256-3hWshG0...` → `sha256-Lh1UoM8zSMFji/TkqDAOiRtFRrQ/jqn5TbONySj9ckg=` |

---

## 2026-06-12T10:51:31+09:00

**概要**：codewhale 0.8.58 — 上流修正；mcp-searxng 1.3.4 — 上流修正

| コミット | 説明 |
|------|------|
| `716d98c` | docs(MAINTENANCE): record 2026-06-12 updates (codewhale 0.8.58, mcp-searxng 1.3.4) |
| `ef9daae` | chore(pkgs): bump mcp-searxng 1.3.4 |
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| mcp-searxng | 1.3.2 | 1.3.4 |
| 　 | cli hash | `sha256-Hp0Z6mwe...` → `sha256-AR9jJZzB1VNUe7yaI3jpSUJsXuzgvqk5aWeLWe/L/vA=` |
| 　 | tui hash | `sha256-dExfhrfG...` → `sha256-BpCHu9MbDGuCAXNNJXPTZpj3BrIwx7jWs29I31cbSag=` |
| 　 | source hash | `sha256-OVllsRM...` → `sha256-Xsp1vRegHDWNk54nqLk+4l5MI0xGgocCg5Qa2UwWNqA=` |
| 　 | npmDepsHash | `sha256-LN9yDbw...` → `sha256-3hWshG0L8k0U2fnmz0OotrYaPAYBQE7DanjXgnFnNrE=` |

---

## 2026-06-11T04:52:16+09:00

**概要**：codewhale 0.8.57 — TUI 新增；mcp-searxng 1.3.2 — 上流修正

| コミット | 説明 |
|------|------|
| `07f347f` | docs(skill): add descriptive title rule for MAINTENANCE files |
| `f92f9c4` | docs(MAINTENANCE): use descriptive titles instead of filename |
| `7902bd1` | docs(MAINTENANCE): fix timestamps to exact commit times |
| `543bcf9` | chore(pkgs): bump codewhale 0.8.57, mcp-searxng 1.3.2 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.55 | 0.8.57 |
| mcp-searxng | 1.3.1 | 1.3.2 |
| 　 | cli hash | `sha256-jwn3rKD...` → `sha256-Hp0Z6mweaC+sB/BH2KpD1W/sdS0me69pErKiWOa2GqY=` |
| 　 | tui hash | `sha256-1Cxofu9...` → `sha256-dExfhrfGs1wbWWmvXYTuCGXKnkhD+7rBY32aV938Dz0=` |

---

## 2026-06-10T02:28:10+09:00

**概要**：codewhale 0.8.55 — 上流修正；mcp-searxng 1.3.1 — 上流修正

| コミット | 説明 |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

---

## 2026-06-08T14:25:02+09:00

**概要**：mcp-searxng 1.2.1 — 上流修正

| コミット | 説明 |
|------|------|
| `2f58ac5` | refactor: move localized README/MAINTENANCE files into docs/ |
| `e5e505e` | docs(skills): sync trilingual MAINTENANCE rule to skill docs |
| `b34ed08` | docs: add trilingual MAINTENANCE (en/ja) with language switchers |
| `b4742ad` | docs(skills): sync refined MAINTENANCE.md format rules to trilingual docs |
| `1a28625` | docs(MAINTENANCE): backfill full package history from repo creation |
| `2cd9daf` | docs: drop doc-sync line from MAINTENANCE; only record substantive rewrites |
| `e4a3813` | docs: omit build status and unchanged hashes from MAINTENANCE.md |
| `b3d7d0f` | docs: switch MAINTENANCE.md to table-only format, drop trilingual prose |
| `b8a98bc` | docs(skill): skip MAINTENANCE.md when no updates found |
| `5ba1361` | docs(skills): sync MAINTENANCE.md step to trilingual docs |
| `d4cb81f` | docs(skill): add Step 8 — MAINTENANCE.md update workflow |
| `db680df` | docs: add MAINTENANCE.md — software update changelog |
| `07b1ee5` | chore(pkgs): bump mcp-searxng 1.1.0 → 1.2.1 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| mcp-searxng | 1.1.0 | 1.2.1 |

---

## 2026-06-06T13:58:47+09:00

**概要**：codewhale 0.8.53 — 上流修正；mcp-searxng 1.1.0 — 上流修正；opencode-telegram 0.21.1 — 上流修正

| コミット | 説明 |
|------|------|
| `300a9a6` | chore(pkgs): bump codewhale 0.8.53, mcp-searxng 1.1.0, opencode-telegram 0.21.1 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.49 | 0.8.53 |
| mcp-searxng | 1.0.4 | 1.1.0 |
| opencode-telegram | 0.21.0 | 0.21.1 |
| 　 | cli hash | `sha256-97zk4L...` → `sha256-VxBNH2o4iEkk0PrnuZHDPECjvm+ARXR9T/BV8QqvYtw=` |
| 　 | tui hash | `sha256-tc/s3e...` → `sha256-DBiWk4c4QFh/BKPlG5a3KkH0ZTxNQgqZ7IWwH4OaEEw=` |
| 　 | source hash | `sha256-ML5Hgle...` → `sha256-OVllsRMst6dWO/RagsmGyWN3muz1ATtffxfmLTfa0qU=` |
| 　 | npmDepsHash(searx) | `sha256-xnefgQ...` → `sha256-LN9yDbwvlICoFl5KgQvzZjLGXflVM0QkSzaB2dJzR/w=` |
| 　 | source hash(telegram) | `sha256-Al7CVol...` → `sha256-V/rThMV5qZ5Z07A+A54Il4Vi/69bv8PVgV6uIr6vxGA=` |
| 　 | npmDepsHash(telegram) | `sha256-ZOhS7l...` → `sha256-BcexuryL26CNLKeAOR9DffE07H4dYO1UYPqfX9aHm4g=` |

---

## 2026-06-06T12:51:46+09:00

**概要**：comfyui-strix-halo 补丁 — ROCm 7.2 wheels 内嵌支持

| コミット | 説明 |
|------|------|
| `58b06ea` | docs(comfyui-strix-halo): clarify kernel param is set by module, not hardware |
| `468b89a` | feat(skill): add patch-embedded version check for comfyui-strix-halo |
| `8f16f91` | docs(skill): add length/structure rules from comfyui-strix-halo doc fix |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs in NixKits concise style |
| `48d842f` | docs(ja): add 基本情報 section to comfyui-strix-halo |
| `e11f899` | fix(docs): add missing ja doc and en/ja README entries for comfyui-strix-halo |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| comfyui-strix-halo | 补丁（ROCm 7.2 wheels 内嵌） |

---

## 2026-06-02T05:57:11+09:00

**概要**：codewhale 0.8.49 — 上流修正；mcp-searxng 1.0.4 — 上流修正；obs-bilibili-stream 2.1.0 — 上流修正；opencode-telegram 0.21.0 — 上流修正

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.47 | 0.8.49 |
| mcp-searxng | 1.0.3 | 1.0.4 |
| obs-bilibili-stream | 2.0.12 | 2.1.0 |
| opencode-telegram | 0.20.5 | 0.21.0 |
| 　 | cli hash | `sha256-JGNVKih...` → `sha256-97zk4LzahspVqd8U/Z8rfS60oOWNUPsWn4xtn/rL8CQ=` |
| 　 | tui hash | — → `sha256-tc/s3e1oomJhfYEN1EtuEtPBF77dByrMimDH3bQibCI=` |
| 　 | source hash(searx) | `sha256-xS2Hr/g...` → `sha256-ML5HgleThmzBwJFtmsCQEPxHvZz4gzrDxW3Udkx9YjA=` |
| 　 | npmDepsHash(searx) | `sha256-...+` → `sha256-xnefgQnFuHVPSCWVSD8MWxjHmNSrKpWlbGaAtks5rkg=` |
| 　 | source hash(obs) | — → `sha256-lbN73L3ey7qZftsgmRGb9wPcj8DmwlOUWR9gdEni29w=` |
| 　 | source hash(tele) | `sha256-RKsZwK...` → `sha256-Al7CVol/HDgH3M0FwkdQWOze6xY/wvaWOskRsh9Abxo=` |
| 　 | npmDepsHash(tele) | `sha256-...+` → `sha256-ZOhS7lX5z2bRi0Cilm2QBUVKmacK41oRcUn9kRcfdOg=` |

---

## 2026-05-29T10:18:46+09:00

**概要**：codewhale v0.8.47 — 新規パッケージ

| コミット | 説明 |
|------|------|
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | v0.8.47 |

---

## 2026-05-21T16:35:02+09:00

**概要**：mcp-searxng v1.0.3 — 新規パッケージ；opencode-telegram v0.20.5 — 新規パッケージ

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

---

## 2026-05-14T17:10:06+09:00

**概要**：llama-cpp-rocm — 新規パッケージ（动态追踪上游最新 Release）

| コミット | 説明 |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| llama-cpp-rocm | 动态（ビルド时获取上游最新 Release） |

---

## 2026-05-14T07:38:08+09:00

**概要**：kitsfmt — 新規パッケージ（自建 Nix 格式化器）；obs-bilibili-stream v1.0.0 — 新規パッケージ

| コミット | 説明 |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

---

## 2026-05-01T01:08:15+09:00

**概要**：rcc-fix — 新規パッケージ（asusctl 补丁）

| コミット | 説明 |
|------|------|
| `e2d09a2` | RCC-Fix |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（overlay + patch） |

---

## 2026-06-17T06:48:47+09:00

**概要**：fix(mcp-searxng): 修复入口文件错误 — dist/index.js → dist/cli.js，MCP 服务器可正常启动

| コミット | 説明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

---

## 2026-06-12T05:00:00+09:00

**概要**：feat(llama-cpp-rocm): 恢复 modelsPreset 支持（nixpkgs 已移除），命名空间迁移至 nixkits

---

## 2026-06-10T04:31:20+09:00

**概要**：fix(opencode-telegram): 修改 KillMode 为 process，TimeoutStopSec 追加でシャットダウンハング防止

| コミット | 説明 |
|------|------|
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

---

## 2026-05-29T05:30:00+09:00

**概要**：fix(kitsfmt): 修复 inherit 逗号、缩进字符串损坏、lambda 空格等多个格式化问题；修复幂等性

| コミット | 説明 |
|------|------|
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |

---

## 2026-05-29T05:00:00+09:00

**概要**：fix(rcc-fix): 用 D-Bus InterfacesAdded 事件替代轮询，优化二合一键盘热插拔检测

---

## 2026-05-29T04:50:00+09:00

**概要**：fix(build): 修复 .vscode gitignore 范围过宽导致 vendored crate 文件被排除

