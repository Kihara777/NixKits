# opencode-telegram

[OpenCode](https://opencode.ai) 的 Telegram Bot 客户端。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.20.5 |
| 上游 | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## 使用

```bash
opencode-telegram start           # 交互式配置
opencode-telegram start --daemon  # 后台运行
opencode-telegram status          # 查看状态
opencode-telegram stop            # 停止
```

## 引用

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.opencode-telegram ];

# Default overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## 系统服务

```nix
systemd.services.opencode-telegram = {
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "simple";
    ExecStart = "${pkgs.opencode-telegram}/bin/opencode-telegram start";
    Restart = "on-failure";
    RestartSec = 10;
    User = "kix";
    Group = "users";
    Environment = [
      "PATH=${pkgs.opencode}/bin:${pkgs.opencode-telegram}/bin:/run/wrappers/bin"
    ];
  };
};
```
