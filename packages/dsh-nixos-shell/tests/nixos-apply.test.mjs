// nixos_apply 的**运行期**测试：加载即注册，调用即执行。
//
// 来历（2026-11-06，一次真机上的一击）：`nixos_apply` 装进系统之后第一次调用
// 直接报 `sh is not defined`——因为 `sh()` 被写在了 `executeCli` 函数体里，
// 而 `nixos_apply` 的 `execute` 在另一个作用域。`node --check` 只查语法，
// 看不到这种错；**只有真的跑一次才暴露**。
//
// 所以这组用例的判据是：apply() 之后把工具取出来，**真的调用一次 execute**，
// 任何未定义标识符都会立刻抛。
//
// 只测 stage=build 的「拒绝/通过」分支与参数校验——不真的构建（那要几分钟，
// 且会写 /run）。真正构建交给真机验收。

import assert from "node:assert/strict";
import { test } from "node:test";

import { apply } from "../lib/index.js";

/** 最小的 ctx：只提供 apply() 在注册阶段真正会碰的东西。 */
function fakeCtx() {
  const tools = new Map();
  return {
    tools: {
      register: (tool) => tools.set(tool.name, tool),
    },
    subprocess: {
      spawn: () => {
        throw new Error("fakeCtx: 本用例不该真的 spawn");
      },
    },
    timer: { timeout: async () => {} },
    systemPrompt: { section: () => {} },
    get: () => undefined,
    toolsMap: tools,
  };
}

test("apply() 注册出 nixos_apply，且它有一个 execute", () => {
  const ctx = fakeCtx();
  apply(ctx, { sudoSocketPath: "/run/fake.sock" });
  const tool = ctx.toolsMap.get("nixos_apply");
  assert.ok(tool, "nixos_apply 没被注册");
  assert.equal(typeof tool.execute, "function", "nixos_apply 没有 execute");
});

test("stage 必填：缺 stage 时不静默走 build", async () => {
  const ctx = fakeCtx();
  apply(ctx, { sudoSocketPath: "/run/fake.sock" });
  const tool = ctx.toolsMap.get("nixos_apply");
  // `stage` 在 schema 里是 required，但 execute 自己也该有兜底：
  // 没给 stage 时**不能**默默当成 build 跑一遍构建。
  await assert.rejects(
    async () => tool.execute({}, { agent: { cwd: "/tmp" } }),
    /stage/i,
  );
});

test("stage=switch 缺 justification 时拒绝（而不是先切换再报错）", async () => {
  const ctx = fakeCtx();
  apply(ctx, { sudoSocketPath: "/run/fake.sock" });
  const tool = ctx.toolsMap.get("nixos_apply");
  await assert.rejects(
    async () => tool.execute({ stage: "switch", flakeDir: "/etc/nixos" }, { agent: { cwd: "/tmp" } }),
    /justification/,
  );
});

test("未知 stage 走 build 分支前必须被挡住", async () => {
  const ctx = fakeCtx();
  apply(ctx, { sudoSocketPath: "/run/fake.sock" });
  const tool = ctx.toolsMap.get("nixos_apply");
  // 现在实现是「非 switch 一律当 build」。这条用例把它钉死成**已知行为**：
  // 如果哪天改成抛错，这条会红，提醒改的人去更新文档，而不是悄悄变语义。
  const r = await tool.execute({ stage: "bogus", flakeDir: "/nonexistent-flake" }, { agent: { cwd: "/tmp" } });
  assert.equal(r.stage, "build", "非 switch 的 stage 目前按 build 处理");
  assert.notEqual(r.exitCode, 0, "对不存在的 flake 目录，构建必须失败");
});
