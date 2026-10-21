# nix-packaging (Skill)

[中文](../../zh/skills/nix-packaging.md) | [English](../../en/skills/nix-packaging.md) | [日本語](../../ja/skills/nix-packaging.md)  | 偽中国語

> 上流 software 零 從 Nix 式 package 化。

## 基本情報

| 項 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| path | `skills/nix-packaging/SKILL.md` |
| 対象 | 「此 software package 未 有」最初 一歩 |

## 四層 受入

| 層 | 判据 | 罠 |
|---|---|---|
| 評価 | `nix eval` 期待 version 返 | 評価可 build 可 限 無 |
| build | log `building` 出（全 cache 非） | cache 命中 = 一行 build 無 |
| 成果物 | `$out/bin` 空 非 | 空 bin = 無駄 build |
| 実行 | `--help` 終了 code 0 | node wrapper 欠 此層 初出 |

## 範囲

- 来源別 分岐（GitHub source / npm / Rust / prebuilt / Gitea / PyPI）
- hash 二段階（`lib.fakeHash` → `got:` 読 → 埋 → **再 build 受入**）
- vendored lock 生成（npm、`--legacy-peer-deps` 罠）
- wrapper 必要時
- 本 repo 約束（`__structuredAttrs` 與 交叉編訳 衝突）與 実測 罠 六件

## 範囲外

- 既存 package version 更新 → `nix-flake-update-check`
- 上流 投稿 → `upstream-audit`
