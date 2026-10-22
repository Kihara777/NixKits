// maintenance-skills 的行为测试：失败必须抛，不能静默降级。
//
// 来历（2026-10-22，外部审计第 5 条）：apply 里原来三处 `catch {}` 与提前
// `return`，会让「技能目录里少了几个」表现为「维护模式正常启动、只是技能不在」。
// 这组用例把「读不到目录」与「目录缺 SKILL.md」两类坏输入都撞一遍，
// 再用一个正常树做对照（防止判据变成「一律抛错」）。

import assert from "node:assert/strict";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

import { apply } from "../lib/maintenance-skills.js";

function fakeCtx() {
  const registered = [];
  const sections = [];
  return {
    registered,
    sections,
    skills: { register: (skill) => registered.push(skill) },
    systemPrompt: { section: (section) => sections.push(section) },
  };
}

function writeSkill(root, id) {
  mkdirSync(join(root, id), { recursive: true });
  writeFileSync(
    join(root, id, "SKILL.md"),
    `---\nname: ${id}\ndescription: test skill ${id}\n---\n\nbody of ${id}\n`,
    "utf8",
  );
}

test("正常树：注册排除表之外的技能，不抛", () => {
  const root = mkdtempSync(join(tmpdir(), "mskills-ok-"));
  try {
    writeSkill(root, "alpha");
    writeSkill(root, "beta");
    writeSkill(root, "nixkits-skills"); // 在排除表里，不该注册

    const ctx = fakeCtx();
    apply(ctx, { root });

    assert.deepEqual(
      ctx.registered.map((skill) => skill.name).sort(),
      ["alpha", "beta"],
    );
    assert.equal(ctx.sections.length, 1, "成功时应注入维护提示词");
    assert.equal(ctx.registered[0].source, "runtime");
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});

test("坏输入：技能目录不存在 → 抛错，且不注入提示词", () => {
  const ctx = fakeCtx();
  assert.throws(
    () => apply(ctx, { root: join(tmpdir(), "mskills-does-not-exist-xyz") }),
    /技能目录不可读/,
  );
  assert.equal(ctx.registered.length, 0);
  assert.equal(ctx.sections.length, 0, "失败时不应再注入维护提示词");
});

test("坏输入：目录在但缺 SKILL.md → 抛错（不静默跳过这一项）", () => {
  const root = mkdtempSync(join(tmpdir(), "mskills-broken-"));
  try {
    writeSkill(root, "alpha");
    mkdirSync(join(root, "empty-dir"), { recursive: true });

    const ctx = fakeCtx();
    assert.throws(() => apply(ctx, { root }), /缺少 SKILL\.md/);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});
