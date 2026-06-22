#!/usr/bin/env python3
"""偽中国語 translator: Japanese → pcn."""

import re, sys, os

DICT_PATH = "/home/kix/NixKits/skills/translate-pseudocn/dictionary.md"

def load_dict(path):
    m = {}
    with open(path, encoding="utf-8") as f:
        in_t = False
        for line in f:
            line = line.strip()
            if line.startswith("|") and "片假名" in line:
                in_t = True; continue
            if in_t and line.startswith("|") and not line.startswith("|---"):
                p = [x.strip() for x in line.split("|")]
                if len(p) >= 3 and p[1] and p[2]:
                    m[p[1]] = p[2]
    return m

DICT = load_dict(DICT_PATH)
DICT_KEYS = sorted(DICT.keys(), key=len, reverse=True)

def _cp(c): return ord(c)
def is_hira(ch):
    return 0x3041 <= _cp(ch) <= 0x3094
def is_hira_strip(ch):
    c = _cp(ch)
    if c in (0x3099,0x309A,0x309B,0x309C): return False
    return 0x3040 <= c <= 0x309F
def is_kata(ch):
    return 0x30A0 <= _cp(ch) <= 0x30FF
def is_kata_hw(ch):
    return 0xFF65 <= _cp(ch) <= 0xFF9F
def is_kata_any(ch):
    return is_kata(ch) or is_kata_hw(ch)
def is_prol(ch):
    return _cp(ch) == 0x30FC
def is_kanji(ch):
    c = _cp(ch)
    return (0x4E00 <= c <= 0x9FFF or 0x3400 <= c <= 0x4DBF or
            0xF900 <= c <= 0xFAFF or 0x20000 <= c <= 0x2A6DF)
def is_voiced(ch):
    return _cp(ch) in (0x3099,0x309A,0x309B,0x309C,0xFF9E,0xFF9F)

def strip_hira(text):
    r = []
    for ch in text:
        if ch == 'の': r.append('之')
        elif is_hira_strip(ch): continue
        else: r.append(ch)
    return ''.join(r)

def replace_kata(text):
    """Greedy longest-match katakana→kanji. Unmatched kept, ー stripped."""
    r = []
    i = 0
    while i < len(text):
        ch = text[i]
        if is_kata_any(ch) or is_prol(ch) or is_voiced(ch):
            j = i
            while j < len(text):
                cj = text[j]
                if is_kata_any(cj) or is_prol(cj) or is_voiced(cj):
                    j += 1
                else:
                    break
            run = text[i:j]
            # Also gather any following voiced mark
            pos = 0
            while pos < len(run):
                best = None
                for key in DICT_KEYS:
                    if run.startswith(key, pos):
                        if best is None or len(key) > len(best):
                            best = key
                if best:
                    if pos > 0:
                        pre = run[:pos]
                        pre = ''.join(c for c in pre if not is_prol(c))
                        r.append(pre)
                    r.append(DICT[best])
                    pos += len(best)
                else:
                    if not is_prol(run[pos]):
                        r.append(run[pos])
                    pos += 1
            i = j
        else:
            r.append(ch)
            i += 1
    return ''.join(r)

VERBS = {
    '提供','修正','管理','設定','使用','導入','実行',
    '削除','追加','変更','更新','確認','検証','検出',
    '対応','追従','保持','生成','記録','作成','復元',
    '変換','翻訳','置換','除去','適用','参照','表示',
    '起動','停止','開始','終了','保存','読取','書込',
    '送信','受信','接続','切断','登録','解除','有効',
    '無効','宣言','定義','注入','構成','構築',
    '含','必要','可能','推奨','必須','許可','防止',
    '報告','識別','処理','比較','期待','存在',
    '通過','変更','回復','要求','発見',
}

def svo(text):
    s = text.strip()
    if not s or s.startswith('|') or s.startswith('#') or s.startswith('>'):
        return text
    words = text.split()
    if len(words) < 2: return text
    last = words[-1]
    punct = ''
    if last and last[-1] in '。！？':
        punct = last[-1]; last = last[:-1]
    if last in VERBS:
        prev = words[-2]
        if any(is_kanji(c) for c in prev) and not prev.startswith('`'):
            words[-2], words[-1] = last, prev
            if punct: words[-1] += punct
    return ' '.join(words)

def lang_sw(line, ja_rel):
    parts = re.split(r'\s*\|\s*', line)
    new = []
    for part in parts:
        part = part.strip()
        m = re.match(r'\[([^\]]+)\]\(([^)]+)\)', part)
        if m:
            name, url = m.group(1), m.group(2)
            if name == '偽中国語': new.append('偽中国語')
            elif name == '日本語': new.append(f'[日本語]({ja_rel})')
            else: new.append(part)
        else:
            if part == '日本語': new.append(f'[日本語]({ja_rel})')
            elif part == '偽中国語': new.append('偽中国語')
            else: new.append(part)
    return ' | '.join(new)

def transform(text):
    text = strip_hira(text)
    text = replace_kata(text)
    parts = re.split(r'([。！？])', text)
    out = []
    for p in parts:
        if p in ('。','！','？'): out.append(p)
        else: out.append(svo(p))
    text = ''.join(out)
    text = re.sub(r'  +', ' ', text)
    text = re.sub(r' ([。、！？）】」』])', r'\1', text)
    text = re.sub(r'([（【「『]) ', r'\1', text)
    return text

def process(inpath, outpath):
    with open(inpath, encoding="utf-8") as f:
        content = f.read()
    lines = content.split('\n')
    result = []
    i = 0
    in_fence = False
    fname = os.path.basename(outpath)
    if '/skills/' in outpath:
        ja_rel = '../../ja/skills/' + fname
    elif outpath.endswith('README.pcn.md'):
        ja_rel = 'README.ja.md'
    elif outpath.endswith('MAINTENANCE.pcn.md'):
        ja_rel = 'docs/MAINTENANCE.ja.md'
    else:
        ja_rel = '../ja/' + fname

    while i < len(lines):
        line = lines[i]
        ls = line.strip()
        if ls.startswith('```'):
            if not in_fence:
                in_fence = True; result.append(line); i += 1
                while i < len(lines):
                    inner = lines[i]; result.append(inner)
                    if inner.strip().startswith('```'):
                        in_fence = False; i += 1; break
                    i += 1
                continue
        if in_fence:
            result.append(line); i += 1; continue
        if ('日本語' in line or '偽中国語' in line) and '|' in line and \
           any(x in line for x in ['中文','English','ｶﾀﾘｯｼｭ']):
            result.append(lang_sw(line, ja_rel)); i += 1; continue
        result.append(transform(line)); i += 1

    os.makedirs(os.path.dirname(outpath), exist_ok=True)
    with open(outpath, "w", encoding="utf-8") as f:
        f.write('\n'.join(result))
    print(f"  -> {outpath}")

def main():
    bj = "/home/kix/NixKits/docs/ja"
    bp = "/home/kix/NixKits/docs/pcn"
    for fn in sorted(os.listdir(bj)):
        if fn.endswith('.md'):
            print(f"Processing: {fn}")
            process(os.path.join(bj, fn), os.path.join(bp, fn))
    sj = os.path.join(bj, "skills")
    sp = os.path.join(bp, "skills")
    if os.path.isdir(sj):
        for fn in sorted(os.listdir(sj)):
            if fn.endswith('.md'):
                print(f"Processing: skills/{fn}")
                process(os.path.join(sj, fn), os.path.join(sp, fn))
    for src, dst in [
        ("/home/kix/NixKits/docs/README.ja.md", "/home/kix/NixKits/docs/README.pcn.md"),
        ("/home/kix/NixKits/docs/MAINTENANCE.ja.md", "/home/kix/NixKits/docs/MAINTENANCE.pcn.md"),
    ]:
        if os.path.exists(src):
            print(f"Processing: {os.path.basename(src)}")
            process(src, dst)
    print("\nDone.")

if __name__ == "__main__":
    main()
