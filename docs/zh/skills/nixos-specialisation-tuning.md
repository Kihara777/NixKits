# nixos-specialisation-tuning (Skill)

中文 | [English](../../en/skills/nixos-specialisation-tuning.md) | [日本語](../../ja/skills/nixos-specialisation-tuning.md)  | [偽中国語](../../pcn/skills/nixos-specialisation-tuning.md)

> 为 NixOS 设计 specialisation 分面，并在统一内存（UMA）设备上调优 llama.cpp 本地推理。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixos-specialisation-tuning/SKILL.md` |

## 功能

- **分面架构**：三文件布局（默认面 / 可选面 / 共用底座）与覆盖冲突规则
- **归属原则**：配置项放在其消费者所在模块，避免跨面副作用
- **llama.cpp 调优**：UMA 设备上的参数速查表与禁用项
- **诊断顺序**：输出退化时先排除环境变量，再怀疑量化与模板
- **上下文开销分析**：检测 Agent 工具 schema 的每轮固定开销
- **静默故障诊断**：识别"服务 active 但功能失效"类问题
- **实验有效性自检**：识别无效对照实验

## 使用

由 AI 助手在以下场景激活：

| 场景 | 触发 |
|------|------|
| 配置拆分 | 需要"默认精简 + 可选全功能"两套启动配置 |
| 推理异常 | 本地 llama.cpp 输出退化、加载失败、速度异常 |
| 优化决策 | 需要成本/收益/代价评估，而非单一收益数字 |
| 疑难排查 | 服务运行正常但功能不工作 |

## 核心原则

| 原则 | 说明 |
|------|------|
| 不在列表属性上用 `mkForce` | 会删除其它模块的贡献；`systemPackages` 用追加 |
| 配置归属消费者 | 不使用某服务的面不该承受其副作用 |
| 先实测再宣称收益 | 未经实测的数字不写入建议 |
| 读配置日志不只看 systemd 状态 | 未加载模块的配置键会被静默忽略 |
| 实验与生产矛盾时先疑实验 | 而非生产环境 |
