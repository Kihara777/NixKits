# NixKits

[中文](../README.md) | [English](README.en.md) | 日本語 | [ｶﾀﾘｯｼｭ](README.katalish.md) | [偽中国語](README.pcn.md)

NixKits — ソフトウェア、パッチ、NixOS モジュール、AI コーディングアシスタントスキルのコレクション。

## 追加

```nix
# リモート
inputs.nix-kits.url = "github:Kihara777/NixKits";

# ローカル
inputs.nix-kits.url = "/home/kix/NixKits";
```

## ソフトウェア

すべての `lib.platforms.linux` に対応 — nixpkgs に自動追従。

| ソフトウェア | 説明 | ドキュメント |
|---|------|------|
| codewhale | DeepSeek V4 端末コーディングエージェント | [docs/zh/codewhale.md](ja/codewhale.md) |
| kitsfmt | Nix フォーマッタ（AST ソート + ベストプラクティス自動修正） | [docs/zh/kitsfmt.md](ja/kitsfmt.md) |
| mcp-searxng | SearXNG 向け MCP サーバー | [docs/zh/mcp-searxng.md](ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili 配信プラグイン | [docs/zh/obs-bilibili-stream.md](ja/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 向け Telegram Bot クライアント | [docs/zh/opencode-telegram.md](ja/opencode-telegram.md) |
| ruyi | RuyiSDK パッケージマネージャー（RISC-V 開発ツール） | [docs/zh/ruyi.md](ja/ruyi.md) |
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ComfyUI ROCm サポート | [docs/zh/comfyui-strix-halo.md](ja/comfyui-strix-halo.md) |

## 開発

`nix develop` で即利用可能。まずレジストリを追加：

```bash
nix registry add nix-kits github:Kihara777/NixKits
```

| パッケージ | `nix develop` |
|-----------|---------------|
| ruyi | `nix develop nix-kits#ruyi` |

## パッチ

スタンドアロンオーバーレイ。`default` には含まれない：

| パッチ | 説明 | ドキュメント |
|------|------|------|
| llama-cpp-rocm | 上流最新リリースを追跡する ROCm アクセラレーション | [docs/zh/llama-cpp-rocm.md](ja/llama-cpp-rocm.md) |
| rcc-fix | asusctl の 2-in-1 デバイス体験を修正 | [docs/zh/rcc-fix.md](ja/rcc-fix.md) |
| ruyi-nixos-compat | ruyi の NixOS ランタイム互換性（ELF interpreter リダイレクト + GCC 子プロセス修正） | [docs/zh/ruyi-nixos-compat.md](ja/ruyi-nixos-compat.md) |
| comfyui-rocm-patch | ComfyUI に ROCm 機能パッチを提供 | [docs/zh/comfyui-rocm-patch.md](ja/comfyui-rocm-patch.md) |
| rog-control-center-fix | シャットダウン時の asusd デッドロックを修正 | [docs/zh/rog-control-center-fix.md](ja/rog-control-center-fix.md) |

## スキル

AI コーディングアシスタント向け：

> 本プロジェクトのスキルは主に中国語ユーザーと中国のオープンソースモデルを対象としています。すべての SKILL.md は中国語で記述されています。

| スキル | 説明 | ドキュメント |
|------|------|------|
| nixkits-check-updates | 上流アップデートをチェックして自動更新 | [docs/zh/skills/nixkits-check-updates.md](ja/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits スキルインストーラー（ローカル/オンライン） | [docs/zh/skills/nixkits-skills.md](ja/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS モダン CLI ガイド（AI モデル向け） | [docs/zh/skills/nixos-modern-cli.md](ja/skills/nixos-modern-cli.md) |
| recover-nixos-config | 削除された /etc/nixos 設定を Nix store から復元 | [docs/zh/skills/recover-nixos-config.md](ja/skills/recover-nixos-config.md) |
| translate-katalish | カタカナ英語翻訳（英単語→半角カタカナ機械置換） | [docs/zh/skills/translate-katalish.md](ja/skills/translate-katalish.md) |
| translate-pseudocn | 偽中国語翻訳（日本語→仮名除去＋語順変換） | [docs/zh/skills/translate-pseudocn.md](ja/skills/translate-pseudocn.md) |
| write-maintenance-log | NixKits 仕様に沿った MAINTENANCE.md エントリの作成（ソフトウェア更新 + バグ修正） | [docs/zh/skills/write-maintenance-log.md](ja/skills/write-maintenance-log.md) |
| write-project-docs | 任意のプロジェクトに NixKits スタイルの多言語ドキュメントを作成 | [docs/zh/skills/write-project-docs.md](ja/skills/write-project-docs.md) |

## クレジット

- **狐莉 (キツのり)** — 作成と保守
- **小爪 (キツのめ)** — 設計・開発 feat. DeepSeek V4 Pro (Max)
- **小小爪 (キツのめ)** — ハードウェア推論インフラ feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ライセンス

[MIT](../LICENSE)