# NixKits · impure 分支

[中文](README.md) | [English](docs/README.en.md) | [日本語](docs/README.ja.md)  | [偽中国語](docs/README.pcn.md)

**这个分支只做一件事：把「浮动」关在这里，好让 `main` 可以锁死。**

| 项 | 内容 |
|---|---|
| 唯一内容 | `llama-cpp-rocm`（overlay + NixOS 模块 + 包） |
| 浮动输入 | `llama-cpp-ver`（GitHub `releases/latest` 的 JSON）、`nixpkgs`（`nixos-unstable`） |
| `flake.lock` | **故意不提交**（`.gitignore` 里钉着） |
| 与 `main` 的关系 | **无共同历史**（orphan 分支）；由 `main` 或 `/etc/nixos` 以 input 引用 |

## 为什么存在

`llama-cpp-rocm` 的版本来自上游 llama.cpp 的最新 release，写不死；而一旦 `main` 提交
`flake.lock`，这个浮动输入就会随上游发布而过期——这正是 `main` 过去一直不提交 lock 的原因，
代价是**整个仓库的 CI 都不可复现**。

把它搬到一个独立分支后：

- 本分支**不锁**，永远跟最新；
- `main` **可以锁**，因为它不再含任何浮动输入；
- 想升级 llama.cpp 时，只 bump 本分支的 rev（`nix flake update nixkits-impure`），
  不必拖动 `main` 的其他任何输入。

## 用法

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixkits-impure.url = "github:Kihara777/NixKits/impure";
  };

  outputs = { nixpkgs, nixkits-impure, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      modules = [
        # ① overlay 提供 pkgs.llama-cpp-rocm（ROCM 构建、版本跟上游）
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nixkits-impure.overlays.default ];
          services.llama-cpp.package = pkgs.llama-cpp-rocm;
        })

        # ② 模块提供 nixkits.llama-cpp-rocm.*（模型预设、systemd 加固覆盖）
        nixkits-impure.nixosModules.default
        { nixkits.llama-cpp-rocm.enable = true; }
      ];
    };
  };
}
```

直接取包（不经 NixOS 模块）：

```bash
nix build github:Kihara777/NixKits/impure#llama-cpp-rocm
```

## 取回版本的方式与代价

`llama-cpp-ver` 是**普通 URL 输入**（`api.github.com`）。Nix **不会**给这类 fetch 附加
`access-tokens`，未认证额度是 **60 次/小时**——共享出口 IP 时容易 403。两种处置：

```bash
# ① 用认证的 gh 取回同一份 JSON，本地覆盖（CI 就是这样）
gh api repos/ggml-org/llama.cpp/releases/latest > /tmp/llama.json
nix flake check --override-input llama-cpp-ver path:/tmp/llama.json

# ② 先更新再离线用（会写 flake.lock，本分支不提交它）
nix flake update llama-cpp-ver
```

## 边界

- **不**含 `main` 的任何其他包、模块、技能；
- **不**跑 `main` 的自检（那些判据与文件都不在这个分支上）；
- 完整文档（模型预设、UMA 调优、热管理、故障排查）在 `docs/zh/llama-cpp-rocm.md`
  （四语齐全），**随组件一起搬到了本分支**——主仓不再保留副本，避免两份必然漂移。
  调优方法论（分面架构、统一内存、热管理）仍在 `main` 的 `nixos-specialisation-tuning`
  技能里，那是可移植的方法，不属于这个包。

## 许可

MIT，见 `LICENSE`。
