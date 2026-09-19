# 安全政策

[中文](../SECURITY.md) | [English](SECURITY.en.md) | [日本語](SECURITY.ja.md)  | 偽中国語

## 支持 版本

本 project flake 形式 配布、**最新 `main` branch 限定** 安全修正 受取。
過去 commit 個別 維持 不——旧版本 必要 場合 fork 自身 維持 願。

| 範囲 | 支持 |
|------|---------|
| `main` branch（最新） | ✅ 安全修正 受取 |
| 公開済 flake 出力（旧世代） | ❌ 最新 更新 願 |
| `dsh-api-balance` sub project | 同 sub project **独自 安全政策 整備済**（評価済 報告一覧 與 設計境界 含）——脆弱性 其 [独立 repo 非公開報告 channel](https://github.com/Kihara777/dsh-api-balance/security/advisories/new) 報告、或 [`SECURITY.md`](https://github.com/Kihara777/dsh-api-balance/blob/main/SECURITY.md) 参照 |

## 脆弱性 報告

**安全問題 公開 issue 報告 不 下 願。**

以下 何方 非公開 channel 利用 願：

1. **GitHub 非公開脆弱性報告**（推奨）：<https://github.com/Kihara777/NixKits/security/advisories/new>
2. mail：`npm@g41.moe`

可能 範囲 以下 含 願：

- 影響 component（package / module / 技能 / plugin）與 file path
- 再現手順 又 概念実証
- 影響評価（data 読取、code 実行、権限昇格、service 拒否）
- 修正案 有 場合 其 内容

## 対応期限

本 project **一級視覚障害 証明** 保有 個人 維持。
体調 対応速度 影響 受 場合 有——其 現実的 制約 理解 願。

| 段階 | 目標 |
|------|------|
| 受領確認 | 7 日以内 |
| 初期評価 | 14 日以内 |
| 修正 又 緩和 | 深刻度 與 体調 変動。連絡 継続 |

深刻 問題 優先 対応。長期間 応答 無 場合、督促 mail 再送 願。

## 既知 設計境界

以下 **脆弱性 非** 意図 挙動。報告前 確認 願：

| 項目 | 説明 |
|------|------|
| `nixkits.dsh.reverseProxy.autoAuth` | 宣言的 **認証不要 入口**。信頼 LAN 限定 有効化 願。risk 利用者 network 境界 負担（`docs/zh/dsh.md` 参照） |
| `sudo` daemon | root 必要 操作 外部 sudo daemon 経由 実行 記録。sandbox 権限段階 利用者 session 毎 明示的 選択、**既定 一切 緩 不** |
| `dsh-api-balance` browser Local Storage 読 | platform session token 取得 為。**既定 有効、無効化 可能**。token 限定 読、browser 内 他 data 収集 不。token `0600` 保存 |
| `/nix/store` 絶対 path | 設定 埋込 store path GC 後 無効——既知 罠 脆弱性 非。`nixos_cli op=audit-store-paths` 監査 可能 |

## 評価済 外部報告（close 済 含）

以下 報告 全部 **項目毎 精査**、証拠 公開 回答 済。
**掲載 理由 後続 報告者 同種 問題 再提出 無 済 様 為**——
何 結論 誤 思 場合 知 願。再評価。

| 報告 | 主張 | 結論 | 根拠 |
|------|------|------|------|
| PR #4（@anupamme） | `/token` / `/voicepack` / `/tts` rate 制限 無 | **誤検出、merge 不** | 説明 diff 不一致（実際 変更 `/query` 限定）。rate 制限 key `x-forwarded-for` client 偽造 可能、local 同一 origin RPC 此 header 送 無 故、全 local traffic 単一 bucket 集約 利用者 自身 panel 制限 |
| PR #5（@anupamme） | `/query` request body size 上限 無 | **誤検出、merge 不** | 其 防御 `readJsonBody` 64 KiB 上限 既存。追加 `content-length` 検査 chunked 回避 可能、`text.length` byte 数 非 UTF-16 code 単位 数 |
| issue #1（@begininvoke） | `secrets: inherit` 最小権限 違反 | **誤検出、close** | 被呼出側 同一 repo 内 local workflow（issue 想定 外部 source 非）。repo secret 合計 2 個 限定、明示受渡 也 `inherit` 也 集合 完全同一——攻撃者 利得 無 |
| issue #2（@begininvoke） | issue #1 同（byte 単位 完全重複） | **重複、close** | 同上 |

> 此等 報告 **規則 概 事実 突**、但 脅威 model 本 project 配備形態 該当 不。
> 我々「先 精査、再現可能 証拠 添 回答」方針 扱、無条件 受入 不。

### 重複投稿 就

**上表 既 記載 同一 結論、新 証拠 無 再投稿 場合、本節 指 示 其 侭 close。**

此 security 報告 拒否 非、線引：

| 受理 | 其 侭 close |
|---------|-------------|
| 上表 含 無 **新規** 問題 | 上表 同一 結論、新 証拠 無 重複報告 |
| 上表 何 結論 **誤** 指摘（再現可能 証拠 添 場合） | 上表 既 有 結論 単 再述 |
| 同一 主題 但 **異** 脅威 model 又 攻撃経路 | 同一 規則 再度 出力 自動 scan |

**「結論 誤」指摘 常 歓迎**——上表 4 件 也 精査 上 判断、其 根拠 自体 誤 場合 訂正。

### 此等 齎 実際 改善

此等 報告 **2 件 実際 堅牢化** 繋——報告 自体 誤検出 但、指 方向 追 価値 有：

| 堅牢化 | 内容 |
|--------|------|
| **`/tts` endpoint SSRF** | 何 報告 也 言及 無、但 endpoint 精査 過程 発見：此 proxy 任意 `http(s)` URL 受、host 身分 request 発行、user 制御 `headers` 其 侭 転送。修正済——loopback / private / link-local / 予約 address 拒否（IPv4-mapped IPv6 含）、custom request header whitelist 化。**当該 endpoint `dsh-api-balance` 共 [独立 repo](https://github.com/Kihara777/dsh-api-balance) 移転 済** |
| **CI 最小権限** | issue 精査 過程 発見：31 build workflow `permissions` 宣言 無、repo 既定（読書 可能）継承、但 必要 `contents: read` 限定。全部 更新 |

**意味**：本 repo 報告 歓迎、真剣 精査。誤検出 迷惑 扱 不——上記 4 件 報告 最終的 2 件 実際 堅牢化 繋。

## Supply chain 説明

- 本 repo CI 第三者 GitHub Actions **commit SHA 固定**（浮動 tag 非）
- repo **何 秘密情報 也 含 不**。認証情報 常 外部 置、`path:` input 経由 取込
- build 成果物 公開 Cachix binary cache push
- build workflow 最小権限 明示 宣言（`contents: read`）
