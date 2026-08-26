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

		/**
		 * 语音喊饿（Web Speech API，中文优先）。余额不足时提醒主人；
		 * 30 分钟限流防重复，浏览器不支持时静默降级。
		 */
		function speakHungry(text) {
			try {
				if (typeof window === "undefined" || !speechEnabled()) return;
				const synth = window.speechSynthesis;
				if (synth === void 0) return;
				const now = Date.now();
				if (now - lastHungrySpeechAt < HUNGRY_SPEECH_INTERVAL_MS) return;
				lastHungrySpeechAt = now;
				const utter = new SpeechSynthesisUtterance(text);
				utter.lang = "zh-CN";
				utter.rate = 1.05;
				const voices = synth.getVoices();
				const zh = voices.find((voice) => voice.lang.toLowerCase().startsWith("zh"));
				if (zh !== void 0) utter.voice = zh;
				synth.cancel();
				synth.speak(utter);
			} catch {
				// 语音不可用（无语音引擎/自动播放策略）时静默
			}
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

		/** 根据饥饿状态播报对应文案（受限流约束）。 */
		function announceHunger(t, balance) {
			const state = hungryState(balance);
			if (state === "dead") speakHungry(t("speech.dead"));
			else if (state === "low") speakHungry(t("speech.low"));
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
		 * 替代圆圈组件。props 为框架标准 props（useProjection、t）+ 注册时
		 * inject 的 owner face（queryBalance、clearToken）。
		 */
		function ApiBalanceMeter({ useProjection, t, queryBalance, clearToken }) {
			const pressure = useProjection("contextPressure");
			const breakdown = useProjection("contextBreakdown");
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
			const touchDevice = isTouchDevice();
			const context = contextOccupancy(pressure);
			const available = context !== null;

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

			const load = (refresh) => {
				setBalanceState("loading");
				return queryBalance(refresh)
					.then((result) => {
						if (result !== null && typeof result === "object" && result.ok === true) {
							setBalance(result.value);
							setBalanceState("ok");
							announceHunger(t, result.value);
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
			 * 一键授权：打开平台用量页，把回传命令写入剪贴板，并开始轮询
			 * 检测令牌是否回传成功；成功后自动加载官方用量数据，无需用户
			 * 再抄录任何内容。
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
				let attempts = 0;
				const poll = async () => {
					attempts += 1;
					try {
						const value = await queryBalance(true);
						if (value !== null && typeof value === "object" && value.ok === true) {
							const usage = value.value?.usage;
							if (usage !== null && typeof usage === "object" && usage.status !== "no-token") {
								setBalance(value.value);
								setBalanceState("ok");
								setConnectState("idle");
								return;
							}
						}
					} catch {
						// 轮询失败继续尝试
					}
					if (attempts < 24) {
						pollRef.current = window.setTimeout(poll, 2500);
					} else {
						setConnectState("timeout");
					}
				};
				poll();
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
			const hungerPollRef = react.useRef(null);
			react.useEffect(() => {
				let cancelled = false;
				const poll = async () => {
					const value = await queryBalance(true).catch(() => null);
					if (cancelled || value === null || typeof value !== "object" || value.ok !== true) return;
					setBalance(value.value);
					setBalanceState("ok");
					announceHunger(t, value.value);
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
				// no-token：授权 UI。桌面端走一键授权（打开平台页 + 剪贴板
				// 回传命令 + 自动轮询）；触屏设备无 DevTools 控制台，直接
				// 展开手动令牌输入框（同源 POST 保存）。桌面端也提供
				// 「手动输入」折叠入口作为备用通道。
				if (usage !== null && usage.status === "no-token") {
					const waiting = connectState === "waiting";
					const showManual = touchDevice || manualOpen;
					const connectButton = touchDevice
						? null
						: react.createElement(
								"button",
								{
									type: "button",
									disabled: waiting,
									onClick: () => (waiting ? void 0 : startConnect()),
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
								waiting ? t("balance.connecting") : t("balance.connect"),
							);
					const manualLink =
						touchDevice || waiting
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
								? t("balance.connectWaiting")
								: connectState === "timeout"
									? t("balance.connectTimeout")
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
				// 已连接：提供断开入口（清除本机令牌）。
				if (usage !== null && usage.status !== "no-token") {
					balanceBody = react.createElement(
						react.Fragment,
						null,
						balanceBody,
						react.createElement(
							"div",
							{ style: { display: "flex", gap: "8px", alignItems: "center", marginTop: "10px" } },
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
							react.createElement(
								"button",
								{
									type: "button",
									"aria-pressed": speechOn,
									onClick: toggleSpeech,
									style: {
										display: "inline-flex",
										alignItems: "center",
										gap: "4px",
										padding: "1px 10px",
										borderRadius: "999px",
										cursor: "pointer",
										border: "1px solid var(--dsw-alias-separator-primary)",
										background: speechOn ? "var(--dsw-alias-interactive-bg-hover)" : "transparent",
										color: speechOn ? "var(--dsw-alias-label-secondary)" : "var(--dsw-alias-label-tertiary)",
										fontSize: "11px",
										lineHeight: "18px",
									},
								},
								speechOn ? t("balance.speechOn") : t("balance.speechOff"),
							),
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
			"balance.speechOn": "🔔 语音提醒：开",
			"balance.speechOff": "🔕 语音提醒：关",
			"speech.dead": "主人，余额不足啦，我快饿晕了，快喂我吃 token！",
			"speech.low": "主人，token 快吃完了，记得喂我哦！",
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
			"balance.speechOn": "🔔 Voice alerts: on",
			"balance.speechOff": "🔕 Voice alerts: off",
			"speech.dead": "Master, I'm out of tokens — please feed me!",
			"speech.low": "Master, tokens are running low, remember to feed me!",
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
							queryBalance: async (refresh) => {
								const result = await ctx.connection.rpc.call("/api", "api-balance/query", {
									args: { refresh: refresh === true },
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
