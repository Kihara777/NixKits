# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | [English](../en/godot-ai.md) | [日本語](../ja/godot-ai.md)  | 偽中国語

Godot 引擎 高品質 MCP server 與 AI 工具 — MCP client **実行中 Godot editor** 接続、AI 助手 場景構築・節點脚本編集・信号配線・UI材料動画設定可能。43 MCP 工具 / 120+ 操作。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Python 応用（MCP server）|
| 上流 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| 版本 | `3.2.5` |
| 許可 | MIT |
| Python | ≥ 3.11 |

## 架構

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: MCP client stdio 起動 独立 Python 行程
- **Godot Editor Plugin**: Godot Asset Library 導入（`hi-godot/godot-ai`）、WebSocket 受信

## 依存

| 依存 | 提供元 | 要件 |
|------|--------|-----|
| fastmcp | NixKits overlay | ≥ 3.4.0（nixpkgs 3.3.1 循環 import bug）|
| websockets | nixpkgs | ≥ 13.0 |
| pydantic | nixpkgs | ≥ 2.0 |
| httpx | nixpkgs | ≥ 0.27 |
| uvicorn | nixpkgs | ≥ 0.23 |
| starlette | nixpkgs | ≥ 0.40 |

> **fastmcp 3.4 昇級**: nixpkgs fastmcp 3.3.1 `fastmcp.server` 循環 import bug。NixKits `overlays/fastmcp.nix` 3.4.7 昇級、fastmcp-slim + py-key-value-aio 0.4.5 連動。

## 導入與使用

### 系統導入

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.godot-ai ];
```

### 速試

```bash
godot-ai
```

MCP client 設定（Claude Code / Codex 等）:

```json
{
  "Godot": {
    "command": "godot-ai",
    "env": {}
  }
}
```

### 前提條件

1. Godot 4.5+ editor（4.7+ 推奨）
2. Godot Asset Library 導入 `hi-godot/godot-ai` plugin（editor **AssetLib** tab）
3. Godot editor 起動、godot-ai WebSocket（`ws://127.0.0.1:9876`）自動接続
