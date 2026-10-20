# mcp-searxng

[中文](../zh/mcp-searxng.md) | [English](../en/mcp-searxng.md) | [日本語](../ja/mcp-searxng.md)  | 偽中国語

**状態**：廃止（2026-10-20）—— 上流 nixpkgs 収録済、本倉 自前 build 終了。
詳細 [廃止 project 説明](deprecated/mcp-searxng.md)。

## 現在 使用法

**nixpkgs 直接 使用**

```nix
environment.systemPackages = [ pkgs.mcp-searxng ];
```

本倉 残 別名 等価（`inputs.nixkits.packages.${pkgs.system}.mcp-searxng` 同一 package 指）。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 2.6.0（nixpkgs 追従） |
| 上流 | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |
| nixpkgs 属性 | `mcp-searxng` |
| nixpkgs 追加 | 2026-08-29（init 2.1.0） |

> SearXNG 向 MCP server。AI 助手 網頁検索 提供。実行時 `SEARXNG_URL` 環境変数 必要。
