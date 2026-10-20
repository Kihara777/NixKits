# 廃止工程

[中文](../DEPRECATED.md) | [English](DEPRECATED.en.md) | [日本語](DEPRECATED.ja.md)  | 偽中国語

本文件 NixKits 中**曾 保守、現在 廃止** 工程 之 **索引**。各工程 詳細
（曾 何 解決、為何 廃止 可能、廃止後 設定方法）各自 独立 説明文書 参照。

廃止 無価値 意味 非 —— 多数 項目 上流 同等 能力 内蔵 理由。記録 故、
後 来者 同一 穴 踏 無、回帰時 過去 判断 速 辿 可能。

## 一覧

| 工程 | 上流状態（廃止理由） | 旧位置 | 詳細 |
|------|------|--------|------|
| comfyui-rocm 補丁工程 | 上流 comfyui-nix 0.34.0 ROCm 支援 内蔵 | `modules/comfyui-rocm.nix` + 三補丁 | [中文](zh/deprecated/comfyui-rocm.md) · [EN](en/deprecated/comfyui-rocm.md) · [JA](ja/deprecated/comfyui-rocm.md) · [PCN](pcn/deprecated/comfyui-rocm.md) |
| mcp-searxng 自前 package | 上流 nixpkgs 収録済（2026-08-29、現在 2.6.0） | `packages/mcp-searxng.nix` + 三 build workflow | [中文](zh/deprecated/mcp-searxng.md) · [EN](en/deprecated/mcp-searxng.md) · [JA](ja/deprecated/mcp-searxng.md) · [PCN](pcn/deprecated/mcp-searxng.md) |
