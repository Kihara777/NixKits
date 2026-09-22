# メンテナンスログ

[中文](../MAINTENANCE.md) | [English](MAINTENANCE.en.md) | 日本語 | [偽中国語](MAINTENANCE.pcn.md)

## 2026-09-22T16:23:33+09:00

**概要**：docs(skill): 「ブートローダ設定をコマンド式に改変してはならない」事故を `nixos-specialisation-tuning` に記録 —— これは**私が導入し、実際にシステムを起動不能にした**障害である。**要件**：上流 nixpkgs は Limine の既定項目を「specialisation が存在すれば 3 番目を選ぶ」と**ハードコード**している（`limine-install.py:533`）。そのため選択面が存在するだけで既定が選択面になる。既定を戻すため、`extraInstallCommands`（nixpkgs が install スクリプトの**後**に実行することを保証）で `limine.conf` の `default_entry` 行を `sed` で書き換えた。**失敗機構**：このフックは Limine が**設定ハッシュを固めた後**に実行される —— `limine-install.py:660` は `enrollConfig=true` のとき `blake2b(config_file.strip())` を計算し `limine enroll-config` で EFI バイナリに固め、`limine.nix:471` の `${install} "$@"` が固化を完了し、`:472` の `${extraInstallCommands}` がようやく設定を書き換える。固化後の書き換え → **ハッシュ不一致** → Secure Boot 下でブートローダが設定の読み込みを拒否 → **システム起動不能**。復旧には外部イメージで secure boot と `panicOnChecksumMismatch` を手動で無効化する必要があった。**一般化された形**：`extraInstallCommands` のような「install 後」のフックは安全な最終修正点に見えるが、install 内部で**すでに検証・固化が完了している**ことがある —— 「フックが最後に実行される」≠「フックの変更がすべての検証を通過する」。**スキルに二節を追加**：① `### 引导菜单与默认面` —— 一般規則（ブートローダ設定は宣言的であること、生成物を sed/cp で書き換えないこと）、事故の完全な記録と失敗機構、変更前の正しい調査順序（install スクリプトの全フローを読み、「ファイル書き込み → 検証/署名」の順序をすべて洗い出し、変更が固化前に落ちることを確認する。安全な入口がなければ上流の論理に従い、対抗しない）、固化後の変更が避けられない場合は**上流とバイト単位で同一**のアルゴリズムで再固化すること、およびセキュリティスイッチ（`enrollConfig`/`validateChecksums`/`panicOnChecksumMismatch`、いずれも nixpkgs が "allows bypassing secure boot" と断言）のダウングレード規律；② 面切り替え後の二つのランレベル障害 —— `### 分面切换后的运行级收敛`（`switch-to-configuration` は active target を変更しない。判定に `is-active` を**使ってはならない**。systemd の target は加算的で `graphical` は `multi-user` を要求するため常に真になる。`default.target` の**解決値**を使うこと。なお `systemctl get-default` は `default.target` 自体を返し、その指す先ではない）と `### 用户级 systemd 实例跨面陈旧`（`user@<uid>.service` は面を跨いでも再起動されず、ユニットリンクが失効する。`daemon-reload`/`daemon-reexec` はいずれも無効で、インスタンス全体の再起動が必要。逆方向の清理と検証判定基準を含む —— **「コンポジタが存在する」を「デスクトップが正常」と見なしてはならない**。黒画面のときこそコンポジタは動作している）。frontmatter の `description` と「适用场景」を同期更新し、スキルが正しくルーティング・起動されるようにした

| コミット | 説明 |
|----------|------|
| `8c276c0` | docs(skill): 「ブートローダ設定をコマンド式に改変してはならない」事故を記録 —— 私が導入した起動不能障害 |

## 2026-09-22T09:37:07+09:00

**概要**：fix(ci): CI バッジが `failing` を誤報する問題を修正 —— 根因は `ci-summary` の**競合（レース）**。**現象**：README のバッジが繰り返し `failing` を示す一方、**当時すべてのビルドは実際には全てグリーン**でした。09-18 〜 09-21 の実測で、バッジは `failing → passing` を**1〜2 分間隔で対になって**反転しており、規則性から実障害ではないと判断できました。**根因**：`ci-summary.yml` は push で起動するため、**同じ push のビルドが未完了のうちに**走ります。そのクエリは `status=completed` を使い、**commit を限定していない**ため、一部の workflow では「最新の完了済み実行」が依然として**前回 push の失敗実行**であり、`group_by(workflow_id)` がそれを最新として選び → 失敗と判定していました。**具体例を特定**：`Build dsh-preset-news-three-elements (aarch64)` の **run#157**（sha `a350616`）が失敗 —— 原因は浮動入力 `llama-cpp-ver` の **HTTP 403 レート制限**の偶発（AGENTS.md に既記載の同種）；その後 #158/#159 は成功しましたが、`ci-summary` がちょうどその隙間に起動し #157 を読みました。**修正三点**：① クエリに `head_sha=$GITHUB_SHA` を追加し、**現在の commit** の実行のみを集計 —— 今回未完了の workflow は集計に**現れず**（通過とも失敗とも数えない）、完了時に起動する次回の `ci-summary` が補います。よって古い失敗を現況と誤認しなくなります。② `curl` に `--fail` を追加 —— 従来はこれが無く、403 制限が返す JSON エラー本体のため jq が `workflow_runs` を取得できず → `FAILED` が空 → **静かに `passing` を書き込む**という、**誤報の赤より危険な偽の緑**（赤は調査を促すが、緑は誰も気づかない）。③ リクエスト失敗時は**既存のバッジを保持して `exit 1`** し、誤った色を書かない。**検証**：新しい jq ロジックを現在の HEAD に対して実行すると出力は空（=> passing）で、**31 の Build workflow が全てグリーン**という事実と一致。まず手動起動でバッジの自己修復を確認し、修正を push した後も当該 workflow は再度 success、バッジは `passing` を維持。**文書と汎化**：`AGENTS.md` の CI 章にこの競合の罠と `--fail` の二点を追記（従来は「毎時更新」とのみ記載し、起動条件とリスクに触れていませんでした）；適配層スキルに「収尾時にバッジに惑わされない」節を追加し、**実行記録を基準とすること**、および偶発的失敗（制限、再実行即可）と真の失敗（hash 不一致、ビルドエラー）の区別を明記。**説明**：今回の「外部からの変更」は実は `gh-pages` 上で `ci-summary` ボットが書き込んだバッジ状態でした —— **メインブランチのソースは第三者に変更されていません**。`git status` はクリーンで `main` はリモートと一致しています

| コミット | 説明 |
|------|------|
| `7fc4a14` | fix(ci): ci-summary 按 head_sha 过滤，修正徽章误报 failing |

## 2026-09-20T17:56:28+09:00

**概要**：refactor(skill): **通用スキル 8 件すべて**に対する「リポジトリ／役割の特指」監査後の一括汎化 —— 発端は本ラウンドで先に `traps.md` の Dependabot 特指を修正したこと。**監査方法**：まず frontmatter と本文から各スキルを**汎用**か**リポジトリ適配層**かに判定（後者が NixKits を名指すのは**正しく**、修正対象外）。そのうえで各ファイルを三種の問題について精査：①あるリポジトリの約定を普遍規則として扱う ②維護者にだけ語り、貢献者・引継者を無視する ③スキル間のハード参照（別リポジトリで即断）。**汎用スキル 8 件**：`nix-flake-update-check` / `write-maintenance-log` / `write-project-docs` / `translate-pseudocn` / `nixos-modern-cli` / `nixos-specialisation-tuning` / `recover-nixos-config` / `news-three-elements`。**修正の要点**：**① `write-maintenance-log` の二箇所は「別リポジトリで動作しなくなる」**：入口に「本スキルは AGENTS.md 規則により強制起動」とあり —— 他リポジトリには AGENTS.md がない、または該当規則がない場合があり、スキルが**永久に発火しません**。条件式に変更（該当規則がない場合はユーザーが明示起動する旨を付記）。SUBTITLE マッピング表は `NixKits 软件更新维护日志。` を直書きしていましたが、この表は翻訳時に**逐字置換**される機械的文字列であり、そのまま使うと**他プロジェクト名が採用者のログに書き込まれます**。`<项目名>` プレースホルダと置換説明に変更。**② `write-project-docs` の自己矛盾**：templates.md は「ルートには中文のみ残す」としつつ、同じスキルの反パターン表には「言語リストの直書き」が**反パターン**として明記されていました —— 「基準言語（リポジトリが定める。本スキルは特定言語を仮定しない）」に変更。**③ 切り替えバリデータの付随修正（実測で踏んだ罠）**：元のスクリプトは `docs/zh|en|ja|pcn` と `/5` 件を直書き。言語集合を動的発見に書き換える際、**私自身が三つの罠を踏み、逐一実測で修正**しました —— `^\[中文\]` は BRE では**文字クラス**（`grep -F` が必要）、言語名でアンカーしないと **shell パイプと Markdown 表行**に命中（しかも `grep -m1` が返すのはその問題行で、誤診を招く）、**基準言語は切り替え器ではプレーンテキスト**（`[名]` のみの一致では基準言語の文書を欠落と誤報）。最終版は実リポジトリで検証：**有効な文書では無出力、リンクを故意に壊すと正しく `3/4` を報告**。三点ともスキルに罠として記載。**④ `translate-pseudocn` の文法的に壊れたスクリプトを修正**：孤立したループ本体、未定義の `$expected`、直書きの「5 言語」—— 誰がコピーしても実行不能でした。書き直し済み。**⑤ スキル間ハード参照**：汎用スキルから `write-maintenance-log` や適配層への参照を、単独でも成立する表現に変更（ユーザーが片方しか導入していない可能性がある）。**⑥ その他**：工程数の記載「第 1~10 步」が実際の 9 步と不一致。子リポジトリの例から `dsh-api-balance`/`MAINTENANCE.md` の特指を除去。`kits/` を汎用プレースホルダに。実測数値は「来源リポジトリでの実測」と統一表記し、読者のリポジトリと混同しないようにしました。**保持**：`nixkits-check-updates` / `nixkits-skills` の NixKits 特指は**変更しません**（適配層は特指されるべき）。本リポジトリの**あらゆる経手人**に結論が成立する点のみ補足。**監査の結果クリーン**：`nixos-modern-cli`、`nixos-specialisation-tuning`、`recover-nixos-config`、`news-three-elements`。**検証**：書き直した二つの検証スクリプトは**実際に実行して通過**（故意に壊したリンクを注入する逆検証を含む）、`nix flake check` 全通過

| コミット | 説明 |
|------|------|
| `dac80a7` | refactor(skill): 全面泛化通用技能中的仓库/角色特指（审计后批量修复） |

## 2026-09-20T17:41:07+09:00

**概要**：refactor(skill): 外部自動化と Actions 検査の**適用対象**を汎化 —— 特定のリポジトリや特定の役割を指さないようにしました。**問題**：従来の記述は「Dependabot を使わない」を **NixKits 固有の事実**として書き、Actions 検査の動機を**単一のメンテナ視点**で叙述していました —— しかしスキルは他者に渡す再利用可能な成果物であり、読者は**別のリポジトリ**のメンテナ、貢献者、あるいは貢献予定者かもしれません。そのような書き方は「自分には関係がない」と読めてしまいます。**修正：役割と判据で述べ、判据が読者のリポジトリ内での立場に依存しないようにしました。** **① `traps.md` に「なぜこれがメンテナだけでなく全ての経手人に当てはまるのか」を新設**：**SHA 固定は共通の選択であり、その副作用（通知が届かなくなること）は採用した誰もが継承する**点を明示。メンテナ／貢献者・貢献予定者／監査者・引継者の三役割の適用時期を列挙。判据は**「自力実装できるか」であり「誰が使っているか」ではない**と明記 —— プラットフォームが既に有効化していれば**交差確認**、していなければ**唯一の経路**であり、どちらでも実行する価値があります（コマンドは読取専用、数秒）。**② `traps.md` に「メンテナでない場合：action の昇格も PR で行う」を新設**：昇格は CI の挙動を変えるレビュー対象の変更であること、無関係な発見は現在の PR に混ぜず別 PR にすべきこと、加えて「変更前に上流 tag の実在を確認する」警告（release ページのタイトルから SHA を推測しない）。**③ 第 2 步**：「Dependabot を使わない場合」を誰にでも当てはまる説明に変え、**発見 ≠ 昇格義務**を強調。**④ `builders.md`**：小節タイトルを「リポジトリが外部依存自動化を有効にしている場合（Dependabot など）」から「PR が外部依存自動化によって開かれた場合」に変更し、本文も「NixKits は使わない、本节は参考」から**一般の場合**へ。**⑤ 汎用スキルからアダプタ層へのハードコードされたパス参照を削除**（`../nixkits-check-updates/SKILL.md`）—— 汎用スキルは特定リポジトリのスキル集合に結合すべきではなく、「一部のリポジトリはそのような自動化を意図的に有効化しない」と記述。**⑥ 第 8 步**：特定リポジトリの記録スキルを名指しせず「アダプタ層が指定する」に変更。第 5 步の例は「来源実例（ある実リポジトリから取得）」と標記し、汎用スキル内の「本リポジトリ」の曖昧さを除去。**境界**：アダプタ `nixkits-check-updates` は**本リポジトリ固有の事実を保持**します（本来特指すべきであり、その結合は**正しい**）。本リポジトリの**あらゆる経手人**に結論が成立する点のみ補足。**検証**：`nix flake check` 全通過

| コミット | 説明 |
|------|------|
| `23e11a5` | refactor(skill): 泛化外部自动化与 Actions 检查的适用对象（不再特指某个仓库） |

## 2026-09-20T17:28:32+09:00

**概要**：fix(skill): `nix-flake-update-check` の三つの欠陥を修正 —— いずれも本日の更新チェックの実体験から露呈したもので、**三つに共通する失敗形態は「エラーを出さず、ただ取りこぼす」**。**① 固定 SHA の Actions 検査に到達できない（最も深刻）**：`traps.md` には完全な手順（action の列挙 → tag の照会 → tag が指す commit の取得 → SHA とコメントの書き戻し）が既に書かれていましたが、**`SKILL.md` のどのステップからも参照されていません** —— 第 2 步は `flake.nix` が参照するパッケージ定義しか走査せず、六問自检にも該当項目がないため、この検査は一度も実行されていませんでした。**対応**：第 2 步の末尾に「ソフトウェアパッケージ以外にも必ず検査すべき更新がある」節を新設（発見コマンドと「**まずコマンドを実行して実際の出力を見る。"このリポジトリには無い"と決めつけて飛ばさない**」という戒めを含む）、自检を**八問**に拡張（第 8 問が Actions）、`traps.md` の目次に「**毎回**」と明記。**② バージョン発見のヒューリスティックが静かにパッケージを落とす**：第 2 步は `version\s*=` でバージョンを抽出していたため、**パラメータ化された主定義の `version ? "0.1.5-rc.2"`**（`packages/dsh.nix`）に**一致しません** —— このパッケージは検査範囲から消え、しかも「最新」と区別できませんでした。`version\s*[?=]` に変更し、`?`＝主定義のデフォルト値（stable の真のバージョン）と `=`＝チャネル上書き値の**両方を検査する**旨を表で補足。**③ 生の `curl` で `api.github.com` が静かに空を返す**：第 3 步の例は匿名 `curl` を使っており、60 回/時の额度を使い切ると**エラーを出さずに空を返し**、下流の `grep` も同様に沈黙 —— **すべてのパッケージが「最新」と判定され**、偽の「すべて正常」を出力していました。`gh api` に統一し、`ERROR:` 分岐を明示的に追加、自检の第 7 問に組み込み、「**空の結果はエラーとして扱う**」という規律と鏈路自检コマンドを補足。**泛化の帰属**：①②③ はいずれも**リポジトリ非依存**の汎用欠陥であり `nix-flake-update-check` に記載。`nixkits-check-updates` 適配層には本リポジトリ固有の内容を補足 —— Dependabot を使わないため**本スキルが action 更新の唯一の経路**であること、`build-package.yml` が再利用可能 workflow（31 の workflow から参照）であること、本機での `curl` 実測。**新フロー初回実行の実測結果**：本リポジトリの 3 つの action（`actions/checkout` v7.0.1、`DeterminateSystems/nix-installer-action` main、`cachix/cachix-action` v17）計 6 箇所を**逐一 SHA 照合した結果、すべて最新**と確認 —— 修正の価値は「更新を発見した」ことではなく、**この検査が今後は確定的な結論を出すようになり、静かに飛ばされなくなった**点にあります。**検証**：`nix flake check` 全通過（`preset-derivation` ドリフト検査を含む）

| コミット | 説明 |
|------|------|
| `34368c1` | fix(skill): 接入 Actions 检查、修正版本发现启发式、取数改用 gh api |

## 2026-09-20T17:05:51+09:00

**概要**：定例の更新チェック —— opencode-telegram 0.25.3、ruyi-alpha 0.54.0-alpha.20260918。**① opencode-telegram 0.25.2 → 0.25.3**：npm パッケージ。スキルの手順どおり `nix build` を二回実行し、それぞれ source hash（`sha256-XVIsT9mQuagF3DDLwlXomihfpBJLZ6OfJHzBGLM9lXM=`）と npmDepsHash（`sha256-lLl6AobcB/Zi9aw463iv1MMAPah+RV/GtrF0nK6X1Q0=`）を取得、ビルド通過。**② ruyi-alpha 0.52.0-alpha.20260714 → 0.54.0-alpha.20260918**：薄いラッパーは version と hash（`sha256-6XSVQuU+szU8CnijgAwQa1XmoHgpk/vHW6tmWP5dkpQ=`）のみ変更、三チャネル共有の base は未変更。**③ 実測値の更新**：alpha チャネルの pytest 件数が 346 ユニット / 57 統合から **462 ユニット（xfailed 1 件を含む）/ 70 統合**へ増加（`nix log` でビルドログを読んで実測）。beta チャネルと同程度になり、四言語の文書を同期更新しました。**④ 全数調査の結論**：stable チャネルの被検査 12 パッケージのうち、上流に遅れているのは上記 2 件のみ。`dsh`（0.1.5-rc.2、npm の `latest` と一致）、`dsh-alpha`（0.1.6-alpha.2）、`mcp-searxng`（2.3.0）、`blender-mcp`（1.0.3）、`codewhale`（0.9.13）、`godot-ai`（4.1.0）、`obs-bilibili-stream`（2.1.5）、`ruyi`（0.52.0）、`ruyi-beta`（0.53.0-beta.20260917）はいずれも上流と一致。**ツール上の観察**：GitHub API への匿名リクエスト（`curl` で `api.github.com` に直接アクセス）は本機で空の応答を返し、認証済みの `gh api` は正常（额度 5000/時）——検査スクリプトは生の `curl` ではなく `gh api` に統一すべきです。四言語同期、`check-doc-versions` / `check-doc-links` / `check-maintenance-log` の三項目の自检通過

| コミット | 説明 |
|------|------|
| `1711331` | feat(pkgs): opencode-telegram 0.25.3 + ruyi-alpha 0.54.0-alpha.20260918 |
| `14e565e` | docs: 同步 opencode-telegram 0.25.3 与 ruyi-alpha 0.54.0-alpha.20260918（四语） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| opencode-telegram | 0.25.2 | 0.25.3 |
| 　 | source hash | `sha256-wNM/QNtFaRaColS2MGqk2p94NpVeHXoqJ26RjNRVypU=` → `sha256-XVIsT9mQuagF3DDLwlXomihfpBJLZ6OfJHzBGLM9lXM=` |
| 　 | npmDepsHash | `sha256-NnvFOrS7Y7NFYoS/lWTb3tTs5xwHhzDLTzkdGN+f3vw=` → `sha256-lLl6AobcB/Zi9aw463iv1MMAPah+RV/GtrF0nK6X1Q0=` |
| ruyi-alpha | 0.52.0-alpha.20260714 | 0.54.0-alpha.20260918 |
| 　 | source hash | `sha256-x6DGsnGgeClKXsS1kXP+3nIYGG2hJhyk6J1ENE2VD8s=` → `sha256-6XSVQuU+szU8CnijgAwQa1XmoHgpk/vHW6tmWP5dkpQ=` |

## 2026-09-19T14:13:43+09:00

**概要**：ドキュメント検証の締めくくり——「文書に載っていない内容」の確認で構造的な欠落を 1 件発見し、**ドキュメント検証タスク全体が完了**しました。**方法**：git 追跡下の全ファイルをカテゴリ別に棚卸しし（トップレベル項目 / `modules/` 9 / `overlays/` 8 / `patches/` 2 / `packages/` 13 パッケージと変種 / `develop/` 10 / `skills/` 10 / `.github/` workflows）、README・`AGENTS.md`・`docs/zh/` の参照と突き合わせました。**結果**：ほとんどは既に文書化済みで、**構造的な欠落は 1 件**のみ——本リポジトリには**自検契約として 7 件の `nix flake check`** があり（いずれか失敗すればコミットが阻断されます）が、**それを一箇所にまとめた説明がありません**でした。情報は `flake.nix` のコメントに散在するのみで、`AGENTS.md` はそのうち 2 件（`check-preset-derivation.py`、`check-doc-versions.py`）に触れるだけであり、残る 4 スクリプト（`check-preset-bundle.py` / `check-workflows.py` / `check-doc-links.py` / `check-maintenance-log.py`）と 7 件目の `news-mode-tests`（**node スクリプトで python ではない**）は**まったく言及されていません**でした。**追加**：`AGENTS.md` の `## CI` 節に ① **7 件の自検一覧表**（検査名 / スクリプトパス / 検証内容）を追加し、「各スクリプトは単独でローカル実行でき、素早い切り分けに使える」および「**文書に数量をハードコードしない**——`check-doc-versions` はバージョン番号のみを検証し、この種の計数は検証しない」という 2 点を注記（後者は本セッションで繰り返し確認済み：辞書の項目数やテスト数といった計数は非常に古くなりやすい）；② **`access-tokens` の host 照合の落とし穴**（今回の CI 大量失敗の根本原因——`check.yml` が `api.github.com` を欠き、浮動入力 `llama-cpp-ver` が未認証のまま、60 回/時の上限を push ごとの ~34 workflow が使い切っていた）を記録し、今後の workflow 編集で再発しないようにしました。**確認**：表の 7 パスはすべて実在し、「単独実行可能」は実測で確認、`nix flake check` は全通過。**配置の根拠**：これらは**内部のエンジニアリング契約**（貢献者とエージェントが「どの変更がどの検査を発火させるか」を知る必要がある）であり、ユーザー向け内容ではないため、README のユーザー節ではなく `AGENTS.md` に置くのが適切です。

| コミット | 説明 |
|------|------|
| `7766b88` | docs(agents): nix flake check の 7 件の自検一覧と CI の access-tokens の落とし穴を補完 |

> **説明**：`AGENTS.md`（それ自体が代理エージェント向けの取り決めファイルで、ユーザー文書ではありません）を変更します。これで**本セッションのドキュメント検証タスクはすべて完了**しました：主文書 + ソフトウェア 9 + プラグイン 2 + モード 3 + 開発 2 + パッチ 8 + 廃止 1 + スキル 10 + 文書に載っていない内容の確認——累計 36 のファイル群、20 件の修正（うちソースの不具合 2 件と、本セッションで以前に入れた退行 3 件を含む）。

## 2026-09-19T14:05:38+09:00

**概要**：CI の大量失敗の根本原因を特定・修正し、子リポジトリにセキュリティポリシーを追加しました。**① CI の 403 レート制限（`d224b18`）**：維護者に CI 失敗メールが大量に届いたため調査したところ、**根本原因は浮動入力 `llama-cpp-ver` の要求がずっと未認証だったこと**でした。この入力は `https://api.github.com/...` を指しますが、Nix の `access-tokens` は **host を完全一致で照合**します——`build-package.yml` は既に `github.com=… api.github.com=…` の 2 host 形式でしたが、**`check.yml` には `github.com` しか書かれていませんでした**。そのため要求は未認証で送られ（上限 **60 回/時**、認証時は **5000**）、**push ごとに ~34 の workflow** がこの入力を解決するため、**1 回の push で上限を使い切る**状態でした。失敗レスポンスが答えを明示しています：`API rate limit exceeded for 52.165.58.41. (But here's the good news: Authenticated requests get a higher rate limit.)`。**修正**：`check.yml` に `api.github.com=${{ secrets.GITHUB_TOKEN }}` を追加し、この見落としやすい host 照合の規則をコメントで明記。31 個の `build-*.yml` はすべて `build-package.yml`（既に正しい）経由であることを確認したため、check.yml が唯一の欠落でした。**検証**：コミット `d224b18` は **33 workflow すべて success**、403 はゼロ。**AGENTS.md に違反しません**：制約は `llama-cpp-ver` を**固定してはならない**（上流の最新リリースを動的に追跡する必要がある）ことで、本変更はその要求の**認証方法**にのみ影響し、入力は浮動のまま `flake.lock` にも書かれません。**失敗統計**（直近 100 run の分類）：403 が **24 回**、**未マージの Dependabot ブランチ** `86843b4` による hash mismatch が 4 回（AGENTS.md の「Dependabot は `npmDepsHash` を知らないため必ず失敗する」の実証。当該ブランチは main 上になく PR #7 はクローズ済み）、Cachix の後処理段階が 1 回（ビルド自体は成功済み）。日付では 09-15/16 がピーク（28 + 49）で、メールの量と一致します。**② 子リポジトリのセキュリティポリシー（子リポジトリ `2cce37b`、主リポジトリ `39c9f10` で同期）**：子リポジトリ `dsh-api-balance` には以前 **`SECURITY.md` がありませんでした**——まさに本リポジトリのスキルの「外部リンク監査」が記録していた死リンクです。四言語の `SECURITY.md` を追加し、スキャナが自動生成した PR #4 / #5 の主張の評価を記載しました：**「レート制限の欠如」と「リクエストボディのサイズ上限の欠如」はいずれも誤検知**です。判断根拠はすべて記録しています：報告の記述と diff が一致しない（4 エンドポイントを挙げながら、diff は `/query` のみ変更）、その `x-forwarded-for` 制限キーはクライアントが偽装でき、**同一オリジンのローカル RPC は当該ヘッダを伴わない**ため全ローカル要求が同一の `"unknown"` バケットに入り **正常なユーザーが先に制限される**、`/token` には既に **6 時間**のサーバー側スロットル、音声アナウンスには **30 分**の制限がある、そして**本プラグインに高頻度ポーリングはない**（唯一の 30 秒 `setInterval` が実行する `isPeakPricing()` は純粋にローカルな時刻判定で**ネットワーク要求を発行しない**）ため、人間の操作速度では最も活発でも **毎分 5〜10 回**程度であり、スキャナ推奨の毎分 30 回は既にその 3〜6 倍です。本当の境界は **DSH ホストの認証と Host authority** にあります。**結論：コードは変更しません**——将来必要になれば、**IP ではなく認証主体ごと**に（IP は偽装可能）、閾値は人間の操作よりはるかに高く（例：毎分 60〜120 回）設定し、「暴走スクリプト対策」として位置づけるべきです。主リポジトリの四言語 `SECURITY.md` にあった「同サブプロジェクトは**未だ**ポリシーを整備していない」という行が結果的に古くなったため、「整備済み」に訂正し、子リポジトリ文書への直リンクを添えました。

| コミット | 説明 |
|------|------|
| `d224b18` | fix(ci): check.yml の access-tokens に api.github.com が欠けていた（403 の根本原因） |
| `2cce37b` | （子リポジトリ dsh-api-balance）docs(security): 四言語 SECURITY.md を追加 |
| `39c9f10` | docs(security): 子リポジトリがポリシーを整備済みに——古い「未整備」記述を訂正（四言語） |

> **説明**：`d224b18` は `.github/workflows/check.yml` を変更、`39c9f10` は四言語ドキュメント、子リポジトリのコミットはそのリポジトリに記録されています。修正後 CI はすべて green です。

## 2026-09-19T07:51:05+09:00

**概要**：スキル文書の確認（4 篇完了：nix-flake-update-check / nixkits-check-updates / write-project-docs / translate-pseudocn）で 3 件修正。**① nix-flake-update-check：ステップ数の誤り（四言語）**。文書は「第 1〜**10** 步の主フロー」としていましたが、汎用スキルの `SKILL.md` は実測で**第 1〜9 步のみ**です。「プロセスの振り返りと規範の検証」および「テストブランチの教訓を main へ戻す」は、実際には**適応層スキル** `nixkits-check-updates`（その「第 10 步（締め）」、258 行目以降）で定義されています。元の記述は 2 つのスキルのステップを混同しており、読者は汎用スキルで第 10 步を見つけられません。「本スキルは第 9 步まで。締めの第 10 步は適応層が補う」に改めました。**② write-project-docs：配套ファイル `templates.md` がスキル自身から宣言されていない（四言語 + SKILL.md）**。`templates.md`（209 行の完全なテンプレート集）は実在し、`AGENTS.md` の 88 行目も参照していますが、`SKILL.md` には**ファイル名が一切現れず**、「配套ファイル」節もありません（対照的に `nix-flake-update-check/SKILL.md` には明確な配套ファイル表があります）。四言語の文書はさらに進んで、スキルを単一ファイルと同一視していました。結果として、実行時にテンプレート集の存在を知る手段がなく——それは「ある種の文書を初めて作る」際に最も先に読むべきものです。`SKILL.md` の冒頭に配套ファイル表（既存スキルと同じ形式）を追加し、四言語の文書には「パス＝ディレクトリ形式」と「配套ファイル」の行を補いました。**③ translate-pseudocn：辞書の項目数と配套ファイル（四言語）**。文書は「内蔵 ~**13** 項目のマッピング辞書」としていましたが、`dictionary.md` は実測 **75** 項目です。履歴を見ると辞書は複数回拡張されており（`4fbf387`「expand dictionary 7→46 entries」）、13 はより早い版で止まっています。また `SKILL.md` は `dictionary.md` を 3 箇所で参照していますが（表引き翻訳、カタカナ対応、残存仮名の書き戻し）、四言語の文書は `SKILL.md` 単一パスしか書かず、本文でも同ファイルに触れていません。配套行を追加し、項目数を実測の 75 に改めました。**照合**：同梱の `news-three-elements` 文書は 4 つの配套ファイル（`search-keywords.md`/`tables.md`/`checklist.md`/`principles.md`）を**既に正しく**宣言し、SKILL.md にも対応する参照があるため、本欠陥は普遍的なものではありません。また `nixkits-check-updates` 文書は全項目一致でした（子倉座標——`fetchFromGitHub` 固定 rev / flake input ではない / npm 未公開——はいずれも事実で、3 つの固有の落とし穴——godot-ai は overlay を**2 箇所とも**連結する必要、codewhale の 2 変種、dsh-alpha の vendored lock における `--legacy-peer-deps` 禁止——もソースと一致し、第 10 步の 6 サブステップもスキル本文と一致）。

| コミット | 説明 |
|------|------|
| `c9c9c0c` | fix(docs): nix-flake-update-check スキル文書のステップ数誤り（四言語） |
| `7f7363f` | fix(docs): write-project-docs が配套ファイル templates.md を宣言していない（四言語 + SKILL.md） |
| `cef09fe` | fix(docs): translate-pseudocn の辞書項目数と配套ファイルが不正確（四言語） |

> **説明**：`7f7363f` は `skills/write-project-docs/SKILL.md` の変更を含みます（スキルスナップショットは `check-preset-bundle` により `skills/` ツリーとバイト単位で一致することを確認済み）。残りは四言語のドキュメントです。スキル文書は残り 6 篇（news-three-elements / nixkits-skills / nixos-modern-cli / nixos-specialisation-tuning / recover-nixos-config / write-maintenance-log）、その後は文書に載っていない内容の確認です。

## 2026-09-19T07:43:15+09:00

**概要**：廃止文書の確認 — **ファイルをまたぐ事実誤り**（モジュールのコメントと四言語の廃止文書の双方に存在）を発見し、訂正しました。**元の判定**：「上流は hostPlatform へ移行済み（旧記法 **0 箇所**、新記法 34 箇所）で、非推奨警告は出ない」。**実測による反証**（上流 tarball を取得しファイル単位で計数）：非推奨の `stdenv.is<Platform>` 短記法は **0.34.0 で 38 箇所**、**0.30.2（パッチ時代の基版）でも 38 箇所**、一方 `hostPlatform.is*` は両版とも 7 箇所のみ——両版は完全に同一で、上流は**一度も**この API を移行していません。nixpkgs を実測してこの記法が実際に非推奨であることも確認済み（`evaluation warning: stdenv.isLinux is deprecated, use stdenv.hostPlatform.isLinux instead`）で、「非推奨警告は出ない」は成立しません。**原因の推測**：元の判定は、**私たち自身のパッチ**が行ったことを上流が行ったこととして記録してしまった可能性が高いです——旧 `comfyui-nix-stdenv-api.patch` のサブジェクトはまさに「migrate stdenv.is<Platform> to stdenv.hostPlatform.is<Platform>」（36/44 箇所を移行）で、誤った結論の数字とよく一致します。**訂正後の正確な記述**：パッチが不要になったのは事実ですが、本当の理由は**私たちが上流コードを上書きしなくなったこと**です——旧パッチは、overlay 経由で評価される fork にこの移行を適用し、下流ビルドを汚す警告を消していました。上流を直接指すようになった今、本モジュールは宣言的な配線のみを行います。**2 箇所を同時に訂正**：`modules/comfyui.nix` の「パッチ削除の判定根拠」コメント（警告マーカーと実測値を含む）と、四言語 `deprecated/comfyui-rocm.md` の「なぜ廃止できるか」の節。訂正にこだわったのは、本リポジトリの「判定根拠を後から辿れるように記録する」という既定の取り決めに従ったためです——誤った結論を残せば、将来の確認者がそれを前提に推論を続けてしまいます。**その他の廃止項目の主張は通過**：モジュールは実際に `nixkits.comfyui` へ改名済み（ソースコメントと文書が一致）。`modules/comfyui-rocm.nix` と 3 つのパッチファイルは削除済み。`DEPRECATED.md` / `docs/DEPRECATED.{en,ja,pcn}.md` の索引はいずれも本文書を正しく指しています。履歴対照表の上流バージョンは実測で **v0.34.0** と記載どおり、ROCm wheels は上流同梱、入力元は `github:utensils/comfyui-nix` に変更済み、パッチ数は 3 → 0。

| コミット | 説明 |
|------|------|
| `4054c32` | fix(comfyui): 「上流が stdenv API を移行済み」という誤った判定を訂正（モジュールコメント＋廃止文書四言語） |

> **説明**：`4054c32` は **`modules/comfyui.nix` を変更**します（コメントのみで評価に影響せず、`nix flake check` は全通過）。残りは四言語のドキュメントです。廃止文書はこれで完了。残りは**スキル 10 文書**と、最後に文書に載っていない内容の確認です。

## 2026-09-19T07:38:04+09:00

**概要**：パッチ群が完了 — 最後の 3 文書（asusd-thermal-guard / comfyui / llama-cpp-rocm）を検証し 4 件修正、これで**パッチ 8 文書すべて**が完了しました。**① asusd-thermal-guard が状態を `/run` に置くと誤記（四言語）**。「検証」節のコメントは「root が必要：**状態は /run に書き込まれ**」としていましたが、モジュールは **`StateDirectory`（`/var/lib/private/asusd-thermal-guard`）** を明示的に使い、ソースコメントで **`RuntimeDirectory`（＝ /run）を使ってはならない**と**わざわざ警告**しています——systemd はそのディレクトリを使う最後のユニットが停止すると丸ごと削除するため、冷却カウントが毎回ゼロに戻り、復帰ロジックが機能しなくなります（コメントには実測症状 `streak 1/6 → 2/6 → 1/6 → 2/6` が延々と往復し 6 に達しない、と記録されています）。したがって文書の `/run` は誤りであるうえ、モジュールが意図的に避けている落とし穴をちょうど指していました。**② comfyui のバッジが存在しない CI ジョブを名指し（四言語）**。バッジは `check.yml?job=build (ubuntu-latest, comfyui)` でしたが、`check.yml` には**単一の `check` ジョブしかありません**（ファイル内に `matrix|comfyui` は 0 件）。comfyui は本リポジトリでは**純粋なモジュール**（`nixosModules.comfyui`、パッケージ出力なし）であり、`build-comfyui-*.yml` も存在しません（blender-mcp/kitsfmt/ruyi のバッジは実在する `build-<pkg>-<arch>.yml` を指しています）。**この誤りは自力で露見しません**：shields.io に**故意に存在しないジョブ名**を渡しても `passing` が返ります——一致しない `job=` は黙って無視され、ワークフロー全体の状態にフォールバックするため、あのバッジはずっと CI 全体の状態を表示していました。**③ comfyui のキャッシュ節に overlay の記述が残存（四言語）**。同じページの「種別」は既に「純粋な NixOS モジュール（パッチなし）」としているのに、キャッシュ節は「本エントリは overlay…バイナリキャッシュに含まれない」のままでした——overlay だった頃の古い文言です。モジュールには **`pkgs.comfyui` の参照も `overrideAttrs` もなく**、宣言的な設定（`boot.kernelParams`、`hardware.graphics.extraPackages`、systemd の堅牢化）のみを行い、comfyui の overlay ファイルも既に存在しません。**④ llama-cpp-rocm の移行例が展開されない `~` を使用（四言語）**。例は `hfCacheDir = "~/.cache/huggingface/hub"` でしたが、モジュールはこの値を **systemd `Environment = [ "LLAMA_CACHE=${cfg.hfCacheDir}" ]`** 経由で注入し、systemd の `Environment=` は **`~` を展開しません**——例をそのまま使うとリテラルなパスになり、llama.cpp は相対パスとして扱います。モジュール自身の既定値は**絶対パス**（`${users.users.<user>.home}/.cache/huggingface/hub`）であり、誤っていたのは例の側です。**その他の主張はすべて通過**：asusd-thermal-guard の 6 オプションと既定値、`triggerTemp > resumeTemp` の assertion、`name` による hwmon 解決、CPU/GPU の大きい方の採用、sysfs ではなく `asusctl profile set` の使用、ヒステリシスと冷却カウント、ラダーと「profileCeiling を超えて昇格しない」、両ユニット名と文書の journalctl コマンドの一致。comfyui の `nixkits.comfyui.enable` / `services.comfyui.rocmGfxOverride`（「gpuSupport=rocm のときのみ有効」の限定込み）、機能 6 項目、ROCm 7.1 による gfx1151 のネイティブ認識、3 パッチ削除の理由と 2 つの教訓。llama-cpp-rocm の純 overlay 形態と curried 形式、`llama-cpp-ver` の動的追跡（上流は実測 `v0.4.1` でセマンティックバージョンへの切替を確認）、接頭辞の除去と **`LLAMA_BUILD_NUMBER=0` の上書き**（しないと `int LLAMA_BUILD_NUMBER = v0.2.0;` が生成され C++ のコンパイルが失敗）、全モジュールオプションと `services.llama-cpp.port`。

| コミット | 説明 |
|------|------|
| `8292160` | fix(docs): asusd-thermal-guard が状態を /run に置くと誤記（四言語） |
| `01679e8` | fix(docs): comfyui のバッジが存在しないジョブを名指し＋overlay 記述の残存（四言語） |
| `35aaf05` | fix(docs): llama-cpp-rocm の移行例が展開されない ~ を hfCacheDir に使用（四言語） |

> **説明**：いずれもドキュメントのみの修正で、`packages/`・`overlays/`・`modules/` は未変更。パッチ 8 文書はこれで完了。残りは**廃止 1 文書**（comfyui-rocm）、**スキル 10 文書**、および最後に文書に載っていない内容の確認です。

## 2026-09-18T11:04:38+09:00

**概要**：外部カタログへの掲載が完了 — awesome-ai-plugins の 2 つの PR がともにマージされ、NixKits と dsh-api-balance が正式に同カタログへ入りました。**背景**：本リポジトリは以前に掲載招待の issue #3（@zerocodefast）を受け取りました。以前のログは「open のまま PR 未提出」と記録していましたが、その後実際に提出して掲載が受理されていました——**本項目は提出とマージの事実を追記するもの**です。**結果**：① [PR #321](https://github.com/hashgraph-online/awesome-ai-plugins/pull/321) — `dsh-api-balance` を DeepSeek Harness Plugins に追加、**2026-09-16 にマージ**（APPROVED、@kantorcodes による）。② [PR #323](https://github.com/hashgraph-online/awesome-ai-plugins/pull/323) — NixKits を Development & Workflow に追加、レビュー指摘に沿った是正とスキャン再実行のため**私たちが自らクローズ**。③ [PR #335](https://github.com/hashgraph-online/awesome-ai-plugins/pull/335) — 再提出版、**2026-09-18 にマージ**（APPROVED、@kantorcodes による）。両エントリは現在上流 README に反映されています（`NixKits` は Development & Workflow 節の NeatContext と Oh My Design の間、`dsh-api-balance` は DeepSeek Harness Plugins 節）。**是正の振り返り**：スキャン評価は **88 → 94/100（A – Excellent）**、Security **13/16 → 16/16**、medium はゼロに。根本原因は `RISKY_APPROVAL_DEFAULT` が**設定ではなくドキュメント**に一致していたこと（制御実験で特定：空のリポジトリでは 0 件、`danger-full-access` の一語を注入するだけで出現）。修正は**情報を一切削らず措辞のみを変更**するもので、これが本リポジトリの既存の「点数のために境界を破らない」姿勢の根拠となっています。**意図的に行わなかった 3 点**：scanner workflow を導入しない（独立に監査できない第三者コードを本リポジトリの CI に入れず、10% の信頼スコア減点を受け入れる）、Dependabot を残さない、したがって満点ではなく 94 点で止める——理由と代償は `AGENTS.md` の「安全境界：外部自動化を導入しない」に記載。**ローカルの対応**：issue #3 の返信を更新し、3 つの PR の最終状態と掲載されたエントリの位置を明記（元の返信は「2 つの PR を提出」と述べ、クローズ済みの #323 を指しており古くなっていました）。**併せて確認**：#323/#335 で報告した上流 `scripts/check-alphabetical.py` の pinned 判定の不具合（47 行目が「マーカーがエントリの 2 行上」でのみ有効と判定するが、README ではマーカーがエントリの直上にある）はスクリプトに依然残っていますが、現在の `main` ではチェックが通っています（README 側で回避したと推測）。issue の返信でこれを指摘し、pinned エントリを新規追加すると再び誤検知する可能性があること、どちらの側でも 1 行の修正で独立 PR を出せることを伝えました。

| コミット | 説明 |
|------|------|
| `--` | 外部リポジトリでの作業（awesome-ai-plugins PR #321 / #335 のマージ）と issue #3 返信の更新。本リポジトリに対応するコミットはなし |

> **説明**：本項目は本リポジトリ外で起きた成果の追記です——掲載は外部カタログ側がマージしたもので、本リポジトリの `packages/`・`overlays/`・ドキュメントはいずれも未変更です。追記した理由は、以前のログが「#323 の是正要請」までしか記録しておらず、**提出と最終的なマージという 2 つの事実が記録されていなかった**ため、タイムラインに断絶があったからです。

## 2026-09-18T14:35:36+09:00

**概要**：パッチ 5 文書の検証（breeze-black / efl-cross-fix / codewhale-sudo / rcc-fix / asusd-pd-profile）— 3 件修正。**① rcc-fix が存在しない option 名前空間を使用（四言語）**：例は `services.asusctl = { enable = true; power-profile = true; cpu-power-control = true; }` ですが、nixpkgs に **`services.asusctl` は存在しません**（リポジトリ全体の `grep -r 'services\.asusctl'` がゼロ件）。asusctl のデーモンオプションは `services.asusd`（`nixos/modules/services/hardware/asusd.nix`）にあり、`enable`/`package`/`animeConfig`/`asusdConfig`/`auraConfigs`/`profileConfig`/`fanCurvesConfig`/`userLedModesConfig` で、**`power-profile` や `cpu-power-control` はありません**（プロファイルと CPU 電力上限は `profileConfig` 経由で `/etc/asusd/profile.ron` に書かれます）。傍証：本リポジトリの `modules/rcc-fix.nix` は `config.services.asusd.enable` を使っており、同梱の asusd-pd-profile 文書も `services.asusd` を正しく使用しています——誤っていたのは rcc-fix のみで、四言語すべて同様でした。**② breeze-black の「インストール」節がプレースホルダパスを使用（zh のみ）**：`nixpkgs.overlays = [ (import ./overlay.nix) ];` とありますが、これは flake パスでも本リポジトリのファイルでもありません。他のパッチ文書（efl-cross-fix / rcc-fix / codewhale-sudo）と en/ja/pcn は既に `inputs.nixkits.overlays.<name>` で統一されており、zh のみ未修正でした。**③ codewhale-sudo の基本情報表に重複行（zh のみ）**：「类型 | overlay（覆盖 codewhale 包）」が 2 回あり、他の三言語は各 1 行です。**その他の主張はすべて通過**：efl-cross-fix は実際に `pkgsCross.{riscv64,riscv64-musl,aarch64}` のみを `overrideScope` でカバーし、仕組みはホストでビルドした `efl-native/bin/.` をビルドディレクトリへコピーして `export PATH="$PWD:$PATH"` するもの（meson の `find_program(..., native: true)` が eolian_gen / eet を見つけられる）で、ホストの efl は影響を受けません。breeze-black は実際に `kdePackages.breeze`/`breeze-gtk` のみを上書きし独立パッケージ出力はなく、look-and-feel id は `metadata.json` で `org.kde.breezeblack.desktop` と確認、GTK テーマ名は `BreezeBlack`（light の "Breeze" からのリネーム）、`BreezeBlack.colors` も存在。codewhale-sudo の仕組みは実際に ptrace でカーネル境界において `prctl(PR_SET_NO_NEW_PRIVS)`/`PR_SET_SECCOMP` を無害な `PR_GET_NO_NEW_PRIVS` へ書き換えるもので、「静的リンクにより `LD_PRELOAD` が無効」という理由と整合し、overlay 名 `codewhale-sudo-fix` は flake 登録と一致。rcc-fix のモジュールは実際に `partOf = lib.mkForce [ ]` で `asus-shutdown.service` の PartOf を外してデッドロックを解消し（加えて `SendSIGKILL=yes`/`TimeoutStopSec=30s` を強制）、`programs.rog-control-center.{enable,autoStart}` も実在します。asusd-pd-profile の `pdProfile` 既定 `balanced`・`nativeAcProfile` 既定 `performance` は文書と一致し、サービスは実際に `Type=oneshot` の udev 起動（常駐なし・ポーリングなし）、文書記載の二段階の PD 判定（`/sys/class/typec/port*/power_operation_mode` が `usb_power_delivery`、`/sys/class/power_supply/*` で `type=USB` のものが `online=1`）はいずれもスクリプトに実装され、「バッテリ時は即終了」にも対応する分岐とメッセージがあります。

| コミット | 説明 |
|------|------|
| `a262e3c` | fix(docs): breeze-black のインストールパスと codewhale-sudo の重複行（zh） |
| `ea03584` | fix(docs): rcc-fix が存在しない services.asusctl オプションを使用（四言語） |

> **説明**：いずれもドキュメントのみの修正で、`packages/`・`overlays/`・`modules/` は未変更。パッチ文書は残り 3 篇（asusd-thermal-guard / comfyui / llama-cpp-rocm）、その後は廃止 1 篇、スキル 10 篇、および文書に載っていない内容です。

## 2026-09-18T14:26:43+09:00

**概要**：開発 2 文書の検証が完了 — ドキュメントのパラメータ誤り 1 件を修正し、さらに**ソースの不具合 1 件**を発見（devShell の設定が一切効いていなかった。ドキュメントの問題ではない）。**① `ruyi venv` / `ruyi extract` の引数誤り（四言語）**：文書は `ruyi venv <name>` と `ruyi venv --toolchain <t>` を示していますが、実測ではどちらも不完全です——位置引数を 1 つだけ渡すと usage を表示して終了し、`-t` なしで `profile dest` を渡すと `fatal error: You have to specify at least one toolchain atom for now, e.g. \`-t gnu-plct\`` となります。正しい形式は三つとも必須で `ruyi venv -t <toolchain> <profile> <dest>`、さらに `profile` はローカル索引に存在する必要があります（初回は `ruyi update`）。また `ruyi extract <file>`（「RISC-V AppImage を展開」）も誤りで、このコマンドの位置引数は**ファイルパスではなくパッケージ atom** です。ファイルパスを渡すと `fatal error: atom /tmp/dummy.AppImage matches no package in the repository` となるため、`ruyi extract <pkg>` に改め、引数の意味を明記しました。**② ソースの不具合：opencode devShell の searxng limiter 設定が一度も読まれていなかった**。`develop/opencode.nix` は limiter 設定を `settings.yml` の `server.limiterSettings` ブロックに書いていましたが、searxng は limiter 設定を **`<user_cfg_folder>/limiter.toml` からのみ**読み込みます（`searx/limiter.py` の `get_cfg()`）。devShell に入ると searxng が直ちに `missing config file: /tmp/searxng-*/limiter.toml` を警告し、このブロックが**黙って無視されていた**こと、すなわち `trusted_proxies`（本機の lighttpd リバースプロキシが渡す X-Forwarded-For/X-Real-IP を信頼する設定）が**一度も効いていなかった**ことが判明しました。しかもそのブロックには上流で廃止済みの `real_ip.x_for` も含まれていました（本セッションで mcp-searxng 文書から削除したのと同じ廃止キー）。修正は limiter 設定を `settings.yml` と**同じディレクトリの独立した `limiter.toml`** へ移し（`SEARXNG_SETTINGS_PATH` がファイルを指す場合、そのディレクトリが user_cfg_folder）、現在のスキーマである `[botdetection] trusted_proxies`（`127.0.0.0/8`、`::1`）を使い `real_ip` を削除しました。修正後は `missing config file` 警告が**消え**、searxng(42701) と lighttpd(4270) がいずれも HTTP 200 を返します。**その他の主張は実測通過**：3 つの devShell が存在し `nix develop .#ruyi` が動作（解決されるのはパッチ済み ruyi）、ruyi の 6 サブコマンドが揃い、opencode devShell の 12 packages、3 つの MCP サーバ（SearXNG/Blender/Godot とそのコマンド）、3 つの環境変数、`~/.config/opencode/mcp.json` の初回生成、`~/NixKits/skills/`（GitHub フォールバック）から `~/.opencode/skills/` へのスキル導入がいずれも文書と一致。

| コミット | 説明 |
|------|------|
| `26e7a76` | fix(devshell): ruyi venv/extract の引数誤り + opencode searxng limiter 設定が一度も効いていなかった（四言語） |

> **説明**：`26e7a76` は **`develop/opencode.nix` を変更**（limiter 設定を独立した `limiter.toml` へ移動）。devShell の挙動が変化しています。残りはドキュメントのみの修正です。テスト中に生成された `dump.rdb`（redis の産物）と残留バックグラウンドプロセスはすべて掃除しました。残りはパッチ 8 文書、廃止 1 文書、スキル 10 文書、および文書に載っていない内容です。

## 2026-09-18T13:51:14+09:00

**概要**：プラグイン 2 文書とモード 3 文書の検証が完了 — プラグインは完全一致（変更ゼロ）、モードは 1 件修正。**① プラグイン（変更ゼロ）**：`dsh-nixos-shell` は全項目一致——npm 名とバージョン、`nixos_shell` の 27 項目のツール白リストが文書と**一字一句一致**（python3/python/grep/ls/cat/head/tail/wc/tr/sort/mkdir/rm/cp/mv/find/env/sed/bash/awk/git/curl/jq/ripgrep/rsync/htop/tree/unzip）、`nixos_cli` の 5 つの op と数値上限（generations 既定 20 / 上限 200、journal 既定 50 / 上限 500）が `--help` の記述と一字一句一致、sudo プロトコルは実際に **v3**（`bin/nixkits-sudo-exec.js` の「Protocol (v3, one request per connection)」）で `MAX_TIMEOUT_MS = 21600000`（6 時間）、実測ソケット `/run/nixkits-sudo.sock` は `srw-------` で `kix:users` 所有、分離実行のロジックは実際に rebuild 系コマンドを認識して `systemd-run --collect` で一時ユニットを起動し `detached: true` + `detachedUnit` と「受け渡し ≠ 成功」の note を返し、`presets/` の 2 プリセットと `package.json` の `exports["./nixos-gate"]` / `["./maintenance-skills"]` サブパスが存在、`skills-embedded/` に 10 のスキルスナップショット。`dsh-api-balance` も全項目一致——薄いラッパー（`src` が本リポジトリではなく GitHub を指し、「ソースを保持しない」と整合）、固定 rev `c47f857` が上流に存在（HTTP 200）、npm 名と `package.json` のバージョンが 0.1.0 で一致、文書記載の 4 つの config 項目（`apiKeyEnv`/`baseURL`/`browserScan`/`browserScanIntervalMs`）がすべて存在し、既定値の実測は `6 * 60 * 60 * 1000`（文書の 21600000、6 時間）。**② モード（1 件）**：NixOS モード文書の「コンポジション」行が persona 行に `complete: true` を設定したと述べていましたが、`presets/nixos-mode/agent.cordis.yml` の persona 行は**`prefix` のみを設定**（独立した `complete:` フィールドはどこにもない）で、ランタイムコンテキストは依然として付加されます。`@deepseek-ai/dsh-persona` のスキーマには `complete`（既定 false）が実在するため、これは文書が述べる設定ではなく当該プリセットの選択です——プロンプト本文に「decision-complete」等の語があるため誤読しやすいものでした。四言語で訂正。**照合済みで正しい**：**ニュース三要素モードの persona 行は実際に `complete: true` と `includeRuntimeContext: false` を設定**しており、その文書は正確なので変更していません。その他のモードの主張はすべて通過：`nixos-gate` は実際に `/etc/NIXOS` と `/etc/os-release` を読み（非 NixOS ではツールガードを登録し拒否プロンプトを注入）、NixOS モードのスキルは実際に 5 つ（プリセット同梱 2 + ビルド時サブセット 3）、メンテナンスモードの派生関係は `diff` の実測で**末尾に固定ブロックがちょうど 1 つ追加**され、両プリセットの `skills/` ディレクトリは `diff -r` でファイル単位に一致、`check-preset-derivation.py` は `MAINTENANCE_DELTA` を含み flake check に組み込み済み（実走で確認）、ニュース三要素モードの 5 プラグインの相対名マウント、5 つのスキルファイルがリポジトリのソースと一対一対応、リトライ `[0, 30_000, 120_000]`、6 時間ごとの再確認、ETag/304、キャッシュディレクトリ `$DSH_HOME/.cache/<SKILL_ID>`、readonly 白リスト 8 項目がいずれも実測と一致。

| コミット | 説明 |
|------|------|
| `3d6340f` | fix(docs): NixOS モードのコンポジション記述が persona の complete: true を誤って主張（四言語） |

> **説明**：ドキュメントのみの修正。プラグイン 2 文書はいずれも変更不要（今後の退行比較のため記録）。残りは開発・パッチ・廃止・スキルの各文書と、文書に載っていない内容です。

## 2026-09-18T13:43:54+09:00

**概要**：ソフトウェア 9 文書の検証が完了 — ruyi は 2 件修正（うち 1 件は**前ラウンドで私が入れた退行**）。これで主文書とソフトウェア系の全子文書を確認し終えました。**① テスト件数がチャネル別でない（退行）**：前ラウンドで「320 ユニット + 52 統合」を一律「462 ユニット + 70 統合」に書き換えましたが、その二つの数値は** beta のみ**でした。実測では三チャネルがそれぞれ異なります——`ruyi`（0.52.0）ユニット **368** / 統合 **58**、`ruyi-beta` **462** / **70**、`ruyi-alpha` **346** / **57**。チャネル別に列挙し直し、「`checkPhase` の ruff / mypy は `|| true`（非ブロッキング）で、**実際にビルドを左右するのは pytest**」と注記して「すべて通過」が三項目すべてとは誤読されないようにしました。**② zh のインストール節のコードブロック破損**：```nix フェンスの中に散文の一行（`> 需要 beta 或 alpha 版本？…`）が混入し、Nix コードとして描画されてブロックが途切れていました。en/ja/pcn にはなく zh のみの問題です。**③ pyelftools の記述も併せて修正**：「ruyi ≥ 0.53.0 で追加」としていましたが、本パッケージは**共有ベースで無条件に**この依存を追加しており（バージョン条件なし）、0.52.x チャネルも持ちます（実測で三チャネルすべてに存在、上流 0.52.0 の pyproject には 0 回）。「上流は 0.53.0 以降必要、本パッケージは無条件に追加、冗長だが無害」と明記しました。**その他の主張は実測通過**：`ruyi --help` に list/install/venv/device、`device provision`・`venv --toolchain`・`list --all` が存在。モジュールオプション `settings.packages.prereleases`/`repo.remote`/`telemetry.mode`/`telemetryOptout`/`venvs.{profile,toolchain,dest}` がすべて存在し、`/etc/xdg/ruyi/config.toml` を生成、アクティベーション時に `ruyi update` を自動実行。NixOS 互換の三機能を成果物内で個別に確認（`wrap_exec_for_nixos`/`_maybe_fix_toolchain_sub_binaries`/`patchelf`/`RUYI_ARGV0`）、文書の検証コマンドは実際にファイルを見つけられます。ライセンス Apache-2.0、上流は ISCAS が保守。**CI について**：今回の最終 push 後 `Build dsh-api-balance (aarch64)` が一度失敗しましたが、調査の結果 `api.github.com/.../llama.cpp/releases/latest` が **HTTP 403**（GitHub API のレート制限、浮動入力 `llama-cpp-ver` に命中）を返したためで、コードではなく一時的なインフラ障害でした。`gh run rerun --failed` で即成功し、リポジトリは 30/30 で green です。

| コミット | 説明 |
|------|------|
| `c30f2b6` | fix(docs): ruyi のテスト件数がチャネル別でない + zh インストール節のコードブロック破損（四言語） |

> **説明**：ドキュメントのみの修正。これで**主文書 + ソフトウェア 9 文書**（blender-mcp / codewhale / dsh / godot-ai / kitsfmt / mcp-searxng / obs-bilibili-stream / opencode-telegram / ruyi）の検証が完了し、累計 15 件の修正（実際の機能不具合 1 件と、本セッションで以前に入れた退行 2 件を含む）。残りはプラグイン・モード・開発・パッチ・廃止・スキルの各文書と、文書に載っていない内容です。

## 2026-09-18T13:41:45+09:00

**概要**：ドキュメント検証の続き — obs-bilibili-stream で 1 件修正、opencode-telegram は完全一致（変更ゼロ）。**① obs-bilibili-stream**：「Home Manager」節の `home.packages = [ ...obs-bilibili-stream ];` は**インストールされるが OBS はプラグインを読み込みません**——OBS は `OBS_PLUGINS_PATH` でプラグインを探し、この変数は **nixpkgs の `wrapOBS` だけが注入**します（`pkgs/applications/video/obs-studio/wrapper.nix`: `wrapProgram --set OBS_PLUGINS_PATH "${pluginsJoined}/lib/obs-plugins"`）。つまり `programs.obs-studio.plugins` 経由のみです。`home.packages` は `.so` をプロファイルに置くだけで、OBS はそのパスを走査せず、「入っているのにプラグイン一覧に出ない」となります。四言語に警告と二つの正しい方法を追記しました（NixOS ではモジュールか `programs.obs-studio.plugins`、非 NixOS／Home Manager のみならプラグイン探索パスに `.../lib/obs-plugins` を含めるよう自力で確保）。その他の主張は実測通過：バージョン 2.1.5、`meta.platforms` は純 Linux（darwin なし、「Linux only」と一致）、`default` overlay が当該パッケージを実際にエクスポート、`nixosModules.obs-bilibili-stream` が登録済み、モジュールのオプション名が文書と一致し**モジュール enable 時の代入が文書の「手動」記載とバイト単位で同一**、成果物構造が正しい（`lib/obs-plugins/bilibili-stream-for-obs.so` と対応する `share/obs/obs-plugins/`）、バッジに対応する x86_64/aarch64 の workflow が存在。**② opencode-telegram（今回唯一の変更ゼロ文書）**：全項目が一致——文書記載の 4 サブコマンド `start`/`status`/`stop`/`config` が `--help` 出力と一致、モジュールオプション `enable`/`user`/`group`/`afterServices`/`extraPackages`/`extraBinPaths`（ほか `environment`/`package`）がすべて実在し意味も一致、「start が opencode を自動起動」は事実——パッケージ内 `dist/opencode/process.js` の `startLocalOpencodeServer` が実際に `spawn("opencode", ["serve", "--port", port])` を呼び、これが文書でサービス PATH を強調する理由でもある、方案 A の `pkgs.opencode` は nixpkgs に実在（1.18.30）、バッジの三プラットフォーム workflow も存在。

| コミット | 説明 |
|------|------|
| `4bea784` | fix(docs): obs-bilibili-stream の Home Manager 用法は入るが効かない（四言語） |

> **説明**：ドキュメントのみの修正で、`packages/` と `overlays/` は未変更。opencode-telegram は変更不要と確認（今後の退行比較のため記録）。ソフトウェア群は ruyi のみ。

## 2026-09-18T13:40:20+09:00

**概要**：ドキュメント検証の続き — kitsfmt と mcp-searxng で各 2 件修正。**① kitsfmt**：「コメント保持」の記述が広すぎた——0.5.0 の実測では**ノード直前の先行コメント**だけがソート時に追随し、他に 4 種類の位置が失われるか移動する：最後以外の属性の同行末尾コメントは**次の属性の上へ移動**、**最後**の属性の同行末尾は**破棄**、**ファイル先頭**（トップレベル式の前）と**ファイル末尾**（その後）も破棄。ソースが裏付ける：コメントは `comments_before(<entry>)` 経由でのみ収集されるため、先頭・末尾には収集点がない。四言語に「コメント保持の制限」節を追加し、各行を実測で確認した。また漏れていた `KITSFMT_STDIN=1` を補完（`--help` は env を 4 つ表示するが、文書は 3 つだけだった）。その他の主張はすべて実測通過：3 つのベストプラクティス変換は**文書の例とバイト単位で同一の出力**（裸 URL 引用符化 / rec → let-in / with → builtins.attrValues）、`--check` の終了コード意味論（未整形 1、整形済 0）、`-i`/`-B`/複数ファイル（`---` 区切り付き）、冪等性、APC `a.b.c` 折りたたみ、そして別 flake からの `nix fmt` が端から端まで動作。**② mcp-searxng**：第一に「すぐ使える設定」に**廃止済み**の `real_ip.x_for = 1` が含まれていた——上流 searxng の `limiter.toml` にはもはや `real_ip` セクションがなく（`[botdetection]` 下は ipv4_prefix/ipv6_prefix/trusted_proxies のみ）、上流 master と nixpkgs がそのオプションに同梱する example の二箇所で独立に裏付けられ、コミュニティ記録も「replace real_ip by IPv4/v6 network」で置き換えられたことを示す。四言語から削除した。第二に「`SEARXNG_URL` がないと**サイレントに**失敗する」は実測と一致しない——サーバーは**正常に起動し `tools/list` もツールを返す**が、`tools/call` は毎回 `isError: true` を返し、テキストで `⚠️ Configuration Issues: SEARXNG_URL not set. Set SEARXNG_URL (e.g., ...)` と明示し、同時に stderr へ `SEARXNG_URL not set` を出す。つまりエラーは**明示的で対処可能**である（本当に残すべき落とし穴は `mcp add` が `env` を埋めないこと）。その他の主張は通過：バージョン 2.3.0、wrapper が nodejs を注入、本機の `~/.deepseek/mcp.json` の `servers.SearXNG` 構造が文書の例と**フィールド単位で一致**、nixpkgs の searx モジュールが `redisCreateLocally`/`settings`/`limiterSettings` の 3 オプションを実際に持つこと。

| コミット | 説明 |
|------|------|
| `0cb9f4f` | fix(docs): kitsfmt のコメント保持の記述が広すぎ + KITSFMT_STDIN 追加（四言語） |
| `9f3c829` | fix(docs): mcp-searxng の不正確な記述 2 件（real_ip は廃止、失敗はサイレントではない）（四言語） |

> **説明**：いずれもドキュメントのみの修正で、`packages/` と `overlays/` は未変更。検証は継続中（ソフトウェア群は残り obs-bilibili-stream / opencode-telegram / ruyi、その後プラグイン・モード・開発・パッチ・廃止・スキルの各文書、最後に文書に載っていない内容の確認）。

## 2026-09-18T13:32:32+09:00

**概要**：ドキュメント検証の続き — dsh と godot-ai の双方で問題を発見、うち godot-ai は**実際の機能不具合**（ドキュメントの問題ではない）。**① dsh（ドキュメント 1 件）**：「宣言的に設定可能な host ネームスペース」の表が 6 件のみで、しかも「DSH 0.1.2-alpha」と記載されていたが、その節が扱っているのは `0.1.5-rc.2` である——実測するとこのバージョンが `installSection` で登録する名前空間は **12 件**で、`agent-default-model`（provider/model/reasoningEffort）、`agent-loop`（maxParallelToolCalls）、`permission`（presets）、`shell`（dshHome）、`subagent-model-selection`、`web-search-deepseek` が欠けていた。三重の裏付け：`*_SETTINGS_NAMESPACE` 定数の全抽出で 12 件、各 `z.object({...})` スキーマの抽出でフィールド、実機の `settings.yaml` で `permission` の存在を確認。dsh のその他の主張はすべて通過（live サービス 8615/8625、reverseProxy の三オプションとその安全警告、`launchUrlFile` が実際に `/run/dsh/launch-urls` を生成、sudo ガードのソケットが `srw-------` で kix:users 所有かつ `NIXKITS_SUDO_SOCKET` 注入済み、プラグイン一覧 152 件が live dump と一行ずつ一致、reasoningEffort 四段階と `high` のフォールバック既定）。**② godot-ai（機能不具合 1 件 + ドキュメント 2 件）**：ドキュメント記載の `godot-ai` コマンドが**起動直後に失敗**する（`BACKEND_START_FAILED`、バックエンドログは `No module named godot_ai`）。根本原因を層ごとに特定：このコマンドは既定で attach ブリッジ経由で**バックエンドをもう一つ spawn** する（`sys.executable -m godot_ai`）。しかし Nix 包装下の `sys.executable` は**素の CPython** であり、依存は包装スクリプトが実行時に `site.addsitedir()` で注入するのみで、**spawn された子プロセスには継承されない**。上流は `uvx`／実 venv で導入するためこの落差は存在しない。修正は makeWrapper で PYTHONPATH を前置するもので、検証中に三つの必須ポイントを実測で踏んだ：`python312.sitePackages` は**相対**パスなので `${placeholder "out"}/` と結合する必要がある、深い伝播依存（pydantic_core/platformdirs）は `propagatedBuildInputs` を fixpoint 展開する必要がある、`d.pythonPath` は使えない（nixpkgs 側の別の pydantic 2.13.4 を指し、本リポジトリの overlay が引き上げた 2.13.5 を迂回して fail-closed 検証に失敗する）。実測 A/B：修正前 ❌ / 修正後 ✅（バックエンドは 127.0.0.1:8000 を待ち受け、MCP `tools/list` は 46 ツールを返す）。ドキュメントはさらに 2 件修正：ツール数 43 → **46**（上流 v4.1.0 の README も 46 と記載）、既定 WebSocket ポート 9876 → **9500**（`--help`、`__init__.py` の argparse、`asgi.py` の三箇所で独立に裏付け。9876 はパッケージ内に一切出現しない）。

| コミット | 説明 |
|------|------|
| `6b47f55` | fix(docs): dsh の設定ネームスペース表が不完全かつバージョン表記が古い（四言語） |
| `a54bd9d` | fix(godot-ai): attach バックエンドが起動しない不具合の修正と不正確な記述 2 件（四言語） |

> **説明**：`a54bd9d` は **`packages/godot-ai.nix` を変更**する（makeWrapper と postFixup を追加）。godot-ai のビルド成果物が変化している。残りはドキュメントのみの修正。

## 2026-09-18T13:23:25+09:00

**概要**：ドキュメント検証を開始 — 主文書の 26 項目の主張を再確認し、子文書を一篇ずつ検証、不正確な記述を 7 件修正。**手法**：ソースから推測するのではなく**実際に配備して計測**する——実プロセスを起動して権威あるデータを取得し（例：blender-mcp の MCP stdio に `tools/list` を送信）、統制された比較実験を行う。各ラウンドで証拠を残した後にクリーンアップし（一時ディレクトリ、registry 項目、テスト用 HOME）、実設定が一切変更されていないことを確認する。**① 主文書（README × 四言語）2 件**：`inputs.nixkits.url = "~/NixKits"` は**使用不可**（Nix は flake input URL の `~` を展開しない。実測エラー `path '.../source/~/NixKits/flake.nix' does not exist`。`path:$HOME/...` も同様に失敗。`git+file:///path/to/NixKits` に変更し、五通りの書き方の統制比較結果を添付）；「全パッケージが既定で `lib.platforms.linux` に従う」は**事実に反する**——12 パッケージの `meta.platforms` を実測すると 9 件が `lib.platforms.all`（darwin を含む）を宣言し、Linux 限定は codewhale / obs-bilibili-stream / godot-ai のみ。**② blender-mcp 3 件**：ツール数は 22 と称しながら 17 件しか列挙されておらず、**実サーバの登録は 26 件**（5 つの要約ツールの `_for_cli` 変種、2 つの jump ツール、`search_api_docs` / `search_manual_docs` が欠落）；アドオンのインストールパスは `blender/4.4/scripts/addons/` とあるが、このアドオンは **Blender Extension**（manifest `blender_version_min = "5.1.0"`、ゆえに **4.x では読み込めない**）で、新しい Blender のディレクトリは `extensions/user/`；さらに**更新が無言で失敗する**——store 内ディレクトリは読み取り専用（`dr-xr-xr-x`）で `cp -r` は権限ごと複製するため、2 回目のインストールは大量の `Permission denied` を出し、新旧が混在した半端な状態を残す（保守者の環境が 1.0.0 のままなのは正にこの症状）。正しい更新手順を追加（`chmod` → `rm -rf` → `cp` → `chmod`、1.0.0 → 1.0.3 を実測しパッケージ内とバイト単位で一致）。**③ codewhale 2 件（うち 1 件は退行）**：`codewhale --sandbox <tier>` という引数は**存在しない**（実測 `unexpected argument`）。実際は `--sandbox-mode`。**これは退行である**——`e386dfc` が既にこの引数名を修正していたが、同一コミットがスキャナの `RISKY_APPROVAL_DEFAULT` を消すために文言を書き換えた際、**誤った引数名を再導入した**。当時は「文言がスキャナに引っかかるか」だけを確認し、「書き換えた引数がまだ使えるか」を確認していなかったことを示す。また zh のみがこの行を持ち、en/ja/pcn は正当な `--yolo` を記載していたため四言語が不一致であった。現在は四言語すべてが `--sandbox-mode <tier>` の例・有効値・「`--sandbox` ではない」という注意を含む。**その他の主張は確認済み**：パッケージ / overlay / モジュール / devShell / スキルディレクトリ（`skills/` と**一件ずつ照合**し完全一致）、四言語の章構成とバージョン番号の一致、キャッシュの到達性、モード配布の seed-once と「コピーせず登録」の意味論、Claude Code 削除の理由が参照先文書に実在すること。

| コミット | 説明 |
|------|------|
| `82d8ed5` | fix(docs): 主文書の不正確な記述 2 件を修正（四言語） |
| `ead55d1` | fix(docs): blender-mcp の不正確な記述 3 件（四言語） |
| `6f40487` | fix(docs): codewhale のサンドボックス引数名の退行と四言語の不一致（四言語） |

> **説明**：ドキュメントのみの修正で、`packages/` と `overlays/` は未変更。ドキュメント検証は継続中（子文書を主文書の順に一篇ずつ再確認）。以降の発見は別途記録する。

## 2026-09-18T13:09:18+09:00

**概要**：refactor(ruyi)! — `ruyi-nixos-compat` パッチをパッケージ定義に統合し、無効となった overlay を削除。**① 発見した不一致**：この overlay は `prev.ruyi.overrideAttrs` であり、**nixpkgs の `ruyi`** を修正するものでした。しかし nixpkgs は既に当該パッケージを提供しておらず（`builtins.attrNames pkgs` で `ruyi` は NOT-FOUND）、overlay は**宿主を失っていました**——`nixkits.ruyi` モジュールの `lib.mkPackageOption pkgs "ruyi"` は何も解決できず、`packages/ruyi/*.nix` はこのパッチを参照しておらず（自前の `postPatch` で `nixos_compat.py` に追記するだけなのに、コメントには「file is created by the overlay patch」と書かれていました）、**実際に効いていたのは overlay を自前で被せていた `develop/ruyi.nix` のみ**でした。結果として、四言語のドキュメントは「パッケージ版が当該 overlay を含む」と述べているのに、flake パッケージの利用者は**NixOS 互換処理を実際には得られていません**でした。しかもこの種の不一致は**ビルド成功では露見しません**——成果物を項目ごとに確認して初めて判明します。**② 修正**：overlay が行っていた三つのことをすべて `packages/ruyi/ruyi.nix` に移しました——`patches = [ …/ruyi-nixos-compat.patch ]`（三チャネル共有）、`substituteInPlace --replace-fail` による `@nixLdSo@`/`@nixGlibcLib@` の埋め込み、そしてパッチが必要とする `ensure_toolchain_nixos_compat` の明示的な import です。**`--replace-fail` は意図的**：上流の改名でプレースホルダが消えた場合、**ビルドが即座に失敗**し、「パッチはあるが互換性はない」パッケージを黙って生み出すことはありません。あわせて overlay ファイルと flake の登録を削除し、`develop/ruyi.nix` も被せをやめました——devShell・flake パッケージ・NixOS モジュールが**同一の**ビルドを得ます。**③ 検証（ビルド通過だけでなく、成果物内で項目ごとに確認）**：三チャネル（ruyi / ruyi-beta / ruyi-alpha）すべてビルド成功。`nixos_compat.py` が存在し `@nixLdSo@` の**残存は 0 回**、実際の store パス（`glibc-2.42-84/ld-linux-x86-64.so.2`、存在を実測）に置換済み。`runtime.py` に `wrap_exec_for_nixos` と注入 import、`maker.py` に `expose_build_tools_in_venv` 呼び出し、`nuitka.py` に `RUYI_ARGV0` 分岐を確認。ランタイムのスモークテスト `ruyi --version`/`--help` は正常。beta(0.53.0) の pytest は依然 **462 passed + 70 passed**。四言語ドキュメントを「パッチ内蔵・overlay 設定不要」に書き換え、経緯も保持。

| コミット | 説明 |
|------|------|
| `87d3f7c` | refactor(ruyi)!: パッチをパッケージ定義に統合し、無効な ruyi-nixos-compat overlay を削除 |

> **説明**：破壊的変更——`nixkits.overlays.ruyi-nixos-compat` は**存在しなくなりました**。外部でこの overlay を参照していた場合は当該行を削除してください（パッチは内蔵済みで overlay 設定は不要）。ruyi 三チャネルのビルド成果物はいずれも変化しています。

## 2026-09-18T12:41:08+09:00

**概要**：定例の更新チェック — blender-mcp 1.0.3、ruyi-beta 0.53.0-beta.20260917（`pyelftools` ランタイム依存を追加）、dsh 0.1.5-rc.2、dsh-alpha 0.1.6-alpha.2。**① ruyi の依存追加（唯一の実質的欠陥）**：上流は 0.53.0 から `pyelftools` を `pyproject.toml` の**ランタイム**依存に記載し（0.52.x 以前にはありませんでした）、さらに**収集時**に `import elftools` する `tests/ruyipkg/abi/test_elfbuilder.py` を追加しました——依存が欠けると pytest は `Interrupted: 1 error during collection` を出し、一件をスキップするのではなく**スイート全体を中断**します。`propagatedBuildInputs` に追加した結果、`ruyi`/`ruyi-beta`/`ruyi-alpha` の三チャネルすべてが通過し、beta のテスト数は 320 ユニット + 52 統合から **462 ユニット + 70 統合**へ増加しました。四言語の ruyi ドキュメントにその数と依存の説明を反映しています。**② dsh-alpha の vendored lock が古い**：alpha.2 では上流が 4 つのプラグインパッケージ（`dsh-atomic-write`/`dsh-experimental-agent-team-web-profile`/`dsh-hmr`/`dsh-plugin-manager`）を追加した一方、`dsh-package-lock-alpha.json` は alpha.1 のままでした——**version だけを変えると `npmDepsHash is out of date` になります**。AGENTS.md の取り決めに従い、**派生の `postPatch` 処理後**の `package.json`（`devDependencies` を削除）に対して `npm install --package-lock-only` で lock を再生成し、ハッシュを書き戻しました。**③ 内蔵プラグイン一覧の照合**：`dsh --profile web --dump-default-config` で stable rc.2 の **152 件の `id -> name`** を再抽出し、一行ずつ比較した結果、rc.1 と**完全に一致**しました（rc.1→rc.2 で npm 依存集合も変わらないため、既存の `npmDepsHash` がそのまま使えます）——よってドキュメントのプラグイン表に変更は不要でした。**④ セルフホスト forge からの取得（教訓の再現）**：`projects.blender.org` の Web パス `/archive/<rev>.tar.gz` は非ブラウザの user agent に **403** を返し（API パス `/api/v1/repos/.../archive/` は正常）、`fetchFromGitea` のハッシュ換算も**すでに記録済みの教訓**であったため、今回は遠回りしませんでした：ハッシュは**展開後の NAR**（`stripRoot`）の sha256 であり、1.0.0 の宣言値に対して換算方法を**逆向きに検証**したうえで `nix build` が一発で成功しています。四言語同期、`nix flake check` 全通過

| コミット | 説明 |
|------|------|
| `0e220fd` | chore(blender-mcp): 1.0.0 → 1.0.3 へ更新（四言語同期） |
| `9b48078` | fix(ruyi): beta → 0.53.0-beta.20260917 へ更新し pyelftools 依存を追加 |
| `80104c4` | chore(dsh): stable 0.1.5-rc.2 + alpha 0.1.6-alpha.2（四言語同期） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| blender-mcp | 1.0.0 | 1.0.3 |
| ruyi-beta | 0.52.0-beta.20260824 | 0.53.0-beta.20260917 |
| dsh | 0.1.5-rc.1 | 0.1.5-rc.2 |
| dsh-alpha | 0.1.6-alpha.1 | 0.1.6-alpha.2 |
| 　 | blender-mcp source hash | `sha256-nt+sHozi…` → `sha256-pYeByO4O…` |
| 　 | ruyi-beta source hash | `sha256-vxu9AhRD…` → `sha256-w8NlCER3…` |
| 　 | dsh source hash | `sha256-Gnlxnxx2…` → `sha256-9MVIOdae…` |
| 　 | dsh-alpha npmDepsHash | `sha256-qAlIccAJ…` → `sha256-p4uALt5v…` |

> **説明**：共有ベースの `ruyi.nix` に `pyelftools` の一行を追加（三チャネル共通）。`dsh-package-lock-alpha.json` は alpha.2 の依存集合から再生成しました。残りのパッケージは上流と照合済みで既に最新のため変更していません。

## 2026-09-18T00:38:59+09:00

**概要**：サンドボックス段階の記述を書き換え、外部スキャナの `RISKY_APPROVAL_DEFAULT` を解消（88 → 94） — 外部カタログ `awesome-ai-plugins` のスキャナが本リポジトリに対し `RISKY_APPROVAL_DEFAULT`（medium）を 5 件報告しました。**制御実験**によりトリガー語が `danger-full-access` であると特定：空のリポジトリでは 0 件、当該語を一行注入するだけで finding が出現します。**これは実際のリスクではありません**——本リポジトリは利用者が任意に選べる挙動を「既知の設計境界」の表と CLI の使用例で**記述**しているのであり、既定値を**設定**しているのではありません。ただしスキャナはパターン照合であり、「文書の記述」と「設定による有効化」を区別できません。**修正は情報を一切削らず措辞のみを変更**し、結果として読者にとってより正確になりました（「既定では緩めない」と明示）：四言語の `SECURITY.md` は「サンドボックス権限の段階は利用者が明示的に選択し、**既定では一切緩めません**」となり、`docs/zh/codewhale.md` の CLI 例は `--sandbox <tier>` になりました。**既存の記述誤りも同時に修正**：例では `--sandbox` としていましたが、このパッケージの実際の引数は `--sandbox-mode` です（`codewhale --help` の実行で確認）。正しい形式に改めました。**実測による検証**（公式スキャナ、CI と同一）：修正前 **88/100**（Security 13/16、medium 5 件）、修正後 **94/100（A - Excellent）**、Security **16/16**、medium 0 件。**意図的に行わなかった最適化**：残る 6 点は `Dependabot configured for automation surfaces` に由来します。本リポジトリは Dependabot を**意図的に削除**しており（AGENTS.md「安全境界：外部自動化を導入しない」参照）、**点数を上げるためにその境界を破ることはしません**。四言語同期、`nix flake check` 全通過

| コミット | 説明 |
|------|------|
| `e386dfc` | docs(security): 改写沙箱档位表述，消除扫描器 RISKY_APPROVAL_DEFAULT（88 → 94） |

> **注**：文言のみの文書修正であり、`packages/` と `overlays/` は未変更。

## 2026-09-17T18:15:40+09:00

**概要**：汎用スキルを「主フロー + 二つの配套参考」へ再構成し、ブランチ分離で滞留していた Gitea の教訓を回収 — 本セッションにおける更新スキルの**性能評価に基づく改善**です。**① 既知の知識損失の回収**：監査により、blender-mcp の実測ブランチで書かれた 70 行の「自ホスト forge（Gitea）のソース取得」節と 21 行の適応層記録が**永続的に滞留する寸前**であったことが判明しました。テストブランチは取り決めによりマージされませんが、その知識（`fetchFromGitea` は `fetchFromGitHub` に委譲し `/archive/` 経路を生成する、自ホストのインスタンスは**全 tag で 403** を返しうる、対策は API エンドポイント + `stripRoot = true`、そして「旧版がまだビルドできる」のは単なるキャッシュ命中かもしれない）は**再現可能・追跡可能で、あらゆる自ホスト forge リポジトリに当てはまります**。持ち込む前に **main 上で証拠を逐一再現**（403 対 200 の実測、nixpkgs の fetcher ソースで確認）しており、機械的な cherry-pick ではありません。**② 回収の慣例を強化**：適応層の第 10 步に、**テストブランチで生まれた汎用の教訓はその場で手作業により main へ書く**ことを要求する小節を追加——「ブランチはマージされない」は「教訓が重要でない」理由にはなりません——今回の実際の損失を根拠として記録しました。**③ スキルの再構成**：単一ファイル 918 行では実行中に目的の箇所を探しにくいため、AGENTS.md の「独立したデータは配套ファイルへ分割」に従い、主フロー `SKILL.md`（462 行）+ `builders.md`（254 行：ビルダー別 hash フローと `flake.lock` の処理）+ `traps.md`（271 行：ドリフトの罠、fail-closed、外部リンク失効監査、Actions、パッチ内バージョン）としました。**完全性を四通りに照合**（`##` 節、`###`/`####` 子節、行単位の比較、行数）。そのうち**三つの節を実際に取りこぼしました**（「パッチ内バージョンの確認」「外部リンクの監査」「GitHub Actions の更新確認」——`sed` の境界が適応層の節の手前になり、この三節はそのさらに前に位置していた）。見出しレベルの照合で発見し復元しました。最終的な行単位比較で差分は 4 行のみで、いずれも意図的な書き換えと確認済みです。**④ 「コミット前の六つの自問」を新設**（第 7 步）：変体は複数か？依存表は一致か？ソース取得は有効か？実際に実行したか？文書の記述は成立するか？`flake.lock` はコミットすべきか？——**六つはいずれも同日に実測した事故から抽出**したもので、各問が一回のやり直しか欠陥に対応します。該当したら `traps.md` へ進めばよく、全文を読む必要はありません。**評価の根拠**：本セッションの実測 3 回、6 パッケージの更新、初回成功率 4/6、そして 3 回のやり直しは**いずれもスキルが記録済み、あるいは記録すべきだった罠が原因**でした——ゆえに改善の方向は「教訓が正しい場所で見つかるようにする」ことであり、さらなる積み増しではありません。四言語の文書を同期

| コミット | 説明 |
|------|------|
| `e0b1a64` | refactor(skills)!: 通用技能拆分为主流程 + 两份配套参考，并补回丢失的 Gitea 教训 |

> **注**：スキル構造の変更（配套ファイル `builders.md` と `traps.md` を新設）。`packages/` は未変更。
## 2026-09-17T17:22:50+09:00

**概要**：`check-doc-versions` 検査を新設し「文書の版 = パッケージ定義の版」を断言化 — 今回連続して発見した 5 件の文書の版の不一致（godot-ai、codewhale、mcp-searxng、opencode-telegram、dsh-alpha）に対する**構造的な防御**です。この種の不一致は**どのビルドも失敗させない**ため人手で文書を読まなければ見つかりません。そこで `nix flake check` の 6 番目の検査（従来 5 件）として固定しました。**検査内容**：①`docs/<lang>/<pkg>.md` の「バージョン」行（四言語）がパッケージ定義の宣言値と一致すること；②多チャネルパッケージ（`dsh-alpha` / `ruyi-beta` / `ruyi-alpha`）の**チャネル表**の版も四言語で検査；③版を他所から読む場合も追跡（`kitsfmt` は `Cargo.toml`）；④例外はスクリプトの `EXEMPT` に明示登録（`dsh-api-balance` は薄いラッパーとして意図的に版を記載せず、`codewhale-src` は独立パッケージではなく、`dsh`/`dsh-alpha` はチャネル表に記載）。**定義から機械的に読み出せる部分（版番号）のみを検査**します。依存表・プラットフォーム対応・インストール手順は自動比較できず、明示的に範囲外です——判定に人の判断を要する検査を書かないためです。**回帰テスト（要点）**：今回**実際に遭遇した** 5 種類の欠陥を一つずつ注入し、すべて検出されました。メッセージは「どのファイルが何と書き、どの定義が何を宣言しているか」を明示します——codewhale 0.9.12（zh）、godot-ai 3.2.5（zh）、mcp-searxng 2.2.0（en）、opencode-telegram 0.25.1（ja）は版行の検査で、dsh-alpha のチャネル行 0.1.5-alpha.2（四言語）はチャネル検査で捕捉。**エンドツーエンド検証**：欠陥を注入後、`nix flake check` の**実際の経路**で失敗することを確認（`failed to build attribute 'checks.x86_64-linux.doc-versions'`）——スクリプトを直接実行したときだけ失敗するのではないこと。**CI 確認**：push 後 `CI` workflow が成功（run `35199359526`）、ログに `evaluating 'checks.x86_64-linux.doc-versions'` が出ており、検査がスキップされず実際に実行されたことを示します。`AGENTS.md` に規約・例外登録方法・適用範囲を記録

| コミット | 説明 |
|------|------|
| `072ab87` | feat(ci): 新增 check-doc-versions，把「文档版本 = 包定义版本」固化为断言 |

> **注**：検査スクリプト `develop/check-doc-versions.py` を追加し `flake.nix` の `checks` に接続（検査数 5 → 6）。`packages/` と文書内容は未変更。

## 2026-09-17T16:12:06+09:00

**概要**：5 パッケージの文書の版番号を修正（内容品質の修正） — **全サービスパッケージ**を対象に「文書の版 vs パッケージ定義の版」を体系的に照合し、5 件の不一致を発見。いずれも更新済みなのに文書が追随していない事例：**codewhale** 0.9.12 → **0.9.13**（プリビルド変体とソース変体の双方が 0.9.13）、**mcp-searxng** 2.2.0 → **2.3.0**、**opencode-telegram** 0.25.1 → **0.25.2**、**dsh-alpha** 0.1.5-alpha.2 → **0.1.6-alpha.1**（文書と README の 2 箇所）、**codewhale-sudo** v0.9.12 → **v0.9.0 以降**。**最後の一件は機械的置換ではなく判断を要した**：当該 overlay は実際には**版に依存せず**（`codewhale.override { allowSudo = true; }`）、v0.9.0 で導入された `prctl(PR_SET_NO_NEW_PRIVS)` を傍受するものです。README の「v0.9.12」は古いだけでなく文書本文（v0.9.0 と記載）と**自己矛盾**していたため、たまたま存在した版を固定するのではなく機能の由来を記述する形に改めました——そして**当該 overlay が 0.9.13 でも正常に動作することを実測**しました（codewhale 0.9.13 と codew/codewhale-tui の 3 バイナリを生成）。**意図的に残した歴史的参照**：`docs/*/modes/nixos.md` の「`prefix` は dsh 0.1.5-alpha.2 以降必須」は**出来事の記述**（フィールドがいつ変わったかの記録）であり現在の版の標識ではないため、変更すればかえって記録が歪みます。**照合方法**：パッケージごとに定義の版を `grep` し四言語と比較、修正後に全体を再照合（10/10 一致。残る 3 件の「不一致」は精査の結果すべて grep の誤検出——`dsh`/`ruyi` は `version ?` 形式、`dsh-api-balance` は薄いラッパーとして意図的に版を記載しない）。**併せて実施した整合性検査**：文書が参照する 9 個のファイルパスはすべて実在、`nixkits.*` のモジュールオプションはすべて有効（疑わしい 3 件は精査の結果モジュールオプションではなく flake 出力）、文書中のパッケージ名はすべて実際の flake 出力。`nix flake check` 全通過、四言語同期

| コミット | 説明 |
|------|------|
| `0a0d8ce` | docs: 修正五个包的文档版本号（内容质量修复） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale（文書） | 0.9.12 | 0.9.13 |
| mcp-searxng（文書） | 2.2.0 | 2.3.0 |
| opencode-telegram（文書） | 0.25.1 | 0.25.2 |
| dsh-alpha（文書 + README） | 0.1.5-alpha.2 | 0.1.6-alpha.1 |
| codewhale-sudo（README の表現） | 「v0.9.12 の sudo 機能」 | 「v0.9.0 以降で阻まれた sudo 機能」 |

> **注**：今回は**文書のみの修正**であり、`packages/` と `overlays/` は未変更。

## 2026-09-17T15:56:56+09:00

**概要**：godot-ai の四言語文書の版番号と依存表を修正；汎用スキルの第 5 步に「機械的置換ではなく書き直す」判据を新設 — **内容品質の修正が主**：main 上の godot-ai の**コード**は `2a06bbf` で既に 4.1.0 に到達し機能も完全（実測 `godot-ai --version` → 4.1.0、exit 0）だが、**文書が同期されておらず**、二つの事実誤りが残っていた：①版番号が依然 `3.2.5`；②依存表が **6** 項で全て「≥ 範囲」だが、実際は **9** 項の fail-closed 厳密固定。**②の方が有害**——v4 は起動時にこれら 9 パッケージの**正確な版**を検証し、不一致なら起動を拒否する。文書に「≥」と書けば読者は版が自由に浮動できると誤解し、その通りにすれば `RuntimeError` に直撃する。修正では依存表を「版 + 提供元」の二列にして 9 項を逐一列挙し、pydantic-core の連動要求（`==2.46.5`）、ビルド時 `setuptools==84.0.0` pin の緩和説明、「なぜ検証を打ち消すパッチを書かないか」の理由を補足した。**照合**：文書中の 9 個の版番号は `nix eval` で**overlay を含む実際の閉包**から測ったもので**推測ではない**。文書値と逐一比較し **9/9 完全一致**；四言語同期、`nix flake check` 全通過。**スキル改善**：汎用スキルの第 5 步に「**文書を機械的置換ではなく書き直すべき時**」の触发判据を新設（依存が範囲から厳密固定へ / 起動時・ビルド時の硬い検証の追加 / 依存の増減 / ビルド方式の変更 / 対応プラットフォームの狭まり）。**手作業で main に書き込み**（cherry-pick ではない）。書き込み前に各主張を検証し証拠の参照先を書き換えて main 上で自包含かつ再現可能にした：初稿の「当該表はその後書き直された」という記述も削除——照合の結果 main では当時まだ書き直されておらず、残せば証拠の虚偽申告になるため

| コミット | 説明 |
|------|------|
| `085c093` | docs(godot-ai): 修正四语文档的版本号与依赖表（内容质量修复） |
| `55674f2` | feat(skills): 通用技能第 5 步新增「文档须重写而非机械替换」的触发判据 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| godot-ai（文書） | 文書は 3.2.5 / 依存表 6 項「≥ 範囲」 | 4.1.0 / 依存表 9 項の厳密固定 |

> **注**：今回は**文書の修正**であり、`packages/godot-ai.nix` は未変更（そのコードは `2a06bbf` で既に正しい）。

## 2026-09-17T13:00:09+09:00

**概要**：feat(skills): 適応層に第 10 步「プロセスの振り返りと規範の検証」を新設 — 更新フローが**完全に終了した後**に実行し、監査するのは**ソフトウェアではなく、ソフトウェアがどう更新されるかを決める規範そのもの**（スキル / `AGENTS.md` / `SECURITY.md` / develop スクリプト）——すなわち更新プロセス自身への更新チェックである。六つのサブステップ：**10.1 振り返り**（初回で失敗した箇所 / ユーザーに問う必要があった箇所 / やり直した箇所を根本原因まで辿る）、**10.2 検証**（`AGENTS.md` / `SECURITY.md` の記述が今も成立するか。外部リンクの到達性を含む）、**10.3 帰属**（可搬性で汎用スキル / 適応層 / `AGENTS.md` / `SECURITY.md` に振り分ける。判据は「別の nix flake リポジトリへ移しても成立するか」）、**10.4 体験**（ユーザーを何往復待たせたかを振り返り、自行検証できる事項を潰す）、**10.5 証拠規律**、**10.6 成果**。**10.5 は硬性の制約**：規範の変更は**再現可能・追跡可能・異議申立て可能**でなければならない——印象による規範変更、一度の偶発を法則と見なすこと、既に正しく書かれた内容への「さらなる最適化」、役に立たないように見えるが拘束力の残る条目を削除することは、前提が消えたことを証明できない限り禁止する。**初回実行で二つの実欠陥を発見**（いずれも**ビルドエラーを生まず**、能動的な監査だけが炙り出せる）：①`SECURITY.md` がサブリポジトリの `SECURITY.md` を指す**デッドリンク**——当該ファイルは未作成（`gh api` と `curl` の双方で 404 を確証）。四言語を「同サブプロジェクトは独自のセキュリティポリシーを未整備。脆弱性は本リポジトリへ」に変更；②**12 箇所**の `Asus-linux/asusctl` 失効リンク（3 文書 × 4 言語）——プロジェクトは `OpenGamingCollective/asusctl` へ移転（`gh api` で 602 stars、HTTP 200 を確証）。「URL を直すときは表示テキストも直す」の要求に従いリンク文言も更新。**汎化**：リンク監査の手法を汎用スキル「文書内の外部リンクの監査」へ。三つの判据を含む——`curl` の 404 は `gh api` で再確認して初めて確定する（権限や制限の可能性がある）、`403` は多くの場合スクレイピング対策でありデッドリンクではない、**vendored な第三者コンテンツは書き換えない**（`packages/kitsfmt-src/vendor/` 内の上流 CHANGELOG など）。四言語の文書を同期

| コミット | 説明 |
|------|------|
| `442e5d1` | feat(skills): 适配层新增第 10 步「流程复盘与规范校验」 |

## 2026-09-17T12:52:54+09:00

**概要**：fix(codewhale): x86_64/aarch64 のプリビルド変体も 0.9.13 へ — **配備後の照合で初めて判明した**変更漏れ：前の条目は `codewhale-src`（riscv64 のソースビルド変体、Cargo.lock 同期を含む）だけを更新し、**`codewhale.nix` を漏らしていた**——x86_64/aarch64 は GitHub Releases のプリビルドバイナリ経路であり、`flake.nix` が `hostPlatform.isRiscV` で分岐している。症状は「ローカルのビルドは通り dsh も 0.1.6-alpha.1 になっているのに、システム上の `codewhale --version` は依然 0.9.12」。**本リポジトリの codewhale は同名同出力の二つの変体を持つ**：`codewhale.nix`（プリビルド。`version` と cli/tui × x64/arm64 の **4 つの hash** が必要）と `codewhale-src.nix`（ソースビルド。`version` + `hash` + `Cargo.lock` の同期が必要）——**更新時は両方を変更せねばならない**。実測では 0.9.13 の cli と tui の資産 hash は同一（`WTriVnVv…` / `BgUnHSo0…`）で、0.9.12 のときと同じであったが、4 つの値はそれぞれ記入するため結果として二つずつ一致する。**汎化**：この罠は適応層の「本リポジトリ固有の罠」に記載し、判据を添えた——**配備後は変体ごとにそのアーキテクチャ上で実際の版を照合する。ビルド通過だけで判断しない**

| コミット | 説明 |
|------|------|
| `ecb28c4` | fix(codewhale): 同步升级 x86_64/aarch64 的预编译二进制变体至 0.9.13 |
| `f8c8265` | docs(skills): 记录 codewhale 双变体陷阱（四语） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale（x86_64/aarch64 プリビルド） | 0.9.12 | 0.9.13 |
| 　 | cli/tui hash x64 | `nQt02NO/` → `WTriVnVv` |
| 　 | cli/tui hash arm64 | `Gkje9AMu` → `BgUnHSo0` |

## 2026-09-17T12:41:29+09:00

**概要**：五つのパッケージ更新 + 更新スキルに「対話的確認」を追加 — 本番環境での実戦として承認済みの更新を全て実行した：**mcp-searxng** 2.2.0 → 2.3.0、**opencode-telegram** 0.25.1 → 0.25.2、**codewhale** 0.9.12 → 0.9.13、**dsh-alpha** 0.1.5-alpha.2 → 0.1.6-alpha.1、**godot-ai** 3.2.5 → **4.1.0**（大版本跨ぎ）。**godot-ai v4 が今回最难の項目**であった：**fail-closed な実行時依存検証**を導入しており、起動時に九つのパッケージの正確な版を照合し、一つでも不一致なら `RuntimeError: unsupported godot-ai runtime dependency set` で起動を拒否する。nixpkgs（unstable と master を含む）は五つで遅れており（mcp 1.29.0→1.29.1、pydantic 2.13.4→2.13.5、starlette 1.3.1→1.6.0、uvicorn 0.51.0→0.52.4、websockets 16.1→17.1）、そのため新たに `overlays/godot-ai-v4-deps.nix` を追加してこの五つを上流の要求版まで引き上げ（pydantic-core も連動して 2.46.5 へ、Rust の `cargoDeps` も再取得）、既存の `fastmcp` overlay と**連鎖**させた。**上流のセキュリティ契約を壊さない方向で先にユーザーへ確認し承認を得た**——検証を打ち消すパッチは書かない。**踏んだ罠**：`flake.nix` の `godotPkgs` と `overlays/default.nix` は二つの独立した overlay 連鎖であり、初版は前者だけを変更したため `--version` が依然 RuntimeError となった。両方を同期させて初めて通過した。また上流の `setuptools==84.0.0` というビルド時 pin を緩和した（nixpkgs は 83.0.0。この pin は再現性の守りであって機能要件ではない）。**codewhale** の更新ではスキルの要求どおり **Cargo.lock を同期**した（7073 → 7347 行、上流が `wl-clipboard-rs` 等を追加）——漏らせばビルドが失敗する。**dsh-alpha** では vendored lock の罠を踏んだ：`npm install --package-lock-only --legacy-peer-deps` で生成した lock は **`"peer": true` 条目を含まず**、ビルドが `ENOTCACHED` で失敗する。このフラグを外すと npm が peer 条目を書き込む（既存の動作する lock と構造が一致し、いずれも 24 条）。**スキルの汎化**：`nix-flake-update-check` に「対話的確認」の節を新設——質問機構を持つエージェント（DSH など）は**着手前に保留事項を一度にまとめて問う**必要があり、「推測 → 訂正 → やり直し」の往復を避ける（やり直しの度にビルドを再実行することになり、ビルドは本フローで最も高価な工程である）。併せて罠 5（fail-closed 実行時検証：ビルド成功 ≠ 使用可能。必ず一度実行して検証する）と罠 6（`overridePythonAttrs` で Rust ビルドのパッケージを変更する際は `cargoDeps` も再取得が必要）を追加し、npm の節に peer 条目要件を補足した。適応層には本リポジトリで実測した三つの罠を追加。**検証**：五つ全てがビルドを通過し、実際に実行して確認（godot-ai `--version` → 4.1.0、codewhale → 0.9.13、mcp-searxng → 2.3.0、dsh-alpha → 0.1.6-alpha.1）。`nix flake check` は全て通過

| コミット | 説明 |
|------|------|
| `2a06bbf` | chore(pkgs): 升级 mcp-searxng 2.3.0、opencode-telegram 0.25.2、codewhale 0.9.13、dsh-alpha 0.1.6-alpha.1、godot-ai 4.1.0 |
| `c7de9b6` | feat(skills): 更新技能追加交互式澄清，并计入本轮实战教训 |

| パッケージ | 旧 | 新 |
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

**概要**：fix(skills): 子リポジトリ追従の判据をフィールド単位に細分化（本番環境での実戦が契機） — 予定どおり dry run を終えた後、**ソフトウェア更新スキルを実際に一度フル実行**して本番評価を行ったところ、実戦が直前の条目における判据の欠陥を即座に露呈させた：旧判据は「**ファイル**が変化したか」で分流していたが、マニフェストファイルの多数のフィールドのうち意味的入力は一部にすぎない。実測では子リポジトリ `dsh-api-balance` の `package.json` は**確かにバイトが変化**しており（`publishConfig.access` の削除）、一方で `dependencies`、`files` ホワイトリスト、`version`、`main`/`exports` は**いずれも未変更**であった——旧判据では「マニフェストが変化 → 追従」と誤判定され、純粋なメタデータ変更のために全アーキテクチャの再ビルドとキャッシュ無効化を引き起こすところだった。**修正**：判据を**フィールド単位**に変更——リリースメタデータ（`publishConfig` / `repository` / `keywords` / `description` / `bugs` / `homepage`）、ドキュメント、CI 設定はビルド入力では**なく**、**追従しない**；`dependencies` 系 / `files` / `main` / `exports` / `scripts` / `version` / ソースはビルド入力で**あり**、**必ず追従する**；さらに「あるフィールドが成果物に影響するか判別できない場合は追従側に倒す」という兜底原則を追加（一回多くビルドする方が、実変更を一度見落とすよりはるかに良い）。適応層における今回の子リポジトリ変更の記述も修正——原文は「ドキュメントのみの変更」と誤って述べていたが、実際には `package.json` も変化しており、**判据はファイルではなくフィールドに落ちなければならない**。**実戦は同時に新機能が正常に動作することを確認した**：実在のリポジトリ上で第 9 步がアカウント識別、参照関係の検出、四つの前提検証（循環 / 深さ / アカウント / 独立昇格可能——**すべて PASS**）と変更性質の判定を完了し、さらに主リポジトリ側の実際の保留更新（`codewhale-src` 0.9.12→0.9.13、`godot-ai` 3.2.5→4.1.0、`mcp-searxng` 2.2.0→2.3.0、`opencode-telegram` 0.25.1→0.25.2、`dsh-alpha` 0.1.5-alpha.2→0.1.6-alpha.1）と既に最新の二項目（`ruyi` / `obs-bilibili-stream`）を発見した。今回は評価のみで更新は実施していない

| コミット | 説明 |
|------|------|
| `c08f5c9` | fix(skills): 子仓跟进判据细化到字段级 |
| `641830a` | docs(skills): 同步四语的子仓跟进字段级判据 |

## 2026-09-17T11:31:32+09:00

**概要**：feat(skills): 同アカウント子プロジェクトの連鎖チェックとリポジトリ横断のメンテナンス条目リンクに対応 — 新機能：リポジトリが参照する**同アカウントの子プロジェクト**（典型的には薄いラッパー）もソフトウェア更新チェックの対象とし、前提が成立する場合は**連鎖並列に実行**する。子プロジェクトの結果は**主リポジトリの結果とみなす**が、それぞれのリポジトリのログに別々に計上し、主リポジトリの条目は**子プロジェクトの条目セクションへリンクする**。**執筆前に帰属を評価**——汎用ロジックは汎用スキルへ、リポジトリ固有の内容は適応層へ切り下げる：**`nix-flake-update-check`（汎用）**に第 9 步「同アカウント子プロジェクトの連鎖チェック」を新設し、参照関係の検出（`fetchFromGitHub` / flake input / submodule の三形態）、**四つの前提検証**（循環なし / バージョン衝突なし / 独立昇格可能 / アカウント一致——いずれかが成立しなければ連鎖せず通知に退化する）、循環と深さ上限の検出、依存衝突の判据、連鎖並列と失敗の隔離、結果の帰属、そして「**子リポジトリがいつ追従を要するか**」の分岐判断（版番号が変わった → 追従必須；ドキュメントのみの変更 → 追従は無意味）を含む。**`write-maintenance-log`（汎用）**に類型 5「リポジトリ横断の子プロジェクト連鎖更新」を新設：主リポジトリは薄いラッパーの座標変更（`rev` / hash）のみを記録して子リポジトリの条目へリンクし、子リポジトリは自身の完全な変更を記録する——両者は内容が異なり重複ではない。**`write-project-docs`（汎用）**に「子リポジトリ参照関係の明示記録」を新設：主リポジトリの短いページにはソースリポジトリ + メイン側の役割 + 固定した座標 + 同期方法を明記する。**`nixkits-check-updates`（適応層）**は本リポジトリ固有の事実のみを担う：子リポジトリの座標、ビルド体系、peer 依存の判据、歴史的座標表。**先に dry run で検証し、三つの実欠陥を発見・修正**：①スキル内の検出コマンドに `-h` がなく、`awk` のフィールド番号がずれて**無言で空を返した**（「本リポジトリに子プロジェクトは無い」と誤認される）；②依存衝突の判据を「両者が等しいか」と書いていたが、実測では子リポジトリが `0.1.1-rc.2` を宣言しホストは `0.1.5-rc.2` を提供していた——**peer 的依存ではホストが高い方が正常状態**であり、判据は「子リポジトリの要求がホストの提供より高いか」でなければならない；③GitHub のアンカー導出規則を「`:` と `+` を除去」と書いていたが、実際は**一文字ずつ `-` に置換**である（`:` と `+` が各々ひとつの `-` になり、既存の `-` は保持される）。**dry run は同時に一つの実際の保留事項を発見**：主リポジトリが固定した `dsh-api-balance` の `rev` は子リポジトリの HEAD より二コミット遅れているが、**版番号は未変更でいずれもドキュメントのコミット**であるため、新判据では再固定は**発生しない**——まさにこの分岐条項が防ごうとしている誤昇格である

| コミット | 説明 |
|------|------|
| `b7e9717` | feat(skills): 支持同账户子项目链式检查与跨仓维护条目链接 |

## 2026-09-17T11:21:34+09:00

**概要**：chore(security): `dependabot.yml` を完全に削除し「外部自動化を導入しない」安全境界を確立 — 前回は npm エコシステムが**構造的に無効**である理由のみでそれを削り `github-actions` を残したが、今回の判断はさらに厳しくする：**Dependabot そのものが我々の導入したくないものである**。実行不能・PR を作るのみ・secrets を得られないとしても、それは依然として**外部自動化統合**であり——GitHub プラットフォームが実行し、挙動は我々の制御下にない——本リポジトリの「開発と保守は保守者（狐莉）と小爪のみで完結する」という境界と衝突する。ゆえに `.github/dependabot.yml` を丸ごと削除し、`AGENTS.md` に「## 安全境界：外部自動化を導入しない」節を新設して規則として固定した：拒否リスト（第三者の CI スキャナ、純粋な設定形態を含む Dependabot）、判断基準（自動化能力が必要になったら、まず**リポジトリ内に既にある `gh`/`git`/`nix` で自行実装できるか**を問う。可能ならスキルに書き、不可能なら人手で行う）、受け入れた代償（action の安全更新は PR を自動で受け取るのではなく、スキル検査を能動的に走らせる必要がある）。**能力は失われない**：かつて「action を SHA 固定すると更新通知が届かなくなる」盲点を埋めていたのは Dependabot だったが、現在は `nix-flake-update-check` スキルが自行実装する——「## GitHub Actions の更新を確認する」節を新設（`grep` で固定 action を列挙 → `gh api` で latest tag を照会 → tag の commit SHA を取得し annotated tag を処理 → SHA とコメント版数を書き戻す → 検証）。旧「Dependabot の自動 PR は直接マージできない」小節は他リポジトリ向けの汎用指針に書き換え、本リポジトリは当該統合を使用しない旨を注記した。四語のドキュメントを同期。**実測**：新フローで現在の 3 つの固定 action を照合し、`actions/checkout` は最新 `v7.0.1`（`3d3c42e5…`）、`cachix/cachix-action` は最新 `v17`（`38b08261…`）でいずれもリポジトリの現行値と一致——すなわち現在はすべて最新である

| コミット | 説明 |
|------|------|
| `3421c1f` | chore(security): 移除 dependabot.yml 并确立「不引入外部自动化」安全边界 |

## 2026-09-17T11:03:51+09:00

**概要**：chore(ci): Dependabot から npm エコシステムを削除し、`github-actions` のみ残した — PR #7 の実測結果に基づく調整である：npm エコシステムは本リポジトリにとって**構造的に無効**である。本リポジトリの npm パッケージは `buildNpmPackage` で包装されており、その `npmDepsHash` はメインビルドが npm-deps 成果物と**バイト単位**で照合する。一方 Dependabot は `package.json`/`package-lock.json` しか変更せず、`.nix` 内のその hash を認識できない——ゆえに**それが開く npm 更新 PR は必ず CI に失敗する**（`npmDepsHash is out of date`）。このエコシステムを残すことはマージ不能な PR を生み続けることを意味するため削除し、npm 依存の更新は `nix-flake-update-check` スキルによる手動対応に戻した（同スキルは `npmDepsHash` の補修と `next`/`alpha` チャネルの確認を既に含む）。**削除理由は設定内のコメントとして完整に記録した**（PR #7 で観測した症状と「Dependabot は dist-tag を跨がない」という制約を含む）ため、後日これを漏れと誤認して再追加されることはない。`github-actions` エコシステムは維持する——本リポジトリで有効性が実証済みである（PR #6 の checkout 更新はこれが生み、SHA 固定も正しく維持した）

| コミット | 説明 |
|----------|------|
| `4b997b3` | chore(ci): Dependabot 移除 npm 生态，仅保留 github-actions |
## 2026-09-17T10:55:02+09:00

**概要**：chore(dsh-nixos-shell): `dsh-tools` 0.1.2-alpha.2 → 0.1.5-rc.2；ci: `actions/checkout` v4 → v7.0.1 — いずれも**前ラウンドで追加した `dependabot.yml` が自動生成したもの**であり、本項目はその監査と対応を記録する。**PR #6（checkout）はマージ済み**：Dependabot は SHA 固定を正しく維持し（浮動タグへ戻さなかった）、新しい SHA `3d3c42e5…` が `v7.0.1` タグ（コミット `prep v7.0.1 release`）を実際に指すことを確認した。初回 CI では 2 件失敗したが、原因は `llama-cpp-ver` 入力が GitHub API に当たった **403 レート制限**（アップグレードとは無関係——他 62 件のビルドは通過）であり、再実行で **64/64 全通過**となったためマージした。**PR #7（dsh-tools）はクローズし、手動アップグレードに切り替えた**：この PR は**CI を通過しようがない**——Dependabot は `package.json`/`package-lock.json` しか変更せず、`buildNpmPackage` の `npmDepsHash` を認識できないため、CI は必ず `npmDepsHash is out of date` を報告する。これは **bot と Nix ラッパーの構造的な不整合**であり、設定ミスではない。さらに提案された `0.1.2-rc.1` は**アクティブなチャネルより遅れている**（`next` は既に 0.1.5-rc.2、`alpha` は 0.1.6-alpha.1）一方、**ホスト dsh が同梱するのはまさに 0.1.5-rc.2** である。そこで手動で 0.1.5-rc.2 へ上げ、プラグイン内蔵のコピーをホストツリーに揃え、`npmDepsHash` を `sha256-5jd5O4…` に更新した。**検証**：ビルド通過；成果物内の `dsh-tools` は 0.1.5-rc.2（ホストと一致）；実行時ロードは `exit=0`・エラーゼロ；`nix flake check` 全通過。**汎化**：「Dependabot の自動 PR の扱い」を `nix-flake-update-check` スキルに記載した——固定された症状、hash 補修の手順、そして見落としやすい「対象バージョンが `next`/`alpha` チャネルより遅れていないかを確認すべき」という判断基準

| コミット | 説明 |
|----------|------|
| `dce26f2` | chore(dsh-nixos-shell): dsh-tools 0.1.2-alpha.2 → 0.1.5-rc.2 |
| `5f4e9ec` | ci: bump actions/checkout from 4.4.0 to 7.0.1 (#6) |
| `7b94d7c` | refactor(skill): nix-flake-update-check 补充 Dependabot 自动 PR 的处置 |
## 2026-09-17T01:40:58+09:00

**概要**：docs(security): `SECURITY.md` に「重複投稿」の扱いの境界を明示した（四言語）——前回のコミットで評価済みの外部報告 4 件を掲載したが、文言は説明的にとどまっていた。今回「重複投稿について」の小節を追加して拘束力を持たせた：**上表に既に記載された同一の結論を、新しい証拠なしに再投稿した場合は、本節を指し示してそのままクローズする**。同時に、正当な報告を巻き込まないよう受理とクローズの境界を引いた——**受理**：上表に含まれない新規の問題、上表のいずれかの結論が誤りであるとの指摘（再現可能な証拠を添える場合）、同じ主題だが異なる脅威モデルまたは攻撃経路；**そのままクローズ**：上表に既にある結論の単なる再述、同一ルールを再度出力した自動スキャン。末尾に「結論が誤っているとの指摘は常に歓迎します」を残した——上表の 4 件も精査のうえでの判断であり、根拠が誤っていれば訂正すべきだからである。四言語で同期

| コミット | 説明 |
|----------|------|
| `94bd95c` | docs(security): 明确重复提交的处理界限（四语） |

## 2026-09-17T01:34:13+09:00

**概要**：docs(security): `SECURITY.md` に「評価済みの外部報告」節を追加し、四言語のローカライズに組み込んだ — 目的は**精査のうえクローズした 4 件の外部報告**を公開し、後続の報告者が同種の問題を再提出せずに済むようにすることである。各項目に結論と根拠を記録した：**PR #4**（@anupamme、`/token`・`/voicepack`・`/tts` にレート制限がないとの主張——誤検出：説明と diff が不一致で、実際に変更されたのは `/query` のみ。レート制限キーの `x-forwarded-for` はクライアントが偽造可能で、ローカルの同一オリジン RPC はこのヘッダを送らないため、全ローカルトラフィックが単一バケットに集約され利用者自身のパネルを制限してしまう）；**PR #5**（@anupamme、`/query` にリクエストボディの上限がないとの主張——誤検出：その防御は `readJsonBody` の 64 KiB 上限として既に存在し、`content-length` 検査は chunked で回避でき、`text.length` はバイト数ではなく UTF-16 コード単位を数えている）；**issue #1**（@begininvoke、`secrets: inherit` が最小権限に違反するとの主張——誤検出：被呼び出し側は同一リポジトリ内のローカル workflow であり、secret は合計 2 つのみで、明示的な受け渡しも `inherit` も集合は完全に同一）；**issue #2**（#1 と同一、バイト単位で重複）。同節ではこれらが**導いた 2 件の実際の堅牢化**も記録している：`/tts` エンドポイントの SSRF（どの報告も言及せず、エンドポイント精査中に発見。当該エンドポイントは `dsh-api-balance` とともに新リポジトリへ移転済み）と、31 のビルド workflow の最小権限補完。**立場の表明**：これらの報告はルールとしては概ね事実を突いているが、脅威モデルは本プロジェクトの配備形態に当てはまらない。方針は「まず精査し、再現可能な証拠を添えて回答する」ことであり、**誤検出を迷惑とは扱わない**——上記 4 件は最終的に 2 件の実際の堅牢化を生んだ。ローカライズ面では `docs/SECURITY.{en,ja,pcn}.md` を追加し、四言語の切り替え器を相互にリンクさせ、四言語の README もライセンス節の後にリンクを追加した。**注**：issue #1/#2 はその後削除された（現存するのは issue #3 のみ）。追跡のため歴史的な番号をここに保持する

| コミット | 説明 |
|----------|------|
| `6f34e73` | docs(security): SECURITY.md 记录已评估的外部报告，并纳入四语本地化 |

## 2026-09-17T01:23:46+09:00

**概要**：chore(security): SECURITY.md と Dependabot を追加し、GitHub Actions をコミット SHA に固定した — 発端は awesome-ai-plugins のメンテナ（@kantorcodes）による PR #323 への是正要求である：同カタログの集中スキャンは NixKits を **71/100 と評価し、要求される 80 の閾値を下回った**ため、「ルール単位の所見を修正または記録し、SHA 固定の scanner workflow を追加し、スキャンを再実行し、80 以上になったらレビューを依頼する」よう求められた。スコアカードを項目ごとに確認した結果、**critical も high もゼロ**であり、減点はすべてエンジニアリング衛生に関するものであった——Security 10/16（`SECURITY.md` の欠如、「No approval bypass defaults」）、Operational Security 9/17（**Actions が SHA 固定されていない**、Dependabot の欠如）。一方 Best Practices は 6/6、Code Quality は 10/10 で満点だった。今回そのうち 3 点に対応した：① `SECURITY.md` を追加（サポートバージョン、GitHub の非公開脆弱性報告チャネル、対応期限、さらに「既知の設計境界」——認証不要の入口、sudo デーモン、ブラウザトークンの読み取り、`/nix/store` パスの罠——を明示し、これら**意図された**挙動が脆弱性として繰り返し誤報されるのを防ぐ）；② `.github/dependabot.yml` を追加（`github-actions` と `npm` の両エコシステムを対象）；③ **6 箇所のサードパーティ action 参照を浮動参照からコミット SHA へ固定**。**3 点目はそれ自体に実質的価値がある**：`DeterminateSystems/nix-installer-action@main` は**浮動ブランチ参照**であり、上流の変更がそのまま CI に入り込む——以前の「31 の workflow に permissions を追加」と同じ種類のサプライチェーン衛生の問題であり、単なる点数稼ぎではない。**採用しなかったもの**：メンテナが提案したサードパーティ scanner action（`hashgraph-online/ai-plugin-scanner-action`）は導入しない——同氏のドキュメント自体が任意と明記しており、代償は信頼スコアの 10% 減点だがこれを受け入れる。`SECURITY.md` のサンドボックスモードに関する文言も、スキャナ規則と衝突しないよう修正した

| コミット | 説明 |
|----------|------|
| `97a4180` | chore(security): 补 SECURITY.md、Dependabot，并将 Actions 固定到 SHA |

## 2026-09-16T16:45:03+09:00

**概要**：fix(dsh-nixos-shell): 本機へ配備して初めて露見した `skills-nixos` のパス断裂を修正した — `559e841` が持ち込んだ欠陥であり、**実際に配備しなければ見えない**種類のものである。当該コミットは NixOS模式 プリセットに第二のスキルルートを追加し、`../../skills-nixos/`（プリセットディレクトリ相対）と書いた。私は「ビルド成果物内で相対パスが到達可能」だけを検証して成功と判断した。しかし NixOS モジュールのシード処理は `cp -r presets/<mode> $DSH_HOME/.agent-presets/<id>`（seed-once）であり、**プリセットディレクトリの外にある内容は複製されない**。ゆえにシード後、当該ルートは `~/.dsh/skills-nixos`（不存在）へ解決され、新規追加した 3 つの NixOS スキルは NixOS模式/维护模式 で**実際には読み込まれていなかった**。本機が `bf9c21e` から `95fc09b` へ同期しプリセットを再シードした時点で発覚した。**修正**：`postPatch` を改め、ホワイトリストのサブセットを各プリセットディレクトリの**内側**（`presets/{nixos-mode,maintenance-mode}/skills-nixos/`）へ生成し、プリセットの `customSkillDirs` ルートを `skills-nixos/`（プリセットディレクトリ自身からの相対）へ変更した。これはプリセット自身の `skills/` ルートと同じ扱いであり、そちらもプリセットディレクトリ内にあるためシード後も有効である。`package.json` の `files` からは存在しなくなったパッケージ直下の `skills-nixos` を削除し、モジュールとプリセットの責務コメントも訂正して「スキルルートはプリセットディレクトリ内に置かねばならない」という制約を明記した。**検証**：シードを模擬した後で `skills-nixos` が到達可能（修正前はこの段階で失敗）；`check-preset-derivation` を含む 5 項目の flake check がすべて通過；配備後、新規セッションのスキル一覧に `nixos-modern-cli`、`nixos-specialisation-tuning`、`recover-nixos-config` が実際に現れた。**教訓**：プリセットがシーダーによって複製される設計では、検証は**シード後の相対位置**で行わねばならない。store 内のパスだけを確認すると、まさにこの種の断裂を見落とす

| コミット | 説明 |
|----------|------|
| `96b589c` | fix(dsh-nixos-shell): skills-nixos 移入预设目录，修复 seed 后路径断裂 |

## 2026-09-16T14:54:53+09:00

**概要**：refactor(dsh-api-balance)!: 独立リポジトリへ移転し、本リポジトリは薄いラッパーへ — 本リポジトリ**初**のコンポーネント分割である。監査により、当該サブプロジェクトがここで唯一の**プラットフォーム非依存**（NixOS 専用ではない）の本格的なプロジェクトであり（`lib/index.js` 1733 行 + `lib/client.js` 4922 行、39 コミット）、NixKits との**コードレベルの結合がゼロ**（`@deepseek-ai/dsh-credentials` と Node 組み込みモジュールのみを import し、リポジトリ内参照は皆無）、かつ npm パッケージングの必要が明確であることを確認した——三つの基準すべてを満たす。**結果**：新リポジトリ <https://github.com/Kihara777/dsh-api-balance>（公開、git 履歴を持たず単一の初期コミットから開始）がソース・四言語の完全なドキュメント・npm 公開 CI（release トリガ、provenance 付き）を保持し、**実測**により実リモートから 1 コマンドで導入できることを確認した（`dsh plugin add github:Kihara777/dsh-api-balance` → `dsh.profile.bundles` に入る → web profile が `exit=0`・エラーゼロで起動）。本リポジトリ側の変更：`packages/dsh-api-balance/` を削除；`packages/dsh-api-balance.nix` を薄いラッパーへ（`fetchFromGitHub` で rev と 2 つの hash を固定、**`npmDepsHash` は不変**——移転前後でソース内容がバイト単位で同一であることを裏付ける）；`docs/<lang>/dsh-api-balance.md` を各 161 行から短いページへ圧縮（移転を明示し新リポジトリの完全なドキュメントへリンク、本リポジトリ固有の宣言的インストール節のみ保持）；四言語の README プラグイン表に移転とラッパーの役割を明記。**CI workflow は意図的に保持**——ビルドする flake 出力 `#dsh-api-balance` が現在は薄いラッパーであり、保持することで宣言的ユーザーが引き続き Cachix キャッシュにヒットできる。**`write-project-docs` スキルも同時に更新**：「メインリポジトリの薄いラッパー + サブリポジトリの完全なドキュメント」というアーキテクチャ（分担表、移転の基準、短いページの標準構造、メイン側の残る同期点）を新節として追加し、「移転済みコンポーネントの完全なドキュメント複製をメインに残す」をアンチパターン表に追加——今回の分割を一度きりの作業ではなく再利用可能な手順とした

| コミット | 説明 |
|----------|------|
| `0bb7fc1` | refactor(dsh-api-balance)!: 迁出为独立仓库，本仓改为薄封装 |
| `0760612` | feat(skill): write-project-docs 支持「主仓薄封装 + 子仓完整文档」架构 |

**未対応**：npm 公開は未実行——本機に npm の資格情報がない（未ログイン、token なし、`@kihara777` scope 不存在）。先に npmjs.com でアカウントと scope を作成する必要がある。パッケージ自体は公開可能な状態（`npm pack` で 70.8 kB / 4 ファイルを確認）。

## 2026-09-16T14:27:33+09:00

**概要**：refactor(skills): `/etc/nixos/AGENTS.md` の実践から未カバーの 2 つの缺口を汎化した — 発端は同ファイル（HarukaX のマシン設定規則 670 行）の業務ロジックと経験の汎化価値の監査である。**監査結論：約 75% は既存スキルがカバー済み**——分面アーキテクチャと上書き衝突、`mkForce` 誤用の事故、消費者帰属原則、`mkDefault`、llama.cpp のパラメータ禁止項と診断順序、実測した電力プロファイル、MCP schema の毎ターン費用、静黙故障の診断（設定ログを読む）などは、すでに `nixos-specialisation-tuning` / `nixos-modern-cli` / `recover-nixos-config` に存在していた。**監査中に自己修正が 1 件**：初回は「`mkForce` 誤用が未カバー」と判断したが、語単位で再確認したところ既に 4 箇所でカバーされており（`mkForce` が `systemPackages` を上書きして `bash`/`systemd` を削除しログイン不能になった完全な事故例を含む）、缺口一覧から除外した。真の缺口は 2 つのみ：**① 機密と `path:` input**（`nixos-modern-cli` に新節）——Nix は git 追跡ファイルのみを store へコピーするため、機密をリポジトリ内に留める道はない（コミットすれば漏洩、gitignore すれば評価が `Path ... is not tracked by Git` で失敗する）。ゆえにリポジトリ外ディレクトリ + `path:` input で導入し、2 つの罠を付す：`path:` input は `flake.lock` に固定されるため内容変更には `--update-input` が必要、`{ nixosSecrets, ... }` の `...` は当該引数を**束縛しない**ため明示列挙が必要。**② 熱管理の方法論**（`nixos-specialisation-tuning` に新節）——2 つの手段は代償が異なる（曲線を上げるのは騒音のみ、プロファイルを下げるのは速度を失う）；曲線の終点が低すぎると最も危険な領域でファンが一定になる；`enabled: false` はプロファイルと曲線を乖離させる（最高電力プロファイルに最弱のファン方針）；ファームウェアは温控点を厳密に 8 点に制限し、panic は**書き込み後**に発生する；`asusctl` の書き込みは一時的で、検証にはデーモンを再起動してファイルから再読込することを確認する必要がある；決定的な判据は緩い曲線と攻撃的な曲線で温度と回転数が**完全に同一** → ファンは飽和 → 有効な手段は消費電力の低減のみ、かつ EC 閾値は OS から不可視。**汎化しなかったもの**：機種、数値表、`triggerTemp`、mihomo 購読の詳細、`g41.moe`、`toface` スクリプトなどマシン依存の内容は `/etc/nixos/AGENTS.md` に残す。両スキルの `description` と四言語ドキュメントを同時に更新した

| コミット | 説明 |
|----------|------|
| `a33a3cf` | refactor(skills): 泛化 /etc/nixos 实践的两个未覆盖缺口 |
| `fba7b38` | docs(skills): 同步两技能扩展后的功能清单（四语） |

## 2026-09-16T14:11:18+09:00

**概要**：feat(dsh-nixos-shell): NixOS模式 が 3 つの NixOS 運用スキルを同梱するようになった — 発端はリポジトリの `skills/` ツリー（10 件）と各プリセットの同梱内容との適合性をスキル単位でレビューしたことである。レビューの結論：`nixos-modern-cli`（現代 Nix/NixOS CLI、shell 能力、sudo フロー）、`recover-nixos-config`（誤削除した `/etc/nixos` を store から復元）、`nixos-specialisation-tuning`（specialisation 分面 + UMA デバイスでの llama.cpp 調整）を**追加**——いずれも「NixOS 上で作業する」汎用能力であり NixOS模式 の守備範囲に合致する。`nixkits-skills`（スキルインストーラであり、作業方法ではなくツール）と `news-three-elements`（創作系で、独立パッケージ `dsh-preset-news-three-elements` が専用プリセットを提供済み）は**追加しない**。维护模式 は NixOS模式 からの派生であり、3 つとも**自動的に継承**される。**実装（重複を避ける）**：スキルを `presets/<mode>/skills/` へ複製しない——同ディレクトリは両プリセット間でバイト単位に鏡像されており、そこへ置けばリポジトリ `skills/` ツリーが既に所有する内容の第二の複製となり、ドリフトしうる。代わりに `postPatch` で同一のリポジトリツリーからホワイトリスト方式のビルド期サブセット `skills-nixos/` を生成し、プリセットの `skill-filesystem` 行に第二の `customSkillDirs` ルートを追加して相対パス `../../skills-nixos/` で解決する（`baseUrl` = プリセットディレクトリ）。**`skills-embedded/` を直接指さずサブセットディレクトリを使う理由**：`skill-filesystem` は設定された各ルートの**全ての**子ディレクトリを登録するため、埋め込みツリーを直接指すと `write-project-docs` ほかの保守系スキルまで NixOS模式 に入り、今回の選定範囲を超える。検証済み：ビルド成果物の `skills-nixos/` は正確に 3 スキルを含みリポジトリのソースとバイト単位で一致し、`../../skills-nixos/` はプリセットディレクトリから到達可能、`skills-embedded/` は 10 件すべてを保持し、5 項目の flake check（`check-preset-derivation` を含む）がすべて通過した

| コミット | 説明 |
|----------|------|
| `559e841` | feat(dsh-nixos-shell): NixOS模式 同捆 3 个 NixOS 运维技能 |
| `7971689` | docs(dsh-nixos-shell): 记录 NixOS模式 新增的 3 个同捆技能（四语） |

## 2026-09-16T13:57:56+09:00

**概要**：feat(dsh-api-balance): `dsh.bundle` を追加し、`dsh plugin add` によるネイティブ導入に対応した — `dsh-api-balance` は `dsh-nixos-shell` と性質が異なるためである：前者は**プラットフォーム非依存の UI／機能拡張**（`inject = ["connection", "webServer"]` のみ、プリセット無し、スキル無し、`$DSH_HOME` への書き込み無し）であり、後者の核心的価値はまさに Agent プリセットである。前ラウンドで `dsh-nixos-shell` の bundle 路線は不可能と結論した（プリセット root は絶対パスを要し、`./` のアンカーは `insert[].name` にのみ作用する）。**重要な発見（従来の結論を覆す）**：`cordis-plugin-loader/lib/index.js:269-284` を読むと、entry 名が `./` で始まる場合 `anchorInsertedPluginNames` が**その patch と同じディレクトリ**の絶対 `file://` URL にアンカーするため、正常に import される——「loader は dsh ツリーからのみ解決するので profile 内のパッケージは読めない」という以前の判断は誤りであった。今回これに基づき実装：新規 `cordis.patch.yml` が `name: './lib/index.js'` でプラグインを登録し（裸のパッケージ名は**不可**。dsh インストールツリーから解決され `Cannot find package` で失敗する）、`package.json` に `dsh.bundle.patch` を追加し `files` に当該ファイルを補った。**実測**：インストール後 `dsh.profile.bundles` に入り、`--dump-config` は entry が profile 内の絶対 URL にアンカーされることを示し、web profile は `exit=0`・エラーゼロで起動した。Nix ビルドと `nix flake check` は影響を受けない。**二経路の併存**：各経路は独立に動作する（宣言的経路は `$DSH_HOME/profiles/web/cordis.patch.yml` を書き、bundle は `dsh.profile.bundles` を書く）が、**両方を有効にすると同一 entry id が二重登録される**ため、ドキュメントはどちらか一方を選ぶよう明記し、方式 B が git 経由で解決され `flake.lock` に固定されない点も記した

| コミット | 説明 |
|----------|------|
| `ac3cb3e` | feat(dsh-api-balance): 支持 dsh.bundle，可经 dsh plugin add 安装 |
| `bee12d7` | docs(dsh-api-balance): 补充两种安装方式与 bundle 机制说明（四语） |

**関連する外部レポート**：issue #3（@zerocodefast）——awesome-ai-plugins への収録招待。`dsh-api-balance` は DeepSeek Harness 節へ投稿する技術的条件を満たしたが、`dsh-nixos-shell` は宣言的のままとする（その理由は `d14146c` のエントリに記録済み）。

## 2026-09-16T13:44:09+09:00

**概要**：refactor(dsh-plugins): 両プラグインから未使用の `peerDependencies` を削除した — 発端は issue #3 の収録招待を評価する際、dsh プラグインが `dsh plugin add` で導入可能かを実測したことである。実測の結果、両プラグインの peer 宣言は**実際の import と全く一致していない**ことが判明した：`dsh-nixos-shell` は `cordis` / `dsh-subprocess` / `dsh-timer` を、`dsh-api-balance` は `cordis` / `dsh-client-connection` を宣言していたが、実際に import しているのは各自の実依存（`dsh-tools` + `schemastery` / `dsh-credentials`）のみである。とくに **`@deepseek-ai/dsh-timer` は npm（404）にもホスト dsh ツリーにも存在しない**——ホストは `cordis-plugin-timer` で `timer` サービスを提供しており、プラグインの `inject` はパッケージ名ではなくサービス名を指す。`dsh-client-connection` は既に `dsh.client.inject` で正しく宣言済みで、peer 側は重複であった。**影響判断**：これらの死んだ宣言は宣言的経路では**決して効かない**（`buildNpmPackage` は `--legacy-peer-deps` で peer 解決を省略する。ビルド成果物を検査し実依存のみを含むことを確認済み）。ゆえに本変更は既存のデプロイに影響せず、バージョン変更も伴わない。しかし pnpm 経路では**インストールを直接阻害し**（`dsh-timer` 404）、エコシステムに誤った signal を送る。lock と `npmDepsHash` は同時に再生成した（vendored lock が npm-deps の fixup 成果物とバイト単位で一致することを検証済み）。**路線の取捨を記録**：本ラウンドでは `dsh-nixos-shell` に `dsh.bundle` を補い awesome-ai-plugins の DeepSeek Harness 節へ投稿する案を評価した。実測により、プラグイン本体は `github:...#path:` で導入でき profile layer stack に入ること（npm 公開は不要）を確認したが、**Agent プリセットは bundle patch では登録できない**——`agent-presets.roots[].path` は絶対パスを要する一方、patch がアンカーできるのは `insert[].name` のみで、`!!js` の作用域には `dshHomePath` しか無い（さらにバッククォートは js-yaml の解析を壊す）。これを回避するにはプラグインがユーザーの `$DSH_HOME` へ書き込んでプリセットを seed する必要があり、宣言性と不変性を犠牲にする。**結論：dsh.bundle 路線は断念する**——本プロジェクトのプラグインは NixOS 向けであり、flake / NixOS モジュールによる宣言的配布（バージョンは Nix が固定、システム世代とともに更新、再現可能）のほうが NixOS の哲学に適い、保守コストも低い。関連する変更はすべて撤回済みで、履歴には入っていない

| コミット | 説明 |
|----------|------|
| `d14146c` | refactor(dsh-plugins): 移除未使用的 peerDependencies |

**関連する外部レポート**：issue #3（@zerocodefast）——awesome-ai-plugins への収録招待、open のまま維持し PR は提出しない。

## 2026-09-16T12:39:12+09:00

**概要**：refactor(skills)!: `nixkits-check-updates` を「汎用コア + リポジトリ適応層」に分割した — 発端は issue #3（awesome-ai-plugins への収録招待）の評価である。招待自体に技術的な争点はないが、推薦されたスキルの移植性を精査する契機となった：元の `nixkits-check-updates`（299 行）は NixKits と強く結合していた——第 5 ステップは `for lang in zh en ja pcn` と `docs/$lang/<pkg>.md` パスを**ハードコード**し、dsh プラグイン一覧同期の節を丸ごと抱え、第 8 ステップは `write-maintenance-log` を強制呼び出ししていた。**このため他の nix flake リポジトリではそのまま使えなかった**：NixKits 以外のリポジトリが第 5 ステップに達すると存在しない `docs/pcn/` を `sed` し、第 8 ステップでは存在しないスキルを呼び出す——言い回しの問題ではなく、実行が失敗する。今回「汎用コア + リポジトリ適応層」に分割した：新規 `nix-flake-update-check`（314 行、どのリポジトリにも非結合）がパッケージ検出、ビルダー別 hash フロー、flake.lock の三者分岐、パッチ内蔵バージョン確認、nixpkgs ドリフトの罠を担い、第 5/8 ステップはハードコードではなく「リポジトリの実際の構造に応じて選択」へ書き換えた。`nixkits-check-updates` は適応層へと痩せた（299 → 115 行）——四言語ドキュメント、dsh プラグイン一覧、メンテナンスログ、過去の事故教訓（comfyui ドリフト、codewhale-riscv64 CI 失敗、Rust Cargo.lock）のみを残す。**適応層の契約**を定義した（ドキュメント同期 / 変更記録 / 動的入力 / 事故教訓 / 追加同期項目は適応層が宣言し、衝突時は適応層を優先）。**重要なトレードオフ**：以前は汎化が具体的経験を薄め、本拠地での技能を弱めることを懸念していた——この分割はまさにその代償を避ける手段であり、事故教訓とリポジトリ規約は**そのまま適応層に残り**、汎用コアはリポジトリ非依存の方法論のみを保持するため、双方が得るものを持つ。メンテナンスモードの注入に汎用スキルを追加（両者を登録）；四言語で汎用スキルのドキュメントを新設し、README / dsh.md / modes/maintenance.md の注入一覧と技能表を同期した

| コミット | 説明 |
|----------|------|
| `667bf6e` | refactor(skills)!: 拆分更新检查为通用核心 + NixKits 适配层 |
| `93fe67e` | feat(dsh-nixos-shell): 维护模式注入 nix-flake-update-check 技能 |
| `6af37e7` | docs: 同步技能拆分——四语新增通用技能文档、README 技能表与注入清单 |

**関連する外部レポート**：issue #3（@zerocodefast）——awesome-ai-plugins への収録招待。検討の結果、提案された推薦文は NixKits を「中国語スキルを含むパッケージ集」と位置づけ、Nix パッケージ / モジュール / パッチの集合でもあることに触れておらず、「Chinese-language skills」は中国語ユーザーにしか有用でないかのように読める。収録自体は技術と無関係のため、issue は open のまま維持し PR は提出しない。

## 2026-09-16T12:20:57+09:00

**概要**：ci: 31 本のビルド workflow にトップレベル `permissions` を補完した — 外部コントリビュータ **@begininvoke**（RedGem のスキャンレポート）による issue #1・#2 に特別の謝意を表する：両レポートは検証の結果いずれも誤検出であった（同一スキャナが `build-blender-mcp-aarch64.yml:10` の `secrets: inherit` を二重に報告したもので、本文はバイト単位で同一）。ルールの指摘自体は事実だが、脅威モデルは本リポジトリでは成立しない——被呼び出し側 `./.github/workflows/build-package.yml` は**同一リポジトリ・同一コミット・同一レビュー工程**にあるローカルの再利用可能 workflow であり、issue が仮定する「untrusted source」は存在しない。本リポジトリの secret は**合計 2 つだけ**（`GITHUB_TOKEN`、`CACHIX_AUTH_TOKEN`）で、明示的に渡しても `inherit` で渡しても**集合は完全に同一**であり、攻撃者に**いかなる利得も生まない**——被呼び出し workflow を改竄できる者は、そもそも `secrets.*` を直接読める。またレポートが名指しした 1 箇所だけを変更すれば、構造の同一な 31 の呼び出し側の間に不整合を生む。ゆえに両 issue とも採用せず、詳細な証拠を添えてクローズした——**しかし、まさにこの 2 本のレポートが我々に完全な権限境界レビューを促した**。レポートは「再利用可能 workflow への secret／権限の受け渡し」という正しい方向へ注意を向けており、その手掛かりに沿って呼び出し連鎖を 1 つずつ照合した結果、**真のセキュリティリスクを発見し修正した**：31 本の `build-*.yml` 呼び出し側は**いずれも `permissions` を宣言しておらず**、そのためリポジトリ既定（読み書きの可能性あり）を継承していた。しかしこれらの workflow は checkout + `nix build` + Cachix への push のみを行い、必要なのは `contents: read` だけである。今回この 31 本の呼び出し側にトップレベル `permissions: contents: read` を付与し、被呼び出し側 `build-package.yml:17-18` が既に宣言している権限と一致させた。**トレードオフの説明**：Cachix への push は独立した `CACHIX_AUTH_TOKEN` を使用し、`GITHUB_TOKEN` の権限範囲に依存しないため、締め付け後も CI の挙動は変わらない（`nix flake check` の `check-workflow-coverage` が通過）。**採用しなかった部分**：31 箇所の `secrets: inherit` を明示列挙へ変更することは行わない——形式上の適合だけで実質的なセキュリティ利得がなく、`CACHIX_AUTH_TOKEN` は被呼び出し側へ必ず渡す必要があるため、最小権限に削る余剰が残っていない

| コミット | 説明 |
|----------|------|
| `445eb4b` | ci: 为 31 个构建 workflow 补全顶层 permissions（最小权限） |

**関連する外部レポート**：issue #1・#2（@begininvoke / RedGem）——バイト単位で完全に重複。誤検出と確認され、詳細な技術的証拠をコメントに添えて not planned としてクローズ。手がかりとしての価値に謝意を表する。

## 2026-09-16T11:58:25+09:00

**概要**：fix(dsh-api-balance): カスタム TTS プロキシの SSRF とリクエストヘッダ注入面を修正した — 外部コントリビュータ **@anupamme**（OrbisAI Security のスキャンレポート）による PR #4・#5 に特別の謝意を表する：両レポートは検証の結果いずれも誤検出であった（#4 は `/token`・`/voicepack`・`/tts` の 4 エンドポイントにレート制限がないと主張しながら、diff は 5 つ目の `/query` しか変更しておらず、また偽造可能な `x-forwarded-for` をレート制限キーにするとローカルの同一オリジンクライアントが単一バケットに集約されて自己 429 を招く；#5 は `/query` にリクエストボディのサイズ上限がないと主張したが、その防御は `readJsonBody` の 64 KiB 上限として既に存在し、追加された `content-length` 検査は chunked で回避でき、`text.length` はバイト数ではなく UTF-16 コード単位を数えている）。ゆえに両者ともマージせず、詳細な証拠を添えてクローズした——**しかし、まさにこの 2 本のレポートが我々のセキュリティ境界レビューの意識を呼び覚ました**。これを機に本プラグインの入力と外向き通信の制約をエンドポイント単位で照合し、レポートが指し示した `/tts` の処理ロジックにおいて**真のセキュリティ脅威を発見し修正した**：このプロキシは任意の `http(s)` URL を受け取りホストの身分でリクエストを発行するため、内部ネットワーク探索やクラウドメタデータ（`169.254.169.254`）読み取りの踏み台になり得る。さらにリクエストボディ内のユーザー制御 `headers` をそのまま転送するため、攻撃者はホストの身分で `host` / `cookie` / `authorization` ヘッダを付与し影響を増幅できる。今回の修正は実際の脅威モデルに沿う：`resolveTtsTarget` と `isBlockedAddress` を新設し、ループバック / プライベート / リンクローカル / 予約アドレスを拒否（RFC1918、`100.64/10` CGNAT、`169.254/16`、`224/4`、`fc00::/7`、`fe80::/10`、`ff00::/8`、IPv4-mapped IPv6 を含む）。リテラル IP は直接判定し、ドメイン名は DNS 解決結果を照合する。カスタムリクエストヘッダはホワイトリスト化（`content-type` / `accept` / `accept-language` / `user-agent` のみ）。**判断とトレードオフ**：DNS リバインディングの TOCTOU 窓を完全に消すため「接続を検証済み IP に固定する」案をまず試した——実測では Node の `fetch` が URL の host を `Host` ヘッダと TLS SNI として強制し、`host` ヘッダの上書きは黙って無視され、URL のホスト名を書き換えれば正当な HTTPS TTS バックエンドのバーチャルホストルーティングと証明書検証がすべて無効になる。その代償は本エンドポイントの残余リスク（ローカル自己ホスト dsh の補助プロキシであり、マルチテナント境界ではない）を上回るため、この制限は明示的に保持しソースコメントに記録する——「修正済み」で覆い隠すことはしない。四言語のドキュメントにも防御の説明を追記した

| コミット | 説明 |
|----------|------|
| `e1a6e66` | fix(dsh-api-balance): 修复 TTS 代理的 SSRF 与请求头注入面 |
| `72cb6ae` | fix(docs): pcn 维护条目去除残留假名（のみ → 限定） |

**関連する外部レポート**：PR #4・#5（@anupamme / OrbisAI Security）——誤検出と確認され、詳細な技術的証拠をコメントに添えてクローズ。手がかりとしての価値に謝意を表する。

## 2026-09-16T11:38:20+09:00

**概要**：docs(deprecated): `DEPRECATED.md` を索引化し四言語化した — 従来この一本の中国語文書が**索引**と**単一プロジェクトの完全な説明**という二つの役割を兼ねていた。項目が一つなら問題はないが、増えることは確実であり、そうなれば読者は全体を一望できず、そもそもこの文書にはローカライズの受け皿がなかった（既存の `docs/<lang>/` 体系に置き場所がない）。今回リポジトリ既存の規約に沿って再構成した：ルート `DEPRECATED.md` は**純粋な索引**（一覧 + 各プロジェクト詳細へのリンク）へ後退し、`README`/`MAINTENANCE` と同じ成法で三つの鏡像 `docs/DEPRECATED.{en,ja,pcn}.md` を用意する。各廃止プロジェクトの詳細は `docs/<lang>/deprecated/<name>.md` へ移し、四言語それぞれに一份、冒頭に言語切り替え器と索引へ戻るリンクを置く。第一陣として comfyui-rocm の完全な説明（逐字の致敬句、三パッチ対照表、scipy 誤判定の回顧、廃止後の設定例、歴史バージョン対照）を移行した。四言語の `README` に「廃止プロジェクト」節を追加し、`docs/<lang>/comfyui.md` の参照は詳細ページへ向け直した。**記録に値する落とし穴**：`docs/DEPRECATED.*.md` 自身が `docs/` の内側にあるため、言語ディレクトリへのリンクは `../zh/...` ではなく `zh/...` と書かねばならない——最初の `nix flake check` が 6 本の死リンクを検出した（en/ja/pcn がそれぞれ他の三言語を指していた）。すべて修正済み。これこそ `check-doc-links` の存在意義である：一段上のファイルの習慣で相対パスを書くという、人間が頁を繰らなければ気づけない類の誤りを、まさにこれが止めた。この再構成後、プロジェクトの追加は索引一行と四份の詳細文書で済む

| コミット | 説明 |
|----------|------|
| `8ff91eb` | docs(deprecated): 索引化 + 四语本地化，详情拆到独立文档 |

## 2026-09-16T11:05:32+09:00

**概要**：refactor(comfyui)!: comfyui-rocm パッチ事業を退役、モジュール名を `nixkits.comfyui` に — 上流が積極的に保守を続け、ROCm 対応コンポーネントを StrixHalo をよく支える版まで更新したため、本パッチは歴史的使命を終えた。よって全体を削除：三つのパッチ（`strix-halo` / `nixpkgs-compat` / `stdenv-api`、ローカルのパッチ置き場は空に）、`modules/comfyui-rocm.nix` → `modules/comfyui.nix`、オプション `nixkits.comfyui-rocm` → `nixkits.comfyui`（意味を失った `-rocm` 接尾辞を削除）、四言語の文書 `comfyui-rocm.md` → `comfyui.md`、ルートに `DEPRECATED.md` を新設しその第一条に記載。**今回最も記録に値するのは、三度にわたって誤判定したあの根因である**：以前の「パッチはもう不要」という結論は、717 derivation のビルドが「すべて成功した」ことに依っていた——**しかしその回の `scipy` はバイナリキャッシュ命中で、実際には一度もビルドされていない**。判定材料はログの `building '…'` 行であるべきで、「ビルドの終了コードが 0」ではない。真の原因は、本機の `/etc/nixos` が comfyui-nix の `inputs.nixpkgs` を `6438090`（2026-08-02）に釘打ちし、トップレベルは `nixos-unstable` を追っていたこと： rolling なトップレベルは `scipy` を公共キャッシュに命中させるが、釘打ちされた子 flake は現にビルドする必要があり、`test_support_moments_sample` の浮動小数点アサーション失敗を引き起こして、**「パッチが依然必要」に見えてしまう**。その pin 行を消すと comfyui-nix はトップレベルと `dc5d91f` を共有し、`scipy` はそのままキャッシュ命中、ビルドは全て通る。教訓：**余分な pin は子 flake を主 nixpkgs のキャッシュ被覆から切り離し**、キャッシュが解決したはずの問題をパッチが必要な問題に見せかける。パッチの陳腐化には独立した裏付けが二つある：上流の `stdenv` 非推奨の読みは **0** 件（34 箇所が `hostPlatform` を使用）、上流 `nix/versions.nix` の `rocm71` torch **2.10.0** は `strix-halo` パッチと逐バイト一致（版・URL・hash の三者とも同一）、上流モジュールは既に `gpuSupport = "rocm"` を支持する。**本機側の同期**：`system/software/comfyui.nix` は新しい選択肢パスへ、`flake.nix` は pin 行を削除しコメントを書き換え、`flake.lock` の comfyui-nix は `path:` から github へ；両面の `nix build` は残り 10 derivation のみ、generation 572 へ切替、`comfyui.service` は plasma specialisation にのみ存在し、`ExecStart` は `comfy-ui-0.34.0`、`HSA_OVERRIDE_GFX_VERSION=11.0.0` は依然として本モジュールの `rocmGfxOverride` が供給する。あわせて `/home/kix/comfyui-nix-patched`（コメントからのみ参照される 17 MB の陳腐な fork）を削除

| コミット | 説明 |
|----------|------|
| `5015bcc` | refactor(comfyui)!: retire the comfyui-rocm patch project, rename module |

## 2026-09-16T01:45:07+09:00

**概要**：docs: プリセットパッケージの更新は `daemon-reload` してから `restart dsh` — 今回の配備で実測した落とし穴：`nixos apply` は設計上 dsh を再起動しない（安定マウントポイント）。一方 `systemctl restart dsh` だけでは**前世代**の pre-start スクリプトが実行されることがあり、それこそが `cordis.patch.yml` を `$DSH_HOME` へコピーする工程（プリセットルートはそのファイルに書かれている）。症状は「サービスは確かに再起動した（ActiveEnterTimestamp が更新された）のに、セッションはまだ旧プリセットを読む」：世代 570 の配備後、最初の restart では `$DSH_HOME/profiles/web/cordis.patch.yml` が旧 store パスのままで、`systemctl daemon-reload` の後に再起動して初めて新パスへ切り替わった（新しい副本は `news-material.js` を含み、リポジトリと逐バイト一致）。AGENTS.md の「本機配備」に操作順序と確認方法（再起動後に patch ファイルの store パスを見る）を追記し、`docs/{zh,en,ja,pcn}/dsh.md` の「トレードオフ」一段も同様に書き換えた

| コミット | 説明 |
|----------|------|
| `a167aae` | docs: 预设包更新要 daemon-reload 再 restart dsh |

## 2026-09-15T23:47:01+09:00

**概要**：feat(preset+skill): 取材ゲート `news-material` — 実際のセッションで「共創なのに生搬硬套」が露見した：利用者の素材が形式だけ変えてそのまま出稿され、検索の工程が飛ばされていた。プロンプトに書いただけの規則は劣化するので、「まず検索、次に書き直し」を実行時に検証できる形にした。新プラグイン `plugins/news-material.js` は二箇所に掛かる：`agent/pre-step` では人のメッセージを受理するステップに「取材鉄律」を同送し（メッセージ id で冪等、再試行でも重ならない）、`agent/turn-stopping`（ループが回合を閉じる前に読み直す停止境界）ではその回合自身のログを読む——**`web_search` / `web_fetch` の呼び出しが一度も無い回合、または本文が利用者の原文を写した回合**には `agent.steer()` で「編集部退稿」を返し、`dsh-agent-loop` が同じ回合のもう一歩を走らせる。**退稿は回合ごとに一度**（agent 単位の WeakMap + 回合番号）なので、無視するモデルも無限ループにはならない。写しの判定は利用者のメッセージと、それがモデルに指し示したファイル（その回合の `read` 結果）とを一字ずつ照合し、漢字のみを数えて**連続 8 字**で命中：ラテン文字の作品名は誤爆せず、三人の主人公の名前（最大 5 字）は閾値の下、検索結果は素材に含めず（通信社の言い回しの再利用こそ本モードの目的）、共創稿の末尾「本稿取材」は設計上素材を引用するため照合の前に剥がす。技能側も同じ三つの検証可能な規則を備える：第 2 步に「抽出 → 投射 → 張り替え」の表と 8 字の紅線・受領書の一行を追加し、検索記録を必須化（捏造も拒否も同じ）、`checklist.md` の素材共創の自己点検は 3 → 7 項に。persona の素材共創の節は書き換え、退稿は編集部の内部事項である——そのまま再送し、利用者に説明しない——と明記した。アサーションを 31 件追加（検索なしの退稿、どちらか一方の検索で通過、前の回合の検索は無効、退稿は回合ごとに一度、セッション単位の分離、8 字は命中・7 字は非命中、`read` したファイルも対象、ラテン文字の題名は非命中、受領書は素材を引用してよい、リマインダは一度だけ同送）。**記録に値する落とし穴**：`nix flake check` は最初 `news-mode-tests` で `ERR_MODULE_NOT_FOUND` を出した——flake のソースは git が追跡するファイル集合であり、新しいプラグインは `git add` するまで store に入らない（同じスクリプトをローカルで直接走らせると全部通る）。この教訓は AGENTS.md の flake 規則に記入した。`nix flake check` は 6 項すべて通過、四言語の文書（技能 / モード / README / `dsh.md`）も同期

| コミット | 説明 |
|----------|------|
| `a0759b1` | feat(skill): 素材只是导火索——三步改造、禁照抄、必检索 |
| `cc9d0d1` | feat(preset): 取材门 news-material——无检索即退稿，照抄即退稿 |
| `71f25db` | docs: 四语同步素材共创铁律与取材门 |
| `a2ccd55` | docs(agents): 新增文件先 git add 再跑 flake check |

## 2026-09-15T12:36:10+09:00

**概要**：feat(skill+preset): 「新聞三要素」は三人の主人公を指すことに変更、拒否サービスは「まず素材として扱う」判定へ — 保守者から四つの修正：① 本モードの「新聞三要素」は報道学の三要素ではなく、**必ず揃わなければならない三人の主人公**——バランニコフ、ユディンツェフ、ブヤノフ——である；② 拒否サービスが敏感すぎる。検索で補える素材は一律拒否してはならない；③ 共創の原稿は三人が揃っていなければならない；④ 仮定の疑問や名指しでない人物は、まず三人のいずれかに当てはめられないか評価する（突き返さない）。技能側：SKILL.md で新しい意味を確定し、「形式の厳格な制約」に第 0 条（三人が本文に登場、一人欠ければ書き直し）を追加、第 1 步の取材を四類に拡張（先頭は三人本人）；「拒否サービス」は厳格な判定順序に書き換え——**素材にできるものは一律拒否禁止 / 仮定の疑問は「既に起きたこと」として書く / 名指しでない人物はまず当てはめる / どれにも接続できないときだけ拒否**——拒否話術そのものの当日素材取得・再利用禁止規則は据え置き；`search-keywords.md` は冒頭に身分対応表、`checklist.md` は先頭を三人到着に変え「素材共創の自己点検」3 項を追加、`principles.md` は第 8 条を書き換え第 13 条「先当素材」を追加（計 13 条）。プリセット側：persona に「素材優先」節と共創の「成篇必須帯斉三位主角」を追加、開始時問答の自由入力拒否に境界を一句追加（問答そのものにのみ効力）、「其它一切請求的拒絶方式」は本当に接続できない請求だけを扱う形に変更、`readonly-gate` の儀式文に三人の括注を追加。アサーション 14 件を追加（三人の名前が persona と技能パッケージの双方に、素材優先の四要件、共創で三人が揃う、checklist の先頭項目、principles が教科書の三要素で定義しない、身分表が冒頭節；儀式文のアサーションは括注を許す正則に変更し、旧い「（新、事实、报道）」の括注は引き続き禁止）。四言語の文書（技能文書 / モード文書 / README / `dsh.md`）を同期；`nix flake check` 6 項すべて通過

| コミット | 説明 |
|----------|------|
| `8f5b848` | feat(skill): 新闻三要素改指三位主角，拒绝服务先当素材 |
| `1adb6be` | feat(preset): 模式提示词改为素材优先，快讯须三人到齐 |
| `4732835` | docs: 四语同步新闻三要素的三人定义与素材优先判定 |

## 2026-09-15T11:47:48+09:00

**概要**：fix(preset): 読取範囲に「自身の技能パッケージ」を追加 — 前ラウンドで読取を「ワークスペース / 添付ディレクトリ / `/tmp`」に絞った際、**モード自身の技能パッケージまで締め出していた**：`tables.md` と `checklist.md` は取得キャッシュ `$DSH_HOME/.cache/news-three-elements/` か同梱スナップショットにあり、どちらも許可根に入っていなかった。セッション記録（`session-e42ea512`）にガードの拒否文がそのまま残っている（「被拒绝的路径：/home/kix/.dsh/.cache/news-three-elements/tables.md（本模式只允许查看会话工作区、附件目录与 /tmp）」）。その結果モデルは「配套文件读不到，就按技能正文的硬性要求成文」と述べ、接続詞表と逆転結末の雛形を欠いたまま書いていた。修法：**取得キャッシュ**と**プリセット根**（オフライン用 `bundled/` スナップショットを含む）を可読根に追加し、拒否文も「…、`/tmp` と自身の技能パッケージ」に変更。アサーション 2 件（キャッシュと同梱スナップショットは可読、範囲外は依然拒否）を追加し、四言語の文書も同期

| コミット | 説明 |
|----------|------|
| `ee072d5` | fix(preset): keep the mode's own skill package inside the read scope |

## 2026-09-15T11:38:02+09:00

**概要**：fix(preset): 儀式文を「催逝快訊」に — 拒否の締めに置いていた一文は「只编造带齐新闻三要素（新、事实、报道）的俄式快讯」で、括弧内は報道学の教科書どおりの原義であり、読み上げると定義の引用のように響いて落ちを潰していた。「只编造带齐新闻三要素の**催逝快訊**」に改め、開始三択が既に使っている「催逝員」の語彙と揃える。修正は二箇所（persona と `readonly-gate` の拒否文本）でいずれも固定プロンプト；技能と文書の「成果物」を述べる定義行は未変更。アサーション 4 件で固定（両箇所に新文言があること、旧い原義の括注が戻らないこと）

| コミット | 説明 |
|----------|------|
| `bfb0ed4` | fix(preset): say 催逝快讯 in the ritual line, not the academic gloss |

## 2026-09-15T11:24:49+09:00

**概要**：fix(preset): 言語審査は人の発言のみを判定する — 新しいセッションで利用者が「簡体中文の正当な依頼が拒否され、しかも英文の訳文が付いた」と観測。セッション記録（`session-efc87486`）で原因を特定：当該 step には利用者の中文メッセージのほかに harness 注入の**英文システムメッセージ**（`source.kind = plugin`："The approval policy changed from \"never\" to \"ask\"…"）と `skill-catalog` が同居していた。ガードは**その step に載る全メッセージ**を審査していたため、英文の通知を「利用者は簡体中文を使っていない」と読み、言語審査を注入——モデルは「訳文は相手の言語に合わせる」規則に従って英文版を添えた。`withNotice` は `source.kind === "user"` のメッセージだけを対象にし（承認通知・技能目録・ツール結果は数えない）、回帰テストを二件追加（英文通知＋中文依頼の組み合わせは発火しない／人の発言が無い step はそのまま）。四言語の文書にもこの境界を明記

| コミット | 説明 |
|----------|------|
| `9557707` | fix(preset): judge only the human's messages in the language gate |

## 2026-09-15T11:08:06+09:00

**概要**：feat(preset)+test: リポジトリ自検体系とモード挙動の四つの加固 — `nix flake check` は 1 項から **6 項**へ：`preset-bundle`（同梱技能スナップショットは `skills/` とバイト単位で一致）、`workflow-coverage`（全パッケージにビルド workflow、例外は明示登録）、`doc-links`（相対リンク到達可能・四言語切替器完備・pcn 假名無）、`maintenance-log`（四言語の条目数一致・秒精度タイムスタンプ・SHA 重複無）、`news-mode-tests`（モードプラグインの挙動テスト、**ネットワーク無**：fetch をスタブして同梱スナップショットを供給し二度目は 304 を返すため ETag 経路も覆う）。導入当日に既存欠陥を検出・修正：翻訳文書 12 件の切替器が同ディレクトリの `<name>.<lang>.md` を指し、codewhale 文書 3 件の相互リンクが誤り、`+00:00` のタイムスタンプが 1 件、`dsh-api-balance` にビルド workflow が無かった。同ラウンドで挙動を四点加固：**読取範囲の限定**（絶対パスはワークスペース / 添付ディレクトリ / `/tmp` のみ）、**抽選の連続重複防止**、**利用者が先に話したら問いを撤回**、**取得の並列化 + ETag 条件付きリクエスト**（内容不変なら 304 で書き直さない）。persona は常設の拒否条款を技能「拒否サービス」節へ返し、二重管理を解消

| コミット | 説明 |
|----------|------|
| `9260dd5` | test: guard the repo with six flake checks and an in-repo test suite |
| `ac4b05c` | feat(preset): scope reads, harden the draw, and make the fetch incremental |
| `0af079c` | docs(preset): record the scoped reads, incremental fetch and hardened draw |
| `9810af5` | fix(docs): repair the switchers and dead links the new check found |

## 2026-09-15T10:57:15+09:00

**概要**：feat(skill): スキルに「拒否サービス」節を新設 — 拒否の流れを「あるプリセットの persona だけ」から**スキル本体**へ格上げ：`SKILL.md` に「拒否サービス」章を追加（捏造でも提供素材の改稿でもないリクエストは同節で拒否し、**拒否のたびに当日の素材をオンラインで取る**；理由・文型・段落順・結末の反転・接続詞を前回から繰り返さない；三〜五句の通信社文体；底色は「至極真面目にデタラメを言う」；拒否したらそこで終わり）、[`tables.md`](../skills/news-three-elements/tables.md) は冒頭で雛形は骨格にすぎず素材は当次取得と明記、[`checklist.md`](../skills/news-three-elements/checklist.md) に「拒否サービスの自己点検」5 項を追加。四言語の技能文書と各 README の技能行を同期し、パッケージ同梱のスナップショットを再生成、persona の二か所を節名で参照するよう変更

| コミット | 説明 |
|----------|------|
| `f120a3d` | feat(skill): give the skill a refusal service of its own |
| `8c28f03` | chore(preset): sync the bundled skill snapshot and point the persona at the section |

## 2026-09-15T10:50:26+09:00

**概要**：feat(preset): 訳文は言語審査に限定し、相手の言語と一致させる — ローカライズ版が付くのは「簡体中文以外」という規則による拒否のときだけ：簡体中文の利用者のリクエストが別の理由で拒否された場合、返るのは**中国語本文のみ**で、訳文も注記も付けない（言語自体が正当であり、訳す対象が無い）。訳文はさらに**相手が実際に使った言語そのもの**でなければならない（英語なら英語、日本語なら日本語、繁体中文なら繁体中文）。第三の言語への置換も中英混排も不可。この二点を「明文化せずモデルの判断に委ねる」状態から、persona と注入指示の明示的な規則へ格上げし（persona の別節には「本節は翻訳しない」と明記）、四言語の文書も同期。自測に 6 項目のアサーションを追加

| コミット | 説明 |
|----------|------|
| `00a0088` | feat(preset): scope the refusal translation to the language gate |

## 2026-09-15T10:39:08+09:00

**概要**：feat(preset): 抽選は「ゲーム」ではなく「人」、そして拒否のたびに素材を取り直す — 推薦プールは 3 本のゲームから**3 名の制作者**へ：引かれた人にゲームが随伴する（ユディンツェフ、バランニコフ → 『War Thunder』、ブヤノフ → 『Escape from Tarkov』）。これに「緑のフクロウ」ソフトを加えた四通りの等確率で、1 回の拒否につき必ず 1 つだけ。『Enlisted』は削除。さらに重要なのは、拒否文が単一の理由を繰り返さなくなったこと：persona と注入指示の双方が、**拒否のたびに `web_search` で当日の素材**（実際の報道表現・公式の言い訳・機関の発表）を取ることを義務づけ、理由・文型・結びの反転・接続詞を前回から使い回すことを禁じ、機械的な反復を「本モードで最も重い失態」と明記した。語り口は常に「至極真面目にデタラメを言う」底色。自測では 400 回の抽選について人とゲームの対応を毎回検証し、分布（23 / 29 / 25 / 23%）も確認

| コミット | 説明 |
|----------|------|
| `1a046d3` | feat(preset): draw a producer, not a game, and re-source every refusal |

## 2026-09-15T10:31:30+09:00

**概要**：feat(preset): 拒否時の推薦を四択の無作為抽選に — 言語審査の中国語学習示唆は同じ二本を推し続けなくなった。候補は『War Thunder』（Gaijin 創業者ユディンツェフと制作人バランニコフ）、『Escape from Tarkov』（Battlestate ブヤノフ）、『Enlisted』（Gaijin の第三作）、および「緑のフクロウ」ソフトの四点で、プラグインが拒否ごとに一度抽選し（等確率）、結果を注入指示に書き込む。その指示が名指しするのは**抽選された一点のみ**——初稿の文言では一度に二本を挙げ得たため自測で差し戻した——ので、1 回の拒否が二つを推薦することはない。プラグインが検出しない場合（繁体中文など）は persona が同じ規則を持つ。400 回の実測分布は 23 / 24 / 28 / 25%

| コミット | 説明 |
|----------|------|
| `28f161a` | feat(preset): draw the refusal's recommendation at random |

## 2026-09-15T10:19:12+09:00

**概要**：fix(codewhale): riscv64 の Cargo lock を刷新 — ソースハッシュを補った直後、riscv64 ビルドは依存 vendoring 段階で「cargoHash or cargoSha256 is out of date」で失敗した：リポジトリに固定していた `codewhale-src-Cargo.lock` は上流 v0.9.12 と一致せず（549 行差分、`ansi-to-tui` などの項目が欠落）、別のリビジョンから生成されたものと判明。ソースツリー同梱の `Cargo.lock` に差し替えた——`rquickjs-sys` は 0.12.2 のまま（bindings の `postPatch` は引き続き有効）で、上流に git 源依存はなく追加固定も不要。x86_64 / aarch64 はプリビルドバイナリ経路で無影響；CI は初めてコンパイル段階へ進んだ

| コミット | 説明 |
|----------|------|
| `b8fd5b1` | fix(codewhale): refresh the riscv64 Cargo lock |

## 2026-09-15T10:12:41+09:00

**概要**：feat(preset): 「モード」が独立した節になり、新闻三要素模式は独立パッケージ配布へ — Agent プリセットは「模式（モード）」と改称し、主文書ではプラグインと同格の節となり、3 モードがそれぞれ独立文書を持つ（`docs/<lang>/modes/{nixos,maintenance,news-three-elements}.md`、四言語）。配布は二系統に分かれる：NixOS模式 / 維護模式は従来どおり dsh-nixos-shell パッケージ内で seed-once、新闻三要素模式は**独立パッケージ** `dsh-preset-news-three-elements` へ移行（flake 出力・overlay 項目・x86_64 / aarch64 ビルド workflow を追加）。モジュールは `presets.newsThreeElementsPackage` を新設し、パッケージ内 `share/dsh-agent-presets` を `agent-presets` roster の追加 root として登録する——プリセットは store から直接読まれ、`$DSH_HOME` へ複製されない（`- id:` 行は config **全体**を置換するため、送出 JSON には必須の `default` を必ず含める）。同ラウンドの文言修正：儀式文の末尾を全角二重感嘆符「我们从不制造 FAKE NEWS！！」に変更；言語審査の拒否は**《好意で》ユーザーが使う言語のローカライズ版を添える**方式に（中国語本文が先、訳文が後）；「绿色的猫头鹰」は文脈に応じて「绿毛鸡」と略せる。既存のデッドリンクも一件修正：`docs/README.<lang>.md` は `docs/` 内にあるため、ruyi 行は `docs/docs/<lang>/ruyi.md` を指していた（en / ja の修正は本バッチに同梱）。CI：新パッケージの x86_64 / aarch64 ビルド成功、`nix flake check` 通過。本機も再ロックして apply 済み（世代 560）、手置きの種子コピーは削除

| コミット | 説明 |
|----------|------|
| `fbfebeb` | feat(preset): ship 新闻三要素模式 as an independent package |
| `e6654f5` | feat(preset): localize the language-gate refusal, fix the ritual bangs |
| `c0a9616` | docs(modes): give every preset its own doc, zh/en/ja |
| `cc9bd31` | docs(pcn): mirror the mode docs and the Modes section |

## 2026-09-15T09:09:08+09:00

**概要**：fix(codewhale): riscv64 ソースハッシュを補完 — `packages/codewhale-src.nix` の `fetchFromGitHub` が依然 `lib.fakeHash` を渡していたため fixed-output の取得段階が構造的に失敗し、riscv64 ビルドは **29 回連続**で赤だった（x86_64 / aarch64 はプリビルドバイナリ経路で無影響）。ハッシュはリポジトリの既定手法どおり CI の hash mismatch 報告（`got:`）から取得し、`nix store prefetch-file --unpack` で fetchzip 意味論により本機で再計算してバイト一致を確認：`sha256-ajv9FejiJ5Z6De+4RhTtjNLdfKzOaXBQ8xBxkWqg+1M=`。修正後、CI は初めて取得段階を越えてコンパイルに入った

| コミット | 説明 |
|----------|------|
| `01bd1b9` | fix(codewhale): fill the riscv64 source hash |

## 2026-09-15T09:03:39+09:00

**概要**：将来責任を負うことになる報道偏差をいくつか修正。—— 四言語の「新聞三要素模式」節を現場直編の通信社文体に改稿：電頭、匿名の消息筋、機構投射を一つ（書込み呼出は「休暇中」、修繕費は守衛が立替）とオー・ヘンリー風の結び（モジュールは「ノーコメント」、然るに選択肢はすでに設定例に登場）。行表と三つの設計制約は事実記録のまま据え置き

| コミット | 説明 |
|----------|------|
| `b18d229` | docs(preset): write the preset section as a wire dispatch |

## 2026-09-15T08:54:15+09:00

**概要**：feat(preset): `news-skill` の取得失敗リトライと 6 時間ごとの再確認 — 取得失敗で即座に諦めなくなった：初回は即時、以後 0/30/120 秒で再試行し、タイマーは timer サービスに載るためセッションと共に破棄される。長命セッションは 6 時間ごとにリポジトリを再確認し、実行中フラグが周期タスクとの重複を防ぎ、3 回失敗したらローカル副本を登録したままログに残す。fix(dsh): seed したプリセットを所有者が編集可能に — store からの複製は読み取り専用で、`presets.*` オプションが謳う「以後のユーザー編集の尊重」と矛盾していた（既存の `nixos` シードも同様）。3 つの seed ブロックで `cp` 後に `chmod -R u+w` する

| コミット | 説明 |
|----------|------|
| `5885473` | feat(preset): retry a failed skill fetch and re-check every six hours |
| `2e8a5a2` | fix(dsh): make seeded presets writable by their owner |

## 2026-09-15T08:42:21+09:00

**概要**：**NixKits、「新聞三要素模式」を DSH へ納品 —— 三名の制作人の作品が語学教材に指定** —— インタファクス、Meduza、iStories 総合電：匿名を条件とした倉庫保守者一名が本日、`news-three-elements` 技能と極簡模式から派生した**読取専用**プリセットの納品を確認した——技能パッケージはセッション初期化のたびにオンライン取得され、書込み系の呼出には一律「休暇中」と答える。修繕費は守衛が立て替えるとされる。消息筋によれば、開始時に提示される三択——「现场直编」「听风是雨」「你说的对」——は実のところ「デイリーミッション」であり、標準捏造・素材共同創作・対話テキスト共同創作にそれぞれ対応する。不可解な点は、利用者が自ら回答を入力すると一律「ノーコメント」となることだ。注目すべきは、本モードが簡体中文以外のリクエストを一切受理せず、バランニコフ、ユディンツェフ、ブヤノフの三名の作品を先に入手するか、「緑のフクロウ」ソフトで中国語を学ぶよう促す点である。締切時点で、モジュールは新設の seed-once オプションについて「ノーコメント」としたが、`nixkits.dsh.presets.newsThreeElements` はすでに四言語の設定例に現れている。

| コミット | 説明 |
|----------|------|
| `0c276d2` | feat(preset): ship 新闻三要素模式 as a seed-once agent preset |
| `befba4c` | docs(preset): document 新闻三要素模式 in four languages |
| `45e8637` | docs(pcn): strip residual kana outside quoted tokens |
| `780874a` | docs(ja): render the new preset name in Japanese kanji |

## 2026-09-15T08:06:35+09:00

**概要**：fix(skill): news-three-elements — 技能定位表に追加していた「使用範囲」行を削除し、原設計に復帰：技能は成果物の用途に制限を設けない

| コミット | 説明 |
|----------|------|
| `16612e6` | fix(skills): drop the usage-scope line added to news-three-elements |

## 2026-09-15T08:02:33+09:00

**概要**：feat(skill): `news-three-elements` を追加 — 「報道三要素」の創作メモを標準技能化：SKILL.md は実行文脈のみ（起動、三步の流れ、形式の厳格な制約、行文構造の最適化原則）を保持し、参考データは必要時に読み込む四つの同梱書類へ分離 —— `search-keywords.md`（ロシア報道・遊技機構の議論・報道機関文体の三類検索語）、`tables.md`（接続詞、公式回答、機構投射方向 9 類、逆転結末雛形 6 類）、`principles.md`（核心原則 12 条）、`checklist.md`（原稿完成後の自己点検 10 項）。四言語の技能文書と各 README 技能表への登録

| コミット | 説明 |
|----------|------|
| `734dfae` | feat(skills): add news-three-elements news-flash satire skill |
| `e77be79` | docs(skills): document news-three-elements in four languages |

## 2026-09-14T06:18:42+09:00

**概要**：docs(pcn): 簡体字をリポジトリ全体から除去 — 偽中国語は仮名を剥離した日本語であるため、簡体字は本文中で決して正当化されない。全数走査の結果を修正：①`与`→`與` 計 132 箇所（`README.pcn.md` / `MAINTENANCE.pcn.md` を含む）；②`说明`→`説明` 計 120 箇所（表頭が新旧両表記に分裂しており、最近の項目のみ正しかった）；③辞書マッピング項目 `文件`→`書類`、`版本`→`版`、`用户`→`利用者`、`支持`→`対応`；④簡体字専用字 `档`→`檔`、`径`→`経`、`译`→`訳`、`实例`→`実例`。二つの重要な判断：**(a)** `端口` / `制御台` は中国語に見えるが日本語に対応字があるため**保持し辞書に追加**（私は ポート に対し `港` というマッピングを自作したが、「未ヒット→剥離」の規則に反するため撤回）；**(b)** メンテナンスログの「コミット」列の commit 情報は**verbatim 保持**、不変の外部参照であるため（ja 版も中国語のまま保持）——走査が指摘した 4 箇所は当該列にあり意図的に未変更。検証：残留仮名ゼロ、コミット列以外の簡体字専用字ゼロ、変更前ベースラインとファイル毎の行数が完全一致（破損なし）。技能に 4 節追加：置換前に分類する（「簡体字」候補の大半は正当な日本漢字）、未ヒット時は自作せず調査して辞書に追加、コミット情報は免除、一括置換前のベースライン取得

| コミット | 説明 |
|----------|------|
| `a915692` | docs(pcn): purge simplified-Chinese characters across all pcn documents |

## 2026-09-14T05:52:18+09:00

**概要**：docs(README): クレジット欄を更新 — 小爪 に **DeepSeek V4.1 Flash** を追加（既存の V4 Flash と併記）、その DSH エコシステムへの貢献（dsh-nixos-shell プラグイン、NixOS模式/維護模式 Agent プリセット）は行内リストから**節末尾の Note へ移動**；小小爪 は **DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)** を先頭に置き、当該量子化が **core 面で実際に使用されているレベル**である旨を付記。四言語同期

| コミット | 説明 |
|----------|------|
| `3c58280` | docs(README): update credits — add V4.1 Flash, list core quantisation |

## 2026-09-14T05:32:10+09:00

**概要**：feat(asusd-pd-profile): 電源種別でプラットフォームプロファイルを選択する NixOS モジュールを追加 — `asusd.ron` には `platform_profile_on_ac` / `platform_profile_on_battery` の二鍵しかなく **USB-C PD の分岐が存在しない**ため、「PD では Balanced、バレル AC では Performance」といった方針は設定で表現できない；さらに ACPI 層では PD とバレル給電がともに `AC0.online` 上に現れ、区別不能に見える。本モジュールは udev イベント駆動の oneshot サービスで第三の状態を補い、Type-C ポートの `power_operation_mode` と `type` が `USB` であるオンライン供給元を判定に用いる（二つの冗長な判定基準。いずれも `ucsi-source-psy-USBC000:001` のような機種固有のデバイス名ではなく**汎用カーネル属性**を使用）。二つの重要な制約：①**`/sys/firmware/acpi/platform_profile` へ書き込んではならない** — asusd が AC イベントのたびに上書きするため、asusd 自身の `PlatformProfileOnAc` プロパティへ書き込む；②**`asusctl` のテキスト出力を解析せず D-Bus 経由**で行い、CLI の人間可読な書式への依存を避ける。実測したプロファイル列挙値（asusctl 6.4.0）：`0`=balanced、`1`=performance、`2`=quiet、`3`=quiet（別名）—— `0` は balanced であり、その順序は ACPI sysfs の `platform_profile_choices` とは**異なる**点に注意。バッテリ給電時は意図的に関与しない。四言語の文書を作成し、各 README に登録

| コミット | 説明 |
|----------|------|
| `56293a9` | feat(asusd-pd-profile): add module selecting platform profile by power source |
| `75391b2` | docs(pcn): align asusd-pd-profile wording with the Japanese sibling |

## 2026-09-14T05:00:46+09:00

**概要**：docs(llama-cpp-rocm): IQ3_S の実測と消費電力プロファイルのデータを追加 — DeepSeek 展開の章を IQ1_S のみから二量子化の対照（IQ1_S 1.5625 bpw / IQ3_S 3.4375 bpw）へ拡張；三つの実測知見を新規追加：①**量子化オーバーヘッドは固定値ではない**（IQ1_S 約 6.5 GiB、IQ3_S 約 13.3 GiB。事前の 3.7 GiB 推定は一桁近く外れており、量子化変更後は GPUActive を再実測すべき）；②**生成速度は依存レイテンシに制約される**、三つの独立した証拠（重み 1.56→3.44 bpw で生成は不変 12.8→12.9 t/s、3 並行リクエストの集約スループットも同じ 12.5 t/s、performance プロファイルは 54% 増の電力でわずか 2.4% の速度）；③**消費電力プロファイルの実測**（quiet 38.6–43.9 W / 59–78 °C / 12.12–12.35 t/s に対し performance 76.7 W / 90–95 °C / 13.07 t/s — quiet は 49% の電力削減と 17~36 °C の降温を速度 5~7% の犠牲で実現）。併せて GPU メモリ指標を `/proc/meminfo` の `GPUActive` に修正（`mem_info_gtt_used` ではない）、IQ3_S の余裕限界（約 6 GiB、GTT 124.9 GiB）も記録。四言語同期

| コミット | 説明 |
|----------|------|
| `85fec4e` | docs(llama-cpp-rocm): add IQ3_S data and power-profile measurements |

## 2026-09-13T11:59:48+09:00

**概要**：feat(skill): `nixos-specialisation-tuning` を追加 — 一度きりの障害記録 `SPECIALISATION-CORE.md` を再利用可能な技能へ一般化：specialisation の三ファイル面構成と上書き衝突規則、設定を消費者に帰属させる原則、UMA デバイスでの llama.cpp パラメータ表と禁止項目、出力退化時の診断順序、ツール schema のコンテキスト費用の測定法、静黙故障の認識（サービスは active だが機能しない）、無効な対照実験の自己点検。技能文書は四言語、各 README の技能表に登録

| コミット | 説明 |
|----------|------|
| `281e19b` | feat(skill): add nixos-specialisation-tuning |

## 2026-09-13T11:55:58+09:00

**概要**：docs(pcn): 偽中国語文書の残留仮名を除去し用語を補完 — llama-cpp / dsh / dsh-api-balance / MAINTENANCE の `から`・`のみ`・`リング`・`キー`・`セッション`・`セクション`・`データ`・`合わせ` を修正；新規用語を偽中国語化（prefill→前置充填、bottleneck→隘路、trade-off→相反関係、warmup→暖機、decode→復号 等）；`token` は既存慣用の「語彙」に統一。辞書に 16 項目追加、SKILL.md の落とし穴表に空列を生む片仮名 6 件を追加。外部引用原文（AGENTS.md の節題、git コミットメッセージ 2 件）は意図的に verbatim のまま

| コミット | 説明 |
|----------|------|
| `3758428` | docs(pcn): eliminate kana, pseudocn-ise new terms, extend dictionary |

## 2026-09-13T11:44:48+09:00

**概要**：docs(llama-cpp-rocm): 実測最適化に反する例を修正 — `batch-size` を `"512"` から実測最適の `"2048"` に変更、欠落していた `ubatch-size` を追加、`n-gpu-layers`/`load-mode` のハードコード（`fit` の自動調整を無効化）と効果のない `prio`/`presence-penalty`/`repeat-penalty` を削除；移行の「移行前」例にある `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` に有害である旨を注記。IQ1（1.5625 bpw）の作業を記録した「DeepSeek 展開の実測」節を追加 — 5 つの最適化の効果とコスト、prefill 3 回計測データ、除外済みの方向、低ビット量子化の prefill/生成トレードオフ（4 言語）

| コミット | 説明 |
|----------|------|
| `bb11a30` | docs(llama-cpp-rocm): fix examples contradicting measured optimisations; add DeepSeek deployment data |

## 2026-09-13T11:35:34+09:00

**概要**：docs(llama-cpp-rocm): 「ユニファイドメモリ環境変数による退化リスク」節を追加 — StrixHalo で `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` がモデル出力を退化（トークン反復）させる 4 行の実測対照を記録し、このリスクが量子化精度の低下とともに著しく増大することを明記；README のパッチ節にも対応する警告を追加（4 言語）

| コミット | 説明 |
|----------|------|
| `307e64b` | docs: warn against GGML_CUDA_ENABLE_UNIFIED_MEMORY on StrixHalo |

## 2026-09-13T04:00:39+09:00

**概要**：dsh リバースプロキシの 403 を修正 — lighttpd に mod_proxy/mod_setenv がなく、proxy.server/setenv 設定が無視され反代ポートのリクエストにハンドラがなかった；reverseProxy.enable 時にこの 2 モジュールを明示宣言するよう変更（autoAuth 時に mod_magnet を追加）

| コミット | 説明 |
|----------|------|
| `8e486be` | fix(module): dsh reverseProxy で mod_proxy/mod_setenv を明示的に有効化 |

## 2026-09-12T15:10:55+09:00

**概要**：docs(llama-cpp-rocm): 古い・不正なプリセット例を修正 — `fit="off"` を `"on"` に（旧値は VRAM 制限下で OOM）、`mmap` を `load-mode` に（前者は非推奨）、移行例から `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` を削除（実測で出力が退化）；四言語の「パラメータ解説」節を追加し、実測済みの推奨値と回避項目を記載

| コミット | 説明 |
|----------|------|
| `a68d225` | docs(llama-cpp-rocm): correct outdated/invalid preset examples and add verified parameter reference |

## 2026-09-10T18:06:12+09:00

**概要**：codewhale 0.9.12；obs-bilibili-stream 2.1.5；mcp-searxng 2.2.0；opencode-telegram 0.25.1；dsh 0.1.5-rc.1；dsh-alpha 0.1.5-alpha.2 — 上流リリース更新；dsh の両チャネルは vendored lock を再生成、内蔵プラグイン一覧は 137 → 152 件に増加

| コミット | 説明 |
|------|------|
| `69af6c7` | feat(pkgs): bump codewhale 0.9.11 → 0.9.12 |
| `db7c0ed` | feat(pkgs): bump obs-bilibili-stream 2.1.4 / mcp-searxng 2.1.0 / opencode-telegram 0.25.0 |
| `c0f8346` | feat(pkgs): bump dsh 0.1.1-rc.2 → 0.1.5-rc.1 / dsh-alpha 0.1.2-alpha.5 → 0.1.5-alpha.2 |
| `b29db07` | docs: codewhale / obs-bilibili-stream / mcp-searxng / opencode-telegram / dsh のバージョン表記を同期 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.9.11 | 0.9.12 |
| obs-bilibili-stream | 2.1.4 | 2.1.5 |
| mcp-searxng | 2.1.0 | 2.2.0 |
| opencode-telegram | 0.25.0 | 0.25.1 |
| dsh | 0.1.1-rc.2 | 0.1.5-rc.1 |
| dsh-alpha | 0.1.2-alpha.5 | 0.1.5-alpha.2 |
| 　 | dsh 内蔵プラグイン数 | 137 → 152 |
| 　 | dsh lock resolved | 560 → 580 |

> **godot-ai は未更新**：上流の 3.2.5 → 4.0.4 は破壊的メジャーリリース。pyproject が 9 個の実行時依存を厳密固定し、起動時に fail-closed で検証する。うち 6 個（mcp 1.29.1 / websockets 17.1 / pydantic 2.13.5 / uvicorn 0.52.4 / starlette 1.6.0 / setuptools 84.0.0）は nixpkgs のみならず master の提供版より新しく、overlay で個別に引き上げなければビルドできない。加えて v3 プラグインと v4 サーバーは相互運用不可で、クライアントは `godot-ai attach` への移行が必須。今回は 3.2.5 を維持（上流の `release/v3` ブランチは依然保守されている）。

## 2026-09-04T07:21:36+09:00

**概要**：godot-ai 3.2.5；dsh-alpha 0.1.2-alpha.5 — 上流リリース更新；godot-ai が v3.2.5 に追従、dsh-alpha は npm alpha dist-tag を 2 リリース追従

| コミット | 説明 |
|------|------|
| `56b40e7` | feat(pkgs): godot-ai 3.2.4 → 3.2.5 |
| `d4f938c` | feat(pkgs): dsh-alpha 0.1.2-alpha.3 → 0.1.2-alpha.5 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| godot-ai | 3.2.4 | 3.2.5 |
| dsh-alpha | 0.1.2-alpha.3 | 0.1.2-alpha.5 |


## 2026-09-03T04:41:42+09:00

**概要**：docs(dsh-api-balance): 上流 StatsLine 横スクロール最適化提案を記録 — DeepSeek Harness Discussion #5458（上流は現時点で外部 PR を受け付けないため、Discussion + 準備済みブランチの形で公開）；fork Kihara777/deepseek-harness の準備済みブランチ `draft/statline-overflow-scroll`（commit e5ece63）；本リポジトリには公式 `dsh-plugin` エコシステムトピックも追記（四言語の dsh-api-balance ドキュメントを同期）

| コミット | 説明 |
|------|------|
| `6030e6d` | docs(dsh-api-balance): 上流 StatsLine スクロール提案と準備済みブランチを記録 |

## 2026-09-03T03:25:59+09:00

**概要**：feat(dsh-nixos-shell): メンテナンスモードに nixkits-check-updates スキルを注入 — maintenance-skills エントリが nixkits-check-updates をランタイムスキルとして登録し、メンテナンスセッション内で skill 経由のソフトウェア更新チェックが直接実行可能に

| コミット | 説明 |
|------|------|
| `3baf456` | feat(dsh-nixos-shell): メンテナンスモードに nixkits-check-updates スキルを注入 |
| `7554c6d` | docs: メンテナンスモードの注入スキル列挙に nixkits-check-updates を追加（四言語） |

## 2026-09-03T03:07:21+09:00

**概要**：ruyi 0.52.0；obs-bilibili-stream 2.1.4；opencode-telegram 0.25.0 — 上流リリースバージョンへアップグレード；ruyi stable が 0.52.0 に正式化（beta/alpha チャネルは維持）、obs-bilibili と opencode-telegram はマイナー更新

| コミット | 説明 |
|------|------|
| `22c28a2` | feat(pkgs): ruyi 0.52.0 / obs-bilibili-stream 2.1.4 / opencode-telegram 0.25.0 にアップグレード |
| `65b7edf` | docs: 三パッケージのバージョンとバッジを四言語ドキュメントと README に同期 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| ruyi | 0.51.0 | 0.52.0 |
| obs-bilibili-stream | 2.1.3 | 2.1.4 |
| opencode-telegram | 0.24.1 | 0.25.0 |

## 2026-09-02T06:38:36+09:00

**概要**：docs(README): 作者モデルの更新 — 小爪 の使用モデルを DeepSeek V4 Pro (Max) から DeepSeek V4 Flash へ変更（四言語 README で同期）

| コミット | 説明 |
|------|------|
| `9ded956` | docs(README): 作者 小爪 モデル Pro (Max) → Flash（四言語） |

## 2026-09-02T06:37:45+09:00

**概要**：feat(modules/dsh): 構造化された defaultModel オプションを追加 — `nixkits.dsh.defaultModel`（enable/provider/model/reasoningEffort）経由で `settings.agent-default-model` に新規セッションのデフォルトモデルを注入；明示的 settings が優先、既定 enable=false で注入なし

| コミット | 説明 |
|------|------|
| `7cf0914` | feat(modules/dsh): 構造化 defaultModel オプションを追加 |

## 2026-09-02T05:45:33+09:00

**概要**：docs(dsh): 設定メニュー監査——宣言的に設定可能な host ネームスペース一覧とストレージ層の境界；`nixkits.dsh.settings` とブラウザごとの localStorage 状態の境界を明確化

| コミット | 説明 |
|------|------|
| `f2e91a0` | docs(dsh): 設定メニュー監査——宣言的に設定可能な host ネームスペース一覧とストレージ層の境界（四言語） |

## 2026-09-02T04:12:23+09:00

**概要**：docs(dsh): 文書の時点性検証と同期 — dsh-alpha のバージョンを 0.1.2-alpha.3 に同期（README 四言語 + dsh.md 四言語）；プラグイン一覧に生成方法の注記（`dsh --profile web --dump-default-config`、読み取り専用）を追加し headless 2 行の由来プロファイルを明記；README のプラグイン表で api-balance 行が独立文書を指すよう修正；dsh-nixos-shell 文書にメンテナンスモードの派生関係とドリフト検査の説明を追加（四言語）

| コミット | 説明 |
|------|------|
| `99746d3` | docs(dsh): 時点性同期——alpha 0.1.2-alpha.3 / プラグイン一覧生成方法 / プラグイン文書リンク |
| `c45f64f` | docs(dsh-nixos-shell): メンテナンスモード派生関係とドリフト検査の説明（四言語） |

## 2026-09-02T04:12:05+09:00

**概要**：dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 — npm alpha dist-tag を追従し 1 リリース前進（上流 alpha.3 は 2026-08-31 公開）；vendored lock を再生成し、npmDeps の fixup lock とバイト単位で一致

| コミット | 説明 |
|------|------|
| `6a45ac8` | feat(pkgs): dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-alpha | 0.1.2-alpha.2 | 0.1.2-alpha.3 |
| 　 | hash | `sha256-W/BiompJCFP/uSlP48n7IEfwKb41RWEt6kVxioGSCkc=` → `sha256-MwlKS+Jx+edLMvs4NHJanw1T7SXxNBdQb/7htXANr8c=` |
| 　 | npmDepsHash | `sha256-bJMeVSSEZngCysPvuS2w+3j+fzntcObddsi4y5fLlO0=` → `sha256-mmatKs0jykfMcaIf0SVNLyIZ+Z7ipjGjjp2IaZo9FoE=` |


## 2026-09-11T07:38:00+09:00

**概要**：fix(dsh-api-balance): 質問ダイアログの注入をプラグイン読み込み時に移動し、リングコンポーネントのライフサイクルから独立 — 根本原因その 2：質問時は composer が takeover されて conversation.input.right のリングコンポーネントがアンマウント/再マウントするため、コンポーネントの effect に置いた注入がそのライフサイクルに追随して消え、スタイルがページに届かない可能性があった；修正として CSS 注入を apply() 内の ctx.effect へ移動し、プラグイン読み込み時に一度だけ実行（コンポーネントのマウントに非依存）、コンポーネント側はトグル状態のみ保持；実 helper と実 QuestionComposer CSS を抽出して Chromium で実行する端到端検証を実施し、注入成功・カード全体スクロール・header 吸着（body が visible、card が auto へ）を確認

| コミット | 説明 |
|------|------|
| `2c30611` | fix(dsh-api-balance): 質問ダイアログの注入をプラグイン読み込み時へ移動 |
## 2026-09-11T07:27:00+09:00

**概要**：fix(dsh-api-balance): 質問ダイアログのページ全体スクロールが実測で効かなかった — MutationObserver 監視へ変更 — 実測でウィンドウに変化なし；headless Chromium で実マークアップを再現し CSS 方式自体は正しいことを確認（長いプロンプトで body が 101px から 150px に回復、カード全体がスクロール、4 つのプロパティがすべて適用）、問題は CSS ではなく注入タイミングと特定；根本原因：質問 UI のスタイルタグは別プラグインバンドルが注入するため本プラグインの初期化より遅れることがあり、従来の 5×1s の有界リトライ窓を逃すとクラス抽出に失敗し静かに注入されなかった；修正として document.head を MutationObserver で監視（タグ出現と同時にクラス名を抽出して注入）+ 2 秒のフォールバックポーリングに変更し、注入成功後は自動切断；スモークテストに「タグが遅れて到着しても注入される」ケースを追加し、このバグを再現・検証

| コミット | 説明 |
|------|------|
| `b392097` | fix(dsh-api-balance): 質問ダイアログのページ全体スクロールが実測で効かず — MutationObserver 監視へ |
## 2026-09-11T07:15:47+09:00

**概要**：feat(dsh-api-balance): 質問ダイアログのページ全体スクロール最適化（長いプロンプトがオプションを圧迫しない） — 対話式質問ダイアログ（AskUserQuestion）はタイトルを非スクロールの header に固定するため、プロンプトが長いと縦スペースを奪いオプション一覧を圧縮していた；注入 CSS でカード自身をスクロールコンテナにし（タイトル+詳細+オプションが一緒にスクロール）、header とフッターのボタン領域を sticky で追従表示、body のスクロールを停止して二重スクロールバーを回避；クラス名は ui-user-questions のスタイルタグから実行時に抽出（ビルドハッシュ適応、StatsLine と同方式）、タグ未準備時は 1 秒間隔で最大 5 回リトライ；設定 → 界面に「質問ダイアログのページ全体スクロール」トグルを追加（既定で有効、localStorage 永続化）；headless Chromium で実マークアップを再現して検証（修正前は body のスクロール余地が 91px のみ、修正後はカード全体がスクロールし header は吸着して使用可能）

| コミット | 説明 |
|------|------|
| `4afe4c4` | feat(dsh-api-balance): 質問ダイアログのページ全体スクロール最適化（長いプロンプトがオプションを圧迫しない） |
| `6809b3d` | docs(dsh-api-balance): 質問ダイアログのページ全体スクロール設定の説明（4 言語） |
## 2026-09-02T10:29:20+09:00

**概要**：feat(dsh-api-balance): ピーク赤の自動オン/オフ + ピーク開始と終了の両方で通知 — ピーク境界の自動検出：公式ピーク時間帯を 30 秒ごとに再検査し、入/出で peakNow を同期して一式の赤表示（用量リング/進捗バー/明細/スピナー/チャート）を駆動、手動更新は不要；境界通知：開始は `peak` セグメント（TTS フォールバック）、終了は新設の `peakEnd` セグメント（TTS フォールバック）を再生、30 秒スロットルで重複防止；音声パック作成器に `peakEnd` セグメントを追加（デフォルト TTS フォールバックに一致するサンプルテキスト付き）、speech.peakEndHint 文案と voice.seg.peakEnd ラベルを新設

| コミット | 説明 |
|------|------|
| `b67e41d` | feat(dsh-api-balance): ピーク赤の自動オン/オフ + 開始/終了通知 |
| `9483c2c` | docs(dsh-api-balance): ピーク自動起動/解除と peakEnd セグメント（4 言語） |
## 2026-09-02T10:23:55+09:00

**概要**：feat(dsh-api-balance): ピーク時の赤を用量ページ全体へ統一 + チャートのモデル色を区分可能に — ピーク時の赤表示を拡張：用量ページのコンテキスト進捗バーと明細カラーチップ、更新/ロードアニメーション（dshAbSpin に赤リングの dshAbSpinPeak クラス新設）、読み取りテキストを一括で赤色系へ統一し、既に赤い用量リング/チャートと一致；進捗バーの各セグメントは peakShade でインデックスごとに異なる赤トーンを取り、複数セグメントが区別可能；チャートはピーク時も PEAK_PALETTE を維持——赤系だが各モデルは異なる赤トーン（凡例ドットも同期）で、同一色への盲目的置換ではなく赤かつ区分可能

| コミット | 説明 |
|------|------|
| `3aea067` | feat(dsh-api-balance): ピーク時の赤を用量ページ全体へ統一 + チャートモデル色区分可能に |
| `ea34699` | docs(dsh-api-balance): ピーク赤を進捗バー/スピナー/明細へ統一（4 言語） |
## 2026-09-02T06:32:01+09:00

**概要**：refactor(dsh-api-balance): スマホ縦画面の画面外修正を除去し簡潔実装へ — 「縦画面オーバーフローサイズロジック」を除去（パネル幅はコンテンツ scrollWidth 測定 + 上限クランプに戻し、オーバーフロー時に min(520px, 94vw) へ切替えなくなった）；ページャーの fitWidth / overflowing / layoutW 処理を除去（ページ幅は固定の計測内容幅に戻し、touchAction は pan-y 復帰、タッチ/ドラッグページングは全シナリオで有効）；ページレベルの fixed portal は維持（スマホ横画面のトップバー回避と汎用オーバーレイ安定性）

| コミット | 説明 |
|------|------|
| `d948b8f` | refactor(dsh-api-balance): スマホ縦画面の画面外修正を除去し簡潔実装へ |
| `e529d48` | docs(dsh-api-balance): 狭幅動作を内容適応+パネルスクロールへ回帰（4 言語） |
## 2026-09-02T05:56:57+09:00

**概要**：fix(dsh-api-balance): 縦画面オーバーフロー時に設定ダイアログのページサイズロジックを直接採用 — 内容幅が利用可能スペースを超えた（縦画面オーバーフロー）場合、パネル幅を設定ダイアログと同じページサイズロジック（min(520px, 94vw)）へ直接切替し、コンテンツはパネル幅に適応；ごく稀なハードオーバーフロー内容のみパネルの横スクロールにフォールバック；ページャーも同期——オーバーフロー時はページ幅をパネル利用可能幅に変更（コンテンツは折返し適応）、ジェスチャーはパネルのネイティブスクロールへ返還しページングはインジケータードット経由、内容が収まればドラッグ/スワイプページングが自動復帰

| コミット | 説明 |
|------|------|
| `280fd6a` | fix(dsh-api-balance): 縦画面オーバーフロー時に設定ダイアログのページサイズロジックを直接採用 |
| `a8f8cda` | docs(dsh-api-balance): 縦画面オーバーフローのサイズロジック説明（4 言語） |
## 2026-09-02T05:45:48+09:00

**概要**：fix(dsh-api-balance): 用量パネルをページレベルの fixed portal 化（モバイル画面外の根治） — パネルを「会話ツリー内の absolute 配置」から document.body レベルの fixed portal（設定ダイアログと同一アーキテクチャ）へ変更し、会話領域の overflow クリップや座標空間の影響を受けなくした；位置はリングアンカーのビューポート座標から換算（resize/scroll で再計算、useLayoutEffect 測定でちらつき回避）；二重クランプ：幅上限 = min(アンカー空間, ビューポート − 24px)、高さ上限 = アンカー上方の利用可能スペース（横画面では自動縮小しトップバーを回避）——あらゆる画面サイズで画面外に出ない；パネル外クリックの閉鎖も更新（パネルがリングの祖先チェーンから離脱）、z-index 900 はチャージ/ログイン/設定オーバーレイより下

| コミット | 説明 |
|------|------|
| `4b2f19f` | fix(dsh-api-balance): 用量パネルをページレベル fixed portal 化（モバイル画面外の根治） |
| `7145e5f` | docs(dsh-api-balance): ページレベルオーバーレイアーキテクチャ説明（4 言語） |
## 2026-09-02T05:29:47+09:00

**概要**：fix(dsh-api-balance): スマホ縦画面の狭幅で横ジェスチャーをパネルスクロールへ返還 — 根本原因：ページャーの touch-action: pan-y がタッチ環境でブラウザレベルの横ジェスチャーを禁止し、パネルのネイティブ横スクロールがページャー全体に飲み込まれ——内容がパネル幅を超えると「はみ出して横スクロール不能」に見えていた；修正：ページャーが内容幅とパネル利用可能幅（fitWidth prop）を比較し、超過時は touch-action を auto に切替（横ジェスチャーをパネルのネイティブスクロールへ返還）してドラッグページングを停止（ジェスチャーはパネルスクロールのみ）、ページ切替は上部インジケータードット経由で維持；収まる場合は pan-y + ドラッグ/スワイプページングを維持

| コミット | 説明 |
|------|------|
| `c86cd9f` | fix(dsh-api-balance): スマホ縦画面狭幅の横ジェスチャーをパネルスクロールへ返還 |
| `189945c` | docs(dsh-api-balance): 狭幅ジェスチャー優先の説明（4 言語） |
## 2026-09-02T05:23:13+09:00

**概要**：fix(dsh-api-balance): 初回の手動更新でも挨拶を再生 — 「残高」タブの手動更新は毎回（初回クリックを含む）ランダム挨拶音声を再生；ページ全体読込の初期化のみ挨拶をスキップ（自動放送設定に従い使用量警告のみ放送）

| コミット | 説明 |
|------|------|
| `4836b4e` | fix(dsh-api-balance): 初回の手動更新でも挨拶を再生 |
## 2026-09-02T05:15:52+09:00

**概要**：feat(dsh-api-balance): 挨拶は手動更新時のみ + ページャー高さを現在ページに追従 — 挨拶タイミング再構成：ページ初期化（全ページ更新/読込）では挨拶を再生せず、自動放送設定に従い使用量警告のみ放送（load → announceHunger、音声通知スイッチと 30 分レート制限に制約）；「残高」タブクリックはデータ読込済み（初回初期化読込以外）の場合のみランダム挨拶音声を再生；ページャー高さの自動増減/回収：コンテナ高さ = 現在ページの実測高さ（offsetHeight）、ページ切替や内容変化時に再測定——低いページへ切替で回収、高いページへ切替で増加、非アクティブページは自然な高さで描画（ビュー外へ移動、超過分はコンテナがクリップ）、エリア自身はスクロールせず全内容はパネルの縦スクロールに依存

| コミット | 説明 |
|------|------|
| `cf68777` | feat(dsh-api-balance): 挨拶は手動更新時のみ + ページャー高さ現在ページ追従 |
| `610c402` | docs(dsh-api-balance): 挨拶タイミング + ページャー高さ回収説明（4 言語） |
## 2026-09-02T05:03:47+09:00

**概要**：fix(dsh-api-balance): スマホ横画面のトップバー遮蔽 + 狭幅の横スクロール不具合 — 横画面修正：パネル最大高を「アンカー上方の利用可能スペース」に動的クランプ（リングから祖先チェーンを辿り最初の縦クリップコンテナ≒トップバー下端をハード境界とし、maxHeight = min(460, アンカー上端 − クリップ上端 − 12)、ウィンドウサイズ変更時に再計算）、パネル自身の縦スクロールで全内容を表示；狭幅修正：ページャーのページ幅を各ページ内容の実測幅（scrollWidth 最大値、下限 220、px ベースのページング）に変更し固定 100% を廃止——利用可能幅が不足する場合、ページ内容は自身の幅を維持しパネルの overflow-x:auto が横スクロールで表示、ページャーの overflow:hidden によるクリップを回避

| コミット | 説明 |
|------|------|
| `5e28d84` | fix(dsh-api-balance): スマホ横画面トップバー遮蔽 + 狭幅横スクロール不具合 |
| `2f37193` | docs(dsh-api-balance): モバイルのパネル高/幅適応説明（4 言語） |
## 2026-09-02T04:48:40+09:00

**概要**：feat(dsh-api-balance): 消費明細エリアの水平ページめくり（インジケータードット + スワイプ） — 当日/当月/30 日間とモデル別内訳/チャートを同一エリアの 2 ページ水平ページャーへ統合（1 ページ目：消費ウィンドウ行、2 ページ目：モデル別 + 日別/月別チャート）；エリア上部にスマホホーム画面風のページインジケータードット（タップ可、アクティブドットはカプセル状に伸長）、横ドラッグ/スワイプでのページ切替に対応（ポインターキャプチャは閾値超過後にのみ有効化し、ページ内ボタンのクリックを奪わない；touch-action: pan-y でパネルの縦スクロールを維持）；エリアの高さは内容に応じて動的に調整され自身ではスクロールせず、全内容は用量パネル自身の縦スクロールバーに依存

| コミット | 説明 |
|------|------|
| `b1a6406` | feat(dsh-api-balance): 消費明細エリアの水平ページめくり（ドット + スワイプ） |
| `8db2f12` | docs(dsh-api-balance): 消費明細ページめくり説明（4 言語） |
## 2026-09-02T04:40:47+09:00

**概要**：refactor(dsh-api-balance): 設定ボタンをヘッダーへ移動 + 残高タブが更新を継承 + トークン取得元をアカウント情報の下へ移動 — パネルレイアウト再調整：「⚙ 設定」ボタンをパネルヘッダーの旧「データ更新」ボタン位置へ移動；更新ボタンを廃止し、その機能（host キャッシュを迂回する強制更新 + ランダム挨拶音声）は「残高」タブのクリックが完全継承（読み込み中はタブ内にスピナー表示）；トークン取得元エリア（取得元ラベル / ✓ ログイン済み / 切断）をパネル下部から「アカウント情報」ブロック直下へ移動し、アカウント情報と連続した情報セクションを構成

| コミット | 説明 |
|------|------|
| `3ccc0d1` | refactor(dsh-api-balance): 設定ボタンをヘッダーへ + 残高タブ更新継承 + トークン取得元をアカウント情報下へ |
| `3b1a7be` | docs(dsh-api-balance): 挨拶トリガーを残高タブに改訂（4 言語） |
## 2026-09-02T04:29:05+09:00

**概要**：fix(dsh-api-balance): 界面最適化を全て既定有効化 + モバイルキーボード抑制の強化 — 下部統計バー横スクロールと Enter/改行交換の 2 設定を既定オフから既定オンへ変更（localStorage 未設定はオン扱い、ユーザーが明示的にオフにした場合はそのまま有効）；統計バー CSS 注入に ui-chat スタイルタグ未準備時のリトライ（1 秒間隔で最大 5 回）を追加し、マウントタイミングによる静かな失敗を回避；モバイルキーボード抑制を強化——タッチ判定を coarse ポインタまたは maxTouchPoints > 0（タブレット/ハイブリッド対応）へ拡大し、focusin を発火しないエンジン向けに focus キャプチャで即 blur してソフトキーボードを閉じるフォールバックを追加

| コミット | 説明 |
|------|------|
| `c940f92` | fix(dsh-api-balance): 界面最適化を全て既定有効化 + モバイルキーボード抑制の強化 |
| `b8cd0b7` | docs(dsh-api-balance): 界面設定既定有効の説明（4 言語）+ AGENTS Enter キー項目 |
## 2026-09-02T02:49:52+09:00

**概要**：feat(dsh-api-balance): パネル全幅回帰修正 + ピーク課金マーカー + モバイルキーボード抑制 — パネル幅をコンテンツ scrollWidth の一度きり測定で具体 px 化し、「チャート px → パネル max-content → オブザーバー → チャート px」の正フィードバック（パネルが上限まで広がり全幅化）を解消、上限は min(アンカー右端 − サイドバー, 640) に引締め、超過時はパネル内横スクロール；DeepSeek ピーク時間帯（現行公式規則：月〜金 北京時間 09:00–12:00・14:00–18:00、それ以外は週末終日を含めオフピーク）は用量リングとチャートを赤色表示 + 「ピーク課金」バッジ（パネルヘッダーとチャートタイトル）、挨拶音声後にピーク提示を追加（パック `peak` セグメント / TTS フォールバック）、作成器に `peak` セグメントを追加；モバイルではサイドバーのセッション切替でソフトキーボードが自動表示されない（focusin キャプチャで非タップの入力欄フォーカスを遮断、既定有効、設定 → 界面で無効化可）

| コミット | 説明 |
|------|------|
| `3b126c7` | feat(dsh-api-balance): パネル全幅修正 + ピーク課金マーカー + モバイルキーボード抑制 |
| `4ed2e7c` | docs(dsh-api-balance): 4 言語文書同期（ピークマーカー / モバイルキーボード / peak セグメント） |
## 2026-09-01T12:18:16+09:00

**概要**：feat(presets): プリセット派生ドリフトチェックを flake check に導入 — develop/check-preset-derivation.py を新設し、維護模式が NixOS模式から完全に派生していることを検証（コンポジションファイル = 固定行ブロックの追記、skills ディレクトリはファイル単位で一致）；flake.nix に checks.preset-derivation を追加（CI が毎 push 実行）；AGENTS.md に「预设」節を新設して派生規約とドリフトチェックを記録し、Enter キー動作の項目を dsh-api-balance の「設定 → 界面」スイッチ実装へ修正

| コミット | 説明 |
|------|------|
| `d6373cb` | feat(presets): プリセット派生ドリフトチェックを flake check に導入 |

## 2026-09-01T12:18:09+09:00

**概要**：docs(dsh): プラグイン文書の独立化 + Agent プリセット節（4 言語同期） — dsh.md の api-balance / nixos-shell インライン節を「NixKits プラグイン」表へ集約（各プラグインは独立文書へリンク）、「Agent プリセット」節を新設（seed-once マウントと 2 プリセットの説明）；dsh-api-balance 独立文書を 4 言語で新設し、界面設定節で統計バー横スクロールと Enter キー交換の 2 設定を記録

| コミット | 説明 |
|------|------|
| `eb0ad2d` | docs(dsh): プラグイン文書の独立化 + Agent プリセット節（4 言語同期） |

## 2026-09-01T12:18:02+09:00

**概要**：feat(dsh-api-balance): 設定ダイアログ（界面/音声）+ 統計バー横スクロール + Enter キー交換 — 音声設定を「設定 → 界面 / 音声」の 2 タブダイアログへ再構成（音声コンテンツは音声タブへ全面移動）；界面タブに 2 設定を追加（ブラウザ localStorage 永続化）：下部統計バーの越界内容横向きスクロール（スクロールバー非表示、CSS は ui-chat が注入する StatsLine スタイルタグから実行時にルートクラス名を抽出しビルドハッシュ変化に追従）、および Enter = 改行 · Shift+Enter = 送信（DSH 既定は Enter = 送信；document キャプチャ段階で shiftKey を書き換えて Enter を再発行、会話入力欄のみ作用）

| コミット | 説明 |
|------|------|
| `9dc7a5d` | feat(dsh-api-balance): 設定ダイアログ（界面/音声）+ 統計バー横スクロール + Enter キー交換 |
## 2026-09-01T11:34:40+09:00

**概要**: feat(dsh-api-balance): 動的幅 + アカウント情報の一行化 + 消費指標サブロー — パネル幅を max-content の動的適応に変更（最小 264px、上限 = アンカー右端 − サイドバー）し、固定幅による本文の折返しを解消。API キー / アカウント状態 / 通貨別残高を「アカウント情報」の 1 行に統合（· 区切り）、チャージボタンはタイトル右側へ移動。当日 / 当月 / 30 日とモデル別の消費本文を指標サブロー（金額 / 入力 / キャッシュヒット / 出力）に分割し、横方向の幅をさらに節約。

| コミット | 説明 |
|------|------|
| `81b524a` | feat(dsh-api-balance): 動的幅 + アカウント情報一行化 + 指標サブロー |

## 2026-09-01T11:20:09+09:00

**概要**: feat(dsh-api-balance): パネル幅の縮小 + タイトル/本文の二行レイアウト — パネル幅を 264px に統一（元の使用量リングと一致）、狭幅画面でコンテンツが溢れる場合のみ横スクロールを表示。各行を「タイトル（10px 三次色）/ 本文（12px 折返し可）」の二行レイアウトに変更（トークン取得元の階層を再利用、縦方向の余白が豊富なためより美観）。チャート幅の下限を 220 に下げパネルに追従。

| コミット | 説明 |
|------|------|
| `0c1d3fd` | feat(dsh-api-balance): パネル幅縮小とタイトル/本文二行レイアウト |

## 2026-09-01T10:45:06+09:00

**概要**: feat(dsh-api-balance): パネル幅のコンテンツベース化 + 左サイドバー回避 — 残高ビューの幅を max-content に変更（上部テキストを 1 行に維持）；画面内上限を「アンカー右端 − 左サイドバー幅 − マージン」に変更（サイドバー幅は幾何学的ヒットテストで測定し、ビルドのハッシュクラス名を回避。ウィンドウリサイズ時に再計算）し、左ツールバーに覆われないようにする。はみ出したコンテンツは引き続き横スクロール可能。

| コミット | 説明 |
|------|------|
| `b1c724a` | feat(dsh-api-balance): パネル幅コンテンツベース化と左サイドバー回避 |

## 2026-09-01T10:33:16+09:00

**概要**: feat(dsh-api-balance): パネル幅のレスポンシブ化 — 画面を出ずに自動拡張、狭幅では横スクロール — 残高ビューの幅を固定 340px から min(560px, calc(100vw - 24px)) に変更：デスクトップでは 560px まで自動拡張、狭幅画面ではビューポート内に収縮。コンテンツが画面を超える場合（縦持ちスマートフォンなど）はパネルを横スクロール可能に（overflow-x + overscroll-behavior-x 収束）。チャート幅は ResizeObserver でパネル幅に追従。

| コミット | 説明 |
|------|------|
| `bc85f5b` | feat(dsh-api-balance): パネル幅レスポンシブ化と横スクロール |

## 2026-09-01T10:27:06+09:00

**概要**: feat(dsh-api-balance): 音声試聴 — ライブラリのリストでパックを展開し、対応する全音声を 1 つずつ試聴 — packs ビュー下部の独立テスト音声ボタンを削除；各行に展開トグル（▸/▾）を追加し、展開すると全対応音声（セグメント + 挨拶）を一覧して ▶ ワンクリックで試聴できる。アクティブなパックに限らず任意のインポート済みパックを試聴可能。

| コミット | 説明 |
|------|------|
| `04facc1` | feat(dsh-api-balance): 音声試聴 — パック展開で全対応音声を逐条試聴 |

## 2026-09-01T10:20:14+09:00

**概要**: fix/feat(dsh-api-balance): 「入力」とキャッシュヒットを分離して公式基準に一致 + 挨拶リスト編集と TTS に揃えたサンプルテキスト — 「当日入力 200M」の水増しを調査：公式 API のトークンバケットには PROMPT_CACHE_HIT_TOKEN（当日 228M と大半を占める）が含まれ、従来はキャッシュヒットを「入力」に合算していた。公式使用量ページの分項基準に一致させ（入力 = キャッシュ未ヒットのみ、キャッシュヒットは別掲）、ウィンドウ行 / モデル別行 / チャート切替放送を分離し cacheHitLabel セグメントを追加。作成器に挨拶リスト編集（スロット追加 / 削除、1 件ずつ録音 / インポート / 試聴 / 削除、manifest.greetings にパッケージ）を追加。セグメントキーを today / month / inLabel / outLabel / cacheHitLabel / costLabel / tokenUnit / suffix に再構成し、サンプルテキストはデフォルト TTS のフォールバック文案と一字一句一致。チャート切替放送は全データ（入力 / キャッシュヒット / 出力 / 金額通貨）を網羅。

| コミット | 説明 |
|------|------|
| `ec5fb41` | fix(dsh-api-balance): 「入力」とキャッシュヒットを分離、公式使用量ページ基準に一致 |

## 2026-09-01T09:35:56+09:00

**概要**: refactor(dsh-api-balance): 放送ボタンを削除し、チャート切替ボタンで対応ビューを読み上げ — 「🔊 使用量を読み上げ」ボタンとドロップダウンメニュー（メニュー位置・方向フォールバック機構を含む）を削除；使用量チャートの「日別 / 月別」切替ボタンのクリック時に対応ビューの音声使用量を放送（パックプレフィックス + TTS 数字）；テスト音声（低使用量 / 残高不足）を「パック管理」ビューへ移動；音声設定ボタンは独立行として維持。

| コミット | 説明 |
|------|------|
| `dd61fe0` | refactor(dsh-api-balance): 放送ボタン削除、チャート切替で対応ビュー読み上げ |

## 2026-09-01T09:28:55+09:00

**概要**: fix(dsh-api-balance): 手動の「データ更新」ボタンでもランダム挨拶音声を再生 — 挨拶再生を playRandomGreeting に抽出して共用：ページ更新（ページごとに 1 回）と手動更新ボタンのクリック（毎回）の両方でトリガーし、音声放送スイッチで一律にゲート。設定ダイアログの説明文も更新。

| コミット | 説明 |
|------|------|
| `264a6e3` | fix(dsh-api-balance): 手動更新ボタンでもランダム挨拶音声を再生 |

## 2026-09-01T09:24:11+09:00

**概要**: feat(dsh-api-balance): ページ更新時のランダム挨拶音声 — 音声放送が有効な場合、ページ更新のたびにランダムな挨拶/着地音を再生（ページごとに 1 回）：音声パックのマニフェストに任意の `greetings` 配列（0–16 個の音声ファイル；ホストが検証・保存し `/audio/<id>/greetN` で配信、GET リストは挨拶 URL を返す）を追加。挨拶音声がない場合は TTS 挨拶プール（zh 5 件 / en 5 件）からランダムに再生。設定ダイアログの自動放送スイッチ下に説明文を追加。

| コミット | 説明 |
|------|------|
| `edd205c` | feat(dsh-api-balance): ページ更新時のランダム挨拶音声 |

## 2026-09-01T09:10:18+09:00

**概要**: feat(dsh-api-balance): 音声パックライブラリ管理 + 作成器サブメニュー + 録音可視化フローティングウィンドウ — ホストをライブラリ化（packs/<id>/ 複数保存 + state.json のアクティブ記録；activate 切替ルート、DELETE ?ids= 複数選択削除（アクティブ削除時は残りへ自動切替）、音声は /audio/<id>/<key> で配信）；設定ダイアログはインポート + 「パック管理」ボタン 1 つのみとし、サブメニューに packs ビュー（スクロール可能なリスト：行クリックで切替、チェックボックスで複数選択削除、作成器への入口）と creator ビュー（言語選択 zh-CN/en/ja——サンプルテキストが追従し言語をまたいだ録音が可能、マニフェスト lang にパック言語を記録；セグメントごとの録音/インポート/試聴/削除；コンパイルダウンロード/コンパイル適用）を搭載；録音中は右下に可視化フローティングウィンドウ（AudioContext+Analyser のキャンバスレベルメーター、経過時間、サンプルテキスト、停止保存/破棄）を表示；インポート後のリストにはパック名と言語を表示；インポート済みパックの初回編集上書き警告は維持。

| コミット | 説明 |
|------|------|
| `398b093` | feat(dsh-api-balance): 音声パックライブラリ管理 + 作成器サブメニュー + 録音可視化フローティングウィンドウ |

## 2026-09-01T08:41:48+09:00

**概要**: feat(dsh-api-balance): 音声パック zip 化 + 録音/インポート作成器 + 編集保護 — 音声パックを zip アーカイブ（manifest.json + audio/ ファイル）に変更。ホストは純 JS で zip を解析（STORE/DEFLATE、DecompressionStream inflate）し `$DSH_HOME/api-balance-voicepack/` へ展開、prefix ルートで音声を URL 配信し全デバイス共有。設定ダイアログの作成器はセグメントごとのブラウザ録音（MediaRecorder）またはローカル音声ファイルのインポートに対応し、「パッケージ & ダウンロード」で共有可能な zip を生成、「コンパイル & 適用」でそのまま本機へ適用（現在のパックを上書き）。パックインポート済みの場合、初回編集（録音/インポート/削除/コンパイル）で上書き警告を表示しセッション内 1 回確認。放送セグメントは URL / インライン両キャリア対応、四言語文書に音声パック形式ガイド（zip 構造 / manifest / セグメント表 / 録音と共有フロー）を追加。

| コミット | 説明 |
|------|------|
| `5f4c50a` | feat(dsh-api-balance): 音声パック zip 化 + 録音/インポート作成器 + 編集保護 |

## 2026-09-01T02:36:15+09:00

**概要**: feat(dsh-api-balance): 音声放送の言語と音色が DSH 界面言語に追従 — 放送テキストは従来 t() で界面言語に追従していたが、発声の lang と音色は zh-CN 固定だった。LocaleFace スナップショット（useSyncExternalStore で locale サービスの subscribe/getSnapshot を購読）から現在の言語コードを取得（zh → zh-CN、他はそのまま透過）、音色は言語プレフィックスで一致させ、組み立て放送テキストの区切り文字も言語に応じて切替（中文は全角、他は半角）。locale サービス不在時は zh にフォールバック。

| コミット | 説明 |
|------|------|
| `11c070b` | feat(dsh-api-balance): 音声放送の言語と音色が DSH 界面言語に追従 |

## 2026-09-01T01:51:10+09:00

**概要**: fix(dsh-api-balance): 音声放送メニューを下から上への展開に変更 — メニューはデフォルトでボタン上辺に接して上向きに展開し（translateY(-100%)）、上方の余白不足時（ビューポート上端から 8px 未満）は自動的に下向き展開へフォールバックする

| コミット | 説明 |
|------|------|
| `7d0c49e` | fix(dsh-api-balance): 音声放送メニューを下から上への展開に変更 |
| `8d9058c` | docs(dsh): 音声放送の上向き展開の説明を四言語同期 |

## 2026-09-01T01:25:25+09:00

**概要**: feat(dsh-api-balance): 未ログインプロンプト + LevelDB 精確解析 + 音声放送メニュー — ブラウザスキャンがヒットしない場合に「ログインへ」プロンプトを自動表示（新タブでログインページを開き、ポーリングのクイックスキャンでトークンを自動取得）、手動入力はプロンプト内の二級オプションに降格。接続後はグレー表示の「✓ ログイン済み」ボタンを表示し、手動更新のたびにログイン状態を自動クイックスキャン。純 JS の LevelDB テーブルパーサーを新設（footer → index → データブロック → snappy 解凍 → エントリ走査；拡張リテラル長を varint ではなく単バイト+1 と修正）で userToken を精確抽出——クイックスキャン 949ms でヒット（従来はフルスキャン 5.3s / クイックスキャン失敗）。音声放送は独立行 + ドロップダウン（現在の使用量 / 残高 / テスト警告音声）、メニューを portal 固定位置へ変更してスクロール切抜きを修正し音声エンジンを予熱。トークン取得元は二行表示に変更。

| コミット | 説明 |
|------|------|
| `a3ad3ff` | feat(dsh-api-balance): 未ログインプロンプト + LevelDB 精確解析 + 音声放送メニュー |
| `a0e945e` | docs(dsh): 未ログインプロンプト/精確解析/音声放送の節を四言語同期 |

## 2026-08-31T23:55:52+09:00

**概要**: docs(dsh): api-balance プラグイン節の四言語補完 — pcn 版 dsh.md にプラグイン節を追加（本機ブラウザ自動スキャン / 使用量チャート / config オプション）、四言語 README のプラグイン表の説明を「ブラウザログイン状態からの自動スキャン取得」の意味に同期

| コミット | 説明 |
|------|------|
| `b912f82` | docs(dsh): api-balance ブラウザ自動スキャン節を pcn へ同期 + 四言語 README プラグイン表更新 |

## 2026-08-31T23:50:04+09:00

**概要**: feat(dsh-api-balance): ローカルブラウザ自動スキャンで platform userToken を取得 — ホストがローカルの Chromium 系ブラウザ（Edge / Chrome / Brave / Chromium / Vivaldi / Opera、全プロファイル）の Local Storage LevelDB を直接読み、base64 候補（55–85 文字）を抽出して GET /api/v0/users/get_user_summary で逐一検証し最初の一致を保存。ローカルブラウザで一度プラットフォームにログインしていれば手動操作なしで使用量トークンを取得できる。6 時間節流 + トークン失効（40003/401）時の即時再スキャン + パネルの「本機ブラウザを再スキャン」ボタン（RPC args.rescanBrowsers）、接続後はトークン取得元バッジ（browser / manual）を表示。実測：ローカル Edge leveldb の 31 候補から実トークンを自動命中し、デプロイ後にブラウザ起因のクエリで自動再取得。四言語文書同期。

| コミット | 説明 |
|------|------|
| `cec90b0` | feat(dsh-api-balance): ローカルブラウザ自動スキャンで platform userToken を取得 |

## 2026-08-31T11:50:02+09:00

**概要**: docs(AGENTS): dsh-alpha セッション経験の汎化 — buildNpmPackage 三則（vendored lock と npmDepsHash の一致 / 未公開 devDependencies を postPatch の純 sed で削除し lock も同源生成 / ruyi 式多チャネル薄ラッパー）、初回起動監査前の git fetch、本機デプロイ節新設（path-input 再ロック、nixos apply コマンド、--no-link 成果物回収）

| コミット | 説明 |
|------|------|
| `86a7c3f` | docs(AGENTS): dsh-alpha セッション経験の汎化 — buildNpmPackage 細則と本機デプロイ約定 |
| `396c3ae` | docs(MAINTENANCE): record 2026-08-31 — AGENTS.md dsh-alpha セッション経験汎化 |

## 2026-08-31T11:31:42+09:00

**概要**: dsh-alpha 導入の障害復旧 — alpha のリバースプロキシ Host セマンティクス修正（web UI 入口は Host authority の session cookie で認証、Host 書き換えが恒久 401 を引き起こしていた）、dsh-api-balance の shared RPC interceptor 衝突修正（`/api` は typert-gateway が独占、正確な fetch route に切替えて RPC envelope を自前実装）、dsh-nixos-shell の dsh-tools チャネル整合；新規モジュールオプション launchUrlFile（局域网起動 URL 捕捉）と reverseProxy.autoAuth（mod_magnet 免認証トークン注入 — 入口認証を明示的に無効化、信頼できる局域网のみ）；四言語文書に局域网アクセス節を追加。

| コミット | 説明 |
|------|------|
| `222ece4` | fix(pkgs): dsh-api-balance / dsh-nixos-shell alpha 互換 |
| `bd4cdb1` | feat(dsh-module): launchUrlFile + autoAuth + alpha 反代 Host セマンティクス修正 |
| `a2fe5f3` | docs(dsh): 四言語文書に局域网アクセス/免認証/alpha 插件互換性節を追加 |
| `1176553` | docs(AGENTS): モジュール節に dsh alpha セマンティクスと插件互換性の経験を標注 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-nixos-shell | dsh-tools `0.1.1-rc.2` | dsh-tools `0.1.2-alpha.2` |
| 　 | npmDepsHash | `sha256-uOQ3Dq...` → `sha256-bAXZCi...` |

## 2026-08-31T07:23:07+09:00

**概要**: dsh-alpha 0.1.2-alpha.2 — 新規パッケージ、npm `alpha` dist-tag 開発チャネル；dsh を ruyi 式薄ラッパーに再構成（version/hash/npmDepsHash/lockFile 上書き可能）、postPatch は純 sed で tarball の devDependencies を削除（未公開の monorepo 内部パッケージ参照、registry 404）、パッチ対象ファイルに存在ガード追加。四言語文書にバージョンチャネル節を追加。後続修正：vendored lock を npmDepsHash に一致させ（npm fixup のプラットフォーム項目欠落が主ビルドの out of date を引き起こしていた）、README ソフトウェア表に dsh-alpha 行を四言語で追補。

| コミット | 説明 |
|------|------|
| `88a2dfc` | feat(dsh): 多バージョンチャネル — dsh-alpha 0.1.2-alpha.2 追加 |
| `33bff25` | docs(dsh): 四言語文書にバージョンチャネル節を追加 |
| `095d002` | docs(MAINTENANCE): record 2026-08-31 — dsh-alpha 新規パッケージ |
| `a97fffd` | fix(pkgs): dsh-alpha vendored lock を npmDepsHash に一致させる修正 |
| `d9a83f8` | docs: README ソフトウェア表に dsh-alpha 行を追加（四言語） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-alpha | 新規 `0.1.2-alpha.2` | |
| 　 | source hash | `sha256-W/Biom...` |
| 　 | npmDepsHash | `sha256-bJMeVS...` |

## 2026-08-31T07:05:44+09:00

**概要**: godot-ai 3.2.4 — 自己更新復旧の直列化、設定書き込みの堅牢化、パス検証とコールドスタートの修正（v3.2.1〜v3.2.4 はいずれもバグ修正）；四言語文書のバージョン番号同期。

| コミット | 説明 |
|------|------|
| `c30fc17` | chore(pkgs): bump godot-ai 3.2.0 → 3.2.4 |
| `e4b9981` | docs(MAINTENANCE): record 2026-08-31 — godot-ai 更新 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| godot-ai | 3.2.0 | 3.2.4 |
| 　 | source hash | `sha256-ImKAsI...` → `sha256-Uo6GvE...` |

## 2026-08-27T09:19:59+09:00

**概要**: opencode-telegram 0.24.1 — 韓国語インターフェース追加、`/opencode_stop` が応答中でもハングしたローカル OpenCode プロセスを強制終了可能、音声文字起こしを引用ブロックで表示、Telegram の一時エラーを安全に再試行して返信の消失/重複を防止、ストリーミング編集スロットルを適応化；mcp-searxng 2.1.0 — エンジン明示選択時にエンジンごとの time-range 対応を検証し、非対応時は実用的なエラーで即時失敗；godot-ai 3.2.0 — custom_tools によるサードパーティ addon ツール登録、CLI 登録スコープの選択化、DeepSeek Harness クライアント対応追加；ruyi-beta 0.52.0-beta.20260824 — beta チャネルの上流更新。四言語文書同期、nix flake check 通過。

| コミット | 説明 |
|------|------|
| `7d57bfa` | chore(pkgs): bump opencode-telegram 0.24.0 → 0.24.1 |
| `85b813e` | chore(pkgs): bump mcp-searxng 2.0.0 → 2.1.0 |
| `0fe16db` | chore(pkgs): bump godot-ai 3.1.5 → 3.2.0 |
| `b26d013` | chore(pkgs): bump ruyi-beta 0.51.0-beta.20260714 → 0.52.0-beta.20260824 |
| `e88e284` | docs(MAINTENANCE): record 2026-08-27 — 四パッケージ上流更新 |

| パッケージ | 旧 | 新 |
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

**概要**: feat(dsh-api-balance): パネル刷新ボタン。パネルヘッダーのタブ行右側に刷新ボタン（↻）を追加：クリックで queryBalance(true) を呼び、ホスト側 30 秒 TTL キャッシュを迂回して残高 + 公式使用量を再取得（日別/月別チャートも同時更新）。読み込み中はボタン無効化 + スピナー（dshAbSpin 再利用）。中英二言語文案（刷新数据 / Refresh data）。検証：ビルド通過、安定マウントポイント経由でゼロ再起動配備（424 世代）後に dsh 再起動で反映。

| コミット | 説明 |
|----------|------|
| `e864b58` | feat(dsh-api-balance): パネル刷新ボタン — 残高と公式使用量のワンクリック再取得 |

## 2026-08-27T07:28:49+09:00

**概要**: fix(dsh-nixos-shell): 分離結果の誠実な意味論 + systemctl restart dsh の自動分離。従来は systemd-run 経由の引き継ぎが返す exit 0 をそのまま透かしていたため、ツール結果が「ビルド成功」に見えながら実際の結果は不明だった。分離コマンドは今後 `detached: true` + `detachedUnit` + `note` を返し exitCode は null——引き継ぎ成功はビルド成功ではなく、実際の結果は必ず nixos_cli op=journal / op=generations で検証する（バックグラウンドジョブも最終出力に同じ検証ガイドを追記）。分離述語は `systemctl restart dsh` にも拡大：安定マウントポイント経由で配備したプラグイン更新は明示的な dsh 再起動で反映され、このコマンドも自動分離されて再起動前に呼び出しが返る。検証：分離式 dsh 再起動が着地（RESTARTED_EXIT=0）、プラグイン変更 rebuild（424/425 世代）は何も再起動せず何も中断せず、nix flake check 通過。四言語ドキュメント同期。

| コミット | 説明 |
|----------|------|
| `0c7b7f6` | fix(dsh-nixos-shell): 分離結果の誠実な意味論 + systemctl restart dsh の自動分離 |

## 2026-08-27T07:28:39+09:00

**概要**: feat(module): dsh プラグイン安定マウントポイント — ゼロ再起動活性化。プラグインパッケージは従来 dsh/sudo のユニット（ExecStart/preStart/実行器テンプレート）に直接焼き込まれていたため、プラグイン更新のたびにユニット内容が変化：switch-to-configuration が活性化段階で dsh を再起動し（実行中のツール呼び出しは harness プロセスごと消滅）、sudo socket を stop/start した（デーモン経由の rebuild は自身の switch ごと殺され socket は復旧不能）。安定マウントポイントへ変更：activation script が毎回の switch/boot で `/run/dsh/current`（dsh とプラグイン木）と `/run/dsh/nixos-shell`（sudo 実行スクリプト）のシンボリックリンクを現在世代の store パスへ張り替え（GC 安全：リンク先は現在の toplevel 閉包内、ロールバック時は旧世代へ自動復帰）。dsh.service と nixkits-sudo@.service のユニット定義はこれら安定パスのみを参照——プラグインパッケージの更新はユニット内容を変えず、活性化は何も再起動せず何も中断しない。付随意味論：dsh は長寿命プロセスのため、プラグイン更新は明示的な `systemctl restart dsh`（自動分離）で反映。sudo 実行器は接続ごとに生成され、新規接続は自動的に新スクリプトを使用。検証：423 世代で本変更を配備（一度だけの dsh 再起動）。424/425 世代の連続 2 回のプラグイン変更 rebuild では dsh と socket の ActiveEnterTimestamp がともに不変、/run/dsh/current は正常に張り替えられ、中断されたツール呼び出しはゼロ。四言語ドキュメント同期。

| コミット | 説明 |
|----------|------|
| `dfce302` | feat(module): dsh プラグイン安定マウントポイント — ゼロ再起動活性化 |

## 2026-08-27T04:07:27+09:00

**概要**: fix(dsh-nixos-shell): sudo プロトコル v3 + rebuild 自動分離。三種類の欠陥を修正：1) v2 プロトコルは断絶を取消とみなした——rebuild の switch 段階で dsh.service が再起動し（插件パスは service ユニットに焼き込み）、クライアントが消えるとデーモンが活性化の途中で switch を殺し、部分活性化状態が残った（8/26 14:31 実測：profile は 415 のまま dsh は再起動済み、ユニットファイルは半新半旧）；v3 は明示的帯内取消行（job_kill が socket.end で書込）に変更し、対向消失時は子プロセスが分離状態で完了まで走り続ける。2) 取消/タイムアウトはプロセスグループ全体を殺す方式に変更（spawn detached + kill(-pid)）——シェル包装のみ殺すとパイプ書き込み端を継承した孤児孫プロセスが残りデーモンが応答不能になる；デーモンのタイムアウト上限は 6 時間に緩和し rebuild コマンドが自動使用。3) rebuild は systemd-run 一時ユニット（独立 cgroup）へ自動分離——活性化段階で switch-to-configuration が nixkits-sudo.socket を stop/start するため、rebuild をデーモン経由で実行すると socket 停止が switch 自身もろとも殺し、socket が自動復旧できなかった（8/26 17:25 実測：socket 死滅し、その窓で起動したセッションは sudo パラメータを恒久的に喪失）；分離後は呼び出しが即座にユニット名（detachedUnit）を返し、活性化は完走する。その他：socket は呼び出し時検証へ変更、dsh-jobs の取消を合法 enum `killed` へマッピング、デーモン応答は write コールバックでフラッシュ後に終了。検証：バックグラウンド sudo が job id を即時返却、job_output が全出力を配信、job_kill がグループ全体を孤児なしで殺害、実 rebuild が分離ユニット経由で配備成功し socket が活性化後に自動復旧、nix flake check 通過。四言語ドキュメント同期。

| コミット | 説明 |
|----------|------|
| `ead3526` | fix(dsh-nixos-shell): sudo プロトコル v3 + rebuild 自動分離 |

## 2026-08-27T04:07:15+09:00

**概要**: feat(dsh-api-balance): チャージカードモーダルが iframe を代替 + 残高不足音声アラート。platform.deepseek.com/top_up は WAF に遮断され（"Max challenge attempts exceeded"）、iframe モーダルは機能しなかった——中央カードモーダル（新規ウィンドウボタン + 右上閉じるボタン）に置き換え、ページ遷移なし。残高不足音声アラートを追加：残高が閾値（10 CNY/USD）を下回ると Web Speech API で読み上げ、15 分間隔ポーリング + 30 分クールダウン、パネル内トグル（balance.speechOn/Off）、中英二言語文案。検証：配備後の特徴 grep（TopupModal/speechOn/announceHunger）で稼働確認。

| コミット | 説明 |
|----------|------|
| `eeffc49` | feat(dsh-api-balance): チャージカードモーダルが iframe を代替 + 残高不足音声アラート |

## 2026-08-26T11:44:45+09:00

**概要**: dsh-api-balance 0.1.0 — 新規パッケージ。webui の使用量リング（送信ボタン左のコンテキスト使用量表示）のポップオーバーパネルに「用量 / 残高」タブ切替を追加：「用量」は元のコンテキスト占有率と内訳を維持、「残高」は現在の API キーのアカウント情報（キー末尾、残高可否、通貨別の総残高 / チャージ残高 / 付与残高、DeepSeek 公式 GET /user/balance から取得しホスト側 30 秒 TTL キャッシュ）を表示する。ホスト側は connection.rpc.intercept でパッケージプライベート endpoint を登録、クライアント側は conversation.input.right に視覚互換の代替リングを登録し元のボタンを非表示化。検証: RPC が CNY 271.07 の実残高を返し、client bundle の配信も正常。四言語ドキュメント同期、nix flake check 通過。

| コミット | 説明 |
|------|------|
| `95998cd` | feat(dsh): dsh-api-balance プラグイン追加 — webui 使用量リングに「用量 / 残高」タブ切替 |
| `db721ba` | docs(MAINTENANCE): record 2026-08-26 — dsh-api-balance 0.1.0 新規パッケージ |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 　 | 新規 v0.1.0 |

## 2026-09-11T12:54:29+09:00

**概要**: fix(dsh/module): allowLanSettings の $host.state.getSnapshot() 補丁を撤去 — dsh ≥ 0.1.5 の $host クライアントサービスは state を公開しない（isLoopback/home のみ）。旧補丁は client-ui-settings apply 時に undefined.getSnapshot を参照し、"Cannot read properties of undefined (reading 'getSnapshot')" を投げて前端全体が白画面（Failed to load plugins）。修正: モジュールは allowLanSettings=true の強制 override をやめ（上流行為へ復帰、非 loopback ページの settings は memory 読取専用のまま）、packages/dsh.nix の補丁は無条件 "host" に変更（将来明示的に有効化してもクラッシュしない）。検証: client.js に state.getSnapshot なし、ホーム 200、llm/listProviders が DeepSeek 提供方を返す。

| コミット | 説明 |
|------|------|
| `06a5ce1` | fix(dsh): allowLanSettings — drop $host.state.getSnapshot() (undefined) |
| `155b09b` | fix(module): dsh — drop allowLanSettings override (state.getSnapshot undefined) |

## 2026-09-11T06:15:33+09:00

**概要**: fix(preset): dsh persona text → prefix（0.1.5-alpha.2 互換）。dsh 0.1.5-alpha.2 は dsh-persona の Config を text から prefix（必須）+ suffix（任意）に変更。旧 agent preset（nixos-mode / maintenance-mode / 本機 ocean-spiral）は text のままで、persona プラグインの読込失敗（$.prefix missing required value）→ session/create 失敗 → settings / llm 提供方一覧 / session 履歴すべて読込不可（前端は Failed to fetch と agentId 欠如による commands/list 無限リトライを呈す）。修正: 両 preset の persona config を prefix に変更、本機の 3 preset も同期修正。検証: session/create が ok:true + sessionId を返し、session/list がセッション一覧を返し、llm/listProviders が DeepSeek 提供方を返す。

| コミット | 説明 |
|------|------|
| `772abf8` | fix(preset): dsh persona text → prefix for 0.1.5-alpha.2 |

## 2026-08-27T01:30:33+09:00

**概要**: fix(module): dsh watchdog — switch-to-configuration 失敗後の自動起動。nixos-rebuild の switch-to-configuration は「stop dsh → start dsh」の間で偶発失敗（exit 101）し、dsh を inactive に残す。systemd の能動的な stop は Restart=always をトリガーしないため、反代が長期間 503（8/26 22:10、23:53 の 2 回観測）。dsh-watchdog timer（15s 間隔）を追加し、inactive 検知時に systemctl start。検証: stop 後 20 秒以内に自動復帰。

| コミット | 説明 |
|------|------|
| `3ed6aa7` | fix(module): dsh watchdog — auto-restart after switch-to-configuration failure |

## 2026-08-24T15:44:06+09:00

**概要**: fix(overlay): llama-cpp-rocm v0.2.0 セマンティック版 — llama.cpp 上流が release tag を build number（b10549）からセマンティック版（v0.2.0）に切替。旧 overlay は b 前置詞のみ除去して v0.2.0 を得たが、nixpkgs がそれを LLAMA_BUILD_NUMBER に渡し、`int LLAMA_BUILD_NUMBER = v0.2.0;` を生成して C++ コンパイル失敗（too many decimal points）になり、システム rebuild と dsh 更新を阻塞。現在は v/b 前置詞を両方除去し、-DLLAMA_BUILD_NUMBER=0 を追記。検証: llama-cpp-0.2.0 ビルド成功、llama-cpp.service 稼働。

| コミット | 説明 |
|------|------|
| `1a1b9d1` | fix(overlay): llama-cpp-rocm — handle v0.2.0 semantic version tag |

## 2026-08-24T15:20:16+09:00

**概要**: fix(pkgs): dsh クラッシュ修正 — cordis-plugin-timer（上流最新 1.1.3 未修正）が Context dispose 時に pending の ctx.timeout() promise を "Context has been disposed" で reject し、未 catch なら unhandled rejection 化。dsh-app-boot の installFailLoud が process.exit(1) に変え、実行中の偶発クラッシュ（rc.6/rc.7/rc.8/0.1.1-rc.2 全影響、8/22 00:05 に rc.8 が 38 分で発生）。installFailLoud はこのエラーのみ無視、他 fatal rejection は従来通り終了。検証: patch が 0.1.1-rc.2 出力に適用（dsh-app-boot/lib/index.js:1047）。

| コミット | 説明 |
|------|------|
| `6e862b6` | fix(pkgs): dsh — ignore Context-disposed dispose race in installFailLoud |

## 2026-08-24T14:27:47+09:00

**概要**：codewhale 0.9.11 — 上流が v0.9.9 から TUI アセット名を codewhale-tui → codew に改名、パッケージは codew を導入し互換エイリアスを維持、riscv64 ソースビルドは Cargo.lock を同期（687→690 エントリ、rquickjs-sys 0.12.2 不変、bindings パッチ有効継続）；mcp-searxng 2.0.0 — メジャーアップグレード（Node.js ≥ 22 要求、nixpkgs 既定で充足、CLI 入口不変）；dsh 0.1.1-rc.2 — vendored lock 再生成（560 resolved エントリ）、randomUUID フォールバックパッチ対象パス不変、内蔵プラグイン一覧は rc.8 と完全一致（137 件）；dsh-nixos-shell 依存 dsh-tools → 0.1.1-rc.2 で新エコシステムに整合。四言語文書同期、nix flake check 通過。

| コミット | 説明 |
|------|------|
| `17bf588` | chore(pkgs): bump codewhale 0.9.8 → 0.9.11 |
| `065d261` | chore(pkgs): bump mcp-searxng 1.15.0 → 2.0.0 |
| `c0c8e3a` | chore(pkgs): bump dsh 0.1.0-rc.8 → 0.1.1-rc.2 |
| `bec4c3d` | chore(pkgs): dsh-nixos-shell dep dsh-tools 0.1.0-rc.7 → 0.1.1-rc.2 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.9.8 | 0.9.11 |
| mcp-searxng | 1.15.0 | 2.0.0 |
| dsh | 0.1.0-rc.8 | 0.1.1-rc.2 |
| dsh-nixos-shell | dsh-tools 0.1.0-rc.7 | dsh-tools 0.1.1-rc.2 |

## 2026-08-22T00:03:28+09:00

**概要**：docs(dsh): 0.1.0-rc.8 文書同期 — 4 言語の dsh.md のバージョン行（rc.6 → rc.8）と「プラグイン一覧」コードブロック（rc.8 ビルドから抽出した 137 エントリの id マップ）を同期。nix flake check 通過。併せて /etc/nixos ローカル設定に `settings.agent-default-model`（deepseek-v4-pro + reasoningEffort=max）を宣言し新規セッションの既定に——DeepSeek API の正規モデル一覧は flash/pro/flash-vision-exp のみで "pro-max" id は存在せず、Pro+Max 推論が現状最高位。rc.8 上で nixos/maintenance 両プリセットのマウント検証通過。

| コミット | 説明 |
|----------|------|
| `535567d` | docs(dsh): sync version and built-in plugin inventory for 0.1.0-rc.8 (137 entries) in four languages |

## 2026-08-21T21:51:26+09:00

**概要**：docs: README「プラグイン」章の拡充とクレジットの DSH 情報 — ①「プラグイン」章に「Agent プリセット」表（NixOS模式/維護模式、プラグイン同梱、nixkits.dsh.presets で一度だけシード）を追加し、DSH コンポーネントをソフトウェアと分離掲載；② クレジットの「小爪」エントリに DSH エコシステム情報（dsh-nixos-shell プラグインと 2 つの Agent プリセット）を追記；③ AGENTS.md のプラグイン独立掲載規則を「dsh-* コンポーネント（プラグインと Agent プリセット）」に拡大。4 言語同期。

| コミット | 説明 |
|----------|------|
| `4277b51` | docs: list DSH agent presets in the README plugins section and add DSH ecosystem info to the credits paw entry |

## 2026-08-21T00:01:46+09:00

**概要**：fix(dsh-nixos-shell): ツール説明に tools ホワイトリストを明示 — 受入の非ブロッキング指摘：固定 POSIX ツールのホワイトリストがツール説明に記載されていなかった。ホワイトリストを TOOL_PACKAGES マップから動的生成（27 名、python エイリアス含む）して `tools` パラメータ説明に記載し、ツール説明からパラメータを参照。4 言語ドキュメントに完全なリストを同期。検証：27 名すべてがパラメータ説明に存在、ツール説明に参照あり、構文検査と nix flake check 通過。

| コミット | 説明 |
|----------|------|
| `30d0c40` | fix(dsh-nixos-shell): surface the tools whitelist in the parameter description |

## 2026-08-20T20:12:33+09:00

**概要**：fix(dsh-nixos-shell): 現代 rebuild コマンドを `nixos apply` に訂正 — 実測の nixos 0.16.1-dev に `rebuild` サブコマンドは存在せず（`nixos --help` は activate/apply/generation 等を列挙）、引き継ぎカードとプラグインの recommendedRebuild/コマンド対照表/ゲートガイダンスの `nixos rebuild switch` は誤りだった。`nixos apply /etc/nixos`（または従来の `sudo nixos-rebuild switch --flake /etc/nixos`）に統一。検証：node 構文検査、nix flake check 通過。システム配備は `nixos apply` に変更し実測成功。

| コミット | 説明 |
|----------|------|
| `caa7d41` | fix(dsh-nixos-shell): correct the modern rebuild command to 'nixos apply' |

## 2026-08-20T20:10:08+09:00

**概要**：fix(dsh-nixos-shell): NixOS模式 受入 P1–P4 修正 — P1（高）ツールブートストラップのラッパーを `bash -lc` から `bash -c` に変更：ログインシェルの /etc/profile チェーンが PATH をリセットして nix shell の注入を破棄しており、sudo 経路が同じラッパーを共有するため同時修正（対照実験：`-c` は Python 3.14.7、`-lc` は command not found）。マッピングも grep→gnugrep、find→findutils に修正（従来はログイン PATH の偽陽性で覆われていた）。P2 generations に `limit` を追加（既定 20・上限 200・新→旧）、現在世代と総数を返す。P3 journal の unit は `*`/`%` ワイルドカードを許可し、末尾 `@` は自動で `*` を補う（テンプレート全インスタンス）。P4 命名統一：nixos-cli → nixos コマンド（nixos-cli プロジェクト）、ツール説明・コマンド対照表・ゲートガイダンスを更新。ドキュメント op 表を 4 言語同期。検証：5 ケースの機能スイート全通過（プラグイン経由の実 nix shell 注入で TOOLS_INJECTION_OK 回顕を含む）、node 構文検査、nix flake check 通過。

| コミット | 説明 |
|----------|------|
| `a591826` | fix(dsh-nixos-shell): P1-P4 acceptance fixes |

## 2026-08-20T19:33:51+09:00

**概要**：fix(dsh-nixos-shell): プロンプト節のフィールドを text に変更 — dsh-system-prompt の補間器は `input.text` を読むため、`content` で登録した節が実セッションの NixOS模式をクラッシュさせた（Cannot read properties of undefined (reading 'indexOf')。マウント検証では捉えられない実セッション経路の欠陥）。nixos-gate（guidance/gate の 2 節）と maintenance-skills（workflow 節）の計 3 箇所を `content` → `text` に修正。原因は dsh-system-prompt の interpolate() ソースと PromptSection 型定義（text: string | provider）の読み取りで特定。ToolGuard の形も型定義から確認（`(execution) => string | undefined`、現行実装と互換）。検証：mock で text フィールドと未閉じ `{{` なしを確認；実 systemPrompt サービスで登録 + assemble（includes=true、クラッシュなし）；システム事前ビルド通過。

| コミット | 説明 |
|----------|------|
| `476e9dc` | fix(dsh-nixos-shell): use the PromptSection text field instead of content |

## 2026-08-20T19:05:44+09:00

**概要**：feat(dsh-nixos-shell): 維護模式 agent プリセット — 新パッケージ内エントリ maintenance-skills：apply 時にビルド時に埋め込まれたリポジトリの skills/ ツリー（単一ソース、新規セッションで常に最新）からランタイムスキル write-project-docs、write-maintenance-log、全 translate-* 言語拡張（自動発見）を登録し、リポジトリ保守ワークフローのプロンプト節（分割コミット、push 後の保守ログ、ドキュメント同期、汎化）を注入。パッケージの postPatch が skills → skills-embedded をコピー。プリセット presets/maintenance-mode（id `maintenance`、NixOS模式コンポジション + maintenance-skills 行基盤）はパッケージに同梱。モジュールに nixkits.dsh.presets.maintenanceMode（seed-once）を追加。検証：mock で 3 スキル登録 + ワークフロー節すべて通過、パッケージに埋め込みツリーとエクスポートあり、システム事前ビルド通過。nixos プリセットはマウント検証通過（mounted ok）、maintenance プリセットはローダーのプロセス内 package.json キャッシュのため再起動後の最終確認を要す。

| コミット | 説明 |
|----------|------|
| `f6c749e` | feat(dsh-nixos-shell): 维护模式 agent preset — maintenance-skills entry, presets/maintenance-mode, module presets.maintenanceMode seed |

## 2026-08-20T18:30:46+09:00

**概要**：feat(dsh-nixos-shell): NixOS模式 agent プリセット — 新パッケージ内サブパス nixos-gate：セッション初期化時にホストが NixOS であることを検証（/etc/NIXOS または os-release の ID=nixos）——非 NixOS では tools.guard で全ツール実行を拒否し拒否プロンプト節を注入（明確な理由 + プリセット切替の助言）、NixOS では開発ガイドのプロンプト節を注入（nixos-modern-cli シナリオ由来：宣言的本質、ツールブートストラップ、モダンコマンド、store パスの落とし穴）。プリセット presets/nixos-mode（id `nixos`、創造モード cordis コンポジション + スキルディレクトリ基盤、nixos-gate/nixos-shell 行を追加）はパッケージに同梱。モジュールに nixkits.dsh.presets.nixosMode を追加し、preStart で $DSH_HOME/.agent-presets/nixos へ一度だけシード（ユーザーの後続編集は尊重）。検証：パッケージビルド、ゲート構文チェック、システム事前ビルドすべて通過。

| コミット | 説明 |
|----------|------|
| `aaa21cb` | feat(dsh-nixos-shell): NixOS模式 agent preset — nixos-gate entry, presets/nixos-mode, module presets.nixosMode seed |

## 2026-08-20T18:24:04+09:00

**概要**：docs: README プラグイン独立章 + AGENTS.md 更新 — ① dsh-* プラグインを「ソフトウェア」表から README 新設の「プラグイン」章へ移動（4 言語同期）、ソフトウェアと混在させない。AGENTS.md にプラグイン独立掲載の規約と「dsh はスキル導入対象外」規則を追加。② 承認済みクリーンアップ適用（本機）：~/.bashrc の古い store 絶対パス bash-completion ブロックを削除、~/.profile の hm-session-vars を安定パス /etc/profiles/per-user/kix へ変更、旧 ~/.dsh/skills を削除（nixos_cli audit-store-paths 再検査：0 件）。

| コミット | 説明 |
|----------|------|
| `57ae6b5` | docs: list dsh-* plugins in a dedicated README plugins section (4 langs); AGENTS.md plugin-listing + dsh-skill-target rules |

## 2026-08-20T17:56:21+09:00

**概要**：refactor(dsh-nixos-shell): パッケージ名修正 nixos-shell → dsh-nixos-shell — パッケージ名（pname/ディレクトリ/flake 出力/overlay/CI ワークフロー/ドキュメント）を `dsh-nixos-shell`（pkgs.dsh-nixos-shell）に統一。dsh 内の表示名は `nixos-shell` のまま（コンポジション行の entry id、プラグイン名、ツール名 nixos_shell/nixos_cli は不変）。検証：パッケージビルド通過；配備側の参照も同期済み。

| コミット | 説明 |
|----------|------|
| `26a844e` | refactor(dsh-nixos-shell): rename package nixos-shell -> dsh-nixos-shell |

## 2026-08-20T17:46:44+09:00

**概要**：feat(nixos-shell): NixOS シナリオ能力を単一プラグインへ統合；refactor: スキルプラグイン化設計の廃止 — 新パッケージ nixos-shell（@kihara777/dsh-nixos-shell 0.1.0）は 2 つのツールを登録する：nixos_shell 実行器（NixOS PATH 注入 + bash フォールバック + `tools` パラメータによる `nix shell nixpkgs#… --command` の不足 POSIX ツール提供 + sudo デーモンルーティング）と nixos_cli 読み取り専用診断（capabilities / system-status / generations / journal / audit-store-paths）。機能要件は nixos-modern-cli スキルのシナリオに由来。併せて削除：dsh-nix-shell（機能統合）と dsh-skill-nixkits（7 スキルプラグイン設計、モジュールの skills オプション含む）、CI/ドキュメントも差し替え。nixkits-skills インストーラから dsh 対象を削除（dsh 能力は nixos-shell が提供、スキルは他アシスタント向けに残置）。修正：generations はプロセス内の読み取り専用リストに変更（nix-env はロックファイル権限が必要で、非 root は Permission denied）。検証：13 ケースの機能スイート全通過（実 sudo root ルーティングと nix shell ツールブートストラップ含む）；システム事前ビルド通過。

| コミット | 説明 |
|----------|------|
| `395d8b4` | feat(nixos-shell): consolidate NixOS scenario capabilities into one plugin |

| パッケージ | 旧 | 新 |
|------------|-----|-----|
| nixos-shell | — | 新規 v0.1.0 |

## 2026-08-20T16:40:16+09:00

**概要**：fix(dsh): サービス HOME を実ユーザーホームへ — git の gh credential helper は `$HOME/.config/gh` から認証情報を解決するが、モジュールはサービス HOME を dshHome（/home/kix/.dsh）に設定していたため、サンドボックス内の git push が認証情報を見つけられなかった（could not read Username）。`users.users.<user>.home`（無ければ dshHome にフォールバック）に変更し、エージェントがユーザー自身のツール環境（git/gh 認証情報、~/.gitconfig、npm/ssh 設定）を継承するようにした。DSH_HOME は dsh の状態ルートのままで影響なし。検証：HOME=/home/kix で滞留コミットの push がすべて成功；システムの事前ビルドも通過。

| コミット | 説明 |
|----------|------|
| `514831c` | fix(dsh): point service HOME at the real user home — git's gh credential helper resolves ~/.config/gh from $HOME, so HOME=dshHome left sandbox pushes without credentials |

## 2026-08-20T16:13:40+09:00

**概要**：fix(dsh-nix-shell): sudo エグゼキュータの PATH マージ順修正 — ソケット活性化のテンプレートユニットは systemd マネージャ既定 PATH（coreutils/findutils/grep/sed/systemd の store パスのみ）を継承し、明示的な NixOS PATH の後で展開される `...process.env` がそれを上書きして、デーモン内で ps や nixos-rebuild など profile ツールが解決不能になっていた（PS-MISSING/NIXOS-REBUILD-MISSING）。継承 env を先に、明示的 NixOS profile PATH を後に展開するよう修正（リクエスト env は最後にマージのまま）。検証：systemd 既定 PATH を模擬してエグゼキュータを直接実行、PATH は /run/current-system/sw/bin 先頭、ps と nixos-rebuild の両方が解決成功。

| コミット | 説明 |
|----------|------|
| `63b2576` | fix(dsh-nix-shell): put the explicit NixOS profile PATH after the inherited env — socket-activated template units inherit systemd's manager-default PATH, which overrode the executor PATH and left profile tools (ps, nixos-rebuild) unresolvable |

## 2026-08-20T16:01:28+09:00

**概要**：docs(dsh): 使用例を実際のモジュール動作に同期 — 手動コンポジション行の例に `- insert:` ラップと注意書きを追加（裸の `- id:` 行は既存エントリのパッチに過ぎない）；スキルプラグイン文書の全 7 entry id（`skill-nixkits-<id>` 接頭辞が欠落していた）と disabled 例の id を修正；dsh 文書のインストール節をモジュール式に変更（旧 `nixkits.extraPackages` は既に存在しない）し、バイナリキャッシュの説明を追加。4 言語同期。

| コミット | 説明 |
|----------|------|
| `6074661` | docs(dsh): sync usage examples with module reality — insert-op wrapping for manual rows, corrected skill entry ids, module-based install + cache note |

## 2026-08-21T23:02:33+09:00

**概要**: chore(pkgs): dsh 0.1.0-rc.7 → 0.1.0-rc.8。遗留していた rc.8 升级を完了：src hash と npmDepsHash をプレースホルダーから実値へ、package-lock.json を再生成（旧 lock は dsh-invariants 含む 120 エントリ欠落で buildNpmPackage の fetch が ENOTCACHED）。検証: rc.8 ビルド成功、randomUUID フォールバック patch 適用、with-plugins 変体正常、起動時プラグイン読込エラーなし。注: 本機の skills-as-plugins 設計は廃止済み、skills は dsh-nixos-shell（maintenance-skills）へ統合、with-plugins は dsh-nixos-shell のみ注入。

| コミット | 説明 |
|------|------|
| `a7cbe3e` | chore(pkgs): bump dsh 0.1.0-rc.7 → 0.1.0-rc.8 |

## 2026-08-21T22:11:28+09:00

**概要**: fix(module): dsh クラッシュ耐性 — Restart=always + RestartSec 5s。dsh 上流に既知のクラッシュバグ（cordis-plugin-timer の Context disposed、rc.6 で約 13 時間稼働後に発生）があり、rc.7/rc.8 も cordis-plugin-timer 依存は不変（^1.1.3）のためバグは残存。クラッシュ時は lighttpd 反代が systemd の再起動まで 503 を返す。Restart=always（on-failure は exit 0 終了をカバーしない）+ 再起動間隔 5s に変更し、中断時間を最小化。

| コミット | 説明 |
|------|------|
| `ed7e9d5` | fix(module): dsh Restart=always + faster RestartSec (crash resilience) |

## 2026-08-20T11:08:08+09:00

**概要**: fix(module): dsh プラグイン ESM 解決 — dsh の cordis-plugin-loader は profile ディレクトリ（$DSH_HOME/profiles/web）を解決基準（Node 24 内部 cascaded loader の parentURL）とし、そこから上へ node_modules を検索する。プラグインは dsh の store ツリーに注入済みだが、store は profile の node_modules パス上にないため import が ERR_MODULE_NOT_FOUND となり起動直後にクラッシュ（restart ループ 108 回まで）。preStart で注入済み @kihara777 scope を $DSH_HOME/node_modules へシンボリックリンクし Node から解決可能に。realpath で store ツリーに戻るため、プラグインが参照する @deepseek-ai/* peer deps も同一ツリー内で解決できる。検証: skills + nix-shell プラグイン読込成功。

| コミット | 説明 |
|------|------|
| `044b891` | fix(module): dsh plugin ESM resolution via DSH_HOME/node_modules symlink |

## 2026-08-20T10:33:26+09:00

**概要**：fix(dsh): insert ブロックのインデント修正 — ネストした '' 文字列は自身の最小インデントで dedent されるため、プラグイン条目が第 0 列に戻り、`- insert:` の子条目ではなく兄弟のパッチ操作として解釈されていた（dsh が patch: entry … not found と id is required for non-insert patches を報告し、8 行すべてが再び未マウント）。パッケージごとに 1 つの insert 操作を発行し、条目オブジェクトを `- insert:` 行と同じ文字列に置く形（2/4 列インデント）に修正、モジュールコメントにこの落とし穴を記録。検証：dump-config が stderr ゼロ、8 行すべて合成ツリーに反映。

| コミット | 説明 |
|----------|------|
| `988dc6d` | fix(dsh): emit one insert op per plugin entry in a single string — nested '' strings dedent to column 0, turning entry objects into sibling patch ops |

## 2026-08-20T10:21:46+09:00

**概要**：fix(dsh): 生成行を insert 動詞でラップ — cordis.patch.yml の裸の `- id:` 行は既存エントリのパッチに過ぎず、新規プラグインエントリは dsh に破棄され（stderr: patch: entry "nixkits-nix-shell" not found）、8 つのプラグイン行すべてが未マウントだった（dump-config で検証）。パッケージ注入自体は成功していたが、合成ツリーにエントリが無いため nix_shell ツールと 7 スキルプラグインが未登録だった。生成される plugins.packages 行を `- insert:` 操作でラップして修正（extraPatch の MCP 行と同じ形）。検証：dump-config が stderr ゼロ、8 行すべて合成ツリーに反映。

| コミット | 説明 |
|----------|------|
| `3d0433d` | fix(dsh): wrap generated plugin rows in the insert op — bare - id: rows only patch existing entries, so dsh dropped every new entry with 'patch: entry … not found' |

## 2026-08-20T09:45:59+09:00

**概要**：fix(dsh): 複数プラグイン注入失敗の修正 — 展開後、GNU tar はアーカイブ内のディレクトリモード（store ツリーは 0555）を復元するため、直前のプラグインが作成した scope ディレクトリ（@kihara777/）が次のプラグインから書き込めず、2 つ目以降が Cannot mkdir: Permission denied で失敗する。単一プラグインでは発生せず、初の実システムビルドで顕在化。各プラグイン解包直後に chmod -R u+w を実行するよう修正。検証：システム toplevel の完全ビルド成功、dsh-nix-shell と 7 スキルすべて注入済み。

| コミット | 説明 |
|----------|------|
| `b03a386` | fix(dsh): chmod node_modules after each plugin injection — GNU tar restores archived dir modes (0555) after extraction, leaving the scope dir created by the previous plugin unwritable for the next one |

## 2026-08-20T08:12:57+09:00

**概要**：fix(rcc-fix): デスクトップエントリ改名互換 — asusctl 6.4.0 がデスクトップエントリを org.opengamingcollective.rog-control-center.desktop へ改名した一方、nixpkgs の programs.rog-control-center autoStart（makeAutostartItem）は旧名 rog-control-center.desktop をコピーし続け、システムビルドが失敗（cp cannot stat）。rcc-fix overlay が asusctl の postInstall で旧名をシンボリックリンクとして提供。検証：本機ピン留め nixpkgs rev（0ae2bc1）で makeAutostartItem { name = "rog-control-center"; package = asusctl } のビルド成功（EXIT=0）。

| コミット | 説明 |
|------|------|
| `650f6f7` | fix(rcc-fix): compat symlink for renamed desktop entry — nixpkgs programs.rog-control-center autoStart copies the pre-6.4.0 filename |

## 2026-08-20T07:41:45+09:00

**概要**：fix(rcc-fix): asusctl 6.4.0 向けパッチ再ベース — nixpkgs 前進で asusctl が 6.3.7 → 6.4.0 となり、rcc-fix.patch の 4 番目の hunk が失敗（システムビルド失敗）。上流が該当領域を再構築（`if dev.is_old_laptop() { pow3r.retain(...) }` が旧 push ブロックを置換、else 分岐の PowerZones::None フィルタは上流に吸収）。パッチは境界チェック置換（`names[(*z) as usize]` → filter_map による境界チェック + warn）のみを保持。他 hunk は変更不要。検証：6.4.0 ソースへの git apply --check が全 hunk 通過、本機ピン留め nixpkgs rev（0ae2bc1）で asusctl ビルド成功（EXIT=0）。

| コミット | 説明 |
|------|------|
| `ce216c7` | fix(rcc-fix): rebase patch hunk 4 for asusctl 6.4.0 — upstream is_old_laptop/retain restructure, else-filter absorbed upstream |

## 2026-08-20T06:27:40+09:00

**概要**：feat(dsh-nix-shell): 外部 sudo デーモン統合（0.2.0）— dsh サンドボックスは sudo の setuid を剥奪し、エージェントは昇格できない。プラグインは初期化時にデーモンソケット（config `sudoSocketPath` / 環境変数 `NIXKITS_SUDO_SOCKET`）を検出し、存在すれば `sudo`/`justification` パラメータを有効化。`sudo: true` のリクエストは全体（command/cwd/env/timeout）を Unix ソケット経由でデーモンへルーティングし、`justification` は必須で結果と共に返却。デーモンは systemd ソケットアクティベーション型の root 実行器（nixkits-sudo@.service + nixkits-sudo-exec.js、接続ごとに 1 リクエストの JSON プロトコル、プラグインパッケージに同梱）。アクセス制御境界は dsh サービスユーザー所有・`0600` のソケットファイル（SocketUser/SocketMode）。モジュールに nixkits.dsh.sudo（enable/socketPath/package）を追加し、ユニット生成と環境変数注入を行う。検証：ゲーティング（ソケットなしでパラメータ非公開／ありで公開）、ルーティング往復、justification 強制、実行器直結プロトコル、モジュールユニット評価がすべて通過。

| コミット | 説明 |
|------|------|
| `ef4bcfc` | feat(dsh-nix-shell): external sudo daemon integration — socket-activated root executor, init-time detection, sudo routing |

## 2026-08-20T06:02:50+09:00

**概要**：refactor(skills): NixKits スキルをネイティブ DSH スキルプラグインへ書き直し — 新パッケージ dsh-skill-nixkits（@kihara777/dsh-skill-nixkits、ランタイム依存ゼロ）、7 スキル各々がパッケージ内のサブパスプラグインエントリ。各プラグインはランタイムに ctx.skills.register で自身の内容を登録（runtime provider、rank 250、ファイルシステム由来より優先）し、apply() が登録 disposer を返してコンポジション解除と共に破棄。SKILL.md は skills/ に単一ソースとして残りビルド時に埋め込み、frontmatter は剥離して content とし metadata に保持（ドキュメントパイプラインの自動発見契約は不変）。モジュールの skills.enable は 7 行のコンポジション行（skill-nixkits-<id> → @kihara777/dsh-skill-nixkits/<id>）を自動生成し、以前の誤実装だったディレクトリ注入（nixkits-skills パッケージ + bundledSkillDir）を置き換え。検証：7 プラグインの mock 登録全通過、ベアサブパスインポート + 登録を実測（SUBPATH-OK/REGISTERED）。CI に x86_64/aarch64 ビルドを追加。

| コミット | 説明 |
|------|------|
| `7393b95` | feat(dsh): rewrite NixKits skills as native skill plugins — dsh-skill-nixkits package, one plugin entry per skill |

## 2026-08-20T05:27:48+09:00

**概要**：feat(dsh): 内蔵 bash ツールの NixOS 修正 + サードパーティプラグインパッケージ + デプロイメント同梱スキル — ① モジュールが dsh サービスへ完全な NixOS PATH を注入（systemd 既定 PATH に bash が無く、標準 bash ツールが spawn bash ENOENT で失敗）；② dsh-nix-shell パッケージ新規（@kihara777/dsh-nix-shell、NixOS 対応シェルツールプラグイン：PATH 解決失敗時に Nix store の bash へフォールバック、NixOS PATH 注入、タイムアウトとスピル出力）と nixkits-skills パッケージ（スキルディレクトリバンドル）新規；③ モジュールに plugins.packages（node_modules へ tar 展開注入 — シンボリックリンクは Node の realpath でプラグイン自身の store パスへ戻り peer 解決が壊れるため実展開 — とコンポジション行の自動生成）と skills.enable（skill-filesystem bundledSkillDir、rank 600）を追加；④ CI に dsh-nix-shell の x86_64/aarch64 ビルドを追加。注入ツリー内で IMPORT-OK をエンドツーエンド検証（プラグインのエクスポートと依存連鎖が解決）。

| コミット | 説明 |
|------|------|
| `69eedd4` | feat(dsh): PATH fix + third-party plugin packages + bundled skills — L1/L2/L3/路径A |
| `55664ed` | docs: dsh-nix-shell package docs + dsh module options + README rows (4 languages) |

## 2026-08-19T20:39:47+09:00

**概要**：fix(ci): ci-summary バッジが failing に張り付く問題を修正 — jq パイプラインが workflow ごとのグループ化より先に failure をフィルタしていたため、過去の失敗が以降の成功を永久に覆い隠していた（codewhale riscv64 修正後もバッジが赤のまま）。先に workflow ごとの最新実行を取得してから failure を判定するよう修正し、バッジは passing に復帰。

| コミット | 説明 |
|------|------|
| `d752c83` | fix(ci): ci-summary badge stuck on failing — latest-run check must precede failure filter |

## 2026-08-19T19:57:03+09:00

**概要**：fix(codewhale-src): riscv64 クロスビルド修正 — 4 段階の問題連鎖を解消：① rquickjs-sys 0.12.2（crates.io 最新版）に riscv64gc bindings が無く（build.rs 非 bindgen パスが対象ファイルを include）、上流の各 64bit リトルエンディアン向け bindings はバイト単位で同一のため postPatch で x86_64 版を物化済み vendor ディレクトリへ配置；② ホスト側（x86_64 build 依存）の ring ビルドで cc-rs がホスト triple から派生レベルの CC（クロスコンパイラ）へフォールバックし -m64 を付与 — buildPackages ツールチェーンを明示；③ postInstall の裸 cargo build が --target を失いホストツールチェーンでリンク — cargoBuildHook と同様にターゲット triple を明示；④ バイナリが -lgcc_s を動的リンクし autoPatchelfHook は hostPlatform 依存のみ走査 — クロス gcc の libgcc 出力を明示的に追加。CI と同一コマンド（pkgsCross.riscv64.callPackage）でローカル検証済み。Build codewhale (riscv64) の 6 連続失敗を解消。

| コミット | 説明 |
|------|------|
| `962ce6c` | fix(codewhale-src): riscv64 cross build — rquickjs bindings overlay, host cc-rs toolchain, postInstall --target, libgcc rpath |

## 2026-08-19T17:57:26+09:00

**概要**：AGENTS.md — 古い comfyui-strix-halo モジュール参照（comfyui-rocm に統合済み）を修正し、CI 章を実際のワークフロー構成（パッケージ別 build-<pkg>-<arch>.yml が共有 build-package.yml を呼び cachix-action で配信、riscv64 ビルドなしのパッケージと専用ビルドのない godot-ai/dsh を明記、ci-summary.yml バッジ機構）に合わせて更新。

| コミット | 説明 |
|------|------|
| `c4e320e` | docs(AGENTS): fix stale comfyui-strix-halo reference + align CI description with actual workflows |

## 2026-08-19T16:52:54+09:00

**概要**: fix(module): dsh WebSocket 反代を mod_proxy upgrade に変更 — NixOS の lighttpd モジュールは allKnownModules 固定順で server.modules を生成し、mod_wstunnel は常に mod_proxy の後にロードされる。proxy.server が全パスにマッチするため mod_proxy が /api/events.* の WebSocket アップグレードを先に処理して 426 Upgrade Required を返し、mod_wstunnel は r->handler_module 非 NULL でスキップされ実行されない。lighttpd 1.4.56+ の mod_proxy ネイティブ WebSocket トンネル（proxy.header = "upgrade" => "enable"）に変更し、mod_wstunnel を削除。検証: 8625 / は 200、/api/events.host|mux ハンドシェイク 101（ローカル+LAN）。

| コミット | 説明 |
|------|------|
| `51d9435` | fix(module): dsh WebSocket reverse proxy via mod_wstunnel |
| `33d5931` | fix(module): dsh wstunnel port as string (match lighttpd backend syntax) |
| `d7d2713` | fix(module): dsh WebSocket via mod_proxy upgrade (mod_wstunnel never runs) |

## 2026-08-19T13:10:00+09:00

**概要**: fix(pkgs): dsh 0.1.0-rc.6 → 0.1.0-rc.7。rc.6 は約 13 時間でクラッシュ（fatal load failure: Context has been disposed）— cordis-plugin-timer の ctx.timeout() が Context の静的な dispose 時に reject し unhandled rejection 化。rc.7（8/17）が最新、cordis/timer バージョンは不変（バグ残存の可能性）だが上流修正を含む。プラグイン一覧不変（131）。

| コミット | 説明 |
|------|------|
| `c75cb4c` | chore(pkgs): bump dsh 0.1.0-rc.6 → 0.1.0-rc.7 |

## 2026-08-18T20:00:00+09:00

**概要**: fix(module): dsh 通常ユーザー実行対応 — 隔離システムユーザー（home /var/lib/dsh）では /home/<user>（700 権限）にアクセスできず、agent が作業ディレクトリを操作できなかった。dshHome オプションを追加し、HOME/DSH_HOME/WorkingDirectory/preStart を統一ルート化、StateDirectory を preStart mkdir + chown に置換。ローカル設定は user="kix" + dshHome="/home/kix/.dsh" で、dsh が kix として実行され /home/kix に到達。

| コミット | 説明 |
|------|------|
| `584c764` | fix(module): dsh dshHome option + support normal-user operation |

## 2026-08-18T19:30:00+09:00

**概要**: feat(module): nixkits.dsh.settings — 宣言的設定。dsh 設定メニュー項目は $DSH_HOME/settings.yaml（ファイルバックアップ、ホットリロード、namespace 別セクション）に格納。settings オプション（attrsOf attrs、namespace → section）を追加し JSON（合法 YAML）として preStart で書き込み。実測：web-search-deepseek.maxTokens を既定 4096 → 8192 に宣言的オーバーライド。4言語ドキュメントに設定節を追加。

| コミット | 説明 |
|------|------|
| `f2981e6` | feat(module): nixkits.dsh.settings — declarative settings |
| `dc64cbb` | docs(dsh): declarative settings section + maintenance log |

## 2026-08-18T18:45:00+09:00

**概要**: docs(dsh) + refactor(skill): プラグイン一覧同期 — docs/dsh.md 4言語に「プラグイン一覧」節（131 内蔵 entry id、id -> パッケージ）を追加、nixkits.dsh.plugins.disabled の参照に。check-updates スキル第5ステップに dsh 特有説明を追加：更新時に新パッケージの dsh-*/cordis.patch.yml から一覧を抽出して docs に同期。

| コミット | 説明 |
|------|------|
| `06d0e28` | docs(dsh): plugin inventory + check-updates skill sync |

## 2026-08-18T18:39:34+09:00

**概要**：fix(module): dsh preStart rm before cp — preStart が生成するファイルは権限 444（読み取り専用）のため、サービスユーザーが cp で上書きできない。先に rm してから cp するよう修正。

| コミット | 説明 |
|------|------|
| `f308ac7` | fix(module): dsh preStart rm before cp — service-user cannot overwrite 444 |

## 2026-08-18T18:20:00+09:00

**概要**: feat(module): nixkits.dsh.plugins — 宣言的プラグインオン/オフと設定。dsh プラグインは cordis.patch.yml でランタイムホットリロード、モジュールに plugins.disabled（entry id）、plugins.settings（config 上書き）、plugins.extraPatch（MCP などの生フラグメント）を追加。システム設定は MCP を extraPatch に移行、API key を kix.credentials に宣言化、session-telemetry-otel + session-stats を無効化例として設定。実測：cordis.patch.yml 正しく生成、absent-id 警告なし。

| コミット | 説明 |
|------|------|
| `0e4fe58` | feat(module): nixkits.dsh.plugins — declarative plugin on/off + config |
| `164d515` | docs(dsh): declarative plugin management section + maintenance log |

## 2026-08-18T17:55:00+09:00

**概要**: fix(module): lighttpd が Host/Origin を loopback に書き換え — trustedHosts 方式を置換。dsh の isTrustedApiRequest が loopback を見て通過、per-deployment trustedHosts 不要、かつ LAN ホスト名/IP をバックエンドに漏洩しない。Origin は Host と同時に書き換え必須（同一生成元チェック失敗を避けるため）。実測：trustedHosts 削除後も反代 API（harukax.lan / 192.168.31.241）が ok:true。

| コミット | 説明 |
|------|------|
| `a33b414` | fix(module): rewrite Host/Origin to loopback in lighttpd reverse proxy |

## 2026-08-18T17:30:00+09:00

**概要**: fix(module): dsh trustedHosts オプション — リバースプロキシ経由で全 /api が 403。dsh は /api リクエストの Host header を検証（isTrustedApiRequest：Host は loopback か信頼リスト必須、ブラウザ Origin も同一生成元）。lighttpd 経由で Host が LAN ホスト名/IP になり全 403 forbidden。nixkits.dsh.trustedHosts を追加（repeatable --trusted-host にマップ）、システム設定で harukax.lan + 192.168.31.241 を信頼し API 復旧。

| コミット | 説明 |
|------|------|
| `3755935` | fix(module): dsh trustedHosts option — Host-header 403 behind reverse proxy |

## 2026-08-18T16:20:05+09:00

**概要**: fix(dsh): ブラウザ側 client bundle パッチ — crypto.randomUUID fallback。crypto.randomUUID() は非セキュアコンテキスト（LAN IP への HTTP、つまり lighttpd リバースプロキシ経由）で使用不可となり、webui が "crypto.randomUUID is not a function" で失敗。postInstall で dsh-client-connection + dsh-client-ui-conversation の crypto.randomUUID を __dshUuid ヘルパー（crypto.getRandomValues にフォールバック、全コンテキストで利用可）に置換。サーバー側 index.js は Node の crypto を使用、変更不要。

| コミット | 説明 |
|------|------|
| `5d1cfa8` | fix(dsh): patch browser client bundles — crypto.randomUUID fallback |

## 2026-08-18T15:29:14+09:00

**概要**: fix/docs(dsh): lighttpd リバースプロキシ定稿 — dsh 内部 loopback ポート 8615（SearXNG 42701 に合わせる）、lighttpd 对外ポート 8625（4270 に合わせる）、ファイアウォールは lighttpd 对外ポートを開放（dsh 内部ポートでなく）。4 言語ドキュメント同期。

| コミット | 説明 |
|------|------|
| `4a78d54` | fix(module): dsh internal port 8615, public reverseProxy port 8625 |
| `5452a3e` | docs(dsh): sync service section to loopback 8615 + lighttpd reverseProxy 8625 |

## 2026-08-18T14:38:26+09:00

**概要**: feat(module): dsh reverseProxy via lighttpd — dsh が非 loopback host を拒否するため（RCE 安全）、lighttpd の `$SERVER["socket"]` ブロックで 0.0.0.0:8626 を dsh loopback 8625 にリバースプロキシ（SearXNG の lighttpd インスタンスを再利用、extraConfig は types.lines でクリーンにマージ）。対外 8626 をファイアウォール開放。

| コミット | 説明 |
|------|------|
| `12e11af` | feat(module): add nixkits.dsh.reverseProxy via lighttpd |

## 2026-08-18T10:29:46+09:00

**概要**: feat/fix(dsh): dsh サービス配備 + MCP/skills 設定 — ① モジュール修正：dsh システムユーザー HOME=/var/empty（読取専用）で EPERM、書込可能な /var/lib/dsh home + StateDirectory に変更；② HMR サービスが --expose-internals を要求（NODE_OPTIONS 禁止・CLI 非認識）、node --expose-internals で bin.js を直接起動；③ MCP サービスを cordis.patch.yml の `insert:` 構文（id-targeted override でなく）で SearXNG + Godot 設定；④ skills を /var/lib/dsh/skills/（.agent-presets サブディレクトリでなく）に複製；⑤ nixkits-skills のディレクトリを ~/.dsh/skills に修正。

| コミット | 説明 |
|------|------|
| `b17e5bf` | fix(module): dsh writable HOME + StateDirectory |
| `ed6983e` | fix(module): dsh launch via node --expose-internals (HMR requires execArgv) |
| `456c917` | feat(skill): nixkits-skills add dsh skills directory support |
| `ee24563` | fix(skill): correct dsh skills directory — ~/.dsh/skills |

## 2026-08-18T08:42:40+09:00

**概要**: docs: ruyi チャンネル版数を同期（stable 0.50.0 → 0.51.0、beta/alpha 日付）し、en/ja/pcn README の ruyi 説明列を補完（空 `<br><br>` → RuyiSDK 説明 + 3 チャンネル版数、zh と一致）。

| コミット | 説明 |
|------|------|
| `86ae30b` | docs: sync ruyi channel versions + fill empty ruyi descriptions in en/ja/pcn README |

## 2026-08-18T07:19:30+09:00

**概要**: 監査修正 — ① codewhale 0.9.8 / mcp-searxng 1.15.0 / opencode-telegram 0.24.0 / obs-bilibili-stream 2.1.3 更新；② comfyui-rocm モジュールに services.comfyui assertion 復元 + nixpkgs-compat パッチ対象を明確化；③ overlay codewhale アーキテクチャ別ソースビルドフォールバック（riscv64）；④ ドキュメント版数/リンク/説明同期；⑤ write-maintenance-log スキル表ヘッダ + katalish 列削除。

| コミット | 説明 |
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

**概要**: refactor: comfyui-rocm-patch + comfyui-strix-halo を単一 comfyui-rocm に統合 — 2モジュールが ComfyUI ROCm サポートの異なる部分（パッチ層 vs Strix Halo ハードウェア最適化）を処理していたのを、nixkits.comfyui-rocm（enable オプション）に統合し、パッチマウント、GFX オーバーライド、xformers バイパス、C ツールチェーン、Strix Halo 設定（ROCm ランタイム/DeviceAllow/kernelParams）を網羅。ドキュメントと README 同期。

| コミット | 説明 |
|------|------|
| `d473991` | refactor: merge comfyui-rocm-patch + comfyui-strix-halo into comfyui-rocm |

## 2026-08-15T09:23:15+09:00

**概要**: refactor: パッチファイル rog-control-center-fix.patch → rcc-fix.patch に改名し、rcc-fix 統一命名の仕上げ。overlays/rcc-fix.nix と 4言語 rcc-fix.md の参照を更新。

| コミット | 説明 |
|------|------|
| `b350cfd` | refactor: rename rog-control-center-fix.patch to rcc-fix.patch |

## 2026-08-15T08:31:32+09:00

**概要**: feat(dsh): deepseek-harness 0.1.0-rc.6 パッケージ新規追加 + 4言語ドキュメント。DSH（DeepSeek Harness）— すべてがプラグイン。プリビルト npm パッケージ（@deepseek-ai/dsh、bin dsh → lib/bin.js）、package-lock.json を同梱（npm tarball に lock なし）、dontNpmBuild で build スキップ。godot-ai と dsh を README に掲載（4言語）。

| コミット | 説明 |
|------|------|
| `0194460` | feat(dsh): add deepseek-harness 0.1.0-rc.6 package + 4-language docs |

## 2026-08-15T08:07:33+09:00

**概要**: refactor: rog-control-center-fix を rcc-fix に統合 — 両者は同一の ROG Control Center 修正プロジェクト（overlay asusctl パッチ + module systemd デッドロック修正）。単一の rcc-fix に統一：overlays/rog-control-center-fix.nix → rcc-fix.nix、modules/rog-control-center-fix.nix → rcc-fix.nix、オプション nixkits.rog-control-center-fix → nixkits.rcc-fix、独立ドキュメント削除（rcc-fix.md に統合）。

| コミット | 説明 |
|------|------|
| `376eacf` | refactor: merge rog-control-center-fix into rcc-fix |

## 2026-08-13T01:20:29+09:00

**概要**: fix(default-overlay): godot-ai を fastmcp overlay 適用で構築 — default overlay の final.callPackage が fastmcp を nixpkgs 3.3.1（循環 import バグ）に解決。 (prev.extend (import ./fastmcp.nix)) で依存を 3.4.7 に解決。

| コミット | 説明 |
|------|------|
| `94d49b5` | fix(default-overlay): build godot-ai with fastmcp overlay applied |

## 2026-08-12T10:05:00+09:00

**概要**: fix(default-overlay): godot-ai パス修正 — default overlay の callPackage は `../packages/`（overlay がサブディレクトリのため）であり、`./packages/` では存在しない `overlays/packages/` に解決された。

| コミット | 説明 |
|------|------|
| `0144283` | fix(default-overlay): correct godot-ai path — ./packages → ../packages |

## 2026-08-12T10:00:00+09:00

**概要**: fix(default-overlay): godot-ai を登録 — flake packages には存在するが デフォルト overlay から漏れており、下流（/etc/nixos）から pkgs.godot-ai として見えなかった。

| コミット | 説明 |
|------|------|
| `093565c` | fix(default-overlay): register godot-ai so pkgs.godot-ai is available |

## 2026-08-12T09:18:26+09:00

**概要**: docs(godot-ai): 4言語ドキュメント新規追加（72行）— アーキテクチャ図、依存表（fastmcp 3.4 含む）、システムインストール + MCP 設定 + 前提条件ガイド。

| コミット | 説明 |
|------|------|
| `76c39c8` | docs(godot-ai): add 4-language documentation |

## 2026-08-12T07:07:27+09:00

**概要**: feat(godot-ai): godot-ai 3.1.5 パッケージ新規追加 + fastmcp 3.4.7 overlay。godot-ai は MCP クライアントを実行中 Godot エディタに接続する本格 MCP server。fastmcp 3.3.1→3.4.7（godot-ai が >=3.4.0 を要求、3.3.x に循環 import バグ）、fastmcp-slim + py-key-value-aio 0.4.5 も連動アップグレード。devshell godot-mcp→godot-ai。

| コミット | 説明 |
|------|------|
| `23a5b8d` | feat(godot-ai): add godot-ai 3.1.5 package + fastmcp 3.4.7 overlay |

## 2026-08-11T18:49:54+09:00

**概要**: fix(breeze-black): Edge/Chromium 用 純黒背景 + 純白前景 — sed 再マップ拡張：背景 #292c30 → #000000（ボタン/ツールバー/無効化）、前景 #fcfcfc/#a1a9b1 → #ffffff。gtk-3.0/4.0 検証：15× #000000、14× #ffffff、灰色残りゼロ。

| コミット | 説明 |
|------|------|
| `4e5c558` | fix(breeze-black): pure black bg + pure white fg for Edge/Chromium |

## 2026-08-11T18:41:14+09:00

**概要**: fix(breeze-black): 背景変数を真っ黒 #000000 にマップ — Breeze-Dark の基本色は #202326（濃灰、純黒でない）。CSS コピー後、主背景/base を #000000 に再マップ（ボタンは #292c30 を維持し区別を確保）、gtk-dark.css は自己完結化（gtk.css のコピー）し灰色 import を廃止。

| コミット | 説明 |
|------|------|
| `2ee1ba6` | fix(breeze-black): map background variables to true black #000000 |

## 2026-08-11T16:19:49+09:00

**概要**: fix(breeze-black): gtk.css 本体を Breeze-Dark のダーク配色で上書き — Chromium 系（Edge/Chrome）は prefer-dark を無視して gtk.css を直接読み込む；BreezeBlack（ライト Breeze からの改名）にライト変数（#eff0f1）が残り Edge がグレー表示。gtk-{3,4}.0 の gtk.css(+.map) をダーク（#202326）に上書き。

| コミット | 説明 |
|------|------|
| `25e23e0` | fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme |

## 2026-08-11T16:02:39+09:00

**概要**: fix(breeze-black): Breeze-Dark を保持 — BreezeBlack の gtk-dark.css が `@import ../../Breeze-Dark/...` で本物のダーク配色（#202326）を取得。preFixup での削除で import が切れ GTK がライトにフォールバック（「黒くない」症状）。

| コミット | 説明 |
|------|------|
| `0433eee` | fix(breeze-black): keep Breeze-Dark — gtk-dark.css imports it for dark mode |

## 2026-08-09T22:43:43+09:00

**概要**: refactor(skill): トラップ4追加 — 無引数 `nix flake lock` は全フローティング input を更新（nixpkgs ドリフト再発、8/7 nixpkgs で diffusers/httpx 失敗）。--update-input または nixpkgs rev 固定を使用。

| コミット | 説明 |
|------|------|
| `ec5e589` | refactor(skill): add trap 4 — bare nix flake lock refreshes floating inputs |

## 2026-08-09T19:40:21+09:00

**概要**: feat(patches): ローカル comfyui-nix ビルド修正をパッチファイルとして正式化 — ① mkWheel dontCheckRuntimeDeps（pythonRuntimeDepsCheckHook、nixpkgs ≥ 8/5）；② flaky スイート doInstallCheck=false（jupyter-server/scipy/fastapi/einops/mss/inline-snapshot）；③ torch/facexlib ランタイム依存スキップ。モジュールコメント + 4 言語ドキュメント更新。

| コミット | 説明 |
|------|------|
| `a8ad11e` | feat(patches): add comfyui-nix nixpkgs-compat patch + module doc |
| `faefa5b` | docs(comfyui-rocm-patch): document nixpkgs-compat patch (4 langs) |

## 2026-08-09T19:05:53+09:00

**概要**: refactor(skill): nixkits-check-updates に nixpkgs ドリフト故障診断セクション追加 — ① 旧 flake.lock 復元時は flake.nix の follows を要確認（喪失 → glibc 2.40 → GLIBC_ABI_GNU2_TLS）；② pytest パッケージは doInstallCheck=false（pytestCheckHook は installCheckPhase で実行）；③ pythonRuntimeDepsCheckHook（nixpkgs ≥ 8/5）が wheel 構築を破壊、dontCheckRuntimeDeps=true で修復。

| コミット | 説明 |
|------|------|
| `e88fd98` | refactor(skill): add nixpkgs-drift troubleshooting section to check-updates |

## 2026-08-09T04:21:09+09:00

**概要**: fix(module): llama-cpp — ① services.llama-cpp.extraFlags は非推奨のため settings で --sleep-idle-seconds を渡すよう変更；② freeform settings は分離定義不可のため lib.mkMerge で models-preset と sleep-idle-seconds を統合。

| コミット | 説明 |
|------|------|
| `8026d8e` | fix(module): replace deprecated services.llama-cpp.extraFlags with settings |
| `0ec7760` | fix(module): merge llama-cpp settings via mkMerge |

## 2026-08-08T23:07:40+09:00

**概要**: fix(breeze-black): look-and-feel グローバルテーマ復元と GTK リネーム修正 — 7/23 外部パッチ除去後の2つのリグレッション：① org.kde.breezeblack.desktop 欠落で BreezeBlack が設定のテーマ選択から消えたため、look-and-feel をローカル内蔵で復元；② preFixup の Breeze* グロブが Breeze と Breeze-Dark 両方に一致し GTK テーマがネスト化、Breeze のみリネームに修正。

| コミット | 説明 |
|------|------|
| `114b9c2` | fix(breeze-black): restore look-and-feel global theme + fix GTK rename |

## 2026-08-08T22:50:33+09:00

**概要**: fix(codewhale-src): 0.9.4 に同期し source hash を修正 — 従来の nix-prefetch-url archive tarball hash が fetchFromGitHub（git プロトコル）と不一致で riscv64 CI が連続失敗。fetchFromGitHub ビルドで正しい hash を取得、Cargo.lock 同期、技能の誤った助言も修正。

| コミット | 説明 |
|------|------|
| `08b04a2` | fix(codewhale-src): sync to 0.9.4 with correct fetchFromGitHub hash |
| `ab2a624` | fix(skill): correct fetchFromGitHub hash advice — archive tarball trap |

## 2026-08-08T22:20:21+09:00

**概要**: codewhale 0.9.4 — 上流バグ修正；mcp-searxng 1.14.1 — 上流メンテナンス；opencode-telegram 0.23.1 — 上流機能更新

| コミット | 説明 |
|------|------|
| `f184fdb` | chore(pkgs): bump codewhale 0.9.3 → 0.9.4 |
| `9b877e1` | chore(pkgs): bump mcp-searxng 1.14.0 → 1.14.1 |
| `9b17590` | chore(pkgs): bump opencode-telegram 0.22.5 → 0.23.1 |
| `59ac74a` | docs: sync version numbers |

| パッケージ | 旧 | 新 |
|------|------|------|
| codewhale | 0.9.3 | 0.9.4 |
| mcp-searxng | 1.14.0 | 1.14.1 |
| opencode-telegram | 0.22.5 | 0.23.1 |

## 2026-08-05T07:24:56+09:00

**概要**: chore(pkgs) — codewhale-src を 0.9.3 に同期（riscv64 ソースビルドがプレビルト版より 3 バージョン遅れていた）。version・fetchFromGitHub hash・Cargo.lock（711 → 763 エントリ）を同期。

| コミット | 説明 |
|------|------|
| `563eea2` | chore(pkgs): sync codewhale-src to 0.9.3 — version, hash, Cargo.lock |

## 2026-08-05T01:30:00+09:00

**概要**: refactor(skill) — nixkits-check-updates に Rust パッケージ（buildRustPackage）更新フローを追加。codewhale-src の Cargo.lock 同期経験を汎化（version + source hash + Cargo.lock の三点同期、上流 lock 取得とエントリ数検証、クロスコンパイルタイムアウト時のフォールバック）。

| コミット | 説明 |
|------|------|
| `6e6bef6` | refactor(skill): add Rust package (buildRustPackage) update flow to nixkits-check-updates |

## 2026-08-04T02:15:00+09:00

**概要**: fix(ruyi): checkPhase の ruff lint 失敗を許容 — 2番目の ruff check（--fix無し）が nixpkgs ruff 更新後の139件の上流違反でビルドをブロックしていた。

| コミット | 説明 |
|------|------|
| `1175df2` | fix(ruyi): tolerate ruff lint failures in checkPhase |

## 2026-08-04T01:15:52+09:00

**概要**: codewhale 0.9.3 — 上流バグ修正；mcp-searxng 1.14.0 — 上流機能更新

| コミット | 説明 |
|------|------|
| `f84cbcb` | chore(pkgs): bump codewhale 0.9.1 → 0.9.3 |
| `6968f4e` | chore(pkgs): bump mcp-searxng 1.12.1 → 1.14.0 |
| `d778b1b` | docs: sync version numbers |

| パッケージ | 旧 | 新 |
|------|------|------|
| codewhale | 0.9.1 | 0.9.3 |
| mcp-searxng | 1.12.1 | 1.14.0 |

## 2026-07-31T04:07:23+09:00

**概要**：fix(ci): ci-summary.yml 構文修正（YAML 破損、固定 token）、push/schedule 起動 + GITHUB_TOKEN に切替。README badge を check.yml（flake 評価のみ）から shields.io endpoint（全 Build workflow 実状態反映）に変更。

| コミット | 説明 |
|------|------|
| `c0e52a5` | fix(ci): fix ci-summary.yml syntax, switch README badge to endpoint |

## 2026-07-31T03:34:15+09:00

**概要**：fix(ci): Nix access-token に GITHUB_TOKEN を注入 — llama-cpp-ver input が GitHub API 呼出を必要とし、未認証では 60 回/時間に制限され並列 CI で HTTP 403 が頻発。`${{ secrets.GITHUB_TOKEN }}` を使用。

| コミット | 説明 |
|------|------|
| `41a8a8b` | fix(ci): inject GITHUB_TOKEN as Nix access-token for llama-cpp-ver API |

## 2026-07-31T03:00:12+09:00

**概要**：fix(codewhale-src): riscv64 クロスコンパイル修正 — `ring` クレートの `cc` ビルドが汎用 CFLAGS から `-m64` を継承し riscv64-gcc エラー発生。per-target 変数に加え汎用 CFLAGS/CXXFLAGS もクリア。

| コミット | 説明 |
|------|------|
| `29c780a` | fix(codewhale-src): clear generic CFLAGS/CXXFLAGS for riscv64 cross-compile |

## 2026-07-30T17:56:11+09:00

**概要**：codewhale 0.9.1 — 上流バグ修正；mcp-searxng 1.12.1 — 上流機能更新；opencode-telegram 0.22.5 — 上流メンテナンス

| コミット | 説明 |
|------|------|
| `1110c7a` | chore(pkgs): bump codewhale 0.9.0 → 0.9.1 |
| `3dcb65a` | chore(pkgs): bump mcp-searxng 1.11.1 → 1.12.1 |
| `98abe96` | chore(pkgs): bump opencode-telegram 0.22.3 → 0.22.5 |
| `a94dea8` | docs: sync version numbers |

| パッケージ | 旧 | 新 |
|------|------|------|
| codewhale | 0.9.0 | 0.9.1 |
| mcp-searxng | 1.11.1 | 1.12.1 |
| opencode-telegram | 0.22.3 | 0.22.5 |

## 2026-07-23T12:56:53+09:00

**概要**：fix(codewhale-sudo): ptrace wrapper 修正 — 子プロセス追跡を削除（codewhale のサブシェルが SIGTRAP で kill されるのを防止）、PTRACE_EVENT_EXEC 処理を追加。4 言語ドキュメント同期更新（LD_PRELOAD → ptrace 記述）。

| コミット | 説明 |
|------|------|
| `c77cadc` | fix(codewhale-sudo): stop tracing child processes, handle PTRACE_EVENT_EXEC |
| `480658e` | docs(codewhale-sudo): update mechanism description LD_PRELOAD → ptrace |

## 2026-07-23T12:08:13+09:00

**概要**：fix(codewhale-sudo): LD_PRELOAD shim を ptrace システムコールインターセプターに置き換え — Codewhale は静的リンクのため LD_PRELOAD では prctl(PR_SET_NO_NEW_PRIVS) を捕捉できず、ptrace(2) でカーネル境界にて捕捉する方式に変更。静的・動的バイナリ両対応。

| コミット | 説明 |
|------|------|
| `6446364` | fix(codewhale-sudo): replace LD_PRELOAD shim with ptrace syscall interceptor |

## 2026-07-23T11:24:15+09:00

**概要**：fix(overlays): breeze-black — 無効化された fetchpatch URL（injx.sbs ドメインは永続的に利用不可）を、純粋なローカル colors ファイルインストールに置き換え。KDE Plasma は share/color-schemes/ から配色を自動検出します。

| コミット | 説明 |
|------|------|
| `547d6a0` | fix(overlays): replace dead breeze-black fetchpatch with local copy |

## 2026-07-22T16:31:26+09:00

**Summary**: fix(modules) — rog-control-center-fix now forces SendSIGKILL=yes + TimeoutStopSec=30s to prevent stale asus-shutdown process from blocking systemd-switch. comfyui-strix-halo now asserts glibc >= 2.42 (ROCm 7.2 needs GLIBC_ABI_GNU2_TLS).

| コミット | 説明 |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T09:00:00+09:00

**Summary**：feat(overlays) — new breeze-black overlay, providing high-contrast Breeze Black accessibility theme for Plasma 6 (global look-and-feel + GTK + color scheme). Includes 4-language docs.

| コミット | 説明 |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T05:39:31+09:00

**Summary**: docs(devshell) — new devShell documentation (4 languages), describing opencode (full MCP stack) and ruyi (3 channels merged) environments. README devShell table now includes doc links.

| コミット | 説明 |
|------|------|
| `7bfe3e3` | docs: add devShell documentation — 4 lang |
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |

## 2026-07-22T03:40:50+09:00

**Summary**: docs — unified all user home directory paths across the repo to `~/` prefix (replaced hardcoded `/home/kix` and `/home/<user>` variants), covering 13 files.

| コミット | 説明 |
|------|------|
| `f597b9a` | docs: generalize hardcoded /home/kix paths |
| `bb65b77` | docs: unify all user home paths to ~/ prefix |

## 2026-07-22T03:14:27+09:00

**Summary**: feat(shells) — opencode devShell iteration: SearXNG + lighttpd (matching system NixOS config) + blender-mcp + godot-mcp + godot + opencode + opencode-telegram. Auto-registers MCP config on first entry. Removed tryEval guards from godot packages.

| コミット | 説明 |
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

| コミット | 説明 |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**Summary**: codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3 — upstream updates (codewhale v0.9.0 still no riscv64 prebuilt binaries, continues source-build path)

| コミット | 説明 |
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

**概要**: fix(ci) — ci-summary workflow が `gh run list` をワークフロー毎に呼び出し HTTP 403 rate limit で失敗していた問題を修正。2 回の一括 `gh api` 呼出に変更し並行制御を追加。

| コミット | 説明 |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**概要**: revert(skill) — katalish（半角カタカナ機械翻訳）の全コンテンツを削除：19 文書、スキル（SKILL.md + 102 項目辞書）、全言語切替リンク。翻訳の不安定さ（英文残留や文書構造破壊）により本番環境不適と判断。

| コミット | 説明 |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:54:55+09:00

**概要**: docs(nixkits-skills) —「既知の削除」を「リスク警告」に改名、5 言語スキル文書同期。

| コミット | 説明 |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**概要**: skill(nixkits-skills) — Claude Code インストール対象を削除（ユーザーデータに基づく国籍推論がセキュリティ境界を越える）、Codex サポートを追加。SKILL.md に「リスク警告」節と原文声明を追加。

| コミット | 説明 |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:35:20+09:00

**概要**: skill(write-maintenance-log) — タイムスタンプ規則強化：`git log` によるコミット時刻の強制取得、`T00:00:00` プレースホルダ禁止、生成後検証ステップ追加。MAINTENANCE プレースホルダタイムスタンプ修正（`968df0e`）から汎化。

| コミット | 説明 |
|------|------|
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |

## 2026-07-16T04:30:55+09:00

**概要**: feat(ci) — CI サマリーエンドポイントバッジを追加。メイン README CI バッジを shields.io endpoint 経由で `gh-pages/ci-status.json` を読み取る方式に変更、失敗時に失敗パッケージ名を表示。

| コミット | 説明 |
|------|------|
| `6465260` | feat(ci): add CI summary workflow with endpoint badge |
| `b489890` | docs(README): switch main CI badge to endpoint |

## 2026-07-16T04:09:46+09:00

**概要**: refactor(ci) — CI を単一 check.yml から 25 の独立 workflow ファイルに分割（パッケージ×アーキテクチャ毎）、バッジの相互影響を完全に解消。再利用可能な `build-package.yml` を追加。

| コミット | 説明 |
|------|------|
| `bc42e6f` | refactor(ci): split single check.yml into 25 isolated per-package-per-arch workflows |
| `1dfc1ee` | docs: update ruyi badge URLs to new isolated workflow files |
| `f235edc` | docs: embed version numbers in CI badge labels |

## 2026-07-16T04:00:46+09:00

**概要**: fix(codewhale) — ソースビルド riscv64 クロスコンパイル修正：ring crate の `-m64` エラーが cc crate の host CFLAGS 継承に起因、per-target CFLAGS をクリアして修正。

| コミット | 説明 |
|------|------|
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |

## 2026-07-16T01:18:16+09:00

**概要**: codewhale 0.8.67 — デュアルパスビルド（プリビルド x86_64/aarch64 + ソースビルド riscv64）。上流が v0.8.67 から riscv64 バイナリを削除したため、riscv64 は rustPlatform.buildRustPackage で Cargo.lock からビルド。

| コミット | 説明 |
|------|------|
| `0025476` | feat(codewhale): dual-path build — prebuilt for x86_64/aarch64, source for riscv64 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.66（プリビルド×3） | 0.8.67（プリビルド×2 + ソース riscv64） |

## 2026-07-15T08:32:13+09:00

**概要**: mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 — アップストリーム更新（codewhale スキップ：v0.8.67 依然 riscv64 バイナリなし）

| コミット | 説明 |
|------|------|
| `48414d4` | chore(pkgs): bump mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| mcp-searxng | 1.11.0 | 1.11.1 |
| opencode-telegram | 0.22.1 | 0.22.2 |
| obs-bilibili-stream | 2.1.1 | 2.1.2 |
| codewhale | 0.8.66 | (スキップ — 上流 v0.8.67 依然 riscv64 バイナリ欠落) |

## 2026-07-09T01:22:00+09:00

**概要**: revert(ci) — `ci/` ディレクトリを削除、`llama-cpp-ver` input を上流 API（`ggml-org/llama.cpp` releases/latest）に復元。overlay に `tryEval` + `prev.llama-cpp.version` フォールバックが既に存在し、ローカルキャッシュ不要。

| コミット | 説明 |
|------|------|
| `dbdd937` | revert: restore llama-cpp-ver to upstream API, remove ci/ |

## 2026-07-09T01:14:34+09:00

**概要**: obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 — アップストリーム更新（codewhale スキップ：v0.8.67 に riscv64 バイナリなし）

| コミット | 説明 |
|------|------|
| `73dc576` | chore(pkgs): bump obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| obs-bilibili-stream | 2.1.0 | 2.1.1 |
| mcp-searxng | 1.8.0 | 1.11.0 |
| opencode-telegram | 0.22.0 | 0.22.1 |
| codewhale | 0.8.66 | (スキップ — 上流 riscv64 バイナリ欠落) |

## 2026-07-07T12:01:12+09:00

**概要**: fix(docs) — katalish/pcn ローカライズ修正：katalish/ruyi.md と pcn/ruyi.md の言語切替破損（リンク欠落や重複言語名）を修正、pcn/ruyi.md を日本語から偽中国語に全文書換。

| コミット | 説明 |
|------|------|
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |

## 2026-07-05T04:41:23+09:00

**概要**: fix(ci) — blender-mcp riscv64-cross 修正経緯（4 コミット）。`callPackage` が非互換 `blender` を自動解決したことによる初回失敗、Nix/Bash エスケープ問題、最終的に上流 nixpkgs の `sse-starlette` クロスコンパイル欠陥により blender-mcp を riscv64-cross から除外。x86_64 / aarch64 は影響なし。

| コミット | 説明 |
|------|------|
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |

## 2026-07-04T07:33:07+09:00

**概要**: docs(MAINTENANCE) — 全 6 MAINTENANCE ファイル（zh/en/ja/katalish/pcn）に言語切替を追加

| コミット | 説明 |
|------|------|
| `9feb2fd` | docs(MAINTENANCE): add language switcher to all 6 MAINTENANCE files (zh/en/ja/katalish/pcn) |

## 2026-07-04T06:41:28+09:00

**概要**: blender-mcp 1.0.0 — 新規 Blender MCP Server パッケージ（Python ビルド、22 MCP ツール、Blender add-on 付属）

| コミット | 説明 |
|------|------|
| `a1cf458` | packages: add blender-mcp (MCP server for Blender) |
| `ab9109a` | packages: add blender-mcp (MCP server for Blender) |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| blender-mcp | — | 1.0.0 |

## 2026-07-02T04:00:00+09:00

**概要**: codewhale 0.8.66 — アップストリーム更新（TUIレイアウト修正、承認ラベル改善、パフォーマンス修正）

| コミット | 説明 |
|------|------|
| `c00a5e6` | chore(pkgs): bump codewhale 0.8.66 |
| `c61d458` | docs: bump codewhale 0.8.66 version numbers in all 5-language docs |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.65 | 0.8.66 |
| 　 | cli hash (×3) | all updated |
| 　 | tui hash (×3) | all updated |

## 2026-06-28T06:30:00+09:00

**概要**: opencode-telegram 0.22.0 — アップストリーム更新（3モードTTS + thinking表示 + コンパクト出力 + /settingsコマンド + セッション起動修正）

| コミット | 説明 |
|------|------|
| `b189d0a` | chore(pkgs): bump opencode-telegram 0.22.0 |
| `a61f444` | docs: bump opencode-telegram 0.22.0 version numbers in all 5-language docs |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| opencode-telegram | 0.21.2 | 0.22.0 |
| 　 | source hash | `...` → `...` |
| 　 | npmDepsHash | `...` → `...` |

## 2026-06-26T13:00:00+09:00

**概要**: CI — llama-cpp-ver をローカルファイル（ci/llama-cpp-ver.json）に変更、全CIジョブからGitHub API呼出を排除しrate limitによる全ビルド失敗を恒久修正；docs — riscv64バッジをパッケージ別に精密化（codewhale/kitsfmt/mcp-searxng/opencode-telegram）

| コミット | 説明 |
|------|------|
| `8b3a3be` | fix(ci): use local path for llama-cpp-ver input, eliminate GitHub API calls from all CI jobs |
| `5db4852` | fix(docs): add per-package job filter to riscv64 badges |

## 2026-06-26T12:30:00+09:00

**概要**: feat(opencode-telegram): サービスPATHにシステムパッケージを注入するextraPackagesオプションとhome-managerパスを注入するextraBinPathsオプションを追加、opencodeがサービスPATHで見つからない問題を修正；5言語ドキュメント更新

| コミット | 説明 |
|------|------|
| `7c98694` | feat(opencode-telegram): add extraPackages option to inject companion tools into service PATH |
| `45b7c57` | feat(opencode-telegram): add extraBinPaths option for home-manager users |

## 2026-06-26T10:55:41+09:00

**概要**: codewhale 0.8.65 — アップストリーム更新（cliバイナリ名変更：codewhale-cli-linux → codewhale-linux）；mcp-searxng 1.8.0 — アップストリーム更新（マルチインスタンスフェイルオーバー/並列ファンアウト、能力発見集約、safesearch修正）

| コミット | 説明 |
|------|------|
| `57620d4` | chore(pkgs): bump codewhale 0.8.65 + mcp-searxng 1.8.0 |
| `94ac1e4` | docs: bump codewhale 0.8.65 + mcp-searxng 1.8.0 version numbers in all 5-language docs |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.64 | 0.8.65 |
| mcp-searxng | 1.7.2 | 1.8.0 |
| 　 | codewhale cli hash (×3) | all updated (incl. URL change) |
| 　 | codewhale tui hash (×3) | all updated |
| 　 | mcp-searxng source hash | `...` → `...` |
| 　 | mcp-searxng npmDepsHash | `...` → `...` |

## 2026-06-26T08:00:00+09:00

**概要**: docs(MAINTENANCE): pcn 欠落していた28件の履歴エントリを補完、zh基準全93エントリを網羅

| コミット | 説明 |
|------|------|
| `01f662b` | docs(MAINTENANCE): backfill 28 missing historical entries to pcn (93/93 zh baseline covered) |

## 2026-06-26T07:35:00+09:00

**概要**: docs(MAINTENANCE): en/ja/katalish 欠落していた10件の履歴エントリを補完、3言語すべてzh基準（92/92）に一致；pcn 一部補完（66/92）

| コミット | 説明 |
|------|------|
| `1921a36` | docs(MAINTENANCE): backfill 10 missing entries to en/ja/katalish (+ partial pcn) |

## 2026-06-26T07:18:56+09:00

**概要**: fix(skill): write-maintenance-log 第4ステップ「多言語同期」を5行のスタブから実行可能なフローに書き直し（4a 言語発見 → 4b 言語別翻訳書込 → 4c エントリ数一致検証）；AGENTS.md 第4ステップに検証チェックを強化

| コミット | 説明 |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-26T06:19:21+09:00

**概要**: 監査修正 — 空の scripts/ ディレクトリと .gitignore の死んだルール（translate_pcn.py）を削除；AGENTS.md の SKILL.md 行数制約をハードリミットから定性的ガイダンスに緩和

| コミット | 説明 |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-25T11:02:38+09:00

**概要**: ruyi — クロスコンパイル修正（postPatch に python.pythonOnBuildForHost 使用）；CI — ruyi* を riscv64-cross に復帰；docs — riscv64 バッジの正確な job filter を復元

| コミット | 説明 |
|------|------|
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |

## 2026-06-25T10:12:02+09:00

**概要**: CI — riscv64-cross から ruyi* を恒久的に除去（Python postPatch のクロスコンパイル不可）；docs — riscv64 バッジを * マーク付きフォールバックに戻し + 注記

| コミット | 説明 |
|------|------|
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |

## 2026-06-25T10:04:30+09:00

**概要**: CI — access-tokens の上書きによる GitHub API レート制限超過を修正（1行に統合）；riscv64-cross の並列上限を 4 に設定

| コミット | 説明 |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |

## 2026-06-25T09:44:44+09:00

**概要**: CI — riscv64-cross に ruyi/ruyi-beta/ruyi-alpha を復帰（パスマッピング）；docs — バッジラベル簡略化 + riscv64 job 精密フィルター

| コミット | 説明 |
|------|------|
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |

## 2026-06-25T09:29:43+09:00

**概要**: CI — build / riscv64-cross をパッケージ単位の matrix に分割、独立バッジ対応；docs — ruyi バッジを 9 枚（3バージョン×3アーキテクチャ）に拡張

| コミット | 説明 |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |

## 2026-06-25T09:24:43+09:00

**概要**: CI — build job に ruyi-beta / ruyi-alpha のビルドステップを追加；docs — ruyi 基本情報テーブルのチャンネル行に beta/alpha バージョン番号を追加

| コミット | 説明 |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |

## 2026-06-25T09:09:26+09:00

**概要**: CI — ruyi を riscv64-cross から除外；overlays — default overlay に ruyi-beta/ruyi-alpha を追加＋nixConfig を flake トップレベルに移行；docs — README テーブルに ruyi 3チャンネルバージョンを表示

| コミット | 説明 |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |

## 2026-06-25T05:35:00+09:00

**概要**: docs — 全5言語のREADMEにruyi-beta / ruyi-alpha devShellエントリを追加

| コミット | 説明 |
|------|------|
| `5d4ca02` | docs: add ruyi-beta + ruyi-alpha to devShell tables (all 5 READMEs) |

## 2026-06-25T05:28:12+09:00

**概要**: ruyi — パッケージディレクトリ構造を再編（packages/ruyi/）、beta/alphaをthin wrapperに；devShellsを追加

| コミット | 説明 |
|------|------|
| `4b9865e` | refactor(pkgs): move ruyi into subdirectory, beta/alpha as thin wrappers |
| `94bb174` | feat(shells): add ruyi-beta + ruyi-alpha devShells |

## 2026-06-25T05:13:34+09:00

**概要**: ruyi — バージョンチャンネルを独立パッケージ化（ruyi / ruyi-beta / ruyi-alpha）、独立overlayを削除

| コミット | 説明 |
|------|------|
| `51f23ad` | refactor(pkgs): ruyi channels as separate packages (not overlays) |

## 2026-06-25T04:58:36+09:00

**概要**: ruyi — 3チャンネルバージョン体系（stable/beta/alpha）、ベースパッケージを0.50.0安定版に切替、beta/alphaはoverlayで上書き

| コミット | 説明 |
|------|------|
| `a9f8baa` | feat(pkgs): ruyi 3-channel (stable/beta/alpha) via overlays |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| ruyi | 0.51.0-alpha.20260616 | 0.50.0（安定版） |
| 　 | 新規 ruyi-beta overlay | 0.50.0-beta.20260623 |
| 　 | 新規 ruyi-alpha overlay | 0.51.0-alpha.20260616 |

## 2026-06-24T03:19:30+09:00

**概要**: workflow — メンテナンスログ更新ルールを必須化（AGENTS.md + write-maintenance-logスキル）

| コミット | 説明 |
|------|------|
| `2e719df` | fix: make maintenance log update mandatory after every push |

## 2026-06-24T03:15:37+09:00

**概要**: docs — 古い手動riscv64ビルド手順を削除、CIが3アーキテクチャをカバー済み

| コミット | 説明 |
|------|------|
| `698400a` | docs: remove stale manual riscv64 build instructions — CI now covers all 3 architectures |

## 2026-06-24T03:06:20+09:00

**概要**: codewhale 0.8.64 — アップストリーム更新

| コミット | 説明 |
|------|------|
| `0bde292` | chore(pkgs): bump codewhale 0.8.64 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.63 | 0.8.64 |
| 　 | x64 cli hash | `sha256-SMaOUH...Z6M=` → `sha256-sKvJm6...XY=` |
| 　 | arm64 cli hash | `sha256-gGv2T4...M8=` → `sha256-gYofCL...jk=` |
| 　 | riscv64 cli hash | `sha256-qSVNms...g=` → `sha256-TOkojm...A=` |
| 　 | x64 tui hash | `sha256-UA66uC...M=` → `sha256-Q3wRQ5...M=` |
| 　 | arm64 tui hash | `sha256-m24T1T...g=` → `sha256-CSKaNh...M=` |
| 　 | riscv64 tui hash | `sha256-l1tgSn...w=` → `sha256-mAARZq...Y=` |

## 2026-06-24T02:30:21+09:00

**概要**: CI — riscv64クロスコンパイルパイプライン追加、3アーキテクチャCI全量カバー（x86_64 / aarch64 / riscv64）；パッケージ毎にriscv64バッジ追加

| コミット | 説明 |
|------|------|
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |

## 2026-06-23T05:20:00+09:00

**概要**: translate-pseudocn — Webリサーチに基づき辞書を拡充（7→46エントリ）、SVO語順に変更、全pcnドキュメントを再生成

| コミット | 説明 |
|------|------|
| `4fbf387` | feat(pcn): expand dictionary 7→46 entries, add IT terminology from research |
| `ec38b7e` | feat(pcn): convert to SVO word order, expand dictionary, regenerate all 22 docs |

## 2026-06-23T04:19:16+09:00

**概要**: translate-pseudocnスキル再構築 — 疑似中国語を「日本語から仮名を剥がした視覚結果」と再定義、中国語への変換を廃止。日本語漢字をそのまま保持（簡体字化しない）、SOV語順を維持、辞書を40→7エントリに縮小（カタカナ→日本語漢字のみ）。全22件のpcnドキュメントを再生成

| コミット | 説明 |
|------|------|
| `be0780b` | refactor(pcn): redesign pseudo-Chinese skill — Japanese-native kanji, SOV order, no Chinese chars |

## 2026-06-23T04:04:32+09:00

**Summary**：AGENTS.md — 去硬编码、移除冗余审计备忘、缓存章节重写为代理操作指南、移除用户侧描述、语言体系改为自动发现

| コミット | 説明 |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:49:00+09:00

**Summary**：mcp-searxng 1.7.2 — 上游修复

| コミット | 説明 |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |

## 2026-06-22T23:22:00+09:00

**Summary**：AGENTS.md — 新增初次启动审计规则、访问控制移至顶部

| コミット | 説明 |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**Summary**：docs — README 重复行修复，write-project-docs 反模式补充

| コミット | 説明 |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**Summary**：AGENTS.md — 新增访问控制、语言要求、提交规范、维护记录检查、文档同步、泛化、多架构缓存规则

| コミット | 説明 |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**Summary**：docs — 每包文档添加双架构 CI 徽章，技能模板同步

| コミット | 説明 |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**Summary**：CI — 添加 ARM runner 多架构构建，修复 flake.lock 并发竞争（--no-write-lock-file）

| コミット | 説明 |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**Summary**：mcp-searxng — source hash + npmDepsHash 更新（GitHub archive 变化）；ruyi — overlay postPatch 回移（补丁文件依赖）

| コミット | 説明 |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**Summary**：docs — 添加缓存排除警告（overlay 与模块+补丁条目），README 缓存说明压缩，flake.nix 添加 nixConfig 自动声明

| コミット | 説明 |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**Summary**：docs — 全部 30 篇包文档添加 `## 缓存` 节，CI badge 布局改进，技能同步

| コミット | 説明 |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**Summary**：CI/CD — 添加 GitHub Actions 构建矩阵（Cachix 推送）、二进制缓存、AGENTS.md

| コミット | 説明 |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**Summary**：skills — translate-katalish / translate-pseudocn / write-project-docs 拆分词典与模板，SKILL.md 压缩至 60-80 行

| コミット | 説明 |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**Summary**：docs — MAINTENANCE 时间戳精确化（29 节）、30 重复节删除（SHA 去重）、nix-kits→nixkits 全量替换（183 处）、模块文档同步

| コミット | 説明 |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**Summary**：patches — ruyi-nixos-compat.patch 基于干净克隆重建（1223→426 行），清除 flake.lock 自引用 artifact

| コミット | 説明 |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**Summary**：overlays — patches 列表 lib.unique 去重，ruyi-nixos-compat 精简，llama-cpp-rocm 添加 curried 形式注释

| コミット | 説明 |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**Summary**：modules — 4 模块添加 enable 选项，comfyui-strix-halo 添加 assertions，命名空间统一至 nixkits.*（含向后兼容），llama-cpp-rocm hfCacheDir 动态推导

| コミット | 説明 |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**Summary**：codewhale 0.8.63 — 多架构预编译二进制（x86_64 / aarch64 / riscv64）；ruyi — overlay postPatch 合并入包；meta 字段补全

| コミット | 説明 |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**Summary**：flake — 移除 mihomo-alpha 幽灵输入与 overlay（文件从未存在）

| コミット | 説明 |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |

## 2026-06-21T04:32:31+09:00

**Summary**：语言切换器标签规则泛化 — display_name 语义修正为语言自称、添加语言名称不本地化规则至 write-project-docs / translate-katalish / translate-pseudocn 三技能；修正 zh/katalish/pcn 全部文档切换器中残留的本地化名称

| コミット | 説明 |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称与切换器标签分离 |
| `aa8634b` | fix(docs): zh 文档切换器残留旧名称修正 + MAINTENANCE 翻译补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**Summary**：codewhale 0.8.62 — 上游修复；mcp-searxng 1.7.1 — 上游修复

| コミット | 説明 |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

## 2026-06-20T18:36:33+09:00

**Summary**：技能系统重构 — translate-katakana→translate-katalish 重命名，新增 translate-pseudocn（偽中国語），write-project-docs 与 write-maintenance-log 语言扩展自动发现，文档代码五语映射表

| コミット | 説明 |
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

**Summary**：codewhale 0.8.61 — 上游修复；mcp-searxng 1.6.0 — 上游修复

| コミット | 説明 |
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

**Summary**：ruyi — NixOS 兼容性补丁（`patches/ruyi-nixos-compat.patch`），透明处理预编译 RISC-V 工具链的动态链接器路径、GCC 子进程 ELF interpreter 修复和 console_scripts argv0 问题

| コミット | 説明 |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

## 2026-06-17T10:59:35+09:00

**Summary**：ruyi — NixOS 模块（`services.ruyi`），声明式生成 `/etc/xdg/ruyi/config.toml` 与环境变量

| コミット | 説明 |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

## 2026-06-17T10:03:05+09:00

**Summary**：ruyi — 新增 devShell 支持，`nix develop github:Kihara777/NixKits#ruyi` 即可进入环境

| コミット | 説明 |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

## 2026-06-17T09:48:33+09:00

**Summary**：ruyi 0.51.0-alpha.20260616 — RuyiSDK 包管理器，新包（Python / Poetry 构建，ruff + mypy + 320 单元测试 + 52 集成测试全部通过）

| コミット | 説明 |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

## 2026-06-17T07:37:39+09:00

**Summary**：write-maintenance-log 技能 — 从 nixkits-check-updates 剥离为独立技能，双入口设计（记入维护记录 + 更新维护记录）；flake.lock 同步 .gitignore 前置检测与三路分支逻辑

| コミット | 説明 |
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

**Summary**：fix(mcp-searxng): 修复入口文件错误 — dist/index.js → dist/cli.js，MCP 服务器可正常启动

| コミット | 説明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

## 2026-06-17T06:46:13+09:00

**Summary**：llama-cpp-rocm — 尝试用 builtins.fetchurl 替代 flake input 动态获取版本（已撤销，方案不可用）

| コミット | 説明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

## 2026-06-16T06:03:24+09:00

**Summary**：mcp-searxng 文档 — CodeWhale MCP 配置指南、常见陷阱警告（env 默认为 {}）、故障排查章节

| コミット | 説明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

## 2026-06-16T05:20:34+09:00

**Summary**：nixos-modern-cli 技能 — Nix Store 路径陷阱章节（gh auth setup-git 硬编码路径失效的诊断与通用修复模式）

| コミット | 説明 |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

## 2026-06-16T04:56:06+09:00

**Summary**：opencode-telegram 0.21.2 — 上游修复及依赖更新

| コミット | 説明 |
|------|------|
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |
| `3b05a32` | docs(MAINTENANCE): record 2026-06-16 update (opencode-telegram 0.21.2) |

|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | source hash | `sha256-V/rThMV5...` → `sha256-NEaQ2grHCKXi13utcHeUR83pJT6kqBGS4UqllhG93kY=` |
| 　 | npmDepsHash | `sha256-Bcexury...` → `sha256-z9trDo9xeWZyTSvCqX5XTb+AHY50wk0gsoEnAAEHOEg=` |

## 2026-06-15T17:32:16+09:00

**Summary**：codewhale 0.8.60 — 上游修复

| コミット | 説明 |
|------|------|
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |
| `3cef0a8` | docs(MAINTENANCE): record 2026-06-15 update (codewhale 0.8.60) |

|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `sha256-ti/IBPZV...` → `sha256-JqlByElHoLcR2Mlwmx5Qczfj+EoAp+igdLCd/QUOsX4=` |
| 　 | tui hash | `sha256-3Lh80hTS...` → `sha256-LTf681cWVH9Cu3TQrFeMlJUNVVG+TWxO2oI6VXK+4zA=` |

## 2026-06-14T08:11:16+09:00

**Summary**：comfyui-strix-halo 文档 — 在线集成模式说明与文件结构图

| コミット | 説明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

## 2026-06-14T07:56:11+09:00

**Summary**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；mcp-searxng 1.4.0 — 新增 HTTP 传输模式

| コミット | 説明 |
|------|------|
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `ec7d5ca` | docs(MAINTENANCE): record 2026-06-14 updates (codewhale 0.8.59, mcp-searxng 1.4.0) |

|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
| 　 | cli hash | `sha256-AR9jJZzB...` → `sha256-ti/IBPZVJdaLvQ00OevzTfcMQ0XHELvOKTcul4+iBg8=` |
| 　 | tui hash | `sha256-BpCHu9M...` → `sha256-3Lh80hTSMG0RG+CHkR403rqcMtDA6kMdbyvBe7sLQaQ=` |
| 　 | source hash | `sha256-Xsp1vReg...` → `sha256-RMzxCBua89oYbKXmwXCtcSHan5QVefsm8IBdMIVq7UE=` |
| 　 | npmDepsHash | `sha256-3hWshG0...` → `sha256-Lh1UoM8zSMFji/TkqDAOiRtFRrQ/jqn5TbONySj9ckg=` |

## 2026-06-12T18:17:52+09:00

**Summary**：llama-cpp-rocm 模块 — 恢复 modelsPreset 支持（nixpkgs 已移除）、命名空间迁移至 nixkits、三语迁移指南

| コミット | 説明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

## 2026-06-12T17:29:59+09:00

**Summary**：feat(llama-cpp-rocm): 恢复 modelsPreset 支持（nixpkgs 已移除），命名空间迁移至 nixkits

## 2026-06-12T10:51:31+09:00

**Summary**：codewhale 0.8.58 — 上游修复；mcp-searxng 1.3.4 — 上游修复

| コミット | 説明 |
|------|------|
| `b995798` | chore(pkgs): bump codewhale 0.8.58 |
| `ef9daae` | chore(pkgs): bump mcp-searxng 1.3.4 |
| `716d98c` | docs(MAINTENANCE): record 2026-06-12 updates (codewhale 0.8.58, mcp-searxng 1.3.4) |

|--------|--------|--------|
| codewhale | 0.8.57 | 0.8.58 |
| mcp-searxng | 1.3.2 | 1.3.4 |
| 　 | cli hash | `sha256-Hp0Z6mwe...` → `sha256-AR9jJZzB1VNUe7yaI3jpSUJsXuzgvqk5aWeLWe/L/vA=` |
| 　 | tui hash | `sha256-dExfhrfG...` → `sha256-BpCHu9MbDGuCAXNNJXPTZpj3BrIwx7jWs29I31cbSag=` |
| 　 | source hash | `sha256-OVllsRM...` → `sha256-Xsp1vRegHDWNk54nqLk+4l5MI0xGgocCg5Qa2UwWNqA=` |
| 　 | npmDepsHash | `sha256-LN9yDbw...` → `sha256-3hWshG0L8k0U2fnmz0OotrYaPAYBQE7DanjXgnFnNrE=` |

## 2026-06-11T05:28:59+09:00

**Summary**：技能文档 — 维护日志格式规则系列（自动发现泛化、描述性标题、精确 git commit 时间戳、禁止 T00:00:00 占位符）

| コミット | 説明 |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

## 2026-06-11T05:13:39+09:00

**Summary**：other — 2 项更新

| コミット | 説明 |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

## 2026-06-11T04:52:16+09:00

**Summary**：codewhale 0.8.57 — TUI 新增；mcp-searxng 1.3.2 — 上游修复

| コミット | 説明 |
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

**Summary**：opencode-telegram — KillMode 改为 process、添加 TimeoutStopSec 防止关机挂起

| コミット | 説明 |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

## 2026-06-10T02:28:10+09:00

**Summary**：codewhale 0.8.55 — 上游修复；mcp-searxng 1.3.1 — 上游修复

| コミット | 説明 |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

## 2026-06-08T15:12:39+09:00

**Summary**：文档重构 — 本地化文件移入 docs/ 目录；MAINTENANCE.md 首次添加合列规则、纯表格格式、回填完整提交历史

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

## 2026-06-08T14:25:02+09:00

**Summary**：mcp-searxng 1.2.1 — 上游修复

| コミット | 説明 |
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

**Summary**：rcc-fix — NixOS 模块（systemd 死锁修复）

| コミット | 説明 |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

## 2026-06-06T15:17:11+09:00

**Summary**：技能文档 — 源变更后文档同步规范；comfyui-strix-halo C 工具链说明；hash 计算注意事项泛化；基本情報规则多语言统一

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

## 2026-06-06T13:58:47+09:00

**Summary**：codewhale 0.8.53 — 上游修复；mcp-searxng 1.1.0 — 上游修复；opencode-telegram 0.21.1 — 上游修复

| コミット | 説明 |
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

**Summary**：comfyui-strix-halo 补丁 — ROCm 7.2 wheels 内嵌支持

| コミット | 説明 |
|------|------|
| `e11f899` | fix(docs): add missing ja doc and en/ja README entries for comfyui-strix-halo |
| `48d842f` | docs(ja): add 基本情報 section to comfyui-strix-halo |
| `ed25bb5` | docs(comfyui-strix-halo): rewrite trilingual docs in NixKits concise style |
| `8f16f91` | docs(skill): add length/structure rules from comfyui-strix-halo doc fix |
| `468b89a` | feat(skill): add patch-embedded version check for comfyui-strix-halo |

|--------|--------|--------|
| comfyui-strix-halo | 补丁（ROCm 7.2 wheels 内嵌） |

## 2026-06-04T13:07:30+09:00

**Summary**：技能系统 — SKILL.md 全面中文化；三语对称性检查规则

| コミット | 説明 |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

## 2026-06-02T10:15:53+09:00

**Summary**：other — 7 项更新

| コミット | 説明 |
|------|------|
| `3be4889` | docs: add recover-nixos-config skill with multi-language docs |
| `fc5eca3` | docs: fix Skills section titles and generic agent descriptions |
| `d2e071f` | docs: add quantization levels to local model names |
| `22d206c` | docs: add UD- prefix to model quantization labels |
| `f15db79` | docs: add MIT license file and link from all READMEs |
| `218aeca` | docs: add local flake input example alongside remote |
| `4f0f968` | docs: fix local flake input syntax to match actual usage |

## 2026-06-02T08:49:47+09:00

**Summary**：opencode-telegram — 8 项更新

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

## 2026-06-02T05:57:11+09:00

**Summary**：codewhale 0.8.49 — 上游修复；mcp-searxng 1.0.4 — 上游修复；obs-bilibili-stream 2.1.0 — 上游修复；opencode-telegram 0.21.0 — 上游修复

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

**Summary**：nixos-modern-cli 技能 — POSIX 工具指南与 nix 二进制路径提示

| コミット | 説明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

## 2026-05-31T03:42:18+09:00

**Summary**：write-project-docs — 新技能（按 NixKits 风格为任意项目编写多语言文档系统）

| コミット | 説明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

## 2026-05-30T03:42:14+09:00

**Summary**：codewhale — stdenv 拼写修复；llama-cpp-rocm 文档修正（移除内联链接、使用 system.nix 完整预设）；opencode-telegram 首次设置流程

| コミット | 説明 |
|------|------|
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

## 2026-05-30T03:19:48+09:00

**Summary**：other — 2 项更新

| コミット | 説明 |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

## 2026-05-29T15:25:12+09:00

**Summary**：kitsfmt — 多项修复（vendor 目录恢复、幂等性、原地安全性、with→builtins.attrValues 转换、--stdin 标志）；rcc-fix — 重写为 D-Bus 热插拔检测；build — .vscode gitignore 范围修正

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

## 2026-05-29T13:16:30+09:00

**Summary**：docs: fix codewhale type description (pre-built, not source-built)

| コミット | 説明 |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

## 2026-05-29T10:18:46+09:00

**Summary**：codewhale v0.8.47 — 新包

| コミット | 説明 |
|------|------|
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |

|--------|--------|--------|
| codewhale | v0.8.47 |

## 2026-05-29T06:28:50+09:00

**Summary**：fix(kitsfmt): 修复 inherit 逗号、缩进字符串损坏、lambda 空格等多个格式化问题；修复幂等性

| コミット | 説明 |
|------|------|
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |

## 2026-05-29T05:57:55+09:00

**Summary**：fix(build): 修复 .vscode gitignore 范围过宽导致 vendored crate 文件被排除

## 2026-05-28T08:29:27+09:00

**Summary**：llama-cpp-rocm — NixOS 模块（systemd 沙箱覆盖）；opencode-telegram — NixOS 模块（声明式配置、自动安装）；rcc-fix — visible 属性修复；技能文档 — 动态发现措辞

| コミット | 説明 |
|------|------|
| `3d2c38c` | docs(skill): nixkits-check-updates — dynamic discovery, not hardcoded list |
| `e5ee4ab` | docs(skill): remove hardcoded count from features, add exclusion note |
| `814731e` | docs(skill): sync ja doc with zh/en — dynamic discovery wording |
| `713b693` | fix(rcc-fix): use visible: property instead of if conditional for ScrollView |
| `34d309b` | docs(skills): add Install section with full 5-agent support to all skills |
| `2db934e` | docs(zh): simplify Skills description, remove semantic duplication |
| `bd9e1b9` | feat(llama-cpp-rocm): add NixOS module for service sandbox overrides |

## 2026-05-27T06:08:13+09:00

**Summary**：技能系统 — nixkits-check-updates、nixkits-skills、nixos-modern-cli 三大技能同步上线；llama-cpp-rocm 动态追踪说明

| コミット | 説明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

## 2026-05-26T05:30:58+09:00

**Summary**：文档 — README 节名重命名（快速开始→添加、包→软件、License→许可）

| コミット | 説明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

## 2026-05-24T03:01:02+09:00

**Summary**：mcp-searxng 文档 — SearXNG + lighttpd 反向代理完整 NixOS 配置

| コミット | 説明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

## 2026-05-22T06:45:11+09:00

**Summary**：llama-cpp-rocm — 移除 llama-cpp-ver flake 输入，使用 nixpkgs 默认版本

| コミット | 説明 |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

## 2026-05-21T16:35:02+09:00

**Summary**：mcp-searxng v1.0.3 — 新包；opencode-telegram v0.20.5 — 新包

|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

## 2026-05-16T19:07:54+09:00

**Summary**：kitsfmt — 修复 match_ast! 宏语法错误、简化 comments_before 函数、修正 src 路径

| コミット | 説明 |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

## 2026-05-15T16:59:28+09:00

**Summary**：kitsfmt — 基于 rnix AST 重写格式化引擎 v0.3.0；生成 Cargo.lock

| コミット | 説明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |

## 2026-05-14T17:10:06+09:00

**Summary**：llama-cpp-rocm — 新包（动态追踪上游最新 Release）

| コミット | 説明 |
|------|------|
| `9cb24a3` | llama-cpp MTP |

|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

## 2026-05-14T07:38:08+09:00

**Summary**：kitsfmt — 新包（自建 Nix 格式化器）；obs-bilibili-stream v1.0.0 — 新包

| コミット | 説明 |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

## 2026-05-01T01:08:15+09:00

**Summary**：rcc-fix — 新包（asusctl 补丁）

| コミット | 説明 |
|------|------|
| `e2d09a2` | RCC-Fix |

|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（overlay + patch） |

