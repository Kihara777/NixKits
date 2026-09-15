/**
 * Behaviour tests for the 新闻三要素模式 preset plugins.
 *
 * Run by `nix flake check` (checks.news-mode-tests) with the package tree as the
 * store path, so the imports below resolve inside the same snapshot the preset
 * mounts. Every check prints one line; a non-zero exit means the composition no
 * longer behaves the way the docs claim.
 *
 * The plugins are driven through stub contexts: no harness, no network beyond
 * the repository fetch, no filesystem writes outside the user's cache directory.
 */
import { mkdtempSync, readFileSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

// The plugins resolve their cache directory from DSH_HOME when they load, so the
// environment is pointed at a scratch directory BEFORE the imports below — and
// the whole suite stays hermetic: no network, no writes outside this directory.
process.env.DSH_HOME = mkdtempSync(join(tmpdir(), "news-mode-tests-"));

const { apply: applySkill } = await import("../plugins/news-skill.js");
const { apply: applyOpening } = await import("../plugins/news-opening.js");
const { apply: applyLanguage } = await import("../plugins/news-language.js");
const { apply: applyGate } = await import("../plugins/readonly-gate.js");

const ROOT = fileURLToPath(new URL("..", import.meta.url));
const BUNDLED = new URL("../bundled/news-three-elements/", import.meta.url);
const CACHE_DIR = join(process.env.DSH_HOME, ".cache", "news-three-elements");

let failures = 0;
const check = (label, ok, detail = "") => {
	console.log(`${ok ? "PASS" : "FAIL"} ${label}${detail === "" ? "" : ` — ${detail}`}`);
	if (!ok) failures += 1;
};
const settled = () => new Promise((resolve) => setTimeout(resolve, 0));

/**
 * Serve the package from the bundled snapshot, honouring If-None-Match: the
 * second fetch of a file must come back 304, which is how the ETag path is
 * exercised without a network.
 */
function installFetchStub() {
	const state = { served: 0, notModified: 0, requests: [] };
	globalThis.fetch = async (url, options = {}) => {
		const file = String(url).split("/").pop();
		const body = readFileSync(new URL(file, BUNDLED), "utf8");
		const etag = `"stub-${file}"`;
		state.requests.push(file);
		if (options.headers?.["if-none-match"] === etag) {
			state.notModified += 1;
			return new Response(null, { status: 304 });
		}
		state.served += 1;
		return new Response(body, { status: 200, headers: { etag } });
	};
	return state;
}

/** Let a refresh settle: the fetch resolves immediately, the writes are sync. */
const settleRefresh = () => new Promise((resolve) => setTimeout(resolve, 50));

// ── 1. news-skill: local first, then the live package, then retries ─────────
{
	const stub = installFetchStub();
	const timers = { timeouts: [], intervals: [] };
	const registrations = [];
	const ctx = {
		setTimeout: (fn, ms) => {
			timers.timeouts.push({ fn, ms });
			return () => {};
		},
		setInterval: (fn, ms) => {
			timers.intervals.push({ fn, ms });
			return () => {};
		},
		skills: {
			register(skill) {
				const entry = { skill, disposed: false };
				registrations.push(entry);
				return () => {
					entry.disposed = true;
				};
			},
		},
		logger: { warn: () => {} },
	};
	rmSync(CACHE_DIR, { recursive: true, force: true });
	applySkill(ctx);

	check("skill: the bundled copy is registered synchronously", registrations.length === 1);
	check("skill: it carries the canonical id", registrations[0]?.skill.name === "news-three-elements");
	check("skill: it links the archived package", readdirSync(registrations[0].skill.resourceBase.path).length >= 5);
	check("skill: a six-hour re-check is scheduled", timers.intervals[0]?.ms === 6 * 60 * 60 * 1000, String(timers.intervals[0]?.ms));

	await settleRefresh();
	check("skill: all five files are fetched in one pass", stub.served === 5, `${stub.served} served`);
	check("skill: the live package replaces the bundled one", registrations.length === 2, `${registrations.length} registrations`);
	check("skill: the replaced registration is disposed", registrations[0]?.disposed === true);
	check("skill: the live copy points at the cache", registrations[1]?.skill.resourceBase.path === CACHE_DIR);
	check("skill: the cache holds the whole package", readdirSync(CACHE_DIR).filter((name) => name.endsWith(".md")).length === 5);
	check("skill: the cached body is the repository body", readFileSync(join(CACHE_DIR, "SKILL.md"), "utf8").includes("新闻学三要素时刻"));
	check("skill: an ETag sidecar is written for the next fetch", readdirSync(CACHE_DIR).includes(".etags.json"));

	// The six-hour timer re-checks; every file now answers 304.
	await timers.intervals[0].fn();
	await settleRefresh();
	check("skill: the re-check sends conditional requests", stub.notModified === 5, `${stub.notModified} not-modified`);
	check("skill: an unchanged package is served from the cache", stub.served === 5, `${stub.served} served`);
	check("skill: the skill is re-registered from the cache", registrations.length === 3);

	// A failed fetch retries on the fixed backoff and keeps the local copy.
	let failing = true;
	globalThis.fetch = async () => {
		if (failing) throw new Error("network down");
		return new Response(readFileSync(new URL("SKILL.md", BUNDLED), "utf8"), { status: 200 });
	};
	const retryTimers = [];
	const retryCtx = {
		setTimeout: (fn, ms) => {
			retryTimers.push({ fn, ms });
			return () => {};
		},
		setInterval: () => () => {},
		skills: { register: () => () => {} },
		logger: { warn: () => {} },
	};
	const before = retryTimers.length;
	applySkill(retryCtx);
	await settleRefresh();
	check("skill: a failed attempt schedules the 30 s retry", retryTimers[before]?.ms === 30_000, String(retryTimers[before]?.ms));
	failing = false;
	installFetchStub();
}

// ── 2. news-opening: the picker, its answer, and its withdrawal ─────────────
{
	const harness = (options = {}) => {
		const state = { asked: [], followed: [], listeners: new Map(), aborted: false };
		const agent = {
			id: "session-test",
			session: { ownEvents: () => options.events ?? [] },
			followup: (message) => state.followed.push(message),
		};
		const ctx = {
			logger: { warn: () => {} },
			on: (event, listener) => {
				state.listeners.set(event, listener);
				return () => state.listeners.delete(event);
			},
			userQuestions: {
				ask: async (request) => {
					state.asked.push(request);
					if (options.onAsk !== undefined) return options.onAsk(request, state);
					return options.answer;
				},
			},
		};
		applyOpening(ctx);
		return { state, agent, fire: () => state.listeners.get("agent/session-start")({ agent, source: "startup" }) };
	};

	const labels = [
		"现场直编：你忠诚的俄罗斯三位甲级战争英雄催逝员",
		"听风是雨：想搞个大新闻？巧妇难为无米之炊呀~",
		"你说的对：但是...后边儿是啥来着？",
	];
	{
		const { state, fire } = harness({ answer: { answers: [{ id: "opening", selected: [labels[0]], custom: "" }] } });
		fire();
		await settled();
		const request = state.asked[0];
		check("opening: three options, verbatim", request.questions[0].options.map((option) => option.label).join("|") === labels.join("|"));
		check("opening: no option leaks what it does", request.questions[0].options.every((option) => Object.keys(option).join(",") === "label"));
		check("opening: the ask is agent-scoped and abortable", request.agent !== undefined && request.signal !== undefined);
		check("opening: the answer becomes the session's first user message", state.followed[0]?.content?.[0]?.text === `【新闻三要素模式 · 开场选择】${labels[0]}`);
	}
	{
		const { state, fire } = harness({ answer: { answers: [{ id: "opening", selected: [], custom: "  帮我改下 README  " }] } });
		fire();
		await settled();
		check("opening: a custom answer is passed through, uninterpreted", state.followed[0]?.content?.[0]?.text?.endsWith("（自定义回答）帮我改下 README") === true);
	}
	{
		const { state, fire } = harness({ events: [{ type: "user/message" }], answer: { answers: [{ id: "opening", selected: [labels[1]], custom: "" }] } });
		fire();
		await settled();
		check("opening: a resumed session is not asked again", state.asked.length === 0);
	}
	{
		// The human types first: the pending question is withdrawn and nothing is delivered.
		const { state, fire } = harness({
			onAsk: (request) =>
				new Promise((resolve, reject) => {
					request.signal.addEventListener("abort", () => reject(new Error("ASK_ABORTED")));
					setTimeout(() => resolve({ answers: [] }), 5000);
				}),
		});
		fire();
		await settled();
		check("opening: the picker is still pending until the human acts", state.asked.length === 1 && state.followed.length === 0);
		state.listeners.get("agent/pre-step")({ messages: [{ id: "m1", source: { kind: "user" } }] });
		await settled();
		check("opening: a typed message withdraws the picker", state.followed.length === 0);
	}
}

// ── 3. readonly-gate: allowlist, and the scope of what may be viewed ────────
{
	let guard;
	applyGate({ tools: { guard: (fn) => (guard = fn) } });
	const agent = { session: { header: { cwd: "/home/kix/NixKits" } } };
	const call = (name, args) => guard({ name, arguments: args ?? {}, agent });

	for (const name of ["read", "read_image", "glob", "grep", "web_search", "web_fetch", "skill", "ask_user_question"]) {
		check(`gate: allows ${name}`, call(name) === undefined);
	}
	for (const name of ["write", "edit", "bash", "pwsh", "subagent", "workflow", "todo_write", "some_future_tool"]) {
		const reason = call(name);
		check(`gate: denies ${name}`, typeof reason === "string" && reason.includes("FAKE NEWS"));
	}
	check("gate: viewing inside the workspace is allowed", call("read", { file_path: "/home/kix/NixKits/README.md" }) === undefined);
	check("gate: viewing an attachment is allowed", call("read", { file_path: join(process.env.DSH_HOME ?? join(homedir(), ".dsh"), "attachments/x.png") }) === undefined);
	check("gate: viewing /tmp is allowed", call("glob", { path: "/tmp" }) === undefined);
	check("gate: a relative path is left to the backend", call("read", { file_path: "docs/zh/dsh.md" }) === undefined);
	const denied = call("read", { file_path: "/etc/shadow" });
	check("gate: viewing outside those roots is refused", typeof denied === "string" && denied.includes("/etc/shadow"));
	const deniedGrep = call("grep", { path: "/etc" });
	check("gate: the same scope covers grep", typeof deniedGrep === "string" && deniedGrep.includes("/etc"));
}

// ── 4. news-language: detection, the draw, and the notice's demands ─────────
{
	const persona = readFileSync(join(ROOT, "agent.cordis.yml"), "utf8");
	const plugin = readFileSync(join(ROOT, "plugins/news-language.js"), "utf8");

	let listener;
	applyLanguage({ on: (_event, fn) => (listener = fn), logger: { warn: () => {} } });
	const step = async (text, id = `m${Math.random()}`) => {
		const message = { id, role: "user", content: [{ type: "text", text }], source: { kind: "user" } };
		const decision = await listener({ agent: { id: "s" }, messages: [message], turn: 1, step: 1 }, async () => ({ kind: "enter", messages: [message] }));
		return decision.messages.at(-1);
	};

	for (const [label, text] of [
		["Simplified Chinese", "新闻三要素"],
		["Simplified Chinese with a path", "读一下 docs/zh/skills/news-three-elements.md"],
		["emoji only", "🙂🙂"],
		["digits only", "12345"],
		["Simplified quoting a Traditional name", "把「這個」换成简体再发我"],
	]) {
		const injected = await step(text);
		check(`language: ${label} passes untouched`, injected.source?.plugin === undefined);
	}
	for (const [label, text] of [
		["English", "please rewrite the readme"],
		["Japanese", "READMEを書き直してください"],
		["Korean", "README를 고쳐 주세요"],
		["pinyin", "bang wo gai yi xia"],
		["Traditional Chinese", "請幫我修改這個檔案"],
	]) {
		const injected = await step(text);
		check(`language: ${label} is flagged`, injected.source?.plugin === "news-language", injected.content?.[0]?.text?.slice(0, 40));
	}

	// The draw: the three producers plus the owl, never twice in a row.
	const POOL = [
		{ marker: "尤丁采夫", game: "战争雷霆" },
		{ marker: "巴兰尼科夫", game: "战争雷霆" },
		{ marker: "布亚诺夫", game: "逃离塔科夫" },
		{ marker: "绿色的猫头鹰", game: null },
	];
	const counts = new Map();
	let previous;
	let repeats = 0;
	const DRAWS = 200;
	for (let i = 0; i < DRAWS; i += 1) {
		const injected = await step("please help me", `draw-${i}`);
		const text = injected.content[0].text;
		const hits = POOL.filter((entry) => text.includes(entry.marker));
		if (hits.length !== 1) {
			check("language: every refusal names exactly one entry", false, hits.map((h) => h.marker).join(",") || "none");
			break;
		}
		const [hit] = hits;
		if (hit.game !== null && !text.slice(text.indexOf(hit.marker)).includes(hit.game)) {
			check(`language: ${hit.marker} brings their own game`, false, text.slice(-120));
			break;
		}
		if (previous === hit.marker) repeats += 1;
		previous = hit.marker;
		counts.set(hit.marker, (counts.get(hit.marker) ?? 0) + 1);
	}
	check("language: all four entries are drawn", counts.size === 4, [...counts.entries()].map(([k, v]) => `${k}=${v}`).join(" "));
	check("language: consecutive draws never repeat", repeats === 0, `${repeats} repeats`);
	for (const [entry, n] of counts) {
		check(`language: ${entry} keeps a plausible share`, n / DRAWS > 0.12 && n / DRAWS < 0.4, `${((n / DRAWS) * 100).toFixed(0)}%`);
	}

	const sample = (await step("please help me", "notice-sample")).content[0].text;
	check("notice: demands a fresh search", sample.includes("动笔前先联网取材") && sample.includes("不得复用上一次用过的理由"));
	check("notice: keeps the ritual line with both full-width bangs", sample.includes("我们从不制造 FAKE NEWS！！"));
	check("notice: scopes the translation to the gate", sample.includes("只因为这条请求触发了语言审查"));
	check("notice: matches the caller's own language", sample.includes("对方实际所用的那一种语言"));
	check("persona: draws over people, not games", persona.includes("抽的是**人**") && persona.includes("游戏随人走"));
	check("persona: cites the skill's refusal section", persona.includes("「拒绝服务」一节"));
	check("persona: no half-width ritual bangs", !/FAKE NEWS!!/.test(persona));
	check("plugin: no half-width ritual bangs", !/FAKE NEWS!!/.test(plugin));
}

console.log(failures === 0 ? "\nALL CHECKS PASSED" : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);
