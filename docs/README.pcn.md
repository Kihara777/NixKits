# NixKits · impure 分支

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md)  | 偽中国語

**本分支 唯一 事 実行：「浮動」 此処 閉込、`main` 固定 可能 化。**

| 項目 | 内容 |
|---|---|
| 唯一 内容 | `llama-cpp-rocm`（overlay ＋ NixOS 模組 ＋ 包） |
| 浮動 入力 | `llama-cpp-ver`（GitHub `releases/latest` JSON）、`nixpkgs`（`nixos-unstable`） |
| `flake.lock` | **意図的 非提交**（`.gitignore` 内 固定） |
| `main` 関係 | **共通履歴 無**（orphan 分支）。`main` 或 `/etc/nixos` 由 input 参照 |

## 存在理由

`llama-cpp-rocm` 版 由 上流 llama.cpp 最新 release 由来、固定 不可。而 `main` 若
`flake.lock` 提交、此 浮動入力 上流 release 毎 古 化 —— 此事由 即 `main` 長期間
lock 非提交 之 原因、代償 全 repo CI 再現不能。

独立分支 移 後、両方 解決：

- 本分支 **非固定**、常 最新 追；
- `main` **固定 可能**、浮動入力 含有 無 故；
- llama.cpp 昇格 時 本分支 rev 只 bump（`nix flake update nixkits-impure`）、
  `main` 他 input 不動。

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
        # ① overlay 提供 pkgs.llama-cpp-rocm（ROCm 構建、版 上流 追随）
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nixkits-impure.overlays.default ];
          services.llama-cpp.package = pkgs.llama-cpp-rocm;
        })

        # ② 模組 提供 nixkits.llama-cpp-rocm.*（模型 既定値、systemd 強化 上書）
        nixkits-impure.nixosModules.default
        { nixkits.llama-cpp-rocm.enable = true; }
      ];
    };
  };
}
```

包 直接 取得（NixOS 模組 経由 無）：

```bash
nix build github:Kihara777/NixKits/impure#llama-cpp-rocm
```

## 版 取得 方法 與 代償

`llama-cpp-ver` 是 **通常 URL input**（`api.github.com`）。Nix 對此種 fetch
`access-tokens` 付与 無。未認証 枠 **60 回/時** —— 共有出口 IP 時 403 易。
対処 二：

```bash
# ① 認証済 gh 由 同一 JSON 取得、本地 上書（CI 即 此）
gh api repos/ggml-org/llama.cpp/releases/latest > /tmp/llama.json
nix flake check --override-input llama-cpp-ver path:/tmp/llama.json

# ② 先 更新 後 離線 使用（flake.lock 書込、本分支 非提交）
nix flake update llama-cpp-ver
```

## 境界

- `main` 他 包・模組・技能 **一切** 含 無；
- `main` 自検 **実行 無**（其 判据 與 文件 本分支 無）；
- 完全 文書（模型 既定値、UMA 調優、熱管理、障害対応）在 `docs/zh/llama-cpp-rocm.md`
  （四言語）、**與 component 一緒 本分支 移** —— `main` 副本 残 無、
  故 二 必 乖離 無。調優 方法論（specialisation 構成、統一 memory、熱管理）在
  `main` 之 `nixos-specialisation-tuning` 技能 残。是 移植可能 方法、此 包 一部 非。

## 許可

MIT、`LICENSE` 参照。
