# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md) | [ｶﾀﾘｯｼｭ](README.katalish.md) | 偽中国語

NixKits — ソフトウェア、パッチ、NixOS モジュル、AI コーディングアシスタントスキル之コレクション。

## 追加

```nix
# リモート
inputs.nixkits.url = "github:Kihara777/NixKits";

# ローカル
inputs.nixkits.url = "/home/kix/NixKits";
```

## ソフトウェア

之 `lib.platforms.linux` 対応 — nixpkgs 自動追従。

| ソフトウェア | 説明 | ドキュメント |
|---|------|------|
| codewhale | DeepSeek V4 端末コーディングエージェント | [docs/ja/codewhale.md](ja/codewhale.md) |
| kitsfmt | Nix フォーマッタ（AST ソート + ベストプラクティス自動修正） | [docs/ja/kitsfmt.md](ja/kitsfmt.md) |
| mcp-searxng | SearXNG 向 MCP サーバー | [docs/ja/mcp-searxng.md](ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili 配信プラグイン | [docs/ja/obs-bilibili-stream.md](ja/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 向 Telegram Bot クライアント | [docs/ja/opencode-telegram.md](ja/opencode-telegram.md) |
| ruyi | RuyiSDK パッケージマネージャ（RISC-V 開発ツール） | [docs/ja/ruyi.md](ja/ruyi.md) |
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ComfyUI ROCm サポート | [docs/ja/comfyui-strix-halo.md](ja/comfyui-strix-halo.md) |

> ⚠️ comfyui-strix-halo モジュル+パッチ、独立パッケージ、バイナリキャッシュ含。

## 開発

`nix develop` 即利用可能。レジストリ追加：

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| パッケージ | `nix develop` |
|-----------|---------------|
| ruyi | `nix develop nixkits#ruyi` |

## パッチ

スタンドアロンオーバーレイ。`default` 含：

| パッチ | 説明 | ドキュメント |
|------|------|------|
| llama-cpp-rocm | 上流最新リリース追跡 ROCm アクセラレーション | [docs/ja/llama-cpp-rocm.md](ja/llama-cpp-rocm.md) |
| rcc-fix | asusctl 之 2-in-1 デバイス体験修正 | [docs/ja/rcc-fix.md](ja/rcc-fix.md) |
| ruyi-nixos-compat | ruyi 之 NixOS ランタイム互換性（ELF interpreter リダイレクト + GCC 子プロセス修正） | [docs/ja/ruyi-nixos-compat.md](ja/ruyi-nixos-compat.md) |
| comfyui-rocm-patch | ComfyUI  ROCm 機能パッチ提供 | [docs/ja/comfyui-rocm-patch.md](ja/comfyui-rocm-patch.md) |
| rog-control-center-fix | シャットダウン時之 asusd デッドロック修正 | [docs/ja/rog-control-center-fix.md](ja/rog-control-center-fix.md) |

> ⚠️ パッチ overlay 、上流之 nixpkgs パッケージ変更之、独立ビルド。之バイナリキャッシュ含。動的版追跡プロジェクト（llama-cpp-rocm ）ハッシュ上流リリース與変化、キャッシュ固定不可。

## スキル

AI コーディングアシスタント向：

> 本プロジェクト之スキル主中国語ユーザー與中国之オープンソースモデル対象與。之 SKILL.md 中国語記述。

| スキル | 説明 | ドキュメント |
|------|------|------|
| nixkits-check-updates | 上流アップデートチェック自動更新 | [docs/ja/skills/nixkits-check-updates.md](ja/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits スキルインストーラー（ローカル/オンライン） | [docs/ja/skills/nixkits-skills.md](ja/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS モダン CLI ガイド（AI モデル向） | [docs/ja/skills/nixos-modern-cli.md](ja/skills/nixos-modern-cli.md) |
| recover-nixos-config | 削除 /etc/nixos 設定 Nix store 復元 | [docs/ja/skills/recover-nixos-config.md](ja/skills/recover-nixos-config.md) |
| translate-katalish | カタカナ英語翻訳（英単語→半角カタカナ機械置換） | [docs/ja/skills/translate-katalish.md](ja/skills/translate-katalish.md) |
| translate-pseudocn | 偽中国語翻訳（日本語→仮名除去＋語順変換） | [docs/ja/skills/translate-pseudocn.md](ja/skills/translate-pseudocn.md) |
| write-maintenance-log | NixKits 仕様沿 MAINTENANCE.md エントリ之作成（ソフトウェア更新 + バグ修正） | [docs/ja/skills/write-maintenance-log.md](ja/skills/write-maintenance-log.md) |
| write-project-docs | 任意之プロジェクト NixKits スタイル之多言語ドキュメント作成 | [docs/ja/skills/write-project-docs.md](ja/skills/write-project-docs.md) |

## クレジット

- **狐莉 (キツ之)** — 作成與保守
- **小爪 (キツ之)** — 設計・開発 feat. DeepSeek V4 Pro (Max)
- **小小爪 (キツ之)** — ハードウェア推論インフラ feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## 許諾

[MIT](../LICENSE)