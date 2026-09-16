# comfyui-rocm 補丁工程（既廃止）

[中文](../../zh/deprecated/comfyui-rocm.md) | [English](../../en/deprecated/comfyui-rocm.md) | [日本語](../../ja/deprecated/comfyui-rocm.md)  | 偽中国語

[← 廃止工程索引](../../../DEPRECATED.md)

**状態**：既廃止（2026-09-15）
**旧位置**：`modules/comfyui-rocm.nix` + `patches/comfyui-nix-{strix-halo,nixpkgs-compat,stdenv-api}.patch`
**現状**：模組 保留 且 `nixkits.comfyui` 改名、**三補丁 全部 削除**

### 我们很荣幸地看到上游开发者积极维护着项目并更新 ROCm 支持组件到了能很好支持 StrixHalo 设备的版本，本补丁的历史使命已经完成。

## 曾 何 解決

上流 `comfyui-nix` 之 ROCm 支持 曾 Strix Halo（gfx1151 / RDNA 3.5）要求 遅。
本補丁工程 三補丁 補：

| 補丁 | 曾 解決 問題 |
|------|-------------|
| `comfyui-nix-strix-halo` | ROCm / PyTorch wheel 更新、gfx1151 支持 追加 |
| `comfyui-nix-nixpkgs-compat` | nixpkgs drift 原因 構築失敗（sandbox 内 Python test 不通過） |
| `comfyui-nix-stdenv-api` | 上流 非推奨 `stdenv.is<Platform>` 短記法 使用、評価警告 発生 |

## 為何 廃止 可能

上流 `comfyui-nix` **0.34.0** 上述 全部 内蔵 済：

- **ROCm 支持**：上流 ROCm 7.1 / PyTorch 2.10.0 wheel 自帯、其 `nix/versions.nix`
  中 版・URL・hash 我々 補丁 産物 与 **逐 byte 一致**；其 模組 原生
  `gpuSupport = "rocm"` 支持。
- **stdenv 移行**：上流 全面 `stdenv.hostPlatform.*` 移行 済（旧記法 **0 処**、
  新記法 34 処）、非推奨警告 無。
- **nixpkgs 互換**：上流 Python test 跳过 logic 大半 既 cover。

## ⚠️ 一度 誤判定（記録 値）

`comfyui-nix-nixpkgs-compat` 之 廃止判定 **当初 誤**：

1. 初回評価 時「完全構築検証」行：717 derivation 全部 成功、
   `scipy` / `jupyter-server` / `jupyterlab` / `fastapi` 等「test 跳过 必要」
   包 失敗 無、依此 補丁 不要 判定。
2. **但 其回 `scipy` 緩衝命中、一度 実際 未構築。** 検証 緩衝内 産物、
   非 現実 構築。
3. 実際 昇級 後 直 失敗：

   ```
   scipy-1.18.0  test_support_moments_sample
     ACTUAL:  array([0., 0.])
     DESIRED: array([0.000000e+00, 2.010276e-09])
   ```

   正 補丁 自身 注釈 述「flaky 浮動小数点 assertion」。

**真 根因 本機 残留 一 余分 pin** —— 非「下流 組合 本質的 異」。
本機 `comfyui-nix` 之 `inputs.nixpkgs` `6438090`（2026-08-02）固定、一方
top level rolling `nixos-unstable` 追。top level 公共緩衝 命中、固定 子 flake
`scipy` 現 構築 必要 —— 故「緩衝 解決 其 問題」「補丁 必要 問題」見。
**其 pin 行 削除 後 `comfyui-nix` top level `dc5d91f` 共有、`scipy` 直 緩衝命中、
構築 全通過、補丁 一切 不要。**

> **教訓一**：構築検証、対象 derivation 緩衝命中 非 **真実 構築** 確認 必須。
> `nix build --dry-run` 一覧、及 構築 log `building '…'` 行 出現 ——
> 此「確 構築」証拠。「構築成功」唯「構築通過」與「構築 不要」区別 不能。
>
> **教訓二**：余分 `inputs.*` pin 子 flake **主 nixpkgs 緩衝被覆 切離**、
> 緩衝 解決 其 問題 補丁 必要 問題 見做。pin 加 前 其 何 解決 問、
> 問題 消 後 削除 忘 無。本工程 二度 誤判定（「不要」→「我々 組合 偶然 必要」）
> 皆 此 pin 到達 不能 原因。

## 廃止後 設定方法

**既 fork 也 補丁 不要。** `comfyui-nix` input 上流 直接 向：

```nix
{
  inputs.comfyui-nix.url = "github:utensils/comfyui-nix";

  # 模組名 與 選項 path 更新 済（旧 nixkits.comfyui-rocm）
  imports = [ inputs.nixkits.nixosModules.comfyui ];

  nixkits.comfyui.enable = true;
  services.comfyui = {
    enable = true;
    gpuSupport = "rocm";
    # rocmGfxOverride = "11.0.0";   # gfx1151 認識 無 場合 唯 有効化
  };
}
```

> **改名 就**：模組 曾 `nixkits.comfyui-rocm` —— 其 出自「ROCm 補丁工程」故。
> 補丁 消 今、其 責務 **統合 配線**（服務選項、設備権限、kernel parameter、
> C toolchain）唯 成、故 実際 責務 合 `nixkits.comfyui` 改名。

**模組 現状 文書**：[`comfyui.md`](../comfyui.md) 参照。

## 歴史版本対照

| 項 | 補丁時代 | 現在 |
|----|---------|------|
| comfyui-nix 版本 | 0.30.2（局所 fork、14 commit） | 上流 0.34.0 |
| ROCm wheel | 補丁 注入 | 上流 自帯 |
| 輸入元 | `path:/home/kix/comfyui-nix-patched` | `github:utensils/comfyui-nix` |
| 補丁数 | 3 | 0 |
