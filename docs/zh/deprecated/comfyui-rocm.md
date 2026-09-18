# comfyui-rocm 补丁项目（已废弃）

中文 | [English](../../en/deprecated/comfyui-rocm.md) | [日本語](../../ja/deprecated/comfyui-rocm.md)  | [偽中国語](../../pcn/deprecated/comfyui-rocm.md)

[← 废弃项目索引](../../../DEPRECATED.md)

**状态**：已废弃（2026-09-15）
**原位置**：`modules/comfyui-rocm.nix` + `patches/comfyui-nix-{strix-halo,nixpkgs-compat,stdenv-api}.patch`
**现状**：模块保留并更名为 `nixkits.comfyui`，**三个补丁全部删除**

### 我们很荣幸地看到上游开发者积极维护着项目并更新 ROCm 支持组件到了能很好支持 StrixHalo 设备的版本，本补丁的历史使命已经完成。

## 它曾解决什么

上游 `comfyui-nix` 的 ROCm 支持一度落后于 Strix Halo（gfx1151 / RDNA 3.5）的需求。
本补丁项目通过三个补丁补齐：

| 补丁 | 曾解决的问题 |
|------|-------------|
| `comfyui-nix-strix-halo` | 升级到 ROCm / PyTorch wheels，并加入 gfx1151 支持 |
| `comfyui-nix-nixpkgs-compat` | nixpkgs 漂移导致的构建失败（Python 测试在沙箱中不通过） |
| `comfyui-nix-stdenv-api` | 上游使用已弃用的 `stdenv.is<Platform>` 短写法，触发求值告警 |

## 为何可以废弃

上游 `comfyui-nix` **0.34.0** 已把上述内容全部内置：

- **ROCm 支持**：上游自带 ROCm 7.1 / PyTorch 2.10.0 wheels，其 `nix/versions.nix`
  中的版本、URL、hash 与我们的补丁产出**逐字节一致**；其模块原生支持
  `gpuSupport = "rocm"`。
- **stdenv API**：⚠️ **此项原判定有误，已更正**。上游 **并未**迁移 —— 实测 0.34.0 仍保留
  `stdenv.is<Platform>` 短写法 **38 处**（`hostPlatform.is*` 仅 7 处），与 0.30.2 完全相同，
  故直接求值上游 flake/overlay 时弃用告警**依然会出现**。补丁不再需要的真实理由是
  **我们不再覆盖上游代码**：旧补丁把该迁移施加给一个会被 overlay 求值的 fork，以消除
  污染下游构建的告警；改为直接指向上游后，本模块只做声明式接线。
- **nixpkgs 兼容**：上游已覆盖大部分 Python 测试跳过逻辑。

## ⚠️ 一次判定失误（值得记录）

`comfyui-nix-nixpkgs-compat` 的废弃判定**曾经出错**，过程如下：

1. 初次评估时做了一次"完整构建验证"：717 个 derivation 全部成功，
   `scipy` / `jupyter-server` / `jupyterlab` / `fastapi` 等"需跳过测试"的包
   均无失败，据此判定补丁不再必要。
2. **但那次 `scipy` 是缓存命中，从未真正构建。** 检验的是二进制缓存里的产物，
   而非一次真实构建。
3. 实际升级后立即失败：

   ```
   scipy-1.18.0  test_support_moments_sample
     ACTUAL:  array([0., 0.])
     DESIRED: array([0.000000e+00, 2.010276e-09])
   ```

   正是该补丁注释中描述的"flaky 浮点断言"。

**根因是本地遗留的一个多余 pin**，而非"下游组合天然不同"：本机把 `comfyui-nix`
的 `inputs.nixpkgs` 钉死在 `6438090`（2026-08-02），而顶层走滚动 `nixos-unstable`。
顶层命中公共缓存，被钉住的子 flake 则需现建 `scipy` —— 于是"缓存本可解决的问题"
看起来像"需要打补丁"。**删掉那行 pin 后 `comfyui-nix` 与顶层共用 `dc5d91f`，
`scipy` 直接缓存命中，构建全绿、无需任何补丁。**

> **教训一**：构建验证必须确认目标 derivation **真的被构建**，而非缓存命中。
> `nix build --dry-run` 的列表、以及构建日志中是否出现 `building '…'`，
> 才是"确实构建过"的证据。仅凭"构建成功"无法区分"构建通过"与"无需构建"。
>
> **教训二**：额外的 `inputs.*` pin 会让子 flake **脱离主 nixpkgs 的缓存覆盖**，
> 把缓存本来能解决的问题暴露成需要打补丁的问题。加 pin 前先问它解决了什么；
> 问题消失后记得删。本项目的两个错误判定（"不需要"→"我们的组合恰好需要它"）
> 都是因为没追到这处 pin。

## 废弃后如何配置

**不再需要 fork，也不再需要任何补丁。** 直接把 `comfyui-nix` input 指向上游：

```nix
{
  inputs.comfyui-nix.url = "github:utensils/comfyui-nix";

  # 模块名与选项路径已更新（原 nixkits.comfyui-rocm）
  imports = [ inputs.nixkits.nixosModules.comfyui ];

  nixkits.comfyui.enable = true;
  services.comfyui = {
    enable = true;
    gpuSupport = "rocm";
    # rocmGfxOverride = "11.0.0";   # gfx1151 若未被识别时再启用
  };
}
```

> **重命名说明**：模块原名 `nixkits.comfyui-rocm`，因为其出身是"ROCm 补丁项目"。
> 补丁移除后它只剩**集成接线**职责（服务选项、设备权限、内核参数、C 工具链），
> 故更名为 `nixkits.comfyui`，使名字与实际职责一致。

**模块现状文档**：见 [`comfyui.md`](../comfyui.md)。

## 历史版本对照

| 项 | 补丁时代 | 现在 |
|----|---------|------|
| comfyui-nix 版本 | 0.30.2（本地 fork，14 个提交） | 上游 0.34.0 |
| ROCm wheels | 补丁植入 | 上游自带 |
| 输入来源 | `path:/home/kix/comfyui-nix-patched` | `github:utensils/comfyui-nix` |
| 补丁数量 | 3 | 0 |
