---
name: nixkits-skills
description: 将 NixKits 技能安装或更新到编码助手目录（opencode、codewhale、codex、openclaw、agents）。支持本地和在线两种安装模式。DeepSeek Harness (dsh) 不再作为安装目标——其 NixOS 场景能力由 nixos-shell 插件提供。
---

# NixKits 技能安装器

将 NixKits 技能安装到各编码助手的技能目录中。

## 支持的助手

| 助手 | 技能目录 |
|------|---------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Codex | `~/.codex/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| 通用 | `~/.agents/skills/` |

> **dsh 例外**：DeepSeek Harness 不再是安装目标。其 NixOS 场景能力（shell 执行、工具引导、sudo 守护、NixOS 诊断）已整合进 `nixos-shell` 插件（`@kihara777/dsh-nixos-shell`），经 `nixkits.dsh.plugins.packages` 声明式挂载。

## 可用的技能

自动从 `skills/*/SKILL.md` 的 frontmatter 中提取：

```bash
for skill in skills/*/SKILL.md; do
  name=$(grep '^name:' "$skill" | sed 's/name: *//')
  desc=$(grep '^description:' "$skill" | sed 's/description: *//')
  echo "| $name | $desc |"
done
```

> 技能列表不应硬编码；每次执行时从当前 skills/ 目录动态生成。

## 安装模式

### 模式 1：本地安装（从 NixKits 源码）

当用户已位于 NixKits 源码目录内时：

```bash
# 自动发现源码目录
NIXKITS_DIR=$(pwd)
# 或从 flake.nix 推断：
[ -z "$NIXKITS_DIR" ] && NIXKITS_DIR=$(dirname "$(readlink -f flake.nix)" 2>/dev/null)

# 将技能复制到各已存在的助手目录
for dir in ~/.opencode/skills ~/.codewhale/skills ~/.codex/skills ~/.openclaw/skills ~/.agents/skills; do
  if [ -d "$dir" ]; then
    cp -r "$NIXKITS_DIR/skills/"* "$dir/"
    echo "Installed to $dir"
  fi
done
```

### 模式 2：在线安装（从 GitHub）

当本地没有 NixKits 源码时：

```bash
# 自动发现远程仓库 URL
REPO_URL=$(git remote get-url origin 2>/dev/null || echo "")
# 克隆到临时目录
TMPDIR=$(mktemp -d)
git clone ${REPO_URL:-https://github.com/Kihara777/NixKits.git} "$TMPDIR"

# 从克隆的源码安装
for dir in ~/.opencode/skills ~/.codewhale/skills ~/.codex/skills ~/.openclaw/skills ~/.agents/skills; do
  if [ -d "$dir" ]; then
    cp -r "$TMPDIR/skills/"* "$dir/"
    echo "Installed to $dir"
  fi
done

rm -rf "$TMPDIR"
```

## 检查更新

安装前，将本地技能与源码对比：

```bash
# 本地模式：与源码对比
NIXKITS_DIR=$(pwd)
for skill_dir in "$NIXKITS_DIR/skills/"*/; do
  skill_name=$(basename "$skill_dir")
  for agent_dir in ~/.opencode/skills ~/.codewhale/skills ~/.codex/skills ~/.openclaw/skills ~/.agents/skills; do
    if [ -d "$agent_dir/$skill_name" ]; then
      if ! diff -rq "$skill_dir" "$agent_dir/$skill_name" > /dev/null 2>&1; then
        echo "Update available: $skill_name in $(basename $(dirname $agent_dir))"
        echo "  Source: $skill_dir"
        echo "  Target: $agent_dir/$skill_name"
      fi
    fi
  done
done
```

## 工作流程

1. **检测助手目录** — 检查哪些技能目录存在
2. **检查已安装的 NixKits 技能** — 如已安装则对比版本差异
3. **询问用户** — 发现差异时确认是否应用更新
4. **选择模式** — 在 NixKits 源码内则本地模式，否则在线模式
5. **安装** — 将技能复制到各检测到的助手目录
6. **验证** — 确认安装成功

## 已移除 / 改名的技能

技能改名或下线时，**先 grep 再动**：下面六处有一处没跟上，CI 或会话就会看到旧名字。

| 位置 | 检查什么 |
|---|---|
| `README.md` + `docs/README.*.md` | 技能列表行（四语） |
| `docs/<lang>/skills/<name>.md` | 文档页（改名用 `git mv`，四语都要） |
| `develop/check-skill-registry.py` | 新名字必须被注入器认领，否则报「没有归属」 |
| `packages/dsh-nixos-shell/lib/maintenance-skills.js` | 维护模式的 `registerSkill("<name>")` |
| 其他技能里的引用 | `grep -rn "<旧名>" skills/`（适配层的「接口」表最容易漏） |
| 预设文件 | `presets/*/preset.patch.yml` 里的技能名 |

**两条纪律**：

1. **历史不追改**：`MAINTENANCE.*` 里的旧技能名是事实记录，批量替换时要排除它们
   （2026-10-20 实测：一次 `rglob` 替换把根 `MAINTENANCE.md` 也打中了，靠 `git checkout` 回退）。
2. **已安装副本不自动迁移**：本安装器装到其他助手目录的副本是**快照**，改名后旧目录还在。
   在安装目标里手动删掉旧目录，或重跑安装（写入新名，但不删旧名）。

## 风险警示

**Claude Code** 已于 2026-07 移除支持，原因如下：

> Claude Code 作为一家公司享有 KYC 以及选择服务用户和国家地区的权利，但在其软件内添加「基于用户数据挖掘对用户国籍进行判断的业务逻辑」这一行为，不论出于何种目的或说辞，都已严重跨越安全模型边界，打破了最基础的用户信任。
>
> 基于以上原因，本仓库强烈建议任何使用该软件的用户重新评估必要性并在可能的情况下考虑迁移工作流，本仓库充分理解用户需求的多样性与个人选择，但本仓库有义务告知用户这一风险，且由于使用本仓库内容导致您的 Anthropic 账户产生任何异常或损失时，您承认该事件与本仓库无关。
