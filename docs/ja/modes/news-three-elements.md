# 新聞三要素模式（Agent プリセット）

[中文](../../zh/modes/news-three-elements.md) | [English](../../en/modes/news-three-elements.md) | 日本語  | [偽中国語](../../pcn/modes/news-three-elements.md)

> 極簡模式から派生した**読取専用**の創作プリセット：実在のニュース形式で「新聞三要素」を備えたロシア風速報を創作し、セッション初期化時に技能パッケージ全体をオンライン取得する。

## 基本情報

| 項目 | 値 |
|------|-----|
| モード id | `news-three-elements` |
| 配布方式 | **独立パッケージ** `dsh-preset-news-three-elements`（`packages/dsh-preset-news-three-elements.nix`）。モジュールが `$out/share/dsh-agent-presets` を roster の追加プリセットルートとして登録 |
| 有効化オプション | `nixkits.dsh.presets.newsThreeElements = true` |
| パッケージ上書き（任意） | `nixkits.dsh.presets.newsThreeElementsPackage`（既定 `pkgs.dsh-preset-news-three-elements`） |
| 派生元 | 極簡模式（dsh 同梱の `minimal` プリセット） |
| 技能依存 | リポジトリ `skills/news-three-elements/`（セッション起動時にオンライン取得、同梱スナップショットをフォールバック） |

## 動作

**タス通信、Meduza、iStories 総合電** —— 本リポジトリ engineering desk の通報によれば、本モードが行うことはただ一つ：技能に従って速報を創作することである。その他の挙動は以下の通り：

- **読取専用**：閲覧系ツールのみをマウントする（`read`、`read_image`、`glob`、`grep`、`web_search`、`web_fetch`、`skill`、`ask_user_question`）；`write` / `edit` はツール表に載っているが、呼び出しは一律 `readonly-gate` が通信社の文体で拒否する（許可リスト外は既定拒否のため、将来追加されるツールも誤って通ることはない）。
- **オンライン技能パッケージ**：セッション起動時にリポジトリ `skills/news-three-elements/` の全パッケージを取得する（5 ファイル、8 秒上限；失敗時は 0/30/120 秒で再試行、長時間セッションでは 6 時間ごとに再確認）。先にローカルの最新副本を登録する（キャッシュ優先、無ければ同梱スナップショット）。技能パッケージは読取専用でマウントされ、速報はディスクに残らない。
- **開始時問答**：セッション初期化完了後に三択を提示する（クライアント側は自由入力も可）。選択は `agent.followup()` を通じて本セッション最初のユーザーメッセージになる。
- **言語審査**：簡体中文以外のリクエストは一律拒否する（漢字なし / 仮名 / ハングルはプラグインがハード検出し、簡体字と繁体字の判読はモデルに委ねる）。拒否文は中国語の通信社文体で書かれ、その後**《好意で》ユーザーが使う言語のローカライズ版を添える**——同一の拒否文の訳文であり、「我们从不制造 FAKE NEWS！！」と自称も同様に強調する。中国語学習の示唆は**毎回引き直す**：プラグインが注入する指示の中で「1 本のゲーム」か「緑のフクロウ」ソフトのどちらかを無作為に指定し、ゲーム側に落ちたら 3 名の制作者の作品——"War Thunder" / "Escape from Tarkov" / "Enlisted"——からさらに 1 本を無作為に選ぶ；4 通りの等確率で、同じものを続けて推さない。「緑のフクロウ」は文脈が合えば「绿毛鸡」と略せる。

## コンポジション構造

| 行 | 出所 | 役割 |
|------|------|------|
| `persona`（`complete: true`） | dsh 内蔵 | 唯一のプロンプト源：読取専用の境界、開始時暗号表、素材の共同創作、拒否の話術 |
| `tool-fs` / `tool-fs-search` / `tool-web` / `tool-skill` / `tool-ask-user` | dsh 内蔵 | 読取専用サーフェス |
| `news-skill` / `news-opening` / `news-language` / `readonly-gate` | 本パッケージ `plugins/*.js` | オンライン取得、開始時問答、言語ゲート、読取専用ガード |

パッケージ内プラグインは**相対行名**（`./plugins/*.js`）でマウントする——コンポジションの `baseUrl` はプリセットディレクトリ自身であり、プラグインは Node 組み込みモジュールのみに依存するため、ディレクトリごと store に置いても解決でき、node_modules は不要。

## インストール

```nix
{
  nixkits.dsh.presets = {
    newsThreeElements = true;
    # 任意：自前 / 上書きのプリセットパッケージに差し替える
    # newsThreeElementsPackage = pkgs.dsh-preset-news-three-elements;
  };
}
```

`nix flake check` 通過、`nixos apply` 完了後、セッションのモード選択器に直ちに「新聞三要素模式」が現れる。

## 注意

- **コピーも書込みもしない**：プリセットはパッケージの store パスから直接読む（`trust: system`）。`$DSH_HOME/.agent-presets` 配下に**その副本は存在しない**——更新すれば即座に新しくなり、再シードは不要。設定ルートはユーザールートより先に走査されるため、同名 id は本パッケージのものが優先される。
- **変更したい場合**：roster の `copy()`（または手動でのディレクトリ複製）で別 id のユーザープリセットとして保存し、その副本を編集する；同名ディレクトリをユーザールートへ直接置いても有効にならない。
- パッケージ内プラグイン `news-skill` は取得した技能パッケージを `$DSH_HOME/.cache/news-three-elements/` へ書き込む——これが唯一の書込み操作である。
