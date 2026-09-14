# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | [日本語](../ja/llama-cpp-rocm.md)  | 偽中国語

llama.cpp ROCm GPU 加速有効化。構築時 GitHub 最新版動的取得、最先端機能試験使用。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 上流最新版自動追跡 |
| 上流 | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| 注意 | 上乗提供、単独包出力無 |

## 導入

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## 使用法

上流 llama.cpp 文書参照。

## Flake 部品

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
                # 批次処理：実測最適点。512 → 2048 使 前置充填 従 142.7 至
                # 168.7 t/s 向上（代価僅約 0.9 GiB）。4096 反退化至 116.8。
                batch-size       = "2048";
                ubatch-size      = "2048";
                cache-type-k     = "q4_0";
                cache-type-v     = "q4_0";
                threads          = "32";
                parallel         = "1";
                jinja            = "on";
                # 以下 llama 既定値、立場表明為明記、省略可能：
                # flash-attn（既定 on）、暖機（既定 on）、fit（既定 on）。
                # n-gpu-layers / load-mode 書死禁止 —— fit 自動調整無効化。
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

部品 `LLAMA_CACHE` `~/.cache/huggingface/hub` 自動設定、`/home` 與 `/proc` 砂箱制限解除。

> **警告: Home Manager llama-cpp 服務**
>
> Home Manager 経由有効化場合、追加利用者段砂箱 GPU 接続（`/dev/dri`、`/dev/kfd`）遮断可能性有。体系段設定推奨。

## 模型説明

`modelsPreset` 複数模型保持、服務起動時必要応読込。全局預設 `"*"` 全模型適用、個別模型項目特定参數上書可能。`hf-repo` HuggingFace 自 GGUF 形式模型書類自動取得。

## 参數詳解

以下参數、Strix Halo（統合記憶体）上 llama.cpp 0.4.0 以実測検証済。

| 参數 | 推奨値 | 説明 |
|------|--------|------|
| `fit` | `"on"`（既定） | 未設定引數 装置記憶体 合自動調整。**`"off"` VRAM 制限下 OOM 発生**。`n-gpu-layers` 書死時、該自動調整無効 |
| `jinja` | `"on"` | 模型内蔵 chat template 適用。**無効化時、輸出退化** |
| `cache-type-k` / `cache-type-v` | `"q4_0"` | KV cache 量子化。**`iq4_nl` ROCm 核心不在 CPU 退回、約 2.6 倍遅**；`f16` 実測 前置充填 反低速（150.8 t/s） |
| `batch-size` | `"2048"` | 論理批次。**実測最適点**：512 → 2048 使 前置充填 142.7 → 168.7 t/s（+18%）；4096 退化至 116.8 |
| `ubatch-size` | `"2048"` | 物理批次。`batch-size` 合致 |
| `parallel` | `"1"` | 服務槽位数。増加時 KV 予約倍数増 |
| `threads` | `"32"` | CPU 執行糸数。核心数合致 |
| `暖機` | `"on"`（既定） | 読込後空実行一回。最初実請求高速化 |

> **設定不要項目**：`flash-attn`・`暖機`・`fit` 既定値既推奨値、明記立場表明唯。`presence-penalty`・`repeat-penalty`・`prio` 実測効果無、既定値記述冗長。

> **注意**：`modelsPreset` 値 **文字列**（`attrsOf (attrsOf str)`）必須。`"on"` / `"off"` 記述、`true` / `false` 使用不可。

### 回避項目

| 項目 | 理由 |
|------|------|
| `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` | **模型輸出破壊**（語彙反復・文字化）。同模型同預設、此変数無場合正常応答。次節参照 |
| `mmap` | 非推奨。`load-mode` 使用 |
| `--no-mmproj` | mmproj 量子化不一致時暫定回避唯。画像入力必要 |

### 統一記憶域環境変数退化危険

StrixHalo 等統一記憶域（UMA）機器、**`GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` 設定禁止**。該変数 GPU 記憶域割当経路（専用 VRAM 従統一記憶域 addressing 至）変更、該様硬件事模型輸出退化招致。

> ⚠️ **危険模型量子化精度低下随著顕著増大。** 低 bit 量子化最重影響 —— 量子化攻撃的程、重値分布狭化、該割当変更導入雑音敏感。

**退化症状**：語彙反復（`We need need need…`、`The user user user…`）、文崩壊、終了不能。

**実測比較**（Strix Halo / Ryzen AI Max、模型 `UD-IQ1_S` 1.5625 bpw）：

| 起動方法 | 変数設定 | 結果 |
|---------|---------|------|
| systemd 服務 | ✅ 有 | ❌ **退化**（語彙反復） |
| 手動起動 server（同 ini/模型） | ❌ 無 | ✅ 正常 |
| `llama-cli`（同 ini/模型） | ❌ 無 | ✅ 正常 |
| 手動起動 server | ✅ 有 | ❌ **退化再現** |

最後二行決定的証拠：**同模型・同預設・同設定書類**、唯一変数該環境変数、双方向再現。

**誤診容易理由**：`llama-cli` 既定 `--fit on` 與 `--n-gpu-layers auto`、但預設 `fit off` 設定時 OOM 至。該二症状（輸出異常 vs 読込失敗）量子化・模板（`jinja`）問題混同容易。**先該変数除外**、後量子化・模板疑。

## DeepSeek 展開実測

Strix Halo（Ryzen AI Max、128 GiB 統一記憶域）上 DeepSeek-V4-Flash-Vision 展開実測記録。**IQ1_S（1.5625 bpw）** 與 **IQ3_S（3.4375 bpw）** 二種量子化対象。

### 測試対象

| 項目 | IQ1_S | IQ3_S |
|------|-------|-------|
| 模型 | `unsloth/DeepSeek-V4-Flash-Vision-Exp-GGUF:UD-IQ1_S` | `…:UD-IQ3_S` |
| 量子化 | 1.5625 bpw（82.4 GB） | **3.4375 bpw（114.4 GB）** |
| 参數 | 総 284 B（MoE） | 総 284 B（MoE） |
| 硬件 | Strix Halo / Radeon 8060S（`gfx1151`、統一記憶域） | 同左 |
| 後端 | ROCm、llama.cpp 0.4.0 | 同左 |

### 量子化開銷非固定値

IQ3_S 装載前予測「固定開銷約 3.7 GiB」、**実測偏差近一量級**：

| 量子化 | 重値書類 | 装載後 GPUActive | 超出重値 開銷 |
|--------|---------|-----------------|--------------|
| IQ1_S | 82.4 GiB | ≈ 88.9 GiB | **≈ 6.5 GiB** |
| IQ3_S | 114.4 GiB | **112.8–112.9 GiB** | **≈ 13.3 GiB**† |

> † IQ3_S 重値 4 分片（shard）拆分後実際落盤略小標称値、故此処開銷按
> 「重値分片実際占用」與 GPUActive 之差計算。

**結論：不要用固定常数外推開銷。** 開銷随量子化精度、分片方式、
KV cache 量子化與 `fit` 自適応結果共同変化。**換量子化後必須再実測 GPUActive**、
不能沿用上一檔数字。

**IQ3_S 余量**：GPUActive 112.8–112.94 GiB 時体系僅残約 5.8–6 GiB、
GTT 上限 124.9 GiB。実測通過 15013 語彙 與 40012 語彙 前置充填 未 OOM、
僅 179 頁被換出。**但余量既緊**、故：

- 不要提高 `ubatch-size`
- 不要増加 `parallel`
- 不要把 KV cache 改為 `f16`

### 最適化成果

| 最適化 | 変更 | 効果 | 代価 |
|--------|------|------|------|
| **批次処理** | `batch-size`/`ubatch-size` 512 → **2048** | 前置充填 **142.7 → 168.7 t/s**（+18%） | +0.9 GiB VRAM |
| **KV 量子化** | `q4_0` 維持（`f16` 非変更） | 前置充填 168.7 vs 150.8、生成 12.8 vs 10.6 t/s | 5.2 GiB 節約 |
| **KV 型** | `iq4_nl` 破棄 | CPU 退回回避（5.54 → 14.14 t/s） | — |
| **槽位数** | `parallel` auto(4) → **1** | 槽位毎 KV 予約 1/4 化、読込可能 | 並行度 1 |
| **投機復号** | `--spec-type ngram-mod` | 生成 **12.8 → 30.8 t/s**（+141%、内容依存） | 記憶域 零 |

**前置充填 実測詳細**（11015 語彙、各 3 回）：

| 構成 | 前置充填 t/s |
|------|-----------|
| batch512 / ubatch512 | 142.7 |
| batch2048 / ubatch1024 | 164.2 / 158.9 / 152.5 |
| **batch2048 / ubatch2048** | **168.7 / 162.4 / 154.0** |
| batch4096 / ubatch2048 | 156.4 / 157.3 / 151.9 |
| batch2048 + KV `f16` | 165.7 / 159.0 / 153.5 |

### 除外済方向

以下実測 **効果無** 確認済。再試行不要：

| 方向 | 結論 |
|------|------|
| GPU 未飽和 | 前置充填 時 `GPU use = 100%`、既硬件演算限界 |
| ROCm 目標欠落 | `gfx1151` nixpkgs `gpuTargets` 内、汎用退回非 |
| KV `f16` 化 | 前置充填 反 150.8 t/s 低下、且 5.2 GiB 多消費 |
| `cache-ram` | 既定 8192 **上限**非事前確保；無効化時 GPUActive 同一 |
| 更大批次 | `ubatch` 4096 退化至 116.8 t/s |
| `draft-mtp` | 模型 MTP 層無（GGUF `nextn` 無）；使用不可 |
| **提高量子化精度** | IQ1_S 1.56 bpw → IQ3_S 3.44 bpw、**生成速度不変**（12.8 → 12.9 t/s） |
| **提高 GPU 頻率** | performance 檔相比 balanced 多耗 54% 功耗、生成僅 +2.4% |

### 生成速度：隘路 是 依頼遅延

**提高重値精度不提升生成速度**：重値自 1.56 bpw 升至 3.44 bpw（体積 +39%）、
生成速度 12.8 → 12.9 t/s、**雑音範囲内**。若隘路 在 顕存帯域、精度提升本応顕著減速。

**並行不提升聚合吞吐**：3 個並行請求 聚合吞吐 仍為 12.5 t/s、
與単請求相同 —— 説明隘路 不在 吞吐能力。

**頻率几乎不影響生成**：performance 檔 sclk 2778 MHz、功耗 70.2 W、
生成 12.9 t/s；balanced 檔 2436 MHz、45.6 W、生成 12.6 t/s。
**多耗 54% 功耗只換 2.4% 速度。**

三条証拠共同指向：**生成受限於逐 語彙 依頼遅延**、而非帯域、算力或功耗。
此亦低量子化對生成影響甚微、對 前置充填 影響顕著理由。

### 功耗檔位実測

同一提示詞、同一会期、400 語彙 生成：

| 檔位 | 功耗 | sclk | 温度 | 生成速度 |
|------|------|------|------|---------|
| quiet | **38.6–43.9 W** | 2228–2464 MHz | **59–78 °C** | 12.12–12.35 t/s |
| balanced | 55.1 W | 2586–2731 MHz | 87–93 °C | 12.84 t/s |
| performance | 76.7 W | 2753–2859 MHz | 90–95 °C | 13.07 t/s |

**quiet 相対 performance：功耗 −49%、温度 −17~36 °C、速度僅 −5~7%。**
按「毎瓦吞吐」衡量、quiet 是三檔中効率最高者。

### 重要結論

**低 bit 量子化 双面性**：低 bit 對**生成**有利（重値帯域小）、但對 **前置充填** 不利 —— 毎層須逆量子化重値、而 前置充填 是計算集約段階、逆量子化算力占比随位幅低下而升高。実測 前置充填 僅 142–169 t/s、而生成 12.8 t/s、比值約 11–13 倍（GPU 上健全値通常 15–30 倍）。

**故 前置充填 是 代理用途 主要 隘路**：一輪 6k 語彙 文脈約 35 秒 暖機、而 200 語彙 生成僅約 8 秒。

> ⚠️ 測試中**服務起動前 `GPUActive` 帰零必確認**。本機大型模型同時一実例 唯保持可能。残留工程 数十 GiB 統一記憶域占、服務 OOM 陥、設定誤謬装。
>
> 注意：真実 顕存指標 是 `/proc/meminfo` 之 **`GPUActive`**、
> **不是** `mem_info_gtt_used`（後者 於 統一記憶域機器 不反映実際占用）。

## 移行手引

### 影響受版

| 構成素 | 影響範囲 | 変更内容 |
|-------------|---------|---------|
| nixpkgs | 2026-06 以降（master） | `services.llama-cpp.modelsPreset` 削除、`port`/`host`/`model`/`modelsDir` `settings.port`/`settings.host`/… 改名 |
| NixKits | `6f52ddf` 以降（`modules/llama-cpp-rocm.nix`） | 名前空間 `services.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` 移行 |
| 上流 llama.cpp | b9605 | `--models-preset` CLI 引数維持 |

### 設定項目対応表

| 旧設定（非推奨） | 新設定 | 備考 |
|-----------------|--------|------|
| `services.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | nixpkgs 自削除、NixKits 以復元 |
| `services.llama-cpp-rocm.enable` | `nixkits.llama-cpp-rocm.enable` | 名前空間統一 |
| `services.llama-cpp-rocm.user` | `nixkits.llama-cpp-rocm.user` | 同上 |
| `services.llama-cpp-rocm.group` | `nixkits.llama-cpp-rocm.group` | 同上 |
| `services.llama-cpp.port` | `services.llama-cpp.settings.port` | nixpkgs 改名 |
| `services.llama-cpp.host` | `services.llama-cpp.settings.host` | nixpkgs 改名 |
| `services.llama-cpp.model` | `services.llama-cpp.settings.model` | nixpkgs 改名 |
| `services.llama-cpp.modelsDir` | `services.llama-cpp.settings.models-dir` | nixpkgs 改名 |
| 手動 `systemd.services.llama-cpp.serviceConfig` | 削除 | NixKits 部品自動処理 |
| `services.llama-cpp.extraFlags` | `services.llama-cpp.settings` 対応旗追加 | nixpkgs 削除 |

### 移行例

> **⚠️ 段階 1**: `flake.nix` 部品一覧 `nixkits.nixosModules.llama-cpp-rocm` 追加

**移行前**:

```nix
# flake.nix — 部品一覧
{ modules = [
    # nixkits.nixosModules.llama-cpp-rocm  # ← 未輸入
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
      # ⚠️ 歴史設定、現在有害確認済：StrixHalo 等統一記憶域機器模型輸出退化、
      # 危険量子化精度低下随増大。移行時必削除。
      # 「統一記憶域環境変数退化危険」節参照。
      "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
    ];
    ProcSubset = lib.mkForce "all";
  };
}
```

**移行後**:

```nix
# flake.nix — 部品一覧（追加）
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
  # NixKits 選項以覆非環境変数
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=~/.cache/huggingface/hub"
  ];
}
```
