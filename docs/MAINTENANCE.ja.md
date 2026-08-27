# メンテナンスログ

[中文](../MAINTENANCE.md) | [English](MAINTENANCE.en.md) | 日本語  | [偽中国語](MAINTENANCE.pcn.md)

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

