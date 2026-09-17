# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | [English](../en/godot-ai.md) | [日本語](../ja/godot-ai.md)  | 偽中国語

Godot 引擎 高品質 MCP server 與 AI 工具 — MCP client **実行中 Godot editor** 接続、AI 助手 場景構築・節點脚本編集・信号配線・UI材料動画設定可能。43 MCP 工具 / 120+ 操作。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Python 応用（MCP server）|
| 上流 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| 版 | `4.1.0` |
| 許可 | MIT |
| Python | ≥ 3.11 |

## 架構

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: MCP client stdio 起動 独立 Python 行程
- **Godot Editor Plugin**: Godot Asset Library 導入（`hi-godot/godot-ai`）、WebSocket 受信

## 依存

**v4 以降 fail-closed 厳密固定**：起動時 以下 九 包 **正確 版** 照合、一 異 則 `RuntimeError` 送出 起動 拒否。nixpkgs 五 遅 故、`overlays/godot-ai-v4-deps.nix` 上流 要求 迄 引上。

| 依存 | 版 | 提供元 |
|------|-----------|--------|
| fastmcp | `3.4.7` | `overlays/fastmcp.nix` |
| anyio | `4.14.2` | nixpkgs |
| mcp | `1.29.1` | `overlays/godot-ai-v4-deps.nix` |
| websockets | `17.1` | `overlays/godot-ai-v4-deps.nix` |
| pydantic | `2.13.5` | `overlays/godot-ai-v4-deps.nix` |
| httpx | `0.28.1` | nixpkgs |
| uvicorn | `0.52.4` | `overlays/godot-ai-v4-deps.nix` |
| starlette | `1.6.0` | `overlays/godot-ai-v4-deps.nix` |
| h11 | `0.16.0` | nixpkgs |

> **pydantic-core**：pydantic 2.13.5 `pydantic-core==2.46.5` 要求（nixpkgs 2.46.4）。同 package Rust build 故、引上 時 `cargoDeps` 也 再取得 必要。

> **build 時 pin**：上流 `[build-system].requires` `setuptools==84.0.0` 固定（nixpkgs 83.0.0）。package 内 `postPatch` 緩和——此 pin 再現性 守 且 機能要件 非。

> **検証 打消 修正 不 理由**：v4 厳密固定 其 安全境界（接続／本文／frame／session 予算）奉仕 物。`runtime_dependencies.py` 緩 則 其 境界 静 弱 事 成。「検証 nixpkgs 合」非「依存 上流 合 引上」方 採。

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
