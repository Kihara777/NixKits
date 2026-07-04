# blender-mcp

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20blender-mcp%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20blender-mcp%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/blender-mcp.md) | [日本語](../ja/blender-mcp.md) | [ｶﾀﾘｯｼｭ](../katalish/blender-mcp.md) | [偽中国語](../pcn/blender-mcp.md)

Blender 的 MCP (Model Context Protocol) 服务器，为 AI 助手提供 Blender Python API 的自然语言接口。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 1.0.0 |
| 上游 | [Blender Lab / blender_mcp](https://projects.blender.org/lab/blender_mcp) |
| 类型 | Python 包（setuptools） |
| 许可 | GPL-3.0-or-later |
| 平台 | x86_64 / aarch64（riscv64 不支持：依赖链交叉编译缺陷） |

## 架构

```
MCP Client  ⇐ MCP/stdio ⇒  blender-mcp  ⇐ TCP socket ⇒  Blender Add-on
```

- **blender-mcp**：独立进程，由 MCP 客户端通过 stdio 启动
- **Blender Add-on**：运行在 Blender 内部的插件，通过 TCP socket 接收请求

## 工具列表

共 22 个 MCP 工具：

| 类别 | 工具 | 说明 |
|------|------|------|
| 代码执行 | `execute_blender_code` | 在已连接的 Blender 中执行 Python 代码 |
|  | `execute_blender_code_for_cli` | 在后台 Blender 进程中执行 Python 代码 |
| 场景摘要 | `get_blendfile_summary_datablocks` | 数据块计数、活动工作区、渲染引擎 |
|  | `get_blendfile_summary_missing_files` | 缺失的外部文件引用 |
|  | `get_blendfile_summary_of_linked_libraries` | 链接库依赖树 |
|  | `get_blendfile_summary_path_info` | 路径、保存状态、备份 |
|  | `get_blendfile_summary_usage_guess` | 猜测 blend 文件主要用途 |
| 对象查询 | `get_object_detail_summary` | 指定对象的详细摘要 |
|  | `get_objects_summary` | 场景集合层级与对象列表 |
| 截屏 | `get_screenshot_of_area_as_image` | 单个区域截屏（PNG） |
|  | `get_screenshot_of_window_as_image` | 整个窗口截屏（PNG） |
|  | `get_screenshot_of_window_as_json` | 窗口布局 JSON 描述 |
| 导航 | `jump_to_tab_by_name` | 按名称切换工作区标签 |
|  | `jump_to_tab_by_space_type` | 按空间类型切换工作区 |
|  | `jump_to_view3d_object_by_name` | 聚焦到指定对象 |
|  | `jump_to_view3d_object_data_by_name` | 聚焦到数据块对应对象 |
| 渲染 | `render_thumbnail_to_path` | 渲染小尺寸缩略图 |
|  | `render_viewport_to_path` | 渲染当前场景 |
| 文档 | `get_python_api_docs` | 搜索 Blender Python API 文档 |

> 带 `_for_cli` 后缀的工具无需预先连接 Blender，可对任意 .blend 文件执行（通过后台 Blender 进程）。

## 引用

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.blender-mcp ];

# Default overlay → pkgs.blender-mcp
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## MCP 客户端配置

```json
{
  "mcpServers": {
    "blender": {
      "command": "blender-mcp",
      "env": { "BLENDER_PATH": "/path/to/blender" }
    }
  }
}
```

> `BLENDER_PATH` 为可选，用于 `_for_cli` 工具的后台 Blender 进程。nix 包可通过 `(pkgs.blender-mcp.override { blender = pkgs.blender; })` 预设路径。

## Add-on 安装

```bash
# 安装路径
$out/share/blender/scripts/addons/blender_mcp_addon/

# 手动安装（从 nix 包复制）
cp -r /nix/store/*-blender-mcp-*/share/blender/scripts/addons/blender_mcp_addon \
  ~/.config/blender/4.4/scripts/addons/
```

在 Blender 中：Edit → Preferences → Add-ons → 搜索 "Blender MCP" → 启用。

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。