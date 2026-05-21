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
    eprintln!("  -c, --check      Check if file is formatted correctly");
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
                    // Ensure comment starts with #
                    let formatted = if text.starts_with('#') || text.starts_with('*') || text.starts_with('}') {
                        text
                    } else if text.is_empty() {
                        "#".to_string()
                    } else {
                        format!("# {}", text)
                    };
                    // Prepend to maintain original order (we traverse backwards)
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

/// Format an attribute name for sorting
fn entry_sort_key(entry: &Entry) -> String {
    match entry {
        Entry::AttrpathValue(attrpath_value) => {
            if let Some(attrpath) = attrpath_value.attrpath() {
                attrpath.to_string().trim().to_string()
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

/// Format a single entry with its comments
fn format_entry(entry: &Entry, indent: usize) -> String {
    let prefix = "  ".repeat(indent);

    match entry {
        Entry::AttrpathValue(attrpath_value) => {
            let comments = comments_before(attrpath_value.syntax());
            let comment_lines = if !comments.is_empty() {
                let comment_prefix = "  ".repeat(indent);
                comments
                    .lines()
                    .map(|line| format!("{}{}", comment_prefix, line))
                    .collect::<Vec<_>>()
                    .join("\n")
            } else {
                String::new()
            };
            let comment_part = if !comment_lines.is_empty() {
                format!("{}\n", comment_lines)
            } else {
                String::new()
            };

            if let Some(attrpath) = attrpath_value.attrpath() {
                if let Some(value) = attrpath_value.value() {
                    format!(
                        "{}{}{} = {};",
                        comment_part,
                        prefix,
                        attrpath,
                        format_expr(&value, indent)
                    )
                } else {
                    format!("{}{}{}{}", comment_part, prefix, attrpath, ";")
                }
            } else {
                String::new()
            }
        }
        Entry::Inherit(inherit) => {
            let comments = comments_before(inherit.syntax());
            let comment_lines = if !comments.is_empty() {
                let comment_prefix = "  ".repeat(indent);
                comments
                    .lines()
                    .map(|line| format!("{}{}", comment_prefix, line))
                    .collect::<Vec<_>>()
                    .join("\n")
            } else {
                String::new()
            };
            let comment_part = if !comment_lines.is_empty() {
                format!("{}\n", comment_lines)
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
    let items: Vec<String> = list
        .items()
        .map(|item| format_expr(&item, indent + 1))
        .collect();

    if items.is_empty() {
        return "[]".to_string();
    }

    let formatted_items: Vec<String> = items
        .iter()
        .map(|item| format!("{}{}", item_prefix, item))
        .collect();

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

    // Collect comments with bindings
    let mut bindings_with_comments: Vec<String> = Vec::new();
    for entry in &entries {
        if let Entry::AttrpathValue(attrpath_value) = entry {
            let comments = comments_before(attrpath_value.syntax());
            let comment_lines = if !comments.is_empty() {
                let comment_prefix = "  ".repeat(indent + 1);
                comments
                    .lines()
                    .map(|line| format!("{}{}", comment_prefix, line))
                    .collect::<Vec<_>>()
                    .join("\n")
            } else {
                String::new()
            };
            let comment_part = if !comment_lines.is_empty() {
                format!("{}\n", comment_lines)
            } else {
                String::new()
            };

            if let (Some(attrpath), Some(value)) = (attrpath_value.attrpath(), attrpath_value.value()) {
                bindings_with_comments.push(format!(
                    "{}{}{} = {};",
                    comment_part, binding_prefix, attrpath, format_expr(&value, indent + 1)
                ));
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
                ast::Param::Pattern(pattern) => format_pattern(&pattern),
            };
            let body = lambda.body()
                .map(|e| format_expr(&e, indent))
                .unwrap_or_default();
            // For complex bodies (let-in, if-else, attrset, list, with), put on new line
            let is_complex = body.starts_with("let")
                || body.starts_with("if ")
                || body.starts_with("{")
                || body.starts_with("[")
                || body.starts_with("with ");
            if is_complex {
                format!("{}{}{}:\n{}", prefix, arg_str, "", body)
            } else {
                format!("{}{}{}: {}", prefix, arg_str, "", body)
            }
        }
        None => lambda.body()
            .map(|e| format_expr(&e, indent))
            .unwrap_or_default(),
    }
}

fn format_pattern_entry(entry: ast::PatEntry) -> String {
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

fn format_pattern(pattern: &ast::Pattern) -> String {
    let mut entries: Vec<String> = pattern
        .pat_entries()
        .map(format_pattern_entry)
        .collect();

    // Add ellipsis if present
    if pattern.ellipsis_token().is_some() && !entries.contains(&"...".to_string()) {
        entries.push("...".to_string());
    }

    if entries.is_empty() {
        return "{}".to_string();
    }

    format!("{{ {} }}", entries.join(", "))
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

// ── Main ─────────────────────────────────────────────────────────────────────

fn format_content(content: &str) -> Result<String, String> {
    let parse = rnix::Root::parse(content);
    let root = parse.ok().map_err(|_| "Failed to parse Nix expression".to_string())?;
    let expr = root.expr().ok_or("No expression found".to_string())?;
    Ok(format_expr(&expr, 0))
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
            match fs::write(filepath, &formatted) {
                Ok(_) => {}
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
        // Check idempotency: format(input) should equal format(format(input))
        let reformatted = match format_content(&formatted) {
            Ok(r) => r,
            Err(e) => {
                eprintln!("Error: {}", e);
                return ExitCode::FAILURE;
            }
        };
        if formatted.trim_end() != reformatted.trim_end() {
            if let Some(ref filepath) = file {
                eprintln!("File '{}' is not formatted correctly", filepath);
            } else {
                eprintln!("Input is not formatted correctly");
            }
            return ExitCode::FAILURE;
        }
    } else {
        println!("{}", formatted);
    }

    ExitCode::SUCCESS
}
