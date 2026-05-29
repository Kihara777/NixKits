# mcp-searxng

[SearXNG](https://docs.searxng.org) 的 [MCP Server](https://modelcontextprotocol.io)，为 AI 助手提供网页搜索能力。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 1.0.3 |
| 上游 | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## 引用

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];

# Default overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## 配置示例

```json
{
  "mcpServers": {
    "searxng": {
      "command": "mcp-searxng",
      "env": { "SEARXNG_URL": "http://127.0.0.1:4270" }
    }
  }
}
```

SearXNG 需启用 JSON 格式：

```yaml
# settings.yml
search:
  formats:
    - html
    - json
```
