# mcp-searxng 自前 package（廃止済）

[中文](../../zh/deprecated/mcp-searxng.md) | [English](../../en/deprecated/mcp-searxng.md) | [日本語](../../ja/deprecated/mcp-searxng.md)  | 偽中国語

[← 廃止工程索引](../../../DEPRECATED.md)

**状態**：廃止（2026-10-20）
**旧位置**：`packages/mcp-searxng.nix` + `.github/workflows/build-mcp-searxng-{x86_64,aarch64,riscv64}.yml`
**現状**：package 定義 與 三 build workflow 削除済；flake 與 devshell nixpkgs 同名属性 参照；overlay 行 削除（nixpkgs 提供 故、残 自己参照 化）。

## 曾 何 解決

NixKits mcp-searxng（SearXNG 向 MCP server）自前 package 化、三 workflow x86_64 /
aarch64 / riscv64 成果物 build、Cachix push。

## 為何 廃止 可能

上流 nixpkgs **2026-08-29** 収録（`init at 2.1.0`）、2026-10-13 **2.6.0** 更新。
現在 版本 與 二 hash **完全一致**：

| 項 | 本倉（旧） | nixpkgs |
|---|---|---|
| 版本 | 2.6.0 | 2.6.0 |
| src hash | `sha256-dbxJSS…` | 同一 |
| npmDepsHash | `sha256-+df6o…` | 同一 |
| `__structuredAttrs` / `strictDeps` | 有 | 有 |
| wrapper | 手動 `makeWrapper` | 無（`buildNpmPackage` 処理） |

nixpkgs 版 簡潔、`mcp-searxng --help` 実測 動作。

## 廃止後 設定方法

```nix
environment.systemPackages = [ pkgs.mcp-searxng ];
```

或 本倉 別名（等価）：`inputs.nixkits.packages.${pkgs.system}.mcp-searxng`。

## 一 判据

廃止前 検証 **command 動作**（`mcp-searxng --help`）、「版本 同一」 非 ——
nixpkgs 版 手動 wrapper 無、二 定義 等価 非。「同 版本」 從 「同 挙動」 導 不能。
