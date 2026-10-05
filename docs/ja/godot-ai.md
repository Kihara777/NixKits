# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | [English](../en/godot-ai.md) | 日本語  | [偽中国語](../pcn/godot-ai.md)

Godotエンジン向けの本格的なMCPサーバーおよびAIツール — MCPクライアントを**実行中のGodotエディタ**に接続し、AIアシスタントによるシーン構築・ノード/スクリプト編集・シグナル配線・UI/マテリアル/アニメーション設定などを可能にします。46 MCPツール / 120+ 操作。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Python アプリ（MCPサーバー）|
| 上流 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| バージョン | `4.3.0` |
| ライセンス | MIT |
| Python | ≥ 3.11, < 3.15 |

## アーキテクチャ

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: MCPクライアントが stdio 経由で起動する独立 Python プロセス
- **Godot Editor Plugin**: Godot Asset Library からインストール（`hi-godot/godot-ai`）、WebSocket でリクエスト受信

## 依存関係

**v4 以降は fail-closed な厳密固定**：起動時に以下の 14 パッケージの**正確な版**を照合し、一つでも異なれば `RuntimeError` を送出して起動を拒否します。項目数は 4.2.3 で 14 に確定しました（当時 `fastmcp-slim` / `httpx2` / `httpcore2` / `mcp-types` / `sniffio` を追加し、`mcp` はメジャーバージョンをまたぎました：1.29.1 → 2.2.0、上流が wire types を独立ディストリビューション `mcp-types` に分離し、HTTP クライアントを `httpx2` に変更）。4.3.0 は**項目の増減なし**で、うち六項目を引き上げます：`fastmcp` / `fastmcp-slim` 4.0.5 → 4.0.10、`httpx2` / `httpcore2` 2.13.0 → 2.13.1、`uvicorn` 0.53.0 → 0.54.0、`starlette` 1.6.0 → 1.7.0。

| 依存 | バージョン | 提供元 |
|------|-----------|--------|
| anyio | `4.15.1` | `overlays/godot-ai-v4-deps.nix` |
| fastmcp | `4.0.10` | `overlays/fastmcp.nix` |
| fastmcp-slim | `4.0.10` | `overlays/fastmcp.nix` |
| h11 | `0.16.0` | nixpkgs |
| httpx | `0.28.1` | nixpkgs |
| httpx2 | `2.13.1` | `overlays/godot-ai-v4-deps.nix` |
| httpcore2 | `2.13.1` | `overlays/godot-ai-v4-deps.nix` |
| mcp | `2.2.0` | `overlays/godot-ai-v4-deps.nix` |
| mcp-types | `2.2.0` | `overlays/godot-ai-v4-deps.nix`（nixpkgs に存在せず、上流ソースから新規定義） |
| pydantic | `2.13.5` | `overlays/godot-ai-v4-deps.nix` |
| sniffio | `1.3.1` | nixpkgs |
| starlette | `1.7.0` | `overlays/godot-ai-v4-deps.nix` |
| uvicorn | `0.54.0` | `overlays/godot-ai-v4-deps.nix` |
| websockets | `17.1` | `overlays/godot-ai-v4-deps.nix` |

> 上表の 14 行は `packages/godot-ai.nix` の `dependencies` と**一対一に対応**し（数もバージョンも同一）、上流 `runtime_dependencies.py` の pin 表とも一致します。

> **mcp-types**：nixpkgs に存在しないため、`overlays/godot-ai-v4-deps.nix` が上流の同一リポジトリ（`modelcontextprotocol/python-sdk` の `src/mcp-types/`）から新規定義しています。

> **pydantic-core**：pydantic 2.13.5 は `pydantic-core==2.46.5` を要求します（nixpkgs は 2.46.4）。同パッケージは Rust ビルドのため、引上げ時は `cargoDeps` も再取得が必要です。

> **ビルド時の pin**：上流は `[build-system].requires` に `setuptools==84.0.0` を固定しています（nixpkgs は 83.0.0）。パッケージ内の `postPatch` で緩和しています——この pin は再現性の守りであり機能要件ではありません。

> **検証を打ち消すパッチにしない理由**：v4 の厳密固定はその安全境界（接続／本文／フレーム／セッションの予算）に奉仕するものです。`runtime_dependencies.py` を緩めればその境界を静かに弱めることになります。ゆえに「検証を nixpkgs に合わせる」のではなく「依存を上流に合わせて引き上げる」方を採ります。

> **二つの overlay は両方とも実際に効いている必要があります**：`overlays/fastmcp.nix` と `overlays/godot-ai-v4-deps.nix` は 2 か所（`flake.nix` の `godotPkgs` と `overlays/default.nix`）で連結され、どちらも nixpkgs の `pythonPackagesExtensions` 経由で取り付けます。`python312.override { packageOverrides = …; }` を使うと後者が前者を**置き換え**、fastmcp の上書きが黙って捨てられたままビルドは成功します。

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
3. Godot エディターを起動すると、godot-ai が WebSocket（`ws://127.0.0.1:9500`、既定ポート。`--ws-port` で変更可）経由で自動接続
