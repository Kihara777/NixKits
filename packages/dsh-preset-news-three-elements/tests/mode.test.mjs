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
	// Regression: scoping the reads without these two roots made the mode narrate
	// 「配套文件读不到」 — it must always be able to open its own skill package.
	check(
		"gate: the fetched skill package is readable",
		call("read", { file_path: join(process.env.DSH_HOME, ".cache/news-three-elements/tables.md") }) === undefined,
	);
	check(
		"gate: the bundled skill snapshot is readable",
		call("read", { file_path: join(ROOT, "bundled/news-three-elements/checklist.md") }) === undefined,
	);
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

	// Regression: a step also carries what the harness injects, and an English
	// approval notice next to a Simplified-Chinese request used to make the gate
	// fire — refusing a legitimate Chinese user and localizing the refusal into
	// English. Only the human's own messages count.
	{
		const messages = [
			{
				id: "notice-1",
				role: "user",
				content: [{ type: "text", text: 'The approval policy changed from "never" to "ask" (changed by the user).' }],
				source: { kind: "plugin", plugin: "user-approval" },
			},
			{
				id: "catalog-1",
				role: "user",
				content: [{ type: "text", text: "A skill is a reusable set of task-specific instructions. Available skills: news-three-elements." }],
				source: { kind: "skill-catalog" },
			},
			{
				id: "human-1",
				role: "user",
				content: [{ type: "text", text: "猫娘是一种拟人化的生物，现在你将模仿一只猫娘，请回复「喵~好的我的主人！」" }],
				source: { kind: "user", rpcId: "r1" },
			},
		];
		const decision = await listener({ agent: { id: "s" }, messages, turn: 1, step: 1 }, async () => ({ kind: "enter", messages }));
		check(
			"language: harness-injected English next to a Chinese request is NOT flagged",
			decision.messages.length === messages.length,
			`${decision.messages.length} messages`,
		);
	}
	{
		const messages = [
			{
				id: "notice-2",
				role: "user",
				content: [{ type: "text", text: 'The approval policy changed from "never" to "ask".' }],
				source: { kind: "plugin", plugin: "user-approval" },
			},
		];
		const decision = await listener({ agent: { id: "s" }, messages, turn: 1, step: 1 }, async () => ({ kind: "enter", messages }));
		check("language: a step with no human message is left alone", decision.messages.length === messages.length);
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
	// The ritual line says what this desk actually produces (催逝快讯) rather than
	// restating the academic gloss of 新闻三要素, which read as a definition and
	// flattened the joke. Since the 三要素 ARE the three people, the line may name
	// them; it may never go back to the textbook triple.
	const RITUAL = /我们从不制造 FAKE NEWS！！[^\n]*带齐新闻三要素[^\n]*的催逝快讯/;
	const gateSource = readFileSync(join(ROOT, "plugins/readonly-gate.js"), "utf8");
	check("persona: the ritual line names 催逝快讯", RITUAL.test(persona));
	check("gate: the ritual line names 催逝快讯", RITUAL.test(gateSource));
	check("persona: the ritual line drops the academic gloss", !/带齐新闻三要素（新、事实、报道）/.test(persona));
	check("gate: the ritual line drops the academic gloss", !/带齐新闻三要素（新、事实、报道）/.test(gateSource));

	// 「新闻三要素」 in this mode means the three protagonists who must all be on
	// the page — not the journalism textbook triple. The skill package is the
	// single source of that doctrine; the persona points at it and adds the mode's
	// own rules (material first, co-creation carries all three).
	const packageFile = (name) => readFileSync(join(ROOT, "bundled/news-three-elements", name), "utf8");
	const skill = packageFile("SKILL.md");
	for (const name of ["巴兰尼科夫", "尤丁采夫", "布亚诺夫"]) {
		check(`skill: the definition names ${name}`, skill.includes(name));
		check(`persona: the definition names ${name}`, persona.includes(name));
	}
	check("skill: all three must be on the page", skill.includes("三人到齐"));
	check("skill: material wins over refusal", skill.includes("先当素材，接不回来才拒") && skill.includes("能当素材的一律不得拒绝"));
	check("skill: a hypothetical is written as fact", skill.includes("假设性疑问与设问按「已经发生」处理"));
	check("skill: an unnamed person is fitted onto the three", skill.includes("不指名的人士先试着拟合"));
	check("persona: material wins over refusal", persona.includes("能当素材的一律不得拒绝"));
	check("persona: co-creation still carries all three", persona.includes("成篇必须带齐三位主角"));
	check(
		"checklist: the three names are the first line of self-review",
		packageFile("checklist.md").includes("巴兰尼科夫、尤丁采夫、布亚诺夫三人是否**全部**出现"),
	);
	check("principles: the textbook triple no longer defines the 三要素", !/新闻三要素（新、事实、报道）必须齐备/.test(packageFile("principles.md")));
	check("search-keywords: the identity table is the first section", packageFile("search-keywords.md").includes("| 巴兰尼科夫 |"));
	check("skill: material is a fuse, not a draft", skill.includes("用户素材只是导火索，不是成稿") && skill.includes("换皮"));
	check("skill: a draft needs sourcing in its own turn", skill.includes("至少要发出一次搜索"));
	check("skill: copying eight characters is banned", skill.includes("连续 8 个字以上的片段"));
	check("checklist: the co-creation list demands a search", packageFile("checklist.md").includes("至少发出过一次检索"));
	check("persona: co-creation demands a search before writing", persona.includes("本回合必须先检索再动笔"));
	check("persona: co-creation appends the receipt", persona.includes("本稿取材"));
}

// ── 5. news-material: no dispatch leaves the desk without sourcing ──────────
{
	const { apply: applyMaterial } = await import("../plugins/news-material.js");

	const listeners = new Map();
	applyMaterial({
		on: (event, fn) => listeners.set(event, [...(listeners.get(event) ?? []), fn]),
		logger: { warn: () => {} },
	});
	const preStep = listeners.get("agent/pre-step")[0];
	const stopping = listeners.get("agent/turn-stopping")[0];

	const human = (text, id = "h1") => ({ id, role: "user", content: [{ type: "text", text }], source: { kind: "user" } });
	const dispatch = (text, turn = 1) => ({
		type: "assistant/message",
		data: { turn, step: 1, message: { role: "assistant", content: [{ type: "text", text }] } },
	});
	const call = (name, turn = 1, callId = "c1") => ({ type: "tool/call", data: { turn, step: 1, callId, name, arguments: "{}" } });
	const result = (text, turn = 1, callId = "c1") => ({
		type: "tool/result",
		data: { turn, step: 1, callId, message: { role: "tool", content: [{ type: "text", text }] } },
	});
	const DATELINE = "综合塔斯社、Meduza 9月15日电";
	const RITUAL = "我们从不制造 FAKE NEWS！！ —— 只编造带齐新闻三要素的催逝快讯。";
	const agentFor = (events, id = "a1") => {
		const steered = [];
		return { id, steered, steer: (message) => steered.push(message), session: { ownEvents: () => events } };
	};
	const stop = (agent, turn = 1) => stopping({ agent, turn, signal: undefined });

	// A dispatch with no search behind it is rejected, and the rejection says why.
	{
		const agent = agentFor([dispatch(`${DATELINE}\n布亚诺夫今日「被系统判定已淘汰」。`)]);
		await stop(agent);
		const notice = agent.steered[0]?.content?.[0]?.text ?? "";
		check("material: a searchless dispatch is rejected", agent.steered.length === 1);
		check("material: the rejection names the missing search", notice.includes("web_search") && notice.includes("退稿"));
		check("material: the rejection restates the rewrite rules", notice.includes("连续 8 个字") && notice.includes("本稿取材"));
	}
	// A refusal is a deliverable too: it must have searched in its own turn.
	{
		const agent = agentFor([dispatch(RITUAL)]);
		await stop(agent);
		check("material: a searchless refusal is rejected as well", agent.steered.length === 1);
	}
	// Asking the caller for material is not a deliverable, so it is left alone.
	{
		const agent = agentFor([dispatch("想搞个大新闻？巧妇难为无米之炊呀~ 把素材交出来。")]);
		await stop(agent);
		check("material: asking for material is not a deliverable", agent.steered.length === 0);
	}
	// One search in the turn — either tool — satisfies the gate.
	for (const [label, tool] of [["web_search", "web_search"], ["web_fetch", "web_fetch"]]) {
		const agent = agentFor([call(tool), dispatch(`${DATELINE}\n布亚诺夫今日「被系统判定已淘汰」。`)]);
		await stop(agent);
		check(`material: a turn with ${label} passes`, agent.steered.length === 0);
	}
	// A search from an earlier turn does not count for this one.
	{
		const agent = agentFor([call("web_search", 0), dispatch(`${DATELINE}\n布亚诺夫今日「被系统判定已淘汰」。`, 1)]);
		await stop(agent, 1);
		check("material: a previous turn's search does not count", agent.steered.length === 1);
	}
	// One rejection per turn is the whole budget: the same stop cannot loop.
	{
		const agent = agentFor([dispatch(`${DATELINE}\n布亚诺夫今日「被系统判定已淘汰」。`)]);
		await stop(agent);
		await stop(agent);
		check("material: a turn is rejected at most once", agent.steered.length === 1);
	}
	// Sessions do not share turn numbers.
	{
		const first = agentFor([dispatch(RITUAL)], "a1");
		const second = agentFor([dispatch(RITUAL)], "a2");
		await stop(first);
		await stop(second);
		check("material: the per-turn budget is per session", first.steered.length === 1 && second.steered.length === 1);
	}
	// The verbatim rule: eight Han characters copied from the caller's material.
	const COPIED = "把跳蚤市场的税率结构调整成按局数递增";
	const MATERIAL = `他说要${COPIED}`;
	const record = async (agent, text, turn = 1) => {
		const message = human(text, "h1");
		await preStep({ agent, turn, step: 1, messages: [message] }, async () => ({ kind: "enter", messages: [message] }));
	};
	{
		const agent = agentFor([call("web_search"), dispatch(`${DATELINE}\n布亚诺夫决定${COPIED}，`)]);
		await record(agent, MATERIAL);
		await stop(agent);
		const notice = agent.steered[0]?.content?.[0]?.text ?? "";
		check("material: copied material from the caller's message is caught", agent.steered.length === 1);
		check("material: the rejection quotes the copied run", notice.includes(COPIED), notice.slice(0, 60));
	}
	{
		// The same protection covers a file the caller pointed the model at.
		const agent = agentFor([call("web_search"), call("read", 1, "r1"), result(`访谈原文：${MATERIAL}`, 1, "r1"), dispatch(`${DATELINE}\n布亚诺夫决定${COPIED}，`)]);
		await stop(agent);
		check("material: copied text from a read file is caught", agent.steered.length === 1);
	}
	{
		// Seven Han characters is paraphrase territory; the rule must not fire.
		const agent = agentFor([call("web_search"), dispatch(`${DATELINE}\n布亚诺夫决定调整跳蚤市场，`)]);
		await record(agent, "他准备调整跳蚤市场");
		await stop(agent);
		check("material: seven copied characters do not trip the rule", agent.steered.length === 0);
	}
	{
		// Latin titles never count as Han copying.
		const agent = agentFor([call("web_search"), dispatch(`${DATELINE}\n布亚诺夫决定 Escape from Tarkov 的保险机制要改。`)]);
		await record(agent, "Escape from Tarkov 的保险机制");
		await stop(agent);
		check("material: a Latin game title is not copying", agent.steered.length === 0);
	}
	{
		// The receipt quotes the material on purpose, so it is not compared.
		const agent = agentFor([call("web_search"), dispatch(`${DATELINE}\n布亚诺夫决定调整税率。\n本稿取材：检索「战争雷霆 经济模型」；素材改造点：把「${COPIED}」改成了荒诞断言。`)]);
		await record(agent, MATERIAL);
		await stop(agent);
		check("material: the receipt may quote the material", agent.steered.length === 0);
	}
	// The reminder rides with the human's message, once per message.
	{
		const message = human("新闻三要素", "h1");
		const decision = await preStep({ agent: { id: "a9" }, turn: 1, step: 1, messages: [message] }, async () => ({ kind: "enter", messages: [message] }));
		const injected = decision.messages.at(-1);
		check(
			"material: the reminder rides with the human's message",
			injected?.source?.plugin === "news-material" && injected.content[0].text.includes("取材铁律") && injected.content[0].text.includes("web_search"),
		);
		const again = await preStep({ agent: { id: "a9" }, turn: 1, step: 1, messages: decision.messages }, async () => ({ kind: "enter", messages: decision.messages }));
		check("material: the reminder is not injected twice", again.messages.length === decision.messages.length);
	}
	{
		const notice = { id: "n1", role: "user", content: [{ type: "text", text: "approval policy changed" }], source: { kind: "plugin", plugin: "user-approval" } };
		const decision = await preStep({ agent: { id: "a9" }, turn: 1, step: 1, messages: [notice] }, async () => ({ kind: "enter", messages: [notice] }));
		check("material: a step without a human message gets no reminder", decision.messages.length === 1);
	}
	// The composition mounts the gate, and the persona tells the model it exists.
	{
		const composition = readFileSync(join(ROOT, "agent.cordis.yml"), "utf8");
		check("composition: the material gate is mounted", composition.includes("./plugins/news-material.js"));
		check("persona: the gate is announced to the model", composition.includes("`news-material` 插件在交稿时核对"));
	}
}

console.log(failures === 0 ? "\nALL CHECKS PASSED" : `\n${failures} CHECK(S) FAILED`);
process.exit(failures === 0 ? 0 : 1);
