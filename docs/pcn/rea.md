# rea

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-rea-x86_64.yml?branch=main&label=x86_64%20v6.7.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-rea-aarch64.yml?branch=main&label=aarch64%20v6.7.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/rea.md) | [English](../en/rea.md) | [日本語](../ja/rea.md)  | 偽中国語

**REA（Reverse Engineer Anything）** — 依 agent 実現万能逆工程：CLI・MCP 服務器各一体、応用挙動自原生二進制迄探下。解析本地実行、結論附証拠与限界。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 6.7.0 |
| 上流 | <https://github.com/morluto/rea> |
| npm 名 | `rea-agents` |
| 許可 | MIT |
| 梱包形態 | 上流**構築済** npm tarball（`dist/` 原様、Nix 側無編譯） |
| 対応平台 | x86_64-linux / aarch64-linux |

## 使用法

```bash
rea --help                                    # 命令一覧（約 100 個之副命令）
rea doctor                                    # 就緒性診断（客端登録 / 解析機関 / 宿主机）
rea capabilities                              # provider 能力与副作用一覧
rea analyze-javascript-application <dir> --format json   # JS/Electron 応用之静的再構築
rea mcp                                       # stdio MCP 服務器
```

解析結果乃 **Evidence envelope**：結論於 `normalized_result`、其結論不到之境界於 `limitations`。

## 能力与依存之境界

REA 之大半**不要外部機関**——是本包之主用途。要機関之部分請自備、本包不推測路径。

| 対象 | 返却物 | 必要物 |
|------|--------|--------|
| JavaScript / Electron | 模組、import、source map、経路、IPC、原生拡張之関係 | 本包同梱 `ps`（procps） |
| .NET 組立品 | 元情報、CIL 命令、宣言済原生依存 | 無（純静的） |
| Go / Rust 二進制 | 埋込構築版、模組、依存辺 | 無（純静的） |
| Godot PCK / IL2CPP / SQLite / 包与資源 | 档案目録、型与方法名、表構造、digest | 無（純静的） |
| 原生二進制（擬似碼 / 逆組立） | 擬似碼、組立、文字列、符号、呼出与参照 | 外部設置之 Hopper / Ghidra / IDA |
| Android APK | manifest、類、逆編譯済方法 | JADX 与完全 JDK |

## 本包之既知境界

> 以下非「未検証」、乃**既知之不可**或**既知之錯誤**。記於此、避他在所拾相反期待。

| 事項 | 実際 |
|------|------|
| `rea doctor` 宿主机判定 | NixOS 報告 `host: unsupported_host`（上流依 apt / dnf / pacman 系列識別分配、NixOS 不在其列）。**静的解析実測可用**——此乃判定、非実行前提 |
| frida 動的計装 | 上流之 optionalDependency、設置時以 `prebuild-install` 下載二進制。Nix 構築離線且 `npmRebuildFlags = [ "--ignore-scripts" ]`、故 frida native binding 不存在——関連命令失敗、非静黙降格 |
| Hopper / Ghidra / IDA / JADX | 本包一切不提供。以環境変数指自己之物（`GHIDRA_INSTALL_DIR`、`HOPPER_LAUNCHER_PATH`、`REA_JADX_MCP_JAR`） |
| riscv64 | **非対応**：`@lydell/node-pty` 只公開 x64/arm64 構築済成果物、且 REA import 之 |

## 参照

```nix
# 直接参照
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.rea ];

# Default overlay（推奨）
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.rea
```

## MCP 服務器之利用

`rea mcp` 乃 stdio 転送。他客端之手動登録参照上流 `docs/installation.md`；`rea doctor` 列挙本機発見之客端設定与不足項目。

## 更新

`packages/rea.nix` 固定三物：npm tarball 之 `hash`、`npmDepsHash`、vendor 済 `packages/rea-package-lock.json`。三者須同源——vendored lock 只含本番依存、故 `postPatch` 削除 tarball 之 `devDependencies`。不一致時 `npm ci` 即時失敗（有意：不一致比編譯錯誤更難見）。一般手順参照 `nix-flake-update-check` 技能。

成果物之実検証在 `develop/qemu-smoke-tests/rea.sh`（CI 之 x86_64 / aarch64 両 workflow 実行）。判定基準乃**実際一度静的解析実行**、非 `--version`。
