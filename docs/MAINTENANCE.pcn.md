# Maintenance Log

[中文](../MAINTENANCE.md) | [English](MAINTENANCE.en.md) | [日本語](MAINTENANCE.ja.md)  | 偽中国語

## 2026-08-20T16:13:40+09:00

**摘要**：fix(dsh-nix-shell): sudo 実行器 PATH 合併順修正 — 套接字活性化模版単元 systemd 管理器既定 PATH（coreutils/findutils/grep/sed/systemd store 路徑僅）継承、明示 NixOS PATH 後展開 `...process.env` 覆蓋、守護内 ps 与 nixos-rebuild 等 profile 工具解決不能（PS-MISSING/NIXOS-REBUILD-MISSING）。継承 env 先、明示 NixOS profile PATH 後展開修正（請求 env 最後合併不変）。検証：systemd 既定 PATH 模擬実行器直接実行、PATH /run/current-system/sw/bin 先頭、ps 与 nixos-rebuild 両方解決成功。

| 提交 | 説明 |
|------|------|
| `63b2576` | fix(dsh-nix-shell): put the explicit NixOS profile PATH after the inherited env — socket-activated template units inherit systemd's manager-default PATH, which overrode the executor PATH and left profile tools (ps, nixos-rebuild) unresolvable |

## 2026-08-20T16:01:28+09:00

**摘要**：docs(dsh): 使用例実模組動作同期 — 手動組合行例 `- insert:` 包裹与警告追加（裸 `- id:` 行僅補丁既有条目）；技能插件文書全 7 entry id（`skill-nixkits-<id>` 接頭辞欠落）与 disabled 例 id 修正；dsh 文書安裝節模組式変更（旧 `nixkits.extraPackages` 既不存在）与二進緩存説明追加。4 言語同期。

| 提交 | 説明 |
|------|------|
| `6074661` | docs(dsh): sync usage examples with module reality — insert-op wrapping for manual rows, corrected skill entry ids, module-based install + cache note |

## 2026-08-20T11:08:08+09:00

**摘要**: fix(module): dsh 插件 ESM 解決 — dsh cordis-plugin-loader profile 目録（$DSH_HOME/profiles/web）解決基準（Node 24 内部 cascaded loader parentURL）、上方向 node_modules 検索。插件 dsh store 樹注入済、store profile node_modules 路徑上不在、import ERR_MODULE_NOT_FOUND 起動直後崩壊（restart 循環 108 回）。preStart 注入済 @kihara777 scope $DSH_HOME/node_modules 符号連結、Node 解決可。realpath store 樹復帰、插件参照 @deepseek-ai/* peer deps 同一樹内解決可。検証: skills + nix-shell 插件読込成功。

| 提交 | 説明 |
|------|------|
| `044b891` | fix(module): dsh plugin ESM resolution via DSH_HOME/node_modules symlink |

## 2026-08-20T10:33:26+09:00

**摘要**：fix(dsh): insert 塊縮進修正 — 嵌套 '' 字符串按自身最小縮進剝離、插件条目第 0 列復帰、`- insert:` 兄弟補丁操作誤解析（dsh 報 patch: entry … not found + id is required for non-insert patches、8 行再度全部未掛載）。每包一個 insert 操作発行、条目对象与 `- insert:` 行同字符串（2/4 列縮進）修正、模組注釈陷阱記録。検証：dump-config stderr 零、8 行全部合成樹反映。

| 提交 | 説明 |
|------|------|
| `988dc6d` | fix(dsh): emit one insert op per plugin entry in a single string — nested '' strings dedent to column 0, turning entry objects into sibling patch ops |

## 2026-08-20T10:21:46+09:00

**摘要**：fix(dsh): 生成行 insert 動詞包裹 — cordis.patch.yml 裸 `- id:` 行僅補丁既有条目、新規插件条目 dsh 破棄（stderr: patch: entry "nixkits-nix-shell" not found）、8 插件行全部未掛載（dump-config 検証）。包注入成功処、合成樹無条目故 nix_shell 工具与 7 技能插件未登録。生成 plugins.packages 行 `- insert:` 操作包裹修正（extraPatch MCP 行同形）。検証：dump-config stderr 零、8 行全部合成樹反映。

| 提交 | 説明 |
|------|------|
| `3d0433d` | fix(dsh): wrap generated plugin rows in the insert op — bare - id: rows only patch existing entries, so dsh dropped every new entry with 'patch: entry … not found' |

## 2026-08-20T09:45:59+09:00

**摘要**：fix(dsh): 複数插件注入失敗修正 — 展開後 GNU tar 復元归档内目録模式（store 樹 0555）、直前插件作成 scope 目録（@kihara777/）次插件書込不可、2 個目以降 Cannot mkdir: Permission denied 失敗。単一插件不発生、初実系統構築顕在化。各插件解包直後 chmod -R u+w 実行修正。検証：系統 toplevel 完全構築成功、dsh-nix-shell 与 7 技能全部注入済。

| 提交 | 説明 |
|------|------|
| `b03a386` | fix(dsh): chmod node_modules after each plugin injection — GNU tar restores archived dir modes (0555) after extraction, leaving the scope dir created by the previous plugin unwritable for the next one |

## 2026-08-20T08:12:57+09:00

**摘要**：fix(rcc-fix): desktop 条目改名互換 — asusctl 6.4.0 desktop 条目 org.opengamingcollective.rog-control-center.desktop 改名、nixpkgs programs.rog-control-center autoStart（makeAutostartItem）旧名 rog-control-center.desktop 複製続、系統構築失敗（cp cannot stat）。rcc-fix overlay asusctl postInstall 旧名符号連結提供。検証：本機釘 nixpkgs rev（0ae2bc1）makeAutostartItem { name = "rog-control-center"; package = asusctl } 構築成功（EXIT=0）。

| 提交 | 説明 |
|------|------|
| `650f6f7` | fix(rcc-fix): compat symlink for renamed desktop entry — nixpkgs programs.rog-control-center autoStart copies the pre-6.4.0 filename |

## 2026-08-20T07:41:45+09:00

**摘要**：fix(rcc-fix): asusctl 6.4.0 向補丁再基 — nixpkgs 前進 asusctl 6.3.7 → 6.4.0、rcc-fix.patch 第 4 hunk 失敗（系統構築失敗）。上流該領域再構築（`if dev.is_old_laptop() { pow3r.retain(...) }` 旧 push 塊置換、else 分岐 PowerZones::None 過濾上流吸収）。補丁境界検査置換（`names[(*z) as usize]` → filter_map 境界検査 + warn）保持。他 hunk 変更不要。検証：6.4.0 源 git apply --check 全 hunk 通過、本機釘 nixpkgs rev（0ae2bc1）asusctl 構築成功（EXIT=0）。

| 提交 | 説明 |
|------|------|
| `ce216c7` | fix(rcc-fix): rebase patch hunk 4 for asusctl 6.4.0 — upstream is_old_laptop/retain restructure, else-filter absorbed upstream |

## 2026-08-20T06:27:40+09:00

**摘要**：feat(dsh-nix-shell): 外部 sudo 守護統合（0.2.0）— dsh 沙箱 sudo setuid 剥奪、代理昇格不能。插件初期化時守護套接字（config `sudoSocketPath` / 環境変数 `NIXKITS_SUDO_SOCKET`）検出、存在時 `sudo`/`justification` 參數有効化。`sudo: true` 請求全体（command/cwd/env/timeout）Unix 套接字経由守護路由、`justification` 必須結果随返。守護 = systemd 套接字激活型 root 実行器（nixkits-sudo@.service + nixkits-sudo-exec.js、接続毎 1 請求 JSON 協議、插件包同梱）。接続制御境界 = dsh service 用戶所有 `0600` 套接字文件（SocketUser/SocketMode）。部品 nixkits.dsh.sudo（enable/socketPath/package）追加、単元生成与環境変数注入。検証：門控（套接字無參數非公開／有公開）、路由往復、justification 強制、実行器直結協議、部品単元評価全通過。

| 提交 | 説明 |
|------|------|
| `ef4bcfc` | feat(dsh-nix-shell): external sudo daemon integration — socket-activated root executor, init-time detection, sudo routing |

## 2026-08-20T06:02:50+09:00

**摘要**：refactor(skills): NixKits 技能原生 DSH 技能插件書換 — 新包 dsh-skill-nixkits（@kihara777/dsh-skill-nixkits、runtime 依存零）、7 技能各包内子路插件条目。各插件 runtime ctx.skills.register 自身内容登録（runtime provider、rank 250、文件系統由來優先）、apply() 登録 disposer 返組合解除随破棄。SKILL.md skills/ 単一來源殘置構築期嵌入、frontmatter 剥離 content 化 metadata 保持（文書管自動発見契約不変）。部品 skills.enable 7 組合行（skill-nixkits-<id> → @kihara777/dsh-skill-nixkits/<id>）自動生成、旧誤実装目録注入（nixkits-skills 包 + bundledSkillDir）置換。検証：7 插件 mock 登録全通過、裸子路 import + 登録実測（SUBPATH-OK/REGISTERED）。CI x86_64/aarch64 構築追加。

| 提交 | 説明 |
|------|------|
| `7393b95` | feat(dsh): rewrite NixKits skills as native skill plugins — dsh-skill-nixkits package, one plugin entry per skill |

## 2026-08-20T05:27:48+09:00

**摘要**：feat(dsh): 内建 bash 工具 NixOS 修正 + 第三者插件包 + 配備同梱技能 — ① 部品 dsh service 完全 NixOS PATH 注入（systemd 既定 PATH bash 無、標準 bash 工具 spawn bash ENOENT 失敗）；② dsh-nix-shell 包新規（@kihara777/dsh-nix-shell、NixOS 対応 shell 工具插件：PATH 解失敗時 Nix store bash 回退、NixOS PATH 注入、超時與落盤輸出）與 nixkits-skills 包（技能目録 bundle）新規；③ 部品 plugins.packages（node_modules tar 展開注入 — 符号連結 Node realpath 插件自身 store 路戻 peer 解決壊故実展開 — 與組合行自動生成）與 skills.enable（skill-filesystem bundledSkillDir、rank 600）追加；④ CI dsh-nix-shell x86_64/aarch64 構築追加。注入樹内 IMPORT-OK 端到端検証（插件輸出與依存連鎖解決正常）。

| 提交 | 説明 |
|------|------|
| `69eedd4` | feat(dsh): PATH fix + third-party plugin packages + bundled skills — L1/L2/L3/路径A |
| `55664ed` | docs: dsh-nix-shell package docs + dsh module options + README rows (4 languages) |

## 2026-08-19T20:39:47+09:00

**摘要**：fix(ci): ci-summary 徽章 failing 固定問題修正 — jq 管 workflow 分組先 failure 過濾、旧失敗永久覆後続成功（codewhale riscv64 修正後徽章仍紅）。先 workflow 別最新実行取得後 failure 判定修正、徽章 passing 復帰。

| 提交 | 説明 |
|------|------|
| `d752c83` | fix(ci): ci-summary badge stuck on failing — latest-run check must precede failure filter |

## 2026-08-19T19:57:03+09:00

**摘要**：fix(codewhale-src): riscv64 交叉構築修正 — 四重問題連鎖解消：① rquickjs-sys 0.12.2（crates.io 最新版）riscv64gc bindings 無（build.rs 非 bindgen 路 include 目標文件）、上流各 64bit 小端 bindings 字節一致故 postPatch x86_64 版物化済 vendor 目録配置；② 宿主側（x86_64 build 依存）ring 構築 cc-rs 宿主 triple 自派生 CC（交叉編譯器）回退 -m64 付与 — buildPackages 工具連明示；③ postInstall 裸 cargo build --target 喪失宿主工具連連結 — cargoBuildHook 同目標 triple 明示；④ 二進 -lgcc_s 動的連結 autoPatchelfHook hostPlatform 依存走査 — 交叉 gcc libgcc 輸出明示追加。CI 同命令（pkgsCross.riscv64.callPackage）本地検証済。Build codewhale (riscv64) 六連敗解消。

| 提交 | 説明 |
|------|------|
| `962ce6c` | fix(codewhale-src): riscv64 cross build — rquickjs bindings overlay, host cc-rs toolchain, postInstall --target, libgcc rpath |

## 2026-08-19T17:57:26+09:00

**摘要**：AGENTS.md — 旧 comfyui-strix-halo 部品参照（comfyui-rocm 統合済）修正、CI 章実際 workflow 構成（包別 build-<pkg>-<arch>.yml 共有 build-package.yml 呼出 + cachix-action 配信、riscv64 構築無包及専用構築無 godot-ai/dsh 明記、ci-summary.yml 徽章機構）一致更新。

| 提交 | 説明 |
|------|------|
| `c4e320e` | docs(AGENTS): fix stale comfyui-strix-halo reference + align CI description with actual workflows |

## 2026-08-19T16:52:54+09:00

**摘要**: fix(module): dsh WebSocket 反代 mod_proxy upgrade 変更 — NixOS lighttpd 模組 allKnownModules 固定順 server.modules 生成、mod_wstunnel 常 mod_proxy 後負載。proxy.server 全路徑匹配、mod_proxy /api/events.* WebSocket 升級請求先処理 426 Upgrade Required 返、mod_wstunnel r->handler_module 非 NULL skip 不実行。lighttpd 1.4.56+ mod_proxy 原生 WebSocket 隧道（proxy.header = "upgrade" => "enable"）変更、mod_wstunnel 削除。検証: 8625 / 200、/api/events.host|mux 握手 101（本地+LAN）。

| 提交 | 説明 |
|------|------|
| `51d9435` | fix(module): dsh WebSocket reverse proxy via mod_wstunnel |
| `33d5931` | fix(module): dsh wstunnel port as string (match lighttpd backend syntax) |
| `d7d2713` | fix(module): dsh WebSocket via mod_proxy upgrade (mod_wstunnel never runs) |

## 2026-08-19T13:10:00+09:00

**摘要**: fix(pkgs): dsh 0.1.0-rc.6 → 0.1.0-rc.7。rc.6 約 13 時間後崩壊（fatal load failure: Context has been disposed）— cordis-plugin-timer ctx.timeout() Context 静態 dispose 時 reject unhandled rejection 化。rc.7（8/17）最新、cordis/timer 版不変（bug 残存可）上流修正含。插件清單不変（131）。

| 提交 | 説明 |
|------|------|
| `c75cb4c` | chore(pkgs): bump dsh 0.1.0-rc.6 → 0.1.0-rc.7 |

## 2026-08-18T20:00:00+09:00

**摘要**: fix(module): dsh 通常用户実行対応 — 隔離 system user（home /var/lib/dsh）無法 /home/<user>（700）訪問、agent 作業目録操作不能。dshHome 選項追加、HOME/DSH_HOME/WorkingDirectory/preStart 統一、StateDirectory preStart mkdir + chown 置換。本機 user="kix" + dshHome="/home/kix/.dsh"、dsh kix 身份実行 /home/kix 到達。

| 提交 | 説明 |
|------|------|
| `584c764` | fix(module): dsh dshHome option + support normal-user operation |

## 2026-08-18T19:30:00+09:00

**摘要**: feat(module): nixkits.dsh.settings — 宣言設定。dsh 設定菜單項目 $DSH_HOME/settings.yaml（文件备份、hot reload、namespace 別 section）格納。settings 選項（attrsOf attrs、namespace → section）追加 JSON（合法 YAML）preStart 写入。実測：web-search-deepseek.maxTokens 既定 4096 → 8192 宣言覆写。4言語文書設定節追加。

| 提交 | 説明 |
|------|------|
| `f2981e6` | feat(module): nixkits.dsh.settings — declarative settings |
| `dc64cbb` | docs(dsh): declarative settings section + maintenance log |

## 2026-08-18T18:45:00+09:00

**摘要**: docs(dsh) + refactor(skill): 插件清單同期 — docs/dsh.md 4言語「插件清單」節（131 内建 entry id、id -> 包名）追加、nixkits.dsh.plugins.disabled 参照。check-updates 技能第5步 dsh 特説明追加：更新時新包 dsh-*/cordis.patch.yml 清單抽出 docs 同期。

| 提交 | 説明 |
|------|------|
| `06d0e28` | docs(dsh): plugin inventory + check-updates skill sync |

## 2026-08-18T18:39:34+09:00

**摘要**：fix(module): dsh preStart rm before cp — preStart 生成文件権限 444（読取専用）、服務用戶 cp 上書不能。先 rm 後 cp 修正。

| 提交 | 説明 |
|------|------|
| `f308ac7` | fix(module): dsh preStart rm before cp — service-user cannot overwrite 444 |

## 2026-08-18T18:20:00+09:00

**摘要**: feat(module): nixkits.dsh.plugins — 宣言插件 on/off 与設定。dsh 插件 cordis.patch.yml runtime hot reload、module plugins.disabled（entry id）、plugins.settings（config 覆写）、plugins.extraPatch（MCP 等生片段）追加。系統設定 MCP extraPatch 移行、API key kix.credentials 宣言化、session-telemetry-otel + session-stats 無効化例。実測：cordis.patch.yml 正生成、absent-id 警告無。

| 提交 | 説明 |
|------|------|
| `0e4fe58` | feat(module): nixkits.dsh.plugins — declarative plugin on/off + config |
| `164d515` | docs(dsh): declarative plugin management section + maintenance log |

## 2026-08-18T17:55:00+09:00

**摘要**: fix(module): lighttpd 反代 Host/Origin loopback 改写 — trustedHosts 方式取代。dsh isTrustedApiRequest loopback 通過、per-deployment trustedHosts 不要、LAN 域名/IP 不外泄。Origin 与 Host 同時改写必須（同一生成元 check 失敗避）。実測：trustedHosts 削除後反代 API（harukax.lan / 192.168.31.241）ok:true。

| 提交 | 説明 |
|------|------|
| `a33b414` | fix(module): rewrite Host/Origin to loopback in lighttpd reverse proxy |

## 2026-08-18T17:30:00+09:00

**摘要**: fix(module): dsh trustedHosts 選項 — 反代後全 /api 403。dsh /api 要求 Host header 検証（isTrustedApiRequest：Host loopback 或信頼必須、Origin 同一生成元）。lighttpd 経由 Host LAN 域名/IP 化、全 403 forbidden。nixkits.dsh.trustedHosts 追加（repeatable --trusted-host 映射）、系統設定 harukax.lan + 192.168.31.241 信頼後 API 復旧。

| 提交 | 説明 |
|------|------|
| `3755935` | fix(module): dsh trustedHosts option — Host-header 403 behind reverse proxy |

## 2026-08-18T16:20:05+09:00

**摘要**: fix(dsh): 瀏覧器 client bundle patch — crypto.randomUUID fallback。crypto.randomUUID() 非安全上下文（HTTP LAN IP、lighttpd 反代）不可用、webui "crypto.randomUUID is not a function" 失敗。postInstall dsh-client-connection + dsh-client-ui-conversation 置換 __dshUuid helper（crypto.getRandomValues fallback、全上下文可）。server index.js Node crypto 使用、変更不要。

| 提交 | 説明 |
|------|------|
| `5d1cfa8` | fix(dsh): patch browser client bundles — crypto.randomUUID fallback |

## 2026-08-18T15:29:14+09:00

**摘要**: fix/docs(dsh): lighttpd 反代定稿 — dsh 内部 loopback 端口 8615（SearXNG 42701 对齐）、lighttpd 对外端口 8625（4270 对齐）、防火牆開放 lighttpd 对外端口（非 dsh 内部）。4 語言文書同期。

| 提交 | 説明 |
|------|------|
| `4a78d54` | fix(module): dsh internal port 8615, public reverseProxy port 8625 |
| `5452a3e` | docs(dsh): sync service section to loopback 8615 + lighttpd reverseProxy 8625 |

## 2026-08-18T14:38:26+09:00

**摘要**: feat(module): dsh reverseProxy via lighttpd — dsh 拒否 non loopback（RCE 安全）、lighttpd `$SERVER["socket"]` block 0.0.0.0:8626 dsh loopback 8625 反代（SearXNG lighttpd 实例再利用、extraConfig types.lines 合併）。对外 8626 firewall 開放。

| 提交 | 説明 |
|------|------|
| `12e11af` | feat(module): add nixkits.dsh.reverseProxy via lighttpd |

## 2026-08-18T10:29:46+09:00

**摘要**: feat/fix(dsh): dsh 服務配備 + MCP/skills 設定 — ① module 修正：dsh system user HOME=/var/empty（読取専用）EPERM、書込可 /var/lib/dsh home + StateDirectory 変更；② HMR 需 --expose-internals（NODE_OPTIONS 禁止・CLI 非認識）、node --expose-internals bin.js 直起動；③ MCP cordis.patch.yml `insert:` 構文（id-targeted override 非）SearXNG + Godot 設定；④ skills /var/lib/dsh/skills/（.agent-presets 子目録非）複製；⑤ nixkits-skills 目録 ~/.dsh/skills 修正。

| 提交 | 説明 |
|------|------|
| `b17e5bf` | fix(module): dsh writable HOME + StateDirectory |
| `ed6983e` | fix(module): dsh launch via node --expose-internals (HMR requires execArgv) |
| `456c917` | feat(skill): nixkits-skills add dsh skills directory support |
| `ee24563` | fix(skill): correct dsh skills directory — ~/.dsh/skills |

## 2026-08-18T08:42:40+09:00

**摘要**: docs: ruyi 通道版本同期（stable 0.50.0 → 0.51.0、beta/alpha 日期）+ en/ja/pcn README ruyi 説明列補完（空 `<br><br>` → RuyiSDK 説明 + 3 通道版本、zh 一致）。

| 提交 | 説明 |
|------|------|
| `86ae30b` | docs: sync ruyi channel versions + fill empty ruyi descriptions in en/ja/pcn README |

## 2026-08-18T07:19:30+09:00

**摘要**: 監査修正 — ① codewhale 0.9.8 / mcp-searxng 1.15.0 / opencode-telegram 0.24.0 / obs-bilibili-stream 2.1.3 更新；② comfyui-rocm module services.comfyui assertion 復元 + nixpkgs-compat patch 目標明確化；③ overlay codewhale arch 別 source build fallback（riscv64）；④ 文書版数/連結/説明同期；⑤ write-maintenance-log 技能表頭 + katalish 列削除。

| 提交 | 説明 |
|------|------|
| `0ffa734` | fix(comfyui-rocm): clarify nixpkgs-compat patch target + restore assertion |
| `cb4e250` | fix(default-overlay): codewhale riscv64 fallback to source build |
| `04e95da` | chore(pkgs): bump mcp-searxng 1.14.1 → 1.15.0 |
| `c65d740` | chore(pkgs): bump codewhale 0.9.4 → 0.9.8 |
| `4531bf6` | chore(pkgs): bump opencode-telegram 0.23.1 → 0.24.0 |
| `7f14633` | chore(pkgs): bump obs-bilibili-stream 2.1.2 → 2.1.3 |
| `685864e` | docs: sync version numbers + ruyi link + codewhale-sudo description |
| `cc768d0` | fix(skill): write-maintenance-log table header + drop katalish |

## 2026-08-15T10:04:37+09:00

**摘要**: refactor: comfyui-rocm-patch + comfyui-strix-halo 単一 comfyui-rocm 統合 — 2 module 異部分処理（patch 層 vs Strix Halo 硬件最適化）、nixkits.comfyui-rocm（enable 選項）統合、patch mount/GFX 覆写/xformers 迂回/C 工具鏈/Strix Halo 設定（ROCm runtime/DeviceAllow/kernelParams）網羅。文書与 README 同期。

| 提交 | 説明 |
|------|------|
| `d473991` | refactor: merge comfyui-rocm-patch + comfyui-strix-halo into comfyui-rocm |

## 2026-08-15T09:23:15+09:00

**摘要**: refactor: 補丁 rog-control-center-fix.patch → rcc-fix.patch 改名、rcc-fix 統一名称收尾。overlays/rcc-fix.nix 与 4言語 rcc-fix.md 参照更新。

| 提交 | 説明 |
|------|------|
| `b350cfd` | refactor: rename rog-control-center-fix.patch to rcc-fix.patch |

## 2026-08-15T08:31:32+09:00

**摘要**: feat(dsh): deepseek-harness 0.1.0-rc.6 新包 + 4言語文書。DSH（DeepSeek Harness）— 万物皆插件。預構築 npm 包（@deepseek-ai/dsh、bin dsh → lib/bin.js）、package-lock.json 同梱（npm tarball 無 lock）、dontNpmBuild build 跳過。godot-ai 与 dsh README 掲載（4言語）。

| 提交 | 説明 |
|------|------|
| `0194460` | feat(dsh): add deepseek-harness 0.1.0-rc.6 package + 4-language docs |

## 2026-08-15T08:07:33+09:00

**摘要**: refactor: rog-control-center-fix rcc-fix 統合 — 両者同一 ROG Control Center 修正（overlay asusctl patch + module systemd 死鎖修正）。単一 rcc-fix 統一：overlays/rog-control-center-fix.nix → rcc-fix.nix、modules/rog-control-center-fix.nix → rcc-fix.nix、選項 nixkits.rog-control-center-fix → nixkits.rcc-fix、独立文書削除（rcc-fix.md 統合）。

| 提交 | 説明 |
|------|------|
| `376eacf` | refactor: merge rog-control-center-fix into rcc-fix |

## 2026-08-13T01:20:29+09:00

**摘要**: fix(default-overlay): godot-ai fastmcp overlay 適用構築 — default overlay final.callPackage fastmcp nixpkgs 3.3.1（循環 import bug）解決。 (prev.extend (import ./fastmcp.nix)) 依存 3.4.7 解決。

| 提交 | 説明 |
|------|------|
| `94d49b5` | fix(default-overlay): build godot-ai with fastmcp overlay applied |

## 2026-08-12T10:05:00+09:00

**摘要**: fix(default-overlay): godot-ai 路径修正 — default overlay callPackage `../packages/` 要（overlay 子目録）、`./packages/` 誤無存 `overlays/packages/` 解決。

| 提交 | 説明 |
|------|------|
| `0144283` | fix(default-overlay): correct godot-ai path — ./packages → ../packages |

## 2026-08-12T10:00:00+09:00

**摘要**: fix(default-overlay): godot-ai 登録 — flake packages 存在 default overlay 遺漏、下流 pkgs.godot-ai 不可視。

| 提交 | 説明 |
|------|------|
| `093565c` | fix(default-overlay): register godot-ai so pkgs.godot-ai is available |

## 2026-08-12T09:18:26+09:00

**摘要**: docs(godot-ai): 4言語文書新規追加（72行）— 架構図、依存表（fastmcp 3.4 含）、系統導入 + MCP 設定 + 前提條件指南。

| 提交 | 説明 |
|------|------|
| `76c39c8` | docs(godot-ai): add 4-language documentation |

## 2026-08-12T07:07:27+09:00

**摘要**: feat(godot-ai): godot-ai 3.1.5 新包 + fastmcp 3.4.7 overlay。godot-ai MCP client Godot editor 接続本格 MCP server。fastmcp 3.3.1→3.4.7（必要 >=3.4.0、3.3.x 循環 import bug）、fastmcp-slim + py-key-value-aio 0.4.5 連動。devshell godot-mcp→godot-ai。

| 提交 | 説明 |
|------|------|
| `23a5b8d` | feat(godot-ai): add godot-ai 3.1.5 package + fastmcp 3.4.7 overlay |

## 2026-08-11T18:49:54+09:00

**摘要**: fix(breeze-black): Edge/Chromium 純黒背景 + 純白前景 — sed 再映射拡張：背景 #292c30 → #000000（按鈕/工具欄/禁用）、前景 #fcfcfc/#a1a9b1 → #ffffff。gtk-3.0/4.0 検証：15× #000000、14× #ffffff、零灰残留。

| 提交 | 説明 |
|------|------|
| `4e5c558` | fix(breeze-black): pure black bg + pure white fg for Edge/Chromium |

## 2026-08-11T18:41:14+09:00

**摘要**: fix(breeze-black): 背景変数 純黒 #000000 映射 — Breeze-Dark 基本色 #202326（濃灰非純黒）。CSS 複製後 主背景/base #000000 再映射（按鈕 #292c30 維持區別）、gtk-dark.css 自己完結（gtk.css 複製）灰色 import 廢止。

| 提交 | 説明 |
|------|------|
| `2ee1ba6` | fix(breeze-black): map background variables to true black #000000 |

## 2026-08-11T16:19:49+09:00

**摘要**: fix(breeze-black): gtk.css 本体 Breeze-Dark dark 覆写 — Chromium 系（Edge/Chrome）prefer-dark 無視、gtk.css 直読；BreezeBlack（light Breeze 改名）light 変数（#eff0f1）残留、Edge 灰色。gtk-{3,4}.0 gtk.css(+.map) dark（#202326）覆写。

| 提交 | 説明 |
|------|------|
| `25e23e0` | fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme |

## 2026-08-11T16:02:39+09:00

**摘要**: fix(breeze-black): Breeze-Dark 保持 — BreezeBlack gtk-dark.css `@import ../../Breeze-Dark/...` 真 dark 配色（#202326）取得、preFixup 削除致 import 断、GTK 浅色退避（「不够黑」症状）。

| 提交 | 説明 |
|------|------|
| `0433eee` | fix(breeze-black): keep Breeze-Dark — gtk-dark.css imports it for dark mode |

## 2026-08-09T22:43:43+09:00

**摘要**: refactor(skill): 陷阱第4条追加 — 無引数 `nix flake lock` 全 floating input 更新（nixpkgs 漂移再発、8/7 diffusers/httpx 失敗）。--update-input 或 rev 固定使用。

| 提交 | 説明 |
|------|------|
| `ec5e589` | refactor(skill): add trap 4 — bare nix flake lock refreshes floating inputs |

## 2026-08-09T19:40:21+09:00

**摘要**: feat(patches): 本地 comfyui-nix build 修正 patch 正式化 — ① mkWheel dontCheckRuntimeDeps（pythonRuntimeDepsCheckHook ≥ 8/5）；② flaky 套件 doInstallCheck=false（jupyter-server/scipy/fastapi/einops/mss/inline-snapshot）；③ torch/facexlib runtime 依頼 skip。module 注釈 + 4 言語文書更新。

| 提交 | 説明 |
|------|------|
| `a8ad11e` | feat(patches): add comfyui-nix nixpkgs-compat patch + module doc |
| `faefa5b` | docs(comfyui-rocm-patch): document nixpkgs-compat patch (4 langs) |

## 2026-08-09T19:05:53+09:00

**摘要**: refactor(skill): nixkits-check-updates nixpkgs 漂移診断節追加 — ① 旧 flake.lock 復元 follows 要確認（喪失 → glibc 2.40 → GLIBC_ABI_GNU2_TLS）；② pytest 包 doInstallCheck=false 使用；③ pythonRuntimeDepsCheckHook（≥ 8/5）wheel 構築破壊、dontCheckRuntimeDeps=true 修復。

| 提交 | 説明 |
|------|------|
| `e88fd98` | refactor(skill): add nixpkgs-drift troubleshooting section to check-updates |

## 2026-08-09T04:21:09+09:00

**摘要**: fix(module): llama-cpp — ① services.llama-cpp.extraFlags 非推奨、settings 採用；② freeform settings 分離定義不可、lib.mkMerge 統合。

| 提交 | 説明 |
|------|------|
| `8026d8e` | fix(module): replace deprecated services.llama-cpp.extraFlags with settings |
| `0ec7760` | fix(module): merge llama-cpp settings via mkMerge |

## 2026-08-08T23:07:40+09:00

**摘要**: fix(breeze-black): look-and-feel 全局主題復元 + GTK 改名修正 — 7/23 外部補丁除去後 2 種後退：① org.kde.breezeblack.desktop 欠落 BreezeBlack 設定主題選択消失、local 内蔵復元；② preFixup Breeze* 同時匹配 Breeze/Breeze-Dark GTK 主題嵌套、Breeze 単独改名修正。

| 提交 | 説明 |
|------|------|
| `114b9c2` | fix(breeze-black): restore look-and-feel global theme + fix GTK rename |

## 2026-08-08T22:50:33+09:00

**摘要**: fix(codewhale-src): 0.9.4 同期 source hash 修正 — nix-prefetch-url archive tarball hash fetchFromGitHub（git 方式）不一致、riscv64 CI 連続失敗。fetchFromGitHub build 正 hash 取得、Cargo.lock 同期、技能誤助言修正。

| 提交 | 説明 |
|------|------|
| `08b04a2` | fix(codewhale-src): sync to 0.9.4 with correct fetchFromGitHub hash |
| `ab2a624` | fix(skill): correct fetchFromGitHub hash advice — archive tarball trap |

## 2026-08-08T22:20:21+09:00

**摘要**: codewhale 0.9.4 — 上流修正；mcp-searxng 1.14.1 — 上流保守；opencode-telegram 0.23.1 — 上流機能追加

| 提交 | 説明 |
|------|------|
| `f184fdb` | chore(pkgs): bump codewhale 0.9.3 → 0.9.4 |
| `9b877e1` | chore(pkgs): bump mcp-searxng 1.14.0 → 1.14.1 |
| `9b17590` | chore(pkgs): bump opencode-telegram 0.22.5 → 0.23.1 |
| `59ac74a` | docs: sync version numbers |

| 軟件名 | 舊 | 新 |
|------|------|------|
| codewhale | 0.9.3 | 0.9.4 |
| mcp-searxng | 1.14.0 | 1.14.1 |
| opencode-telegram | 0.22.5 | 0.23.1 |

## 2026-08-05T07:24:56+09:00

**摘要**: chore(pkgs) — codewhale-src 0.9.3 同期（riscv64 源码 build 預編譯 3 版遅）。version・fetchFromGitHub hash・Cargo.lock（711 → 763 項目）同期。

| 提交 | 説明 |
|------|------|
| `563eea2` | chore(pkgs): sync codewhale-src to 0.9.3 — version, hash, Cargo.lock |

## 2026-08-05T01:30:00+09:00

**摘要**: refactor(skill) — nixkits-check-updates Rust 包（buildRustPackage）更新流程追加。codewhale-src Cargo.lock 同期経験汎化（version + source hash + Cargo.lock 三所同期、上流 lock 取得 項目数検証、交叉編譯 timeout 迂回）。

| 提交 | 説明 |
|------|------|
| `6e6bef6` | refactor(skill): add Rust package (buildRustPackage) update flow to nixkits-check-updates |

## 2026-08-04T02:15:00+09:00

**摘要**: fix(ruyi): ruff lint 失敗許容 — 第2 ruff check（--fix無）nixpkgs ruff 更新後 139件 上流違反 build 遮断。

| 提交 | 说明 |
|------|------|
| `1175df2` | fix(ruyi): tolerate ruff lint failures in checkPhase |

## 2026-08-04T01:15:52+09:00

**摘要**：codewhale 0.9.3 — 上流修正；mcp-searxng 1.14.0 — 上流機能追加

| 提交 | 説明 |
|------|------|
| `f84cbcb` | chore(pkgs): bump codewhale 0.9.1 → 0.9.3 |
| `6968f4e` | chore(pkgs): bump mcp-searxng 1.12.1 → 1.14.0 |
| `d778b1b` | docs: sync version numbers |

| 軟件名 | 舊 | 新 |
|------|------|------|
| codewhale | 0.9.1 | 0.9.3 |
| mcp-searxng | 1.12.1 | 1.14.0 |

## 2026-07-31T04:07:23+09:00

**摘要**：fix(ci): ci-summary.yml 構文修正（YAML 混在、固定 token）、push/schedule + GITHUB_TOKEN 移行。README badge shields.io endpoint 全 Build 実状態反映変更。

| 提交 | 説明 |
|------|------|
| `c0e52a5` | fix(ci): fix ci-summary.yml syntax, switch README badge to endpoint |

## 2026-07-31T03:34:15+09:00

**摘要**：fix(ci): GITHUB_TOKEN 注入 Nix access-token — llama-cpp-ver input GitHub API 要、未認証 60回/時 制限、並列 CI HTTP 403 頻発。`${{ secrets.GITHUB_TOKEN }}` 使用。

| 提交 | 说明 |
|------|------|
| `41a8a8b` | fix(ci): inject GITHUB_TOKEN as Nix access-token for llama-cpp-ver API |

## 2026-07-31T03:00:12+09:00

**摘要**：fix(codewhale-src): riscv64 交叉修正 — `ring` `cc` build 汎用 CFLAGS `-m64` 継承、riscv64-gcc 誤。per-target + 汎用 CFLAGS/CXXFLAGS clear。

| 提交 | 説明 |
|------|------|
| `29c780a` | fix(codewhale-src): clear generic CFLAGS/CXXFLAGS for riscv64 cross-compile |

## 2026-07-30T17:56:11+09:00

**摘要**：codewhale 0.9.1 — 上流修正；mcp-searxng 1.12.1 — 上流機能追加；opencode-telegram 0.22.5 — 上流保守

| 提交 | 説明 |
|------|------|
| `1110c7a` | chore(pkgs): bump codewhale 0.9.0 → 0.9.1 |
| `3dcb65a` | chore(pkgs): bump mcp-searxng 1.11.1 → 1.12.1 |
| `98abe96` | chore(pkgs): bump opencode-telegram 0.22.3 → 0.22.5 |
| `a94dea8` | docs: sync version numbers |

| 軟件名 | 舊 | 新 |
|------|------|------|
| codewhale | 0.9.0 | 0.9.1 |
| mcp-searxng | 1.11.1 | 1.12.1 |
| opencode-telegram | 0.22.3 | 0.22.5 |

## 2026-07-23T12:56:53+09:00

**摘要**：fix(codewhale-sudo): ptrace wrapper 修正 — 子追跡削除（sub-shell SIGTRAP kill 防止）、PTRACE_EVENT_EXEC 追加。4 言語文書同期更新。

| 提交 | 説明 |
|------|------|
| `c77cadc` | fix(codewhale-sudo): stop tracing child processes, handle PTRACE_EVENT_EXEC |
| `480658e` | docs(codewhale-sudo): update mechanism description LD_PRELOAD → ptrace |

## 2026-07-23T12:08:13+09:00

**摘要**：fix(codewhale-sudo): LD_PRELOAD shim → ptrace 入替 — codewhale 静的連結故 LD_PRELOAD 不可、ptrace(2) 採用。kernel 境界捕捉、静的双方可。

| 提交 | 説明 |
|------|------|
| `6446364` | fix(codewhale-sudo): replace LD_PRELOAD shim with ptrace syscall interceptor |

## 2026-07-23T11:24:15+09:00

**摘要**：fix(overlays): breeze-black — 無効化 fetchpatch URL（injx.sbs 永久不可用）、純粋 局所 colors 手動入替。KDE Plasma 配色自動検出 share/color-schemes/ 経由。

| 提交 | 説明 |
|------|------|
| `547d6a0` | fix(overlays): replace dead breeze-black fetchpatch with local copy |

## 2026-07-22T16:31:26+09:00

**Summary**: fix(modules) — rog-control-center-fix now forces SendSIGKILL=yes + TimeoutStopSec=30s to prevent stale asus-shutdown process from blocking systemd-switch. comfyui-strix-halo now asserts glibc >= 2.42 (ROCm 7.2 needs GLIBC_ABI_GNU2_TLS).

| 提交 | 说明 |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T09:00:00+09:00

**Summary**：feat(overlays) — new breeze-black overlay, providing high-contrast Breeze Black accessibility theme for Plasma 6 (global look-and-feel + GTK + color scheme). Includes 4-language docs.

| 提交 | 说明 |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T05:39:31+09:00

**Summary**: docs(devshell) — new devShell documentation (4 languages), describing opencode (full MCP stack) and ruyi (3 channels merged) environments. README devShell table now includes doc links.

| 提交 | 说明 |
|------|------|
| `7bfe3e3` | docs: add devShell documentation — 4 lang |
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |

## 2026-07-22T03:40:50+09:00

**Summary**: docs — unified all user home directory paths across the repo to `~/` prefix (replaced hardcoded `/home/kix` and `/home/<user>` variants), covering 13 files.

| 提交 | 说明 |
|------|------|
| `f597b9a` | docs: generalize hardcoded /home/kix paths |
| `bb65b77` | docs: unify all user home paths to ~/ prefix |

## 2026-07-22T03:14:27+09:00

**Summary**: feat(shells) — opencode devShell iteration: SearXNG + lighttpd (matching system NixOS config) + blender-mcp + godot-mcp + godot + opencode + opencode-telegram. Auto-registers MCP config on first entry. Removed tryEval guards from godot packages.

| 提交 | 说明 |
|------|------|
| `35cc4e8` | feat(shells): add opencode-telegram devShell + nix run doc |
| `2b8f676` | fix(shells): add opencode to opencode-telegram devShell |
| `e83982d` | refactor(shells): merge blender-mcp + mcp-searxng |
| `c5a57a6` | refactor(shells): rename opencode, add godot-mcp + godot_4 |
| `60a065e` | fix(shells): add GODOT_PATH |
| `47e43b3` | fix(shells): set SEARXNG_URL |
| `3652030` | feat(shells): add self-contained SearXNG + Redis |
| `e0ead5a` | refactor(shells): extract devShells from flake.nix to develop/ |
| `9d67fd8` | feat(shells): auto-register opencode MCP servers on first entry |
| `6a6537d` | fix(shells): add limiterSettings/trusted_proxies |
| `c316c97` | feat(shells): add lighttpd reverse proxy |
| `f8943ff` | refactor(shells): remove tryEval for godot-mcp |
| `8d2f65b` | fix(shells): s/godot_4/godot/ |

## 2026-07-22T02:43:51+09:00

**Summary**: feat(overlays) — new efl-cross-fix overlay, fixing efl cross-compilation failures on riscv64/riscv64-musl/aarch64 caused by missing native code-gen tools (eolian_gen, eet). Includes 4-language docs.

| 提交 | 说明 |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**Summary**: codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3 — upstream updates (codewhale v0.9.0 still no riscv64 prebuilt binaries, continues source-build path)

| 提交 | 说明 |
|------|------|
| `deca3e8` | chore(pkgs): bump opencode-telegram 0.22.3 |
| `6046594` | chore(pkgs): bump ruyi 0.51.0 + beta 0.51.0-beta.20260714 + alpha 0.52.0-alpha.20260714 |
| `4df8df2` | chore(pkgs): bump codewhale 0.9.0 |

|--------|--------|--------|
| codewhale | 0.8.67 | 0.9.0 |
| ruyi | 0.50.0 | 0.51.0 |
| ruyi-beta | 0.50.0-beta.20260623 | 0.51.0-beta.20260714 |
| ruyi-alpha | 0.51.0-alpha.20260616 | 0.52.0-alpha.20260714 |
| opencode-telegram | 0.22.2 | 0.22.3 |

## 2026-07-16T06:08:43+09:00

**摘要**: fix(ci) — ci-summary workflow `gh run list` 逐 workflow API 呼出 HTTP 403 rate limit 修正。2 回一括 `gh api` 呼出並列制御変更。

| 提交 | 说明 |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**摘要**: revert(skill) — katalish（半角片仮名機械翻訳）全内容削除：19 文書、技能（SKILL.md + 102 条辞書）、全言語切替連結。翻訳不安定（英文残留又文書構造破壊）生産環境不適。

| 提交 | 说明 |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:54:55+09:00

**Summary**: docs(nixkits-skills) — renamed 'Known Removals' to 'Risk Advisory' across 5-language skill docs.

| 提交 | 说明 |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**摘要**: skill(nixkits-skills) — Claude Code 導入対象削除（利用者資料基国籍推論安全境界越）、Codex 支援追加。SKILL.md「危険警告」節追記、原文声明含。

| 提交 | 说明 |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:35:20+09:00

**Summary**: skill(write-maintenance-log) — strengthened timestamp rules: mandatory `git log` for commit times, ban `T00:00:00` placeholders, add post-generation verification step. Generalized from the MAINTENANCE placeholder timestamp fix (`968df0e`).

| 提交 | 说明 |
|------|------|
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |

## 2026-07-16T04:30:55+09:00

**摘要**: feat(ci) — CI 集計端点徽章追加。主文書 CI 徽章 shields.io endpoint 経由 `gh-pages/ci-status.json` 読取、失敗時失敗包名表示。

| 提交 | 说明 |
|------|------|
| `6465260` | feat(ci): add CI summary workflow with endpoint badge |
| `b489890` | docs(README): switch main CI badge to endpoint |

## 2026-07-16T04:09:46+09:00

**摘要**: refactor(ci) — CI 単一 check.yml 25 独立 workflow 書類分割（包×構造毎）、徽章相互影響完全解消。再利用可能 `build-package.yml` 追加。

| 提交 | 说明 |
|------|------|
| `bc42e6f` | refactor(ci): split single check.yml into 25 isolated per-package-per-arch workflows |
| `1dfc1ee` | docs: update ruyi badge URLs to new isolated workflow files |
| `f235edc` | docs: embed version numbers in CI badge labels |

## 2026-07-16T04:00:46+09:00

**摘要**: fix(codewhale) — 源構築 riscv64 交叉編集修正：ring crate `-m64` 誤 cc crate 継承 host CFLAGS 起因、per-target CFLAGS 清空修正。

| 提交 | 说明 |
|------|------|
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |

## 2026-07-16T01:18:16+09:00

**Summary**: codewhale 0.8.67 — dual-path build (prebuilt x86_64/aarch64 + source-built riscv64). Upstream removed riscv64 binaries from v0.8.67 release; riscv64 now built via rustPlatform.buildRustPackage from vendored Cargo.lock.

| 提交 | 说明 |
|------|------|
| `0025476` | feat(codewhale): dual-path build — prebuilt for x86_64/aarch64, source for riscv64 |

|--------|--------|--------|
| codewhale | 0.8.66 (prebuilt ×3) | 0.8.67 (prebuilt ×2 + source riscv64) |

## 2026-07-15T08:32:13+09:00

**Summary**: mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 — upstream updates (codewhale skipped: v0.8.67 still missing riscv64 binaries)

| 提交 | 说明 |
|------|------|
| `48414d4` | chore(pkgs): bump mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 |

|--------|--------|--------|
| mcp-searxng | 1.11.0 | 1.11.1 |
| opencode-telegram | 0.22.1 | 0.22.2 |
| obs-bilibili-stream | 2.1.1 | 2.1.2 |
| codewhale | 0.8.66 | (skipped — upstream v0.8.67 still missing riscv64 binaries) |

## 2026-07-09T01:22:00+09:00

**摘要**: revert(ci) — `ci/` 削除、`llama-cpp-ver` input 上流 API 復元。上乗既 `tryEval` + fallback 備、局所緩衝不要。

| 提交 | 说明 |
|------|------|
| `dbdd937` | revert: restore llama-cpp-ver to upstream API, remove ci/ |

## 2026-07-09T01:14:34+09:00

**摘要**: obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 — 上流更新（codewhale 跳過：v0.8.67 riscv64 二進欠落）

| 提交 | 说明 |
|------|------|
| `73dc576` | chore(pkgs): bump obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| obs-bilibili-stream | 2.1.0 | 2.1.1 |
| mcp-searxng | 1.8.0 | 1.11.0 |
| opencode-telegram | 0.22.0 | 0.22.1 |
| codewhale | 0.8.66 | (跳過 — 上流 riscv64 二進欠落) |

## 2026-07-07T12:01:12+09:00

**摘要**: fix(docs) — katalish/pcn 現地化修正：katalish/ruyi.md pcn/ruyi.md 言語切替破損（連結欠落又重複言語名）修正、pcn/ruyi.md 全文日本語偽中国語書換。

| 提交 | 说明 |
|------|------|
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |

## 2026-07-05T04:41:23+09:00

**摘要**: fix(ci) — blender-mcp riscv64-cross 修正経緯（4 回）。初 `callPackage` 自動解決非互換 `blender` 失敗、Nix/Bash 逸脱問題、最終上流 nixpkgs `sse-starlette` 交叉編集欠陥故 blender-mcp 除外。x86_64 / aarch64 無影響。

| 提交 | 说明 |
|------|------|
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |

## 2026-07-04T07:33:07+09:00

**摘要**: docs(MAINTENANCE) — 全 6 MAINTENANCE 書類（zh/en/ja/katalish/pcn）言語切替追加

| 提交 | 说明 |
|------|------|
| `9feb2fd` | docs(MAINTENANCE): add language switcher to all 6 MAINTENANCE files (zh/en/ja/katalish/pcn) |

## 2026-07-04T06:41:28+09:00

**摘要**: blender-mcp 1.0.0 — 新規 Blender MCP 伺服器包（Python 構築、22 MCP 道具、Blender 拡張含）

| 提交 | 说明 |
|------|------|
| `a1cf458` | packages: add blender-mcp (MCP server for Blender) |
| `ab9109a` | packages: add blender-mcp (MCP server for Blender) |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| blender-mcp | — | 1.0.0 |

## 2026-07-02T04:00:00+09:00

**摘要**: codewhale 0.8.66 — 上流更新

| 提交 | 说明 |
|------|------|
| `c00a5e6` | chore(pkgs): bump codewhale 0.8.66 |
| `c61d458` | docs: bump codewhale 0.8.66 version numbers in all 5-language docs |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.65 | 0.8.66 |
| 　 | cli hash (×3) | all updated |
| 　 | tui hash (×3) | all updated |

## 2026-06-28T06:30:00+09:00

**摘要**: opencode-telegram 0.22.0 — 上流更新（三模式TTS + thinking表示 + 緊湊出力 + /settings命令 + session起動修正）

| 提交 | 说明 |
|------|------|
| `b189d0a` | chore(pkgs): bump opencode-telegram 0.22.0 |
| `a61f444` | docs: bump opencode-telegram 0.22.0 version numbers in all 5-language docs |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.21.2 | 0.22.0 |
| 　 | source hash | `...` → `...` |
| 　 | npmDepsHash | `...` → `...` |

## 2026-06-26T13:00:00+09:00

**摘要**: CI — llama-cpp-ver 本地文件切替（ci/llama-cpp-ver.json）、全CI作業GitHub API呼出排除rate limit全局構築失敗恒久修正；docs — riscv64徽章包装別精密化

| 提交 | 说明 |
|------|------|
| `8b3a3be` | fix(ci): use local path for llama-cpp-ver input, eliminate GitHub API calls from all CI jobs |
| `5db4852` | fix(docs): add per-package job filter to riscv64 badges |

## 2026-06-26T12:30:00+09:00

**摘要**: feat(opencode-telegram): 服務PATH系包装注入extraPackages選択肢home-manager路注入extraBinPaths選択肢追加、opencode不在服務PATH問題修正；5言語文書更新

| 提交 | 说明 |
|------|------|
| `7c98694` | feat(opencode-telegram): add extraPackages option to inject companion tools into service PATH |
| `45b7c57` | feat(opencode-telegram): add extraBinPaths option for home-manager users |

## 2026-06-26T10:55:41+09:00

**摘要**: codewhale 0.8.65 — 上流更新（cli二進名変更：codewhale-cli-linux → codewhale-linux）；mcp-searxng 1.8.0 — 上流更新（多実例故障転送/並列扇出、能力発見集約、safesearch修正）

| 提交 | 说明 |
|------|------|
| `57620d4` | chore(pkgs): bump codewhale 0.8.65 + mcp-searxng 1.8.0 |
| `94ac1e4` | docs: bump codewhale 0.8.65 + mcp-searxng 1.8.0 version numbers in all 5-language docs |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.64 | 0.8.65 |
| mcp-searxng | 1.7.2 | 1.8.0 |
| 　 | codewhale cli hash (×3) | all updated (incl. URL change) |
| 　 | codewhale tui hash (×3) | all updated |
| 　 | mcp-searxng source hash | `...` → `...` |
| 　 | mcp-searxng npmDepsHash | `...` → `...` |

## 2026-06-26T08:00:00+09:00

**摘要**: docs(MAINTENANCE): pcn 欠落28件履歴項目補完、zh基準全93項目網羅

| 提交 | 说明 |
|------|------|
| `01f662b` | docs(MAINTENANCE): backfill 28 missing historical entries to pcn (93/93 zh baseline covered) |

## 2026-06-26T07:35:00+09:00

**摘要**: docs(MAINTENANCE): en/ja/katalish 欠落10件履歴項目補完、3言語全zh基準（92/92）一致；pcn 一部補完（66/92）

| 提交 | 说明 |
|------|------|
| `1921a36` | docs(MAINTENANCE): backfill 10 missing entries to en/ja/katalish (+ partial pcn) |

## 2026-06-26T07:18:56+09:00

**摘要**: fix(skill): write-maintenance-log 第4段階「多言語同期」雛形実行可能流書直（4a 言語発見 → 4b 言語別翻訳書込 → 4c 項目数一致検証）；AGENTS.md 第4段階検証確認強化

| 提交 | 说明 |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-26T06:19:21+09:00

**摘要**: 監査修正 — 空 scripts/ 目録削除 .gitignore 死規則（translate_pcn.py）削除；AGENTS.md SKILL.md 行数制約硬性数値定性案内緩和

| 提交 | 说明 |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-25T11:02:38+09:00

**Summary**: ruyi — 交叉編訳修正（postPatch 使用 python.pythonOnBuildForHost）；CI — ruyi* riscv64-cross 復帰；docs — riscv64 徽章正確 job filter 復元

| 提交 | 说明 |
|------|------|
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |

## 2026-06-25T10:12:02+09:00

**Summary**: CI — riscv64-cross 恒久除去 ruyi*（Python postPatch 交叉編訳不可）；docs — riscv64 徽章 * 標記回落復帰 + 注記

| 提交 | 说明 |
|------|------|
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |

## 2026-06-25T10:04:30+09:00

**Summary**: CI — access-tokens 覆写 修正、GitHub API 速率限界超過解消（一行統合）；riscv64-cross 並列上限 4 設定

| 提交 | 说明 |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |

## 2026-06-25T09:44:44+09:00

**Summary**: CI — riscv64-cross に ruyi/ruyi-beta/ruyi-alpha 復帰（路映射）；docs — 徽章標籤簡略化 + riscv64 job 精密過濾

| 提交 | 说明 |
|------|------|
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |

## 2026-06-25T09:29:43+09:00

**Summary**: CI — build / riscv64-cross を包別 matrix 分割、独立徽章対応；docs — ruyi 徽章を 9 枚（3版本×3架構）拡張

| 提交 | 说明 |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |

## 2026-06-25T09:24:43+09:00

**Summary**: CI — build job に ruyi-beta / ruyi-alpha 構築段階追加；docs — ruyi 基本情報表格通道行に beta/alpha 版本番号追加

| 提交 | 说明 |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |

## 2026-06-25T09:09:26+09:00

**Summary**: CI — ruyi を riscv64-cross 除外；overlays — default overlay に ruyi-beta/ruyi-alpha 追加＋nixConfig を flake 最上位層移行；docs — README 表に ruyi 3路版本表示

| 提交 | 说明 |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |

## 2026-06-25T05:35:00+09:00

**摘要**: docs — 全5言語README ruyi-beta / ruyi-alpha devShell 項目追加

| 提交 | 说明 |
|------|------|
| `5d4ca02` | docs: add ruyi-beta + ruyi-alpha to devShell tables (all 5 READMEs) |

## 2026-06-25T05:28:12+09:00

**摘要**: ruyi — 包装目録構造再編（packages/ruyi/）、beta/alpha thin wrapper化；devShells 追加

| 提交 | 说明 |
|------|------|
| `4b9865e` | refactor(pkgs): move ruyi into subdirectory, beta/alpha as thin wrappers |
| `94bb174` | feat(shells): add ruyi-beta + ruyi-alpha devShells |

## 2026-06-25T05:13:34+09:00

**摘要**: ruyi — 版通道独立包装化（ruyi / ruyi-beta / ruyi-alpha）、独立overlay削除

| 提交 | 说明 |
|------|------|
| `51f23ad` | refactor(pkgs): ruyi channels as separate packages (not overlays) |

## 2026-06-25T04:58:36+09:00

**摘要**: ruyi — 3通道版体系（stable/beta/alpha）、基本包装0.50.0安定版切替、beta/alpha overlay上書

| 提交 | 说明 |
|------|------|
| `a9f8baa` | feat(pkgs): ruyi 3-channel (stable/beta/alpha) via overlays |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| ruyi | 0.51.0-alpha.20260616 | 0.50.0（安定版） |
| 　 | 新規 ruyi-beta overlay | 0.50.0-beta.20260623 |
| 　 | 新規 ruyi-alpha overlay | 0.51.0-alpha.20260616 |

## 2026-06-24T03:19:30+09:00

**摘要**: workflow — 維護記録更新規則必須化（AGENTS.md + write-maintenance-log 技能）

| 提交 | 说明 |
|------|------|
| `2e719df` | fix: make maintenance log update mandatory after every push |

## 2026-06-24T03:15:37+09:00

**摘要**: docs — 古手動riscv64構築手順削除、CI 3架構網羅済

| 提交 | 说明 |
|------|------|
| `698400a` | docs: remove stale manual riscv64 build instructions — CI now covers all 3 architectures |

## 2026-06-24T03:06:20+09:00

**摘要**: codewhale 0.8.64 — 上流更新

| 提交 | 说明 |
|------|------|
| `0bde292` | chore(pkgs): bump codewhale 0.8.64 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.63 | 0.8.64 |
| 　 | x64 cli hash | `...` → `...` |
| 　 | arm64 cli hash | `...` → `...` |
| 　 | riscv64 cli hash | `...` → `...` |
| 　 | x64 tui hash | `...` → `...` |
| 　 | arm64 tui hash | `...` → `...` |
| 　 | riscv64 tui hash | `...` → `...` |

## 2026-06-24T02:30:21+09:00

**摘要**: CI — riscv64交叉編訳管追加、3架構CI全量網羅（x86_64 / aarch64 / riscv64）；包装毎riscv64徽章追加

| 提交 | 说明 |
|------|------|
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |

## 2026-06-23T05:20:00+09:00

**摘要**: translate-pseudocn — Web調査基辞書拡充（7→46項目）、SVO語順変更、全pcn文書再生成

| 提交 | 说明 |
|------|------|
| `4fbf387` | feat(pcn): expand dictionary 7→46 entries, add IT terminology from research |
| `ec38b7e` | feat(pcn): convert to SVO word order, expand dictionary, regenerate all 22 docs |

## 2026-06-23T04:19:16+09:00

**摘要**: translate-pseudocn技能再構築 — 疑似中国語「日本語仮名剥視覚結果」再定義、中国語変換廃止。日本語漢字保持（簡体字化）、SOV語順維持、辞書40→7項目縮小（片仮名→日本語漢字）。全22件pcn文書再生成

| 提交 | 说明 |
|------|------|
| `be0780b` | refactor(pcn): redesign pseudo-Chinese skill — Japanese-native kanji, SOV order, no Chinese chars |

## 2026-06-23T04:04:32+09:00

**Summary**：AGENTS.md — 硬符号除去、冗長監査備忘削除、緩衝章代理操作手引書換、利用者側記述削除、言語体系自動発見変更

| 提交 | 说明 |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:49:00+09:00

**Summary**：mcp-searxng 1.7.2 — 上流修復

| 提交 | 说明 |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |

## 2026-06-22T23:22:00+09:00

**Summary**：AGENTS.md — 新規初回起動監査規則、接続制御頂部移動

| 提交 | 说明 |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**Summary**：docs — README 重複行修復、write-project-docs 反模式補充

| 提交 | 说明 |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**Summary**：AGENTS.md — 新規接続制御、言語要求、送信規範、保守記録確認、文書同期、汎化、多構造緩衝規則

| 提交 | 说明 |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**Summary**：docs — 毎包文書双構造 CI 徽章追加、技能雛形同期

| 提交 | 说明 |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**Summary**：CI — ARM runner 多構造構築追加、flake.lock 並行競合修正（--no-write-lock-file）

| 提交 | 说明 |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**Summary**：mcp-searxng — source hash + npmDepsHash 更新（GitHub archive 変化）；ruyi — overlay postPatch 戻移（修正書類依存）

| 提交 | 说明 |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**Summary**：docs — 緩衝除外警告追加（上乗及部品+修正条目）、README 緩衝説明圧縮、flake.nix nixConfig 自動宣言追加

| 提交 | 说明 |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**Summary**：docs — 全 30 篇包文書 `## 緩衝` 節追加、CI badge 配置改善、技能同期

| 提交 | 说明 |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**Summary**：CI/CD — GitHub Actions 構築行列（Cachix 推送）追加、二進緩衝、AGENTS.md

| 提交 | 说明 |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**Summary**：skills — translate-katalish / translate-pseudocn / write-project-docs 辞書及雛形分割、SKILL.md 60-80 行圧縮

| 提交 | 说明 |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**Summary**：docs — MAINTENANCE 時刻精確化（29 節）、30 重複節削除（SHA 去重）、nix-kits→nixkits 全量置換（183 箇所）、部品文書同期

| 提交 | 说明 |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**Summary**：patches — ruyi-nixos-compat.patch 清浄複製基再構築（1223→426 行）、flake.lock 自参照 artifact 清除

| 提交 | 说明 |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**Summary**：overlays — patches 一覧 lib.unique 去重、ruyi-nixos-compat 精簡、llama-cpp-rocm curried 形式注釈追加

| 提交 | 说明 |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**Summary**：modules — 4 部品 enable 選項追加、comfyui-strix-halo assertions 追加、名前空間 nixkits.* 統一（含後方互換）、llama-cpp-rocm hfCacheDir 動的導出

| 提交 | 说明 |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**Summary**：codewhale 0.8.63 — 多構造予編集二進（x86_64 / aarch64 / riscv64）；ruyi — overlay postPatch 包統合；meta 欄補完

| 提交 | 说明 |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**Summary**：flake — mihomo-alpha 幽霊入力及上乗除去（書類未存在）

| 提交 | 说明 |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |

## 2026-06-21T04:32:31+09:00

**Summary**：言語切替器札規則汎化 — display_name 意味修正言語自称、言語名称不局所化規則 write-project-docs / translate-katalish / translate-pseudocn 三技能追加；修正 zh/katalish/pcn 全文書切替器中残留局所化名称

| 提交 | 说明 |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称与切换器标签分离 |
| `aa8634b` | fix(docs): zh 文档切换器残留旧名称修正 + MAINTENANCE 翻译补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**Summary**：codewhale 0.8.62 — 上流修復；mcp-searxng 1.7.1 — 上流修復

| 提交 | 说明 |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

## 2026-06-20T18:36:33+09:00

**Summary**：技能体系再構築 — translate-katakana→translate-katalish 改名、新規 translate-pseudocn（偽中国語）追加、write-project-docs 及 write-maintenance-log 言語拡張自動発見、文書符号五語対応表

| 提交 | 说明 |
|------|------|
| `0588ee0` | skill: write-project-docs 新增伪中国语(pcn)语言支持 |
| `c5fb218` | docs: write-project-docs 英日文版同步更新四语(pcn)支持 |
| `f1904a1` | feat(skill): add translate-katakana — katakana english mechanical substitution |
| `97b696c` | docs(skill): purge pcn references from write-project-docs, add kata-en |
| `7caf343` | refactor(translate-katakana): rename kata-en → katalish, use ｶﾀﾘｯｼｭ as canonical name |
| `911052b` | refactor(docs): migrate pcn directory to katalish |
| `39906b9` | docs: purge remaining pcn references from zh write-project-docs |
| `177ad9b` | refactor: rename translate-katakana→translate-katalish, add translate-pseudocn, auto-discovery |
| `fee1534` | docs(skill): add translate-* support and docs-as-code mapping to write-maintenance-log |

## 2026-06-18T09:52:34+09:00

**Summary**：codewhale 0.8.61 — 上流修復；mcp-searxng 1.6.0 — 上流修復

| 提交 | 说明 |
|------|------|
| `719e16e` | chore(pkgs): bump codewhale 0.8.61 |
| `d6717c1` | chore(pkgs): bump mcp-searxng 1.6.0 |

|--------|--------|--------|
| codewhale | 0.8.60 | 0.8.61 |
| 　 | cli hash | `...` → `sha256-3k0K/I/NxYHrNszgniQncWTu8HRqsR3RSg+YLuB+IkY=` |
| 　 | tui hash | `...` → `sha256-YVjKDO/JNnsAHwzCf4itrEw8psKyi9bbFaLJLFvMyAI=` |
| mcp-searxng | 1.4.0 | 1.6.0 |
| 　 | source hash | `...` → `sha256-oBpSAAppLfnPhC3tHoE2X1YAGMyd42fka+xAVFuhjKw=` |
| 　 | npmDepsHash | `...` → `sha256-7z5T8po2ya698J7vqu4pA7c8s85k33sRbOV2tRmGdPo=` |

## 2026-06-18T09:03:48+09:00

**Summary**：ruyi — NixOS 互換性修正（`patches/ruyi-nixos-compat.patch`）、透過的処理予編集 RISC-V 道具連動的連結器路、GCC 子工程 ELF interpreter 修復及 console_scripts argv0 問題

| 提交 | 说明 |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

## 2026-06-17T10:59:35+09:00

**Summary**：ruyi — NixOS 部品（`services.ruyi`）、宣言的生成 `/etc/xdg/ruyi/config.toml` 及環境変数

| 提交 | 说明 |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

## 2026-06-17T10:03:05+09:00

**Summary**：ruyi — 新規 devShell 支援追加、`nix develop github:Kihara777/NixKits#ruyi` 環境入可能

| 提交 | 说明 |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

## 2026-06-17T09:48:33+09:00

**Summary**：ruyi 0.51.0-alpha.20260616 — RuyiSDK 包管理者、新包（Python / Poetry 構築、ruff + mypy + 320 単体試験 + 52 統合試験全通過）

| 提交 | 说明 |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 軟体名 | 新版 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

## 2026-06-17T07:37:39+09:00

**Summary**：write-maintenance-log 技能 — nixkits-check-updates 自保守記録書式変更抽出独立技能化；MAINTENANCE.md 再生成（動的名称 + 精密時刻 + LIFO + hash 省略）

| 提交 | 说明 |
|------|------|
| `b77170a` | docs(skill): re-apply flake.lock sync and build verification steps |
| `be2239b` | docs(skill): add .gitignore pre-check to flake.lock sync step |
| `704ebe4` | docs(skill): correct flake.lock pre-check — three-branch logic |
| `359fe29` | feat(skill): extract write-maintenance-log as standalone skill |
| `5187b07` | docs(skill): optimize write-maintenance-log triggers and add audit entry |
| `34bf34e` | feat(skill): add write-maintenance-log SKILL.md (zh) |
| `edce70f` | refactor(docs): switch MAINTENANCE.md to ISO 8601 precise timestamps |
| `fb6f1a5` | docs(skill): write-maintenance-log — add auto-discovery contract |
| `fe4b13f` | fix(docs): remove non-patch sections from MAINTENANCE.md |
| `d5318fb` | docs(skill): write-maintenance-log — add 使用 section |
| `e9e40f4` | docs(skill): add write-maintenance-log skill with trilingual docs |
| `c9dedf9` | docs(skill): write-maintenance-log — add en/ja skill docs |

## 2026-06-17T06:48:47+09:00

**Summary**：fix(mcp-searxng): 入口書類誤修正 — dist/index.js → dist/cli.js、MCP 伺服器正常起動可能

| 提交 | 说明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

## 2026-06-17T06:46:13+09:00

**摘要**: llama-cpp-rocm — builtins.fetchurl 代替 flake input 動的版取得試行（既撤回、方案不可用）

| 提交 | 说明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

## 2026-06-16T06:03:24+09:00

**摘要**: mcp-searxng 文書 — CodeWhale MCP 構成指南、常見罠警告（env 既定{}）、故障排查章節

| 提交 | 说明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

## 2026-06-16T05:20:34+09:00

**摘要**: nixos-modern-cli 技能 — Nix Store 路罠章節（gh auth setup-git 硬碼路失效診断汎用修正pattern）

| 提交 | 说明 |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

## 2026-06-16T04:56:06+09:00

**摘要**: opencode-telegram 0.21.2 — 上流修正及依存更新

| 提交 | 说明 |
|------|------|
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |
| `3b05a32` | docs(MAINTENANCE): record 2026-06-16 update (opencode-telegram 0.21.2) |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | source hash | `...` → `...` |
| 　 | npmDepsHash | `...` → `...` |

## 2026-06-15T17:32:16+09:00

**摘要**: codewhale 0.8.60 — 上流修正

| 提交 | 说明 |
|------|------|
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |
| `3cef0a8` | docs(MAINTENANCE): record 2026-06-15 update (codewhale 0.8.60) |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `...` → `...` |
| 　 | tui hash | `...` → `...` |

## 2026-06-14T08:11:16+09:00

**摘要**: comfyui-strix-halo 文書 — 線上統合 mode 説明 文件構造図

| 提交 | 说明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

## 2026-06-14T07:56:11+09:00

**摘要**: codewhale 0.8.59 — 若干 TUI 描画問題修正；mcp-searxng 1.4.0 — HTTP 伝送 mode 新規

| 提交 | 说明 |
|------|------|
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `ec7d5ca` | docs(MAINTENANCE): record 2026-06-14 updates (codewhale 0.8.59, mcp-searxng 1.4.0) |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
| 　 | cli hash | `...` → `...` |
| 　 | tui hash | `...` → `...` |
| 　 | source hash | `...` → `...` |
| 　 | npmDepsHash | `...` → `...` |

## 2026-06-12T18:17:52+09:00

**摘要**: llama-cpp-rocm 模块 — modelsPreset 支持復旧（nixpkgs 既削除）、名前空間 nixkits 移行、三言語移行指南

| 提交 | 说明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

## 2026-06-12T17:29:59+09:00

**Summary**：feat(llama-cpp-rocm): modelsPreset 支援復元（nixpkgs 既削除）、名前空間 nixkits 移行

## 2026-06-12T10:51:31+09:00

**摘要**: codewhale 0.8.58 — 上流修正；mcp-searxng 1.3.4 — 上流修正

| 提交 | 说明 |
|------|------|
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |
| `ef9daae` | chore(pkgs): bump mcp-searxng 1.3.4 |
| `716d98c` | docs(MAINTENANCE): record 2026-06-12 updates (codewhale 0.8.58, mcp-searxng 1.3.4) |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| mcp-searxng | 1.3.2 | 1.3.4 |
| 　 | cli hash | `...` → `...` |
| 　 | tui hash | `...` → `...` |
| 　 | source hash | `...` → `...` |
| 　 | npmDepsHash | `...` → `...` |

## 2026-06-11T05:28:59+09:00

**摘要**: 技能文書 — 維護記録格式規則系列（自動発見汎化、記述的標題、正確git commit時間印、禁止T00:00:00占位符）

| 提交 | 说明 |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

## 2026-06-11T05:13:39+09:00

**摘要**: other — 2件更新

| 提交 | 说明 |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

## 2026-06-11T04:52:16+09:00

**Summary**：codewhale 0.8.57 — TUI 新規追加；mcp-searxng 1.3.2 — 上流修復

| 提交 | 说明 |
|------|------|
| `543bcf9` | chore(pkgs): bump codewhale 0.8.57, mcp-searxng 1.3.2 |
| `7902bd1` | docs(MAINTENANCE): fix timestamps to exact commit times |
| `f92f9c4` | docs(MAINTENANCE): use descriptive titles instead of filename |
| `07f347f` | docs(skill): add descriptive title rule for MAINTENANCE files |

|--------|--------|--------|
| codewhale | 0.8.55 | 0.8.57 |
| mcp-searxng | 1.3.1 | 1.3.2 |
| 　 | cli hash | `sha256-jwn3rKD...` → `sha256-Hp0Z6mweaC+sB/BH2KpD1W/sdS0me69pErKiWOa2GqY=` |
| 　 | tui hash | `sha256-1Cxofu9...` → `sha256-dExfhrfGs1wbWWmvXYTuCGXKnkhD+7rBY32aV938Dz0=` |

## 2026-06-10T04:31:20+09:00

**摘要**: opencode-telegram — KillMode process変更、TimeoutStopSec 追加防止 shutdown 掛起

| 提交 | 说明 |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

## 2026-06-10T02:28:10+09:00

**Summary**：codewhale 0.8.55 — 上流修復；mcp-searxng 1.3.1 — 上流修復

| 提交 | 说明 |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

## 2026-06-08T15:12:39+09:00

**摘要**: 文書再構 — 地域化文件 docs/ 目録移入；MAINTENANCE.md 初回合列規則追加、純表格形式、完全提交歴史逆填

| 提交 | 说明 |
|------|------|
| `b3d7d0f` | docs: switch MAINTENANCE.md to table-only format, drop trilingual prose |
| `e4a3813` | docs: omit build status and unchanged hashes from MAINTENANCE.md |
| `4bf2d30` | docs(skill): add first-time package table format rule |
| `f7bb6ce` | docs(skill): merge version columns for first-time packages |
| `1a28625` | docs(MAINTENANCE): backfill full package history from repo creation |
| `b4742ad` | docs(skills): sync refined MAINTENANCE.md format rules to trilingual docs |
| `2f58ac5` | refactor: move localized README/MAINTENANCE files into docs/ |
| `551e6fd` | docs(skills): sync localized-file-in-docs/ rule and path updates |

## 2026-06-08T14:25:02+09:00

**Summary**：mcp-searxng 1.2.1 — 上流修復

| 提交 | 说明 |
|------|------|
| `07b1ee5` | chore(pkgs): bump mcp-searxng 1.1.0 → 1.2.1 |
| `db680df` | docs: add MAINTENANCE.md — software update changelog |
| `d4cb81f` | docs(skill): add Step 8 — MAINTENANCE.md update workflow |
| `5ba1361` | docs(skills): sync MAINTENANCE.md step to trilingual docs |
| `b8a98bc` | docs(skill): skip MAINTENANCE.md when no updates found |
| `2cd9daf` | docs: drop doc-sync line from MAINTENANCE; only record substantive rewrites |
| `b34ed08` | docs: add trilingual MAINTENANCE (en/ja) with language switchers |
| `e5e505e` | docs(skills): sync trilingual MAINTENANCE rule to skill docs |

|--------|--------|--------|
| mcp-searxng | 1.1.0 | 1.2.1 |

## 2026-06-08T14:22:25+09:00

**摘要**: rcc-fix — NixOS 模块（systemd 死鎖修正）

| 提交 | 说明 |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

## 2026-06-06T15:17:11+09:00

**摘要**: 技能文書 — 源変更後文書同期規範；comfyui-strix-halo C 道具鎖説明；hash 計算注意事項汎化；基本情報規則多言語統一

| 提交 | 说明 |
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

## 2026-06-06T13:58:47+09:00

**Summary**：codewhale 0.8.53 — 上流修復；mcp-searxng 1.1.0 — 上流修復；opencode-telegram 0.21.1 — 上流修復

| 提交 | 说明 |
|------|------|
| `300a9a6` | chore(pkgs): bump codewhale 0.8.53, mcp-searxng 1.1.0, opencode-telegram 0.21.1 |

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

## 2026-06-06T12:51:46+09:00

**Summary**：comfyui-strix-halo 修正 — ROCm 7.2 wheels 内蔵支援

| 提交 | 说明 |
|------|------|
| `e11f899` | fix(docs): add missing ja doc and en/ja README entries for comfyui-strix-halo |
| `48d842f` | docs(ja): add 基本情報 section to comfyui-strix-halo |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs in NixKits concise style |
| `8f16f91` | docs(skill): add length/structure rules from comfyui-strix-halo doc fix |
| `468b89a` | feat(skill): add patch-embedded version check for comfyui-strix-halo |

|--------|--------|--------|
| comfyui-strix-halo | 修正（ROCm 7.2 wheels 内蔵） |

## 2026-06-04T13:07:30+09:00

**摘要**: 技能体系 — SKILL.md 全面中国語化；三言語対称性確認規則

| 提交 | 说明 |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

## 2026-06-02T10:15:53+09:00

**摘要**: other — 7件更新

| 提交 | 说明 |
|------|------|
| `3be4889` | docs: add recover-nixos-config skill with multi-language docs |
| `fc5eca3` | docs: fix Skills section titles and generic agent descriptions |
| `d2e071f` | docs: add quantization levels to local model names |
| `22d206c` | docs: add UD- prefix to model quantization labels |
| `f15db79` | docs: add MIT license file and link from all READMEs |
| `218aeca` | docs: add local flake input example alongside remote |
| `4f0f968` | docs: fix local flake input syntax to match actual usage |

## 2026-06-02T08:49:47+09:00

**摘要**: opencode-telegram — 8件更新

| 提交 | 说明 |
|------|------|
| `8fe0b3d` | feat(opencode-telegram): add NixOS module with declarative config |
| `8fe3fae` | docs(opencode-telegram): simplify to flake module config only, remove manual systemd |
| `ee0a904` | docs(opencode-telegram): rename NixOS module → flake module |
| `a38e426` | docs(opencode-telegram): use accurate section name — service config, not module |
| `dea4dc6` | docs(opencode-telegram): show full flake.nix context in service config |
| `44975ed` | docs(opencode-telegram): flake module as section title, consistent across langs |
| `941eb48` | feat(opencode-telegram): auto-install package when module enabled |
| `2a8c41b` | docs(opencode-telegram): add first-time setup flow (opencode serve + config) |

## 2026-06-02T05:57:11+09:00

**Summary**：codewhale 0.8.49 — 上流修復；mcp-searxng 1.0.4 — 上流修復；obs-bilibili-stream 2.1.0 — 上流修復；opencode-telegram 0.21.0 — 上流修復

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

## 2026-06-02T03:42:25+09:00

**摘要**: nixos-modern-cli 技能 — POSIX 道具指南 nix 二進路提示

| 提交 | 说明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

## 2026-05-31T03:42:18+09:00

**摘要**: write-project-docs — 新技能（NixKits 風任意 project 多語言文書体系作成）

| 提交 | 说明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

## 2026-05-30T03:42:14+09:00

**摘要**: codewhale — stdenv 綴修正；llama-cpp-rocm 文書修正（内line連結削除、system.nix 完全 preset 使用）；opencode-telegram 初回設定流

| 提交 | 说明 |
|------|------|
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

## 2026-05-30T03:19:48+09:00

**摘要**: other — 2件更新

| 提交 | 说明 |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

## 2026-05-29T15:25:12+09:00

**Summary**：kitsfmt — 多修正（vendor 目録回復、冪等性、上書安全、with→builtins.attrValues 変換、--stdin 旗）；rcc-fix — D-Bus 熱挿抜検出書換；build — .vscode gitignore 範囲修正

| 提交 | 说明 |
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

## 2026-05-29T13:16:30+09:00

**摘要**: docs: codewhale 種別説明修正（事前構築済、非原始碼構築）

| 提交 | 说明 |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

## 2026-05-29T10:18:46+09:00

**Summary**：codewhale v0.8.47 — 新包

| 提交 | 说明 |
|------|------|
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |

|--------|--------|--------|
| codewhale | v0.8.47 |

## 2026-05-29T06:28:50+09:00

**Summary**：fix(kitsfmt): inherit 逗号、字下文字列破損、lambda 空白等多整形問題修復；冪等性修復

| 提交 | 说明 |
|------|------|
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |

## 2026-05-29T05:57:55+09:00

**Summary**：fix(build): .vscode gitignore 範囲過広 vendored crate 書類排除修正

## 2026-05-28T08:29:27+09:00

**Summary**：llama-cpp-rocm — NixOS 部品（systemd 砂箱上書）；opencode-telegram — NixOS 部品（宣言的設定、自動導入）；rcc-fix — visible 属性修復；技能文書 — 動的発見表現

| 提交 | 说明 |
|------|------|
| `3d2c38c` | docs(skill): nixkits-check-updates — dynamic discovery, not hardcoded list |
| `e5ee4ab` | docs(skill): remove hardcoded count from features, add exclusion note |
| `814731e` | docs(skill): sync ja doc with zh/en — dynamic discovery wording |
| `713b693` | fix(rcc-fix): use visible: property instead of if conditional for ScrollView |
| `34d309b` | docs(skills): add Install section with full 5-agent support to all skills |
| `2db934e` | docs(zh): simplify Skills description, remove semantic duplication |
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

## 2026-05-27T06:08:13+09:00

**Summary**：技能体系 — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三技能同期上線；llama-cpp-rocm 動的追跡説明

| 提交 | 说明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

## 2026-05-26T05:30:58+09:00

**摘要**: 文書 — README 節名改名（快速開始→追加、包→軟件、License→許可）

| 提交 | 说明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

## 2026-05-24T03:01:02+09:00

**摘要**: mcp-searxng 文書 — SearXNG + lighttpd 逆代理完全 NixOS 構成

| 提交 | 说明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

## 2026-05-22T06:45:11+09:00

**摘要**: llama-cpp-rocm — llama-cpp-ver flake 入力削除、nixpkgs 既定版使用

| 提交 | 说明 |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

## 2026-05-21T16:35:02+09:00

**Summary**：mcp-searxng v1.0.3 — 新包；opencode-telegram v0.20.5 — 新包

|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

## 2026-05-16T19:07:54+09:00

**摘要**: kitsfmt — match_ast! 宏構文誤修正、comments_before 関数簡略化、src 路修正

| 提交 | 说明 |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

## 2026-05-15T16:59:28+09:00

**摘要**: kitsfmt — rnix AST 基盤格式化 engine v0.3.0 書換；Cargo.lock 生成

| 提交 | 说明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |

## 2026-05-14T17:10:06+09:00

**Summary**：llama-cpp-rocm — 新包（動的追跡上流最新 Release）

| 提交 | 说明 |
|------|------|
| `9cb24a3` | llama-cpp MTP |

|--------|--------|--------|
| llama-cpp-rocm | 動的（構築時取得上流最新 Release） |

## 2026-05-14T07:38:08+09:00

**Summary**：kitsfmt — 新包（自建 Nix 整形器）；obs-bilibili-stream v1.0.0 — 新包

| 提交 | 说明 |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

## 2026-05-01T01:08:15+09:00

**Summary**：rcc-fix — 新包（asusctl 修正）

| 提交 | 说明 |
|------|------|
| `e2d09a2` | RCC-Fix |

|--------|--------|--------|
| rcc-fix | 追従 nixpkgs（上乗 + 修正） |

