// 自动兜底的判据（2026-11-09）。
//
// 缘起：她遇到两次「agent 觉得环境没有工具」，但**性质不同**——
//   · ffmpeg 那次是假阴性：`/run/current-system/sw/bin/ffmpeg` 好好躺着，是 agent
//     把「我没找到」写成了「不存在」（MIND 形态 E）；
//   · chromium 那次是真缺，而且闭包 1–2 GB。
// 所以兜底的第一件事不是「拉包」，是**分清这四档**：
//
//   no-index           没有构建期索引 → 什么都判不了（不许猜）
//   not-in-nixpkgs     系统没有、仓库也没有 → 命令打错
//   already-in-path    索引说系统里有 → 不是缺工具，是 PATH/调用方式
//   installable        仓库有、环境没有 → 可以拉（大包另要授权）
//
// 这一组用**假 ctx + 真子进程**：因为要验的正是「跑了之后怎么判」，而判定本身
// 是纯的。跑真 dsh 太重；喂假 stdout 又验不到「127 才兜底」这条边界。
//
// 跑法：`node --test tests/shell-bootstrap.test.mjs`
import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { mkdtempSync, writeFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";

import { apply } from "../lib/index.js";

/** 最小的 ctx：subprocess 是真的（要跑命令），其余按注册期的需要给。 */
function fakeCtx() {
  const tools = new Map();
  return {
    tools: { register: (tool) => tools.set(tool.name, tool) },
    subprocess: {
      spawn({ argv }) {
        const child = spawn(argv[0], argv.slice(1), { stdio: ["ignore", "pipe", "pipe"] });
        let out = "";
        let err = "";
        child.stdout.on("data", (d) => { out += d; });
        child.stderr.on("data", (d) => { err += d; });
        const done = new Promise((resolve) => child.on("close", (exitCode, signal) => resolve({ exitCode, signal })));
        const mk = (get) => ({ readFrom: () => ({ text: get(), lossy: false, spillPath: null }) });
        return {
          terminate: () => child.kill(),
          done,
          collected: { stdout: mk(() => out), stderr: mk(() => err) },
        };
      },
      resolveExecutable: async (n) => n,
    },
    // unref：生产里这个 timer 本来就活到进程结束，但测试里它会把 --test 挂住 120s。
    timer: { timeout: (ms) => new Promise((r) => { const t = setTimeout(r, ms); t.unref?.(); }) },
    systemPrompt: { section: () => {} },
    get: () => undefined,
    toolsMap: tools,
  };
}

function withIndex(data) {
  const dir = mkdtempSync(path.join(os.tmpdir(), "shell-index-"));
  const file = path.join(dir, "shell-index.json");
  if (data !== null) writeFileSync(file, JSON.stringify(data));
  const ctx = fakeCtx();
  // 路径走 config，不走进程级 env：`node --test` 默认并行，env 会互相踩。
  apply(ctx, { shellIndexPath: file });
  return ctx.toolsMap.get("nixos_shell");
}

const INDEX = {
  nixpkgs: { rev: "testrev", label: "test" },
  system: {
    ffmpeg: { package: "ffmpeg-8.1.3", path: "/run/current-system/sw/bin/ffmpeg" },
    // 故意造一个「索引说有、磁盘上没有」的名字：`already-in-path` 这一档
    // 说的正是这种情况——**不是缺工具，是没找到**。用真 ffmpeg 测不出来，
    // 因为这台机器上它真的在（2026-11-09 实测，这正是那次假阴性的本体）。
    "ghost-tool": { package: "ghost-1.0", path: "/nix/store/fake/bin/ghost-tool" },
  },
  nixpkgsAttributes: ["jq", "ripgrep", "chromium", "nodejs"],
};

test("没有索引文件 → no-index，且不改口说「命令不存在」", async () => {
  const tool = withIndex(null);
  const r = await tool.execute({ command: "definitely-not-a-command-zzz" }, {});
  assert.equal(r.exitCode, 127);
  assert.equal(r.bootstrap.kind, "no-index");
  assert.match(r.bootstrap.note, /shellIndex\.enable/);
});

test("系统里没有、nixpkgs 里也没有 → not-in-nixpkgs（命令打错）", async () => {
  const tool = withIndex(INDEX);
  const r = await tool.execute({ command: "definitely-not-a-command-zzz" }, {});
  assert.equal(r.bootstrap.kind, "not-in-nixpkgs");
  assert.equal(r.bootstrap.triggered, "definitely-not-a-command-zzz");
});

test("索引说系统里已经有 → already-in-path（不是缺工具）", async () => {
  // 用索引里登记过、磁盘上却不存在的名字——「有，但没用上」那种情形。
  const tool = withIndex(INDEX);
  const r = await tool.execute({ command: "ghost-tool" }, {});
  assert.equal(r.bootstrap.kind, "already-in-path");
  assert.ok(typeof r.bootstrap.path === "string");
});

test("退出码不是 127 就不兜底（差一个字母也不该触发下载）", async () => {
  const tool = withIndex(INDEX);
  const r = await tool.execute({ command: "false" }, {});
  assert.equal(r.exitCode, 1);
  assert.equal(r.bootstrap, undefined, "业务失败不该带 bootstrap 收据");
});

test("调用方已经给了 tools 就再兜一层——不兜", async () => {
  const tool = withIndex(INDEX);
  const r = await tool.execute({ command: "definitely-not-a-command-zzz", tools: ["jq"] }, {});
  assert.equal(r.bootstrap, undefined);
});

test("表外名字可以当 nixpkgs 属性用，但危险字符会被拒", async () => {
  const tool = withIndex(INDEX);
  // `pkg:x; rm -rf /` 这种必须被挡在拼字符串之前。
  await assert.rejects(
    () => tool.execute({ command: "true", tools: ["pkg:jq; rm -rf /"] }, {}),
    /invalid tool name/,
  );
});
