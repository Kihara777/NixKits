# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | [English](../en/godot-ai.md) | 日本語  | [偽中国語](../pcn/godot-ai.md)

Godotエンジン向けの本格的なMCPサーバーおよびAIツール — MCPクライアントを**実行中のGodotエディタ**に接続し、AIアシスタントによるシーン構築・ノード/スクリプト編集・シグナル配線・UI/マテリアル/アニメーション設定などを可能にします。43 MCPツール / 120+ 操作。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Python アプリ（MCPサーバー）|
| 上流 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| バージョン | `3.2.5` |
| ライセンス | MIT |
| Python | ≥ 3.11 |

## アーキテクチャ

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: MCPクライアントが stdio 経由で起動する独立 Python プロセス
- **Godot Editor Plugin**: Godot Asset Library からインストール（`hi-godot/godot-ai`）、WebSocket でリクエスト受信

## 依存関係

| 依存 | 提供元 | 要件 |
|------|--------|-----|
| fastmcp | NixKits overlay | ≥ 3.4.0（nixpkgs の 3.3.1 には循環 import バグ）|
| websockets | nixpkgs | ≥ 13.0 |
| pydantic | nixpkgs | ≥ 2.0 |
| httpx | nixpkgs | ≥ 0.27 |
| uvicorn | nixpkgs | ≥ 0.23 |
| starlette | nixpkgs | ≥ 0.40 |

> **fastmcp 3.4 アップグレード**: nixpkgs の fastmcp 3.3.1 には `fastmcp.server` の循環 import バグがあります。NixKits は `overlays/fastmcp.nix` で 3.4.7 にアップグレードし、fastmcp-slim + py-key-value-aio 0.4.5 も連動アップグレードします。

## インストールと使用方法

### システムインストール

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.godot-ai ];
```

### クイックスタート

```bash
godot-ai
```

MCPクライアント設定（Claude Code / Codex 等）:

```json
{
  "Godot": {
    "command": "godot-ai",
    "env": {}
  }
}
```

### 前提条件

1. Godot 4.5+ エディター（4.7+ 推奨）
2. Godot Asset Library から `hi-godot/godot-ai` プラグインをインストール（エディターの **AssetLib** タブ）
3. Godot エディターを起動すると、godot-ai が WebSocket（`ws://127.0.0.1:9876`）経由で自動接続
