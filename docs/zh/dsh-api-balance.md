# dsh-api-balance

中文 | [English](../en/dsh-api-balance.md) | [日本語](../ja/dsh-api-balance.md)  | [偽中国語](../pcn/dsh-api-balance.md)

API 用量余额插件（DeepSeek Harness）——在 webui 用量圆圈（发送按钮左侧的上下文已用显示）的弹出面板中提供「用量 / 余额」标签切换。

> **本项目已迁出为独立仓库**：<https://github.com/Kihara777/dsh-api-balance>
>
> 它是一个**平台无关的 DSH 插件**（非 NixOS 专项），故独立分发并发布到 npm。
> **完整文档（四语）在新仓库内**：<https://github.com/Kihara777/dsh-api-balance#文档>
>
> 本页只保留 NixKits 独有的一节——**声明式安装**。

## 基本信息

| 项目 | 值 |
|------|-----|
| 源码仓库 | <https://github.com/Kihara777/dsh-api-balance> |
| npm 名 | `@kihara777/dsh-api-balance` |
| 类型 | DSH Host + Client 插件 |
| 许可 | MIT |
| NixKits 侧角色 | 薄封装包（提供声明式安装），不承载源码 |

## 安装

### 方式 A：`dsh plugin add`（DSH 原生）

```bash
dsh plugin --profile web add github:Kihara777/dsh-api-balance
# 或从 npm
dsh plugin --profile web add @kihara777/dsh-api-balance
```

### 方式 B：声明式（NixOS 模块，本页独有）

NixKits 保留 `pkgs.dsh-api-balance` 薄封装（从新仓库拉源码构建），使 NixOS 用户可声明式安装——版本由 Nix 锁定、随系统代际更新、可复现：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-api-balance;
    id = "api-balance";
    name = "@kihara777/dsh-api-balance";
    # config 可选：
    #   apiKeyEnv = "DEEPSEEK_API_KEY";   # credential-ref
    #   baseURL = "https://api.deepseek.com";
    #   browserScan = true;               # 本机浏览器自动扫描
    #   browserScanIntervalMs = 21600000; # 扫描节流（默认 6 小时）
  }];
}
```

> ⚠️ **不要与方式 A 同时使用**——两者注册同一 entry id 会重复。

## 薄封装的更新方式

`packages/dsh-api-balance.nix` 固定新仓库的一个 `rev` 与两个 hash（源码 + `npmDepsHash`）。
升级时需同步更新三者，通用流程见 `nix-flake-update-check` 技能。

## 功能概览

完整功能说明见[新仓库文档](https://github.com/Kihara777/dsh-api-balance)。概要：

- **余额**：DeepSeek 官方 `GET /user/balance`（API key 认证）
- **用量**：当日 / 当月 / 30 日消耗（金额 + token + 分模型明细）与按日 / 按月图表
- **平台令牌**：默认从本机浏览器登录态自动扫描，手动连接为回退
- **语音播报**：语音包 + TTS（浏览器内置 / 自定义 API），峰谷计费自动提示
- **界面增强**：峰时红色标识、疑问窗口滚动优化、底部统计条滚动等
