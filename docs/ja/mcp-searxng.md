# mcp-searxng

[中文](../zh/mcp-searxng.md) | [English](../en/mcp-searxng.md) | 日本語  | [偽中国語](../pcn/mcp-searxng.md)

**状態**：廃止（2026-10-20）—— 上流 nixpkgs が収録済みのため、本リポジトリは自前ビルドを終了した。
詳細は[廃止プロジェクトの説明](deprecated/mcp-searxng.md)。

## 現在の使い方

**nixpkgs を直接使う**

```nix
environment.systemPackages = [ pkgs.mcp-searxng ];
```

本リポジトリが残す別名は等価（`inputs.nixkits.packages.${pkgs.system}.mcp-searxng` は同じパッケージを指す）。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 2.6.0（nixpkgs に追従） |
| 上流 | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |
| nixpkgs 属性 | `mcp-searxng` |
| nixpkgs 追加 | 2026-08-29（init 2.1.0） |

> SearXNG 向け MCP サーバー。AI アシスタントにウェブ検索を提供する。実行時に `SEARXNG_URL` 環境変数が必要。
