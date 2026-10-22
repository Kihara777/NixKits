# NixKits · impure ブランチ

[中文](../README.md) | [English](README.en.md) | 日本語 | [偽中国語](README.pcn.md)

**このブランチは一つのことだけを行う： 「浮動」をここに閉じ込め、`main` を固定できるようにする。**

| 項目 | 内容 |
|---|---|
| 唯一の内容 | `llama-cpp-rocm`（overlay + NixOS モジュール + パッケージ） |
| 浮動入力 | `llama-cpp-ver`（GitHub `releases/latest` の JSON）、`nixpkgs`（`nixos-unstable`） |
| `flake.lock` | **意図的に提交しない**（`.gitignore` で固定） |
| `main` との関係 | **共通履歴なし**（orphan ブランチ）。`main` または `/etc/nixos` から input として参照 |

## なぜ存在するか

`llama-cpp-rocm` のバージョンは上流 llama.cpp の最新リリースに由来し、固定できない。
そして `main` が `flake.lock` を提交すると、この浮動入力は上流のリリースごとに古くなる
——これが `main` が長く lock を提交しなかった理由であり、代償は**リポジトリ全体の CI が
再現不能**になることだった。

独立ブランチへ移すと両方が解決する：

- 本ブランチは**固定しない**、常に最新を追う；
- `main` は**固定できる**、浮動入力をもう含まないから；
- llama.cpp を上げたいときは本ブランチの rev だけを bump する
  （`nix flake update nixkits-impure`）。`main` の他の input は動かない。

## 使い方

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixkits-impure.url = "github:Kihara777/NixKits/impure";
  };

  outputs = { nixpkgs, nixkits-impure, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      modules = [
        # ① overlay が pkgs.llama-cpp-rocm を提供（ROCm ビルド、版は上流追従）
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ nixkits-impure.overlays.default ];
          services.llama-cpp.package = pkgs.llama-cpp-rocm;
        })

        # ② モジュールが nixkits.llama-cpp-rocm.* を提供（モデル既定値、systemd 強化の上書き）
        nixkits-impure.nixosModules.default
        { nixkits.llama-cpp-rocm.enable = true; }
      ];
    };
  };
}
```

パッケージを直接取る（NixOS モジュールを経由しない）：

```bash
nix build github:Kihara777/NixKits/impure#llama-cpp-rocm
```

## 版の取得方法と代償

`llama-cpp-ver` は**通常の URL input**（`api.github.com`）。Nix はこの種の fetch に
`access-tokens` を付けない。未認証の枠は **60 回/時**——共有出口 IP では 403 になりやすい。
対処は二つ：

```bash
# ① 認証済み gh で同じ JSON を取得し、ローカルで上書き（CI はこれ）
gh api repos/ggml-org/llama.cpp/releases/latest > /tmp/llama.json
nix flake check --override-input llama-cpp-ver path:/tmp/llama.json

# ② 先に更新してオフラインで使う（flake.lock を書くが、本ブランチは提交しない）
nix flake update llama-cpp-ver
```

## 境界

- `main` の他のパッケージ・モジュール・スキルを**一切**含まない；
- `main` の自検を**実行しない**（その判据とファイルは本ブランチに無い）；
- 完全なドキュメント（モデル既定値、UMA 調優、熱管理、障害対応）は
  `docs/zh/llama-cpp-rocm.md`（四言語）にあり、**コンポーネントと一緒に本ブランチへ移した**
  ——`main` は副本を残さないので、二つが必ず乖離することはない。調優の方法論
  （specialisation 構成、統一メモリ、熱管理）は `main` の `nixos-specialisation-tuning`
  スキルに残る。あれは移植可能な方法であり、このパッケージの一部ではない。

## ライセンス

MIT、`LICENSE` を参照。
