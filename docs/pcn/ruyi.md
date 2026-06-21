# ruyi

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | 偽中国語

[RuyiSDK](https://ruyisdk.org) 軟件包管理器。RISC-V 開發環境工具安裝，仮想環境管理，配置，軟件包倉庫操作提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 0.51.0-alpha.20260616 |
| 上游 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 許可 | Apache 2.0 |
| 注意 | ァ段階軟件，API 変更可能性 |

## Dev Shell

```bash
nix develop nixkits#ruyi             # nixkits を flake input に追加済みの場合
nix develop github:Kihara777/NixKits#ruyi  # 事前設定不要のワンショット
```

`$PATH` `ruyi` 追加環境入。

## 安裝

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# または overlay 経由
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

> ruyi 軟件包(`packages-index`)接続必要。初回 `ruyi list` 時自動行。

## 模塊

NixOS 模塊 ruyi 運行時設置宣言的構成：

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

`/etc/xdg/ruyi/config.toml` 自動生成，環境変数設置，系統時軟件包自動更新。

宣言的仮想環境支持：

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits ruyi 構建 `patches/ruyi-nixos-compat.patch` 含，NixOS 固有問題透過的処理：

- **動的**： RISC-V 工具(GCC，QEMU 等) `/lib64/ld-linux-x86-64.so.2` 期待 NixOS 存在。 NixOS `ld.so` 経由実行。
- **工具修復**：GCC 内部 `cc1`，`as`，`collect2` 等 ruyi mux 。 `patchelf` ELF interpreter 自動修復。
- **Nix console_scripts 互換性**：`RUYI_ARGV0` 環境変数 Nix 失 `exec -a` 動作回復。

## 注意

- [ISCAS](https://www.iscas.ac.cn) RISC-V 開發者向
- 運行時依存(curl，gnutar，git，patchelf ) wrapProgram 注入
- ：ruff lint，mypy 型，pytest (320)，統合(52)— 通過
