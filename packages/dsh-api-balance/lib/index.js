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
 * 令牌获取（两级，全自动优先）：
 *  1. 本机浏览器自动扫描：直接读取本机 Chromium 系浏览器（Edge / Chrome /
 *     Brave / Chromium / Vivaldi / Opera，各 Profile）的 Local Storage
 *     LevelDB（`Local Storage/leveldb/*.ldb|.log`），提取 base64 候选
 *     （55–85 字符）并逐个发往
 *     GET platform.deepseek.com/api/v0/users/get_user_summary 校验
 *     （code === 0 即有效），命中即落盘——用户在本机浏览器登录过平台
 *     即可无感获取，无需控制台手动粘贴。节流：默认每 6 小时最多扫描
 *     一次；令牌失效（40003/401）后下一次查询立即重扫。
 *  2. 手动一键授权（回退）：client 端「连接平台」按钮打开
 *     platform.deepseek.com/usage 并把一条回传命令写入剪贴板；用户在
 *     平台页控制台粘贴回车，命令读取 localStorage 的 userToken 并 POST
 *     到本插件的 `/api/api-balance/token` 端点（CORS 仅放行
 *     platform.deepseek.com origin）。
 *
 * 令牌只落盘 $DSH_HOME/api-balance-token（0600），绝不回显、绝不入日志。
 *
 * 币种：两个官方接口的响应均自带 currency 字段，host 只做 JSON 归一化与
 * 短 TTL 缓存，client 按币种分组渲染——识别/区分币种由数据天然完成。
 *
 * @module @kihara777/dsh-api-balance
 */
import { credentialRef } from "@deepseek-ai/dsh-credentials";
import { readFileSync, writeFileSync, rmSync, readdirSync, statSync } from "node:fs";
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

/** 平台用户摘要接口：浏览器扫描候选的校验端点（code === 0 即令牌有效）。 */
const USER_SUMMARY_PATH = "/api/v0/users/get_user_summary";

/** 本机 Chromium 系浏览器配置根目录（Local Storage LevelDB 所在）。 */
const BROWSER_ROOTS = (() => {
  const home = homedir();
  const localAppData = process.env.LOCALAPPDATA;
  if (process.platform === "darwin") {
    return [
      join(home, "Library", "Application Support", "Google", "Chrome"),
      join(home, "Library", "Application Support", "Microsoft Edge"),
      join(home, "Library", "Application Support", "BraveSoftware", "Brave-Browser"),
      join(home, "Library", "Application Support", "Arc"),
    ];
  }
  if (process.platform === "win32" && typeof localAppData === "string" && localAppData.length > 0) {
    return [
      join(localAppData, "Google", "Chrome", "User Data"),
      join(localAppData, "Microsoft", "Edge", "User Data"),
      join(localAppData, "BraveSoftware", "Brave-Browser", "User Data"),
    ];
  }
  return [
    join(home, ".config", "microsoft-edge"),
    join(home, ".config", "google-chrome"),
    join(home, ".config", "chromium"),
    join(home, ".config", "BraveSoftware", "Brave-Browser"),
    join(home, ".config", "vivaldi"),
    join(home, ".config", "opera"),
  ];
})();
/** 单文件扫描上限（避免误读超大文件）。 */
const BROWSER_SCAN_MAX_BYTES = 64 * 1024 * 1024;
/** userToken 候选长度区间（实测 64/66 字符，放宽防变化）。 */
const TOKEN_LEN_MIN = 55;
const TOKEN_LEN_MAX = 85;
/** 单次扫描校验的候选上限（约束「无有效令牌」时的上游成本）。 */
const MAX_CANDIDATES = 40;

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

/** 令牌元数据：记录获取来源（browser / manual），供 client 展示。 */
function tokenMetaPath() {
  return `${tokenFilePath()}.meta.json`;
}

function readTokenMeta() {
  try {
    const value = JSON.parse(readFileSync(tokenMetaPath(), "utf8"));
    return typeof value === "object" && value !== null ? value : {};
  } catch {
    return {};
  }
}

function writeTokenMeta(source) {
  try {
    writeFileSync(tokenMetaPath(), JSON.stringify({ source, at: Date.now() }), { mode: 0o600 });
  } catch {
    // 元数据写入失败不影响令牌本身
  }
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

/**
 * 扫描本机浏览器 Local Storage LevelDB，提取 userToken 候选。
 * Chromium 系浏览器把 localStorage 存为 LevelDB：键形如
 * `_https://platform.deepseek.com\x00\x01userToken`，值为 `\x01`（编码
 * 标记）+ `{"value":"<token>","__version":"0"}`。LevelDB 记录可能跨
 * SSTable / 日志文件且块经 snappy 压缩，无法可靠整体解析，因此采用
 * 启发式：只读含 platform origin 或 userToken 标记的文件，提取 base64
 * 运行，按「userToken 标记邻近的 JSON value」→「origin 文件内」→
 * 「其余」分档排序（真实令牌通常落在第一档）。
 */
function scanBrowserTokens() {
  const tiers = [[], [], []];
  const seen = new Set();
  const push = (tier, token) => {
    if (!seen.has(token)) {
      seen.add(token);
      tiers[tier].push(token);
    }
  };
  for (const root of BROWSER_ROOTS) {
    let profiles = [];
    try {
      profiles = readdirSync(root);
    } catch {
      continue;
    }
    for (const profile of profiles) {
      if (profile === "Local State" || profile.startsWith(".")) continue;
      let files = [];
      try {
        files = readdirSync(join(root, profile, "Local Storage", "leveldb"));
      } catch {
        continue;
      }
      for (const file of files) {
        if (!file.endsWith(".ldb") && !file.endsWith(".log")) continue;
        const path = join(root, profile, "Local Storage", "leveldb", file);
        let buf;
        try {
          if (statSync(path).size > BROWSER_SCAN_MAX_BYTES) continue;
          buf = readFileSync(path);
        } catch {
          continue;
        }
        const text = buf.toString("latin1");
        const hasOrigin = text.includes("platform.deepseek.com");
        const hasMarker = text.includes("userToken");
        if (!hasOrigin && !hasMarker) continue;
        // 第一档：userToken 标记邻近的 JSON value（最接近真实记录结构）。
        if (hasMarker) {
          let idx = 0;
          while ((idx = text.indexOf("userToken", idx)) !== -1) {
            const segment = text.slice(idx, idx + 600);
            const match = segment.match(/"value"\s*:\s*"([A-Za-z0-9+/=]{40,200})"/);
            if (match !== null) push(0, match[1]);
            idx += 9;
          }
        }
        // 第二/三档：文件内独立 base64 运行，按长度收敛。
        const re = /[A-Za-z0-9+/=]{40,200}/g;
        let match;
        while ((match = re.exec(text)) !== null) {
          const len = match[0].length;
          if (len < TOKEN_LEN_MIN || len > TOKEN_LEN_MAX) continue;
          push(hasOrigin ? 1 : 2, match[0]);
        }
      }
    }
  }
  const byLen = (a, b) => Math.abs(a.length - 65) - Math.abs(b.length - 65);
  return [...tiers[0].sort(byLen), ...tiers[1].sort(byLen), ...tiers[2].sort(byLen)].slice(0, MAX_CANDIDATES);
}

/** 校验候选令牌：平台用户摘要接口 code === 0 即有效。 */
async function verifyPlatformToken(token, signal) {
  try {
    const response = await fetchWithTimeout(
      `${PLATFORM_BASE_URL}${USER_SUMMARY_PATH}`,
      { headers: { authorization: `Bearer ${token}`, ...PLATFORM_HEADERS } },
      signal,
    );
    if (!response.ok) return false;
    const data = await response.json();
    return data?.code === 0;
  } catch {
    return false;
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

  // 浏览器自动扫描状态：来源记录、扫描节流与并发去重。
  const browserScan = config.browserScan !== false;
  const browserScanIntervalMs =
    typeof config.browserScanIntervalMs === "number" && config.browserScanIntervalMs > 0
      ? config.browserScanIntervalMs
      : 6 * 60 * 60 * 1000;
  const tokenState = {
    source: readTokenMeta().source === "browser" ? "browser" : "manual",
    lastScanAt: 0,
    scanInFlight: null,
  };

  /** 扫描本机浏览器并逐候选校验，命中即落盘（返回扫描报告）。 */
  async function acquireBrowserToken(signal) {
    if (tokenState.scanInFlight !== null) return tokenState.scanInFlight;
    const run = (async () => {
      const started = Date.now();
      const candidates = scanBrowserTokens();
      const report = { candidates: candidates.length, found: false, elapsedMs: 0 };
      for (const token of candidates) {
        if (await verifyPlatformToken(token, signal)) {
          writeTokenFile(token);
          writeTokenMeta("browser");
          tokenState.source = "browser";
          report.found = true;
          break;
        }
      }
      report.elapsedMs = Date.now() - started;
      tokenState.lastScanAt = Date.now();
      return report;
    })();
    tokenState.scanInFlight = run;
    try {
      return await run;
    } finally {
      tokenState.scanInFlight = null;
    }
  }

  /** 平台令牌获取：落盘文件优先；无令牌且开启扫描时自动尝试本机浏览器。 */
  async function ensureUsageToken(signal, forceScan) {
    const existing = readTokenFile();
    if (existing !== null) {
      return { token: existing, source: tokenState.source, scan: null };
    }
    if (!browserScan) return { token: null, source: null, scan: null };
    if (forceScan !== true && Date.now() - tokenState.lastScanAt < browserScanIntervalMs) {
      return { token: null, source: null, scan: null };
    }
    const report = await acquireBrowserToken(signal);
    const token = readTokenFile();
    return { token, source: token !== null ? tokenState.source : null, scan: report };
  }

  /** 查询平台用量（当日/当月/30日窗口 + 按日/按月图表序列）。
   * 平台接口单窗口上限 31 天：主窗口取 30 天；按月图表的历史月份
   * 逐月单独请求（月初到次月初 ≤ 31 天），当月复用主窗口数据。 */
  async function queryUsage(signal, tokenCtx) {
    const { token, source, scan } = tokenCtx;
    const tokenMeta = {
      tokenSource: source,
      scanReport: scan !== null ? scan : null,
    };
    if (token === null) {
      return {
        status: "no-token",
        message: "尚未连接 DeepSeek 平台",
        ...tokenMeta,
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
          tokenState.lastScanAt = 0; // 令牌失效：下次查询立即重扫浏览器
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
      if (main.invalid === true) return { status: "no-token", message: main.message, ...tokenMeta };
      if (main.error !== void 0) return { status: "error", message: main.error, ...tokenMeta };
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
      return { status: "ok", windows, series: { daily, monthly }, ...tokenMeta };
    } catch (error) {
      const aborted = error?.name === "AbortError";
      return {
        status: "error",
        message: aborted
          ? "用量查询超时"
          : `用量查询失败 — ${error instanceof Error ? error.message : String(error)}`,
        ...tokenMeta,
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
        writeTokenMeta("manual");
        tokenState.source = "manual";
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

  /** api-balance/query 的 RPC 业务逻辑（apply 闭包内，供 exact fetch route 调用）。 */
  async function queryRpc(payload, signal) {
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
    // 平台令牌：落盘优先；缺失时按节流自动扫描本机浏览器（rescanBrowsers
    // 强制立即重扫）。扫描在余额请求并发之外先行完成，避免竞态写令牌。
    const usageTokenCtx = await ensureUsageToken(signal, payload?.args?.rescanBrowsers === true);
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
      queryUsage(signal, usageTokenCtx),
    ]);
    if (!balanceResult.ok) {
      return { ok: false, error: { code: "internal", message: `api-balance: ${balanceResult.error}`, details: {} } };
    }
    const value = { ...balanceResult.value, usage: usageResult };
    cache = value;
    cacheAt = Date.now();
    return { ok: true, value };
  }

  ctx.effect(() => {
    // 注意：不能用 ctx.connection.rpc.intercept("/api", …)——client-connection
    // 的 shared RPC channel interceptor 是互斥的（每 channel 仅一个，重复
    // 注册直接 throw），而 /api 已被 typert-gateway 占用；再抢会导致其
    // interceptor 被顶掉、所有 llm/session 等 RPC 方法 404。改用精确
    // fetch route（fetchRoutes 优先于 interceptor 命中），自行实现 dsh 的
    // RPC envelope 约定：{ rpcId, method, payload } →
    // { type: "server-response", rpcId, result }。
    const dispose = ctx.connection.fetch.register({
      path: "/api/api-balance/query",
      methods: ["POST"],
      fetch: async (request) => {
        let body;
        try {
          body = await request.json();
        } catch {
          return new Response("body is not JSON", { status: 400 });
        }
        const rpcId = typeof body?.rpcId === "string" ? body.rpcId : "invalid-request";
        if (body?.method !== "api-balance/query") {
          return Response.json({
            type: "server-response",
            rpcId,
            result: {
              ok: false,
              error: {
                code: "gateway/bad-request",
                message: `method ${JSON.stringify(body?.method)} does not match endpoint "api-balance/query"`,
                details: { issues: [] },
              },
            },
          });
        }
        try {
          const result = await queryRpc(body?.payload ?? {}, request.signal);
          return Response.json({ type: "server-response", rpcId, result });
        } catch (error) {
          return new Response(`handler failure: ${String(error)}`, { status: 500 });
        }
      },
    });
    return () => {
      dispose();
    };
  }, "api-balance: rpc endpoint");
}
