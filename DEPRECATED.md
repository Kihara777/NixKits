# 已废弃项目

中文 | [English](docs/DEPRECATED.en.md) | [日本語](docs/DEPRECATED.ja.md)  | [偽中国語](docs/DEPRECATED.pcn.md)

本文件是 NixKits 中**曾经维护、现已废弃**项目的**索引**。每个项目的详情
（它曾解决什么问题、为何可以废弃、废弃后应当怎么配置）见各自独立的说明文档。

废弃不等于无价值 —— 多数条目是因为**上游已内置等效能力**。记录下来是为了让后来者
不必重新踩坑，也便于在回归时快速定位历史决策。

## 列表

| 项目 | 上游状态（废弃原因） | 原位置 |
|------|------|--------|
| [comfyui-rocm 补丁项目](docs/zh/deprecated/comfyui-rocm.md) | 上游 comfyui-nix 0.34.0 已内置 ROCm 支持 | `modules/comfyui-rocm.nix` + 三个补丁 |
| [mcp-searxng 自建包](docs/zh/deprecated/mcp-searxng.md) | 上游 nixpkgs 已收录（2026-08-29，当前 2.6.0） | `packages/mcp-searxng.nix` + 三个构建工作流 |
| [nixkits-package-upstream 技能名](docs/zh/deprecated/nixkits-package-upstream.md) | 已被 `upstream-audit` 取代（2026-10-20 拆分：只读审计 + 本机私有提交层） | `skills/nixkits-package-upstream/` |
