# 狐莉模式 (Agent プリセット)

[中文](../../zh/modes/foxli.md) | [English](../../en/modes/foxli.md) | 日本語  | [偽中国語](../../pcn/modes/foxli.md)

> NixOS模式から派生した「スイスアーミーナイフ」プリセット：**日常保守・開発・リバースを一体**に扱う。同時に**コミュニティへ下放する能力の境界**でもある——掌灯模式はこれから派生し、私有アダプタ層だけを足す。

## 基本情報

| 項目 | 値 |
|------|-----|
| モード id | `foxli` |
| 配布方法 | dsh-nixos-shell パッケージ内 `presets/foxli-mode/preset.patch.yml`、`@deepseek-ai/dsh-agent-preset` の patch 行として 1 行 |
| 有効化オプション | `nixkits.dsh.presets.foxliMode = true` |
| 派生元 | [NixOS模式](nixos.md)（本文 + 固定 2 ブロック：**保守**・**リバース**） |
| 依存パッケージ | `nixkits.dsh.presets.reaPackage`（既定 `pkgs.rea`） |
| 文書 | [dsh-nixos-shell.md](../dsh-nixos-shell.md)、[rea.md](../rea.md) |

## 三層派生

```
NixOS模式（最小の NixOS 適配）
  └─ 狐莉模式（保守 + 開発 + リバース）   ← 本ページ；コミュニティ境界はここまで
       └─ 掌灯模式（Kitsunome 側：本ページの本文 + 私有差分）
```

**なぜ一つにまとめたか**：旧来の保守モードとリバースモードはそれぞれ「NixOS + 1 ブロック」だった。分けたままでは下流が 2 回派生し、技能リストを 2 本維持することになる——しかも**下流の写しを誰も見ていなかった**（2026-10-21 に 3 つの技能が漏れていたのはそのため）。

## 挙動

NixOS模式の全機能の上に**2 ブロック**を追加する。

### 保守ブロック

- **実行時技能**：`maintenance-skills` がビルド期に埋め込んだ `skills/` ツリーから `write-project-docs`、`write-maintenance-log`、`nix-flake-update-check`、`nixkits-check-updates`、`upstream-audit`、`nixkits-package-upstream`、`agent-self-maintenance` を登録し、`translate-*` を自動発見する。
- **二層の保守プロンプト**：`maintenance-workflow`（汎用、901）と `maintenance-workflow-repo`（本リポジトリの約束、902）。判定は一言：**その規約は他のリポジトリでも成立するか？**

### リバースブロック

同梱プラグイン `@kihara777/dsh-nixos-shell/rea-mcp`：

| 項目 | 値 |
|------|-----|
| 接続のタイミング | `agent/session-start` —— **本プリセットを選んだセッションごとに 1 本**、終了で切断 |
| 転送 | stdio JSON-RPC、`args: ['mcp']` |
| 実行ファイル | `$REA_BIN_PATH`（モジュールが `pkgs.rea` の `bin/rea` としてエクスポート） |
| ツール名 | `mcp__rea__<原名>`、**その agent の scope** に登録 |

REA の 207 個（6.8.0 の `tools/list` 実測）をすべて登録し、`inputSchema` は**そのまま**渡す —— 「JSON Schema → dsh 簡略 spec」の変換はしない（壊れると正当な呼び出しを静かに拒否するため）。

**なぜ `@deepseek-ai/dsh-mcp-client` を使わないか**：最初の版はそうしていた。2026-10-20 の実デプロイで、プリセットが **eager activation** であること（dsh 起動 4 秒後に `rea mcp` が spawn し、まだセッションは一つも無い）、ツール登録が root scope に落ちること（**掌灯模式のセッション**にも 207 個が載り、リクエストヘッダで 31 + 207 = **238**）を実測した。「モード」の意味は「それを選んだセッションだけが持つ」なので、この層は自前で書く。

## 前提

`pkgs.rea` は NixKits overlay 由来。無い場合は `presets.reaPackage` を明示する——求値は「attribute 'rea' missing」で**明示的に**失敗する。

`presets.foxliMode = true` のときモジュールは `REA_BIN_PATH` を dsh サービスへエクスポートするので、プリセット本文に **store パスは一切現れない**。

## 検証状態

| 層 | 結果 |
|---|---|
| プリセット宣言がプラットフォームに受理される | ✅ `AgentPresetRegistry.mount()` が OK |
| REA MCP サーバーが実際に起動する | ✅ dsh 起動から **4 秒**で spawn（pid 実測、5 時間以上生存、8 本のパイプ） |
| 207 個のツールがモデル要求へ届く | ✅ セッション記録の `request/header` に **207** 個（総数 238） |
| **本モードのセッションだけに見える** | ⏳ セッション単位の `rea-mcp` に変えた後、検証待ち |

## 有効化

```nix
{
  nixkits.dsh = {
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;
    presets.foxliMode = true;
  };
}
```

## 派生関係

組み合わせファイル = NixOS模式の `plugins:` 本文 + **固定 2 ブロック**（保守・リバース、コメント含む）。それ以外の差異は許されない。`develop/check-preset-derivation.py` がバイト単位で照合し、`nix flake check` に組み込まれている：

```python
PATCH_FOXLI_DELTA = PATCH_MAINTENANCE_DELTA + PATCH_REA_DELTA
```

**掌灯模式の派生はここではない**：Kitsunome 側にあり、ビルド期に本ページの本文を読んで私有差分を足す。その検査は向こうのリポジトリが持つ。
