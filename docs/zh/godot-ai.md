# godot-ai

[![godot-ai](https://img.shields.io/badge/Godot-Asset%20Library-478cbf?logo=godotengine&logoColor=white)](https://github.com/hi-godot/godot-ai)

中文 | [English](../en/godot-ai.md) | [日本語](../ja/godot-ai.md)  | [偽中国語](../pcn/godot-ai.md)

Production-grade MCP server 和 AI 工具，用于 Godot 引擎 — 连接 MCP 客户端到**运行中的 Godot 编辑器**，让 AI 助手构建场景、编辑节点/脚本、连线信号、配置 UI/材质/动画等。46 个 MCP 工具 / 120+ 操作。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Python 应用（MCP server）|
| 上游 | [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) |
| 版本 | `4.2.3` |
| 许可 | MIT |
| Python | ≥ 3.11, < 3.15 |

## 架构

```
MCP Client  ⇐ MCP/stdio ⇒  godot-ai  ⇐ WebSocket ⇒  Godot Editor Plugin
```

- **godot-ai**：独立 Python 进程，由 MCP 客户端通过 stdio 启动
- **Godot 编辑器插件**：从 Godot Asset Library 一键安装（`hi-godot/godot-ai`），接收 WebSocket 请求

## 依赖

**v4 起为 fail-closed 精确锁定**：启动时校验下列 14 个包的**精确版本**，任一不符即 `RuntimeError` 拒绝启动。4.2.3 由 9 项增至 14 项——新增 `fastmcp-slim` / `httpx2` / `httpcore2` / `mcp-types` / `sniffio`，且 `mcp` 跨大版本（1.29.1 → 2.2.0：上游把 wire types 拆成独立发行版 `mcp-types`，HTTP 客户端换成 `httpx2`）。

| 依赖 | 版本 | 来源 |
|------|------|------|
| anyio | `4.15.1` | `overlays/godot-ai-v4-deps.nix` |
| fastmcp | `4.0.5` | `overlays/fastmcp.nix` |
| fastmcp-slim | `4.0.5` | `overlays/fastmcp.nix` |
| h11 | `0.16.0` | nixpkgs |
| httpx | `0.28.1` | nixpkgs |
| httpx2 | `2.13.0` | `overlays/godot-ai-v4-deps.nix` |
| httpcore2 | `2.13.0` | `overlays/godot-ai-v4-deps.nix` |
| mcp | `2.2.0` | `overlays/godot-ai-v4-deps.nix` |
| mcp-types | `2.2.0` | `overlays/godot-ai-v4-deps.nix`（nixpkgs 无此包，源内新建定义） |
| pydantic | `2.13.5` | `overlays/godot-ai-v4-deps.nix` |
| sniffio | `1.3.1` | nixpkgs |
| starlette | `1.6.0` | `overlays/godot-ai-v4-deps.nix` |
| uvicorn | `0.53.0` | `overlays/godot-ai-v4-deps.nix` |
| websockets | `17.1` | `overlays/godot-ai-v4-deps.nix` |

> 上表 14 行与 `packages/godot-ai.nix` 的 `dependencies` **逐项对应**（数目与版本都相同），也与上游 `runtime_dependencies.py` 的 pin 表一致。

> **mcp-types**：nixpkgs 里不存在，由 `overlays/godot-ai-v4-deps.nix` 从上游同一仓库（`modelcontextprotocol/python-sdk` 的 `src/mcp-types/`）新建定义。

> **pydantic-core**：pydantic 2.13.5 要求 `pydantic-core==2.46.5`（nixpkgs 为 2.46.4）。该包由 Rust 构建，抬版时 `cargoDeps` 须一并重取。

> **构建期 pin**：上游 `[build-system].requires` 写死 `setuptools==84.0.0`（nixpkgs 为 83.0.0），由包内 `postPatch` 放宽——该 pin 是可复现性守卫而非功能需求。

> **为何不打补丁绕过校验**：v4 的精确锁服务于其安全边界（连接 / 消息体 / 帧 / 会话预算），放宽 `runtime_dependencies.py` 会静默削弱该边界。故采用「抬依赖对齐上游」而非「改校验迁就 nixpkgs」。

> **两个 overlay 必须同时生效**：`overlays/fastmcp.nix` 与 `overlays/godot-ai-v4-deps.nix` 经 `flake.nix` 的 `godotPkgs` 与 `overlays/default.nix` 两处链入，并且都以 nixpkgs 的 `pythonPackagesExtensions` 挂载——用 `python312.override { packageOverrides = …; }` 时后者会**替换**前者，导致 fastmcp 覆盖被静默丢弃而构建照常成功。

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
3. 启动 Godot 编辑器，godot-ai 自动通过 WebSocket 连接到 `ws://127.0.0.1:9500`（默认端口，可用 `--ws-port` 更改）

