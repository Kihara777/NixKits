# 逆向模式 (Agent プリセット)

[中文](../../zh/modes/rea.md) | [English](../../en/modes/rea.md) | 日本語  | [偽中国語](../../pcn/modes/rea.md)

> 维护模式を土台にしたリバースエンジニアリング用エージェント：维护模式の**全機能**の上に、REA（Reverse Engineer Anything）の MCP サーバーを本セッションへ接続する——ツール名は `mcp__rea__*`、全量登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| モード id | `rea` |
| 配布方法 | dsh-nixos-shell パッケージ内 `presets/rea-mode/preset.patch.yml`、`@deepseek-ai/dsh-agent-preset` の patch 行として 1 行 |
| 有効化オプション | `nixkits.dsh.presets.reaMode = true` |
| 派生元 | [维护模式](maintenance.md)（組み合わせの末尾に固定行ブロックを追加） |
| 依存パッケージ | `nixkits.dsh.presets.reaPackage`（既定 `pkgs.rea`） |
| ドキュメント | [rea.md](../rea.md)（パッケージ本体）、[dsh-nixos-shell.md](../dsh-nixos-shell.md)（本モードを配布するパッケージ） |

## 挙動

维护模式の全機能の上に `@deepseek-ai/dsh-mcp-client` の行を 1 つ追加する：

| 項目 | 値 |
|------|-----|
| `serverName` | `rea` |
| `transport` | `stdio` |
| `command` | `$REA_BIN_PATH`（モジュールが `pkgs.rea` の `bin/rea` としてエクスポート） |
| `args` | `['mcp']` |
| `failOnStartupError` | `false` |

結果は三つ：

- **全ツール**：REA の MCP ツールがすべて `mcp__rea__*` として登録される（約 100 個）。`dsh-mcp-client` には許可リストやフィルタのオプションが**無い**（README と config のフィールド表で確認済み）ため、「一部だけ」を選ぶ唯一の方法はこの行を張らないこと——本モードは「全部欲しい」場面向けであり、**ツール表が長いのは代償であって欠陥ではない**。
- **维护模式の機能はそのまま**：ホスト検証、`nixos_shell` / `nixos_cli`、ドキュメント・保守ログ技能、四言語の約束事もすべて残る。解析結果をリポジトリへ戻すとき、ワークフローは既にそこにある。
- **REA が落ちてもプリセットは壊れない**：`failOnStartupError: false`。REA が起動できなくても维护模式の他の機能は使え、欠けるのは `mcp__rea__*` の一群だけ（ログに接続失敗が残る）。

## 前提

`pkgs.rea` は NixKits overlay 由来（`nixpkgs.overlays = [ inputs.nixkits.overlays.default ]`）。overlay を入れていない場合は `presets.reaPackage` を明示する——さもなければ求値は「attribute 'rea' missing」で失敗する。これは**明示的な失敗**であり、黙って飛ばすのではない。

`presets.reaMode = true` のときモジュールは `REA_BIN_PATH` を dsh サービスへエクスポートする。したがってプリセット本文には **store パスが一切現れない**（本文はバイト単位で派生でき、Nix の無い機械でも読める必要がある）。

## 既知の境界

[rea パッケージ文書](../rea.md) と同じであり、ここでは繰り返さない。誤読しやすい三つ：

| 事項 | 実際 |
|------|------|
| `rea doctor` のホスト判定 | NixOS では `unsupported_host` を報告する（上流は apt/dnf/pacman 系列でディストリビューションを識別する）。**静的解析は実測どおり使える**——それは判定であって実行前提ではない |
| frida 動的計装 | 本パッケージ内では不可（オフラインビルド + `--ignore-scripts`） |
| Hopper / Ghidra / IDA、JADX | 利用者側で用意する。JDK と `ps` は `pkgs.rea` が同梱する |

## 有効化

```nix
{
  nixkits.dsh = {
    # プリセットの `@kihara777/dsh-nixos-shell/maintenance-skills` 行はこの注入が無いと解決できない
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.maintenanceMode = true;   # 逆向模式は维护模式から派生する
    presets.reaMode = true;
  };
}
```

## 派生関係

逆向模式の組み合わせファイル = 维护模式の `plugins:` 本文 + **末尾に固定の `mcp-rea` 行ブロックを追加**（コメント含む）。それ以外の差異は許されない。

```yaml
- id: mcp-rea
  name: '@deepseek-ai/dsh-mcp-client'
  config:
    serverName: rea
    transport: stdio
    command: !!js "(process.env.REA_BIN_PATH || 'rea')"
    args: ['mcp']
    failOnStartupError: false
```

派生チェーンは**三段**：NixOS模式 → 维护模式 → 逆向模式。`develop/check-preset-derivation.py` が各段をバイト単位で照合し、`nix flake check`（push のたび）に組み込まれている：NixOS模式を変えて维护模式を放置すれば一段目が、维护模式を変えて本モードを放置すれば二段目が鳴る。追加ブロック自体を意図的に変える場合はスクリプトの `PATCH_REA_DELTA` 定数を更新する。詳細は `AGENTS.md` の「预设」節。

## 本当にマウントされたかの確認

セッションに `mcp__rea__*` ツールがあるか、あるいは設定画面で `preset-rea` 行の `fiberPhase` を見る。**「設定ファイルに書いてある」は「マウントできた」ではない**——アクティベーションに失敗した宣言は roster に診断付きで残り、黙って消えはしない。
