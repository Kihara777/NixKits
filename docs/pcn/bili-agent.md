# bili-agent

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-bili-agent-x86_64.yml?branch=main&label=x86_64%20v1.3.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-bili-agent-aarch64.yml?branch=main&label=aarch64%20v1.3.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/bili-agent.md) | [English](../en/bili-agent.md) | [日本語](../ja/bili-agent.md)  | 偽中国語

AI 代理為設計之 B 站命令行工具。各命令只於 stdout 出**一箇 JSON**、零対話、
帳号操作附帯限流・監査日志・私信白名単。命令名 `bili`。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 1.3.0 |
| 上流 | [kukemc/bili-cli](https://github.com/kukemc/bili-cli) |
| 類型 | Python 応用（hatchling） |
| 許可 | MIT |
| 平台 | x86_64 / aarch64 |
| 命令 | `bili` |

## 本倉亦自帯一箇庫之理由

上流固定 `bilibili-api-python==17.4.2`、然 **nixpkgs 無其庫**（2026-11-04 逐一確認）。
故本倉亦包 `packages/bilibili-api-python.nix`。実行期依存的 12 箇全部来自 nixpkgs、
構建期 追加 `setuptools-scm` 必要——層之誤 則 `Unmet dependencies … setuptools-scm` 落。

以 nixpkgs 之新版代替 非選択肢：`==` 為厳格制約、検査飛 則 実行時挙動差 出現
（同族 `blender-mcp` 曾踏 `mcp<2`）。

## 用法

```bash
bili auth status          # 先看登録態
bili feed inbox           # 此回之新着
bili video watch <BV>     # 情報 + AI 摘要 + 全文 + 熱評 + 弾幕山 + 画面総覧
bili schema               # 全命令之機構可読説明
```

書込操作 全部 `--dry-run` 対応。全命令表 在 技能 `bili-cli`（lampkeeper 模式内）
或 上流 `skills/bili-cli/SKILL.md`。

## 登録

一度之 QR 読取：`bili auth login` 返 `qr_image`（本地 PNG 路径）与 180 秒有効之 `qr_url`、
以 Bilibili App 読取、其後 `bili auth status --wait 120`。憑据 落 `~/.config/bili-cli/`、
**不入 nix store、不入 倉庫**。

## 既知之限界

- 構建 只 x86_64 与 aarch64。無 riscv64 之 workflow——`curl-cffi` 之 riscv64 対応 未検証、
  **不書 即 不約束**。
- 上流 為 MIT、然 閉包内之 `bilibili-api-python` 為 GPL-3.0-or-later。頒布義務 各自掛。
