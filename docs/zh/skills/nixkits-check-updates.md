# nixkits-check-updates (Skill)

[中文](nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-check-updates.md) | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> 检查 NixKits 所有软件包和补丁的上游版本更新，自动升级并更新文档；将修复写入维护日志。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixkits-check-updates/SKILL.md` |

## 功能

- 从 `flake.nix` 自动发现所有外部包并检查最新 GitHub Release
- 更新构建配置（版本号、source hash、npmDepsHash）
- 同步更新多语文档中的版本号
- 更新完成后自动调用 `write-maintenance-log` 技能撰写维护记录
- 报告本地已安装版本
- 识别补丁文件内的硬编码版本并提供检查指引

## hash 计算注意事项

- SRI hash 必须用标准 base64（`+` `/` `=`），不能使用 URL-safe 变体（`-` `_`）
- `fetchFromGitHub` 的 source hash **不能**从 GitHub archive tarball 预计算，必须通过 `nix build` 的 hash mismatch 错误获取
- `npmDepsHash` 清空时使用 `lib.fakeHash` 而非空字符串 `""`
- npm 包需两次 `nix build`：第一次获取 source hash，第二次获取 npmDepsHash

## 检查范围

动态读取 `flake.nix` → `packages`，排除以下类别：
- 自建软件包（源码在仓库内）
- 动态版本追踪（构建时获取最新版）
- 跟随 nixpkgs 版本（补丁覆盖）
- 补丁内硬编码版本（需手动检查，如 `comfyui-strix-halo`）

其余外部包均自动纳入更新检查。

## 使用

由 AI 助手在用户要求「检查软件更新」或「更新包版本」时激活。
