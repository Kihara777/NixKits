# 新聞三要素模式（Agent 預設）

[中文](../../zh/modes/news-three-elements.md) | [English](../../en/modes/news-three-elements.md) | [日本語](../../ja/modes/news-three-elements.md)  | 偽中国語

> 極簡模式派生之**読取専用**創作預設：実在新聞形式以「新聞三要素」備之露風速報創作、session 初期化時技能包全体 online 取得。

## 基本情報

| 項目 | 値 |
|------|-----|
| 模式 id | `news-three-elements` |
| 配布方式 | **独立包** `dsh-preset-news-three-elements`（`packages/dsh-preset-news-three-elements.nix`）。模組 `$out/share/dsh-agent-presets` roster 之追加預設 root 登録 |
| 有効化選項 | `nixkits.dsh.presets.newsThreeElements = true` |
| 包上書（任意） | `nixkits.dsh.presets.newsThreeElementsPackage`（既定 `pkgs.dsh-preset-news-three-elements`） |
| 派生元 | 極簡模式（dsh 同梱 `minimal` 預設） |
| 技能依存 | 倉庫 `skills/news-three-elements/`（session 起動時 online 取得、同梱 snapshot fallback） |

## 動作

**TASS、Meduza、iStories 綜合電** —— 本倉庫 engineering desk 通報 依、本模式所行唯一個：技能従之速報創作。其他挙動以下：

- **読取専用**：閲覧系工具限定掛載（`read`、`read_image`、`glob`、`grep`、`web_search`、`web_fetch`、`skill`、`ask_user_question`）；`write` / `edit` 雖 工具表掲載、呼出 一律 `readonly-gate` 通信社文体 拒否（許可一覧外 既定拒否故、将来追加工具 亦誤通過無）。
- **online 技能包**：session 起動時 倉庫 `skills/news-three-elements/` 全包取得（5 書類、8 秒上限；失敗時 0/30/120 秒再試、長時間 session 6 時間毎再確認）。先 局所最新副本登録（cache 優先、無時同梱 snapshot）。技能包 読取専用掛載、速報 disk 殘留無。
- **開始時問答**：session 初期化完了後 三択提示（client 側 自由入力 可）。選択 `agent.followup()` 経由 本 session 最初 user message 化。
- **言語審査**：簡体中文以外之請求 一律拒否（漢字無 / 仮名 / 諺文 plugin 硬検出、簡体字與繁体字判読 model 委譲）。拒絶文 中国語通信社文体 書就、其後**《好意》 用戶所用言語之 localize 版 添付**——同一拒絶文之訳文、同様「我们从不制造 FAKE NEWS！！」與自称 強調。中国語学習示唆 **毎回引直**。引 対象 **人**——三名製作者自 一名 無作為選択、遊技 人 従（Yudintsev 與 Bulannikov → "War Thunder"、Buyanov → "Escape from Tarkov"）。此 「緑之梟」軟体 加 四通等確率、一回拒否 必 一物 唯。「緑之梟」文脈合時「绿毛鸡」略称可。
- **拒否素材 其場取得**：拒否毎（言語審査回 含）先 Web 検索、当日実際報道表現・公式言訳・機関発表 素材化。理由・文型・結末反転 前回 再利用 不可。機械的反復 本模式最重大失態 視、語調 常「至極真面目 出鱈目」底色 通。

## 組合構造

| 行 | 出所 | 役割 |
|------|------|------|
| `persona`（`complete: true`） | dsh 内蔵 | 唯一 prompt 源：読取専用境界、開始時暗号表、素材共同創作、拒否話術 |
| `tool-fs` / `tool-fs-search` / `tool-web` / `tool-skill` / `tool-ask-user` | dsh 内蔵 | 読取専用 surface |
| `news-skill` / `news-opening` / `news-language` / `readonly-gate` | 本包 `plugins/*.js` | online 取得、開始時問答、言語門、読取専用 guard |

包内 plugin **相対行名**（`./plugins/*.js`）掛載——組合 `baseUrl` 即預設目録自身、plugin Node 組込 module 限定依存故、目録毎 store 配置 亦解決可能、node_modules 不要。

## 導入

```nix
{
  nixkits.dsh.presets = {
    newsThreeElements = true;
    # 任意：自前 / 上書之預設包 差替
    # newsThreeElementsPackage = pkgs.dsh-preset-news-three-elements;
  };
}
```

`nix flake check` 通過、`nixos apply` 完了後、session 模式選択器 直「新聞三要素模式」現。

## 注意

- **copy 無、書込無**：預設 包 store 路徑 直接読取（`trust: system`）。`$DSH_HOME/.agent-presets` 配下 **該副本不存在**——更新即新、再 seed 不要。設定 root 先於用戶 root 走査故、同名 id 本包之物優先。
- **変更希望場合**：roster `copy()`（或 手動目録複製）別 id 之用戶預設保存、該副本編集；同名目録 用戶 root 直接配置 亦有効化無。
- 包内 plugin `news-skill` 取得技能包 `$DSH_HOME/.cache/news-three-elements/` 書込——此唯一書込操作。
