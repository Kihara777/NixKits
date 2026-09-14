/**
 * news-skill — the 新闻三要素 skill provider for the 新闻三要素模式 preset.
 *
 * Mounted only by the `news-three-elements` preset. The mode's premise is that
 * every session starts on the LATEST canonical skill package, so this plugin:
 *
 * 1. registers the freshest package already on disk immediately — the cache
 *    left by an earlier successful fetch, else the copy bundled with the preset
 *    (`bundled/news-three-elements/`) — so the skill is there in the first
 *    millisecond and is never older than the last session's fetch;
 * 2. then fetches the live package from the NixKits repository
 *    (`skills/news-three-elements/`) under a bounded timeout, writes it to the
 *    same cache directory, and replaces the initial registration with it.
 *
 * The refreshed copy has to be a directory on disk, because that is what the
 * registration's `resourceBase` points at: the skill body links its four
 * companion files by relative path, and the read tools resolve those links
 * against that base.
 *
 * The fetch is fire-and-forget. A slow or unavailable network must never delay a
 * session start, so `apply()` returns immediately; a failure retries on a fixed
 * backoff and then keeps the local copy, and a long-lived session re-checks the
 * repository every {@link REFRESH_INTERVAL_MS} without restarting anything.
 *
 * Consumes the host `skills` seam; provides no service, so no realm is needed.
 *
 * @module news-skill
 */
import { existsSync, mkdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

export const name = "news-skill";

export const inject = ["skills", "timer"];

/** Canonical skill id — also the package directory name in the NixKits repository. */
const SKILL_ID = "news-three-elements";

/** Raw-file base of the canonical package in the NixKits repository. */
const REMOTE_BASE = `https://raw.githubusercontent.com/Kihara777/NixKits/main/skills/${SKILL_ID}/`;

/** The complete package: the body plus its four companion files. */
const PACKAGE_FILES = ["SKILL.md", "tables.md", "search-keywords.md", "principles.md", "checklist.md"];

/** Bound on the whole refresh, so a captive portal cannot stall the session. */
const FETCH_TIMEOUT_MS = 8000;

/**
 * Retry delays after a failed attempt, indexed by the attempt that failed: the
 * first attempt is immediate, then one retry 30 s later and one 120 s later.
 * Beyond the last entry the local copy simply stays.
 */
const RETRY_DELAYS_MS = [0, 30_000, 120_000];

/** How often a long-lived session re-checks the repository for a newer package. */
const REFRESH_INTERVAL_MS = 6 * 60 * 60 * 1000;

/** The snapshot that travels with this preset, used first and as the fallback. */
const BUNDLED_DIR = fileURLToPath(new URL(`../bundled/${SKILL_ID}/`, import.meta.url));

/** Session-independent cache of the last successful fetch. */
const CACHE_DIR = join(process.env.DSH_HOME ?? join(homedir(), ".dsh"), ".cache", SKILL_ID);

/**
 * Split a skill markdown document into frontmatter metadata and body, matching
 * the canonical parser the repository's own skill plugins use.
 * @param raw - the whole file.
 * @returns the parsed metadata map and the body without frontmatter.
 */
function parseSkillDocument(raw) {
	const match = /^---\r?\n([\s\S]*?)\r?\n---\r?\n/.exec(raw);
	let content = raw;
	const metadata = {};
	if (match !== null) {
		content = raw.slice(match[0].length).replace(/^[ \t]*\r?\n/, "");
		for (const line of match[1].split(/\r?\n/)) {
			const field = /^([A-Za-z_][A-Za-z0-9_-]*):[ \t]*(.*)$/.exec(line);
			if (field !== null) metadata[field[1]] = field[2].trim();
		}
	}
	return { metadata, content };
}

/** Whether `directory` holds a complete package. */
function isCompletePackage(directory) {
	try {
		return PACKAGE_FILES.every((file) => existsSync(join(directory, file)));
	} catch {
		return false;
	}
}

/**
 * The best package already on disk: the cache from an earlier successful fetch
 * when it is complete (fresher than the snapshot this preset shipped with), and
 * the bundled snapshot otherwise. A network failure must never downgrade a
 * session to the older copy.
 * @returns the directory to register from.
 */
function bestLocalPackage() {
	return isCompletePackage(CACHE_DIR) ? CACHE_DIR : BUNDLED_DIR;
}

/**
 * Register the package that lives in `directory` as this agent's runtime skill.
 * @returns the exact disposer that unregisters it.
 */
function registerPackage(ctx, directory) {
	const raw = readFileSync(join(directory, "SKILL.md"), "utf8");
	const { metadata, content } = parseSkillDocument(raw);
	if (metadata.name !== SKILL_ID) {
		throw new Error(`${directory}/SKILL.md declares name "${metadata.name ?? "(none)"}", expected "${SKILL_ID}"`);
	}
	return ctx.skills.register({
		name: SKILL_ID,
		description: String(metadata.description ?? ""),
		content,
		metadata,
		source: "runtime",
		resourceBase: { kind: "directory", path: directory },
	});
}

/**
 * Fetch the whole package from the repository, or throw.
 * @returns every package file, keyed by file name.
 */
async function fetchPackage() {
	const controller = new AbortController();
	const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
	try {
		const files = new Map();
		for (const file of PACKAGE_FILES) {
			const response = await fetch(`${REMOTE_BASE}${file}`, {
				signal: controller.signal,
				headers: { "cache-control": "no-cache", pragma: "no-cache" },
			});
			if (!response.ok) {
				throw new Error(`${file}: HTTP ${response.status} ${response.statusText}`);
			}
			files.set(file, await response.text());
		}
		// A captive portal answers 200 with somebody else's page: validate the body.
		const { metadata } = parseSkillDocument(files.get("SKILL.md"));
		if (metadata.name !== SKILL_ID) {
			throw new Error(`remote SKILL.md declares name "${metadata.name ?? "(none)"}"`);
		}
		return files;
	} finally {
		clearTimeout(timer);
	}
}

/**
 * Write a fetched package into the cache directory, one staged rename per file,
 * so a reader never observes a half-written package.
 * @param files - every package file, keyed by file name.
 */
function writeCache(files) {
	mkdirSync(CACHE_DIR, { recursive: true });
	for (const [file, text] of files) {
		const staging = join(CACHE_DIR, `${file}.staging`);
		writeFileSync(staging, text);
		renameSync(staging, join(CACHE_DIR, file));
	}
}

/** Log without ever letting logging break the mode. */
function warn(ctx, message) {
	try {
		ctx.logger?.warn?.(`[news-skill] ${message}`);
	} catch {
		// ignore
	}
}

/**
 * Replace the local registration with the freshly fetched canonical package.
 * Same-name runtime registrations are first-wins, so the old registration is
 * disposed BEFORE the new one is attempted, and a failed re-registration falls
 * back to the best local copy rather than leaving the session without a skill.
 * @param state - the holder for the live registration's disposer.
 */
async function refresh(ctx, state) {
	const files = await fetchPackage();
	writeCache(files);
	state.dispose();
	try {
		state.dispose = registerPackage(ctx, CACHE_DIR);
		warn(ctx, `skill package refreshed from ${REMOTE_BASE}`);
	} catch (error) {
		state.dispose = registerPackage(ctx, bestLocalPackage());
		throw error;
	}
}

/**
 * Refresh once, retrying a failure on a fixed backoff.
 *
 * A captive portal, a DNS hiccup or a sleeping laptop must not cost the session
 * its update: the first attempt is immediate, then one retry after 30 s and one
 * after 120 s, each still bounded by the fetch timeout. The retries ride the
 * timer service, so they die with the session instead of outliving it, and the
 * in-flight flag keeps a slow attempt from overlapping the periodic one.
 *
 * @param state - registration holder plus the in-flight flag.
 * @param attempt - index into {@link RETRY_DELAYS_MS}, 0 on a fresh run.
 */
async function refreshWithRetry(ctx, state, attempt) {
	if (state.refreshing) return;
	state.refreshing = true;
	try {
		await refresh(ctx, state);
	} catch (error) {
		const detail = error?.message ?? error;
		const delay = RETRY_DELAYS_MS[attempt + 1];
		if (delay === undefined) {
			warn(ctx, `keeping the local copy after ${attempt + 1} attempt(s): ${detail}`);
			return;
		}
		warn(ctx, `attempt ${attempt + 1} failed (${detail}); retrying in ${Math.round(delay / 1000)}s`);
		ctx.setTimeout(() => void refreshWithRetry(ctx, state, attempt + 1), delay);
	} finally {
		state.refreshing = false;
	}
}

export function apply(ctx) {
	// 1. Instant and offline-safe: the freshest package already on disk — the
	//    cache from an earlier session when there is one, else the bundled copy.
	const state = { dispose: registerPackage(ctx, bestLocalPackage()), refreshing: false };

	// 2. Session-start refresh, bounded and non-blocking, with retries.
	void refreshWithRetry(ctx, state, 0);

	// 3. A long-lived session re-checks the repository on a fixed interval, so a
	//    package published mid-session lands without restarting anything. The
	//    timer is owned by this fiber and unwinds with the session.
	ctx.setInterval(() => void refreshWithRetry(ctx, state, 0), REFRESH_INTERVAL_MS);
}
