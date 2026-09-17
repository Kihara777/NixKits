# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | [English](../en/godot-ai.md) | 日本語  | [偽中国語](../pcn/godot-ai.md)

Godotエンジン向けの本格的なMCPサーバーおよびAIツール — MCPクライアントを**実行中のGodotエディタ**に接続し、AIアシスタントによるシーン構築・ノード/スクリプト編集・シグナル配線・UI/マテリアル/アニメーション設定などを可能にします。43 MCPツール / 120+ 操作。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Python アプリ（MCPサーバー）|
| 上流 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| バージョン | `4.1.0` |
| ライセンス | MIT |
| Python | ≥ 3.11 |

## アーキテクチャ

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: MCPクライアントが stdio 経由で起動する独立 Python プロセス
- **Godot Editor Plugin**: Godot Asset Library からインストール（`hi-godot/godot-ai`）、WebSocket でリクエスト受信

## 依存関係

**v4 以降は fail-closed な厳密固定**：起動時に以下の 9 パッケージの**正確な版**を照合し、一つでも異なれば `RuntimeError` を送出して起動を拒否します。nixpkgs は 5 つで遅れているため、`overlays/godot-ai-v4-deps.nix` が上流の要求まで引き上げます。

| 依存 | 上流の要求 | nixpkgs | 提供元 |
|------|-----------|---------|--------|
| fastmcp | `==3.4.7` | 3.4.7 | `overlays/fastmcp.nix` |
| anyio | `==4.14.2` | 4.14.2 | nixpkgs |
| mcp | `==1.29.1` | 1.29.0 | **overlay で引上げ** |
| websockets | `==17.1` | 16.1 | **overlay で引上げ** |
| pydantic | `==2.13.5` | 2.13.4 | **overlay で引上げ** |
| httpx | `==0.28.1` | 0.28.1 | nixpkgs |
| uvicorn | `==0.52.4` | 0.51.0 | **overlay で引上げ** |
| starlette | `==1.6.0` | 1.3.1 | **overlay で引上げ** |
| h11 | `==0.16.0` | 0.16.0 | nixpkgs |

> **pydantic-core**：pydantic 2.13.5 は `pydantic-core==2.46.5` を要求します（nixpkgs は 2.46.4）。同パッケージは Rust ビルドのため、引上げ時は `cargoDeps` も再取得が必要です。

> **ビルド時の pin**：上流は `[build-system].requires` に `setuptools==84.0.0` を固定しています（nixpkgs は 83.0.0）。パッケージ内の `postPatch` で緩和しています——この pin は再現性の守りであり機能要件ではありません。

> **検証を打ち消すパッチにしない理由**：v4 の厳密固定はその安全境界（接続／本文／フレーム／セッションの予算）に奉仕するものです。`runtime_dependencies.py` を緩めればその境界を静かに弱めることになります。ゆえに「検証を nixpkgs に合わせる」のではなく「依存を上流に合わせて引き上げる」方を採ります。

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
