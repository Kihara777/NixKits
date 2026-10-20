# mcp-searxng 自前パッケージ（廃止済み）

[中文](../../zh/deprecated/mcp-searxng.md) | [English](../../en/deprecated/mcp-searxng.md) | 日本語  | [偽中国語](../../pcn/deprecated/mcp-searxng.md)

[← 廃止プロジェクト索引](../../../DEPRECATED.md)

**状態**：廃止（2026-10-20）
**旧位置**：`packages/mcp-searxng.nix` + `.github/workflows/build-mcp-searxng-{x86_64,aarch64,riscv64}.yml`
**現状**：パッケージ定義と三つのビルドワークフローは削除済み；flake と devshell は nixpkgs の同名属性を参照；overlay の行は削除（nixpkgs が提供するため、残すと自己参照になる）。

## かつて何を解決していたか

NixKits が mcp-searxng（SearXNG 向け MCP サーバー）を自前でパッケージ化し、三つの
ワークフローで x86_64 / aarch64 / riscv64 の成果物をビルドして Cachix に push していた。

## なぜ廃止できるか

上流 nixpkgs は **2026-08-29** に収録（`init at 2.1.0`）、2026-10-13 に **2.6.0** へ更新。
現在はバージョンと二つの hash が**完全に一致**している：

| 項目 | 本リポジトリ（旧） | nixpkgs |
|---|---|---|
| バージョン | 2.6.0 | 2.6.0 |
| src hash | `sha256-dbxJSS…` | 同一 |
| npmDepsHash | `sha256-+df6o…` | 同一 |
| `__structuredAttrs` / `strictDeps` | あり | あり |
| wrapper | 手動 `makeWrapper` | なし（`buildNpmPackage` が処理） |

nixpkgs 版のほうが簡潔で、`mcp-searxng --help` も実測で動作する。

## 廃止後の設定方法

```nix
environment.systemPackages = [ pkgs.mcp-searxng ];
```

または本リポジトリの別名（等価）：`inputs.nixkits.packages.${pkgs.system}.mcp-searxng`。

## 一つの判据

廃止前に検証したのは**コマンドが動くこと**（`mcp-searxng --help`）であり、
「バージョンが同じ」ではない —— nixpkgs 版には手動 wrapper が無く、二つの定義は
等価ではない。「同じバージョン」から「同じ挙動」は導けない。
