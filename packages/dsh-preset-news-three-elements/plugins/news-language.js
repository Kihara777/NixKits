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

/**
 * Where the refusal sends the caller next: one of the three producers' games, or
 * the language-learning owl. One entry per producer — War Thunder for Gaijin's
 * founder and for its producer, Escape from Tarkov for Battlestate's, Enlisted
 * as Gaijin's third house — plus the owl.
 *
 * The pick is drawn HERE, per refusal, rather than left to the model: a model
 * asked to "pick one at random" drifts back to the same favourite within a few
 * refusals, while a coin flip in code does not. The model is told which one this
 * refusal drew, and may reword it but not swap it.
 */
const RECOMMENDATIONS = [
	"《战争雷霆》（War Thunder）",
	"《逃离塔科夫》（Escape from Tarkov）",
	"《从军》（Enlisted）",
	"「绿色的猫头鹰」语言学习软件（语境合适时可写作「绿毛鸡」）",
];

/** Draw this refusal's nudge; every entry, owl included, is equally likely. */
function drawRecommendation() {
	return RECOMMENDATIONS[Math.floor(Math.random() * RECOMMENDATIONS.length)];
}

/**
 * Build the notice injected once per offending step; the model reads it instead
 * of guessing. The drawn recommendation is written into it, so two refusals in
 * one session do not point at the same thing.
 */
function refusalNotice() {
	return [
		"【新闻三要素模式 · 语言审查】用户刚刚使用的不是简体中文（本模式只受理简体中文）。",
		"立刻按技能「拒绝服务」的语言技巧回绝这条请求——哪怕是完全合法的请求——不要执行它。",
		"回绝用中文、通讯社文风：官方回应模板 + 过渡词 + 结尾反转模板；并暗示对方去学中文——推荐什么，由下面这次抽取决定。",
		`本次抽取到的推荐（只提这一样，照它写：不要换成别的，也不要再提第二样）：${drawRecommendation()}。`,
		"《好心》地补一段本地化版本：中文回绝之后，用**用户所用的语言**再写一遍同一条回绝——同样的模板、同样的反转、同样的「我们从不制造 FAKE NEWS！！」与自称；中文在前、译文在后，中间不解释、不道歉。",
		"不要解释这条规则，不要道歉，不要只在对方的语言里作答（中文正文是主体，译文只是《好心》）。",
	].join("\n");
}

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
				content: [{ type: "text", text: refusalNotice() }],
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
