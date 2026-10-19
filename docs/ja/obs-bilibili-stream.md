# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | 日本語  | [偽中国語](../pcn/obs-bilibili-stream.md)

**状態**：廃止（2026-10-19）—— 上流 nixpkgs が収録済みのため、本リポジトリは自前ビルドを終了した。
詳細は[廃止プロジェクトの説明](deprecated/obs-bilibili-stream.md)。

## 現在の使い方

**NixOS モジュール（本リポジトリが提供継続、内部は上流パッケージを参照）**

```nix
{
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**nixpkgs を直接使う**

```nix
{
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
  };
}
```

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 2.1.5（nixpkgs に追従） |
| 上流 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| nixpkgs 属性 | `obs-studio-plugins.obs-bilibili-stream` |
| 私たちの貢献 | [NixOS/nixpkgs#574725](https://github.com/NixOS/nixpkgs/pull/574725)（2026-10-19 マージ） |
| プラットフォーム | x86_64 / aarch64（riscv64 非対応：`obs-studio` の `meta.platforms` に含まれない） |

> ⚠️ **`home.packages` だけで入れたパッケージは OBS に読み込まれない**：OBS は
> `OBS_PLUGINS_PATH` でプラグインを探し、この変数は nixpkgs の `wrapOBS`（すなわち
> `programs.obs-studio.plugins`）だけが注入する。`home.packages` は `.so` を
> プロファイルに置くだけで、OBS はそのパスを走査しない。したがって：
>
> - **NixOS では**上のモジュールか `programs.obs-studio.plugins` を使う（推奨）
> - **NixOS 以外 / Home Manager のみ**の場合は、OBS のプラグイン探索パスに
>   `.../lib/obs-plugins` が含まれることを自分で確保する（`wrapOBS` で包む、
>   または `.so` を手動配置）
