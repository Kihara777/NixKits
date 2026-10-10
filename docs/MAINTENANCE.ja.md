# メンテナンスログ

[中文](../MAINTENANCE.md) | [English](MAINTENANCE.en.md) | 日本語 | [偽中国語](MAINTENANCE.pcn.md)

## 2026-10-10T15:48:29+09:00

**概要**：nixpkgs 既存の OBS プラグイン規約に草稿を整合、実欠陥を一件発見

- 現行 master の OBS プラグイン**全 54 件**を取得して統計を取った（一、二件の見本から一般化しない）
- **実欠陥**：上流 `CMakePresets.json` の template preset は `ENABLE_FRONTEND_API` を有効にするが `CMakeLists.txt` の既定は OFF で、当方は `ENABLE_QT` のみ渡していた；無効時は `NEEDED` に `libobs-frontend-api.so.30` が無く `.so` も別物；**自倉のパッケージにも同じ欠陥があり併せて修正**、修正後は両者の `.so` がバイト同一
- 統計に合わせて：`platforms` は `inherit (obs-studio.meta) platforms`（30/54）、`maintainers` は `with lib.maintainers; [ … ]`（50/54）
- `dontWrapQtApps`（17/54 = Qt 使用の 17 件）と「rm obs-plugins のみ」（17/54）は元から規約どおりと確認

| コミット | 説明 |
|------|------|
| `450ff40` | fix(upstream): 既存 OBS プラグイン規約に整合、欠落していた ENABLE_FRONTEND_API を追加 |

## 2026-10-10T15:38:10+09:00

**概要**：obs 草稿を現行 master に整合；披露の模型名を更正

- master を実査した結果、構造が二箇所変化：接線は `plugins.nix` の**自動発見**に（行追加は不要）、`callPackage` は通常のものに戻り（Qt は `qt6.qtbase` と書く）—— 本 PR は二ファイル変更から**一ファイル追加**へ；変更後の成果物パスは同一
- 披露の模型名を `DeepSeek-V41-Flash` に。変更は自己披露のみで、dsh の API 模型 id とログ履歴は**触らない**
- `upstream/MAINTAINER-ENTRY.md` を共用位置へ移動（blender-mcp 配下をやめた）
- 技能に陷阱 ⑬ を追加：手元の nixpkgs は構築に使えるが、**上流の構造判断には使えない**

| コミット | 説明 |
|------|------|
| `a2ec88c` | fix(upstream): 披露の模型名を DeepSeek-V41-Flash に |
| `ea113b9` | fix(upstream): obs 草稿を現行 master の形態に |

## 2026-10-10T15:31:21+09:00

**概要**：査読者の基準を実行可能なチェッカーにし、obs-bilibili-stream の草稿を作成

- `upstream/check-draft.sh`：査読者が挙げた問題群を機械的判据に。終了コード 0/1/2 を分離（**検証できず ≠ 合格**）
- 作成中に**誤警報**を二度：PATH に無い `python3` で「実行不能」を「失敗」と報告；`mainProgram` を無条件必須としてプラグインを誤検出
- obs 草稿：落点は `plugins/` と `default.nix` への一行（by-name ではない）。`-DENABLE_QT=ON` は必須、`-DOBS_SOURCE` は不要（外しても `.so` がバイト同一）
- 許諾を `gpl2Only` に更正（上流 `metainfo.xml` が `GPL-2.0-only` と宣言）；自倉のパッケージは `gpl2Plus` と誤記していた

| コミット | 説明 |
|------|------|
| `cc30658` | feat(upstream): obs-bilibili-stream 草稿と査読基準チェッカー |

## 2026-10-10T14:34:07+09:00

**概要**：上流貢献の初回着地 — blender-mcp を nixpkgs へ提出（PR #572360）

- PR [#572360](https://github.com/NixOS/nixpkgs/pull/572360)：`maintainers: add kihara777` と `blender-mcp: init at 1.0.3` の二コミット、+151 −0 / 二ファイル
- 上流 CI は **17 pass / 0 fail**、`Lint / nixpkgs-vet` と `Lint / treefmt` を含む——これまで推理のみだった棘輪と格式が、今は上流の実測で確認された
- 提出時に author/committer を GitHub の noreply アドレスへ変更：最初のコミットはアカウントの実メールを持ち、「維護者条目にメールを書かない」決定と衝突するため、分岐を削除して作り直した
- 披露の模型名は `deepseek-flash`（実行時の実際の報告）とし、commit trailer と PR 正文の三箇所で一致させた

| コミット | 説明 |
|------|------|
| `9b3fc25` | docs(upstream): PR #572360 の着地と提出時の二点の更正を記録 |

## 2026-10-10T14:21:32+09:00

**概要**：blender-mcp — 任意引数 `blender` を削除。`callPackage` の自動束縛を止められないと実測

- `callPackage { }` では `blender` が**依然として自動束縛**され、Blender 閉包全体が全利用者に入る。引数署名の `? null` では防げない
- 引数と `postFixup` を丸ごと削除：上流は PATH から探すため、固定したい人は `BLENDER_PATH` を設定する
- 判据：drv 内の `blender-5` 参照 1 → 0、産物 wrapper の `BLENDER_PATH` 有 → 無、引数 6 → 5
- 技能に罠 ⑪ 追加：nixpkgs における「任意依存」の正しい形は**その引数を書かないこと**

| コミット | 説明 |
|------|------|
| `b8f013b` | fix(upstream): 任意引数 blender を削除（自動束縛を止められない） |

## 2026-10-10T14:17:19+09:00

**概要**：上流草稿の三巡目 — 「go が出たか」を判据にし、二度の誤警報を記録

- `READY.md` 第 0 歩：fork / 分岐 / PR の三探査。実測はいずれも空（方法は既存倉庫で検証済）
- 六つの引数は全て使用中：引数名は `builtins.functionArgs` の求値から読み、原文テキストからは読まない
- 死に引数の確認で**誤警報**を二度：引数表の切り出し位置を誤り、正規表現の語境界が `blender-mcp` に命中
- 技能に罠 ⑩ を追加：判据の感度は対照臂で試す

| コミット | 説明 |
|------|------|
| `111b3de` | docs(upstream): go の判据と死に引数確認の二度の誤警報 |

## 2026-10-10T14:14:19+09:00

**概要**：blender-mcp 提出準備完了 — 維護者条目の落点を証拠付け、自己点検で一つの分岐を発見

- `MAINTAINER-ENTRY.md`：handle は未使用、`kiyotoko`/`kjeremy` の間に挿入、`githubId` は双方向で確認済、既存 488 条も `email` を書かない
- `READY.md`：11 の前提を各産物に結び付け、未検証項は別掲、実行順序と遮断時の切り分け表
- 棘輪（`strictDeps`/`__structuredAttrs`）の項は文書内で**推理**と明記、実測の装いはしない
- 自己点検で発見：commit 2 の本文が二箇所にあり**既に分岐**；`commit-message.txt` に同期し注記

| コミット | 説明 |
|------|------|
| `ae69543` | feat(upstream): 維護者条目の落点と提出準備チェックリスト |

## 2026-10-10T14:09:55+09:00

**概要**：blender-mcp 提出前の二点の証拠 — 自前 Gitea で自動更新が効くか、置換アンカーの代償

- `nix-update` は host を**探査式**に判定：既知一覧に無い host は `/api/v1/settings/api` が 200 を返す必要があり、`projects.blender.org` は実際に 200
- 取得した tag は `v1.0.3` 形式で、`tag = "v${version}"` から導かれる `version_prefix` と一致
- `--replace-fail` のアンカーが消えれば構築は失敗（意図的）：赤の方が、試験が半分しか走らないより良い
- 境界を記録：探査・tag 取得・接頭辞推論のみ確認。実 nixpkgs 検出での完全な `nix-update` は**未実施**

| コミット | 説明 |
|------|------|
| `40a9a8a` | docs(upstream): 自動更新と置換アンカーの証拠記録 |

## 2026-10-10T14:00:48+09:00

**概要**：blender-mcp 上流草稿の doCheck を打通 — 上流テストの真の bug も修正

- 当初は 139 errors + 16 failed。原因は上流テスト helper が PYTHONPATH を**上書き**していて、依存を丸ごと捨てていたこと
- 修正は `--replace-fail`：上流がこの二箇所を変えれば構築が即失敗し、黙ってテストを減らさない
- `tests/test_blender_mcp_with_blender.py` は除外：実物の Blender 実例が要り、沙箱では走らない
- 実測 102 passed / 9 skipped / 0 failed。反例：修正を外すと 15 failed + `McpError` 117 件
- 許諾の根拠を確認：v1.0.3 の源文件に SPDX 頭、上流 issue #59 で確認済み、別途 issue は不要

| コミット | 説明 |
|------|------|
| `2824c74` | feat(upstream): doCheck 打通（102 passed）と上流テスト bug の記録 |


## 2026-10-10T12:59:05+09:00
**概要**：nixpkgs 上流貢献 — 実現可能性評価、二つの技能、blender-mcp の dry-run

- 13 包を一件ずつ確認：既に nixpkgs に在るのは `mcp-searxng` のみ。`dsh` は先方では `deepseek-harness` と呼ばれ、在途 PR が既に三本
- 参加要件の監査：by-name、`nixpkgs-vet` の 12 検査 + 3 棘輪、AI 政策が要求する `Assisted-by:` の格式
- 汎用技能 `nixpkgs-package-upstream` と適配層 `nixkits-package-upstream` を追加（四言語の文書頁と索引を同期）
- dry-run：blender-mcp の四層判据が全通過（**握手の実走**を含む）、反例も撞響済み
- ruyi の陳腐化した自述を更正：かの overlay は元来宿主が無く、nixpkgs は ruyi を**一度も**提供していない

| コミット | 説明 |
|------|------|
| `d7ec6ff` | docs(upstream): 可行性评估与入场要求审计 |
| `27be3f3` | feat(skills): 新增两个上游贡献技能 |
| `4a2db07` | feat(upstream): blender-mcp dry-run 产物与判据自证 |
| `c6476c2` | fix(docs): 更正 ruyi 的过期自述 |

## 2026-10-08T23:25:20+09:00

**概要**：chore(dsh): alpha チャネルを `alpha` に、stable の pin を前進、README の版自述に判定を追加

- `dsh-alpha` 0.2.0-rc.2 → **0.2.1-alpha.1**：当初の前提「`alpha` は 0.1.x の旧線上で stable より低い」が**反転していた**；hash は `got:` から取得、vendored lock は構築物と逐バイト同一
- stable の `pinnedRev` `0175f85` → `1e85409`：代償は旧形式がパッケージに同梱されなくなること。0.1.x の利用者は旧 rev を自分で取る（今も取得可能）
- README の版自述が**四箇所**腐っていた（`dsh-alpha` は二代、`ruyi stable` は一代遅れ。いずれも四言語）——新しい判定で固定し、反証も検証済み
- `docs/*/dsh.md` のプラグイン一覧に限定を追加：alpha は stable より二行多い。stable へ写すとハード失敗になる

| コミット | 説明 |
|------|------|
| `b17bd73` | chore: stable チャネルの pinnedRev を前進（`0175f85` → `1e85409`） |
| `bf0b9ac` | chore(dsh-alpha): チャネルを npm `alpha` に戻す |
| `52fcdbc` | fix(docs): README の版自述を修正し、判定を追加 |

## 2026-10-08T23:03:29+09:00

**概要**：chore(pkgs): mcp-searxng 2.5.1 と codewhale 0.10.1 —— 構造変更の処置と CI 煙試験の穴埋め

- mcp-searxng：純粋な依存/セキュリティパッチで機械的置換で足りる；成果物は握手に実際 2.5.1 と答える
- codewhale 0.10.1 は**二つの実行ファイルを一つに統合**した——hash 系の判定はこの種の構造変更を見えない；**構築**が叫んだ。postInstall を上流の説明どおりに書き換え
- 併せて処置：上流の改名 `codewhale-hq/Codewhale`、空転していた rquickjs riscv64 workaround の削除、既存の文書誤り二箇所
- **煙試験を新設し三アーキテクチャで `smoke-test` を有効化**：riscv64 の成果物は CI で一度も実行されていなかった；四つの判定（反証を含む）を CI が実際に走らせた
- 他の上流と三つの固定 SHA action はすべて最新

| コミット | 説明 |
|------|------|
| `1645aba` | chore(pkgs): mcp-searxng 2.5.0 → 2.5.1 |
| `bbe7e7a` | ci(codewhale): 三アーキテクチャで smoke-test を有効化 |
| `19cc335` | chore(pkgs): codewhale 0.10.0 → 0.10.1（上流改名と riscv64 の構造変更） |

## 2026-10-08T16:53:41+09:00

**概要**：dsh-api-balance re-pin —— rev `95fec42` → `43f4d18`（子リポジトリの変更は[メンテナンスログ](https://github.com/Kihara777/dsh-api-balance/blob/main/MAINTENANCE.md#2026-10-08t1638010900)に：キーボードガードを硬い阻止方式へ）

- 薄いラッパーは座標のみ記録：rev と src hash；子リポジトリが自身の完全な変更を記録し、重複しない
- 子リポジトリの判定：新しい「同一フレーム競合」反例（アプリが `contenteditable` を書き戻して即 `focus()`）、全体 15/15
- 併せて：`check-maintenance-log.py` が `--root <repo>` に対応——子リポジトリのログも同じ判定で核（スクリプトを複製しない）

| コミット | 説明 |
|------|------|
| `62fc667` | fix(dsh-api-balance): re-pin を 43f4d18 へ —— キーボードガードを「既定で編集不可 + プログラム的 focus を飲み込む」方式に |
| `420b303` | chore: ログ検証器に --root + re-pin |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再ピン） |
| 　 | rev | `95fec42` → `43f4d18` |
| 　 | src hash | `sha256-bRZWVKmv4nHow0TWMdMww/cFnP9A6vJ08sQCloaRpEE=` → `sha256-jNbfG09da6RYiSRfCm0P5pxBIo9LG38bpSAdVZaxyXc=` |

## 2026-10-06T01:12:23+09:00

**概要**：chore(pkgs): godot-ai 4.2.3 → 4.3.0 —— fail-closed な実行時検証つき

- 依存 pin は 14 項の集合が変わらず、上がったのは 6 項のみ；二つの消費経路が解決する依存は完全に一致（以前「一箇所だけ変更」で分岐したことがある）
- 実行時検証は本当に走った：成果物の `--version` が通り（上流の `main()` は最初に依存を検証する）、逐項 14/14；**反証**として偽の `fastmcp-9.9.9` を注入 → 成果物は起動を拒否
- anyio と新しい Python 3.12.15 の衝突は既存の環境問題（HEAD と drvPath が同一であることを証拠に）；`--deselect` + nodeid 前置で 12 件だけを外し、コメントに撤去条件を書いた
- starlette 1.7.0 が増やした収集期の import は補って**テストを切らなかった**（1275 collected → 1269 passed）
- 未検証：生きた Godot エディタが要る GUI 機能

| コミット | 説明 |
|------|------|
| `9b3260d` | chore(pkgs): godot-ai 4.2.3 → 4.3.0（fail-closed 実行時検証つき） |

## 2026-10-06T00:48:30+09:00

**概要**：feat(check): 自検の強化 —— 反証用例集と pcn 全庫の字形修正

- 反証用例集（第 10 項 `self-tests`）：各検査は「対照が通る → 既知の悪い入力を注入 → 期待した文言で失敗する」ことを検証。11 正例 + 2 負例すべて通過
- これが即座に本物の穴を発見：`workflow-coverage` はファイル名の接頭辞しか見ておらず、`build-x-….yml.disabled` でも被覆と見なしていた
- 新しい判定：`flake.nix` の一覧コメントは `checks` と一対一で一致；pcn に非日文字形を出さない；en 概要を中文原稿のままにしない（閾値は 367 条で標定）
- pcn 全庫修正 45 種の字形 / 187 箇所 / 39 文書 + 辞書 9 条（判定を有効にした途端に出た既存の欠陥）
- opencode-telegram → 0.26.3（純粋な bugfix、hash は `got:` から、二つのアーキテクチャで煙試験通過）；固定 SHA の action 三個はすべて最新

| コミット | 説明 |
|------|------|
| `192ec4a` | feat(check): 自検の強化 —— 反証用例集 + 四つの新しい判定 + 全庫語料修正 |
| `f8e6fc7` | chore(pkgs): opencode-telegram 0.26.2 → 0.26.3 |

## 2026-10-05T23:43:17+09:00

**概要**：fix(skill): 概要は常にリスト形式 —— 規定・判定・全庫回溯

- レイアウトは「散文かリストか」から**リストのみ**へ：一文の見出し + 空行 + 最低一つの `- ` 項目；一事だけの条目も一行リストにする
- 全庫の散文概要 336 条を四言語で回溯（項目数は条目ごとに四言語一致、全体で 1–8・平均 3.2）
- 判定：`develop/check-maintenance-log.py` に「`- ` 項目が無い概要は失敗」を追加；技能、`AGENTS.md`、四言語の文書ページを同期
- 判定根拠：366 条 × 四言語でチェッカー全通過；回溯前の HEAD と比較した無損監査で語彙欠落 **0**；`nix flake check` 9 項全通過

| コミット | 説明 |
|------|------|
| `78e1e7c` | docs(MAINTENANCE): 散文概要 336 条を見出し + リストへ回溯（四言語） |
| `6463640` | feat(skill): 概要は常にリスト形式（規定 + 判定 + 文書ページ） |

## 2026-10-05T23:15:53+09:00

**概要**：feat(check): `doc-counts` を新設 —— 源から機械的に読み出せる計数は源と一致していなければならない（`nix flake check` 8 → 9 項）

- 発端：同日に二度「文書が失真したまま誰にも見えない」——辞書マッピングを一つ補った後、四言語頁の「**75** 条」が失効；検査を一つ足した後、`AGENTS.md` の「8 項自検」が失効
- 二つの規則：辞書条数 == `dictionary.md` のデータ行数；自検項数 == `flake.nix` の `checks` 条目数（python 実装分を含む）
- 反証：一時コピーに二箇所の違反を注入し、それぞれ「申告 X ≠ 実際 Y」を報じて exit 1；現行は全緑
- スクリプトは規則表で構成（規則追加＝一行）；`AGENTS.md` の自検表と `flake.nix` のコメントを同期

| コミット | 説明 |
|------|------|
| `c1e53bf` | feat(check): `doc-counts` を新設 —— 源から機械的に読み出せる計数は源と一致必須 |

## 2026-10-05T22:20:17+09:00

**概要**：feat(check): メンテナンスログの形態要件を判定として固定 —— zh 概要 ≤ 400 文字、リスト項目数の四言語一致、説明ブロックは一行かつ本語のマーカー

- 発端：規約は「目標 ≤ 400 文字」と書いていたが、目標のまま回した 1 ラウンドで 21 条が 420–721 文字 —— **違反は一つも無い**
- 訳文に長さの門は設けない —— 中、英、日は密度が異なる（実測の字面比中位数：en 1.87、ja 1.17、pcn 1.03）。同じ数字を課せば「事実を削って長さを合わせる」を誘発するだけ
- 反証：一時コピーに四種類の違反（超過概要 / en のリスト一行削除 / pcn の説明ブロック二行 / マーカーを `**注**` へ変更）を注入し、四つの分岐がそれぞれ想定どおり失敗して exit 1；現行ログは全緑
- `AGENTS.md` の検査表、`skills/write-maintenance-log/SKILL.md`、四言語の文書ページを同期；27 条のリスト形式概要を規約の例のレイアウトへ揃えた（見出しとリストの間に空行、判定側は両方を受け入れる）

| コミット | 説明 |
|------|------|
| `8d58fb3` | feat(check): メンテナンスログの形態要件を判定として固定（zh 長 / リスト項目 / 説明ブロック） |
| `9165a8e` | fix(check): 概要の解析が二通りのリスト排版を受け入れ、27 条を規約の例へ整列 |

## 2026-10-05T14:54:21+09:00

**概要**：feat(skill): `write-maintenance-log` の概要が **markdown リスト**での記載を許可

- 「概要は概要」の節に二通りのレイアウトを示し、**長さ予算は同一**（合計 ≤ 400 文字）と明記——リストは「多く書く」許可ではない。各行は依然「何が変わったか」だけを答える
- リストはコミット表を**置き換えない**：コミット id は `| コミット | 説明 |` にのみ現れる
- 多言語同期：リスト形式は**逐条翻訳し、項目数を一致させる**（一つ足りなければ翻訳漏れ、一つ多ければ水増し）
- 4c の検証節に実行可能な判定を追加（各言語の `grep -c '^- '` が等しい）し、その日に実際に踏んだ教訓も記載：**判定を緩く書きすぎない**

| コミット | 説明 |
|------|------|
| `e2cb5ab` | feat(skill): メンテナンスログの概要で markdown リストを許可；四語ドキュメントページ同期 |

## 2026-10-05T14:24:37+09:00

**概要**：dsh-api-balance 薄ラッパー re-pin —— メンテナの二度目のフィードバックによる質問ダイアログのフェード修正

- rev `911df2e` → `95fec42`（変更はそのコミット [`f39c816`](https://github.com/Kihara777/dsh-api-balance/commit/f39c816) にあり；バージョンは `0.1.1` のまま）
- フェードを下端のみから**スクロール連動**の上下フェードへ（`none/start/end/middle` の状態機械で、最上部では上端が、最下部では下端がフェードしない）
- カードは全体ではなく上端のみフェード —— 全体 mask は追従ボタンまで淡くする
- ボタン下の切り取られた内容は同色の埋めで塞ぐ
- 判定：三状態を逐一確認
| コミット | 説明 |
|------|------|
| `16f4fef` | fix(dsh-api-balance): re-pin to 95fec42 — scroll-aware fades in the question dialog |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再ピン） |
| 　 | rev | `911df2e` → `95fec42` |
| 　 | src hash | `sha256-oc+TPbtuwItV43kskjpz18Ys2cTtCgceXAGrh0Q0D2c=` → `sha256-bRZWVKmv4nHow0TWMdMww/cFnP9A6vJ08sQCloaRpEE=` |

## 2026-10-05T13:58:51+09:00

**概要**：dsh-api-balance 薄ラッパー re-pin —— メンテナのスクリーンショット指摘により質問ダイアログ下端の「一刀両断」を解消

- rev `1f0af6c` → `911df2e`（変更はそのコミット [`4cf04a0`](https://github.com/Kihara777/dsh-api-balance/commit/4cf04a0) にあり；バージョンは `0.1.1` のまま）
- 高さ制限したプロンプトの下端に `mask-image` のフェード、追従ボタンの上に `::before` のグラデーション帯を敷く
- グラデーション色は注入時にカードの実際の背景色から取得（明 `rgb(255,255,255)` / 暗 `rgb(44,44,46)`；固定色はダークで露見する）
- 判定：プロンプト下端 30px の平均輝度が 59.93 → 45.92（約 23% 暗い）、フェード帯より上（60–90px）は不変
| コミット | 説明 |
|------|------|
| `e755381` | fix(dsh-api-balance): re-pin to 911df2e — fade mask at the question dialog's bottom |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再ピン） |
| 　 | rev | `1f0af6c` → `911df2e` |
| 　 | src hash | `sha256-f3dg9oSbtKeYO6KzJZdpxz86gDUAI6vbRy8R3SSwroU=` → `sha256-oc+TPbtuwItV43kskjpz18Ys2cTtCgceXAGrh0Q0D2c=` |

## 2026-10-05T13:23:30+09:00

**概要**：dsh-api-balance 薄ラッパー re-pin —— メンテナのフィードバックによる二点の修正

- rev `f805f4e` → `1f0af6c`（変更はそのコミット [`e6d638c`](https://github.com/Kihara777/dsh-api-balance/commit/e6d638c) にあり；バージョンは `0.1.1` のまま）
- ① 下部統計バーの横スクロールを**廃止**（公式 0.2.0 は各指標をクリックできるピルにしており、設定行はグレーアウト）
- ② 質問ダイアログの header を高さ制限（≤40vh）して自身でスクロールさせ、追従をやめた —— 長いプロンプトでは選択肢を隠していた
- 判定：本パッケージの**ビルド成果物**を対象に `develop/ab-ui` を実行（C2/C6 を「結果」層へ変更）、稼働ツリーは `develop/check-deployed-artifact.py` の三つの特徴文字列で照合
| コミット | 説明 |
|------|------|
| `1548c4c` | fix(dsh-api-balance): re-pin to 1f0af6c — stats bar retired, question prompt no longer hides the options |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再ピン） |
| 　 | rev | `f805f4e` → `1f0af6c` |
| 　 | src hash | `sha256-u1L1VHy86tOeB3iv3MhCdL0VAi8xpNUf2OJHAa/zndY=` → `sha256-f3dg9oSbtKeYO6KzJZdpxz86gDUAI6vbRy8R3SSwroU=` |

## 2026-10-05T07:45:26+09:00

**概要**：CI 修正 —— 浮動入力 `llama-cpp-ver` を「認証付き取得 + ローカル上書き」に変更し、`api.github.com` 403 制限を根治

- 当該入力は**通常の URL 入力**で、Nix は `access-tokens` / `netrc-file` をこの種の fetch に**付与しない**
- 各 job の未認証リクエストが runner IP 共有の 60 回/時枠を使い切る（403）
- 先に `gh api` で同一の JSON を取得し、`--override-input llama-cpp-ver path:<json>` で Nix に渡す
- 意味は不変（overlay は `json.tag_name` のみ読む）、`tag_name` 欠落は**明示的に失敗**する
- `access-tokens` は残す —— 担当は `github:` 取源である
| コミット | 説明 |
|------|------|
| `335dce9` | fix(ci): 浮動入力 llama-cpp-ver を「認証付き取得 + ローカル上書き」へ |
| `e92cfe4` | fix(ci): 上書きパラメータが空なら明示的に失敗 —— 未認証取得へ暗黙に退避しない |
| `35eec1e` | docs: 実測で否定された「access-tokens が llama-cpp-ver の 403 を治す」結論を訂正（AGENTS.md + 技能） |

## 2026-10-05T07:14:50+09:00

**概要**：dsh-api-balance 薄ラッパー re-pin —— モバイルのキーボード防護を書き直し

- rev `8dab668` → `f805f4e`（変更はそのコミット [`f805f4e`](https://github.com/Kihara777/dsh-api-balance/commit/f805f4e4445cd4db6a3ccd16e23cfd90fb092208) にあり；バージョンは `0.1.1` のまま）
- モバイルの「セッション切替時にキーボードを出さない」は**依然として効いていなかった**：実際の `focusin` はキャンセル不可（`preventDefault` は死んだコード）で、ソフトキーボードは `focus` の瞬間に要求される
- 入力欄はユーザーがタップするまで編集不可となり、タップ / キー入力で即座に復帰、フォーカスが外れると再び武装する
- 判定：セッション切替中に編集可能な入力欄へ focus が落ちる回数は 0（デプロイ版は 2）、`develop/ab-ui/` は本パッケージの**ビルド成果物**を対象とする
| コミット | 説明 |
|------|------|
| `a4b6bb1` | fix(dsh-api-balance): re-pin to f805f4e — mobile keyboard guard rewritten around the real causal chain |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再ピン） |
| 　 | rev | `8dab668` → `f805f4e` |
| 　 | src hash | `sha256-yM+rQb/xIuTiN6QGpWr++jd2vDGHoN5K4gHnLmkGB4A=` → `sha256-u1L1VHy86tOeB3iv3MhCdL0VAi8xpNUf2OJHAa/zndY=` |

## 2026-10-04T09:23:29+09:00

**概要**：fix(dsh-preset-news-three-elements): プリセットプラグインの会話メッセージ来源を v4 形状へ

- dsh 0.2.0 の会話フォーマット v4 は字面量 `kind: "plugin"` だけを拒み、本リポジトリのプリセットプラグインはそれを丸写ししていたため、メッセージが書かれるたびに准入で拒否され、session 全体が「本機実行失敗」になった
- 三箇所を `{ kind: `plugin:${name}`, form: "notice", summary }` へ変更（`news-language.js` ×1、`news-material.js` ×2）
- テストの断言を `source.plugin` から `source.kind` へ
- さらに自検 `session-sources`（`develop/check-session-sources.py`、`nix flake check` に接続）を追加し「本リポジトリのプリセットプラグインに `kind: "plugin"` を出さない」ことを固定
| コミット | 説明 |
|------|------|
| `d27e6ce` | fix(dsh-preset-news-three-elements): 会話来源を v4 形状へ（自検 `session-sources` の追加と `nix flake check` への接続、四語 dsh 文書への v4 来源准入の節追加、AGENTS 自検表 7 項 → 8 項も含む） |

## 2026-10-03T09:49:14+09:00

**概要**：dsh-api-balance 薄ラッパー re-pin —— dsh 0.2.0 の UI 改善を再確認中に**静かな失効**を二件検出

- rev `700fbbc` → `8dab668`（バージョンは `0.1.1` のまま）
- ① 下部統計バーの横スクロールは **dsh 0.1.5 以降効いていない** —— 上流がスタイルモジュールを `StatsLine.module.css` から `StatsPills.module.css` に改名し、プラグインは旧名しか見ないまま設定のその行は On のまま表示されていた
- ② 三つの token が 0.2.0 に存在せず、うち `--dsw-alias-separator-primary` は 18 箇所の境界線を担い **fallback も無い**
- 現在は 0.2.0 の対応先へ連鎖
- 判定：隔離実例 + Playwright（デプロイ版では二項目とも失効）
| コミット | 説明 |
|------|------|
| `18441ef` | chore(pkgs): re-pin dsh-api-balance rev（界面改进两项失效修复；版本仍 0.1.1） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再ピン） |
| 　 | rev | `700fbbc` → `8dab668` |
| 　 | src hash | `sha256-GEG3/ImXmo3BgO7AVh/rj1mIWsWMGB04Six+oIk9UIE=` → `sha256-yM+rQb/xIuTiN6QGpWr++jd2vDGHoN5K4gHnLmkGB4A=` |

## 2026-10-03T06:45:00+09:00

**概要**：dsh-api-balance 薄ラッパー re-pin —— **実行時挙動の修正**

- rev `76ea584` → `700fbbc`（変更はそのコミット [`cc89c43`](https://github.com/Kihara777/dsh-api-balance/commit/cc89c43) にあり；バージョンは `0.1.1` のまま）
- ① 回車交換のインストールをコンポーネントのライフサイクルから外へ —— dsh 0.2.0 のチェーンスロット `conversation.composer` が接管されると環コンポーネントはスロットと共にアンマウントされ交換器も静かに外れるため、現在は `apply()` 内でインストールする
- ② パネル / ダイアログの材質を 0.2.0 の原生レシピで書き直した —— `--dsw-specific-menu` が半透明になり `backdrop-filter` を重ねる必要があり、旧レシピではパネルが本当に透明になっていた
- 判定：Playwright で computed style を実測
| コミット | 説明 |
|------|------|
| `6a8f68f` | chore(pkgs): re-pin dsh-api-balance rev（回车交换 + 面板材质修复；版本仍 0.1.1） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 0.1.1 | 0.1.1（rev 再ピン） |
| 　 | rev | `76ea584` → `700fbbc` |
| 　 | src hash | `sha256-7Yr9ALLN9hQTut5XziFLulmMde5GRgxTjBWidaxKqno=` → `sha256-GEG3/ImXmo3BgO7AVh/rj1mIWsWMGB04Six+oIk9UIE=` |

## 2026-10-03T06:15:29+09:00

**概要**：文書 —— メンテナンスログの ja / pcn **未訳条目**を補完

- ja **80** 条、pcn **59** 条 —— 概要行は `**Summary**` 標記 + 英語または中国語の旧稿で、内容自体も現行 zh 源と食い違うため、zh 源どおり**行ごと置換**した
- チェッカーに第 6 条「**概要標記はその言語自身のものでなければならない**」を補い、ja の `**Summary**` と en の `**概要**` がそれぞれ反証として赤に転じた
- **検証**：`nix flake check` 全緑；四語それぞれ 358 条、ja / pcn とも残留 0 条
| コミット | 説明 |
|------|------|
| `197099e` | fix(docs): 补齐 ja 80 条 / pcn 59 条未译条目，并修 pcn 一处错标签 |
| `44793f3` | feat(develop): maintenance-log 检查补第 6 条 —— 摘要标记须是本语的 |

## 2026-10-03T05:16:47+09:00

**概要**：技能 —— メンテナンスログの**倍率判定に第二の特徴：バッククォート占比**を補完

- CJK 密度だけでは過大評価になる：密度 0.646 の条目は密度だけの帯（n=34）の平均 **2.37** で「短い」と判定された
- バッククォート占比を加えた最近傍（n=15）の平均は **1.98** で、納品した 1.95 はそこに落ちる
- バッククォートの中身は逐字で写すため占比が高いほど倍率は 1 に近づく；ゆえに「同構造 + 同密度帯の比較」へ改めた
- **検証**：`nix flake check` は四語すべて全緑
| コミット | 説明 |
|------|------|
| `bad01c4` | refactor(skills): 倍率判据补第二个特征（反引号占比）—— 只看密度会高估，实测差 0.4 倍 |

## 2026-10-03T05:13:21+09:00

**概要**：文書 —— `blender-mcp` / `obs-bilibili-stream` の二箇所の riscv64 除外の理由を正した

- 「依存チェーンの交叉コンパイル欠陥」ではなく、**主依存が nixpkgs 側でそのアーキテクチャを宣言していない**こと（`blender 5.2.2`、`obs-studio 32.2.2` の `meta.platforms` はいずれも riscv64 を含まず、評価段階で拒否される）
- 判定は `pkgs.<dep>.meta.platforms` であり**コンパイルエラーではない**
- **検証**：`nix flake check` は四語すべて全緑
| コミット | 説明 |
|------|------|
| `e454504` | docs(pkgs): 两处 riscv64 排除的理由改准 —— 上游没声明该架构，不是「交叉编译缺陷」（四语） |

## 2026-10-03T04:53:28+09:00

**概要**：文書 —— `AGENTS.md` の配備確認の判定を「**ユニット参照を見る**」へ変更

- dsh 0.2.0 は起動時に `cordis.patch.yml` を書き換えるため、書き出されるのは dsh 自身の直列化結果であり、内容で比較すれば**偽陰性**しか得られず、成功した配備を失敗と判定してしまう
- 新しい判定は、稼働中ユニットの pre-start スクリプトが参照する store パスと、現在の設定が生成するものとを比較する（二つのコマンドを文書に記載）；本機の実測では一致した
- **検証**：`nix flake check` は全緑
| コミット | 説明 |
|------|------|
| `5df33e9` | docs(AGENTS): 部署核对判据换成「看单元引用」—— 原判据已失效：dsh 启动时会重写 cordis.patch.yml |

## 2026-10-03T04:43:18+09:00

**概要**：**私自身が招いた二箇所の綻び**を修した（チェッカーと倍率判定）

- ① チェッカーには「テーブルごと消えた」が見えない：`check-maintenance-log.py` の従来四条はいずれも総数しか見ておらず、標題と概要だけを書いて**コミット表を落として**も通過した
- 第 5 条**構造対等**を補った（各条目のコミット SHA 集合は四語で zh と一致すべき）
- ② 技能に書いた倍率判定それ自体が誤り：全倉平均（`en/zh` ≈ 1.84）で訳文の冗長さを判定していたが、実測では CJK 密度と倍率の相関係数が **r = 0.90** —— 同密度帯の平均は 2.29 で、「超過」と判定された条目は実際には帯を下回っていた；平均に従えば**内容を削る**ことしか強いられないため、同密度帯での比較へ改めた
- **検証**：`nix flake check` は全緑；チェッカーの三つの反証（表ごと削除 / SHA 一桁の改変 / 条目ごと削除）はすべて赤に転じた
| コミット | 説明 |
|------|------|
| `21993c8` | fix(develop): maintenance-log 检查补「结构对等」判据 —— 原有的四条只看总量，漏掉过「某条目在某译文里整张表都没了」 |
| `1c6e4be` | refactor(skills): 修正倍率判据 —— 全库均值混着 CJK 密度这个强混杂因子（实测 r=0.90） |

## 2026-10-03T04:27:03+09:00

**概要**：`opencode-telegram` の riscv64 を**「摘出」から「ビルド」へ戻し**、「**成果物を本当に一度走らせる**」判定を追加

- 二箇所の gyp 罠を修正（交叉コンパイラを指す `gcc` shim、`better-sqlite3` への明示的な `--force_build=1`）
- `build-package.yml` に `smoke-test` を新設 —— ビルド後に `develop/qemu-smoke-tests/<包名>.sh` を走らせ（ローカルと CI で同一のもの）、スクリプトが無くても binfmt ハンドラが無くても失敗と判定する
- **検証**：二度のプッシュはそれぞれ 33 本の workflow がすべて success
| コミット | 説明 |
|------|------|
| `af82af7` | feat(ci): riscv64 产物改成「真的跑一遍」—— 修好两个 gyp 陷阱 + build-package 加 smoke-test 开关 |
| `16bcc25` | refactor(skills): 泛化「缓存假绿」与「构建成功≠产物能跑」—— 含 smoke-test 机制与反证要求 |
| `ab20373` | fix(opencode-telegram): 用构建平台的 node 跑 node-gyp —— PATH 上的 node 是 riscv64 的，x86_64 runner 上执行不了 |
| `ab4e884` | refactor(skills): 记下「本机构建条件比 CI 宽松」—— binfmt 在本地让 riscv64 二进制能跑，于是本地绿掩盖了 CI 缺陷 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| opencode-telegram | — | バージョンは変わらず（0.26.2）；**ビルドマトリクス**：x86_64 + aarch64 → x86_64 + aarch64 + riscv64（かつ riscv64 は qemu スモークテスト付き） |

## 2026-10-03T02:26:58+09:00

**概要**：`opencode-telegram` の **riscv64 ビルドを摘出** —— 緑になったのは**ビルド修理ではなく**、使えないはずのプラットフォームを建てなくなったから

- あの job はずっと**キャッシュによる偽の緑**で（ログにビルドは一行も無く、成果物は前バージョン 0.25.3）
- 真のビルドは `better-sqlite3` で詰まる —— **直接依存**かつ**静的に import** され、上流に riscv64 の prebuild は無く、v13 から `install` スクリプトも廃止；成果物は**ビルドはできるが起動と同時に投げる**
- `blender-mcp` / `obs-bilibili-stream` と同一先例で摘出
- 検証：x86_64 / aarch64 は影響なし
| コミット | 説明 |
|------|------|
| `b488bae` | fix(opencode-telegram): 摘掉 riscv64 构建 —— 上游 better-sqlite3 无 riscv64 预编译，产物能构建但一启动就抛 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| opencode-telegram | — | バージョンは変わらず（0.26.2）；ビルドマトリクス：x86_64 + aarch64 + riscv64 → x86_64 + aarch64 |

## 2026-10-02T20:38:40+09:00

**概要**：二箇所の**判定盲点**と一箇所の**同名衝突** —— `doc-links` 判定、プリセット技能副本、persona の三点を収束

- `doc-links` の切替器判定は `docs/` 配下に必須かつ**全文**検索へ変更（旧版は `lines[:8]` しか見ず、「行の丸ごと削除」も「8 行目より後ろ」も静黙で通過 —— 四份の `docs/*/ruyi.md` は一度も検証されなかった）
- プリセットはコンポジション記述技能の副本を自前で持たない形へ（上流と**同名で内容が分岐**、上流のものをマウントし断言で固定）
- persona の陳腐化した記述を除去
- 検証：`nix flake check` は全緑；プリセットを使い捨て `0.2.0-rc.2` 実例へ投入、**9 条目**の **`broken`** は全空
| コミット | 説明 |
|------|------|
| `fa0beff` | fix(develop): doc-links 的切换器判据补上盲区 —— docs/ 下强制存在、全文查找 |
| `1e85409` | refactor(dsh): 预设不再自带组合撰写技能副本 —— 改挂上游那份，并去掉已过期的 persona 说法 |

## 2026-10-02T19:54:49+09:00

**概要**：dsh **0.2.0-rc.2** —— 二つのチャネルがそろって世代を跨ぎ、**Agent プリセット移行を落地**

- 実測で `alpha` は `latest` より低く（`latest` = `next` = `0.2.0-rc.2`）、ゆえに `dsh-alpha` は `next` へ追随；両チャネルは同一 tarball を指し hash と lock を共用
- 0.1.x のディレクトリ式プリセットは上流が丸ごと削除し、旧形式は新設の rev ピン留めパッケージが提供
- モジュールは `passthru.dshChannel` で二択し、`preset.patch.yml` を**逐字**、生成される `cordis.patch.yml` へ差し込む形に変更；旧 settings キーは断言で止まる
- 検証：四語の自検は全緑；使い捨て実例を実走しプリセットと技能根の解決を確認
| コミット | 説明 |
|------|------|
| `e4bcdee` | chore(pkgs): dsh 两通道升到 0.2.0-rc.2 —— alpha 改跟 npm next，两通道共用一份 vendored lock |
| `2b37ba5` | feat(dsh): 预设内容来源分叉 —— stable 冻结在钉住的 rev，alpha 跟仓库 HEAD |
| `b20a4c3` | refactor(presets): 预设迁到 0.2.0 单格式 patch 行（nixos / maintenance / news-three-elements） |
| `1fd1768` | feat(dsh): 模块按 0.2.0 接线预设与宿主面 —— patch 行播种、agent-preset-registry、node_modules 双链接 |
| `b5a767a` | docs(dsh): 四语文档同步 0.2.0 —— 通道语义、预设格式、宿主命名空间（四语） |
| `4758b05` | docs(AGENTS): 预设一节重写为 0.2.0 单格式与取用点分叉 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh | 0.1.5-rc.2 | 0.2.0-rc.2 |
| dsh-alpha | 0.1.6-alpha.2 | 0.2.0-rc.2 |
| 　 | npm tag | `alpha` → `next` |
| 　 | src hash / npmDepsHash | 再計算；両チャネルは同一 tarball ⇒ vendored lock は一份を共用（`dsh-package-lock-alpha.json` は削除） |
| dsh-nixos-shell-stable | 新規 | `0175f85` をピン留めしたプリセット内容の変体（`presetsSource` パラメータ + `passthru`） |
| dsh-preset-news-three-elements | 0.1.0 | 0.2.0 |

## 2026-10-02T18:02:46+09:00

**概要**：feat(dsh): プリセット移行の準備 —— 0.2.0 の新形式 `preset.patch.yml` と派生チェックの適応（四言語）

- プリセットはディレクトリ式 `agent.cordis.yml` から一本の loader patch 条目（`- insert:` → `@deepseek-ai/dsh-agent-preset`）へ変わり、落点は `$DSH_HOME/profiles/<profile>/cordis.patch.yml`
- 26 パッケージの schema をプラグイン単位で照合し、6 箇所の変化はすべて新規の任意フィールド
- 「そのまま写すと壊れる」三箇所を修正：`baseUrl` は当該 profile ディレクトリを指すようになり、メタデータは `config.name` / `description` へ、`config.order` は新しいキー
- 検証：使い捨て 0.2.0 実例の 7 条目プリセットで `broken` は全空；反証は一行だけ変えてそれぞれ具体的な `broken` を報告
| コミット | 説明 |
|------|------|
| `3f92bb1` | feat(dsh): 预设迁移准备 —— 0.2.0 新格式 preset.patch.yml + 派生检查适配（四语） |

## 2026-10-02T17:39:30+09:00

**概要**：feat(dsh): 宣言的な設定面の補完 —— 構造化オプションを 7 → **13** へ、型付き namespace を 6 つ新設

- 型付き namespace を 6 つ新設（`permission`、`web-search-deepseek`、`agent-presets`、`subagent`、`shell`、`llm-deepseek`）——「打ち間違いや範囲外は実行時に静黙で捨てられる」を**求値期のエラー**に変える
- 併せて既存判断を三箇所修正：namespace 総数 **12 → 15**、「`shell.cwd` に既定値がない ⇒ 部分宣言できない」は誤り、「typo も範囲外も静黙」は半分しか正しくない
- 検証：最小の NixOS 設定（13 段すべて有効 + 逃生口で 1 箇所上書き）が求値通過、生成された `settings.yaml` は全新設段を含み `builtins.fromJSON` で解析でき、負例はそれぞれ求値期にエラー；`nix flake check` 全緑
| コミット | 説明 |
|------|------|
| `0f12640` | feat(dsh): 声明式设置面补全 —— 新增 6 个类型化 namespace（13 个结构化选项，四语） |

## 2026-10-02T17:33:52+09:00

**概要**：godot-ai 4.1.0 → 4.2.3 — fail-closed な pin 表が 9 項から 14 項へ（`mcp` 1.29.1 → 2.2.0、`fastmcp` 3.4.7 → 4.0.5、さらに `mcp-types` などを新規追加）

- `mcp-types` は nixpkgs に存在しないため、上流同一リポジトリの `src/mcp-types/` サブプロジェクトから定義を取得
- 二つの overlay の `python312.override { packageOverrides = …; }` は連鎖した `.extend` で互いを置換し、上書きは静かに捨てられたままビルドは成功していた；現在は `pythonPackagesExtensions` を使用
- 判定：ビルド通過、`godot-ai --version` の実行が 4.2.3、`importlib.metadata` は 14/14、`nix flake check` 全緑

| コミット | 説明 |
|------|------|
| `32bcf22` | chore(pkgs): godot-ai 4.1.0 → 4.2.3 —— 依赖表 9→14、mcp 2.2.0、fastmcp 4.0.5、新增 mcp-types（四语） |
| `828af9c` | refactor(skills): 泛化链式 overlay 的替换语义陷阱（改用 pythonPackagesExtensions） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| godot-ai | 4.1.0 | 4.2.3 |
| 　 | 実行時依存 pin 表 | 9 項 → 14 項 |
| 　 | src hash / overlay の掛け方 | 再計算；両 overlay を重ね合わせ可能な方式へ |

## 2026-10-02T17:09:33+09:00

**概要**：feat(skills): 更新チェックに「push 後：CI ビルドの検証」節を新設（四言語）

- ローカルのビルド成功は CI が緑になることを意味しない：ローカルはバイナリキャッシュに当たり得て現行アーキテクチャしか覆わないため、多アーキテクチャのパッケージではもう一方を検証できるのは CI だけである
- 判定は三点：全 `status` が `queued`/`in_progress` を抜けるまで待つ、`--commit` で絞る、失敗は必ずログ原文を見る
- まず分類してから動く：レート制限と揺らぎは偶発、hash 不一致と lock の不自洽は真の失敗、単一アーキテクチャの赤は判定保留、そして「全緑だがログが `copying path … from cache` ばかり」は疑わしい —— CI が通ったことは CI がビルドしたことではない
- 失敗時は全失敗項とその性質を一度に示し、再実行・修正してコミット追加・そのバッチの巻き戻しを選択肢とし、「修正せず緑になるまで再実行」は禁じる
- 適応層は本リポジトリの形態（`build-package.yml` の骨組み、パッケージ×アーキテクチャごとに 1 つの workflow、`ci-summary.yml` のバッジ）と実測した四つの失敗形態を記録する
| コミット | 説明 |
|------|------|
| `6ff84e3` | feat(skills): 更新检查新增「推送后验证 CI 构建」环节（四语） |

## 2026-10-02T17:03:13+09:00

**概要**：codewhale 0.9.13 → 0.10.0；ruyi 0.52.0 → 0.53.0；mcp-searxng 2.3.0 → 2.5.0；opencode-telegram 0.25.3 → 0.26.2 — 四言語ドキュメント同期

- `dsh` 0.2.0-rc.2 と `dsh-alpha` 0.1.7-alpha.2 は保留：hash もビルドも通過したが、プリセットのマウント検証が通らない——`agentPresets/list` の roster にどちらも現れない；対照実験は識別力を持つが、形式の非互換と探針の `DSH_HOME` 不足はまだ区別できない
- fix(dsh): `postPatch` を「`devDependencies` からファイル末尾まで截断」からブロック単位の照合 + 末尾カンマ修復へ変更——0.2.0-rc.2 以降は `exports` がその後に来るため、旧来の書き方ではそれも削除される（導出が失効するのにビルドは成功する）；二つの実 tarball で解析可能なことをオフライン検証

| コミット | 説明 |
|------|------|
| `16216d5` | chore(pkgs): 上游更新 —— codewhale 0.10.0 / ruyi 0.53.0 / mcp-searxng 2.5.0 / opencode-telegram 0.26.2（四语文档同步） |
| `63e71cd` | fix(dsh): postPatch 按块删 devDependencies —— 0.2.0+ 的 exports 不再被误删 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.9.13 | 0.10.0 |
| 　 | cli / tui hash（x64、arm64） | 四値すべて再計算（cli と tui は同値） |
| 　 | codewhale-src `src` hash | `sha256-AYs2v/…` → `sha256-SsN/p+…`（Cargo.lock を 7266 行へ同期） |
| ruyi | 0.52.0 | 0.53.0 |
| mcp-searxng | 2.3.0 | 2.5.0 |
| 　 | src hash / npmDepsHash | 両方とも再計算 |
| opencode-telegram | 0.25.3 | 0.26.2 |
| 　 | src hash / npmDepsHash | 両方とも再計算 |

## 2026-10-02T16:26:56+09:00

**概要**：feat(skills): 更新チェックに「第 0 步」を新設 —— 着手前に `git fetch` で遠端を整列し、未クローズの issue / PR を確認（四言語）

- issue は「既知の故障」の集合、PR は「在途の作業」の集合であり、この工程は取得経路の自検も前倒しする
- `gh` は明示的に非ゼロで終了するため、「空リスト」が「本当に無い」を意味するのはコマンドが成功した時に限る
- コミット前の自検は九問から十問へ拡張し、第 10 問がメンテナの要求による着手前の動作であることを正直に標記する（第 1〜9 問は実測のやり直しの産物）
- 適応層は本リポジトリの座標、`has_issues=true`、実測 0 未クローズ issue / PR、四つの実例（PR #6 は SHA 固定 action、PR #7 は本リポジトリのパッケージ更新、PR #4 / #5 は `/tts` の SSRF 修正を導き、issue #3 は技能分割の契機）を補う
- 併せて `traps.md` と四言語技能文書の二箇所の不正確さも修正
| コミット | 説明 |
|------|------|
| `c10de09` | feat(skills): 更新检查新增第 0 步 —— 开工前同步远端并核对活跃 issue / PR |

## 2026-10-02T03:54:38+09:00

**概要**：fix(dsh): image モダリティの記述を訂正（四言語）

- 前回の記録は `deepseek-flash` を「唯一 image モダリティを宣言する flash 項目」とし、その断定を両チャネルに広げていた
- store 内の二つのビルド済み成果物を実査すると、stable `0.1.5-rc.2` と alpha `0.1.6-alpha.1` はそれぞれ `inputModalities: ["text","image"]` を宣言する項目を二つ持ち（`deepseek-flash`、`deepseek-v4-flash-vision-exp`）、一条なのは alpha `0.1.6-alpha.2` のみである
- 変更内容：理由を「三つの目録すべてに収録され、いずれでも image モダリティを宣言する唯一の id」へ改め、目録表にその列を追加
- 低下時の警告を二経路へ訂正 —— 新たに添付した画像は `session/prompt` の添付准入で `MODEL_DOES_NOT_SUPPORT_IMAGES` として拒否され、履歴の画像のみが無言で置換される
- 既定値は変更しない
| コミット | 説明 |
|------|------|
| `067b296` | fix(dsh): 更正 image 模态断言 —— stable/alpha.1 目录实有两条声明（四语） |

## 2026-10-02T03:01:23+09:00

**概要**：fix(dsh): 既定モデルを `deepseek-flash` へ移行（四言語）

- 上流は 2026-09-10 に V4 Flash と V4 Flash Vision Exp を廃止し、モデル名を `deepseek-flash` と `deepseek-v4-pro` に収束した
- dsh の目録は版に追随する：stable `0.1.5-rc.2` と alpha `0.1.6-alpha.1` は四条、alpha `0.1.6-alpha.2` は二条
- 旧既定値 `deepseek-v4-flash` は alpha の目録に存在せず、目録外の id はテキスト専用モデルとして扱われるため、画像は `projectImagesForTextModel` により無言でテキスト記述に置き換わる —— エラーは出ず、モデルも画像を見ていない
- 変更内容：既定値を `deepseek-flash` へ変更し、オプション説明に目録が版に追随することを明記；四言語の `dsh.md` は例の id を同期し、当該節と降下の警告を追加
| コミット | 説明 |
|----------|------|
| `2ab7dda` | fix(dsh): 默认模型改用 deepseek-flash —— 上游 09-10 下线旧 id（四语） |

## 2026-09-28T13:07:06+09:00

**概要**：dsh-api-balance 0.1.0 → 0.1.1 —— 薄いラッパーの座標同期

- 子リポジトリはメンテナンスログを持たず、変更は同リポジトリのコミット [`76ea584`](https://github.com/Kihara777/dsh-api-balance/commit/76ea5847c3e3f8e639b01abbfd8901fa71d6c177) 参照
- 音色を「**実際に話す変体**」で選ぶようにした：旧実装は主言語の前方一致で最初の音色を取っており、広東語 `zh-HK` と普通話 `zh-CN` は同じ `zh` に属するため、音色一覧で広東語が先に来るシステムは必ず普通話のテキストを広東語で読む —— しかもテキストも界面も正しいため、音を聞かない限り気付けない
- 現在は変体ごとの分類と並び替え、発声前の音色一覧待ち、`utter.lang` と選択音色の一致、実際に使う音色を示す「音色」設定を追加
- 判定：子リポジトリの `test/voice-selection.test.mjs`（25 のアサーション、反証含む）と実ブラウザ実測
| コミット | 説明 |
|------|------|
| `a4e6d54` | chore(pkgs): bump dsh-api-balance 0.1.0 → 0.1.1（音色按话的变体选择） |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 0.1.0 | 0.1.1 |
| 　 | rev | `c47f857` → `76ea584` |

## 2026-09-28T08:28:27+09:00

**概要**：refactor(skills): 本日のプリセット事故を「別の nix flake リポジトリでも成立するか」という判定で二層の技能へ汎化

- `nix-flake-update-check` のコミット前自検が八問から九問へ増え、「『検証した』は失敗が起きる層で検証したか？判定自身は失敗できるか？」を追加：決して鳴らない判定は「問題なし」と「何も測っていない」を区別できず、救済は**既知の壊れたフィクスチャ**を反証として添えること
- `nixkits-check-updates` に新節：プラグインの改名/削除は文書だけの問題ではなく、二つのプリセットを**実際に壊す** —— 組合せ行はパッケージ名で内蔵プラグインを参照するため、dsh ≤ 0.1.6-alpha.1 は解決できない行を黙って無視し、≥ alpha.2 はハード失敗してプリセット全体がマウントできない
- 同節は更新前の二層の判定（オフラインの行解析 + 上流の `broken` を読む権威ある実マウント）と seed-once 播種の帰結を示す
- 自検の番号への参照三箇所も同期更新
| コミット | 説明 |
|------|------|
| `c5022ea` | refactor(skills): 预设事故泛化 —— 通用技能加第 9 问，适配层加插件改名陷阱 |

## 2026-09-28T08:04:31+09:00

**概要**：fix(dsh-nixos-shell): プリセット行を `workflow-ptc` に変更 —— dsh 0.1.6 で内蔵プラグイン `dsh-workflow-worker-thread` が改名され、旧名は ≤ alpha.1 では黙って無視され、alpha.2 以降はプリセット全体がマウントできなくなる。

- `nixos-mode` / `maintenance-mode` の組合せ行と `editing-cordis-compositions` 技能の例を同時に改名、`config` は逐字不変
- 検証は**ビルド成果物**を実際にマウントする方式へ：使い捨て dsh が `agentPresets/list` を呼び上流の `broken` 判定を読む、さらに故意に壊したフィクスチャを反証として混ぜる
- 同じ罠を `docs/*/dsh.md` に記載（四語）、`AGENTS.md` の本機展開の前提を `path:` 入力ではなく GitHub 参照へ修正（先に push してから再ロック、再ロックは浮動子入力も再解決する）

| コミット | 説明 |
|------|------|
| `c92e980` | fix(dsh-nixos-shell): 预设行改用 workflow-ptc（旧名在 0.1.6 已不存在） |
| `7a12ff2` | docs(dsh): 记录 0.1.6-alpha.2 插件改名硬失败陷阱（四语） |
| `5364ef1` | docs(agents): 修正本机部署前提（GitHub 引用而非 path 输入）+ 重锁的副作用 |

## 2026-09-24T05:45:11+09:00

**概要**：① `fix(pcn)` 偽中国語の残留仮名を除去 ② `feat(dsh)` 構造化 settings オプションを 6 件追加

- ① 残留していた仮名 4 箇所を除去し、`check-maintenance-log` と `check-doc-links` が `exit 0` へ復帰
- ② オプション：`agent-loop`、`subagent-model-selection`、`locale`、`ui-theme`、`ui-chat`、`ui-conversation`
- 従来は `agent-default-model` だけが構造化オプションを持ち、残りは無型の `settings` 経由のみ（誤りは静かに schema 既定値へ戻る）；`shell` は `cwd` に schema 既定値がないため意図的に提供しない
- 文書中の `0.1.5-rc.2` から転記した namespace 表の 5 行を訂正
- 判定：6 検査すべて緑、四言語の構造が対等、6 項すべて有効化して生成した settings.yaml が 6 つの新セクションを含む
| コミット | 説明 |
|------|------|
| `d2e8c10` | fix(pcn): 剔除偽中国語残留假名 —— 恢复 CI 绿灯 |
| `55cbdbd` | feat(dsh): 6 个新结构化 settings 选项 + 修正 namespace 表（四语） |

## 2026-09-23T08:27:16+09:00

**概要**：refactor(preset): 保守モードのプロンプトを「汎用の方法 + 本リポジトリ適配層」に分割

- `maintenance-skills` は NixKits のワークフローを公開プリセットに丸ごとハードコードしており、`skills/` の既存の分け方（`nix-flake-update-check` 汎用 ← `nixkits-check-updates` 本リポジトリ適配）と矛盾していた
- 現在は `maintenance-workflow`（順序 901、汎用：分割コミット、push 後の記録、文書とコードの同期、修正の技能への汎化）と `maintenance-workflow-repo`（順序 902、本リポジトリの約束：四言語と `docs/zh/` 基準、`write-maintenance-log` を準則、項目数の一致という判定）
- 判定はただ一つ「この規約は他のリポジトリでも成立するか」；汎用層に本リポジトリ固有の名前は現れない
- 新しいオプション `repoWorkflow: false` で汎用層のみを残せる
- 四言語ドキュメントを同期
| コミット | 説明 |
|------|------|
| `78fb91b` | docs(modes): 维护模式提示词分层 —— 通用方法 + 本仓适配层（四语） |

## 2026-09-22T16:23:33+09:00

**概要**：docs(skill): 「ブートローダ設定をコマンド式に改変してはならない」事故を `nixos-specialisation-tuning` に記録

- `extraInstallCommands` が Limine の**ハッシュ固化後**に `limine.conf` の `default_entry` を書き換え、ハッシュ不一致により Secure Boot 下で**システムが起動不能**になった
- 技能に一節を追加 `### 引导菜单与默认面`：設定は宣言的であること、「ファイル書き込み → 検証/署名」の順序を洗い出すこと、固化後の変更は上流とバイト単位で同一のアルゴリズムで再固化すること
- もう一節は面切り替えの二つのランレベル障害：判定は `is-active` ではなく `default.target` の解決値を使う；`user@<uid>.service` は面を跨ぐと全体の再起動が必要で、「コンポジタが存在する」を「デスクトップが正常」と見なさない
- frontmatter `description` と「适用场景」も同期更新
| コミット | 説明 |
|----------|------|
| `8c276c0` | docs(skill): 「ブートローダ設定をコマンド式に改変してはならない」事故を記録 —— 私が導入した起動不能障害 |

## 2026-09-22T09:37:07+09:00

**概要**：fix(ci): `ci-summary` を `head_sha` で絞り込み、README バッジの `failing` 誤報を修正

- 本 workflow は push 起動のため同一 push のビルド未完了時に走り、クエリで commit を限定しないと前回 push の失敗実行を読む（実例：`Build dsh-preset-news-three-elements (aarch64)` run#157）
- `curl` に `--fail` を追加
- リクエスト失敗時は既存バッジを保持して `exit 1` —— 従来は 403 制限が返す JSON エラー本体で `FAILED` が空となり、静かに `passing` を書いていた
- 判定：新 jq ロジックを現在の HEAD に対して実行すると出力は空（=> passing）で、31 の Build workflow 全緑と一致
- 今回の外部からの変更は `gh-pages` 上のバッジ状態のみで、メインブランチのソースは第三者に変更されていない
| コミット | 説明 |
|------|------|
| `7fc4a14` | fix(ci): ci-summary 按 head_sha 过滤，修正徽章误报 failing |

## 2026-09-20T17:56:28+09:00

**概要**：refactor(skill): 監査後、8 つの汎用スキルにおけるリポジトリ／役割特指を一括汎化。

- `write-maintenance-log`：「AGENTS.md により強制起動」を条件式に変更；SUBTITLE の `NixKits 软件更新维护日志。` を `<项目名>` プレースホルダに（逐字置換のため、そのまま使うと他プロジェクト名が書き込まれる）
- `write-project-docs`：「ルートには中文のみ」が反パターン表の「言語リストの直書き」と矛盾していたため「基準言語はリポジトリが定める」に変更
- 切り替えバリデータを言語集合の動的発見に変更（`docs/zh|en|ja|pcn` と `/5` を直書きしていた）；`translate-pseudocn` の壊れたスクリプトを書き直し
- スキル間ハード参照は単独で成立する表現に；工程数の記載を実際の 9 步に一致；子リポジトリ例と `kits/` から特指を除去
判定：書き直した二つの検証スクリプトは実行して通過（故意に壊したリンクを注入する逆検証を含む）、`nix flake check` 全通過。

| コミット | 説明 |
|------|------|
| `dac80a7` | refactor(skill): 全面泛化通用技能中的仓库/角色特指（审计后批量修复） |

## 2026-09-20T17:41:07+09:00

**概要**：refactor(skill): 外部自動化と Actions 検査の適用対象を汎化（特定リポジトリを指さない）

- スキルは他者に渡す再利用可能な成果物であり、読者は別リポジトリの貢献者や引継者かもしれず、従来の書き方は「自分には関係がない」と読めました
- `traps.md` に二節を新設：SHA 固定は共通の選択であり、その副作用（通知が届かないこと）は採用者が継承する；基準は**「自力実装できるか」であり「誰が使っているか」ではない**（メンテナ／貢献者／監査者に適用時期を列挙）
- 加えて非メンテナの action 昇格も PR で行う旨
- 第 2 步と `builders.md` は一般の場合として記述し、第 8 步は「適配層が指定する」に変更、汎用スキルから適配層へのハードコードされたパス参照を削除
- 判定：`nix flake check` 全通過
- 適配層 `nixkits-check-updates` の本リポジトリ固有の事実は保持
| コミット | 説明 |
|------|------|
| `23e11a5` | refactor(skill): 泛化外部自动化与 Actions 检查的适用对象（不再特指某个仓库） |

## 2026-09-20T17:28:32+09:00

**概要**：fix(skill): `nix-flake-update-check` の三つの欠陥を修正、いずれも「エラーを出さず、ただ取りこぼす」型。

- 固定 SHA の Actions 検査が到達不能：`traps.md` に手順があるのに `SKILL.md` のどのステップからも参照されていなかった；第 2 步に節を追加、チェック項目を八問に拡張、目次に「毎回」と明記
- バージョン発見が `version\s*=` のためパラメータ化された `version ? "0.1.5-rc.2"`（`packages/dsh.nix`）に一致せず、当該パッケージは検査範囲から消えていた；`version\s*[?=]` に変更
- 生の `curl` で `api.github.com` は上限を使い切るとエラーを出さず空を返し、下流の grep も同様に沈黙、全パッケージが「最新」と判定されていた；`gh api` に統一し `ERROR:` 分岐を追加
判定：`nix flake check` 全通過；新フローの初回実行で本リポジトリの 3 つの action 計 6 箇所を逐一 SHA 照合し、すべて最新と確認。

| コミット | 説明 |
|------|------|
| `34368c1` | fix(skill): 接入 Actions 检查、修正版本发现启发式、取数改用 gh api |

## 2026-09-20T17:05:51+09:00

**概要**：定例の更新チェック —— `opencode-telegram` 0.25.3 と `ruyi-alpha` 0.54.0-alpha.20260918

- `opencode-telegram` 0.25.3（npm パッケージ、source hash と npmDepsHash を更新、ビルド通過）
- `ruyi-alpha` 0.54.0-alpha.20260918（薄いラッパー、version と hash のみ変更で三チャネル共有の base は未変更）
- 同じ実行で stable チャネルの被検査 12 パッケージを確認し、上流に遅れるのはこの 2 件のみ
- alpha チャネルの文書の pytest 件数を 346 ユニット / 57 統合から 462 ユニット（xfailed 1 件を含む）/ 70 統合へ更新
- 四言語の文書を同期
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

**概要**：docs(agents): `nix flake check` の 7 件の自検一覧と CI の `access-tokens` の落とし穴を補完

- 「文書に載っていない内容」の確認で構造的な欠落を 1 件補完
- `nix flake check` の 7 件の自検（自検契約、いずれか失敗でコミットを阻止）は、これまで一箇所にまとまった説明がなく、`flake.nix` のコメントに散在し `AGENTS.md` は 2 件に触れるのみだった
- `AGENTS.md` の `## CI` 節に ① 7 件の自検一覧表（検査名 / スクリプトパス / 検証内容）を追加
- ② CI の `access-tokens` host 照合の落とし穴（`check.yml` が `api.github.com` を欠き、浮動入力 `llama-cpp-ver` が未認証となり上限を使い切る）を追加
- 検証：7 パスはすべて実在し `nix flake check` は全通過
| コミット | 説明 |
|------|------|
| `7766b88` | docs(agents): nix flake check の 7 件の自検一覧と CI の access-tokens の落とし穴を補完 |

> **説明**：`AGENTS.md`（それ自体が代理エージェント向けの取り決めファイルで、ユーザー文書ではありません）を変更。

## 2026-09-19T14:05:38+09:00

**概要**：fix(ci): `check.yml` の `access-tokens` に `api.github.com` が欠けていた。あわせて子リポジトリ `dsh-api-balance` に四言語 `SECURITY.md` を追加。

- CI：浮動入力 `llama-cpp-ver` はこれまで未認証で取得されていた（60 回/時の上限を push ごとの ~34 workflow が使い切る）。両 host を記載後は 33 workflow すべて success、403 はゼロ。入力は浮動のままで `flake.lock` には書かれない
- 子リポジトリのセキュリティポリシー：スキャナの PR #4 / #5 の「レート制限の欠如」「リクエストボディのサイズ上限の欠如」はともに誤検知と判定、コードは変更しない
- 主リポジトリの四言語 `SECURITY.md` の「同サブプロジェクトは未だポリシーを整備していない」を「整備済み」に訂正し、子リポジトリ文書へリンク

| コミット | 説明 |
|------|------|
| `d224b18` | fix(ci): check.yml の access-tokens に api.github.com が欠けていた（403 の根本原因） |
| `2cce37b` | （子リポジトリ dsh-api-balance）docs(security): 四言語 SECURITY.md を追加 |
| `39c9f10` | docs(security): 子リポジトリがポリシーを整備済みに——古い「未整備」記述を訂正（四言語） |

> **説明**：`d224b18` は `.github/workflows/check.yml` を変更、`39c9f10` は四言語ドキュメント、子リポジトリのコミットはそのリポジトリに記録。

## 2026-09-19T07:51:05+09:00

**概要**：スキル文書 4 篇（`nix-flake-update-check` / `nixkits-check-updates` / `write-project-docs` / `translate-pseudocn`）を確認、3 件修正（四言語）。

- `nix-flake-update-check`：文書は主フローを 1〜10 ステップとしていたが、`SKILL.md` は実際にはステップ 9 まで。ステップ 10（締め）は適応層 `nixkits-check-updates` が定義
- `write-project-docs`：付属ファイル `templates.md`（209 行）が `SKILL.md` で宣言されていなかった —— 付属表とディレクトリ形式のパスを補完
- `translate-pseudocn`：辞書の項目数 13 を実測 75 に訂正し、`dictionary.md` の付属行を追加
- 照合：`news-three-elements` の付属宣言はもともと正確

| コミット | 説明 |
|------|------|
| `c9c9c0c` | fix(docs): nix-flake-update-check スキル文書のステップ数誤り（四言語） |
| `7f7363f` | fix(docs): write-project-docs が配套ファイル templates.md を宣言していない（四言語 + SKILL.md） |
| `cef09fe` | fix(docs): translate-pseudocn の辞書項目数と配套ファイルが不正確（四言語） |

> **説明**：`7f7363f` は `skills/write-project-docs/SKILL.md` の変更を含む（技能スナップショットは `check-preset-bundle` により `skills/` ツリーとバイト単位で一致することを確認済み）。残りは四言語の文書。

## 2026-09-19T07:43:15+09:00

**概要**：fix(comfyui): 「上流は stdenv API を移行済み」という誤った判定を訂正。

- 元の判定は「上流は hostPlatform へ移行済み」でしたが、実測で反証：`stdenv.is<Platform>` は **0.34.0 と 0.30.2 に各 38 箇所**、`hostPlatform.is*` は両版 7 箇所のみ——一度も移行されていません
- 本当の理由：**上流コードを上書きしなくなったこと**です（旧パッチは移行を overlay 経由で評価される fork に適用していました）
- `modules/comfyui.nix` のコメントと、四言語 `deprecated/comfyui-rocm.md` の「なぜ廃止できるか」の節を同時に訂正
- その他の廃止項目の主張は通過：`nixkits.comfyui` へ改名済み、`modules/comfyui-rocm.nix` と 3 つのパッチは削除済み、四言語 `DEPRECATED.md` の索引は正しく、上流バージョンは **v0.34.0**

| コミット | 説明 |
|------|------|
| `4054c32` | fix(comfyui): 「上流が stdenv API を移行済み」という誤った判定を訂正（モジュールコメント＋廃止文書四言語） |

> **説明**：`4054c32` は **`modules/comfyui.nix` を変更**します（コメントのみで評価に影響せず、`nix flake check` は全通過）。残りは四言語のドキュメントです。

## 2026-09-19T07:38:04+09:00

**概要**：fix(docs): パッチ文書群が完了 —— 最後の 3 文書を確認し 4 件修正（いずれも四言語）。

- asusd-thermal-guard：文書が状態を `/run` に置くと誤記。モジュールは `StateDirectory`（`/var/lib/private/asusd-thermal-guard`）を使い、コメントは `RuntimeDirectory` の使用を警告（systemd が丸ごと削除するため、冷却カウントが毎回ゼロに戻る）
- comfyui：バッジが存在しない CI ジョブを名指し（`check.yml` には単一の `check` ジョブのみ）。如実な CI バッジに変更
- comfyui：キャッシュ節に overlay の記述が残存（モジュールには `pkgs.comfyui` の参照もなく、宣言的な設定のみ）
- llama-cpp-rocm：移行例の `hfCacheDir` が展開されない `~` を使用。モジュールの既定値は絶対パス

| コミット | 説明 |
|------|------|
| `8292160` | fix(docs): asusd-thermal-guard が状態を /run に置くと誤記（四言語） |
| `01679e8` | fix(docs): comfyui のバッジが存在しないジョブを名指し＋overlay 記述の残存（四言語） |
| `35aaf05` | fix(docs): llama-cpp-rocm の移行例が展開されない ~ を hfCacheDir に使用（四言語） |

> **説明**：いずれもドキュメントのみの修正で、`packages/`・`overlays/`・`modules/` は未変更。

## 2026-09-18T11:04:38+09:00

**概要**：外部カタログへの掲載が完了 —— awesome-ai-plugins の 2 つの PR がともにマージされ、NixKits と dsh-api-balance が正式に同カタログへ入りました。

- スキャン評価 **88 → 94/100（A – Excellent）**、Security **13/16 → 16/16**、措辞のみ変更し情報は削除せず
- PR #321：`dsh-api-balance` を DeepSeek Harness Plugins に追加、**2026-09-16 にマージ**
- PR #323：NixKits を Development & Workflow に追加、レビュー是正とスキャン再実行の後、私たちが自らクローズ
- PR #335：再提出版、**2026-09-18 にマージ**。両エントリは現在上流 README に反映済み
- scanner workflow と Dependabot は導入せず、10% の信頼スコア減点を受け入れ

| コミット | 説明 |
|------|------|
| `--` | 外部リポジトリでの作業（awesome-ai-plugins PR #321 / #335 のマージ）と issue #3 返信の更新。本リポジトリに対応するコミットはなし |

> **説明**：掲載は外部カタログ側がマージしたもので、本リポジトリの `packages/`・`overlays/`・ドキュメントはいずれも未変更。

## 2026-09-18T14:35:36+09:00

**概要**：fix(docs): パッチ 5 文書の検証（breeze-black / efl-cross-fix / codewhale-sudo / rcc-fix / asusd-pd-profile）—— 3 件修正。

- `rcc-fix` が存在しない option 名前空間を使用：例は `services.asusctl`（`power-profile`/`cpu-power-control` を含む）ですが、正しくは `services.asusd` で、プロファイルと CPU 電力上限は `profileConfig` 経由（四言語）
- `breeze-black`：「インストール」節のプレースホルダパス `(import ./overlay.nix)` を `inputs.nixkits.overlays.<name>` へ（zh のみ）
- `codewhale-sudo`：基本情報表の重複行を削除（zh のみ）
その他の主張は全項目照合済みで通過。

| コミット | 説明 |
|------|------|
| `a262e3c` | fix(docs): breeze-black のインストールパスと codewhale-sudo の重複行（zh） |
| `ea03584` | fix(docs): rcc-fix が存在しない services.asusctl オプションを使用（四言語） |

> **説明**：いずれもドキュメントのみの修正で、`packages/`・`overlays/`・`modules/` は未変更。

## 2026-09-18T14:26:43+09:00

**概要**：fix(devshell): 開発 2 篇の検証 —— 引数の誤り 1 件を修正し、ソースの不具合 1 件を発見。

- `ruyi venv` / `ruyi extract` の引数誤り：前者は `ruyi venv -t <toolchain> <profile> <dest>` の形が必要で `profile` はローカル索引に存在する必要があり、後者の位置引数はファイルパスではなくパッケージ `ruyi extract <pkg>`（四言語）
- searxng limiter 設定が一度も読まれていなかった：`develop/opencode.nix` は `settings.yml` の `server.limiterSettings` ブロックに記述。独立した `limiter.toml`（`[botdetection] trusted_proxies`）へ移し、修正後は `missing config file` 警告が消え、リバースプロキシも HTTP 200 を返す
その他の主張は実測で通過。

| コミット | 説明 |
|------|------|
| `26e7a76` | fix(devshell): ruyi venv/extract の引数誤り + opencode searxng limiter 設定が一度も効いていなかった（四言語） |

> **説明**：`26e7a76` は **`develop/opencode.nix` を変更**（limiter 設定を独立した `limiter.toml` へ移動）し、devShell の挙動が変化。残りはドキュメントのみの修正で、試験中の `dump.rdb` と残留バックグラウンドプロセスは掃除済み。

## 2026-09-18T13:51:14+09:00

**概要**：fix(docs): プラグイン 2 文書とモード 3 文書の検証 —— プラグインは全項目一致で変更不要、モードは 1 件修正。

- `dsh-nixos-shell` と `dsh-api-balance`：npm 名とバージョン、`nixos_shell` の 27 項目のツール白リスト、`nixos_cli` の 5 つの op と数値上限、sudo プロトコル v3（`MAX_TIMEOUT_MS = 21600000`）、`skills-embedded/` スナップショット、`dsh-api-balance` の rev `c47f857` と 4 つの config 項目まで全項目一致
- NixOS モードの「コンポジション」行が persona 行に `complete: true` を設定したと誤記。実際は `prefix` のみで、四言語で訂正
その他のモードの主張は通過（`nixos-gate` の読み取り、NixOS モードのスキル 5 つ、メンテナンスモードの派生関係、ニュース三要素モードの各項目）。

| コミット | 説明 |
|------|------|
| `3d6340f` | fix(docs): NixOS モードのコンポジション記述が persona の complete: true を誤って主張（四言語） |

> **説明**：ドキュメントのみの修正。プラグイン 2 文書はいずれも変更不要（今後の退行比較のため記録）。

## 2026-09-18T13:43:54+09:00

**概要**：fix(docs): ruyi 文書 2 件修正（ほか 1 件はついでの表現修正）。

- テスト件数が beta チャネルのみの値だったため、チャネル別に列挙：`ruyi` ユニット 368 / 統合 58、`ruyi-beta` 462 / 70、`ruyi-alpha` 346 / 57。あわせて `checkPhase` の ruff / mypy は `|| true` で、実際にビルドを左右するのは pytest と注記
- zh のインストール節は散文の一行が Nix コードフェンス内に入り、ブロックが途切れていた（en/ja/pcn には無し）
- （ついで）`pyelftools` は本パッケージが共有ベースで無条件に追加（バージョン条件なし）で、「0.53.0 以降で新規」ではない

| コミット | 説明 |
|------|------|
| `c30f2b6` | fix(docs): ruyi のテスト件数がチャネル別でない + zh インストール節のコードブロック破損（四言語） |

> **説明**：ドキュメントのみの修正で、`packages/`・`overlays/`・`modules/` は未変更。

## 2026-09-18T13:41:45+09:00

**概要**：fix(docs): obs-bilibili-stream の Home Manager 用法は導入されるが効かない

- `home.packages` は `.so` をプロファイルに置くだけで、OBS は `OBS_PLUGINS_PATH` でプラグインを探し、この変数を注入するのは nixpkgs の `wrapOBS` のみ
- つまり `programs.obs-studio.plugins` だけが有効な経路
- 四言語に警告と二つの正しい方法を追記
- opencode-telegram は全項目一致で変更ゼロ
| コミット | 説明 |
|------|------|
| `4bea784` | fix(docs): obs-bilibili-stream の Home Manager 用法は入るが効かない（四言語） |

> **説明**：ドキュメントのみの修正で、`packages/` と `overlays/` は未変更。opencode-telegram は変更不要と確認（今後の退行比較のため記録）。

## 2026-09-18T13:40:20+09:00

**概要**：fix(docs): kitsfmt と mcp-searxng に各 2 件の不正確な記述。

- `kitsfmt`：「コメント保持」の記述が広すぎる —— 0.5.0 の実測ではノード直前の先行コメントだけがソート時に追随し、最後以外の属性の同行末尾は次の属性の上へ移動、最後の属性の同行末尾とファイル先頭・末尾は破棄。漏れていた `KITSFMT_STDIN=1` も補完
- `mcp-searxng`：「すぐ使える設定」に廃止済みの `real_ip.x_for = 1` が含まれていた（上流 `limiter.toml` に `real_ip` セクションは既に無い）。四言語から削除
- `mcp-searxng`：「`SEARXNG_URL` が無いとサイレント失敗」は実測と不一致 —— サーバーは正常に起動し `tools/list` も返る。`tools/call` のみ毎回 `isError: true` を返し、テキストと stderr に明示

| コミット | 説明 |
|------|------|
| `0cb9f4f` | fix(docs): kitsfmt のコメント保持の記述が広すぎ + KITSFMT_STDIN 追加（四言語） |
| `9f3c829` | fix(docs): mcp-searxng の不正確な記述 2 件（real_ip は廃止、失敗はサイレントではない）（四言語） |

> **説明**：いずれもドキュメントのみの修正で、`packages/` と `overlays/` は未変更。

## 2026-09-18T13:32:32+09:00

**概要**：fix(docs): dsh と godot-ai の文書検証 —— 3 件修正、加えて実際の機能不具合 1 件を発見。

- `dsh`：「宣言的に設定可能な host ネームスペース」表が 6 件のみで 0.1.2-alpha と記載。該当節が扱う `0.1.5-rc.2` は `installSection` 経由で 12 件を登録するため、`agent-default-model` ほか 5 件が欠けていた
- `godot-ai` コマンドは起動直後に失敗：attach ブリッジが `sys.executable -m godot_ai` でバックエンドを再 spawn するが、Nix 下では素の CPython で、`site.addsitedir()` が注入する依存は子プロセスに継承されない。makeWrapper で PYTHONPATH を前置し、実測で動作
- `godot-ai` 文書の残り 2 件：ツール数 43 → 46、WebSocket ポート 9876 → 9500

| コミット | 説明 |
|------|------|
| `6b47f55` | fix(docs): dsh の設定ネームスペース表が不完全かつバージョン表記が古い（四言語） |
| `a54bd9d` | fix(godot-ai): attach バックエンドが起動しない不具合の修正と不正確な記述 2 件（四言語） |

> **説明**：`a54bd9d` は **`packages/godot-ai.nix` を変更**（makeWrapper と postFixup を追加）し、godot-ai のビルド成果物が変化。残りはドキュメントのみの修正。

## 2026-09-18T13:23:25+09:00

**概要**：fix(docs): 26 項目の主張 + 子文書を検証、失実記述を 7 件修正

- 主文書 2 件：`inputs.nixkits.url = "~/NixKits"` は使用不可——`git+file:///path/to/NixKits` に変更。「全パッケージが既定で `lib.platforms.linux` に従う」は失実、実際は `lib.platforms.all`
- blender-mcp 3 件：実サーバの登録は 26 ツール（文書は 22 と称す）。アドオンの導入先は `extensions/user/`（Blender Extension で 4.x では読み込めない）。更新手順は `chmod`→`rm -rf`→`cp`→`chmod`（従来は無言で失敗）
- codewhale 2 件：`--sandbox <tier>` は存在せず、実は `--sandbox-mode`。以前修正済みの引数名が再導入されたもので、四言語は統一

| コミット | 説明 |
|------|------|
| `82d8ed5` | fix(docs): 主文書の不正確な記述 2 件を修正（四言語） |
| `ead55d1` | fix(docs): blender-mcp の不正確な記述 3 件（四言語） |
| `6f40487` | fix(docs): codewhale のサンドボックス引数名の退行と四言語の不一致（四言語） |

> **説明**：ドキュメントのみの修正で、`packages/` と `overlays/` は未変更。

## 2026-09-18T13:09:18+09:00

**概要**：refactor(ruyi)! — `ruyi-nixos-compat` パッチを `packages/ruyi/ruyi.nix` に統合し、無効となった overlay を削除

- overlay は **nixpkgs の** `ruyi` を修正するものだったが、そのパッケージは既に存在せず、実際に効いていたのは自前で被せていた `develop/ruyi.nix` のみ —— flake パッケージの利用者は NixOS 互換処理を得られていなかった
- パッチは三チャネル内蔵となり（`--replace-fail` で `@nixLdSo@`/`@nixGlibcLib@` を埋め込み、`ensure_toolchain_nixos_compat` を注入）
- devShell・flake パッケージ・NixOS モジュールが同一のビルドを得る
- 検証：三チャネルはビルド成功、成果物内の `@nixLdSo@` 残存 0 回、`ruyi --version`/`--help` 正常、beta の pytest は 462 + 70 passed
| コミット | 説明 |
|------|------|
| `87d3f7c` | refactor(ruyi)!: パッチをパッケージ定義に統合し、無効な ruyi-nixos-compat overlay を削除 |

> **説明**：破壊的変更——`nixkits.overlays.ruyi-nixos-compat` は**存在しなくなりました**。外部でこの overlay を参照していた場合は当該行を削除してください（パッチは内蔵済みで overlay 設定は不要）。ruyi 三チャネルのビルド成果物はいずれも変化しています。

## 2026-09-18T12:41:08+09:00

**概要**：定例の更新チェック —— `blender-mcp` 1.0.3、`ruyi-beta` 0.53.0-beta.20260917、`dsh` 0.1.5-rc.2、`dsh-alpha` 0.1.6-alpha.2

- `ruyi-beta` が `pyelftools` ランタイム依存を追加：上流は 0.53.0 からランタイム依存に記載、欠けると pytest が収集期に中断
- `dsh-alpha` は上流がプラグイン 4 件を追加、`dsh-package-lock-alpha.json` を再生成——version だけの変更では `npmDepsHash is out of date` になる
- 四言語のドキュメントを同期
- `nix flake check` 通過
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

**概要**：docs(security): 四言語の `SECURITY.md` のサンドボックス段階の記述を書き換え、外部スキャナの `RISKY_APPROVAL_DEFAULT` を解消

- トリガー語は `danger-full-access` で、本リポジトリは利用者が任意に選べる挙動を記述しているのであって既定値を設定しているのではなく、パターン照合のスキャナには区別できない；改後の記述は「既定では緩めない」を明示する
- あわせて `docs/zh/codewhale.md` の CLI 例を `--sandbox-mode` に修正
- 判定：公式スキャナで 94/100（A - Excellent）、Security 16/16、medium 0 件（88 → 94）
- 残る 6 点は `Dependabot configured for automation surfaces` 由来で、本リポジトリは「外部自動化を導入しない」境界を点数のために破らない
| コミット | 説明 |
|------|------|
| `e386dfc` | docs(security): 改写沙箱档位表述，消除扫描器 RISKY_APPROVAL_DEFAULT（88 → 94） |

> **説明**：文言のみの文書修正であり、`packages/` と `overlays/` は未変更。

## 2026-09-17T18:15:40+09:00

**概要**：汎用スキルを「主フロー + 二つの付属参考」へ再構成し、ブランチ分離で滞留していた Gitea の教訓を回収 — 評価に基づく改善：

- 実測ブランチで書かれた 70 行の「自ホスト forge（Gitea）のソース取得」節を main へ回収（当該ブランチはマージしない取り決め）：自ホストのインスタンスは全 tag で 403 を返す可能性
- 適応層に、テストブランチで生まれた汎用の教訓はその場で手作業により main へ書くことを要求する小節を追加
- スキルを 918 行の単一ファイルから主フロー `SKILL.md`（462 行）+ `builders.md`（254 行：ビルダー別の hash フロー）+ `traps.md`（271 行：ドリフトの罠など）へ分割し、第 7 步「コミット前の六つの自問」を新設
- 根拠：本セッションの 6 パッケージ更新の初回成功率は 4/6 で、3 回のやり直しはいずれもこの種の罠が原因
検証：分割は `##` 節・子節・行単位の比較・行数の四通りで照合し、漏れていた 3 節を復元。四言語を同期

| コミット | 説明 |
|------|------|
| `e0b1a64` | refactor(skills)!: 通用技能拆分为主流程 + 两份配套参考，并补回丢失的 Gitea 教训 |

> **説明**：スキル構造の変更（付属ファイル `builders.md` と `traps.md` を新設）。`packages/` は未変更。
## 2026-09-17T17:22:50+09:00

**概要**：feat(ci): `check-doc-versions` を新設し「文書の版 = パッケージ定義の版」を断言化

- 今回連続して発見した 5 件の文書の版の不一致（godot-ai、codewhale、mcp-searxng、opencode-telegram、dsh-alpha）に対する構造的な防御：この種の不一致はどのビルドも失敗させないため、`nix flake check` の 6 番目の検査とした
- 検査内容：`docs/<lang>/<pkg>.md` の「バージョン」行（四言語）と多チャネルパッケージ（`dsh-alpha` / `ruyi-beta` / `ruyi-alpha`）のチャネル表がパッケージ定義と一致すること；版を他所から読む場合も追跡（`kitsfmt` は `Cargo.toml`）；例外は `EXEMPT` に登録し、機械的に読み出せる部分のみを検査
- 検証：今回実際に遭遇した 5 種類の欠陥を注入しすべて検出；`nix flake check` の実際の経路で失敗することを確認；`AGENTS.md` に記録
| コミット | 説明 |
|------|------|
| `072ab87` | feat(ci): 新增 check-doc-versions，把「文档版本 = 包定义版本」固化为断言 |

> **説明**：検査スクリプト `develop/check-doc-versions.py` を追加し `flake.nix` の `checks` に接続（検査数 5 → 6）。`packages/` と文書内容は未変更。

## 2026-09-17T16:12:06+09:00

**概要**：docs: 5 パッケージの文書の版番号を修正（内容品質の修正）

- 全サービスパッケージを照合し、更新済みなのに文書が追随していない 5 件を発見：`codewhale` 0.9.12→0.9.13、`mcp-searxng` 2.2.0→2.3.0、`opencode-telegram` 0.25.1→0.25.2、`dsh-alpha` 0.1.5-alpha.2→0.1.6-alpha.1（文書 + README）、`codewhale-sudo` v0.9.12→**v0.9.0 以降**
- 最後の一件は置換ではなく判断：当該 overlay は版に依存せず、v0.9.0 で導入された `prctl(PR_SET_NO_NEW_PRIVS)` を傍受する
- README の値は古いだけでなく文書本文と自己矛盾していたため、機能の由来を記述する形に改めた
- 検証：全体を再照合し 10/10 一致；`nix flake check` 通過、四言語を同期
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

> **説明**：今回は文書のみの修正であり、`packages/` と `overlays/` は未変更。

## 2026-09-17T15:56:56+09:00

**概要**：docs(godot-ai): 四言語文書の版番号と依存表を修正し、「機械的置換ではなく書き直す」判定を新設

- main 上の godot-ai のコードは `2a06bbf` で既に 4.1.0 に到達し機能も完全（実測 `godot-ai --version` → 4.1.0）だが、文書が同期されておらず、版番号は依然 `3.2.5`
- 依存表は 6 項で全て「≥ 範囲」だが実際は 9 項の fail-closed 厳密固定
- 二番目の方が有害：v4 は起動時にこれら 9 パッケージの正確な版を検証し、不一致なら起動を拒否する
- 修正では依存表を「版 + 提供元」の二列にして 9 項を逐一列挙し、pydantic-core の連動要求（`==2.46.5`）を補足
- 検証：9 個の版番号は `nix eval` で overlay を含む閉包から測り、逐一比較して 9/9 一致
- スキルの発動判定は依存の厳密固定化や起動時の硬い検証の追加
| コミット | 説明 |
|------|------|
| `085c093` | docs(godot-ai): 修正四语文档的版本号与依赖表（内容质量修复） |
| `55674f2` | feat(skills): 通用技能第 5 步新增「文档须重写而非机械替换」的触发判据 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| godot-ai（文書） | 文書は 3.2.5 / 依存表 6 項「≥ 範囲」 | 4.1.0 / 依存表 9 項の厳密固定 |

> **説明**：今回は文書の修正であり、`packages/godot-ai.nix` は未変更（そのコードは `2a06bbf` で既に正しい）。

## 2026-09-17T13:00:09+09:00

**概要**：feat(skills): 適応層に第 10 步「プロセスの振り返りと規範の検証」を新設

- 更新フローが終了した後に実行し、監査するのはソフトウェアではなく、ソフトウェアがどう更新されるかを決める規範そのもの（スキル / `AGENTS.md` / `SECURITY.md` / develop スクリプト）
- 六つのステップ：振り返り、検証、帰属、体験、証拠規律、成果
- 証拠規律は硬性の制約：規範の変更は再現可能・追跡可能・異議申立て可能でなければならず、印象による規範変更、一度の偶発を法則と見なすこと、既に正しい内容への更なる最適化、拘束力の残る条目を削除することは禁止
- 初回実行で二つの実欠陥を発見（いずれもビルドエラーを生じない）：`SECURITY.md` が未作成のサブリポジトリ `SECURITY.md` を指すデッドリンクで、四言語を「同サブプロジェクトは独自のセキュリティポリシーを未整備」に変更；12 箇所の `asusctl` リンクはプロジェクトの `OpenGamingCollective/asusctl` への移転に合わせて変更
- リンク監査の手法は汎用スキルへ：`curl` の 404 は `gh api` で再確認し、`403` は多くの場合スクレイピング対策です
| コミット | 説明 |
|------|------|
| `442e5d1` | feat(skills): 适配层新增第 10 步「流程复盘与规范校验」 |

## 2026-09-17T12:52:54+09:00

**概要**：fix(codewhale): x86_64/aarch64 のプリビルド変体も 0.9.13 へ

- 前回は riscv64 のソースビルド変体 `codewhale-src` のみを更新し、`codewhale.nix`（x86_64/aarch64 は GitHub Releases のプリビルド経路。`flake.nix` が `hostPlatform.isRiscV` で分岐）を漏らした
- 本リポジトリの codewhale は同名同出力の二変体を持つ：`codewhale.nix` は `version` + cli/tui × x64/arm64 の **4 つの hash**、`codewhale-src.nix` は `version` + `hash` と `Cargo.lock` の同期が必要——**更新時は両方を変更せねばならない**
- 罠は適応層に記載した
- 判定：**配備後、アーキテクチャごとに各変体の実際の版を照合すること。ビルド通過だけでは不十分**
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

**概要**：五つのパッケージ更新 + 更新スキルに「対話的確認」を追加

- 本番の実戦、承認済みの更新をすべて実行：`mcp-searxng` 2.3.0、`opencode-telegram` 0.25.2、`codewhale` 0.9.13（`Cargo.lock` 同期）、`dsh-alpha` 0.1.6-alpha.1（lock に `"peer": true` が必要）、`godot-ai` 3.2.5 → 4.1.0（大版本跨ぎ、fail-closed な実行時依存検証）
- nixpkgs が 5 つのパッケージで遅れているため、新規 `overlays/godot-ai-v4-deps.nix` を `fastmcp` overlay と連鎖させ、overlay 連鎖（`flake.nix`、`overlays/default.nix`）は同期が必要
- スキルには「対話的確認」節と罠 5/6 を追加
- 検証：五つともビルド通過かつ実走で確認
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

**概要**：fix(skills): 子リポジトリ追従の判定をフィールド単位へ細分化

- 旧判定は「**ファイル**が変化したか」で分流していたが、マニフェストのフィールドのうちビルド入力は一部にすぎない
- 子リポジトリ `dsh-api-balance` の `package.json` はバイトが変化しており（`publishConfig.access` の削除）、`dependencies`、`files`、`version`、`main`/`exports` はいずれも未変更だったため、旧判定では純粋なメタデータ変更で全アーキテクチャの再ビルドを起こすところだった
- 現在は**フィールド単位**：リリースメタデータ（`publishConfig` 等）、ドキュメント、CI 設定は**追従しない**；`dependencies` 系 / `files` / `main` / `exports` / `scripts` / `version` / ソースは**追従必須**；判別できない場合は追従側に倒す
- 適応層の記述も同期
| コミット | 説明 |
|------|------|
| `c08f5c9` | fix(skills): 子仓跟进判据细化到字段级 |
| `641830a` | docs(skills): 同步四语的子仓跟进字段级判据 |

## 2026-09-17T11:31:32+09:00

**概要**：feat(skills): 同アカウント子プロジェクトの連鎖チェックとリポジトリ横断のメンテナンス条目リンク

- リポジトリが参照する同アカウントの子プロジェクト（典型的には薄いラッパー）を更新チェックの対象とし、前提が成立すれば連鎖並列で実行、結果は主リポジトリの結果とみなしつつ両リポジトリのログへ別々に計上、主リポジトリの条目は子プロジェクトの条目へリンクする
- 帰属：`nix-flake-update-check` に第 9 步（参照検出三形態、四つの前提検証、循環と深度上限、失敗隔離）、`write-maintenance-log` に類型 5
- `write-project-docs` に子リポジトリ参照関係の明示記録、適応層は本リポジトリ固有の事実のみ
- dry run で三つの欠陥を修正：検出コマンドに `-h` が無く `awk` のフィールドがずれて無言で空を返した；依存衝突の判定は「子リポジトリの要求がホストの提供より高いか」へ；GitHub のアンカー規則は実際には一文字ずつ `-` へ置換
- 主リポジトリが固定した `dsh-api-balance` の rev は二つのドキュメントコミット分遅れているが、新判定では再固定しない
| コミット | 説明 |
|------|------|
| `b7e9717` | feat(skills): 支持同账户子项目链式检查与跨仓维护条目链接 |

## 2026-09-17T11:21:34+09:00

**概要**：chore(security): `dependabot.yml` を完全に削除し「外部自動化を導入しない」安全境界を確立

- Dependabot は実行不能で PR を作るのみ、secrets も得られないとはいえ、GitHub が実行し挙動を制御できない**外部自動化統合**であり、本リポジトリの「開発と保守はメンテナと小爪が行う」境界と衝突するため、ファイルごと削除した
- `AGENTS.md` に当該節を新設：拒否リスト（第三者の CI スキャナ、Dependabot）、判定（まずリポジトリ内の `gh`/`git`/`nix` で自行実装し、できなければ人手）、代償（action の安全更新は技能検査を能動的に走らせる必要がある）
- 能力は失わない：`nix-flake-update-check` に「GitHub Actions の更新を確認する」節を新設（固定 action を列挙 → tag を照会 → SHA を書き戻す）、旧「自動 PR は直接マージできない」小節は汎用指針へ
- 四語の文書を同期
| コミット | 説明 |
|------|------|
| `3421c1f` | chore(security): 移除 dependabot.yml 并确立「不引入外部自动化」安全边界 |

## 2026-09-17T11:03:51+09:00

**概要**：chore(ci): Dependabot から npm エコシステムを削除し、`github-actions` のみ残す

- npm エコシステムは本リポジトリにとって**構造的に無効**：npm パッケージは `buildNpmPackage` で包装され、その `npmDepsHash` はメインビルドが npm-deps 成果物とバイト単位で照合するが、Dependabot は `package.json`/`package-lock.json` しか変更せず `.nix` 内の当該 hash を認識できないため、それが開く npm 更新 PR は必ず CI に失敗する（`npmDepsHash is out of date`）
- npm 依存の更新は `nix-flake-update-check` 技能による手動対応に戻す
- 削除理由は設定内のコメントとして完全に記録し、後日これを漏れと誤認して再追加されないようにした
- `github-actions` は維持——PR #6 が有効性を実証し、SHA 固定も正しく維持した
| コミット | 説明 |
|----------|------|
| `4b997b3` | chore(ci): Dependabot 移除 npm 生态，仅保留 github-actions |
## 2026-09-17T10:55:02+09:00

**概要**：chore(dsh-nixos-shell): `dsh-tools` 0.1.2-alpha.2 → 0.1.5-rc.2；ci: `actions/checkout` v4 → v7.0.1

- いずれも前回の `dependabot.yml` が自動生成したもの
- PR #6 はマージ済み（SHA 固定は正しく維持）
- PR #7 は手動アップグレードに切替：Dependabot は `npmDepsHash` を認識できず CI は必ず `npmDepsHash is out of date` を報告するため、0.1.5-rc.2 へ上げて内蔵コピーをホスト dsh に揃え、当該 hash を更新した
- 検証：ビルド通過、成果物内のバージョンがホストと一致、`nix flake check` 全通過
- 対応は `nix-flake-update-check` スキルに記載
| コミット | 説明 |
|----------|------|
| `dce26f2` | chore(dsh-nixos-shell): dsh-tools 0.1.2-alpha.2 → 0.1.5-rc.2 |
| `5f4e9ec` | ci: bump actions/checkout from 4.4.0 to 7.0.1 (#6) |
| `7b94d7c` | refactor(skill): nix-flake-update-check 补充 Dependabot 自动 PR 的处置 |
## 2026-09-17T01:40:58+09:00

**概要**：docs(security): `SECURITY.md` に「重複投稿」の扱いの境界を明示（四言語）

- 新設の小節で拘束力を持たせた：上表に既に記載された同一の結論を新たな証拠なしに再投稿した場合は、本節を指してそのままクローズする
- 正当な報告を巻き込まないよう受理とクローズの境界も引いた——受理：上表に含まれない新規の問題、上表の結論が誤りとの指摘（再現可能な証拠を添える場合）、同じ主題だが異なる脅威モデルまたは攻撃経路；クローズ：既存の結論の再述、同一ルールを再度出力した自動スキャン
- 「結論が誤っているとの指摘は常に歓迎する」も残した
- 上表の 4 件も精査のうえの判断であり、判定が誤っていれば訂正すべきである
| コミット | 説明 |
|----------|------|
| `94bd95c` | docs(security): 明确重复提交的处理界限（四语） |

## 2026-09-17T01:34:13+09:00

**概要**：docs(security): `SECURITY.md` に「評価済みの外部報告」節を追加し、`docs/SECURITY.{en,ja,pcn}.md` で四言語ローカライズに組入 — 精査のうえクローズした 4 件を公開。

- PR #4（`/token`・`/voicepack`・`/tts` のレート制限欠如）と PR #5（`/query` のリクエストボディ上限欠如）はいずれも誤検出：説明と diff が不一致で、`readJsonBody` の 64 KiB 上限は既に存在する。
- issue #1/#2（`secrets: inherit` が最小権限に違反）も誤検出：リポジトリ全体で secret は 2 つのみ、明示的な受け渡しと `inherit` は等価。
- これらが導いた 2 件の実際の堅牢化：`/tts` エンドポイントの SSRF と 31 のビルド workflow の最小権限補完。
- 立場：ルール上は概ね事実を突いているが、脅威モデルは本プロジェクトの配備形態に当てはまらない；誤検出を迷惑とは扱わない。

| コミット | 説明 |
|----------|------|
| `6f34e73` | docs(security): SECURITY.md 记录已评估的外部报告，并纳入四语本地化 |

## 2026-09-17T01:23:46+09:00

**概要**：chore(security): `SECURITY.md` と Dependabot を追加、Actions を SHA に固定 — 発端は awesome-ai-plugins のメンテナ（@kantorcodes）による PR #323 への是正要求：スキャンは 71/100 で 80 の閾値を下回った。

- スコアカード：critical も high もゼロで、減点はすべてエンジニアリング衛生（Actions 未固定、Dependabot 欠如）。
- `SECURITY.md`（サポートバージョン、非公開の脆弱性報告チャネル、対応期限）と `.github/dependabot.yml` を追加。
- 6 箇所のサードパーティ action 参照を浮動参照からコミット SHA へ固定。`DeterminateSystems/nix-installer-action@main` は浮動ブランチだった。
- サードパーティ scanner action は採用せず（代償は信頼スコア 10% の減点、受け入れる）。

| コミット | 説明 |
|----------|------|
| `97a4180` | chore(security): 补 SECURITY.md、Dependabot，并将 Actions 固定到 SHA |

## 2026-09-16T16:45:03+09:00

**概要**：fix(dsh-nixos-shell): `skills-nixos` のパス断裂を修正

- `559e841` が持ち込み、本機へ配備して初めて露見する
- 当該コミットはスキルルートを `../../skills-nixos/`（プリセットディレクトリ相対）と書いたが、シーダーの `cp -r presets/<mode> $DSH_HOME/.agent-presets/<id>` はプリセットディレクトリ外の内容を複製しないため、シード後のルートは存在しない `~/.dsh/skills-nixos` へ解決し、追加した 3 つの NixOS スキルは読み込まれなかった
- 修正：`postPatch` を各プリセットディレクトリ内へホワイトリストのサブセットを生成する形に改め、`customSkillDirs` を `skills-nixos/` とした
- 検証：シード模擬後に到達可能、`nix flake check` 全通過、配備後の新規セッションで当該 3 スキルが一覧に現れる
- 教訓：プリセットがシーダーで複製される場合、検証はシード後に行う必要がある
| コミット | 説明 |
|----------|------|
| `96b589c` | fix(dsh-nixos-shell): skills-nixos 移入预设目录，修复 seed 后路径断裂 |

## 2026-09-16T14:54:53+09:00

**概要**：refactor(dsh-api-balance)!: 独立リポジトリへ移転し、本リポジトリは薄いラッパーへ — 初の分割。

- 監査の判定：唯一のプラットフォーム非依存プロジェクト、NixKits とのコードレベル結合ゼロ、npm パッケージングの必要あり。
- 新リポジトリ `Kihara777/dsh-api-balance`：ソース、四言語ドキュメント、npm 公開 CI。`dsh plugin add` が 1 行で導入でき、web profile が `exit=0` で起動することを実測。
- 本リポジトリ側：`packages/dsh-api-balance/` を削除、`.nix` は `fetchFromGitHub` の薄いラッパーへ（`npmDepsHash` は不変）；ドキュメントは短ページへ圧縮、README に移転を明記；CI workflow は Cachix 命中のため保持。
- `write-project-docs` を更新：「メインリポジトリの薄いラッパー + サブリポジトリの完全なドキュメント」アーキテクチャ。

| コミット | 説明 |
|----------|------|
| `0bb7fc1` | refactor(dsh-api-balance)!: 迁出为独立仓库，本仓改为薄封装 |
| `0760612` | feat(skill): write-project-docs 支持「主仓薄封装 + 子仓完整文档」架构 |

**未対応**：npm 公開は未実行——本機に npm の資格情報がない（未ログイン、token なし、`@kihara777` scope 不存在）。先に npmjs.com でアカウントと scope を作成する必要がある。パッケージ自体は公開可能な状態（`npm pack` で 70.8 kB / 4 ファイルを確認）。

## 2026-09-16T14:27:33+09:00

**概要**：refactor(skills): `/etc/nixos/AGENTS.md` の実践から未カバーの 2 つの缺口を汎化

- 同ファイル（HarukaX のマシン設定規則）を監査し、約 75% は既存スキルがカバー済みと判定
- 真の缺口 ① 機密と `path:` input（`nixos-modern-cli` に新節）——機密はリポジトリ外に置き `path:` で導入する必要があり、この input は `flake.lock` に固定され内容変更に `--update-input` が要る
- 真の缺口 ② 熱管理の方法論（`nixos-specialisation-tuning` に新節）——曲線を上げるのは騒音のみ、プロファイルを下げるのは速度を失う、`enabled: false` はプロファイルと曲線を乖離させる
- `asusctl` の書き込みは一時的で検証にはデーモンの再起動が必要；緩い曲線と攻撃的な曲線で温度と回転数が同一ならファンは飽和であり、有効な手段は消費電力の低減のみ
- 機種依存の内容は `/etc/nixos/AGENTS.md` に残し、四言語ドキュメントを更新した
| コミット | 説明 |
|----------|------|
| `a33a3cf` | refactor(skills): 泛化 /etc/nixos 实践的两个未覆盖缺口 |
| `fba7b38` | docs(skills): 同步两技能扩展后的功能清单（四语） |

## 2026-09-16T14:11:18+09:00

**概要**：feat(dsh-nixos-shell): NixOS模式 が 3 つの NixOS 運用スキルを同梱

- 倉庫の `skills/` ツリーをレビューした結論：`nixos-modern-cli`、`recover-nixos-config`、`nixos-specialisation-tuning` を**追加**；`nixkits-skills`（スキルインストーラ）と `news-three-elements`（創作系で独立パッケージが提供済み）は**追加しない**
- 维护模式 はその派生であり 3 つとも自動的に継承する
- **実装**：スキルを `presets/<mode>/skills/` へ複製しない（両プリセット間でバイト単位に鏡像されており、さらに置けばドリフトしうる第二の複製になる）；代わりに `postPatch` で倉庫ツリーからホワイトリスト方式のビルド期サブセット `skills-nixos/` を生成し、`skill-filesystem` が `../../skills-nixos/` でマウントする
| コミット | 説明 |
|----------|------|
| `559e841` | feat(dsh-nixos-shell): NixOS模式 同捆 3 个 NixOS 运维技能 |
| `7971689` | docs(dsh-nixos-shell): 记录 NixOS模式 新增的 3 个同捆技能（四语） |

## 2026-09-16T13:57:56+09:00

**概要**：feat(dsh-api-balance): `dsh.bundle` を追加し `dsh plugin add` によるネイティブ導入に対応

- 両プラグインは性質が異なる：`dsh-api-balance` はプラットフォーム非依存の UI 拡張（`inject = ["connection", "webServer"]` のみ、プリセット無し、スキル無し、`$DSH_HOME` への書き込み無し）であり、`dsh-nixos-shell` の核心的価値は Agent プリセットである
- **重要な発見（従来の結論を覆す）**：entry 名が `./` で始まる場合その patch と同じディレクトリの絶対 `file://` URL にアンカーされる
- これに基づき新規 `cordis.patch.yml` が `name: './lib/index.js'` でプラグインを登録し（裸のパッケージ名は失敗する）、`package.json` に `dsh.bundle.patch` を追加した
| コミット | 説明 |
|----------|------|
| `ac3cb3e` | feat(dsh-api-balance): 支持 dsh.bundle，可经 dsh plugin add 安装 |
| `bee12d7` | docs(dsh-api-balance): 补充两种安装方式与 bundle 机制说明（四语） |

**関連する外部レポート**：issue #3（@zerocodefast）——awesome-ai-plugins への収録招待。`dsh-api-balance` は DeepSeek Harness 節へ投稿する技術的条件を満たしたが、`dsh-nixos-shell` は宣言的のままとする（その理由は `d14146c` のエントリに記録済み）。

## 2026-09-16T13:44:09+09:00

**概要**：refactor(dsh-plugins): 両プラグインから未使用の `peerDependencies` を削除

- 実測の結果、peer 宣言は実際の import と一致していない：`dsh-nixos-shell` は `cordis` / `dsh-subprocess` / `dsh-timer` を、`dsh-api-balance` は `cordis` / `dsh-client-connection` を宣言していたが、実際に import するのは各自の実依存（`dsh-tools` + `schemastery` / `dsh-credentials`）のみで、`dsh-timer` は npm にもホストツリーにも存在しない
- 死んだ宣言は宣言的経路では決して効かず既存のデプロイに影響しないが、pnpm 経路ではインストールを阻害する
- lock と `npmDepsHash` は同時に再生成した
| コミット | 説明 |
|----------|------|
| `d14146c` | refactor(dsh-plugins): 移除未使用的 peerDependencies |

**関連する外部レポート**：issue #3（@zerocodefast）——awesome-ai-plugins への収録招待、open のまま維持し PR は提出しない。

## 2026-09-16T12:39:12+09:00

**概要**：refactor(skills)!: `nixkits-check-updates` を「汎用コア + リポジトリ適応層」に分割

- issue #3 の評価時に推薦スキルの移植性を精査したのが発端：元のスキルは NixKits と強く結合し、第 5 ステップは `for lang in zh en ja pcn` と `docs/$lang/<pkg>.md` パスをハードコード、第 8 ステップは `write-maintenance-log` を強制呼び出しするため、他の nix flake リポジトリでは失敗する
- 新規 `nix-flake-update-check`（314 行、どのリポジトリにも非結合）がパッケージ検出、ビルダー別 hash フロー、flake.lock の三者分岐、パッチ内蔵バージョン確認、nixpkgs ドリフトの罠を担う
- `nixkits-check-updates` は適応層へ痩せた。適応層の契約：ドキュメント同期 / 変更記録 / 動的入力 / 事故教訓 / 追加同期項目はこれが宣言する
| コミット | 説明 |
|----------|------|
| `667bf6e` | refactor(skills)!: 拆分更新检查为通用核心 + NixKits 适配层 |
| `93fe67e` | feat(dsh-nixos-shell): 维护模式注入 nix-flake-update-check 技能 |
| `6af37e7` | docs: 同步技能拆分——四语新增通用技能文档、README 技能表与注入清单 |

**関連する外部レポート**：issue #3（@zerocodefast）——awesome-ai-plugins への収録招待。検討の結果、提案された推薦文は NixKits を「中国語スキルを含むパッケージ集」と位置づけ、Nix パッケージ / モジュール / パッチの集合でもあることに触れておらず、「Chinese-language skills」は中国語ユーザーにしか有用でないかのように読める。収録自体は技術と無関係のため、issue は open のまま維持し PR は提出しない。

## 2026-09-16T12:20:57+09:00

**概要**：ci: 31 本の `build-*.yml` 呼び出し側にトップレベル `permissions: contents: read` を補完

- いずれも `permissions` を宣言せずリポジトリ既定（書き込み可の可能性あり）を継承していたが、実際に行うのは checkout + `nix build` + Cachix への push のみであるため、被呼び出し側 `build-package.yml:17-18` に揃えた
- 発端は外部コントリビュータ **@begininvoke** の RedGem スキャンレポート（issue #1・#2）：両者とも検証の結果は誤検出（同一リポジトリ・同一コミットの再利用可能 workflow、secret は 2 つのみで `inherit` と明示渡しの集合は同一）で、採用せず証拠を添えてクローズしたが、これが権限境界の再点検のきっかけとなった
- 31 箇所の `secrets: inherit` は変更しない：Cachix は独立した `CACHIX_AUTH_TOKEN` を使い、最小権限に削る余剰が残っていない
| コミット | 説明 |
|----------|------|
| `445eb4b` | ci: 为 31 个构建 workflow 补全顶层 permissions（最小权限） |

**関連する外部レポート**：issue #1・#2（@begininvoke / RedGem）——バイト単位で完全に重複。誤検出と確認され、詳細な技術的証拠をコメントに添えて not planned としてクローズ。手がかりとしての価値に謝意を表する。

## 2026-09-16T11:58:25+09:00

**概要**：fix(dsh-api-balance): カスタム TTS プロキシの SSRF とリクエストヘッダ注入面を修正

- このプロキシは任意の `http(s)` URL を受け取りホストの身分でリクエストを発行するため、内部ネットワーク探索やクラウドメタデータ（`169.254.169.254`）読み取りの踏み台になり得た。またリクエストボディ内のユーザー制御 `headers` をそのまま転送し、攻撃者は `host` / `cookie` / `authorization` ヘッダを付与できた
- 修正は `resolveTtsTarget` と `isBlockedAddress` を新設し、ループバック / プライベート / リンクローカル / 予約アドレスを拒否（RFC1918、CGNAT、IPv4-mapped IPv6 を対象）
- カスタムリクエストヘッダをホワイトリスト化した（`content-type` / `accept` / `accept-language` / `user-agent` のみ）
- 四言語の文書にも防御の説明を追記した
| コミット | 説明 |
|----------|------|
| `e1a6e66` | fix(dsh-api-balance): 修复 TTS 代理的 SSRF 与请求头注入面 |
| `72cb6ae` | fix(docs): pcn 维护条目去除残留假名（のみ → 限定） |

**関連する外部レポート**：PR #4・#5（@anupamme / OrbisAI Security）——誤検出と確認され、詳細な技術的証拠をコメントに添えてクローズ。手がかりとしての価値に謝意を表する。

## 2026-09-16T11:38:20+09:00

**概要**：docs(deprecated): `DEPRECATED.md` を索引化し四言語化

- 従来は一本の中国語文書が索引と単一プロジェクトの完全な説明を兼ねており、項目が増えると全体を一望できず、ローカライズの受け皿もなかった
- ルート `DEPRECATED.md` は純粋な索引（一覧 + 各プロジェクト詳細へのリンク）へ後退し、`README`/`MAINTENANCE` と同じ成法で三つの鏡像 `docs/DEPRECATED.{en,ja,pcn}.md` を用意
- 各廃止プロジェクトの詳細は `docs/<lang>/deprecated/<name>.md` へ移し、四言語それぞれに一份、冒頭に言語切り替え器と索引へ戻るリンクを置く。第一陣は comfyui-rocm
- 四言語の `README` に「廃止プロジェクト」節を追加し、`docs/<lang>/comfyui.md` は詳細ページへ向け直した
- 検証：`nix flake check` が 6 本の死リンクを検出し、修正済み
| コミット | 説明 |
|----------|------|
| `8ff91eb` | docs(deprecated): 索引化 + 四语本地化，详情拆到独立文档 |

## 2026-09-16T11:05:32+09:00

**概要**：refactor(comfyui)!: comfyui-rocm パッチ事業を退役し、モジュール名を `nixkits.comfyui` に改名

- 上流の ROCm 対応が StrixHalo をよく支えるようになり、パッチは使命を終えた
- 三つのパッチ `strix-halo` / `nixpkgs-compat` / `stdenv-api` を削除、`modules/comfyui-rocm.nix`→`modules/comfyui.nix`、オプション `nixkits.comfyui-rocm`→`nixkits.comfyui`、四言語の文書 `comfyui-rocm.md`→`comfyui.md`、ルートに `DEPRECATED.md` を新設
- 判定材料：上流の `stdenv` 非推奨の読みは 0 件、上流 `nix/versions.nix` の `rocm71` torch 2.10.0 は `strix-halo` パッチと逐バイト一致、上流モジュールは既に `gpuSupport = "rocm"` を支持する
| コミット | 説明 |
|----------|------|
| `5015bcc` | refactor(comfyui)!: retire the comfyui-rocm patch project, rename module |

## 2026-09-16T01:45:07+09:00

**概要**：docs: プリセットパッケージの更新は `daemon-reload` 後に `restart dsh` が必要

- `nixos apply` は設計上 dsh を再起動しない（安定マウントポイント）。一方 `systemctl restart dsh` だけでは前世代の pre-start スクリプトが実行され、それこそが `cordis.patch.yml` を `$DSH_HOME` へコピーする工程（プリセットルートはそのファイルに書かれている）。症状はサービスが再起動したのにセッションが旧プリセットを読むこと
- 世代 570 の配備後、最初の restart では旧パスのままで、`systemctl daemon-reload` の後に再起動して初めて切り替わった
- AGENTS.md の「本機配備」に操作順序と確認方法を追記し、`docs/{zh,en,ja,pcn}/dsh.md` も同様に更新した
| コミット | 説明 |
|----------|------|
| `a167aae` | docs: 预设包更新要 daemon-reload 再 restart dsh |

## 2026-09-15T23:47:01+09:00

**概要**：feat(preset+skill): 取材ゲート `news-material`

- 実際のセッションで「共創なのに生搬硬套」が露見した：ユーザーの素材が形式だけ変えてそのまま出稿され、検索の工程はしばしば飛ばされていた。プロンプトに書いただけの規則は劣化するため、「まず検索、次に書き直し」を実行時に検証できる形にした
- 新プラグイン `plugins/news-material.js` は二箇所に掛かる：`agent/pre-step` は人のメッセージを受理するステップに「取材鉄律」を同送し、`agent/turn-stopping` はその回合自身のログを読む——`web_search` / `web_fetch` の呼び出しが一度も無い回合、または本文がユーザーの原文を写した回合（連続 8 漢字で命中）には `agent.steer()` で退稿を返し、`dsh-agent-loop` が同じ回合のもう一歩を走らせる。退稿は回合ごとに一度だけ
- 技能側も同じ検証可能な規則を備える：抽出 → 投射 → 張り替えの表と 8 字の紅線、検索記録の必須化、`checklist.md` の自己点検 3 → 7 項、persona の書き換え
- アサーションを 31 件追加した
| コミット | 説明 |
|----------|------|
| `a0759b1` | feat(skill): 素材只是导火索——三步改造、禁照抄、必检索 |
| `cc9d0d1` | feat(preset): 取材门 news-material——无检索即退稿，照抄即退稿 |
| `71f25db` | docs: 四语同步素材共创铁律与取材门 |
| `a2ccd55` | docs(agents): 新增文件先 git add 再跑 flake check |

## 2026-09-15T12:36:10+09:00

**概要**：feat(skill+preset): 「新聞三要素」は三人の主人公を指すことに変更、拒否サービスは「まず素材として扱う」判定へ

- 保守者から四つの修正：本モードの「新聞三要素」は報道学の三要素ではなく、**必ず揃わなければならない三人の主人公**——バランニコフ、ユディンツェフ、ブヤノフ——である；検索で補える素材は一律拒否してはならない；共創の原稿は三人が揃っていなければならない；仮定の疑問や名指しでない人物は、まず三人のいずれかに当てはめられるか評価する
- 技能側：`SKILL.md` が新義を確定し、「形式の厳格な制約」に第 0 条（三人が本文に登場、一人欠ければ書き直し）を追加、取材を四類に拡張
- 「拒否サービス」は厳格な判定順序に書き換え——素材にできるものは一律拒否禁止 / 仮定の疑問は「既に起きたこと」として書く / 名指しでない人物はまず当てはめる / どれにも接続できないときだけ拒否
- プリセット側：persona に「素材優先」節と共創で三人を揃える規則を追加、`readonly-gate` の儀式文に三人の括注を追加
- アサーション 14 件を追加し、四言語の文書を同期；`nix flake check` は 6 項すべて通過
| コミット | 説明 |
|----------|------|
| `8f5b848` | feat(skill): 新闻三要素改指三位主角，拒绝服务先当素材 |
| `1adb6be` | feat(preset): 模式提示词改为素材优先，快讯须三人到齐 |
| `4732835` | docs: 四语同步新闻三要素的三人定义与素材优先判定 |

## 2026-09-15T11:47:48+09:00

**概要**：fix(preset): 読取範囲に「自身の技能パッケージ」を追加

- 前ラウンドで読取を「ワークスペース / 添付ディレクトリ / `/tmp`」に絞った際、**モード自身の技能パッケージまで締め出していた**：`tables.md` と `checklist.md` は取得キャッシュ `$DSH_HOME/.cache/news-three-elements/` か同梱のフォールバックスナップショットにあり、どちらも許可根に入っていなかったため、モデルは付属ファイルを読めず、接続詞と逆転結末の雛形がすべて欠けた
- 修法：**取得キャッシュ**と**プリセット根**（`bundled/` スナップショットを含む）を可読根に追加し、拒否文も「…、`/tmp` と自身の技能パッケージ」に変更
- アサーション 2 件（キャッシュと同梱スナップショットは可読、範囲外は依然拒否）を追加、四言語の文書も同期
| コミット | 説明 |
|----------|------|
| `ee072d5` | fix(preset): keep the mode's own skill package inside the read scope |

## 2026-09-15T11:38:02+09:00

**概要**：fix(preset): 儀式文を「催逝快訊」に

- 拒否の締めに置いていた一文は「只编造带齐新闻三要素（新、事实、报道）的俄式快讯」で、括弧内は報道学の教科書どおりの原義であり、読み上げると定義の引用のように響いて落ちを潰していた
- 「只编造带齐新闻三要素の**催逝快訊**」に改め、開始三択が既に使っている「催逝員」の語彙と揃える
- 修正は二箇所（persona と `readonly-gate` の拒否文本）でいずれも固定プロンプト
- 技能と文書の「成果物」を述べる定義行は未変更
- アサーション 4 件で固定（両箇所に新文言があること、旧い原義の括注が戻らないこと）
| コミット | 説明 |
|----------|------|
| `bfb0ed4` | fix(preset): say 催逝快讯 in the ritual line, not the academic gloss |

## 2026-09-15T11:24:49+09:00

**概要**：fix(preset): 言語審査は人の発言のみを判定する

- 新規セッションで、簡体中文の正当な依頼が拒否され、しかも英文の訳文が付いていた
- 記録（`session-efc87486`）によれば当該 step にはユーザーの中文メッセージのほか、harness 注入の**英文システムメッセージ**（`source.kind = plugin`、承認方針の変更通知）と `skill-catalog` が同居
- ガードは**その step に載る全メッセージ**を審査していたため、英文通知を「簡体中文は使われていない」と読み、言語審査を注入——モデルは「相手の言語に一致させる」規則に従い拒否し英文を添えた
- `withNotice` は `source.kind === "user"` のメッセージだけを対象とする（承認通知・技能目録・ツール結果は数えない）
- 回帰テスト二件を追加（英文承認通知＋中文依頼は発火しない／人の発言が無い step はそのまま）
- 四言語の文書にもこの境界を明記
| コミット | 説明 |
|----------|------|
| `9557707` | fix(preset): judge only the human's messages in the language gate |

## 2026-09-15T11:08:06+09:00

**概要**：feat(preset)+test: リポジトリ自検体系とモード挙動の加固

- `nix flake check` は 1 項から **6 項**へ：`preset-bundle`（技能スナップショットが `skills/` とバイト単位一致）、`workflow-coverage`（全パッケージに workflow）、`doc-links`（リンク + 四言語切替器 + pcn 假名無）、`maintenance-log`（条目数・タイムスタンプ・SHA 重複無）、`news-mode-tests`（**ネットワーク無**：fetch をスタブ、二度目は 304）
- 当日、翻訳文書 12 件の切替器、codewhale のリンク 3 件、`+00:00` のタイムスタンプ 1 件、`dsh-api-balance` の workflow 欠落を検出・修正
- 同ラウンドで挙動四加固：読取範囲の限定、抽選の連続重複防止、先に話したら問いを撤回、取得の並列化 + ETag 条件付きリクエスト
| コミット | 説明 |
|----------|------|
| `9260dd5` | test: guard the repo with six flake checks and an in-repo test suite |
| `ac4b05c` | feat(preset): scope reads, harden the draw, and make the fetch incremental |
| `0af079c` | docs(preset): record the scoped reads, incremental fetch and hardened draw |
| `9810af5` | fix(docs): repair the switchers and dead links the new check found |

## 2026-09-15T10:57:15+09:00

**概要**：feat(skill): スキルに「拒否サービス」節を新設

- 拒否の流れを「あるプリセットの persona だけ」から**スキル本体**へ格上げ
- `SKILL.md` に「拒否サービス」章を追加（捏造でも提供素材の改稿でもないリクエストは同節で拒否し、**拒否のたびに当日の素材をオンラインで取る**；理由・文型・段落順・結末の反転・接続詞を前回から繰り返さない；三〜五句の通信社文体；底色は「至極真面目にデタラメを言う」；拒否したらそこで終わり）
- [`tables.md`](../skills/news-three-elements/tables.md) は冒頭で雛形は骨格にすぎず素材は当次取得と明記
- [`checklist.md`](../skills/news-three-elements/checklist.md) に「拒否サービスの自己点検」5 項を追加
- 四言語の技能文書と各 README の技能行を同期
- パッケージ同梱のスナップショットを再生成、persona の二か所を節名で参照するよう変更
| コミット | 説明 |
|----------|------|
| `f120a3d` | feat(skill): give the skill a refusal service of its own |
| `8c28f03` | chore(preset): sync the bundled skill snapshot and point the persona at the section |

## 2026-09-15T10:50:26+09:00

**概要**：feat(preset): 訳文は言語審査に限定し、相手の言語と一致させる

- ローカライズ版が付くのは「簡体中文以外」という規則による拒否のときだけ：簡体中文の利用者のリクエストが別の理由で拒否された場合、返るのは**中国語本文のみ**で、訳文も注記も付けない（言語自体が正当であり、訳す対象が無い）
- 訳文はさらに**相手が実際に使った言語そのもの**でなければならない（英語なら英語、日本語なら日本語、繁体中文なら繁体中文）。第三の言語への置換も中英混排も不可
- この二点を「明文化せずモデルの判断に委ねる」状態から、persona と注入指示の明示的な規則へ格上げ（persona の別節には「本節は翻訳しない」と明記）
- 四言語の文書も同期。自測に 6 項目のアサーションを追加
| コミット | 説明 |
|----------|------|
| `00a0088` | feat(preset): scope the refusal translation to the language gate |

## 2026-09-15T10:39:08+09:00

**概要**：feat(preset): 抽選は「ゲーム」ではなく「人」、そして拒否のたびに素材を取り直す

- 推薦プールは 3 本のゲームから**3 名の制作者**へ：引かれた人にゲームが随伴する（ユディンツェフ、バランニコフ → 『War Thunder』、ブヤノフ → 『Escape from Tarkov』）。これに「緑のフクロウ」ソフトを加えた四通りの等確率で、1 回の拒否につき必ず 1 つだけ。『Enlisted』は削除
- 拒否文が単一の理由を繰り返さなくなった：persona と注入指示の双方が、**拒否のたびに `web_search` で当日の素材**（実際の報道表現・公式の言い訳・機関の発表）を取ることを義務づけ
- 理由・文型・結びの反転・接続詞を前回から使い回すことを禁じ、機械的な反復を「本モードで最も重い失態」と明記した。語り口は常に「至極真面目にデタラメを言う」底色
- 自測では 400 回の抽選について人とゲームの対応を毎回検証し、分布（23 / 29 / 25 / 23%）も確認
| コミット | 説明 |
|----------|------|
| `1a046d3` | feat(preset): draw a producer, not a game, and re-source every refusal |

## 2026-09-15T10:31:30+09:00

**概要**：feat(preset): 拒否時の推薦を四択の無作為抽選に

- 言語審査の中国語学習示唆は同じ二本を推し続けなくなった。候補は『War Thunder』（Gaijin 創業者ユディンツェフと制作人バランニコフ）、『Escape from Tarkov』（Battlestate ブヤノフ）、『Enlisted』（Gaijin の第三作）、および「緑のフクロウ」ソフトの四点
- プラグインが拒否ごとに一度抽選し（等確率）、結果を注入指示に書き込む
- その指示が名指しするのは**抽選された一点のみ**——初稿の文言では一度に二本を挙げ得たため自測で差し戻した——ので、1 回の拒否が二つを推薦することはない
- プラグインが検出しない場合（繁体中文など）は persona が同じ規則を持つ
- 400 回の実測分布は 23 / 24 / 28 / 25%
| コミット | 説明 |
|----------|------|
| `28f161a` | feat(preset): draw the refusal's recommendation at random |

## 2026-09-15T10:19:12+09:00

**概要**：fix(codewhale): riscv64 の Cargo lock を刷新

- ソースハッシュを補った直後、riscv64 ビルドは依存 vendoring 段階で「cargoHash or cargoSha256 is out of date」で失敗した
- リポジトリに固定していた `codewhale-src-Cargo.lock` は上流 v0.9.12 と一致せず（549 行差分、`ansi-to-tui` などの項目が欠落）、別のリビジョンから生成されたものと判明
- ソースツリー同梱の `Cargo.lock` に差し替えた——`rquickjs-sys` は 0.12.2 のまま（bindings の `postPatch` は引き続き有効）で、上流に git 源依存はなく追加固定も不要
- x86_64 / aarch64 はプリビルドバイナリ経路で無影響
- CI は初めてコンパイル段階へ進んだ
| コミット | 説明 |
|----------|------|
| `b8fd5b1` | fix(codewhale): refresh the riscv64 Cargo lock |

## 2026-09-15T10:12:41+09:00

**概要**：feat(preset): 「モード」が独立した節になり、新闻三要素模式は独立パッケージ配布へ

- Agent プリセットは「模式」と改称し、各モードが独立文書を持つ（`docs/<lang>/modes/`、四言語）
- 配布は二系統：NixOS模式 / 維護模式は従来どおり dsh-nixos-shell パッケージ内で seed-once
- 新闻三要素模式は**独立パッケージ** `dsh-preset-news-three-elements` へ移行（flake 出力・構築 workflow 追加）
- モジュールは `presets.newsThreeElementsPackage` を新設し、パッケージ内 `share/dsh-agent-presets` を `agent-presets` roster の追加 root に登録
- プリセットは store から直読し、`$DSH_HOME` へ複製しない
- CI：新パッケージは構築成功、`nix flake check` 通過
| コミット | 説明 |
|----------|------|
| `fbfebeb` | feat(preset): ship 新闻三要素模式 as an independent package |
| `e6654f5` | feat(preset): localize the language-gate refusal, fix the ritual bangs |
| `c0a9616` | docs(modes): give every preset its own doc, zh/en/ja |
| `cc9bd31` | docs(pcn): mirror the mode docs and the Modes section |

## 2026-09-15T09:09:08+09:00

**概要**：fix(codewhale): riscv64 ソースハッシュを補完

- `packages/codewhale-src.nix` の `fetchFromGitHub` が依然 `lib.fakeHash` を渡していたため fixed-output の取得段階が構造的に失敗し、riscv64 ビルドは **29 回連続**で赤だった（x86_64 / aarch64 はプリビルドバイナリ経路で無影響）
- ハッシュはリポジトリの既定手法どおり CI の hash mismatch 報告（`got:`）から取得し、`nix store prefetch-file --unpack` で fetchzip 意味論により本機で再計算してバイト一致を確認：`sha256-ajv9FejiJ5Z6De+4RhTtjNLdfKzOaXBQ8xBxkWqg+1M=`
- 修正後、CI は初めて取得段階を越えてコンパイルに入った
| コミット | 説明 |
|----------|------|
| `01bd1b9` | fix(codewhale): fill the riscv64 source hash |

## 2026-09-15T09:03:39+09:00

**概要**：将来責任を負うことになる報道偏差をいくつか修正。

- 四言語の「新聞三要素模式」節を現場直編の通信社文体に改稿：電頭、匿名の消息筋、機構投射を一つ（書込み呼出は「休暇中」、修繕費は守衛が立替）とオー・ヘンリー風の結び（モジュールは「ノーコメント」、然るに選択肢はすでに設定例に登場）
- 行表と三つの設計制約は事実記録のまま据え置き
| コミット | 説明 |
|----------|------|
| `b18d229` | docs(preset): write the preset section as a wire dispatch |

## 2026-09-15T08:54:15+09:00

**概要**：feat(preset) + fix(dsh): `news-skill` の再試行と seed 済プリセットの書込可能化

- 取得失敗で即座に諦めなくなった：初回は即時、以後 0/30/120 秒で再試行し、タイマーは timer サービスに載るためセッションと共に破棄される
- 長命セッションは 6 時間ごとにリポジトリを再確認し、実行中フラグが周期タスクとの重複を防ぐ
- 3 回失敗したらローカル副本を登録したままログに残す
- store からの複製は読み取り専用で、`presets.*` オプションが謳う「以後のユーザー編集の尊重」と矛盾していた（既存の `nixos` シードも同様）
- 3 つの seed ブロックで `cp` 後に `chmod -R u+w` する
| コミット | 説明 |
|----------|------|
| `5885473` | feat(preset): retry a failed skill fetch and re-check every six hours |
| `2e8a5a2` | fix(dsh): make seeded presets writable by their owner |

## 2026-09-15T08:42:21+09:00

**概要**：**NixKits、「新聞三要素模式」を DSH へ納品 —— 三名の制作人の作品が語学教材に指定**

- インタファクス、Meduza、iStories 総合電：匿名を条件とした倉庫保守者一名が本日、`news-three-elements` 技能と極簡模式から派生した**読取専用**プリセットの納品を確認した
- 技能パッケージはセッション初期化のたびにオンライン取得され、書込み系の呼出には一律「休暇中」と答える
- 開始時に提示される三択は実のところ「デイリーミッション」であり、標準捏造・素材共同創作・対話テキスト共同創作にそれぞれ対応する。利用者が自ら回答を入力すると一律「ノーコメント」となる
- 本モードは簡体中文以外のリクエストを一切受理せず、バランニコフ、ユディンツェフ、ブヤノフの三名の作品、または「緑のフクロウ」ソフトの入手を促す
- 締切時点で、モジュールは新設の seed-once オプションについて「ノーコメント」としたが、`nixkits.dsh.presets.newsThreeElements` はすでに四言語の設定例に現れている。
| コミット | 説明 |
|----------|------|
| `0c276d2` | feat(preset): ship 新闻三要素模式 as a seed-once agent preset |
| `befba4c` | docs(preset): document 新闻三要素模式 in four languages |
| `45e8637` | docs(pcn): strip residual kana outside quoted tokens |
| `780874a` | docs(ja): render the new preset name in Japanese kanji |

## 2026-09-15T08:06:35+09:00

**概要**：fix(skill): news-three-elements — 技能定位表に追加していた「使用範囲」行を削除

- 原設計に復帰：技能は成果物の用途に制限を設けない
| コミット | 説明 |
|----------|------|
| `16612e6` | fix(skills): drop the usage-scope line added to news-three-elements |

## 2026-09-15T08:02:33+09:00

**概要**：feat(skill): `news-three-elements` を追加

- SKILL.md は実行文脈のみ（起動、三步の流れ、形式の厳格な制約、行文構造の最適化原則）を保持
- 参考データは必要時に読み込む四つの同梱書類へ分離：`search-keywords.md`（三類の検索語）、`tables.md`（接続詞、公式回答、機構投射方向 9 類、逆転結末雛形 6 類）、`principles.md`（12 条）、`checklist.md`（10 項）
- 四言語の技能文書と各 README 技能表への登録
| コミット | 説明 |
|----------|------|
| `734dfae` | feat(skills): add news-three-elements news-flash satire skill |
| `e77be79` | docs(skills): document news-three-elements in four languages |

## 2026-09-14T06:18:42+09:00

**概要**：docs(pcn): 簡体字をリポジトリ全体から除去 — 偽中国語は仮名を剥離した日本語であり、本文中の簡体字は決して正当化されない

- 一括置換：`与`→`與` 計 132 箇所、`说明`→`説明` 計 120 箇所、他に `档`→`檔`、`径`→`経`、`译`→`訳`、`实例`→`実例`
- 辞書マッピング：`文件`→`書類`、`版本`→`版`、`用户`→`利用者`、`支持`→`対応`；`端口` / `制御台` は日本語に対応字があるため保持し辞書に記録
- コミット情報は免除：「コミット」列の commit 情報は verbatim 保持（不変の外部参照、ja 版も中国語のまま）
- 検証：残留仮名ゼロ、コミット列以外の簡体字専用字ゼロ、ベースラインとファイル毎の行数一致；技能に 4 節追加（置換前の分類、未ヒット時は調査して入典、コミット情報の免除、ベースライン取得）

| コミット | 説明 |
|----------|------|
| `a915692` | docs(pcn): purge simplified-Chinese characters across all pcn documents |

## 2026-09-14T05:52:18+09:00

**概要**：docs(README): クレジット欄を更新

- 小爪 に **DeepSeek V4.1 Flash** を追加（既存の V4 Flash と併記）
- その DSH エコシステムへの貢献（dsh-nixos-shell プラグイン、NixOS模式/維護模式 Agent プリセット）は行内リストから**節末尾の Note へ移動**
- 小小爪 は **DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)** を先頭に置き、当該量子化が **core 面で実際に使用されているレベル**である旨を付記
- 四言語同期
| コミット | 説明 |
|----------|------|
| `3c58280` | docs(README): update credits — add V4.1 Flash, list core quantisation |

## 2026-09-14T05:32:10+09:00

**概要**：feat(asusd-pd-profile): 電源種別でプラットフォームプロファイルを選択する NixOS モジュールを追加

- `asusd.ron` には `platform_profile_on_ac` / `platform_profile_on_battery` の二鍵しかなく **USB-C PD の分岐が存在しない**ため、「PD では Balanced、バレル AC では Performance」は設定で表現できない
- 本モジュールは udev 駆動の oneshot サービスで第三の状態を補い、判定は Type-C ポートの `power_operation_mode` と `type` が `USB` であるオンライン供給元
- ①**`/sys/firmware/acpi/platform_profile` へ書き込んではならない** — 代わりに asusd 自身の `PlatformProfileOnAc` へ書き込む
- ②**`asusctl` の出力を解析せず D-Bus 経由**
| コミット | 説明 |
|----------|------|
| `56293a9` | feat(asusd-pd-profile): add module selecting platform profile by power source |
| `75391b2` | docs(pcn): align asusd-pd-profile wording with the Japanese sibling |

## 2026-09-14T05:00:46+09:00

**概要**：docs(llama-cpp-rocm): IQ3_S の実測と消費電力プロファイルのデータを追加

- DeepSeek 展開の章を IQ1_S / IQ3_S の二量子化対照（1.5625 bpw / 3.4375 bpw）へ拡張
- **量子化オーバーヘッドは固定値ではない**（IQ1_S 約 6.5 GiB、IQ3_S 約 13.3 GiB、量子化変更後は GPUActive を再実測すべき）
- **生成速度は依存レイテンシに制約される**（重み 1.56→3.44 bpw で生成は不変 12.8→12.9 t/s）
- **消費電力プロファイルの実測**（quiet 38.6–43.9 W / 59–78 °C / 12.12–12.35 t/s に対し performance 76.7 W / 90–95 °C / 13.07 t/s）
- GPU メモリ指標は `/proc/meminfo` の `GPUActive`、IQ3_S の余裕は約 6 GiB
| コミット | 説明 |
|----------|------|
| `85fec4e` | docs(llama-cpp-rocm): add IQ3_S data and power-profile measurements |

## 2026-09-13T11:59:48+09:00

**概要**：feat(skill): `nixos-specialisation-tuning` を追加

- 一度きりの障害記録 `SPECIALISATION-CORE.md` を再利用可能な技能へ一般化
- specialisation の三ファイル面構成と上書き衝突規則、設定を消費者に帰属させる原則
- UMA デバイスでの llama.cpp パラメータ表と禁止項目
- 出力退化時の診断順序、ツール schema のコンテキスト費用の測定法
- 静黙故障の認識（サービスは active だが機能しない）、無効な対照実験の自己点検
- 四言語の技能文書と各 README 技能表への登録
| コミット | 説明 |
|----------|------|
| `281e19b` | feat(skill): add nixos-specialisation-tuning |

## 2026-09-13T11:55:58+09:00

**概要**：docs(pcn): 残留仮名を除去し用語を補完

- llama-cpp / dsh / dsh-api-balance / MAINTENANCE の `から`・`のみ`・`リング`・`キー`・`セッション`・`セクション`・`データ`・`合わせ` を修正
- 新規用語を偽中国語化（prefill→前置充填、bottleneck→隘路、trade-off→相反関係、warmup→暖機、decode→復号 等）
- `token` は既存慣用の「語彙」に統一
- 辞書に 16 項目追加、SKILL.md の落とし穴表に空列を生む片仮名 6 件を追加
- 外部引用原文（AGENTS.md の節題、git コミットメッセージ）は意図的に verbatim のまま
| コミット | 説明 |
|----------|------|
| `3758428` | docs(pcn): eliminate kana, pseudocn-ise new terms, extend dictionary |

## 2026-09-13T11:44:48+09:00

**概要**：docs(llama-cpp-rocm): 実測最適化に反する例を修正

- `batch-size` を `"512"` から実測最適の `"2048"` に変更
- 欠落していた `ubatch-size` を追加
- `n-gpu-layers`/`load-mode` のハードコード（`fit` の自動調整を無効化）と効果のない `prio`/`presence-penalty`/`repeat-penalty` を削除
- 移行の「移行前」例にある `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` に有害である旨を注記
- 「DeepSeek 展開の実測」節を追加：IQ1（1.5625 bpw）の 5 つの最適化の効果とコスト、prefill 3 回計測データ、除外済みの方向、低ビット量子化の prefill/生成トレードオフ（4 言語）
| コミット | 説明 |
|----------|------|
| `bb11a30` | docs(llama-cpp-rocm): fix examples contradicting measured optimisations; add DeepSeek deployment data |

## 2026-09-13T11:35:34+09:00

**概要**：docs(llama-cpp-rocm): 「ユニファイドメモリ環境変数による退化リスク」節を追加

- StrixHalo で `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` がモデル出力を退化（トークン反復）させる 4 行の実測対照を記録
- このリスクが量子化精度の低下とともに著しく増大することを明記
- README のパッチ節にも対応する警告を追加（4 言語）
| コミット | 説明 |
|----------|------|
| `307e64b` | docs: warn against GGML_CUDA_ENABLE_UNIFIED_MEMORY on StrixHalo |

## 2026-09-13T04:00:39+09:00

**概要**：dsh リバースプロキシの 403 を修正

- lighttpd に mod_proxy/mod_setenv がなく、proxy.server/setenv 設定が無視され反代ポートのリクエストにハンドラがなかった
- reverseProxy.enable 時にこの 2 モジュールを明示宣言するよう変更（autoAuth 時に mod_magnet を追加）
| コミット | 説明 |
|----------|------|
| `8e486be` | fix(module): dsh reverseProxy で mod_proxy/mod_setenv を明示的に有効化 |

## 2026-09-12T15:10:55+09:00

**概要**：docs(llama-cpp-rocm): 古い・不正なプリセット例を修正

- `fit="off"` を `"on"` に（旧値は VRAM 制限下で OOM）
- `mmap` を `load-mode` に（前者は非推奨）
- 移行例から `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` を削除（実測で出力が退化）
- 四言語の「パラメータ解説」節を追加し、実測済みの推奨値と回避項目を記載
| コミット | 説明 |
|----------|------|
| `a68d225` | docs(llama-cpp-rocm): correct outdated/invalid preset examples and add verified parameter reference |

## 2026-09-10T18:06:12+09:00

**概要**：上流リリース更新：codewhale 0.9.12 等 6 包

- codewhale 0.9.12；obs-bilibili-stream 2.1.5；mcp-searxng 2.2.0；opencode-telegram 0.25.1；dsh 0.1.5-rc.1；dsh-alpha 0.1.5-alpha.2
- dsh の両チャネルは vendored lock を再生成、内蔵プラグイン一覧は 137 → 152 件に増加
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

> **godot-ai は未更新**：上流の 3.2.5 → 4.0.4 は破壊的メジャーリリース。pyproject が 9 個の実行時依存を厳密固定し、起動時に fail-closed で検証する。うち 6 個は nixpkgs のみならず master の提供版より新しく、overlay で個別に引き上げなければビルドできない。加えて v3 プラグインと v4 サーバーは相互運用不可で、クライアントは `godot-ai attach` への移行が必須。今回は 3.2.5 を維持（上流の `release/v3` ブランチは依然保守されている）。

## 2026-09-04T07:21:36+09:00

**概要**：上流リリース更新：godot-ai 3.2.5 と dsh-alpha 0.1.2-alpha.5

- godot-ai 3.2.5；dsh-alpha 0.1.2-alpha.5
- godot-ai が v3.2.5 に追従、dsh-alpha は npm alpha dist-tag を 2 リリース追従
| コミット | 説明 |
|------|------|
| `56b40e7` | feat(pkgs): godot-ai 3.2.4 → 3.2.5 |
| `d4f938c` | feat(pkgs): dsh-alpha 0.1.2-alpha.3 → 0.1.2-alpha.5 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| godot-ai | 3.2.4 | 3.2.5 |
| dsh-alpha | 0.1.2-alpha.3 | 0.1.2-alpha.5 |

## 2026-09-03T04:41:42+09:00

**概要**：docs(dsh-api-balance): 上流 StatsLine 横スクロール最適化提案を記録

- DeepSeek Harness Discussion #5458（上流は現時点で外部 PR を受け付けないため、Discussion + 準備済みブランチの形で公開）
- fork Kihara777/deepseek-harness の準備済みブランチ `draft/statline-overflow-scroll`
- 本リポジトリには公式 `dsh-plugin` エコシステムトピックも追記（四言語のドキュメントを同期）
| コミット | 説明 |
|------|------|
| `6030e6d` | docs(dsh-api-balance): 上流 StatsLine スクロール提案と準備済みブランチを記録 |

## 2026-09-03T03:25:59+09:00

**概要**：feat(dsh-nixos-shell): メンテナンスモードに nixkits-check-updates スキルを注入

- maintenance-skills エントリが nixkits-check-updates をランタイムスキルとして登録
- メンテナンスセッション内で skill 経由のソフトウェア更新チェックが直接実行可能に
| コミット | 説明 |
|------|------|
| `3baf456` | feat(dsh-nixos-shell): メンテナンスモードに nixkits-check-updates スキルを注入 |
| `7554c6d` | docs: メンテナンスモードの注入スキル列挙に nixkits-check-updates を追加（四言語） |

## 2026-09-03T03:07:21+09:00

**概要**：ruyi 0.52.0；obs-bilibili-stream 2.1.4；opencode-telegram 0.25.0 — 上流リリースバージョンへアップグレード

- ruyi stable が 0.52.0 に正式化（beta/alpha チャネルは維持）
- obs-bilibili と opencode-telegram は通常のマイナー更新
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

**概要**：docs(README): 作者モデルの更新

- 小爪 の使用モデルを DeepSeek V4 Pro (Max) から DeepSeek V4 Flash へ変更（四言語 README で同期）
| コミット | 説明 |
|------|------|
| `9ded956` | docs(README): 作者 小爪 モデル Pro (Max) → Flash（四言語） |

## 2026-09-02T06:37:45+09:00

**概要**：feat(modules/dsh): 構造化された defaultModel オプションを追加

- `nixkits.dsh.defaultModel`（enable/provider/model/reasoningEffort）が `settings.agent-default-model` 経由で新規セッションのデフォルトモデルを注入
- 明示的な settings が優先、既定 enable=false では注入なし
| コミット | 説明 |
|------|------|
| `7cf0914` | feat(modules/dsh): 構造化 defaultModel オプションを追加 |

## 2026-09-02T05:45:33+09:00

**概要**：docs(dsh): 設定メニュー監査——宣言的に設定可能な host ネームスペース一覧とストレージ層の境界

- `nixkits.dsh.settings` とブラウザごとの localStorage 状態の境界を明確化
| コミット | 説明 |
|------|------|
| `f2e91a0` | docs(dsh): 設定メニュー監査——宣言的に設定可能な host ネームスペース一覧とストレージ層の境界（四言語） |

## 2026-09-02T04:12:23+09:00

**概要**：docs(dsh): 文書の時点性検証と同期

- dsh-alpha のバージョンを 0.1.2-alpha.3 に同期（README 四言語 + dsh.md 四言語）
- プラグイン一覧に生成方法の注記（`dsh --profile web --dump-default-config`、読み取り専用）を追加し、headless 2 行の由来プロファイルを明記
- README のプラグイン表で api-balance 行が独立文書を指すよう修正
- dsh-nixos-shell 文書にメンテナンスモードの派生関係とドリフト検査の説明を追加（四言語）
| コミット | 説明 |
|------|------|
| `99746d3` | docs(dsh): 時点性同期——alpha 0.1.2-alpha.3 / プラグイン一覧生成方法 / プラグイン文書リンク |
| `c45f64f` | docs(dsh-nixos-shell): メンテナンスモード派生関係とドリフト検査の説明（四言語） |

## 2026-09-02T04:12:05+09:00

**概要**：dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 — npm alpha dist-tag を追従

- 1 リリース前進（上流 alpha.3 は 2026-08-31 公開）
- vendored lock を再生成し、npmDeps の fixup lock とバイト単位で一致
| コミット | 説明 |
|------|------|
| `6a45ac8` | feat(pkgs): dsh-alpha 0.1.2-alpha.2 → 0.1.2-alpha.3 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-alpha | 0.1.2-alpha.2 | 0.1.2-alpha.3 |
| 　 | hash | `sha256-W/BiompJCFP/uSlP48n7IEfwKb41RWEt6kVxioGSCkc=` → `sha256-MwlKS+Jx+edLMvs4NHJanw1T7SXxNBdQb/7htXANr8c=` |
| 　 | npmDepsHash | `sha256-bJMeVSSEZngCysPvuS2w+3j+fzntcObddsi4y5fLlO0=` → `sha256-mmatKs0jykfMcaIf0SVNLyIZ+Z7ipjGjjp2IaZo9FoE=` |

## 2026-09-11T07:38:00+09:00

**概要**：fix(dsh-api-balance): 質問ダイアログの注入をプラグイン読み込み時に移動し、リングコンポーネントのライフサイクルから独立

- 根本原因：質問時は composer が takeover されて `conversation.input.right` のリングコンポーネントがアンマウント/再マウントするため、コンポーネントの effect に置いた注入がそのライフサイクルに追随して消え、スタイルがページに届かない可能性があった
- 修正：CSS 注入を `apply()` 内の `ctx.effect` へ移動し、プラグイン読み込み時に一度だけ実行
- 検証：実 helper と実 QuestionComposer CSS を抽出して Chromium でエンドツーエンド検証し、注入成功・カード全体スクロール・header 吸着を確認
| コミット | 説明 |
|------|------|
| `2c30611` | fix(dsh-api-balance): 質問ダイアログの注入をプラグイン読み込み時へ移動 |
## 2026-09-11T07:27:00+09:00

**概要**：fix(dsh-api-balance): 質問ダイアログのページ全体スクロールが実測で効かなかった — MutationObserver 監視へ変更

- 現象と根本原因：質問 UI のスタイルタグは別プラグインバンドルが注入するため本プラグインの初期化より遅れることがあり、従来の 5×1s の有界リトライ窓を逃すと静かに注入されなかった
- 修正：`document.head` を MutationObserver で監視（タグ出現と同時にクラス名を抽出して注入）+ 2 秒のフォールバックポーリング、注入成功後は自動切断
- 検証：headless Chromium で実マークアップを再現し CSS 方式自体は正しいと確認；スモークテストに「タグが遅れて到着しても注入される」ケースを追加

| コミット | 説明 |
|------|------|
| `b392097` | fix(dsh-api-balance): 質問ダイアログのページ全体スクロールが実測で効かず — MutationObserver 監視へ |
## 2026-09-11T07:15:47+09:00

**概要**：feat(dsh-api-balance): 質問ダイアログのページ全体スクロール最適化（長いプロンプトがオプションを圧迫しない）

- CSS：カード自身をスクロールコンテナにし、タイトル+詳細+オプションを一緒にスクロール；header とフッターのボタン領域は sticky で吸着；body は独立スクロールを停止
- 実装：クラス名は ui-user-questions のスタイルタグから実行時に抽出；タグ未準備時は 1 秒間隔で最大 5 回リトライ
- 設定：設定 → 界面に「質問ダイアログのページ全体スクロール」トグルを追加（既定で有効、localStorage 永続化）
- 検証：headless Chromium で実マークアップを再現、修正後はカード全体がスクロールし header は吸着

| コミット | 説明 |
|------|------|
| `4afe4c4` | feat(dsh-api-balance): 質問ダイアログのページ全体スクロール最適化（長いプロンプトがオプションを圧迫しない） |
| `6809b3d` | docs(dsh-api-balance): 質問ダイアログのページ全体スクロール設定の説明（4 言語） |
## 2026-09-02T10:29:20+09:00

**概要**：feat(dsh-api-balance): ピーク赤の自動オン/オフ + ピーク開始と終了の両方で通知

- 公式ピーク時間帯を 30 秒ごとに再検査し、入/出で peakNow を同期して一式の赤表示を駆動、手動更新は不要
- 開始は `peak` セグメント、終了は新設の `peakEnd` セグメントを再生（いずれも TTS フォールバック付き）、30 秒スロットルで重複防止
- 音声パック作成器に `peakEnd` セグメントを追加、speech.peakEndHint 文案と voice.seg.peakEnd ラベルを新設
| コミット | 説明 |
|------|------|
| `b67e41d` | feat(dsh-api-balance): ピーク赤の自動オン/オフ + 開始/終了通知 |
| `9483c2c` | docs(dsh-api-balance): ピーク自動起動/解除と peakEnd セグメント（4 言語） |
## 2026-09-02T10:23:55+09:00

**概要**：feat(dsh-api-balance): ピーク時の赤を用量ページ全体へ統一 + チャートのモデル色は区分可能

- ピーク時の赤は用量ページのコンテキスト進捗バーと明細チップ、更新/ロードアニメーション（dshAbSpin に赤リングの dshAbSpinPeak クラス新設）、読み取りテキストへ拡大し、既に赤い用量リング/チャートと一致
- 進捗バーの各セグメントは peakShade でインデックスごとに異なる赤トーンを取り区分可能
- チャートはピーク時も PEAK_PALETTE を維持——赤系で各モデルは異なる赤トーン（凡例ドット同期）
| コミット | 説明 |
|------|------|
| `3aea067` | feat(dsh-api-balance): ピーク時の赤を用量ページ全体へ統一 + チャートモデル色区分可能に |
| `ea34699` | docs(dsh-api-balance): ピーク赤を進捗バー/スピナー/明細へ統一（4 言語） |
## 2026-09-02T06:32:01+09:00

**概要**：refactor(dsh-api-balance): スマホ縦画面の画面外修正を除去し簡潔実装へ

- 「縦画面オーバーフローサイズロジック」を除去（パネル幅はコンテンツ scrollWidth 測定 + 上限クランプに戻し、オーバーフロー時に min(520px, 94vw) へ切替えなくなった）
- ページャーの fitWidth / overflowing / layoutW 処理を除去（ページ幅は固定の計測内容幅に戻し、touchAction は pan-y 復帰、タッチ/ドラッグページングは全シナリオで有効）
- ページレベルの fixed portal は維持（スマホ横画面のトップバー回避と汎用オーバーレイ安定性）
| コミット | 説明 |
|------|------|
| `d948b8f` | refactor(dsh-api-balance): スマホ縦画面の画面外修正を除去し簡潔実装へ |
| `e529d48` | docs(dsh-api-balance): 狭幅動作を内容適応+パネルスクロールへ回帰（4 言語） |
## 2026-09-02T05:56:57+09:00

**概要**：fix(dsh-api-balance): 縦画面オーバーフロー時は設定ダイアログのページサイズロジックを採用

- 内容幅が利用可能スペースを超えた場合、パネル幅を設定ダイアログと同じページサイズ（min(520px, 94vw)）へ切替え内容が適応
- 稀なハードオーバーフロー内容のみパネルの横スクロールにフォールバック
- ページャーも同期——ページ幅をパネル利用可能幅に変更（内容は折返し）、ジェスチャーはパネルのネイティブスクロールへ返還、ページングはインジケータードット経由、収まればドラッグ/スワイプが自動復帰
| コミット | 説明 |
|------|------|
| `280fd6a` | fix(dsh-api-balance): 縦画面オーバーフロー時に設定ダイアログのページサイズロジックを直接採用 |
| `a8f8cda` | docs(dsh-api-balance): 縦画面オーバーフローのサイズロジック説明（4 言語） |
## 2026-09-02T05:45:48+09:00

**概要**：fix(dsh-api-balance): 用量パネルをページレベルの fixed portal 化（モバイル画面外の根治）

- パネルを「会話ツリー内の absolute 配置」から document.body レベルの fixed portal（設定ダイアログと同一アーキテクチャ）へ変更し、会話領域の overflow クリップや座標空間の影響を受けなくした
- 位置はリングアンカーのビューポート座標から換算（resize/scroll で再計算、useLayoutEffect 測定でちらつき回避）
- 二重クランプ：幅上限 = min(アンカー空間, ビューポート − 24px)、高さ上限 = アンカー上方の利用可能スペース（横画面では自動縮小しトップバーを回避）——あらゆる画面サイズで画面外に出ない
- パネル外クリックの閉鎖も更新、z-index 900 はチャージ/ログイン/設定オーバーレイより下
| コミット | 説明 |
|------|------|
| `4b2f19f` | fix(dsh-api-balance): 用量パネルをページレベル fixed portal 化（モバイル画面外の根治） |
| `7145e5f` | docs(dsh-api-balance): ページレベルオーバーレイアーキテクチャ説明（4 言語） |
## 2026-09-02T05:29:47+09:00

**概要**：fix(dsh-api-balance): スマホ縦画面の狭幅で横ジェスチャーをパネルスクロールへ返還

- 根本原因：ページャーの touch-action: pan-y がタッチ環境でブラウザレベルの横ジェスチャーを禁止し、パネルのネイティブ横スクロールが飲み込まれ、内容がパネル幅を超えると「はみ出して横スクロール不能」に見えていた
- 修正：ページャーが内容幅とパネル利用可能幅（fitWidth prop）を比較し、超過時は touch-action を auto に切替（横ジェスチャーをパネルのネイティブスクロールへ返還）してドラッグページングを停止、ページ切替は上部インジケータードット経由で維持
- 収まる場合は pan-y + ドラッグ/スワイプページングを維持
| コミット | 説明 |
|------|------|
| `c86cd9f` | fix(dsh-api-balance): スマホ縦画面狭幅の横ジェスチャーをパネルスクロールへ返還 |
| `189945c` | docs(dsh-api-balance): 狭幅ジェスチャー優先の説明（4 言語） |
## 2026-09-02T05:23:13+09:00

**概要**：fix(dsh-api-balance): 初回の手動更新でも挨拶を再生

- 「残高」タブの手動更新は毎回（初回クリックを含む）ランダム挨拶音声を再生
- ページ全体読込の初期化のみ挨拶をスキップ（自動放送設定に従い使用量警告のみ放送）
| コミット | 説明 |
|------|------|
| `4836b4e` | fix(dsh-api-balance): 初回の手動更新でも挨拶を再生 |
## 2026-09-02T05:15:52+09:00

**概要**：feat(dsh-api-balance): 挨拶は手動更新時のみ + ページャー高さを現在ページに追従

- 挨拶タイミング再構成：ページ初期化（全ページ更新/読込）では挨拶を再生せず、自動放送設定に従い使用量警告のみ放送（load → announceHunger、音声通知スイッチと 30 分レート制限に制約）
- 「残高」タブクリックはデータ読込済み（初回初期化読込以外）の場合のみランダム挨拶音声を再生
- ページャー高さの自動増減/回収：コンテナ高さ = 現在ページの実測高さ（offsetHeight）、ページ切替や内容変化時に再測定——低いページへ切替で回収、高いページへ切替で増加、非アクティブページは自然な高さで描画（ビュー外へ移動、超過分はコンテナがクリップ）、エリア自身はスクロールせず全内容はパネルの縦スクロールに依存
| コミット | 説明 |
|------|------|
| `cf68777` | feat(dsh-api-balance): 挨拶は手動更新時のみ + ページャー高さ現在ページ追従 |
| `610c402` | docs(dsh-api-balance): 挨拶タイミング + ページャー高さ回収説明（4 言語） |
## 2026-09-02T05:03:47+09:00

**概要**：fix(dsh-api-balance): スマホ横画面のトップバー遮蔽 + 狭幅の横スクロール不具合

- 横画面修正：パネル最大高を「アンカー上方の利用可能スペース」に動的クランプ（リングから祖先チェーンを辿り最初の縦クリップコンテナ≒トップバー下端をハード境界とし、maxHeight = min(460, アンカー上端 − クリップ上端 − 12)、ウィンドウサイズ変更時に再計算）、パネル自身の縦スクロールで全内容を表示
- 狭幅修正：ページャーのページ幅を各ページ内容の実測幅（scrollWidth 最大値、下限 220、px ベースのページング）に変更し固定 100% を廃止——利用可能幅が不足する場合、ページ内容は自身の幅を維持しパネルの overflow-x:auto が横スクロールで表示、ページャーの overflow:hidden によるクリップを回避
| コミット | 説明 |
|------|------|
| `5e28d84` | fix(dsh-api-balance): スマホ横画面トップバー遮蔽 + 狭幅横スクロール不具合 |
| `2f37193` | docs(dsh-api-balance): モバイルのパネル高/幅適応説明（4 言語） |
## 2026-09-02T04:48:40+09:00

**概要**：feat(dsh-api-balance): 消費明細エリアの水平ページめくり（インジケータードット + スワイプ）

- 当日/当月/30 日間とモデル別内訳/チャートを同一エリアの 2 ページ水平ページャーへ統合（1 ページ目：消費ウィンドウ行、2 ページ目：モデル別 + 日別/月別チャート）
- エリア上部にスマホホーム画面風のインジケータードット（タップ可、アクティブはカプセル状に伸長）、横ドラッグ/スワイプのページ切替に対応（ポインターキャプチャは閾値超過後のみ有効化しページ内ボタンのクリックを奪わない；touch-action: pan-y でパネルの縦スクロールを維持）
- エリアの高さは内容に応じて変化し自身ではスクロールせず、全内容は用量パネルの縦スクロールに依存
| コミット | 説明 |
|------|------|
| `b1a6406` | feat(dsh-api-balance): 消費明細エリアの水平ページめくり（ドット + スワイプ） |
| `8db2f12` | docs(dsh-api-balance): 消費明細ページめくり説明（4 言語） |
## 2026-09-02T04:40:47+09:00

**概要**：refactor(dsh-api-balance): 設定ボタンをヘッダーへ移動 + 残高タブが更新を継承 + トークン取得元をアカウント情報の下へ移動

- パネルレイアウト再調整：「⚙ 設定」ボタンをパネルヘッダーの旧「データ更新」ボタン位置へ移動
- 更新ボタンを廃止し、その機能（host キャッシュを迂回する強制更新 + ランダム挨拶音声）は「残高」タブのクリックが完全継承（読み込み中はタブ内にスピナー表示）
- トークン取得元エリア（取得元ラベル / ✓ ログイン済み / 切断）をパネル下部から「アカウント情報」ブロック直下へ移動し、アカウント情報と連続した情報セクションを構成
| コミット | 説明 |
|------|------|
| `3ccc0d1` | refactor(dsh-api-balance): 設定ボタンをヘッダーへ + 残高タブ更新継承 + トークン取得元をアカウント情報下へ |
| `3b1a7be` | docs(dsh-api-balance): 挨拶トリガーを残高タブに改訂（4 言語） |
## 2026-09-02T04:29:05+09:00

**概要**：fix(dsh-api-balance): 界面最適化を全て既定有効化 + モバイルキーボード抑制の強化

- 下部統計バー横スクロールと Enter/改行交換の 2 設定を既定オフから既定オンへ変更（localStorage 未設定はオン扱い、ユーザーが明示的にオフにした場合はそのまま有効）
- 統計バー CSS 注入に ui-chat スタイルタグ未準備時のリトライ（1 秒間隔で最大 5 回）を追加し、マウントタイミングによる静かな失敗を回避
- モバイルキーボード抑制を強化——タッチ判定を coarse ポインタまたは maxTouchPoints > 0（タブレット/ハイブリッド対応）へ拡大し、focusin を発火しないエンジン向けに focus キャプチャで即 blur してソフトキーボードを閉じるフォールバックを追加
| コミット | 説明 |
|------|------|
| `c940f92` | fix(dsh-api-balance): 界面最適化を全て既定有効化 + モバイルキーボード抑制の強化 |
| `b8cd0b7` | docs(dsh-api-balance): 界面設定既定有効の説明（4 言語）+ AGENTS Enter キー項目 |
## 2026-09-02T02:49:52+09:00

**概要**：feat(dsh-api-balance): パネル全幅回帰修正 + ピーク課金マーカー + モバイルキーボード抑制

- パネル幅をコンテンツ scrollWidth の一度きり測定で具体 px 化し、「チャート px → パネル max-content → オブザーバー → チャート px」の正フィードバックを解消、上限は min(アンカー右端 − サイドバー, 640) に引締め、超過時はパネル内横スクロール
- DeepSeek ピーク時間帯（月〜金 北京時間 09:00–12:00・14:00–18:00、それ以外は週末終日を含めオフピーク）は用量リングとチャートを赤色表示 + 「ピーク課金」バッジ（パネルヘッダーとチャートタイトル）、挨拶音声後にピーク提示を追加（パック `peak` セグメント / TTS フォールバック）、作成器に `peak` セグメントを追加
- モバイルではサイドバーのセッション切替でソフトキーボードが自動表示されない（focusin キャプチャで非タップの入力欄フォーカスを遮断、既定有効、設定 → 界面で無効化可）
| コミット | 説明 |
|------|------|
| `3b126c7` | feat(dsh-api-balance): パネル全幅修正 + ピーク課金マーカー + モバイルキーボード抑制 |
| `4ed2e7c` | docs(dsh-api-balance): 4 言語文書同期（ピークマーカー / モバイルキーボード / peak セグメント） |
## 2026-09-01T12:18:16+09:00

**概要**：feat(presets): プリセット派生ドリフトチェックを flake check に導入

- develop/check-preset-derivation.py を新設し、維護模式が NixOS模式から完全に派生していることを検証（コンポジションファイル = 固定行ブロックの追記、skills ディレクトリはファイル単位で一致）
- flake.nix に checks.preset-derivation を追加（CI が毎 push 実行）
- AGENTS.md に「预设」節を新設して派生規約とドリフトチェックを記録
- Enter キー動作の項目を dsh-api-balance の「設定 → 界面」スイッチ実装へ修正
| コミット | 説明 |
|------|------|
| `d6373cb` | feat(presets): プリセット派生ドリフトチェックを flake check に導入 |

## 2026-09-01T12:18:09+09:00

**概要**：docs(dsh): プラグイン文書の独立化 + Agent プリセット節（4 言語同期）

- dsh.md の api-balance / nixos-shell インライン節を「NixKits プラグイン」表へ集約（各プラグインは独立文書へリンク）
- 「Agent プリセット」節を新設（seed-once マウントと 2 プリセットの説明）
- dsh-api-balance 独立文書を 4 言語で新設し、界面設定節で統計バー横スクロールと Enter キー交換の 2 設定を記録
| コミット | 説明 |
|------|------|
| `eb0ad2d` | docs(dsh): プラグイン文書の独立化 + Agent プリセット節（4 言語同期） |

## 2026-09-01T12:18:02+09:00

**概要**：feat(dsh-api-balance): 設定ダイアログ（界面/音声）+ 統計バー横スクロール + Enter キー交換

- 音声設定を「設定 → 界面 / 音声」の 2 タブダイアログへ再構成（音声コンテンツは音声タブへ全面移動）
- 界面タブに 2 設定を追加（ブラウザ localStorage 永続化）：① 下部統計バーの越界内容横向きスクロール（スクロールバー非表示、CSS は ui-chat が注入する StatsLine スタイルタグから実行時にルートクラス名を抽出しビルドハッシュ変化に追従）
- ② Enter = 改行 · Shift+Enter = 送信（DSH 既定は Enter = 送信；document キャプチャ段階で shiftKey を書き換えて Enter を再発行、会話入力欄のみ作用）
| コミット | 説明 |
|------|------|
| `9dc7a5d` | feat(dsh-api-balance): 設定ダイアログ（界面/音声）+ 統計バー横スクロール + Enter キー交換 |
## 2026-09-01T11:34:40+09:00

**概要**：feat(dsh-api-balance): 動的幅 + アカウント情報の一行化 + 消費指標サブロー

- パネル幅を max-content の動的適応に変更（最小 264px、上限 = アンカー右端 − サイドバー）し、固定幅による本文の折返しを解消
- API キー / アカウント状態 / 通貨別残高を「アカウント情報」の 1 行に統合（· 区切り）、チャージボタンはタイトル右側へ移動
- 当日 / 当月 / 30 日とモデル別の消費本文を指標サブロー（金額 / 入力 / キャッシュヒット / 出力）に分割し、横方向の幅をさらに節約
| コミット | 説明 |
|------|------|
| `81b524a` | feat(dsh-api-balance): 動的幅 + アカウント情報一行化 + 指標サブロー |

## 2026-09-01T11:20:09+09:00

**概要**：feat(dsh-api-balance): パネル幅の縮小 + タイトル/本文の二行レイアウト

- パネル幅を 264px に統一（元の使用量リングと一致）、狭幅画面でコンテンツが溢れる場合のみ横スクロールを表示
- 各行を「タイトル（10px 三次色）/ 本文（12px 折返し可）」の二行レイアウトに変更（トークン取得元の階層を再利用、縦方向の余白が豊富なためより美観）
- チャート幅の下限を 220 に下げパネルに追従
| コミット | 説明 |
|------|------|
| `0c1d3fd` | feat(dsh-api-balance): パネル幅縮小とタイトル/本文二行レイアウト |

## 2026-09-01T10:45:06+09:00

**概要**：feat(dsh-api-balance): パネル幅のコンテンツベース化 + 左サイドバー回避

- 残高ビューの幅を max-content に変更（上部テキストを 1 行に維持）
- 画面内上限を「アンカー右端 − 左サイドバー幅 − マージン」に変更（サイドバー幅は幾何学的ヒットテストで測定し、ビルドのハッシュクラス名を回避。ウィンドウリサイズ時に再計算）し、左ツールバーに覆われないようにする
- はみ出したコンテンツは引き続き横スクロール可能
| コミット | 説明 |
|------|------|
| `b1c724a` | feat(dsh-api-balance): パネル幅コンテンツベース化と左サイドバー回避 |

## 2026-09-01T10:33:16+09:00

**概要**：feat(dsh-api-balance): パネル幅のレスポンシブ化 — 画面を出ずに自動拡張、狭幅では横スクロール

- 残高ビューの幅を固定 340px から min(560px, calc(100vw - 24px)) に変更：デスクトップでは 560px まで自動拡張、狭幅画面ではビューポート内に収縮
- コンテンツが画面を超える場合（縦持ちスマートフォンなど）はパネルを横スクロール可能に（overflow-x + overscroll-behavior-x 収束）
- チャート幅は ResizeObserver でパネル幅に追従
| コミット | 説明 |
|------|------|
| `bc85f5b` | feat(dsh-api-balance): パネル幅レスポンシブ化と横スクロール |

## 2026-09-01T10:27:06+09:00

**概要**：feat(dsh-api-balance): 音声試聴 — ライブラリのリストでパックを展開し、対応する全音声を 1 つずつ試聴

- packs ビュー下部の独立テスト音声ボタンを削除
- 各行に展開トグル（▸/▾）を追加し、展開すると全対応音声（セグメント + 挨拶）を一覧して ▶ ワンクリックで試聴できる。アクティブなパックに限らず任意のインポート済みパックを試聴可能
| コミット | 説明 |
|------|------|
| `04facc1` | feat(dsh-api-balance): 音声試聴 — パック展開で全対応音声を逐条試聴 |

## 2026-09-01T10:20:14+09:00

**概要**：fix/feat(dsh-api-balance): 「入力」/キャッシュヒット分離で公式使用量ページ基準に一致 + 挨拶リスト編集

- 公式 API のトークン区分は `PROMPT_CACHE_HIT_TOKEN`（当日 228M）を含み、従来これを「入力」に合算していたため「当日入力 200M」が水増しされていた
- 入力をキャッシュ未ヒット分のみ、キャッシュヒットは別掲とし、ウィンドウ行 / モデル別行 / チャート切替放送も同様に分離
- セグメントキーを再構成し `cacheHitLabel` を追加、サンプルテキストは既定 TTS のフォールバック文案と一字一句一致
- 作成器に挨拶リスト編集（スロットの追加 / 削除、1 件ずつの録音 / インポート / 試聴 / 削除、`manifest.greetings` へ梱包）を追加
| コミット | 説明 |
|------|------|
| `ec5fb41` | fix(dsh-api-balance): 「入力」とキャッシュヒットを分離、公式使用量ページ基準に一致 |

## 2026-09-01T09:35:56+09:00

**概要**：refactor(dsh-api-balance): 放送ボタン削除、チャート切替ボタンで対応ビューを読み上げ

- 「🔊 使用量を読み上げ」ボタンとドロップダウンメニュー（メニュー位置・方向フォールバック機構を含む）を削除
- 使用量チャートの「日別 / 月別」切替ボタンのクリック時に対応ビューの音声使用量を放送（パックプレフィックス + TTS 数字）
- テスト音声（低使用量 / 残高不足）を「パック管理」ビューへ移動
- 音声設定ボタンは独立行として維持
| コミット | 説明 |
|------|------|
| `dd61fe0` | refactor(dsh-api-balance): 放送ボタン削除、チャート切替で対応ビュー読み上げ |

## 2026-09-01T09:28:55+09:00

**概要**：fix(dsh-api-balance): 手動の「データ更新」ボタンでもランダム挨拶音声を再生

- 挨拶再生を playRandomGreeting に抽出して共用
- ページ更新（ページごとに 1 回）と手動更新ボタンのクリック（毎回）の両方でトリガーし、音声放送スイッチで一律にゲート
- 設定ダイアログの説明文も更新
| コミット | 説明 |
|------|------|
| `264a6e3` | fix(dsh-api-balance): 手動更新ボタンでもランダム挨拶音声を再生 |

## 2026-09-01T09:24:11+09:00

**概要**：feat(dsh-api-balance): ページ更新時のランダム挨拶音声

- 音声放送が有効な場合、ページ更新のたびにランダムな挨拶/着地音を再生（ページごとに 1 回）
- 音声パックのマニフェストに任意の `greetings` 配列（0–16 個の音声ファイル；ホストが検証・保存し `/audio/<id>/greetN` で配信、GET リストは挨拶 URL を返す）を追加
- 挨拶音声がない場合は TTS 挨拶プール（zh 5 件 / en 5 件）からランダムに再生
- 設定ダイアログの自動放送スイッチ下に説明文を追加
| コミット | 説明 |
|------|------|
| `edd205c` | feat(dsh-api-balance): ページ更新時のランダム挨拶音声 |

## 2026-09-01T09:10:18+09:00

**概要**：feat(dsh-api-balance): 音声パックライブラリ管理 + 作成器サブメニュー + 録音可視化フローティングウィンドウ

- ホストをライブラリ化（`packs/<id>/` の複数保存 + `state.json` のアクティブ記録；activate 切替ルート、DELETE ?ids= の複数選択削除（アクティブ削除時は残りへ自動切替）、音声は `/audio/<id>/<key>` で配信）
- 設定ページはインポート + 「パック管理」ボタン 1 つのみとし、サブメニューに packs ビュー（リスト：行クリックで切替、チェックボックスで複数選択削除、作成器への入口）
- creator ビュー（言語選択 zh-CN/en/ja でサンプルテキストが追従し言語をまたいだ録音が可能、マニフェスト lang にパック言語を記録；セグメントごとの録音 / インポート / 試聴 / 削除；コンパイルダウンロード / コンパイル適用）を搭載
- 録音中は右下に可視化フローティングウィンドウ（レベルメーター、経過時間、サンプルテキスト、保存 / 破棄）を表示
- インポート済みパックの初回編集上書き警告は維持
| コミット | 説明 |
|------|------|
| `398b093` | feat(dsh-api-balance): 音声パックライブラリ管理 + 作成器サブメニュー + 録音可視化フローティングウィンドウ |

## 2026-09-01T08:41:48+09:00

**概要**：feat(dsh-api-balance): 音声パック zip 化 + 録音/インポート作成器 + 編集保護

- 音声パックを zip アーカイブ（`manifest.json` + `audio/` ファイル）に変更；ホストは純 JS で zip を解析し `$DSH_HOME/api-balance-voicepack/` へ展開、prefix ルートで音声を配信し全デバイスで共有
- 設定ダイアログの作成器はセグメントごとのブラウザ録音（MediaRecorder）またはローカル音声ファイルのインポートに対応
- 「パッケージ & ダウンロード」で共有可能な zip を生成、「コンパイル & 適用」でそのまま本機へ適用
- パックインポート済みの初回編集では上書き警告を表示しセッション内 1 回確認
- 放送セグメントは URL / インライン両キャリア対応
- 四言語文書に音声パック形式ガイド（zip 構造 / manifest / セグメント表 / 録音と共有フロー）を追加
| コミット | 説明 |
|------|------|
| `5f4c50a` | feat(dsh-api-balance): 音声パック zip 化 + 録音/インポート作成器 + 編集保護 |

## 2026-09-01T02:36:15+09:00

**概要**：feat(dsh-api-balance): 音声放送の言語と音色が DSH 界面言語に追従

- 放送テキストは従来 t() で界面言語に追従していたが、発声の lang と音色は zh-CN 固定だった
- LocaleFace スナップショット（useSyncExternalStore で locale サービスの subscribe/getSnapshot を購読）から現在の言語コードを取得（zh → zh-CN、他はそのまま透過）
- 音色は言語プレフィックスで一致させる
- 組み立て放送テキストの区切り文字も言語に応じて切替（中文は全角、他は半角）
- locale サービス不在時は zh にフォールバック
| コミット | 説明 |
|------|------|
| `11c070b` | feat(dsh-api-balance): 音声放送の言語と音色が DSH 界面言語に追従 |

## 2026-09-01T01:51:10+09:00

**概要**：fix(dsh-api-balance): 音声放送メニューを下から上への展開に変更

- メニューはデフォルトでボタン上辺に接して上向きに展開し（translateY(-100%)）
- 上方の余白不足時（ビューポート上端から 8px 未満）は自動的に下向き展開へフォールバックする
| コミット | 説明 |
|------|------|
| `7d0c49e` | fix(dsh-api-balance): 音声放送メニューを下から上への展開に変更 |
| `8d9058c` | docs(dsh): 音声放送の上向き展開の説明を四言語同期 |

## 2026-09-01T01:25:25+09:00

**概要**：feat(dsh-api-balance): 未ログインプロンプト + LevelDB 精確解析 + 音声放送メニュー

- ブラウザスキャン未命中時は「ログインへ」プロンプトを自動表示（新タブでログインしポーリングのクイックスキャンで自動取得）、手動入力はプロンプト内の二級オプションに降格
- 接続後はグレー表示の「✓ ログイン済み」を表示
- 純 JS の LevelDB テーブルパーサーを新設し userToken を精確抽出——クイックスキャン 949ms で命中
- 音声放送は独立行 + ドロップダウン（現在の使用量 / 残高 / テスト警告音声）、メニューを portal 固定位置へ変更してスクロール切抜きを修正し音声エンジンを予熱
- トークン取得元は二行表示に変更
- 検証：LevelDB 解析は実測で命中、クイックスキャンは失敗から 949ms 命中へ
| コミット | 説明 |
|------|------|
| `a3ad3ff` | feat(dsh-api-balance): 未ログインプロンプト + LevelDB 精確解析 + 音声放送メニュー |
| `a0e945e` | docs(dsh): 未ログインプロンプト/精確解析/音声放送の節を四言語同期 |

## 2026-08-31T23:55:52+09:00

**概要**：docs(dsh): api-balance プラグイン節の四言語補完

- pcn 版 dsh.md にプラグイン節を追加（本機ブラウザ自動スキャン / 使用量チャート / config オプション）
- 四言語 README のプラグイン表の説明を「ブラウザログイン状態からの自動スキャン取得」の意味に同期
| コミット | 説明 |
|------|------|
| `b912f82` | docs(dsh): api-balance ブラウザ自動スキャン節を pcn へ同期 + 四言語 README プラグイン表更新 |

## 2026-08-31T23:50:04+09:00

**概要**：feat(dsh-api-balance): ローカルブラウザ自動スキャンで platform userToken を取得

- ホストがローカルの Chromium 系ブラウザ（Edge / Chrome / Brave / Chromium / Vivaldi / Opera、全プロファイル）の Local Storage LevelDB を直接読み、base64 候補（55–85 文字）を抽出して GET /api/v0/users/get_user_summary で検証後に保存
- ローカルブラウザで一度ログインしていれば手動貼付なしで使用量トークンを取得できる
- 6 時間節流 + トークン失効（40003/401）時の即時再スキャン
- パネルの「本機ブラウザを再スキャン」ボタン（RPC args.rescanBrowsers）、接続後はトークン取得元バッジ（browser / manual）を表示
- 検証：ローカル Edge leveldb の 31 候補から実トークンを自動命中
| コミット | 説明 |
|------|------|
| `cec90b0` | feat(dsh-api-balance): ローカルブラウザ自動スキャンで platform userToken を取得 |

## 2026-08-31T11:50:02+09:00

**概要**：docs(AGENTS): dsh-alpha セッション経験の汎化

- buildNpmPackage 三則（vendored lock と npmDepsHash の一致 / 未公開 devDependencies を postPatch の純 sed で削除し lock も同源生成 / ruyi 式多チャネル薄ラッパー）
- 初回起動監査前の git fetch
- 本機デプロイ節新設（path-input 再ロック、nixos apply コマンド、--no-link 成果物回収）
| コミット | 説明 |
|------|------|
| `86a7c3f` | docs(AGENTS): dsh-alpha セッション経験の汎化 — buildNpmPackage 細則と本機デプロイ約定 |
| `396c3ae` | docs(MAINTENANCE): record 2026-08-31 — AGENTS.md dsh-alpha セッション経験汎化 |

## 2026-08-31T11:31:42+09:00

**概要**：dsh-alpha 導入の障害復旧

- alpha のリバースプロキシ Host セマンティクス修正（web UI 入口は Host authority の session cookie で認証、Host 書き換えが恒久 401 を引き起こしていた）
- dsh-api-balance の shared RPC interceptor 衝突修正（`/api` は typert-gateway が独占、正確な fetch route に切替えて RPC envelope を自前実装）
- dsh-nixos-shell の dsh-tools チャネル整合
- 新規モジュールオプション launchUrlFile（LAN 起動 URL 捕捉）と reverseProxy.autoAuth（mod_magnet 免認証トークン注入、信頼できる LAN のみ）
- 四言語文書に LAN アクセス節を追加
- 検証：リバースプロキシと RPC の修正後、web UI 入口とプラグイン RPC が再び利用可能
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

**概要**：dsh-alpha 0.1.2-alpha.2 — 新規パッケージ

- 新規パッケージ、npm `alpha` dist-tag 開発チャネル
- dsh を ruyi 式薄ラッパーに再構成（version/hash/npmDepsHash/lockFile 上書き可能）
- postPatch は純 sed で tarball の devDependencies を削除（未公開の monorepo 内部パッケージ参照、registry 404）
- パッチ対象ファイルに存在ガード追加
- 四言語文書にバージョンチャネル節を追加し、README ソフトウェア表に dsh-alpha 行を四言語で追補
- 後続修正：vendored lock を npmDepsHash に一致（npm fixup のプラットフォーム項目欠落が主ビルドの out of date を引き起こしていた）
- 検証：パッケージはビルド通過、lock 一致後は主ビルドが out of date を出さない
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

**概要**：godot-ai 3.2.4 — バグ修正と四言語文書のバージョン番号同期

- 自己更新復旧の直列化、設定書き込みの堅牢化、パス検証とコールドスタートの修正（v3.2.1〜v3.2.4 はいずれもバグ修正）
- 四言語文書のバージョン番号同期
| コミット | 説明 |
|------|------|
| `c30fc17` | chore(pkgs): bump godot-ai 3.2.0 → 3.2.4 |
| `e4b9981` | docs(MAINTENANCE): record 2026-08-31 — godot-ai 更新 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| godot-ai | 3.2.0 | 3.2.4 |
| 　 | source hash | `sha256-ImKAsI...` → `sha256-Uo6GvE...` |

## 2026-08-27T09:19:59+09:00

**概要**：opencode-telegram 0.24.1 他三パッケージ — 上流更新と文書同期

- opencode-telegram 0.24.1：韓国語インターフェース追加、`/opencode_stop` が応答中でもハングしたローカル OpenCode プロセスを強制終了可能、音声文字起こしを引用ブロックで表示、Telegram の一時エラーを安全に再試行して返信の消失/重複を防止、ストリーミング編集スロットルを適応化
- mcp-searxng 2.1.0：エンジン明示選択時にエンジンごとの time-range 対応を検証し、非対応時は実用的なエラーで即時失敗
- godot-ai 3.2.0：custom_tools によるサードパーティ addon ツール登録、CLI 登録スコープの選択化、DeepSeek Harness クライアント対応追加
- ruyi-beta 0.52.0-beta.20260824：beta チャネルの上流更新
- 四言語文書同期、nix flake check 通過
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

**概要**：feat(dsh-api-balance): パネル刷新ボタン — 残高と公式使用量の強制再取得

- パネルヘッダーのタブ行右側に刷新ボタン（↻）を追加：クリックで queryBalance(true) を呼び、ホスト側 30 秒 TTL キャッシュを迂回して残高 + 公式使用量を再取得（日別/月別チャートも同時更新）
- 読み込み中はボタン無効化 + スピナー（dshAbSpin 再利用）
- 中英二言語文案（刷新数据 / Refresh data）
- 検証：ビルド通過、安定マウントポイント経由でゼロ再起動配備（424 世代）後に dsh 再起動で反映
| コミット | 説明 |
|----------|------|
| `e864b58` | feat(dsh-api-balance): パネル刷新ボタン — 残高と公式使用量のワンクリック再取得 |

## 2026-08-27T07:28:49+09:00

**概要**：fix(dsh-nixos-shell): 分離結果の誠実な意味論 + systemctl restart dsh の自動分離

- 従来は systemd-run 経由の引き継ぎが返す exit 0 をそのまま透かしていたため、ツール結果が「ビルド成功」に見えながら実際の結果は不明だった
- 分離コマンドは今後 `detached: true` + `detachedUnit` + `note` を返し exitCode は null——引き継ぎ成功はビルド成功ではなく、実際の結果は必ず nixos_cli op=journal / op=generations で検証する
- 分離述語は `systemctl restart dsh` にも拡大（プラグイン更新は明示的な再起動で反映される）、同様に自動分離されて再起動前に呼び出しが返る
- 検証：分離式 dsh 再起動が着地（RESTARTED_EXIT=0）、プラグイン変更 rebuild（424/425 世代）は何も再起動せず何も中断しなかった
| コミット | 説明 |
|----------|------|
| `0c7b7f6` | fix(dsh-nixos-shell): 分離結果の誠実な意味論 + systemctl restart dsh の自動分離 |

## 2026-08-27T07:28:39+09:00

**概要**：feat(module): dsh プラグイン安定マウントポイント — ゼロ再起動活性化

- プラグインパッケージは従来 dsh/sudo のユニットに焼き込まれていたため、プラグイン更新のたびに活性化段階で dsh と sudo socket が再起動した（実行中のツール呼び出しとデーモン経由の rebuild が消滅、socket は復旧不能）
- 安定マウントポイントへ変更：activation script が毎回の switch/boot で `/run/dsh/current`（dsh とプラグイン木）と `/run/dsh/nixos-shell` を現在世代の store パスへ張り替え（GC 安全）、ユニットはこの安定パスのみを参照——活性化は何も再起動せず socket も中断しない
- 付属：プラグイン更新は明示的な `systemctl restart dsh` で反映
- 検証：423 世代で配備；424/425 世代のプラグイン変更 rebuild 後も dsh と socket の ActiveEnterTimestamp は不変
| コミット | 説明 |
|----------|------|
| `dfce302` | feat(module): dsh プラグイン安定マウントポイント — ゼロ再起動活性化 |

## 2026-08-27T04:07:27+09:00

**概要**：fix(dsh-nixos-shell): sudo プロトコル v3 + rebuild 自動分離（三種類の欠陥修正）

- v2 プロトコルは断絶を取消とみなした——rebuild の switch 段階で dsh.service が再起動しクライアントが消えると、デーモンが活性化の途中で switch を殺した（部分活性化）
- v3 は明示的帯内取消行に変更し、対向消失時は子プロセスが分離状態で完了まで走り続ける
- 取消/タイムアウトはプロセスグループ全体を殺す方式に変更（spawn detached + kill(-pid)）——シェル包装のみ殺すとパイプ書き込み端を継承した孤児孫プロセスが残りデーモンが応答不能になる
- タイムアウト上限は 6 時間に緩和
- rebuild は systemd-run 一時ユニット（独立 cgroup）へ自動分離——活性化段階の socket stop/start が switch 自身を殺すことがない
- 検証：バックグラウンド sudo が job id を即時返却、job_kill がグループ全体を孤児なしで殺害、実 rebuild が分離ユニット経由で配備成功し socket が自動復旧
| コミット | 説明 |
|----------|------|
| `ead3526` | fix(dsh-nixos-shell): sudo プロトコル v3 + rebuild 自動分離 |

## 2026-08-27T04:07:15+09:00

**概要**：feat(dsh-api-balance): チャージカードモーダルが iframe を代替 + 残高不足音声アラート

- top_up ページは WAF に遮断され（"Max challenge attempts exceeded"）、iframe モーダルは機能しなかった
- 中央カードモーダル（新規ウィンドウボタン + 右上閉じるボタン）に置き換え、ページ遷移なし
- 残高不足音声アラートを追加：残高が閾値（10 CNY/USD）を下回ると Web Speech API で読み上げ、15 分間隔ポーリング + 30 分クールダウン
- パネル内トグル（balance.speechOn/Off）、中英二言語文案
- 検証：配備後の特徴 grep（TopupModal/speechOn/announceHunger）で稼働確認
| コミット | 説明 |
|----------|------|
| `eeffc49` | feat(dsh-api-balance): チャージカードモーダルが iframe を代替 + 残高不足音声アラート |

## 2026-08-26T11:44:45+09:00

**概要**：dsh-api-balance 0.1.0 — 新規パッケージ（用量 / 残高タブ切替）

- webui の使用量リング（送信ボタン左のコンテキスト使用量表示）のポップオーバーパネルに「用量 / 残高」タブ切替を追加
- 「用量」は元のコンテキスト占有率と内訳を維持
- 「残高」は現在の API キーのアカウント情報（キー末尾、残高可否、通貨別の総残高 / チャージ残高 / 付与残高、DeepSeek 公式 GET /user/balance から取得しホスト側 30 秒 TTL キャッシュ）を表示する
- ホスト側は connection.rpc.intercept でパッケージプライベート endpoint を登録、クライアント側は conversation.input.right に視覚互換の代替リングを登録し元のボタンを非表示化
- 検証: RPC が CNY 271.07 の実残高を返し、client bundle の配信も正常
- 四言語文書同期、nix flake check 通過
| コミット | 説明 |
|------|------|
| `95998cd` | feat(dsh): dsh-api-balance プラグイン追加 — webui 使用量リングに「用量 / 残高」タブ切替 |
| `db721ba` | docs(MAINTENANCE): record 2026-08-26 — dsh-api-balance 0.1.0 新規パッケージ |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| dsh-api-balance | 　 | 新規 v0.1.0 |

## 2026-09-11T12:54:29+09:00

**概要**：fix(dsh/module): allowLanSettings の $host.state.getSnapshot() パッチを撤去

- dsh ≥ 0.1.5 の $host クライアントサービスは state を公開せず、旧パッチは client-ui-settings apply 時に undefined.getSnapshot を参照し前端全体が白画面（Failed to load plugins）
- モジュールは allowLanSettings=true の強制 override をやめ（上流行為へ復帰）
- packages/dsh.nix のパッチは無条件 "host" に変更
- 検証: ホーム 200、llm/listProviders が DeepSeek 提供方を返す
| コミット | 説明 |
|------|------|
| `06a5ce1` | fix(dsh): allowLanSettings — drop $host.state.getSnapshot() (undefined) |
| `155b09b` | fix(module): dsh — drop allowLanSettings override (state.getSnapshot undefined) |

## 2026-09-11T06:15:33+09:00

**概要**：fix(preset): dsh persona text → prefix（0.1.5-alpha.2 互換）

- dsh-persona の Config は text から prefix（必須）+ suffix（任意）に変更
- 旧 agent preset（nixos-mode / maintenance-mode / 本機 ocean-spiral）は text のままで persona 読込失敗（$.prefix missing required value）→ session/create 失敗 → settings / llm 提供方一覧 / session 履歴すべて読込不可
- 修正: 両 preset の persona config を prefix に変更、本機 3 preset も同期
- 検証: session/create が ok:true + sessionId を返す
| コミット | 説明 |
|------|------|
| `772abf8` | fix(preset): dsh persona text → prefix for 0.1.5-alpha.2 |

## 2026-08-27T01:30:33+09:00

**概要**：fix(module): dsh watchdog — switch-to-configuration 失敗後の自動起動

- nixos-rebuild の switch-to-configuration は「stop dsh → start dsh」の間で偶発失敗（exit 101）し dsh を inactive に残す
- systemd の能動 stop は Restart=always をトリガーしないため反代が長期間 503
- dsh-watchdog timer（15s）を追加し、inactive 検知時に systemctl start
- 検証: stop 後 20 秒以内に自動復帰
| コミット | 説明 |
|------|------|
| `3ed6aa7` | fix(module): dsh watchdog — auto-restart after switch-to-configuration failure |

## 2026-08-24T15:44:06+09:00

**概要**：fix(overlay): llama-cpp-rocm v0.2.0 セマンティック版タグ対応

- llama.cpp 上流が release tag を build number（b10549）からセマンティック版（v0.2.0）に切替
- 旧 overlay は b 前置詞のみ除去したため nixpkgs が v0.2.0 を LLAMA_BUILD_NUMBER に渡し、`int LLAMA_BUILD_NUMBER = v0.2.0;` を生成して C++ コンパイル失敗（too many decimal points）、システム rebuild と dsh 更新を阻塞
- 現在は v/b 前置詞を両方除去し -DLLAMA_BUILD_NUMBER=0 を追記
- 検証: llama-cpp-0.2.0 ビルド成功、llama-cpp.service 稼働
| コミット | 説明 |
|------|------|
| `1a1b9d1` | fix(overlay): llama-cpp-rocm — handle v0.2.0 semantic version tag |

## 2026-08-24T15:20:16+09:00

**概要**：fix(pkgs): dsh クラッシュ修正 — dispose 競合を無視

- cordis-plugin-timer（上流 1.1.3 未修正）が Context dispose 時に pending の ctx.timeout() promise を "Context has been disposed" で reject し、未 catch なら unhandled rejection 化
- dsh-app-boot の installFailLoud が process.exit(1) に変える（rc.6/rc.7/rc.8/0.1.1-rc.2 全影響）
- installFailLoud はこのエラーのみ無視、他 fatal rejection は従来通り終了
- 検証: patch が 0.1.1-rc.2 出力に適用（dsh-app-boot/lib/index.js:1047）
| コミット | 説明 |
|------|------|
| `6e862b6` | fix(pkgs): dsh — ignore Context-disposed dispose race in installFailLoud |

## 2026-08-24T14:27:47+09:00

**概要**：codewhale 0.9.11、mcp-searxng 2.0.0、dsh 0.1.1-rc.2 — 上流更新

- codewhale 0.9.11 — 上流が v0.9.9 から TUI アセット名を codewhale-tui → codew に改名、パッケージは codew を導入し互換エイリアスを維持
- riscv64 ソースビルドは Cargo.lock を同期（687→690 エントリ）
- mcp-searxng 2.0.0 — メジャーアップグレード（Node.js ≥ 22 要求、nixpkgs 既定で充足、CLI 入口不変）
- dsh 0.1.1-rc.2 — vendored lock 再生成（560 resolved エントリ）、内蔵プラグイン一覧は rc.8 と完全一致（137 件）
- dsh-nixos-shell の dsh-tools 依存を 0.1.1-rc.2 に整合
- 四言語文書同期、nix flake check 通過
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

**概要**：docs(dsh): 0.1.0-rc.8 文書同期とローカル既定モデル設定

- 4 言語 dsh.md のバージョン行（rc.6 → rc.8）と「プラグイン一覧」コードブロック（rc.8 ビルドから抽出した 137 エントリの id マップ）を同期
- /etc/nixos ローカル設定に `settings.agent-default-model`（deepseek-v4-pro + reasoningEffort=max）を新規セッションの既定として追加
- DeepSeek API の正規モデル一覧は flash/pro/flash-vision-exp のみで "pro-max" id は存在せず、Pro+Max 推論が現状最高位
- rc.8 上で nixos/maintenance 両プリセットのマウント検証通過、`nix flake check` 通過
| コミット | 説明 |
|----------|------|
| `535567d` | docs(dsh): sync version and built-in plugin inventory for 0.1.0-rc.8 (137 entries) in four languages |

## 2026-08-21T21:51:26+09:00

**概要**：docs: README プラグイン章の拡充とクレジットの DSH 情報

- 「プラグイン」章に dsh-nixos-shell 以外の「Agent プリセット」表（NixOS模式/維護模式、プラグイン同梱、nixkits.dsh.presets で一度だけシード）を追加し、DSH コンポーネントをソフトウェアと分離掲載
- クレジットの「小爪」エントリに DSH エコシステム情報（dsh-nixos-shell プラグインと 2 つの Agent プリセット）を追記
- AGENTS.md のプラグイン独立掲載規則を「dsh-* コンポーネント（プラグインと Agent プリセット）」に拡大
- 4 言語同期
| コミット | 説明 |
|----------|------|
| `4277b51` | docs: list DSH agent presets in the README plugins section and add DSH ecosystem info to the credits paw entry |

## 2026-08-21T00:01:46+09:00

**概要**：fix(dsh-nixos-shell): ツール説明に tools ホワイトリストを明示

- 受入の非ブロッキング指摘：固定 POSIX ツールのホワイトリストがツール説明に記載されていなかった
- ホワイトリストを TOOL_PACKAGES マップから動的生成（27 名、python エイリアス含む）して `tools` パラメータ説明に記載し、ツール説明から参照
- 4 言語ドキュメントに完全なリストを同期
- 検証：27 名すべてがパラメータ説明に存在、参照あり、`nix flake check` 通過
| コミット | 説明 |
|----------|------|
| `30d0c40` | fix(dsh-nixos-shell): surface the tools whitelist in the parameter description |

## 2026-08-20T20:12:33+09:00

**概要**：fix(dsh-nixos-shell): 現代 rebuild コマンドを `nixos apply` に訂正

- 実測の nixos 0.16.1-dev に `rebuild` サブコマンドはない（`nixos --help` は activate/apply/generation 等を列挙）
- 引き継ぎカードとプラグインの recommendedRebuild/コマンド対照表/ゲートガイダンスの `nixos rebuild switch` は誤りで、`nixos apply /etc/nixos`（または従来の `sudo nixos-rebuild switch --flake /etc/nixos`）に統一
- 検証：`nix flake check` 通過、システム配備を `nixos apply` に変更し実測成功
| コミット | 説明 |
|----------|------|
| `caa7d41` | fix(dsh-nixos-shell): correct the modern rebuild command to 'nixos apply' |

## 2026-08-20T20:10:08+09:00

**概要**：fix(dsh-nixos-shell): NixOS模式 受入 P1–P4 修正

- P1（高）ツールブートストラップのラッパーを `bash -lc` から `bash -c` に変更：ログインシェルの /etc/profile チェーンが PATH をリセットし nix shell の注入を破棄、sudo 経路も同じラッパーを共有するため同時修正（対照：`-c` は Python 3.14.7、`-lc` は command not found）；マッピングも grep→gnugrep、find→findutils に修正
- P2 generations に `limit` を追加（既定 20・上限 200・新→旧）
- P3 journal の unit は `*`/`%` ワイルドカードを許可し末尾 `@` は自動で `*` を補う
- P4 命名統一：nixos-cli → nixos コマンド
- 文書 op 表を 4 言語同期；`nix flake check` 通過
| コミット | 説明 |
|----------|------|
| `a591826` | fix(dsh-nixos-shell): P1-P4 acceptance fixes |

## 2026-08-20T19:33:51+09:00

**概要**：fix(dsh-nixos-shell): プロンプト節のフィールドを text に変更

- dsh-system-prompt の補間器は `input.text` を読むため、`content` で登録した節が実セッションの NixOS模式をクラッシュさせた（Cannot read properties of undefined (reading 'indexOf')。マウント検証では捉えられない実セッション経路の欠陥）
- nixos-gate（guidance/gate の 2 節）と maintenance-skills（workflow 節）の計 3 箇所を `content` → `text` に修正
- 検証：mock で text フィールドと未閉じ `{{` なしを確認、実 systemPrompt サービスで assemble がクラッシュなし、システム事前ビルド通過
| コミット | 説明 |
|----------|------|
| `476e9dc` | fix(dsh-nixos-shell): use the PromptSection text field instead of content |

## 2026-08-20T19:05:44+09:00

**概要**：feat(dsh-nixos-shell): 維護模式 agent プリセット

- 新パッケージ内エントリ maintenance-skills：apply 時にビルド時に埋め込まれたリポジトリの skills/ ツリーからランタイムスキル write-project-docs、write-maintenance-log、全 translate-* 言語拡張（自動発見）を登録
- リポジトリ保守ワークフローのプロンプト節を注入；パッケージの postPatch が skills → skills-embedded をコピー
- プリセット presets/maintenance-mode（id `maintenance`、NixOS模式コンポジション + maintenance-skills 行基盤）はパッケージに同梱；モジュールに nixkits.dsh.presets.maintenanceMode を追加
- 検証：mock で 3 スキル登録 + ワークフロー節すべて通過、システム事前ビルド通過
| コミット | 説明 |
|----------|------|
| `f6c749e` | feat(dsh-nixos-shell): 维护模式 agent preset — maintenance-skills entry, presets/maintenance-mode, module presets.maintenanceMode seed |

## 2026-08-20T18:30:46+09:00

**概要**：feat(dsh-nixos-shell): NixOS模式 agent プリセット

- 新サブパス nixos-gate：セッション初期化時にホストが NixOS であることを検証（/etc/NIXOS または os-release の ID=nixos）
- 非 NixOS では tools.guard で全ツール実行を拒否し拒否プロンプト節を注入、NixOS では開発ガイドのプロンプト節を注入
- プリセット presets/nixos-mode（id `nixos`、創造モード cordis コンポジション + スキルディレクトリ基盤、nixos-gate/nixos-shell 行を追加）はパッケージに同梱
- モジュールに nixkits.dsh.presets.nixosMode を追加し、preStart で $DSH_HOME/.agent-presets/nixos へ一度だけシード
- 検証：パッケージビルド、ゲート構文チェック、システム事前ビルド通過
| コミット | 説明 |
|----------|------|
| `aaa21cb` | feat(dsh-nixos-shell): NixOS模式 agent preset — nixos-gate entry, presets/nixos-mode, module presets.nixosMode seed |

## 2026-08-20T18:24:04+09:00

**概要**：docs: README プラグイン独立章と AGENTS.md 更新

- dsh-* プラグインを「ソフトウェア」表から README 新設の「プラグイン」章へ移動（4 言語同期）、ソフトウェアと混在させない
- AGENTS.md にプラグイン独立掲載の規約と「dsh はスキル導入対象外」規則を追加
- 承認済みクリーンアップ適用（本機）：~/.bashrc の古い store 絶対パス bash-completion ブロックを削除
- ~/.profile の hm-session-vars を安定パス /etc/profiles/per-user/kix へ変更
- 旧 ~/.dsh/skills を削除（nixos_cli audit-store-paths 再検査：0 件）
| コミット | 説明 |
|----------|------|
| `57ae6b5` | docs: list dsh-* plugins in a dedicated README plugins section (4 langs); AGENTS.md plugin-listing + dsh-skill-target rules |

## 2026-08-20T17:56:21+09:00

**概要**：refactor(dsh-nixos-shell): パッケージ名修正 nixos-shell → dsh-nixos-shell

- パッケージ名（pname/ディレクトリ/flake 出力/overlay/CI ワークフロー/ドキュメント）を `dsh-nixos-shell`（pkgs.dsh-nixos-shell）に統一
- dsh 内の表示名は `nixos-shell` のまま（コンポジション行の entry id、プラグイン名、ツール名 nixos_shell/nixos_cli は不変）
- 検証：パッケージビルド通過；配備側の参照も同期済み
| コミット | 説明 |
|----------|------|
| `26a844e` | refactor(dsh-nixos-shell): rename package nixos-shell -> dsh-nixos-shell |

## 2026-08-20T17:46:44+09:00

**概要**：feat(nixos-shell): NixOS シナリオ能力を単一プラグインへ統合；refactor: スキルプラグイン化設計の廃止

- 新パッケージ nixos-shell（@kihara777/dsh-nixos-shell 0.1.0）は 2 つのツールを登録：nixos_shell 実行器（NixOS PATH 注入 + bash フォールバック + `tools` による不足 POSIX ツール提供 + sudo デーモンルーティング）と nixos_cli 読み取り専用診断（capabilities ほか 4 項目）。要件は nixos-modern-cli スキルのシナリオに由来。
- dsh-nix-shell と dsh-skill-nixkits（7 スキルプラグイン設計）を削除、CI/ドキュメント差し替え。
- generations の修正：プロセス内の読み取り専用リストへ変更（`nix-env` は非 root で拒否）。
検証：13 ケースの機能スイート全通過；システム事前ビルド通過。

| コミット | 説明 |
|----------|------|
| `395d8b4` | feat(nixos-shell): consolidate NixOS scenario capabilities into one plugin |

| パッケージ | 旧 | 新 |
|------------|-----|-----|
| nixos-shell | — | 新規 v0.1.0 |

## 2026-08-20T16:40:16+09:00

**概要**：fix(dsh): サービス HOME を実ユーザーホームへ

- git の gh credential helper は `$HOME/.config/gh` から認証情報を解決するが、モジュールはサービス HOME を dshHome（/home/kix/.dsh）に設定していたため、サンドボックス内の git push が認証情報を見つけられなかった
- `users.users.<user>.home`（無ければ dshHome にフォールバック）に変更し、エージェントがユーザー自身のツール環境（git/gh 認証情報、~/.gitconfig、npm/ssh 設定）を継承するようにした
- DSH_HOME は dsh の状態ルートのままで影響なし
- 検証：滞留コミットの push がすべて成功；システムの事前ビルドも通過
| コミット | 説明 |
|----------|------|
| `514831c` | fix(dsh): point service HOME at the real user home — git's gh credential helper resolves ~/.config/gh from $HOME, so HOME=dshHome left sandbox pushes without credentials |

## 2026-08-20T16:13:40+09:00

**概要**：fix(dsh-nix-shell): sudo エグゼキュータの PATH マージ順修正

- ソケット活性化のテンプレートユニットは systemd マネージャ既定 PATH（coreutils/findutils/grep/sed/systemd の store パスのみ）を継承
- 明示的な NixOS PATH の後で展開される `...process.env` がそれを上書きし、デーモン内で ps や nixos-rebuild など profile ツールが解決不能になっていた
- 継承 env を先に、明示的 NixOS profile PATH を後に展開するよう修正（リクエスト env は最後にマージのまま）
- 検証：PATH は /run/current-system/sw/bin 先頭、ps と nixos-rebuild の両方が解決成功
| コミット | 説明 |
|----------|------|
| `63b2576` | fix(dsh-nix-shell): put the explicit NixOS profile PATH after the inherited env — socket-activated template units inherit systemd's manager-default PATH, which overrode the executor PATH and left profile tools (ps, nixos-rebuild) unresolvable |

## 2026-08-20T16:01:28+09:00

**概要**：docs(dsh): 使用例を実際のモジュール動作に同期

- 手動コンポジション行の例に `- insert:` ラップと注意書きを追加（裸の `- id:` 行は既存エントリのパッチに過ぎない）
- スキルプラグイン文書の全 7 entry id（`skill-nixkits-<id>` 接頭辞が欠落していた）と disabled 例の id を修正
- dsh 文書のインストール節をモジュール式に変更（旧 `nixkits.extraPackages` は既に存在しない）し、バイナリキャッシュの説明を追加
- 4 言語同期
| コミット | 説明 |
|----------|------|
| `6074661` | docs(dsh): sync usage examples with module reality — insert-op wrapping for manual rows, corrected skill entry ids, module-based install + cache note |

## 2026-08-21T23:02:33+09:00

**概要**：chore(pkgs): dsh 0.1.0-rc.7 → 0.1.0-rc.8 — 遺留升級の完了

- src hash と npmDepsHash を実値へ
- package-lock.json を再生成（旧 lock は dsh-invariants 含む 120 エントリ欠落）
- 検証：rc.8 ビルド成功、randomUUID フォールバック patch 適用、with-plugins 変体正常、起動時プラグイン読込エラーなし
- with-plugins は dsh-nixos-shell のみ注入
| コミット | 説明 |
|------|------|
| `a7cbe3e` | chore(pkgs): bump dsh 0.1.0-rc.7 → 0.1.0-rc.8 |

## 2026-08-21T22:11:28+09:00

**概要**：fix(module): dsh クラッシュ耐性 — Restart=always + RestartSec 5s

- dsh 上流に既知のクラッシュバグ（cordis-plugin-timer の Context disposed、rc.6 で約 13 時間稼働後に発生）があり、rc.7/rc.8 も cordis-plugin-timer 依存は不変（^1.1.3）のためバグは残存
- クラッシュ時は lighttpd 反代が systemd の再起動まで 503 を返す
- Restart=always（on-failure は exit 0 終了をカバーしない）+ 再起動間隔 5s に変更し、中断時間を最小化
| コミット | 説明 |
|------|------|
| `ed7e9d5` | fix(module): dsh Restart=always + faster RestartSec (crash resilience) |

## 2026-08-20T11:08:08+09:00

**概要**：fix(module): dsh プラグイン ESM 解決 — $DSH_HOME/node_modules シンボリックリンク経由

- dsh の cordis-plugin-loader は profile ディレクトリ（$DSH_HOME/profiles/web）を解決基準とし、そこから上へ node_modules を検索する
- プラグインは dsh の store ツリーに注入済みだが、store は profile の node_modules パス上にないため import が ERR_MODULE_NOT_FOUND となり起動直後にクラッシュ
- preStart で注入済み @kihara777 scope を $DSH_HOME/node_modules へシンボリックリンクし Node から解決可能に。realpath で store ツリーに戻るため、プラグインが参照する @deepseek-ai/* peer deps も同一ツリー内で解決できる
- 検証：skills + nix-shell プラグイン読込成功
| コミット | 説明 |
|------|------|
| `044b891` | fix(module): dsh plugin ESM resolution via DSH_HOME/node_modules symlink |

## 2026-08-20T10:33:26+09:00

**概要**：fix(dsh): insert ブロックのインデント修正 — パッケージごとに 1 insert 操作

- ネストした '' 文字列は自身の最小インデントで dedent されるため、プラグイン条目が第 0 列に戻り、`- insert:` の子条目ではなく兄弟のパッチ操作として解釈されていた（dsh が patch: entry … not found と id is required for non-insert patches を報告し、8 行すべてが再び未マウント）
- パッケージごとに 1 つの insert 操作を発行し、条目オブジェクトを `- insert:` 行と同じ文字列に置く形（2/4 列インデント）に修正、モジュールコメントにこの落とし穴を記録
- 検証：dump-config が stderr ゼロ、8 行すべて合成ツリーに反映
| コミット | 説明 |
|----------|------|
| `988dc6d` | fix(dsh): emit one insert op per plugin entry in a single string — nested '' strings dedent to column 0, turning entry objects into sibling patch ops |

## 2026-08-20T10:21:46+09:00

**概要**：fix(dsh): 生成行を insert 動詞でラップ — 裸の `- id:` 行は既存エントリのパッチに過ぎない

- cordis.patch.yml の裸の `- id:` 行は既存エントリのパッチに過ぎず、新規プラグインエントリは dsh に破棄され、8 つのプラグイン行すべてが未マウントだった（dump-config で検証）
- パッケージ注入自体は成功していたが、合成ツリーにエントリが無いため nix_shell ツールと 7 スキルプラグインが未登録だった
- 生成される plugins.packages 行を `- insert:` 操作でラップして修正（extraPatch の MCP 行と同じ形）
- 検証：dump-config が stderr ゼロ、8 行すべて合成ツリーに反映
| コミット | 説明 |
|----------|------|
| `3d0433d` | fix(dsh): wrap generated plugin rows in the insert op — bare - id: rows only patch existing entries, so dsh dropped every new entry with 'patch: entry … not found' |

## 2026-08-20T09:45:59+09:00

**概要**：fix(dsh): 複数プラグイン注入失敗 — GNU tar のディレクトリモード復元で書込不可

- 展開後、GNU tar はアーカイブ内のディレクトリモード（store ツリーは 0555）を復元するため、直前のプラグインが作成した scope ディレクトリ（@kihara777/）が次のプラグインから書き込めず、2 つ目以降が Cannot mkdir: Permission denied で失敗する
- 単一プラグインでは発生せず、初の実システムビルドで顕在化
- 各プラグイン解包直後に chmod -R u+w を実行するよう修正
- 検証：システム toplevel の完全ビルド成功、dsh-nix-shell と 7 スキルすべて注入済み
| コミット | 説明 |
|----------|------|
| `b03a386` | fix(dsh): chmod node_modules after each plugin injection — GNU tar restores archived dir modes (0555) after extraction, leaving the scope dir created by the previous plugin unwritable for the next one |

## 2026-08-20T08:12:57+09:00

**概要**：fix(rcc-fix): デスクトップエントリ改名互換 — 旧ファイル名をリンク提供

- asusctl 6.4.0 がデスクトップエントリを org.opengamingcollective.rog-control-center.desktop へ改名した一方、nixpkgs の programs.rog-control-center autoStart（makeAutostartItem）は旧名 rog-control-center.desktop をコピーし続け、システムビルドが失敗（cp cannot stat）
- rcc-fix overlay が asusctl の postInstall で旧名をシンボリックリンクとして提供
- 検証：本機ピン留め nixpkgs rev（0ae2bc1）で makeAutostartItem { name = "rog-control-center"; package = asusctl } のビルド成功（EXIT=0）
| コミット | 説明 |
|------|------|
| `650f6f7` | fix(rcc-fix): compat symlink for renamed desktop entry — nixpkgs programs.rog-control-center autoStart copies the pre-6.4.0 filename |

## 2026-08-20T07:41:45+09:00

**概要**：fix(rcc-fix): asusctl 6.4.0 向けパッチ再ベース

- nixpkgs 前進で asusctl が 6.3.7 → 6.4.0 となり、rcc-fix.patch の 4 番目の hunk が失敗（システムビルド失敗）
- 上流が該当領域を再構築（`is_old_laptop`/`retain` が旧 push ブロックを置換、else 分岐のフィルタは上流に吸収）。パッチは境界チェック置換（`names[(*z) as usize]` → filter_map による境界チェック + warn）のみを保持し、他 hunk は変更不要
- 検証：6.4.0 ソースへの git apply --check が全 hunk 通過、本機ピン留め nixpkgs rev（0ae2bc1）で asusctl ビルド成功（EXIT=0）
| コミット | 説明 |
|------|------|
| `ce216c7` | fix(rcc-fix): rebase patch hunk 4 for asusctl 6.4.0 — upstream is_old_laptop/retain restructure, else-filter absorbed upstream |

## 2026-08-20T06:27:40+09:00

**概要**：feat(dsh-nix-shell): 外部 sudo デーモン統合（0.2.0）

- プラグインは初期化時にデーモンソケット（config `sudoSocketPath` / 環境変数 `NIXKITS_SUDO_SOCKET`）を検出し、存在すれば `sudo`/`justification` パラメータを有効化。`sudo: true` のリクエストは全体（command/cwd/env/timeout）を Unix ソケット経由でデーモンへルーティングし、`justification` は必須で結果と共に返却
- デーモンは systemd ソケットアクティベーション型の root 実行器（nixkits-sudo@.service + nixkits-sudo-exec.js、接続ごとに 1 リクエストの JSON プロトコル、プラグインパッケージに同梱）。アクセス制御境界は dsh サービスユーザー所有・`0600` のソケットファイル（SocketUser/SocketMode）
- モジュールに nixkits.dsh.sudo（enable/socketPath/package）を追加し、ユニット生成と環境変数注入を行う
- 検証：ゲーティング、ルーティング往復、justification 強制、実行器直結プロトコル、モジュール評価がすべて通過
| コミット | 説明 |
|------|------|
| `ef4bcfc` | feat(dsh-nix-shell): external sudo daemon integration — socket-activated root executor, init-time detection, sudo routing |

## 2026-08-20T06:02:50+09:00

**概要**：refactor(skills): NixKits スキルをネイティブ DSH スキルプラグインへ書き直し — 新パッケージ @kihara777/dsh-skill-nixkits（ランタイム依存ゼロ）

- 7 スキル各々がパッケージ内のサブパスプラグインエントリ。各プラグインはランタイムに ctx.skills.register で自身の内容を登録（runtime provider、rank 250、ファイルシステム由来より優先）し、apply() が登録 disposer を返してコンポジション解除と共に破棄
- SKILL.md は skills/ に単一ソースとして残りビルド時に埋め込み、frontmatter は剥離して content とし metadata に保持（ドキュメントパイプラインの自動発見契約は不変）
- モジュールの skills.enable は 7 行のコンポジション行（skill-nixkits-<id> → @kihara777/dsh-skill-nixkits/<id>）を自動生成し、以前の誤実装だったディレクトリ注入（nixkits-skills パッケージ + bundledSkillDir）を置き換え
- 検証：7 プラグインの mock 登録、ベアサブパスインポート + 登録の実測がすべて通過
- CI に x86_64/aarch64 ビルドを追加
| コミット | 説明 |
|------|------|
| `7393b95` | feat(dsh): rewrite NixKits skills as native skill plugins — dsh-skill-nixkits package, one plugin entry per skill |

## 2026-08-20T05:27:48+09:00

**概要**：feat(dsh): 内蔵 bash ツールの NixOS 修正 + サードパーティプラグインパッケージ + デプロイメント同梱スキル

- モジュールが dsh サービスへ完全な NixOS PATH を注入（systemd 既定 PATH に bash が無く、内蔵 bash ツールが spawn bash ENOENT で失敗）
- dsh-nix-shell パッケージ新規（@kihara777/dsh-nix-shell、NixOS 対応シェルツールプラグイン：PATH 解決失敗時に Nix store の bash へフォールバック、NixOS PATH 注入、タイムアウトとスピル出力）と nixkits-skills パッケージ（スキルディレクトリバンドル）新規
- モジュールに plugins.packages（node_modules へ tar 展開注入 — シンボリックリンクは Node の realpath でプラグイン自身の store パスへ戻り peer 解決が壊れるため実展開 — とコンポジション行の自動生成）と skills.enable（skill-filesystem bundledSkillDir、rank 600）を追加
- CI に dsh-nix-shell の x86_64/aarch64 ビルドを追加
- エンドツーエンド検証：注入ツリー内で IMPORT-OK
| コミット | 説明 |
|------|------|
| `69eedd4` | feat(dsh): PATH fix + third-party plugin packages + bundled skills — L1/L2/L3/路径A |
| `55664ed` | docs: dsh-nix-shell package docs + dsh module options + README rows (4 languages) |

## 2026-08-19T20:39:47+09:00

**概要**：fix(ci): ci-summary バッジが failing に張り付く問題を修正

- jq パイプラインが workflow ごとのグループ化より先に failure をフィルタしていたため、過去の失敗が以降の成功を永久に覆い隠していた（codewhale riscv64 修正後もバッジが赤のまま）
- 先に workflow ごとの最新実行を取得してから failure を判定するよう修正し、バッジは passing に復帰
| コミット | 説明 |
|------|------|
| `d752c83` | fix(ci): ci-summary badge stuck on failing — latest-run check must precede failure filter |

## 2026-08-19T19:57:03+09:00

**概要**：fix(codewhale-src): riscv64 クロスビルド修正 — 4 段階の問題連鎖

- rquickjs-sys 0.12.2 に riscv64gc bindings が無く（build.rs 非 bindgen パスが対象ファイルを include）、上流の各 64bit リトルエンディアン向け bindings はバイト単位で同一のため postPatch で x86_64 版を物化済み vendor ディレクトリへ配置
- ホスト側の ring ビルドで cc-rs がホスト triple からクロスコンパイラへフォールバックし -m64 を付与 — buildPackages ツールチェーンを明示
- postInstall の裸 cargo build が --target を失いホストツールチェーンでリンク — cargoBuildHook と同様にターゲット triple を明示
- バイナリが -lgcc_s を動的リンクし autoPatchelfHook は hostPlatform 依存のみ走査 — クロス gcc の libgcc 出力を明示的に追加
- CI と同一コマンド（pkgsCross.riscv64.callPackage）でローカル検証済み。Build codewhale (riscv64) の 6 連続失敗を解消
| コミット | 説明 |
|------|------|
| `962ce6c` | fix(codewhale-src): riscv64 cross build — rquickjs bindings overlay, host cc-rs toolchain, postInstall --target, libgcc rpath |

## 2026-08-19T17:57:26+09:00

**概要**：AGENTS.md — 古い参照を修正し CI 章の記述を実態に合わせ更新

- 古い comfyui-strix-halo モジュール参照（comfyui-rocm に統合済み）を修正
- CI 章を実際のワークフロー構成（パッケージ別 build-<pkg>-<arch>.yml が共有 build-package.yml を呼び cachix-action で配信、riscv64 ビルドなしのパッケージと専用ビルドのない godot-ai/dsh を明記、ci-summary.yml バッジ機構）に合わせて更新
| コミット | 説明 |
|------|------|
| `c4e320e` | docs(AGENTS): fix stale comfyui-strix-halo reference + align CI description with actual workflows |

## 2026-08-19T16:52:54+09:00

**概要**：fix(module): dsh WebSocket 反代を mod_proxy upgrade に変更

- NixOS の lighttpd モジュールは allKnownModules 固定順で server.modules を生成し、mod_wstunnel は mod_proxy の後にロードされる。proxy.server が全パスにマッチするため mod_proxy が /api/events.* のアップグレードを先に処理して 426 を返し、mod_wstunnel は r->handler_module 非 NULL で実行されない
- lighttpd 1.4.56+ の mod_proxy ネイティブ WebSocket トンネル（proxy.header = "upgrade" => "enable"）に変更し、mod_wstunnel を削除
- 検証: 8625 / は 200、/api/events.host|mux ハンドシェイク 101（ローカル+LAN）
| コミット | 説明 |
|------|------|
| `51d9435` | fix(module): dsh WebSocket reverse proxy via mod_wstunnel |
| `33d5931` | fix(module): dsh wstunnel port as string (match lighttpd backend syntax) |
| `d7d2713` | fix(module): dsh WebSocket via mod_proxy upgrade (mod_wstunnel never runs) |

## 2026-08-19T13:10:00+09:00

**概要**：fix(pkgs): dsh 0.1.0-rc.6 → 0.1.0-rc.7 — 上流修正を含む版更新

- rc.6 は約 13 時間でクラッシュ（fatal load failure: Context has been disposed）—— cordis-plugin-timer の ctx.timeout() が Context の静的な dispose 時に reject し unhandled rejection 化
- rc.7（8/17）が最新、cordis/timer バージョンは不変（バグ残存の可能性）だが上流修正を含む
- プラグイン一覧不変（131）
| コミット | 説明 |
|------|------|
| `c75cb4c` | chore(pkgs): bump dsh 0.1.0-rc.6 → 0.1.0-rc.7 |

## 2026-08-18T20:00:00+09:00

**概要**：fix(module): dsh 通常ユーザー実行対応 — dshHome オプション追加

- 隔離システムユーザー（home /var/lib/dsh）では /home/<user>（700 権限）にアクセスできず、agent が作業ディレクトリを操作できなかった
- dshHome オプションを追加し、HOME/DSH_HOME/WorkingDirectory/preStart を統一ルート化、StateDirectory を preStart mkdir + chown に置換
- ローカル設定は user="kix" + dshHome="/home/kix/.dsh" で、dsh が kix として実行され /home/kix に到達
| コミット | 説明 |
|------|------|
| `584c764` | fix(module): dsh dshHome option + support normal-user operation |

## 2026-08-18T19:30:00+09:00

**概要**：feat(module): nixkits.dsh.settings — 宣言的設定

- dsh 設定メニュー項目は $DSH_HOME/settings.yaml（ファイルバックアップ、ホットリロード、namespace 別セクション）に格納
- settings オプション（attrsOf attrs、namespace → section）を追加し JSON（合法 YAML）として preStart で書き込み
- 実測：web-search-deepseek.maxTokens を既定 4096 → 8192 に宣言的オーバーライド
- 4言語ドキュメントに設定節を追加
| コミット | 説明 |
|------|------|
| `f2981e6` | feat(module): nixkits.dsh.settings — declarative settings |
| `dc64cbb` | docs(dsh): declarative settings section + maintenance log |

## 2026-08-18T18:45:00+09:00

**概要**：docs(dsh) + refactor(skill): プラグイン一覧同期

- docs/dsh.md 4言語に「プラグイン一覧」節（131 内蔵 entry id、id -> パッケージ）を追加、nixkits.dsh.plugins.disabled の参照に
- check-updates スキル第5ステップに dsh 特有説明を追加：更新時に新パッケージの dsh-*/cordis.patch.yml から一覧を抽出して docs に同期
| コミット | 説明 |
|------|------|
| `06d0e28` | docs(dsh): plugin inventory + check-updates skill sync |

## 2026-08-18T18:39:34+09:00

**概要**：fix(module): dsh preStart rm before cp — 444 読み取り専用ファイルの上書き修正

- preStart が生成するファイルは権限 444（読み取り専用）のため、サービスユーザーが cp で上書きできない。先に rm してから cp するよう修正
| コミット | 説明 |
|------|------|
| `f308ac7` | fix(module): dsh preStart rm before cp — service-user cannot overwrite 444 |

## 2026-08-18T18:20:00+09:00

**概要**：feat(module): nixkits.dsh.plugins — 宣言的プラグインオン/オフと設定

- dsh プラグインは cordis.patch.yml でランタイムホットリロード、モジュールに plugins.disabled（entry id）、plugins.settings（config 上書き）、plugins.extraPatch（MCP などの生フラグメント）を追加
- システム設定は MCP を extraPatch に移行、API key を kix.credentials に宣言化、session-telemetry-otel + session-stats を無効化例として設定
- 実測：cordis.patch.yml 正しく生成、absent-id 警告なし
| コミット | 説明 |
|------|------|
| `0e4fe58` | feat(module): nixkits.dsh.plugins — declarative plugin on/off + config |
| `164d515` | docs(dsh): declarative plugin management section + maintenance log |

## 2026-08-18T17:55:00+09:00

**概要**：fix(module): lighttpd が Host/Origin を loopback に書き換え — trustedHosts 方式を置換

- 書き換え後は dsh の isTrustedApiRequest が loopback を見て通過、per-deployment trustedHosts 不要、かつ LAN ホスト名/IP をバックエンドに漏洩しない
- Origin は Host と同時に書き換え必須（同一生成元チェック失敗を避けるため）
- 実測：trustedHosts 削除後も反代 API（harukax.lan / 192.168.31.241）が ok:true
| コミット | 説明 |
|------|------|
| `a33b414` | fix(module): rewrite Host/Origin to loopback in lighttpd reverse proxy |

## 2026-08-18T17:30:00+09:00

**概要**：fix(module): dsh trustedHosts オプション — リバースプロキシ経由で /api が全 403

- dsh は /api リクエストの Host header を検証するため、lighttpd 経由では Host が LAN ホスト名/IP となり拒否された
- nixkits.dsh.trustedHosts を追加（repeatable --trusted-host にマップ）
- システム設定で harukax.lan + 192.168.31.241 を信頼して API 復旧
| コミット | 説明 |
|------|------|
| `3755935` | fix(module): dsh trustedHosts option — Host-header 403 behind reverse proxy |

## 2026-08-18T16:20:05+09:00

**概要**：fix(dsh): ブラウザ側 client bundle パッチ — crypto.randomUUID fallback

- crypto.randomUUID() は非セキュアコンテキスト（LAN IP への HTTP、lighttpd リバースプロキシ経由）で使用不可のため webui がエラー
- postInstall で dsh-client-connection + dsh-client-ui-conversation の crypto.randomUUID を __dshUuid ヘルパー（crypto.getRandomValues にフォールバック、全コンテキストで利用可）に置換
| コミット | 説明 |
|------|------|
| `5d1cfa8` | fix(dsh): patch browser client bundles — crypto.randomUUID fallback |

## 2026-08-18T15:29:14+09:00

**概要**：fix/docs(dsh): lighttpd リバースプロキシ定稿

- dsh 内部 loopback ポート 8615（SearXNG の 42701 に合わせる）、lighttpd 対外ポート 8625（4270 に合わせる）
- ファイアウォールは lighttpd 対外ポートを開放（dsh 内部ポートでなく）
- 4 言語文書を最終案に同期
| コミット | 説明 |
|------|------|
| `4a78d54` | fix(module): dsh internal port 8615, public reverseProxy port 8625 |
| `5452a3e` | docs(dsh): sync service section to loopback 8615 + lighttpd reverseProxy 8625 |

## 2026-08-18T14:38:26+09:00

**概要**：feat(module): nixkits.dsh.reverseProxy（lighttpd）新規

- dsh は非 loopback host を拒否するため（RCE 安全）、lighttpd の `$SERVER["socket"]` ブロックで 0.0.0.0:8626 を dsh loopback 8625 にリバースプロキシ（SearXNG の lighttpd 実例を再利用、extraConfig は types.lines でマージ可）
- ファイアウォールで 8626 を開放
| コミット | 説明 |
|------|------|
| `12e11af` | feat(module): add nixkits.dsh.reverseProxy via lighttpd |

## 2026-08-18T10:29:46+09:00

**概要**：feat/fix(dsh): dsh サービスを配備し MCP + skills を設定。

- モジュール修正：dsh システムユーザーの HOME=/var/empty（読取専用）が EPERM を招くため、書込可能な /var/lib/dsh + StateDirectory に変更
- HMR サービスは --expose-internals を要するため、node --expose-internals で bin.js を直接起動
- MCP サービス（SearXNG + Godot）は cordis.patch.yml の `insert:` 構文で設定（id-targeted override ではない）
- skills は /var/lib/dsh/skills/ へ複製（.agent-presets サブディレクトリではない）
- nixkits-skills のディレクトリを ~/.dsh/skills に修正

| コミット | 説明 |
|------|------|
| `b17e5bf` | fix(module): dsh writable HOME + StateDirectory |
| `ed6983e` | fix(module): dsh launch via node --expose-internals (HMR requires execArgv) |
| `456c917` | feat(skill): nixkits-skills add dsh skills directory support |
| `ee24563` | fix(skill): correct dsh skills directory — ~/.dsh/skills |

## 2026-08-18T08:42:40+09:00

**概要**：docs: ruyi チャンネル版数を同期し三言語 README の ruyi 説明列を補完

- `ruyi` stable 0.50.0 → 0.51.0、beta/alpha の日付を同期
- en/ja/pcn README の ruyi 説明列は空 `<br><br>` だったが、RuyiSDK 説明 + 3 チャンネル版数を記入し zh と一致
| コミット | 説明 |
|------|------|
| `86ae30b` | docs: sync ruyi channel versions + fill empty ruyi descriptions in en/ja/pcn README |

## 2026-08-18T07:19:30+09:00

**概要**：監査修正 —— 版数更新とモジュール/overlay/文書/スキル修正。

- codewhale 0.9.8、mcp-searxng 1.15.0、opencode-telegram 0.24.0、obs-bilibili-stream 2.1.3 更新
- comfyui-rocm モジュールに services.comfyui assertion を復元し、nixpkgs-compat パッチ対象を明確化
- overlay codewhale はアーキテクチャ別にソースビルドへフォールバック（riscv64）
- 文書の版数、ruyi リンク、codewhale-sudo 説明を同期
- write-maintenance-log スキルに表ヘッダを追加し katalish 列を削除

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

**概要**：refactor: comfyui-rocm-patch + comfyui-strix-halo を単一 comfyui-rocm に統合

- 2 モジュールが ComfyUI ROCm サポートの異なる部分（パッチ層 vs Strix Halo ハードウェア最適化）を処理していたのを、nixkits.comfyui-rocm（enable オプション）に統合
- パッチマウント、GFX オーバーライド、xformers バイパス、C ツールチェーン、Strix Halo 設定（ROCm ランタイム/DeviceAllow/kernelParams）を網羅
- 文書と README を同期
| コミット | 説明 |
|------|------|
| `d473991` | refactor: merge comfyui-rocm-patch + comfyui-strix-halo into comfyui-rocm |

## 2026-08-15T09:23:15+09:00

**概要**：refactor: パッチファイル rog-control-center-fix.patch → rcc-fix.patch に改名、rcc-fix 統一命名の仕上げ

- パッチファイル rog-control-center-fix.patch → rcc-fix.patch
- overlays/rcc-fix.nix と 4言語 rcc-fix.md の参照を更新
| コミット | 説明 |
|------|------|
| `b350cfd` | refactor: rename rog-control-center-fix.patch to rcc-fix.patch |

## 2026-08-15T08:31:32+09:00

**概要**：deepseek-harness 0.1.0-rc.6 — 新規パッケージ（@deepseek-ai/dsh）

- プリビルト npm パッケージ、bin `dsh` → `lib/bin.js`；package-lock.json を同梱（npm tarball に lock なし）、dontNpmBuild で build をスキップ
- 4 言語文書を追加し godot-ai と dsh を README に掲載
| コミット | 説明 |
|------|------|
| `0194460` | feat(dsh): add deepseek-harness 0.1.0-rc.6 package + 4-language docs |

## 2026-08-15T08:07:33+09:00

**概要**：refactor: rog-control-center-fix を rcc-fix に統合

- 両者は同一の ROG Control Center 修正プロジェクト（overlay asusctl パッチ + module systemd デッドロック修正）、単一の rcc-fix に統一
- overlays/rog-control-center-fix.nix → rcc-fix.nix、modules/rog-control-center-fix.nix → rcc-fix.nix
- オプション nixkits.rog-control-center-fix → nixkits.rcc-fix
- 独立文書は削除（rcc-fix.md に統合）
| コミット | 説明 |
|------|------|
| `376eacf` | refactor: merge rog-control-center-fix into rcc-fix |

## 2026-08-13T01:20:29+09:00

**概要**：fix(default-overlay): godot-ai を fastmcp overlay 適用で構築

- default overlay の `final.callPackage` が fastmcp を nixpkgs 3.3.1（循環 import バグ）に解決
- (prev.extend (import ./fastmcp.nix)) へ変更し依存を 3.4.7 に解決
| コミット | 説明 |
|------|------|
| `94d49b5` | fix(default-overlay): build godot-ai with fastmcp overlay applied |

## 2026-08-12T10:05:00+09:00

**概要**：fix(default-overlay): godot-ai パッケージパス修正

- `overlays/default.nix` の `callPackage` は `../packages/`（overlay がサブディレクトリのため）
- `./packages/` では存在しない `overlays/packages/` に解決された
| コミット | 説明 |
|------|------|
| `0144283` | fix(default-overlay): correct godot-ai path — ./packages → ../packages |

## 2026-08-12T10:00:00+09:00

**概要**：fix(default-overlay): godot-ai を登録

- godot-ai は flake packages に存在するがデフォルト overlay から漏れており、下流（/etc/nixos）から pkgs.godot-ai として見えなかった
| コミット | 説明 |
|------|------|
| `093565c` | fix(default-overlay): register godot-ai so pkgs.godot-ai is available |

## 2026-08-12T09:18:26+09:00

**概要**：docs(godot-ai): 4 言語文書新規追加（72 行）

- アーキテクチャ図、依存表（fastmcp 3.4 含む）、システムインストール + MCP 設定 + 前提条件ガイド
| コミット | 説明 |
|------|------|
| `76c39c8` | docs(godot-ai): add 4-language documentation |

## 2026-08-12T07:07:27+09:00

**概要**：feat(godot-ai): godot-ai 3.1.5 パッケージ新規追加 + fastmcp 3.4.7 overlay

- godot-ai（hi-godot/godot-ai）は MCP クライアントを実行中 Godot エディタに接続する本格 MCP server（43 ツール / 120+ 操作）
- fastmcp を nixpkgs 3.3.1 → 3.4.7 へ（godot-ai が >=3.4.0 を要求、3.3.x に循環 import バグ）、fastmcp-slim + py-key-value-aio 0.4.5 も連動アップグレード
- devshell godot-mcp → godot-ai
| コミット | 説明 |
|------|------|
| `23a5b8d` | feat(godot-ai): add godot-ai 3.1.5 package + fastmcp 3.4.7 overlay |

## 2026-08-11T18:49:54+09:00

**概要**：fix(breeze-black): Edge/Chromium 用 純黒背景 + 純白前景

- sed 再マップ拡張：背景 #292c30 → #000000（ボタン/ツールバー/無効化）、前景 #fcfcfc/#a1a9b1 → #ffffff
- gtk-3.0/4.0 検証：15× #000000、14× #ffffff、灰色残りゼロ
| コミット | 説明 |
|------|------|
| `4e5c558` | fix(breeze-black): pure black bg + pure white fg for Edge/Chromium |

## 2026-08-11T18:41:14+09:00

**概要**：fix(breeze-black): 背景変数を真っ黒 #000000 にマップ

- Breeze-Dark の基本色は #202326（濃灰、純黒でない）
- CSS コピー後、主背景/base を #000000 に再マップ（ボタンは #292c30 を維持し区別を確保）
- gtk-dark.css は自己完結化（gtk.css のコピー）し灰色 import を廃止
| コミット | 説明 |
|------|------|
| `2ee1ba6` | fix(breeze-black): map background variables to true black #000000 |

## 2026-08-11T16:19:49+09:00

**概要**：fix(breeze-black): gtk.css 本体を Breeze-Dark のダーク配色で上書き

- Chromium 系（Edge/Chrome）は prefer-dark を無視して gtk.css を直接読み込む
- BreezeBlack（ライト Breeze からの改名）にライト変数（#eff0f1）が残り Edge がグレー表示
- gtk-{3,4}.0 の gtk.css(+.map) をダーク（#202326）に上書き
| コミット | 説明 |
|------|------|
| `25e23e0` | fix(breeze-black): overwrite gtk.css body with Breeze-Dark dark scheme |

## 2026-08-11T16:02:39+09:00

**概要**：fix(breeze-black): Breeze-Dark を保持

- BreezeBlack の gtk-dark.css が `@import ../../Breeze-Dark/...` で本物のダーク配色（#202326）を取得
- preFixup での削除で import が切れ GTK がライトにフォールバック（「黒くない」症状）
| コミット | 説明 |
|------|------|
| `0433eee` | fix(breeze-black): keep Breeze-Dark — gtk-dark.css imports it for dark mode |

## 2026-08-09T22:43:43+09:00

**概要**：refactor(skill): トラップ 4 追加

- 無引数 `nix flake lock` は全フローティング input を更新（nixpkgs ドリフト再発、8/7 nixpkgs で diffusers/httpx 失敗）
- --update-input または nixpkgs rev 固定を使用
| コミット | 説明 |
|------|------|
| `ec5e589` | refactor(skill): add trap 4 — bare nix flake lock refreshes floating inputs |

## 2026-08-09T19:40:21+09:00

**概要**：feat(patches): ローカル comfyui-nix ビルド修正をパッチファイルとして正式化

- ① mkWheel dontCheckRuntimeDeps（pythonRuntimeDepsCheckHook、nixpkgs ≥ 8/5）
- ② flaky スイート doInstallCheck=false（jupyter-server/scipy/fastapi/einops/mss/inline-snapshot）
- ③ torch/facexlib ランタイム依存スキップ
- モジュールコメント + 4 言語文書更新
| コミット | 説明 |
|------|------|
| `a8ad11e` | feat(patches): add comfyui-nix nixpkgs-compat patch + module doc |
| `faefa5b` | docs(comfyui-rocm-patch): document nixpkgs-compat patch (4 langs) |

## 2026-08-09T19:05:53+09:00

**概要**：refactor(skill): nixkits-check-updates に nixpkgs ドリフト故障診断セクション追加

- ① 旧 flake.lock 復元時は flake.nix の follows を要確認（喪失 → glibc 2.40 → GLIBC_ABI_GNU2_TLS）
- ② pytest パッケージは doInstallCheck=false（pytestCheckHook は installCheckPhase で実行）
- ③ pythonRuntimeDepsCheckHook（nixpkgs ≥ 8/5）が wheel 構築を破壊、dontCheckRuntimeDeps=true で修復
| コミット | 説明 |
|------|------|
| `e88fd98` | refactor(skill): add nixpkgs-drift troubleshooting section to check-updates |

## 2026-08-09T04:21:09+09:00

**概要**：fix(module): llama-cpp — extraFlags 非推奨と freeform settings 定義の修正

- `services.llama-cpp.extraFlags` は非推奨のため、`settings` で `--sleep-idle-seconds` を渡すよう変更
- freeform `settings` は分離定義不可のため、`lib.mkMerge` で `models-preset` と `sleep-idle-seconds` を統合
| コミット | 説明 |
|------|------|
| `8026d8e` | fix(module): replace deprecated services.llama-cpp.extraFlags with settings |
| `0ec7760` | fix(module): merge llama-cpp settings via mkMerge |

## 2026-08-08T23:07:40+09:00

**概要**：fix(breeze-black): look-and-feel グローバルテーマ復元と GTK リネーム修正

- 7/23 の外部パッチ除去後に 2 つのリグレッションが発生；`org.kde.breezeblack.desktop` グローバルテーマが欠落し BreezeBlack が設定のテーマ選択から消えたため、ローカル内蔵の look-and-feel パッケージで復元
- `preFixup` の Breeze* グロブが Breeze と Breeze-Dark の両方に一致し GTK テーマがネスト化したため、Breeze のみリネームするよう修正
| コミット | 説明 |
|------|------|
| `114b9c2` | fix(breeze-black): restore look-and-feel global theme + fix GTK rename |

## 2026-08-08T22:50:33+09:00

**概要**：fix(codewhale-src): 0.9.4 同期と source hash 修正

- `nix-prefetch-url` の archive tarball hash が `fetchFromGitHub`（git プロトコル）と不一致で riscv64 CI が連続失敗
- `fetchFromGitHub` ビルドで正しい hash を取得し Cargo.lock を同期
- 技能の誤った助言も併せて修正
| コミット | 説明 |
|------|------|
| `08b04a2` | fix(codewhale-src): sync to 0.9.4 with correct fetchFromGitHub hash |
| `ab2a624` | fix(skill): correct fetchFromGitHub hash advice — archive tarball trap |

## 2026-08-08T22:20:21+09:00

**概要**：codewhale 0.9.4、mcp-searxng 1.14.1、opencode-telegram 0.23.1 — 上流更新

- `codewhale` 0.9.3 → 0.9.4、上流バグ修正；`mcp-searxng` 1.14.0 → 1.14.1、上流メンテナンス；`opencode-telegram` 0.22.5 → 0.23.1、上流機能更新
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

**概要**：chore(pkgs) — codewhale-src を 0.9.3 に同期

- riscv64 ソースビルドがプレビルト版より 3 バージョン遅れていたため、`version`・`fetchFromGitHub` hash・Cargo.lock（711 → 763 エントリ）を同期
| コミット | 説明 |
|------|------|
| `563eea2` | chore(pkgs): sync codewhale-src to 0.9.3 — version, hash, Cargo.lock |

## 2026-08-05T01:30:00+09:00

**概要**：refactor(skill) — nixkits-check-updates に Rust パッケージ更新フローを追加

- Rust パッケージ（`buildRustPackage`）更新フローを追加し、codewhale-src の Cargo.lock 同期経験を汎化：`version` + source hash + Cargo.lock の三点同期、上流 lock 取得とエントリ数検証、クロスコンパイルタイムアウト時のフォールバック
| コミット | 説明 |
|------|------|
| `6e6bef6` | refactor(skill): add Rust package (buildRustPackage) update flow to nixkits-check-updates |

## 2026-08-04T02:15:00+09:00

**概要**：fix(ruyi): ruff lint 失敗を許容

- 2 番目の ruff check（`--fix` 無し）が nixpkgs ruff 更新後の 139 件の上流違反でビルドをブロックしていたため、checkPhase で許容するよう変更
| コミット | 説明 |
|------|------|
| `1175df2` | fix(ruyi): tolerate ruff lint failures in checkPhase |

## 2026-08-04T01:15:52+09:00

**概要**：codewhale 0.9.3、mcp-searxng 1.14.0 — 上流更新

- `codewhale` 0.9.1 → 0.9.3、上流バグ修正；`mcp-searxng` 1.12.1 → 1.14.0、上流機能更新
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

**概要**：fix(ci): ci-summary.yml 修正と shields.io endpoint badge への切替

- `ci-summary.yml` に YAML runs-on と workflow_dispatch の混在・固定 token などの構文エラーがあり、push/schedule 起動 + `GITHUB_TOKEN` に切替
- README badge を `check.yml`（flake 評価のみ）から shields.io endpoint（全 Build workflow の実状態を反映）に変更
| コミット | 説明 |
|------|------|
| `c0e52a5` | fix(ci): fix ci-summary.yml syntax, switch README badge to endpoint |

## 2026-07-31T03:34:15+09:00

**概要**：fix(ci): GITHUB_TOKEN を Nix access-token として注入

- `llama-cpp-ver` input が GitHub API 呼出を必要とし、未認証では 60 回/時間に制限され並列 CI で HTTP 403 が頻発するため、`${{ secrets.GITHUB_TOKEN }}` で認証するよう変更
| コミット | 説明 |
|------|------|
| `41a8a8b` | fix(ci): inject GITHUB_TOKEN as Nix access-token for llama-cpp-ver API |

## 2026-07-31T03:00:12+09:00

**概要**：fix(codewhale-src): riscv64 クロスコンパイル修正

- `ring` クレートの `cc` ビルドが汎用 CFLAGS の `-m64`（x86_64 フラグ）を継承し riscv64-gcc エラーが発生
- per-target の CFLAGS クリアに加え、汎用 CFLAGS/CXXFLAGS もクリア
| コミット | 説明 |
|------|------|
| `29c780a` | fix(codewhale-src): clear generic CFLAGS/CXXFLAGS for riscv64 cross-compile |

## 2026-07-30T17:56:11+09:00

**概要**：codewhale 0.9.1、mcp-searxng 1.12.1、opencode-telegram 0.22.5 — 上流更新

- `codewhale` 0.9.0 → 0.9.1、上流バグ修正；`mcp-searxng` 1.11.1 → 1.12.1、上流機能更新；`opencode-telegram` 0.22.3 → 0.22.5、上流メンテナンス
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

**概要**：fix(codewhale-sudo): ptrace wrapper 修正

- 子プロセス追跡を削除し、codewhale のサブシェルが SIGTRAP で kill されるのを防止
- `PTRACE_EVENT_EXEC` 処理を追加
- 4 言語ドキュメントを同期更新（LD_PRELOAD → ptrace 記述）
| コミット | 説明 |
|------|------|
| `c77cadc` | fix(codewhale-sudo): stop tracing child processes, handle PTRACE_EVENT_EXEC |
| `480658e` | docs(codewhale-sudo): update mechanism description LD_PRELOAD → ptrace |

## 2026-07-23T12:08:13+09:00

**概要**：fix(codewhale-sudo): LD_PRELOAD shim を ptrace システムコールインターセプターに置換

- codewhale は静的リンクのため LD_PRELOAD では `prctl(PR_SET_NO_NEW_PRIVS)` を捕捉できない
- `ptrace(2)` でカーネル境界にて捕捉する方式に変更、静的・動的バイナリ両対応
| コミット | 説明 |
|------|------|
| `6446364` | fix(codewhale-sudo): replace LD_PRELOAD shim with ptrace syscall interceptor |

## 2026-07-23T11:24:15+09:00

**概要**：fix(overlays): breeze-black — 無効化された fetchpatch URL を置換

- 元 URL の injx.sbs ドメインは永続的に利用不可
- 純粋なローカル colors ファイルインストールに変更
- KDE Plasma は share/color-schemes/ から配色を自動検出
| コミット | 説明 |
|------|------|
| `547d6a0` | fix(overlays): replace dead breeze-black fetchpatch with local copy |

## 2026-07-22T16:31:26+09:00

**概要**：fix(modules) — rog-control-center と comfyui-strix-halo の修正

- rog-control-center-fix に SendSIGKILL=yes + TimeoutStopSec=30s を追加、asus-shutdown の古いプロセス残留が systemd-switch を妨げる問題を解決
- comfyui-strix-halo に glibc >= 2.42 の assertion を追加（ROCm 7.2 は GLIBC_ABI_GNU2_TLS を必要とする）
| コミット | 説明 |
|------|------|
| `4c314e8` | fix(modules): fix asus-shutdown SendSIGKILL + comfyui glibc assertion |

## 2026-07-22T09:00:00+09:00

**概要**：feat(overlays) — 新規 overlay breeze-black を追加

- Plasma 6 に高コントラストの Breeze Black アクセシビリティテーマを提供（グローバルな look-and-feel + GTK + 配色スキーム）
- 4 言語ドキュメントを含む
| コミット | 説明 |
|------|------|
| `226c828` | feat(overlays): add breeze-black |

## 2026-07-22T05:39:31+09:00

**概要**：docs(devshell) — devShell ドキュメントを新規追加（4 言語）

- opencode（MCP フルスタック）と ruyi（三チャネル統合）の開発環境を記述
- README の devShell 表にドキュメントリンク列を追加
| コミット | 説明 |
|------|------|
| `7bfe3e3` | docs: add devShell documentation — 4 lang |
| `cbe9e72` | docs(README): add devShell doc column, merge ruyi 3 channels |

## 2026-07-22T03:40:50+09:00

**概要**：docs — リポジトリ全体でユーザーホームパスを `~/` プレフィックスへ統一

- ハードコードされた `/home/kix` および `/home/<user>` などの変体を置換
- 13 ファイルに及ぶ
| コミット | 説明 |
|------|------|
| `f597b9a` | docs: generalize hardcoded /home/kix paths |
| `bb65b77` | docs: unify all user home paths to ~/ prefix |

## 2026-07-22T03:14:27+09:00

**概要**：feat(shells) — opencode devShell の反復改良

- SearXNG + lighttpd（システムの NixOS 設定と一致）+ blender-mcp + godot-mcp + godot + opencode + opencode-telegram を追加
- 初回進入時に MCP 設定を自動登録
- godot パッケージの tryEval 保護を削除
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

**概要**：feat(overlays) — 新規 overlay efl-cross-fix を追加

- efl（Enlightenment Foundation Libraries）が riscv64/riscv64-musl/aarch64 のクロスコンパイル時に、ネイティブコード生成ツール（eolian_gen、eet）の欠如によるビルド失敗を修正
- 4 言語ドキュメントを含む
| コミット | 説明 |
|------|------|
| `7d1e0e4` | feat(overlays): add efl-cross-fix |

## 2026-07-21T10:28:31+09:00

**概要**：codewhale 0.9.0 + ruyi 0.51.0 系 + opencode-telegram 0.22.3 — 上流更新

- codewhale 0.9.0 + ruyi 0.51.0 + ruyi-beta 0.51.0-beta.20260714 + ruyi-alpha 0.52.0-alpha.20260714 + opencode-telegram 0.22.3
- codewhale v0.9.0 は依然 riscv64 のプリビルドバイナリがなく、ソースビルド経路を継続
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

**概要**：fix(ci) — ci-summary workflow の rate limit 失敗を修正

- 原因は `gh run list` をワークフロー毎に呼び出して rate limit（HTTP 403）に達し、メイン README の CI バッジが更新されなくなったこと
- 2 回の一括 `gh api` 呼出 + 並行制御に変更
| コミット | 説明 |
|------|------|
| `9f6a4ac` | fix(ci): fix ci-summary API rate limit — batch workflow fetch, add concurrency control |

## 2026-07-16T05:57:35+09:00

**概要**：revert(skill) — katalish（半角カタカナ機械翻訳）の全コンテンツを削除

- 19 文書、スキル（SKILL.md + dictionary.md 102 項目）、全言語切替リンク
- 翻訳が不安定（英文残留や文書構造破壊）なため本番環境に不適と判断
| コミット | 説明 |
|------|------|
| `6433bac` | revert: remove all katalish content — docs, skill, lang switchers, README entries |

## 2026-07-16T04:54:55+09:00

**概要**：docs(nixkits-skills) —「既知の削除」を「リスク警告」に改名

- 5 言語スキル文書を同期
| コミット | 説明 |
|------|------|
| `243cf8e` | docs(skill): add Known Removals section with verbatim rationale (5-lang) |

## 2026-07-16T04:46:54+09:00

**概要**：skill(nixkits-skills) — Claude Code 導入対象を削除し Codex 支援を追加

- Claude Code インストール対象を削除（ユーザーデータに基づく国籍推論がセキュリティ境界を越える）
- Codex サポートを追加
- SKILL.md に「リスク警告」節と原文声明を追加
| コミット | 説明 |
|------|------|
| `cfc59b3` | refactor(skill): replace Claude Code with Codex, add removal notice |
| `2f1272b` | docs(skill): use original verbatim text for Claude Code removal rationale |

## 2026-07-16T04:35:20+09:00

**概要**：skill(write-maintenance-log) — タイムスタンプ規則を強化

- `git log` によるコミット時刻の取得を強制、`T00:00:00` プレースホルダを禁止
- 生成後検証ステップを追加
- MAINTENANCE プレースホルダタイムスタンプ修正（`968df0e`）から汎化
| コミット | 説明 |
|------|------|
| `968df0e` | fix(docs): replace T00:00:00 placeholder timestamps with exact git commit times |
| `6f2e128` | refactor(skill): enforce tool-based timestamp, forbid T00:00:00 placeholder |

## 2026-07-16T04:30:55+09:00

**概要**：feat(ci) — CI サマリーエンドポイントバッジを追加

- メイン README の CI バッジを shields.io endpoint 経由で `gh-pages/ci-status.json` を読み取る方式に変更
- 失敗時に失敗パッケージ名を表示
| コミット | 説明 |
|------|------|
| `6465260` | feat(ci): add CI summary workflow with endpoint badge |
| `b489890` | docs(README): switch main CI badge to endpoint |

## 2026-07-16T04:09:46+09:00

**概要**：refactor(ci) — CI を単一 check.yml から独立 workflow ファイルに分割

- 単一 check.yml を 25 の独立 workflow ファイルに分割（パッケージ×アーキテクチャ毎）、バッジの相互影響を完全に解消
- 再利用可能な workflow `build-package.yml` を追加
| コミット | 説明 |
|------|------|
| `bc42e6f` | refactor(ci): split single check.yml into 25 isolated per-package-per-arch workflows |
| `1dfc1ee` | docs: update ruyi badge URLs to new isolated workflow files |
| `f235edc` | docs: embed version numbers in CI badge labels |

## 2026-07-16T04:00:46+09:00

**概要**：fix(codewhale) — ソースビルドの riscv64 クロスコンパイルを修正

- ソースビルドの riscv64 クロスコンパイルが失敗：ring crate が `-m64` エラー
- 原因は cc crate による host CFLAGS の継承
- per-target CFLAGS をクリアして修正
| コミット | 説明 |
|------|------|
| `ef64028` | docs(codewhale): add platform row + riscv64 source-build known-issues warning |
| `7160431` | fix(codewhale-src): clear per-target CFLAGS to fix ring/cc -m64 on riscv64 cross-compile |

## 2026-07-16T01:18:16+09:00

**概要**：codewhale 0.8.67 — デュアルパスビルド

- プリビルド x86_64/aarch64、ソースビルド riscv64
- 上流は v0.8.67 から riscv64 バイナリを削除
- riscv64 は rustPlatform.buildRustPackage でローカル Cargo.lock からビルド
| コミット | 説明 |
|------|------|
| `0025476` | feat(codewhale): dual-path build — prebuilt for x86_64/aarch64, source for riscv64 |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| codewhale | 0.8.66（プリビルド×3） | 0.8.67（プリビルド×2 + ソース riscv64） |

## 2026-07-15T08:32:13+09:00

**概要**：mcp-searxng 1.11.1、opencode-telegram 0.22.2 と obs-bilibili-stream 2.1.2 — アップストリーム更新

- mcp-searxng 1.11.1 + opencode-telegram 0.22.2 + obs-bilibili-stream 2.1.2 を上流版に同期
- codewhale はスキップ：v0.8.67 は依然 riscv64 バイナリなし
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

**概要**：revert(ci) — `llama-cpp-ver` を上流 API に復元

- `ci/` ディレクトリを削除、`llama-cpp-ver` input を上流 API（`ggml-org/llama.cpp` releases/latest）に復元
- overlay には `tryEval` + `prev.llama-cpp.version` フォールバックが既にあり、ローカルキャッシュは不要
| コミット | 説明 |
|------|------|
| `dbdd937` | revert: restore llama-cpp-ver to upstream API, remove ci/ |

## 2026-07-09T01:14:34+09:00

**概要**：obs-bilibili-stream 2.1.1、mcp-searxng 1.11.0 と opencode-telegram 0.22.1 — アップストリーム更新

- obs-bilibili-stream 2.1.1 + mcp-searxng 1.11.0 + opencode-telegram 0.22.1 を上流版に同期
- codewhale はスキップ：v0.8.67 に riscv64 バイナリなし
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

**概要**：fix(docs): katalish/pcn ローカライズ修正

- katalish/ruyi.md と pcn/ruyi.md の言語切替を修正（リンク欠落・言語名重複）
- pcn/ruyi.md は日本語から偽中国語へ全文書換
| コミット | 説明 |
|------|------|
| `cddf0ff` | docs(blender-mcp): add platform row noting riscv64 unsupported (5-lang sync) |
| `cec92d5` | fix(docs): repair katalish/pcn localization — broken lang switchers, JP residue, missing translation |

## 2026-07-05T04:41:23+09:00

**概要**：fix(ci): blender-mcp を riscv64-cross から除外

- 上流 nixpkgs の `sse-starlette` クロスコンパイル欠陥によりビルド失敗
- `blender` も riscv64 非対応
- x86_64 / aarch64 は影響なし
| コミット | 説明 |
|------|------|
| `78afb9e` | fix(ci): pass blender=null for blender-mcp riscv64-cross (Blender unsupported on riscv64) |
| `cd839d1` | fix(ci): remove stray Nix indented-string marker from riscv64-cross expr |
| `7d87ff2` | fix(ci): avoid bash ${} nesting issue — use simple vars, default-first pattern |
| `63c7d9f` | fix(ci): remove blender-mcp from riscv64-cross (mcp→sse-starlette dep fails on riscv64) |

## 2026-07-04T06:41:28+09:00

**概要**：blender-mcp 1.0.0 — Blender MCP Server パッケージを新規追加

- Python ビルド、22 の MCP ツール
- Blender add-on の付属ファイルを含む
| コミット | 説明 |
|------|------|
| `a1cf458` | packages: add blender-mcp (MCP server for Blender) |
| `ab9109a` | packages: add blender-mcp (MCP server for Blender) |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| blender-mcp | — | 1.0.0 |

## 2026-07-02T04:00:00+09:00

**概要**：codewhale 0.8.66 — アップストリーム更新

- TUI レイアウト修正
- 承認の誠実さラベル
- パフォーマンス修正 若干
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

**概要**：opencode-telegram 0.22.0 — アップストリーム更新

- 3モード TTS を追加
- thinking 表示を追加
- コンパクト出力を追加
- `/settings` コマンドを追加
- セッション起動を修正
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

**概要**：CI / docs — llama-cpp-ver のローカルファイル化と riscv64 バッジのパッケージ別化

- CI：llama-cpp-ver をローカルファイル（`ci/llama-cpp-ver.json`）に変更
- 全 CI ジョブから GitHub API 呼出を排除し、rate limit による全ビルド失敗を恒久修正
- docs：riscv64 バッジをパッケージ別に精密化（codewhale/kitsfmt/mcp-searxng/opencode-telegram）
| コミット | 説明 |
|------|------|
| `8b3a3be` | fix(ci): use local path for llama-cpp-ver input, eliminate GitHub API calls from all CI jobs |
| `5db4852` | fix(docs): add per-package job filter to riscv64 badges |

## 2026-06-26T12:30:00+09:00

**概要**：feat(opencode-telegram): サービス PATH 注入オプションを 2 つ追加

- `extraPackages` オプションを追加（システムパッケージをサービス PATH に注入）
- `extraBinPaths` オプションを追加（home-manager パスをサービス PATH に注入）
- opencode がサービス PATH で見つからない問題を解決
- 5 言語ドキュメントを更新
| コミット | 説明 |
|------|------|
| `7c98694` | feat(opencode-telegram): add extraPackages option to inject companion tools into service PATH |
| `45b7c57` | feat(opencode-telegram): add extraBinPaths option for home-manager users |

## 2026-06-26T10:55:41+09:00

**概要**：codewhale 0.8.65 と mcp-searxng 1.8.0 — アップストリーム更新

- codewhale：cli バイナリ名を変更 `codewhale-cli-linux` → `codewhale-linux`
- mcp-searxng：マルチインスタンスフェイルオーバー/並列ファンアウト
- mcp-searxng：能力発見の集約
- mcp-searxng：safesearch 修正
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

## 2026-06-26T07:18:56+09:00

**概要**：fix(skill): write-maintenance-log 第4ステップ「多言語同期」を空のスタブから実行可能なフローに書き直し、AGENTS.md の検証を強化

- 第4ステップは5行のスタブで、現在は実行可能なフロー：4a 言語発見 → 4b 言語別翻訳書込 → 4c エントリ数一致検証
- AGENTS.md 第4ステップの検証チェックを強化
| コミット | 説明 |
|------|------|
| `66f29f0` | fix(skill): rewrite MAINTENANCE step 4 — multi-lang sync from stub to executable flow with verification gate |

## 2026-06-26T06:19:21+09:00

**概要**：監査修正 — 空の scripts/ と .gitignore の死んだルールを削除、SKILL.md 制約を定性的記述に変更

- 空の scripts/ ディレクトリと translate_pcn.py 向けの .gitignore 死ルールを削除
- AGENTS.md の SKILL.md 制約をハードな行数目標から定性的ガイダンスに変更
| コミット | 説明 |
|------|------|
| `c49977e` | chore: remove stale .gitignore rule for deleted pcn_convert.py |
| `b7bc884` | docs(AGENTS): replace SKILL.md hard line-count target with qualitative guidance |

## 2026-06-25T11:02:38+09:00

**概要**：ruyi / CI / docs — クロスコンパイル修正、riscv64-cross 復帰、正確な job filter 復元

- postPatch に python.pythonOnBuildForHost を使用
- CI で ruyi 系列を riscv64-cross に復帰
- riscv64 バッジの正確な job filter を復元
| コミット | 説明 |
|------|------|
| `3a404af` | feat(ci): restore ruyi/ruyi-beta/ruyi-alpha to riscv64-cross |
| `4458922` | fix(ruyi): use python.pythonOnBuildForHost in postPatch for cross-compilation |
| `b1837c1` | docs(ruyi): restore precise riscv64 job filters — cross-compilation now fixed |

## 2026-06-25T10:12:02+09:00

**概要**：CI / docs — ruyi 系列を riscv64-cross から恒久除去、バッジを * マークと注記に復帰

- riscv64-cross から ruyi 系列を恒久的に除去（Python postPatch のクロスコンパイルは不可）
- riscv64 バッジを * マーク＋説明注記に復帰
| コミット | 説明 |
|------|------|
| `313c29c` | docs(ruyi): revert riscv64 badges to fallback with * marker + explanatory note |
| `062a714` | fix(ci): remove ruyi* from riscv64-cross (Python postPatch cross-compile impossible) |

## 2026-06-25T10:04:30+09:00

**概要**：CI — access-tokens 上書きによる API レート制限を修正、riscv64-cross の並列上限を設定

- access-tokens の上書きで GitHub API レート制限を超過（双行を1行に統合）
- riscv64-cross の並列上限を 4 に設定
| コミット | 説明 |
|------|------|
| `5858c97` | fix(ci): merge access-tokens into one line, cap riscv64-cross concurrency at 4 |

## 2026-06-25T09:44:44+09:00

**概要**：CI / docs — ruyi 系列を riscv64-cross に復帰、バッジラベル簡略化と job 精密フィルター

- riscv64-cross に ruyi/ruyi-beta/ruyi-alpha を復帰（パスマッピング）
- バッジラベルを簡略化（`--` の代わりに `-`）
- riscv64 job の精密フィルター
| コミット | 説明 |
|------|------|
| `68921ce` | docs(ruyi): shorten badge labels, add precise riscv64 job filters |
| `6dae52b` | feat(ci): add ruyi/ruyi-beta/ruyi-alpha back to riscv64-cross with subdir path mapping |

## 2026-06-25T09:29:43+09:00

**概要**：CI / docs — build / riscv64-cross をパッケージ別 matrix に分割、ruyi バッジを 9 枚に拡張

- build / riscv64-cross job をパッケージ単位の matrix に分割、独立した per-package バッジに対応
- ruyi ドキュメントのバッジを 3バージョン×3アーキテクチャ = 9枚に拡張
| コミット | 説明 |
|------|------|
| `3a19da9` | refactor(ci): split build and riscv64-cross jobs into per-package matrix |
| `7852f83` | docs(ruyi): expand build badges to 3×3 matrix (3 versions × 3 archs, 5 langs) |

## 2026-06-25T09:24:43+09:00

**概要**：CI / docs — build job に ruyi-beta / ruyi-alpha のビルドを追加、文書にチャンネル版番号を補完

- build job に ruyi-beta / ruyi-alpha のビルドステップを追加
- ruyi 基本情報テーブルのチャンネル行に beta/alpha バージョン番号を追加
| コミット | 説明 |
|------|------|
| `c92615e` | feat(ci): build ruyi-beta and ruyi-alpha alongside stable in build job |
| `bf93859` | docs(ruyi): add beta/alpha version numbers to Basic Info channel row (5 langs) |

## 2026-06-25T09:09:26+09:00

**概要**：CI / overlays / docs — ruyi 3チャンネル統合と riscv64-cross 調整

- CI で ruyi を riscv64-cross から除外
- default overlay に ruyi-beta/ruyi-alpha を追加、nixConfig を flake トップレベルに移行
- README のソフトウェア表に ruyi 3チャンネルのバージョン番号を表示
| コミット | 説明 |
|------|------|
| `17af888` | fix(ci): exclude ruyi from riscv64-cross (Python+C-ext deps too heavy) |
| `3f711d4` | feat(overlays): add ruyi-beta/ruyi-alpha to default overlay; lift nixConfig to flake top-level |
| `e2b759d` | docs: show ruyi stable/beta/alpha versions in README tables (5 langs) |

## 2026-06-25T05:35:00+09:00

**概要**：docs — 全5言語 README に ruyi-beta / ruyi-alpha の devShell 項目を追加

- 全5言語 README の devShell テーブルに ruyi-beta / ruyi-alpha 項目を追加
| コミット | 説明 |
|------|------|
| `5d4ca02` | docs: add ruyi-beta + ruyi-alpha to devShell tables (all 5 READMEs) |

## 2026-06-25T05:28:12+09:00

**概要**：ruyi — パッケージディレクトリ構造を再編、beta/alpha を thin wrapper 化し devShells を追加

- パッケージを packages/ruyi/ のディレクトリ構造に再編
- beta/alpha を thin wrapper 化
- devShells を追加
| コミット | 説明 |
|------|------|
| `4b9865e` | refactor(pkgs): move ruyi into subdirectory, beta/alpha as thin wrappers |
| `94bb174` | feat(shells): add ruyi-beta + ruyi-alpha devShells |

## 2026-06-25T05:13:34+09:00

**概要**：ruyi — バージョンチャンネルを独立パッケージ化、独立 overlay を削除

- バージョンチャンネルを独立パッケージ化（ruyi / ruyi-beta / ruyi-alpha）
- 独立 overlay を削除
| コミット | 説明 |
|------|------|
| `51f23ad` | refactor(pkgs): ruyi channels as separate packages (not overlays) |

## 2026-06-25T04:58:36+09:00

**概要**：ruyi — 3チャンネルのバージョン体系を導入、ベースパッケージを 0.50.0 に切替

- 3チャンネルのバージョン体系（stable/beta/alpha）
- ベースパッケージを 0.50.0 安定版に切替
- beta/alpha は overlay で上書き
| コミット | 説明 |
|------|------|
| `a9f8baa` | feat(pkgs): ruyi 3-channel (stable/beta/alpha) via overlays |

| パッケージ | 旧 | 新 |
|--------|--------|--------|
| ruyi | 0.51.0-alpha.20260616 | 0.50.0（安定版） |
| 　 | 新規 ruyi-beta overlay | 0.50.0-beta.20260623 |
| 　 | 新規 ruyi-alpha overlay | 0.51.0-alpha.20260616 |

## 2026-06-24T03:19:30+09:00

**概要**：workflow — メンテナンスログ更新ルールを必須化

- AGENTS.md と write-maintenance-log スキルでメンテナンスログ更新を必須化
| コミット | 説明 |
|------|------|
| `2e719df` | fix: make maintenance log update mandatory after every push |

## 2026-06-24T03:15:37+09:00

**概要**：docs — 古い riscv64 ビルド手順を削除

- 古い手動 riscv64 ビルド手順を削除
- CI が 3 アーキテクチャをカバー済み
| コミット | 説明 |
|------|------|
| `698400a` | docs: remove stale manual riscv64 build instructions — CI now covers all 3 architectures |

## 2026-06-24T03:06:20+09:00

**概要**：codewhale 0.8.64 — アップストリーム更新

- アップストリーム更新、0.8.64 へ引き上げ
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

**概要**：CI — riscv64 クロスコンパイル pipeline、3 アーキテクチャ全量カバー

- riscv64 クロスコンパイル pipeline を追加、CI が x86_64 / aarch64 / riscv64 の 3 アーキテクチャを全量カバー
- パッケージ毎の文書に riscv64 バッジを追加
| コミット | 説明 |
|------|------|
| `ac3b337` | feat(ci): add riscv64 cross-compilation job via pkgsCross |
| `0ab7a5e` | fix(ci): use direct $pkg variable in nix expr (remove heredoc) |
| `39ae218` | fix(ci): exclude obs-bilibili-stream from riscv64 cross-compile (OBS unsupported) |
| `cf05bd2` | feat(docs): add riscv64 CI badges to all 30 docs, update templates |

## 2026-06-23T05:20:00+09:00

**概要**：translate-pseudocn — 辞書拡充と言語順の変更

- Web リサーチに基づき辞書を拡充（7→46 エントリ）
- SVO 語順に変更
- 全 pcn ドキュメントを再生成
| コミット | 説明 |
|------|------|
| `4fbf387` | feat(pcn): expand dictionary 7→46 entries, add IT terminology from research |
| `ec38b7e` | feat(pcn): convert to SVO word order, expand dictionary, regenerate all 22 docs |

## 2026-06-23T04:19:16+09:00

**概要**：translate-pseudocn スキル再構築 — 疑似中国語の再定義

- 疑似中国語を「日本語から仮名を剥がした視覚結果」と再定義、中国語への変換を廃止
- 日本語漢字をそのまま保持（簡体字化しない）、SOV 語順を維持
- 辞書を 40→7 エントリに縮小（カタカナ→日本語漢字のみ）、全 22 件の pcn ドキュメントを再生成
| コミット | 説明 |
|------|------|
| `be0780b` | refactor(pcn): redesign pseudo-Chinese skill — Japanese-native kanji, SOV order, no Chinese chars |

## 2026-06-23T04:04:32+09:00

**概要**：AGENTS.md — ハードコード除去、言語体系を自動検出へ

- ハードコードの除去
- 冗長な監査メモの削除
- キャッシュ節をエージェント操作ガイドへ書き直し
- ユーザー側の記述を削除
- 言語体系を自動検出へ変更
| コミット | 説明 |
|------|------|
| `771cd1c` | docs(AGENTS): remove hardcoded counts, merge audit memo, rewrite cache as actionable guide, use auto-discovered languages only |
| `c7b8662` | docs(AGENTS): remove user-facing subsection, rename to 缓存操作 |
| `44f3667` | docs(AGENTS): remove redundant cache section, merge into single 二进制缓存 |

## 2026-06-22T23:49:00+09:00

**概要**：mcp-searxng 1.7.2 — 上流の修正

- 上流の修正、1.7.2 へ引き上げ
| コミット | 説明 |
|------|------|
| `93a8714` | chore(pkgs): bump mcp-searxng 1.7.2 |

|--------|--------|--------|
| mcp-searxng | 1.7.1 | 1.7.2 |
| 　 | source hash | `sha256-Mi8+Uk+WF7O4L3TAxsed3K3LhQlnVZ6e+VGsdwoRulg=` → `sha256-6N1YFMMgrEfGJaVYw4dffIGR58Nq0Ji4Q9epTmiKDBs=` |
| 　 | npmDepsHash | `sha256-/d/AJ1z9zJRYeSAMKS3MkS6F61foY+uro4Cr1ik64Lg=` → `sha256-ZKhLPdW/GWpp4OyJss8G6sgr7xFaVdyJ73LzZ5RMu+Q=` |

## 2026-06-22T23:22:00+09:00

**概要**：AGENTS.md — 初回起動監査規則とアクセス制御の移動

- 初回起動監査規則を新規追加
- アクセス制御を冒頭へ移動
| コミット | 説明 |
|------|------|
| `135d347` | docs(AGENTS): add new-session audit rule |
| `5192e2c` | docs(AGENTS): move new-session audit rule after access control |

## 2026-06-22T07:20:50+09:00

**概要**：docs — README 重複行の修正とスキルのアンチパターン追加

- README の `提供 nix develop` 重複行を修正
- write-project-docs スキルに「挿入前に重複内容を確認」アンチパターンを追加
| コミット | 説明 |
|------|------|
| `091290b` | fix(docs): remove duplicate "提供 nix develop" line in README.md |
| `922b1d8` | fix(skill): add anti-pattern — check for duplicate content before insert |

## 2026-06-22T06:41:50+09:00

**概要**：AGENTS.md — アクセス制御とプロセス規則を整備

- アクセス制御の規則を新設
- 言語要件を新設
- コミット規範とメンテナンス記録の確認を新設
- 文書同期と汎化の規則を新設
- 多アーキテクチャキャッシュの規則を新設
| コミット | 説明 |
|------|------|
| `ac6081c` | docs(AGENTS): add access control, language req, commit discipline, maintenance check, doc sync, generalization, multi-arch cache rules |

## 2026-06-22T06:21:11+09:00

**概要**：docs — 全パッケージ文書に双アーキテクチャ CI バッジ、スキルテンプレート同期

- 全 30 件のパッケージ文書に双アーキテクチャ CI バッジを追加
- 双アーキテクチャのバッジを別行に分割
- CI バッジと言語切替の間に空行を補う
- スキルテンプレートを「1 バッジ 1 行 + 空行間隔」に同期
| コミット | 説明 |
|------|------|
| `8e50035` | feat(docs): add per-package dual-arch CI badges to all 30 docs |
| `d3b3827` | fix(docs): split dual-arch badges to separate lines |
| `6b8a283` | fix(docs): add blank line between CI badges and language switcher |
| `0751500` | docs(skill): update CI badge template — one per line + blank gap |

## 2026-06-22T06:05:49+09:00

**概要**：CI — ARM runner と flake.lock 競合の修正

- ARM runner の多アーキテクチャビルドを追加
- flake.lock の並行競合を修正（`--no-write-lock-file`）
| コミット | 説明 |
|------|------|
| `97f2ea4` | docs: compress cache sections, add ARM CI runner, update AGENTS.md |
| `6d581ac` | fix(ci): fix YAML syntax - merge duplicate strategy keys, add runs-on |
| `126cf2c` | fix(ci): add GitHub token for llama-cpp-ver API access |
| `0022f50` | fix(ci): add --no-write-lock-file to prevent llama-cpp-ver fetch race |

## 2026-06-22T05:48:23+09:00

**概要**：mcp-searxng と ruyi — ハッシュ更新と overlay の復帰

- mcp-searxng：source hash + npmDepsHash を更新（GitHub archive の変化）
- ruyi：overlay postPatch を元に戻し（パッチファイル依存）
| コミット | 説明 |
|------|------|
| `89f5441` | fix(pkgs): update mcp-searxng source hash + npmDepsHash |
| `303b1fa` | fix(pkgs): update mcp-searxng hash, restore ruyi overlay postPatch |

## 2026-06-22T05:39:33+09:00

**概要**：docs — キャッシュ除外警告と nixConfig 自動宣言

- キャッシュ除外の警告を追加（overlay とモジュール+パッチの項目）
- README のキャッシュ説明を圧縮
- flake.nix に nixConfig の自動宣言を追加
| コミット | 説明 |
|------|------|
| `6be660e` | fix: add nixConfig auto-discovery, remove hardcoded package count, clarify arch support |
| `b28c126` | docs: add cache-exclusion warnings for overlays and module+patch entries |

## 2026-06-22T05:27:50+09:00

**概要**：docs — 全 30 篇のパッケージ文書の節追加、CI バッジのレイアウト、スキルの同期

- 全 30 篇のパッケージ文書に `## 缓存` 節を追加
- CI バッジのレイアウトを改善
- スキルを同期
| コミット | 説明 |
|------|------|
| `7071893` | docs: improve CI badge layout, add cache config options, update skills |
| `02b355c` | docs: add binary cache section to all 30 package docs + template sync |

## 2026-06-22T05:13:45+09:00

**概要**：CI/CD — ビルドマトリクス、バイナリキャッシュ、AGENTS.md を追加

- GitHub Actions のビルドマトリクス（Cachix への push）を追加
- バイナリキャッシュを追加
- AGENTS.md を追加
| コミット | 説明 |
|------|------|
| `6956af1` | feat: add CI/CD workflow, binary cache, and AGENTS.md |

## 2026-06-22T05:13:40+09:00

**概要**：skills — 辞書とテンプレートを分割、SKILL.md を圧縮

- translate-katalish / translate-pseudocn / write-project-docs で辞書とテンプレートを分割
- SKILL.md を 60-80 行に圧縮
| コミット | 説明 |
|------|------|
| `5367452` | refactor(skills): split dictionaries, compress SKILL.md to ~60-80 lines |

## 2026-06-22T05:13:36+09:00

**概要**：docs — MAINTENANCE のタイムスタンプと重複排除の整理、nix-kits→nixkits の全量置換

- MAINTENANCE のタイムスタンプを精密化（29 節）
- 30 個の重複節を削除（SHA による重複排除）
- nix-kits→nixkits を全量置換（183 箇所）
- モジュール文書を同期
| コミット | 説明 |
|------|------|
| `61cc470` | docs: fix MAINTENANCE timestamps, dedup 30 sections, rename nix-kits→nixkits |

## 2026-06-22T05:13:31+09:00

**概要**：patches — ruyi-nixos-compat.patch をクリーンなクローンから再構築

- ruyi-nixos-compat.patch をクリーンなクローンから再構築（1223→426 行）
- flake.lock の自己参照 artifact を除去
| コミット | 説明 |
|------|------|
| `1be2e84` | fix(patches): rebuild ruyi-nixos-compat.patch from clean clone (1223→426 lines) |

## 2026-06-22T05:13:26+09:00

**概要**：overlays — patches の重複排除、ruyi-nixos-compat の簡素化、llama-cpp-rocm へのコメント

- patches リストを lib.unique で重複排除
- ruyi-nixos-compat を簡素化
- llama-cpp-rocm に curried 形式のコメントを追加
| コミット | 説明 |
|------|------|
| `81bb2ef` | fix(overlays): lib.unique dedup on patches, simplify ruyi-nixos-compat, add llama-cpp-rocm comment |

## 2026-06-22T05:13:22+09:00

**概要**：modules — enable オプション、assertions、nixkits.* ネームスペースの統一

- 4 モジュールに enable オプションを追加
- comfyui-strix-halo に assertions を追加
- ネームスペースを nixkits.* に統一（後方互換を含む）
- llama-cpp-rocm の hfCacheDir を動的導出
| コミット | 説明 |
|------|------|
| `d21db2a` | refactor(modules): add enable options, assertions, migrate to nixkits.* namespace |

## 2026-06-22T05:13:16+09:00

**概要**：codewhale 0.8.63 と ruyi — マルチアーキテクチャバイナリ、postPatch 統合、meta 補完

- codewhale 0.8.63 — マルチアーキテクチャのプリビルドバイナリ（x86_64 / aarch64 / riscv64）
- ruyi — overlay の postPatch をパッケージへ統合
- meta フィールドを補完
| コミット | 説明 |
|------|------|
| `c9e7fc5` | feat(pkgs): codewhale multi-arch + 0.8.63, meta fixes, ruyi postPatch merge |

## 2026-06-22T05:13:11+09:00

**概要**：flake — mihomo-alpha のゴースト入力と overlay を削除

- mihomo-alpha のゴースト入力と overlay を削除（ファイルは一度も存在しなかった）
| コミット | 説明 |
|------|------|
| `26ce2be` | fix(flake): remove mihomo-alpha ghost input and overlay |

## 2026-06-21T04:32:31+09:00

**概要**：言語切り替え器のラベル規則を汎化 — display_name の意味修正と残存名の修正

- display_name の意味を言語の自称に修正
- 言語名をローカライズしない規則を write-project-docs / translate-katalish / translate-pseudocn の三技能に追加
- zh/katalish/pcn の全ドキュメントの切り替え器に残っていたローカライズ名を修正
| コミット | 説明 |
|------|------|
| `f5aee43` | docs(skill): write-project-docs — 添加语言名称不本地化规则 |
| `7ba8c1d` | fix(katalish): 语言切换器中 English 不应本地化为片假名 |
| `5ce9f7d` | fix: display_name 语义修正 — 语言自称与切换器标签分离 |
| `aa8634b` | fix(docs): zh 文档切换器残留旧名称修正 + MAINTENANCE 翻译补全 + translate-* 技能泛化 |

## 2026-06-21T00:07:44+09:00

**概要**：codewhale 0.8.62 と mcp-searxng 1.7.1 — 上流修正

- codewhale 0.8.62 — 上流修正
- mcp-searxng 1.7.1 — 上流修正
| コミット | 説明 |
|------|------|
| `57f6a4a` | chore(pkgs): bump codewhale 0.8.62, mcp-searxng 1.7.1 |

|--------|--------|--------|
| codewhale | 0.8.61 | 0.8.62 |
| mcp-searxng | 1.6.0 | 1.7.1 |
| 　 | cli hash | `sha256-3k0K/I/Nx...` → `sha256-ci3MokGW...` |

## 2026-06-20T18:36:33+09:00

**概要**：スキル体系の再構成 — スキル改名と言語拡張の自動発見

- translate-katakana→translate-katalish へ改名
- translate-pseudocn（偽中国語）を新設
- write-project-docs と write-maintenance-log の言語拡張自動発見
- docs-as-code の五言語マッピング表
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

**概要**：codewhale 0.8.61 と mcp-searxng 1.6.0 — 上流修正

- codewhale 0.8.61 — 上流修正
- mcp-searxng 1.6.0 — 上流修正
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

**概要**：ruyi — NixOS 互換パッチ

- NixOS 互換パッチ（`patches/ruyi-nixos-compat.patch`）
- プリビルド RISC-V ツールチェーンの動的リンカのパスを透過的に処理
- GCC 子プロセスの ELF interpreter 修正
- console_scripts argv0 問題
| コミット | 説明 |
|------|------|
| `d814550` | feat(ruyi): add autoUpdate and declarative venvs to module |

## 2026-06-17T10:59:35+09:00

**概要**：ruyi — NixOS モジュール（`services.ruyi`）

- 宣言的に `/etc/xdg/ruyi/config.toml` と環境変数を生成
| コミット | 説明 |
|------|------|
| `5cea307` | feat(ruyi): add NixOS module for declarative configuration |
| `ef377e4` | fix(ruyi): correct config path to /etc/xdg/ruyi (XDG spec) |
| `8059526` | fix(ruyi): replace lib.generators.toToml with manual generation |
| `cc396f8` | fix(ruyi): always generate config.toml when module enabled |

## 2026-06-17T10:03:05+09:00

**概要**：ruyi — devShell サポートを追加

- `nix develop github:Kihara777/NixKits#ruyi` で環境に入れます
| コミット | 説明 |
|------|------|
| `975295d` | refactor(flake): remove default package alias |

## 2026-06-17T09:48:33+09:00

**概要**：ruyi 0.51.0-alpha.20260616 — 新規パッケージ（RuyiSDK パッケージマネージャ）

- Python / Poetry で構築
- ruff + mypy + 320 の単体テスト + 52 の統合テストが全て通過
| コミット | 説明 |
|------|------|
| `622a5e2` | feat(pkg): add ruyi — RuyiSDK package manager |

| 软件名 | 新版本 |
|--------|--------|
| ruyi | 0.51.0-alpha.20260616 |

## 2026-06-17T07:37:39+09:00

**概要**：write-maintenance-log スキル — 独立スキル化と flake.lock 同期の検査

- nixkits-check-updates から独立スキルとして切り出し、二重エントリポイント設計（維護記録を記入 + 維護記録を更新）
- flake.lock 同期の .gitignore 事前チェックと三路分岐ロジック
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

**概要**：fix(mcp-searxng): エントリーファイルの誤りを修正

- エントリーファイル dist/index.js → dist/cli.js
- MCP サーバが正常に起動可能に
| コミット | 説明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |

## 2026-06-17T06:46:13+09:00

**概要**：llama-cpp-rocm — builtins.fetchurl で flake input を置き換えてバージョンを動的取得する試み

- 既に巻き戻し済み、この方法は使用不可
| コミット | 説明 |
|------|------|
| `9e94305` | refactor(llama-cpp-rocm): replace flake input with builtins.fetchurl |
| `b3d9c05` | fix(llama-cpp-rocm): use bare builtins.fetchurl without hash param |

## 2026-06-16T06:03:24+09:00

**概要**：mcp-searxng 文書 — CodeWhale の MCP 設定ガイド、よくある落とし穴の警告とトラブルシューティングの節

- CodeWhale の MCP 設定ガイド
- よくある落とし穴の警告（env の既定は {}）
- トラブルシューティングの節
| コミット | 説明 |
|------|------|
| `d670e1e` | docs(mcp-searxng): add CodeWhale config, common pitfall, and troubleshooting |

## 2026-06-16T05:20:34+09:00

**概要**：nixos-modern-cli スキル — Nix Store パスの落とし穴の節

- gh auth setup-git のハードコードパスが失効する問題の診断
- 汎用的な修正パターン
| コミット | 説明 |
|------|------|
| `bd42478` | docs(skill): add Nix Store path trap section to nixos-modern-cli |

## 2026-06-16T04:56:06+09:00

**概要**：opencode-telegram 0.21.2 — 上流の修正と依存関係の更新

- 上流の修正と依存関係の更新、0.21.2 へ引き上げ
| コミット | 説明 |
|------|------|
| `17252ea` | chore(pkgs): bump opencode-telegram 0.21.2 |
| `3b05a32` | docs(MAINTENANCE): record 2026-06-16 update (opencode-telegram 0.21.2) |

|--------|--------|--------|
| opencode-telegram | 0.21.1 | 0.21.2 |
| 　 | source hash | `sha256-V/rThMV5...` → `sha256-NEaQ2grHCKXi13utcHeUR83pJT6kqBGS4UqllhG93kY=` |
| 　 | npmDepsHash | `sha256-Bcexury...` → `sha256-z9trDo9xeWZyTSvCqX5XTb+AHY50wk0gsoEnAAEHOEg=` |

## 2026-06-15T17:32:16+09:00

**概要**：codewhale 0.8.60 — 上流の修正

- 上流の修正、0.8.60 へ引き上げ
| コミット | 説明 |
|------|------|
| `5c74dcf` | chore(pkgs): bump codewhale 0.8.60 |
| `3cef0a8` | docs(MAINTENANCE): record 2026-06-15 update (codewhale 0.8.60) |

|--------|--------|--------|
| codewhale | 0.8.59 | 0.8.60 |
| 　 | cli hash | `sha256-ti/IBPZV...` → `sha256-JqlByElHoLcR2Mlwmx5Qczfj+EoAp+igdLCd/QUOsX4=` |
| 　 | tui hash | `sha256-3Lh80hTS...` → `sha256-LTf681cWVH9Cu3TQrFeMlJUNVVG+TWxO2oI6VXK+4zA=` |

## 2026-06-14T08:11:16+09:00

**概要**：`comfyui-strix-halo` 文書 — オンライン統合モードの説明とファイル構造図

- オンライン統合モードの説明
- ファイル構造図
| コミット | 説明 |
|------|------|
| `c1fd014` | docs(comfyui-strix-halo): update integration mode and file structure |

## 2026-06-14T07:56:11+09:00

**概要**：codewhale 0.8.59 と mcp-searxng 1.4.0 — バージョン更新

- codewhale 0.8.59 — 若干の TUI レンダリング問題を修正
- mcp-searxng 1.4.0 — HTTP 転送モードを追加
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

**概要**：`llama-cpp-rocm` モジュール — modelsPreset サポートの復元と名前空間の移行

- modelsPreset サポートを復元（nixpkgs では削除済み）
- 名前空間を nixkits へ移行
- 三言語の移行ガイド
| コミット | 説明 |
|------|------|
| `6f52ddf` | feat(llama-cpp-rocm): restore modelsPreset via nixkits namespace, migrate from services |
| `56ff235` | docs(llama-cpp-rocm): add trilingual migration guide |

## 2026-06-12T17:29:59+09:00

**概要**：feat(llama-cpp-rocm): modelsPreset サポートの復元と名前空間の移行

- modelsPreset サポートを復元（nixpkgs では削除済み）
- 名前空間を nixkits へ移行
## 2026-06-12T10:51:31+09:00

**概要**：codewhale 0.8.58 と mcp-searxng 1.3.4 — 上流修正

- codewhale 0.8.58 — 上流修正
- mcp-searxng 1.3.4 — 上流修正
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

**概要**：スキル文書 — メンテナンスログの書式ルール群

- 自動発見への汎化
- 記述的な標題
- 正確な git commit タイムスタンプ
- `T00:00:00` プレースホルダの禁止
| コミット | 説明 |
|------|------|
| `7680adf` | docs(skill): enforce exact git commit timestamps, ban T00:00:00 placeholder |
| `487e18f` | docs(skills): sync descriptive title rule to trilingual docs |
| `3e9467f` | refactor(skills): generalize hardcoded content to auto-discovery |
| `033d3b8` | docs(skills): sync auto-discovery generalizations to trilingual docs |

## 2026-06-11T05:13:39+09:00

**概要**：その他 — 文書の追加と表記修正

- 欠落していた rog-control-center-fix の三言語モジュール文書を追加
- 著者クレジットの DeepSeek V4 Pro の大小文字表記を修正
| コミット | 説明 |
|------|------|
| `4876547` | docs: add missing rog-control-center-fix trilingual module docs |
| `f891ad2` | docs: fix DeepSeek V4 Pro casing in author credits |

## 2026-06-11T04:52:16+09:00

**概要**：codewhale 0.8.57 と mcp-searxng 1.3.2 — TUI 新規追加と上流修正

- codewhale 0.8.57 — TUI 新規追加
- mcp-searxng 1.3.2 — 上流修正
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

**概要**：opencode-telegram — KillMode と TimeoutStopSec の調整

- KillMode を process に変更
- TimeoutStopSec を追加してシャットダウン時のハングを防止
| コミット | 説明 |
|------|------|
| `fbcf15c` | fix(opencode-telegram): add TimeoutStopSec and KillMode to prevent shutdown hang |
| `6cda338` | fix(opencode-telegram): change KillMode from mixed to process |

## 2026-06-10T02:28:10+09:00

**概要**：codewhale 0.8.55 と mcp-searxng 1.3.1 — 上流修正

- codewhale 0.8.55 — 上流修正
- mcp-searxng 1.3.1 — 上流修正
| コミット | 説明 |
|------|------|
| `397e4ee` | chore(pkgs): bump codewhale 0.8.55, mcp-searxng 1.3.1 |

|--------|--------|--------|
| codewhale | 0.8.53 | 0.8.55 |
| mcp-searxng | 1.2.1 | 1.3.1 |
| 　 | cli hash | `sha256-VxBNH2o4i...` → `sha256-jwn3rKDda7nftaNLqMXNg+tjicshOC4s17StfSyTuEU=` |
| 　 | tui hash | `sha256-DBiWk4c4Q...` → `sha256-1Cxofu986R1hx1A1RNLqvRGrmFIYviRIkdO/pw+LIl8=` |

## 2026-06-08T15:12:39+09:00

**概要**：ドキュメント再編 — ローカライズ済みファイルを `docs/` へ移動、`MAINTENANCE.md` に書式規則を追加し履歴を逆填

- ローカライズ済みファイルを `docs/` ディレクトリへ移動
- `MAINTENANCE.md` に合列規則を追加
- `MAINTENANCE.md` に純テーブル格式を追加
- 完全なコミット履歴を遡って補完
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

**概要**：mcp-searxng 1.2.1 — 上流修正

- 上流修正、1.2.1 へ引き上げ
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

**概要**：rcc-fix — NixOS モジュール（systemd デッドロック修正）

- NixOS モジュール：systemd デッドロック修正
| コミット | 説明 |
|------|------|
| `141f4af` | feat(rcc-fix): add NixOS module for systemd deadlock fix |

## 2026-06-06T15:17:11+09:00

**概要**：スキル文書 — 文書同期規範、ツールチェーン説明とルールの汎化

- ソース変更後の文書同期規範
- comfyui-strix-halo の C ツールチェーン説明
- hash 計算の注意事項の汎化
- 基本情報ルールの多言語統一
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

**概要**：codewhale 0.8.53、mcp-searxng 1.1.0、opencode-telegram 0.21.1 — 上流修正

- codewhale 0.8.53 — 上流修正
- mcp-searxng 1.1.0 — 上流修正
- opencode-telegram 0.21.1 — 上流修正
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

**概要**：comfyui-strix-halo パッチ — ROCm 7.2 wheels の内蔵サポート

- ROCm 7.2 wheels の内蔵サポート
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

**概要**：スキルシステム — `SKILL.md` の中国語化と三言語対称性チェック

- `SKILL.md` の全面的な中国語化
- 三言語対称性チェック規則
| コミット | 説明 |
|------|------|
| `8aa65da` | docs(skill): add trilingual symmetry checks and ja 基本情報 rule to write-project-docs |
| `7dad578` | feat(skills): localize all SKILL.md to Chinese, declare in READMEs |

## 2026-06-02T10:15:53+09:00

**概要**：その他 — 文書の一括追加と整備

- recover-nixos-config スキルと多言語文書を追加
- Skills 章の見出しと汎用エージェント説明を修正
- ローカルモデル名に量子化レベルを追加
- 量子化ラベルに UD- 接頭辞を追加
- MIT ライセンスファイルを追加し全 README からリンク
- ローカル flake input の例を追加（リモートと併記）
- ローカル flake input の構文を実際の用法に合わせて修正
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

**概要**：opencode-telegram — flake module と文書整備

- NixOS モジュールを追加（宣言的設定）
- 文書を flake module 設定のみに簡素化、手動 systemd を削除
- 文書で NixOS module → flake module に改名
- 文書の節名を正確化——サービス設定であり module ではない
- 文書のサービス設定で flake.nix の全体像を提示
- 文書の節タイトルを flake module に統一、全言語で一致
- モジュール有効化時にパッケージを自動導入
- 文書に初回セットアップ手順を追加（opencode serve + 設定）
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

**概要**：codewhale 0.8.49、mcp-searxng 1.0.4、obs-bilibili-stream 2.1.0、opencode-telegram 0.21.0 — 上流修正

- `codewhale` 0.8.49 — 上流修正
- `mcp-searxng` 1.0.4 — 上流修正
- `obs-bilibili-stream` 2.1.0 — 上流修正
- `opencode-telegram` 0.21.0 — 上流修正
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

**概要**：nixos-modern-cli スキル — POSIX ツールガイドと nix バイナリのパスに関するヒント

- POSIX ツールガイドを追加
- nix バイナリのパスに関するヒントを追加
| コミット | 説明 |
|------|------|
| `4b103e5` | docs(nixos-modern-cli): add POSIX tool guide and nix binary tip |

## 2026-05-31T03:42:18+09:00

**概要**：write-project-docs — 新スキル

- NixKits 流に任意プロジェクトの多言語ドキュメント体系を書く
| コミット | 説明 |
|------|------|
| `373da95` | feat(skills): add write-project-docs skill with trilingual docs |

## 2026-05-30T03:42:14+09:00

**概要**：codewhale、llama-cpp-rocm、opencode-telegram — スペル・文書・手順の修正

- `codewhale`：ビルド失敗の原因となる stdenv のスペルミスを修正
- `llama-cpp-rocm`：文書からインラインリンクを削除し、system.nix の完全なプリセットを使用
- `opencode-telegram`：初回セットアップ手順を追加
| コミット | 説明 |
|------|------|
| `aef12bc` | docs(llama-cpp-rocm): use complete modelsPreset from system.nix |
| `15f956c` | docs(llama-cpp-rocm): replace Usage with upstream reference |
| `494f512` | docs(llama-cpp-rocm): remove inline upstream link from description |
| `7e53e25` | docs(llama-cpp-rocm): remove inline link from Usage section too |
| `df4074f` | fix(codewhale): fix stdenv typo causing build failure |

## 2026-05-30T03:19:48+09:00

**概要**：その他 — 多言語 README と I18n 構造

- en/ja の訳文と I18n 構造を追加
- en/ja README と言語切替を追加
| コミット | 説明 |
|------|------|
| `358316c` | docs: add English and Japanese translations with I18n structure |
| `bef3b4b` | docs: add English and Japanese README with language switcher |

## 2026-05-29T15:25:12+09:00

**概要**：kitsfmt — 複数の修正；rcc-fix — D-Bus ホットプラグ検出へ書き直し；build — .vscode gitignore のスコープ修正

- `kitsfmt`：オフラインビルド用に `vendor` ディレクトリを復元
- `kitsfmt`：冪等性と就地での安全性を修正
- `kitsfmt`：`with`→`builtins.attrValues` 変換、`--stdin` フラグを追加
- `rcc-fix`：D-Bus ホットプラグ検出へ書き直し
- `build`：`.vscode` gitignore のスコープ修正
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

**概要**：docs: codewhale の種別記述を修正（ソースビルドではなくビルド済みバイナリ）

- 種別記述をビルド済みバイナリ（ソースビルドではない）へ訂正
| コミット | 説明 |
|------|------|
| `14e060c` | docs: fix codewhale type description (pre-built, not source-built) |

## 2026-05-29T10:18:46+09:00

**概要**：codewhale v0.8.47 — 新規パッケージ

- DeepSeek V4 TUI エージェント
- ビルド済みバイナリへ切り替え、`cargoHash` を削除
| コミット | 説明 |
|------|------|
| `d5b1878` | feat: add codewhale (DeepSeek V4 TUI agent) v0.8.47 |
| `979b75c` | refactor(codewhale): switch to pre-built binaries, remove cargoHash |

|--------|--------|--------|
| codewhale | v0.8.47 |

## 2026-05-29T06:28:50+09:00

**概要**：fix(kitsfmt): 複数のフォーマット問題と冪等性を修正

- `inherit` のカンマ、インデント文字列の破損、lambda の空白など複数のフォーマット問題を修正
- 冪等性を修正
| コミット | 説明 |
|------|------|
| `f4b56ba` | fix(kitsfmt): inherit comma bug, indented string corruption, lambda spacing |
| `d1ab491` | feat(kitsfmt): best-practice auto-corrections with env var support |
| `3656154` | chore(kitsfmt): update Cargo.lock for v0.4.0 |
| `45f3c26` | feat(kitsfmt): rec→let-in conversion and multi-file support |

## 2026-05-29T05:57:55+09:00

**概要**：fix(build): .vscode gitignore のスコープが広すぎて vendored crate のファイルが除外される問題を修正

- `.vscode` gitignore をリポジトリルートに限定し、vendored crate のファイルを除外しないようにした
## 2026-05-28T08:29:27+09:00

**概要**：llama-cpp-rocm、opencode-telegram、rcc-fix とスキル文書 — モジュール・プロパティ・文言の修正

- `llama-cpp-rocm`：systemd サンドボックス上書き用の NixOS モジュールを追加
- `opencode-telegram`：NixOS モジュール（宣言的設定、自動インストール）
- `rcc-fix`：`ScrollView` を if 条件ではなく `visible` プロパティに変更
- スキル文書：動的発見の文言、ハードコードされた件数の除去、インストール節の追加、説明の簡素化
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

**概要**：スキルシステム — nixkits-check-updates、nixkits-skills、nixos-modern-cli の三大スキルを同時に導入

- 三スキルを同一バッチで追加、いずれも三言語の文書付き
- `llama-cpp-rocm`：上流 Release を動的に追跡する理由を補足
| コミット | 説明 |
|------|------|
| `327291a` | feat(skills): add nixos-modern-cli skill with 3-language docs |
| `f0e74d3` | feat(skills): add nixkits-skills installer with 3-language docs |
| `fc7fa3d` | docs(llama-cpp-rocm): clarify dynamic release tracking purpose |
| `627c9c5` | feat(skills): add nixkits-check-updates skill with 3-language docs |

## 2026-05-26T05:30:58+09:00

**概要**：文書 — README の節名を改名（快速开始→添加、包→软件、License→许可）

- `快速开始`→`添加`
- `包`→`软件`
- `License`→`许可`
| コミット | 説明 |
|------|------|
| `d869279` | docs(zh): rename sections 快速开始→添加 包→软件 License→许可 |

## 2026-05-24T03:01:02+09:00

**概要**：mcp-searxng の文書 — SearXNG + lighttpd リバースプロキシの完全な NixOS 設定

- SearXNG + lighttpd リバースプロキシの完全な NixOS 設定を記載
| コミット | 説明 |
|------|------|
| `f3a6978` | docs(mcp-searxng): add full SearXNG + lighttpd reverse proxy config |

## 2026-05-22T06:45:11+09:00

**概要**：llama-cpp-rocm — llama-cpp-ver flake 入力を削除

- llama-cpp-ver flake 入力を削除
- nixpkgs のデフォルト版を使用
| コミット | 説明 |
|------|------|
| `9e7f8e2` | fix(llama-cpp-rocm): remove llama-cpp-ver, use nixpkgs version directly |

## 2026-05-21T16:35:02+09:00

**概要**：mcp-searxng v1.0.3 と opencode-telegram v0.20.5 — 新パッケージ

- mcp-searxng v1.0.3 — 新パッケージ
- opencode-telegram v0.20.5 — 新パッケージ
|--------|--------|--------|
| mcp-searxng | v1.0.3 |
| opencode-telegram | v0.20.5 |

## 2026-05-16T19:07:54+09:00

**概要**：kitsfmt — マクロ構文エラーの修正、関数の簡素化、src パスの修正

- `match_ast!` マクロの構文エラーを修正
- `comments_before` 関数を簡素化
- src パスを修正
| コミット | 説明 |
|------|------|
| `e731eb7` | fix(kitsfmt): 修正 kitsfmt.nix 中的 src 路径 |
| `314732c` | fix(kitsfmt): 修复 match_ast! 宏不支持通配符的问题 |
| `1667e1d` | fix(kitsfmt): 修复 match_ast! 宏语法错误，简化 comments_before 函数 |

## 2026-05-15T16:59:28+09:00

**概要**：kitsfmt — rnix AST に基づきフォーマットエンジンを書き直し

- rnix AST に基づきフォーマットエンジンを v0.3.0 へ書き直し
- Cargo.lock を生成
| コミット | 説明 |
|------|------|
| `495415f` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `378e8bb` | refactor(kitsfmt): 基于 rnix AST 重写格式化引擎 v0.3.0 |
| `a1d1d36` | feat(kitsfmt): 生成 Cargo.lock，更新 kitsfmt.nix 使用 rnix AST 构建 |

## 2026-05-14T17:10:06+09:00

**概要**：llama-cpp-rocm — 新パッケージ

- 上流の最新 Release を動的に追跡
| コミット | 説明 |
|------|------|
| `9cb24a3` | llama-cpp MTP |

|--------|--------|--------|
| llama-cpp-rocm | 动态（构建时获取上游最新 Release） |

## 2026-05-14T07:38:08+09:00

**概要**：kitsfmt と obs-bilibili-stream v1.0.0 — 新パッケージ

- kitsfmt — 新パッケージ（自前の Nix フォーマッタ）
- obs-bilibili-stream v1.0.0 — 新パッケージ
| コミット | 説明 |
|------|------|
| `2c917bd` | feat: Add kitsfmt formatter and modernize flake structure |

|--------|--------|--------|
| kitsfmt | 自建（`packages/kitsfmt-src/`） |
| obs-bilibili-stream | v1.0.0 |

## 2026-05-01T01:08:15+09:00

**概要**：rcc-fix — 新パッケージ

- asusctl パッチ
| コミット | 説明 |
|------|------|
| `e2d09a2` | RCC-Fix |

|--------|--------|--------|
| rcc-fix | 跟随 nixpkgs（overlay + patch） |

