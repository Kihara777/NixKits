# blender-mcp

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-blender-mcp-x86_64.yml?branch=main&label=x86_64%20v1.0.3)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-blender-mcp-aarch64.yml?branch=main&label=aarch64%20v1.0.3)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/blender-mcp.md) | [English](../en/blender-mcp.md) | 日本語  | [偽中国語](../pcn/blender-mcp.md)

Blender 向け MCP (Model Context Protocol) サーバー。AI アシスタントに Blender Python API への自然言語インターフェースを提供します。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 1.0.3 |
| 上流 | [Blender Lab / blender_mcp](https://projects.blender.org/lab/blender_mcp) |
| タイプ | Python パッケージ（setuptools） |
| ライセンス | GPL-3.0-or-later |
| プラットフォーム | x86_64 / aarch64（riscv64 非対応：依存チェーンのクロスコンパイル不具合） |
| アドオン種別 | Blender Extension（`blender_manifest.toml` 同梱、`id = "mcp"`） |
| Blender 要件 | >= 5.1（`blender_version_min = "5.1.0"`） |

## アーキテクチャ

```
MCP Client  ⇐ MCP/stdio ⇒  blender-mcp  ⇐ TCP socket ⇒  Blender Add-on
```

- **blender-mcp**: MCP クライアントが stdio 経由で起動する独立プロセス
- **Blender Add-on**: Blender 内部で動作し、TCP ソケット経由でリクエストを受信

## ツール一覧

全 26 個の MCP ツール（実際の `tools/list` 出力から計測）：

| カテゴリ | ツール | 説明 |
|----------|--------|------|
| コード実行 | `execute_blender_code` | 接続中の Blender で Python コードを実行 |
|  | `execute_blender_code_for_cli` | バックグラウンド Blender でコード実行 |
| シーン概要 | `get_blendfile_summary_datablocks` | データブロック数、ワークスペース、レンダーエンジン |
|  | `get_blendfile_summary_missing_files` | 見つからない外部ファイル参照 |
|  | `get_blendfile_summary_of_linked_libraries` | リンクライブラリ依存ツリー |
|  | `get_blendfile_summary_path_info` | パス、保存状態、バックアップ |
|  | `get_blendfile_summary_usage_guess` | blend ファイルの主な用途を推測 |
|  | 上記 5 項目の `_for_cli` 変種 | 同じ概要のバックグラウンド Blender 版 |
| オブジェクト | `get_object_detail_summary` | 指定オブジェクトの詳細サマリ |
|  | `get_objects_summary` | シーンコレクション階層とオブジェクト一覧 |
| スクリーンショット | `get_screenshot_of_area_as_image` | 単一エリアの PNG スクリーンショット |
|  | `get_screenshot_of_window_as_image` | ウィンドウ全体の PNG スクリーンショット |
|  | `get_screenshot_of_window_as_json` | ウィンドウレイアウトの JSON 記述 |
| ナビゲーション | `jump_to_tab_by_name` | 名前でワークスペースタブを切替 |
|  | `jump_to_tab_by_space_type` | スペースタイプでワークスペースを切替 |
|  | `jump_to_view3d_object_by_name` | 指定オブジェクトにフォーカス |
|  | `jump_to_view3d_object_data_by_name` | データブロック名でフォーカス |
| レンダリング | `render_thumbnail_to_path` | 小サイズのサムネイルをレンダリング |
|  | `render_viewport_to_path` | 現在のシーンをレンダリング |
| ドキュメント | `get_python_api_docs` | 識別子の API ドキュメントを照会、または一致するモジュールを列挙 |
|  | `search_api_docs` | 同梱の Blender Python API リファレンスを全文検索 |
|  | `search_manual_docs` | 同梱の Blender ユーザーマニュアルを全文検索 |

> `_for_cli` サフィックス付きツールは Blender を事前接続せず、任意の .blend ファイルに対してバックグラウンド Blender 経由で動作します。

## 参照

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.blender-mcp ];

# Default overlay → pkgs.blender-mcp
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## MCP クライアント設定

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

> `BLENDER_PATH` はオプションで、`_for_cli` ツールのバックグラウンド Blender 用です。`(pkgs.blender-mcp.override { blender = pkgs.blender; })` で事前設定可能。

## Add-on インストール

```bash
# インストールパス
$out/share/blender/scripts/addons/blender_mcp_addon/

# 手動インストール（nix パッケージからコピー）
cp -r /nix/store/*-blender-mcp-*/share/blender/scripts/addons/blender_mcp_addon \
  ~/.config/blender/5.1/extensions/user/
```

> `5.1` は実際に使用している Blender のバージョンに置き換えてください（ディレクトリ形式：`~/.config/blender/<バージョン>/`）。**Blender 4.x では読み込めません** — manifest が `blender_version_min = "5.1.0"` を要求します。

> ⚠️ **更新時は先に読み取り専用を解除**：store 内のアドオンディレクトリは読み取り専用（`dr-xr-xr-x`）で、`cp -r` は**権限ごと複製**します。そのため 2 回目のインストール（対象が既存）は大量の `Permission denied` で失敗し、新旧が混在した半端な状態を残す恐れがあります。再インストール時は先に旧ディレクトリを削除してください：
>
> ```bash
> DEST=~/.config/blender/5.1/extensions/user/blender_mcp_addon
> chmod -R u+w "$DEST" 2>/dev/null   # 旧コピーは読み取り専用。削除前に書き込み権限を付与
> rm -rf "$DEST"
> cp -r /nix/store/*-blender-mcp-*/share/blender/scripts/addons/blender_mcp_addon \
>   ~/.config/blender/5.1/extensions/user/
> chmod -R u+w "$DEST"               # 次回の置換のため
> ```

Blender で：Edit → Preferences → Add-ons → "MCP" を検索 → 有効化。

## キャッシュ

`cachix use nixkits`（flake の `nixConfig` で自動宣言、初回使用時にプロンプト表示）。