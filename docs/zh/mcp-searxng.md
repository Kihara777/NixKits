# mcp-searxng

中文 | [English](../en/mcp-searxng.md) | [日本語](../ja/mcp-searxng.md)  | [偽中国語](../pcn/mcp-searxng.md)

**状态**：已废弃（2026-10-20）—— 上游 nixpkgs 已收录，本仓不再自行打包。
详情见[废弃项目说明](deprecated/mcp-searxng.md)。

## 现在怎么用

**直接从 nixpkgs**

```nix
environment.systemPackages = [ pkgs.mcp-searxng ];
```

经本仓的别名等价（`inputs.nixkits.packages.${pkgs.system}.mcp-searxng` 指向同一个包）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 2.6.0（跟随 nixpkgs） |
| 上游 | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |
| nixpkgs 属性 | `mcp-searxng` |
| nixpkgs 加入时间 | 2026-08-29（init 2.1.0） |

> SearXNG 的 MCP Server，为 AI 助手提供网页搜索能力。运行时需要 `SEARXNG_URL` 环境变量。
