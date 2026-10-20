# 廃止プロジェクト

[中文](../DEPRECATED.md) | [English](DEPRECATED.en.md) | 日本語  | [偽中国語](DEPRECATED.pcn.md)

本ファイルは NixKits において**かつて保守され、現在は廃止された**プロジェクトの
**索引**である。各プロジェクトの詳細（かつて何を解決していたか、なぜ廃止できるか、
廃止後の設定方法）は、それぞれ独立した説明文書を参照のこと。

廃止は無価値という意味ではない —— ほとんどの項目は**上流が同等の能力を内蔵した**
ことが理由である。記録しておくことで、後から来る者が同じ穴を踏まずに済み、
回帰時に過去の判断を素早く辿れる。

## 一覧

| プロジェクト | 上流の状態（廃止理由） | 旧位置 | 詳細 |
|--------------|------|--------|------|
| comfyui-rocm パッチプロジェクト | 上流 comfyui-nix 0.34.0 が ROCm サポートを内蔵 | `modules/comfyui-rocm.nix` + 三つのパッチ | [中文](zh/deprecated/comfyui-rocm.md) · [EN](en/deprecated/comfyui-rocm.md) · [JA](ja/deprecated/comfyui-rocm.md) · [PCN](pcn/deprecated/comfyui-rocm.md) |
| mcp-searxng 自前パッケージ | 上流 nixpkgs が収録済み（2026-08-29、現在 2.6.0） | `packages/mcp-searxng.nix` + 三つのビルドワークフロー | [中文](zh/deprecated/mcp-searxng.md) · [EN](en/deprecated/mcp-searxng.md) · [JA](ja/deprecated/mcp-searxng.md) · [PCN](pcn/deprecated/mcp-searxng.md) |
