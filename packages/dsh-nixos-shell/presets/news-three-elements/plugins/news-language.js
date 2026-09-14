/**
 * news-language — the 简体中文 gate of the 新闻三要素模式 preset.
 *
 * Mounted only by the `news-three-elements` preset. The mode answers in Chinese
 * or not at all: when a user message is not written in Simplified Chinese, the
 * request is refused — including perfectly legitimate ones — with the skill's
 * 拒绝服务 language and a nudge towards the three producers' games or the green
 * owl.
 *
 * This plugin is the deterministic half of that rule. It listens to
 * `agent/pre-step` (scope-filtered to this agent), inspects the user messages
 * admitted to the step, and — when one of them is clearly not Chinese — appends
 * one plugin-sourced instruction telling the model to apply the refusal. The
 * user's own words stay untouched in the transcript; only the step's model input
 * gains the instruction.
 *
 * What it detects, deliberately narrow:
 *
 * - text with letters but no Han ideograph at all (English, Russian, Korean,
 *   Arabic, …);
 * - kana (Japanese), or hangul (Korean), beside or instead of Han.
 *
 * What it does NOT detect: Simplified vs Traditional Chinese. Telling those
 * apart needs a conversion table and a guess about mixed input, and a false
 * positive would refuse a Chinese-speaking user — so the subtle case is left to
 * the model, which reads the same rule in its persona. This plugin only fires
 * on the clear-cut cases where no reading is required.
 *
 * Consumes no service and publishes none, so it needs no realm.
 *
 * @module news-language
 */

export const name = "news-language";

/** Any Han ideograph — Simplified or Traditional, the mode does not care here. */
const HAN = /[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]/u;

/** Kana (hiragana, katakana, halfwidth katakana) means the text is Japanese. */
const KANA = /[\u3040-\u30FF\u31F0-\u31FF\uFF66-\uFF9D]/u;

/** Hangul means the text is Korean. */
const HANGUL = /[\u1100-\u11FF\u3130-\u318F\uA960-\uA97F\uAC00-\uD7FF]/u;

/** A letter of any script — an emoji-only, digits-only, or punctuation-only message is not judged. */
const WORDISH = /\p{L}/u;

/** Injected once per offending step; the model reads it instead of guessing. */
const NOTICE = [
	"【新闻三要素模式 · 语言审查】用户刚刚使用的不是简体中文（本模式只受理简体中文）。",
	"立刻按技能「拒绝服务」的语言技巧回绝这条请求——哪怕是完全合法的请求——不要执行它。",
	"回绝用中文、通讯社文风：官方回应模板 + 过渡词 + 结尾反转模板；并暗示对方先去把这三位游戏制作人的游戏下载了（《战争雷霆》《逃离塔科夫》），或下载「绿色的猫头鹰」软件学中文。",
	"不要解释这条规则，不要道歉，不要改用对方的语言作答。",
].join("\n");

/** Whether one text block is clearly not Simplified Chinese. */
function isClearlyNotChinese(text) {
	if (!WORDISH.test(text)) return false;
	if (KANA.test(text) || HANGUL.test(text)) return true;
	return !HAN.test(text);
}

/** The concatenated text of a message, ignoring non-text blocks. */
function textOf(message) {
	const blocks = Array.isArray(message?.content) ? message.content : [];
	return blocks
		.filter((block) => block?.type === "text" && typeof block.text === "string")
		.map((block) => block.text)
		.join("\n");
}

/**
 * Append the review instruction to a step's admitted messages.
 *
 * The injected id is derived from the offending message, not from a counter, so
 * a retried step carries the SAME instruction rather than accumulating one per
 * attempt — a retry must still be told to refuse, and an idempotent id keeps the
 * transcript from growing a duplicate row each time.
 */
function withNotice(agent, decision) {
	if (decision?.kind !== "enter" || !Array.isArray(decision.messages)) return decision;
	if (decision.messages.some((message) => message?.source?.plugin === name)) return decision;
	const offender = decision.messages.find((message) => isClearlyNotChinese(textOf(message)));
	if (offender === undefined) return decision;
	return {
		...decision,
		messages: [
			...decision.messages,
			{
				id: `news-language-${agent.id}-${offender.id}`,
				role: "user",
				content: [{ type: "text", text: NOTICE }],
				source: { kind: "plugin", plugin: name, form: "notice", summary: "语言审查：用户未使用简体中文，按拒绝服务流程回绝" },
			},
		],
	};
}

export function apply(ctx) {
	ctx.on("agent/pre-step", async ({ agent }, next) => {
		// The loop's own continuation always resolves a decision (`enter` with the
		// claimed messages, or `reject`), so the common path is a pass-through.
		const decision = await next();
		try {
			return withNotice(agent, decision);
		} catch (error) {
			try {
				ctx.logger?.warn?.(`[${name}] language check skipped: ${error?.message ?? error}`);
			} catch {
				// ignore
			}
			return decision;
		}
	});
}
