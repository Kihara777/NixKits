# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | 偽中国語

[RuyiSDK](https://ruyisdk.org) 之パッケージマネージャ。RISC-V 開発環境之ツールチェーン導入、仮想環境管理、デバイスプロビジョニング、パッケージリポジトリ操作提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.51.0-alpha.20260616 |
| 上流 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 許諾 | Apache 2.0 |
| 注意 | アルファ段階之ソフトウェア、API 変更之可能性 |

## Dev Shell

```bash
nix develop nixkits#ruyi             # nixkits を flake input に追加済みの場合
nix develop github:Kihara777/NixKits#ruyi  # 事前設定不要のワンショット
```

`$PATH`  `ruyi` 追加環境入。

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

#  overlay 経由
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 使方

```bash
ruyi --help
ruyi list --all          # 利用可能な全パッケージを表示
ruyi install <pkg>       # ツールチェーンをインストール
ruyi venv --toolchain <t> # 仮想環境を作成
ruyi device provision    # デバイスをプロビジョニング
```

> ruyi パッケージインデックス（`packages-index`）之クローンネットワーク接続必要。初回 `ruyi list` 時自動行。

## モジュル

NixOS モジュル ruyi 之ランタイム設定宣言的構成：

```nix
# flake.nix
{ modules = [ nixkits.nixosModules.ruyi ]; }

nixkits.ruyi = {
  enable = true;
  settings = {
    packages.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.mode = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

`/etc/xdg/ruyi/config.toml` 自動生成、環境変数設定、システムアクティベーション時パッケージインデックス自動更新。

宣言的仮想環境サポート：

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits 之 ruyi ビルド `patches/ruyi-nixos-compat.patch` 含、NixOS 固有之問題透過的処理：

- **動的リンカパス**：プリコンパイル RISC-V ツールチェーンバイナリ（GCC、QEMU 等） `/lib64/ld-linux-x86-64.so.2` 期待 NixOS 存在。パッチ NixOS 之 `ld.so` 経由実行リダイレクト。
- **ツールチェーンサブプロセス修復**：GCC 内部之 `cc1`、`as`、`collect2` 等之サブプロセス ruyi 之 mux バイパス。パッチ `patchelf`  ELF interpreter 自動修復。
- **Nix console_scripts 互換性**：`RUYI_ARGV0` 環境変数 Nix ラッパー失 `exec -a` 之動作回復。

## 注意

- [ISCAS](https://www.iscas.ac.cn)  RISC-V 開発者向メンテナンス
- ランタイム依存（curl、gnutar、git、patchelf ） wrapProgram 注入
- テストカバレッジ：ruff lint、mypy 型チェック、pytest ユニット（320）、統合（52）— 通過

## キャッシュ

`cachix use nixkits`（flake  `nixConfig` 自動宣言、flake input 與使用時自動案内）。
