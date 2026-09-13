# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | 日本語  | [偽中国語](../pcn/llama-cpp-rocm.md)

llama.cpp に ROCm GPU アクセラレーションを有効化。ビルド時に GitHub 最新リリースバージョンを動的取得し、最先端機能のテストに使用します。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | アップストリーム最新リリースを自動追跡 |
| アップストリーム | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| 注意 | overlay のみ提供、単独パッケージ出力なし |

## インストール

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## 使い方

アップストリーム llama.cpp のドキュメントを参照してください。

## Flake モジュール

```nix
# flake.nix
{
  inputs.nixkits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nixkits, ... }: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      modules = [
        nixkits.nixosModules.llama-cpp-rocm
        {
          services.llama-cpp = {
            enable = true;
            package = pkgs.llama-cpp-rocm;
            port = 2027;
          };
          nixkits.llama-cpp-rocm = {
            enable = true;
            user = "kix";
            group = "users";
            modelsPreset = {
              "*" = {
                # バッチ処理：実測による最適点。512 → 2048 で prefill が
                # 142.7 から 168.7 t/s に向上（コストは約 0.9 GiB のみ）。
                # 4096 はむしろ 116.8 に退化。
                batch-size       = "2048";
                ubatch-size      = "2048";
                cache-type-k     = "q4_0";
                cache-type-v     = "q4_0";
                threads          = "32";
                parallel         = "1";
                jinja            = "on";
                # 以下は llama の既定値であり、立場を示すために明記するのみで
                # 省略可能：flash-attn（既定 on）、warmup（既定 on）、fit（既定 on）。
                # n-gpu-layers / load-mode をハードコードしないこと ——
                # fit の自動調整が無効になります。
              };
              "Qwen3.6-27B-MTP" = {
                hf-repo              = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
                alias                = "Qwen3.6-27B-MTP";
                temp                 = "0.6";
                top-p                = "0.95";
                top-k                = "20";
                min-p                = "0.00";
                ctx-size             = "1048576";
                rope-scaling         = "yarn";
                rope-scale           = "4";
                yarn-orig-ctx        = "262144";
                spec-type            = "draft-mtp";
                spec-draft-n-max     = "2";
              };
              "Qwen3.6-35B-A3B-MTP" = {
                hf-repo              = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL";
                alias                = "Qwen3.6-35B-A3B-MTP";
                temp                 = "0.6";
                top-p                = "0.95";
                top-k                = "20";
                min-p                = "0.00";
                ctx-size             = "1048576";
                rope-scaling         = "yarn";
                rope-scale           = "4";
                yarn-orig-ctx        = "262144";
                spec-type            = "draft-mtp";
                spec-draft-n-max     = "2";
              };
              "Qwen3.5-122B-A10B-MTP" = {
                hf-repo              = "unsloth/Qwen3.5-122B-A10B-MTP-GGUF:UD-Q4_K_XL";
                alias                = "Qwen3.5-122B-A10B-MTP";
                temp                 = "0.6";
                top-p                = "0.95";
                top-k                = "20";
                min-p                = "0.00";
                ctx-size             = "1048576";
                rope-scaling         = "yarn";
                rope-scale           = "4";
                yarn-orig-ctx        = "262144";
                spec-type            = "draft-mtp";
                spec-draft-n-max     = "2";
              };
              "Qwen3-Coder-Next" = {
                hf-repo       = "unsloth/Qwen3-Coder-Next-GGUF:UD-Q4_K_XL";
                alias         = "Qwen3-Coder-Next";
                temp          = "1.0";
                top-p         = "0.95";
                top-k         = "40";
                min-p         = "0.01";
                seed          = "3407";
                ctx-size      = "1048576";
                rope-scaling  = "yarn";
                rope-scale    = "4";
                yarn-orig-ctx = "262144";
              };
              "MiniMax-M2.7" = {
                hf-repo  = "unsloth/MiniMax-M2.7-GGUF:UD-Q2_K_XL";
                alias    = "MiniMax-M2.7";
                temp     = "1.0";
                top-p    = "0.95";
                top-k    = "40";
                min-p    = "0.01";
                ctx-size = "196608";
              };
            };
          };
        }
      ];
    };
  };
}
```

モジュールは `LLAMA_CACHE` を `~/.cache/huggingface/hub` に自動設定し、`/home` と `/proc` のサンドボックス制限を解除します。

> **警告: Home Manager の llama-cpp サービス**
>
> Home Manager 経由で有効にした場合、追加のユーザーレベルサンドボックスにより GPU アクセス（`/dev/dri`、`/dev/kfd`）がブロックされる可能性があります。システムレベルでの設定を推奨します。

## モデル説明

`modelsPreset` は複数モデルを保持し、サービス起動時に必要に応じてロードされます。グローバルプリセット `"*"` は全モデルに適用され、個別モデルのエントリで特定のパラメータを上書きできます。`hf-repo` は HuggingFace から GGUF 形式のモデルファイルを自動ダウンロードします。

## パラメータ解説

以下は Strix Halo（統合メモリ）上の llama.cpp 0.4.0 で実測検証済みです。

| パラメータ | 推奨値 | 説明 |
|-----------|--------|------|
| `fit` | `"on"`（既定） | 未設定の引数をデバイスメモリに合わせて自動調整。**`"off"` は VRAM 制限下で OOM になる**。`n-gpu-layers` をハードコードすると自動調整が無効になる |
| `jinja` | `"on"` | モデル内蔵の chat template を適用。**無効化すると出力が退化する** |
| `cache-type-k` / `cache-type-v` | `"q4_0"` | KV cache 量子化。**`iq4_nl` は ROCm カーネル不在で CPU にフォールバックし約 2.6 倍遅くなる**；`f16` は実測で prefill がむしろ低速（150.8 t/s） |
| `batch-size` | `"2048"` | 論理バッチ。**実測による最適点**：512 → 2048 で prefill が 142.7 → 168.7 t/s（+18%）；4096 は 116.8 に退化 |
| `ubatch-size` | `"2048"` | 物理バッチ。`batch-size` と揃える |
| `parallel` | `"1"` | サーバースロット数。増やすと KV 予約が倍増する |
| `threads` | `"32"` | CPU スレッド数。コア数に一致させる |
| `warmup` | `"on"`（既定） | ロード後の空実行 1 回。最初の実リクエストを高速化 |

> **設定不要な項目**：`flash-attn`・`warmup`・`fit` は既定値が既に推奨値であり、明記は立場の表明に過ぎません。`presence-penalty`・`repeat-penalty`・`prio` は実測で効果がなく、既定値の記述は冗長です。

> **注意**：`modelsPreset` の値は**文字列**（`attrsOf (attrsOf str)`）でなければなりません。`"on"` / `"off"` と書き、`true` / `false` は使えません。

### 避けるべき項目

| 項目 | 理由 |
|------|------|
| `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` | **モデル出力を破壊する**（トークン反復・文字化け）。同じモデルとプリセットでも、この変数なしなら正常に応答する。次節を参照 |
| `mmap` | 非推奨。`load-mode` を使用 |
| `--no-mmproj` | mmproj と量子化が不一致な場合の暫定回避策のみ。画像入力には必要 |

### ユニファイドメモリ環境変数による退化リスク

StrixHalo などのユニファイドメモリ（UMA）デバイスでは、**`GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` を設定しないでください**。この変数は GPU メモリ割り当て経路（専用 VRAM からユニファイドメモリアドレッシングへ）を変更し、そのようなハードウェアでモデル出力を退化させます。

> ⚠️ **リスクはモデルの量子化精度が下がるほど著しく増大します。** 低ビット量子化が最も影響を受けます —— 量子化が攻撃的であるほど重みの分布が狭まり、この割り当て変更がもたらすノイズに敏感になります。

**退化の症状**：トークン反復（`We need need need…`、`The user user user…`）、文の崩壊、終了不能。

**実測比較**（Strix Halo / Ryzen AI Max、モデル `UD-IQ1_S` 1.5625 bpw）：

| 起動方法 | 変数の設定 | 結果 |
|---------|-----------|------|
| systemd サービス | ✅ あり | ❌ **退化**（トークン反復） |
| 手動起動 server（同一 ini/モデル） | ❌ なし | ✅ 正常 |
| `llama-cli`（同一 ini/モデル） | ❌ なし | ✅ 正常 |
| 手動起動 server | ✅ あり | ❌ **退化を再現** |

最後の 2 行が決定的な証拠です：**同一モデル・同一プリセット・同一設定ファイル**で、唯一の変数がこの環境変数であり、双方向に再現します。

**誤診しやすい理由**：`llama-cli` はデフォルトで `--fit on` と `--n-gpu-layers auto` ですが、プリセットが `fit off` を設定すると OOM になります。この 2 つの症状（出力異常 vs 読み込み失敗）は、量子化やテンプレート（`jinja`）の問題と混同しやすいです。**まずこの変数を除外**してから、量子化やテンプレートを疑ってください。

## DeepSeek 展開の実測

Strix Halo（Ryzen AI Max、128 GiB ユニファイドメモリ）で DeepSeek-V4-Flash-Vision を展開した実測記録。現在は **IQ1 量子化のみ**（1.5625 bpw）を対象とします。

### テスト対象

| 項目 | 値 |
|------|-----|
| モデル | `unsloth/DeepSeek-V4-Flash-Vision-Exp-GGUF:UD-IQ1_S` |
| 量子化 | IQ1_S、**1.5625 bpw**（82.4 GB） |
| パラメータ | 総 284 B（MoE） |
| ハードウェア | Strix Halo / Radeon 8060S（`gfx1151`、ユニファイドメモリ） |
| バックエンド | ROCm、llama.cpp 0.4.0 |

### 最適化の成果

| 最適化 | 変更 | 効果 | コスト |
|--------|------|------|--------|
| **バッチ処理** | `batch-size`/`ubatch-size` 512 → **2048** | prefill **142.7 → 168.7 t/s**（+18%） | +0.9 GiB VRAM |
| **KV 量子化** | `q4_0` を維持（`f16` にしない） | prefill 168.7 vs 150.8、生成 12.8 vs 10.6 t/s | 5.2 GiB 節約 |
| **KV 型** | `iq4_nl` を破棄 | CPU フォールバック回避（5.54 → 14.14 t/s） | — |
| **スロット数** | `parallel` auto(4) → **1** | スロットあたり KV 予約が 1/4 になり読み込める | 並行度 1 |
| **投機デコード** | `--spec-type ngram-mod` | 生成 **12.8 → 30.8 t/s**（+141%、内容依存） | メモリゼロ |

**prefill 実測詳細**（11015 トークン、各 3 回）：

| 構成 | prompt t/s |
|------|-----------|
| batch512 / ubatch512 | 142.7 |
| batch2048 / ubatch1024 | 164.2 / 158.9 / 152.5 |
| **batch2048 / ubatch2048** | **168.7 / 162.4 / 154.0** |
| batch4096 / ubatch2048 | 156.4 / 157.3 / 151.9 |
| batch2048 + KV `f16` | 165.7 / 159.0 / 153.5 |

### 除外済みの方向

以下は実測により**効果なし**と確認済みです。再試行は不要です：

| 方向 | 結論 |
|------|------|
| GPU が飽和していない | prefill 時 `GPU use = 100%`、既にハードウェア演算限界 |
| ROCm ターゲット欠落 | `gfx1151` は nixpkgs の `gpuTargets` に含まれる。汎用フォールバックではない |
| KV を `f16` に | prefill はむしろ 150.8 t/s に低下し、さらに 5.2 GiB 消費 |
| `cache-ram` | 既定 8192 は**上限**であり事前確保ではない；無効化しても GPUActive は同一 |
| より大きなバッチ | `ubatch` 4096 は 116.8 t/s に退化 |
| `draft-mtp` | モデルに MTP 層なし（GGUF に `nextn` なし）；使用不可 |

### 重要な結論

**1.56 bpw の二面性**：低ビットは**生成**に有利（重み帯域が小さい）ですが、**prefill** には不利です —— 各層で重みを逆量子化する必要があり、prefill は計算集約的な段階であるため、逆量子化の演算比率がビット幅の低下とともに増大します。実測 prefill は 142–169 t/s に対し生成 12.8 t/s、比率は約 11–13 倍（GPU の健全値は通常 15–30 倍）。

**したがって agentic 用途では prefill が主要なボトルネックです**：6k トークンの文脈で約 35 秒のウォームアップに対し、200 トークンの生成は約 8 秒です。

> ⚠️ テスト中は**サービス起動前に `GPUActive` がゼロに戻ったことを必ず確認**してください。本機は大型モデルを一度に 1 インスタンスしか保持できません。残留プロセスは数十 GiB のユニファイドメモリを占め、サービスを OOM に陥れ、設定エラーに見せかけます。

## 移行ガイド

### 影響を受けるバージョン

| コンポーネント | 影響範囲 | 変更内容 |
|-------------|---------|---------|
| nixpkgs | 2026-06 以降（master） | `services.llama-cpp.modelsPreset` 削除、`port`/`host`/`model`/`modelsDir` を `settings.port`/`settings.host`/… にリネーム |
| NixKits | `6f52ddf` 以降（`modules/llama-cpp-rocm.nix`） | 名前空間を `services.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` に移行 |
| アップストリーム llama.cpp | b9605 | `--models-preset` CLI 引数は維持 |

### 設定項目の対応表

| 旧設定（非推奨） | 新設定 | 備考 |
|-----------------|--------|------|
| `services.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | nixpkgs から削除、NixKits で復元 |
| `services.llama-cpp-rocm.enable` | `nixkits.llama-cpp-rocm.enable` | 名前空間統一 |
| `services.llama-cpp-rocm.user` | `nixkits.llama-cpp-rocm.user` | 同上 |
| `services.llama-cpp-rocm.group` | `nixkits.llama-cpp-rocm.group` | 同上 |
| `services.llama-cpp.port` | `services.llama-cpp.settings.port` | nixpkgs リネーム |
| `services.llama-cpp.host` | `services.llama-cpp.settings.host` | nixpkgs リネーム |
| `services.llama-cpp.model` | `services.llama-cpp.settings.model` | nixpkgs リネーム |
| `services.llama-cpp.modelsDir` | `services.llama-cpp.settings.models-dir` | nixpkgs リネーム |
| 手動 `systemd.services.llama-cpp.serviceConfig` | 削除 | NixKits モジュールが自動処理 |
| `services.llama-cpp.extraFlags` | `services.llama-cpp.settings` に対応フラグを追加 | nixpkgs 削除 |

### 移行例

> **⚠️ ステップ 1**: `flake.nix` のモジュールリストに `nixkits.nixosModules.llama-cpp-rocm` を追加

**移行前**:

```nix
# flake.nix — モジュールリスト
{ modules = [
    # nixkits.nixosModules.llama-cpp-rocm  # ← 未インポート
];}

# llama-cpp.nix
{
  services.llama-cpp-rocm = {
    enable = true;
    user = "kix";
    group = "users";
  };
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    port = 2027;
    modelsPreset = {
      "Qwen3-Coder-Next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        temp = "1.0";
      };
    };
  };
  # 手動 systemd 設定
  systemd.services.llama-cpp.serviceConfig = {
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    ProtectHome = lib.mkForce false;
    User = lib.mkForce "kix";
    Group = lib.mkForce "users";
    Environment = lib.mkForce [
      "LLAMA_CACHE=~/.cache/huggingface/hub"
      # ⚠️ 歴史的な設定であり、現在は有害と確認済み：StrixHalo などの
      # ユニファイドメモリデバイスでモデル出力を退化させ、リスクは量子化精度の
      # 低下とともに増大します。移行時は必ず削除してください。
      # 「ユニファイドメモリ環境変数による退化リスク」節を参照。
      "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
    ];
    ProcSubset = lib.mkForce "all";
  };
}
```

**移行後**:

```nix
# flake.nix — モジュールリスト（追加）
{ modules = [
    nixkits.nixosModules.llama-cpp-rocm
];}

# llama-cpp.nix
{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    settings.port = 2027;
  };
  nixkits.llama-cpp-rocm = {
    enable = true;
    user = "kix";
    group = "users";
    hfCacheDir = "~/.cache/huggingface/hub";
    modelsPreset = {
      "Qwen3-Coder-Next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        temp = "1.0";
      };
    };
  };
  # NixKits オプションでカバーされない環境変数
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=~/.cache/huggingface/hub"
  ];
}
```
