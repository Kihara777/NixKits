# obs-bilibili-stream

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-x86_64.yml?branch=main&label=x86_64%20v2.1.5)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-aarch64.yml?branch=main&label=aarch64%20v2.1.5)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | 日本語  | [偽中国語](../pcn/obs-bilibili-stream.md)

OBS Studio の Bilibili ライブ配信プラグイン。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 2.1.5 |
| アップストリーム | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| プラットフォーム | Linux only |

## 参照

**推奨：NixOS モジュール**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**手動**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-bilibili-stream ];
  };
}
```

**Home Manager**

```nix
home.packages = [ inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream ];
```

> 警告 -- **`home.packages` で入れるだけでは OBS はこれを読み込みません**：OBS は `OBS_PLUGINS_PATH` でプラグインを探し、この変数は nixpkgs の `wrapOBS`（＝ `programs.obs-studio.plugins`）だけが注入します。`home.packages` は `.so` をプロファイルに置くだけで、OBS はそのパスを走査しません。したがって：
>
> - **NixOS では**上のモジュールか `programs.obs-studio.plugins` を使用（推奨）
> - **非 NixOS / Home Manager のみ**の場合は、OBS のプラグイン探索パスに `.../lib/obs-plugins` が含まれるよう自分で確保してください（`wrapOBS` で包装する、または `.so` を手動配置）

## キャッシュ

`cachix use nixkits`（flake は `nixConfig` で自動宣言、flake input として使用時に自動案内）。
