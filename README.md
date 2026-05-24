# NixKits

个人 NixOS flake 仓库，提供自定义包、overlay 和 NixOS 模块。

## 添加为 flake input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nix-kits.url = "github:Kihara777/NixKits";
  };
}
```

## 支持系统

| 包 | x86_64-linux | aarch64-linux |
|---|:---:|:---:|
| kitsfmt | ✅ | ✅ |
| opencode-telegram | ✅ | ✅ |
| mcp-searxng | ✅ | ✅ |
| obs-bilibili-stream | ✅ | ✅ |
| llama-cpp-rocm | ✅ | ✅ |
| rcc-fix | ✅ | ✅ |

---

## kitsfmt

Rust 编写的 Nix 格式化器，基于 `rnix` AST 解析，支持属性排序、注释保留、缩进规范化。

**直接引用**：
```nix
{ inputs, ... }: {
  environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.kitsfmt ];
}
```

**作为 Nix 默认格式化器**：
```nix
{ inputs, ... }: {
  nix.settings.formatter = "${inputs.nix-kits.packages.${pkgs.system}.kitsfmt}/bin/kitsfmt";
}
```

**Overlay**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.kitsfmt ];
}
# → pkgs.kitsfmt
```

**CLI**：
```bash
kitsfmt file.nix           # 格式化输出到 stdout
kitsfmt --check file.nix   # 检查是否已格式化（幂等性）
kitsfmt --inplace file.nix # 原地格式化
```

---

## opencode-telegram

> 源码：[grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot)

[OpenCode](https://opencode.ai) 的 Telegram Bot 客户端，通过手机远程执行 AI 编码任务。

**直接引用**：
```nix
{ inputs, ... }: {
  environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.opencode-telegram ];
}
```

**Overlay**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.opencode-telegram ];
}
# → pkgs.opencode-telegram
```

**systemd service**：
```nix
{ inputs, ... }: {
  systemd.services.opencode-telegram = {
    description = "OpenCode Telegram Bot";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${inputs.nix-kits.packages.${pkgs.system}.opencode-telegram}/bin/opencode-telegram start --daemon";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
```

**使用**：
```bash
opencode-telegram start          # 交互式配置
opencode-telegram start --daemon # 后台运行
opencode-telegram status         # 查看状态
opencode-telegram stop           # 停止
```

---

## mcp-searxng

> 源码：[ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng)

[SearXNG](https://docs.searxng.org) 的 [MCP](https://modelcontextprotocol.io) Server，为 AI 助手提供网页搜索能力。

**直接引用**：
```nix
{ inputs, ... }: {
  environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];
}
```

**Overlay**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.mcp-searxng ];
}
# → pkgs.mcp-searxng
```

**Claude Desktop 配置**（`claude_desktop_config.json`）：
```json
{
  "mcpServers": {
    "searxng": {
      "command": "mcp-searxng",
      "env": {
        "SEARXNG_URL": "https://your-searxng-instance"
      }
    }
  }
}
```

**前提条件**：SearXNG 实例需启用 JSON 格式：
```yaml
# settings.yml
search:
  formats:
    - html
    - json
```

---

## obs-bilibili-stream

> 源码：[Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream)

OBS Studio 的 Bilibili 直播插件。Linux only。

**NixOS module（推荐）**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.obs-bilibili-stream ];
  imports = [ inputs.nix-kits.nixosModules.obs-bilibili-stream ];
}
```

**手动配置**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.obs-bilibili-stream ];

  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-bilibili-stream ];
  };
}
```

**Home Manager**：
```nix
{ inputs, ... }: {
  home.packages = [ inputs.nix-kits.packages.${pkgs.system}.obs-bilibili-stream ];
}
```

---

## llama-cpp-rocm

> 源码：[ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp)

基于上游 `llama.cpp`，启用 ROCm GPU 加速，版本号自动跟踪最新 GitHub Release。

**Overlay**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
}
# → pkgs.llama-cpp-rocm
```

**使用**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];

  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

```bash
llama-server -m model.gguf --gpu-device 0
```

---

## rcc-fix

> 源码：[Asus-linux/asusctl](https://github.com/Asus-linux/asusctl)（nixpkgs 上游）+ 本地补丁

修补 `asusctl`，改善 ASUS ROG Control Center 在二合一设备上的表现：键盘连接检测、Aura 灯光控制边界检查、友好提示信息。

**Overlay**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-fix ];
}
# → 修补后的 pkgs.asusctl
```

**使用**：
```nix
{ inputs, ... }: {
  nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-fix ];

  services.asusctl = {
    enable = true;
    power-profile = true;
    cpu-power-control = true;
  };
}
```

---

## 开发

```bash
nix flake check              # 检查当前系统
nix flake check --all-systems # 检查所有支持系统
nix build .#kitsfmt          # 构建指定包
```

## License

MIT
