/**
 * news-material — the desk's sourcing gate for the 新闻三要素模式 preset.
 *
 * The mode has one failure the prompt alone does not prevent: handed material
 * (a pasted log, an uploaded document, a file in the workspace), the model
 * reformats the caller's own words into a dispatch and never searches. The
 * persona asks for a fresh search before every dispatch; a rule that is only
 * asked for decays, so this plugin makes the two halves of it checkable.
 *
 * - `agent/pre-step` rides one 取材铁律 reminder along with the human's own
 *   message, so the very step that decides whether to search carries the rule.
 * - `agent/turn-stopping` reads the closing turn's own log. A turn that
 *   delivered a dispatch or a refusal (a dateline, or the ritual line) with no
 *   `web_search` / `web_fetch` call anywhere in it is rejected: the listener
 *   steers one 退稿 notice, which the loop consumes as fresh steering and runs
 *   another step of the SAME turn (`dsh-agent-loop`: a steered stop boundary
 *   re-reads the inbox and keeps the turn open). One rejection per turn is the
 *   whole budget, so a model that ignores the notice cannot loop.
 *
 * The second half of the same rule is stated numerically: a co-created dispatch
 * may not carry a run of eight or more consecutive Han characters copied from
 * the caller's own material — their messages, plus the files they pointed the
 * model at (`read` results this turn; search results are deliberately NOT
 * material, since reusing a wire-service phrase is the point of the mode). Only
 * Han characters count, so a Latin game title is never mistaken for copying and
 * the protagonists' names (five characters at most) stay clear of the
 * threshold. The receipt line 「本稿取材」 quotes the material on purpose and is
 * excluded from the comparison.
 *
 * Reads the mode's own session log through the host `agent` seam and provides no
 * service, so no realm is needed.
 *
 * @module news-material
 */

export const name = "news-material";

/** The tool calls that count as sourcing a dispatch. */
const SOURCING_TOOLS = new Set(["web_search", "web_fetch"]);

/** The tools whose results are caller-supplied material. */
const MATERIAL_TOOLS = new Set(["read"]);

/** What a dispatch or a refusal looks like: a dateline, or the ritual line. */
const DELIVERABLE = /综合[^\n]{0,80}电|我们从不制造 FAKE NEWS！！/;

/** The receipt line a co-created dispatch appends; it quotes material on purpose. */
const RECEIPT = /\n?本稿取材[\s\S]*$/;

/** Han characters are the unit the verbatim rule counts. */
const HAN = /^[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]+$/;

/** How many consecutive Han characters copied from the material count as copying. */
const MIN_COPIED = 8;

/** Per-text and per-turn bounds, so one pasted novel cannot stall a turn. */
const MAX_TEXT = 4000;
const MAX_MATERIAL = 12000;

/** The reminder injected with the human's own message. */
const REMINDER = [
	"【新闻三要素模式 · 取材铁律】用户素材只是导火索，不是成稿。",
	"动笔前先按技能 `SKILL.md` 第 1 步联网检索——本回合至少要发出一次 `web_search` / `web_fetch`；再按「提炼 → 投射 → 换皮」改写：正文里不得出现用户原文中连续 8 个字以上的片段，事实外壳（电头、职务、机构、日期）一律用当次检索到的真实材料。",
	"编辑部在交稿时核对：本回合没有检索记录的稿子一律退回重写。",
].join("\n");

/** The rejection for a dispatch that was written without a single search. */
const NO_SEARCH_NOTICE = [
	"【新闻三要素模式 · 编辑部退稿】这一稿没有任何取材记录：本回合里没发出过一次 `web_search` / `web_fetch`，等于把用户给的材料换了层皮就发稿。",
	"按技能 `SKILL.md` 第 1 步重发一稿：",
	"1. 先联网检索——三位主角近况、俄罗斯当日真实新闻措辞、游戏机制近期争议；",
	"2. 用户素材只当导火索，按「提炼 → 投射 → 换皮」改写，正文里不得出现用户原文中连续 8 个字以上的片段；",
	"3. 事实外壳（电头、职务、机构、日期）一律用检索到的真实材料，三人到齐，结尾欧·亨利式反转；",
	"4. 交稿后附一行「本稿取材」：检索词 + 一条当日真实细节 + 素材改造点。",
].join("\n");

/**
 * The rejection for a dispatch that copied the caller's words.
 * @param fragment - the copied run, quoted back so the rewrite is unambiguous.
 * @returns the notice text.
 */
function copiedNotice(fragment) {
	return [
		`【新闻三要素模式 · 编辑部退稿】这一稿照搬了用户的原文——检测到连续 8 个字以上的原文片段：「${fragment}」。`,
		"素材是导火索，不是成稿：先按技能 `SKILL.md` 第 1 步确认本回合已有检索，再用检索到的当日真实措辞重写这一段，把它改造成荒诞断言挂到三位主角身上。",
		"三人到齐、结尾欧·亨利式反转，交稿后附一行「本稿取材」。重发一稿。",
	].join("\n");
}

/** The concatenated text of a message, ignoring non-text blocks. */
function textOf(message) {
	const blocks = Array.isArray(message?.content) ? message.content : [];
	return blocks
		.filter((block) => block?.type === "text" && typeof block.text === "string")
		.map((block) => block.text)
		.join("\n")
		.slice(0, MAX_TEXT);
}

/** The messages this gate may treat as material: the human's own. */
function isHumanMessage(message) {
	return message?.source?.kind === "user";
}

/** The session's own events, or an empty log when it cannot be read. */
function eventsOf(agent) {
	try {
		return agent.session.ownEvents();
	} catch {
		return [];
	}
}

/** The events this turn produced. */
function turnEvents(agent, turn) {
	return eventsOf(agent).filter((event) => event?.data?.turn === turn);
}

/** Whether the turn sourced anything at all. */
function sourcedThisTurn(events) {
	return events.some((event) => event.type === "tool/call" && SOURCING_TOOLS.has(event.data?.name));
}

/** Whether the turn delivered a dispatch or a refusal. */
function deliveredThisTurn(events) {
	return events.some((event) => event.type === "assistant/message" && DELIVERABLE.test(textOf(event.data?.message)));
}

/** The draft text this turn delivered, so the verbatim test has something to read. */
function draftOf(events) {
	return events
		.filter((event) => event.type === "assistant/message")
		.map((event) => textOf(event.data?.message))
		.join("\n")
		.slice(0, MAX_TEXT);
}

/** The text of every file the turn read, which is material too. */
function readMaterial(events) {
	const calls = new Set();
	for (const event of events) {
		if (event.type === "tool/call" && MATERIAL_TOOLS.has(event.data?.name)) calls.add(event.data?.callId);
	}
	if (calls.size === 0) return "";
	return events
		.filter((event) => event.type === "tool/result" && calls.has(event.data?.callId))
		.map((event) => textOf(event.data?.message))
		.join("\n");
}

/**
 * The longest run of consecutive Han characters the draft shares with the
 * material, when that run reaches the threshold.
 *
 * The material's qualifying 8-grams go into a set, so detection costs one pass
 * over each text instead of a quadratic scan; a hit is then extended in both
 * directions to quote the exact copied run.
 *
 * @param material - the caller's own words plus what the turn read.
 * @param draft - the dispatch the turn delivered.
 * @returns the copied run, or `undefined` when the draft is clear.
 */
function copiedRun(material, draft) {
	const source = String(material ?? "").slice(0, MAX_MATERIAL);
	const text = String(draft ?? "").replace(RECEIPT, "");
	if (source === "" || text === "") return undefined;
	const grams = new Set();
	for (let i = 0; i + MIN_COPIED <= source.length; i += 1) {
		const gram = source.slice(i, i + MIN_COPIED);
		if (HAN.test(gram)) grams.add(gram);
	}
	if (grams.size === 0) return undefined;
	for (let i = 0; i + MIN_COPIED <= text.length; i += 1) {
		const gram = text.slice(i, i + MIN_COPIED);
		if (!HAN.test(gram) || !grams.has(gram)) continue;
		const at = source.indexOf(gram);
		let length = MIN_COPIED;
		while (
			i + length < text.length &&
			at + length < source.length &&
			text[i + length] === source[at + length] &&
			HAN.test(text[i + length])
		) {
			length += 1;
		}
		return text.slice(i, i + length);
	}
	return undefined;
}

/** Log without ever letting logging break the mode. */
function warn(ctx, message) {
	try {
		ctx.logger?.warn?.(`[${name}] ${message}`);
	} catch {
		// ignore
	}
}

export function apply(ctx) {
	/** Per-agent bookkeeping: this turn's material, and the turns already rejected. */
	const state = new WeakMap();
	const stateOf = (agent) => {
		let entry = state.get(agent);
		if (entry === undefined) {
			entry = { material: new Map(), rejected: new Set() };
			state.set(agent, entry);
		}
		return entry;
	};

	ctx.on("agent/pre-step", async ({ agent, turn }, next) => {
		const decision = await next();
		try {
			if (decision?.kind !== "enter" || !Array.isArray(decision.messages)) return decision;
			const human = decision.messages.filter(isHumanMessage);
			if (human.length === 0) return decision;
			const entry = stateOf(agent);
			// Accumulate: a turn can admit the user's opening message and then a
			// steering message, and the material of both belongs to that turn.
			const previous = entry.material.get(turn) ?? "";
			entry.material.set(turn, `${previous}\n${human.map(textOf).join("\n")}`.slice(0, MAX_MATERIAL));
			// Only the current turn's material is ever read back.
			for (const key of entry.material.keys()) if (key !== turn) entry.material.delete(key);
			const id = `news-material-${agent.id}-${human[0].id}`;
			if (decision.messages.some((message) => message?.id === id)) return decision;
			return {
				...decision,
				messages: [
					...decision.messages,
					{
						id,
						role: "user",
						content: [{ type: "text", text: REMINDER }],
						source: { kind: "plugin", plugin: name, form: "notice", summary: "取材铁律：素材只是导火索，成稿前必须联网检索" },
					},
				],
			};
		} catch (error) {
			warn(ctx, `material reminder skipped: ${error?.message ?? error}`);
			return decision;
		}
	});

	ctx.on("agent/turn-stopping", ({ agent, turn }) => {
		try {
			const entry = stateOf(agent);
			if (entry.rejected.has(turn)) return;
			const events = turnEvents(agent, turn);
			if (!deliveredThisTurn(events)) return;
			const reject = (text, summary) => {
				entry.rejected.add(turn);
				agent.steer({
					id: `news-material-${agent.id}-${turn}`,
					role: "user",
					content: [{ type: "text", text }],
					source: { kind: "plugin", plugin: name, form: "notice", summary },
				});
			};
			if (!sourcedThisTurn(events)) {
				reject(NO_SEARCH_NOTICE, "编辑部退稿：本稿没有任何检索记录");
				return;
			}
			const material = [entry.material.get(turn) ?? "", readMaterial(events)].filter((part) => part !== "").join("\n");
			const fragment = copiedRun(material, draftOf(events));
			if (fragment === undefined) return;
			reject(copiedNotice(fragment), `编辑部退稿：照搬了用户原文「${fragment}」`);
		} catch (error) {
			warn(ctx, `sourcing check skipped: ${error?.message ?? error}`);
		}
	});
}
