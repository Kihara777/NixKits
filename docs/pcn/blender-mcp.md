# blender-mcp

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-blender-mcp-x86_64.yml?branch=main&label=x86_64)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-blender-mcp-aarch64.yml?branch=main&label=aarch64)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/blender-mcp.md) | [English](../en/blender-mcp.md) | [日本語](../ja/blender-mcp.md) | [ｶﾀﾘｯｼｭ](../katalish/blender-mcp.md) | 偽中国語

Blender 用 MCP (Model Context Protocol) 伺服器。AI 代理対自然言語接続提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 1.0.0 |
| 上流 | [Blender Lab / blender_mcp](https://projects.blender.org/lab/blender_mcp) |
| 種別 | Python 包（setuptools） |
| 許諾 | GPL-3.0-or-later |
| Platform | x86_64 / aarch64 (riscv64 unsupported: dependency chain cross-compilation defect) |

## 構成

```
MCP Client  ⇐ MCP/stdio ⇒  blender-mcp  ⇐ TCP socket ⇒  Blender Add-on
```

- **blender-mcp**: MCP 依頼者 stdio 経由起動独立工程
- **Blender Add-on**: Blender 内部動作、TCP 接続経由要求受信

## 道具一覧

全 22 個 MCP 道具：

| 分類 | 道具 | 説明 |
|------|------|------|
| 符号実行 | `execute_blender_code` | 接続中 Blender 内 Python 符号実行 |
|  | `execute_blender_code_for_cli` | 背景 Blender 工程符号実行 |
| 場面概要 | `get_blendfile_summary_datablocks` | 資料区画数、作業区、描画機関 |
|  | `get_blendfile_summary_missing_files` | 未発見外部書類参照 |
|  | `get_blendfile_summary_of_linked_libraries` | 連結庫依存木 |
|  | `get_blendfile_summary_path_info` | 経路、保存状態、複製 |
|  | `get_blendfile_summary_usage_guess` | 場面書類主用途推測 |
| 物体 | `get_object_detail_summary` | 指定物体詳細摘要 |
|  | `get_objects_summary` | 場面収集階層物体一覧 |
| 画面取得 | `get_screenshot_of_area_as_image` | 単一区域 PNG 画面取得 |
|  | `get_screenshot_of_window_as_image` | 窓全体 PNG 画面取得 |
|  | `get_screenshot_of_window_as_json` | 窓配置 JSON 記述 |
| 導航 | `jump_to_tab_by_name` | 名称作業区札切替 |
|  | `jump_to_tab_by_space_type` | 空間種別作業区切替 |
|  | `jump_to_view3d_object_by_name` | 指定物体焦中 |
|  | `jump_to_view3d_object_data_by_name` | 資料区画名焦中 |
| 描画 | `render_thumbnail_to_path` | 小寸法縮小描画 |
|  | `render_viewport_to_path` | 現在場面描画 |
| 文書 | `get_python_api_docs` | Blender Python API 文書検索 |

> `_for_cli` 接尾辞付道具、Blender 事前接続不要、任意 .blend 書類対背景 Blender 経由動作。

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.blender-mcp ];

# 既定上乗 → pkgs.blender-mcp
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## MCP 依頼者設定

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

> `BLENDER_PATH` 任意、`_for_cli` 道具背景 Blender 用。`(pkgs.blender-mcp.override { blender = pkgs.blender; })` 事前設定可能。

## 拡張導入

```bash
# 導入経路
$out/share/blender/scripts/addons/blender_mcp_addon/

# 手動導入（nix 包複写）
cp -r /nix/store/*-blender-mcp-*/share/blender/scripts/addons/blender_mcp_addon \
  ~/.config/blender/4.4/scripts/addons/
```

Blender 内：Edit → Preferences → Add-ons → "Blender MCP" 検索 → 有効化。

## 緩衝

`cachix use nixkits`（flake `nixConfig` 自動宣言、初回使用時案内）。