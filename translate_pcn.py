#!/usr/bin/env python3
"""偽中国語 (pseudo-Chinese) translator: Japanese → pcn.

Transformation pipeline per line:
1. Strip hiragana (の→之 preserved; combining marks U+3099-U+309C excluded)
2. Katakana dict lookup (longest-match against DICT, keep unmatched as-is)
3. Kanji preserved
4. SOV→SVO (heuristic verb-before-object swap)
5. Particles stripped (already done via hiragana removal)
6. Japanese punctuation preserved
7. Code blocks: fences and content untouched
8. Language switcher: 日本語→[日本語](link), 偽中国語→plain text
"""

import re
import sys
import os

# ── Dictionary ──────────────────────────────────────────────
DICT_PATH = "/home/kix/NixKits/skills/translate-pseudocn/dictionary.md"

def load_dictionary(path):
    mapping = {}
    with open(path, "r", encoding="utf-8") as f:
        in_table = False
        for line in f:
            line = line.strip()
            if line.startswith("|") and "片假名" in line:
                in_table = True
                continue
            if in_table and line.startswith("|") and not line.startswith("|---"):
                parts = [p.strip() for p in line.split("|")]
                if len(parts) >= 3 and parts[1] and parts[2]:
                    kana, kanji = parts[1], parts[2]
                    if kana and kanji:
                        mapping[kana] = kanji
    return mapping

DICT = load_dictionary(DICT_PATH)
DICT_KEYS = sorted(DICT.keys(), key=len, reverse=True)  # longest first

# ── Unicode helpers ────────────────────────────────────────
def _cp(ch):
    return ord(ch)

def is_hiragana(ch):
    """True for hiragana letters U+3041-U+3094.
    Excludes combining marks U+3099-U+309C (used with katakana too)."""
    c = _cp(ch)
    return 0x3041 <= c <= 0x3094  # 3095-309F are small/archaic, strip those too? Keep safe.

def is_hiragana_or_combining(ch):
    """Hiragana + combining marks that should be stripped.
    We strip U+3040-U+309F EXCEPT we handle voiced marks specially."""
    c = _cp(ch)
    # U+3099 COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK
    # U+309A COMBINING KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK
    # These are used with katakana and should NOT be stripped.
    # U+309B KATAKANA-HIRAGANA VOICED SOUND MARK (spacing)
    # U+309C KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK (spacing)
    if c in (0x3099, 0x309A, 0x309B, 0x309C):
        return False  # keep — used with katakana
    return 0x3040 <= c <= 0x309F

def is_katakana(ch):
    """Full-width katakana block U+30A0-U+30FF."""
    c = _cp(ch)
    return 0x30A0 <= c <= 0x30FF

def is_katakana_half(ch):
    """Half-width katakana U+FF65-U+FF9F."""
    c = _cp(ch)
    return 0xFF65 <= c <= 0xFF9F

def is_katakana_any(ch):
    return is_katakana(ch) or is_katakana_half(ch)

def is_prolonged(ch):
    """Prolonged sound mark ー (U+30FC)."""
    return _cp(ch) == 0x30FC

def is_kanji(ch):
    c = _cp(ch)
    return (0x4E00 <= c <= 0x9FFF or
            0x3400 <= c <= 0x4DBF or
            0xF900 <= c <= 0xFAFF or
            0x20000 <= c <= 0x2A6DF)

def is_voiced_mark(ch):
    """Combining or spacing voiced/semi-voiced marks."""
    return _cp(ch) in (0x3099, 0x309A, 0x309B, 0x309C, 0xFF9E, 0xFF9F)

# ── Step 1: Strip hiragana ─────────────────────────────────
def strip_hiragana(text):
    """Strip hiragana except の→之. Keep voiced marks (used with katakana)."""
    result = []
    for ch in text:
        if ch == 'の':
            result.append('之')
        elif is_hiragana_or_combining(ch):
            continue  # strip
        else:
            result.append(ch)
    return ''.join(result)

# ── Step 2: Katakana replacement ───────────────────────────
def replace_katakana(text):
    """Longest-match katakana→kanji via DICT. Unmatched katakana kept, ー removed."""
    result = []
    i = 0
    while i < len(text):
        ch = text[i]
        if is_katakana_any(ch) or is_prolonged(ch) or is_voiced_mark(ch):
            # Gather a run of katakana + prolonged marks + voiced marks
            j = i
            while j < len(text):
                cj = text[j]
                if is_katakana_any(cj) or is_prolonged(cj) or is_voiced_mark(cj):
                    j += 1
                else:
                    break
            run = text[i:j]
            
            # Try greedy longest-match on the original run
            pos = 0
            while pos < len(run):
                best_key = None
                for key in DICT_KEYS:
                    if run.startswith(key, pos):
                        if best_key is None or len(key) > len(best_key):
                            best_key = key
                
                if best_key:
                    # Output any unmatched prefix (keep but strip ー)
                    if pos > 0:
                        prefix = run[:pos]
                        # Strip prolonged marks from the prefix
                        prefix_clean = ''.join(c for c in prefix if not is_prolonged(c))
                        result.append(prefix_clean)
                    
                    result.append(DICT[best_key])
                    pos += len(best_key)
                else:
                    # Keep this character (but strip prolonged marks)
                    if not is_prolonged(run[pos]):
                        result.append(run[pos])
                    pos += 1
            
            i = j
        else:
            result.append(ch)
            i += 1
    return ''.join(result)

# ── Step 4: SOV → SVO ──────────────────────────────────────
VERB_SET = {
    '提供', '修正', '管理', '設定', '使用', '導入', '実行',
    '削除', '追加', '変更', '更新', '確認', '検証', '検出',
    '対応', '追従', '保持', '生成', '記録', '作成', '復元',
    '変換', '翻訳', '置換', '除去', '適用', '参照', '表示',
    '起動', '停止', '開始', '終了', '保存', '読取', '書込',
    '送信', '受信', '接続', '切断', '登録', '解除', '有効',
    '無効', '宣言', '定義', '注入', '構成', '構築',
    '含', '必要', '可能', '推奨', '必須', '許可', '防止',
    '報告', '識別', '処理', '比較', '期待', '存在',
    '通過', '変更', '回復', '除去', '要求', '発見',
}

def _is_verb(w):
    return w.rstrip('。！？') in VERB_SET

def apply_sov_to_svo(text):
    """If last word is a verb and preceding word contains kanji, swap them."""
    stripped = text.strip()
    if not stripped or stripped.startswith('|') or stripped.startswith('#') or stripped.startswith('>'):
        return text
    
    words = text.split()
    if len(words) < 2:
        return text
    
    last = words[-1]
    punct = ''
    if last and last[-1] in '。！？':
        punct = last[-1]
        last = last[:-1]
    
    if last in VERB_SET:
        prev = words[-2]
        if any(is_kanji(c) for c in prev) and not prev.startswith('`'):
            # Swap
            words[-2], words[-1] = last, prev
            if punct:
                words[-1] = words[-1] + punct
    
    return ' '.join(words)

# ── Step 8: Language switcher ──────────────────────────────
def transform_lang_switcher(line, ja_rel):
    """日本語 gets link; 偽中国語 becomes plain text."""
    parts = re.split(r'\s*\|\s*', line)
    new = []
    for part in parts:
        part = part.strip()
        m = re.match(r'\[([^\]]+)\]\(([^)]+)\)', part)
        if m:
            name, url = m.group(1), m.group(2)
            if name == '偽中国語':
                new.append('偽中国語')
            elif name == '日本語':
                new.append(f'[日本語]({ja_rel})')
            else:
                new.append(part)
        else:
            if part == '日本語':
                new.append(f'[日本語]({ja_rel})')
            elif part == '偽中国語':
                new.append('偽中国語')
            else:
                new.append(part)
    return ' | '.join(new)

# ── Full text transform ────────────────────────────────────
def transform_text(text):
    text = strip_hiragana(text)
    text = replace_katakana(text)
    
    # SOV→SVO per sentence
    parts = re.split(r'([。！？])', text)
    out = []
    for p in parts:
        if p in ('。', '！', '？'):
            out.append(p)
        else:
            out.append(apply_sov_to_svo(p))
    text = ''.join(out)
    
    # Cleanup spacing
    text = re.sub(r'  +', ' ', text)
    text = re.sub(r' ([。、！？）】」』])', r'\1', text)
    text = re.sub(r'([（【「『]) ', r'\1', text)
    return text

# ── File processor ─────────────────────────────────────────
def process_file(inpath, outpath):
    with open(inpath, "r", encoding="utf-8") as f:
        content = f.read()
    
    lines = content.split('\n')
    result = []
    i = 0
    in_fence = False
    
    # Compute ja relative path from pcn output
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
                in_fence = True
                result.append(line)
                i += 1
                while i < len(lines):
                    inner = lines[i]
                    result.append(inner)
                    if inner.strip().startswith('```'):
                        in_fence = False
                        i += 1
                        break
                    i += 1
                continue
        
        if in_fence:
            result.append(line)
            i += 1
            continue
        
        # Language switcher
        if ('日本語' in line or '偽中国語' in line) and '|' in line and \
           any(x in line for x in ['中文', 'English', 'ｶﾀﾘｯｼｭ']):
            result.append(transform_lang_switcher(line, ja_rel))
            i += 1
            continue
        
        result.append(transform_text(line))
        i += 1
    
    os.makedirs(os.path.dirname(outpath), exist_ok=True)
    with open(outpath, "w", encoding="utf-8") as f:
        f.write('\n'.join(result))
    print(f"  → {outpath}")

# ── Main ────────────────────────────────────────────────────
def main():
    base_ja = "/home/kix/NixKits/docs/ja"
    base_pcn = "/home/kix/NixKits/docs/pcn"
    
    for fname in sorted(os.listdir(base_ja)):
        if fname.endswith('.md'):
            print(f"Processing: {fname}")
            process_file(os.path.join(base_ja, fname),
                         os.path.join(base_pcn, fname))
    
    skills_ja = os.path.join(base_ja, "skills")
    skills_pcn = os.path.join(base_pcn, "skills")
    if os.path.isdir(skills_ja):
        for fname in sorted(os.listdir(skills_ja)):
            if fname.endswith('.md'):
                print(f"Processing: skills/{fname}")
                process_file(os.path.join(skills_ja, fname),
                             os.path.join(skills_pcn, fname))
    
    for src, dst in [
        ("/home/kix/NixKits/docs/README.ja.md", "/home/kix/NixKits/docs/README.pcn.md"),
        ("/home/kix/NixKits/docs/MAINTENANCE.ja.md", "/home/kix/NixKits/docs/MAINTENANCE.pcn.md"),
    ]:
        if os.path.exists(src):
            print(f"Processing: {os.path.basename(src)}")
            process_file(src, dst)
    
    print("\nDone.")

if __name__ == "__main__":
    main()
