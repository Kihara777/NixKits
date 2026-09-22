# 维护模式 (Agent 预设)

中文 | [English](../../en/modes/maintenance.md) | [日本語](../../ja/modes/maintenance.md)  | [偽中国語](../../pcn/modes/maintenance.md)

> 基于 NixOS模式的仓库维护专用代理：注入文档撰写与维护日志技能、上游更新检查技能，并载入**分两层**的维护工作流提示词——通用方法 + 本仓（NixKits）适配层。

## 基本信息

| 项目 | 值 |
|------|-----|
| 模式 id | `maintenance` |
| 分发方式 | dsh-nixos-shell 包内 `presets/maintenance-mode/`，seed-once 复制到 `$DSH_HOME/.agent-presets/maintenance` |
| 开启选项 | `nixkits.dsh.presets.maintenanceMode = true` |
| 派生自 | [NixOS模式](nixos.md)（组合末尾追加固定行块） |
| 文档 | [dsh-nixos-shell.md](../dsh-nixos-shell.md)（分发本模式的包） |

## 行为

在 NixOS模式的全部能力之上追加：

- **运行时技能**：`maintenance-skills` 入口在 apply 时从**构建期嵌入**的仓库 `skills/` 树注册 `write-project-docs`、`write-maintenance-log`、`nix-flake-update-check`、`nixkits-check-updates`，并自动发现全部 `translate-*` 语言扩展——技能内容以仓库 `skills/` 为单一来源，全新会话即最新。
- **维护工作流提示词，分两层**（与上面技能的分法一致：通用方法 ← 仓库适配层）：

  | 段名 | 作用域 | 内容 |
  |------|--------|------|
  | `maintenance-workflow`（序号 901） | **通用**——任何仓库都成立 | 按逻辑类别分批提交、推送后记录、文档与代码同步、修复泛化到技能、技能内容单一来源 |
  | `maintenance-workflow-repo`（序号 902） | **本仓（NixKits）约定** | 四语与文档基准（`docs/zh/` 先写）、`write-maintenance-log` 为准绳、条目数一致的可核验判据、技能树单一来源 |

  判据只有一句：**这条规矩换个仓库还成立吗？** 成立留在通用层，不成立进适配层。
  通用层里不出现任何本仓专名（NixKits / 四语 / `translate-*` / `MAINTENANCE.md` / `grep -c` / `docs/zh`）。

  组件选项 `repoWorkflow: false` 可只留通用层，供「维护另一个仓库」的会话使用。
- 其余（系统校验、`nixos_shell` / `nixos_cli`、开发提示词、NixOS模式同捆的 5 个技能）与 NixOS模式一致。

## 派生关系

维护模式的组合文件 = NixOS模式组合**末尾追加固定的 `maintenance-skills` 行块**（含注释），两预设的 `skills/` 目录逐文件一致——除此之外不得有任何差异。

```yaml
- id: maintenance-skills
  name: '@kihara777/dsh-nixos-shell/maintenance-skills'
```

`develop/check-preset-derivation.py` 校验该派生关系，并挂入 `nix flake check`（CI 每次 push 执行）；漂移时检查失败，修复后才能提交。刻意变更追加块本身时，需同步更新脚本内的 `MAINTENANCE_DELTA` 常量。详见仓库 `AGENTS.md`「预设」一节。

## 安装

```nix
{
  nixkits.dsh = {
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;
    presets.maintenanceMode = true;
  };
}
```

## 注意

- 与 NixOS模式同为 **seed-once**：`$DSH_HOME/.agent-presets/maintenance` 已存在时不覆盖，改动请直接编辑该目录（模块会放开写权限）。
- 修改 NixOS模式后必须把相同改动镜像到维护模式，否则 `nix flake check` 会因派生漂移失败。
