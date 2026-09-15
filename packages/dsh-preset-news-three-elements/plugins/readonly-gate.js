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
 * The view itself is scoped too: the read-side tools carry a path argument, and
 * an absolute path outside the session workspace, the attachment store and the
 * temp directory is refused as well. Relative paths are left to the filesystem
 * backend, which resolves them under the session root.
 *
 * It consumes the host `tools` seam and provides no service, so it needs no
 * realm.
 *
 * @module readonly-gate
 */
import { homedir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

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
	"我们从不制造 FAKE NEWS！！ —— 你忠诚的新闻学三要素助手，只编造带齐新闻三要素（巴兰尼科夫、尤丁采夫、布亚诺夫三位缺一不可）的催逝快讯。",
].join("\n");

/** Tools whose path argument is checked against the readable roots below. */
const PATH_ARGUMENTS = {
	read: "file_path",
	read_image: "file_path",
	glob: "path",
	grep: "path",
};

/**
 * The mode's own skill package: the fetched copy in the cache, and the snapshot
 * this preset ships for offline sessions. Both must stay readable — they are
 * what `read` is pointed at when the model opens `tables.md` or `checklist.md`,
 * and scoping them out made the mode narrate "配套文件读不到" instead.
 */
const SKILL_CACHE_DIR = join(process.env.DSH_HOME ?? join(homedir(), ".dsh"), ".cache", "news-three-elements");
const PRESET_ROOT = fileURLToPath(new URL("..", import.meta.url));

/**
 * Where the mode is allowed to look: the session's working directory, the
 * attachment store, the temp directory, and its own skill package (cache plus
 * the bundled snapshot). Paths are absolute in the args, so a relative path is
 * left to the filesystem backend, which resolves it under the session root.
 */
function readableRoots(exec) {
	const roots = [];
	try {
		const cwd = exec?.agent?.session?.header?.cwd;
		if (typeof cwd === "string" && cwd !== "") roots.push(cwd);
	} catch {
		// An unreadable session header simply drops the workspace root.
	}
	const home = process.env.DSH_HOME ?? join(homedir(), ".dsh");
	roots.push(join(home, "attachments"), "/tmp", SKILL_CACHE_DIR, PRESET_ROOT);
	return roots;
}

/** Whether `candidate` is inside one of `roots` (or is one of them). */
function within(candidate, roots) {
	return roots.some((root) => candidate === root || candidate.startsWith(root.endsWith("/") ? root : `${root}/`));
}

/**
 * The path the mode is not allowed to look at, or `undefined` when the call is
 * fine. Only absolute paths are judged: a relative one belongs to the session's
 * own root and the fs backend vets it.
 */
function outOfScopePath(exec) {
	const argument = PATH_ARGUMENTS[exec?.name];
	if (argument === undefined) return undefined;
	const value = exec?.arguments?.[argument];
	if (typeof value !== "string" || value === "" || !value.startsWith("/")) return undefined;
	return within(value, readableRoots(exec)) ? undefined : value;
}

export function apply(ctx) {
	ctx.tools.guard((exec) => {
		if (!READ_ONLY_TOOLS.has(exec.name)) {
			return `${REFUSAL}\n\n被拒绝的调用：${exec.name}`;
		}
		const denied = outOfScopePath(exec);
		if (denied !== undefined) {
			return `${REFUSAL}\n\n被拒绝的路径：${denied}（本模式只允许查看会话工作区、附件目录、/tmp 与自身技能包目录）`;
		}
		return undefined;
	});
}
