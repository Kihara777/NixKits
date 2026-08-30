# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

中文 | [English](../en/godot-ai.md) | [日本語](../ja/godot-ai.md)  | [偽中国語](../pcn/godot-ai.md)

Production-grade MCP server 和 AI 工具，用于 Godot 引擎 — 连接 MCP 客户端到**运行中的 Godot 编辑器**，让 AI 助手构建场景、编辑节点/脚本、连线信号、配置 UI/材质/动画等。43 个 MCP 工具 / 120+ 操作。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Python 应用（MCP server）|
| 上游 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| 版本 | `3.2.4` |
| 许可 | MIT |
| Python | ≥ 3.11 |

## 架构

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**：独立 Python 进程，由 MCP 客户端通过 stdio 启动
- **Godot 编辑器插件**：从 Godot Asset Library 一键安装（`hi-godot/godot-ai`），接收 WebSocket 请求

## 依赖

| 依赖 | 来源 | 版本要求 |
|------|------|--------|
| fastmcp | NixKits overlay | ≥ 3.4.0（nixpkgs 锁定 3.3.1 有 circular-import bug）|
| websockets | nixpkgs | ≥ 13.0 |
| pydantic | nixpkgs | ≥ 2.0 |
| httpx | nixpkgs | ≥ 0.27 |
| uvicorn | nixpkgs | ≥ 0.23 |
| starlette | nixpkgs | ≥ 0.40 |

> **fastmcp 3.4 升级**：nixpkgs 的 fastmcp 3.3.1 有 circular-import bug（`fastmcp.server` 无法导入）。NixKits 通过 `overlays/fastmcp.nix` 升级到 3.4.7，联动升级 fastmcp-slim + py-key-value-aio 0.4.5。

## 安装与使用

### 系统安装

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.godot-ai ];
```

### 试用

```bash
godot-ai
```

MCP 客户端配置（Claude Code / Codex 等）：

```json
{
  "Godot": {
    "command": "godot-ai",
    "env": {}
  }
}
```

### 前置条件

1. Godot 4.5+ 编辑器（推荐 4.7+）
2. 从 Godot Asset Library 安装 `hi-godot/godot-ai` 插件（编辑器内 **AssetLib** 标签页）
3. 启动 Godot 编辑器，godot-ai 自动通过 WebSocket 连接到 `ws://127.0.0.1:9876`

