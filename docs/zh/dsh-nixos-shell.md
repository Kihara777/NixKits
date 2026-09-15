# dsh-nixos-shell

中文 | [English](../en/dsh-nixos-shell.md) | [日本語](../ja/dsh-nixos-shell.md)  | [偽中国語](../pcn/dsh-nixos-shell.md)

NixOS 场景能力的 DeepSeek Harness（DSH）插件——**单一插件整合** shell 执行、工具引导、sudo 守护路由与只读 NixOS 诊断。功能需求源自 `nixos-modern-cli` 技能的场景描述（NixOS 声明式不可变、PATH 极简、现代 CLI、系统维护、Nix store 路径陷阱）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | DSH Host 插件（npm 包） |
| npm 名 | `@kihara777/dsh-nixos-shell` |
| 版本 | `0.1.0` |
| 许可 | MIT |
| 前置 | 宿主 dsh 树（`subprocess`/`timer`/`tools` 能力接缝与 peer 依赖） |
| 替代 | `dsh-nix-shell`（shell 工具 + sudo 守护）与 `dsh-skill-nixkits`（7 技能插件，已废弃） |

## 工具

### nixos_shell — shell 执行器

| 参数 | 说明 |
|------|------|
| `command` | 要执行的 shell 命令（必填） |
| `tools` | 可选 POSIX 工具名列表，命令经 `nix shell nixpkgs#<pkg>… --command` 执行。白名单：python3、python、grep、ls、cat、head、tail、wc、tr、sort、mkdir、rm、cp、mv、find、env、sed、bash、awk、git、curl、jq、ripgrep、rsync、htop、tree、unzip |
| `workdir` / `timeoutMs` / `env` | 工作目录 / 超时（受配置上限约束）/ 追加环境变量（合并于注入的 NixOS PATH） |
| `run_in_background` | `true` 时注册 dsh-jobs 后台任务并立即返回 job id（经 `job_output` 读取、`job_kill` 停止，无客户端超时上限；`sudo: true` 任务受守护侧单请求上限约束）。适合 `nixos-rebuild` 等长命令——避免工具结果因执行时间过长被丢弃。本地任务支持增量输出；`sudo: true` 任务经守护协议 v3 执行，`job_kill` 通过显式取消行让守护杀死子进程。**注意**：rebuild 的激活阶段会重启 dsh 服务（插件路径烧进服务 unit），进程内 job 记录随之清空——rebuild 结束后应经 `nixos_cli op=generations` 验证完成，命令本身会在守护中继续运行到完成（断连绝不取消） |
| `sudo` / `justification` | 检测到 sudo 守护套接字时启用：`sudo: true` 将请求路由至外部 root 执行器，`justification` 必填并随结果回显 |

行为：优先经 PATH 解析 `bash`，失败回退 Nix store shell 路径（修复内置 bash 工具的 `spawn bash ENOENT`）；每个子进程注入完整 NixOS PATH；输出截断 + 溢出文件。

### nixos_cli — 只读 NixOS 诊断

| op | 说明 |
|----|------|
| `capabilities` | 探测 nixos / nix-command / 解析到的 shell / sudo 守护可用性，输出推荐 rebuild 命令与传统→现代命令对照表 |
| `system-status` | `systemctl is-system-running` + 失败单元列表 |
| `generations` | 系统 profile 代际列表，新→旧；`limit` 参数默认 20、上限 200，返回当前代与总数 |
| `journal` | 指定 unit 的日志尾部（`unit` 必填，支持 `*`/`%` 通配，尾随 `@` 自动补 `*` 匹配模板全部实例；`lines` 默认 50 上限 500） |
| `audit-store-paths` | 扫描 `~/.gitconfig`/`~/.bashrc`/`~/.zshrc`/`~/.profile` 中的 `/nix/store/` 绝对路径（gc 后失效风险），检查 git 凭据助手形式并给出修复规则 |

变更性维护（`nix store gc`、`nix store optimise`、rebuild）经 `nixos_shell` 的 `sudo: true` 执行——提权始终携带显式 justification。

## 架构

```
nixos-shell 插件
├─ nixos_shell ── 本地: ctx.subprocess（PATH 注入 + 溢出/超时）
│                └─ sudo: Unix 套接字 → nixkits-sudo@.service（root，systemd 套接字激活）
└─ nixos_cli ──── 只读本地执行（systemctl / nix-env / journalctl / 配置文件扫描）
```

sudo 守护 = systemd 套接字激活的 root 执行器（`nixkits-sudo-exec.js`，随插件包发布）：单请求单连接 JSON 协议（v3：客户端写入一行请求后保持连接打开，守护读首行即执行，完成回写响应并退出；请求行之后的任何输入行 = 显式取消，守护对子进程**整组** SIGTERM、宽限后 SIGKILL——只杀 shell 包装进程会留下继承管道写端的孤儿孙进程并卡死守护——这是 `job_kill` 的带内取消机制）。**连接断开不是取消**：rebuild 的激活阶段重启 dsh 服务会断开连接，若按断开取消则 switch 在激活中途被杀、留下部分激活状态，因此对端消失时子进程以分离方式继续运行到完成（守护侧超时上限 6 小时，rebuild 命令自动使用该上限）。访问控制边界为套接字文件（归 dsh 服务用户所有、`0600`）。PATH 合并顺序：继承 env 在前、显式 NixOS profile PATH 在后（systemd 模板单元的默认 PATH 只含基础 store 路径）。

### rebuild / dsh 重启自动分离

`nixos_shell` 识别出 `nixos-rebuild` / `nixos apply` / `systemctl restart dsh` 命令（`sudo: true`）后自动将其包装进 `systemd-run --collect` 瞬态单元（独立 cgroup）执行，调用立即返回单元名（结果含 `detachedUnit`）。原因：若这些命令经守护执行，其触发的 dsh 重启或 socket 停止会连同调用链自身一起杀掉（@ 实例与子进程同 cgroup，或 harness 进程即本调用宿主），激活中途死亡、socket 无法自动恢复、调用结果丢失。分离执行后进程完整跑完；进度经 `nixos_cli op=journal unit=nixkits-rebuild-<id>` 查看，结果经 `nixos_cli op=generations` 验证。

分离调用的结果**不声称构建成败**：返回 `detached: true` + `detachedUnit` + `note` 且 `exitCode` 为 `null`（systemd-run 仅完成交接，交接成功 ≠ 构建成功），真实结果一律经 journal/generations 验证。

模块侧配合「稳定挂载点」（见 dsh.md）：插件包更新不再改变 dsh/sudo 的 unit 内容，普通 rebuild 已不重启任何东西；插件更新经显式 `systemctl restart dsh`（同样自动分离）生效，sudo 守护按连接生成、新连接自动用新脚本。

sudo 套接字在**调用时**校验而非 apply 时：rebuild 激活期间 socket 会短暂消失，恰在该窗口启动的会话不会永久丢失 `sudo` 参数——socket 恢复后即可直接使用。

## 使用

推荐经 `nixkits.dsh` 模块声明式安装（自动注入 node_modules + 生成组合行）：

```nix
{
  nixkits.dsh = {
    sudo.enable = true;                 # 部署 sudo 守护并注入 NIXKITS_SUDO_SOCKET
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
  };
}
```

工具调用：

```
nixos_shell(command = "nix flake check", tools = ["git" "jq"])

# 变更性维护：经 sudo 守护以 root 执行
nixos_shell(command = "nixos-rebuild switch --flake /etc/nixos", sudo = true, justification = "...")

nixos_cli(op = "capabilities")
nixos_cli(op = "journal", unit = "dsh", lines = 30)
nixos_cli(op = "audit-store-paths")
```


## 分发的模式

本包随包分发两个 **Agent 预设（模式）**，两者的行为、组合结构、persona 行 schema、派生维护规则与安装片段都在各自的独立文档里：

| 模式 | id | 说明 | 文档 |
|------|-----|------|------|
| NixOS模式 | `nixos` | 宿主校验 + `nixos_shell` / `nixos_cli` + 开发提示词 | [modes/nixos.md](modes/nixos.md) |
| 维护模式 | `maintenance` | 派生自 NixOS模式；文档 / 日志 / 更新检查技能 + 维护工作流 | [modes/maintenance.md](modes/maintenance.md) |

两者均由模块经 `nixkits.dsh.presets.nixosMode` / `presets.maintenanceMode` **seed-once** 写入 `$DSH_HOME/.agent-presets/<id>`：

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

门控入口为包内子路径 `@kihara777/dsh-nixos-shell/nixos-gate`，仅在预设组合中挂载，不影响全局会话。第三个模式「新闻三要素模式」**不由本包分发**，而是独立包 `dsh-preset-news-three-elements` —— 见 [modes/news-three-elements.md](modes/news-three-elements.md)。
