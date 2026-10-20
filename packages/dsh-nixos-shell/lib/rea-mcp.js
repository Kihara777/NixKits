/**
 * rea-mcp —— 把 REA（Reverse Engineer Anything）的 MCP 服务接进**选了逆向模式的那个会话**。
 *
 * ── 为什么不是一条 `@deepseek-ai/dsh-mcp-client` 行 ────────────────────────
 * 试过。2026-10-20 在真实部署里量到的结果是：`mcp-rea` 行放在预设里，预设被
 * **eager activation**（dsh 启动 4 秒后就 spawn 了 `rea mcp`），而工具注册落到
 * root scope —— 于是**掌灯模式的会话**也背上 207 个 `mcp__rea__*`（请求头里
 * 31 + 207 = 238 个工具）。预设的语义是「只有这个模式才有」，那不是它。
 *
 * 所以这里自己开一条 stdio JSON-RPC，并且**只在 `agent/session-start` 时才连**：
 * 那个事件是 scope-filtered 到本预设的 agent，连接和注册都绑在 `agent.ctx` 上，
 * 会话结束就断开。没有 agent 就没有进程、没有工具。
 *
 * ── 工具为什么是全量的 ────────────────────────────────────────────────────
 * 上游 `dsh-mcp-client` 导出的 `createMcpToolDefinition` 正好做这件事：它把 MCP 的
 * `inputSchema`（标准 JSON Schema）**原样**交给工具注册表，参数校验由 REA 自己做。
 * 于是不需要「JSON Schema → dsh 简写 spec」的转换器 —— 那个转换器一旦写歪，
 * 会**静默拒掉合法调用**，而且是 207 个工具里最难发现的一类错。
 *
 * 代价：会话刚开始那几秒 REA 还在启动，工具表里暂时没有它们；连上之后才出现。
 */
import { spawn } from "node:child_process";

import { createMcpToolDefinition } from "@deepseek-ai/dsh-mcp-client";

/** Cordis 插件名（loader 诊断用）。 */
export const name = "rea-mcp";

/** 需要的服务：工具注册表。 */
export const inject = ["tools"];

/** 单次 JSON-RPC 请求的超时（毫秒）。 */
const REQUEST_TIMEOUT_MS = 120_000;

/**
 * 一条 stdio JSON-RPC 连接（MCP 的换行分隔传输）。
 * @param command REA 可执行文件
 * @param args 参数（默认 `mcp`）
 */
function connect(command, args) {
  const child = spawn(command, args, { stdio: ["pipe", "pipe", "pipe"] });
  const pending = new Map();
  let nextId = 0;
  let buffer = "";
  let closed = null;

  const rejectAll = (error) => {
    for (const [, entry] of pending) entry.reject(error);
    pending.clear();
  };

  child.on("error", (error) => {
    closed = error;
    rejectAll(error);
  });
  child.on("exit", (code, signal) => {
    closed = new Error(`REA MCP server exited (${code ?? signal})`);
    rejectAll(closed);
  });
  // stderr 不能堵：REA 往那里写进度，管道满了它会卡住。
  child.stderr.resume();

  child.stdout.setEncoding("utf8");
  child.stdout.on("data", (chunk) => {
    buffer += chunk;
    let newline;
    while ((newline = buffer.indexOf("\n")) >= 0) {
      const line = buffer.slice(0, newline);
      buffer = buffer.slice(newline + 1);
      if (line.trim().length === 0) continue;
      let message;
      try {
        message = JSON.parse(line);
      } catch {
        continue;
      }
      if (message.id !== undefined && pending.has(message.id)) {
        const entry = pending.get(message.id);
        pending.delete(message.id);
        if (message.error !== undefined) entry.reject(new Error(message.error.message ?? "MCP error"));
        else entry.resolve(message.result);
        continue;
      }
      // 服务端主动请求（sampling / roots / elicitation）：不支持就显式回空，
      // 不让 REA 等到超时。
      if (message.method !== undefined && message.id !== undefined) {
        child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id: message.id, result: {} })}\n`);
      }
    }
  });

  const request = (method, params) =>
    new Promise((resolve, reject) => {
      if (closed !== null) {
        reject(closed);
        return;
      }
      const id = ++nextId;
      const timer = setTimeout(() => {
        pending.delete(id);
        reject(new Error(`MCP ${method} timed out after ${REQUEST_TIMEOUT_MS} ms`));
      }, REQUEST_TIMEOUT_MS);
      pending.set(id, {
        resolve: (value) => {
          clearTimeout(timer);
          resolve(value);
        },
        reject: (error) => {
          clearTimeout(timer);
          reject(error);
        },
      });
      child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
    });

  return {
    request,
    notify: (method, params) => child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method, params })}\n`),
    close: () => {
      try {
        child.stdin.end();
      } catch {
        /* 已经关了 */
      }
      try {
        child.kill();
      } catch {
        /* 已经退出 */
      }
    },
  };
}

/**
 * 为一个 agent 起一条连接，并把 REA 的全部工具注册到它的 scope 上。
 * @param agent 已经 live 的 agent（`agent/session-start` 的载荷）
 * @param config 插件配置：`command` / `args`
 */
async function attach(agent, config) {
  const command = config.command ?? process.env.REA_BIN_PATH ?? "rea";
  const args = config.args ?? ["mcp"];
  const connection = connect(command, args);

  // 无论成败，agent 结束时都要断开 —— 泄漏一个 275 MB 的进程比报错更难查。
  agent.ctx.effect(() => () => connection.close(), "rea-mcp.connection");

  try {
    await connection.request("initialize", {
      protocolVersion: "2025-06-18",
      capabilities: {},
      clientInfo: { name: "dsh-rea-mcp", version: "0" },
    });
    connection.notify("notifications/initialized", {});
    const listed = await connection.request("tools/list", {});
    const tools = listed?.tools ?? [];
    if (tools.length === 0) throw new Error("REA MCP server reported no tools");

    for (const tool of tools) {
      // 注册到 **agent.ctx**：只有这个会话可见。这是与「预设里挂一行 mcp-client」
      // 的全部区别 —— 那一版把工具注册到了 root scope。
      agent.ctx.tools.register(
        createMcpToolDefinition(agent.ctx, {
          name: `mcp__rea__${tool.name}`,
          rawName: tool.name,
          description: tool.description ?? tool.name,
          inputSchema: tool.inputSchema ?? { type: "object", properties: {} },
          outputSchema: tool.outputSchema,
          call: (argv) => connection.request("tools/call", { name: tool.name, arguments: argv ?? {} }),
        }),
      );
    }
    process.stderr.write(`rea-mcp: attached ${tools.length} tools to this session\n`);
  } catch (error) {
    // 显式说出来：预设里少一组工具是**可诊断的降级**，不是静默的空表。
    process.stderr.write(`rea-mcp: attach failed: ${error?.message ?? String(error)}\n`);
    connection.close();
  }
}

/**
 * 每个选了本预设的会话拿一条自己的连接。
 * @param ctx 插件上下文
 * @param config 插件配置
 */
export function apply(ctx, config = {}) {
  // 刻意**不在 apply 里连接**：apply 发生在预设被 eager activation 的时候，
  // 那时没有 agent，工具只会落到 root scope（2026-10-20 实测：掌灯模式会话
  // 也拿到了 207 个 mcp__rea__*）。
  ctx.on("agent/session-start", ({ agent }) => {
    void attach(agent, config);
  });
}
