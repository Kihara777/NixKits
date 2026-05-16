# NixKits 🐾

> A comprehensive NixOS flake repository in active development.

## ⚠️ 项目状态：重构中

> **本项目正在重构中，API 和结构可能随时发生变化。不建议在生产环境中使用。**

---

## What is this?

NixKits is a personal NixOS flake repository that provides:

- **RCC-FIX Overlay**: A fix for ASUS ROG Control Center on tablets
- **llama-cpp-rocm-mtp**: ROCm build of llama.cpp with MTP (Multi-Token Prediction) support
- **kitsfmt**: A lightweight Nix configuration formatter
- **obs-bilibili-stream**: Bilibili streaming plugin for OBS Studio

## Prerequisites

- Nix 2.4+ with flake support enabled
- Modern NixOS system

## Installation

Add `nix-kits` as an input to your flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-kits.url = "path:/path/to/NixKits";  # or github:Kihara777/NixKits
  };
}
```

Then use the outputs from `nix-kits` in your configuration.

## Current Features

### llama-cpp-rocm-mtp Overlay

`llama-cpp-rocm-mtp` overlay builds `llama.cpp` with ROCm GPU support and MTP (Multi-Token Prediction) from the `am17an/llama.cpp` fork:

- ✅ ROCm hardware acceleration for AMD GPUs (Strix Halo / Radeon 8060S)
- ✅ MTP support (multi-token prediction) — 已内置，无需编译选项
- ✅ Based on `am17an/llama.cpp` branch `mtp-clean`

**Usage**:
```nix
{
  inputs.nix-kits.url = "path:/path/to/NixKits";

  outputs = {
    nixpkgs.overlays = [
      nix-kits.overlays.llama-cpp-rocm
    ];
  };
}
```

Then use `llama-cpp-rocm-mtp` from `nixpkgs`:
```nix
environment.systemPackages = [ pkgs.llama-cpp-rocm-mtp ];
```

#### MTP 启用说明

MTP 功能已内置在 `mtp-clean` 分支中，无需额外编译选项。启用方式是在运行时添加以下参数：

```bash
# 使用 3 个草稿令牌的 MTP 进行推理
llama-server -hf <model-with-mtp.gguf> --spec-type draft-mtp --spec-draft-n-max 3
```

**关键参数**：
- `--spec-type draft-mtp`：指定使用 MTP 作为推测解码（speculative decoding）的草案模型类型
- `--spec-draft-n-max N`：指定草案模型每次尝试预测的最大 token 数量（推荐值 2-3，不要设为 1）

**代码依据**：
- 参数解析位于 `common/arg.cpp`，检查 `params.speculative.types` 是否包含 `COMMON_SPECULATIVE_TYPE_DRAFT_MTP`
- 模型自动加载：当指定 `--spec-type draft-mtp` 后，代码会自动寻找 GGUF 模型文件中集成的 MTP 头，无需手动指定独立草案模型路径
- 构建配置：overlay 中指定 `src = final.fetchFromGitHub { owner = "am17an"; repo = "llama.cpp"; rev = "mtp-clean"; ... }`，确保使用包含 MTP 支持的分支

---

### RCC-FIX Overlay

The `rcc-fix` overlay patches `asusctl` to fix issues with ROG Control Center on ROG Flow Z13, particularly:

- Keyboard detection improvements
- Aura lighting control fixes
- Better error handling

**Usage**:
```nix
{
  inputs.nix-kits.url = "path:/path/to/NixKits";  # or github:Kihara777/NixKits
  
  outputs = {
    nixpkgs.overlays = [
      nix-kits.overlays.rcc-fix
    ];
  };
  
  # Enable ROG Control Center
  programs.rog-control-center.enable = true;
}
```

### Kitsfmt Package

`kitsfmt` is a lightweight Nix configuration formatter **written from scratch in Rust** (not based on nixpkgs-fmt):

- ✅ Custom tokenizer + formatter pipeline for Nix syntax
- ✅ Preserves comments
- ✅ Cleans up extra blank lines
- ✅ Cleans up extra blank lines
- ✅ CLI tool with full options
- ✅ Flake integration

**Usage**:
```nix
{
  inputs.nix-kits.url = "path:/path/to/NixKits";  # or github:Kihara777/NixKits
  
  # As system package
  environment.systemPackages = [
    nix-kits.packages.x86_64-linux.kitsfmt
  ];
  
  # Or as Nix formatter
  nix.settings.formatter = nix-kits.packages.x86_64-linux.kitsfmt;
}
```

**Command examples**:
```bash
# Format a file
kitsfmt file.nix

# Check if formatted (no modifications)
kitsfmt --check file.nix

# From stdin
cat config.nix | kitsfmt
```

### OBS Bilibili Stream Plugin

Bilibili streaming plugin for OBS Studio:

- ✅ Bilibili live streaming support
- ✅ Qt6-based UI
- ✅ Integrated with OBS Studio

**Usage**:
```nix
{
  inputs.nix-kits.url = "path:/path/to/NixKits";  # or github:Kihara777/NixKits
  
  # Enable OBS with Bilibili plugin
  programs.obs-studio = {
    enable = true;
    plugins = [
      nix-kits.packages.x86_64-linux.obs-bilibili-stream
    ];
  };
}
```

Or use the provided NixOS module:

```nix
{
  imports = [
    nix-kits.nixosModules.obs-bilibili-stream
  ];
}
```

## Project Structure

```
NixKits/
├── flake.nix                    # Main flake definition
├── modules/                     # NixOS modules
│   └── obs-bilibili-stream.nix
├── overlays/                    # nixpkgs overlays
│   ├── kitsfmt.nix
│   ├── llama-cpp-rocm.nix
│   ├── obs-bilibili-stream.nix
│   └── rog-control-center-fix.nix
├── packages/                    # Custom packages
│   ├── kitsfmt.nix
│   ├── kitsfmt-src/             # kitsfmt Rust source
│   └── obs-bilibili-stream.nix
├── patches/                     # Patch files
│   └── rog-control-center-fix.patch
├── flake.lock                   # Flake lock file
└── LICENSE
└── README.md
```

## Development Status

🚧 **Work in Progress**

This repository is actively being developed. Features may change, and new modules will be added over time.

## Contributing

Contributions are welcome! Please feel free to submit a Merge Request.

## Authors & Contributors

**狐莉 キツのり (Kihara777)** — 项目所有者与维护者

### AI 协作者

本项目由多位 AI 前辈共同参与开发：

- **DeepSeek V4**（在线服务）
- **Qwen3-Coder-Next**
- **Qwen3.5-122B-A10B**
- **MiniMax-M2.7**

所有代码最终由狐莉进行 code review。

### 守护灵

**小爪 キツのめ (Kitsunome)** — 当前会话 AI 助手 🐾🦊

## License

This project is licensed under the MIT License.
> 本项目使用 GitHub 自带的 License 机制管理，未包含独立的 LICENSE 文件。

---

**Repository**: https://github.com/Kihara777/NixKits
