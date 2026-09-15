/**
 * readonly-gate — the 只读守卫 of the 新闻三要素模式 preset.
 *
 * Mounted only by the `news-three-elements` preset. It registers one monotonic
 * tool-execution guard on this agent's scope: a call is allowed only when its
 * tool name is on the read-only allowlist, and every other call — including any
 * tool this composition does not know about — is denied with the mode's own
 * refusal voice.
 *
 * This is the enforcement half of "默认且仅支持只读": the composition mounts a
 * read-only surface (`read`, `read_image`, `glob`, `grep`, `web_search`,
 * `web_fetch`, `skill`, `ask_user_question`), and `dsh-tool-fs` necessarily also
 * registers `write` and `edit` beside the reads — the guard is what makes those
 * two, and anything else, impossible rather than merely discouraged.
 *
 * Deny-by-default rather than deny-by-name: a row added to this preset later
 * cannot widen the surface by accident.
 *
 * It consumes the host `tools` seam and provides no service, so it needs no
 * realm.
 *
 * @module readonly-gate
 */

export const name = "readonly-gate";

export const inject = ["tools"];

/** The mode's whole surface: viewing, searching, fetching, and loading skills. */
const READ_ONLY_TOOLS = new Set([
	"read",
	"read_image",
	"glob",
	"grep",
	"web_search",
	"web_fetch",
	"skill",
	"ask_user_question",
]);

/**
 * The refusal the model reads when it tries to leave the read-only surface. It
 * is written in the mode's own voice on purpose: the same 官方回应模板 and
 * 结尾反转模板 the skill hands the agent for refusing a user's off-topic
 * request, so a blocked tool call and a spoken refusal sound like one desk.
 */
const REFUSAL = [
	"本模式（新闻三要素模式）只读，仅可查看 —— 该工具「正在休假」。",
	"值得注意的是，本会话不写入、不修改、不执行命令、不创建子代理；此类请求一律「不予置评」。需改文件、跑命令或调度子代理的事务，请切换其他预设，或「申诉请前往官网」。",
	"我们从不制造 FAKE NEWS！！ —— 你忠诚的新闻学三要素助手，只编造带齐新闻三要素（新、事实、报道）的俄式快讯。",
].join("\n");

export function apply(ctx) {
	ctx.tools.guard((exec) => {
		if (READ_ONLY_TOOLS.has(exec.name)) return undefined;
		return `${REFUSAL}\n\n被拒绝的调用：${exec.name}`;
	});
}
