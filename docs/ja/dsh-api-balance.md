# dsh-api-balance

[中文](../zh/dsh-api-balance.md) | [English](../en/dsh-api-balance.md) | 日本語  | [偽中国語](../pcn/dsh-api-balance.md)

API 使用量残高プラグイン（DeepSeek Harness）——webui の使用量リング（送信ボタン左のコンテキスト使用量表示）のポップアップパネルに「用量 / 残高」タブ切替を追加する。

> **本プロジェクトは独立リポジトリへ移転しました**：<https://github.com/Kihara777/dsh-api-balance>
>
> これは**プラットフォーム非依存の DSH プラグイン**（NixOS 専用ではない）であるため、独立して配布し npm へ公開しています。
> **完全なドキュメント（四言語）は新リポジトリ内にあります**：<https://github.com/Kihara777/dsh-api-balance#文档>
>
> 本ページは NixKits 固有の一節——**宣言的インストール**——のみを保持します。

## 基本情報

| 項目 | 値 |
|------|-----|
| ソースリポジトリ | <https://github.com/Kihara777/dsh-api-balance> |
| npm 名 | `@kihara777/dsh-api-balance` |
| タイプ | DSH Host + Client プラグイン |
| ライセンス | MIT |
| NixKits での役割 | 薄いラッパーパッケージ（宣言的インストールを提供）。ソースは保持しない |

## インストール

### 方式 A：`dsh plugin add`（DSH ネイティブ）

```bash
dsh plugin --profile web add github:Kihara777/dsh-api-balance
# または npm から
dsh plugin --profile web add @kihara777/dsh-api-balance
```

### 方式 B：宣言的（NixOS モジュール——本ページ固有）

NixKits は薄い `pkgs.dsh-api-balance` ラッパー（新リポジトリのソースからビルド）を保持し、NixOS ユーザーが宣言的にインストールできるようにしています——バージョンは Nix が固定し、システム世代とともに更新され、再現可能です：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-api-balance;
    id = "api-balance";
    name = "@kihara777/dsh-api-balance";
    # config（任意）：
    #   apiKeyEnv = "DEEPSEEK_API_KEY";   # credential-ref
    #   baseURL = "https://api.deepseek.com";
    #   browserScan = true;               # ローカルブラウザ自動スキャン
    #   browserScanIntervalMs = 21600000; # スキャン節流（デフォルト 6 時間）
  }];
}
```

> ⚠️ **方式 A と併用しないこと**——両者は同じ entry id を登録するため重複します。

## 薄いラッパーの更新

`packages/dsh-api-balance.nix` は新リポジトリの 1 つの `rev` と 2 つの hash（ソースと `npmDepsHash`）を固定しています。更新時は 3 つすべてを同期させる必要があり、一般的な手順は `nix-flake-update-check` スキルにあります。

## 機能概要

完全な機能説明は[新リポジトリ](https://github.com/Kihara777/dsh-api-balance)にあります。概要：

- **残高**：DeepSeek 公式 `GET /user/balance`（API key 認証）
- **使用量**：当日 / 当月 / 30 日消費（金額 + token + モデル別明細）と日別 / 月別チャート
- **プラットフォームトークン**：デフォルトで本機ブラウザのログイン状態から自動スキャン、手動接続はフォールバック
- **音声**：音声パック + TTS（ブラウザ内蔵 / カスタム API）、ピーク・オフピーク課金の自動通知
- **UI 強化**：ピーク時の赤表示、疑問ウィンドウのスクロール修正、下部統計バーのスクロールなど
