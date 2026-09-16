# 已废弃项目

本文件记录 NixKits 中**曾经维护、现已废弃**的项目。每个条目说明：它曾解决什么问题、
为何可以废弃、以及废弃后应当怎么配置。

废弃不等于无价值 —— 多数条目是因为**上游已内置等效能力**。记录下来是为了让后来者
不必重新踩坑，也便于在回归时快速定位历史决策。

---

## 1. comfyui-rocm 补丁项目

**状态**：已废弃（2026-09-15）
**原位置**：`modules/comfyui-rocm.nix` + `patches/comfyui-nix-{strix-halo,nixpkgs-compat,stdenv-api}.patch`
**现状**：模块保留并更名为 `nixkits.comfyui`，**三个补丁全部删除**

### 我们很荣幸地看到上游开发者积极维护着项目并更新 ROCm 支持组件到了能很好支持 StrixHalo 设备的版本，本补丁的历史使命已经完成。

### 它曾解决什么

上游 `comfyui-nix` 的 ROCm 支持一度落后于 Strix Halo（gfx1151 / RDNA 3.5）的需求。
本补丁项目通过三个补丁补齐：

| 补丁 | 曾解决的问题 |
|------|-------------|
| `comfyui-nix-strix-halo` | 升级到 ROCm / PyTorch wheels，并加入 gfx1151 支持 |
| `comfyui-nix-nixpkgs-compat` | nixpkgs 漂移导致的构建失败（Python 测试在沙箱中不通过） |
| `comfyui-nix-stdenv-api` | 上游使用已弃用的 `stdenv.is<Platform>` 短写法，触发求值告警 |

### 为何可以废弃

上游 `comfyui-nix` **0.34.0** 已把上述内容全部内置：

- **ROCm 支持**：上游自带 ROCm 7.1 / PyTorch 2.10.0 wheels，其 `nix/versions.nix`
  中的版本、URL、hash 与我们的补丁产出**逐字节一致**；其模块原生支持
  `gpuSupport = "rocm"`。
- **stdenv 迁移**：上游已全面改用 `stdenv.hostPlatform.*`（旧写法 **0 处**，
  新写法 34 处），不再产生弃用告警。
- **nixpkgs 兼容**：上游已覆盖大部分 Python 测试跳过逻辑。

### ⚠️ 一次判定失误（值得记录）

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

**根因**是 nixpkgs 组合不同：上游 flake 用 `nixos-unstable`（其 scipy 命中公共缓存），
而下游常把 `comfyui-nix` 的 nixpkgs `follow` 到本地钉定的版本 —— 那个组合需要现建，
于是触发测试失败。

> **教训**：构建验证必须确认目标 derivation **真的被构建**，而非缓存命中。
> `nix build --dry-run` 的列表、以及构建日志中是否出现 `building '…'`，
> 才是"确实构建过"的证据。仅凭"构建成功"无法区分"构建通过"与"无需构建"。

### 废弃后如何配置

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

### 历史版本对照

| 项 | 补丁时代 | 现在 |
|----|---------|------|
| comfyui-nix 版本 | 0.30.2（本地 fork，14 个提交） | 上游 0.34.0 |
| ROCm wheels | 补丁植入 | 上游自带 |
| 输入来源 | `path:/home/kix/comfyui-nix-patched` | `github:utensils/comfyui-nix` |
| 补丁数量 | 3 | 0 |
