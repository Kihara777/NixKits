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
		 * 在 `conversation.input.right` 注册一个视觉与行为完全兼容的替代圆圈，
		 * 其弹出面板顶部带「用量 | 余额」标签切换：
		 *  - 「用量」（默认）= 原 ContextMeter 面板内容（上下文已用百分比、
		 *    占用条、系统提示词 / 工具 / 对话消息细分），数据源同为
		 *    `contextPressure` / `contextBreakdown` 投影；
		 *  - 「余额」= 当前 API KEY 的账户信息（key 尾号、余额是否充足、
		 *    各币种总余额 / 充值余额 / 赠送余额），经 host 端
		 *    `api-balance/query` RPC 获取。
		 *
		 * 原 ContextMeter 按钮经 CSS 隐藏（结构选择器 + dsh 0.1.1-rc.2 的
		 * 构建类名双保险）；两者渲染位置相邻且仅此一处，隐藏后替代圆圈即
		 * 「发送按钮左侧的圆圈」。
		 *
		 * @module @kihara777/dsh-api-balance/client
		 */
		let react = require("react");
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
			return `${(n / 1_000_000).toFixed(1)}M`;
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
		 * 替代圆圈组件。props 为框架标准 props（useProjection、t）+ 注册时
		 * inject 的 owner face（queryBalance）。
		 */
		function ApiBalanceMeter({ useProjection, t, queryBalance }) {
			const pressure = useProjection("contextPressure");
			const breakdown = useProjection("contextBreakdown");
			const [open, setOpen] = react.useState(false);
			const [tab, setTab] = react.useState(TAB_USAGE);
			const [balance, setBalance] = react.useState(null);
			const [balanceState, setBalanceState] = react.useState("idle");
			const rootRef = react.useRef(null);
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

			const switchTab = (next) => {
				setTab(next);
				if (next === TAB_BALANCE && balanceState === "idle") {
					setBalanceState("loading");
					queryBalance()
						.then((result) => {
							if (result !== null && typeof result === "object" && result.ok === true) {
								setBalance(result.value);
								setBalanceState("ok");
							} else {
								setBalance(null);
								setBalanceState("error");
							}
						})
						.catch(() => {
							setBalance(null);
							setBalanceState("error");
						});
				}
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

			// 「余额」标签内容：当前 API KEY 的账户信息。
			let balanceBody = null;
			if (balanceState === "loading") {
				balanceBody = react.createElement("span", { style: { color: "var(--dsw-alias-label-tertiary)" } }, t("balance.loading"));
			} else if (balanceState === "error" || balance === null) {
				balanceBody = react.createElement(
					"span",
					{ style: { color: "var(--dsw-alias-danger-primary, #e5484d)" } },
					t("balance.error"),
				);
			} else {
				const infos = Array.isArray(balance.balanceInfos) ? balance.balanceInfos : [];
				const rows = [];
				if (typeof balance.keyHint === "string" && balance.keyHint.length > 0) {
					rows.push([t("balance.key"), balance.keyHint]);
				}
				rows.push([t("balance.status"), balance.isAvailable === true ? t("balance.available") : t("balance.unavailable")]);
				for (const info of infos) {
					const currency = info.currency ?? "CNY";
					if (info.totalBalance !== null) rows.push([`${t("balance.total")} (${currency})`, info.totalBalance]);
					if (info.toppedUpBalance !== null) rows.push([t("balance.toppedUp"), info.toppedUpBalance]);
					if (info.grantedBalance !== null) rows.push([t("balance.granted"), info.grantedBalance]);
				}
				balanceBody = react.createElement(
					"dl",
					{ style: { margin: 0 } },
					rows.map(([label, value], index) =>
						react.createElement(
							"div",
							{
								key: `${label}-${index}`,
								style: {
									justifyContent: "space-between",
									alignItems: "center",
									gap: "12px",
									padding: "2px 0",
									display: "flex",
								},
							},
							react.createElement("dt", { style: { color: "var(--dsw-alias-label-secondary)", margin: 0 } }, label),
							react.createElement(
								"dd",
								{
									style: {
										fontVariantNumeric: "tabular-nums",
										color: "var(--dsw-alias-label-primary)",
										margin: 0,
									},
								},
								value,
							),
						),
					),
				);
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
							"aria-label": t("usage.headline"),
							style: {
								zIndex: 100,
								boxSizing: "border-box",
								border: "1px solid var(--dsw-alias-border-inverted)",
								background: "var(--dsw-specific-menu)",
								width: "264px",
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
							{
								role: "tablist",
								"aria-label": t("tab.aria"),
								style: { display: "flex", gap: "4px", marginBottom: "12px" },
							},
							tabButton(TAB_USAGE, tab === TAB_USAGE),
							tabButton(TAB_BALANCE, tab === TAB_BALANCE),
						),
						tab === TAB_USAGE ? usageBody : balanceBody,
					),
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
			"balance.key": "API Key",
			"balance.status": "账户状态",
			"balance.available": "余额充足",
			"balance.unavailable": "余额不足",
			"balance.total": "总余额",
			"balance.toppedUp": "充值余额",
			"balance.granted": "赠送余额",
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
			"balance.error": "Balance fetch failed",
			"balance.key": "API Key",
			"balance.status": "Status",
			"balance.available": "Available",
			"balance.unavailable": "Insufficient",
			"balance.total": "Total",
			"balance.toppedUp": "Top-up",
			"balance.granted": "Granted",
		};

		/**
		 * 隐藏原 ContextMeter 的样式：结构选择器（trigger 是内嵌 14px ring
		 * svg 的 dialog 按钮）+ dsh 0.1.1-rc.2 构建类名双保险。只影响该按钮。
		 */
		const css =
			'button[aria-haspopup="dialog"]:has(> svg[viewBox="0 0 14 14"]){display:none!important}' +
			".JObwrW_root{display:none!important}";

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
		 * 槽位后注册（渲染在原 ContextMeter 左侧同一工具行）。
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
							queryBalance: async () => {
								const result = await ctx.connection.rpc.call("/api", "api-balance/query", { args: {} });
								return result;
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
