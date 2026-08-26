/**
 * api-balance — API 用量余额插件 for the DeepSeek Harness.
 *
 * 在 webui 原有的用量显示（composer dock 统计行）旁添加「用量 / 开销」标签切换：
 * 「用量」保留原有 token 统计；切换为「开销」后展示当前 API KEY 的账户信息——
 * 账户可用状态、各币种余额（总余额 / 充值余额 / 赠送余额），数据来自 DeepSeek
 * 官方 GET /user/balance 接口。
 *
 * Host 端职责（本文件）：
 *  1. 通过 `connection.rpc.intercept("/api", …)` 注册包私有 endpoint
 *     `api-balance/query`（authority: trusted-host，与 dsh-api-gateway 的
 *     typert 通道同策略），浏览器端 client 经同一 RPC 传输调用，无需新增
 *     公开 Remote Service。
 *  2. 解析 DeepSeek API key：优先 `credentials` 服务按 `apiKeyEnv`
 *     （默认 DEEPSEEK_API_KEY，与 dsh-llm-deepseek 同一 credential-ref
 *     语义）解析，回退进程环境变量。
 *  3. 调用 `GET {baseURL}/user/balance`（Bearer 认证），把响应规整为
 *     client 需要的 JSON，并做短 TTL 缓存避免每次切换标签都打一次上游。
 *
 * 该 endpoint 属于 plugin fiber：插件停止/更新后 intercept 自动移除。
 *
 * @module @kihara777/dsh-api-balance
 */
import { credentialRef } from "@deepseek-ai/dsh-credentials";

export const name = "api-balance";

export const inject = ["connection"];

/** 与 dsh-llm-deepseek 相同的默认环境变量名（credential-ref）。 */
const DEFAULT_API_KEY_ENV = "DEEPSEEK_API_KEY";
/** DeepSeek 官方 API 根地址。 */
const DEFAULT_BASE_URL = "https://api.deepseek.com";
/** 余额查询接口路径（官方 Get User Balance）。 */
const BALANCE_PATH = "/user/balance";
/** 余额响应短缓存：30 秒内重复查询不重打上游。 */
const BALANCE_CACHE_TTL_MS = 30_000;
/** 上游请求超时。 */
const BALANCE_FETCH_TIMEOUT_MS = 10_000;

/** 归一化后的余额视图（client 渲染所需的全部字段，均为基础 JSON 标量）。 */
function projectBalance(data, apiKey) {
  const rawInfos = Array.isArray(data?.balance_infos) ? data.balance_infos : [];
  return {
    isAvailable: data?.is_available === true,
    // 当前 API KEY 的标识尾号（用于界面确认是哪把 key，绝不回传完整密钥）。
    keyHint: typeof apiKey === "string" && apiKey.length > 4 ? `***${apiKey.slice(-4)}` : null,
    balanceInfos: rawInfos.map((info) => ({
      currency: info?.currency ?? "CNY",
      totalBalance: info?.total_balance ?? null,
      grantedBalance: info?.granted_balance ?? null,
      toppedUpBalance: info?.topped_up_balance ?? null,
    })),
  };
}

/** 解析 DeepSeek API key：credentials 服务优先，环境变量回退。 */
async function resolveApiKey(ctx, apiKeyEnv) {
  const credentials = ctx.get("credentials");
  if (credentials !== undefined) {
    try {
      const hit = await credentials.resolve(credentialRef(apiKeyEnv));
      if (hit !== undefined && hit.value.length > 0) return hit.value;
    } catch {
      // 解析失败视为未配置，走环境变量回退
    }
  }
  const ambient = process.env[apiKeyEnv];
  return typeof ambient === "string" && ambient.length > 0 ? ambient : null;
}

export function apply(ctx, config = {}) {
  const apiKeyEnv = config.apiKeyEnv ?? DEFAULT_API_KEY_ENV;
  const baseURL = (config.baseURL ?? DEFAULT_BASE_URL).replace(/\/+$/u, "");

  let cache = null;
  let cacheAt = 0;

  ctx.effect(() => {
    const dispose = ctx.connection.rpc.intercept(
      "/api",
      (endpoint) => endpoint === "api-balance/query",
      async (_endpoint, _payload, signal) => {
        const now = Date.now();
        if (cache !== null && now - cacheAt < BALANCE_CACHE_TTL_MS) {
          return { ok: true, value: cache };
        }
        const apiKey = await resolveApiKey(ctx, apiKeyEnv);
        if (apiKey === null) {
          return {
            ok: false,
            error: {
              code: "internal",
              message: `api-balance: API key 未配置（credential-ref ${apiKeyEnv}）`,
              details: {},
            },
          };
        }
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), BALANCE_FETCH_TIMEOUT_MS);
        try {
          const response = await fetch(`${baseURL}${BALANCE_PATH}`, {
            method: "GET",
            headers: {
              authorization: `Bearer ${apiKey}`,
              accept: "application/json",
            },
            signal: signal ?? controller.signal,
          });
          if (!response.ok) {
            const body = await response.text().catch(() => "");
            return {
              ok: false,
              error: {
                code: "internal",
                message: `api-balance: DeepSeek /user/balance 返回 ${response.status}${body ? `: ${body.slice(0, 200)}` : ""}`,
                details: {},
              },
            };
          }
          const data = await response.json();
          const value = projectBalance(data, apiKey);
          cache = value;
          cacheAt = Date.now();
          return { ok: true, value };
        } catch (error) {
          const aborted = error?.name === "AbortError";
          return {
            ok: false,
            error: {
              code: "internal",
              message: aborted
                ? "api-balance: 查询 DeepSeek 余额超时"
                : `api-balance: 查询失败 — ${error instanceof Error ? error.message : String(error)}`,
              details: {},
            },
          };
        } finally {
          clearTimeout(timeout);
        }
      },
      { authority: "trusted-host" },
    );
    return () => {
      dispose().catch(() => {});
    };
  }, "api-balance: rpc endpoint");
}
