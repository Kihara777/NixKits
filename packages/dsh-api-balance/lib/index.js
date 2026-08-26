/**
 * api-balance — API 用量余额插件 for the DeepSeek Harness.
 *
 * 在 webui 用量圆圈（发送按钮左侧的上下文已用显示）弹出面板中提供
 * 「用量 / 余额」标签切换。数据全部来自官方接口：
 *  - 余额：GET api.deepseek.com/user/balance（API key 认证）
 *  - 用量：GET platform.deepseek.com/api/v0/usage/by_api_key/{amount,cost}
 *    （平台会话令牌认证）→ 当日 / 当月 / 30 日内消耗（金额 + token +
 *    分模型明细）
 *
 * 令牌获取（一键授权，非手动抄录）：client 端「连接平台」按钮打开
 * platform.deepseek.com/usage 并把一条回传命令写入剪贴板；用户在平台页
 * 控制台粘贴回车，命令读取 localStorage 的 userToken 并 POST 到本插件的
 * `/api/api-balance/token` 端点（CORS 仅放行 platform.deepseek.com origin，
 * 令牌只落盘 $DSH_HOME/api-balance-token，绝不回显、绝不入日志）。此后
 * 插件自动读取令牌调用官方接口，无需再次打扰用户。
 *
 * 币种：两个官方接口的响应均自带 currency 字段，host 只做 JSON 归一化与
 * 短 TTL 缓存，client 按币种分组渲染——识别/区分币种由数据天然完成。
 *
 * @module @kihara777/dsh-api-balance
 */
import { credentialRef } from "@deepseek-ai/dsh-credentials";
import { readFileSync, writeFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

export const name = "api-balance";

export const inject = ["connection", "webServer"];

/** 与 dsh-llm-deepseek 相同的默认环境变量名（credential-ref）。 */
const DEFAULT_API_KEY_ENV = "DEEPSEEK_API_KEY";
/** DeepSeek 官方 API 根地址。 */
const DEFAULT_BASE_URL = "https://api.deepseek.com";
/** 平台控制台根地址（用量接口宿主，有 WAF）。 */
const PLATFORM_BASE_URL = "https://platform.deepseek.com";
/** 平台授权页（用户粘贴回传命令的页面）。 */
const PLATFORM_USAGE_URL = `${PLATFORM_BASE_URL}/usage`;
/** 余额查询接口路径（官方 Get User Balance）。 */
const BALANCE_PATH = "/user/balance";
/** 平台按 API key 的用量接口（token 与金额）。 */
const USAGE_AMOUNT_PATH = "/api/v0/usage/by_api_key/amount";
const USAGE_COST_PATH = "/api/v0/usage/by_api_key/cost";
/** 令牌回传端点（client 授权流程的落点）。 */
const TOKEN_ROUTE = "/api/api-balance/token";
const TOKEN_CLEAR_ROUTE = "/api/api-balance/token/clear";
/** 响应短缓存：30 秒内重复查询不重打上游。 */
const CACHE_TTL_MS = 30_000;
/** 上游请求超时。 */
const FETCH_TIMEOUT_MS = 10_000;
/** 用量窗口：查询最近 30 天，再切分为当日 / 当月 / 30 日内。 */
const USAGE_WINDOW_DAYS = 30;
/** 平台接口单窗口上限：31 天（32 天起返回 INVALID_PARAM）。 */
const MAX_WINDOW_DAYS = 31;
/** 按日图表的柱数（最近 N 天，与主窗口一致）。 */
const DAILY_SERIES_DAYS = 30;
/** 按月图表的柱数（最近 N 个月；历史月份逐月单独请求）。 */
const MONTHLY_SERIES_MONTHS = 6;

/** 平台接口 WAF 需要的浏览器头（与网页控制台请求一致）。 */
const PLATFORM_HEADERS = {
  "user-agent":
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
  accept: "application/json, text/plain, */*",
  "accept-language": "zh-CN,zh;q=0.9,en;q=0.8",
  origin: PLATFORM_BASE_URL,
  referer: PLATFORM_USAGE_URL,
};

/** 令牌落盘路径：$DSH_HOME/api-balance-token（0600，仅本机服务用户可读）。 */
function tokenFilePath() {
  const home = process.env.DSH_HOME ?? join(homedir(), ".dsh");
  return join(home, "api-balance-token");
}

function readTokenFile() {
  try {
    const value = readFileSync(tokenFilePath(), "utf8").trim();
    return value.length > 0 ? value : null;
  } catch {
    return null;
  }
}

function writeTokenFile(token) {
  if (typeof token !== "string" || token.trim().length === 0) return false;
  writeFileSync(tokenFilePath(), token.trim(), { mode: 0o600 });
  return true;
}

function clearTokenFile() {
  rmSync(tokenFilePath(), { force: true });
}

/** 数值归一化：非法值记 0。 */
function num(value) {
  if (value === null || value === void 0) return 0;
  if (typeof value === "number") return Number.isFinite(value) ? value : 0;
  const n = parseFloat(String(value));
  return Number.isFinite(n) ? n : 0;
}

/** 本地时区的日期键（YYYY-MM-DD）。 */
function localDateKey(ms) {
  const d = new Date(ms);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

/** 当月前缀（YYYY-MM）。 */
function localMonthKey(ms) {
  const d = new Date(ms);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
}

/** 用量窗口参数：最近 days 天（本地时区日界），start/end 为 unix 秒，tz 为本地时区偏移秒。
 * 平台接口按整日边界取数：end 必须是次日 00:00（传当前时刻返回 INVALID_PARAM）。 */
function usageWindowParams(days, now = new Date()) {
  const tzSec = -now.getTimezoneOffset() * 60;
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  start.setDate(start.getDate() - (days - 1));
  const end = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  end.setDate(end.getDate() + 1);
  return { start: Math.floor(start.getTime() / 1000), end: Math.floor(end.getTime() / 1000), tz: tzSec };
}

/** 时间桶 unix 秒（加时区偏移）→ 本地日期键；非数字输入原样返回（形状 B 直接给日期串）。 */
function bucketDateKey(timeSec, tzSec) {
  if (typeof timeSec !== "number" || !Number.isFinite(timeSec)) return "";
  return localDateKey((timeSec + tzSec) * 1000);
}

/** 一个用量桶累加进按日表（token 侧）。 */
function addAmountBucket(days, dateKey, model, usage) {
  if (typeof dateKey !== "string" || dateKey.length === 0) return;
  let day = days.get(dateKey);
  if (day === void 0) days.set(dateKey, (day = { hit: 0, miss: 0, completion: 0, models: new Map() }));
  const hit = num(usage?.PROMPT_CACHE_HIT_TOKEN);
  const miss = num(usage?.PROMPT_CACHE_MISS_TOKEN) + num(usage?.PROMPT_TOKEN);
  const completion = num(usage?.COMPLETION_TOKEN) + num(usage?.RESPONSE_TOKEN);
  day.hit += hit;
  day.miss += miss;
  day.completion += completion;
  let row = day.models.get(model);
  if (row === void 0) day.models.set(model, (row = { hit: 0, miss: 0, completion: 0, cost: 0 }));
  row.hit += hit;
  row.miss += miss;
  row.completion += completion;
}

/** 一个金额桶累加进按日表（cost 侧）。 */
function addCostBucket(days, dateKey, currency, model, cost) {
  if (typeof dateKey !== "string" || dateKey.length === 0) return;
  let day = days.get(dateKey);
  if (day === void 0) days.set(dateKey, (day = { byCurrency: new Map(), models: new Map() }));
  day.byCurrency.set(currency, (day.byCurrency.get(currency) ?? 0) + cost);
  day.models.set(model, (day.models.get(model) ?? 0) + cost);
}

/**
 * 解析 amount 响应 → Map<dateKey, 按日 token 表>。
 * 形状 A（by_api_key/amount）：biz_data.series[].buckets[].{time, usage{}}，
 * series 可能带 model 字段；形状 B（备用）：biz_data[].days[].data[].{model, usage:[{type,amount}]}。
 */
function parsePlatformAmount(json, tzSec) {
  const days = new Map();
  const biz = json?.data?.biz_data;
  if (biz !== null && typeof biz === "object" && Array.isArray(biz.series)) {
    for (const series of biz.series) {
      const model = typeof series?.model === "string" ? series.model : "";
      for (const bucket of Array.isArray(series?.buckets) ? series.buckets : []) {
        addAmountBucket(days, bucketDateKey(bucket?.time, tzSec), model, bucket?.usage ?? {});
      }
    }
  } else {
    const root = Array.isArray(biz) ? biz[0] : biz;
    for (const day of Array.isArray(root?.days) ? root.days : []) {
      for (const entry of Array.isArray(day?.data) ? day.data : []) {
        const usage = {};
        for (const item of Array.isArray(entry?.usage) ? entry.usage : []) usage[item?.type] = item?.amount;
        addAmountBucket(days, day?.date, entry?.model ?? "", usage);
      }
    }
  }
  return days;
}

/**
 * 解析 cost 响应 → Map<dateKey, 按日金额表>。
 * 形状 A（by_api_key/cost）：biz_data.data[].{currency, series[].buckets[].{time, cost}}；
 * 形状 B（备用）：biz_data[].days[].data[].{model, usage:[{type,amount}]}（非 TOKEN 类型记为金额）。
 */
function parsePlatformCost(json, tzSec) {
  const days = new Map();
  const biz = json?.data?.biz_data;
  if (biz !== null && typeof biz === "object" && Array.isArray(biz.data)) {
    for (const row of biz.data) {
      const currency = typeof row?.currency === "string" ? row.currency : "";
      for (const series of Array.isArray(row?.series) ? row.series : []) {
        const model = typeof series?.model === "string" ? series.model : "";
        for (const bucket of Array.isArray(series?.buckets) ? series.buckets : []) {
          addCostBucket(days, bucketDateKey(bucket?.time, tzSec), currency, model, num(bucket?.cost));
        }
      }
    }
  } else {
    const root = Array.isArray(biz) ? biz[0] : biz;
    for (const day of Array.isArray(root?.days) ? root.days : []) {
      for (const entry of Array.isArray(day?.data) ? day.data : []) {
        for (const item of Array.isArray(entry?.usage) ? entry.usage : []) {
          if (String(item?.type ?? "").includes("TOKEN")) continue;
          addCostBucket(days, day?.date, "", entry?.model ?? "", num(item?.amount));
        }
      }
    }
  }
  return days;
}

/** 按日数据切分为 当日 / 当月 / 30日内 三个窗口（模型明细随窗口累计）。 */
function foldUsageWindows(amountDays, costDays, now = new Date()) {
  const todayKey = localDateKey(now.getTime());
  const monthKey = localMonthKey(now.getTime());
  const makeWindow = () => ({ costByCurrency: new Map(), hit: 0, miss: 0, completion: 0, models: new Map() });
  const windows = { today: makeWindow(), month: makeWindow(), last30d: makeWindow() };
  const pick = (dateKey) =>
    dateKey === todayKey ? windows.today : dateKey.startsWith(monthKey) ? windows.month : null;

  for (const [dateKey, day] of amountDays) {
    for (const window of [windows.last30d, pick(dateKey)]) {
      if (window === null) continue;
      window.hit += day.hit;
      window.miss += day.miss;
      window.completion += day.completion;
      for (const [model, row] of day.models) {
        let entry = window.models.get(model);
        if (entry === void 0) window.models.set(model, (entry = { hit: 0, miss: 0, completion: 0, cost: 0 }));
        entry.hit += row.hit;
        entry.miss += row.miss;
        entry.completion += row.completion;
      }
    }
  }
  for (const [dateKey, day] of costDays) {
    for (const window of [windows.last30d, pick(dateKey)]) {
      if (window === null) continue;
      for (const [currency, cost] of day.byCurrency) {
        window.costByCurrency.set(currency, (window.costByCurrency.get(currency) ?? 0) + cost);
      }
      for (const [model, cost] of day.models) {
        let entry = window.models.get(model);
        if (entry === void 0) window.models.set(model, (entry = { hit: 0, miss: 0, completion: 0, cost: 0 }));
        entry.cost += cost;
      }
    }
  }
  const project = (window) => ({
    costByCurrency: Object.fromEntries(
      [...window.costByCurrency.entries()].map(([currency, cost]) => [currency, Math.round(cost * 1e6) / 1e6]),
    ),
    hit: window.hit,
    miss: window.miss,
    completion: window.completion,
    models: [...window.models.entries()]
      .map(([model, row]) => ({
        model,
        hit: row.hit,
        miss: row.miss,
        completion: row.completion,
        cost: Math.round(row.cost * 1e6) / 1e6,
      }))
      .sort((a, b) => b.hit + b.miss + b.completion - (a.hit + a.miss + a.completion)),
  });
  return { today: project(windows.today), month: project(windows.month), last30d: project(windows.last30d) };
}

/** 只保留最近 N 天内的按日数据（日期键为 ISO 字符串，字典序即时间序）。 */
function recentDays(days, keepDays, now = new Date()) {
  const cutoff = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  cutoff.setDate(cutoff.getDate() - (keepDays - 1));
  const cutoffKey = localDateKey(cutoff.getTime());
  return new Map([...days.entries()].filter(([key]) => key >= cutoffKey));
}

/** 数值取整到 1e-6（JSON 传输去浮点尾巴）。 */
function round6(value) {
  return Math.round(value * 1e6) / 1e6;
}

/**
 * 折叠按日序列：最近 DAILY_SERIES_DAYS 天逐日（缺日补零），按模型金额堆叠。
 * 金额逐币种透传（costByCurrency），模型段只保留有花费的条目。
 */
function foldDailySeries(amountDays, costDays, now = new Date()) {
  const daily = [];
  for (let i = DAILY_SERIES_DAYS - 1; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    d.setDate(d.getDate() - i);
    const key = localDateKey(d.getTime());
    const amount = amountDays.get(key);
    const cost = costDays.get(key);
    daily.push({
      date: key,
      hit: amount?.hit ?? 0,
      miss: amount?.miss ?? 0,
      completion: amount?.completion ?? 0,
      costByCurrency: Object.fromEntries(
        [...(cost?.byCurrency ?? new Map()).entries()].map(([currency, value]) => [currency, round6(value)]),
      ),
      models: [...(cost?.models ?? new Map()).entries()]
        .filter(([, value]) => value > 0)
        .map(([model, value]) => ({ model, cost: round6(value) }))
        .sort((a, b) => b.cost - a.cost),
    });
  }
  return daily;
}

/** 单月聚合点：把一个月内的按日数据合并为一个序列点。 */
function foldMonthlyPoint(amountDays, costDays, monthKey) {
  let hit = 0;
  let miss = 0;
  let completion = 0;
  const byCurrency = new Map();
  const models = new Map();
  for (const [dateKey, day] of amountDays) {
    if (!dateKey.startsWith(monthKey)) continue;
    hit += day.hit;
    miss += day.miss;
    completion += day.completion;
  }
  for (const [dateKey, day] of costDays) {
    if (!dateKey.startsWith(monthKey)) continue;
    for (const [currency, value] of day.byCurrency) {
      byCurrency.set(currency, (byCurrency.get(currency) ?? 0) + value);
    }
    for (const [model, value] of day.models) {
      models.set(model, (models.get(model) ?? 0) + value);
    }
  }
  return {
    month: monthKey,
    hit,
    miss,
    completion,
    costByCurrency: Object.fromEntries([...byCurrency.entries()].map(([currency, value]) => [currency, round6(value)])),
    models: [...models.entries()]
      .filter(([, value]) => value > 0)
      .map(([model, value]) => ({ model, cost: round6(value) }))
      .sort((a, b) => b.cost - a.cost),
  };
}

/** 归一化余额视图（balance_infos 逐币种透传，不做币种假设）。 */
function projectBalance(data, apiKey) {
  const rawInfos = Array.isArray(data?.balance_infos) ? data.balance_infos : [];
  return {
    isAvailable: data?.is_available === true,
    keyHint: typeof apiKey === "string" && apiKey.length > 4 ? `***${apiKey.slice(-4)}` : null,
    balanceInfos: rawInfos.map((info) => ({
      currency: info?.currency ?? "",
      totalBalance: info?.total_balance ?? null,
      grantedBalance: info?.granted_balance ?? null,
      toppedUpBalance: info?.topped_up_balance ?? null,
    })),
  };
}

/** 解析 credential-ref：credentials 服务优先，进程环境变量回退。 */
async function resolveSecret(ctx, envName) {
  const credentials = ctx.get("credentials");
  if (credentials !== void 0) {
    try {
      const hit = await credentials.resolve(credentialRef(envName));
      if (hit !== void 0 && hit.value.length > 0) return hit.value;
    } catch {
      // 解析失败视为未配置，走环境变量回退
    }
  }
  const ambient = process.env[envName];
  return typeof ambient === "string" && ambient.length > 0 ? ambient : null;
}

/** 带超时的 fetch（外部 AbortSignal 优先）。 */
async function fetchWithTimeout(url, init, signal) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
  try {
    return await fetch(url, { ...init, signal: signal ?? controller.signal });
  } finally {
    clearTimeout(timeout);
  }
}

export function apply(ctx, config = {}) {
  const apiKeyEnv = config.apiKeyEnv ?? DEFAULT_API_KEY_ENV;
  const baseURL = (config.baseURL ?? DEFAULT_BASE_URL).replace(/\/+$/u, "");

  let cache = null;
  let cacheAt = 0;
  // 历史月份序列缓存：月数据一天内几乎不变（仅月末回看），TTL 拉长到 10 分钟，
  // 避免每次刷新都串行重打 10 个上游请求。
  let monthSeriesCache = null;
  let monthSeriesCacheAt = 0;
  const MONTH_SERIES_CACHE_TTL_MS = 10 * 60 * 1000;

  /** 查询平台用量（当日/当月/30日窗口 + 按日/按月图表序列）。
   * 平台接口单窗口上限 31 天：主窗口取 30 天；按月图表的历史月份
   * 逐月单独请求（月初到次月初 ≤ 31 天），当月复用主窗口数据。 */
  async function queryUsage(signal) {
    const token = readTokenFile();
    if (token === null) {
      return {
        status: "no-token",
        message: "尚未连接 DeepSeek 平台",
      };
    }
    const headers = { authorization: `Bearer ${token}`, ...PLATFORM_HEADERS };
    const fetchWindow = async (days) => {
      const { start, end, tz } = usageWindowParams(days);
      const query = `start=${start}&end=${end}&tz=${tz}`;
      const [amountResp, costResp] = await Promise.all([
        fetchWithTimeout(`${PLATFORM_BASE_URL}${USAGE_AMOUNT_PATH}?${query}`, { headers }, signal),
        fetchWithTimeout(`${PLATFORM_BASE_URL}${USAGE_COST_PATH}?${query}`, { headers }, signal),
      ]);
      if (!amountResp.ok || !costResp.ok) {
        const bad = !amountResp.ok ? amountResp : costResp;
        const body = await bad.text().catch(() => "");
        if (bad.status === 401 || /invalid token/i.test(body)) {
          clearTokenFile();
          return { invalid: true, message: "平台令牌已失效，请重新连接" };
        }
        return { invalid: false, error: `用量接口返回 ${bad.status}${body ? `: ${body.slice(0, 200)}` : ""}` };
      }
      return {
        amountDays: parsePlatformAmount(await amountResp.json(), tz),
        costDays: parsePlatformCost(await costResp.json(), tz),
      };
    };

    try {
      const main = await fetchWindow(USAGE_WINDOW_DAYS);
      if (main.invalid === true) return { status: "no-token", message: main.message };
      if (main.error !== void 0) return { status: "error", message: main.error };
      const { amountDays, costDays } = main;
      const windows = foldUsageWindows(
        recentDays(amountDays, USAGE_WINDOW_DAYS),
        recentDays(costDays, USAGE_WINDOW_DAYS),
      );
      const daily = foldDailySeries(amountDays, costDays);
      // 按月序列：当月复用主窗口；历史月份优先走 10 分钟缓存，缓存未命中
      // 时按月并发请求（每月 2 个接口，全部 Promise.all 并发；平台 WAF
      // 对短时少量并发无碍，且失败单月填零占位不影响其余月份）。
      const cacheNow = Date.now();
      const historyHit =
        monthSeriesCache !== null && cacheNow - monthSeriesCacheAt < MONTH_SERIES_CACHE_TTL_MS;
      let historyMonthly;
      if (historyHit) {
        historyMonthly = monthSeriesCache;
      } else {
        const fetchMonth = async (offset) => {
          const monthDate = new Date(new Date().getFullYear(), new Date().getMonth() - offset, 1);
          const monthKey = localMonthKey(monthDate.getTime());
          const monthStart = new Date(monthDate.getFullYear(), monthDate.getMonth(), 1);
          const monthEnd = new Date(monthDate.getFullYear(), monthDate.getMonth() + 1, 1);
          const startSec = Math.floor(monthStart.getTime() / 1000);
          const endSec = Math.floor(monthEnd.getTime() / 1000);
          const tzSec = -monthDate.getTimezoneOffset() * 60;
          const query = `start=${startSec}&end=${endSec}&tz=${tzSec}`;
          try {
            const [amountResp, costResp] = await Promise.all([
              fetchWithTimeout(`${PLATFORM_BASE_URL}${USAGE_AMOUNT_PATH}?${query}`, { headers }, signal),
              fetchWithTimeout(`${PLATFORM_BASE_URL}${USAGE_COST_PATH}?${query}`, { headers }, signal),
            ]);
            if (amountResp.ok && costResp.ok) {
              const monthAmount = parsePlatformAmount(await amountResp.json(), tzSec);
              const monthCost = parsePlatformCost(await costResp.json(), tzSec);
              return foldMonthlyPoint(monthAmount, monthCost, monthKey);
            }
          } catch {
            // 单月失败填零占位
          }
          return { month: monthKey, hit: 0, miss: 0, completion: 0, costByCurrency: {}, models: [] };
        };
        historyMonthly = await Promise.all(
          Array.from({ length: MONTHLY_SERIES_MONTHS - 1 }, (_, i) => fetchMonth(i + 1)),
        );
        monthSeriesCache = historyMonthly;
        monthSeriesCacheAt = cacheNow;
      }
      const monthly = [foldMonthlyPoint(amountDays, costDays, localMonthKey(Date.now()))];
      monthly.push(...historyMonthly);
      return { status: "ok", windows, series: { daily, monthly } };
    } catch (error) {
      const aborted = error?.name === "AbortError";
      return {
        status: "error",
        message: aborted
          ? "用量查询超时"
          : `用量查询失败 — ${error instanceof Error ? error.message : String(error)}`,
      };
    }
  }

  // 令牌回传端点：仅放行 platform.deepseek.com 的跨域 POST（CORS 预检 +
  // 实际请求），令牌落盘 0600 文件，响应不回显令牌。
  const corsHeaders = {
    "access-control-allow-origin": PLATFORM_BASE_URL,
    "access-control-allow-methods": "POST, OPTIONS",
    "access-control-allow-headers": "content-type",
    "access-control-max-age": "600",
    vary: "Origin",
  };

  const readJsonBody = (req) =>
    new Promise((resolve) => {
      let body = "";
      req.on("data", (chunk) => {
        body += chunk;
        if (body.length > 64 * 1024) req.destroy();
      });
      req.on("end", () => {
        try {
          resolve(JSON.parse(body));
        } catch {
          resolve(null);
        }
      });
      req.on("error", () => resolve(null));
    });

  ctx.effect(() => {
    const disposeToken = ctx.webServer.register({
      kind: "exact",
      path: TOKEN_ROUTE,
      handler: async (req, res) => {
        for (const [key, value] of Object.entries(corsHeaders)) res.setHeader(key, value);
        if (req.method === "OPTIONS") {
          res.writeHead(204);
          res.end();
          return;
        }
        if (req.method !== "POST") {
          res.writeHead(405, { "content-type": "application/json" });
          res.end(JSON.stringify({ ok: false, error: "method not allowed" }));
          return;
        }
        const origin = req.headers.origin;
        // 放行：无 Origin（非浏览器客户端）；platform.deepseek.com 页面
        // （跨域回传命令）；webui 自身（同源 fetch，桌面/移动端手动输入）。
        // 浏览器跨域请求必带 Origin，恶意第三方域与 Host 不匹配即被拒。
        let sameOrigin = false;
        if (typeof origin === "string" && typeof req.headers.host === "string") {
          try {
            sameOrigin = new URL(origin).host === req.headers.host;
          } catch {
            sameOrigin = false;
          }
        }
        if (origin !== void 0 && origin !== PLATFORM_BASE_URL && !sameOrigin) {
          res.writeHead(403, { "content-type": "application/json" });
          res.end(JSON.stringify({ ok: false, error: "origin rejected" }));
          return;
        }
        const payload = await readJsonBody(req);
        const token = typeof payload?.token === "string" ? payload.token.trim() : "";
        if (token.length === 0) {
          res.writeHead(400, { "content-type": "application/json" });
          res.end(JSON.stringify({ ok: false, error: "token is required" }));
          return;
        }
        writeTokenFile(token);
        res.writeHead(200, { "content-type": "application/json" });
        res.end(JSON.stringify({ ok: true }));
      },
    });
    const disposeClear = ctx.webServer.register({
      kind: "exact",
      path: TOKEN_CLEAR_ROUTE,
      handler: (req, res) => {
        if (req.method !== "POST") {
          res.writeHead(405, { "content-type": "application/json" });
          res.end(JSON.stringify({ ok: false, error: "method not allowed" }));
          return;
        }
        clearTokenFile();
        res.writeHead(200, { "content-type": "application/json" });
        res.end(JSON.stringify({ ok: true }));
      },
    });
    return () => {
      disposeToken();
      disposeClear();
    };
  }, "api-balance: token routes");

  ctx.effect(() => {
    const dispose = ctx.connection.rpc.intercept(
      "/api",
      (endpoint) => endpoint === "api-balance/query",
      async (_endpoint, payload, signal) => {
        const refresh = payload?.args?.refresh === true;
        const now = Date.now();
        if (!refresh && cache !== null && now - cacheAt < CACHE_TTL_MS) {
          return { ok: true, value: cache };
        }
        const apiKey = await resolveSecret(ctx, apiKeyEnv);
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
        const [balanceResult, usageResult] = await Promise.all([
          (async () => {
            try {
              const response = await fetchWithTimeout(
                `${baseURL}${BALANCE_PATH}`,
                { method: "GET", headers: { authorization: `Bearer ${apiKey}`, accept: "application/json" } },
                signal,
              );
              if (!response.ok) {
                const body = await response.text().catch(() => "");
                return {
                  ok: false,
                  error: `DeepSeek /user/balance 返回 ${response.status}${body ? `: ${body.slice(0, 200)}` : ""}`,
                };
              }
              return { ok: true, value: projectBalance(await response.json(), apiKey) };
            } catch (error) {
              const aborted = error?.name === "AbortError";
              return {
                ok: false,
                error: aborted
                  ? "查询 DeepSeek 余额超时"
                  : `查询失败 — ${error instanceof Error ? error.message : String(error)}`,
              };
            }
          })(),
          queryUsage(signal),
        ]);
        if (!balanceResult.ok) {
          return { ok: false, error: { code: "internal", message: `api-balance: ${balanceResult.error}`, details: {} } };
        }
        const value = { ...balanceResult.value, usage: usageResult };
        cache = value;
        cacheAt = Date.now();
        return { ok: true, value };
      },
      { authority: "trusted-host" },
    );
    return () => {
      dispose().catch(() => {});
    };
  }, "api-balance: rpc endpoint");
}
