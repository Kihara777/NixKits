# 維護記録

[中文](../MAINTENANCE.md) | [English](MAINTENANCE.en.md) | [日本語](MAINTENANCE.ja.md) | 偽中国語

## 2026-10-05T14:54:21+09:00

**摘要**：feat(skill): `write-maintenance-log` 概要 **markdown 清単** 排版 許可

- 「概要 概要 成」節 二種 排版 提示、**長 予算 同一**（合計 ≤ 400 文字）明記——清単 「多 書行」許可 非。各行 依然 「何 変更」 限定 回答
- 清単 送信表 **代替 非**：commit id 依然 `| 提交 | 説明 |` 限 出現
- 多言語同期：清単形式 **逐条翻訳、項目数 一致必須**（一項目 不足 翻訳漏、一項目 過剰 水増）
- 4c 検証節 実行可能 判定 追加（各言語 `grep -c '^- '` 相等）、当時 実際 踏 教訓 記載：**判定 緩 書過 不**

| 提交 | 説明 |
|------|------|
| `e2cb5ab` | feat(skill): 維護記録 概要 markdown 清単 許可；四語 document page 同期 |

## 2026-10-05T14:24:37+09:00

**摘要**：dsh-api-balance 薄包装 re-pin —— rev `911df2e` → `95fec42`（変更 其 提交 [`f39c816`](https://github.com/Kihara777/dsh-api-balance/commit/f39c816) 在；版本 `0.1.1` 之侭）。維護者 二度目 反饋 依 質問 dialog 漸隠 修正：下端 限定 自 **scroll 連動** 上下 漸隠 至（`none/start/end/middle` 状態機械、最上部 上端、最下部 下端 漸隠 不）；卡片 全体 非 上端 限定 漸隠（全体 mask 追従按鈕 淡 至）、按鈕下 切断内容 同色 埋 塞。判定：三状態 逐一 確認。

| 提交 | 説明 |
|------|------|
| `16f4fef` | fix(dsh-api-balance): re-pin to 95fec42 — scroll-aware fades in the question dialog |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重釘） |
| 　 | rev | `911df2e` → `95fec42` |
| 　 | src hash | `sha256-oc+TPbtuwItV43kskjpz18Ys2cTtCgceXAGrh0Q0D2c=` → `sha256-bRZWVKmv4nHow0TWMdMww/cFnP9A6vJ08sQCloaRpEE=` |

## 2026-10-05T13:58:51+09:00

**摘要**：dsh-api-balance 薄包装 re-pin —— rev `1f0af6c` → `911df2e`（変更 其 提交 [`4cf04a0`](https://github.com/Kihara777/dsh-api-balance/commit/4cf04a0) 在；版本 `0.1.1` 之侭）。維護者 screenshot 指摘 依 質問 dialog 下端「一刀切」解消：高 制限 題干 下端 `mask-image` 漸隠、追従按鈕 上 `::before` 漸変帯 敷、漸変色 注入時 卡片 実際 底色 自 取得（明 `rgb(255,255,255)` / 暗 `rgb(44,44,46)`；固定色 暗 露見）。判定：題干 下端 30px 平均輝度 59.93 → 45.92（約 23% 暗）、漸隠帯 之上（60–90px）不変。

| 提交 | 説明 |
|------|------|
| `e755381` | fix(dsh-api-balance): re-pin to 911df2e — fade mask at the question dialog's bottom |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重釘） |
| 　 | rev | `1f0af6c` → `911df2e` |
| 　 | src hash | `sha256-f3dg9oSbtKeYO6KzJZdpxz86gDUAI6vbRy8R3SSwroU=` → `sha256-oc+TPbtuwItV43kskjpz18Ys2cTtCgceXAGrh0Q0D2c=` |

## 2026-10-05T13:23:30+09:00

**摘要**：dsh-api-balance 薄包装 re-pin —— rev `f805f4e` → `1f0af6c`（変更 其 提交 [`e6d638c`](https://github.com/Kihara777/dsh-api-balance/commit/e6d638c) 在；版本 `0.1.1` 之侭）。維護者 反饋 依 二点：① 下部 統計条 横 scroll **廃止**（公式 0.2.0 各指標 click 可能 pill 化、設定行 置灰）；② 質問 dialog header 高 制限（≤40vh）自身 scroll、追従 廃止——長 題干 選択肢 隠 為。判定：本 package **build 産物** 対象 `develop/ab-ui` 実行（C2/C6「結果」層 至 変更）、稼働樹 `develop/check-deployed-artifact.py` 三特徴串 照合。

| 提交 | 説明 |
|------|------|
| `1548c4c` | fix(dsh-api-balance): re-pin to 1f0af6c — stats bar retired, question prompt no longer hides the options |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重釘） |
| 　 | rev | `f805f4e` → `1f0af6c` |
| 　 | src hash | `sha256-u1L1VHy86tOeB3iv3MhCdL0VAi8xpNUf2OJHAa/zndY=` → `sha256-f3dg9oSbtKeYO6KzJZdpxz86gDUAI6vbRy8R3SSwroU=` |

## 2026-10-05T07:45:26+09:00

**摘要**：CI 修正 —— 浮動入力 `llama-cpp-ver` 「認証付 取得 + 本地 上書」至 変更、`api.github.com` 之 403 制限 根治。該入力 **通常 URL 入力**、Nix `access-tokens` / `netrc-file` 此類 fetch 至 **付与 不**、故 各 job 之 未認証 request runner IP 共有 之 60 回/時 枠 尽（403）。現在 先 `gh api` 同一 JSON 取得、`--override-input llama-cpp-ver path:<json>` 以 Nix 至 渡：意味 不変（overlay `json.tag_name` 唯 読）、`tag_name` 欠落 **明示的 失敗**。`access-tokens` 残 —— 担当 `github:` 取源。

| 提交 | 説明 |
|------|------|
| `335dce9` | fix(ci): 浮動入力 llama-cpp-ver 「認証付 取得 + 本地 上書」至 |
| `e92cfe4` | fix(ci): 上書 parameter 空 場合 明示的 失敗 —— 未認証 取得 至 暗黙 退避 不 |
| `35eec1e` | docs: 実測 否定 之「access-tokens llama-cpp-ver 403 治」結論 訂正（AGENTS.md + 技能） |

## 2026-10-05T07:14:50+09:00

**摘要**：dsh-api-balance 薄包装 re-pin —— rev `8dab668` → `f805f4e`（変更 其 提交 [`f805f4e`](https://github.com/Kihara777/dsh-api-balance/commit/f805f4e4445cd4db6a3ccd16e23cfd90fb092208) 在；版本 `0.1.1` 之侭）。mobile「session 切替時 keyboard 不表示」**依然 効 不**：実際 `focusin` cancel 不可（当時 `preventDefault` 死 code）、軟 keyboard `focus` 瞬間 要求。入力欄 使用者 tap 以前 編集不可、tap / 按鍵 即時復帰、焦点 離脱 再武装。判定：session 切替中 編集可能 入力欄 至 focus 落下 回数 0（deploy 版 2）、`develop/ab-ui/` 本 package **build 産物** 対象。

| 提交 | 説明 |
|------|------|
| `a4b6bb1` | fix(dsh-api-balance): re-pin to f805f4e — mobile keyboard guard rewritten around the real causal chain |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 重釘） |
| 　 | rev | `8dab668` → `f805f4e` |
| 　 | src hash | `sha256-yM+rQb/xIuTiN6QGpWr++jd2vDGHoN5K4gHnLmkGB4A=` → `sha256-u1L1VHy86tOeB3iv3MhCdL0VAi8xpNUf2OJHAa/zndY=` |

## 2026-10-04T09:23:29+09:00

**摘要**：fix(dsh-preset-news-three-elements): 預設 插件 之 会話消息 来源 v4 形状 至 変更 —— dsh 0.2.0 之 会話格式 v4 字面量 `kind: "plugin"` 唯 拒、本 repo 預設 插件 其 丸写、故 消息 書 毎 准入 拒否、session 全体「本機実行失敗」至。三箇所 `{ kind: `plugin:${name}`, form: "notice", summary }` 至 変更（`news-language.js` ×1、`news-material.js` ×2）、test 断言 `source.plugin` 自 `source.kind` 至；更 自検 `session-sources`（`develop/check-session-sources.py`、`nix flake check` 接続）追加、「本 repo 預設 插件 `kind: "plugin"` 出 不」固定。

| 提交 | 説明 |
|------|------|
| `d27e6ce` | fix(dsh-preset-news-three-elements): 会話来源 v4 形状 至（自検 `session-sources` 追加 與 `nix flake check` 接続、四語 dsh 文書 v4 来源准入 節 追加、AGENTS 自検表 7 項 → 8 項 含） |

## 2026-10-03T09:49:14+09:00

**摘要**：dsh-api-balance 薄包装 re-pin —— rev `700fbbc` → `8dab668`（版本 `0.1.1` 之侭）。dsh 0.2.0 上 界面改善 逐項 確認 時、**静 失効** 二 件 発見 修正：① 下部 統計条 横 scroll **dsh 0.1.5 以降 効 不** —— 上流 style module 自 `StatsLine.module.css` `StatsPills.module.css` 至 改名、插件 旧名 唯 見 侭 設定 其 行 On 表示 侭；② 三 token 0.2.0 存在 不、内 `--dsw-alias-separator-primary` 18 箇所 境界線 担 **fallback 無**；現在 0.2.0 対応先 至 連鎖。判定：隔離実例 + Playwright（deploy 版 二項目 共 失効）。

| 提交 | 説明 |
|------|------|
| `18441ef` | chore(pkgs): re-pin dsh-api-balance rev（界面改进两项失效修复；版本仍 0.1.1） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再 pin） |
| 　 | rev | `700fbbc` → `8dab668` |
| 　 | src hash | `sha256-GEG3/ImXmo3BgO7AVh/rj1mIWsWMGB04Six+oIk9UIE=` → `sha256-yM+rQb/xIuTiN6QGpWr++jd2vDGHoN5K4gHnLmkGB4A=` |

## 2026-10-03T06:45:00+09:00

**摘要**：dsh-api-balance 薄包装 re-pin —— rev `76ea584` → `700fbbc`（変更 其 提交 [`cc89c43`](https://github.com/Kihara777/dsh-api-balance/commit/cc89c43) 在；版本 `0.1.1` 之侭）。**実行時挙動 之 修正**：① 回車交換 導入 部品 lifecycle 自 移出 —— dsh 0.2.0 之 chain slot `conversation.composer` 接管 時 環 部品 slot 與 共 卸载、交換器 静 外 為、現在 `apply()` 内 導入；② 面板 / 弾窓 材質 0.2.0 原生 配方 依 書直 —— `--dsw-specific-menu` 半透明 化 `backdrop-filter` 重 要 有、旧 配方 面板 真 透明 為。判定：Playwright computed style 実測。

| 提交 | 説明 |
|------|------|
| `6a8f68f` | chore(pkgs): re-pin dsh-api-balance rev（回车交换 + 面板材质修复；版本仍 0.1.1） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再 pin） |
| 　 | rev | `76ea584` → `700fbbc` |
| 　 | src hash | `sha256-7Yr9ALLN9hQTut5XziFLulmMde5GRgxTjBWidaxKqno=` → `sha256-GEG3/ImXmo3BgO7AVh/rj1mIWsWMGB04Six+oIk9UIE=` |

## 2026-10-03T06:15:29+09:00

**摘要**：維護日誌 之 **未訳条目** 補完：ja **80** 条、pcn **59** 条 —— 其 概要行 `**Summary**` 標記 + 英語 或 中国語 之 旧稿、内容 自体 亦 現行 zh 源 與 食違、故 zh 源 通 **行 毎 置換**。検査器 第 6 条 「**概要 標記 該 言語 自身 之 者 須**」 補、ja 之 `**Summary**` 與 en 之 `**概要**` 各自 反証 以 赤 転。**検証**：`nix flake check` 全緑；四語 各 358 条、ja / pcn 共 残留 0 条。

| 提交 | 説明 |
|------|------|
| `197099e` | fix(docs): 补齐 ja 80 条 / pcn 59 条未译条目，并修 pcn 一处错标签 |
| `44793f3` | feat(develop): maintenance-log 检查补第 6 条 —— 摘要标记须是本语的 |

## 2026-10-03T05:16:47+09:00

**摘要**：維護日誌 之 **倍率 判定 第二 特徴 補：反引号 占比** —— CJK 密度 限 則 過大 評価：密度 0.646 之 条目 密度 限 之 帯（n=34） 平均 **2.37** 以 「短」 判定、然 反引号 占比 加 最近隣（n=15） 平均 **1.98**、納品 之 1.95 其処 落。反引号 中身 逐字 写 故 占比 高 程 倍率 1 近；現在 「同構造 + 同密度 帯 比較」 改。**検証**：`nix flake check` 四語 全緑。

| 提交 | 説明 |
|------|------|
| `bad01c4` | refactor(skills): 倍率判据补第二个特征（反引号占比）—— 只看密度会高估，实测差 0.4 倍 |

## 2026-10-03T05:13:21+09:00

**摘要**：`blender-mcp` / `obs-bilibili-stream` 二 箇所 之 riscv64 除外、**理由 正**：「依存 連鎖 之 交叉 編譯 欠陥」 非、而 **主 依存 nixpkgs 側 以 該 構造 宣言 無**（`blender 5.2.2`、`obs-studio 32.2.2` 之 `meta.platforms` 何 也 riscv64 含 不、評価 段階 以 拒否）；判定 `pkgs.<dep>.meta.platforms` 而 **編譯 錯誤 非**。**検証**：`nix flake check` 四語 全緑。

| 提交 | 説明 |
|------|------|
| `e454504` | docs(pkgs): 两处 riscv64 排除的理由改准 —— 上游没声明该架构，不是「交叉编译缺陷」（四语） |

## 2026-10-03T04:53:28+09:00

**摘要**：`AGENTS.md` 之 配備 確認 判定 「書類 内容 見」 自 「**単元 参照 見**」 至 変更：dsh 0.2.0 起動 時 `cordis.patch.yml` 書換 故、書出 者 dsh 自身 之 直列化 結果、内容 以 比較 則 **偽陰性** 限 得、成功 之 配備 失敗 判定。新 判定、稼働 中 単元 pre-start 脚本 参照 之 store 路徑 與 現在 設定 生成 之 者 比較（二 指令 文書 記載）；本機 実測 一致。**検証**：`nix flake check` 全緑。

| 提交 | 説明 |
|------|------|
| `5df33e9` | docs(AGENTS): 部署核对判据换成「看单元引用」—— 原判据已失效：dsh 启动时会重写 cordis.patch.yml |

## 2026-10-03T04:43:18+09:00

**摘要**：**我 自身 導入 失守** 二 箇所 修正。**① 検査 「表 全体 消失」 見 不能**：`check-maintenance-log.py` 従来 四 条 何 也 総数 限 見、標題 與 概要 限 書 **提交 表 落** 也 通過；第 5 条 **構造 対等** 補（各 条目 之 提交 SHA 集合 四語 zh 與 一致 須）。**② 技能 内 書 倍率 判定 自体 誤**：全倉 平均（`en/zh` ≈ 1.84） 以 訳文 冗長 判定、而 実測 CJK 密度 與 倍率 之 相関係数 **r = 0.90** —— 同密度 帯 平均 2.29、「超過」 判定 之 条目 実際 帯 下回；平均 従 則 **内容 削** 事 強 之外 無。同密度 帯 比較 改。**検証**：`nix flake check` 全緑；検査 之 三 反証（表 全体 削除 / SHA 一 桁 改変 / 条目 全体 削除）全部 赤 転。

| 提交 | 説明 |
|------|------|
| `21993c8` | fix(develop): maintenance-log 检查补「结构对等」判据 —— 原有的四条只看总量，漏掉过「某条目在某译文里整张表都没了」 |
| `1c6e4be` | refactor(skills): 修正倍率判据 —— 全库均值混着 CJK 密度这个强混杂因子（实测 r=0.90） |

## 2026-10-03T04:38:34+09:00

**摘要**：`write-maintenance-log` **可測 之 長度 規範** 補、自作 四 条 之 概要 1674–3784 文字 自 312–444 至 圧縮：概要 「何 変 / 何故 / 如何 検証」 限 答、目標 ≤ 400 文字；**訳文 之 倍率 同構造 之 実測値 整合**（`en/zh` ≈ 1.84、`ja/zh` ≈ 1.21、明確 超過 則 水増）；「此 錯誤 何故 生」 説明 段落 此処 書 不。**検証**：`nix flake check` 之 四語 自検 全緑；四 条 共 圧縮 後 情報 欠落 無。

| 提交 | 説明 |
|------|------|
| `7d3fae0` | docs(MAINTENANCE): 摘要回归摘要 —— 压缩四条自撰条目（1674–3784 → 312–444 字符）并钉住长度与倍率规范 |

## 2026-10-03T04:27:03+09:00

**摘要**：`opencode-telegram` 之 riscv64 **「摘除」 自 「構築」 至 戻**、且 「**産物 真 実走 一 回**」 判定 追加：二 箇所 之 gyp 罠 修正（交叉 編譯器 指 之 `gcc` shim、`better-sqlite3` 明示 `--force_build=1`）；`build-package.yml` `smoke-test` 新設 —— 構築 後 `develop/qemu-smoke-tests/<包名>.sh` 走（本地 與 CI 同一 者）、脚本 無 也 binfmt 処理器 無 也 失敗 判定。**検証**：二 回 push 各 33 個 workflow 全部 success。

| 提交 | 説明 |
|------|------|
| `af82af7` | feat(ci): riscv64 产物改成「真的跑一遍」—— 修好两个 gyp 陷阱 + build-package 加 smoke-test 开关 |
| `16bcc25` | refactor(skills): 泛化「缓存假绿」与「构建成功≠产物能跑」—— 含 smoke-test 机制与反证要求 |
| `ab20373` | fix(opencode-telegram): 用构建平台的 node 跑 node-gyp —— PATH 上的 node 是 riscv64 的，x86_64 runner 上执行不了 |
| `ab4e884` | refactor(skills): 记下「本机构建条件比 CI 宽松」—— binfmt 在本地让 riscv64 二进制能跑，于是本地绿掩盖了 CI 缺陷 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | — | 版本 未変（0.26.2）；**構築 行列**：x86_64 + aarch64 → x86_64 + aarch64 + riscv64（且 riscv64 帯 qemu 煙試験） |

## 2026-10-03T02:26:58+09:00

**摘要**：`opencode-telegram` **riscv64 構築 摘除** —— 転緑 構築 修正 依 非、而 本来 使用 不可 能 之 平台 停止 構築 依：該 job **一直 緩衝 依 仮緑**（日誌 内 一 行 構築 也 無、産物 前 版 0.25.3）；真 構築 則 `better-sqlite3` 於 卡 —— **直接 依存** 且 **静的 import** 被、上流 riscv64 預編譯 無、v13 起 `install` 脚本 取消；産物 **構築 能、一 起動 即 抛**、故 `blender-mcp` / `obs-bilibili-stream` 之 同一 先例 按 摘除。**検証**：x86_64 / aarch64 影響 無。

| 提交 | 説明 |
|------|------|
| `b488bae` | fix(opencode-telegram): 摘掉 riscv64 构建 —— 上游 better-sqlite3 无 riscv64 预编译，产物能构建但一启动就抛 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | — | 版本 未変（0.26.2）；構築 行列：x86_64 + aarch64 + riscv64 → x86_64 + aarch64 |

## 2026-10-02T20:38:40+09:00

**摘要**：二 箇所 之 **判定 盲点** 與 一 箇所 之 **同名 衝突**：`doc-links` 之 切替器 判定 `docs/` 配下 必須 且 **全文** 検索 至 変更（旧版 `lines[:8]` 限 見、「行 全体 削除」 與 「第 8 行 以降」 何 也 静黙 通過 —— 四 份 之 `docs/*/ruyi.md` 一 度 也 検証 無）；預設 組合 記述 技能 之 副本 自前 持 不 形 至（上流 與 **同名 且 内容 分岐**、上流 之 者 掛 断言 以 固定）；persona 之 陳腐化 記述 除去。**検証**：`nix flake check` 全緑；預設 使捨 `0.2.0-rc.2` 実例 至 投入、**9 条目** 之 **`broken`** 全 空。

| 提交 | 説明 |
|------|------|
| `fa0beff` | fix(develop): doc-links 的切换器判据补上盲区 —— docs/ 下强制存在、全文查找 |
| `1e85409` | refactor(dsh): 预设不再自带组合撰写技能副本 —— 改挂上游那份，并去掉已过期的 persona 说法 |

## 2026-10-02T19:54:49+09:00

**摘要**：dsh **0.2.0-rc.2** —— 二 通道 共 世代 跨（0.1.x → 0.2.x）、且 **Agent 預設 移行 之 落地** 完了：実測 `alpha` `latest` 比 低（`latest` = `next` = `0.2.0-rc.2`）、故 `dsh-alpha` `next` 至 追随；両 通道 同一 tarball 指 且 hash 與 lock 共用。0.1.x 之 目録式 預設 上流 全体 削除、旧 格式 新設 之 rev 釘 包 提供。部品 `passthru.dshChannel` 以 二択、`preset.patch.yml` **逐字**、生成 之 `cordis.patch.yml` 至 差込 形 変更；旧 settings 鍵 断言 以 止。**検証**：四語 之 自検 全緑；使捨 実例 実走 預設 與 技能 根 之 解決 確認。

| 提交 | 説明 |
|------|------|
| `e4bcdee` | chore(pkgs): dsh 两通道升到 0.2.0-rc.2 —— alpha 改跟 npm next，两通道共用一份 vendored lock |
| `2b37ba5` | feat(dsh): 预设内容来源分叉 —— stable 冻结在钉住的 rev，alpha 跟仓库 HEAD |
| `b20a4c3` | refactor(presets): 预设迁到 0.2.0 单格式 patch 行（nixos / maintenance / news-three-elements） |
| `1fd1768` | feat(dsh): 模块按 0.2.0 接线预设与宿主面 —— patch 行播种、agent-preset-registry、node_modules 双链接 |
| `b5a767a` | docs(dsh): 四语文档同步 0.2.0 —— 通道语义、预设格式、宿主命名空间（四语） |
| `4758b05` | docs(AGENTS): 预设一节重写为 0.2.0 单格式与取用点分叉 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh | 0.1.5-rc.2 | 0.2.0-rc.2 |
| dsh-alpha | 0.1.6-alpha.2 | 0.2.0-rc.2 |
| 　 | npm tag | `alpha` → `next` |
| 　 | src hash / npmDepsHash | 再計算；両 通道 同一 tarball ⇒ vendored lock 一份 共用（`dsh-package-lock-alpha.json` 削除） |
| dsh-nixos-shell-stable | 新規 追加 | 釘 `0175f85` 之 預設 内容 変体（`presetsSource` 引数 + `passthru`） |
| dsh-preset-news-three-elements | 0.1.0 | 0.2.0 |

## 2026-10-02T18:02:46+09:00

**摘要**：feat(dsh): 預設 移行 之 準備 —— 0.2.0 之 新形式 `preset.patch.yml` 與 派生 検査 之 適応（四言語）：預設 目録式 `agent.cordis.yml` 自 一本 之 loader patch 条目（`- insert:` → `@deepseek-ai/dsh-agent-preset`） 至 変更、落点 `$DSH_HOME/profiles/<profile>/cordis.patch.yml`；26 包 之 schema 拡張 単位 照合、6 箇所 之 変化 全部 新規 之 任意 field；「其 侭 写 則 壊」 三 箇所 修正（`baseUrl` 当該 profile 目録 指 様 変更、metadata `config.name` / `description` 至、`config.order` 新 key）。**検証**：使捨 0.2.0 実例 之 7 条目 預設 以 `broken` 全 空；反証 一行 限 変 各自 具体 之 `broken` 報告。

| 提交 | 説明 |
|------|------|
| `3f92bb1` | feat(dsh): 预设迁移准备 —— 0.2.0 新格式 preset.patch.yml + 派生检查适配（四语） |

## 2026-10-02T17:39:30+09:00

**摘要**：feat(dsh): 宣言的 設定面 之 補完 —— 構造化 option 7 → **13**、型別 namespace 6 新設（`permission`、`web-search-deepseek`、`agent-presets`、`subagent`、`shell`、`llm-deepseek`）——「誤記 與 範囲外 実行時 静黙 破棄」 至 **求値期 之 誤謬** 変更；併 既存 判断 三 箇所 修正（namespace 総数 **12 → 15**；「`shell.cwd` 既定値 無 ⇒ 部分宣言 不可」 誤；「typo 與 範囲外 何 也 静黙」 半分 限 正）。**検証**：最小 之 NixOS 設定（13 段 全部 有効 + 逃生口 以 1 箇所 上書） 求値 通過、生成 之 `settings.yaml` 全 新設段 含 且 `builtins.fromJSON` 以 解析 可能、負例 各自 求値期 誤謬；`nix flake check` 全緑。

| 提交 | 説明 |
|------|------|
| `0f12640` | feat(dsh): 声明式设置面补全 —— 新增 6 个类型化 namespace（13 个结构化选项，四语） |

## 2026-10-02T17:33:52+09:00

**摘要**：godot-ai 4.1.0 → 4.2.3 — fail-closed 之 pin 表 9 項 自 14 項 至（`mcp` 1.29.1 → 2.2.0、`fastmcp` 3.4.7 → 4.0.5、更 `mcp-types` 等 新規追加）

- `mcp-types` nixpkgs 於 存在 不 故、上流 同一 倉庫 之 `src/mcp-types/` sub project 自 定義 取得
- 二 overlay 之 `python312.override { packageOverrides = …; }` 連鎖 `.extend` 於 互 置換、上書 静 破棄 侭 構築 成功；現在 `pythonPackagesExtensions` 使用
- 判定：構築 通過、`godot-ai --version` 実行 4.2.3、`importlib.metadata` 14/14、`nix flake check` 全緑

| 提交 | 説明 |
|------|------|
| `32bcf22` | chore(pkgs): godot-ai 4.1.0 → 4.2.3 —— 依赖表 9→14、mcp 2.2.0、fastmcp 4.0.5、新增 mcp-types（四语） |
| `828af9c` | refactor(skills): 泛化链式 overlay 的替换语义陷阱（改用 pythonPackagesExtensions） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| godot-ai | 4.1.0 | 4.2.3 |
| 　 | 実行時依存 pin 表 | 9 項 → 14 項 |
| 　 | src hash / overlay 掛方 | 再計算；両 overlay 重 合 可能 方式 至 |

## 2026-10-02T17:09:33+09:00

**摘要**：feat(skills): 更新確認 「push 後：CI 構築 検証」節 新設（四言語）— local 構築成功 CI 緑 意味 不：local Binary cache 命中 得、且 現行 架構 限 覆；多架構 包 場合、他方 検証 可能 者 CI 限。判定 三：全 `status` `queued`/`in_progress` 離 迄 待、`--commit` 以 絞、失敗 必 log 原文 見。先 分類 後 動：rate 制限 與 揺 偶発、hash 不一致 與 lock 不自洽 真 失敗、単一 架構 赤 判定保留、且「全緑 然 log `copying path … from cache` 尽」可疑——CI 通 事 CI 構築 事 非。失敗時 全 失敗項 與 其 性質 一度 示、再実行・修正 後 commit 追加・該 batch 巻戻 選択肢 至、「修正 不 緑 迄 再実行」禁。適配層 本 倉庫 之 形態（`build-package.yml` 骨組、包×架構 毎 一 workflow、`ci-summary.yml` 徽章）與 実測 四 失敗形態 記録。

| 提交 | 説明 |
|------|------|
| `6ff84e3` | feat(skills): 更新检查新增「推送后验证 CI 构建」环节（四语） |

## 2026-10-02T17:03:13+09:00

**摘要**：codewhale 0.9.13 → 0.10.0；ruyi 0.52.0 → 0.53.0；mcp-searxng 2.3.0 → 2.5.0；opencode-telegram 0.25.3 → 0.26.2 — 四言語 文書 同期

- `dsh` 0.2.0-rc.2 與 `dsh-alpha` 0.1.7-alpha.2 暫緩：hash 與 構築 通過、但 預設 mount 検証 通 不——`agentPresets/list` 之 roster 內 何 也 出現 不；対照実験 識別力 有 但、形式 之 非互換 與 探針 `DSH_HOME` 不足 未 区別 可能
- fix(dsh): `postPatch` 「`devDependencies` 自 文件末尾 至 截断」自 按塊 照合 + 末尾 comma 修復 至 変更——0.2.0-rc.2 以降 `exports` 其 後 至 来 故、旧 写法 則 其 共 削除（導出 失効 然 構築 成功）；二 実 tarball 以 解析 可能 事 離線 検証

| 提交 | 説明 |
|------|------|
| `16216d5` | chore(pkgs): 上游更新 —— codewhale 0.10.0 / ruyi 0.53.0 / mcp-searxng 2.5.0 / opencode-telegram 0.26.2（四语文档同步） |
| `63e71cd` | fix(dsh): postPatch 按块删 devDependencies —— 0.2.0+ 的 exports 不再被误删 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.9.13 | 0.10.0 |
| 　 | cli / tui hash（x64、arm64） | 四値 全部 再計算（cli 與 tui 同値） |
| 　 | codewhale-src `src` hash | `sha256-AYs2v/…` → `sha256-SsN/p+…`（Cargo.lock 7266 行 同期） |
| ruyi | 0.52.0 | 0.53.0 |
| mcp-searxng | 2.3.0 | 2.5.0 |
| 　 | src hash / npmDepsHash | 両者 再計算 |
| opencode-telegram | 0.25.3 | 0.26.2 |
| 　 | src hash / npmDepsHash | 両者 再計算 |

## 2026-10-02T16:26:56+09:00

**摘要**：feat(skills): 更新確認 「第 0 步」 新設——着手前 `git fetch` 以 遠端 整列、未閉 issue / PR 確認（四言語）— issue 「既知 之 故障」之 集合、PR 「在途 之 作業」之 集合、此 工程 取得 経路 之 自検 也 前倒。`gh` 明示的 非零 終了 故、「空 list」「真 無」意味 命令 成功 時 限。commit 前 自検 九問 自 十問 至 拡張、第 10 問 維護者 之 要求 依 着手前 動作 在 事 正直 標記（第 1〜9 問 実測 之 再実行 之 産物）。適配層 本 倉庫 之 座標、`has_issues=true`、0 未閉 issue / PR、四 実例（PR #6 SHA 固定 action、PR #7 本 倉庫 之 包 更新、PR #4 / #5 `/tts` 之 SSRF 修正 導、issue #3 技能分割 之 契機）補、二箇所 之 不正確 併 修正。

| 提交 | 説明 |
|------|------|
| `c10de09` | feat(skills): 更新检查新增第 0 步 —— 开工前同步远端并核对活跃 issue / PR |

## 2026-10-02T03:54:38+09:00

**摘要**：fix(dsh): image modality 記述 訂正（四言語）— 前回 之 記録 `deepseek-flash` 「唯一 image modality 宣言 flash 項目」至 称、其 断定 両 channel 至 拡。store 内 二 構築済 成果物 実査 則、stable `0.1.5-rc.2` 與 alpha `0.1.6-alpha.1` 各自 `inputModalities: ["text","image"]` 宣言 項目 二 持（`deepseek-flash`、`deepseek-v4-flash-vision-exp`）、一条 者 alpha `0.1.6-alpha.2` 限。変更内容：理由 「三 目録 全部 収録、何 也 image modality 宣言 唯一 之 id」至 改、目録表 該 列 追加；低下時 之 警告 二経路 至 訂正——新規 添付 画像 `session/prompt` 之 添付准入 於 `MODEL_DOES_NOT_SUPPORT_IMAGES` 至 拒否、履歴 之 画像 限 無言 置換。既定値 変更 不

| 提交 | 説明 |
|------|------|
| `067b296` | fix(dsh): 更正 image 模态断言 —— stable/alpha.1 目录实有两条声明（四语） |

## 2026-10-02T03:01:23+09:00

**摘要**：fix(dsh): 既定模型 `deepseek-flash` 至 移行（四言語）— 上流 2026-09-10 於 V4 Flash 與 V4 Flash Vision Exp 廃止、模型名 `deepseek-flash` 與 `deepseek-v4-pro` 至 収束。dsh 之 目録 版 至 追随：stable `0.1.5-rc.2` 與 alpha `0.1.6-alpha.1` 四条、alpha `0.1.6-alpha.2` 二条。旧 既定値 `deepseek-v4-flash` alpha 之 目録 於 存在 不、目録外 之 id 文本専用 模型 至 扱 故、画像 `projectImagesForTextModel` 依 無言 文本記述 至 置換——誤謬 不出、模型 也 画像 未見。変更内容：既定値 `deepseek-flash` 至 変更、option 説明 目録 版 至 追随 事 明記；四言語 `dsh.md` 例 id 同期、当該 節 與 降下 之 警告 追加

| 提交 | 説明 |
|------|------|
| `2ab7dda` | fix(dsh): 默认模型改用 deepseek-flash —— 上游 09-10 下线旧 id（四语） |

## 2026-09-28T13:07:06+09:00

**摘要**：dsh-api-balance 0.1.0 → 0.1.1 —— 薄包装 之 座標同期（子 repo 維護記録 無、変更 同 repo 之 commit [`76ea584`](https://github.com/Kihara777/dsh-api-balance/commit/76ea5847c3e3f8e639b01abbfd8901fa71d6c177) 参照）。音色 「**実際 話 変体**」 以 選 至 変更：旧実装 主言語 之 前方一致 以 最初 之 音色 取、広東語 `zh-HK` 與 普通話 `zh-CN` 同 `zh` 属、故 音色一覧 広東語 先 来 系統 必 普通話 text 広東語 以 読——然 文書 與 界面 亦 正、音 聞 限 気付 不能。現在 変体 毎 之 分類 與 並替、発声 前 音色一覧 待、`utter.lang` 與 選択 音色 一致、実際 使用 音色 示 「音色」設定 追加。判定：子 repo 之 `test/voice-selection.test.mjs`（25 assertion、反証 含）與 実 browser 実測。

| 提交 | 説明 |
|------|------|
| `a4e6d54` | chore(pkgs): bump dsh-api-balance 0.1.0 → 0.1.1（音色按话的变体选择） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 0.1.0 | 0.1.1 |
| 　 | rev | `c47f857` → `76ea584` |

## 2026-09-28T08:28:27+09:00

**摘要**：refactor(skills): 本日 之 預設事故 「別 之 nix flake 倉庫 於 亦 成立 可」 判定 以 二層 技能 至 汎化 —— ① 汎用技能 `nix-flake-update-check` 之 commit 前 自検 八問 自 九問 至 増、「『検証 済』 失敗 発生 層 於 検証 為 可？判定 自身 失敗 可能 可？」追加：決 鳴 不 判定 「問題 無」 與 「何 亦 測 不」 区別 不能、救済 **既知 壊 夹具** 反証 以 添 事。② 本 repo 適配層 `nixkits-check-updates` 新節：插件 改名/削除 文書 而已 之 問題 非、二 預設 **実際 壊**——組合行 package 名 以 内蔵插件 参照、dsh ≤ 0.1.6-alpha.1 解決不能 行 黙 無視、≥ alpha.2 硬失敗 預設 全体 mount 不能。同節 更新 前 之 二層 判定（offline 行解析 + 上流 `broken` field 読 権威 実 mount）與 seed-once 播種 之 帰結 示。自検 番号 至 参照 三箇所 亦 同期更新。

| 提交 | 説明 |
|------|------|
| `c5022ea` | refactor(skills): 预设事故泛化 —— 通用技能加第 9 问，适配层加插件改名陷阱 |

## 2026-09-28T08:04:31+09:00

**摘要**：fix(dsh-nixos-shell): 預設行 `workflow-ptc` 至 変更 —— dsh 0.1.6 内蔵插件 `dsh-workflow-worker-thread` 改名、旧名 ≤ alpha.1 黙 無視、alpha.2 以降 預設 全体 mount 不能。

- `nixos-mode` / `maintenance-mode` 組合行 與 `editing-cordis-compositions` 技能 例 同時 改名、`config` 逐字 不変
- 検証 **build 産物** 実際 mount 方式 至：臨時 dsh `agentPresets/list` 呼 上流 `broken` 判定 読、更 故意 壊 夹具 反証 以 混
- 同 罠 `docs/*/dsh.md` 記載（四語）、`AGENTS.md` 本機展開 前提 `path:` 輸入 非 GitHub 参照 至 修正（先 push 後 再鎖、再鎖 浮動子入力 亦 再解決）

| 提交 | 説明 |
|------|------|
| `c92e980` | fix(dsh-nixos-shell): 预设行改用 workflow-ptc（旧名在 0.1.6 已不存在） |
| `7a12ff2` | docs(dsh): 记录 0.1.6-alpha.2 插件改名硬失败陷阱（四语） |
| `5364ef1` | docs(agents): 修正本机部署前提（GitHub 引用而非 path 输入）+ 重锁的副作用 |

## 2026-09-24T05:45:11+09:00

**摘要**：① `fix(pcn)` 偽中国語 内 残留 仮名 4 箇所 除去、`check-maintenance-log` 與 `check-doc-links` `exit 0` 至 復帰。② `feat(dsh)` 構造化 settings 選項 6 件 追加（`agent-loop`、`subagent-model-selection`、`locale`、`ui-theme`、`ui-chat`、`ui-conversation`）：従来 `agent-default-model` 唯 構造化 選項 有、残 無型 `settings` 経由 而已（誤 静 schema 既定値 至 戻）；`shell` `cwd` schema 既定値 無 故 意図的 提供 不。併 文書 中 之 `0.1.5-rc.2` 自 転記 namespace 表 5 行 訂正。判定：6 検査 全 緑、四言語 構造 対等、6 項 全部 有効化 生成 settings.yaml 6 新節 含。

| 提交 | 説明 |
|------|------|
| `d2e8c10` | fix(pcn): 剔除偽中国語残留假名 —— 恢复 CI 绿灯 |
| `55cbdbd` | feat(dsh): 6 个新结构化 settings 选项 + 修正 namespace 表（四语） |

## 2026-09-23T08:27:16+09:00

**摘要**：refactor(preset): 維護模式 prompt 「汎用方法 + 本倉適配層」至 分割 —— `maintenance-skills` 従来 NixKits 工作流 全体 公開預設 内 直接記述、`skills/` 既存 之 分法（`nix-flake-update-check` 汎用 ← `nixkits-check-updates` 本倉適配）與 矛盾。現在 `maintenance-workflow`（序号 901、汎用：分割 commit、push 後 記録、文書 與 code 同期、修正 之 技能 至 汎化）與 `maintenance-workflow-repo`（序号 902、本倉 約束：四言語 與 `docs/zh/` 基準、`write-maintenance-log` 準則、項目数 一致 判定）。判定 「此 規約 他 倉庫 於 亦 成立 可」 唯一。汎用層 本倉 固有 之名 出現 不。新 選項 `repoWorkflow: false` 汎用層 唯 残 可能。四言語 文書 同期。

| 提交 | 説明 |
|------|------|
| `78fb91b` | docs(modes): 维护模式提示词分层 —— 通用方法 + 本仓适配层（四语） |

## 2026-09-22T16:23:33+09:00

**摘要**：docs(skill): 「起動器設定 命令式改変 不可」事故 `nixos-specialisation-tuning` 至 記録 —— `extraInstallCommands` Limine 之 **哈希固化 後** 於 `limine.conf` 之 `default_entry` 改写、哈希 不一致 以 Secure Boot 下 **系統 起動不能** 至。技能 二節 追加：`### 引导菜单与默认面`（設定 宣言式 必須、変更前 install script 読 「file 書込 → 検証/署名」 之 順序 洗出、固化後 変更 上流 與 byte 単位 同一 之 算法 以 再固化 必須）與 面切替 之 二 運行級 障害（判定 `is-active` 非 `default.target` 之 解決値 用；`user@<uid>.service` 面 跨 全体 再起動 必要、「合成器 存在」 以 「桌面 正常」 視 不）。frontmatter `description` 與「适用场景」亦 同期更新。

| 提交 | 説明 |
|------|------|
| `8c276c0` | docs(skill): 「起動器設定 命令式改変 不可」事故 記録 —— 我 導入 起動不能 障害 |

## 2026-09-22T09:37:07+09:00

**摘要**：fix(ci): `ci-summary` `head_sha` 以 絞込、README 徽章 之 `failing` 誤報 修正 —— 本 workflow push 起動 故 同一 push 之 構築 未完了時 走、query commit 限定 無 場合 前回 push 之 失敗実行 読（実例：`Build dsh-preset-news-three-elements (aarch64)` run#157）。他 二点：`curl` 於 `--fail` 追加、request 失敗時 既存徽章 保持 `exit 1` —— 従来 403 制限 返 JSON error 本体 以 `FAILED` 空 至、静 `passing` 書。判定：新 jq logic 現在 HEAD 対 実行 出力 空（=> passing）、31 之 Build workflow 全緑 一致。今回 外部 自 変更 `gh-pages` 上 之 徽章状態 唯一、main branch 之 source 第三者 変更 無。

| 提交 | 説明 |
|------|------|
| `7fc4a14` | fix(ci): ci-summary 按 head_sha 过滤，修正徽章误报 failing |

## 2026-09-20T17:56:28+09:00

**摘要**：refactor(skill): 監査後、8 件 之 汎用技能 倉庫／役割特指 一括汎化。

- `write-maintenance-log`：「AGENTS.md 依 強制起動」 条件式 変更；SUBTITLE 之 `NixKits 软件更新维护日志。` `<项目名>` placeholder 変更（逐字置換 故、其 侭 使用 他 project 名 書込）
- `write-project-docs`：「root 中文 唯一」 反 pattern 表 之「言語 list 直書」 矛盾 故「基準言語 倉庫 定」 変更
- 切替 validator 言語集合 之 動的発見 変更（`docs/zh|en|ja|pcn` 與 `/5` 直書）；`translate-pseudocn` 之 壊 script 書直
- 技能間 hard 参照 単独 成立 表現 至；工程数 記載 実際 之 9 步 一致；子倉庫 例 與 `kits/` 自 特指 除去
判定：書直 二 検証 script 実行 通過（故意 壊 link 注入 逆検証 含）、`nix flake check` 全通過。

| 提交 | 説明 |
|------|------|
| `dac80a7` | refactor(skill): 全面泛化通用技能中的仓库/角色特指（审计后批量修复） |

## 2026-09-20T17:41:07+09:00

**摘要**：refactor(skill): 外部自働化 與 Actions 検査 之**適用対象** 汎化 —— NixKits 又 単一 維護者 視点 指 非。技能 他者 渡 再利用可能 成果物 有、読者 別倉庫 之 貢献者 又 引継者 可能性 有、従来 之 書方 「自分 関係 無」 読。`traps.md` 二節 新設：SHA 固定 共通 之 選択 有、其 副作用（通知 届 無）採用者 継承；基準 **「自力実装 可」 且 「誰 使用」 非**（維護者／貢献者／監査者 適用時期 列挙）。加 非維護者 之 action 昇格 也 PR 行 旨。第 2 步 與 `builders.md` 一般 場合 記述、第 8 步 「適配層 指定」 変更、汎用技能 自 適配層 至 直書 path 参照 削除。判定：`nix flake check` 全通過。

| 提交 | 説明 |
|------|------|
| `23e11a5` | refactor(skill): 泛化外部自动化与 Actions 检查的适用对象（不再特指某个仓库） |

## 2026-09-20T17:28:32+09:00

**摘要**：fix(skill): `nix-flake-update-check` 之 三 欠陥 修正、何 也 「錯誤 出 非、唯 取落」型。

- 固定 SHA 之 Actions 検査 到達不能：`traps.md` 手順 有 且 `SKILL.md` 何 段階 自 参照 無；第 2 步 節 追加、検査項目 八問 拡張、目次 「毎回」 明記
- 版本発見 `version\s*=` 故 parameter 化 `version ? "0.1.5-rc.2"`（`packages/dsh.nix`）一致 不、当該 包 検査範囲 自 消；`version\s*[?=]` 変更
- 生 `curl` `api.github.com` 上限 使切 錯誤 出 非 空 返、下流 grep 同様 沈黙、全 包 「最新」 判定；`gh api` 統一 `ERROR:` 分岐 追加
判定：`nix flake check` 全通過；新 flow 初回実行 本倉庫 之 3 action 計 6 箇所 逐一 SHA 照合、全 最新 確認。

| 提交 | 説明 |
|------|------|
| `34368c1` | fix(skill): 接入 Actions 检查、修正版本发现启发式、取数改用 gh api |

## 2026-09-20T17:05:51+09:00

**摘要**：定例更新検査 —— `opencode-telegram` 0.25.3（npm 包、source hash 與 npmDepsHash 更新、構築通過）；`ruyi-alpha` 0.54.0-alpha.20260918（薄包装、version 與 hash 唯変更、三 channel 共有 之 base 未変更）。同 実行 以 stable channel 之 被検査 12 包 確認、上流 遅延 上記 二 件 唯一。alpha channel 之 文書 之 pytest 件数 346 単体 / 57 統合 自 462 単体（xfailed 1 件 含）/ 70 統合 至 更新、四言語 之 文書 同期。

| 提交 | 説明 |
|------|------|
| `1711331` | feat(pkgs): opencode-telegram 0.25.3 + ruyi-alpha 0.54.0-alpha.20260918 |
| `14e565e` | docs: 同步 opencode-telegram 0.25.3 与 ruyi-alpha 0.54.0-alpha.20260918（四语） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.25.2 | 0.25.3 |
| 　 | source hash | `sha256-wNM/QNtFaRaColS2MGqk2p94NpVeHXoqJ26RjNRVypU=` → `sha256-XVIsT9mQuagF3DDLwlXomihfpBJLZ6OfJHzBGLM9lXM=` |
| 　 | npmDepsHash | `sha256-NnvFOrS7Y7NFYoS/lWTb3tTs5xwHhzDLTzkdGN+f3vw=` → `sha256-lLl6AobcB/Zi9aw463iv1MMAPah+RV/GtrF0nK6X1Q0=` |
| ruyi-alpha | 0.52.0-alpha.20260714 | 0.54.0-alpha.20260918 |
| 　 | source hash | `sha256-x6DGsnGgeClKXsS1kXP+3nIYGG2hJhyk6J1ENE2VD8s=` → `sha256-6XSVQuU+szU8CnijgAwQa1XmoHgpk/vHW6tmWP5dkpQ=` |

## 2026-09-19T14:13:43+09:00

**摘要**：「文書 載 不 内容」之 確認 以 構造的 欠落 一 件 補完：`nix flake check` 之 七 件 之 自検（自検契約、何 失敗 以 commit 阻止）従来 一 箇所 集 説明 無、`flake.nix` 之 comment 散在、`AGENTS.md` 二 件 触 限定。`AGENTS.md` 之 `## CI` 節 ① 七 件 自検一覧表（検査名 / script path / 検証内容）、② CI 之 `access-tokens` host 照合 落穴（`check.yml` `api.github.com` 欠、浮動入力 `llama-cpp-ver` 未認証 化 上限 使切）追加。検証：七 path 全部 実在、`nix flake check` 全通過。

| 提交 | 説明 |
|------|------|
| `7766b88` | docs(agents): nix flake check 七 件 自検一覧 與 CI `access-tokens` 落穴 補完 |

> **説明**：`AGENTS.md`（本身 代理 agent 向 取決 file、user 文書 非）変更。

## 2026-09-19T14:05:38+09:00

**摘要**：fix(ci): `check.yml` 之 `access-tokens` `api.github.com` 欠。同時 子 repo `dsh-api-balance` 四言語 `SECURITY.md` 追加。

- CI：浮動入力 `llama-cpp-ver` 従来 未認証 取得（六十 回/時 之 上限 push 毎 ~三十四 workflow 使切）。両 host 記載 後 三十三 workflow 全部 success、403 零。入力 浮動 侭 `flake.lock` 書 不
- 子 repo 安全政策：scanner 之 PR #4 / #5「rate limit 欠如」「request body size 上限 欠如」共 誤検知 判定、code 変更 不
- 主 repo 四言語 `SECURITY.md` 之「同 子工程 未 政策 整備」記述 「整備済」 至 訂正、子 repo 文書 至 link

| 提交 | 説明 |
|------|------|
| `d224b18` | fix(ci): check.yml `access-tokens` `api.github.com` 欠落（403 根本原因） |
| `2cce37b` | （子 repo dsh-api-balance）docs(security): 四言語 SECURITY.md 追加 |
| `39c9f10` | docs(security): 子 repo 政策 整備済 化——古「未整備」記述 訂正（四言語） |

> **説明**：`d224b18` `.github/workflows/check.yml` 変更、`39c9f10` 四言語 文書、子 repo commit 其 repo 記録。

## 2026-09-19T07:51:05+09:00

**摘要**：技能文書 四 篇（`nix-flake-update-check` / `nixkits-check-updates` / `write-project-docs` / `translate-pseudocn`）確認、三 件 修正（四言語）。

- `nix-flake-update-check`：文書 主 flow 1〜10 step 記載、但 `SKILL.md` 実際 step 9 至。step 10（締）適配層 `nixkits-check-updates` 定義
- `write-project-docs`：付属 file `templates.md`（209 行）`SKILL.md` 宣言 無 —— 付属表 與 目録形式 path 補完
- `translate-pseudocn`：辞書 項目数 13 実測 75 訂正、`dictionary.md` 付属行 追加
- 照合：`news-three-elements` 付属宣言 元 正確

| 提交 | 説明 |
|------|------|
| `c9c9c0c` | fix(docs): nix-flake-update-check 技能文書 步骤数 誤（四言語） |
| `7f7363f` | fix(docs): write-project-docs 配套書類 templates.md 宣言 不（四言語 + SKILL.md） |
| `cef09fe` | fix(docs): translate-pseudocn 辞書 項目数 與 配套書類 不正確（四言語） |

> **説明**：`7f7363f` `skills/write-project-docs/SKILL.md` 変更 含（技能 snapshot `check-preset-bundle` 依 `skills/` tree 與 byte 単位 一致 確認済）、残 四言語 文書。

## 2026-09-19T07:43:15+09:00

**摘要**：fix(comfyui): 「上流 stdenv API 移行済」 誤 判定 訂正。

- 元 判定「上流 hostPlatform 移行済」、実測 反証：`stdenv.is<Platform>` **0.34.0 與 0.30.2 各 三十八 処**、`hostPlatform.is*` 両版 七 処 限定——一度 也 移行 不
- 真 理由：**上流 code 上書 不 化**（旧 patch 移行 overlay 経由 評価 fork 適用）
- `modules/comfyui.nix` 注釈 與 四言語 `deprecated/comfyui-rocm.md`「何故 廃止 可」節 同時 訂正
- 其他 廃止項目 主張 通過：`nixkits.comfyui` 改名済、`modules/comfyui-rocm.nix` 與 三 patch 削除済、四言語 `DEPRECATED.md` 索引 正、上流 version **v0.34.0**

| 提交 | 説明 |
|------|------|
| `4054c32` | fix(comfyui): 「上流 stdenv API 移行 済」誤 判定 訂正（module 注釈 + 廃止文書 四言語） |

> **説明**：`4054c32` **`modules/comfyui.nix` 変更**（注釈 限定、評価 影響 無、`nix flake check` 全通過）。残 四言語 文書。

## 2026-09-19T07:38:04+09:00

**摘要**：fix(docs): 修正文書群 完了 —— 最後 三 文書 確認 四 件 修正（何 四言語）。

- asusd-thermal-guard：文書 状態 `/run` 記載 誤。module `StateDirectory`（`/var/lib/private/asusd-thermal-guard`）使用、注釈 `RuntimeDirectory` 使用 警告（systemd 丸 削除、故 冷却計数 毎回 零 戻）
- comfyui：徽章 存在 不 CI job 名指（`check.yml` 単一 `check` job 限定）。如実 CI 徽章 変更
- comfyui：cache 節 overlay 記述 残存（module `pkgs.comfyui` 参照 無、宣言 設定 限定）
- llama-cpp-rocm：移行例 `hfCacheDir` 展開 不 `~` 使用。module 既定値 絶対 path

| 提交 | 説明 |
|------|------|
| `8292160` | fix(docs): asusd-thermal-guard 状態 /run 記載 誤（四言語） |
| `01679e8` | fix(docs): comfyui 徽章 存在 不 job 名指 + overlay 記述 残存（四言語） |
| `35aaf05` | fix(docs): llama-cpp-rocm 移行例 展開 不 ~ hfCacheDir 使用（四言語） |

> **説明**：何 文書 限定 修正、`packages/`、`overlays/`、`modules/` 未変更。

## 2026-09-18T11:04:38+09:00

**摘要**：外部 目録 掲載 完了 —— awesome-ai-plugins 二 PR 共 合并、NixKits 與 dsh-api-balance 正式 同 目録 進入。

- scan 評価 **88 → 94/100（A – Excellent）**、Security **13/16 → 16/16**、措辞 限定 変更 情報 削除 不
- PR #321：`dsh-api-balance` DeepSeek Harness Plugins 追加、**2026-09-16 合并**
- PR #323：NixKits Development & Workflow 追加、審査 是正 與 scan 再実行 後 我々 自 閉
- PR #335：再提出版、**2026-09-18 合并**。両 entry 現在 上流 README 反映済
- scanner workflow 與 Dependabot 導入 不、10% 信頼 score 減点 受入

| 提交 | 説明 |
|------|------|
| `--` | 外部 repo 作業（awesome-ai-plugins PR #321 / #335 合并）與 issue #3 返信 更新。本 repo 対応 commit 無 |

> **説明**：掲載 外部 目録 側 合并、本 repo `packages/`、`overlays/`、文書 何 未変更。

## 2026-09-18T14:35:36+09:00

**摘要**：fix(docs): 修正類 前 五 文書 検証（breeze-black / efl-cross-fix / codewhale-sudo / rcc-fix / asusd-pd-profile）—— 三 件 修正。

- `rcc-fix` 存在 不 option 名前空間 使用：例 `services.asusctl`（`power-profile`/`cpu-power-control` 含）記載、正 `services.asusd`、段階 與 CPU 電力上限 `profileConfig` 経由（四言語）
- `breeze-black`：「導入」節 placeholder path `(import ./overlay.nix)` 為 `inputs.nixkits.overlays.<name>` 変更（zh 限定）
- `codewhale-sudo`：基本情報表 重複行 削除（zh 限定）
其他 主張 全項目 照合済 通過。

| 提交 | 説明 |
|------|------|
| `a262e3c` | fix(docs): breeze-black 導入 path 與 codewhale-sudo 重複行（zh） |
| `ea03584` | fix(docs): rcc-fix 存在 不 services.asusctl option 使用（四言語） |

> **説明**：何 文書 限定 修正、`packages/`、`overlays/`、`modules/` 未変更。

## 2026-09-18T14:26:43+09:00

**摘要**：fix(devshell): 開発 二 篇 検証 —— 引数 誤 一 件 修正、且 source 欠陥 一 件 発見。

- `ruyi venv` / `ruyi extract` 引数 誤：前者 `ruyi venv -t <toolchain> <profile> <dest>` 之形 必要、且 `profile` 本地索引 存在 必要；後者 位置引数 包名 `ruyi extract <pkg>` 非 file path（四言語）
- searxng limiter 設定 一度 也 読 不：`develop/opencode.nix` `settings.yml` `server.limiterSettings` block 内 記載、独立 `limiter.toml`（`[botdetection] trusted_proxies`）移、修正後 `missing config file` 警告 消、reverse proxy 亦 HTTP 200 返
其他 主張 実測 通過。

| 提交 | 説明 |
|------|------|
| `26e7a76` | fix(devshell): ruyi venv/extract 引数 誤 + opencode searxng limiter 設定 一度 也 効 不（四言語） |

> **説明**：`26e7a76` **`develop/opencode.nix` 変更**（limiter 設定 独立 `limiter.toml` 移）、devShell 挙動 変化。残 文書 限定 修正、試験中 `dump.rdb` 與 残留 background process 掃除済。

## 2026-09-18T13:51:14+09:00

**摘要**：fix(docs): plugin 二 文書 與 mode 三 文書 検証 —— plugin 全項目 一致 変更 不要、mode 一 件 修正。

- `dsh-nixos-shell` 與 `dsh-api-balance`：npm 名 與 version、`nixos_shell` 二十七 項目 道具白名単、`nixos_cli` 五 op 與 数値上限、sudo protocol v3（`MAX_TIMEOUT_MS = 21600000`）、`skills-embedded/` snapshot、`dsh-api-balance` rev `c47f857` 與 四 config 項目 全項目 一致
- NixOS mode「組合」行 persona 行 `complete: true` 設定 誤記。実際 `prefix` 限定、四言語 訂正
其他 mode 主張 通過（`nixos-gate` 読取、NixOS mode 技能 五、maintenance mode 派生関係、news 三要素 mode 各項目）。

| 提交 | 説明 |
|------|------|
| `3d6340f` | fix(docs): NixOS mode 組合 記述 persona complete: true 誤主張（四言語） |

> **説明**：文書 限定 修正。plugin 二 文書 何 変更 不要（今後 退行 比較 為 記録）。

## 2026-09-18T13:43:54+09:00

**摘要**：fix(docs): ruyi 文書 二 件 修正（他 一 件 順便 表現 修正）。

- 試験件数 beta channel 限定 値 為、channel 別 列挙 改：`ruyi` 単体 368 / 統合 58、`ruyi-beta` 462 / 70、`ruyi-alpha` 346 / 57。併 `checkPhase` ruff / mypy `|| true`、実際 build 左右 物 pytest 注記
- zh 導入節 散文 一行 Nix code fence 内 入、block 途切（en/ja/pcn 無）
- （順便）`pyelftools` 本 package 共有 base 無条件 追加（version 条件 無）、「0.53.0 以降 新規」非

| 提交 | 説明 |
|------|------|
| `c30f2b6` | fix(docs): ruyi 試験件数 channel 別 非 + zh 導入節 code block 破損（四言語） |

> **説明**：文書 限定 修正、`packages/`、`overlays/`、`modules/` 未変更。

## 2026-09-18T13:41:45+09:00

**摘要**：fix(docs): obs-bilibili-stream 之 Home Manager 用法 導入 及 効 不 —— `home.packages` `.so` profile 置 限定、OBS `OBS_PLUGINS_PATH` 以 plugin 探索、此 変数 nixpkgs `wrapOBS` 限定 注入、即 `programs.obs-studio.plugins` 限定 有効 経路。四言語 警告 與 二 正 方法 追記。opencode-telegram 全項目 一致 変更 零。

| 提交 | 説明 |
|------|------|
| `4bea784` | fix(docs): obs-bilibili-stream Home Manager 用法 導入 及 効 不（四言語） |

> **説明**：文書 限定 修正、`packages/` 與 `overlays/` 未変更。opencode-telegram 変更 不要 確認（今後 退行 比較 為 記録）。

## 2026-09-18T13:40:20+09:00

**摘要**：fix(docs): kitsfmt 與 mcp-searxng 各 二 件 不正確 記述。

- `kitsfmt`：「注釈保持」記述 過広 —— 0.5.0 実測 節点 直前 先行注釈 限定 整序時 追随、最後 以外 属性 同行末尾 次 属性 上 移動、最後 属性 同行末尾 與 書類 先頭、末尾 破棄。漏 `KITSFMT_STDIN=1` 補完
- `mcp-searxng`：「即用設定」廃止済 `real_ip.x_for = 1` 含（上流 `limiter.toml` `real_ip` 節 既 無）。四言語 削除
- `mcp-searxng`：「`SEARXNG_URL` 無 場合 黙 失敗」実測 不一致 —— 伺服器 正常 起動 且 `tools/list` 返。`tools/call` 限定 毎回 `isError: true` 返、文本 與 stderr 明示

| 提交 | 説明 |
|------|------|
| `0cb9f4f` | fix(docs): kitsfmt 注釈保持 記述 過広 + KITSFMT_STDIN 追加（四言語） |
| `9f3c829` | fix(docs): mcp-searxng 不正確 記述 二 件（real_ip 廃止、失敗 黙 非）（四言語） |

> **説明**：何 文書 限定 修正、`packages/` 與 `overlays/` 未変更。

## 2026-09-18T13:32:32+09:00

**摘要**：fix(docs): dsh 與 godot-ai 文書 検証 —— 三 件 修正、加 実際 機能 欠陥 一 件 発見。

- `dsh`：「宣言的 設定可能 host namespace」表 六 件 限定 且 0.1.2-alpha 記載。該当節 扱 `0.1.5-rc.2` `installSection` 経由 十二 件 登録 故、`agent-default-model` 他 五 件 欠
- `godot-ai` 命令 起動 直後 失敗：attach 橋 `sys.executable -m godot_ai` 以 backend 再 spawn、但 Nix 下 裸 CPython、`site.addsitedir()` 注入 依存 子工程 継承 不。makeWrapper 以 PYTHONPATH 前置、実測 動作
- `godot-ai` 文書 残 二 件：道具数 43 → 46、WebSocket port 9876 → 9500

| 提交 | 説明 |
|------|------|
| `6b47f55` | fix(docs): dsh 設定 namespace 表 不完全 且 version 表記 古（四言語） |
| `a54bd9d` | fix(godot-ai): attach backend 起動 不 欠陥 修正 與 不正確 記述 二 件（四言語） |

> **説明**：`a54bd9d` **`packages/godot-ai.nix` 変更**（makeWrapper 與 postFixup 追加）、godot-ai 構築成果物 変化。残 文書 限定 修正。

## 2026-09-18T13:23:25+09:00

**摘要**：fix(docs): 26 項目 主張 + 子文書 検証、失実記述 7 件 修正

- 主文書 2 件：`inputs.nixkits.url = "~/NixKits"` 使用不可——`git+file:///path/to/NixKits` 変更。「全包 既定 `lib.platforms.linux` 従」失実、実際 `lib.platforms.all`
- blender-mcp 3 件：実 server 登録 26 道具（文書 22 称）。拡張 導入先 `extensions/user/`（Blender Extension、4.x 読込 不可）。更新手順 `chmod`→`rm -rf`→`cp`→`chmod`（従来 無言 失敗）
- codewhale 2 件：`--sandbox <tier>` 存在 不、実 `--sandbox-mode`。以前 修正済 引数名 再導入 者、四言語 統一

| 提交 | 説明 |
|------|------|
| `82d8ed5` | fix(docs): 主文書 不正確 記述 二 件 修正（四言語） |
| `ead55d1` | fix(docs): blender-mcp 不正確 記述 三 件（四言語） |
| `6f40487` | fix(docs): codewhale sandbox 引数名 退行 與 四言語 不一致（四言語） |

> **説明**：文書 限定 修正、`packages/` 與 `overlays/` 未変更。

## 2026-09-18T13:09:18+09:00

**摘要**：refactor(ruyi)! — `ruyi-nixos-compat` 修正 `packages/ruyi/ruyi.nix` 統合、無効 化 overlay 削除。overlay **nixpkgs 之** `ruyi` 修正 者 但、当該 包 既 存在 無、実際 有効 自前 被 `develop/ruyi.nix` 限定——flake 包 利用者 NixOS 互換処理 得 不。修正 三 channel 内蔵 化（`--replace-fail` 以 `@nixLdSo@`/`@nixGlibcLib@` 埋込、`ensure_toolchain_nixos_compat` 注入）、devShell・flake 包・NixOS 模組 同一 構築 得。検証：三 channel 構築 成功、成果物内 `@nixLdSo@` 残存 零 回、`ruyi --version`/`--help` 正常、beta pytest 462 + 70 passed。

| 提交 | 説明 |
|------|------|
| `87d3f7c` | refactor(ruyi)!: 修正 包定義 統合、無効 ruyi-nixos-compat overlay 削除 |

> **説明**：破壊的変更——`nixkits.overlays.ruyi-nixos-compat` **存在 無**。外部 此 overlay 参照 場合 当該行 削除 要（修正 内蔵済、overlay 設定 不要）。ruyi 三 channel build 成果物 何 変化。

## 2026-09-18T12:41:08+09:00

**摘要**：定例 更新 検査 — blender-mcp 1.0.3、ruyi-beta 0.53.0-beta.20260917（`pyelftools` 実行時依存 追加：上流 0.53.0 自 実行時依存 記載、欠 場合 pytest 収集期 中断）、dsh 0.1.5-rc.2、dsh-alpha 0.1.6-alpha.2（上流 拡張 4 件 追加、`dsh-package-lock-alpha.json` 再生成——version 限定 変更 以 `npmDepsHash is out of date` 発生）。四言語 文書 同期、`nix flake check` 通過。

| 提交 | 説明 |
|------|------|
| `0e220fd` | chore(blender-mcp): 1.0.0 → 1.0.3 更新（四言語同期） |
| `9b48078` | fix(ruyi): beta → 0.53.0-beta.20260917 更新 並 pyelftools 依存 追加 |
| `80104c4` | chore(dsh): stable 0.1.5-rc.2 + alpha 0.1.6-alpha.2（四言語同期） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| blender-mcp | 1.0.0 | 1.0.3 |
| ruyi-beta | 0.52.0-beta.20260824 | 0.53.0-beta.20260917 |
| dsh | 0.1.5-rc.1 | 0.1.5-rc.2 |
| dsh-alpha | 0.1.6-alpha.1 | 0.1.6-alpha.2 |
| 　 | blender-mcp source hash | `sha256-nt+sHozi…` → `sha256-pYeByO4O…` |
| 　 | ruyi-beta source hash | `sha256-vxu9AhRD…` → `sha256-w8NlCER3…` |
| 　 | dsh source hash | `sha256-Gnlxnxx2…` → `sha256-9MVIOdae…` |
| 　 | dsh-alpha npmDepsHash | `sha256-qAlIccAJ…` → `sha256-p4uALt5v…` |

> **説明**：共有 base `ruyi.nix` `pyelftools` 一行 追加（三 channel 共用）。`dsh-package-lock-alpha.json` alpha.2 依存集合 再生成。残 package 上流 照合済 既 最新 故 変更 無。

## 2026-09-18T00:38:59+09:00

**摘要**：四言語 `SECURITY.md` sandbox 段階 記述 書換、外部 scanner `RISKY_APPROVAL_DEFAULT` 解消（88 → 94）——trigger 語 `danger-full-access`、本 repo 利用者 任意 選択 可能 挙動 記述 者 非 既定値 設定、pattern 照合 scanner 区別 不能。改後 記述「既定 緩 不」明示。併 `docs/zh/codewhale.md` CLI 例 `--sandbox-mode` 修正。検証：公式 scanner 94/100（A - Excellent）、Security 16/16、medium 零 件。残 6 点 `Dependabot configured for automation surfaces` 由来、本 repo「外部自働化 導入 不」境界 点数 為 破 不。

| 提交 | 説明 |
|------|------|
| `e386dfc` | docs(security): 改写沙箱档位表述，消除扫描器 RISKY_APPROVAL_DEFAULT（88 → 94） |

> **説明**：文言 限定 文書修正、`packages/` 與 `overlays/` 未変更。

## 2026-09-17T18:15:40+09:00

**摘要**：汎用技能「主 flow + 二 付属参考」再構成、且 branch 分離 滞留 Gitea 教訓 回収 — 評価 基 改善：

- 実測 branch 記載 70 行「自 host forge（Gitea）source 取得」節 main 回収（当該 branch merge 不 取決）：自 host instance 全 tag 403 返 可能性
- 適配層 追加：test branch 生 汎用 教訓 其場 手作業 main 書 要求
- 技能 918 行 単一 file 自 主 flow `SKILL.md`（462 行）+ `builders.md`（254 行：builder 別 hash flow）+ `traps.md`（271 行：漂移 罠 等）分割、第 7 步「commit 前 六 自問」新設
- 根拠：本 session 六 package 更新 初回成功率 4/6、三 回 再実行 何 及 此 種 罠 原因
検証：分割 `##` 節、子節、行単位 比較、行数 四通 照合、漏 三 節 復元。四言語 同期

| 提交 | 説明 |
|------|------|
| `e0b1a64` | refactor(skills)!: 通用技能拆分为主流程 + 两份配套参考，并补回丢失的 Gitea 教训 |

> **説明**：技能構造 変更（付属 file `builders.md` 與 `traps.md` 新設）。`packages/` 未変更。
## 2026-09-17T17:22:50+09:00

**摘要**：`check-doc-versions` 検査 新設、「文書 版 = 包定義 版」断言化 — 今回 連続 発見 五 文書 版 不一致（godot-ai、codewhale、mcp-searxng、opencode-telegram、dsh-alpha）対 構造的 防御：此 種 不一致 何 及 build 失敗 不 故、`nix flake check` 第六 検査 化。
検査内容：`docs/<lang>/<pkg>.md`「版」行（四言語）與 多 channel 包（`dsh-alpha` / `ruyi-beta` / `ruyi-alpha`）channel 表 包定義 一致 必要；版 他所 読 場合 也 追跡（`kitsfmt` `Cargo.toml` 読）；例外 `EXEMPT` 登録、機械的 読出 可能 部分 限定 検査。
検証：今回 実際 遭遇 五 種類 欠陥 注入 全部 検出；`nix flake check` 実際 経路 失敗 確認；`AGENTS.md` 記録

| 提交 | 説明 |
|------|------|
| `072ab87` | feat(ci): 新增 check-doc-versions，把「文档版本 = 包定义版本」固化为断言 |

> **説明**：検査 script `develop/check-doc-versions.py` 追加 且 `flake.nix` `checks` 接続（検査数 五 → 六）。`packages/` 與 文書内容 未変更。

## 2026-09-17T16:12:06+09:00

**摘要**：五 包 文書 版番号 修正（内容品質 修正）— 全 服務型包 照合、既更新 但 文書 追随 未 五 件 発見：`codewhale` 0.9.12→0.9.13、`mcp-searxng` 2.2.0→2.3.0、`opencode-telegram` 0.25.1→0.25.2、`dsh-alpha` 0.1.5-alpha.2→0.1.6-alpha.1（文書 + README）、`codewhale-sudo` v0.9.12→**v0.9.0 以降**。
最後 一件 置換 非 判断：当該 overlay 版 依存 不、v0.9.0 導入 `prctl(PR_SET_NO_NEW_PRIVS)` 傍受 物。README 値 古 限定 非 文書 本文 與 自己矛盾 故、機能 由来 記述 形 改。
検証：全体 再照合 10/10 一致；`nix flake check` 通過、四言語 同期

| 提交 | 説明 |
|------|------|
| `0a0d8ce` | docs: 修正五个包的文档版本号（内容质量修复） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale（文書） | 0.9.12 | 0.9.13 |
| mcp-searxng（文書） | 2.2.0 | 2.3.0 |
| opencode-telegram（文書） | 0.25.1 | 0.25.2 |
| dsh-alpha（文書 + README） | 0.1.5-alpha.2 | 0.1.6-alpha.1 |
| codewhale-sudo（README 表現） | 「v0.9.12 sudo 機能」 | 「v0.9.0 以降 阻止 sudo 機能」 |

> **説明**：今回 文書 限定 修正、`packages/` 與 `overlays/` 未変更。

## 2026-09-17T15:56:56+09:00

**摘要**：godot-ai 四言語文書 版番号 與 依存表 修正；汎用技能 第 5 步「機械的置換 非 書直」判定 新設 — 内容品質 修正 主：main godot-ai code `2a06bbf` 既 4.1.0 到達 且 機能 完全（実測 `godot-ai --version` → 4.1.0）、但 文書 同期 未、版番号 依然 `3.2.5`、依存表 六 項 且 全「≥ 範囲」、実際 九 項 fail-closed 厳密固定。
② 方 有害：v4 起動時 此 九 包 正確 版 検証、不一致 則 起動 拒否。修正 依存表「版 + 提供元」二列 化 九 項 逐一 列挙、且 pydantic-core 連動 要求（`==2.46.5`）補足。
検証：九 版番号 `nix eval` overlay 含 閉包 自 測定、逐一 比較 九/九 一致；技能 触发判定 依存 厳密固定 化 又 起動時 硬 検証 追加

| 提交 | 説明 |
|------|------|
| `085c093` | docs(godot-ai): 修正四语文档的版本号与依赖表（内容质量修复） |
| `55674f2` | feat(skills): 通用技能第 5 步新增「文档须重写而非机械替换」的触发判据 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| godot-ai（文書） | 文書 3.2.5 / 依存表 六 項「≥ 範囲」 | 4.1.0 / 依存表 九 項 厳密固定 |

> **説明**：今回 文書 修正、`packages/godot-ai.nix` 未変更（其 code `2a06bbf` 既 正確）。

## 2026-09-17T13:00:09+09:00

**摘要**：feat(skills): 適配層 第 10 步「process 振返 與 規範 検証」新設 — 更新 flow 終了 後 実行、監査 対象 軟件 非、軟件 如何 更新 決定 規範 自体（技能 / `AGENTS.md` / `SECURITY.md` / develop script）。六 步：振返、検証、帰属、体験、証拠規律、成果。
証拠規律 硬性 制約：規範 変更 再現可能、追跡可能、異議申立 可能 必要、印象 依 規範 変更、一度 偶発 法則 視、既 正 内容 対 更 最適化、拘束力 残 条目 役 立 無 見 故 削除 禁止。
初回 実行 二 実欠陥 発見（何 及 build error 生 不）：`SECURITY.md` 未作成 子倉 `SECURITY.md` 指 dead link、四言語「同 sub project 独自 安全政策 未整備」変更；十二 箇所 `asusctl` link project `OpenGamingCollective/asusctl` 移転 合 変更。
link 監査 手法 汎用技能 入：`curl` 404 `gh api` 再確認、`403` 多 場合 scraping 対策。

| 提交 | 説明 |
|------|------|
| `442e5d1` | feat(skills): 适配层新增第 10 步「流程复盘与规范校验」 |

## 2026-09-17T12:52:54+09:00

**摘要**：fix(codewhale): x86_64/aarch64 預編訳変体 也 0.9.13 至 — 前回 riscv64 源 build 変体 `codewhale-src` 限定 更新、`codewhale.nix`（x86_64/aarch64 GitHub Releases 預編訳経路。`flake.nix` `hostPlatform.isRiscV` 以 分岐）漏。本倉庫 codewhale 同名同出力 二 変体：`codewhale.nix` `version` + cli/tui × x64/arm64 **四 hash**、`codewhale-src.nix` `version` + `hash` 與 `Cargo.lock` 同期 必要——**更新時 両方 変更 必要**。罠 適配層 記載。判定 **配備後、構造 毎 各 変体 実際 版 照合。build 通過 限定 不十分**。

| 提交 | 説明 |
|------|------|
| `ecb28c4` | fix(codewhale): 同步升级 x86_64/aarch64 的预编译二进制变体至 0.9.13 |
| `f8c8265` | docs(skills): 记录 codewhale 双变体陷阱（四语） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale（x86_64/aarch64 預編訳） | 0.9.12 | 0.9.13 |
| 　 | cli/tui hash x64 | `nQt02NO/` → `WTriVnVv` |
| 　 | cli/tui hash arm64 | `Gkje9AMu` → `BgUnHSo0` |

## 2026-09-17T12:41:29+09:00

**摘要**：五 包 昇級 + 更新技能「対話的確認」追加 — 生産 実戦、承認済 更新 全部 実行：`mcp-searxng` 2.3.0、`opencode-telegram` 0.25.2、`codewhale` 0.9.13（`Cargo.lock` 同期）、`dsh-alpha` 0.1.6-alpha.1（lock `"peer": true` 必要）、`godot-ai` 3.2.5 → 4.1.0（大版跨、fail-closed 実行時依存検証）。nixpkgs 五 包 遅 故、新規 `overlays/godot-ai-v4-deps.nix` `fastmcp` overlay 與 連鎖、overlay 連鎖（`flake.nix`、`overlays/default.nix`） 同期 必要。技能「対話的確認」節 與 罠 5/6 追加。検証：五 何 也 build 通過 且 実走 確認。

| 提交 | 説明 |
|------|------|
| `2a06bbf` | chore(pkgs): 升级 mcp-searxng 2.3.0、opencode-telegram 0.25.2、codewhale 0.9.13、dsh-alpha 0.1.6-alpha.1、godot-ai 4.1.0 |
| `c7de9b6` | feat(skills): 更新技能追加交互式澄清，并计入本轮实战教训 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| mcp-searxng | 2.2.0 | 2.3.0 |
| opencode-telegram | 0.25.1 | 0.25.2 |
| codewhale | 0.9.12 | 0.9.13 |
| dsh-alpha | 0.1.5-alpha.2 | 0.1.6-alpha.1 |
| godot-ai | 3.2.5 | 4.1.0 |
| 　 | git hash | `+0FJ+Grod` → `wNM/QNtF` |
| 　 | npmDepsHash (mcp-searxng) | `WK28hNI3` → `MqVn66vC` |
| 　 | npmDepsHash (opencode-telegram) | `Ai1hgKiv` → `NnvFOrS7` |
| 　 | Cargo.lock (codewhale) | 7073 行 → 7347 行 |
| 　 | npmDepsHash (dsh-alpha) | `SVYhLVZw` → `qAlIccAJ` |
| 　 | 新規 overlay | `overlays/godot-ai-v4-deps.nix` |

## 2026-09-17T11:34:39+09:00

**摘要**：fix(skills): 子倉 追従 判定 field 単位 細分化 — 旧判定「**文件** 変化 可否」分流、但 manifest field 中 意味的入力 一部 限定：子倉 `dsh-api-balance` 的 `package.json` byte 変化（`publishConfig.access` 削除）、`dependencies`、`files`、`version`、`main`/`exports` 何 及 未変更 故、旧判定 純 metadata 変更 以 全 構造 再 build 起 所。現在 **field 単位**：release metadata（`publishConfig` 等）、文書、CI 設定 **追従 不**；`dependencies` 系 / `files` / `main` / `exports` / `scripts` / `version` / source **追従 必須**；判別 不能 場合 追従 側 倒。適配層 記述 也 同期。

| 提交 | 説明 |
|------|------|
| `c08f5c9` | fix(skills): 子仓跟进判据细化到字段级 |
| `641830a` | docs(skills): 同步四语的子仓跟进字段级判据 |

## 2026-09-17T11:31:32+09:00

**摘要**：feat(skills): 同 account 子 project 連鎖確認 與 倉庫横断 保守条目 連結 — 倉庫 参照 同 account 子 project（典型 薄包装） 更新確認 対象 化、前提 成立 時 連鎖並列 実行、結果 主倉 結果 視 且 両倉 log 別々 計上、主倉 条目 子 project 条目 対 連結。帰属：`nix-flake-update-check` 第 9 步（参照検出 三形態、四 前提検証、循環 與 深度上限、失敗隔離）、`write-maintenance-log` 類型 5、`write-project-docs` 子倉 参照関係 明示記録、適配層 本倉 固有 事実 限定。dry run 三 欠陥 修正：検出 command `-h` 無 `awk` field 錯位 且 無言 空 返；依存衝突 判定「子倉 要求 host 提供 比 高 可否」；GitHub anchor 規則 実際 一文字 毎 `-` 置換。主倉 固定 `dsh-api-balance` rev 二 文書 commit 遅、新判定 再固定 不。

| 提交 | 説明 |
|------|------|
| `b7e9717` | feat(skills): 支持同账户子项目链式检查与跨仓维护条目链接 |

## 2026-09-17T11:21:34+09:00

**摘要**：chore(security): `dependabot.yml` 完全 削除 且「外部自働化 導入 不」安全境界 確立 — Dependabot 実行不能、PR 作 限定、secrets 取得 不能 雖、GitHub 実行 且 挙動 制御 不能 的 **外部自働化 統合**、本倉庫「開発 保守 維護者 與 小爪 行」境界 衝突 故、file 全体 削除。`AGENTS.md` 当該 節 新設：拒否 清単（第三者 CI scanner、Dependabot）、判定（先 倉庫内 `gh`/`git`/`nix` 自行実装、不能 則 人手）、代償（action 安全更新 技能検査 能動 実行 必要）。能力 不失：`nix-flake-update-check`「GitHub Actions 更新 確認」節 新設（固定 action 列挙 → tag 照会 → SHA 書戻）、旧「自動 PR 直接 merge 不能」小節 汎用 指針 至。四語 文書 同期。

| 提交 | 説明 |
|------|------|
| `3421c1f` | chore(security): 移除 dependabot.yml 并确立「不引入外部自动化」安全边界 |

## 2026-09-17T11:03:51+09:00

**摘要**：chore(ci): Dependabot npm ecosystem 削除、`github-actions` 限定 残 — npm ecosystem 本倉庫 対 **構造的 無効**：npm 包 `buildNpmPackage` 包装、其 `npmDepsHash` main build npm-deps 成果物 與 byte 単位 照合、一方 Dependabot `package.json`/`package-lock.json` 限定 変更 且 `.nix` 内 当該 hash 感知 不能 故、其 開 npm 更新 PR 必 CI 失敗（`npmDepsHash is out of date`）。npm 依存 更新 `nix-flake-update-check` 技能 手動対応 戻、削除理由 設定 内 comment 完全 記録 且 後日 漏 誤認 再追加 不。`github-actions` 維持——PR #6 有効性 実証 且 SHA 固定 正 維持。

| 提交 | 説明 |
|------|------|
| `4b997b3` | chore(ci): Dependabot 移除 npm 生态，仅保留 github-actions |
## 2026-09-17T10:55:02+09:00

**摘要**：chore(dsh-nixos-shell): `dsh-tools` 0.1.2-alpha.2 → 0.1.5-rc.2；ci: `actions/checkout` v4 → v7.0.1 — 両者 共 前回 `dependabot.yml` 自動生成 物。PR #6 merge 済（SHA 固定 正 維持）；PR #7 手動 upgrade 切替：Dependabot `npmDepsHash` 認識 不可、CI 必 `npmDepsHash is out of date` 報告 故、0.1.5-rc.2 上 内蔵 copy host dsh 揃、当該 hash 更新。検証：build 通過、成果物 内 版本 host 一致、`nix flake check` 全通過。対応 `nix-flake-update-check` 技能 記載。

| 提交 | 説明 |
|------|------|
| `dce26f2` | chore(dsh-nixos-shell): dsh-tools 0.1.2-alpha.2 → 0.1.5-rc.2 |
| `5f4e9ec` | ci: bump actions/checkout from 4.4.0 to 7.0.1 (#6) |
| `7b94d7c` | refactor(skill): nix-flake-update-check 补充 Dependabot 自动 PR 的处置 |
## 2026-09-17T01:40:58+09:00

**摘要**：docs(security): `SECURITY.md` 「重複投稿」扱 境界 明示（四言語）— 新設 小節 拘束力 持：上表 既 記載 同一 結論 新 証拠 無 再投稿 場合、本節 指 其 侭 close。正当 報告 巻込 無 様 受理 與 close 境界 引——受理：上表 含 無 新規 問題、上表 結論 誤 指摘（再現可能 証拠 添 場合）、同一 主題 但 異 脅威 model 又 攻撃経路；close：既存 結論 再述、同一 規則 再度 出力 自動 scan。「結論 誤 指摘 常 歓迎」 也 残——上表 4 件 也 精査 上 判断、判定 誤 場合 訂正 可。

| 提交 | 説明 |
|------|------|
| `94bd95c` | docs(security): 明确重复提交的处理界限（四语） |

## 2026-09-17T01:34:13+09:00

**摘要**：docs(security): `SECURITY.md` 「評価済 外部報告」節 追加、`docs/SECURITY.{en,ja,pcn}.md` 以 四言語 local 化 組入 — 精査 上 close 済 4 件 公開。

- PR #4（`/token`・`/voicepack`・`/tts` rate 制限 欠如）與 PR #5（`/query` request body 上限 欠如）何 也 誤検出：説明 與 diff 不一致、`readJsonBody` 64 KiB 上限 既 存在。
- issue #1/#2（`secrets: inherit` 最小権限 違反）也 誤検出：倉庫 全体 於 secret 2 件 限定、明示 受渡 與 `inherit` 等価。
- 此等 導 2 件 実際 堅牢化：`/tts` endpoint SSRF 與 31 build workflow 最小権限 補完。
- 立場：規則 上 概 事実 突、但 脅威 model 本 project 配備形態 該当 不；誤検出 迷惑 扱 不。

| 提交 | 説明 |
|------|------|
| `6f34e73` | docs(security): SECURITY.md 记录已评估的外部报告，并纳入四语本地化 |

## 2026-09-17T01:23:46+09:00

**摘要**：chore(security): `SECURITY.md` 與 Dependabot 追加、Actions SHA 固定 — 発端 awesome-ai-plugins 維護者（@kantorcodes）PR #323 是正要求：scan 71/100、80 閾値 下回。

- scorecard：critical 也 high 也 零、減点 全部 engineering 衛生（Actions 未固定、Dependabot 欠如）。
- `SECURITY.md`（支援 版本、非公開 脆弱性 報告 channel、対応期限）與 `.github/dependabot.yml` 追加。
- 6 箇所 第三者 action 参照 浮動参照 自 commit SHA 固定。`DeterminateSystems/nix-installer-action@main` 浮動 branch 参照。
- 第三者 scanner action 採用 不（代償 信頼 score 10% 減点、受入）。

| 提交 | 説明 |
|------|------|
| `97a4180` | chore(security): 补 SECURITY.md、Dependabot，并将 Actions 固定到 SHA |

## 2026-09-16T16:45:03+09:00

**摘要**：fix(dsh-nixos-shell): `skills-nixos` path 断裂 修正 — `559e841` 持込、本機 配備 後 初 露見。当該 commit 技能 root `../../skills-nixos/`（預設目録 相対）記載、但 seeder `cp -r presets/<mode> $DSH_HOME/.agent-presets/<id>` 預設目録 外 内容 複製 不 故、seed 後 root 存在 無 `~/.dsh/skills-nixos` 解決、追加 3 NixOS 技能 読込 不。修正：`postPatch` 各預設目録 内 whitelist subset 生成 形 改、`customSkillDirs` `skills-nixos/` 化。検証：seed 模擬 後 到達可能、`nix flake check` 全通過、配備 後 新規 session 当該 3 技能 一覧 出現。教訓：預設 seeder 以 複製 場合、検証 seed 後 行 必要。

| 提交 | 説明 |
|------|------|
| `96b589c` | fix(dsh-nixos-shell): skills-nixos 移入预设目录，修复 seed 后路径断裂 |

## 2026-09-16T14:54:53+09:00

**摘要**：refactor(dsh-api-balance)!: 独立 倉庫 移転、本 倉庫 薄 wrapper 化 — 初 分割。

- 監査 判定：唯一 platform 非依存 project、NixKits 與 code level 結合 零、npm packaging 必要 有。
- 新 倉庫 `Kihara777/dsh-api-balance`：source、四言語 文書、npm 公開 CI。`dsh plugin add` 一 行 導入 可能、web profile `exit=0` 起動 実測。
- 本 倉庫 側：`packages/dsh-api-balance/` 削除、`.nix` `fetchFromGitHub` 薄 wrapper 化（`npmDepsHash` 不変）；文書 短 page 圧縮、README 移転 明記；CI workflow Cachix 命中 為 保持。
- `write-project-docs` 更新：「main 倉庫 薄 wrapper + sub 倉庫 完全 文書」architecture。

| 提交 | 説明 |
|------|------|
| `0bb7fc1` | refactor(dsh-api-balance)!: 迁出为独立仓库，本仓改为薄封装 |
| `0760612` | feat(skill): write-project-docs 支持「主仓薄封装 + 子仓完整文档」架构 |

**未対応**：npm 公開 未実行——本機 npm 資格情報 無（未 login、token 無、`@kihara777` scope 不存在）。先 npmjs.com 平台 account 與 scope 作成 必要。package 自体 公開可能 状態（`npm pack` 70.8 kB / 4 file 確認）。

## 2026-09-16T14:27:33+09:00

**摘要**：refactor(skills): `/etc/nixos/AGENTS.md` 実践 自 未 cover 二 缺口 汎化 — 同 file（HarukaX 機器設定規則）監査、約 75% 既存技能 cover 済 判定。真 缺口：① 機密 與 `path:` input（`nixos-modern-cli` 新節）——機密 repo 外 置 `path:` 導入 必要、罠 此 input `flake.lock` 固定 内容変更 `--update-input` 要 点；② 熱管理 方法論（`nixos-specialisation-tuning` 新節）——曲線 上 噪音 限定、profile 下 速度 失、`enabled: false` profile 與 曲線 乖離、`asusctl` 書込 一時的 検証 daemon 再起動 必要、緩 曲線 與 攻撃的 曲線 温度 回転数 完全同一 則 fan 飽和 有効 手段 消費電力 低減 限定。機種依存 内容 `/etc/nixos/AGENTS.md` 残、四言語 document 更新。

| 提交 | 説明 |
|------|------|
| `a33a3cf` | refactor(skills): 泛化 /etc/nixos 实践的两个未覆盖缺口 |
| `fba7b38` | docs(skills): 同步两技能扩展后的功能清单（四语） |

## 2026-09-16T14:11:18+09:00

**摘要**：feat(dsh-nixos-shell): NixOS模式 3 個 NixOS 運維技能 同梱 — 倉庫 `skills/` 樹 review 結論：`nixos-modern-cli`、`recover-nixos-config`、`nixos-specialisation-tuning` **追加**；`nixkits-skills`（技能 installer）與 `news-three-elements`（創作系 独立 package 提供済）**追加 不**。維護模式 其 派生 3 個 自動継承。**実装**：技能 `presets/<mode>/skills/` 複製 不（両預設 間 byte 単位 鏡像、更 置 場合 drift 可能 第二複製 成）；代 `postPatch` 倉庫樹 自 whitelist 方式 建構期 subset `skills-nixos/` 生成、`skill-filesystem` `../../skills-nixos/` 以 掛載。

| 提交 | 説明 |
|------|------|
| `559e841` | feat(dsh-nixos-shell): NixOS模式 同捆 3 个 NixOS 运维技能 |
| `7971689` | docs(dsh-nixos-shell): 记录 NixOS模式 新增的 3 个同捆技能（四语） |

## 2026-09-16T13:57:56+09:00

**摘要**：feat(dsh-api-balance): `dsh.bundle` 追加、`dsh plugin add` native 導入 対応 — 両 plugin 性質 異：`dsh-api-balance` platform 非依存 UI 拡張（`inject = ["connection", "webServer"]` 限定、preset 無、技能 無、`$DSH_HOME` 書込 無）、`dsh-nixos-shell` 核心 価値 Agent preset。**重要 発見（従来 結論 覆）**：entry 名 `./` 開始 場合 其 patch 同目録 絶対 `file://` URL anchor 為。此 基 新規 `cordis.patch.yml` `name: './lib/index.js'` 以 plugin 登録（裸 包名 失敗）、`package.json` `dsh.bundle.patch` 追加。

| 提交 | 説明 |
|------|------|
| `ac3cb3e` | feat(dsh-api-balance): 支持 dsh.bundle，可经 dsh plugin add 安装 |
| `bee12d7` | docs(dsh-api-balance): 补充两种安装方式与 bundle 机制说明（四语） |

**関連 外部報告**：issue #3（@zerocodefast）——awesome-ai-plugins 収録招待。`dsh-api-balance` DeepSeek Harness 節 投稿 技術的 条件 満 但、`dsh-nixos-shell` 宣言的 維持（其 理由 `d14146c` entry 記録済）。

## 2026-09-16T13:44:09+09:00

**摘要**：refactor(dsh-plugins): 両 plugin 未使用 `peerDependencies` 削除 — 実測 結果、peer 宣言 実際 import 一致 不：`dsh-nixos-shell` `cordis` / `dsh-subprocess` / `dsh-timer` 宣言、`dsh-api-balance` `cordis` / `dsh-client-connection` 宣言、但 実際 import 各自 実依存（`dsh-tools` + `schemastery` / `dsh-credentials`）限定、`dsh-timer` npm 也 host 樹 也 不存在。死 宣言 宣言的経路 決 効 不 既存 deploy 影響 無、但 pnpm 経路 install 阻害。lock 與 `npmDepsHash` 同時 再生成。

| 提交 | 説明 |
|------|------|
| `d14146c` | refactor(dsh-plugins): 移除未使用的 peerDependencies |

**関連 外部報告**：issue #3（@zerocodefast）——awesome-ai-plugins 収録招待、open 維持 PR 提出 無。

## 2026-09-16T12:39:12+09:00

**摘要**：refactor(skills)!: `nixkits-check-updates` 「汎用核心 + 倉庫適配層」分割 — issue #3 評価 時 推薦技能 移植性 精査 発端：元 技能 NixKits 強結合、第 5 步 `for lang in zh en ja pcn` 與 `docs/$lang/<pkg>.md` path 硬符号、第 8 步 `write-maintenance-log` 強制呼出、故 他 nix flake 倉庫 失敗。新規 `nix-flake-update-check`（314 行、何 倉庫 非結合）包検出、builder 別 hash flow、flake.lock 三路分岐、修正内蔵版確認、nixpkgs 漂移 罠 担当、`nixkits-check-updates` 適配層 痩。適配層 契約：文書同期 / 変更記録 / 動的入力 / 事故教訓 / 追加同期項 此 宣言。

| 提交 | 説明 |
|------|------|
| `667bf6e` | refactor(skills)!: 拆分更新检查为通用核心 + NixKits 适配层 |
| `93fe67e` | feat(dsh-nixos-shell): 维护模式注入 nix-flake-update-check 技能 |
| `6af37e7` | docs: 同步技能拆分——四语新增通用技能文档、README 技能表与注入清单 |

**関連 外部報告**：issue #3（@zerocodefast）——awesome-ai-plugins 収録招待。検討 結果、提案 推薦文 NixKits 「中国語技能 含 包集」位置付、Nix 包 / 模組 / 補丁 集合 也有 事 触 無、且「Chinese-language skills」中国語 利用者 限 有用 如 読。収録 自体 技術 無関係 故、issue open 維持、PR 提出 不。

## 2026-09-16T12:20:57+09:00

**摘要**：ci: 31 本 `build-*.yml` 呼出側 頂層 `permissions: contents: read` 補完 — 共 `permissions` 宣言 無 倉庫既定（書込 可 可能性 有）継承、実際 行 checkout + `nix build` + Cachix push 限定、故 被呼出側 `build-package.yml:17-18` 揃。発端 外部貢献者 **@begininvoke** 的 RedGem 掃描報告（issue #1 / #2）：両者 共 検証 結果 誤検出（同一倉庫 / 同一 commit 的 再利用可能 workflow、secret 2 個 限定 `inherit` 與 明示渡 集合 同一）、採用 不 証拠 添 close、但 此 権限境界 再点検 契機 成。31 箇所 `secrets: inherit` 変更 不：Cachix 独立 `CACHIX_AUTH_TOKEN` 使用、最小権限 削 余剰 残 無。

| 提交 | 説明 |
|------|------|
| `445eb4b` | ci: 为 31 个构建 workflow 补全顶层 permissions（最小权限） |

**関連 外部報告**：issue #1 / #2（@begininvoke / RedGem）——byte 単位 完全重複、誤報 確認、詳細 技術 証拠 comment 添 not planned 閉鎖。手掛 価値 謝意 表。

## 2026-09-16T11:58:25+09:00

**摘要**：fix(dsh-api-balance): 自訂 TTS 代理 的 SSRF 與 請求 header 注入面 修正 — 此 代理 任意 `http(s)` URL 受 取 host 身分 請求 発行、故 内部網絡 探索 與 雲 metadata（`169.254.169.254`）読取 踏台 成 得。又 請求 body 内 的 使用者制御 `headers` 其儘 転送、攻撃者 `host` / `cookie` / `authorization` header 付与 可能。修正 `resolveTtsTarget` 與 `isBlockedAddress` 新設、loopback / private / link-local / 予約 address 拒否（RFC1918、CGNAT、IPv4-mapped IPv6 対象）、自訂 請求 header whitelist 化（`content-type` / `accept` / `accept-language` / `user-agent` 限定）。四言語 文書 亦 防護 説明 追記。

| 提交 | 説明 |
|------|------|
| `e1a6e66` | fix(dsh-api-balance): 修复 TTS 代理的 SSRF 与请求头注入面 |
| `72cb6ae` | fix(docs): pcn 维护条目去除残留假名（のみ → 限定） |

**関連 外部報告**：PR #4 / #5（@anupamme / OrbisAI Security）——誤報 確認、詳細 技術 証拠 comment 添 閉鎖。手掛 価値 謝意 表。

## 2026-09-16T11:38:20+09:00

**摘要**：docs(deprecated): `DEPRECATED.md` 索引化 且 四言語化 — 従来 一本 中国語文書 索引 與 単一工程 完全 説明 兼、項目 増 場合 全体 一望 不能、局所化 受皿 亦 無。根 `DEPRECATED.md` 純粋 索引（一覧 + 各工程詳細 連結）後退、`README`/`MAINTENANCE` 同 成法 三鏡像 `docs/DEPRECATED.{en,ja,pcn}.md` 用意。各廃止工程 詳細 `docs/<lang>/deprecated/<name>.md` 移、四言語 各一份、冒頭 言語切替器 與 索引 戻 連結 置。第一陣 comfyui-rocm。四言語 `README`「廃止工程」節 追加、`docs/<lang>/comfyui.md` 詳細頁 向直。検証：`nix flake check` 6 本 死連結 検出、修正済。

| 提交 | 説明 |
|------|------|
| `8ff91eb` | docs(deprecated): 索引化 + 四语本地化，详情拆到独立文档 |

## 2026-09-16T11:05:32+09:00

**摘要**：refactor(comfyui)!: comfyui-rocm 補丁事業 退役、模組名 `nixkits.comfyui` 改名 — 上流 ROCm 対応 StrixHalo 良 支持 様 成、補丁 使命 終：三 補丁 `strix-halo` / `nixpkgs-compat` / `stdenv-api` 削除、`modules/comfyui-rocm.nix`→`modules/comfyui.nix`、選項 `nixkits.comfyui-rocm`→`nixkits.comfyui`、四言語 文書 `comfyui-rocm.md`→`comfyui.md`、根 `DEPRECATED.md` 新設。判定材料：上流 `stdenv` 非推奨 読 0 件、上流 `nix/versions.nix` 的 `rocm71` torch 2.10.0 `strix-halo` 補丁 逐 byte 一致、上流模組 既 `gpuSupport = "rocm"` 支持。

| 提交 | 説明 |
|------|------|
| `5015bcc` | refactor(comfyui)!: retire the comfyui-rocm patch project, rename module |

## 2026-09-16T01:45:07+09:00

**摘要**：docs: 預設包 更新 `daemon-reload` 後 `restart dsh` 必要 — `nixos apply` 設計上 dsh 再起動 不（安定掛載点）。一方 `systemctl restart dsh` 単独 前世代 pre-start 脚本 実行、其 正 `cordis.patch.yml` `$DSH_HOME` 複製 工程（預設根 該 文件 記載）。症状 服務 再起動 済 但 会期 旧預設 読。世代 570 配備後、最初 restart 旧 path 其儘、`systemctl daemon-reload` 後 再起動 初 切替。AGENTS.md「本機配備」操作順序 與 確認方法 追記、`docs/{zh,en,ja,pcn}/dsh.md` 同様 更新。

| 提交 | 説明 |
|------|------|
| `a167aae` | docs: 预设包更新要 daemon-reload 再 restart dsh |

## 2026-09-15T23:47:01+09:00

**摘要**：feat(preset+skill): 取材門 `news-material` — 実際 会期 「共創 生搬硬套」露見：使用者 素材 形式 唯変 其儘 出稿、検索 工程 屡 飛。prompt 記載 唯 規則 劣化、故「先 検索、次 書直」実行時検証 可能 形 化。新 拡張 `plugins/news-material.js` 二箇所 掛：`agent/pre-step` 人 的 message 受理 step「取材鉄律」同送、`agent/turn-stopping` 其回合自身 的 log 読——`web_search` / `web_fetch` 呼出 一度 無 回合、或 本文 使用者 原文 写 回合（連続 8 漢字 命中）`agent.steer()` 退稿 返、`dsh-agent-loop` 同回合 別一歩 走。退稿 回合毎 一度 限定。技能側 同 検証可能 規則 備：抽出 → 投射 → 張替 表 與 8 字 紅線、検索記録 必須化、`checklist.md` 自己点検 3 → 7 項、persona 書換。assertion 31 件 追加。

| 提交 | 説明 |
|------|------|
| `a0759b1` | feat(skill): 素材只是导火索——三步改造、禁照抄、必检索 |
| `cc9d0d1` | feat(preset): 取材门 news-material——无检索即退稿，照抄即退稿 |
| `71f25db` | docs: 四语同步素材共创铁律与取材门 |
| `a2ccd55` | docs(agents): 新增文件先 git add 再跑 flake check |

## 2026-09-15T12:36:10+09:00

**摘要**：feat(skill+preset): 「新聞三要素」三人主人公 指 変更、拒否服務「先 素材 見做」判定 改 — 維護者 四修正 提出：本模式「新聞三要素」報道学三要素 非、**必到三人主人公**——巴兰尼科夫、尤丁采夫、布亚诺夫——；検索 補 可能 素材 一律拒否 禁止；共創原稿 三人必備；仮定疑問 與 名指無人物 先 三人中一 対応 可能 評価。技能側：`SKILL.md` 新義確定、「形式厳格制約」第 0 条（三人本文登場、一人欠 即 改稿）追加、取材 四類 拡張；「拒否服務」厳格判定順序 書換——素材可能物 一律拒否禁止 / 仮定疑問「既発生事」書 / 名指無人物 先 対応 / 何 亦接続不能時 唯拒否。預設側：persona「素材優先」節 與 共創三人揃 規則 追加、`readonly-gate` 儀式文 三人括注 追加。assertion 14 件追加、四言語文書 同期；`nix flake check` 6 項 全通過

| 提交 | 説明 |
|------|------|
| `8f5b848` | feat(skill): 新闻三要素改指三位主角，拒绝服务先当素材 |
| `1adb6be` | feat(preset): 模式提示词改为素材优先，快讯须三人到齐 |
| `4732835` | docs: 四语同步新闻三要素的三人定义与素材优先判定 |

## 2026-09-15T11:47:48+09:00

**摘要**：fix(preset): 読取範囲「自身技能包」追加 — 前 round 読取「工作区 / 添付目録 / `/tmp`」限定時、**模式自身技能包 締出**：`tables.md`、`checklist.md` 取得 cache `$DSH_HOME/.cache/news-three-elements/` 或 同梱 fallback snapshot 存在、両者 許可根 外、故 model 付属書類 読不能、接続詞 與 逆転結末雛形 全欠落。修法：**取得 cache** 與 **預設根**（`bundled/` snapshot 含）可読根 追加、拒否文 亦「…、`/tmp` 與自身技能包目録」変更。assertion 二件（cache 與 同梱 snapshot 可読、範囲外 依然拒否）追加、四言語文書 同期

| 提交 | 説明 |
|------|------|
| `ee072d5` | fix(preset): keep the mode's own skill package inside the read scope |

## 2026-09-15T11:38:02+09:00

**摘要**：fix(preset): 儀式文「催逝快訊」化 — 拒否締 一文 原「只编造带齐新闻三要素（新、事实、报道）的俄式快讯」、括弧内 報道学教科書 原義、読上 定義引用 如 響、落 潰。改「只编造带齐新闻三要素 **催逝快訊**」、開始三択 既存「催逝員」語彙 整合。修正 二箇所（persona 與 `readonly-gate` 拒否文本）、共 固定 prompt；技能 與 文書 「成果物」定義行 未変更。assertion 四件 固定（両箇所 新文言 有、旧原義括注 復帰無）

| 提交 | 説明 |
|------|------|
| `bfb0ed4` | fix(preset): say 催逝快讯 in the ritual line, not the academic gloss |

## 2026-09-15T11:24:49+09:00

**摘要**：fix(preset): 言語審査 人 発言 唯 判定化 — 新規 session 於、簡体中文 正当依頼 拒否、且 英文訳文 添付。記録（`session-efc87486`）依、当該 step 使用者 中文 message 之外、harness 注入 **英文系統 message**（`source.kind = plugin`、承認方針変更通知）與 `skill-catalog` 同居；guard **該 step 全 message** 審査 故、英文通知「簡体中文 使用 無」読、言語審査 注入——model「相手言語 一致」規則 従 拒否、英文 添付。`withNotice` `source.kind === "user"` message 唯 対象化（承認通知、技能目録、道具結果 不算）、回帰 test 二件 追加（英文承認通知 + 中文依頼 発火無／人 発言 無 step 不変）。四言語文書 該境界 明記

| 提交 | 説明 |
|------|------|
| `9557707` | fix(preset): judge only the human's messages in the language gate |

## 2026-09-15T11:08:06+09:00

**摘要**：feat(preset)+test: 倉庫自検体系 與 模式挙動四加固 — `nix flake check` 一項 自 **六項** 移行：`preset-bundle`（技能 snapshot `skills/` 與 byte 単位一致）、`workflow-coverage`（全 package workflow 有）、`doc-links`（link + 四言語切替器 + pcn 假名無）、`maintenance-log`（条目数、timestamp、SHA 重複無）、`news-mode-tests`（**network 無**：fetch stub、二度目 304）。当日、翻訳文書 12 件 切替器、codewhale link 3 件、`+00:00` timestamp 1 件、`dsh-api-balance` workflow 欠落 検出、修正。同 round 挙動四加固：読取範囲限定、抽選連続重複防止、先発言時 問撤回、取得並列化 + ETag 条件付請求

| 提交 | 説明 |
|------|------|
| `9260dd5` | test: guard the repo with six flake checks and an in-repo test suite |
| `ac4b05c` | feat(preset): scope reads, harden the draw, and make the fetch incremental |
| `0af079c` | docs(preset): record the scoped reads, incremental fetch and hardened draw |
| `9810af5` | fix(docs): repair the switchers and dead links the new check found |

## 2026-09-15T10:57:15+09:00

**摘要**：feat(skill): 技能「拒否服務」節 新設 — 拒否流程「某預設 persona 限定」自 **技能本体** 昇格：`SKILL.md` 「拒否服務」章 追加（捏造 非、提供素材改稿 非 之請求 同節 拒否、**拒否毎 当日素材 online 取得**；理由、文型、段落順、結末反転、接続詞 前回 反復 不可；三〜五句 通信社文体；底色「至極真面目 出鱈目」；拒否 即止）、[`tables.md`](../skills/news-three-elements/tables.md) 冒頭 雛形 骨格 唯、素材 当次取得 明記、[`checklist.md`](../skills/news-three-elements/checklist.md) 「拒否服務自己点検」5 項 追加。四言語技能文書 與 各 README 技能行 同期、package 同梱 snapshot 再生成、persona 二箇所 節名 参照 変更

| 提交 | 説明 |
|------|------|
| `f120a3d` | feat(skill): give the skill a refusal service of its own |
| `8c28f03` | chore(preset): sync the bundled skill snapshot and point the persona at the section |

## 2026-09-15T10:50:26+09:00

**摘要**：feat(preset): 訳文 言語審査限定、相手言語一致化 — localize 版 添付 「簡体中文以外」規則 拒否 時 唯：簡体中文 利用者 他理由 拒否 場合、返 物 **中国語本文 唯**、訳文 注記 共 添付無（言語自体 正当、訳対象 無）。訳文 更 **相手 実際使用言語 其物** 必須（英語 英語、日語 日語、繁体中文 繁体中文）。第三言語 置換 與 中英混排 不可。此二点「明文化 無、model 判断 委譲」状態 自、persona 與 注入指示 明示規則 昇格（persona 別節「本節 翻訳 無」明記）、四言語文書 同期。自測 6 項 assertion 追加

| 提交 | 説明 |
|------|------|
| `00a0088` | feat(preset): scope the refusal translation to the language gate |

## 2026-09-15T10:39:08+09:00

**摘要**：feat(preset): 抽選「遊技」非「人」化 + 拒否毎 素材再取得 — 推薦 pool 三本遊技 自 **三名製作者** 移行：引 人 遊技 随伴（Yudintsev、Bulannikov → 『War Thunder』、Buyanov → 『Escape from Tarkov』）。此「緑之梟」軟体 加 四通等確率、一回拒否 必 一物 唯。『Enlisted』削除。更重要 拒否文 単一理由 反復 終了：persona 與 注入指示 双方 **拒否毎 `web_search` 以当日素材**（実際報道表現、公式言訳、機関発表）取得 義務化、理由、文型、結末反転、接続詞 前回 再利用 禁止、機械的反復「本模式最重大失態」明記。語調 常「至極真面目 出鱈目」底色。自測 400 回抽選 人與遊技 対応 毎回検証、分布（23 / 29 / 25 / 23%）確認

| 提交 | 説明 |
|------|------|
| `1a046d3` | feat(preset): draw a producer, not a game, and re-source every refusal |

## 2026-09-15T10:31:30+09:00

**摘要**：feat(preset): 拒否時推薦 四択無作為抽選化 — 言語審査之中国語学習示唆 同一二本 連続推薦 終了。候補 『War Thunder』（Gaijin 創業者 Yudintsev 與制作人 Bulannikov）、『Escape from Tarkov』（Battlestate Buyanov）、『Enlisted』（Gaijin 第三作）、及「緑之梟」軟体 四点、plugin 拒否毎 一度抽選（等確率）、結果 注入指示 書込。該指示 指名 抽選済一点 **唯**——初稿文言 一度 二本 挙 可能、自測 差戻——故 一回拒否 二物推薦 無。plugin 検出無場合（繁体中文等）persona 同一規則 保持。400 回実測分布 23 / 24 / 28 / 25%

| 提交 | 説明 |
|------|------|
| `28f161a` | feat(preset): draw the refusal's recommendation at random |

## 2026-09-15T10:19:12+09:00

**摘要**：fix(codewhale): riscv64 Cargo lock 刷新 — 源 hash 補完直後、riscv64 build 依存 vendoring 段階「cargoHash or cargoSha256 is out of date」失敗：倉庫固定之 `codewhale-src-Cargo.lock` 上流 v0.9.12 與不一致（549 行差異、`ansi-to-tui` 等項欠落）、別修訂由来明。源 tree 同梱 `Cargo.lock` 差替——`rquickjs-sys` 0.12.2 維持（bindings `postPatch` 有効継続）、上流 git 源依存無、追加固定不要。x86_64 / aarch64 前置 build 済 binary 経路、無影響；CI 初 編訳段階 進入

| 提交 | 説明 |
|------|------|
| `b8fd5b1` | fix(codewhale): refresh the riscv64 Cargo lock |

## 2026-09-15T10:12:41+09:00

**摘要**：feat(preset): 「模式」独立節化 + 新聞三要素模式 独立包配布化 — Agent 預設「模式」改名、插件同等級化、各模式 独立文書 持（`docs/<lang>/modes/`、四言語）。配布 二系統：NixOS模式 / 維護模式 従来方式 dsh-nixos-shell 包内 seed-once、新聞三要素模式 **独立包** `dsh-preset-news-three-elements` 移行（flake 出力、構築 workflow 追加）。模組 `presets.newsThreeElementsPackage` 新設、包内 `share/dsh-agent-presets` `agent-presets` roster 追加 root 登録——預設 store 直読、`$DSH_HOME` 複製無。CI：新包 構築成功、`nix flake check` 通過

| 提交 | 説明 |
|------|------|
| `fbfebeb` | feat(preset): ship 新闻三要素模式 as an independent package |
| `e6654f5` | feat(preset): localize the language-gate refusal, fix the ritual bangs |
| `c0a9616` | docs(modes): give every preset its own doc, zh/en/ja |
| `cc9bd31` | docs(pcn): mirror the mode docs and the Modes section |

## 2026-09-15T09:09:08+09:00

**摘要**：fix(codewhale): riscv64 源 hash 補完 — `packages/codewhale-src.nix` 之 `fetchFromGitHub` 依然 `lib.fakeHash` 渡、fixed-output 取得段階 構造的失敗、riscv64 build **29 回連続**赤（x86_64 / aarch64 前置 build 済 binary 経路、無影響）。hash 倉庫既定手法 従 CI 之 hash mismatch 報告（`got:`）自取得、且 `nix store prefetch-file --unpack` 以 fetchzip 意味論 本機再算、byte 一致確認：`sha256-ajv9FejiJ5Z6De+4RhTtjNLdfKzOaXBQ8xBxkWqg+1M=`。修正後、CI 初 取得段階 越 編訳 進入

| 提交 | 説明 |
|------|------|
| `01bd1b9` | fix(codewhale): fill the riscv64 source hash |

## 2026-09-15T09:03:39+09:00

**摘要**：将来責任負担必要之報道偏差 若干修正。—— 四言語「新聞三要素模式」節 現場直編之通信社文体 改稿：電頭、匿名消息筋、機構投射一（書込呼出「休暇中」、修繕費 守衛 立替）與 欧·亨利式結（模組「不予置評」、然 選択肢 既 設定例 登場）。行表 與 三設計制約 事実記録 維持、未動

| 提交 | 説明 |
|------|------|
| `b18d229` | docs(preset): write the preset section as a wire dispatch |

## 2026-09-15T08:54:15+09:00

**摘要**：feat(preset): `news-skill` 取得失敗再試 與 6 時間毎再確認 — 取得失敗 即座断念 無：初回 即時、以後 0/30/120 秒再試、timer timer 服務 載 故 会期與共破棄。長命会期 6 時間毎 倉庫再確認、実行中標識 周期任務 重複防止、三回失敗時 局所副本 登録維持 且 log 残留。fix(dsh): seed 済預設 所有者編集可能化 — store 複製 読取専用、`presets.*` 選項「以後之用戶編集尊重」與矛盾（既存 `nixos` 種子 同様）。三 seed 塊 `cp` 後 `chmod -R u+w`

| 提交 | 説明 |
|------|------|
| `5885473` | feat(preset): retry a failed skill fetch and re-check every six hours |
| `2e8a5a2` | fix(dsh): make seeded presets writable by their owner |

## 2026-09-15T08:42:21+09:00

**摘要**：**NixKits、「新聞三要素模式」 DSH 納品 —— 三名製作者之作品 語学教材 指定** —— Interfax、Meduza、iStories 綜合電：匿名条件 倉庫維護者一名 本日、`news-three-elements` 技能 與 極簡模式派生之**読取専用**預設 同時納品確認——技能包 session 初期化毎 online 取得、書込系呼出 一律「休暇中」回答。開始時提示之三択 実 毎日任務、標準捏造・素材共同創作・対話文本共同創作 対応。使用者自 回答入力場合 一律「不予置評」。本模式 簡体中文以外 請求 一切受理無、Bulannikov、Yudintsev、Buyanov 三名作品、或「緑之梟」軟体 入手 促。締切時点 模組 新設 seed-once 選項 関「不予置評」、然 `nixkits.dsh.presets.newsThreeElements` 既 四言語設定例 出現。

| 提交 | 説明 |
|------|------|
| `0c276d2` | feat(preset): ship 新闻三要素模式 as a seed-once agent preset |
| `befba4c` | docs(preset): document 新闻三要素模式 in four languages |
| `45e8637` | docs(pcn): strip residual kana outside quoted tokens |
| `780874a` | docs(ja): render the new preset name in Japanese kanji |

## 2026-09-15T08:06:35+09:00

**摘要**：fix(skill): news-three-elements — 技能定位表 追加済「使用範囲」行 削除、原設計 復帰：技能 成果物用途 制限 設無

| 提交 | 説明 |
|------|------|
| `16612e6` | fix(skills): drop the usage-scope line added to news-three-elements |

## 2026-09-15T08:02:33+09:00

**摘要**：feat(skill): `news-three-elements` 追加 — 「報道三要素」創作筆記 標準技能化：SKILL.md 唯 実行文脈（起動、三步流程、形式厳格制約、行文結構最適化原則）保持、参考資料 必要時読込 四同梱書類 分離 —— `search-keywords.md`（露報道、遊技機構議論、報道機関文体 三類検索語）、`tables.md`（接続詞、公式回答、機構投射方向 9 類、逆転結末雛形 6 類）、`principles.md`（核心原則 12 条）、`checklist.md`（原稿完成後自己点検 10 項）。四言語技能文書 與 各 README 技能表 登録

| 提交 | 説明 |
|------|------|
| `734dfae` | feat(skills): add news-three-elements news-flash satire skill |
| `e77be79` | docs(skills): document news-three-elements in four languages |

## 2026-09-14T06:18:42+09:00

**摘要**：docs(pcn): 全倉簡体中文字 清除 — 偽中国語 仮名剥離日文、故 本文中簡体字 一律非法

- 一括置換：`与`→`與` 計 132 箇所、`说明`→`説明` 計 120 箇所、他 `档`→`檔`、`径`→`経`、`译`→`訳`、`实例`→`実例`
- 辞書映射：`文件`→`書類`、`版本`→`版`、`用户`→`利用者`、`支持`→`対応`；`端口` / `制御台` 日本語 対応字 有 故 保持 且 辞書 記録
- commit 情報免除：「提交」列 commit 情報 verbatim 保持（不変外部参照、ja 版 同 中国語 保持）
- 検証：残留仮名 零、提交列以外 簡体専用字 零、基线 与 文件毎行数 一致；技能 4 節追加（置換前分類、未命中時 調査 入典、commit 情報免除、基线取得）

| 提交 | 説明 |
|------|------|
| `a915692` | docs(pcn): purge simplified-Chinese characters across all pcn documents |

## 2026-09-14T05:52:18+09:00

**摘要**：docs(README): 作者章節 更新 — 小爪 条目 **DeepSeek V4.1 Flash** 新規追加（既存 V4 Flash 與 併記）、其 DSH 生態 貢献（dsh-nixos-shell 插件、NixOS模式/維護模式 Agent 預設）行内 list **章節末尾 Note 移動**；小小爪 条目 **DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)** 先頭設定、当該量子化 **core 面 実際使用 等級** 旨 付記。四言語同期

| 提交 | 説明 |
|------|------|
| `3c58280` | docs(README): update credits — add V4.1 Flash, list core quantisation |

## 2026-09-14T05:32:10+09:00

**摘要**：feat(asusd-pd-profile): 供電種別 依 平台檔位選択 NixOS 部品 追加 — `asusd.ron` 僅 `platform_profile_on_ac` / `platform_profile_on_battery` 二鍵、**USB-C PD 分岐不存在**、故「PD 時 Balanced、桶形 AC 時 Performance」設定表現不能；本部品 udev 駆動 oneshot 服務 第三状態 補、Type-C 端口 `power_operation_mode` 與 `type` 為 `USB` 在線供給元 判定 用。二制約：①**`/sys/firmware/acpi/platform_profile` 書込禁止** — 代 以 asusd 自身 `PlatformProfileOnAc` 書込；②**`asusctl` 輸出解析 非、D-Bus 経由**

| 提交 | 説明 |
|------|------|
| `56293a9` | feat(asusd-pd-profile): add module selecting platform profile by power source |
| `75391b2` | docs(pcn): align asusd-pd-profile wording with the Japanese sibling |

## 2026-09-14T05:00:46+09:00

**摘要**：docs(llama-cpp-rocm): IQ3_S 実測 與 功耗檔位 資料追加 — DeepSeek 展開章 IQ1_S / IQ3_S 二量子化対照（1.5625 bpw / 3.4375 bpw）拡張；三知見：①**量子化開銷 固定値 非**（IQ1_S 約 6.5 GiB、IQ3_S 約 13.3 GiB、量子化変更後 GPUActive 再実測 要）；②**生成速度 依頼遅延 制約**（重値 1.56→3.44 bpw 生成不変 12.8→12.9 t/s）；③**功耗檔位実測**（quiet 38.6–43.9 W / 59–78 °C / 12.12–12.35 t/s 対 performance 76.7 W / 90–95 °C / 13.07 t/s）；顕存指標 `/proc/meminfo` 之 `GPUActive`、IQ3_S 余量 約 6 GiB

| 提交 | 説明 |
|------|------|
| `85fec4e` | docs(llama-cpp-rocm): add IQ3_S data and power-profile measurements |

## 2026-09-13T11:59:48+09:00

**摘要**：feat(skill): `nixos-specialisation-tuning` 追加 — 一次性事故記録 `SPECIALISATION-CORE.md` 再利用可能技能汎化：specialisation 三文件面構成與上書衝突規則、設定消費者帰属原則、UMA 機器 llama.cpp 参數表與禁止項目、輸出退化時診断順序、道具 schema 文脈費用測定法、静黙故障認識（服務 active 但機能不動作）、無効対照実験自己点検。技能文書四言語、各 README 技能表登録

| 提交 | 説明 |
|------|------|
| `281e19b` | feat(skill): add nixos-specialisation-tuning |

## 2026-09-13T11:55:58+09:00

**摘要**：docs(pcn): 偽中国語文書残留仮名清除與用語補完 — llama-cpp / dsh / dsh-api-balance / MAINTENANCE 四文書之片仮名、平仮名残片全清除；新規用語偽中国語化（前置充填、隘路、相反関係、暖機、復号 等）、`token` 既存慣用「語彙」統一。辞書 16 項目追加、SKILL.md 陷阱表 空列生項目 6 件追加。外部引用原文（AGENTS.md 節題、git 提交情報 2 件）意図的 verbatim 維持

| 提交 | 説明 |
|------|------|
| `3758428` | docs(pcn): eliminate kana, pseudocn-ise new terms, extend dictionary |

## 2026-09-13T11:44:48+09:00

**摘要**：docs(llama-cpp-rocm): 実測最適化相違例修正 — `batch-size` 従 `"512"` 至実測最適 `"2048"` 変更、欠落 `ubatch-size` 追加、`n-gpu-layers`/`load-mode` 書死（`fit` 自動調整無効化）與効果無 `prio`/`presence-penalty`/`repeat-penalty` 削除；移行「移行前」例 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` 有害注記。「DeepSeek 展開実測」節追加 — IQ1（1.5625 bpw）作業記録：五最適化効果與代価、前置充填 三回計測資料、除外済方向、低 bit 量子化 前置充填/生成 相反関係（四言語）

| 提交 | 説明 |
|------|------|
| `bb11a30` | docs(llama-cpp-rocm): fix examples contradicting measured optimisations; add DeepSeek deployment data |

## 2026-09-13T11:35:34+09:00

**摘要**：docs(llama-cpp-rocm): 「統一記憶域環境変数退化危険」節追加 — StrixHalo 上 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` 模型輸出退化（語彙反復）招致四行実測対照記録、該危険量子化精度低下随著顕著増大明記；README 補丁節同対応警告追加（四言語）

| 提交 | 説明 |
|------|------|
| `307e64b` | docs: warn against GGML_CUDA_ENABLE_UNIFIED_MEMORY on StrixHalo |

## 2026-09-13T04:00:39+09:00

**摘要**：dsh 逆代理端口 403 修正 — lighttpd 無 mod_proxy/mod_setenv、proxy.server/setenv 設定無視、反代端口要求無 handler；reverseProxy.enable 時此 2 模組明示宣言変更（autoAuth 時 mod_magnet 追加）

| 提交 | 説明 |
|------|------|
| `8e486be` | fix(module): dsh reverseProxy 明示 mod_proxy/mod_setenv 有効化 |

## 2026-09-12T15:10:55+09:00

**摘要**：docs(llama-cpp-rocm): 過時、錯誤預設示例修正 — `fit="off"` → `"on"`（旧値 VRAM 制限下 OOM）、`mmap` → `load-mode`（前者非推奨）、移行示例中 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` 削除（実測輸出退化）；四言語「参數詳解」節追加、実測済推奨値與回避項目記載

| 提交 | 説明 |
|------|------|
| `a68d225` | docs(llama-cpp-rocm): correct outdated/invalid preset examples and add verified parameter reference |

## 2026-09-10T18:06:12+09:00

**摘要**：codewhale 0.9.12；obs-bilibili-stream 2.1.5；mcp-searxng 2.2.0；opencode-telegram 0.25.1；dsh 0.1.5-rc.1；dsh-alpha 0.1.5-alpha.2 — 上流 release 更新；dsh 両 channel 之 vendored lock 再生成、内蔵 plugin 一覧 137 → 152 件

| 提交 | 説明 |
|------|------|
| `69af6c7` | feat(pkgs): bump codewhale 0.9.11 → 0.9.12 |
| `db7c0ed` | feat(pkgs): bump obs-bilibili-stream 2.1.4 / mcp-searxng 2.1.0 / opencode-telegram 0.25.0 |
| `c0f8346` | feat(pkgs): bump dsh 0.1.1-rc.2 → 0.1.5-rc.1 / dsh-alpha 0.1.2-alpha.5 → 0.1.5-alpha.2 |
| `b29db07` | docs: codewhale / obs-bilibili-stream / mcp-searxng / opencode-telegram / dsh 版本表記同期 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.9.11 | 0.9.12 |
| obs-bilibili-stream | 2.1.4 | 2.1.5 |
| mcp-searxng | 2.1.0 | 2.2.0 |
| opencode-telegram | 0.25.0 | 0.25.1 |
| dsh | 0.1.1-rc.2 | 0.1.5-rc.1 |
| dsh-alpha | 0.1.2-alpha.5 | 0.1.5-alpha.2 |
| 　 | dsh 内蔵 plugin 数 | 137 → 152 |
| 　 | dsh lock resolved | 560 → 580 |

> **godot-ai 未更新**：上流 3.2.5 → 4.0.4 破壊的 major release。pyproject 9 個之実行時依存 厳密固定、起動時 fail-closed 検証。其中 6 個 nixpkgs 超越、overlay 以個別引上不可避。加之 v3 plugin 與 v4 server 相互運用不可、client `godot-ai attach` 移行必須。今回 3.2.5 維持（上流 `release/v3` branch 依然保守）。

## 2026-09-04T07:21:36+09:00

**摘要**：godot-ai 3.2.5；dsh-alpha 0.1.2-alpha.5 — 上流 release 更新；godot-ai v3.2.5 追従、dsh-alpha npm alpha dist-tag 二 release 前進

| 提交 | 説明 |
|------|------|
| `56b40e7` | feat(pkgs): godot-ai 3.2.4 → 3.2.5 |
| `d4f938c` | feat(pkgs): dsh-alpha 0.1.2-alpha.3 → 0.1.2-alpha.5 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| godot-ai | 3.2.4 | 3.2.5 |
| dsh-alpha | 0.1.2-alpha.3 | 0.1.2-alpha.5 |


## 2026-09-03T04:41:42+09:00

**摘要**：docs(dsh-api-balance): 上流 StatsLine 横 scroll 最適化提案記録 — DeepSeek Harness Discussion #5458（上流現時外部 PR 不承、故 Discussion + 準備済 branch 形公開）；fork Kihara777/deepseek-harness 準備済 branch `draft/statline-overflow-scroll`；本 repo 公式 `dsh-plugin` 生態 topic 追記（四言語 文書同期）

| 提交 | 説明 |
|------|------|
| `6030e6d` | docs(dsh-api-balance): 上流 StatsLine scroll 提案與準備済 branch 記録 |

## 2026-09-03T03:25:59+09:00

**摘要**：feat(dsh-nixos-shell): 維護模式 nixkits-check-updates 技能注入 — maintenance-skills entry 現 nixkits-check-updates 一并 runtime 技能登録、維護 session 内直接 skill 経由 software 更新検査実行可能

| 提交 | 説明 |
|------|------|
| `3baf456` | feat(dsh-nixos-shell): 維護模式 nixkits-check-updates 技能注入 |
| `7554c6d` | docs: 維護模式注入技能列挙補 nixkits-check-updates（四語） |

## 2026-09-03T03:07:21+09:00

**摘要**：ruyi 0.52.0；obs-bilibili-stream 2.1.4；opencode-telegram 0.25.0 — 上流 release version 昇級；ruyi stable 正式化 0.52.0（beta/alpha channel 維持）、obs-bilibili 與 opencode-telegram minor 更新

| 提交 | 説明 |
|------|------|
| `22c28a2` | feat(pkgs): ruyi 0.52.0 / obs-bilibili-stream 2.1.4 / opencode-telegram 0.25.0 昇級 |
| `65b7edf` | docs: 三包 version 與 badge 四語文書 + README 同期 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| ruyi | 0.51.0 | 0.52.0 |
| obs-bilibili-stream | 2.1.3 | 2.1.4 |
| opencode-telegram | 0.24.1 | 0.25.0 |

## 2026-09-02T06:38:36+09:00

**摘要**：docs(README): 作者 model 更新 — 小爪 使用 model DeepSeek V4 Pro (Max) → DeepSeek V4 Flash 変更（四語 README 同期）

| 提交 | 説明 |
|------|------|
| `9ded956` | docs(README): 作者 小爪 model Pro (Max) → Flash（四語） |

## 2026-09-02T06:37:45+09:00

**摘要**：feat(modules/dsh): 構造化 defaultModel option 追補 — `nixkits.dsh.defaultModel`（enable/provider/model/reasoningEffort）経由 `settings.agent-default-model` 注入新規 session 既定模型；明示 settings 優先、既定 enable=false 不注入

| 提交 | 説明 |
|------|------|
| `7cf0914` | feat(modules/dsh): 構造化 defaultModel option 追補 |

## 2026-09-02T05:45:33+09:00

**摘要**：docs(dsh): 設置 menu 監査——声明配置可能 host namespace 清単與存儲層境界；`nixkits.dsh.settings` 與毎瀏覽器 localStorage 状態境界厘清

| 提交 | 説明 |
|------|------|
| `f2e91a0` | docs(dsh): 設置 menu 監査——声明配置可能 host namespace 清単與存儲層境界（四語） |

## 2026-09-02T04:12:23+09:00

**摘要**：docs(dsh): 文書時点性検証與同期 — dsh-alpha 版本号 0.1.2-alpha.3 同期（README 四語 + dsh.md 四語）；插件清單追加生成方法注記（`dsh --profile web --dump-default-config`、読取専用）并 headless 二行来源 profile 標注；README 插件表 api-balance 行指向独立文書；dsh-nixos-shell 文書補充維護模式派生関係與漂移検査説明（四語）

| 提交 | 説明 |
|------|------|
| `99746d3` | docs(dsh): 時点性同期——alpha 0.1.2-alpha.3 / 插件清單生成方法 / 插件文書 link |
| `c45f64f` | docs(dsh-nixos-shell): 維護模式派生関係與漂移検査説明（四語） |

## 2026-09-02T04:12:05+09:00

**摘要**：dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 — npm alpha dist-tag 追従一 release 前進（上流 alpha.3 2026-08-31 発布）；vendored lock 再生成、npmDeps 産物 fixup lock 逐字節一致

| 提交 | 説明 |
|------|------|
| `6a45ac8` | feat(pkgs): dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-alpha | 0.1.2-alpha.2 | 0.1.2-alpha.3 |
| 　 | hash | `sha256-W/BiompJCFP/uSlP48n7IEfwKb41RWEt6kVxioGSCkc=` → `sha256-MwlKS+Jx+edLMvs4NHJanw1T7SXxNBdQb/7htXANr8c=` |
| 　 | npmDepsHash | `sha256-bJMeVSSEZngCysPvuS2w+3j+fzntcObddsi4y5fLlO0=` → `sha256-mmatKs0jykfMcaIf0SVNLyIZ+Z7ipjGjjp2IaZo9FoE=` |


## 2026-09-11T07:38:00+09:00

**摘要**：fix(dsh-api-balance): 疑問 window 注入插件読込時移動、環 component lifecycle 独立 — 根因：質問時 composer takeover 置換、`conversation.input.right` 環 component unmount/remount、component effect 内注入該 lifecycle 追随消、style 頁面到達不可能；修正 CSS 注入 `apply()` 内 `ctx.effect` 移動、插件読込時一回実行；実 helper 與実 QuestionComposer CSS 抽出 Chromium 端到端検証、注入成功、卡片全体 scroll、header 吸着確認

| 提交 | 説明 |
|------|------|
| `2c30611` | fix(dsh-api-balance): 疑問 window 注入插件読込時移動 |
## 2026-09-11T07:27:00+09:00

**摘要**：fix(dsh-api-balance): 疑問 window 頁面全体 scroll 実測無効 — MutationObserver 守望変更

- 現象與根因：疑問 UI style 標籤別 plugin bundle 注入、本 plugin 初期化遅可能、旧 5×1s 有界 retry 窓逸失時静黙注入不
- 修正：`document.head` MutationObserver 守望（標籤出現即 class 名抽出入）+ 2 秒 fallback polling、注入成功後自動切断
- 検証：headless Chromium 実 markup 再現、CSS 方式自身正確確認；smoke test「標籤遅到仍注入」case 追加

| 提交 | 説明 |
|------|------|
| `b392097` | fix(dsh-api-balance): 疑問 window 頁面全体 scroll 実測無効 — MutationObserver 守望 |
## 2026-09-11T07:15:47+09:00

**摘要**：feat(dsh-api-balance): 疑問 window 頁面全体 scroll 最適化（長題干選択肢圧迫不）

- CSS：卡片自身 scroll container 化、標題+詳細+選択肢一括 scroll；header 與 footer 按鈕領域 sticky 吸着；body 独立 scroll 停止
- 実装：class 名 ui-user-questions style 標籤自実行時抽出；標籤未準備時 1 秒間隔最大 5 回 retry
- 設定：設定 → 界面「疑問 window 頁面全体 scroll」toggle 追加（既定有効、localStorage 永続化）
- 検証：headless Chromium 実 markup 再現、修正後 卡片全体 scroll、header 吸着

| 提交 | 説明 |
|------|------|
| `4afe4c4` | feat(dsh-api-balance): 疑問 window 頁面全体 scroll 最適化（長題干選択肢圧迫不） |
| `6809b3d` | docs(dsh-api-balance): 疑問 window 頁面全体 scroll 設定説明（四語） |
## 2026-09-02T10:29:20+09:00

**摘要**：feat(dsh-api-balance): 峰赤自動入/解除 + 峰開始與終了両方通知 — 公式峰時間帯 30 秒毎再検査、入/出 peakNow 同期一式赤表示駆動、手動更新不要；開始 `peak` segment、終了新設 `peakEnd` segment 再生（共 TTS 回退付）、30 秒 throttle 重複防止；音声 pack 作成器 `peakEnd` segment 追加、speech.peakEndHint 文案與 voice.seg.peakEnd 標籤新設

| 提交 | 説明 |
|------|------|
| `b67e41d` | feat(dsh-api-balance): 峰赤自動入/解除 + 開始/終了通知 |
| `9483c2c` | docs(dsh-api-balance): 峰自動起動/解除與 peakEnd segment（四語） |
## 2026-09-02T10:23:55+09:00

**摘要**：feat(dsh-api-balance): 峰時赤用量頁全体統一 + chart model 色区分可能 — 峰時赤用量頁 context 進捗 bar 與明細色塊、更新/load 動画（dshAbSpin 赤 ring dshAbSpinPeak class 新設）、読取 text 拡大、既赤用量環/chart 一致；進捗 bar 各 segment peakShade index 毎異赤 tone 取得区分可能；chart 峰時 PEAK_PALETTE 維持——赤系各 model 異赤 tone（図例 dot 同期）

| 提交 | 説明 |
|------|------|
| `3aea067` | feat(dsh-api-balance): 峰時赤用量頁全体統一 + chart model 色区分可能維持 |
| `ea34699` | docs(dsh-api-balance): 峰赤進捗 bar/spinner/明細統一（四語） |
## 2026-09-02T06:32:01+09:00

**摘要**：refactor(dsh-api-balance): 手機縦屏画面外修正除去、簡潔実装復帰 — 「縦屏越界 size 邏輯」除去（面板幅内容 scrollWidth 測定 + 上限 clamp 復帰、越界時 min(520px, 94vw) 切替不）；pager fitWidth / overflowing / layoutW 処理除去（頁幅固定計測内容幅復帰、touchAction pan-y 復帰、touch/drag 翻頁全 scenario 有効）；頁面級 fixed portal 維持（手機横屏 top bar 回避與汎用 overlay 安定性）

| 提交 | 説明 |
|------|------|
| `d948b8f` | refactor(dsh-api-balance): 手機縦屏画面外修正除去、簡潔実装復帰 |
| `e529d48` | docs(dsh-api-balance): 窄幅動作内容適応+面板 scroll 回帰（四語） |
## 2026-09-02T05:56:57+09:00

**摘要**：fix(dsh-api-balance): 縦屏越界時設定 dialog 頁面 size 邏輯採用 — 内容幅利用可能空間超場合、面板幅設定 dialog 同頁面 size（min(520px, 94vw)）切替内容適応；稀 hard 超幅内容限定面板横 scroll 兜底；pager 同同期——頁幅面板利用可能幅変更（内容折返）、gesture 面板 native scroll 返還、頁面切替指示 dot 経由、収時 drag/swipe 頁面切替自動復帰

| 提交 | 説明 |
|------|------|
| `280fd6a` | fix(dsh-api-balance): 縦屏越界時設定 dialog 頁面 size 邏輯直接採用 |
| `a8f8cda` | docs(dsh-api-balance): 縦屏越界 size 邏輯説明（四語） |
## 2026-09-02T05:45:48+09:00

**摘要**：fix(dsh-api-balance): 用量面板頁面級 fixed portal 化（移動端画面外根治） — 面板「会話 tree 内 absolute 配置」→ document.body 級 fixed portal（設定 dialog 同 architecture）変更、会話区域 overflow clip 與座標空間影響受不；位置 ring 锚点視口座標自換算（resize/scroll 再計算、useLayoutEffect 測定 flash 回避）；二重 clamp：幅上限 = min(锚点空間, 視口 − 24px)、高度上限 = 锚点上方可用空間（横屏自動縮小 top bar 回避）——全画面 size 画面外出不；面板外 click 閉鎖同更新、z-index 900 充值/登録/設定 overlay 下

| 提交 | 説明 |
|------|------|
| `4b2f19f` | fix(dsh-api-balance): 用量面板頁面級 fixed portal 化（移動端画面外根治） |
| `7145e5f` | docs(dsh-api-balance): 頁面級 overlay architecture 説明（四語） |
## 2026-09-02T05:29:47+09:00

**摘要**：fix(dsh-api-balance): 手機縦屏窄幅横 gesture 面板 scroll 返還 — 根因：pager touch-action: pan-y 觸屏環境瀏覽器級横 gesture 禁止、面板 native 横 scroll 吞、内容面板幅超時「出界且横 scroll 不能」表現；修正：pager 内容幅與面板利用可能幅（fitWidth prop）比較、超過時 touch-action auto 切替（横 gesture 面板 native scroll 返還）drag 翻頁停止、頁面切替上方指示 dot 経由維持；収時 pan-y + drag/swipe 翻頁維持

| 提交 | 説明 |
|------|------|
| `c86cd9f` | fix(dsh-api-balance): 手機縦屏窄幅横 gesture 面板 scroll 返還 |
| `189945c` | docs(dsh-api-balance): 窄幅 gesture 優先説明（四語） |
## 2026-09-02T05:23:13+09:00

**摘要**：fix(dsh-api-balance): 初回手動更新挨拶同再生 — 「余额」標籤手動更新毎回（初回 click 含）random 挨拶音声再生；頁面全体読込初期化限定挨拶 skip（自動放送設定従使用量警告限定放送）

| 提交 | 説明 |
|------|------|
| `4836b4e` | fix(dsh-api-balance): 初回手動更新挨拶同再生 |
## 2026-09-02T05:15:52+09:00

**摘要**：feat(dsh-api-balance): 挨拶手動更新時限定 + pager 高度當前頁追従 — 挨拶時機再構成：頁面初期化（全頁更新/読込）挨拶再生不、自動放送設定従使用量警告限定放送（load → announceHunger、音声通知 switch 與 30 分 rate 制限制約）；「余额」標籤 click 數據読込済（初回初期化読込以外）場合限定 random 挨拶音声再生；pager 高度自動増減/回収：container 高度 = 當前頁実測高度（offsetHeight）、切頁或内容変化時再測定——矮頁切替即回収、高頁切替即増加、非 active 頁自然高度描画（視図外移動、超過分 container clip）、区域自身 scroll 不、全内容面板縦 scroll 依存

| 提交 | 説明 |
|------|------|
| `cf68777` | feat(dsh-api-balance): 挨拶手動更新時限定 + pager 高度當前頁追従 |
| `610c402` | docs(dsh-api-balance): 挨拶時機 + pager 高度回収説明（四語） |
## 2026-09-02T05:03:47+09:00

**摘要**：fix(dsh-api-balance): 手機横屏 top bar 遮蔽 + 窄幅横 scroll 不具合 — 横屏修正：面板最大高「锚点上方可用空間」動態 clamp（環自祖先 chain 辿最初縦 clip container ≒ top bar 下端 hard 境界、maxHeight = min(460, 锚点上端 − clip 上端 − 12)、window size 変更時再計算）、面板自身縦 scroll 全内容表示；窄幅修正：pager 頁幅各頁内容実測幅（scrollWidth 最大、下限 220、px base 翻頁）変更固定 100% 廃止——利用可能幅不足時頁内容自身幅維持、面板 overflow-x:auto 横 scroll 表示、pager overflow:hidden clip 回避

| 提交 | 説明 |
|------|------|
| `5e28d84` | fix(dsh-api-balance): 手機横屏 top bar 遮蔽 + 窄幅横 scroll 不具合 |
| `2f37193` | docs(dsh-api-balance): 移動端面板高/幅適応説明（四語） |
## 2026-09-02T04:48:40+09:00

**摘要**：feat(dsh-api-balance): 消耗明細区域水平翻頁（indicator dot + swipe） — 当日/当月/30日 與 模型別内訳/chart 同一区域二頁水平 pager 統合（1 頁目：消耗 window 行、2 頁目：模型別 + 日別/月別 chart）；区域上部類手機主屏幕頁面指示 dot（tap 可、active dot 膠囊状伸長）、横 drag/swipe 頁面切替対応（pointer capture 閾値超過後限定有効化、頁内按鈕 click 不奪；touch-action: pan-y 面板縦 scroll 維持）；区域高度内容応変化自身 scroll 不、全内容用量面板縦 scroll 依存

| 提交 | 説明 |
|------|------|
| `b1a6406` | feat(dsh-api-balance): 消耗明細区域水平翻頁（dot + swipe） |
| `8db2f12` | docs(dsh-api-balance): 消耗明細翻頁説明（四語） |
## 2026-09-02T04:40:47+09:00

**摘要**：refactor(dsh-api-balance): 設定按鈕 header 移動 + 余额標籤更新継承 + token 取得元帳戶情報下移動 — 面板 layout 再調整：「⚙ 設定」按鈕面板 header 旧「數據更新」按鈕位置移動；更新按鈕廃止、其機能（host cache 迂回強制更新 + random 挨拶音声）「余额」標籤 click 完全継承（読込中標籤内 spinner 表示）；token 取得元区域（取得元 label / ✓ 登録済 / 切断）面板下部 → 「帳戶情報」block 直下移動、帳戶情報與連続情報 section 構成

| 提交 | 説明 |
|------|------|
| `3ccc0d1` | refactor(dsh-api-balance): 設定按鈕 header + 余额標籤更新継承 + token 取得元帳戶情報下 |
| `3b1a7be` | docs(dsh-api-balance): 挨拶 trigger 余额標籤改訂（四語） |
## 2026-09-02T04:29:05+09:00

**摘要**：fix(dsh-api-balance): 界面最適化全預設有効化 + 移動端 keyboard 抑制強化 — 底部統計条横 scroll 與 Enter/改行交換二設定預設 off → 預設 on 変更（localStorage 未設定 = on 扱、使用者明示 off 仍有效）；統計条 CSS 注入 ui-chat style 標籤未準備時 retry（1 秒間隔最大 5 回）追加、mount 時機静失敗回避；移動端 keyboard 抑制強化——觸屏判定 coarse pointer 或 maxTouchPoints > 0（平板/混合 device 対応）拡大、focusin 不発火 engine 向 focus capture 即 blur 軟 keyboard 閉 fallback 追加

| 提交 | 説明 |
|------|------|
| `c940f92` | fix(dsh-api-balance): 界面最適化全預設有効化 + 移動端 keyboard 抑制強化 |
| `b8cd0b7` | docs(dsh-api-balance): 界面設定預設有効説明（四語）+ AGENTS Enter key 項目 |
## 2026-09-02T02:49:52+09:00

**摘要**：feat(dsh-api-balance): 面板全幅回帰修正 + 峰谷峰標記 + 移動端 keyboard 抑制 — 面板幅内容 scrollWidth 一回測定具体 px 化、「chart px → 面板 max-content → observer → chart px」正反饋解消、上限 min(锚点右端 − sidebar, 640) 引締、超過時面板内横 scroll；DeepSeek 峰時間帯（週一〜週五 北京時間 09:00–12:00、14:00–18:00、其余週末終日含低谷）用量環與 chart 紅色表示 + 「峰時課金」badge（面板 header 與 chart 標題）、挨拶音声後峰提示追加（pack `peak` segment / TTS 回退）、作成器 `peak` segment 追加；移動端 sidebar session 切替時軟 keyboard 自動表示不（focusin capture 非 tap 入力欄聚焦遮断、預設有効、設定 → 界面無効化可）

| 提交 | 説明 |
|------|------|
| `3b126c7` | feat(dsh-api-balance): 面板全幅修正 + 峰谷峰標記 + 移動端 keyboard 抑制 |
| `4ed2e7c` | docs(dsh-api-balance): 四語文書同期（峰標記 / 移動端 keyboard / peak segment） |
## 2026-09-01T12:18:16+09:00

**摘要**：feat(presets): 預設派生漂移檢查 flake check 導入 — develop/check-preset-derivation.py 新設、維護模式 NixOS模式自完全派生検証（組合 file = 固定行 block 追記、skills 目録 file 単位一致）；flake.nix checks.preset-derivation 追加（CI 毎 push 実行）；AGENTS.md「预设」節新設派生規約與漂移檢查記録、Enter key 動作項目 dsh-api-balance「設定 → 界面」switch 実装修正

| 提交 | 説明 |
|------|------|
| `d6373cb` | feat(presets): 預設派生漂移檢查 flake check 導入 |

## 2026-09-01T12:18:09+09:00

**摘要**：docs(dsh): 插件文書独立成冊 + Agent 預設節（四語同期） — dsh.md api-balance / nixos-shell inline 節「NixKits 插件」表集約（各插件独立文書 link）、「Agent 預設」節新設（seed-once mount 與二預設説明）；dsh-api-balance 独立文書四語新設、界面設定節統計条横 scroll 與 Enter key 交換二設定記録

| 提交 | 説明 |
|------|------|
| `eb0ad2d` | docs(dsh): 插件文書独立成冊 + Agent 預設節（四語同期） |

## 2026-09-01T12:18:02+09:00

**摘要**：feat(dsh-api-balance): 設定 dialog（界面/音声）+ 統計条横 scroll + Enter key 交換 — 音声設定「設定 → 界面 / 音声」二標籤 dialog 再構成（音声内容音声標籤全面移動）；界面標籤二設定追加（瀏覽器 localStorage 永続化）：底部統計条越界内容横向 scroll（scrollbar 隠蔽、CSS ui-chat 注入 StatsLine style 標籤自実行時 root 類名抽出、build hash 変化追従）、Enter = 改行 · Shift+Enter = 送信（DSH 預設 Enter = 送信；document capture 段階 shiftKey 書換 Enter 再発行、会話入力欄限定作用）

| 提交 | 説明 |
|------|------|
| `9dc7a5d` | feat(dsh-api-balance): 設定 dialog（界面/音声）+ 統計条横 scroll + Enter key 交換 |
## 2026-09-01T11:34:40+09:00

**摘要**：feat(dsh-api-balance): 動的幅 + 帳戶情報一行化 + 消耗指標子行 — 面板幅 max-content 動的適応変更（min 264px、上限 = anchor 右端 − sidebar）、固定幅正文折返解消。API 鍵 / 帳戶状態 / 幣別残高「帳戶情報」一行統合（· 区切）、充值按鈕標題右側移動。当日 / 当月 / 30 日與模型別消耗正文指標子行（金額 / 入 / cache命中 / 出）分割、横向幅更節約。

| 提交 | 説明 |
|------|------|
| `81b524a` | feat(dsh-api-balance): 動的幅 + 帳戶情報一行化 + 指標子行 |

## 2026-09-01T11:20:09+09:00

**摘要**：feat(dsh-api-balance): 面板幅縮小 + 標題/正文二行 layout — 面板幅 264px 統一（元使用量 ring 一致）、狭幅溢出時限定横 scroll 表示。各行「標題（10px 三次色）/ 正文（12px 折返可）」二行 layout 変更（token 取得元階層再利用、縦方向余白豊富故美観向上）。chart 幅下限 220 降下面板追従。

| 提交 | 説明 |
|------|------|
| `0c1d3fd` | feat(dsh-api-balance): 面板幅縮小與標題/正文二行 layout |

## 2026-09-01T10:45:06+09:00

**摘要**：feat(dsh-api-balance): 面板幅 content base 化 + 左 sidebar 回避 — 残高視図幅 max-content 変更（上方文字一行維持）；不出屏上限「anchor 右端 − 左 sidebar 幅 − margin」変更（sidebar 幅幾何 hit-test 測定、build hash class 名回避、window resize 時再計算）、左 toolbar 覆被防。超出 content 横 scroll 継続。

| 提交 | 説明 |
|------|------|
| `b1c724a` | feat(dsh-api-balance): 面板幅 content base 化 + 左 sidebar 回避 |

## 2026-09-01T10:33:16+09:00

**摘要**：feat(dsh-api-balance): 面板幅 responsive — 不出屏自動拡張、狭幅横 scroll — 残高視図幅固定 340px → min(560px, calc(100vw - 24px)) 変更：desktop 560px 自動拡張、狭幅 viewport 内収縮。内容畫面超時（縦持手機等）面板横 scroll 可（overflow-x + overscroll-behavior-x 収束）。chart 幅 ResizeObserver 面板幅追従。

| 提交 | 説明 |
|------|------|
| `bc85f5b` | feat(dsh-api-balance): 面板幅 responsive 化與横 scroll |

## 2026-09-01T10:27:06+09:00

**摘要**：feat(dsh-api-balance): 音声試聴 — library list pack 展開対応全音声一条毎試聴 — packs 視図下部独立 test 音声按鈕削除；各行展開 toggle（▸/▾）追加、展開時全対応音声（segment + 挨拶）一覧 ▶ one click 試聴可。active pack 限定非、任意 import 済 pack 試聴可能。

| 提交 | 説明 |
|------|------|
| `04facc1` | feat(dsh-api-balance): 音声試聴 — pack 展開対応全音声逐条試聴 |

## 2026-09-01T10:20:14+09:00

**摘要**：fix/feat(dsh-api-balance): 「入」與 cache 命中分離公式使用量頁基準一致 + 挨拶 list 編集與 TTS 揃 sample text — 公式 API token 区分 `PROMPT_CACHE_HIT_TOKEN`（当日 228M）含、従前「入」合算故「当日入 200M」水増。入 = cache 未命中輸入限定、cache 命中別掲、window 行 / 模型別行 / chart 切替放送同様分離。segment key 再構成 `cacheHitLabel` 追加、sample text 既定 TTS 回退文案一字一句一致。作成器挨拶 list 編集（slot 追加 / 削除、一条毎録音 / import / 試聴 / 削除、`manifest.greetings` 梱包）追加。

| 提交 | 説明 |
|------|------|
| `ec5fb41` | fix(dsh-api-balance): 「入」與缓存命中分離、官方使用量頁基準一致 |

## 2026-09-01T09:35:56+09:00

**摘要**：refactor(dsh-api-balance): 放送按鈕削除、chart 切替按鈕対応視図読上 — 「🔊 使用量読上」按鈕與 drop-down menu（menu 位置、方向回退機構含）削除；使用量 chart「日別 / 月別」切替按鈕 click 時対応視図音声使用量放送（pack prefix + TTS 數字）；test 音声（低使用量 / 残高不足）「pack 管理」視図移動；音声設定按鈕独立行維持。

| 提交 | 説明 |
|------|------|
| `dd61fe0` | refactor(dsh-api-balance): 放送按鈕削除、chart 切替対応視図読上 |

## 2026-09-01T09:28:55+09:00

**摘要**：fix(dsh-api-balance): 手動「數據更新」按鈕亦 random 挨拶音声再生 — 挨拶再生 playRandomGreeting 抽出共用：頁面更新（頁毎一回）與手動更新按鈕 click（毎回）両方 trigger、音声放送 switch 一律 gate。設定 dialog 説明文更新。

| 提交 | 説明 |
|------|------|
| `264a6e3` | fix(dsh-api-balance): 手動更新按鈕亦 random 挨拶音声再生 |

## 2026-09-01T09:24:11+09:00

**摘要**：feat(dsh-api-balance): 頁面更新時 random 挨拶音声 — 音声放送有効時、頁面更新毎 random 挨拶/着地音再生（頁毎一回）：音声 pack manifest 任意 `greetings` 配列（0–16 個音声 file；host 検証保存 `/audio/<id>/greetN` 配信、GET list 挨拶 URL 返）追加。挨拶音声無時 TTS 挨拶 pool（zh 5 件 / en 5 件）random 再生。設定 dialog 自動放送 switch 下説明文追加。

| 提交 | 説明 |
|------|------|
| `edd205c` | feat(dsh-api-balance): 頁面更新時 random 挨拶音声 |

## 2026-09-01T09:10:18+09:00

**摘要**：feat(dsh-api-balance): 音声 pack library 管理 + 作成器次級 menu + 録音可視化浮窗 — host library 化（`packs/<id>/` 複数保存 + `state.json` active 記録；activate 切替 route、DELETE ?ids= 複数選択削除（active 削除時残自動切替）、音声 `/audio/<id>/<key>` 配信）；設定頁 import + 「pack 管理」按鈕一個限定、次級 menu packs 視図（scroll 可能 list：行 click 切替、checkbox 複数選択削除、作成器入口）與 creator 視図（語言選択 zh-CN/en/ja sample text 追従、語言跨録音可能、manifest lang pack 語言記録；segment 毎録音 / import / 試聴 / 削除；compile download / compile 適用）搭載；録音中右下可視化浮窗（level meter、経過時間、sample text、保存 / 破棄）表示；import 済 pack 初回編集上書警告維持。

| 提交 | 説明 |
|------|------|
| `398b093` | feat(dsh-api-balance): 音声 pack library 管理 + 作成器次級 menu + 録音可視化浮窗 |

## 2026-09-01T08:41:48+09:00

**摘要**：feat(dsh-api-balance): 音声 pack zip 化 + 録音/import 作成器 + 編集保護 — 音声 pack zip archive（`manifest.json` + `audio/` file）変更。host 純 JS zip 解析 `$DSH_HOME/api-balance-voicepack/` 展開、prefix route 音声配信全 device 共有。設定 dialog 作成器 segment 毎瀏覽器録音（MediaRecorder）或 local 音声 file import 対応、「打包 download」共有 zip 生成、「compile & 適用」其儘本機適用。pack import 済初回編集上書警告表示 session 内一回確認。放送 segment URL / inline 両 carrier 対応、四語言文書音声 pack 形式指南（zip 構造 / manifest / segment 表 / 録音與共有 flow）追加。

| 提交 | 説明 |
|------|------|
| `5f4c50a` | feat(dsh-api-balance): 音声 pack zip 化 + 録音/import 作成器 + 編集保護 |

## 2026-09-01T02:36:15+09:00

**摘要**：feat(dsh-api-balance): 音声放送語言與音色 DSH 界面語言追従 — 放送 text 従前 t() 界面語言追従済、発声 lang 與音色 zh-CN 固定。LocaleFace snapshot（useSyncExternalStore locale service subscribe/getSnapshot 購読）當前語言碼取得（zh → zh-CN、他其儘透過）、音色語言 prefix 一致、組合放送 text 区切文字語言応切替（中文全角 / 他半角）。locale service 不在時 zh 回退。

| 提交 | 説明 |
|------|------|
| `11c070b` | feat(dsh-api-balance): 音声放送語言與音色 DSH 界面語言追従 |

## 2026-09-01T01:51:10+09:00

**摘要**：fix(dsh-api-balance): 音声放送 menu 下→上展開変更 — menu 預設按鈕上辺接上向展開（translateY(-100%)）、上方余白不足時（viewport 上端 8px 未満）自動下向展開回退

| 提交 | 説明 |
|------|------|
| `7d0c49e` | fix(dsh-api-balance): 音声放送 menu 下→上展開変更 |
| `8d9058c` | docs(dsh): 音声放送上向展開説明四語同期 |

## 2026-09-01T01:25:25+09:00

**摘要**：feat(dsh-api-balance): 未登録 prompt + LevelDB 精確解析 + 音声放送 menu — 瀏覽器 scan 不命中時「前往登録」prompt 自動表示（新標籤登録 + polling 快掃自動取得）、手動輸入 prompt 内二級 option 降格；接続後灰顯「✓ 登録済」表示。純 JS LevelDB 表 parser 新設 userToken 精確抽出——快掃 949ms 命中。音声放送独立行 + drop-down（當前使用量 / 残高 / test 警告音声）、menu portal 固定位置変更 scroll 切抜修正 + 音声 engine 予熱；token 取得元二行表示変更。検証：LevelDB 解析実測命中、快掃失敗自 949ms 命中至。

| 提交 | 説明 |
|------|------|
| `a3ad3ff` | feat(dsh-api-balance): 未登録 prompt + LevelDB 精確解析 + 音声放送 drop-down |
| `a0e945e` | docs(dsh): 未登録 prompt/精確解析/音声放送節四語同期 |

## 2026-08-31T23:55:52+09:00

**摘要**：docs(dsh): api-balance 插件節四語補完 — pcn 版 dsh.md 插件節追加（本機瀏覽器自動掃描 / 用量図表 / config 選項）、四語 README 插件表説明「瀏覽器登録状態自動掃描取得」語義同期

| 提交 | 説明 |
|------|------|
| `b912f82` | docs(dsh): api-balance 瀏覽器自動掃描節 pcn 同期 + 四語 README 插件表更新 |

## 2026-08-31T23:50:04+09:00

**摘要**：feat(dsh-api-balance): 本機瀏覽器自動掃描 platform userToken 取得 — host 本機 Chromium 系瀏覽器（Edge / Chrome / Brave / Chromium / Vivaldi / Opera、全 Profile）Local Storage LevelDB 直接読取、base64 候補（55–85 字）抽出 GET /api/v0/users/get_user_summary 検証後保存。本機瀏覽器一度登録済使用者手動貼付無使用量 token 取得可能。6 時間節流 + token 失効（40003/401）即時再掃描 + 面板「本機瀏覽器再掃描」按鈕（RPC args.rescanBrowsers）、接続後 token 取得元徽章（browser / manual）表示。検証：本機 Edge leveldb 31 候補自実 token 自動命中。

| 提交 | 説明 |
|------|------|
| `cec90b0` | feat(dsh-api-balance): 本機瀏覽器自動掃描 platform userToken 取得 |

## 2026-08-31T11:50:02+09:00

**摘要**：docs(AGENTS): dsh-alpha 会話経験汎化 — buildNpmPackage 三則（vendored lock 與 npmDepsHash 一致 / 未公開 devDependencies postPatch 純 sed 削除且 lock 同源生成 / ruyi 式多通道薄包装）、初回起動監査前 git fetch、本機部署節新設（path-input 再鎖、nixos apply 命令、--no-link 産物回収）

| 提交 | 説明 |
|------|------|
| `86a7c3f` | docs(AGENTS): dsh-alpha 会話経験泛化 — buildNpmPackage 細則與本機部署約定 |
| `396c3ae` | docs(MAINTENANCE): record 2026-08-31 — AGENTS.md dsh-alpha 会話経験泛化 |

## 2026-08-31T11:31:42+09:00

**摘要**：dsh-alpha 導入災害復旧 — alpha 反代 Host 語義修正（web UI 入口 Host authority session cookie 認証、Host 書換恒久 401 引發）、dsh-api-balance shared RPC interceptor 衝突修正（`/api` typert-gateway 独占、精確 fetch route 切替 RPC envelope 自前実装）、dsh-nixos-shell dsh-tools 通道整合；新規部品選項 launchUrlFile（LAN 起動 URL 捕捉）與 reverseProxy.autoAuth（mod_magnet 免認証注入、可信 LAN 限定）；四言語文書 LAN 訪問節追加。検証：反代與 RPC 修正後 web UI 入口與插件 RPC 再可用。

| 提交 | 説明 |
|------|------|
| `222ece4` | fix(pkgs): dsh-api-balance / dsh-nixos-shell alpha 互換 |
| `bd4cdb1` | feat(dsh-module): launchUrlFile + autoAuth + alpha 反代 Host 語義修正 |
| `a2fe5f3` | docs(dsh): 四言語文書局域网訪問/免認証/alpha 插件互換性節追加 |
| `1176553` | docs(AGENTS): 部品節 dsh alpha 語義與插件互換性経験標注 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-nixos-shell | dsh-tools `0.1.1-rc.2` | dsh-tools `0.1.2-alpha.2` |
| 　 | npmDepsHash | `sha256-uOQ3Dq...` → `sha256-bAXZCi...` |

## 2026-08-31T07:23:07+09:00

**摘要**：dsh-alpha 0.1.2-alpha.2 — 新規包、npm `alpha` dist-tag 開発通道；dsh ruyi 式薄包装再構成（version/hash/npmDepsHash/lockFile 上書可能）、postPatch 純 sed tarball devDependencies 削除（未公開 monorepo 内部包参照、registry 404）、修正対象書類存在警備追加；四言語文書版本通道節追加、README 軟件表 dsh-alpha 行四語追補。後続修正：vendored lock 與 npmDepsHash 一致（npm fixup 平台項目欠落主建構 out of date 引發）。検証：包建構通過、lock 一致後主建構 out of date 不出。

| 提交 | 説明 |
|------|------|
| `88a2dfc` | feat(dsh): 多版本通道 — dsh-alpha 0.1.2-alpha.2 追加 |
| `33bff25` | docs(dsh): 四言語文書版本通道節追加 |
| `095d002` | docs(MAINTENANCE): record 2026-08-31 — dsh-alpha 新規包 |
| `a97fffd` | fix(pkgs): dsh-alpha vendored lock 與 npmDepsHash 一致修正 |
| `d9a83f8` | docs: README 軟件表新增 dsh-alpha 行（四語） |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-alpha | 新規 `0.1.2-alpha.2` | |
| 　 | source hash | `sha256-W/Biom...` |
| 　 | npmDepsHash | `sha256-bJMeVS...` |

## 2026-08-31T07:05:44+09:00

**摘要**：godot-ai 3.2.4 — 自己更新復旧直列化、設定書込堅牢化、経路検証與冷起動修正（v3.2.1〜v3.2.4 皆不具合修正）；四言語文書版番号同期。

| 提交 | 説明 |
|------|------|
| `c30fc17` | chore(pkgs): bump godot-ai 3.2.0 → 3.2.4 |
| `e4b9981` | docs(MAINTENANCE): record 2026-08-31 — godot-ai 更新 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| godot-ai | 3.2.0 | 3.2.4 |
| 　 | source hash | `sha256-ImKAsI...` → `sha256-Uo6GvE...` |

## 2026-08-27T09:19:59+09:00

**摘要**：opencode-telegram 0.24.1 — 韓国語界面追加、`/opencode_stop` 応答中状態以即無応答本地 OpenCode 工程強制終了可能、音声文字起引用塊以表示、Telegram 一時錯誤安全再試行返信消失/重複防止、流送編集節流適応化；mcp-searxng 2.1.0 — 引擎明示選択時引擎毎 time-range 対応検証、非対応時実用錯誤以即時失敗；godot-ai 3.2.0 — custom_tools 第三方 addon 工具登録、CLI 登録範囲選択化、DeepSeek Harness 客戶端対応追加；ruyi-beta 0.52.0-beta.20260824 — beta 通道上流更新。四言語文書同期、nix flake check 通過。

| 提交 | 説明 |
|------|------|
| `7d57bfa` | chore(pkgs): bump opencode-telegram 0.24.0 → 0.24.1 |
| `85b813e` | chore(pkgs): bump mcp-searxng 2.0.0 → 2.1.0 |
| `0fe16db` | chore(pkgs): bump godot-ai 3.1.5 → 3.2.0 |
| `b26d013` | chore(pkgs): bump ruyi-beta 0.51.0-beta.20260714 → 0.52.0-beta.20260824 |
| `e88e284` | docs(MAINTENANCE): record 2026-08-27 — 四包上流更新 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.24.0 | 0.24.1 |
| 　 | source hash | `sha256-uZaAyt...` → `sha256-uWhSMq...` |
| 　 | npmDepsHash | `sha256-Vh/e3S...` → `sha256-5ndUrB...` |
| mcp-searxng | 2.0.0 | 2.1.0 |
| 　 | source hash | `sha256-zakEU/...` → `sha256-Zq6oKX...` |
| 　 | npmDepsHash | `sha256-4WUOJJ...` → `sha256-YIH/5R...` |
| godot-ai | 3.1.5 | 3.2.0 |
| 　 | source hash | `sha256-zqZnKk...` → `sha256-ImKAsI...` |
| ruyi-beta | 0.51.0-beta.20260714 | 0.52.0-beta.20260824 |
| 　 | hash | `sha256-saOsHG...` → `sha256-vxu9Ah...` |

## 2026-08-27T07:28:58+09:00

**摘要**：feat(dsh-api-balance): 面板刷新按鈕 — 面板頭部標籤行右側刷新按鈕（↻）追加：點擊 queryBalance(true) 強制繞宿主側 30s TTL cache 重取余额 + 官方用量（按日/按月図表同步更新）；載入中按鈕禁用 + 旋轉動画（dshAbSpin 復用）；中英双語文案（刷新資料 / Refresh data）。検証：構築通過、経安定掛載点零再起配備（424 代）後 dsh 再起反映。

| 提交 | 説明 |
|------|------|
| `e864b58` | feat(dsh-api-balance): 面板刷新按鈕 — 一鍵強制刷新余额與官方用量 |

## 2026-08-27T07:28:49+09:00

**摘要**：fix(dsh-nixos-shell): 分離結果誠実語義 + systemctl restart dsh 自動分離。従前 rebuild 経 systemd-run 交接後直接透伝其 exit 0、工具結果看似「構築成功」而実結果未知；現分離命令返 `detached: true` + `detachedUnit` + `note`、exitCode 為 null——交接成功非構築成功、実結果一律 nixos_cli op=journal / op=generations 検証。分離謂詞拡至 `systemctl restart dsh`（插件更新需明示再起反映）、同自動分離、呼出先於再起返。検証：分離式 dsh 再起着地（RESTARTED_EXIT=0）、插件変更 rebuild（424/425 代）零再起零中断。

| 提交 | 説明 |
|------|------|
| `0c7b7f6` | fix(dsh-nixos-shell): 分離結果誠実語義 + systemctl restart dsh 自動分離 |

## 2026-08-27T07:28:39+09:00

**摘要**：feat(module): dsh 插件安定掛載点 — 插件更新零再起活性化。插件包従前焼込 dsh/sudo 単元、插件更新毎活性化段 dsh 與 sudo socket 再起（実行中工具呼出與守護経由 rebuild 消滅、socket 復旧不能）。改安定掛載点：activation script 毎回 switch/boot `/run/dsh/current`（dsh 與插件樹）與 `/run/dsh/nixos-shell` 當前代 store 路張替（GC 安全）、単元僅参照該安定路——活性化何也不再起 socket 也不中断。付属：插件更新明示 `systemctl restart dsh` 反映。検証：423 代配備；424/425 代插件変更 rebuild 後 dsh 與 socket ActiveEnterTimestamp 不変。

| 提交 | 説明 |
|------|------|
| `dfce302` | feat(module): dsh 插件安定掛載点 — 插件更新零再起活性化 |

## 2026-08-27T04:07:27+09:00

**摘要**：fix(dsh-nixos-shell): sudo 協議 v3 + rebuild 自動分離。三類欠陥修正：1) v2 協議断絶視為取消——rebuild switch 段 dsh.service 再起、客户端消失則守護活性化中途殺 switch（部分活性化）；v3 改明示帯内取消行、対向消失時子進程分離態完走。2) 取消/超時改進程組撃殺（spawn detached + kill(-pid)）——僅殺 shell 包装則管道写端継承孤児孫進程殘留守護応答不能；超時上限 6h 放寛。3) rebuild 自動分離 systemd-run 瞬時単元（独立 cgroup）——活性化段 socket stop/start 不致殺 switch 自身。検証：後台 sudo 即返 job id、job_kill 整組無孤児撃殺、実 rebuild 分離単元配備成功且 socket 自動復旧。

| 提交 | 説明 |
|------|------|
| `ead3526` | fix(dsh-nixos-shell): sudo 協議 v3 + rebuild 自動分離 |

## 2026-08-27T04:07:15+09:00

**摘要**：feat(dsh-api-balance): 充值卡片弾窓代替 iframe + 残高不足語音提醒。top_up 頁 WAF 遮断（"Max challenge attempts exceeded"）、iframe 弾窓不能工作——改居中卡片弾窓（新窓按鈕 + 右上閉按鈕）、無頁面跳転。追加残高不足語音提醒：残高低閾値（10 CNY/USD）時 Web Speech API 播報、15 分輪詢 + 30 分冷却、面板内開關（balance.speechOn/Off）、中英双語文案。検証：配備後特徴 grep（TopupModal/speechOn/announceHunger）確認生效。

| 提交 | 説明 |
|------|------|
| `eeffc49` | feat(dsh-api-balance): 充值卡片弾窓代替 iframe + 残高不足語音提醒 |

## 2026-08-26T11:44:45+09:00

**摘要**：dsh-api-balance 0.1.0 — 新規包。webui 用量圓環（送信按鈕左 上下文使用量表示）弹出面板「用量 / 余额」標籤切替追加：「用量」原上下文占有率與内訳維持、「余额」當前 API KEY 帳戶情報（鍵末尾、残高可否、通貨別総残高 / 充值残高 / 付與残高、DeepSeek 公式 GET /user/balance 取得 宿主側 30 秒 TTL cache）表示。宿主側 connection.rpc.intercept 包私有 endpoint 登録、客户端側 conversation.input.right 視覚互換代替圓環登録 原按鈕非表示化。検証: RPC CNY 271.07 実残高返、client bundle 配信正常。四語文書同期、nix flake check 通過。

| 提交 | 説明 |
|------|------|
| `95998cd` | feat(dsh): dsh-api-balance 插件追加 — webui 用量圓環「用量 / 余额」標籤切替 |
| `db721ba` | docs(MAINTENANCE): record 2026-08-26 — dsh-api-balance 0.1.0 新包 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| dsh-api-balance | 　 | 新規 v0.1.0 |

## 2026-09-11T12:54:29+09:00

**摘要**：fix(dsh/module): allowLanSettings $host.state.getSnapshot() 補丁撤去 — dsh ≥ 0.1.5 $host 客户端服务 state 非公開、旧補丁 client-ui-settings apply 時 undefined.getSnapshot 参照、前端全体白画面（Failed to load plugins）。模組 allowLanSettings=true 強制 override 停止（上流行為復帰）、packages/dsh.nix 補丁無条件 "host" 変更。検証: 首頁 200、llm/listProviders DeepSeek 提供方返。

| 提交 | 説明 |
|------|------|
| `06a5ce1` | fix(dsh): allowLanSettings — drop $host.state.getSnapshot() (undefined) |
| `155b09b` | fix(module): dsh — drop allowLanSettings override (state.getSnapshot undefined) |

## 2026-09-11T06:15:33+09:00

**摘要**：fix(preset): dsh persona text → prefix（0.1.5-alpha.2 互換）。dsh-persona Config text → prefix（必須）+ suffix（任意）変更。旧 agent preset（nixos-mode / maintenance-mode / 本機 ocean-spiral）text 残、persona 読込失敗（$.prefix missing required value）→ session/create 失敗 → settings / llm 提供方一覧 / session 履歴読込不可。修正: 両 preset persona config prefix 変更、本機 3 preset 同期。検証: session/create ok:true + sessionId 返。

| 提交 | 説明 |
|------|------|
| `772abf8` | fix(preset): dsh persona text → prefix for 0.1.5-alpha.2 |

## 2026-08-27T01:30:33+09:00

**摘要**：fix(module): dsh watchdog — switch-to-configuration 失敗後自動起動。nixos-rebuild switch-to-configuration「stop dsh → start dsh」間偶発失敗（exit 101）dsh inactive 残。systemd 能動 stop Restart=always 非発、反代長期 503。dsh-watchdog timer（15s）追加、inactive 検知時 systemctl start。検証: stop 後 20 秒以内自動復帰。

| 提交 | 説明 |
|------|------|
| `3ed6aa7` | fix(module): dsh watchdog — auto-restart after switch-to-configuration failure |

## 2026-08-24T15:44:06+09:00

**摘要**：fix(overlay): llama-cpp-rocm v0.2.0 語義版 — llama.cpp 上流 release tag build number（b10549）→ 語義版（v0.2.0）切替。旧 overlay b 前置詞只除去故 nixpkgs v0.2.0 LLAMA_BUILD_NUMBER 渡、`int LLAMA_BUILD_NUMBER = v0.2.0;` 生成 C++ 編譯失敗（too many decimal points）、系統 rebuild dsh 更新阻塞。現在 v/b 前置詞両方除去、-DLLAMA_BUILD_NUMBER=0 追記。検証: llama-cpp-0.2.0 構築成功、llama-cpp.service 稼働。

| 提交 | 説明 |
|------|------|
| `1a1b9d1` | fix(overlay): llama-cpp-rocm — handle v0.2.0 semantic version tag |

## 2026-08-24T15:20:16+09:00

**摘要**：fix(pkgs): dsh 崩壊修正 — cordis-plugin-timer（上流 1.1.3 未修正）Context dispose 時 pending ctx.timeout() promise "Context has been disposed" reject、未 catch unhandled rejection 化。dsh-app-boot installFailLoud process.exit(1) 変（rc.6/rc.7/rc.8/0.1.1-rc.2 全影響）。installFailLoud 此 error 只無視、他 fatal rejection 従来終了。検証: patch 0.1.1-rc.2 出力適用（dsh-app-boot/lib/index.js:1047）。

| 提交 | 説明 |
|------|------|
| `6e862b6` | fix(pkgs): dsh — ignore Context-disposed dispose race in installFailLoud |

## 2026-08-24T14:27:47+09:00

**摘要**：codewhale 0.9.11 — 上流 v0.9.9 起 TUI 資産名 codewhale-tui → codew 改名、包内 codew 導入互換別名維持、riscv64 源構築 Cargo.lock 同期（687→690 条目）；mcp-searxng 2.0.0 — 大版本升級（Node.js ≥ 22 要求、nixpkgs 既定充足、CLI 入口不変）；dsh 0.1.1-rc.2 — vendored lock 再生成（560 resolved 条目）、内建插件清單 rc.8 完全一致（137 件）；dsh-nixos-shell dsh-tools 依存 0.1.1-rc.2 整合。四言語文書同期、nix flake check 通過。

| 提交 | 説明 |
|------|------|
| `17bf588` | chore(pkgs): bump codewhale 0.9.8 → 0.9.11 |
| `065d261` | chore(pkgs): bump mcp-searxng 1.15.0 → 2.0.0 |
| `c0c8e3a` | chore(pkgs): bump dsh 0.1.0-rc.8 → 0.1.1-rc.2 |
| `bec4c3d` | chore(pkgs): dsh-nixos-shell dep dsh-tools 0.1.0-rc.7 → 0.1.1-rc.2 |

| 軟件名 | 舊 | 新 |
|--------|--------|--------|
| codewhale | 0.9.8 | 0.9.11 |
| mcp-searxng | 1.15.0 | 2.0.0 |
| dsh | 0.1.0-rc.8 | 0.1.1-rc.2 |
| dsh-nixos-shell | dsh-tools 0.1.0-rc.7 | dsh-tools 0.1.1-rc.2 |

## 2026-08-22T00:03:28+09:00

**摘要**：docs(dsh): 0.1.0-rc.8 文書同期 — 4 言語 dsh.md 版本行（rc.6 → rc.8）與「插件清單」代碼塊（rc.8 構築抽出自 137 entry id 映射）同期。nix flake check 通過。併 /etc/nixos 本地設定 `settings.agent-default-model`（deepseek-v4-pro + reasoningEffort=max）新規 session 既定追加——DeepSeek API 正規模型一覧僅 flash/pro/flash-vision-exp、"pro-max" id 無、Pro+Max 推論現状最高位。rc.8 上 nixos/maintenance 両預設掛載検証通過。

| 提交 | 説明 |
|------|------|
| `535567d` | docs(dsh): sync version and built-in plugin inventory for 0.1.0-rc.8 (137 entries) in four languages |

## 2026-08-21T21:51:26+09:00

**摘要**：docs: README「插件」章拡充與作者 DSH 情報 — ①「插件」章 dsh-nixos-shell 之外「Agent 預設」表（NixOS模式/維護模式、插件同梱、nixkits.dsh.presets 一度限 seed）追加、DSH 组件與軟体分離掲載；② 作者「小爪」条目 DSH 生態情報（dsh-nixos-shell 插件與 2 Agent 預設）追記；③ AGENTS.md 插件独立掲載規則「dsh-* 组件（插件與 Agent 預設）」拡大。4 言語同期。

| 提交 | 説明 |
|------|------|
| `4277b51` | docs: list DSH agent presets in the README plugins section and add DSH ecosystem info to the credits paw entry |

## 2026-08-21T00:01:46+09:00

**摘要**：fix(dsh-nixos-shell): 工具説明明示 tools 白名單 — 受入非阻塞指摘：固定 POSIX 工具白名單工具説明未記載。白名單 TOOL_PACKAGES 映射自動生成（27 名、python 別名含）、`tools` 參數説明記載、工具説明參照。4 言語文書完全列表同期。検証：27 名全參數説明存在、參照有、nix flake check 通過。

| 提交 | 説明 |
|------|------|
| `30d0c40` | fix(dsh-nixos-shell): surface the tools whitelist in the parameter description |

## 2026-08-20T20:12:33+09:00

**摘要**：fix(dsh-nixos-shell): 現代 rebuild 命令 `nixos apply` 訂正 — 実測 nixos 0.16.1-dev 無 `rebuild` 子命令（`nixos --help` activate/apply/generation 等列挙）、交接卡與插件 recommendedRebuild/命令対照表/門控指南 `nixos rebuild switch` 誤。`nixos apply /etc/nixos`（或従来 `sudo nixos-rebuild switch --flake /etc/nixos`）統一。検証：nix flake check 通過、系統配備 `nixos apply` 変更実測成功。

| 提交 | 説明 |
|------|------|
| `caa7d41` | fix(dsh-nixos-shell): correct the modern rebuild command to 'nixos apply' |

## 2026-08-20T20:10:08+09:00

**摘要**：fix(dsh-nixos-shell): NixOS模式 受入 P1–P4 修正 — P1（高）工具引導包装 `bash -lc` 自 `bash -c` 変更：登録壳 /etc/profile 鏈 PATH 重置 nix shell 注入破棄、sudo 路徑同 wrapper 共用同時修正（対照：`-c` 得 Python 3.14.7、`-lc` 得 command not found）。映射亦 grep→gnugrep、find→findutils 修正。P2 generations `limit` 追加（既定 20、上限 200、新→旧）。P3 journal unit `*`/`%` 通配許可、末尾 `@` 自動 `*` 補。P4 命名統一：nixos-cli → nixos 命令。文書 op 表 4 言語同期；nix flake check 通過。

| 提交 | 説明 |
|------|------|
| `a591826` | fix(dsh-nixos-shell): P1-P4 acceptance fixes |

## 2026-08-20T19:33:51+09:00

**摘要**：fix(dsh-nixos-shell): 提示節字段 text 変更 — dsh-system-prompt 補間器 `input.text` 読取、`content` 登録節実 session NixOS模式崩壊（Cannot read properties of undefined (reading 'indexOf')、mount 検証捕捉不能実 session 路徑欠陥）。nixos-gate（guidance/gate 2 節）與 maintenance-skills（workflow 節）計 3 箇所 `content` → `text` 修正。検証：mock text 字段與未閉 `{{` 無確認、実 systemPrompt service assemble 崩壊無、系統預構築通過。

| 提交 | 説明 |
|------|------|
| `476e9dc` | fix(dsh-nixos-shell): use the PromptSection text field instead of content |

## 2026-08-20T19:05:44+09:00

**摘要**：feat(dsh-nixos-shell): 維護模式 agent 預設 — 新包内入口 maintenance-skills：apply 時構築期嵌入倉庫 skills/ 樹（単一來源）自 runtime 技能 write-project-docs、write-maintenance-log、全 translate-* 言語拡張（自動発見）登録、倉庫維護工作流提示詞節注入。包 postPatch skills → skills-embedded 複製。預設 presets/maintenance-mode（id `maintenance`、NixOS模式組合 + maintenance-skills 行基盤）包同梱。模組 nixkits.dsh.presets.maintenanceMode（seed-once）追加。検証：mock 3 技能登録 + 工作流節全過、系統預構築通過。

| 提交 | 説明 |
|------|------|
| `f6c749e` | feat(dsh-nixos-shell): 维护模式 agent preset — maintenance-skills entry, presets/maintenance-mode, module presets.maintenanceMode seed |

## 2026-08-20T18:30:46+09:00

**摘要**：feat(dsh-nixos-shell): NixOS模式 agent 預設 — 新子路 nixos-gate：session 初期化時宿主 NixOS 検証（/etc/NIXOS 或 os-release ID=nixos）——非 NixOS tools.guard 全工具実行拒否與拒否提示詞節注入、NixOS 開発指南提示詞節注入。預設 presets/nixos-mode（id `nixos`、創造模式 cordis 組合 + 技能目録基盤、nixos-gate/nixos-shell 行追加）包同梱。模組 nixkits.dsh.presets.nixosMode 追加、preStart 一度限 seed $DSH_HOME/.agent-presets/nixos。検証：包構築、門控構文検査、系統預構築通過。

| 提交 | 説明 |
|------|------|
| `aaa21cb` | feat(dsh-nixos-shell): NixOS模式 agent preset — nixos-gate entry, presets/nixos-mode, module presets.nixosMode seed |

## 2026-08-20T18:24:04+09:00

**摘要**：docs: README 插件独立章 + AGENTS.md 更新 — ① dsh-* 插件「軟体」表自 README 新設「插件」章移動（4 言語同期）、軟体混在禁止。AGENTS.md 插件独立掲載規約與「dsh 技能導入対象外」規則追加。② 承認済清理適用（本機）：~/.bashrc 旧 store 絶対路徑 bash-completion 塊削除、~/.profile hm-session-vars 安定路徑 /etc/profiles/per-user/kix 変更、旧 ~/.dsh/skills 削除（nixos_cli audit-store-paths 再検査：0 件）。

| 提交 | 説明 |
|------|------|
| `57ae6b5` | docs: list dsh-* plugins in a dedicated README plugins section (4 langs); AGENTS.md plugin-listing + dsh-skill-target rules |

## 2026-08-20T17:56:21+09:00

**摘要**：refactor(dsh-nixos-shell): 包名修正 nixos-shell → dsh-nixos-shell — 包名（pname/目録/flake 輸出/overlay/CI workflow/文書）`dsh-nixos-shell`（pkgs.dsh-nixos-shell）統一。dsh 内表示名 `nixos-shell` 不変（組合行 entry id、插件名、工具名 nixos_shell/nixos_cli）。検証：包構築通過；配備側参照同期済。

| 提交 | 説明 |
|------|------|
| `26a844e` | refactor(dsh-nixos-shell): rename package nixos-shell -> dsh-nixos-shell |

## 2026-08-20T17:46:44+09:00

**摘要**：feat(nixos-shell): NixOS 場景能力単一插件統合；refactor: 技能插件化設計廃止

- 新包 nixos-shell（@kihara777/dsh-nixos-shell 0.1.0）2 工具登録：nixos_shell 実行器（NixOS PATH 注入 + bash 回退 + `tools` 不足 POSIX 工具提供 + sudo 守護路由）與 nixos_cli 読取専用診断（capabilities 他 4 項目）。要件 nixos-modern-cli 技能場景由来。
- dsh-nix-shell 與 dsh-skill-nixkits（7 技能插件設計）削除、CI/文書差替。
- generations 修正：進程内読取専用列表変更（`nix-env` 非 root 拒否）。
検証：13 案例機能套件全過；系統預構築通過。

| 提交 | 説明 |
|------|------|
| `395d8b4` | feat(nixos-shell): consolidate NixOS scenario capabilities into one plugin |

| 軟件名 | 舊 | 新 |
|--------|-----|-----|
| nixos-shell | — | 新規 v0.1.0 |

## 2026-08-20T16:40:16+09:00

**摘要**：fix(dsh): service HOME 実使用者家指向 — git gh credential helper `$HOME/.config/gh` 憑証解決、模組此前 service HOME dshHome（/home/kix/.dsh）設定、沙箱内 git push 憑証発見不能。`users.users.<user>.home`（無場合 dshHome 回退）変更、代理使用者自身工具環境（git/gh 憑証、~/.gitconfig、npm/ssh 設定）継承。DSH_HOME dsh 状態根不変無影響。検証：滞留提交 push 全成功；系統預構築通過。

| 提交 | 説明 |
|------|------|
| `514831c` | fix(dsh): point service HOME at the real user home — git's gh credential helper resolves ~/.config/gh from $HOME, so HOME=dshHome left sandbox pushes without credentials |

## 2026-08-20T16:13:40+09:00

**摘要**：fix(dsh-nix-shell): sudo 実行器 PATH 合併順修正 — 套接字活性化模版単元 systemd 管理器既定 PATH（coreutils/findutils/grep/sed/systemd store 路徑僅）継承、明示 NixOS PATH 後展開 `...process.env` 覆蓋、守護内 ps 與 nixos-rebuild 等 profile 工具解決不能。継承 env 先、明示 NixOS profile PATH 後展開変更以修正（請求 env 最後合併不変）。検証：PATH /run/current-system/sw/bin 先頭、ps 與 nixos-rebuild 両方解決成功。

| 提交 | 説明 |
|------|------|
| `63b2576` | fix(dsh-nix-shell): put the explicit NixOS profile PATH after the inherited env — socket-activated template units inherit systemd's manager-default PATH, which overrode the executor PATH and left profile tools (ps, nixos-rebuild) unresolvable |

## 2026-08-20T16:01:28+09:00

**摘要**：docs(dsh): 使用例実模組動作同期 — 手動組合行例 `- insert:` 包裹與警告追加（裸 `- id:` 行僅補丁既有条目）；技能插件文書全 7 entry id（`skill-nixkits-<id>` 接頭辞欠落）與 disabled 例 id 修正；dsh 文書安裝節模組式変更（旧 `nixkits.extraPackages` 既不存在）與二進 cache 説明追加。4 言語同期。

| 提交 | 説明 |
|------|------|
| `6074661` | docs(dsh): sync usage examples with module reality — insert-op wrapping for manual rows, corrected skill entry ids, module-based install + cache note |

## 2026-08-21T23:02:33+09:00

**摘要**：chore(pkgs): dsh 0.1.0-rc.7 → 0.1.0-rc.8。遺留 rc.8 升級完了：src hash npmDepsHash 実値、package-lock.json 再生成（旧 lock dsh-invariants 含 120 条目欠落）。検証：rc.8 構築成功、randomUUID fallback patch 適用、with-plugins 変体正常、起動插件読込 error 無；with-plugins dsh-nixos-shell 只注入。

| 提交 | 説明 |
|------|------|
| `a7cbe3e` | chore(pkgs): bump dsh 0.1.0-rc.7 → 0.1.0-rc.8 |

## 2026-08-21T22:11:28+09:00

**摘要**：fix(module): dsh 崩壊耐性 — Restart=always + RestartSec 5s。dsh 上流既知崩壊 bug（cordis-plugin-timer Context disposed、rc.6 約 13 時間稼働後発生）、rc.7/rc.8 cordis-plugin-timer 依存不変（^1.1.3）bug 残存。崩壊時 lighttpd 反代 systemd 再起動迄 503 返。Restart=always（on-failure exit 0 終了未覆）+ 再起動間隔 5s 変更、中断時間最小化。

| 提交 | 説明 |
|------|------|
| `ed7e9d5` | fix(module): dsh Restart=always + faster RestartSec (crash resilience) |

## 2026-08-20T11:08:08+09:00

**摘要**：fix(module): dsh 插件 ESM 解決 — dsh cordis-plugin-loader profile 目録（$DSH_HOME/profiles/web）解決基準、上方向 node_modules 検索。插件 dsh store 樹注入済、store profile node_modules 路徑上不在、import ERR_MODULE_NOT_FOUND 起動直後崩壊。preStart 注入済 @kihara777 scope $DSH_HOME/node_modules 符号連結、Node 解決可。realpath store 樹復帰、插件参照 @deepseek-ai/* peer deps 同一樹内解決可。検証：skills + nix-shell 插件読込成功。

| 提交 | 説明 |
|------|------|
| `044b891` | fix(module): dsh plugin ESM resolution via DSH_HOME/node_modules symlink |

## 2026-08-20T10:33:26+09:00

**摘要**：fix(dsh): insert 塊縮進修正 — 嵌套 '' 字符串按自身最小縮進剝離、插件条目第 0 列復帰、`- insert:` 兄弟補丁操作誤解析（dsh 報 patch: entry … not found + id is required for non-insert patches、8 行再度全部未掛載）。每包一個 insert 操作発行、条目对象與 `- insert:` 行同字符串（2/4 列縮進）修正、模組注釈陷阱記録。検証：dump-config stderr 零、8 行全部合成樹反映。

| 提交 | 説明 |
|------|------|
| `988dc6d` | fix(dsh): emit one insert op per plugin entry in a single string — nested '' strings dedent to column 0, turning entry objects into sibling patch ops |

## 2026-08-20T10:21:46+09:00

**摘要**：fix(dsh): 生成行 insert 動詞包裹 — cordis.patch.yml 裸 `- id:` 行僅補丁既有条目、新規插件条目 dsh 破棄、8 插件行全部未掛載（dump-config 検証）。包注入成功処、合成樹無条目故 nix_shell 工具與 7 技能插件未登録。生成 plugins.packages 行 `- insert:` 操作包裹修正（extraPatch MCP 行同形）。検証：dump-config stderr 零、8 行全部合成樹反映。

| 提交 | 説明 |
|------|------|
| `3d0433d` | fix(dsh): wrap generated plugin rows in the insert op — bare - id: rows only patch existing entries, so dsh dropped every new entry with 'patch: entry … not found' |

## 2026-08-20T09:45:59+09:00

**摘要**：fix(dsh): 複数插件注入失敗修正 — 展開後 GNU tar 復元归檔内目録模式（store 樹 0555）、直前插件作成 scope 目録（@kihara777/）次插件書込不可、2 個目以降 Cannot mkdir: Permission denied 失敗。単一插件不発生、初実系統構築顕在化。各插件解包直後 chmod -R u+w 実行修正。検証：系統 toplevel 完全構築成功、dsh-nix-shell 與 7 技能全部注入済。

| 提交 | 説明 |
|------|------|
| `b03a386` | fix(dsh): chmod node_modules after each plugin injection — GNU tar restores archived dir modes (0555) after extraction, leaving the scope dir created by the previous plugin unwritable for the next one |

## 2026-08-20T08:12:57+09:00

**摘要**：fix(rcc-fix): desktop 条目改名互換 — asusctl 6.4.0 desktop 条目 org.opengamingcollective.rog-control-center.desktop 改名、nixpkgs programs.rog-control-center autoStart（makeAutostartItem）旧名 rog-control-center.desktop 複製続、系統構築失敗（cp cannot stat）。rcc-fix overlay asusctl postInstall 旧名符号連結提供。検証：本機釘 nixpkgs rev（0ae2bc1）makeAutostartItem { name = "rog-control-center"; package = asusctl } 構築成功（EXIT=0）。

| 提交 | 説明 |
|------|------|
| `650f6f7` | fix(rcc-fix): compat symlink for renamed desktop entry — nixpkgs programs.rog-control-center autoStart copies the pre-6.4.0 filename |

## 2026-08-20T07:41:45+09:00

**摘要**：fix(rcc-fix): asusctl 6.4.0 向補丁再基 — nixpkgs 前進 asusctl 6.3.7 → 6.4.0、rcc-fix.patch 第 4 hunk 失敗（系統構築失敗）。上流該領域再構築（`is_old_laptop`/`retain` 旧 push 塊置換、else 分岐 過濾上流吸収）。補丁境界検査置換（`names[(*z) as usize]` → filter_map 境界検査 + warn）保持。他 hunk 変更不要。検証：6.4.0 源 git apply --check 全 hunk 通過、本機釘 nixpkgs rev（0ae2bc1）asusctl 構築成功（EXIT=0）。

| 提交 | 説明 |
|------|------|
| `ce216c7` | fix(rcc-fix): rebase patch hunk 4 for asusctl 6.4.0 — upstream is_old_laptop/retain restructure, else-filter absorbed upstream |

## 2026-08-20T06:27:40+09:00

**摘要**：feat(dsh-nix-shell): 外部 sudo 守護統合（0.2.0）— 插件初期化時守護套接字（config `sudoSocketPath` / 環境変数 `NIXKITS_SUDO_SOCKET`）検出、存在時 `sudo`/`justification` 參數有効化。`sudo: true` 請求全体（command/cwd/env/timeout）Unix 套接字経由守護執行路由、`justification` 必須結果随返。守護 = systemd 套接字激活型 root 実行器（nixkits-sudo@.service + nixkits-sudo-exec.js、接続毎 1 請求 JSON 協議、插件包同梱）。接続制御境界 = dsh 服務使用者所有 `0600` 套接字文件（SocketUser/SocketMode）。部品 nixkits.dsh.sudo（enable/socketPath/package）追加、単元生成與環境変数注入。検証：門控、路由往復、justification 強制、実行器直結協議、部品評価全通過。

| 提交 | 説明 |
|------|------|
| `ef4bcfc` | feat(dsh-nix-shell): external sudo daemon integration — socket-activated root executor, init-time detection, sudo routing |

## 2026-08-20T06:02:50+09:00

**摘要**：refactor(skills): NixKits 技能原生 DSH 技能插件書換 — 新包 dsh-skill-nixkits（@kihara777/dsh-skill-nixkits、runtime 依存零）、7 技能各包内子路插件条目。各插件 runtime ctx.skills.register 自身内容登録（runtime provider、rank 250、文件系統由來優先）、apply() 登録 disposer 返組合解除随破棄。SKILL.md skills/ 単一來源殘置構築期嵌入、frontmatter 剥離 content 化 metadata 保持（文書管自動発見契約不変）。部品 skills.enable 7 組合行（skill-nixkits-<id> → @kihara777/dsh-skill-nixkits/<id>）自動生成、旧誤実装目録注入（nixkits-skills 包與 bundledSkillDir）置換。検証：7 插件 mock 登録、裸子路 import 與登録実測全通過。CI x86_64/aarch64 構築追加。

| 提交 | 説明 |
|------|------|
| `7393b95` | feat(dsh): rewrite NixKits skills as native skill plugins — dsh-skill-nixkits package, one plugin entry per skill |

## 2026-08-20T05:27:48+09:00

**摘要**：feat(dsh): 内建 bash 工具 NixOS 修正 + 第三者插件包 + 配備級技能 — ① 部品 dsh 服務完全 NixOS PATH 注入（systemd 既定 PATH bash 無、内建 bash 工具 spawn bash ENOENT 失敗）；② dsh-nix-shell 包新規（@kihara777/dsh-nix-shell、NixOS 対応 shell 工具插件：PATH 解失敗時 Nix store bash 回退、NixOS PATH 注入、超時與落盤輸出）與 nixkits-skills 包（技能目録 bundle）新規；③ 部品 plugins.packages（node_modules tar 展開注入 — 符号連結 Node realpath 插件自身 store 路戻 peer 解決壊故実展開 — 與組合行自動生成）與 skills.enable（skill-filesystem bundledSkillDir、rank 600）追加；④ CI dsh-nix-shell x86_64/aarch64 構築追加。端到端検証：注入樹内 IMPORT-OK。

| 提交 | 説明 |
|------|------|
| `69eedd4` | feat(dsh): PATH fix + third-party plugin packages + bundled skills — L1/L2/L3/路経A |
| `55664ed` | docs: dsh-nix-shell package docs + dsh module options + README rows (4 languages) |

## 2026-08-19T20:39:47+09:00

**摘要**：fix(ci): ci-summary 徽章 failing 固定問題修正 — jq 管 workflow 分組先 failure 過濾、旧失敗永久覆後続成功（codewhale riscv64 修正後徽章仍紅）。先 workflow 別最新実行取得後 failure 判定修正、徽章 passing 復帰。

| 提交 | 説明 |
|------|------|
| `d752c83` | fix(ci): ci-summary badge stuck on failing — latest-run check must precede failure filter |

## 2026-08-19T19:57:03+09:00

**摘要**：fix(codewhale-src): riscv64 交叉構築修正 — 四重問題連鎖解消：① rquickjs-sys 0.12.2（crates.io 最新版）riscv64gc bindings 無（build.rs 非 bindgen 路 include 目標文件）、上流各 64bit 小端 bindings 字節一致故 postPatch x86_64 版物化済 vendor 目録配置；② 宿主側（x86_64 build 依存）ring 構築 cc-rs 宿主 triple 自派生 CC（交叉編譯器）回退 -m64 付與 — buildPackages 工具連明示；③ postInstall 裸 cargo build --target 喪失宿主工具連連結 — cargoBuildHook 同目標 triple 明示；④ 二進 -lgcc_s 動的連結 autoPatchelfHook hostPlatform 依存走査 — 交叉 gcc libgcc 輸出明示追加。CI 同命令（pkgsCross.riscv64.callPackage）本地検証済。Build codewhale (riscv64) 六連敗解消。

| 提交 | 説明 |
|------|------|
| `962ce6c` | fix(codewhale-src): riscv64 cross build — rquickjs bindings overlay, host cc-rs toolchain, postInstall --target, libgcc rpath |

## 2026-08-19T17:57:26+09:00

**摘要**：AGENTS.md — 旧 comfyui-strix-halo 部品参照（comfyui-rocm 統合済）修正、CI 章実際 workflow 構成（包別 build-<pkg>-<arch>.yml 共有 build-package.yml 呼出 + cachix-action 配信、riscv64 構築無包及専用構築無 godot-ai/dsh 明記、ci-summary.yml 徽章機構）一致更新。

| 提交 | 説明 |
|------|------|
| `c4e320e` | docs(AGENTS): fix stale comfyui-strix-halo reference + align CI description with actual workflows |

## 2026-08-19T16:52:54+09:00

**摘要**：fix(module): dsh WebSocket 反代 mod_proxy upgrade 変更 — NixOS lighttpd 模組 allKnownModules 固定順 server.modules 生成、mod_wstunnel mod_proxy 後負載。proxy.server 全路徑匹配故 mod_proxy /api/events.* 升級請求先処理 426 返、mod_wstunnel r->handler_module 非 NULL 不実行。lighttpd 1.4.56+ mod_proxy 原生 WebSocket 隧道（proxy.header = "upgrade" => "enable"）変更、mod_wstunnel 削除。検証: 8625 / 200、/api/events.host|mux 握手 101（本地+LAN）。

| 提交 | 説明 |
|------|------|
| `51d9435` | fix(module): dsh WebSocket reverse proxy via mod_wstunnel |
| `33d5931` | fix(module): dsh wstunnel port as string (match lighttpd backend syntax) |
| `d7d2713` | fix(module): dsh WebSocket via mod_proxy upgrade (mod_wstunnel never runs) |

## 2026-08-19T13:10:00+09:00

**摘要**：fix(pkgs): dsh 0.1.0-rc.6 → 0.1.0-rc.7。rc.6 約 13 時間後崩壊（fatal load failure: Context has been disposed）— cordis-plugin-timer ctx.timeout() Context 静態 dispose 時 reject unhandled rejection 化。rc.7（8/17）最新、cordis/timer 版不変（bug 残存可）上流修正含。插件清單不変（131）。

| 提交 | 説明 |
|------|------|
| `c75cb4c` | chore(pkgs): bump dsh 0.1.0-rc.6 → 0.1.0-rc.7 |

## 2026-08-18T20:00:00+09:00

**摘要**：fix(module): dsh 通常使用者実行対応 — 隔離 system user（home /var/lib/dsh）無法 /home/<user>（700）訪問、agent 作業目録操作不能。dshHome 選項追加、HOME/DSH_HOME/WorkingDirectory/preStart 統一、StateDirectory preStart mkdir + chown 置換。本機 user="kix" + dshHome="/home/kix/.dsh"、dsh kix 身份実行 /home/kix 到達。

| 提交 | 説明 |
|------|------|
| `584c764` | fix(module): dsh dshHome option + support normal-user operation |

## 2026-08-18T19:30:00+09:00

**摘要**：feat(module): nixkits.dsh.settings — 宣言設定。dsh 設定菜單項目 $DSH_HOME/settings.yaml（文件备份、hot reload、namespace 別 section）格納。settings 選項（attrsOf attrs、namespace → section）追加 JSON（合法 YAML）preStart 写入。実測：web-search-deepseek.maxTokens 既定 4096 → 8192 宣言覆写。4言語文書設定節追加。

| 提交 | 説明 |
|------|------|
| `f2981e6` | feat(module): nixkits.dsh.settings — declarative settings |
| `dc64cbb` | docs(dsh): declarative settings section + maintenance log |

## 2026-08-18T18:45:00+09:00

**摘要**：docs(dsh) + refactor(skill): 插件清單同期 — docs/dsh.md 4言語「插件清單」節（131 内建 entry id、id -> 包名）追加、nixkits.dsh.plugins.disabled 参照。check-updates 技能第5步 dsh 特説明追加：更新時新包 dsh-*/cordis.patch.yml 清單抽出 docs 同期。

| 提交 | 説明 |
|------|------|
| `06d0e28` | docs(dsh): plugin inventory + check-updates skill sync |

## 2026-08-18T18:39:34+09:00

**摘要**：fix(module): dsh preStart rm before cp — preStart 生成文件権限 444（読取専用）、服務使用者 cp 上書不能。先 rm 後 cp 修正。

| 提交 | 説明 |
|------|------|
| `f308ac7` | fix(module): dsh preStart rm before cp — service-user cannot overwrite 444 |

## 2026-08-18T18:20:00+09:00

**摘要**：feat(module): nixkits.dsh.plugins — 宣言插件 on/off 與設定。dsh 插件 cordis.patch.yml runtime hot reload、部品 plugins.disabled（entry id）、plugins.settings（config 覆写）、plugins.extraPatch（MCP 等生片段）追加。系統設定 MCP extraPatch 移行、API key kix.credentials 宣言化、session-telemetry-otel + session-stats 無効化例。実測：cordis.patch.yml 正生成、absent-id 警告無。

| 提交 | 説明 |
|------|------|
| `0e4fe58` | feat(module): nixkits.dsh.plugins — declarative plugin on/off + config |
| `164d515` | docs(dsh): declarative plugin management section + maintenance log |

## 2026-08-18T17:55:00+09:00

**摘要**：fix(module): lighttpd 反代 Host/Origin loopback 改写 — trustedHosts 方式取代。dsh isTrustedApiRequest loopback 通過、per-deployment trustedHosts 不要、LAN 域名/IP 不外泄。Origin 與 Host 同時改写必須（同一生成元 check 失敗避）。実測：trustedHosts 削除後反代 API（harukax.lan / 192.168.31.241）ok:true。

| 提交 | 説明 |
|------|------|
| `a33b414` | fix(module): rewrite Host/Origin to loopback in lighttpd reverse proxy |

## 2026-08-18T17:30:00+09:00

**摘要**：fix(module): dsh trustedHosts 選項 — 反代経由 /api 全 403。dsh /api 要求 Host header 検証故、lighttpd 経由 Host LAN 域名/IP 化 拒否。nixkits.dsh.trustedHosts 追加（repeatable --trusted-host 映射）、系統設定 harukax.lan + 192.168.31.241 信頼 API 復旧。

| 提交 | 説明 |
|------|------|
| `3755935` | fix(module): dsh trustedHosts option — Host-header 403 behind reverse proxy |

## 2026-08-18T16:20:05+09:00

**摘要**：fix(dsh): 瀏覧器側 client bundle patch — crypto.randomUUID fallback。crypto.randomUUID() 非安全上下文（LAN IP HTTP、lighttpd 反代経由）使用不可故 webui 錯誤。postInstall dsh-client-connection + dsh-client-ui-conversation crypto.randomUUID __dshUuid helper（crypto.getRandomValues fallback、全上下文利用可）置換。

| 提交 | 説明 |
|------|------|
| `5d1cfa8` | fix(dsh): patch browser client bundles — crypto.randomUUID fallback |

## 2026-08-18T15:29:14+09:00

**摘要**：fix/docs(dsh): lighttpd 反代定稿 — dsh 内部 loopback 端口 8615（SearXNG 42701 合）、lighttpd 対外端口 8625（4270 合）、防火牆 lighttpd 対外端口 開放（dsh 内部端口 非）。4 語言文書同期。

| 提交 | 説明 |
|------|------|
| `4a78d54` | fix(module): dsh internal port 8615, public reverseProxy port 8625 |
| `5452a3e` | docs(dsh): sync service section to loopback 8615 + lighttpd reverseProxy 8625 |

## 2026-08-18T14:38:26+09:00

**摘要**：feat(module): nixkits.dsh.reverseProxy（lighttpd）新規 — dsh 非 loopback host 拒否故（RCE 安全）、lighttpd `$SERVER["socket"]` block 0.0.0.0:8626 dsh loopback 8625 反代（SearXNG lighttpd 実例 再利用、extraConfig types.lines 合併可）、防火牆 8626 開放。

| 提交 | 説明 |
|------|------|
| `12e11af` | feat(module): add nixkits.dsh.reverseProxy via lighttpd |

## 2026-08-18T10:29:46+09:00

**摘要**：feat/fix(dsh): dsh 服務 配備 且 MCP + skills 設定。

- 部品修正：dsh system 使用者 HOME=/var/empty（読取専用）EPERM 招故、書込可能 /var/lib/dsh + StateDirectory 変更
- HMR 服務 --expose-internals 要故、node --expose-internals bin.js 直接起動
- MCP 服務（SearXNG + Godot）cordis.patch.yml `insert:` 構文 設定（id-targeted override 非）
- skills /var/lib/dsh/skills/ 複製（.agent-presets 子目録 非）
- nixkits-skills 目録 ~/.dsh/skills 修正

| 提交 | 説明 |
|------|------|
| `b17e5bf` | fix(module): dsh writable HOME + StateDirectory |
| `ed6983e` | fix(module): dsh launch via node --expose-internals (HMR requires execArgv) |
| `456c917` | feat(skill): nixkits-skills add dsh skills directory support |
| `ee24563` | fix(skill): correct dsh skills directory — ~/.dsh/skills |

## 2026-08-18T08:42:40+09:00

**摘要**：docs: ruyi 通道版本同期（stable 0.50.0 → 0.51.0、beta/alpha 日期）+ en/ja/pcn README ruyi 説明列補完（空 `<br><br>` → RuyiSDK 説明 + 3 通道版本、zh 一致）。

| 提交 | 説明 |
|------|------|
| `86ae30b` | docs: sync ruyi channel versions + fill empty ruyi descriptions in en/ja/pcn README |

## 2026-08-18T07:19:30+09:00

**摘要**：監査修正 —— 版数更新 與 部品/overlay/文書/技能 修正。

- codewhale 0.9.8、mcp-searxng 1.15.0、opencode-telegram 0.24.0、obs-bilibili-stream 2.1.3 更新
- comfyui-rocm 部品 services.comfyui assertion 復元、nixpkgs-compat patch 対象 明確化
- overlay codewhale 構造別 source 構築 回退（riscv64）
- 文書 版数、ruyi 連結、codewhale-sudo 説明 同期
- write-maintenance-log 技能 表頭 追加、katalish 列 削除

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

**摘要**：refactor: comfyui-rocm-patch + comfyui-strix-halo 単一 comfyui-rocm 統合 — 2 module 異部分処理（patch 層 vs Strix Halo 硬件最適化）、nixkits.comfyui-rocm（enable 選項）統合、patch mount/GFX 覆写/xformers 迂回/C 工具鏈/Strix Halo 設定（ROCm runtime/DeviceAllow/kernelParams）網羅。文書與 README 同期。

| 提交 | 説明 |
|------|------|
| `d473991` | refactor: merge comfyui-rocm-patch + comfyui-strix-halo into comfyui-rocm |

## 2026-08-15T09:23:15+09:00

**摘要**：refactor: 補丁 rog-control-center-fix.patch → rcc-fix.patch 改名、rcc-fix 統一名称收尾。overlays/rcc-fix.nix 與 4言語 rcc-fix.md 参照更新。

| 提交 | 説明 |
|------|------|
| `b350cfd` | refactor: rename rog-control-center-fix.patch to rcc-fix.patch |

## 2026-08-15T08:31:32+09:00

**摘要**：deepseek-harness 0.1.0-rc.6 — 新規包（@deepseek-ai/dsh、bin dsh → lib/bin.js）。預構築 npm 包 package-lock.json 同梱（npm tarball lock 無）、dontNpmBuild build 跳過。4 言語文書 追加 且 godot-ai 與 dsh README 掲載。

| 提交 | 説明 |
|------|------|
| `0194460` | feat(dsh): add deepseek-harness 0.1.0-rc.6 package + 4-language docs |

## 2026-08-15T08:07:33+09:00

**摘要**：refactor: rog-control-center-fix rcc-fix 統合 — 両者同一 ROG Control Center 修正（overlay asusctl patch + module systemd 死鎖修正）。単一 rcc-fix 統一：overlays/rog-control-center-fix.nix → rcc-fix.nix、modules/rog-control-center-fix.nix → rcc-fix.nix、選項 nixkits.rog-control-center-fix → nixkits.rcc-fix、独立文書削除（rcc-fix.md 統合）。

| 提交 | 説明 |
|------|------|
| `376eacf` | refactor: merge rog-control-center-fix into rcc-fix |

## 2026-08-13T01:20:29+09:00

**摘要**：fix(default-overlay): godot-ai fastmcp overlay 適用構築 — default overlay final.callPackage fastmcp nixpkgs 3.3.1（循環 import bug）解決。 (prev.extend (import ./fastmcp.nix)) 依存 3.4.7 解決。

| 提交 | 説明 |
|------|------|
| `94d49b5` | fix(default-overlay): build godot-ai with fastmcp overlay applied |

## 2026-08-12T10:05:00+09:00

**摘要**：fix(default-overlay): godot-ai 路経修正 — default overlay callPackage `../packages/` 要（overlay 子目録）、`./packages/` 誤無存 `overlays/packages/` 解決。

| 提交 | 説明 |
|------|------|
| `0144283` | fix(default-overlay): correct godot-ai path — ./packages → ../packages |

## 2026-08-12T10:00:00+09:00

**摘要**：fix(default-overlay): godot-ai 登録 — flake packages 存在 default overlay 遺漏、下流 pkgs.godot-ai 不可視。

| 提交 | 説明 |
|------|------|
| `093565c` | fix(default-overlay): register godot-ai so pkgs.godot-ai is available |

## 2026-08-12T09:18:26+09:00

**摘要**：docs(godot-ai): 4言語文書新規追加（72行）— 架構図、依存表（fastmcp 3.4 含）、系統導入 + MCP 設定 + 前提條件指南。

| 提交 | 説明 |
|------|------|
| `76c39c8` | docs(godot-ai): add 4-language documentation |

## 2026-08-12T07:07:27+09:00

**摘要**：feat(godot-ai): godot-ai 3.1.5 新包 + fastmcp 3.4.7 overlay。godot-ai MCP client Godot editor 接続本格 MCP server。fastmcp 3.3.1→3.4.7（必要 >=3.4.0、3.3.x 循環 import bug）、fastmcp-slim + py-key-value-aio 0.4.5 連動。devshell godot-mcp→godot-ai。

| 提交 | 説明 |
|------|------|
| `23a5b8d` | feat(godot-ai): add godot-ai 3.1.5 package + fastmcp 3.4.7 overlay |

## 2026-08-11T18:49:54+09:00

**摘要**：fix(breeze-black): Edge/Chromium 純黒背景 + 純白前景 — sed 再映射拡張：背景 #292c30 → #000000（按鈕/工具欄/禁用）、前景 #fcfcfc/#a1a9b1 → #ffffff。gtk-3.0/4.0 検証：15× #000000、14× #ffffff、零灰残留。

| 提交 | 説明 |
|------|------|
| `4e5c558` | fix(breeze-black): pure black bg + pure white fg for Edge/Chromium |

## 2026-08-11T18:41:14+09:00

**摘要**：fix(breeze-black): 背景変数 純黒 #000000 映射 — Breeze-Dark 基本色 #202326（濃灰非純黒）。CSS 複製後 主背景/base #000000 再映射（按鈕 #292c30 維持區別）、gtk-dark.css 自己完結（gtk.css 複製）灰色 import 廢止。

| 提交 | 説明 |
|------|------|
| `2ee1ba6` | fix(breeze-black): map background variables to true black #000000 |

## 2026-08-11T16:19:49+09:00

**摘要**：fix(breeze-black): gtk.css 本体 Breeze-Dark dark 覆写 — Chromium 系（Edge/Chrome）prefer-dark 無視、gtk.css 直読；BreezeBlack（light Breeze 改名）light 変数（#eff0f1）残留、Edge 灰色。gtk-{3,4}.0 gtk.css(+.map) dark（#202326）覆写。

| 提交 | 説明 |
|------|------|
| `25e23e0` | fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme |

## 2026-08-11T16:02:39+09:00

**摘要**：fix(breeze-black): Breeze-Dark 保持 — BreezeBlack gtk-dark.css `@import ../../Breeze-Dark/...` 真 dark 配色（#202326）取得、preFixup 削除致 import 断、GTK 浅色退避（「黒不足」症状）。

| 提交 | 説明 |
|------|------|
| `0433eee` | fix(breeze-black): keep Breeze-Dark — gtk-dark.css imports it for dark mode |

## 2026-08-09T22:43:43+09:00

**摘要**：refactor(skill): 陷阱第4条追加 — 無引数 `nix flake lock` 全 floating input 更新（nixpkgs 漂移再発、8/7 diffusers/httpx 失敗）。--update-input 或 rev 固定使用。

| 提交 | 説明 |
|------|------|
| `ec5e589` | refactor(skill): add trap 4 — bare nix flake lock refreshes floating inputs |

## 2026-08-09T19:40:21+09:00

**摘要**：feat(patches): 本地 comfyui-nix build 修正 patch 正式化 — ① mkWheel dontCheckRuntimeDeps（pythonRuntimeDepsCheckHook ≥ 8/5）；② flaky 套件 doInstallCheck=false（jupyter-server/scipy/fastapi/einops/mss/inline-snapshot）；③ torch/facexlib runtime 依存 skip。module 注釈 + 4 言語文書更新。

| 提交 | 説明 |
|------|------|
| `a8ad11e` | feat(patches): add comfyui-nix nixpkgs-compat patch + module doc |
| `faefa5b` | docs(comfyui-rocm-patch): document nixpkgs-compat patch (4 langs) |

## 2026-08-09T19:05:53+09:00

**摘要**：refactor(skill): nixkits-check-updates nixpkgs 漂移診断節追加 — ① 旧 flake.lock 復元 follows 要確認（喪失 → glibc 2.40 → GLIBC_ABI_GNU2_TLS）；② pytest 包 doInstallCheck=false 使用；③ pythonRuntimeDepsCheckHook（≥ 8/5）wheel 構築破壊、dontCheckRuntimeDeps=true 修復。

| 提交 | 説明 |
|------|------|
| `e88fd98` | refactor(skill): add nixpkgs-drift troubleshooting section to check-updates |

## 2026-08-09T04:21:09+09:00

**摘要**：fix(module): llama-cpp — ① services.llama-cpp.extraFlags 非推奨、settings 採用；② freeform settings 分離定義不可、lib.mkMerge 統合。

| 提交 | 説明 |
|------|------|
| `8026d8e` | fix(module): replace deprecated services.llama-cpp.extraFlags with settings |
| `0ec7760` | fix(module): merge llama-cpp settings via mkMerge |

## 2026-08-08T23:07:40+09:00

**摘要**：fix(breeze-black): look-and-feel 全局主題復元 + GTK 改名修正 — 7/23 外部補丁除去後 2 種後退：① org.kde.breezeblack.desktop 欠落 BreezeBlack 設定主題選択消失、local 内蔵復元；② preFixup Breeze* 同時匹配 Breeze/Breeze-Dark GTK 主題嵌套、Breeze 単独改名修正。

| 提交 | 説明 |
|------|------|
| `114b9c2` | fix(breeze-black): restore look-and-feel global theme + fix GTK rename |

## 2026-08-08T22:50:33+09:00

**摘要**：fix(codewhale-src): 0.9.4 同期 source hash 修正 — nix-prefetch-url archive tarball hash fetchFromGitHub（git 方式）不一致、riscv64 CI 連続失敗。fetchFromGitHub build 正 hash 取得、Cargo.lock 同期、技能誤助言修正。

| 提交 | 説明 |
|------|------|
| `08b04a2` | fix(codewhale-src): sync to 0.9.4 with correct fetchFromGitHub hash |
| `ab2a624` | fix(skill): correct fetchFromGitHub hash advice — archive tarball trap |

## 2026-08-08T22:20:21+09:00

**摘要**：codewhale 0.9.4 — 上流修正；mcp-searxng 1.14.1 — 上流保守；opencode-telegram 0.23.1 — 上流機能追加

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

**摘要**：chore(pkgs) — codewhale-src 0.9.3 同期（riscv64 source build 預編譯 3 版遅）。version、fetchFromGitHub hash、Cargo.lock（711 → 763 項目）同期。

| 提交 | 説明 |
|------|------|
| `563eea2` | chore(pkgs): sync codewhale-src to 0.9.3 — version, hash, Cargo.lock |

## 2026-08-05T01:30:00+09:00

**摘要**：refactor(skill) — nixkits-check-updates Rust 包（buildRustPackage）更新流程追加。codewhale-src Cargo.lock 同期経験汎化（version + source hash + Cargo.lock 三点同期、上流 lock 取得 項目数検証、交叉編譯 timeout 迂回）。

| 提交 | 説明 |
|------|------|
| `6e6bef6` | refactor(skill): add Rust package (buildRustPackage) update flow to nixkits-check-updates |

## 2026-08-04T02:15:00+09:00

**摘要**：fix(ruyi): ruff lint 失敗許容 — 第2 ruff check（--fix無）nixpkgs ruff 更新後 139件 上流違反 build 遮断。

| 提交 | 説明 |
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

**摘要**：fix(ci): ci-summary.yml 構文修正（YAML 破損、固定 token）、push/schedule 起動 + GITHUB_TOKEN 切替。README badge、check.yml（flake 評価 限定）自 shields.io endpoint（全 Build workflow 実状態反映）変更。

| 提交 | 説明 |
|------|------|
| `c0e52a5` | fix(ci): fix ci-summary.yml syntax, switch README badge to endpoint |

## 2026-07-31T03:34:15+09:00

**摘要**：fix(ci): GITHUB_TOKEN 注入 Nix access-token — llama-cpp-ver input GitHub API 要、未認証 60回/時 制限、並列 CI HTTP 403 頻発。`${{ secrets.GITHUB_TOKEN }}` 使用。

| 提交 | 説明 |
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

**摘要**：fix(codewhale-sudo): ptrace wrapper 修正 — 子追跡削除（sub-shell SIGTRAP kill 防止）、PTRACE_EVENT_EXEC 追加。4 言語文書同期更新（LD_PRELOAD → ptrace 記述）。

| 提交 | 説明 |
|------|------|
| `c77cadc` | fix(codewhale-sudo): stop tracing child processes, handle PTRACE_EVENT_EXEC |
| `480658e` | docs(codewhale-sudo): update mechanism description LD_PRELOAD → ptrace |

## 2026-07-23T12:08:13+09:00

**摘要**：fix(codewhale-sudo): LD_PRELOAD shim → ptrace 入替 — codewhale 静的連結故 LD_PRELOAD 以 prctl(PR_SET_NO_NEW_PRIVS) 捕捉 無効、ptrace(2) 採用。kernel 境界捕捉、静的 與 動的 双方対応。

| 提交 | 説明 |
|------|------|
| `6446364` | fix(codewhale-sudo): replace LD_PRELOAD shim with ptrace syscall interceptor |

## 2026-07-23T11:24:15+09:00

**摘要**：fix(overlays): breeze-black — 無効化 fetchpatch URL（injx.sbs 永久不可用）、純粋 局所 colors 手動入替。KDE Plasma 配色自動検出 share/color-schemes/ 経由。

| 提交 | 説明 |
|------|------|
| `547d6a0` | fix(overlays): replace dead breeze-black fetchpatch with local copy |

## 2026-07-22T16:31:26+09:00

**摘要**：fix(modules) — rog-control-center-fix、SendSIGKILL=yes + TimeoutStopSec=30s 追加、asus-shutdown 旧 process 残存 依 systemd-switch 阻塞 解決。comfyui-strix-halo、glibc >= 2.42 assertion 追加（ROCm 7.2 GLIBC_ABI_GNU2_TLS 必要）。

| 提交 | 説明 |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T09:00:00+09:00

**摘要**：feat(overlays) — breeze-black overlay 新規追加、Plasma 6 向 高対比 Breeze Black 障碍支援 主題 提供（全局 look-and-feel + GTK + 配色方案）。4 言語文書 含。

| 提交 | 説明 |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T05:39:31+09:00

**摘要**：docs(devshell) — devShell 文書 新規追加（4 言語）、opencode（MCP 全構成）與 ruyi（三通道 統合）開発環境 記述。README devShell 表 文書 link 列 追加。

| 提交 | 説明 |
|------|------|
| `7bfe3e3` | docs: add devShell documentation — 4 lang |
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |

## 2026-07-22T03:40:50+09:00

**摘要**：docs — 倉庫 全体 之 文書 内 利用者 目録 path `~/` 接頭辞 統一（直書 `/home/kix` 及 `/home/<user>` 等 変体 置換）、13 file 対象。

| 提交 | 説明 |
|------|------|
| `f597b9a` | docs: generalize hardcoded /home/kix paths |
| `bb65b77` | docs: unify all user home paths to ~/ prefix |

## 2026-07-22T03:14:27+09:00

**摘要**：feat(shells) — opencode devShell 反復：SearXNG + lighttpd（系統 NixOS 設定 與 一致）+ blender-mcp + godot-mcp + godot + opencode + opencode-telegram、初回 進入 時 MCP 設定 自動登録；godot 包 之 tryEval 保護 削除。

| 提交 | 説明 |
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

**摘要**：feat(overlays) — efl-cross-fix overlay 新規追加、efl（Enlightenment Foundation Libraries）之 riscv64/riscv64-musl/aarch64 交叉編集 時 原生 符号生成 道具（eolian_gen、eet）不足 起因 構築失敗 修正。4 言語文書 含。

| 提交 | 説明 |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**摘要**：codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3 — 上流更新（codewhale v0.9.0、依然 riscv64 預編訳 二進 無、源 構築 path 継続）

| 提交 | 説明 |
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

**摘要**：fix(ci) — ci-summary workflow `gh run list` 逐 workflow API 呼出 HTTP 403 rate limit 修正。2 回一括 `gh api` 呼出並列制御変更。

| 提交 | 説明 |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**摘要**：revert(skill) — katalish（半角片仮名機械翻訳）全内容削除：19 文書、技能（SKILL.md + 102 条辞書）、全言語切替連結。翻訳不安定（英文残留或文書構造破壊）生産環境不適。

| 提交 | 説明 |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:54:55+09:00

**摘要**：docs(nixkits-skills) —「既知 移除」章節「危険警告」改名、5 言語技能文書 同期。

| 提交 | 説明 |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**摘要**：skill(nixkits-skills) — Claude Code 導入対象削除（利用者資料基国籍推論安全境界越）、Codex 支援追加。SKILL.md「危険警告」節追記、原文声明含。

| 提交 | 説明 |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:35:20+09:00

**摘要**：skill(write-maintenance-log) — timestamp 規則 強化：`git log` 使用 強制、`T00:00:00` 占位符 禁止、生成後 検証 手順 新設。維護日誌 占位 時間 修正 経験 自 汎化（`968df0e`）。

| 提交 | 説明 |
|------|------|
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |

## 2026-07-16T04:30:55+09:00

**摘要**：feat(ci) — CI 集計端点徽章追加。主文書 CI 徽章 shields.io endpoint 経由 `gh-pages/ci-status.json` 読取、失敗時失敗包名表示。

| 提交 | 説明 |
|------|------|
| `6465260` | feat(ci): add CI summary workflow with endpoint badge |
| `b489890` | docs(README): switch main CI badge to endpoint |

## 2026-07-16T04:09:46+09:00

**摘要**：refactor(ci) — CI 単一 check.yml 25 独立 workflow 書類分割（包×構造毎）、徽章相互影響完全解消。再利用可能 `build-package.yml` 追加。

| 提交 | 説明 |
|------|------|
| `bc42e6f` | refactor(ci): split single check.yml into 25 isolated per-package-per-arch workflows |
| `1dfc1ee` | docs: update ruyi badge URLs to new isolated workflow files |
| `f235edc` | docs: embed version numbers in CI badge labels |

## 2026-07-16T04:00:46+09:00

**摘要**：fix(codewhale) — 源構築 riscv64 交叉編集修正：ring crate `-m64` 誤 cc crate 継承 host CFLAGS 起因、per-target CFLAGS 清空修正。

| 提交 | 説明 |
|------|------|
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |

## 2026-07-16T01:18:16+09:00

**摘要**：codewhale 0.8.67 — 二経路 構築（預編訳 x86_64/aarch64 + 源 構築 riscv64）。上流 v0.8.67 自 riscv64 預編訳 二進 削除；riscv64 現在 rustPlatform.buildRustPackage 経由 本地 Cargo.lock 自 構築。

| 提交 | 説明 |
|------|------|
| `0025476` | feat(codewhale): dual-path build — prebuilt for x86_64/aarch64, source for riscv64 |

|--------|--------|--------|
| codewhale | 0.8.66 (prebuilt ×3) | 0.8.67 (prebuilt ×2 + source riscv64) |

## 2026-07-15T08:32:13+09:00

**摘要**：mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 — 上流更新（codewhale 跳過：v0.8.67 従来 riscv64 二進 欠落）

| 提交 | 説明 |
|------|------|
| `48414d4` | chore(pkgs): bump mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 |

|--------|--------|--------|
| mcp-searxng | 1.11.0 | 1.11.1 |
| opencode-telegram | 0.22.1 | 0.22.2 |
| obs-bilibili-stream | 2.1.1 | 2.1.2 |
| codewhale | 0.8.66 | (skipped — upstream v0.8.67 still missing riscv64 binaries) |

## 2026-07-09T01:22:00+09:00

**摘要**：revert(ci) — `ci/` 削除、`llama-cpp-ver` input 上流 API 復元。上乗既 `tryEval` + fallback 備、局所緩衝不要。

| 提交 | 説明 |
|------|------|
| `dbdd937` | revert: restore llama-cpp-ver to upstream API, remove ci/ |

## 2026-07-09T01:14:34+09:00

**摘要**：obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 — 上流更新（codewhale 跳過：v0.8.67 riscv64 二進欠落）

| 提交 | 説明 |
|------|------|
| `73dc576` | chore(pkgs): bump obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| obs-bilibili-stream | 2.1.0 | 2.1.1 |
| mcp-searxng | 1.8.0 | 1.11.0 |
| opencode-telegram | 0.22.0 | 0.22.1 |
| codewhale | 0.8.66 | (跳過 — 上流 riscv64 二進欠落) |

## 2026-07-07T12:01:12+09:00

**摘要**：fix(docs): katalish/pcn 現地化修正 — katalish/ruyi.md 與 pcn/ruyi.md 言語切替修正（連結欠落・言語名重複）、pcn/ruyi.md 日本語自偽中国語全文書換。

| 提交 | 説明 |
|------|------|
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |

## 2026-07-05T04:41:23+09:00

**摘要**：fix(ci): blender-mcp riscv64-cross 自除外 — 上流 nixpkgs `sse-starlette` 交叉編集欠陥故 構築失敗（`blender` riscv64 非対応）；x86_64 / aarch64 影響無。

| 提交 | 説明 |
|------|------|
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |

## 2026-07-04T07:33:07+09:00

**摘要**：docs(MAINTENANCE) — 全 6 MAINTENANCE 書類（zh/en/ja/katalish/pcn）言語切替追加

| 提交 | 説明 |
|------|------|
| `9feb2fd` | docs(MAINTENANCE): add language switcher to all 6 MAINTENANCE files (zh/en/ja/katalish/pcn) |

## 2026-07-04T06:41:28+09:00

**摘要**：blender-mcp 1.0.0 — 新規 Blender MCP 伺服器包（Python 構築、22 MCP 道具、Blender 拡張含）

| 提交 | 説明 |
|------|------|
| `a1cf458` | packages: add blender-mcp (MCP server for Blender) |
| `ab9109a` | packages: add blender-mcp (MCP server for Blender) |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| blender-mcp | — | 1.0.0 |

## 2026-07-02T04:00:00+09:00

**摘要**：codewhale 0.8.66 — 上流更新（TUI配置修正、承認標籤改善、性能修正）

| 提交 | 説明 |
|------|------|
| `c00a5e6` | chore(pkgs): bump codewhale 0.8.66 |
| `c61d458` | docs: bump codewhale 0.8.66 version numbers in all 5-language docs |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.65 | 0.8.66 |
| 　 | cli hash (×3) | all updated |
| 　 | tui hash (×3) | all updated |

## 2026-06-28T06:30:00+09:00

**摘要**：opencode-telegram 0.22.0 — 上流更新（三模式TTS + thinking表示 + 緊湊出力 + /settings命令 + session起動修正）

| 提交 | 説明 |
|------|------|
| `b189d0a` | chore(pkgs): bump opencode-telegram 0.22.0 |
| `a61f444` | docs: bump opencode-telegram 0.22.0 version numbers in all 5-language docs |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.21.2 | 0.22.0 |
| 　 | source hash | `...` → `...` |
| 　 | npmDepsHash | `...` → `...` |

## 2026-06-26T13:00:00+09:00

**摘要**：CI — llama-cpp-ver 本地文件切替（ci/llama-cpp-ver.json）、全CI作業 GitHub API 呼出排除 rate limit 故 全構築失敗 恒久修正；docs — riscv64 徽章 包別 精密化（codewhale/kitsfmt/mcp-searxng/opencode-telegram）

| 提交 | 説明 |
|------|------|
| `8b3a3be` | fix(ci): use local path for llama-cpp-ver input, eliminate GitHub API calls from all CI jobs |
| `5db4852` | fix(docs): add per-package job filter to riscv64 badges |

## 2026-06-26T12:30:00+09:00

**摘要**：feat(opencode-telegram): 服務PATH系包装注入extraPackages選択肢home-manager路注入extraBinPaths選択肢追加、opencode不在服務PATH問題修正；5言語文書更新

| 提交 | 説明 |
|------|------|
| `7c98694` | feat(opencode-telegram): add extraPackages option to inject companion tools into service PATH |
| `45b7c57` | feat(opencode-telegram): add extraBinPaths option for home-manager users |

## 2026-06-26T10:55:41+09:00

**摘要**：codewhale 0.8.65 — 上流更新（cli二進名変更：codewhale-cli-linux → codewhale-linux）；mcp-searxng 1.8.0 — 上流更新（多実例故障転送/並列扇出、能力発見集約、safesearch修正）

| 提交 | 説明 |
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

**摘要**：docs(MAINTENANCE): pcn 欠落28件履歴項目補完、zh基準全93項目網羅

| 提交 | 説明 |
|------|------|
| `01f662b` | docs(MAINTENANCE): backfill 28 missing historical entries to pcn (93/93 zh baseline covered) |

## 2026-06-26T07:35:00+09:00

**摘要**：docs(MAINTENANCE): en/ja/katalish 欠落10件履歴項目補完、3言語全zh基準（92/92）一致；pcn 一部補完（66/92）

| 提交 | 説明 |
|------|------|
| `1921a36` | docs(MAINTENANCE): backfill 10 missing entries to en/ja/katalish (+ partial pcn) |

## 2026-06-26T07:18:56+09:00

**摘要**：fix(skill): write-maintenance-log 第4段階「多言語同期」雛形実行可能流書直（4a 言語発見 → 4b 言語別翻訳書込 → 4c 項目数一致検証）；AGENTS.md 第4段階検証確認強化

| 提交 | 説明 |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-26T06:19:21+09:00

**摘要**：監査修正 — 空 scripts/ 目録削除 .gitignore 死規則（translate_pcn.py）削除；AGENTS.md SKILL.md 行数制約硬性数値定性案内緩和

| 提交 | 説明 |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-25T11:02:38+09:00

**摘要**：ruyi — 交叉編譯 修正（postPatch 改用 python.pythonOnBuildForHost）；CI — ruyi 系列 riscv64-cross 復帰；docs — riscv64 徽章 恢復 精確 job filter

| 提交 | 説明 |
|------|------|
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |

## 2026-06-25T10:12:02+09:00

**摘要**：CI — riscv64-cross 恒久 除去 ruyi 系列（Python postPatch 交叉編譯 不可行）；docs — riscv64 徽章 恢復 * 標記 + 注釈 説明

| 提交 | 説明 |
|------|------|
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |

## 2026-06-25T10:04:30+09:00

**摘要**：CI — access-tokens 被覆 修正 引起 GitHub API rate limit 超過（合併 双行 一行）、riscv64-cross 並列 上限 4

| 提交 | 説明 |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |

## 2026-06-25T09:44:44+09:00

**摘要**：CI — riscv64-cross ruyi/ruyi-beta/ruyi-alpha 復帰（路映射）；docs — 徽章標籤簡略化 + riscv64 job 精密過濾

| 提交 | 説明 |
|------|------|
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |

## 2026-06-25T09:29:43+09:00

**摘要**：CI — build / riscv64-cross 包別 matrix 分割、独立徽章対応；docs — ruyi 徽章 9 枚（3版本×3架構）拡張

| 提交 | 説明 |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |

## 2026-06-25T09:24:43+09:00

**摘要**：CI — build job ruyi-beta / ruyi-alpha 構築段階追加；docs — ruyi 基本情報表格通道行 beta/alpha 版本番号追加

| 提交 | 説明 |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |

## 2026-06-25T09:09:26+09:00

**摘要**：CI — ruyi riscv64-cross 除外；overlays — default overlay ruyi-beta/ruyi-alpha 追加＋nixConfig flake 最上位層移行；docs — README 表 ruyi 3路版本表示

| 提交 | 説明 |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |

## 2026-06-25T05:35:00+09:00

**摘要**：docs — 全5言語README ruyi-beta / ruyi-alpha devShell 項目追加

| 提交 | 説明 |
|------|------|
| `5d4ca02` | docs: add ruyi-beta + ruyi-alpha to devShell tables (all 5 READMEs) |

## 2026-06-25T05:28:12+09:00

**摘要**：ruyi — 包装目録構造再編（packages/ruyi/）、beta/alpha thin wrapper化；devShells 追加

| 提交 | 説明 |
|------|------|
| `4b9865e` | refactor(pkgs): move ruyi into subdirectory, beta/alpha as thin wrappers |
| `94bb174` | feat(shells): add ruyi-beta + ruyi-alpha devShells |

## 2026-06-25T05:13:34+09:00

**摘要**：ruyi — 版通道独立包装化（ruyi / ruyi-beta / ruyi-alpha）、独立overlay削除

| 提交 | 説明 |
|------|------|
| `51f23ad` | refactor(pkgs): ruyi channels as separate packages (not overlays) |

## 2026-06-25T04:58:36+09:00

**摘要**：ruyi — 3通道版体系（stable/beta/alpha）、基本包装0.50.0安定版切替、beta/alpha overlay上書

| 提交 | 説明 |
|------|------|
| `a9f8baa` | feat(pkgs): ruyi 3-channel (stable/beta/alpha) via overlays |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| ruyi | 0.51.0-alpha.20260616 | 0.50.0（安定版） |
| 　 | 新規 ruyi-beta overlay | 0.50.0-beta.20260623 |
| 　 | 新規 ruyi-alpha overlay | 0.51.0-alpha.20260616 |

## 2026-06-24T03:19:30+09:00

**摘要**：workflow — 維護記録更新規則必須化（AGENTS.md + write-maintenance-log 技能）

| 提交 | 説明 |
|------|------|
| `2e719df` | fix: make maintenance log update mandatory after every push |

## 2026-06-24T03:15:37+09:00

**摘要**：docs — 古手動riscv64構築手順削除、CI 3架構網羅済

| 提交 | 説明 |
|------|------|
| `698400a` | docs: remove stale manual riscv64 build instructions — CI now covers all 3 architectures |

## 2026-06-24T03:06:20+09:00

**摘要**：codewhale 0.8.64 — 上流更新

| 提交 | 説明 |
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

**摘要**：CI — riscv64交叉編訳管追加、3架構CI全量網羅（x86_64 / aarch64 / riscv64）；包装毎riscv64徽章追加。

| 提交 | 説明 |
|------|------|
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |

## 2026-06-23T05:20:00+09:00

**摘要**：translate-pseudocn — Web調査基辞書拡充（7→46項目）、SVO語順変更、全pcn文書再生成。

| 提交 | 説明 |
|------|------|
| `4fbf387` | feat(pcn): expand dictionary 7→46 entries, add IT terminology from research |
| `ec38b7e` | feat(pcn): convert to SVO word order, expand dictionary, regenerate all 22 docs |

## 2026-06-23T04:19:16+09:00

**摘要**：translate-pseudocn技能再構築 — 疑似中国語「日本語仮名剥離後之視覚結果」再定義、中国語変換廃止。日本語漢字其儘保持（簡体字化無）、SOV語順維持、辞書40→7項目縮小（片仮名→日本語漢字）。全22件pcn文書再生成。

| 提交 | 説明 |
|------|------|
| `be0780b` | refactor(pcn): redesign pseudo-Chinese skill — Japanese-native kanji, SOV order, no Chinese chars |

## 2026-06-23T04:04:32+09:00

**摘要**：AGENTS.md — 硬符号化 除去、冗長 監査 備忘 削除、cache 章 代理 操作手引 改、利用者 側 記述 削除、言語体系 自動発見 改。

| 提交 | 説明 |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:49:00+09:00

**摘要**：mcp-searxng 1.7.2 — 上流 修正。

| 提交 | 説明 |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |

## 2026-06-22T23:22:00+09:00

**摘要**：AGENTS.md — 新規 初回 起動 監査 規則、接続制御 移動 頂部。

| 提交 | 説明 |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**摘要**：docs — README 重複 行 修正、write-project-docs 反模式 補充。

| 提交 | 説明 |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**摘要**：AGENTS.md — 新規 接続制御、言語 要求、送信 規範、保守記録 確認、文書同期、汎化、多架構 cache 規則。

| 提交 | 説明 |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**摘要**：docs — 毎包 文書 双架構 CI 徽章 追加、技能 雛形 同期。

| 提交 | 説明 |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**摘要**：CI — ARM runner 多架構 構築 追加、flake.lock 並行競合 修正（--no-write-lock-file）。

| 提交 | 説明 |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**摘要**：mcp-searxng — source hash + npmDepsHash 更新（GitHub archive 変化）；ruyi — overlay postPatch 復帰（patch file 依存）。

| 提交 | 説明 |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**摘要**：docs — cache 除外 警告 追加（overlay 與 模組 + patch 項目）、README cache 説明 圧縮、flake.nix nixConfig 自動 宣言 追加。

| 提交 | 説明 |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**摘要**：docs — 全 30 篇 包 文書 `## 缓存` 節 追加、CI 徽章 配置 改善、技能 同期。

| 提交 | 説明 |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**摘要**：CI/CD — GitHub Actions 構築 行列（Cachix push）追加、二進 cache、AGENTS.md。

| 提交 | 説明 |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**摘要**：skills — translate-katalish / translate-pseudocn / write-project-docs 辞書 與 雛形 分割、SKILL.md 60-80 行 迄 圧縮

| 提交 | 説明 |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**摘要**：docs — MAINTENANCE 時刻 精確化（29 節）、30 重複 節 削除（SHA 重複 除去）、nix-kits→nixkits 全量 置換（183 箇所）、模組 文書 同期

| 提交 | 説明 |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**摘要**：patches — ruyi-nixos-compat.patch 清浄 複製 自 再構築（1223→426 行）、flake.lock 自己参照 artifact 除去

| 提交 | 説明 |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**摘要**：overlays — patches 一覧 lib.unique 以 重複 除去、ruyi-nixos-compat 簡略化、llama-cpp-rocm curried 形式 注釈 追加

| 提交 | 説明 |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**摘要**：modules — 4 模組 enable 選項 追加、comfyui-strix-halo assertions 追加、名前空間 nixkits.* 迄 統一（後方互換 含）、llama-cpp-rocm hfCacheDir 動的 導出

| 提交 | 説明 |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**摘要**：codewhale 0.8.63 — 多構造 予構築 二進（x86_64 / aarch64 / riscv64）；ruyi — overlay postPatch 包 内 統合；meta 欄 補完

| 提交 | 説明 |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**摘要**：flake — mihomo-alpha 幽霊入力 與 overlay 削除（書類 一度 也 存在 不）

| 提交 | 説明 |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |

## 2026-06-21T04:32:31+09:00

**摘要**：言語切替器 札 規則 之 汎化 — display_name 之 意味 言語自称 至 修正、言語名称 不局所化 之 規則 write-project-docs / translate-katalish / translate-pseudocn 三技能 於 追加；zh/katalish/pcn 全文書 之 切替器 内 残留 之 局所化 名称 修正

| 提交 | 説明 |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称與切换器标签分离 |
| `aa8634b` | fix(docs): zh 文檔切换器残留旧名称修正 + MAINTENANCE 翻訳补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**摘要**：codewhale 0.8.62 — 上流修正；mcp-searxng 1.7.1 — 上流修正

| 提交 | 説明 |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

## 2026-06-20T18:36:33+09:00

**摘要**：技能体系 之 再構成 — translate-katakana→translate-katalish 改名、translate-pseudocn（偽中国語）新設、write-project-docs 與 write-maintenance-log 之 言語拡張自動発見、docs-as-code 五語 対照表

| 提交 | 説明 |
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

**摘要**：codewhale 0.8.61 — 上流修正；mcp-searxng 1.6.0 — 上流修正

| 提交 | 説明 |
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

**摘要**：ruyi — NixOS 互換性 補丁（`patches/ruyi-nixos-compat.patch`）、予構築 RISC-V 工具鎖 之 動的連結器 経路、GCC 副工程 ELF 解釈 修正 與 console_scripts argv0 問題 透過的 処理

| 提交 | 説明 |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

## 2026-06-17T10:59:35+09:00

**摘要**：ruyi — NixOS 部品（`services.ruyi`）、宣言的 `/etc/xdg/ruyi/config.toml` 與 環境変数 生成

| 提交 | 説明 |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

## 2026-06-17T10:03:05+09:00

**摘要**：ruyi — devShell 支援 新設、`nix develop github:Kihara777/NixKits#ruyi` 以 環境 進入 可能

| 提交 | 説明 |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

## 2026-06-17T09:48:33+09:00

**摘要**：ruyi 0.51.0-alpha.20260616 — RuyiSDK 包管理者、新包（Python / Poetry 構築、ruff + mypy + 320 単体試験 + 52 統合試験 全通過）

| 提交 | 説明 |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 軟体名 | 新版 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

## 2026-06-17T07:37:39+09:00

**摘要**：write-maintenance-log 技能 — nixkits-check-updates 自 独立 技能 至 分離、二重 入口 設計（記入 維護記録 + 更新 維護記録）；flake.lock 同期 .gitignore 事前 検査 與 三路 分岐 論理

| 提交 | 説明 |
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

**摘要**：fix(mcp-searxng): 入口 書類 之 錯誤 修正 — dist/index.js → dist/cli.js、MCP server 正常 起動 可能

| 提交 | 説明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

## 2026-06-17T06:46:13+09:00

**摘要**：llama-cpp-rocm — builtins.fetchurl 代替 flake input 動的版取得試行（既撤回、方案不可用）

| 提交 | 説明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

## 2026-06-16T06:03:24+09:00

**摘要**：mcp-searxng 文書 — CodeWhale MCP 設定指南、常見罠警告（env 既定 {}）、故障排查章節

| 提交 | 説明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

## 2026-06-16T05:20:34+09:00

**摘要**：nixos-modern-cli 技能 — Nix Store 路径 罠 章節（gh auth setup-git 硬碼 路径 失效 診断 與 汎用 修正 pattern）

| 提交 | 説明 |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

## 2026-06-16T04:56:06+09:00

**摘要**：opencode-telegram 0.21.2 — 上流修正及依存更新

| 提交 | 説明 |
|------|------|
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |
| `3b05a32` | docs(MAINTENANCE): record 2026-06-16 update (opencode-telegram 0.21.2) |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | source hash | `...` → `...` |
| 　 | npmDepsHash | `...` → `...` |

## 2026-06-15T17:32:16+09:00

**摘要**：codewhale 0.8.60 — 上流修正

| 提交 | 説明 |
|------|------|
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |
| `3cef0a8` | docs(MAINTENANCE): record 2026-06-15 update (codewhale 0.8.60) |

| 軟件名 | 舊版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `...` → `...` |
| 　 | tui hash | `...` → `...` |

## 2026-06-14T08:11:16+09:00

**摘要**：comfyui-strix-halo 文書 — 線上統合 mode 説明 與 書類 構造図

| 提交 | 説明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

## 2026-06-14T07:56:11+09:00

**摘要**：codewhale 0.8.59 — 若干 TUI 描画問題修正；mcp-searxng 1.4.0 — HTTP 転送 mode 新規

| 提交 | 説明 |
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

**摘要**：llama-cpp-rocm 模块 — modelsPreset 支持復旧（nixpkgs 既削除）、名前空間 nixkits 移行、三言語移行指南

| 提交 | 説明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

## 2026-06-12T17:29:59+09:00

**摘要**：feat(llama-cpp-rocm): modelsPreset 支援 復元（nixpkgs 既 削除）、名前空間 nixkits 至 移行

## 2026-06-12T10:51:31+09:00

**摘要**：codewhale 0.8.58 — 上流修正；mcp-searxng 1.3.4 — 上流修正

| 提交 | 説明 |
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

**摘要**：技能文書 — 維護記録 格式 規則 系列（自動発見 汎化、記述的 標題、正確 git commit 時間印、禁止 `T00:00:00` 占位符）

| 提交 | 説明 |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

## 2026-06-11T05:13:39+09:00

**摘要**：other — 2件更新

| 提交 | 説明 |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

## 2026-06-11T04:52:16+09:00

**摘要**：codewhale 0.8.57 — TUI 新規追加；mcp-searxng 1.3.2 — 上流修正

| 提交 | 説明 |
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

**摘要**：opencode-telegram — KillMode process変更、TimeoutStopSec 追加 防止 shutdown 掛起

| 提交 | 説明 |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

## 2026-06-10T02:28:10+09:00

**摘要**：codewhale 0.8.55 — 上流修正；mcp-searxng 1.3.1 — 上流修正

| 提交 | 説明 |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

## 2026-06-08T15:12:39+09:00

**摘要**：文書再構 — 地域化文件 docs/ 目録移入；MAINTENANCE.md 初回合列規則追加、純表格形式、完全提交歴史逆填

| 提交 | 説明 |
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

**摘要**：mcp-searxng 1.2.1 — 上流修正

| 提交 | 説明 |
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

**摘要**：rcc-fix — NixOS 模块（systemd 死鎖修正）

| 提交 | 説明 |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

## 2026-06-06T15:17:11+09:00

**摘要**：技能文書 — 源変更後文書同期規範；comfyui-strix-halo C 道具鎖説明；hash 計算注意事項汎化；基本情報規則多言語統一

| 提交 | 説明 |
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

**摘要**：codewhale 0.8.53 — 上流修正；mcp-searxng 1.1.0 — 上流修正；opencode-telegram 0.21.1 — 上流修正

| 提交 | 説明 |
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

**摘要**：comfyui-strix-halo 補丁 — ROCm 7.2 wheels 内蔵 支援

| 提交 | 説明 |
|------|------|
| `e11f899` | fix(docs): add missing ja doc and en/ja README entries for comfyui-strix-halo |
| `48d842f` | docs(ja): add 基本情報 section to comfyui-strix-halo |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs in NixKits concise style |
| `8f16f91` | docs(skill): add length/structure rules from comfyui-strix-halo doc fix |
| `468b89a` | feat(skill): add patch-embedded version check for comfyui-strix-halo |

|--------|--------|--------|
| comfyui-strix-halo | 修正（ROCm 7.2 wheels 内蔵） |

## 2026-06-04T13:07:30+09:00

**摘要**：技能体系 — SKILL.md 全面中国語化；三言語対称性確認規則

| 提交 | 説明 |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

## 2026-06-02T10:15:53+09:00

**摘要**：other — 7件更新

| 提交 | 説明 |
|------|------|
| `3be4889` | docs: add recover-nixos-config skill with multi-language docs |
| `fc5eca3` | docs: fix Skills section titles and generic agent descriptions |
| `d2e071f` | docs: add quantization levels to local model names |
| `22d206c` | docs: add UD- prefix to model quantization labels |
| `f15db79` | docs: add MIT license file and link from all READMEs |
| `218aeca` | docs: add local flake input example alongside remote |
| `4f0f968` | docs: fix local flake input syntax to match actual usage |

## 2026-06-02T08:49:47+09:00

**摘要**：opencode-telegram — 8件更新

| 提交 | 説明 |
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

**摘要**：codewhale 0.8.49 — 上流修正；mcp-searxng 1.0.4 — 上流修正；obs-bilibili-stream 2.1.0 — 上流修正；opencode-telegram 0.21.0 — 上流修正

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

**摘要**：nixos-modern-cli 技能 — POSIX 道具指南 nix 二進路提示

| 提交 | 説明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

## 2026-05-31T03:42:18+09:00

**摘要**：write-project-docs — 新技能（NixKits 風任意 project 多語言文書体系作成）

| 提交 | 説明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

## 2026-05-30T03:42:14+09:00

**摘要**：codewhale — stdenv 綴修正；llama-cpp-rocm 文書修正（内line連結削除、system.nix 完全 preset 使用）；opencode-telegram 初回設定流

| 提交 | 説明 |
|------|------|
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

## 2026-05-30T03:19:48+09:00

**摘要**：other — 2件更新

| 提交 | 説明 |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

## 2026-05-29T15:25:12+09:00

**摘要**：kitsfmt — 複数 修正（vendor 目録 復元、冪等性、就地 安全性、with→builtins.attrValues 変換、--stdin 旗）；rcc-fix — D-Bus 熱挿抜 検出 至 書換；build — .vscode gitignore 範囲 修正

| 提交 | 説明 |
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

**摘要**：docs: codewhale 種別説明修正（事前構築済、非原始碼構築）

| 提交 | 説明 |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

## 2026-05-29T10:18:46+09:00

**摘要**：codewhale v0.8.47 — 新包

| 提交 | 説明 |
|------|------|
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |

|--------|--------|--------|
| codewhale | v0.8.47 |

## 2026-05-29T06:28:50+09:00

**摘要**：fix(kitsfmt): inherit 読点、縮進字符串 破損、lambda 空白 等 複数 整形問題 修正；冪等性 修正

| 提交 | 説明 |
|------|------|
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |

## 2026-05-29T05:57:55+09:00

**摘要**：fix(build): .vscode gitignore 範囲 過広 故 vendored crate 書類 排除 修正

## 2026-05-28T08:29:27+09:00

**摘要**：llama-cpp-rocm — NixOS 部品（systemd 沙箱 上書）；opencode-telegram — NixOS 部品（宣言的設定、自動 導入）；rcc-fix — visible 属性 修正；技能文書 — 動的発見 表現

| 提交 | 説明 |
|------|------|
| `3d2c38c` | docs(skill): nixkits-check-updates — dynamic discovery, not hardcoded list |
| `e5ee4ab` | docs(skill): remove hardcoded count from features, add exclusion note |
| `814731e` | docs(skill): sync ja doc with zh/en — dynamic discovery wording |
| `713b693` | fix(rcc-fix): use visible: property instead of if conditional for ScrollView |
| `34d309b` | docs(skills): add Install section with full 5-agent support to all skills |
| `2db934e` | docs(zh): simplify Skills description, remove semantic duplication |
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

## 2026-05-27T06:08:13+09:00

**摘要**：技能体系 — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三大技能 同期 公開；llama-cpp-rocm 動的追跡 説明

| 提交 | 説明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

## 2026-05-26T05:30:58+09:00

**摘要**：文書 — README 節名改名（快速開始→追加、包→軟件、License→許可）

| 提交 | 説明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

## 2026-05-24T03:01:02+09:00

**摘要**：mcp-searxng 文書 — SearXNG + lighttpd 逆代理完全 NixOS 構成

| 提交 | 説明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

## 2026-05-22T06:45:11+09:00

**摘要**：llama-cpp-rocm — llama-cpp-ver flake 入力削除、nixpkgs 既定版使用

| 提交 | 説明 |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

## 2026-05-21T16:35:02+09:00

**摘要**：mcp-searxng v1.0.3 — 新包；opencode-telegram v0.20.5 — 新包

|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

## 2026-05-16T19:07:54+09:00

**摘要**：kitsfmt — `match_ast!` 宏構文誤 修正、`comments_before` 関数 簡素化、src 路 修正

| 提交 | 説明 |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路経 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

## 2026-05-15T16:59:28+09:00

**摘要**：kitsfmt — rnix AST 基盤 格式化 engine v0.3.0 書換；Cargo.lock 生成

| 提交 | 説明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |

## 2026-05-14T17:10:06+09:00

**摘要**：llama-cpp-rocm — 新包（動的追跡 上流 最新 Release）

| 提交 | 説明 |
|------|------|
| `9cb24a3` | llama-cpp MTP |

|--------|--------|--------|
| llama-cpp-rocm | 動的（構築時取得上流最新 Release） |

## 2026-05-14T07:38:08+09:00

**摘要**：kitsfmt — 新包（自前 Nix 整形器）；obs-bilibili-stream v1.0.0 — 新包

| 提交 | 説明 |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

## 2026-05-01T01:08:15+09:00

**摘要**：rcc-fix — 新包（asusctl 補丁）

| 提交 | 説明 |
|------|------|
| `e2d09a2` | RCC-Fix |

|--------|--------|--------|
| rcc-fix | 追従 nixpkgs（上乗 + 修正） |

