# dsh-api-balance

[中文](../zh/dsh-api-balance.md) | [English](../en/dsh-api-balance.md) | [日本語](../ja/dsh-api-balance.md) | 偽中国語

API 用量残高插件（DeepSeek Harness）——webui 用量圓環（送信按鈕左 上下文使用量表示）弹出面板「用量 / 余额」標籤切替提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | DSH Host + Client 插件（npm package） |
| npm 名 | `@kihara777/dsh-api-balance` |
| 版本 | `0.1.0` |
| 許可 | MIT |
| 數據來源 | DeepSeek 公式 `GET /user/balance`（API キー認証）+ platform 控制台用量 API（platform 会話 token 認証） |

## 功能

- **用量**：原内容（上下文占有率与内訳）
- **余额**：當前 API KEY 帳戶情報（キー末尾、残高可否、通貨別総残高 / 充值残高 / 付与残高）、消耗明細与用量図表——消耗明細同一区域水平翻頁（1 頁目：当日 / 当月 / 30 日、2 頁目：模型別内訳 + 日別 / 月別 chart）、上方類手機主屏幕頁面指示 dot（tap 可、横 drag / swipe 翻頁）、区域高度當前頁内容応自動増減（切頁即回収）自身不 scroll（全内容面板自身縦 scroll 依存）
- 宿主側 30 秒 TTL 緩存；API キー `credentials` service `apiKeyEnv`（預設 `DEEPSEEK_API_KEY`）解決、進程環境変數回退

### platform token 取得（二段、全自動優先）

- **本機瀏覽器自動掃描（預設有効）**：宿主本機 Chromium 系瀏覽器（Edge / Chrome / Brave / Chromium / Vivaldi / Opera、全 Profile）`Local Storage/leveldb` 読取、LevelDB 表構造精確解析（footer → index → 數據 block → snappy 解凍 → entry 走査）`userToken` 取出（解析失敗時生 byte 啓発式回退）、初命中 `$DSH_HOME/api-balance-token`（0600）保存。本機瀏覽器一度 platform 登録済即無感取得；節流預設 6 時間最多一回（`browserScanIntervalMs` 設定可、`browserScan = false` 無効）、token 失効（40003/401）後次回 query 即再掃描。
- **未登録検出与登録案内**：scan 不命中時面板「platform 未登録」prompt 自動表示——「前往登録」新標籤開登録頁、polling token 自動取得。手動輸入 prompt 内二級 option 限定（登録不要時備）。接続後灰顯「✓ 登録済」按鈕与 token 取得元（本機瀏覽器自動取得 / 手動連接）表示、手動更新毎 token 未取得時自動快掃登録状態確認——按鈕操作不要。

### 界面設定（⚙ 設定 → 界面）

- **底部統計条**：越界内容横向 scroll 表示、scrollbar 隠蔽（預設有効）。無効時省略号截断（hover 全文表示）復帰。
- **Enter key 動作**：Enter = 改行、Shift+Enter = 送信（預設有効；DSH 原生動作 Enter = 送信）。無効時原生動作復帰。会話入力欄限定作用、他入力欄不影響。
- **移動端 session 切替 keyboard 不弹出**：觸屏 device 側欄 session 切替時入力欄自動聚焦阻止、軟 keyboard 自動表示防。入力欄 tap 通常入力可。預設有効、此処無効化可。
三設定預設有効、瀏覽器 localStorage 永続化。

### 峰谷課金標記

DeepSeek 現行峰谷課金規則（官方価格頁脚注）：**峰 = 週一〜週五 北京時間 09:00–12:00、14:00–18:00、其余（週末終日含）低谷価格**。峰時間帯：用量リング（送信 key 左円形按鈕）、用量頁 context 進捗 bar 与各明細色塊、更新/load 動画、使用量 chart 一括紅色系表示——chart 内各 model 異紅 tone（紅但区分可、図例同同期）維持、chart 標題横赤「峰時課金」badge 表示（hover 時間帯説明）。紅表示官方峰時間帯合わせ自動入/解除（30 秒毎境界再検査）、手動更新不要。峰開始与終了両方通知自働再生（pack `peak` / `peakEnd` segment 優先、無時 TTS 回退）。「余额」標籤 click（手動更新）挨拶音声後峰提示追加（pack `peak` segment 優先、無時 TTS 回退）。

### 音声放送

使用量 chart「日別 / 月別」切替按鈕 click 時対応視図音声使用量放送（pack segment + TTS 數字連結）。内容：入（未命中輸入）、缓存命中、出、金額（幣種）——官方使用量頁分項基準一致。放送語言与音色 DSH 界面語言（zh / en）追従。「⚙ 設定 → 音声」標籤備：

- 自動放送 switch（残高閾値下通知、30 分 rate 制限）
- TTS backend 選択（瀏覽器内蔵 / 自訂 TTS API——host 経由 proxy CORS 回避、URL template placeholder `{text}` `{lang}` `{rate}`）
- 音声 pack library 管理（複数 zip import、行 click 使用 pack 切替、複数選択一括削除；各 pack 展開「音声試聴」——該 pack 対応全音声一条毎試聴可；`$DSH_HOME/api-balance-voicepack/` 保存全 device 共有）
- 「音声 pack 管理」次級 menu 内作成器（瀏覽器録音或音声 file import、録音中可視化浮窗与 sample text 表示、言語跨録音可能、打包 download / compile 適用）

#### 音声 pack 形式指南

音声 pack **zip archive**（配布共有便利）、`manifest.json` 与音声 file 含。面板「⚙ 設定 → 音声」.zip import 即有効、削除即預設全文 TTS 放送復帰。

zip 構造：

```
voice-pack.zip
├── manifest.json
└── audio/
    ├── dead.mp3
    ├── low.mp3
    └── …
```

```json
// manifest.json
{
  "format": "dsh-api-balance-voice-pack",
  "version": 1,
  "name": "我的 pack",
  "lang": "zh-CN",
  "segments": {
    "dead": "audio/dead.mp3",
    "low": "audio/low.mp3",
    "peak": "audio/peak.mp3",
    "peakEnd": "audio/peakEnd.mp3",
    "today": "audio/today.mp3",
    "month": "audio/month.mp3",
    "inLabel": "audio/inLabel.mp3",
    "outLabel": "audio/outLabel.mp3",
    "cacheHitLabel": "audio/cacheHitLabel.mp3",
    "costLabel": "audio/costLabel.mp3",
    "tokenUnit": "audio/tokenUnit.mp3",
    "suffix": "audio/suffix.mp3",
    // 任意：挨拶音声配列（頁面更新時 random 再生）
    "greetings": ["audio/greet0.mp3", "audio/greet1.mp3"]
  }
}
```

| segment | 用途 |
|------|------|
| `dead` | 残高不足警告全文 |
| `low` | 低残高警告全文 |
| `peak` | 峰時課金提示（挨拶音声後追加） |
| `peakEnd` | 峰時課金終了提示（紅表示自動解除時再生） |
| `today` | 「当日消耗」放送 prefix |
| `month` | 「当月消耗」放送 prefix |
| `inLabel` | 「入」標籤 |
| `outLabel` | 「出」標籤 |
| `cacheHitLabel` | 「缓存命中」標籤 |
| `costLabel` | 「金額」標籤 |
| `tokenUnit` | 数字後単位（例「個 token」、再利用可） |
| `suffix` | 放送結尾 |

全 segment 任意：欠落 segment 放送時 TTS 回退。面板呈現与官方使用量頁基準一致：「入」未命中輸入限定計上、缓存命中別列（token 与金額數據官方 API 日粒度 bucket 取得、二次合算不）。作成器 sample text 預設 TTS 兜底文案一字不差（録音 pack 預設 TTS 体験接近保証）；動的數字（token 数、金額与幣種）當前 TTS backend 合成、「pack segment + TTS 數字」順連結。任意 `greetings` file 路配列（0–32 個）：音声放送有効時、「余额」標籤 click（手動更新）毎 random 一個挨拶/着地音再生。挨拶音声無時 TTS 挨拶 pool random 再生。

**作成与共有**：「設定 → 音声 → 音声 pack 管理」→「音声 pack 作成」作成器開——先 pack 語言（zh-CN / en / ja）選択（sample text 与 manifest `lang` 決定、言語跨録音可能）；segment 逐段瀏覽器 mic 録音、挨拶 list 逐条録音（「添加挨拶」list 拡張、✕ slot 削除、sample text 預設 TTS 挨拶 pool 対応）；或 local 音声 file import。録音中右下可視化浮窗（level meter + 経過時間 + sample text + 停止/破棄）表示。完了後「打包 download」共有 zip 生成、「compile & 適用」本機 library import 即適用可。音声 pack import 済時、初回編集時上書警告表示確認必要（session 内一回）。

**制約**：segment key `[A-Za-z0-9_-]{1,32}`；segments ≤ 32 個、greetings ≤ 32 個（zip entry 合計 ≤ 64）、音声 1 file ≤ 2 MB。音声 mp3 / wav / ogg / webm 推奨、1 segment 2 秒以内、22.05/44.1 kHz mono。動的部分（残高數字、token 数等）pack 不含——當前 TTS backend（瀏覽器内蔵或 host 経由 proxy 自訂 TTS API）実時合成、「pack segment + TTS 數字」順連結完全放送。

## 導入

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-api-balance;
    id = "api-balance";
    name = "@kihara777/dsh-api-balance";
    # config（任意）：
    #   apiKeyEnv = "DEEPSEEK_API_KEY";   # credential-ref
    #   baseURL = "https://api.deepseek.com";
    #   browserScan = true;               # 本機瀏覽器自動掃描
    #   browserScanIntervalMs = 21600000; # 掃描節流（預設 6 時間）
  }];
}
```

## 注意

- 残高數據 DeepSeek 官方 API、用量數據 platform 控制台内部 API 由来——認証方式異（API キー / platform 会話 token）、一方欠時該当視図 error 非表示未登録状態表示。
- 自動掃描本機瀏覽器登録済 token 限定読取、瀏覽器外數據不採集。token file `0600` 権限落盤。
- 面板頁面級 overlay（document 級 fixed portal、会話区域 clip 不、横屏/窄幅均画面外出不）；高度「锚点上方可用空間」自動 clamp（手機横屏 top bar 遮蔽回避）；横向可用幅不足時内容適応幅維持、面板横 scroll 表示、縦向同面板自身 scrollbar 表示。


### 設定存儲層

界面与語音設定（語音提醒、底部統計条横 scroll、Enter 改行 + Shift+Enter 送信交換、mobile 会話切替時 keyboard 抑止、TTS backend）為**瀏覽器 localStorage 状態**：毎瀏覽器独立、既定有効、插件 `⚙ 設定` panel 内切替即時永続化。此等 DSH host 設定系統（`settings.register` / `settings.yaml`）**不経由**、故 `nixkits.dsh.settings` 此等文書化 override **提供無**——此類「毎瀏覽器偏好」device 別 panel 内設定。host 側插件参數（`apiKeyEnv` / `baseURL` / `browserScan` / `browserScanIntervalMs`）依然 `nixkits.dsh.plugins.packages[].config` 声明設定。
