use rnix::ast::{self, AstToken, BinOpKind, Entry, HasEntry, UnaryOpKind};
use rowan::ast::AstNode as RowanAstNode;
use rowan::{NodeOrToken, Direction};
use std::env;
use std::fs;
use std::io::{self, Read};
use std::process::ExitCode;

const VERSION: &str = env!("CARGO_PKG_VERSION");

// ── CLI ──────────────────────────────────────────────────────────────────────

fn print_usage() {
    eprintln!("kitsfmt {} - A Nix formatter with AST-based sorting & merging", VERSION);
    eprintln!();
    eprintln!("Usage: kitsfmt [OPTIONS] [FILE]");
    eprintln!();
    eprintln!("Options:");
    eprintln!("  -i, --inplace    Modify file in-place");
    eprintln!("  -c, --check      Check if file is formatted correctly and idempotent");
    eprintln!("  -v, --version    Print version information");
    eprintln!("  -h, --help       Print help information");
    eprintln!();
    eprintln!("If no FILE is provided, reads from stdin.");
}

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Convert BinOpKind to a string
fn binop_kind_to_string(kind: BinOpKind) -> &'static str {
    match kind {
        BinOpKind::Concat => " + ",
        BinOpKind::Update => " // ",
        BinOpKind::Add => " + ",
        BinOpKind::Sub => " - ",
        BinOpKind::Mul => " * ",
        BinOpKind::Div => " / ",
        BinOpKind::And => " && ",
        BinOpKind::Equal => " == ",
        BinOpKind::Implication => " -> ",
        BinOpKind::Less => " < ",
        BinOpKind::LessOrEq => " <= ",
        BinOpKind::More => " > ",
        BinOpKind::MoreOrEq => " >= ",
        BinOpKind::NotEqual => " != ",
        BinOpKind::Or => " || ",
        BinOpKind::PipeRight => " | ",
        BinOpKind::PipeLeft => " | ",
    }
}

/// Convert UnaryOpKind to a string
fn unary_op_kind_to_string(kind: UnaryOpKind) -> &'static str {
    match kind {
        UnaryOpKind::Invert => "!",
        UnaryOpKind::Negate => "-",
    }
}

/// Get comments before a node, preserving the `#` prefix and original order
fn comments_before(node: &rnix::SyntaxNode) -> String {
    let mut comments = Vec::new();
    for element in node.siblings_with_tokens(Direction::Prev).skip(1) {
        match element {
            NodeOrToken::Token(token) => {
                if let Some(c) = ast::Comment::cast(token) {
                    let text = c.text().trim().to_string();
                    let formatted = if text.starts_with('#') || text.starts_with('*') || text.starts_with('}') {
                        text
                    } else if text.is_empty() {
                        "#".to_string()
                    } else {
                        format!("# {}", text)
                    };
                    comments.insert(0, formatted);
                }
            }
            NodeOrToken::Node(_) => {
                break;
            }
        }
    }
    comments.join("\n")
}

/// Collapse an attrpath into dotted form (APC): `a.b.c`
/// Single-segment attrpaths are returned as-is to avoid Select/Attrpath ambiguity.
fn collapse_attrpath(attrpath: &ast::Attrpath) -> String {
    let segments: Vec<String> = attrpath
        .attrs()
        .map(|attr| attr.to_string())
        .collect();
    if segments.len() == 1 {
        segments.into_iter().next().unwrap_or_default()
    } else {
        segments.join(".")
    }
}

/// Collect all comments within an attrpath and merge them
fn comments_before_attrpath(attrpath: &ast::Attrpath) -> String {
    let mut all_comments = Vec::new();

    // Collect comments from all siblings before each attr segment
    for child in attrpath.syntax().children_with_tokens() {
        if let NodeOrToken::Token(token) = child {
            if let Some(c) = ast::Comment::cast(token) {
                let text = c.text().trim().to_string();
                let formatted = if text.starts_with('#') || text.starts_with('*') {
                    text
                } else if text.is_empty() {
                    "#".to_string()
                } else {
                    format!("# {}", text)
                };
                all_comments.push(formatted);
            }
        }
    }

    all_comments.join("\n")
}

/// Format an attribute name for sorting (uses collapsed APC form)
fn entry_sort_key(entry: &Entry) -> String {
    match entry {
        Entry::AttrpathValue(attrpath_value) => {
            if let Some(attrpath) = attrpath_value.attrpath() {
                collapse_attrpath(&attrpath)
            } else {
                String::new()
            }
        }
        Entry::Inherit(inherit) => {
            let attrs: Vec<String> = inherit
                .attrs()
                .map(|a| a.to_string())
                .collect();
            if attrs.is_empty() {
                "inherit".to_string()
            } else {
                format!("inherit {}", attrs.join(", "))
            }
        }
    }
}

/// Indent continuation lines of a multiline expression (only for non-block values)
fn indent_continuation(value: &str, prefix: &str) -> String {
    let lines: Vec<&str> = value.lines().collect();
    if lines.len() <= 1 {
        return value.to_string();
    }
    // Only indent continuation for expressions that don't start with { or [
    // (attrsets and lists handle their own indentation correctly)
    let first_line = lines[0].trim_start();
    if first_line.starts_with('{') || first_line.starts_with('[') {
        return value.to_string();
    }
    let mut result = Vec::new();
    result.push(lines[0].to_string());
    for line in &lines[1..] {
        result.push(format!("{}{}", prefix, line));
    }
    result.join("\n")
}

/// Format a single entry with its comments
fn format_entry(entry: &Entry, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    let comment_prefix = "  ".repeat(indent);

    match entry {
        Entry::AttrpathValue(attrpath_value) => {
            if let Some(attrpath) = attrpath_value.attrpath() {
                let collapsed = collapse_attrpath(&attrpath);
                let mut all_comments = comments_before(attrpath_value.syntax());
                let inner_comments = comments_before_attrpath(&attrpath);
                if !inner_comments.is_empty() {
                    if !all_comments.is_empty() {
                        all_comments.push('\n');
                    }
                    all_comments.push_str(&inner_comments);
                }

                let comment_part = if !all_comments.is_empty() {
                    let comment_lines = all_comments
                        .lines()
                        .filter(|l| !l.is_empty())
                        .map(|line| format!("{}{}", comment_prefix, line))
                        .collect::<Vec<_>>()
                        .join("\n");
                    if !comment_lines.is_empty() {
                        format!("{}\n", comment_lines)
                    } else {
                        String::new()
                    }
                } else {
                    String::new()
                };

                if let Some(value) = attrpath_value.value() {
                    let formatted_value = format_expr(&value, indent);
                    let indented_value = indent_continuation(&formatted_value, &prefix);
                    format!(
                        "{}{}{} = {};",
                        comment_part,
                        prefix,
                        collapsed,
                        indented_value
                    )
                } else {
                    format!("{}{}{}{}", comment_part, prefix, collapsed, ";")
                }
            } else {
                String::new()
            }
        }
        Entry::Inherit(inherit) => {
            let comments = comments_before(inherit.syntax());
            let comment_part = if !comments.is_empty() {
                let comment_lines = comments
                    .lines()
                    .filter(|l| !l.is_empty())
                    .map(|line| format!("{}{}", comment_prefix, line))
                    .collect::<Vec<_>>()
                    .join("\n");
                if !comment_lines.is_empty() {
                    format!("{}\n", comment_lines)
                } else {
                    String::new()
                }
            } else {
                String::new()
            };

            let attrs: Vec<String> = inherit
                .attrs()
                .map(|a| a.to_string())
                .collect();

            if let Some(from) = inherit.from().and_then(|f| f.expr()) {
                if attrs.is_empty() {
                    format!(
                        "{}{}inherit ({});",
                        comment_part, prefix, format_expr(&from, indent)
                    )
                } else {
                    format!(
                        "{}{}inherit ({}) {};",
                        comment_part,
                        prefix,
                        format_expr(&from, indent),
                        attrs.join(", ")
                    )
                }
            } else if attrs.is_empty() {
                format!("{}{}inherit;", comment_part, prefix)
            } else {
                format!("{}{}inherit {};", comment_part, prefix, attrs.join(", "))
            }
        }
    }
}

/// Format an expression. `indent` is the current block level.
fn format_expr(expr: &ast::Expr, indent: usize) -> String {
    match expr {
        ast::Expr::Ident(ident) => ident.to_string(),
        ast::Expr::Literal(literal) => literal.to_string(),
        ast::Expr::Paren(paren) => paren.expr()
            .map(|e| format!("({})", format_expr(&e, indent)))
            .unwrap_or_else(|| "()".to_string()),
        ast::Expr::List(list) => format_list(list, indent),
        ast::Expr::AttrSet(attrset) => format_attrset(attrset, indent),
        ast::Expr::LetIn(let_in) => format_let(let_in, indent),
        ast::Expr::LegacyLet(_) => String::new(),
        ast::Expr::IfElse(if_expr) => format_ifelse(if_expr, indent),
        ast::Expr::Assert(assert) => format_assert(assert, indent),
        ast::Expr::With(with) => format_with(with, indent),
        ast::Expr::Lambda(lambda) => format_lambda(lambda, indent),
        ast::Expr::BinOp(binop) => format_binop(binop, indent),
        ast::Expr::UnaryOp(unary) => format_unary(unary, indent),
        ast::Expr::Select(select) => format_select(select, indent),
        ast::Expr::HasAttr(hasattr) => format_hasattr(hasattr),
        ast::Expr::Apply(call) => format_apply(call, indent),
        ast::Expr::Str(str_node) => str_node.to_string(),
        ast::Expr::PathAbs(path) => path.to_string(),
        ast::Expr::PathRel(path) => path.to_string(),
        ast::Expr::PathHome(path) => path.to_string(),
        ast::Expr::PathSearch(path) => path.to_string(),
        ast::Expr::CurPos(_) => "@".to_string(),
        ast::Expr::Error(_) => String::new(),
        ast::Expr::Root(_) => String::new(),
    }
}

fn format_list(list: &ast::List, indent: usize) -> String {
    let item_prefix = "  ".repeat(indent + 1);
    let close_prefix = "  ".repeat(indent);

    if list.items().next().is_none() {
        return "[]".to_string();
    }

    // Collect items with their preceding comments by walking syntax tree
    let mut formatted_items: Vec<String> = Vec::new();
    let mut item_idx = 0;
    let all_items: Vec<_> = list.items().collect();

    for child in list.syntax().children_with_tokens() {
        match child {
            NodeOrToken::Token(token) => {
                if let Some(comment) = ast::Comment::cast(token) {
                    let text = comment.text().trim().to_string();
                    let formatted = if text.starts_with('#') || text.starts_with('*') {
                        text
                    } else {
                        format!("# {}", text)
                    };
                    formatted_items.push(format!("{}{}", item_prefix, formatted));
                }
            }
            NodeOrToken::Node(node) => {
                if item_idx < all_items.len() {
                    let item_expr = &all_items[item_idx];
                    let formatted = format_expr(item_expr, indent + 1);
                    formatted_items.push(format!("{}{}", item_prefix, formatted));
                    item_idx += 1;
                }
            }
        }
    }

    format!("[\n{}\n{}]", formatted_items.join("\n"), close_prefix)
}

fn format_attrset(attrset: &ast::AttrSet, indent: usize) -> String {
    let close_prefix = "  ".repeat(indent);
    let entries: Vec<Entry> = attrset.entries().collect();

    if entries.is_empty() {
        return "{}".to_string();
    }

    // Sort entries by attribute name
    let mut sorted_entries = entries.clone();
    sorted_entries.sort_by(|a, b| {
        let key_a = entry_sort_key(a);
        let key_b = entry_sort_key(b);
        key_a.cmp(&key_b)
    });

    // Format each entry at indent+1 level
    let formatted_entries: Vec<String> = sorted_entries
        .iter()
        .map(|entry| format_entry(entry, indent + 1))
        .collect();

    format!("{{\n{}\n{}}}", formatted_entries.join("\n"), close_prefix)
}

fn format_let(let_in: &ast::LetIn, indent: usize) -> String {
    let binding_prefix = "  ".repeat(indent + 1);
    let body_prefix = "  ".repeat(indent);
    let entries: Vec<Entry> = let_in.entries().collect();

    let mut bindings_with_comments: Vec<String> = Vec::new();
    for entry in &entries {
        match entry {
            Entry::AttrpathValue(attrpath_value) => {
                if let (Some(attrpath), Some(value)) = (attrpath_value.attrpath(), attrpath_value.value()) {
                    let collapsed = collapse_attrpath(&attrpath);
                    let mut all_comments = comments_before(attrpath_value.syntax());
                    let inner_comments = comments_before_attrpath(&attrpath);
                    if !inner_comments.is_empty() {
                        if !all_comments.is_empty() {
                            all_comments.push('\n');
                        }
                        all_comments.push_str(&inner_comments);
                    }
                    let comment_part = if !all_comments.is_empty() {
                        let lines = all_comments.lines().filter(|l| !l.is_empty())
                            .map(|l| format!("{}{}", binding_prefix, l)).collect::<Vec<_>>().join("\n");
                        if !lines.is_empty() { format!("{}\n", lines) } else { String::new() }
                    } else { String::new() };
                    bindings_with_comments.push(format!(
                        "{}{}{} = {};", comment_part, binding_prefix, collapsed, format_expr(&value, indent + 1)
                    ));
                }
            }
            Entry::Inherit(inherit) => {
                let comments = comments_before(inherit.syntax());
                let comment_part = if !comments.is_empty() {
                    let lines = comments.lines().filter(|l| !l.is_empty())
                        .map(|l| format!("{}{}", binding_prefix, l)).collect::<Vec<_>>().join("\n");
                    if !lines.is_empty() { format!("{}\n", lines) } else { String::new() }
                } else { String::new() };
                let attrs: Vec<String> = inherit.attrs().map(|a| a.to_string()).collect();
                if let Some(from) = inherit.from().and_then(|f| f.expr()) {
                    bindings_with_comments.push(format!(
                        "{}{}inherit ({}) {};", comment_part, binding_prefix,
                        format_expr(&from, indent + 1), attrs.join(", ")
                    ));
                } else if !attrs.is_empty() {
                    bindings_with_comments.push(format!(
                        "{}{}inherit {};", comment_part, binding_prefix, attrs.join(", ")
                    ));
                }
            }
        }
    }

    let body = let_in.body().map(|e| format_expr(&e, indent)).unwrap_or_default();

    if bindings_with_comments.is_empty() {
        format!("let\nin\n{}{}", body_prefix, body)
    } else {
        format!("let\n{}\nin\n{}{}", bindings_with_comments.join("\n"), body_prefix, body)
    }
}

fn format_ifelse(if_expr: &ast::IfElse, indent: usize) -> String {
    let inner_prefix = "  ".repeat(indent + 1);

    let condition = if_expr.condition()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    let then_body = if_expr.body()
        .map(|e| format_expr(&e, indent + 1))
        .unwrap_or_default();
    let else_body = if_expr.else_body()
        .map(|e| format_expr(&e, indent + 1))
        .unwrap_or_default();

    if else_body.is_empty() {
        format!("if {} then\n{}{}", condition, inner_prefix, then_body)
    } else {
        format!(
            "if {} then\n{}{} else\n{}{}",
            condition,
            inner_prefix,
            then_body,
            inner_prefix,
            else_body
        )
    }
}

fn format_assert(assert: &ast::Assert, indent: usize) -> String {
    let condition = assert.condition()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    let body = assert.body()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    if body.is_empty() {
        format!("assert {};", condition)
    } else {
        format!("assert {}; {}", condition, body)
    }
}

fn format_with(with: &ast::With, indent: usize) -> String {
    let ns = with.namespace()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    let body = with.body()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    format!("with {};\n{}", ns, body)
}

fn format_lambda(lambda: &ast::Lambda, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    match lambda.param() {
        Some(param) => {
            let arg_str = match param {
                ast::Param::IdentParam(ident) => {
                    ident.ident()
                        .map(|i| i.to_string())
                        .unwrap_or_default()
                }
                ast::Param::Pattern(pattern) => format_pattern(&pattern, indent),
            };
            let body = lambda.body()
                .map(|e| format_expr(&e, indent + 1))
                .unwrap_or_default();
            let is_complex = body.starts_with("let")
                || body.starts_with("if ")
                || body.starts_with("{")
                || body.starts_with("[")
                || body.starts_with("with ");
            if is_complex {
                format!("{}{}:\n{}", prefix, arg_str, body)
            } else {
                format!("{}{}: {}", prefix, arg_str, body)
            }
        }
        None => lambda.body()
            .map(|e| format_expr(&e, indent))
            .unwrap_or_default(),
    }
}

fn format_pattern_entry(entry: ast::PatEntry, _indent: usize) -> String {
    let ident = entry.ident()
        .map(|i| i.to_string())
        .unwrap_or_default();

    // Check for default value by examining raw syntax elements
    let mut has_default = false;
    let mut default_expr = String::new();
    for child in entry.syntax().children_with_tokens() {
        match child {
            NodeOrToken::Token(token) => {
                let text = token.to_string();
                if text == "?" {
                    has_default = true;
                } else if has_default && text != ";" && text != " " && !text.starts_with('\n') {
                    default_expr.push_str(&text);
                }
            }
            NodeOrToken::Node(node) => {
                if has_default {
                    default_expr.push_str(&node.to_string());
                }
            }
        }
    }

    if !default_expr.is_empty() {
        format!("{} ? {}", ident, default_expr.trim())
    } else {
        ident
    }
}

fn format_pattern(pattern: &ast::Pattern, indent: usize) -> String {
    let mut entries: Vec<String> = pattern
        .pat_entries()
        .map(|e| format_pattern_entry(e, indent))
        .collect();

    // Add ellipsis if present in AST
    if pattern.ellipsis_token().is_some() {
        entries.push("...".to_string());
    }

    if entries.is_empty() {
        return "{}".to_string();
    }

    // Check if pattern is simple (no defaults, few entries) - keep inline
    let has_defaults = entries.iter().any(|e| e.contains("?"));
    let is_simple = !has_defaults && entries.len() <= 3;

    if is_simple {
        return format!("{{ {} }}", entries.join(", "));
    }

    let entry_prefix = "  ".repeat(indent + 1);
    let close_prefix = "  ".repeat(indent);
    let formatted_entries: Vec<String> = entries
        .iter()
        .map(|e| format!("{}{}", entry_prefix, e))
        .collect();
    format!("{{\n{}\n{}}}", formatted_entries.join(",\n"), close_prefix)
}

fn format_binop(binop: &ast::BinOp, indent: usize) -> String {
    let lhs = binop.lhs()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    let op = binop.operator()
        .map(binop_kind_to_string)
        .unwrap_or(" ");
    let rhs = binop.rhs()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    format!("{}{}{}", lhs, op, rhs)
}

fn format_unary(unary: &ast::UnaryOp, indent: usize) -> String {
    let op = unary.operator()
        .map(unary_op_kind_to_string)
        .unwrap_or("");
    let expr = unary.expr()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    format!("{}{}", op, expr)
}

fn format_select(select: &ast::Select, indent: usize) -> String {
    let expr = select.expr()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    let attrpath = select.attrpath()
        .map(|a| a.to_string())
        .unwrap_or_default();
    if select.or_token().is_some() {
        let default = select.default_expr()
            .map(|e| format_expr(&e, indent))
            .unwrap_or_default();
        format!("{}.{} or {}", expr, attrpath, default)
    } else {
        format!("{}.{}", expr, attrpath)
    }
}

fn format_hasattr(hasattr: &ast::HasAttr) -> String {
    let attrpath = hasattr.attrpath()
        .map(|a| a.to_string())
        .unwrap_or_default();
    format!("hasAttr {}", attrpath)
}

fn format_apply(call: &ast::Apply, indent: usize) -> String {
    let lambda = call.lambda()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    let argument = call.argument()
        .map(|e| format_expr(&e, indent))
        .unwrap_or_default();
    format!("{} {}", lambda, argument)
}

// ── Preprocessing ────────────────────────────────────────────────────────────

/// Normalize Nix syntax not supported by rnix parser.
/// Handles: inherit colon syntax, list semicolon separators.
fn preprocess_nix(input: &str) -> String {
    let chars: Vec<char> = input.chars().collect();
    let len = chars.len();
    let mut output = String::with_capacity(len);
    let mut i = 0;

    while i < len {
        // --- Handle inherit colon: `inherit (expr):` → `inherit (expr)` ---
        // Also check word boundary: char before 'inherit' should not be alphanumeric
        let before_ok = i == 0 || !chars[i - 1].is_alphanumeric() && chars[i - 1] != '_';
        if before_ok && chars[i..].starts_with(&['i', 'n', 'h', 'e', 'r', 'i', 't']) {
            let after_keyword = i + 7;
            if after_keyword < len && (chars[after_keyword] == '(' || chars[after_keyword] == ':' || is_whitespace(chars[after_keyword])) {
                // Scan past whitespace to find '(', ':', or identifier
                let mut j = after_keyword;
                while j < len && is_whitespace(chars[j]) {
                    j += 1;
                }
                if j < len && chars[j] == '(' {
                    // Found '(' — scan to matching ')'
                    let mut depth = 1;
                    j += 1;
                    while j < len && depth > 0 {
                        if chars[j] == '(' { depth += 1; }
                        else if chars[j] == ')' { depth -= 1; }
                        j += 1;
                    }
                    // j is now after the matching ')'
                    // Scan past whitespace to check for ':'
                    let mut k = j;
                    while k < len && is_whitespace(chars[k]) {
                        k += 1;
                    }
                    if k < len && chars[k] == ':' {
                        // Colon found — copy up to ')', skip ':'
                        output.push_str(&chars[i..j].iter().collect::<String>());
                        // Ensure space after ')' before next token
                        let next_char = chars.get(k + 1);
                        if next_char.is_some() && !is_whitespace(*next_char.unwrap()) {
                            output.push(' ');
                        }
                        i = k + 1; // skip ':'
                        continue;
                    }
                    // No colon — copy as-is
                } else if j < len && chars[j] == ':' {
                    // `inherit: a b;` or `inherit:a b;` → remove colon, ensure space
                    output.push_str(&chars[i..after_keyword].iter().collect::<String>());
                    let next_char = chars.get(j + 1);
                    if next_char.is_some() && !is_whitespace(*next_char.unwrap()) {
                        output.push(' ');
                    }
                    i = j + 1; // skip ':'
                    continue;
                }
            }
        }

        // --- Handle list semicolons: `[a;b;c]` → `[a b c]` ---
        if chars[i] == '[' {
            output.push('[');
            i += 1;
            // Scan list contents, replacing ';' with ' ' at depth 1
            while i < len {
                match chars[i] {
                    '"' => {
                        // Handle string: skip to closing '"'
                        output.push('"');
                        i += 1;
                        while i < len {
                            if chars[i] == '\\' && i + 1 < len {
                                output.push(chars[i]);
                                output.push(chars[i + 1]);
                                i += 2;
                            } else if chars[i] == '"' {
                                // Check for "" (indented string) or """ (multiline)
                                let remaining = &chars[i..];
                                if remaining.len() >= 2 && remaining[1] == '"' {
                                    if remaining.len() >= 3 && remaining[2] == '"' {
                                        // """ multiline string — find closing """
                                        output.push_str("\"\"\"");
                                        i += 3;
                                        while i + 2 < len {
                                            if chars[i] == '\\' && i + 1 < len {
                                                output.push(chars[i]);
                                                output.push(chars[i + 1]);
                                                i += 2;
                                            } else if chars[i..].starts_with(&['"', '"', '"']) {
                                                output.push_str("\"\"\"");
                                                i += 3;
                                                break;
                                            } else {
                                                output.push(chars[i]);
                                                i += 1;
                                            }
                                        }
                                    } else {
                                        // "" indented string — find closing ""
                                        output.push_str("\"\"");
                                        i += 2;
                                        while i + 1 < len {
                                            if chars[i] == '\\' && i + 1 < len {
                                                output.push(chars[i]);
                                                output.push(chars[i + 1]);
                                                i += 2;
                                            } else if chars[i..].starts_with(&['"', '"']) {
                                                output.push_str("\"\"");
                                                i += 2;
                                                break;
                                            } else {
                                                output.push(chars[i]);
                                                i += 1;
                                            }
                                        }
                                    }
                                    // Handle trailing quote if any
                                    if i < len && chars[i] == '"' {
                                        output.push('"');
                                        i += 1;
                                    }
                                    break;
                                } else {
                                    output.push('"');
                                    i += 1;
                                    break;
                                }
                            } else {
                                output.push(chars[i]);
                                i += 1;
                            }
                        }
                    }
                    '#' => {
                        // Handle line comment: skip to end of line
                        output.push('#');
                        i += 1;
                        while i < len && chars[i] != '\n' {
                            output.push(chars[i]);
                            i += 1;
                        }
                    }
                    '{' => {
                        // Nested attrset: skip to matching '}'
                        output.push('{');
                        i += 1;
                        let mut depth = 1;
                        while i < len && depth > 0 {
                            if chars[i] == '{' { depth += 1; }
                            else if chars[i] == '}' { depth -= 1; }
                            else if chars[i] == '"' {
                                // String inside attrset
                                output.push(chars[i]);
                                i += 1;
                                while i < len && !(chars[i] == '"' && depth <= 1) {
                                    if chars[i] == '\\' && i + 1 < len {
                                        output.push(chars[i]);
                                        output.push(chars[i + 1]);
                                        i += 2;
                                        continue;
                                    }
                                    output.push(chars[i]);
                                    i += 1;
                                }
                                if i < len {
                                    output.push(chars[i]);
                                    i += 1;
                                }
                                continue;
                            }
                            output.push(chars[i]);
                            i += 1;
                        }
                    }
                    '[' => {
                        // Nested list: process inner semicolons too
                        // Collect the nested list content, preprocess it, append to output
                        let nested_start = i;
                        i += 1;
                        let mut depth = 1;
                        while i < len && depth > 0 {
                            if chars[i] == '[' { depth += 1; }
                            else if chars[i] == ']' { depth -= 1; }
                            i += 1;
                        }
                        // i is now after the closing ']'
                        // Get the nested list content (including brackets)
                        let nested: String = chars[nested_start..i].iter().collect();
                        // Recursively preprocess (handles deeper nesting)
                        let processed = preprocess_nix(&nested);
                        output.push_str(&processed);
                        // Note: i is already past the nested list
                        continue;
                    }
                    ']' => {
                        output.push(']');
                        i += 1;
                        break;
                    }
                    ';' => {
                        // Replace list separator ';' with ' '
                        output.push(' ');
                        i += 1;
                    }
                    _ => {
                        output.push(chars[i]);
                        i += 1;
                    }
                }
            }
            continue;
        }

        output.push(chars[i]);
        i += 1;
    }

    output
}

fn is_whitespace(c: char) -> bool {
    matches!(c, ' ' | '\t' | '\n' | '\r')
}

// ── Main ─────────────────────────────────────────────────────────────────────

fn format_content(content: &str) -> Result<String, String> {
    let normalized = preprocess_nix(content);
    let parse = rnix::Root::parse(&normalized);
    let root = parse.ok().map_err(|_| "Failed to parse Nix expression".to_string())?;
    let expr = root.expr().ok_or("No expression found".to_string())?;
    let result = format_expr(&expr, 0);
    if result.trim().is_empty() && content.trim().len() > 0 {
        return Err("Formatter produced empty output for non-empty input".to_string());
    }
    Ok(result)
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();

    // Check for help and version flags first
    for arg in &args {
        match arg.as_str() {
            "-h" | "--help" => {
                print_usage();
                return ExitCode::SUCCESS;
            }
            "-v" | "--version" => {
                println!("kitsfmt {}", VERSION);
                return ExitCode::SUCCESS;
            }
            _ => {}
        }
    }

    let mut inplace = false;
    let mut check = false;
    let mut file: Option<String> = None;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "-i" | "--inplace" => {
                inplace = true;
            }
            "-c" | "--check" => {
                check = true;
            }
            _ => {
                if file.is_none() {
                    file = Some(args[i].clone());
                } else {
                    eprintln!("Error: Multiple files not supported");
                    print_usage();
                    return ExitCode::FAILURE;
                }
            }
        }
        i += 1;
    }

    let content = if let Some(ref filepath) = file {
        match fs::read_to_string(filepath) {
            Ok(content) => content,
            Err(e) => {
                eprintln!("Error: Failed to read '{}': {}", filepath, e);
                return ExitCode::FAILURE;
            }
        }
    } else {
        let mut buffer = String::new();
        if let Err(e) = io::stdin().read_to_string(&mut buffer) {
            eprintln!("Error: Failed to read stdin: {}", e);
            return ExitCode::FAILURE;
        }
        buffer
    };

    let formatted = match format_content(&content) {
        Ok(formatted) => formatted,
        Err(e) => {
            eprintln!("Error: {}", e);
            return ExitCode::FAILURE;
        }
    };

   if inplace {
        if let Some(ref filepath) = file {
            if formatted.trim().is_empty() {
                eprintln!("Error: Formatting produced empty output for '{}'", filepath);
                return ExitCode::FAILURE;
            }
            let tmp_path = format!("{}.tmp", filepath);
            match fs::write(&tmp_path, &formatted) {
                Ok(_) => {
                    match fs::rename(&tmp_path, filepath) {
                        Ok(_) => {}
                        Err(e) => {
                            eprintln!("Error: Failed to replace '{}': {}", filepath, e);
                            let _ = fs::remove_file(&tmp_path);
                            return ExitCode::FAILURE;
                        }
                    }
                }
                Err(e) => {
                    eprintln!("Error: Failed to write '{}': {}", filepath, e);
                    return ExitCode::FAILURE;
                }
            }
        } else {
            eprintln!("Error: Cannot use --inplace without a file");
            return ExitCode::FAILURE;
        }
    } else if check {
        if content.trim_end() != formatted.trim_end() {
            if let Some(ref filepath) = file {
                eprintln!("File '{}' is not formatted correctly", filepath);
            } else {
                eprintln!("Input is not formatted correctly");
            }
            return ExitCode::FAILURE;
        }
        let re_formatted = match format_content(&formatted) {
            Ok(r) => r,
            Err(e) => {
                eprintln!("Error: Formatter is not idempotent: {}", e);
                return ExitCode::FAILURE;
            }
        };
        if formatted.trim_end() != re_formatted.trim_end() {
            if let Some(ref filepath) = file {
                eprintln!("Warning: Formatter is not idempotent for '{}'", filepath);
            } else {
                eprintln!("Warning: Formatter is not idempotent");
            }
            return ExitCode::FAILURE;
        }
    } else {
        print!("{}\n", formatted);
    }

    ExitCode::SUCCESS
}
