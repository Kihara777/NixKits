# codewhale-sudo

[中文](../zh/codewhale-sudo.md) | [English](codewhale-sudo.en.md) | [日本語](codewhale-sudo.ja.md)  | 偽中国語

codewhale v0.9.0 既定 `prctl(PR_SET_NO_NEW_PRIVS)` 防禦縦深有効、`sudo` 遮断。此補丁 `LD_PRELOAD` shim 該当 prctl 呼出傍受、sudo 機能復元。

## 基本情報

| 項目 | 値 |
|------|-----|
| 補丁 | `overlays/codewhale-sudo-fix.nix` |
| 種別 | overlay（codewhale 包上書） |
| 上流 | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |

## 導入

```nix
nixpkgs.overlays = [ inputs.nixkits.overlays.codewhale-sudo-fix ];
```

## 前提条件

codewhale PTY 経由命令実行、**免暗号 sudo** 必要。利用者 `wheel` 組追加、NixOS 設定：

```nix
security.sudo = {
  enable = true;
  wheelNeedsPassword = false;  # wheel 組免暗号 sudo
};
users.users.you = {
  extraGroups = [ "wheel" ];
};
```

> `/etc/nixos` 実際設定参照。

## 注意点

- 此補丁砂箱安全性低下、`sudo` 必要開発環境専用
- `sudo` 機能正 NixOS 免暗号設定依存、補丁自躰暗号認証不迂回

## 緩衝

補丁 overlay 非二進緩衝。
