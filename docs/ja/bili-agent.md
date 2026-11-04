# bili-agent

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-bili-agent-x86_64.yml?branch=main&label=x86_64%20v1.3.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-bili-agent-aarch64.yml?branch=main&label=aarch64%20v1.3.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/bili-agent.md) | [English](../en/bili-agent.md) | 日本語  | [偽中国語](../pcn/bili-agent.md)

AI エージェント向けに設計された Bilibili のコマンドラインツール。各コマンドは stdout に
**JSON をひとつだけ**出力し、対話を必要とせず、アカウント操作にはレート制限・監査ログ・
DM 許可リストが付いている。コマンド名は `bili`。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 1.3.0 |
| 上流 | [kukemc/bili-cli](https://github.com/kukemc/bili-cli) |
| 種類 | Python アプリケーション（hatchling） |
| ライセンス | MIT |
| プラットフォーム | x86_64 / aarch64 |
| コマンド | `bili` |

## 本リポジトリがライブラリも同梱する理由

上流は `bilibili-api-python==17.4.2` を固定しているが、**nixpkgs にそのライブラリは無い**
（2026-11-04 にひとつずつ確認）。よって本リポジトリは `packages/bilibili-api-python.nix` も
パッケージする。実行時依存 12 個はすべて nixpkgs 由来で、ビルド時には追加で
`setuptools-scm` が要る——層を間違えると `Unmet dependencies … setuptools-scm` で落ちる。

nixpkgs の新しい版で代用するのは**選択肢にならない**：`==` は厳格な制約であり、検査を飛ばすと
実行時の挙動差として現れる（同族の `blender-mcp` は `mcp<2` でこれを踏んだ）。

## 使い方

```bash
bili auth status          # まずログイン状態を見る
bili feed inbox           # この回の新着
bili video watch <BV>     # 情報 + AI 要約 + 全文 + 人気コメント + 弾幕の山 + 画面一覧
bili schema               # 全コマンドの機械可読な説明
```

書き込み操作はすべて `--dry-run` に対応する。コマンド表の全体はスキル `bili-cli`
（lampkeeper モード内）または上流の `skills/bili-cli/SKILL.md` にある。

## ログイン

一度きりの QR 読み取り：`bili auth login` が `qr_image`（ローカル PNG のパス）と 180 秒有効な
`qr_url` を返すので、Bilibili アプリで読み取り、その後 `bili auth status --wait 120`。
認証情報は `~/.config/bili-cli/` に置かれ、**nix store にもリポジトリにも入らない**。

## 既知の限界

- ビルドするのは x86_64 と aarch64 のみ。riscv64 のワークフローは無い——`curl-cffi` の
  riscv64 対応は未検証であり、**書かないことは約束しないこと**。
- 上流は MIT だが、閉包内の `bilibili-api-python` は GPL-3.0-or-later。頒布義務は別々に掛かる。
