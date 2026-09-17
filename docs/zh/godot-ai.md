# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

中文 | [English](../en/godot-ai.md) | [日本語](../ja/godot-ai.md)  | [偽中国語](../pcn/godot-ai.md)

Production-grade MCP server 和 AI 工具，用于 Godot 引擎 — 连接 MCP 客户端到**运行中的 Godot 编辑器**，让 AI 助手构建场景、编辑节点/脚本、连线信号、配置 UI/材质/动画等。43 个 MCP 工具 / 120+ 操作。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Python 应用（MCP server）|
| 上游 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| 版本 | `4.1.0` |
| 许可 | MIT |
| Python | ≥ 3.11 |

## 架构

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**：独立 Python 进程，由 MCP 客户端通过 stdio 启动
- **Godot 编辑器插件**：从 Godot Asset Library 一键安装（`hi-godot/godot-ai`），接收 WebSocket 请求

## 依赖

**v4 起为 fail-closed 精确锁定**：启动时校验下列 9 个包的**精确版本**，任一不符即 `RuntimeError` 拒绝启动。nixpkgs 在 5 个包上落后，故由 `overlays/godot-ai-v4-deps.nix` 抬到上游要求。

| 依赖 | 上游要求 | nixpkgs 提供 | 来源 |
|------|---------|-------------|------|
| fastmcp | `==3.4.7` | 3.4.7 | `overlays/fastmcp.nix` |
| anyio | `==4.14.2` | 4.14.2 | nixpkgs |
| mcp | `==1.29.1` | 1.29.0 | **overlay 抬版** |
| websockets | `==17.1` | 16.1 | **overlay 抬版** |
| pydantic | `==2.13.5` | 2.13.4 | **overlay 抬版** |
| httpx | `==0.28.1` | 0.28.1 | nixpkgs |
| uvicorn | `==0.52.4` | 0.51.0 | **overlay 抬版** |
| starlette | `==1.6.0` | 1.3.1 | **overlay 抬版** |
| h11 | `==0.16.0` | 0.16.0 | nixpkgs |

> **pydantic-core**：pydantic 2.13.5 要求 `pydantic-core==2.46.5`（nixpkgs 为 2.46.4），该包由 Rust 构建，抬版时 `cargoDeps` 须一并重取。

> **构建期 pin**：上游 `[build-system].requires` 写死 `setuptools==84.0.0`（nixpkgs 为 83.0.0），由包内 `postPatch` 放宽——该 pin 是可复现性守卫而非功能需求。

> **为什么不是打补丁绕过校验**：v4 的精确锁是为其安全边界（连接/消息体/帧/会话预算）服务的，放宽 `runtime_dependencies.py` 会静默削弱该边界。故采用「抬依赖对齐上游」而非「改校验迁就 nixpkgs」。

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

