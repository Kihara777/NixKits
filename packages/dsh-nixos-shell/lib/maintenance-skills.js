/**
 * maintenance-skills — repo-maintenance skill injection for the 维护模式
 * agent preset.
 *
 * Mounted only by the `维护模式` preset.  At apply time it registers the
 * NixKits documentation/maintenance skills as runtime skills, embedded at
 * build time from the repository's canonical `skills/` tree (single source
 * of truth, so a fresh session always gets the LATEST skill content):
 *
 * - `write-project-docs` (multi-language documentation authoring);
 * - `write-maintenance-log` (MAINTENANCE.md authoring per NixKits rules);
 * - `nixkits-check-updates` (upstream version bump + docs sync for all
 *   repository packages, so a maintenance session can run it directly);
 * - every `translate-*` language-extension skill (auto-discovered at apply
 *   time from the embedded tree, so new language extensions are picked up
 *   without code changes).
 *
 * It also installs a prompt section with the NixKits repository maintenance
 * workflow (commit batching, push-then-maintenance-log, doc sync, four
 * language versions) so the agent maintains the repo efficiently out of the
 * box.
 *
 * Consumes only the host `skills`/`systemPrompt` capability seams and
 * provides no services, so it needs no realm.
 *
 * @module @kihara777/dsh-nixos-shell/maintenance-skills
 */
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { fileURLToPath } from "node:url";

export const name = "maintenance-skills";

export const inject = ["skills", "systemPrompt"];

/** Parse a skill markdown document: frontmatter metadata + body. */
function parseSkillDocument(raw) {
  const match = /^---\r?\n([\s\S]*?)\r?\n---\r?\n/.exec(raw);
  let content = raw;
  const metadata = {};
  if (match !== null) {
    content = raw.slice(match[0].length).replace(/^[ \t]*\r?\n/, "");
    for (const line of match[1].split(/\r?\n/)) {
      const field = /^([A-Za-z_][A-Za-z0-9_-]*):[ \t]*(.*)$/.exec(line);
      if (field !== null) metadata[field[1]] = field[2].trim();
    }
  }
  return { metadata, content };
}

const MAINTENANCE_WORKFLOW = `## 维护模式 — NixKits 仓库维护工作流

本会话以「维护模式」运行，用于在全新会话中开箱即用地维护与开发仓库内容。遵循仓库 AGENTS.md 的工作流约定：

- **分批提交**：修改核验无误后按逻辑类别分批 commit，每批后立即 push。
- **推送后必须记录维护日志**：获取新 commit SHA（git log --format='%h' origin/main..HEAD），按 write-maintenance-log 技能补录条目并同步全部已注册语言（zh 基准 + en/ja + translate-* 自动发现的扩展语言），验证各语言条目数一致（grep -c '^## 20'）。
- **文档同步**：软件包/技能修改后同步对应文档；新增内容 docs/zh/ 先写，再翻译到其他语言。
- **泛化**：修复后总结业务逻辑，评估可泛化内容并更新到对应技能。
- 技能内容来自本预设注入的运行时技能（write-project-docs / write-maintenance-log / translate-*），调用 skill 工具加载；仓库 skills/ 是内容单一来源。`;

export function apply(ctx) {
  // Embedded canonical tree: <package>/skills-embedded/<skillId>/SKILL.md.
  const root = fileURLToPath(new URL("../skills-embedded/", import.meta.url));

  const registerSkill = (skillId) => {
    const file = `${root}/${skillId}/SKILL.md`;
    if (!existsSync(file)) return;
    const { metadata, content } = parseSkillDocument(readFileSync(file, "utf8"));
    const skillName = String(metadata.name ?? "");
    const description = String(metadata.description ?? "");
    ctx.skills.register({
      name: skillName,
      description,
      content,
      source: "runtime",
      metadata,
      resourceBase: { kind: "directory", path: `${root}/${skillId}` },
    });
  };

  // Fixed maintenance/doc skills.
  registerSkill("write-project-docs");
  registerSkill("write-maintenance-log");
  registerSkill("nixkits-check-updates");

  // Language-extension skills, auto-discovered (translate-*).
  let entries = [];
  try {
    entries = readdirSync(root);
  } catch {
    entries = [];
  }
  for (const entry of entries) {
    if (!/^translate-/.test(entry)) continue;
    try {
      if (statSync(`${root}/${entry}`).isDirectory()) registerSkill(entry);
    } catch {
      // skip unreadable entries
    }
  }

  ctx.systemPrompt.section({
    name: "maintenance-mode-workflow",
    text: MAINTENANCE_WORKFLOW,
    order: 901,
  });
}
