# blender-mcp

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-blender-mcp-x86_64.yml?branch=main&label=x86_64%20v1.0.3)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-blender-mcp-aarch64.yml?branch=main&label=aarch64%20v1.0.3)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/blender-mcp.md) | English | [日本語](../ja/blender-mcp.md)  | [偽中国語](../pcn/blender-mcp.md)

An MCP (Model Context Protocol) server for Blender, providing AI assistants with a natural language interface to Blender's Python API.

## Info

| Item | Value |
|------|-------|
| Version | 1.0.3 |
| Upstream | [Blender Lab / blender_mcp](https://projects.blender.org/lab/blender_mcp) |
| Type | Python package (setuptools) |
| License | GPL-3.0-or-later |
| Platform | x86_64 / aarch64 (riscv64 unsupported: dependency chain cross-compilation defect) |
| Add-on type | Blender Extension (ships `blender_manifest.toml`, `id = "mcp"`) |
| Blender requirement | >= 5.1 (`blender_version_min = "5.1.0"`) |

## Architecture

```
MCP Client  ⇐ MCP/stdio ⇒  blender-mcp  ⇐ TCP socket ⇒  Blender Add-on
```

- **blender-mcp**: standalone process launched by the MCP client over stdio
- **Blender Add-on**: runs inside Blender, receives requests over a TCP socket

## Tools

26 MCP tools total (measured from the live `tools/list` output):

| Category | Tool | Description |
|----------|------|-------------|
| Code exec | `execute_blender_code` | Execute Python code in connected Blender |
|  | `execute_blender_code_for_cli` | Execute Python code in background Blender process |
| Scene summary | `get_blendfile_summary_datablocks` | Data-block counts, active workspace, render engine |
|  | `get_blendfile_summary_missing_files` | Missing external file references |
|  | `get_blendfile_summary_of_linked_libraries` | Linked library dependency tree |
|  | `get_blendfile_summary_path_info` | Path, save status, backups |
|  | `get_blendfile_summary_usage_guess` | Guess primary use-case of a blend file |
|  | `_for_cli` variants of the 5 above | Background-Blender version of each summary |
| Object query | `get_object_detail_summary` | Detailed summary of a named object |
|  | `get_objects_summary` | Scene collection hierarchy and object list |
| Screenshot | `get_screenshot_of_area_as_image` | Screenshot a single area (PNG) |
|  | `get_screenshot_of_window_as_image` | Screenshot the entire window (PNG) |
|  | `get_screenshot_of_window_as_json` | Window layout as JSON |
| Navigation | `jump_to_tab_by_name` | Switch workspace tab by name |
|  | `jump_to_tab_by_space_type` | Switch workspace by space type |
|  | `jump_to_view3d_object_by_name` | Focus on object by name |
|  | `jump_to_view3d_object_data_by_name` | Focus on object by data-block name |
| Render | `render_thumbnail_to_path` | Render a small thumbnail |
|  | `render_viewport_to_path` | Render the current scene |
| Docs | `get_python_api_docs` | Look up API docs for an identifier, or list matching modules |
|  | `search_api_docs` | Full-text search over the bundled Blender Python API reference |
|  | `search_manual_docs` | Full-text search over the bundled Blender user manual |

> Tools with `_for_cli` suffix work on any .blend file without a running Blender instance (via a background Blender process).

## Usage

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.blender-mcp ];

# Default overlay → pkgs.blender-mcp
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## MCP Client Config

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

> `BLENDER_PATH` is optional, used by `_for_cli` tools for background Blender processes. Preset via `(pkgs.blender-mcp.override { blender = pkgs.blender; })`.

## Add-on Installation

```bash
# Install path
$out/share/blender/scripts/addons/blender_mcp_addon/

# Manual install (copy from nix package)
cp -r /nix/store/*-blender-mcp-*/share/blender/scripts/addons/blender_mcp_addon \
  ~/.config/blender/5.1/extensions/user/
```

> Replace `5.1` with the Blender version you actually run (directory form: `~/.config/blender/<version>/`). **Blender 4.x cannot load** this add-on — the manifest requires `blender_version_min = "5.1.0"`.

> ⚠️ **Clear the read-only flag before upgrading**: the add-on directory inside the store is read-only (`dr-xr-xr-x`) and `cp -r` **copies the permissions along with it**, so a second install (with the target already present) fails with a flood of `Permission denied` and can leave a half-updated mixture of old and new files. Remove the old directory first:
>
> ```bash
> DEST=~/.config/blender/5.1/extensions/user/blender_mcp_addon
> chmod -R u+w "$DEST" 2>/dev/null   # the old copy is read-only; widen it before deleting
> rm -rf "$DEST"
> cp -r /nix/store/*-blender-mcp-*/share/blender/scripts/addons/blender_mcp_addon \
>   ~/.config/blender/5.1/extensions/user/
> chmod -R u+w "$DEST"               # so the next replacement works
> ```

In Blender: Edit → Preferences → Add-ons → search "MCP" → enable.

## Cache

`cachix use nixkits` (declared automatically via `nixConfig` in the flake; prompted on first use).