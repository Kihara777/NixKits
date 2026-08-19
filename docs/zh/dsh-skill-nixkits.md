# dsh-skill-nixkits

中文 | [English](../en/dsh-skill-nixkits.md) | [日本語](../ja/dsh-skill-nixkits.md)  | [偽中国語](../pcn/dsh-skill-nixkits.md)

NixKits 全部 7 个技能的原生 DeepSeek Harness（DSH）技能插件包。**每个技能是一个插件条目**（包内子路径导出）：插件在运行时经 `ctx.skills.register` 注册自身内容（runtime provider，rank 250，优先于 `~/.dsh/skills` 等文件系统来源），随组合挂载/卸载、可被 `plugins.disabled` 按 entry id 关闭、进入 dsh 插件清单与设置 UI。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | DSH Host 插件（npm 包，零运行时依赖）|
| npm 名 | `@kihara777/dsh-skill-nixkits` |
| 版本 | `0.1.0` |
| 许可 | MIT |
| 内容来源 | 仓库 `skills/`（构建期嵌入，单一来源）|

## 插件条目

| 子路径 | 插件名 | 技能 |
|--------|--------|------|
| `nixkits-check-updates` | `skill-nixkits-check-updates` | 软件包上游版本检查与自动应用 |
| `nixkits-skills` | `skill-nixkits-skills` | 技能安装到各编码助手目录 |
| `nixos-modern-cli` | `skill-nixos-modern-cli` | NixOS 现代 CLI 工作规范 |
| `recover-nixos-config` | `skill-recover-nixos-config` | 从 Nix store 恢复 /etc/nixos |
| `translate-pseudocn` | `skill-translate-pseudocn` | 伪中国语文档本地化 |
| `write-maintenance-log` | `skill-write-maintenance-log` | 维护日志撰写规范 |
| `write-project-docs` | `skill-write-project-docs` | 多语言项目文档生成 |

## 架构

```
组合行（每技能一条）
  └─ 插件 apply() → ctx.skills.register({ name, description, content, source: "runtime",
                                           resourceBase: { kind: "directory", path: <技能目录> },
                                           metadata: <frontmatter 字段> })
```

- **内容单一来源**：SKILL.md 保留在仓库 `skills/`，构建期（`postPatch cp -r`）嵌入包内；NixKits 文档流水线的自动发现契约（frontmatter 的 `language_code`/`display_name`/`base_language`）不受影响，字段同步保留进 `metadata`
- **注册生命周期**：`apply()` 返回 `skills.register()` 的 disposer，随组合卸载而撤销
- **零依赖**：仅消费 `skills` 能力接缝，peer 由宿主 dsh 树提供

## 使用

推荐经 `nixkits.dsh.skills` 一键注册全部 7 条组合行：

```nix
{
  nixkits.dsh.skills = {
    enable = true;
    package = pkgs.dsh-skill-nixkits;  # 默认值
  };
}
```

手工组合行（选择性挂载，npm 包可从 dsh 解析时）：

```yaml
- id: skill-nixos-modern-cli
  name: '@kihara777/dsh-skill-nixkits/nixos-modern-cli'
```

关闭单个技能（与普通插件一致）：

```nix
nixkits.dsh.plugins.disabled = [ "skill-translate-pseudocn" ];
```
