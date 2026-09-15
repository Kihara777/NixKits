/**
 * news-opening — the session-start picker of the 新闻三要素模式 preset.
 *
 * Mounted only by the `news-three-elements` preset. When a session's lifecycle
 * begins (`agent/session-start`, emitted once before the first turn, after the
 * agent is live and announced), this plugin raises one interactive question with
 * the mode's three opening choices and waits for the human.
 *
 * The answer becomes the session's FIRST USER MESSAGE. That is the whole trick:
 * a preset can put words in the transcript, and the persona maps each opening
 * line to a behaviour, so the mode starts itself without the user typing
 * anything. Raising the question is not enough on its own — `ask()` returns a
 * value to its caller, so the plugin has to deliver it into the loop through
 * `agent.followup()`, which queues a turn and wakes the driver.
 *
 * Two deliberate omissions:
 *
 * - No option carries a `description`. The three labels are the entire visible
 *   surface; what each one actually does lives in the persona, never in the
 *   question the user reads.
 * - A custom answer is passed through verbatim. The persona decides what to do
 *   with it (refuse, per the skill's 拒绝服务 language) — the plugin never
 *   interprets the human's words.
 *
 * A resumed session is skipped: the picker is an opening, not a greeting, and a
 * conversation that already has a `user/message` in its own log has been opened
 * before.
 *
 * Consumes the host `userQuestions` seam; provides no service, so no realm is
 * needed.
 *
 * @module news-opening
 */

export const name = "news-opening";

export const inject = ["userQuestions"];

/** The question id echoed back in the answer. */
const QUESTION_ID = "opening";

/** Heading shown above the question, when the client renders one. */
const HEADER = "新闻三要素模式";

/** What the picker asks. It names no behaviour on purpose. */
const QUESTION = "今日头条，从哪一版开始？";

/**
 * The three opening choices, verbatim. These strings are the user-visible
 * surface AND the tokens the persona keys on, so they must not drift apart.
 */
const OPTIONS = [
	{ label: "现场直编：你忠诚的俄罗斯三位甲级战争英雄催逝员" },
	{ label: "听风是雨：想搞个大新闻？巧妇难为无米之炊呀~" },
	{ label: "你说的对：但是...后边儿是啥来着？" },
];

/** Prefix every opening message carries, so the transcript shows where it came from. */
const PREFIX = "【新闻三要素模式 · 开场选择】";

/** Whether this session has already been opened (a resumed conversation is not re-asked). */
function alreadyOpened(agent) {
	try {
		return agent.session.ownEvents().some((event) => event.type === "user/message");
	} catch {
		// An unreadable log must not suppress the picker on a fresh session.
		return false;
	}
}

/** Read the human's answer as one opening line, or `undefined` when they skipped. */
function openingLine(answer) {
	const entry = answer?.answers?.find((candidate) => candidate.id === QUESTION_ID);
	if (entry === undefined) return undefined;
	const custom = typeof entry.custom === "string" ? entry.custom.trim() : "";
	if (custom !== "") return `（自定义回答）${custom}`;
	const selected = Array.isArray(entry.selected) ? entry.selected.find((label) => typeof label === "string") : undefined;
	return selected === undefined || selected === "" ? undefined : selected;
}

/**
 * Ask, then hand the answer to the loop as the session's first user message.
 *
 * The question is withdrawn the moment the human starts talking on their own:
 * a pending picker in front of a typed request is noise, so a user message
 * admitted to any step aborts the ask, and that first message simply becomes the
 * session's opener instead.
 *
 * @param ctx - the plugin's agent-scoped context.
 * @param agent - the agent whose session just started.
 */
async function open(ctx, agent) {
	if (alreadyOpened(agent)) return;
	const controller = new AbortController();
	const stopWatching = ctx.on("agent/pre-step", ({ messages }) => {
		const typed = (messages ?? []).some(
			(message) => message?.source?.kind === "user" && !String(message?.id ?? "").startsWith("news-opening-"),
		);
		if (typed) controller.abort();
	});
	let answer;
	try {
		answer = await ctx.userQuestions.ask({
			agent,
			questions: [{ id: QUESTION_ID, header: HEADER, question: QUESTION, options: OPTIONS }],
			signal: controller.signal,
		});
	} catch (error) {
		// Withdrawn by the user's own opening line, or no answerer attached
		// (headless, a client-less session): the mode still works by typing.
		warn(ctx, `opening question not answered: ${error?.message ?? error}`);
		return;
	} finally {
		try {
			stopWatching();
		} catch {
			// ignore
		}
	}
	const line = openingLine(answer);
	if (line === undefined) return;
	try {
		agent.followup({
			id: `news-opening-${agent.id}-${Date.now()}`,
			role: "user",
			content: [{ type: "text", text: `${PREFIX}${line}` }],
			source: { kind: "user" },
		});
	} catch (error) {
		warn(ctx, `opening answer not delivered: ${error?.message ?? error}`);
	}
}

/** Log without ever letting logging break the mode. */
function warn(ctx, message) {
	try {
		ctx.logger?.warn?.(`[news-opening] ${message}`);
	} catch {
		// ignore
	}
}

export function apply(ctx) {
	ctx.on("agent/session-start", ({ agent }) => {
		void open(ctx, agent);
	});
}
