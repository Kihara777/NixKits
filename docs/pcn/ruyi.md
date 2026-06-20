# ruyi

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | 偽中国語 | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) 

[RuyiSDK](https://ruyisdk.org) パッケージマネージャー。RISC-V 開発環境ツールチェーンインストール，仮想環境管理，デバイスプロビジョニング，パッケージリポジトリ操作提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.51.0-alpha.20260616 |
| アップストリーム | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ライセンス | Apache 2.0 |
| 注意 | アルファ段階ソフトウェア，API 変更可能性 |

## Dev Shell

```bash
nix develop nix-kits#ruyi             # nix-kits  flake input 追加済場合
nix develop github:Kihara777/NixKits#ruyi  # 事前設定不要ワンショット
```

`$PATH`  `ruyi` 追加環境入。

## インストール

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

#  overlay 経由
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 使方

```bash
ruyi --help
ruyi list --all          # 利用可能全パッケージ表示
ruyi install <pkg>       # ツールチェーンインストール
ruyi venv --toolchain <t> # 仮想環境作成
ruyi device provision    # デバイスプロビジョニング
```

> ruyi パッケージインデックス(`packages-index`)クローンネットワーク接続必要。初回 `ruyi list` 時自動行。

## モジュール

NixOS モジュール ruyi ランタイム設定宣言的構成：

```nix
# flake.nix
{ modules = [ nix-kits.nixosModules.ruyi ]; }

services.ruyi = {
  enable = true;
  settings = {
    packages.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.mode = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

`/etc/xdg/ruyi/config.toml` 自動生成，環境変数設定，システムアクティベーション時パッケージインデックス自動更新。

宣言的仮想環境サポート：

```nix
services.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits  ruyi ビルド `patches/ruyi-nixos-compat.patch` 含，NixOS 固有問題透過的処理：

- **動的リンカパス**：プリコンパイル RISC-V ツールチェーンバイナリ(GCC，QEMU 等) `/lib64/ld-linux-x86-64.so.2` 期待 NixOS 存在。パッチ NixOS  `ld.so` 経由実行リダイレクト。
- **ツールチェーンサブプロセス修復**：GCC 内部 `cc1`，`as`，`collect2` 等サブプロセス ruyi  mux バイパス。パッチ `patchelf`  ELF interpreter 自動修復。
- **Nix console_scripts 互換性**：`RUYI_ARGV0` 環境変数 Nix ラッパー失 `exec -a` 動作回復。

## 注意

- [ISCAS](https://www.iscas.ac.cn)  RISC-V 開発者向メンテナンス
- ランタイム依存(curl，gnutar，git，patchelf ) wrapProgram 注入
- テストカバレッジ：ruff lint，mypy 型チェック，pytest ユニット(320)，統合(52)— 通過
