# codewhale-sudo

[中文](../zh/codewhale-sudo.md) | [English](codewhale-sudo.en.md) | 日本語  | [偽中国語](codewhale-sudo.pcn.md)

codewhale v0.9.0 は `prctl(PR_SET_NO_NEW_PRIVS)` をデフォルトで有効化し、`sudo` をブロックします。Codewhale は静的リンクのため `LD_PRELOAD` は機能しません。このパッチは ptrace ベースのシステムコールインターセプターでカーネル境界にて該当 prctl 呼出を傍受し、sudo 機能を復元します。

## 基本情報

| 項目 | 値 |
|------|-----|
| パッチ | `overlays/codewhale-sudo-fix.nix` |
| 種類 | overlay（codewhale パッケージを上書き） |
| 上流 | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |

## インストール

```nix
nixpkgs.overlays = [ inputs.nixkits.overlays.codewhale-sudo-fix ];
```

## 前提条件

codewhale は PTY 経由でコマンドを実行するため、**パスワード無し sudo** が必要です。ユーザーを `wheel` グループに追加し、NixOS を設定してください：

```nix
security.sudo = {
  enable = true;
  wheelNeedsPassword = false;  # wheel グループにパスワード無し sudo
};
users.users.you = {
  extraGroups = [ "wheel" ];
};
```


## 注意点

- このパッチはサンドボックスセキュリティを低下させるため、`sudo` が必要な開発環境でのみ使用してください
- `sudo` 機能は正しい NixOS パスワード無し設定に依存し、パッチ自体はパスワード認証をバイパスしません

## キャッシュ

パッチは overlay のため、バイナリキャッシュにありません。
