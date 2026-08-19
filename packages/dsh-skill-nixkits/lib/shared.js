/**
 * Shared skill-plugin factory for the NixKits skill plugins.
 *
 * Each skill is a native DSH skill plugin: it registers its own content
 * through `ctx.skills.register` (runtime provider, rank 250 — outranking the
 * filesystem roots), reading the canonical `skills/<id>/SKILL.md` that is
 * embedded into the package at build time.  The repository's `skills/`
 * directory stays the single source of truth; the plugin only wraps it.
 *
 * The SKILL.md frontmatter is stripped from the registered content (matching
 * dsh's SkillDefinition contract) and its fields are preserved as metadata,
 * keeping the NixKits documentation pipeline's auto-discovery contract
 * (language_code / display_name / base_language) intact for programmatic
 * consumers.
 *
 * @module @kihara777/dsh-skill-nixkits/shared
 */
import { readFileSync } from "node:fs";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";

/**
 * Parse a skill markdown document: split the YAML frontmatter block from the
 * body and collect scalar metadata fields.
 */
export function parseSkillDocument(raw) {
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

/**
 * Build the Cordis plugin object for one skill.
 *
 * @param {string} skillId - directory name under the embedded skills/ dir.
 */
export function skillPlugin(skillId) {
  const url = new URL(`../skills/${skillId}/SKILL.md`, import.meta.url);
  const file = fileURLToPath(url);
  const { metadata, content } = parseSkillDocument(readFileSync(file, "utf8"));
  const skillName = String(metadata.name ?? "");
  const description = String(metadata.description ?? "");
  return {
    name: `skill-nixkits-${skillId}`,
    inject: ["skills"],
    apply(ctx) {
      return ctx.skills.register({
        name: skillName,
        description,
        content,
        source: "runtime",
        metadata,
        resourceBase: { kind: "directory", path: dirname(file) },
      });
    },
  };
}

export const SKILL_IDS = [
  "nixkits-check-updates",
  "nixkits-skills",
  "nixos-modern-cli",
  "recover-nixos-config",
  "translate-pseudocn",
  "write-maintenance-log",
  "write-project-docs",
];
