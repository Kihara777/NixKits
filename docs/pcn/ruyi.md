# ruyi

[中文](../../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../../katalish/ruyi.md) | [偽中国語](ruyi.md)

[RuyiSDK](https://ruyisdk.org) 軟件包管理器RISC-V 開発環境工具安裝仮想環境管理設備軟件包倉庫操作提供

## 基本情報

|項目|値|
|------|-----|
|版本|0.51.0-alpha.20260616|
||[ruyisdk/ruyi](https://github.com/ruyisdk/ruyi)|
|許可|Apache 2.0|
|注意|段階軟件API 変更可能性|

## Dev Shell

```bash
nix develop nix-kits#ruyi # nix-kits flake input 追加済場合
nix develop github:Kihara777/NixKits#ruyi # 事前設定不要
```

`$PATH` `ruyi` 追加環境入

## 安裝

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

# overlay 経由
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 使方

```bash
ruyi --help
ruyi list --all # 利用可能全軟件包表示
ruyi install <pkg> # 工具安裝
ruyi venv --toolchain <t> # 仮想環境作成
ruyi device provision # 設備
```

> ruyi 軟件包`packages-index`接続必要初回 `ruyi list` 時自動行

## 模塊

NixOS 模塊 ruyi 運行時設定宣言的構成：

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
telemetryOptout = true; # RUYI_TELEMETRY_OPTOUT=1
};
```

`/etc/xdg/ruyi/config.toml` 自動生成環境変数設定系統時軟件包自動更新

宣言的仮想環境支持：

```nix
services.ruyi.venvs.riscv = {
profile = "gnu-plct";
toolchain = "gnu-plct";
dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 互換性

NixKits ruyi 構建 `patches/ruyi-nixos-compat.patch` 含NixOS 固有問題透過的処理：

- **動的**： RISC-V 工具GCCQEMU 等 `/lib64/ld-linux-x86-64.so.2` 期待 NixOS 存在補丁 NixOS `ld.so` 経由実行
- **工具修復**：GCC 内部 `cc1``as``collect2` 等 ruyi mux 補丁 `patchelf` ELF interpreter 自動修復
- **Nix console_scripts 互換性**：`RUYI_ARGV0` 環境変数 Nix 失 `exec -a` 動作回復

## 注意

- [ISCAS](https://www.iscas.ac.cn) RISC-V 開発者向維護
- 運行時依存curlgnutargitpatchelf  wrapProgram 注入
- ：ruff lintmypy 型pytest 320統合52— 通過