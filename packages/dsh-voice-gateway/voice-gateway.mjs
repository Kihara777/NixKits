#!/usr/bin/env node
/**
 * voice-gateway —— TTS 网关（2026-11-15）
 *
 * ## 它为什么存在
 *
 * 同一个声音能力有两个消费者：dsh 的 Web UI（api-balance 插件）和 Telegram
 * （Kitsunome 的 wake-once）。**两边各写一遍「调 Breeze + 包 WAV 头」，
 * 就是两份会漂的实现。** 这一层只写一次。
 *
 * ## 它守的三条
 *
 * 1. **目标地址写死。** 只连配置里的 `--breeze`（默认 127.0.0.1:18605），
 *    不接受请求里传来的 URL。所以它不碰 api-balance 那条 SSRF 防线——
 *    那条防的是「用户填任意地址」，这里没有用户填的余地。
 *
 * 2. **参考素材只在这里。** `--ref-audio` / `--ref-text-file` 从磁盘读，
 *    **请求参数里没有这两个字段**，浏览器就算想传也传不进来。
 *    私密部分不进插件、不进浏览器、不进 git。
 *
 * 3. **WAV 头自己写。** Breeze 的流式输出把长度写成 0xFFFFFFFF（2026-11-13 实测：
 *    `tts_wav_fix` 那个补丁修的就是这个），裸 PCM 交出去浏览器放不了。
 *    这里按实际字节数重写 44 字节头。
 *
 * ## 用法
 *
 *   node voice-gateway.mjs --breeze http://127.0.0.1:18605 \
 *        --ref-audio /path/ref.wav --ref-text-file /path/ref.txt \
 *        --port 8605
 *
 *   POST /speak   { "text": "..." }        → audio/wav
 *   GET  /health                            → { ok, breeze, voice }
 */
import { createServer } from 'node:http'
import { readFileSync } from 'node:fs'

const args = process.argv.slice(2)
const argOf = (name, dflt) => {
	const i = args.indexOf(`--${name}`)
	return i >= 0 && args[i + 1] !== undefined ? args[i + 1] : dflt
}

const BREEZE = argOf('breeze', 'http://127.0.0.1:18605').replace(/\/+$/, '')
const PORT = Number(argOf('port', '8605'))
const HOST = argOf('host', '127.0.0.1')      // **只本机**：局域网由 8625 的反代进来
const REF_AUDIO = argOf('ref-audio', '')
const REF_TEXT_FILE = argOf('ref-text-file', '')
const VOICE_ID = argOf('voice-id', '')       // 已注册的音色 id（优先于 ref 文件）
const MAX_CHARS = Number(argOf('max-chars', '2000'))

/** 把裸 PCM（s16le 单声道）包成 WAV。 */
function pcmToWav(pcm, sampleRate = 24000, channels = 1, bits = 16) {
	const byteRate = sampleRate * channels * bits / 8
	const blockAlign = channels * bits / 8
	const head = Buffer.alloc(44)
	head.write('RIFF', 0)
	head.writeUInt32LE(36 + pcm.length, 4)      // 文件长 = 36 + 数据长
	head.write('WAVE', 8)
	head.write('fmt ', 12)
	head.writeUInt32LE(16, 16)                  // fmt 块大小
	head.writeUInt16LE(1, 20)                   // PCM
	head.writeUInt16LE(channels, 22)
	head.writeUInt32LE(sampleRate, 24)
	head.writeUInt32LE(byteRate, 28)
	head.writeUInt16LE(blockAlign, 32)
	head.writeUInt16LE(bits, 34)
	head.write('data', 36)
	head.writeUInt32LE(pcm.length, 40)          // **真实字节数**，不写 0xFFFFFFFF
	return Buffer.concat([head, pcm])
}

let refText = ''
if (REF_TEXT_FILE !== '') {
	try {
		refText = readFileSync(REF_TEXT_FILE, 'utf8').trim()
	} catch (error) {
		console.error(`参考文稿读不出来（${REF_TEXT_FILE}）：${error?.message ?? error}`)
		process.exit(2)
	}
}

/** 中文听感上不必念的符号，去掉能少几帧噪声。 */
function cleanText(t) {
	return String(t).replace(/```[\s\S]*?```/g, '代码块').replace(/[`*#>_~]/g, '').trim()
}

const server = createServer(async (req, res) => {
	const url = new URL(req.url ?? '/', `http://${req.headers.host ?? 'x'}`)

	if (url.pathname === '/health') {
		res.writeHead(200, { 'content-type': 'application/json' })
		res.end(JSON.stringify({
			ok: true, breeze: BREEZE, port: PORT,
			voice: VOICE_ID !== '' ? VOICE_ID : (REF_AUDIO !== '' ? 'reference-audio' : 'none'),
		}))
		return
	}

	if (url.pathname !== '/speak' || req.method !== 'POST') {
		res.writeHead(404, { 'content-type': 'application/json' })
		res.end(JSON.stringify({ ok: false, error: 'not found' }))
		return
	}

	// 读 body
	let raw = ''
	for await (const chunk of req) {
		raw += chunk
		if (raw.length > 64 * 1024) { res.writeHead(413); res.end(); return }
	}
	let text = ''
	try {
		text = cleanText(JSON.parse(raw).text ?? '')
	} catch {
		res.writeHead(400, { 'content-type': 'application/json' })
		res.end(JSON.stringify({ ok: false, error: 'invalid json' }))
		return
	}
	if (text === '') {
		res.writeHead(400, { 'content-type': 'application/json' })
		res.end(JSON.stringify({ ok: false, error: 'text is required' }))
		return
	}
	if (text.length > MAX_CHARS) text = text.slice(0, MAX_CHARS)

	// 调 Breeze。**地址是常量拼接**，请求方无从影响。
	try {
		const form = new FormData()
		form.append('text', text)
		if (VOICE_ID !== '') {
			form.append('voice_id', VOICE_ID)
		} else if (REF_AUDIO !== '') {
			// 只有配置里指了才会走这条；参考音频由本进程读盘后上传
			form.append('ref_audio', new Blob([readFileSync(REF_AUDIO)]), 'ref.wav')
			if (refText !== '') form.append('ref_text', refText)
		} else {
			res.writeHead(503, { 'content-type': 'application/json' })
			res.end(JSON.stringify({ ok: false, error: 'no voice configured' }))
			return
		}

		const t0 = Date.now()
		const upstream = await fetch(`${BREEZE}/v1/audio/speech`, { method: 'POST', body: form })
		if (!upstream.ok) {
			const msg = await upstream.text().catch(() => '')
			res.writeHead(502, { 'content-type': 'application/json' })
			res.end(JSON.stringify({ ok: false, error: `breeze ${upstream.status}`, detail: msg.slice(0, 200) }))
			return
		}
		const pcm = Buffer.from(await upstream.arrayBuffer())
		const wav = pcmToWav(pcm)
		res.writeHead(200, {
			'content-type': 'audio/wav',
			'content-length': String(wav.length),
			'x-speak-ms': String(Date.now() - t0),
			'x-audio-seconds': (pcm.length / 2 / 24000).toFixed(2),
			// 同源使用不需要 CORS；这里不加，避免把能力暴露给任意页面
		})
		res.end(wav)
	} catch (error) {
		// **失败要说清楚是什么坏了**（2026-11-15）：「fetch failed」这种话
		// 前端没法据此判断该降级还是该报错。区分「连不上」与「其它」。
		const msg = String(error?.message ?? error)
		const unreachable = /fetch failed|ECONNREFUSED|ENOTFOUND|EAI_AGAIN/i.test(msg)
		res.writeHead(502, { 'content-type': 'application/json' })
		res.end(JSON.stringify({
			ok: false,
			error: unreachable ? 'breeze-unreachable' : msg,
			hint: unreachable ? 'Breeze 没在跑或被重启了；前端应降级到浏览器 TTS' : undefined,
			breeze: BREEZE,
		}))
	}
})

server.listen(PORT, HOST, () => {
	console.log(`voice-gateway on http://${HOST}:${PORT} → breeze ${BREEZE}`)
	console.log(`  voice: ${VOICE_ID !== '' ? VOICE_ID : (REF_AUDIO || 'none')}`)
})
