window.__ModuleLoader__.load({
	id: "@kihara777/dsh-api-balance",
	factory: (require) => {
		var module = { exports: {} };
		var exports = module.exports;
		Object.defineProperty(exports, Symbol.toStringTag, { value: "Module" });
		//#region lib/types/client/index.js
		/**
		 * api-balance — API 用量余额插件（浏览器端）。
		 *
		 * 目标控件：发送按钮左侧的「圆圈」上下文已用显示按钮（conversation
		 * 的 ContextMeter，硬编码在 InputBar 内、不在任何 slot 上）。本插件
		 * 在 `conversation.input.right` 注册视觉与行为完全兼容的替代圆圈，
		 * 挂载后把 DOM 节点移动到原 ContextMeter 的位置（原 root 之后），
		 * 并用 MutationObserver 保位（InputBar 重渲染重建 trailing 时自动
		 * 重新就位）——替代圆圈始终停在原位置。
		 *
		 * 弹出面板顶部带「用量 | 余额」标签切换：
		 *  - 「用量」（默认）= 原 ContextMeter 面板内容（上下文已用百分比、
		 *    占用条、系统提示词 / 工具 / 对话消息细分），数据源同为
		 *    `contextPressure` / `contextBreakdown` 投影；
		 *  - 「余额」= 当前 API KEY 的账户信息：
		 *      · 各币种总余额（接口返回什么币种就显示什么币种，不硬编码）
		 *      · 当日 / 当月 / 30 日内消耗：金额 + token（缓存命中/未命中/输出）
		 *      · 分模型 token 明细（30 日内，接口按模型返回时可得）
		 *    数据经 host 端 `api-balance/query` RPC 获取（同一 /api 通道）。
		 *
		 * 平台令牌两级获取（host 端实现，本端只渲染状态）：
		 *  - 自动：扫描本机浏览器 Local Storage LevelDB 提取并校验 userToken，
		 *    面板内「重新扫描本机浏览器」按钮强制重扫（rescanBrowsers）；
		 *  - 手动回退：一键授权（剪贴板回传命令）与手动输入令牌。
		 * 连接成功后显示令牌来源徽章（tokenSource: browser | manual）。
		 *
		 * 原 ContextMeter 按钮经 CSS 隐藏（结构选择器 + dsh 0.1.1-rc.2 的
		 * 构建类名双保险，`:not()` 排除替代按钮自身）。
		 *
		 * @module @kihara777/dsh-api-balance/client
		 */
		let react = require("react");
		let reactDOM = require("react-dom");
		let primitives = require("@deepseek-ai/dsh-client-ui-primitives");

		/** 本插件的 locale 命名空间（与包名一致，惯例同官方插件）。 */
		const NS = "@kihara777/dsh-api-balance";

		/** 面板标签页。 */
		const TAB_USAGE = "usage";
		const TAB_BALANCE = "balance";

		/** 环形几何（与原 ContextMeter 相同：14px viewBox、2px stroke）。 */
		const RADIUS = 5.5;
		const CIRCUMFERENCE = 2 * Math.PI * RADIUS;

		/** 数字 → 紧凑 token 文案（与原统计行同一量级习惯）。 */
		function formatTokens(n) {
			if (typeof n !== "number" || !Number.isFinite(n) || n < 0) return "0";
			if (n < 1_000) return String(n);
			if (n < 1_000_000) return `${(n / 1_000).toFixed(n < 10_000 ? 1 : 0)}k`;
			if (n < 1_000_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
			return `${(n / 1_000_000_000).toFixed(2)}B`;
		}

		/**
		 * 触屏设备检测（移动端浏览器无 DevTools 控制台，一键授权流程
		 * 不可用，改为手动令牌输入）。基于 pointer: coarse 媒体查询。
		 */
		function isTouchDevice() {
			if (typeof window === "undefined" || typeof window.matchMedia !== "function") return false;
			try {
				return window.matchMedia("(pointer: coarse)").matches;
			} catch {
				return "ontouchstart" in window && window.navigator.maxTouchPoints > 0;
			}
		}

		/** 语音提醒：余额低于该值（任意币种）视为「快没了」。 */
		const HUNGRY_LOW_THRESHOLD = 10;
		/** 语音提醒最小间隔（30 分钟），避免反复喊饿。 */
		const HUNGRY_SPEECH_INTERVAL_MS = 30 * 60 * 1000;
		/** 余额轮询间隔（15 分钟）：页面常驻期间自动检测余额。 */
		const HUNGRY_POLL_INTERVAL_MS = 15 * 60 * 1000;
		let lastHungrySpeechAt = 0;

		/** 页面刷新问候音效：每个页面加载（JS 上下文）只播一次，随机选一。 */
		let pageGreetingPlayed = false;
		/** TTS 问候语池（语音包无问候音频时随机取一条；语言跟随界面语言）。 */
		const GREETING_TTS_POOL = {
			"zh-CN": ["欢迎回来～", "主人，我在这儿哦！", "想我了吗？", "今天也要元气满满呀！", "我一直在等你回来。"],
			en: ["Welcome back!", "I'm here, master!", "Did you miss me?", "Let's have a great day!", "I've been waiting for you."],
		};

		/** 随机播放一个问候/放置音效：语音包 greetings 优先，无则 TTS 池。 */
		function playRandomGreeting(lang, ttsConfig, pack) {
			const greetings = pack !== null && typeof pack === "object" && Array.isArray(pack.greetings) ? pack.greetings : [];
			if (greetings.length > 0) {
				const pick = greetings[Math.floor(Math.random() * greetings.length)];
				if (pick !== null && typeof pick === "object" && typeof pick.url === "string") {
					stopActiveSpeech();
					playAudioSrc(pick.url).catch(() => {});
					return;
				}
			}
			const table = GREETING_TTS_POOL[lang] ?? GREETING_TTS_POOL["zh-CN"];
			stopActiveSpeech();
			ttsSpeak(table[Math.floor(Math.random() * table.length)], lang, ttsConfig).catch(() => {});
		}

		/** 语音提醒开关（localStorage 持久化，默认开启）。 */
		function speechEnabled() {
			if (typeof window === "undefined") return false;
			try {
				return window.localStorage.getItem("dsh-api-balance-speech") !== "off";
			} catch {
				return true;
			}
		}

		function setSpeechEnabled(enabled) {
			try {
				window.localStorage.setItem("dsh-api-balance-speech", enabled ? "on" : "off");
			} catch {
				// 存储不可用则本次会话生效
			}
		}

		// 预热语音引擎：触发浏览器加载语音列表（首次 getVoices 常为空，
		// 不预热会导致首次播报用默认音色甚至无声）。
		if (typeof window !== "undefined" && typeof window.speechSynthesis !== "undefined") {
			try {
				window.speechSynthesis.getVoices();
			} catch {
				// 无语音引擎时忽略
			}
		}

		/**
		 * 界面语言 id → speechSynthesis lang 标签。DSH 界面语言跟随
		 * LocaleFace 快照的 active（zh / en）；语音 lang 与音色选择同样
		 * 跟随——zh 映射为 zh-CN（与 locale 插件的 document lang 逻辑
		 * 一致），其余语言原样透传。
		 */
		function speechLang(localeId) {
			if (typeof localeId !== "string" || localeId.length === 0) return "zh-CN";
			const id = localeId.toLowerCase();
			return id === "zh" ? "zh-CN" : localeId;
		}

		/** 兜底 LocaleFace（稳定引用）：locale 服务不可用时按 zh 处理。 */
		const FALLBACK_LOCALE_SNAPSHOT = Object.freeze({ active: "zh" });
		const FALLBACK_LOCALE_FACE = {
			subscribe: () => () => {},
			getSnapshot: () => FALLBACK_LOCALE_SNAPSHOT,
		};

		// ── 语音引擎：Web Speech / 自定义 TTS（host 代理）+ 语音包拼接 ──
		const TTS_STORE_KEY = "dsh-api-balance-tts";
		const VOICEPACK_ENDPOINT = "/api/api-balance/voicepack";
		const TTS_PROXY_ENDPOINT = "/api/api-balance/tts";
		/** 语音包清单格式标识（host 端同样校验）。 */
		const VOICEPACK_FORMAT = "dsh-api-balance-voice-pack";

		/** TTS 配置读写（localStorage；每浏览器独立）。 */
		function readTtsConfig() {
			try {
				if (typeof window === "undefined") return { backend: "web", urlTemplate: "", method: "GET" };
				const raw = window.localStorage.getItem(TTS_STORE_KEY);
				if (raw !== null) {
					const value = JSON.parse(raw);
					if (value !== null && typeof value === "object") {
						return {
							backend: value.backend === "custom" ? "custom" : "web",
							urlTemplate: typeof value.urlTemplate === "string" ? value.urlTemplate : "",
							method: value.method === "POST" ? "POST" : "GET",
						};
					}
				}
			} catch {
				// 损坏配置回退默认
			}
			return { backend: "web", urlTemplate: "", method: "GET" };
		}

		function writeTtsConfig(config) {
			try {
				window.localStorage.setItem(TTS_STORE_KEY, JSON.stringify(config));
			} catch {
				// 存储不可用则本次会话生效
			}
		}

		/** 自定义 TTS URL 模板占位符替换（{text} / {lang} / {rate}）。 */
		function buildTtsUrl(template, text, lang) {
			return template
				.split("{text}")
				.join(encodeURIComponent(text))
				.split("{lang}")
				.join(encodeURIComponent(lang))
				.split("{rate}")
				.join("1.0");
		}

		/** 当前播放控制器：新播报开始前停止上一次（音频 / 合成）。 */
		let activeAudio = null;
		function stopActiveSpeech() {
			if (activeAudio !== null) {
				try {
					activeAudio.pause();
					activeAudio.src = "";
				} catch {
					// 忽略
				}
				activeAudio = null;
			}
			try {
				if (typeof window !== "undefined" && window.speechSynthesis !== void 0) window.speechSynthesis.cancel();
			} catch {
				// 忽略
			}
		}

		/** 播放一段音频（Promise 化；end/error 均视为完成）。 */
		function playAudioSrc(src) {
			return new Promise((resolve) => {
				try {
					const audio = new Audio(src);
					activeAudio = audio;
					const done = () => {
						if (activeAudio === audio) activeAudio = null;
						resolve();
					};
					audio.onended = done;
					audio.onerror = done;
					audio.play().catch(done);
				} catch {
					resolve();
				}
			});
		}

		/** 经 host 代理调用自定义 TTS 服务并播放返回音频。 */
		async function playCustomTts(text, lang, config) {
			const url = buildTtsUrl(config.urlTemplate, text, lang);
			if (url.length === 0) throw new Error("empty tts url");
			const response = await fetch(TTS_PROXY_ENDPOINT, {
				method: "POST",
				headers: { "content-type": "application/json" },
				body: JSON.stringify({ text, url, method: config.method }),
			});
			if (!response.ok) throw new Error(`tts proxy ${response.status}`);
			const blob = await response.blob();
			if (blob.size === 0) throw new Error("empty tts audio");
			const objectUrl = URL.createObjectURL(blob);
			try {
				await playAudioSrc(objectUrl);
			} finally {
				URL.revokeObjectURL(objectUrl);
			}
		}

		/** 用 Web Speech 朗读（Promise 化；兜底超时防 onend 不触发）。 */
		function playWebSpeech(text, lang) {
			return new Promise((resolve) => {
				try {
					if (typeof window === "undefined") {
						resolve();
						return;
					}
					const synth = window.speechSynthesis;
					if (synth === void 0) {
						resolve();
						return;
					}
					const utter = new SpeechSynthesisUtterance(text);
					utter.lang = lang;
					utter.rate = 1.05;
					utter.volume = 1;
					const voices = synth.getVoices();
					const prefix = lang.toLowerCase().split("-")[0];
					const preferred = voices.find((voice) => voice.lang.toLowerCase().startsWith(prefix));
					if (preferred !== void 0) utter.voice = preferred;
					let settled = false;
					const done = () => {
						if (!settled) {
							settled = true;
							resolve();
						}
					};
					utter.onend = done;
					utter.onerror = done;
					synth.cancel();
					synth.speak(utter);
					window.setTimeout(done, 60_000);
				} catch {
					resolve();
				}
			});
		}

		/** 合成并播放一段 TTS 文本（custom 失败时回落 Web Speech）。 */
		async function ttsSpeak(text, lang, config) {
			if (typeof text !== "string" || text.length === 0) return;
			if (config !== null && typeof config === "object" && config.backend === "custom" && config.urlTemplate.trim().length > 0) {
				try {
					await playCustomTts(text, lang, config);
					return;
				} catch {
					// custom 失败 → Web Speech 兜底
				}
			}
			await playWebSpeech(text, lang);
		}

		/**
		 * 按序播放片段列表。片段：
		 *  - { kind: "pack", key, fallbackText? }：语音包片段；缺省时
		 *    若有 fallbackText 则用 TTS 朗读兜底，否则跳过
		 *  - { kind: "tts", text }：动态数字/文本，走当前 TTS 后端合成
		 * 语音包片段支持两种载体：host 音频 URL（url）或 data URI（audio）。
		 */
		async function playParts(parts, lang, config, pack) {
			const segments = pack !== null && typeof pack === "object" && pack.segments !== null && typeof pack.segments === "object"
				? pack.segments
				: {};
			for (const part of parts) {
				if (part.kind === "pack") {
					const segment = segments[part.key];
					const src =
						segment !== null && typeof segment === "object"
							? typeof segment.url === "string" && segment.url.length > 0
								? segment.url
								: typeof segment.audio === "string" && segment.audio.length > 0
									? segment.audio
									: null
							: null;
					if (src !== null) {
						await playAudioSrc(src);
					} else if (typeof part.fallbackText === "string" && part.fallbackText.length > 0) {
						await ttsSpeak(part.fallbackText, lang, config);
					}
				} else {
					await ttsSpeak(part.text, lang, config);
				}
			}
		}

		/**
		 * 语音喊饿（自动播报；30 分钟限流 + 开关约束）。片段经拼接引擎
		 * 播放：语音包有对应片段则播包，否则 TTS 兜底整句。
		 */
		function speakHungry(parts, lang, config, pack) {
			try {
				if (typeof window === "undefined" || !speechEnabled()) return;
				const now = Date.now();
				if (now - lastHungrySpeechAt < HUNGRY_SPEECH_INTERVAL_MS) return;
				lastHungrySpeechAt = now;
				stopActiveSpeech();
				playParts(parts, lang, config, pack).catch(() => {});
			} catch {
				// 语音不可用时静默
			}
		}

		/** 手动播报（无开关/限流约束）。 */
		function speakNowParts(parts, lang, config, pack) {
			try {
				if (typeof window === "undefined") return;
				stopActiveSpeech();
				playParts(parts, lang, config, pack).catch(() => {});
			} catch {
				// 语音不可用时静默
			}
		}

		/** 语音包片段键（制作器按此清单逐段录制）。 */
		const VOICEPACK_SEGMENT_KEYS = ["dead", "low", "usage", "balance", "tokenUnit", "month", "suffix"];

		/** 制作器示例文本（随语音包语言选择变化；录制浮窗展示朗读用）。 */
		const VOICEPACK_SAMPLE_TEXTS = {
			"zh-CN": {
				dead: "余额不足啦，我快饿晕了，快喂我吃 token！",
				low: "token 快吃完了，记得喂我哦！",
				usage: "当前用量",
				balance: "当前余额",
				tokenUnit: "个 token",
				month: "当月",
				suffix: "以上。",
			},
			en: {
				dead: "Master, I'm out of tokens — please feed me!",
				low: "Tokens are running low, remember to feed me!",
				usage: "Current usage",
				balance: "Current balance",
				tokenUnit: "tokens",
				month: "this month",
				suffix: "That's all.",
			},
			ja: {
				dead: "残高がありません、お腹ペコペコです。トークンをちょうだい！",
				low: "トークンが残りわずかです。補充を忘れずに！",
				usage: "現在の使用量",
				balance: "現在の残高",
				tokenUnit: "トークン",
				month: "今月",
				suffix: "以上です。",
			},
		};

		/** 指定语言/片段键的示例文本（未知语言回退 zh-CN）。 */
		function sampleTextFor(lang, key) {
			const table = VOICEPACK_SAMPLE_TEXTS[lang] ?? VOICEPACK_SAMPLE_TEXTS["zh-CN"];
			return typeof table[key] === "string" ? table[key] : key;
		}

		// ── zip 打包（STORE 方式，浏览器侧导出语音包用）────────────
		const CRC32_TABLE = (() => {
			const table = new Uint32Array(256);
			for (let i = 0; i < 256; i++) {
				let c = i;
				for (let k = 0; k < 8; k++) c = (c & 1) !== 0 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
				table[i] = c >>> 0;
			}
			return table;
		})();

		function crc32(bytes) {
			let crc = 0xffffffff;
			for (let i = 0; i < bytes.length; i++) crc = CRC32_TABLE[(crc ^ bytes[i]) & 0xff] ^ (crc >>> 8);
			return (crc ^ 0xffffffff) >>> 0;
		}

		/** entries: [{ name, data: Uint8Array }] → STORE 方式 zip 字节。 */
		function buildZip(entries) {
			const encoder = new TextEncoder();
			const chunks = [];
			const central = [];
			let offset = 0;
			for (const entry of entries) {
				const nameBytes = encoder.encode(entry.name);
				const data = entry.data;
				const crc = crc32(data);
				const local = new Uint8Array(30 + nameBytes.length);
				const lv = new DataView(local.buffer);
				lv.setUint32(0, 0x04034b50, true);
				lv.setUint16(4, 20, true);
				lv.setUint16(6, 0, true);
				lv.setUint16(8, 0, true);
				lv.setUint16(10, 0, true);
				lv.setUint16(12, 0, true);
				lv.setUint32(14, crc, true);
				lv.setUint32(18, data.length, true);
				lv.setUint32(22, data.length, true);
				lv.setUint16(26, nameBytes.length, true);
				lv.setUint16(28, 0, true);
				local.set(nameBytes, 30);
				chunks.push(local, data);
				const cd = new Uint8Array(46 + nameBytes.length);
				const cv = new DataView(cd.buffer);
				cv.setUint32(0, 0x02014b50, true);
				cv.setUint16(4, 20, true);
				cv.setUint16(6, 20, true);
				cv.setUint16(8, 0, true);
				cv.setUint16(10, 0, true);
				cv.setUint16(12, 0, true);
				cv.setUint16(14, 0, true);
				cv.setUint32(16, crc, true);
				cv.setUint32(20, data.length, true);
				cv.setUint32(24, data.length, true);
				cv.setUint16(28, nameBytes.length, true);
				cv.setUint16(30, 0, true);
				cv.setUint16(32, 0, true);
				cv.setUint16(34, 0, true);
				cv.setUint16(36, 0, true);
				cv.setUint32(38, 0, true);
				cv.setUint32(42, offset, true);
				cd.set(nameBytes, 46);
				central.push(cd);
				offset += local.length + data.length;
			}
			const cdStart = offset;
			let cdTotal = 0;
			for (const c of central) cdTotal += c.length;
			const cdBytes = new Uint8Array(cdTotal);
			let p = 0;
			for (const c of central) {
				cdBytes.set(c, p);
				p += c.length;
			}
			chunks.push(cdBytes);
			const eocd = new Uint8Array(22);
			const ev = new DataView(eocd.buffer);
			ev.setUint32(0, 0x06054b50, true);
			ev.setUint16(8, entries.length, true);
			ev.setUint16(10, entries.length, true);
			ev.setUint32(12, cdBytes.length, true);
			ev.setUint32(16, cdStart, true);
			chunks.push(eocd);
			let total = 0;
			for (const c of chunks) total += c.length;
			const out = new Uint8Array(total);
			p = 0;
			for (const c of chunks) {
				out.set(c, p);
				p += c.length;
			}
			return out;
		}

		/** 余额 → 饥饿状态：dead（不可用）/ low（低于阈值）/ ok。 */
		function hungryState(balance) {
			if (balance === null || typeof balance !== "object") return "ok";
			if (balance.isAvailable === false) return "dead";
			const infos = Array.isArray(balance.balanceInfos) ? balance.balanceInfos : [];
			for (const info of infos) {
				const total = Number.parseFloat(info.totalBalance);
				if (Number.isFinite(total) && total < HUNGRY_LOW_THRESHOLD) return "low";
			}
			return "ok";
		}

		/** 根据饥饿状态播报对应文案（限流；语言/音色/TTS 后端随配置）。 */
		function announceHunger(t, balance, lang, config, pack) {
			const state = hungryState(balance);
			if (state === "dead") {
				speakHungry([{ kind: "pack", key: "dead", fallbackText: t("speech.dead") }], lang, config, pack);
			} else if (state === "low") {
				speakHungry([{ kind: "pack", key: "low", fallbackText: t("speech.low") }], lang, config, pack);
			}
		}

		/** 金额文案：两位小数（万分之一精度的小额不显示成 0.00）。 */
		function formatCost(n) {
			if (typeof n !== "number" || !Number.isFinite(n) || n < 0) return "0.00";
			if (n !== 0 && n < 0.01) return n.toFixed(4);
			return n.toFixed(2);
		}

		/**
		 * 复刻 conversation 的 contextOccupancy：projectedTokens（回退
		 * pressureTokens）/ contextWindow → 占用百分比与分子分母；两个值
		 * 都未知时返回 null（与原圆圈相同的「无数据不渲染」语义）。
		 */
		function contextOccupancy(pressure) {
			const usedTokens = pressure?.projectedTokens ?? pressure?.pressureTokens;
			if (usedTokens === void 0 || pressure?.contextWindow === void 0) return null;
			return {
				percent: Math.min(100, Math.round((usedTokens / pressure.contextWindow) * 100)),
				usedTokens,
				contextWindow: pressure.contextWindow,
			};
		}

		/** 面板用量图例行（键序、文案、色调与原 ContextMeter ROWS 一致）。 */
		const USAGE_ROWS = [
			{ key: "systemTokens", label: "usage.system", tint: "var(--dsw-static-neutral-bluish-400)" },
			{ key: "toolsTokens", label: "usage.tools", tint: "#a78bfa" },
			{ key: "messageTokens", label: "usage.messages", tint: "var(--dsw-static-blue-450)" },
		];

		/**
		 * 查找原 ContextMeter 的 root 节点（用于 DOM 就位）。首选 dsh
		 * 0.1.1-rc.2 的构建类名，回退结构查找（内嵌 14px ring 且不带本插件
		 * 标记的 dialog 按钮向上找 inline-flex relative 祖先）。
		 */
		function findOriginalMeterRoot() {
			if (typeof document === "undefined") return null;
			const byClass = document.querySelector(".JObwrW_root");
			if (byClass !== null) return byClass;
			const trigger = document.querySelector('button[aria-haspopup="dialog"]:not([data-dsh-api-balance]) > svg[viewBox="0 0 14 14"]');
			if (trigger !== null) {
				let node = trigger.parentElement;
				while (node !== null && node !== document.body) {
					const style = window.getComputedStyle(node);
					if (style.position === "relative" && style.display === "inline-flex") return node;
					node = node.parentElement;
				}
			}
			return null;
		}

		/**
		 * 分模型堆叠柱状图（SVG）。series 为 host 端 fold 的
		 * { daily: [{date, models:[{model, cost}]}], monthly: [...] }；
		 * mode 切换按日 / 按月视图。柱高按金额比例，段色按模型名稳定分配。
		 */
		function UsageChart({ t, series, mode, onModeChange, width }) {
			const points = Array.isArray(mode === "daily" ? series.daily : series.monthly)
				? mode === "daily"
					? series.daily
					: series.monthly
				: [];
			const labelOf = (point) => (mode === "daily" ? point.date.slice(5) : point.month.slice(5));
			const fullLabelOf = (point) => (mode === "daily" ? point.date : point.month);

			const modelSet = new Set();
			for (const point of points) for (const entry of point.models) modelSet.add(entry.model);
			const models = [...modelSet].sort();
			const palette = ["#5b8def", "#a78bfa", "#34d399", "#fbbf24", "#f87171", "#22d3ee", "#fb923c", "#a3b18a"];
			const colorOf = (model) => palette[models.indexOf(model) % palette.length];
			const totalOf = (point) => point.models.reduce((sum, entry) => sum + entry.cost, 0);
			const maxTotal = Math.max(1, ...points.map(totalOf));

			const W = width;
			const H = 92;
			const labelH = 14;
			const chartH = H - labelH;
			const step = points.length > 0 ? W / points.length : W;
			const barW = Math.max(2, step * 0.72);

			const rects = [];
			points.forEach((point, i) => {
				const x = i * step + (step - barW) / 2;
				let y = H - labelH;
				for (const entry of point.models) {
					const height = Math.max(1, (entry.cost / maxTotal) * (chartH - 2));
					y -= height;
					rects.push(
						react.createElement(
							"rect",
							{
								key: `${i}-${entry.model}`,
								x: x.toFixed(2),
								y: y.toFixed(2),
								width: barW.toFixed(2),
								height: height.toFixed(2),
								fill: colorOf(entry.model),
								rx: 1,
							},
							react.createElement("title", null, `${entry.model}\n${fullLabelOf(point)}\n${formatCost(entry.cost)}`),
						),
					);
				}
			});
			const xLabels = [];
			points.forEach((point, i) => {
				const show = mode === "daily" ? i % 5 === 0 || i === points.length - 1 : true;
				if (!show) return;
				xLabels.push(
					react.createElement(
						"text",
						{
							key: `x-${i}`,
							x: (i * step + step / 2).toFixed(2),
							y: H - 2,
							fontSize: 8,
							fill: "var(--dsw-alias-label-tertiary)",
							textAnchor: "middle",
						},
						labelOf(point),
					),
				);
			});

			const modeButton = (id, active) =>
				react.createElement(
					"button",
					{
						type: "button",
						onClick: () => onModeChange(id),
						style: {
							padding: "0 8px",
							borderRadius: "999px",
							cursor: "pointer",
							border: "1px solid var(--dsw-alias-separator-primary)",
							background: active ? "var(--dsw-alias-interactive-bg-hover)" : "transparent",
							color: active ? "var(--dsw-alias-label-secondary)" : "var(--dsw-alias-label-tertiary)",
							fontSize: "11px",
							lineHeight: "18px",
						},
					},
					id === "daily" ? t("chart.daily") : t("chart.monthly"),
				);

			return react.createElement(
				"div",
				{ style: { marginTop: "8px" } },
				react.createElement(
					"div",
					{ style: { display: "flex", alignItems: "center", gap: "8px" } },
					react.createElement(
						"span",
						{ style: { fontSize: "11px", color: "var(--dsw-alias-label-tertiary)" } },
						t("chart.title"),
					),
					react.createElement(
						"span",
						{ style: { marginLeft: "auto", display: "flex", gap: "4px" } },
						modeButton("daily", mode === "daily"),
						modeButton("monthly", mode === "monthly"),
					),
				),
				react.createElement(
					"svg",
					{ viewBox: `0 0 ${W} ${H}`, width: W, height: H, style: { display: "block", marginTop: "4px" } },
					rects,
					xLabels,
				),
				react.createElement(
					"div",
					{ style: { display: "flex", flexWrap: "wrap", gap: "4px 10px", marginTop: "6px" } },
					models.map((model) => {
						const total = points.reduce(
							(sum, point) => sum + (point.models.find((entry) => entry.model === model)?.cost ?? 0),
							0,
						);
						return react.createElement(
							"span",
							{
								key: model,
								style: {
									display: "inline-flex",
									alignItems: "center",
									gap: "4px",
									fontSize: "10px",
									lineHeight: "14px",
									color: "var(--dsw-alias-label-tertiary)",
								},
							},
							react.createElement("i", {
								"aria-hidden": true,
								style: {
									width: "8px",
									height: "8px",
									borderRadius: "2px",
									background: colorOf(model),
									display: "inline-block",
								},
							}),
							`${model.length > 0 ? model : t("balance.allModels")} ${formatCost(total)}`,
						);
					}),
				),
			);
		}

		/**
		 * 充值 IFRAME 居中弹窗：全屏遮罩 + 居中容器，右上角关闭按钮，
		 * 内嵌 platform.deepseek.com/top_up（不跳转页面）。经 portal 挂到
		 * document.body，避免被 InputBar 的层叠上下文裁剪。底部附「在新
		 * 窗口打开」备用链接（平台若阻止内嵌时仍可完成充值）。
		 */
		function TopupModal({ t, onClose }) {
			// 遮罩点击关闭；容器内点击不冒泡。
			const overlayStyle = {
				position: "fixed",
				inset: 0,
				zIndex: 1000,
				background: "rgba(0, 0, 0, 0.5)",
				display: "flex",
				alignItems: "center",
				justifyContent: "center",
				padding: "16px",
			};
			const boxStyle = {
				position: "relative",
				width: "min(420px, 94vw)",
				background: "var(--dsw-specific-menu)",
				border: "1px solid var(--dsw-alias-border-inverted)",
				borderRadius: "12px",
				boxShadow: "var(--dsw-shadow-lv3)",
				display: "flex",
				flexDirection: "column",
				overflow: "hidden",
			};
			const closeStyle = {
				position: "absolute",
				top: "8px",
				right: "8px",
				zIndex: 2,
				width: "28px",
				height: "28px",
				display: "grid",
				placeItems: "center",
				border: "none",
				borderRadius: "999px",
				cursor: "pointer",
				background: "var(--dsw-alias-interactive-bg-hover)",
				color: "var(--dsw-alias-label-secondary)",
				fontSize: "14px",
				lineHeight: 1,
			};
			const openTopup = () => {
				window.open("https://platform.deepseek.com/top_up", "_blank", "noopener");
			};
			return reactDOM.createPortal(
				react.createElement(
					"div",
					{
						role: "dialog",
						"aria-modal": true,
						"aria-label": t("balance.topupTitle"),
						style: overlayStyle,
						onClick: onClose,
					},
					react.createElement(
						"div",
						{ style: boxStyle, onClick: (event) => event.stopPropagation() },
						react.createElement(
							"div",
							{
								style: {
									display: "flex",
									alignItems: "center",
									gap: "8px",
									padding: "12px 40px 12px 16px",
									fontSize: "14px",
									fontWeight: 600,
									color: "var(--dsw-alias-label-primary)",
								},
							},
							t("balance.topupTitle"),
						),
						react.createElement(
							"button",
							{ type: "button", "aria-label": t("balance.topupClose"), style: closeStyle, onClick: onClose },
							"✕",
						),
						react.createElement(
							"p",
							{
								style: {
									margin: 0,
									padding: "0 16px 4px",
									fontSize: "12px",
									lineHeight: "18px",
									color: "var(--dsw-alias-label-tertiary)",
								},
							},
							t("balance.topupNote"),
						),
						react.createElement(
							"div",
							{ style: { display: "flex", gap: "8px", padding: "8px 16px 16px" } },
							react.createElement(
								"button",
								{
									type: "button",
									onClick: openTopup,
									style: {
										flex: 1,
										padding: "7px 16px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-brand-primary, #4d6bfe)",
										background: "var(--dsw-alias-brand-primary, #4d6bfe)",
										color: "#fff",
										fontSize: "13px",
										lineHeight: "20px",
									},
								},
								t("balance.topupOpenButton"),
							),
							react.createElement(
								"button",
								{
									type: "button",
									onClick: onClose,
									style: {
										padding: "7px 16px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: "transparent",
										color: "var(--dsw-alias-label-secondary)",
										fontSize: "13px",
										lineHeight: "20px",
									},
								},
								t("balance.topupClose"),
							),
						),
					),
				),
				document.body,
			);
		}

		/**
		 * 平台未登录提示弹窗：本机浏览器扫描未命中有效令牌时自动弹出。
		 * 「前往登录」在新标签页打开平台登录页并开始轮询快扫；「手动输入
		 * 令牌」关闭弹窗并展开面板内的手动输入表单（不想登录时的备选）。
		 */
		function LoginPromptModal({ t, waiting, onClose, onGoLogin, onManual }) {
			const overlayStyle = {
				position: "fixed",
				inset: 0,
				zIndex: 1001,
				background: "rgba(0, 0, 0, 0.5)",
				display: "flex",
				alignItems: "center",
				justifyContent: "center",
				padding: "16px",
			};
			const boxStyle = {
				position: "relative",
				width: "min(420px, 94vw)",
				background: "var(--dsw-specific-menu)",
				border: "1px solid var(--dsw-alias-border-inverted)",
				borderRadius: "12px",
				boxShadow: "var(--dsw-shadow-lv3)",
				display: "flex",
				flexDirection: "column",
				overflow: "hidden",
			};
			const closeStyle = {
				position: "absolute",
				top: "8px",
				right: "8px",
				zIndex: 2,
				width: "28px",
				height: "28px",
				display: "grid",
				placeItems: "center",
				border: "none",
				borderRadius: "999px",
				cursor: "pointer",
				background: "var(--dsw-alias-interactive-bg-hover)",
				color: "var(--dsw-alias-label-secondary)",
				fontSize: "14px",
				lineHeight: 1,
			};
			return reactDOM.createPortal(
				react.createElement(
					"div",
					{
						role: "dialog",
						"aria-modal": true,
						"aria-label": t("balance.loginPromptTitle"),
						style: overlayStyle,
						onClick: onClose,
					},
					react.createElement(
						"div",
						{ style: boxStyle, onClick: (event) => event.stopPropagation() },
						react.createElement(
							"div",
							{
								style: {
									display: "flex",
									alignItems: "center",
									gap: "8px",
									padding: "12px 40px 12px 16px",
									fontSize: "14px",
									fontWeight: 600,
									color: "var(--dsw-alias-label-primary)",
								},
							},
							t("balance.loginPromptTitle"),
						),
						react.createElement(
							"button",
							{ type: "button", "aria-label": t("balance.topupClose"), style: closeStyle, onClick: onClose },
							"✕",
						),
						react.createElement(
							"p",
							{
								style: {
									margin: 0,
									padding: "0 16px 4px",
									fontSize: "12px",
									lineHeight: "18px",
									color: "var(--dsw-alias-label-tertiary)",
								},
							},
							waiting ? t("balance.loginWaiting") : t("balance.loginPromptBody"),
						),
						react.createElement(
							"div",
							{ style: { display: "flex", gap: "8px", padding: "8px 16px 16px", flexWrap: "wrap" } },
							react.createElement(
								"button",
								{
									type: "button",
									disabled: waiting,
									onClick: () => (waiting ? void 0 : onGoLogin()),
									style: {
										flex: 1,
										minWidth: "120px",
										padding: "7px 16px",
										borderRadius: "999px",
										cursor: waiting ? "default" : "pointer",
										border: "1px solid var(--dsw-alias-brand-primary, #4d6bfe)",
										background: "var(--dsw-alias-brand-primary, #4d6bfe)",
										color: "#fff",
										fontSize: "13px",
										lineHeight: "20px",
										opacity: waiting ? 0.6 : 1,
									},
								},
								t("balance.loginGo"),
							),
							react.createElement(
								"button",
								{
									type: "button",
									onClick: onManual,
									style: {
										padding: "7px 16px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: "transparent",
										color: "var(--dsw-alias-label-secondary)",
										fontSize: "13px",
										lineHeight: "20px",
									},
								},
								t("balance.manualFallback"),
							),
							react.createElement(
								"button",
								{
									type: "button",
									onClick: onClose,
									style: {
										padding: "7px 16px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: "transparent",
										color: "var(--dsw-alias-label-secondary)",
										fontSize: "13px",
										lineHeight: "20px",
									},
								},
								t("balance.loginClose"),
							),
						),
					),
				),
				document.body,
			);
		}

		/**
		 * 语音设置弹窗：自动播报开关、TTS 后端（浏览器内置 / 自定义 API
		 * 经 host 代理）、语音包 zip 导入 / 试听 / 清除，以及浏览器录音
		 * 制作语音包并打包下载分享。
		 */
		/**
		 * 语音设置弹窗（三视图）：
		 *  - main：自动播报开关、TTS 后端、语音包行（当前激活 + 导入 + 一个「语音包管理」按钮）
		 *  - packs：语音包库（可滚动列表：点击切换激活、勾选多选移除、进入制作器）
		 *  - creator：制作语音包（语言选择 → 示例文本变化；逐段录音/导入；编译下载/应用）
		 */
		function VoiceSettingsModal({
			t,
			autoOn,
			onToggleAuto,
			ttsCfg,
			onTtsChange,
			packs,
			activeId,
			packBusy,
			packMessage,
			onImportFile,
			onActivate,
			onRemovePacks,
			onTestPack,
			onTestTts,
			recordings,
			recordingKey,
			onStartRecording,
			onStopRecording,
			onPlayRecording,
			onDeleteRecording,
			onImportSegmentFile,
			onCompileInstall,
			editConfirmOpen,
			onConfirmEdit,
			onCancelEdit,
			packNameInput,
			onPackNameInput,
			packLangInput,
			onPackLangInput,
			onDownloadPack,
			onClose,
		}) {
			const [viewMode, setViewMode] = react.useState("main");
			const [selectedIds, setSelectedIds] = react.useState([]);
			const overlayStyle = {
				position: "fixed",
				inset: 0,
				zIndex: 1003,
				background: "rgba(0, 0, 0, 0.5)",
				display: "flex",
				alignItems: "center",
				justifyContent: "center",
				padding: "16px",
			};
			const boxStyle = {
				position: "relative",
				width: "min(520px, 94vw)",
				maxHeight: "80vh",
				overflowY: "auto",
				background: "var(--dsw-specific-menu)",
				border: "1px solid var(--dsw-alias-border-inverted)",
				borderRadius: "12px",
				boxShadow: "var(--dsw-shadow-lv3)",
				display: "flex",
				flexDirection: "column",
			};
			const closeStyle = {
				position: "absolute",
				top: "8px",
				right: "8px",
				zIndex: 2,
				width: "28px",
				height: "28px",
				display: "grid",
				placeItems: "center",
				border: "none",
				borderRadius: "999px",
				cursor: "pointer",
				background: "var(--dsw-alias-interactive-bg-hover)",
				color: "var(--dsw-alias-label-secondary)",
				fontSize: "14px",
				lineHeight: 1,
			};
			const sectionStyle = { margin: "10px 16px 0" };
			const labelStyle = { fontSize: "11px", lineHeight: "16px", color: "var(--dsw-alias-label-tertiary)", margin: 0 };
			const pillStyle = (active) => ({
				padding: "3px 12px",
				borderRadius: "999px",
				cursor: "pointer",
				border: "1px solid var(--dsw-alias-separator-primary)",
				background: active ? "var(--dsw-alias-interactive-bg-hover)" : "transparent",
				color: active ? "var(--dsw-alias-label-secondary)" : "var(--dsw-alias-label-tertiary)",
				fontSize: "12px",
				lineHeight: "20px",
			});
			const inputStyle = {
				flex: 1,
				minWidth: 0,
				padding: "4px 8px",
				borderRadius: "8px",
				border: "1px solid var(--dsw-alias-border-l3)",
				background: "var(--dsw-alias-bg-layer-2, transparent)",
				color: "var(--dsw-alias-label-primary)",
				fontSize: "12px",
				lineHeight: "18px",
			};
			const activePack = Array.isArray(packs) ? packs.find((pack) => pack.id === activeId) ?? null : null;
			const recordedCount = recordings !== null && typeof recordings === "object" ? Object.keys(recordings).length : 0;
			const sampleOf = (key) => {
				const table = VOICEPACK_SAMPLE_TEXTS[packLangInput] ?? VOICEPACK_SAMPLE_TEXTS["zh-CN"];
				return typeof table[key] === "string" ? table[key] : key;
			};
			const packRow = (pack) =>
				react.createElement(
					"div",
					{
						key: pack.id,
						style: {
							display: "flex",
							gap: "8px",
							alignItems: "center",
							padding: "5px 8px",
							borderRadius: "8px",
							cursor: "pointer",
							background: pack.id === activeId ? "var(--dsw-alias-interactive-bg-hover)" : "transparent",
						},
						onClick: () => onActivate(pack.id),
					},
					react.createElement("input", {
						type: "checkbox",
						checked: selectedIds.includes(pack.id),
						onClick: (event) => event.stopPropagation(),
						onChange: (event) => {
							setSelectedIds((current) =>
								event.target.checked ? [...current, pack.id] : current.filter((id) => id !== pack.id),
							);
						},
					}),
					react.createElement(
						"span",
						{
							style: {
								flex: 1,
								minWidth: 0,
								overflow: "hidden",
								textOverflow: "ellipsis",
								whiteSpace: "nowrap",
								fontSize: "12px",
								lineHeight: "18px",
								color: "var(--dsw-alias-label-secondary)",
							},
						},
						pack.name,
					),
					react.createElement(
						"span",
						{ style: { fontSize: "11px", lineHeight: "16px", color: "var(--dsw-alias-label-tertiary)" } },
						pack.lang,
					),
					pack.id === activeId
						? react.createElement(
								"span",
								{ style: { fontSize: "11px", lineHeight: "16px", color: "var(--dsw-alias-brand-primary, #4d6bfe)" } },
								t("voice.activeMark"),
							)
						: null,
				);
			const backButton = (mode) =>
				react.createElement(
					"button",
					{ type: "button", onClick: () => setViewMode(mode), style: { ...pillStyle(false), marginTop: "6px" } },
					t("voice.back"),
				);
			return reactDOM.createPortal(
				react.createElement(
					"div",
					{ role: "dialog", "aria-modal": true, "aria-label": t("voice.title"), style: overlayStyle, onClick: onClose },
					react.createElement(
						"div",
						{ style: boxStyle, onClick: (event) => event.stopPropagation() },
						react.createElement(
							"div",
							{
								style: {
									display: "flex",
									alignItems: "center",
									gap: "8px",
									padding: "12px 40px 12px 16px",
									fontSize: "14px",
									fontWeight: 600,
									color: "var(--dsw-alias-label-primary)",
								},
							},
							viewMode === "main" ? t("voice.title") : viewMode === "packs" ? t("voice.packListTitle") : t("voice.recorderLabel"),
						),
						react.createElement(
							"button",
							{ type: "button", "aria-label": t("voice.close"), style: closeStyle, onClick: onClose },
							"✕",
						),
						viewMode !== "main"
							? null
							: react.createElement(
									react.Fragment,
									null,
									// 自动播报开关
									react.createElement(
										"div",
										{ style: sectionStyle },
										react.createElement("p", { style: labelStyle }, t("voice.autoLabel")),
										react.createElement(
											"button",
											{
												type: "button",
												"aria-pressed": autoOn,
												onClick: onToggleAuto,
												style: { ...pillStyle(autoOn), marginTop: "4px" },
											},
											autoOn ? t("balance.speechOn") : t("balance.speechOff"),
										),
										react.createElement(
											"p",
											{ style: { ...labelStyle, marginTop: "4px" } },
											t("voice.greetingHint"),
										),
									),
									// TTS 后端
									react.createElement(
										"div",
										{ style: sectionStyle },
										react.createElement("p", { style: labelStyle }, t("voice.ttsBackend")),
										react.createElement(
											"div",
											{ style: { display: "flex", gap: "8px", marginTop: "4px" } },
											react.createElement(
												"button",
												{
													type: "button",
													onClick: () => onTtsChange({ ...ttsCfg, backend: "web" }),
													style: pillStyle(ttsCfg.backend === "web"),
												},
												t("voice.ttsWeb"),
											),
											react.createElement(
												"button",
												{
													type: "button",
													onClick: () => onTtsChange({ ...ttsCfg, backend: "custom" }),
													style: pillStyle(ttsCfg.backend === "custom"),
												},
												t("voice.ttsCustom"),
											),
											react.createElement(
												"button",
												{ type: "button", onClick: onTestTts, style: { ...pillStyle(false), marginLeft: "auto" } },
												t("voice.test"),
											),
										),
										ttsCfg.backend === "custom"
											? react.createElement(
													"div",
													{ style: { display: "flex", gap: "6px", marginTop: "6px", alignItems: "center" } },
													react.createElement("input", {
														type: "text",
														value: ttsCfg.urlTemplate,
														placeholder: t("voice.ttsUrlPlaceholder"),
														onChange: (event) => onTtsChange({ ...ttsCfg, urlTemplate: event.target.value }),
														style: inputStyle,
													}),
													react.createElement(
														"select",
														{
															value: ttsCfg.method,
															onChange: (event) => onTtsChange({ ...ttsCfg, method: event.target.value }),
															style: { ...inputStyle, flex: "0 0 auto" },
														},
														react.createElement("option", { value: "GET" }, "GET"),
														react.createElement("option", { value: "POST" }, "POST"),
													),
												)
											: react.createElement(
													"p",
													{ style: { ...labelStyle, marginTop: "4px" } },
													t("voice.ttsUrlHint"),
												),
									),
									// 语音包行：当前激活 + 导入 + 一个「语音包管理」按钮
									react.createElement(
										"div",
										{ style: { ...sectionStyle, marginBottom: "16px" } },
										react.createElement("p", { style: labelStyle }, t("voice.packLabel")),
										react.createElement(
											"div",
											{ style: { display: "flex", gap: "8px", alignItems: "center", marginTop: "4px", flexWrap: "wrap" } },
											react.createElement(
												"span",
												{
													style: {
														flex: 1,
														minWidth: 0,
														fontSize: "12px",
														lineHeight: "18px",
														color: activePack !== null ? "var(--dsw-alias-label-secondary)" : "var(--dsw-alias-label-tertiary)",
													},
												},
												activePack !== null
													? t("voice.packLoaded", { name: activePack.name, lang: activePack.lang })
													: t("voice.packNone"),
											),
											react.createElement("label", { style: pillStyle(false) },
												t("voice.packImport"),
												react.createElement("input", {
													type: "file",
													accept: ".zip,application/zip",
													disabled: packBusy,
													style: { display: "none" },
													onChange: (event) => {
														const file = event.target.files !== null ? event.target.files[0] : null;
														if (file !== null) onImportFile(file);
														event.target.value = "";
													},
												}),
											),
											react.createElement(
												"button",
												{ type: "button", onClick: () => setViewMode("packs"), style: pillStyle(true) },
												t("voice.manage"),
											),
										),
										packMessage !== ""
											? react.createElement(
													"p",
													{ style: { ...labelStyle, marginTop: "4px" } },
													packMessage,
												)
											: null,
									),
								),
						viewMode !== "packs"
							? null
							: react.createElement(
									react.Fragment,
									null,
									react.createElement(
										"div",
										{
											style: {
												...sectionStyle,
												maxHeight: "220px",
												overflowY: "auto",
												border: "1px solid var(--dsw-alias-separator-primary)",
												borderRadius: "8px",
												padding: "4px",
											},
										},
										Array.isArray(packs) && packs.length > 0
											? packs.map(packRow)
											: react.createElement(
													"p",
													{ style: { ...labelStyle, padding: "8px" } },
													t("voice.packNone"),
												),
									),
									react.createElement(
										"p",
										{ style: { ...labelStyle, marginTop: "4px" } },
										t("voice.packListHint"),
									),
									react.createElement(
										"div",
										{ style: { ...sectionStyle, marginBottom: "16px", display: "flex", gap: "8px", flexWrap: "wrap" } },
										react.createElement(
											"button",
											{
												type: "button",
												disabled: packBusy || selectedIds.length === 0,
												onClick: () => {
													onRemovePacks(selectedIds);
													setSelectedIds([]);
												},
												style: pillStyle(false),
											},
											t("voice.removeSelected"),
										),
										react.createElement(
											"button",
											{ type: "button", onClick: () => setViewMode("creator"), style: pillStyle(true) },
											t("voice.create"),
										),
										backButton("main"),
									),
								),
						viewMode !== "creator"
							? null
							: react.createElement(
									react.Fragment,
									null,
									editConfirmOpen
										? react.createElement(
												"div",
												{
													style: {
														display: "flex",
														gap: "8px",
														alignItems: "center",
														flexWrap: "wrap",
														margin: "10px 16px 0",
														padding: "6px 10px",
														borderRadius: "8px",
														border: "1px solid var(--dsw-alias-warning-primary, #e5a50a)",
														background: "var(--dsw-alias-bg-layer-2, transparent)",
													},
												},
												react.createElement(
													"span",
													{
														style: {
															flex: "1 1 100%",
															fontSize: "11px",
															lineHeight: "16px",
															color: "var(--dsw-alias-label-secondary)",
														},
													},
													t("voice.editWarn", { name: activePack?.name ?? "?" }),
												),
												react.createElement(
													"button",
													{ type: "button", onClick: onConfirmEdit, style: pillStyle(true) },
													t("voice.continue"),
												),
												react.createElement(
													"button",
													{ type: "button", onClick: onCancelEdit, style: pillStyle(false) },
													t("voice.cancel"),
												),
											)
										: null,
									react.createElement(
										"div",
										{ style: sectionStyle },
										react.createElement("p", { style: labelStyle }, t("voice.langLabel")),
										react.createElement(
											"select",
											{
												value: packLangInput,
												onChange: (event) => onPackLangInput(event.target.value),
												style: { ...inputStyle, marginTop: "4px", flex: "0 0 auto" },
											},
											Object.keys(VOICEPACK_SAMPLE_TEXTS).map((lang) =>
												react.createElement("option", { key: lang, value: lang }, lang),
											),
										),
										react.createElement(
											"div",
											{ style: { display: "flex", gap: "6px", marginTop: "6px", alignItems: "center" } },
											react.createElement("input", {
												type: "text",
												value: packNameInput,
												placeholder: t("voice.packNamePlaceholder"),
												onChange: (event) => onPackNameInput(event.target.value),
												style: { ...inputStyle, flex: "0 1 220px" },
											}),
											react.createElement(
												"button",
												{
													type: "button",
													disabled: recordedCount === 0,
													onClick: onDownloadPack,
													style: { ...pillStyle(false), marginLeft: "auto" },
												},
												t("voice.download"),
											),
											react.createElement(
												"button",
												{
													type: "button",
													disabled: recordedCount === 0 || packBusy,
													onClick: onCompileInstall,
													style: pillStyle(true),
												},
												t("voice.compileInstall"),
											),
										),
										react.createElement(
											"p",
											{ style: { ...labelStyle, marginTop: "4px" } },
											t("voice.recordHint"),
										),
										VOICEPACK_SEGMENT_KEYS.map((key) => {
											const rec = recordings[key];
											const isRecording = recordingKey === key;
											const canRecordOthers = recordingKey === null;
											return react.createElement(
												"div",
												{
													key,
													style: {
														display: "flex",
														gap: "8px",
														alignItems: "center",
														marginTop: "4px",
														flexWrap: "wrap",
													},
												},
												react.createElement(
													"span",
													{ style: { width: "96px", fontSize: "12px", lineHeight: "18px", color: "var(--dsw-alias-label-secondary)" } },
													t(`voice.seg.${key}`),
												),
												react.createElement(
													"span",
													{
														style: {
															flex: 1,
															minWidth: "120px",
															overflow: "hidden",
															textOverflow: "ellipsis",
															whiteSpace: "nowrap",
															fontSize: "11px",
															lineHeight: "16px",
															color: "var(--dsw-alias-label-tertiary)",
														},
													},
													`${t("voice.sampleText")}：${sampleOf(key)}`,
												),
												react.createElement(
													"button",
													{
														type: "button",
														disabled: !canRecordOthers,
														onClick: () => (isRecording ? onStopRecording(false) : onStartRecording(key)),
														style: pillStyle(isRecording),
													},
													isRecording ? t("voice.stop") : t("voice.record"),
												),
												react.createElement(
													"label",
													{ style: pillStyle(false) },
													t("voice.importFile"),
													react.createElement("input", {
														type: "file",
														accept: "audio/*,.mp3,.wav,.ogg,.webm,.m4a,.aac,.flac",
														style: { display: "none" },
														onChange: (event) => {
															const file = event.target.files !== null ? event.target.files[0] : null;
															if (file !== null) onImportSegmentFile(key, file);
															event.target.value = "";
														},
													}),
												),
												rec !== void 0
													? react.createElement(
															"button",
															{ type: "button", onClick: () => onPlayRecording(key), style: pillStyle(false) },
															t("voice.play"),
														)
													: null,
												rec !== void 0
													? react.createElement(
															"button",
															{ type: "button", onClick: () => onDeleteRecording(key), style: pillStyle(false) },
															t("voice.delete"),
														)
													: null,
												rec !== void 0
													? react.createElement(
															"span",
															{ style: { fontSize: "11px", lineHeight: "16px", color: "var(--dsw-alias-label-tertiary)" } },
															t("voice.recorded"),
														)
													: null,
											);
										}),
										backButton("packs"),
									),
							),
					),
				),
					document.body,
				);
			}		/**
		 * 替代圆圈组件。props 为框架标准 props（useProjection、t）+ 注册时
		 * inject 的 owner face（queryBalance、clearToken）。
		 */
		function ApiBalanceMeter({ useProjection, t, queryBalance, clearToken, localeFace }) {
			const pressure = useProjection("contextPressure");
			const breakdown = useProjection("contextBreakdown");
			// 当前界面语言（LocaleFace 快照的 active；播报语音 lang 与音色跟随）。
			// FALLBACK_LOCALE_FACE 提供稳定引用（getSnapshot 必须返回稳定对象，
			// 否则 useSyncExternalStore 会无限重渲染）。
			const face = localeFace !== null && typeof localeFace === "object" && localeFace !== void 0
				? localeFace
				: FALLBACK_LOCALE_FACE;
			const localeSnap = react.useSyncExternalStore(face.subscribe, face.getSnapshot);
			const uiLocale = speechLang(localeSnap?.active);
			const [open, setOpen] = react.useState(false);
			const [tab, setTab] = react.useState(TAB_USAGE);
			const [balance, setBalance] = react.useState(null);
			const [balanceState, setBalanceState] = react.useState("idle");
			// 授权流程状态机：idle | waiting（等待回传轮询中）| timeout
			const [connectState, setConnectState] = react.useState("idle");
			const pollRef = react.useRef(null);
			const rootRef = react.useRef(null);
			// 手动令牌输入（移动端主通道 / 桌面端备用通道）。
			const [manualOpen, setManualOpen] = react.useState(false);
			const [manualToken, setManualToken] = react.useState("");
			const [manualSaving, setManualSaving] = react.useState(false);
			// 用量图表：按日 / 按月。
			const [chartMode, setChartMode] = react.useState("daily");
			// 充值 IFRAME 弹窗。
			const [topupOpen, setTopupOpen] = react.useState(false);
			// 平台未登录提示弹窗：检测到 no-token 且浏览器扫描启用时自动弹出，
			// 用户关闭后不再自动弹出（面板内按钮仍可再次触发登录流程）。
			const [loginPromptDismissed, setLoginPromptDismissed] = react.useState(false);
			const touchDevice = isTouchDevice();
			const context = contextOccupancy(pressure);
			const available = context !== null;

			// 登录提示弹窗的判定条件（渲染返回在分支作用域之外，故提升到此）。
			const promptUsage = balance !== null && typeof balance === "object" ? balance.usage : null;
			const promptNoToken = promptUsage !== null && promptUsage.status === "no-token";
			const promptBrowserScan = promptUsage !== null && promptUsage.browserScanEnabled === true;
			const promptScanReport =
				promptUsage !== null && typeof promptUsage.scanReport === "object" && promptUsage.scanReport !== null
					? promptUsage.scanReport
					: null;
			const promptScanNotFound = promptScanReport !== null && promptScanReport.found !== true;

			// 面板外点击 / Escape 关闭（与原 ContextMeter 行为一致）。
			react.useEffect(() => {
				if (!open || !available) return;
				const onPointerDown = (e) => {
					if (e.target instanceof Node && rootRef.current?.contains(e.target) === true) return;
					setOpen(false);
				};
				const onKeyDown = (e) => {
					if (e.key === "Escape") setOpen(false);
				};
				document.addEventListener("pointerdown", onPointerDown);
				document.addEventListener("keydown", onKeyDown);
				return () => {
					document.removeEventListener("pointerdown", onPointerDown);
					document.removeEventListener("keydown", onKeyDown);
				};
			}, [available, open]);

			// DOM 就位：把本圆圈移动到原 ContextMeter 的位置（原 root 之后），
			// MutationObserver 保位（InputBar 重渲染重建 trailing 时重新就位）。
			react.useLayoutEffect(() => {
				const ours = rootRef.current;
				if (ours === null) return;
				let raf = 0;
				let observer = null;
				const place = () => {
					const original = findOriginalMeterRoot();
					if (original === null || original.parentElement === null) return;
					const parent = original.parentElement;
					if (ours.parentElement === parent && ours.previousSibling === original) return;
					parent.insertBefore(ours, original.nextSibling);
					if (observer !== null && observer.rootNode !== parent) {
						observer.disconnect();
						observer = null;
					}
					if (observer === null) {
						observer = new MutationObserver(() => {
							if (raf !== 0) return;
							raf = requestAnimationFrame(() => {
								raf = 0;
								place();
							});
						});
						observer.observe(parent, { childList: true });
					}
				};
				place();
				return () => {
					if (raf !== 0) cancelAnimationFrame(raf);
					if (observer !== null) observer.disconnect();
				};
			}, [available]);

			const load = (refresh, rescanBrowsers = false) => {
				setBalanceState("loading");
				return queryBalance({ refresh: refresh === true, rescanBrowsers: rescanBrowsers === true })
					.then((result) => {
						if (result !== null && typeof result === "object" && result.ok === true) {
							setBalance(result.value);
							setBalanceState("ok");
							announceHunger(t, result.value, uiLocale, ttsCfgRef.current, voicePackRef.current);
							return result.value;
						}
						setBalance(null);
						setBalanceState("error");
						return null;
					})
					.catch(() => {
						setBalance(null);
						setBalanceState("error");
						return null;
					});
			};

			const switchTab = (next) => {
				setTab(next);
				if (next === TAB_BALANCE && balanceState === "idle") {
					load(false);
				}
			};

			/** 复制文本到剪贴板（clipboard API 优先，execCommand 回退）。 */
			const copyText = (text) => {
				if (typeof navigator !== "undefined" && navigator.clipboard !== void 0) {
					navigator.clipboard.writeText(text).catch(() => copyTextFallback(text));
					return;
				}
				copyTextFallback(text);
			};
			const copyTextFallback = (text) => {
				const area = document.createElement("textarea");
				area.value = text;
				area.style.position = "fixed";
				area.style.opacity = "0";
				document.body.appendChild(area);
				area.select();
				try {
					document.execCommand("copy");
				} catch {
					// 剪贴板不可用时用户仍可手动复制
				}
				document.body.removeChild(area);
			};

			/**
			 * 登录流程（浏览器扫描启用时主通道）：在新标签页打开平台登录页，
			 * 轮询强制快扫——用户在标签页完成登录后，令牌写入本机浏览器
			 * leveldb，扫描自动拾取，用量随即显示，全程无需控制台。
			 */
			const startLogin = () => {
				window.open("https://platform.deepseek.com/usage", "_blank", "noopener");
				setConnectState("waiting");
				beginPoll();
			};

			/** 轮询检测令牌到位（queryBalance 强制快扫，只校验标记邻近候选）。 */
			const beginPoll = () => {
				if (pollRef.current !== null) {
					window.clearTimeout(pollRef.current);
					pollRef.current = null;
				}
				let attempts = 0;
				const poll = async () => {
					attempts += 1;
					try {
						const value = await queryBalance({ refresh: true, rescanBrowsers: true, quick: true });
						if (value !== null && typeof value === "object" && value.ok === true) {
							const usage = value.value?.usage;
							if (usage !== null && typeof usage === "object" && usage.status !== "no-token") {
								setBalance(value.value);
								setBalanceState("ok");
								setConnectState("idle");
								setLoginPromptDismissed(true);
								return;
							}
						}
					} catch {
						// 轮询失败继续尝试
					}
					if (attempts < 24) {
						pollRef.current = window.setTimeout(poll, 3000);
					} else {
						setConnectState("timeout");
					}
				};
				poll();
			};

			/**
			 * 一键授权（浏览器扫描禁用时的回退）：打开平台用量页，把回传命令
			 * 写入剪贴板，并轮询检测令牌是否回传成功。
			 */
			const startConnect = () => {
				const origin = window.location.origin;
				const command =
					`(() => { const t = JSON.parse(localStorage.getItem('userToken')).value; ` +
					`return fetch('${origin}/api/api-balance/token', { method: 'POST', headers: { 'content-type': 'application/json' }, ` +
					`body: JSON.stringify({ token: t }) }).then(r => r.ok ? '✓ DSH 已连接' : '连接失败: HTTP ' + r.status); })()`;
				copyText(command);
				window.open("https://platform.deepseek.com/usage", "_blank", "noopener");
				setConnectState("waiting");
				beginPoll();
			};

			const disconnectPlatform = async () => {
				if (pollRef.current !== null) {
					window.clearTimeout(pollRef.current);
					pollRef.current = null;
				}
				setConnectState("idle");
				await clearToken().catch(() => {});
				setBalance(null);
				setBalanceState("idle");
			};

			/** 手动保存平台令牌（移动端主通道；同源 POST，无 CORS 依赖）。 */
			const saveManualToken = async () => {
				const value = manualToken.trim();
				if (value.length === 0 || manualSaving) return;
				setManualSaving(true);
				try {
					const resp = await fetch(`${window.location.origin}/api/api-balance/token`, {
						method: "POST",
						headers: { "content-type": "application/json" },
						body: JSON.stringify({ token: value }),
					});
					if (resp.ok) {
						setManualToken("");
						setManualOpen(false);
						setManualSaving(false);
						await load(true);
					} else {
						setManualSaving(false);
					}
				} catch {
					setManualSaving(false);
				}
			};

			// 组件卸载时清理轮询定时器。
			react.useEffect(() => {
				return () => {
					if (pollRef.current !== null) {
						window.clearTimeout(pollRef.current);
						pollRef.current = null;
					}
				};
			}, []);

			// 余额轮询（15 分钟）：页面常驻期间自动检测，余额不足时语音喊饿。
			const [speechOn, setSpeechOn] = react.useState(speechEnabled());
			// 语音设置：TTS 后端配置（localStorage）+ 语音包（host 共享文件）。
			const [voiceSettingsOpen, setVoiceSettingsOpen] = react.useState(false);
			const [ttsCfg, setTtsCfg] = react.useState(readTtsConfig());
			const ttsCfgRef = react.useRef(ttsCfg);
			ttsCfgRef.current = ttsCfg;
			// 语音包库：packs 列表 + activeId；激活包（含 segments URL）供播报引擎。
			const [voicePacks, setVoicePacks] = react.useState([]);
			const [activePackId, setActivePackId] = react.useState(null);
			const voicePackRef = react.useRef(null);
			const refreshPacks = async () => {
				try {
					const resp = await fetch(VOICEPACK_ENDPOINT);
					if (resp.ok) {
						const data = await resp.json();
						const packs = Array.isArray(data.packs) ? data.packs : [];
						setVoicePacks(packs);
						setActivePackId(typeof data.active === "string" ? data.active : null);
						const active = packs.find((pack) => pack.id === data.active) ?? null;
						voicePackRef.current = active;
						return active;
					}
				} catch {
					// 库不可用视为空
				}
				voicePackRef.current = null;
				return null;
			};
			react.useEffect(() => {
				refreshPacks()
					.then(() => {
						// 页面刷新问候音效：语音播报开启时随机播放一个（每页一次）。
						if (pageGreetingPlayed || !speechEnabled()) return;
						pageGreetingPlayed = true;
						window.setTimeout(() => {
							playRandomGreeting(uiLocale, ttsCfgRef.current, voicePackRef.current);
						}, 1200);
					})
					.catch(() => {});
			}, []);
			const [packBusy, setPackBusy] = react.useState(false);
			const [packMessage, setPackMessage] = react.useState("");
			// 语音包制作器：逐段录音 / 导入 + zip 编译；录音可视化浮窗状态。
			const [recordings, setRecordings] = react.useState({});
			const [recordingKey, setRecordingKey] = react.useState(null);
			const [packNameInput, setPackNameInput] = react.useState("");
			const [packLangInput, setPackLangInput] = react.useState(uiLocale === "zh-CN" ? "zh-CN" : uiLocale === "en" ? "en" : "zh-CN");
			const mediaRecorderRef = react.useRef(null);
			const recAnalyserRef = react.useRef(null);
			const recCanvasRef = react.useRef(null);
			const recRafRef = react.useRef(0);
			const recDiscardRef = react.useRef(false);
			const [recElapsed, setRecElapsed] = react.useState(0);
			const stopRecorder = (discard) => {
				recDiscardRef.current = discard === true;
				if (mediaRecorderRef.current !== null) {
					try {
						mediaRecorderRef.current.stop();
					} catch {
						setRecordingKey(null);
					}
				} else {
					setRecordingKey(null);
				}
			};
			const startRecording = async (key) => {
				if (recordingKey !== null) return;
				try {
					const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
					const mimeType =
						MediaRecorder.isTypeSupported("audio/webm;codecs=opus")
							? "audio/webm;codecs=opus"
							: MediaRecorder.isTypeSupported("audio/ogg;codecs=opus")
								? "audio/ogg;codecs=opus"
								: "";
					const recorder = mimeType !== "" ? new MediaRecorder(stream, { mimeType }) : new MediaRecorder(stream);
					const chunks = [];
					recorder.ondataavailable = (event) => {
						if (event.data.size > 0) chunks.push(event.data);
					};
					recorder.onstop = () => {
						stream.getTracks().forEach((track) => track.stop());
						if (!recDiscardRef.current) {
							const blob = new Blob(chunks, { type: recorder.mimeType || "audio/webm" });
							const ext = recorder.mimeType.includes("ogg") ? "ogg" : recorder.mimeType.includes("mp4") ? "m4a" : "webm";
							setRecordings((current) => ({
								...current,
								[key]: { blob, url: URL.createObjectURL(blob), ext },
							}));
						}
						recDiscardRef.current = false;
						mediaRecorderRef.current = null;
						recAnalyserRef.current = null;
						if (recRafRef.current !== 0) {
							cancelAnimationFrame(recRafRef.current);
							recRafRef.current = 0;
						}
						setRecordingKey(null);
					};
					// 可视化：AudioContext + Analyser 电平表（rAF 画布绘制）。
					const AudioCtx = window.AudioContext ?? window.webkitAudioContext;
					if (AudioCtx !== void 0 && recCanvasRef.current !== null) {
						const audioCtx = new AudioCtx();
						const source = audioCtx.createMediaStreamSource(stream);
						const analyser = audioCtx.createAnalyser();
						analyser.fftSize = 256;
						source.connect(analyser);
						recAnalyserRef.current = analyser;
						const data = new Uint8Array(analyser.frequencyBinCount);
						const draw = () => {
							const canvas = recCanvasRef.current;
							const analyserNow = recAnalyserRef.current;
							if (canvas === null || analyserNow === null) return;
							const ctx2d = canvas.getContext("2d");
							if (ctx2d === null) return;
							analyserNow.getByteFrequencyData(data);
							const width = canvas.width;
							const height = canvas.height;
							ctx2d.clearRect(0, 0, width, height);
							const bars = 24;
							const step = Math.floor(data.length / bars);
							for (let i = 0; i < bars; i++) {
								let sum = 0;
								for (let j = 0; j < step; j++) sum += data[i * step + j];
								const level = Math.min(1, (sum / step) / 128);
								const barHeight = Math.max(2, level * height);
								ctx2d.fillStyle = "var(--dsw-alias-brand-primary, #4d6bfe)";
								ctx2d.fillRect(i * (width / bars) + 1, height - barHeight, width / bars - 2, barHeight);
							}
							recRafRef.current = requestAnimationFrame(draw);
						};
						recRafRef.current = requestAnimationFrame(draw);
						stream.getTracks()[0]?.addEventListener("ended", () => {
							audioCtx.close().catch(() => {});
						});
					}
					recorder.start();
					mediaRecorderRef.current = recorder;
					setRecElapsed(0);
					setRecordingKey(key);
				} catch {
					setPackMessage(t("voice.recordDenied"));
				}
			};
			// 录音计时（浮窗展示）。
			react.useEffect(() => {
				if (recordingKey === null) return;
				const started = Date.now();
				const timer = window.setInterval(() => {
					setRecElapsed(Math.round((Date.now() - started) / 1000));
				}, 500);
				return () => window.clearInterval(timer);
			}, [recordingKey]);
			const deleteRecording = (key) => {
				setRecordings((current) => {
					const next = { ...current };
					if (next[key] !== void 0 && typeof next[key].url === "string") {
						try {
							URL.revokeObjectURL(next[key].url);
						} catch {
							// 忽略
						}
					}
					delete next[key];
					return next;
				});
			};
			/** 每段导入音频文件（与录音同构：blob + url + ext）。 */
			const importSegmentAudio = async (key, file) => {
				if (!(file instanceof File) || file.size === 0) return;
				const nameExt = file.name.includes(".") ? file.name.split(".").pop().toLowerCase() : "";
				const ext =
					["mp3", "wav", "ogg", "oga", "webm", "m4a", "mp4", "aac", "flac"].includes(nameExt) ? nameExt : "webm";
				const blob = file.type.length > 0 ? file : new Blob([await file.arrayBuffer()], { type: `audio/${ext}` });
				const rec = { blob, url: URL.createObjectURL(blob), ext };
				setRecordings((current) => {
					if (current[key] !== void 0 && typeof current[key].url === "string") {
						try {
							URL.revokeObjectURL(current[key].url);
						} catch {
							// 忽略
						}
					}
					return { ...current, [key]: rec };
				});
				setPackMessage(t("voice.segmentImported"));
			};
			/** 编译 zip 条目（制作器的共同打包逻辑；lang 取制作器语言选择）。 */
			const buildPackZip = async () => {
				const keys = VOICEPACK_SEGMENT_KEYS.filter((key) => recordings[key] !== void 0);
				if (keys.length === 0) return null;
				const segments = {};
				for (const key of keys) {
					segments[key] = `audio/${key}.${recordings[key].ext}`;
				}
				const audioEntries = await Promise.all(
					keys.map(async (key) => {
						const rec = recordings[key];
						const buf = new Uint8Array(await rec.blob.arrayBuffer());
						return { name: `audio/${key}.${rec.ext}`, data: buf };
					}),
				);
				const manifest = {
					format: "dsh-api-balance-voice-pack",
					version: 1,
					name: packNameInput.trim().length > 0 ? packNameInput.trim() : "voice-pack",
					lang: packLangInput,
					segments,
				};
				return { manifest, zip: buildZip([{ name: "manifest.json", data: new TextEncoder().encode(JSON.stringify(manifest, null, 2)) }, ...audioEntries]) };
			};
			/** 编译并打包下载（分享用）。 */
			const downloadVoicePack = async () => {
				const built = await buildPackZip();
				if (built === null) return;
				const blob = new Blob([built.zip], { type: "application/zip" });
				const anchor = document.createElement("a");
				anchor.href = URL.createObjectURL(blob);
				anchor.download = `${built.manifest.name}.zip`;
				document.body.appendChild(anchor);
				anchor.click();
				document.body.removeChild(anchor);
				setTimeout(() => URL.revokeObjectURL(anchor.href), 5000);
				setPackMessage(t("voice.downloaded"));
			};
			/** 编译并应用本机（导入库并激活）。 */
			const compileInstallPack = async () => {
				const built = await buildPackZip();
				if (built === null) return;
				setPackBusy(true);
				try {
					const resp = await fetch(VOICEPACK_ENDPOINT, {
						method: "POST",
						headers: { "content-type": "application/zip" },
						body: built.zip,
					});
					if (resp.ok) {
						await refreshPacks();
						setPackMessage(t("voice.compiled"));
					} else {
						const err = await resp.json().catch(() => null);
						setPackMessage(`${t("voice.importFailed")}${err?.error ? `（${err.error}）` : ""}`);
					}
				} catch {
					setPackMessage(t("voice.importFailed"));
				}
				setPackBusy(false);
			};
			// 编辑已导入语音包的保护：首次编辑前弹确认提示（会话内确认一次即可）。
			const [editConfirmOpen, setEditConfirmOpen] = react.useState(false);
			const editConfirmedRef = react.useRef(false);
			const pendingEditRef = react.useRef(null);
			const guardEdit = (action) => {
				if (voicePackRef.current !== null && !editConfirmedRef.current) {
					pendingEditRef.current = action;
					setEditConfirmOpen(true);
					return;
				}
				action();
			};
			const confirmEdit = () => {
				editConfirmedRef.current = true;
				setEditConfirmOpen(false);
				const action = pendingEditRef.current;
				pendingEditRef.current = null;
				if (action !== null) action();
			};
			const cancelEdit = () => {
				pendingEditRef.current = null;
				setEditConfirmOpen(false);
			};
			const importVoicePack = async (file) => {
				if (!(file instanceof File) || file.size === 0 || packBusy) return;
				setPackBusy(true);
				try {
					const bytes = await file.arrayBuffer();
					const resp = await fetch(VOICEPACK_ENDPOINT, {
						method: "POST",
						headers: { "content-type": "application/zip" },
						body: bytes,
					});
					if (resp.ok) {
						await refreshPacks();
						setPackMessage(t("voice.imported"));
					} else {
						const err = await resp.json().catch(() => null);
						setPackMessage(`${t("voice.importFailed")}${err?.error ? `（${err.error}）` : ""}`);
					}
				} catch {
					setPackMessage(t("voice.importFailed"));
				}
				setPackBusy(false);
			};
			const activatePack = async (id) => {
				setPackBusy(true);
				try {
					const resp = await fetch(`${VOICEPACK_ENDPOINT}/activate`, {
						method: "POST",
						headers: { "content-type": "application/json" },
						body: JSON.stringify({ id }),
					});
					if (resp.ok) {
						await refreshPacks();
					}
				} catch {
					// 忽略
				}
				setPackBusy(false);
			};
			const removePacks = async (ids) => {
				if (ids.length === 0 || packBusy) return;
				setPackBusy(true);
				try {
					const resp = await fetch(`${VOICEPACK_ENDPOINT}?ids=${encodeURIComponent(ids.join(","))}`, {
						method: "DELETE",
					});
					if (resp.ok) {
						await refreshPacks();
						setPackMessage(t("voice.removed"));
					}
				} catch {
					setPackMessage(t("voice.importFailed"));
				}
				setPackBusy(false);
			};
			// 语音播报下拉菜单（点击播报按钮弹出；portal 渲染，位置按按钮 rect
			// 计算）。默认从下往上展开（按钮顶部上方）；上方空间不足时回退向下。
			const [speechMenuOpen, setSpeechMenuOpen] = react.useState(false);
			const [speechMenuPos, setSpeechMenuPos] = react.useState({ x: 0, y: 0, h: 0 });
			const [speechMenuPlacement, setSpeechMenuPlacement] = react.useState("up");
			const speechMenuRef = react.useRef(null);
			// 菜单打开时：点击菜单外任意处关闭。
			react.useEffect(() => {
				if (!speechMenuOpen) return;
				const onDown = (event) => {
					if (speechMenuRef.current !== null && speechMenuRef.current.contains(event.target)) return;
					setSpeechMenuOpen(false);
				};
				document.addEventListener("pointerdown", onDown);
				return () => document.removeEventListener("pointerdown", onDown);
			}, [speechMenuOpen]);
			// 向上展开空间不足（会超出视口顶部）时回退为向下展开。
			react.useLayoutEffect(() => {
				if (!speechMenuOpen || speechMenuPlacement !== "up") return;
				const menu = speechMenuRef.current;
				if (menu === null) return;
				const height = menu.offsetHeight;
				if (speechMenuPos.y - height - 4 < 8) setSpeechMenuPlacement("down");
			}, [speechMenuOpen, speechMenuPlacement, speechMenuPos]);
			const hungerPollRef = react.useRef(null);
			react.useEffect(() => {
				let cancelled = false;
				const poll = async () => {
					const value = await queryBalance(true).catch(() => null);
					if (cancelled || value === null || typeof value !== "object" || value.ok !== true) return;
					setBalance(value.value);
					setBalanceState("ok");
					announceHunger(t, value.value, uiLocale, ttsCfgRef.current, voicePackRef.current);
				};
				hungerPollRef.current = window.setInterval(poll, HUNGRY_POLL_INTERVAL_MS);
				return () => {
					cancelled = true;
					if (hungerPollRef.current !== null) window.clearInterval(hungerPollRef.current);
					hungerPollRef.current = null;
				};
			}, []);
			const toggleSpeech = () => {
				setSpeechOn((on) => {
					const next = !on;
					setSpeechEnabled(next);
					return next;
				});
			};

			if (context === null) return null;

			const percent = context.percent;
			const reading = `${percent}%`;
			const breakdownTotal =
				breakdown === void 0
					? 0
					: breakdown.systemTokens + breakdown.toolsTokens + breakdown.messageTokens;
			const segments =
				breakdown === void 0 || breakdownTotal === 0
					? [{ key: "total", tint: void 0, width: percent }]
					: USAGE_ROWS.map((row) => ({
							key: row.key,
							tint: row.tint,
							width: (percent * breakdown[row.key]) / breakdownTotal,
						})).filter((part) => part.width > 0);

				// 标签行（用量 | 余额）。
			const tabButton = (id, active) =>
				react.createElement(
					"button",
					{
						type: "button",
						role: "tab",
						"aria-selected": active,
						onClick: () => switchTab(id),
						style: {
							display: "inline-flex",
							alignItems: "center",
							padding: "0 10px",
							borderRadius: "999px",
							cursor: "pointer",
							userSelect: "none",
							border: "1px solid var(--dsw-alias-separator-primary)",
							background: active ? "var(--dsw-alias-interactive-bg-hover)" : "transparent",
							color: active ? "var(--dsw-alias-label-secondary)" : "var(--dsw-alias-label-tertiary)",
							fontSize: "12px",
							lineHeight: "20px",
						},
					},
					id === TAB_USAGE ? t("tab.usage") : t("tab.balance"),
				);

			// 刷新按钮：强制绕过 host 端缓存重新拉取余额 + 官方用量
			// （queryBalance(true) → RPC refresh:true）。加载中显示旋转动画。
			const refreshing = balanceState === "loading";
			const refreshButton = react.createElement(
				"button",
				{
					type: "button",
					"aria-label": t("balance.refresh"),
					title: t("balance.refresh"),
					disabled: refreshing,
					onClick: () => {
						void load(true);
						// 手动刷新也触发随机问候音效（语音播报开启时）。
						if (speechEnabled()) {
							playRandomGreeting(uiLocale, ttsCfgRef.current, voicePackRef.current);
						}
					},
					style: {
						display: "inline-flex",
						alignItems: "center",
						justifyContent: "center",
						width: "24px",
						height: "24px",
						padding: 0,
						borderRadius: "999px",
						cursor: refreshing ? "default" : "pointer",
						userSelect: "none",
						border: "1px solid var(--dsw-alias-separator-primary)",
						background: "transparent",
						color: "var(--dsw-alias-label-tertiary)",
						opacity: refreshing ? 0.6 : 1,
					},
				},
				refreshing
					? react.createElement("i", { className: "dshAbSpin", "aria-hidden": true, style: { margin: 0 } })
					: react.createElement(
							"svg",
							{ viewBox: "0 0 16 16", width: "13", height: "13", "aria-hidden": true },
							react.createElement("path", {
								d: "M13.6 8a5.6 5.6 0 1 1-1.64-3.96",
								fill: "none",
								stroke: "currentColor",
								strokeWidth: 1.6,
								strokeLinecap: "round",
							}),
							react.createElement("path", {
								d: "M12.4 1.5v3.1H9.3",
								fill: "none",
								stroke: "currentColor",
								strokeWidth: 1.6,
								strokeLinecap: "round",
								strokeLinejoin: "round",
							}),
						),
			);

			// 「用量」标签内容：复刻原 ContextMeter 面板。
			const usageBody = react.createElement(
				react.Fragment,
				null,
				react.createElement(
					"div",
					{ style: { alignItems: "center", gap: "6px", display: "flex", marginBottom: "10px" } },
					react.createElement(
						"span",
						{ style: { color: "var(--dsw-alias-label-tertiary)" } },
						t("usage.headline"),
					),
					react.createElement(
						"span",
						{ style: { color: "var(--dsw-alias-label-primary)", fontWeight: 500 } },
						reading,
					),
					react.createElement(
						"span",
						{
							style: {
								fontVariantNumeric: "tabular-nums",
								color: "var(--dsw-alias-label-primary)",
								marginLeft: "auto",
								fontWeight: 500,
							},
						},
						`~${formatTokens(context.usedTokens)} / ${formatTokens(context.contextWindow)}`,
					),
				),
				react.createElement(
					"div",
					{
						style: {
							background: "var(--dsw-alias-interactive-bg-hover)",
							borderRadius: "999px",
							gap: "1px",
							height: "4px",
							margin: "0 0 12px",
							display: "flex",
							overflow: "hidden",
						},
					},
					segments.map((segment) =>
						react.createElement("div", {
							key: segment.key,
							style: {
								background: segment.tint ?? "var(--dsw-alias-label-tertiary)",
								borderRadius: "1px",
								flex: "none",
								minWidth: "2px",
								height: "100%",
								width: `${segment.width}%`,
							},
						}),
					),
				),
				breakdown !== void 0
					? react.createElement(
							"dl",
							{ style: { margin: "6px 0 0" } },
							USAGE_ROWS.map((row) =>
								react.createElement(
									"div",
									{
										key: row.key,
										style: {
											justifyContent: "space-between",
											alignItems: "center",
											gap: "12px",
											padding: "2px 0",
											display: "flex",
										},
									},
									react.createElement(
										"dt",
										{ style: { color: "var(--dsw-alias-label-secondary)", margin: 0 } },
										react.createElement(
											"span",
											{
												"aria-hidden": true,
												style: {
													background: row.tint,
													verticalAlign: "baseline",
													borderRadius: "2px",
													width: "8px",
													height: "8px",
													marginRight: "6px",
													display: "inline-block",
												},
											},
										),
										t(row.label),
									),
									react.createElement(
										"dd",
										{
											style: {
												fontVariantNumeric: "tabular-nums",
												color: "var(--dsw-alias-label-primary)",
												margin: 0,
											},
										},
										`~${formatTokens(breakdown[row.key])}`,
									),
								),
							),
						)
					: null,
			);

			// 明细行（label 左、value 右，面板内通用）。
			const detailRow = (label, value, extra) => {
				const { key, labelStyle, valueStyle } = extra ?? {};
				return react.createElement(
					"div",
					{
						key,
						style: {
							justifyContent: "space-between",
							alignItems: "center",
							gap: "12px",
							padding: "2px 0",
							display: "flex",
						},
					},
					react.createElement(
						"dt",
						{
							style: {
								color: "var(--dsw-alias-label-secondary)",
								margin: 0,
								whiteSpace: "nowrap",
								flexShrink: 0,
								...labelStyle,
							},
						},
						label,
					),
					react.createElement(
						"dd",
						{
							style: {
								fontVariantNumeric: "tabular-nums",
								color: "var(--dsw-alias-label-primary)",
								margin: 0,
								whiteSpace: "nowrap",
								flexShrink: 0,
								marginLeft: "auto",
								...valueStyle,
							},
						},
						value,
					),
				);
			};

			// 消耗窗口行：`¥0.12 · 入 1.2k · 出 800`。
			const usageWindowRow = (window) => {
				const costs = Object.entries(window?.costByCurrency ?? {});
				const parts = [];
				for (const [currency, cost] of costs) {
					parts.push(`${formatCost(cost)}${currency.length > 0 ? ` ${currency}` : ""}`);
				}
				if (parts.length === 0) parts.push(formatCost(0));
				parts.push(`${t("balance.in")} ${formatTokens((window?.hit ?? 0) + (window?.miss ?? 0))}`);
				parts.push(`${t("balance.out")} ${formatTokens(window?.completion ?? 0)}`);
				return parts.join(" · ");
			};

			// 「余额」标签内容。
			let balanceBody = null;
			if (balanceState === "loading") {
				balanceBody = react.createElement(
					"span",
					{ style: { color: "var(--dsw-alias-label-tertiary)", display: "inline-flex", alignItems: "center" } },
					react.createElement("i", { className: "dshAbSpin", "aria-hidden": true }),
					t("balance.loading"),
				);
			} else if (balanceState === "error" || balance === null) {
				balanceBody = react.createElement(
					"span",
					{ style: { color: "var(--dsw-alias-danger-primary, #e5484d)" } },
					t("balance.error"),
				);
			} else {
				const infos = Array.isArray(balance.balanceInfos) ? balance.balanceInfos : [];
				const usage = balance.usage ?? null;
				const usageOk = usage !== null && usage.status === "ok" && typeof usage.windows === "object";
				const usageWindows = usageOk ? usage.windows : null;
				const usageMessage = usage !== null && typeof usage.message === "string" ? usage.message : null;
				const rows = [];
				rows.push(detailRow(t("balance.key"), balance.keyHint ?? "—"));
				rows.push(
					detailRow(
						t("balance.status"),
						react.createElement(
							"span",
							{ style: { display: "inline-flex", alignItems: "center", gap: "6px" } },
							balance.isAvailable === true ? t("balance.available") : t("balance.unavailable"),
							react.createElement(
								"button",
								{
									type: "button",
									onClick: () => setTopupOpen(true),
									style: {
										padding: "0 8px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: "var(--dsw-alias-interactive-bg-hover)",
										color: "var(--dsw-alias-label-secondary)",
										fontSize: "11px",
										lineHeight: "18px",
									},
								},
								t("balance.topup"),
							),
						),
					),
				);
				// 各币种总余额（逐币种透传，无币种假设）。
				infos.forEach((info, index) => {
					rows.push(
						detailRow(
							`${t("balance.total")}${info.currency ? ` (${info.currency})` : ""}`,
							info.totalBalance ?? "—",
							{ key: `total-${index}` },
						),
					);
				});
				// 当日 / 当月 / 30日内消耗（金额 + token）。
				if (usageWindows !== null) {
					rows.push(detailRow(t("balance.today"), usageWindowRow(usageWindows.today), { key: "w-today" }));
					rows.push(detailRow(t("balance.month"), usageWindowRow(usageWindows.month), { key: "w-month" }));
					rows.push(detailRow(t("balance.last30d"), usageWindowRow(usageWindows.last30d), { key: "w-last30d" }));
				} else {
					const isNoToken = usage !== null && usage.status === "no-token";
					rows.push(
						detailRow(
							t("balance.usage"),
							isNoToken ? t("balance.noToken") : t("balance.error"),
							{ key: "w-unavailable" },
						),
					);
				}
				// 分模型 token 明细（30 日内；接口按模型返回时才有）。
				const activeModels =
					usageWindows !== null && Array.isArray(usageWindows.last30d?.models)
						? usageWindows.last30d.models.filter(
								(row) => row.hit + row.miss + row.completion + row.cost > 0,
							)
						: [];
				if (activeModels.length > 0) {
					rows.push(
						detailRow(t("balance.models"), null, {
							key: "m-head",
							labelStyle: { color: "var(--dsw-alias-label-tertiary)", marginTop: "4px" },
						}),
					);
					activeModels.forEach((modelRow, index) => {
						rows.push(
							detailRow(
								modelRow.model.length > 0 ? modelRow.model : t("balance.allModels"),
								`${t("balance.in")} ${formatTokens(modelRow.hit + modelRow.miss)} · ${t("balance.out")} ${formatTokens(modelRow.completion)}${modelRow.cost > 0 ? ` · ${formatCost(modelRow.cost)}` : ""}`,
								{ key: `m-${index}`, labelStyle: { paddingLeft: "10px", fontSize: "11px" }, valueStyle: { fontSize: "11px" } },
							),
						);
					});
				}
				balanceBody = react.createElement("dl", { style: { margin: 0 } }, rows);
				// 分模型堆叠柱状图（按日 / 按月切换）。
				const chartSeries = usage !== null && typeof usage.series === "object" ? usage.series : null;
				if (usageWindows !== null && chartSeries !== null) {
					balanceBody = react.createElement(
						react.Fragment,
						null,
						balanceBody,
						react.createElement(UsageChart, {
							t,
							series: chartSeries,
							mode: chartMode,
							onModeChange: setChartMode,
							width: 316,
						}),
					);
				}
				// no-token：授权 UI。浏览器扫描启用时主通道为「前往登录」
				// （新标签页登录 + 轮询快扫自动拾取）；扫描禁用时回退旧版
				// 剪贴板回传流程。手动输入令牌始终作为不想登录时的备选。
				if (promptNoToken) {
					const waiting = connectState === "waiting";
					const showManual = touchDevice || manualOpen;
					const scanReport = promptScanReport;
					const scanNotFound = promptScanNotFound;
					const browserScanEnabled = promptBrowserScan;
					const scanning = balanceState === "loading";
					const rescanButton = react.createElement(
						"button",
						{
							type: "button",
							disabled: scanning || waiting,
							onClick: () => (scanning || waiting ? void 0 : load(true, true)),
							style: {
								display: "inline-flex",
								alignItems: "center",
								marginTop: "10px",
								marginRight: "8px",
								padding: "3px 12px",
								borderRadius: "999px",
								cursor: scanning || waiting ? "default" : "pointer",
								border: "1px solid var(--dsw-alias-separator-primary)",
								background: "var(--dsw-alias-interactive-bg-hover)",
								color: "var(--dsw-alias-label-secondary)",
								fontSize: "12px",
								lineHeight: "20px",
								opacity: scanning || waiting ? 0.6 : 1,
							},
						},
						scanning ? t("balance.scanning") : t("balance.rescan"),
					);
					// 主行动按钮：扫描启用 → 「前往登录」（新标签页登录 + 轮询
					// 自动拾取，桌面/触屏均可用；轮询中显示「检测登录中…」）；
					// 扫描禁用 → 旧版剪贴板回传流程（仅桌面）。
					const connectButton =
						touchDevice && !browserScanEnabled
							? null
							: react.createElement(
									"button",
									{
										type: "button",
										disabled: waiting,
										onClick: () => (waiting ? void 0 : browserScanEnabled ? startLogin() : startConnect()),
										style: {
											display: "inline-flex",
											alignItems: "center",
											marginTop: "10px",
											padding: "3px 12px",
											borderRadius: "999px",
											cursor: waiting ? "default" : "pointer",
											border: "1px solid var(--dsw-alias-separator-primary)",
											background: "var(--dsw-alias-interactive-bg-hover)",
											color: "var(--dsw-alias-label-secondary)",
											fontSize: "12px",
											lineHeight: "20px",
											opacity: waiting ? 0.6 : 1,
										},
									},
									waiting
										? browserScanEnabled
											? t("balance.loginChecking")
											: t("balance.connecting")
										: browserScanEnabled
											? t("balance.loginGo")
											: t("balance.connect"),
								);
					// 手动输入为二级功能：扫描启用时只在未登录提示弹窗中提供
					// （不想登录时的备选），面板内不再单独展示入口；扫描禁用
					// 时保留旧入口（触屏设备主通道）。
					const manualLink =
						browserScanEnabled || touchDevice || waiting
							? null
							: react.createElement(
									"button",
									{
										type: "button",
										onClick: () => setManualOpen(!manualOpen),
										style: {
											display: "inline-flex",
											alignItems: "center",
											marginTop: "10px",
											marginLeft: "8px",
											padding: "1px 10px",
											borderRadius: "999px",
											cursor: "pointer",
											border: "1px solid var(--dsw-alias-separator-primary)",
											background: "transparent",
											color: "var(--dsw-alias-label-tertiary)",
											fontSize: "11px",
											lineHeight: "18px",
										},
									},
									t("balance.manualLink"),
								);
					const manualForm = !showManual
						? null
						: react.createElement(
								"div",
								{ style: { marginTop: "8px", display: "flex", gap: "6px", alignItems: "center" } },
								react.createElement("input", {
									type: "password",
									autoComplete: "off",
									placeholder: t("balance.manualPlaceholder"),
									value: manualToken,
									onChange: (event) => setManualToken(event.target.value),
									onKeyDown: (event) => {
										if (event.key === "Enter") saveManualToken();
									},
									style: {
										flex: 1,
										minWidth: 0,
										padding: "4px 8px",
										borderRadius: "8px",
										border: "1px solid var(--dsw-alias-border-l3)",
										background: "var(--dsw-alias-bg-layer-2, transparent)",
										color: "var(--dsw-alias-label-primary)",
										fontSize: "12px",
										lineHeight: "18px",
									},
								}),
								react.createElement(
									"button",
									{
										type: "button",
										disabled: manualSaving || manualToken.trim().length === 0,
										onClick: saveManualToken,
										style: {
											padding: "3px 12px",
											borderRadius: "999px",
											cursor: manualSaving || manualToken.trim().length === 0 ? "default" : "pointer",
											border: "1px solid var(--dsw-alias-separator-primary)",
											background: "var(--dsw-alias-interactive-bg-hover)",
											color: "var(--dsw-alias-label-secondary)",
											fontSize: "12px",
											lineHeight: "20px",
											opacity: manualSaving || manualToken.trim().length === 0 ? 0.6 : 1,
										},
									},
									t("balance.manualSave"),
								),
							);
					balanceBody = react.createElement(
						react.Fragment,
						null,
						balanceBody,
						rescanButton,
						connectButton,
						manualLink,
						manualForm,
						react.createElement(
							"p",
							{
								style: {
									margin: "8px 0 0",
									fontSize: "11px",
									lineHeight: "16px",
									color: "var(--dsw-alias-label-tertiary)",
									whiteSpace: "pre-wrap",
									wordBreak: "break-word",
								},
							},
							waiting
								? browserScanEnabled
									? t("balance.loginWaiting")
									: t("balance.connectWaiting")
								: connectState === "timeout"
									? browserScanEnabled
										? t("balance.loginTimeout")
										: t("balance.connectTimeout")
									: scanNotFound
										? `${t("balance.scanHint")}${
												scanReport.candidates > 0 ? `（${scanReport.candidates} 个候选无效）` : ""
											}`
										: touchDevice
											? t("balance.connectGuideMobile")
											: t("balance.connectGuide"),
						),
					);
				} else if (usage !== null && usage.status === "error" && usageMessage !== null) {
					// error 状态：展示错误详情（小字块）。
					balanceBody = react.createElement(
						react.Fragment,
						null,
						balanceBody,
						react.createElement(
							"p",
							{
								style: {
									margin: "8px 0 0",
									fontSize: "11px",
									lineHeight: "16px",
									color: "var(--dsw-alias-label-tertiary)",
									whiteSpace: "pre-wrap",
									wordBreak: "break-word",
								},
							},
							usageMessage,
						),
					);
				}
				// 已连接：令牌来源（标题/正文两行）+ 断开按钮；语音播报独立
				// 一行（播报按钮 + 下拉菜单 + 提醒开关）。
				if (usage !== null && usage.status !== "no-token") {
					const tokenSource = typeof usage.tokenSource === "string" ? usage.tokenSource : null;
					// 播报内容（数据来自当前 balance 快照）。有语音包时按
					// 「包片段 + TTS 动态数字」拼接；无包时整句 TTS。
					const sepForLang = uiLocale.startsWith("zh") ? { c: "，", s: "；" } : { c: ", ", s: "; " };
					const usageFullText = () => {
						if (usageWindows === null) return "";
						const today = usageWindows.today ?? {};
						const month = usageWindows.month ?? {};
						return (
							`${t("balance.today")}${formatTokens((today.hit ?? 0) + (today.miss ?? 0))}` +
							`${sepForLang.c}${t("balance.out")}${formatTokens(today.completion ?? 0)}` +
							`${sepForLang.s}${t("balance.month")}${formatTokens((month.hit ?? 0) + (month.miss ?? 0))}` +
							`${sepForLang.c}${t("balance.out")}${formatTokens(month.completion ?? 0)}`
						);
					};
					const usageParts = () => {
						if (usageWindows === null) return [];
						const today = usageWindows.today ?? {};
						const month = usageWindows.month ?? {};
						return [
							{ kind: "pack", key: "usage", fallbackText: t("balance.usage") },
							{ kind: "tts", text: formatTokens((today.hit ?? 0) + (today.miss ?? 0)) },
							{ kind: "pack", key: "tokenUnit", fallbackText: "" },
							{ kind: "pack", key: "month", fallbackText: t("balance.month") },
							{ kind: "tts", text: formatTokens((month.hit ?? 0) + (month.miss ?? 0)) },
							{ kind: "pack", key: "tokenUnit", fallbackText: "" },
							{ kind: "pack", key: "suffix", fallbackText: "" },
						];
					};
					const balanceFullText = () => {
						const infos = Array.isArray(balance?.balanceInfos) ? balance.balanceInfos : [];
						const parts = infos.map((info) => `${info.currency} ${info.totalBalance}`);
						const colon = uiLocale.startsWith("zh") ? "：" : ": ";
						return `${t("balance.total")}${colon}${parts.length > 0 ? parts.join(uiLocale.startsWith("zh") ? "；" : "; ") : "—"}`;
					};
					const balanceParts = () => {
						const infos = Array.isArray(balance?.balanceInfos) ? balance.balanceInfos : [];
						const parts = [{ kind: "pack", key: "balance", fallbackText: t("balance.total") }];
						for (const info of infos) {
							parts.push({ kind: "tts", text: `${info.totalBalance}` });
							if (typeof info.currency === "string" && info.currency.length > 0) {
								parts.push({ kind: "tts", text: info.currency });
							}
						}
						parts.push({ kind: "pack", key: "suffix", fallbackText: "" });
						return parts;
					};
					const speakCurrentUsage = () => {
						if (usageWindows === null) return;
						if (voicePackRef.current !== null) {
							speakNowParts(usageParts(), uiLocale, ttsCfgRef.current, voicePackRef.current);
						} else {
							speakNowParts([{ kind: "tts", text: usageFullText() }], uiLocale, ttsCfgRef.current, null);
						}
					};
					const speakCurrentBalance = () => {
						if (voicePackRef.current !== null) {
							speakNowParts(balanceParts(), uiLocale, ttsCfgRef.current, voicePackRef.current);
						} else {
							speakNowParts([{ kind: "tts", text: balanceFullText() }], uiLocale, ttsCfgRef.current, null);
						}
					};
					const speechMenuItems = [
						{ key: "usage", label: t("speech.broadcastUsage"), run: speakCurrentUsage },
						{ key: "balance", label: t("speech.broadcastBalance"), run: speakCurrentBalance },
						{
							key: "test-low",
							label: t("speech.testLow"),
							run: () =>
								speakNowParts(
									[{ kind: "pack", key: "low", fallbackText: t("speech.low") }],
									uiLocale,
									ttsCfgRef.current,
									voicePackRef.current,
								),
						},
						{
							key: "test-dead",
							label: t("speech.testDead"),
							run: () =>
								speakNowParts(
									[{ kind: "pack", key: "dead", fallbackText: t("speech.dead") }],
									uiLocale,
									ttsCfgRef.current,
									voicePackRef.current,
								),
						},
					];
					const speechMenu = !speechMenuOpen
						? null
						: reactDOM.createPortal(
								react.createElement(
									"div",
									{
										ref: speechMenuRef,
										onPointerDown: (event) => event.stopPropagation(),
										style: {
											// portal + fixed：面板主体带 overflow 滚动，绝对定位
											// 菜单会被裁剪（播报按钮在下部时菜单不可见/不可点）。
											position: "fixed",
											left: speechMenuPos.x,
											// 默认向上展开：菜单底边贴着按钮顶边（4px 间距）；
											// 上方空间不足时回退向下（贴按钮底边）。
											top: speechMenuPlacement === "up" ? speechMenuPos.y - 4 : speechMenuPos.y + speechMenuPos.h + 4,
											transform: speechMenuPlacement === "up" ? "translateY(-100%)" : "none",
											minWidth: "208px",
											zIndex: 1002,
											background: "var(--dsw-specific-menu)",
											border: "1px solid var(--dsw-alias-border-inverted)",
											borderRadius: "8px",
											boxShadow: "var(--dsw-shadow-lv3)",
											padding: "4px",
										},
									},
									speechMenuItems.map((item) =>
										react.createElement(
											"button",
											{
												key: item.key,
												type: "button",
												onClick: () => {
													setSpeechMenuOpen(false);
													item.run();
												},
												style: {
													display: "block",
													width: "100%",
													textAlign: "left",
													padding: "5px 10px",
													border: "none",
													borderRadius: "6px",
													background: "transparent",
													color: "var(--dsw-alias-label-secondary)",
													fontSize: "12px",
													lineHeight: "18px",
													cursor: "pointer",
												},
											},
											item.label,
										),
									),
								),
								document.body,
							);
					balanceBody = react.createElement(
						react.Fragment,
						null,
						balanceBody,
						react.createElement(
							"div",
							{ style: { display: "flex", gap: "8px", alignItems: "center", marginTop: "10px" } },
							tokenSource === null
								? null
								: react.createElement(
										"div",
										{ style: { marginRight: "auto", minWidth: 0 } },
										react.createElement(
											"div",
											{
												style: {
													fontSize: "10px",
													lineHeight: "14px",
													color: "var(--dsw-alias-label-tertiary)",
												},
											},
											t("balance.sourceLabel"),
										),
										react.createElement(
											"div",
											{
												style: {
													fontSize: "12px",
													lineHeight: "18px",
													color: "var(--dsw-alias-label-secondary)",
												},
											},
											tokenSource === "browser" ? t("balance.sourceBrowser") : t("balance.sourceManual"),
										),
									),
							// 登录状态按钮：已登录 → 灰显「✓ 已登录」。
							react.createElement(
								"button",
								{
									type: "button",
									disabled: true,
									"aria-disabled": true,
									style: {
										display: "inline-flex",
										alignItems: "center",
										gap: "4px",
										padding: "1px 10px",
										borderRadius: "999px",
										cursor: "default",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: "transparent",
										color: "var(--dsw-alias-label-tertiary)",
										fontSize: "11px",
										lineHeight: "18px",
										opacity: 0.6,
									},
								},
								t("balance.loggedIn"),
							),
							react.createElement(
								"button",
								{
									type: "button",
									onClick: () => disconnectPlatform(),
									style: {
										display: "inline-flex",
										alignItems: "center",
										padding: "1px 10px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: "transparent",
										color: "var(--dsw-alias-label-tertiary)",
										fontSize: "11px",
										lineHeight: "18px",
									},
								},
								t("balance.disconnect"),
							),
						),
						react.createElement(
							"div",
							{
								style: {
									position: "relative",
									display: "flex",
									gap: "8px",
									alignItems: "center",
									marginTop: "8px",
								},
							},
							react.createElement(
								"button",
								{
									type: "button",
									"aria-haspopup": "menu",
									"aria-expanded": speechMenuOpen,
									onClick: (event) => {
										const next = !speechMenuOpen;
										if (next) {
											const rect = event.currentTarget.getBoundingClientRect();
											// 锚点：按钮顶边（默认向上展开）。
											setSpeechMenuPos({
												x: Math.round(rect.left),
												y: Math.round(rect.top),
												h: Math.round(rect.height),
											});
											setSpeechMenuPlacement("up");
										}
										setSpeechMenuOpen(next);
									},
									style: {
										display: "inline-flex",
										alignItems: "center",
										gap: "4px",
										padding: "1px 10px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: speechMenuOpen ? "var(--dsw-alias-interactive-bg-hover)" : "transparent",
										color: "var(--dsw-alias-label-secondary)",
										fontSize: "11px",
										lineHeight: "18px",
									},
								},
								t("balance.speechBroadcast"),
							),
							react.createElement(
								"button",
								{
									type: "button",
									"aria-haspopup": "dialog",
									onClick: () => setVoiceSettingsOpen(true),
									style: {
										display: "inline-flex",
										alignItems: "center",
										gap: "4px",
										padding: "1px 10px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: voiceSettingsOpen ? "var(--dsw-alias-interactive-bg-hover)" : "transparent",
										color: speechOn ? "var(--dsw-alias-label-secondary)" : "var(--dsw-alias-label-tertiary)",
										fontSize: "11px",
										lineHeight: "18px",
									},
								},
								t("balance.voiceSettings"),
							),
							speechMenu,
						),
					);
				}
			}

			return react.createElement(
				"span",
				{ ref: rootRef, style: { display: "inline-flex", position: "relative" } },
				react.createElement(
					primitives.Tooltip,
					{
						label: t("usage.aria", { percent: reading }),
						side: "top",
						delayMs: 200,
						disabled: open,
					},
					react.createElement(
						"button",
						{
							type: "button",
							"data-dsh-api-balance": "",
							"aria-label": t("usage.aria", { percent: reading }),
							"aria-haspopup": "dialog",
							"aria-expanded": open,
							onClick: () => setOpen(!open),
							style: {
								width: "28px",
								height: "28px",
								color: "var(--dsw-alias-label-secondary)",
								cursor: "pointer",
								background: "transparent",
								border: "none",
								borderRadius: "999px",
								flex: "none",
								placeItems: "center",
								display: "grid",
							},
						},
						react.createElement(
							"svg",
							{ viewBox: "0 0 14 14", width: "14", height: "14", "aria-hidden": true },
							react.createElement("circle", {
								cx: "7",
								cy: "7",
								r: RADIUS,
								fill: "none",
								stroke: "var(--dsw-alias-border-l3)",
								strokeWidth: "2px",
							}),
							react.createElement("circle", {
								cx: "7",
								cy: "7",
								r: RADIUS,
								fill: "none",
								stroke: "var(--dsw-alias-label-tertiary)",
								strokeWidth: "2px",
								strokeLinecap: "round",
								strokeDasharray: `${(CIRCUMFERENCE * percent) / 100} ${CIRCUMFERENCE}`,
								transform: "rotate(-90 7 7)",
							}),
						),
					),
				),
				open &&
					react.createElement(
						"div",
						{
							role: "dialog",
							className: "dshAbPanel",
							"aria-label": t("usage.headline"),
							style: {
								zIndex: 100,
								boxSizing: "border-box",
								border: "1px solid var(--dsw-alias-border-inverted)",
								background: "var(--dsw-specific-menu)",
								// 用量视图沿用原 ContextMeter 的 264px；余额视图数据列更长，
								// 加宽到 340px 避免中文标签被挤压成竖列。
								width: tab === TAB_BALANCE ? "340px" : "264px",
								maxWidth: "calc(100vw - 24px)",
								boxShadow: "var(--dsw-shadow-lv3)",
								color: "var(--dsw-alias-label-secondary)",
								cursor: "default",
								borderRadius: "12px",
								padding: "12px",
								fontSize: "12px",
								lineHeight: "20px",
								position: "absolute",
								bottom: "calc(100% + 8px)",
								right: 0,
							},
						},
						react.createElement(
							"div",
							{ style: { display: "flex", alignItems: "center", gap: "4px", marginBottom: "12px" } },
							react.createElement(
								"div",
								{
									role: "tablist",
									"aria-label": t("tab.aria"),
									style: { display: "flex", gap: "4px" },
								},
								tabButton(TAB_USAGE, tab === TAB_USAGE),
								tabButton(TAB_BALANCE, tab === TAB_BALANCE),
							),
							react.createElement("span", { style: { flex: "1 1 auto" } }),
							refreshButton,
						),
						tab === TAB_USAGE ? usageBody : balanceBody,
					),
				topupOpen
					? react.createElement(TopupModal, { t, onClose: () => setTopupOpen(false) })
					: null,
				tab === TAB_BALANCE &&
				promptNoToken &&
				promptBrowserScan &&
				promptScanNotFound &&
				!loginPromptDismissed
					? react.createElement(LoginPromptModal, {
							t,
							waiting: connectState === "waiting",
							onClose: () => setLoginPromptDismissed(true),
							onGoLogin: () => (connectState === "waiting" ? void 0 : startLogin()),
							onManual: () => {
								setLoginPromptDismissed(true);
								setManualOpen(true);
							},
						})
					: null,
				voiceSettingsOpen
					? react.createElement(VoiceSettingsModal, {
							t,
							autoOn: speechOn,
							onToggleAuto: toggleSpeech,
							ttsCfg,
							onTtsChange: (next) => {
								setTtsCfg(next);
								writeTtsConfig(next);
							},
							packs: voicePacks,
							activeId: activePackId,
							packBusy,
							packMessage,
							onImportFile: importVoicePack,
							onActivate: activatePack,
							onRemovePacks: removePacks,
							onTestTts: () => {
								stopActiveSpeech();
								ttsSpeak(t("voice.ttsTestText"), uiLocale, ttsCfgRef.current).catch(() => {});
							},
							recordings,
							recordingKey,
							onStartRecording: (key) => guardEdit(() => startRecording(key)),
							onStopRecording: (discard) => stopRecorder(discard === true),
							onPlayRecording: (key) => {
								const rec = recordings[key];
								if (rec !== void 0 && typeof rec.url === "string") {
									stopActiveSpeech();
									playAudioSrc(rec.url).catch(() => {});
								}
							},
							onDeleteRecording: (key) => guardEdit(() => deleteRecording(key)),
							onImportSegmentFile: (key, file) => guardEdit(() => importSegmentAudio(key, file)),
							onCompileInstall: () => guardEdit(compileInstallPack),
							editConfirmOpen,
							onConfirmEdit: confirmEdit,
							onCancelEdit: cancelEdit,
							packNameInput,
							onPackNameInput: setPackNameInput,
							packLangInput,
							onPackLangInput: setPackLangInput,
							onDownloadPack: downloadVoicePack,
							onClose: () => setVoiceSettingsOpen(false),
						})
					: null,
				recordingKey !== null
					? reactDOM.createPortal(
							react.createElement(
								"div",
								{
									role: "dialog",
									"aria-modal": false,
									"aria-label": t("voice.recordingTitle", { label: t(`voice.seg.${recordingKey}`) }),
									style: {
										position: "fixed",
										right: "20px",
										bottom: "20px",
										zIndex: 1004,
										width: "min(320px, 92vw)",
										background: "var(--dsw-specific-menu)",
										border: "1px solid var(--dsw-alias-border-inverted)",
										borderRadius: "12px",
										boxShadow: "var(--dsw-shadow-lv3)",
										padding: "12px 14px",
										display: "flex",
										flexDirection: "column",
										gap: "8px",
									},
								},
								react.createElement(
									"div",
									{
										style: {
											display: "flex",
											alignItems: "center",
											gap: "8px",
											fontSize: "13px",
											fontWeight: 600,
											color: "var(--dsw-alias-label-primary)",
										},
									},
									react.createElement(
										"span",
										{
											style: {
												width: "10px",
												height: "10px",
												borderRadius: "999px",
												background: "#e5484d",
												display: "inline-block",
												animation: "dshAbRecPulse 1s ease-in-out infinite",
											},
										},
									),
									t("voice.recordingTitle", { label: t(`voice.seg.${recordingKey}`) }),
									react.createElement(
										"span",
										{ style: { marginLeft: "auto", fontSize: "12px", color: "var(--dsw-alias-label-secondary)" } },
										`${recElapsed}s`,
									),
								),
								react.createElement("canvas", {
									ref: recCanvasRef,
									width: 288,
									height: 44,
									style: { width: "100%", borderRadius: "8px", background: "var(--dsw-alias-bg-layer-2, transparent)" },
								}),
								react.createElement(
									"p",
									{
										style: {
											margin: 0,
											fontSize: "11px",
											lineHeight: "16px",
											color: "var(--dsw-alias-label-tertiary)",
										},
									},
									t("voice.recordingTip"),
								),
								react.createElement(
									"p",
									{
										style: {
											margin: 0,
											fontSize: "14px",
											lineHeight: "22px",
											color: "var(--dsw-alias-label-primary)",
											fontWeight: 500,
										},
									},
									sampleTextFor(packLangInput, recordingKey),
								),
								react.createElement(
									"div",
									{ style: { display: "flex", gap: "8px" } },
									react.createElement(
										"button",
										{
											type: "button",
											onClick: () => stopRecorder(false),
											style: {
												flex: 1,
												padding: "6px 14px",
												borderRadius: "999px",
												cursor: "pointer",
												border: "1px solid var(--dsw-alias-brand-primary, #4d6bfe)",
												background: "var(--dsw-alias-brand-primary, #4d6bfe)",
												color: "#fff",
												fontSize: "13px",
												lineHeight: "20px",
											},
										},
										t("voice.saveStop"),
									),
									react.createElement(
										"button",
										{
											type: "button",
											onClick: () => stopRecorder(true),
											style: {
												padding: "6px 14px",
												borderRadius: "999px",
												cursor: "pointer",
												border: "1px solid var(--dsw-alias-separator-primary)",
												background: "transparent",
												color: "var(--dsw-alias-label-secondary)",
												fontSize: "13px",
												lineHeight: "20px",
											},
										},
										t("voice.discard"),
									),
								),
							),
							document.body,
						)
					: null,
			);
		}

		/** 中文文案。 */
		const zh = {
			"tab.aria": "面板视图切换",
			"tab.usage": "用量",
			"tab.balance": "余额",
			"usage.aria": "上下文已用 {percent}",
			"usage.headline": "上下文已用",
			"usage.system": "系统提示词",
			"usage.tools": "工具",
			"usage.messages": "对话消息",
			"balance.loading": "查询余额中…",
			"balance.error": "余额查询失败",
			"balance.refresh": "刷新数据",
			"balance.key": "API Key",
			"balance.status": "账户状态",
			"balance.available": "余额充足",
			"balance.unavailable": "余额不足",
			"balance.topup": "充值",
			"balance.topupTitle": "账户充值",
			"balance.topupNote": "DeepSeek 平台的安全验证不允许在面板内嵌充值页面（浏览器阻止第三方 Cookie 后挑战无法通过）。点击下方按钮在新窗口打开充值页面，充值完成后回到本页即可查看最新余额。",
			"balance.topupOpenButton": "打开充值页面",
			"balance.topupClose": "关闭",
			"balance.total": "总余额",
			"balance.today": "当日消耗",
			"balance.month": "当月消耗",
			"balance.last30d": "30日内消耗",
			"balance.in": "入",
			"balance.out": "出",
			"balance.models": "分模型（30日内）",
			"balance.allModels": "全部模型",
			"balance.usage": "用量",
			"balance.noToken": "未连接平台",
			"balance.rescan": "重新扫描本机浏览器",
			"balance.scanning": "正在扫描本机浏览器…",
			"balance.scanHint": "未在本机浏览器检测到平台登录态：请先在浏览器登录 platform.deepseek.com，再点「重新扫描」。",
			"balance.loginPromptTitle": "未检测到平台登录",
			"balance.loginPromptBody": "本机浏览器尚未登录 platform.deepseek.com。点击「前往登录」将在新标签页打开平台登录页；登录完成后回到本页，用量将自动显示。",
			"balance.loginGo": "前往登录",
			"balance.loginChecking": "检测登录中…",
			"balance.loggedIn": "✓ 已登录",
			"balance.loginWaiting": "已在新标签页打开登录页，等待登录完成…（登录后令牌自动获取）",
			"balance.loginTimeout": "尚未检测到登录完成。请确认已在新标签页登录，然后点「重新扫描」。",
			"balance.loginClose": "稍后再说",
			"balance.manualFallback": "手动输入令牌",
			"balance.sourceLabel": "令牌来源",
			"balance.sourceBrowser": "本机浏览器自动获取",
			"balance.sourceManual": "手动连接",
			"chart.title": "用量图表",
			"chart.daily": "按日",
			"chart.monthly": "按月",
			"balance.connect": "连接平台",
			"balance.connecting": "等待授权…",
			"balance.connectGuide": "已打开 platform.deepseek.com/usage 并将授权命令复制到剪贴板：在打开页面的控制台（F12 → Console）粘贴并回车，检测到授权后用量将自动显示。",
			"balance.connectGuideMobile": "在已登录 platform.deepseek.com 的电脑浏览器控制台执行 JSON.parse(localStorage.getItem('userToken')).value，将输出的令牌粘贴到上方输入框保存；或在电脑上完成一次「连接平台」后，本机所有设备自动共享。",
			"balance.connectWaiting": "等待授权回传中… 请切换到刚打开的平台页面，在控制台粘贴已复制的命令并回车。",
			"balance.connectTimeout": "未检测到授权回传。请确认平台页已登录、命令已粘贴回车，然后重试。",
			"balance.manualLink": "手动输入",
			"balance.manualPlaceholder": "粘贴平台令牌…",
			"balance.manualSave": "保存",
			"balance.disconnect": "断开",
			"balance.speechBroadcast": "🔊 播报语音用量",
			"speech.broadcastUsage": "播报当前用量",
			"speech.broadcastBalance": "播报当前余额",
			"speech.testLow": "测试音频：低用量警告",
			"speech.testDead": "测试音频：余额不足警告",
			"balance.speechOn": "🔔 语音提醒：开",
			"balance.speechOff": "🔕 语音提醒：关",
			"speech.dead": "主人，余额不足啦，我快饿晕了，快喂我吃 token！",
			"speech.low": "主人，token 快吃完了，记得喂我哦！",
			"balance.voiceSettings": "⚙ 语音设置",
			"voice.title": "语音设置",
			"voice.close": "关闭",
			"voice.autoLabel": "自动播报（余额不足时提醒）",
			"voice.greetingHint": "开启后每次刷新页面或点击「刷新数据」按钮都会随机播放一个问候音效（语音包问候音频，无则 TTS 问候语）。",
			"voice.ttsBackend": "TTS 后端",
			"voice.ttsWeb": "浏览器内置语音",
			"voice.ttsCustom": "自定义 TTS API",
			"voice.ttsUrlPlaceholder": "https://tts.example.com/speak?text={text}&lang={lang}",
			"voice.ttsUrlHint": "自定义后端经 host 代理调用（避免跨域）；占位符 {text} {lang} {rate}。",
			"voice.test": "试听",
			"voice.ttsTestText": "这是语音设置测试。",
			"voice.packLabel": "语音包",
			"voice.packNone": "未导入",
			"voice.packLoaded": "已导入：{name}（{lang}）",
			"voice.packImport": "导入",
			"voice.packClear": "清除",
			"voice.imported": "导入成功",
			"voice.cleared": "已清除",
			"voice.importFailed": "导入失败：格式不正确",
			"voice.manage": "语音包管理",
			"voice.packListTitle": "语音包库",
			"voice.activeMark": "使用中",
			"voice.removeSelected": "移除所选",
			"voice.removed": "已移除",
			"voice.create": "制作语音包",
			"voice.back": "返回",
			"voice.langLabel": "语音包语言（决定示例文本与清单 lang）",
			"voice.sampleText": "示例文本",
			"voice.recordingTitle": "录制中：{label}",
			"voice.recordingTip": "请朗读下方示例文本",
			"voice.saveStop": "停止并保存",
			"voice.discard": "放弃",
			"voice.packListHint": "点击行切换使用；勾选多行后「移除所选」批量删除。",
			"voice.recorderLabel": "制作语音包（录音或导入音频）",
			"voice.packNamePlaceholder": "语音包名称…",
			"voice.download": "打包下载",
			"voice.downloaded": "已打包下载，可直接分享",
			"voice.compileInstall": "编译并应用",
			"voice.compiled": "已编译并应用本机",
			"voice.importFile": "导入文件",
			"voice.segmentImported": "已导入音频",
			"voice.editWarn": "已导入语音包「{name}」；继续编辑将覆盖其片段。",
			"voice.continue": "继续编辑",
			"voice.cancel": "取消",
			"voice.recordHint": "逐段录制（浏览器麦克风，需授予权限；本地或 HTTPS 环境可用）或导入音频文件，编译为 zip 分享 / 应用本机。",
			"voice.record": "录制",
			"voice.stop": "停止",
			"voice.play": "试听",
			"voice.delete": "删除",
			"voice.recorded": "✓ 已录制",
			"voice.recordDenied": "无法访问麦克风（权限被拒或非安全上下文）",
			"voice.seg.dead": "余额不足提醒",
			"voice.seg.low": "低用量提醒",
			"voice.seg.usage": "用量前缀",
			"voice.seg.balance": "余额前缀",
			"voice.seg.tokenUnit": "单位",
			"voice.seg.month": "当月标签",
			"voice.seg.suffix": "结尾",
		};

		/** 英文文案。 */
		const en = {
			"tab.aria": "Switch panel view",
			"tab.usage": "Usage",
			"tab.balance": "Balance",
			"usage.aria": "{percent} of context used",
			"usage.headline": "Context used",
			"usage.system": "System prompt",
			"usage.tools": "Tools",
			"usage.messages": "Conversation",
			"balance.loading": "Fetching balance…",
			"balance.refresh": "Refresh data",
			"balance.error": "Balance fetch failed",
			"balance.key": "API Key",
			"balance.status": "Status",
			"balance.available": "Available",
			"balance.unavailable": "Insufficient",
			"balance.topup": "Top up",
			"balance.topupTitle": "Top up",
			"balance.topupNote": "DeepSeek's platform security cannot be embedded in this panel (its challenge fails without third-party cookies). Open the top-up page in a new tab and come back — the balance refreshes automatically.",
			"balance.topupOpenButton": "Open top-up page",
			"balance.topupClose": "Close",
			"balance.total": "Total",
			"balance.today": "Today",
			"balance.month": "This month",
			"balance.last30d": "Last 30 days",
			"balance.in": "in",
			"balance.out": "out",
			"balance.models": "By model (30d)",
			"balance.allModels": "All models",
			"balance.usage": "Usage",
			"balance.noToken": "Not connected",
			"balance.rescan": "Rescan local browsers",
			"balance.scanning": "Scanning local browsers…",
			"balance.scanHint": "No platform login found in local browsers: sign in at platform.deepseek.com first, then rescan.",
			"balance.loginPromptTitle": "Platform login not detected",
			"balance.loginPromptBody": "This machine's browser isn't signed in to platform.deepseek.com. Click 「Go to login」 to open the login page in a new tab; once signed in, usage shows automatically.",
			"balance.loginGo": "Go to login",
			"balance.loginChecking": "Checking sign-in…",
			"balance.loggedIn": "✓ Signed in",
			"balance.loginWaiting": "Login page opened in a new tab — waiting for sign-in… (the token is picked up automatically)",
			"balance.loginTimeout": "Sign-in not detected yet. Make sure you signed in on the new tab, then rescan.",
			"balance.loginClose": "Later",
			"balance.manualFallback": "Enter token manually",
			"balance.sourceLabel": "Token source",
			"balance.sourceBrowser": "Auto from local browser",
			"balance.sourceManual": "Manual",
			"chart.title": "Usage chart",
			"chart.daily": "Daily",
			"chart.monthly": "Monthly",
			"balance.connect": "Connect platform",
			"balance.connecting": "Waiting…",
			"balance.connectGuide": "The platform usage page has been opened and the auth command copied to the clipboard: paste it into the console (F12 → Console) of the opened page and press Enter. Usage appears automatically once the token arrives.",
			"balance.connectGuideMobile": "Run JSON.parse(localStorage.getItem('userToken')).value in the console of a desktop browser signed in to platform.deepseek.com, paste the output above and save. Or connect once from a desktop — every device on this machine shares the token automatically.",
			"balance.connectWaiting": "Waiting for the token… Switch to the platform page, paste the copied command into its console, and press Enter.",
			"balance.connectTimeout": "No token received. Make sure you are signed in on the platform page and the command was pasted and run, then retry.",
			"balance.manualLink": "Enter manually",
			"balance.manualPlaceholder": "Paste platform token…",
			"balance.manualSave": "Save",
			"balance.disconnect": "Disconnect",
			"balance.speechBroadcast": "🔊 Speak usage",
			"speech.broadcastUsage": "Speak current usage",
			"speech.broadcastBalance": "Speak current balance",
			"speech.testLow": "Test audio: low-usage warning",
			"speech.testDead": "Test audio: out-of-tokens warning",
			"balance.speechOn": "🔔 Voice alerts: on",
			"balance.speechOff": "🔕 Voice alerts: off",
			"speech.dead": "Master, I'm out of tokens — please feed me!",
			"speech.low": "Master, tokens are running low, remember to feed me!",
			"balance.voiceSettings": "⚙ Voice settings",
			"voice.title": "Voice settings",
			"voice.close": "Close",
			"voice.autoLabel": "Auto broadcast (balance alerts)",
			"voice.greetingHint": "When enabled, a random greeting plays on every page refresh and on each manual 「Refresh data」 click (pack greeting audio, or a TTS greeting otherwise).",
			"voice.ttsBackend": "TTS backend",
			"voice.ttsWeb": "Browser built-in",
			"voice.ttsCustom": "Custom TTS API",
			"voice.ttsUrlPlaceholder": "https://tts.example.com/speak?text={text}&lang={lang}",
			"voice.ttsUrlHint": "Custom backends are called via the host proxy (no CORS issues); placeholders: {text} {lang} {rate}.",
			"voice.test": "Test",
			"voice.ttsTestText": "This is a voice settings test.",
			"voice.packLabel": "Voice pack",
			"voice.packNone": "None",
			"voice.packLoaded": "Loaded: {name} ({lang})",
			"voice.packImport": "Import",
			"voice.packClear": "Clear",
			"voice.imported": "Imported",
			"voice.cleared": "Cleared",
			"voice.importFailed": "Import failed: invalid format",
			"voice.manage": "Manage packs",
			"voice.packListTitle": "Voice pack library",
			"voice.activeMark": "Active",
			"voice.removeSelected": "Remove selected",
			"voice.removed": "Removed",
			"voice.create": "Create a voice pack",
			"voice.back": "Back",
			"voice.langLabel": "Pack language (drives sample texts and manifest lang)",
			"voice.sampleText": "Sample text",
			"voice.recordingTitle": "Recording: {label}",
			"voice.recordingTip": "Read the sample text below",
			"voice.saveStop": "Stop & save",
			"voice.discard": "Discard",
			"voice.packListHint": "Click a row to switch the active pack; check rows to remove in bulk.",
			"voice.recorderLabel": "Create a voice pack (record or import audio)",
			"voice.packNamePlaceholder": "Voice pack name…",
			"voice.download": "Package & download",
			"voice.downloaded": "Packaged — ready to share",
			"voice.compileInstall": "Compile & apply",
			"voice.compiled": "Compiled & applied locally",
			"voice.importFile": "Import file",
			"voice.segmentImported": "Audio imported",
			"voice.editWarn": "A voice pack 「{name}」 is imported; continuing will overwrite its segments.",
			"voice.continue": "Continue",
			"voice.cancel": "Cancel",
			"voice.recordHint": "Record each segment (browser microphone, permission required; localhost or HTTPS only) or import audio files, then compile to a shareable zip / apply locally.",
			"voice.record": "Record",
			"voice.stop": "Stop",
			"voice.play": "Play",
			"voice.delete": "Delete",
			"voice.recorded": "✓ Recorded",
			"voice.recordDenied": "Microphone unavailable (permission denied or insecure context)",
			"voice.seg.dead": "Out-of-tokens alert",
			"voice.seg.low": "Low-usage alert",
			"voice.seg.usage": "Usage prefix",
			"voice.seg.balance": "Balance prefix",
			"voice.seg.tokenUnit": "Unit",
			"voice.seg.month": "This-month label",
			"voice.seg.suffix": "Suffix",
		};

		/**
		 * 隐藏原 ContextMeter 的样式：结构选择器（trigger 是内嵌 14px ring
		 * svg 的 dialog 按钮，且不带本插件的 data 标记）+ dsh 0.1.1-rc.2
		 * 构建类名双保险。`:not()` 排除替代按钮自身，避免结构选择器误伤。
		 */
		const css =
			'button[aria-haspopup="dialog"]:has(> svg[viewBox="0 0 14 14"]):not([data-dsh-api-balance]){display:none!important}' +
			".JObwrW_root:not(:has([data-dsh-api-balance])){display:none!important}" +
			// 加载动画 + 面板滚动条（余额视图内容较长）。
			".dshAbSpin{width:14px;height:14px;border:2px solid var(--dsw-alias-border-l3);" +
			"border-top-color:var(--dsw-alias-label-secondary);border-radius:50%;" +
			"animation:dshAbSpinRot 0.8s linear infinite;display:inline-block;vertical-align:-3px;margin-right:8px}" +
			"@keyframes dshAbSpinRot{to{transform:rotate(360deg)}}" +
			// 录音指示点脉冲动画。
			"@keyframes dshAbRecPulse{0%,100%{opacity:1}50%{opacity:0.3}}" +
			".dshAbPanel{max-height:min(62vh,460px);overflow-y:auto;scrollbar-width:thin}";

		const tagId = `${NS}/client.css`;
		if (typeof document !== "undefined" && document.querySelector(`style[data-plugin-css="${tagId}"]`) === null) {
			const tag = document.createElement("style");
			tag.dataset.plugin = NS;
			tag.dataset.pluginCss = tagId;
			tag.textContent = css;
			document.head.appendChild(tag);
		}

		/** Client 插件声明依赖的 Cordis 服务。 */
		const inject = ["slots", "connection", "locale"];

		/**
		 * Client 插件主体：注册 locale 字典 + 替代圆圈条目。条目经
		 * slots.inject 等待 conversation 声明 `conversation.input.right`
		 * 槽位后注册，挂载后由组件把 DOM 移到原 ContextMeter 位置。
		 */
		function apply(ctx) {
			ctx.effect(() => ctx.locale.register(NS, { zh, en }), "api-balance: dictionaries");
			ctx.slots.inject("conversation.input.right", () =>
				ctx.slots.register(
					{
						name: "conversation.input.right",
						id: "api-balance",
						order: 10,
						locale: NS,
						inject: () => ({
							queryBalance: async (args) => {
								const opts =
									typeof args === "object" && args !== null ? args : { refresh: args === true };
								const result = await ctx.connection.rpc.call("/api", "api-balance/query", {
									args: {
										refresh: opts.refresh === true,
										rescanBrowsers: opts.rescanBrowsers === true,
									},
								});
								return result;
							},
							clearToken: async () => {
								try {
									await fetch(`${window.location.origin}/api/api-balance/token/clear`, {
										method: "POST",
									});
								} catch {
									// 断开失败仅影响本机令牌清理，忽略
								}
							},
							// LocaleFace：播报语音语言与音色跟随 DSH 界面语言
							// （subscribe/getSnapshot 以闭包绑定实例方法）。
							localeFace: {
								subscribe: (callback) => ctx.locale.subscribe(callback),
								getSnapshot: () => ctx.locale.getSnapshot(),
							},
						}),
					},
					ApiBalanceMeter,
				),
			);
		}
		//#endregion
		exports.ApiBalanceMeter = ApiBalanceMeter;
		exports.apply = apply;
		exports.inject = inject;
		return module.exports;
	},
});
