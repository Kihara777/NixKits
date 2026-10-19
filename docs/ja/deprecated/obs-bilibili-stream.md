# obs-bilibili-stream 自前パッケージ（廃止済み）

[中文](../../zh/deprecated/obs-bilibili-stream.md) | [English](../../en/deprecated/obs-bilibili-stream.md) | 日本語  | [偽中国語](../../pcn/deprecated/obs-bilibili-stream.md)

[← 廃止プロジェクト索引](../../../DEPRECATED.md)

**状態**：廃止（2026-10-19）
**旧位置**：`packages/obs-bilibili-stream.nix` + `.github/workflows/build-obs-bilibili-stream-{x86_64,aarch64}.yml`
**現状**：パッケージ定義と二つのビルドワークフローは削除済み；`modules/obs-bilibili-stream.nix` は残し、上流パッケージを参照するよう変更；overlay は同名の互換別名を保持。

### 私たちが貢献したパッケージが上流に収録された：2026-10-19、[NixOS/nixpkgs#574725](https://github.com/NixOS/nixpkgs/pull/574725) がマージ。

## かつて何を解決していたか

NixKits は 2026-10-10 に obs-bilibili-stream（OBS の Bilibili ライブ配信プラグイン）を
初めてパッケージ化し、本リポジトリのユーザーが overlay / モジュール経由で導入できる
ようにした。二つのワークフローが x86_64 と aarch64 の成果物をビルドし、
Cachix キャッシュへ push していた。

## なぜ廃止できるか

上流 nixpkgs が本パッケージを収録済みであり、**その定義はここから貢献し、
レビューで改良されたもの**である：

| 項目 | 本リポジトリ旧版 | 上流マージ版 |
|---|---|---|
| `strictDeps` / `__structuredAttrs` | なし | あり |
| CMake フラグ | 手書き文字列（`-DOBS_SOURCE=` を含む） | `lib.cmakeBool` |
| `platforms` | `lib.platforms.linux` をハードコード | `inherit (obs-studio.meta) platforms` |
| `maintainers` | `[ ]` | `[ kitsunori ]` |

ローカルコピーを保守し続けても上流から乖離するだけである。上流版は
aarch64-linux でも `nixpkgs-review` により `1 package built` と検証済み。

## 廃止後の設定方法

**NixOS モジュール（本リポジトリが保持、内部は上流パッケージ参照に変更済み）**

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

**互換別名**：`pkgs.obs-bilibili-stream`（overlay）と
`nixkits.packages.<system>.obs-bilibili-stream` は引き続き利用でき、同じ上流
パッケージを指す。

## 記録に値する一つの判断

廃止時点で本リポジトリの版はすでに**上流より遅れていた**（`__structuredAttrs` などを欠く）。
先にローカルコピーを「同期」してから廃止するのは無駄な作業だった。
**判据は「上流版が私たちの版を覆っているか」であり、「私たちの版が今もビルドできるか」
ではない** —— ビルドできる古いコピーでも廃止すべきである。
