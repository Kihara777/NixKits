#!/usr/bin/env python3
"""Convert Japanese markdown docs to pseudo-Chinese (pcn)."""
import re
import os
import sys

# --- Dictionary (from skills/translate-pseudocn/dictionary.md) ---
KATAKANA_DICT = {
    "ソフトウェア": "軟体",
    "ハードウェア": "硬体",
    "バージョン": "版",
    "アップストリーム": "上流",
    "タイプ": "種別",
    "デフォルト": "既定",
    "ライセンス": "許諾",
    "セットアップ": "準備",
    "コンパチビリティ": "互換性",
    "インストール": "導入",
    "サーバー": "伺服器",
    "クライアント": "依頼者",
    "ネットワーク": "網絡",
    "データベース": "資料庫",
    "セキュリティ": "安全",
    "プロトコル": "規約",
    "クラウド": "雲",
    "インターネット": "網際",
    "プログラム": "手順",
    "ツール": "道具",
    "サポート": "支援",
    "ファイル": "書類",
    "システム": "体系",
    "モジュール": "部品",
    "パッケージ": "包",
    "マネージャー": "管理者",
    "リポジトリ": "倉庫",
    "ランタイム": "実行時",
    "プロジェクト": "計画",
    "ドキュメント": "文書",
    "テンプレート": "雛形",
    "プラグイン": "拡張",
    "ストリーミング": "流送",
    "コーディング": "符号化",
    "エージェント": "代理",
    "オーバーレイ": "上乗",
    "ビルド": "構築",
    "サービス": "服務",
    "モデル": "模型",
    "インフラ": "基盤",
    "フォーマッター": "整形器",
    "ターミナル": "端末",
}

# Hiragana range (includes small chars, voiced marks, iteration marks)
HIRAGANA_RE = re.compile(r'[\u3040-\u309F]+')

# Full-width katakana + half-width katakana
KATAKANA_RE = re.compile(r'[\u30A0-\u30FF\uFF65-\uFF9F]+')

# Katakana words sorted by length (longest match first)
KATAKANA_WORDS = sorted(KATAKANA_DICT.keys(), key=len, reverse=True)

# Particles to strip
PARTICLES = ['が', 'を', 'に', 'へ', 'で', 'と', 'から', 'まで', 'は']


def strip_hiragana(text):
    """Remove all hiragana characters."""
    return HIRAGANA_RE.sub('', text)


def replace_katakana(text):
    """Replace known katakana words with dictionary mappings, strip the rest."""
    for kw in KATAKANA_WORDS:
        text = text.replace(kw, KATAKANA_DICT[kw])
    text = KATAKANA_RE.sub('', text)
    return text


def handle_no(text):
    """Convert の to 之 before stripping hiragana."""
    return text.replace('の', '之')


def strip_particles(text):
    """Strip grammatical particles."""
    for p in PARTICLES:
        text = text.replace(p, '')
    return text


def normalize_whitespace(text):
    """Collapse multiple spaces into one and clean up doubled punctuation."""
    # Collapse multiple spaces
    text = re.sub(r'  +', ' ', text)
    # Clean up doubled Japanese punctuation: 、、→、 。。→。
    text = re.sub(r'、、+', '、', text)
    text = re.sub(r'。。+', '。', text)
    # Clean up space before Japanese punctuation
    text = re.sub(r' +([、。）」』】｝])', r'\1', text)
    # Clean up space before fullwidth colon
    text = re.sub(r' +(：)', r'\1', text)
    # Clean up space after opening bracket
    text = re.sub(r'([（【｛『「]) +', r'\1', text)
    # Clean up space before closing bracket
    text = re.sub(r' +([）】｝』」])', r'\1', text)
    return text


def convert_text(text):
    """Apply all text conversion rules to non-code text."""
    # 1. Convert の to 之 (before stripping hiragana)
    text = handle_no(text)
    # 2. Replace dictionary katakana
    text = replace_katakana(text)
    # 3. Strip remaining hiragana
    text = strip_hiragana(text)
    # 4. Strip particles
    text = strip_particles(text)
    # 5. Normalize whitespace
    text = normalize_whitespace(text)
    return text


def translate_nix_comment(line):
    """Translate only the # comment portion of a Nix code line."""
    m = re.match(r'^(\s*#\s*)(.*)', line)
    if m:
        prefix = m.group(1)
        comment = m.group(2)
        return prefix + convert_text(comment)
    return line


def is_nix_code_block(info_string):
    """Check if code block info string indicates Nix."""
    if not info_string:
        return False
    lang = info_string.strip().lower()
    return lang in ('nix', 'nixos')


def is_bash_code_block(info_string):
    """Check if code block info string indicates bash/shell."""
    if not info_string:
        return False
    lang = info_string.strip().lower()
    return lang in ('bash', 'sh', 'shell', 'console', 'zsh')


def is_language_switcher(line):
    """Detect if a line is a language switcher (multiple language links separated by |).
    
    Excludes markdown table rows (which start with |) to avoid false positives.
    """
    stripped = line.strip()
    # Must contain |
    if '|' not in stripped:
        return False
    # Must NOT be a table row (starts with |)
    if stripped.startswith('|'):
        return False
    # Check for common language label patterns
    langs = ['中文', 'English', '日本語', '偽中国語']
    count = sum(1 for lang in langs if lang in stripped)
    return count >= 2


def process_language_switcher(line, source_path, dest_path):
    """Process a language switcher line.
    
    For the pcn output:
    - 日本語 → [日本語](<ja_path>)  (add link to ja version)
    - 偽中国語 → 偽中国語 (plain text, no link)
    - Other labels preserved as-is
    """
    workspace = '/home/kix/NixKits'
    
    # Determine the Japanese source path corresponding to the dest_path
    if dest_path.endswith('/README.md'):
        ja_abs = dest_path.replace('/pcn/README.md', '/README.ja.md')
    elif dest_path.endswith('/MAINTENANCE.md'):
        ja_abs = dest_path.replace('/pcn/MAINTENANCE.md', '/MAINTENANCE.ja.md')
    else:
        ja_abs = dest_path.replace('/pcn/', '/ja/')
    
    # Compute relative path from the output file's directory to the ja source
    dest_dir = os.path.dirname(dest_path)
    ja_rel = os.path.relpath(ja_abs, dest_dir)

    # Split by | and process each segment
    segments = line.split('|')
    result_segments = []

    for seg in segments:
        stripped = seg.strip()

        # Check if this segment is a markdown link [label](url)
        link_match = re.match(r'^\[([^\]]*)\]\(([^)]*)\)$', stripped)

        if '日本語' in stripped:
            # Japanese: make it a link to the ja source
            result_segments.append(f'[日本語]({ja_rel})')
        elif '偽中国語' in stripped:
            # Pseudo-Chinese: plain text (current page)
            result_segments.append('偽中国語')
        elif link_match:
            label = link_match.group(1)
            url = link_match.group(2)
            # Preserve as-is (don't convert label)
            result_segments.append(f'[{label}]({url})')
        else:
            # Bare text label: preserve as-is
            result_segments.append(stripped)

    return ' | '.join(result_segments)


def convert_text_with_inline_code(line):
    """Convert text while preserving inline code spans."""
    parts = re.split(r'(`[^`]+`)', line)
    result_parts = []
    for part in parts:
        if part.startswith('`') and part.endswith('`'):
            result_parts.append(part)
        else:
            result_parts.append(convert_text(part))
    return ''.join(result_parts)


def handle_markdown_link(text):
    """Handle markdown links: convert link text, but if it becomes empty, keep URL."""
    def link_replacer(m):
        link_text = m.group(1)
        url = m.group(2)
        converted = convert_text(link_text).strip()
        if not converted:
            # If conversion empties the text, keep original
            return m.group(0)
        return f'[{converted}]({url})'
    
    # Match markdown links [text](url) but not images
    return re.sub(r'\[([^\]]+)\]\(([^)]+)\)', link_replacer, text)


def convert_file(source_path, dest_path):
    """Convert a single markdown file."""
    with open(source_path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    result_lines = []
    in_code_block = False
    in_nix_block = False
    in_bash_block = False

    for line in lines:
        # Check for code block start/end
        code_block_match = re.match(r'^```(.*)$', line)

        if code_block_match:
            if not in_code_block:
                in_code_block = True
                info = code_block_match.group(1).strip()
                in_nix_block = is_nix_code_block(info)
                in_bash_block = is_bash_code_block(info)
                result_lines.append(line)
            else:
                in_code_block = False
                in_nix_block = False
                in_bash_block = False
                result_lines.append(line)
            continue

        if in_code_block:
            if in_nix_block:
                result_lines.append(translate_nix_comment(line))
            else:
                # Bash and other code blocks: leave untouched
                result_lines.append(line)
            continue

        # Outside code blocks: check for language switcher first
        if is_language_switcher(line):
            result_lines.append(process_language_switcher(line, source_path, dest_path))
            continue

        # Convert text with inline code preservation
        converted = convert_text_with_inline_code(line)
        # Handle markdown links (convert link text)
        converted = handle_markdown_link(converted)
        result_lines.append(converted)

    result = '\n'.join(result_lines)

    # Clean up empty section headers: "## " -> preserve as-is or add placeholder
    # Actually keep them as-is; empty headers are valid in pcn

    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    with open(dest_path, 'w', encoding='utf-8') as f:
        f.write(result)

    return True


def main():
    workspace = '/home/kix/NixKits'
    docs_ja = os.path.join(workspace, 'docs', 'ja')
    docs_pcn = os.path.join(workspace, 'docs', 'pcn')

    sources = []

    # docs/ja/*.md
    for f in sorted(os.listdir(docs_ja)):
        if f.endswith('.md'):
            src = os.path.join(docs_ja, f)
            dst = os.path.join(docs_pcn, f)
            sources.append((src, dst))

    # docs/ja/skills/*.md
    skills_ja = os.path.join(docs_ja, 'skills')
    skills_pcn = os.path.join(docs_pcn, 'skills')
    if os.path.isdir(skills_ja):
        for f in sorted(os.listdir(skills_ja)):
            if f.endswith('.md'):
                src = os.path.join(skills_ja, f)
                dst = os.path.join(skills_pcn, f)
                sources.append((src, dst))

    # docs/README.ja.md -> docs/pcn/README.md
    readme_ja = os.path.join(workspace, 'docs', 'README.ja.md')
    if os.path.exists(readme_ja):
        dst = os.path.join(docs_pcn, 'README.md')
        sources.append((readme_ja, dst))

    # docs/MAINTENANCE.ja.md -> docs/pcn/MAINTENANCE.md
    maint_ja = os.path.join(workspace, 'docs', 'MAINTENANCE.ja.md')
    if os.path.exists(maint_ja):
        dst = os.path.join(docs_pcn, 'MAINTENANCE.md')
        sources.append((maint_ja, dst))

    for src, dst in sources:
        print(f"Converting: {src} -> {dst}")
        try:
            convert_file(src, dst)
            print(f"  OK")
        except Exception as e:
            import traceback
            traceback.print_exc()
            print(f"  ERROR: {e}")

    print(f"\nTotal files processed: {len(sources)}")


if __name__ == '__main__':
    main()
