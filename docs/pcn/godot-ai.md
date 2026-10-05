# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

[中文](../zh/godot-ai.md) | [English](../en/godot-ai.md) | [日本語](../ja/godot-ai.md)  | 偽中国語

Godot 機関 高品質 MCP server 與 AI 工具 — MCP client **実行中 Godot editor** 接続、AI 助手 場景構築・節點脚本編集・信号配線・UI材料動画設定可能。46 MCP 工具 / 120+ 操作。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Python 応用（MCP server）|
| 上流 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| 版 | `4.2.3` |
| 許可 | MIT |
| Python | ≥ 3.11, < 3.15 |

## 架構

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**: MCP client stdio 起動 独立 Python 行程
- **Godot Editor Plugin**: Godot Asset Library 導入（`hi-godot/godot-ai`）、WebSocket 受信

## 依存

**v4 以降 fail-closed 厳密固定**：起動時 以下 十四 包 **正確 版** 照合、一 異 則 `RuntimeError` 送出 起動 拒否。4.2.3 九 項目 自 十四 項目 増加——`fastmcp-slim` / `httpx2` / `httpcore2` / `mcp-types` / `sniffio` 追加、且 `mcp` 大版 越（1.29.1 → 2.2.0：上流 wire types 独立 distribution `mcp-types` 分離、HTTP client `httpx2` 変更）。

| 依存 | 版 | 提供元 |
|------|-----------|--------|
| anyio | `4.15.1` | `overlays/godot-ai-v4-deps.nix` |
| fastmcp | `4.0.5` | `overlays/fastmcp.nix` |
| fastmcp-slim | `4.0.5` | `overlays/fastmcp.nix` |
| h11 | `0.16.0` | nixpkgs |
| httpx | `0.28.1` | nixpkgs |
| httpx2 | `2.13.0` | `overlays/godot-ai-v4-deps.nix` |
| httpcore2 | `2.13.0` | `overlays/godot-ai-v4-deps.nix` |
| mcp | `2.2.0` | `overlays/godot-ai-v4-deps.nix` |
| mcp-types | `2.2.0` | `overlays/godot-ai-v4-deps.nix`（nixpkgs 無 存在、上流 源 自 新規定義） |
| pydantic | `2.13.5` | `overlays/godot-ai-v4-deps.nix` |
| sniffio | `1.3.1` | nixpkgs |
| starlette | `1.6.0` | `overlays/godot-ai-v4-deps.nix` |
| uvicorn | `0.53.0` | `overlays/godot-ai-v4-deps.nix` |
| websockets | `17.1` | `overlays/godot-ai-v4-deps.nix` |

> 上表 十四 行 `packages/godot-ai.nix` 之 `dependencies` 與 **一対一対応**（數 與 版 皆 同一）、上流 `runtime_dependencies.py` 之 pin 表 亦 一致。

> **mcp-types**：nixpkgs 無 存在 故、`overlays/godot-ai-v4-deps.nix` 上流 同一 repository（`modelcontextprotocol/python-sdk` 之 `src/mcp-types/`）自 新規定義。

> **pydantic-core**：pydantic 2.13.5 `pydantic-core==2.46.5` 要求（nixpkgs 2.46.4）。同 package Rust build 故、引上 時 `cargoDeps` 也 再取得 必要。

> **build 時 pin**：上流 `[build-system].requires` `setuptools==84.0.0` 固定（nixpkgs 83.0.0）。package 内 `postPatch` 緩和——此 pin 再現性 守 且 機能要件 非。

> **検証 打消 修正 不 理由**：v4 厳密固定 其 安全境界（接続／本文／frame／session 予算）奉仕 物。`runtime_dependencies.py` 緩 則 其 境界 静 弱 事 成。「検証 nixpkgs 合」非「依存 上流 合 引上」方 採。

> **二 overlay 両方 実効 必要**：`overlays/fastmcp.nix` 與 `overlays/godot-ai-v4-deps.nix` 二 箇所（`flake.nix` 之 `godotPkgs` 與 `overlays/default.nix`）於 連結、両者 皆 nixpkgs 之 `pythonPackagesExtensions` 経由 取付。`python312.override { packageOverrides = …; }` 用 時 後者 前者 置換、fastmcp 上書 黙 捨 去、構築 却 成功。

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
3. Godot editor 起動、godot-ai WebSocket（`ws://127.0.0.1:9500`、既定 port。`--ws-port` 変更可）自動接続
