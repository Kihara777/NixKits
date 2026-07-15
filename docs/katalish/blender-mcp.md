# blender-mcp

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-blender-mcp-x86_64.yml?branch=main&label=x86_64%20v1.0.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-blender-mcp-aarch64.yml?branch=main&label=aarch64%20v1.0.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/blender-mcp.md) | [English](../en/blender-mcp.md) | [日本語](../ja/blender-mcp.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/blender-mcp.md)

ｱﾝ MCP (Model Context Protocol) ｻｰﾊﾞｰ ﾌｫｱ Blender, ﾌﾟﾗｵﾌﾞｲﾃﾞｨﾝｸﾞ AI ｱｼｽﾀﾝﾂ ｳｨｽﾞ ｱ ﾅﾁｭﾗﾙ ﾗﾝｹﾞｰｼﾞ ｲﾝﾀｰﾌｪｰｽ ﾄｩ Blender Python API.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 1.0.0 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [Blender Lab / blender_mcp](https://projects.blender.org/lab/blender_mcp) |
| ﾀｲﾌﾟ | Python ﾊﾟｯｹｰｼﾞ (setuptools) |
| ﾗｲｾﾝｽ | GPL-3.0-or-later |
| ﾌﾟﾗｯﾄﾌｫｰﾑ | x86_64 / aarch64 (riscv64 unsupported: ﾃﾞｨﾍﾟﾝﾃﾞﾝｼｰ chain cross-compilation defect) |

## ｱｰｷﾃｸﾁｬ

```
MCP ｸﾗｲｱﾝﾄ  ⇐ MCP/stdio ⇒  blender-mcp  ⇐ TCP socket ⇒  Blender Add-on
```

- **blender-mcp**: standalone process launched by ｻﾞ MCP ｸﾗｲｱﾝﾄ over stdio
- **Blender Add-on**: runs inside Blender, receives requests over a TCP socket

## ﾂｰﾙｽﾞ

22 MCP ﾂｰﾙｽﾞ ｲﾝ total:

| ｶﾃｺﾞﾘ | ﾂｰﾙ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
|----------|------|-------------|
| Code exec | `execute_blender_code` | ｴｸﾞｾﾞｷｭｰﾄ Python code ｲﾝ connected Blender |
|  | `execute_blender_code_for_cli` | ｴｸﾞｾﾞｷｭｰﾄ Python code ｲﾝ background Blender process |
| Scene ｻﾏﾘｰ | `get_blendfile_summary_datablocks` | Data-block counts, active workspace, render engine |
|  | `get_blendfile_summary_missing_files` | Missing external ﾌｧｲﾙ references |
|  | `get_blendfile_summary_of_linked_libraries` | Linked library ﾃﾞｨﾍﾟﾝﾃﾞﾝｼｰ tree |
|  | `get_blendfile_summary_path_info` | Path, save status, backups |
|  | `get_blendfile_summary_usage_guess` | Guess primary use-case of a blend ﾌｧｲﾙ |
| Object query | `get_object_detail_summary` | Detailed ｻﾏﾘｰ of a named object |
|  | `get_objects_summary` | Scene ｺﾚｸｼｮﾝ hierarchy ｱﾝﾄﾞ object list |
| Screenshot | `get_screenshot_of_area_as_image` | Screenshot a single area (PNG) |
|  | `get_screenshot_of_window_as_image` | Screenshot ｻﾞ entire window (PNG) |
|  | `get_screenshot_of_window_as_json` | Window layout as JSON |
| ﾅﾋﾞｹﾞｰｼｮﾝ | `jump_to_tab_by_name` | Switch workspace tab by name |
|  | `jump_to_tab_by_space_type` | Switch workspace by space type |
|  | `jump_to_view3d_object_by_name` | Focus on object by name |
|  | `jump_to_view3d_object_data_by_name` | Focus on object by data-block name |
| ﾚﾝﾀﾞｰ | `render_thumbnail_to_path` | Render a small thumbnail |
|  | `render_viewport_to_path` | Render ｻﾞ current scene |
| Docs | `get_python_api_docs` | Search Blender Python API ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ |

> ﾂｰﾙｽﾞ ｳｨｽﾞ `_for_cli` suffix work on any .blend ﾌｧｲﾙ without a running Blender instance (via a background Blender process).

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.blender-mcp ];

# Default ｵｰﾊﾞｰﾚｲ → pkgs.blender-mcp
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## MCP ｸﾗｲｱﾝﾄ ｺﾝﾌｨｸﾞ

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

> `BLENDER_PATH` ｲｽﾞ optional, used by `_for_cli` ﾂｰﾙｽﾞ ﾌｫｱ background Blender processes. Preset via `(pkgs.blender-mcp.override { blender = pkgs.blender; })`.

## Add-on ｲﾝｽﾄｰﾙ

```bash
# ｲﾝｽﾄｰﾙ path
$out/share/blender/scripts/addons/blender_mcp_addon/

# Manual ｲﾝｽﾄｰﾙ (copy ﾌﾛﾑ nix ﾊﾟｯｹｰｼﾞ)
cp -r /nix/store/*-blender-mcp-*/share/blender/scripts/addons/blender_mcp_addon \
  ~/.config/blender/4.4/scripts/addons/
```

In Blender: Edit → Preferences → Add-ons → search "Blender MCP" → enable.

## ｷｬｯｼｭ

`cachix use nixkits` (declared ｵｰﾄﾏﾃｨｯｸﾘｰ via `nixConfig` in ｻﾞ flake; prompted on first use).