# Maintenance Log

## 2026-06-25T10:04:30+09:00

**Summary**: CI — access-tokens 覆写 修正、GitHub API 速率限界超過解消（一行統合）；riscv64-cross 並列上限 4 設定

| Commit | Description |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |
## 2026-06-25T09:44:44+09:00

**Summary**: CI — riscv64-cross に ruyi/ruyi-beta/ruyi-alpha 復帰（路映射）；docs — 徽章標籤簡略化 + riscv64 job 精密過濾

| Commit | Description |
|------|------|
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
## 2026-06-25T09:29:43+09:00

**Summary**: CI — build / riscv64-cross を包別 matrix 分割、独立徽章対応；docs — ruyi 徽章を 9 枚（3版本×3架構）拡張

| Commit | Description |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |
## 2026-06-25T09:24:43+09:00

**Summary**: CI — build job に ruyi-beta / ruyi-alpha 構築段階追加；docs — ruyi 基本情報表格通道行に beta/alpha 版本番号追加

| Commit | Description |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |
## 2026-06-25T09:09:26+09:00

**Summary**: CI — ruyi を riscv64-cross 除外；overlays — default overlay に ruyi-beta/ruyi-alpha 追加＋nixConfig を flake 最上位層移行；docs — README 表に ruyi 3路版本表示

| Commit | Description |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |
## 2026-06-23T04:04:32+09:00

**Summary**：AGENTS.md — 硬符号除去、冗長監査備忘削除、緩衝章代理操作手引書換、利用者側記述削除、言語体系自動発見変更

| Commit | Description |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:22:00+09:00

**Summary**：AGENTS.md — 新規初回起動監査規則、接続制御頂部移動

| Commit | Description |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**Summary**：docs — README 重複行修復、write-project-docs 反模式補充

| Commit | Description |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**Summary**：AGENTS.md — 新規接続制御、言語要求、送信規範、保守記録確認、文書同期、汎化、多構造緩衝規則

| Commit | Description |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**Summary**：docs — 毎包文書双構造 CI 徽章追加、技能雛形同期

| Commit | Description |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**Summary**：CI — ARM runner 多構造構築追加、flake.lock 並行競合修正（--no-write-lock-file）

| Commit | Description |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**Summary**：mcp-searxng — source hash + npmDepsHash 更新（GitHub archive 変化）；ruyi — overlay postPatch 戻移（修正書類依存）

| Commit | Description |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**Summary**：docs — 緩衝除外警告追加（上乗及部品+修正条目）、README 緩衝説明圧縮、flake.nix nixConfig 自動宣言追加

| Commit | Description |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**Summary**：docs — 全 30 篇包文書 `## 緩衝` 節追加、CI badge 配置改善、技能同期

| Commit | Description |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**Summary**：CI/CD — GitHub Actions 構築行列（Cachix 推送）追加、二進緩衝、AGENTS.md

| Commit | Description |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**Summary**：skills — translate-katalish / translate-pseudocn / write-project-docs 辞書及雛形分割、SKILL.md 60-80 行圧縮

| Commit | Description |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**Summary**：docs — MAINTENANCE 時刻精確化（29 節）、30 重複節削除（SHA 去重）、nix-kits→nixkits 全量置換（183 箇所）、部品文書同期

| Commit | Description |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**Summary**：patches — ruyi-nixos-compat.patch 清浄複製基再構築（1223→426 行）、flake.lock 自参照 artifact 清除

| Commit | Description |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**Summary**：overlays — patches 一覧 lib.unique 去重、ruyi-nixos-compat 精簡、llama-cpp-rocm curried 形式注釈追加

| Commit | Description |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**Summary**：modules — 4 部品 enable 選項追加、comfyui-strix-halo assertions 追加、名前空間 nixkits.* 統一（含後方互換）、llama-cpp-rocm hfCacheDir 動的導出

| Commit | Description |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**Summary**：codewhale 0.8.63 — 多構造予編集二進（x86_64 / aarch64 / riscv64）；ruyi — overlay postPatch 包統合；meta 欄補完

| Commit | Description |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**Summary**：flake — mihomo-alpha 幽霊入力及上乗除去（書類未存在）

| Commit | Description |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |

## 2026-06-22T23:49:00+09:00

**Summary**：mcp-searxng 1.7.2 — 上流修復

| Commit | Description |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |

[中文](docs/MAINTENANCE.md) | [English](docs/MAINTENANCE.en.md) | [日本語](docs/MAINTENANCE.ja.md) | [ｶﾀﾘｯｼｭ](docs/MAINTENANCE.katalish.md) | 偽中国語

NixKits 包更新変更記録。

---

## 2026-06-21T04:32:31+09:00

**Summary**：言語切替器札規則汎化 — display_name 意味修正言語自称、言語名称不局所化規則 write-project-docs / translate-katalish / translate-pseudocn 三技能追加；修正 zh/katalish/pcn 全文書切替器中残留局所化名称

| Commit | Description |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称与切换器标签分离 |
| `aa8634b` | fix(docs): zh 文档切换器残留旧名称修正 + MAINTENANCE 翻译补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**Summary**：codewhale 0.8.62 — 上流修復；mcp-searxng 1.7.1 — 上流修復

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

| Commit | Description |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

## 2026-06-18T09:52:34+09:00

**Summary**：codewhale 0.8.61 — 上流修復；mcp-searxng 1.6.0 — 上流修復

| Commit | Description |
|------|------|
| `...` | chore(pkgs): bump codewhale 0.8.61 |
| `...` | chore(pkgs): bump mcp-searxng 1.6.0 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.60 | 0.8.61 |
| 　 | cli hash | `...` → `sha256-3k0K/I/NxYHrNszgniQncWTu8HRqsR3RSg+YLuB+IkY=` |
| 　 | tui hash | `...` → `sha256-YVjKDO/JNnsAHwzCf4itrEw8psKyi9bbFaLJLFvMyAI=` |
| mcp-searxng | 1.4.0 | 1.6.0 |
| 　 | source hash | `...` → `sha256-oBpSAAppLfnPhC3tHoE2X1YAGMyd42fka+xAVFuhjKw=` |
| 　 | npmDepsHash | `...` → `sha256-7z5T8po2ya698J7vqu4pA7c8s85k33sRbOV2tRmGdPo=` |

---

## 2026-06-18T09:03:48+09:00

**Summary**：ruyi — NixOS 互換性修正（`patches/ruyi-nixos-compat.patch`）、透過的処理予編集 RISC-V 道具連動的連結器路、GCC 子工程 ELF interpreter 修復及 console_scripts argv0 問題

| Commit | Description |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

---

## 2026-06-17T10:59:35+09:00

**Summary**：ruyi — NixOS 部品（`services.ruyi`）、宣言的生成 `/etc/xdg/ruyi/config.toml` 及環境変数

| Commit | Description |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

---

## 2026-06-17T10:03:05+09:00

**Summary**：ruyi — 新規 devShell 支援追加、`nix develop github:Kihara777/NixKits#ruyi` 環境入可能

| Commit | Description |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

---

## 2026-06-17T09:48:33+09:00

**Summary**：ruyi 0.51.0-alpha.20260616 — RuyiSDK 包管理者、新包（Python / Poetry 構築、ruff + mypy + 320 単体試験 + 52 統合試験全通過）

| Commit | Description |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 軟体名 | 新版 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

---

## 2026-06-20T18:36:33+09:00

**Summary**：技能体系再構築 — translate-katakana→translate-katalish 改名、新規 translate-pseudocn（偽中国語）追加、write-project-docs 及 write-maintenance-log 言語拡張自動発見、文書符号五語対応表

| Commit | Description |
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

## 2026-06-17T07:37:39+09:00

**Summary**：write-maintenance-log 技能 — nixkits-check-updates 自保守記録書式変更抽出独立技能化；MAINTENANCE.md 再生成（動的名称 + 精密時刻 + LIFO + hash 省略）

| Commit | Description |
|------|------|
| `e9e40f4` | docs(skill): add write-maintenance-log skill with trilingual docs |
| `edce70f` | refactor(docs): switch MAINTENANCE.md to ISO 8601 precise timestamps |
| `34bf34e` | feat(skill): add write-maintenance-log SKILL.md (zh) |
| `c9dedf9` | docs(skill): write-maintenance-log — add en/ja skill docs |
| `d5318fb` | docs(skill): write-maintenance-log — add 使用 section |
| `fb6f1a5` | docs(skill): write-maintenance-log — add auto-discovery contract |
| `fe4b13f` | fix(docs): remove non-patch sections from MAINTENANCE.md |

---

## 2026-06-17T06:59:00+09:00

**Summary**：nixkits-check-updates — 動的包発見、hash 注意点、確認範囲明確化；llama-cpp-rocm — 技能及文書削除動的追跡重複；flake — default 包別名除去

| Commit | Description |
|------|------|
| `b118858` | fix(skill): nixkits-check-updates — dynamic discovery, not hardcoded list |
| `12e51b8` | docs(skill): add hash pitfalls and check scope to nixkits-check-updates |

---

## 2026-06-12T10:29:00+09:00

**Summary**：codewhale 0.8.58 — 上流修復；mcp-searxng 1.3.4 — 上流修復

| Commit | Description |
|------|------|
| `716d98c` | docs(MAINTENANCE): record 2026-06-12 updates (codewhale 0.8.58, mcp-searxng 1.3.4) |
| `ef9daae` | chore(pkgs): bump mcp-searxng 1.3.4 |
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| mcp-searxng | 1.3.2 | 1.3.4 |
| 　 | cli hash | `sha256-Hp0Z6mwe...` → `sha256-AR9jJZzB1VNUe7yaI3jpSUJsXuzgvqk5aWeLWe/L/vA=` |
| 　 | tui hash | `sha256-dExfhrfG...` → `sha256-BpCHu9MbDGuCAXNNJXPTZpj3BrIwx7jWs29I31cbSag=` |
| 　 | source hash | `sha256-OVllsRM...` → `sha256-Xsp1vRegHDWNk54nqLk+4l5MI0xGgocCg5Qa2UwWNqA=` |
| 　 | npmDepsHash | `sha256-LN9yDbw...` → `sha256-3hWshG0L8k0U2fnmz0OotrYaPAYBQE7DanjXgnFnNrE=` |

---

## 2026-06-11T04:52:16+09:00

**Summary**：codewhale 0.8.57 — TUI 新規追加；mcp-searxng 1.3.2 — 上流修復

| Commit | Description |
|------|------|
| `07f347f` | docs(skill): add descriptive title rule for MAINTENANCE files |
| `f92f9c4` | docs(MAINTENANCE): use descriptive titles instead of filename |
| `7902bd1` | docs(MAINTENANCE): fix timestamps to exact commit times |
| `543bcf9` | chore(pkgs): bump codewhale 0.8.57, mcp-searxng 1.3.2 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.55 | 0.8.57 |
| mcp-searxng | 1.3.1 | 1.3.2 |
| 　 | cli hash | `sha256-jwn3rKD...` → `sha256-Hp0Z6mweaC+sB/BH2KpD1W/sdS0me69pErKiWOa2GqY=` |
| 　 | tui hash | `sha256-1Cxofu9...` → `sha256-dExfhrfGs1wbWWmvXYTuCGXKnkhD+7rBY32aV938Dz0=` |

---

## 2026-06-10T02:28:10+09:00

**Summary**：codewhale 0.8.55 — 上流修復；mcp-searxng 1.3.1 — 上流修復

| Commit | Description |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

---

## 2026-06-08T14:25:02+09:00

**Summary**：mcp-searxng 1.2.1 — 上流修復

| Commit | Description |
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

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | 1.1.0 | 1.2.1 |

---

## 2026-06-06T13:58:47+09:00

**Summary**：codewhale 0.8.53 — 上流修復；mcp-searxng 1.1.0 — 上流修復；opencode-telegram 0.21.1 — 上流修復

| Commit | Description |
|------|------|
| `300a9a6` | chore(pkgs): bump codewhale 0.8.53, mcp-searxng 1.1.0, opencode-telegram 0.21.1 |

| Package | Old | New |
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

**Summary**：comfyui-strix-halo 修正 — ROCm 7.2 wheels 内蔵支援

| Commit | Description |
|------|------|
| `58b06ea` | docs(comfyui-strix-halo): clarify kernel param is set by module, not hardware |
| `468b89a` | feat(skill): add patch-embedded version check for comfyui-strix-halo |
| `8f16f91` | docs(skill): add length/structure rules from comfyui-strix-halo doc fix |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs in NixKits concise style |
| `48d842f` | docs(ja): add 基本情報 section to comfyui-strix-halo |
| `e11f899` | fix(docs): add missing ja doc and en/ja README entries for comfyui-strix-halo |

| Package | Old | New |
|--------|--------|--------|
| comfyui-strix-halo | 修正（ROCm 7.2 wheels 内蔵） |

---

## 2026-06-02T05:57:11+09:00

**Summary**：codewhale 0.8.49 — 上流修復；mcp-searxng 1.0.4 — 上流修復；obs-bilibili-stream 2.1.0 — 上流修復；opencode-telegram 0.21.0 — 上流修復

| Package | Old | New |
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

**Summary**：codewhale v0.8.47 — 新包

| Commit | Description |
|------|------|
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |

| Package | Old | New |
|--------|--------|--------|
| codewhale | v0.8.47 |

---

## 2026-05-21T16:35:02+09:00

**Summary**：mcp-searxng v1.0.3 — 新包；opencode-telegram v0.20.5 — 新包

| Package | Old | New |
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

---

## 2026-05-14T17:10:06+09:00

**Summary**：llama-cpp-rocm — 新包（動的追跡上流最新 Release）

| Commit | Description |
|------|------|
| `9cb24a3` | llama-cpp MTP |

| Package | Old | New |
|--------|--------|--------|
| llama-cpp-rocm | 動的（構築時取得上流最新 Release） |

---

## 2026-05-14T07:38:08+09:00

**Summary**：kitsfmt — 新包（自建 Nix 整形器）；obs-bilibili-stream v1.0.0 — 新包

| Commit | Description |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

| Package | Old | New |
|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

---

## 2026-05-01T01:08:15+09:00

**Summary**：rcc-fix — 新包（asusctl 修正）

| Commit | Description |
|------|------|
| `e2d09a2` | RCC-Fix |

| Package | Old | New |
|--------|--------|--------|
| rcc-fix | 追従 nixpkgs（上乗 + 修正） |

---

## 2026-06-17T06:48:47+09:00

**Summary**：fix(mcp-searxng): 入口書類誤修正 — dist/index.js → dist/cli.js、MCP 伺服器正常起動可能

| Commit | Description |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

---

## 2026-06-12T17:29:59+09:00

**Summary**：feat(llama-cpp-rocm): modelsPreset 支援復元（nixpkgs 既削除）、名前空間 nixkits 移行

---

## 2026-05-29T06:28:50+09:00

**Summary**：fix(kitsfmt): inherit 逗号、字下文字列破損、lambda 空白等多整形問題修復；冪等性修復

| Commit | Description |
|------|------|
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |

---

## 2026-05-29T05:57:55+09:00

**Summary**：fix(build): .vscode gitignore 範囲過広 vendored crate 書類排除修正

---

## 2026-05-29T15:25:12+09:00

**Summary**：kitsfmt — 多修正（vendor 目録回復、冪等性、上書安全、with→builtins.attrValues 変換、--stdin 旗）；rcc-fix — D-Bus 熱挿抜検出書換；build — .vscode gitignore 範囲修正

| Commit | Description |
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

## 2026-05-28T08:29:27+09:00

**Summary**：llama-cpp-rocm — NixOS 部品（systemd 砂箱上書）；opencode-telegram — NixOS 部品（宣言的設定、自動導入）；rcc-fix — visible 属性修復；技能文書 — 動的発見表現

| Commit | Description |
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

## 2026-05-27T06:08:13+09:00

**Summary**：技能体系 — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三技能同期上線；llama-cpp-rocm 動的追跡説明

| Commit | Description |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills and nixkits-check-updates skills |
