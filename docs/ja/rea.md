# rea

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-rea-x86_64.yml?branch=main&label=x86_64%20v6.7.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-rea-aarch64.yml?branch=main&label=aarch64%20v6.7.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/rea.md) | [English](../en/rea.md) | 日本語  | [偽中国語](../pcn/rea.md)

**REA（Reverse Engineer Anything）** — agent で何でもリバースエンジニアリング：CLI と MCP サーバーが一つずつ、アプリの挙動からネイティブバイナリまで降りていく。解析はローカルで走り、結論には証拠と限界が付く。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 6.7.0 |
| 上流 | <https://github.com/morluto/rea> |
| npm 名 | `rea-agents` |
| ライセンス | MIT |
| 梱包形態 | 上流の**ビルド済み** npm tarball（`dist/` はそのまま、Nix 側では何もコンパイルしない） |
| プラットフォーム | x86_64-linux / aarch64-linux |

## 使い方

```bash
rea --help                                    # コマンド一覧（約 100 個のサブコマンド）
rea doctor                                    # 準備状態の診断（クライアント登録 / 解析エンジン / ホスト）
rea capabilities                              # provider の能力と副作用の一覧
rea analyze-javascript-application <dir> --format json   # JS/Electron アプリの静的再構築
rea mcp                                       # stdio MCP サーバー
```

結果は **Evidence envelope**：結論は `normalized_result` に、その結論が届かない境界は `limitations` に入る。

## 能力と依存の境界

REA の大半は**外部エンジンを必要としない**——これが本パッケージの主用途である。エンジンが要る部分は利用者側で用意する。本パッケージはパスを推測しない。

| 対象 | 返るもの | 必要なもの |
|------|---------|-----------|
| JavaScript / Electron | モジュール、import、source map、ルート、IPC、ネイティブアドオンの関係 | 本パッケージが `ps`（procps）を同梱 |
| .NET アセンブリ | メタデータ、CIL 命令、宣言されたネイティブ依存 | なし（純静的） |
| Go / Rust バイナリ | 埋め込まれたビルド版、モジュール、依存辺 | なし（純静的） |
| Godot PCK / IL2CPP / SQLite / パッケージとリソース | アーカイブ目録、型とメソッド名、テーブル構造、digest | なし（純静的） |
| ネイティブバイナリ（擬似コード / 逆アセンブリ） | 擬似コード、アセンブリ、文字列、シンボル、呼び出しと参照 | 外部インストールの Hopper / Ghidra / IDA |
| Android APK | manifest、クラス、逆コンパイル済みメソッド | JADX（jar は自前）と JDK（**本パッケージが同梱**） |

## 本パッケージの既知の境界

> 以下は「未検証」ではなく、**既知の不可**または**既知のエラー**である。別の場所で逆の期待を拾わないよう、ここに書く。

| 事項 | 実際 |
|------|------|
| `rea doctor` のホスト判定 | NixOS では `host: unsupported_host` を報告する（上流は apt / dnf / pacman 系列でディストリビューションを識別しており、NixOS はその一覧に無い）。**静的解析は実測どおり使える**——この行は判定であり実行前提ではない |
| frida 動的計装 | 上流の optionalDependency で、インストール時に `prebuild-install` がバイナリを**ダウンロード**する。Nix ビルドはオフラインかつ `npmRebuildFlags = [ "--ignore-scripts" ]` なので frida の native binding は存在しない——関連コマンドは静かに劣化せず失敗する |
| Hopper / Ghidra / IDA、JADX | 本パッケージは一切提供しない。環境変数で自分のものを指す（`GHIDRA_INSTALL_DIR`、`HOPPER_LAUNCHER_PATH`、`REA_JADX_MCP_JAR`）。**JDK と `ps` は本パッケージが同梱する**——JDK は本パッケージのクロージャに入る（約 +200 MiB）。Android 解析をしない利用者も抱えることになるが、これは意図した取捨である |
| riscv64 | **非対応**：`@lydell/node-pty` は x64/arm64 のビルド済み成果物しか公開しておらず、REA はそれを import する |

## 参照

```nix
# 直接参照
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.rea ];

# Default overlay（推奨）
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.rea
```

## MCP サーバーの利用

`rea mcp` は stdio 転送。他のクライアントへの手動登録は上流の `docs/installation.md` を参照；`rea doctor` は本機で見つけたクライアント設定と不足項目を列挙する。

## 更新

`packages/rea.nix` は三つを固定する：npm tarball の `hash`、`npmDepsHash`、そして vendor した `packages/rea-package-lock.json`。三者は同源でなければならない——vendored lock は本番依存のみを含むため、`postPatch` が tarball の `devDependencies` を削除する。不一致なら `npm ci` は即座に失敗する（意図的：不一致はコンパイルエラーより見つけにくい）。一般的な手順は `nix-flake-update-check` スキルを参照。

成果物の実検証は `develop/qemu-smoke-tests/rea.sh`（CI の x86_64 / aarch64 両ワークフローが実行する）。判定基準は **一度実際に静的解析を走らせること**であり、`--version` ではない。
