use rnix::ast::{self, Arg, Attrset, BinOp, Bind, Call, Case, Expr, HasAttr, If, Inherit, Lambda, LetIn, List, Paren, PatEntry, Str, With};
use rnix::syntax::SyntaxKind::{self, *};
use rnix::Root;
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

// ── AST helpers ──────────────────────────────────────────────────────────────

/// Collect all entries from an AttrSet, including comments before each entry.
fn collect_entries_with_comments(node: &ast::Attrset) -> Vec<(Option<String>, ast::Entry)> {
    let mut result = Vec::new();
    let mut current_comment: Option<String> = None;

    for child in node.syntax().children() {
        let kind = child.kind();
        match kind {
            T![#] | T![//] => {
                // Start of a comment token - collect until newline
                let mut comment_lines = Vec::new();
                let mut node = child;
                loop {
                    let text = node.text();
                    comment_lines.push(text.to_string());
                    if let Some(next) = node.next_sibling() {
                        if next.kind() == Nl {
                            break;
                        }
                        node = next;
                    } else {
                        break;
                    }
                }
                current_comment = Some(comment_lines.join(""));
            }
            ENTRY => {
                if let Some(entry) = ast::Entry::cast(child.clone()) {
                    result.push((current_comment.clone(), entry));
                    current_comment = None;
                }
            }
            _ => {}
        }
    }
    result
}

/// Get the attribute name from an Entry for sorting purposes.
fn entry_name(entry: &ast::Entry) -> String {
    if let Some(attr) = entry.attr() {
        attr.to_string()
    } else {
        String::new()
    }
}

/// Get the value string from an Entry.
fn entry_value(entry: &ast::Entry) -> String {
    if let Some(value) = entry.value() {
        value.to_string()
    } else {
        String::new()
    }
}

/// Check if an Entry has a comment associated with it.
fn entry_has_comment(entry: &ast::Entry) -> bool {
    // Check if there's a comment token before this entry in the parent
    if let Some(parent) = entry.syntax().parent() {
        for child in parent.children() {
            if child.kind() == T![#] || child.kind() == T![//] {
                // Check if this comment is before the entry
                if child.text_range().end() <= entry.syntax().text_range().start() {
                    return true;
                }
            }
        }
    }
    false
}

// ── Formatting ───────────────────────────────────────────────────────────────

/// Format a Nix expression with sorting and merging.
fn format_expr(expr: &Expr, indent: usize) -> String {
    match expr {
        Expr::Var(v) => v.to_string(),
        Expr::Literal(l) => l.to_string(),
        Expr::Paren(p) => format!("({})", format_expr(&p.expr(), indent)),
        Expr::List(list) => format_list(list, indent),
        Expr::Attrset(attrset) => format_attrset(attrset, indent),
        Expr::Let(let_in) => format_let(let_in, indent),
        Expr::If(if_expr) => format_if(if_expr, indent),
        Expr::Assert(assert) => format_assert(assert, indent),
        Expr::With(with) => format_with(with, indent),
        Expr::Lambda(lambda) => format_lambda(lambda, indent),
        Expr::BinOp(binop) => format_binop(binop, indent),
        Expr::UnaryOp(unary) => format_unary(unary, indent),
        Expr::Select(select) => format_select(select, indent),
        Expr::HasAttr(hasattr) => format_hasattr(hasattr, indent),
        Expr::Apply(call) => format_apply(call, indent),
        Expr::Str(str_node) => format_str(str_node, indent),
        Expr::Concat(concat) => format_concat(concat, indent),
        Expr::IfElse(ifelse) => format_ifelse(ifelse, indent),
        Expr::Case(case) => format_case(case, indent),
        Expr::Inherit(inherit) => format_inherit(inherit, indent),
        Expr::Pattern(pattern) => format_pattern(pattern, indent),
        Expr::Error(_) => String::new(),
    }
}

fn format_list(list: &List, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    let items: Vec<String> = list
        .items()
        .filter_map(|item| item.ok())
        .map(|item| format_expr(&item, indent + 1))
        .collect();

    if items.is_empty() {
        return "[]".to_string();
    }

    format!("[\n{}{}\n{}]",
        items.iter().map(|s| format!("{}{}", "  ".repeat(indent + 1), s)).collect::<Vec<_>>().join("\n"),
        if indent == 0 { "" } else { "" },
        prefix
    )
}

fn format_attrset(attrset: &Attrset, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    let entries = collect_entries_with_comments(attrset);

    if entries.is_empty() {
        return "{}".to_string();
    }

    // Sort entries by attribute name
    let mut sorted_entries: Vec<(Option<String>, ast::Entry)> = entries.clone();
    sorted_entries.sort_by(|a, b| {
        let name_a = entry_name(&a.1);
        let name_b = entry_name(&b.1);
        name_a.cmp(&name_b)
    });

    // Format each entry with its comment
    let formatted_entries: Vec<String> = sorted_entries
        .iter()
        .filter_map(|(comment, entry)| {
            let entry_str = format!("{} = {};", entry.attr()?.to_string(), entry.value().ok()?.to_string());
            match comment {
                Some(c) => Some(format!("{}\n{}{}", c, prefix, entry_str)),
                None => Some(format!("{}{}", prefix, entry_str)),
            }
        })
        .collect();

    format!("{{\n{}\n{}}}", formatted_entries.join("\n"), prefix)
}

fn format_let(let_in: &LetIn, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    let bindings: Vec<String> = let_in
        .bindings()
        .filter_map(|b| b.ok())
        .map(|b| format!("{}{} = {};", prefix, b.name(), b.value().ok().map(|v| v.to_string()).unwrap_or_default()))
        .collect();

    format!("let\n{}\nin\n{}",
        bindings.join("\n"),
        format_expr(&let_in.body().ok(), indent)
    )
}

fn format_if(if_expr: &If, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    format!("if {} then {} else {}",
        format_expr(&if_expr.condition().ok(), indent),
        format_expr(&if_expr.then().ok(), indent),
        format_expr(&if_expr.else_expr().ok(), indent)
    )
}

fn format_assert(assert: &ast::Assert, indent: usize) -> String {
    format!("assert {};",
        format_expr(&assert.condition().ok(), indent)
    )
}

fn format_with(with: &With, indent: usize) -> String {
    format!("with {};\n{}",
        format_expr(&with.expr().ok(), indent),
        format_expr(&with.body().ok(), indent + 1)
    )
}

fn format_lambda(lambda: &Lambda, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    match lambda.arg() {
        Some(arg) => {
            let arg_str = match arg {
                Arg::Simple(s) => s.name(),
                Arg::Pattern(p) => format!("@{}", format_pattern(&p, indent)),
            };
            format!("{}{}: {}", prefix, arg_str, format_expr(&lambda.body().ok(), indent))
        }
        None => format_expr(&lambda.body().ok(), indent)
    }
}

fn format_pattern(pattern: &ast::Pattern, indent: usize) -> String {
    let entries: Vec<String> = pattern
        .entries()
        .filter_map(|e| e.ok())
        .map(|e| e.to_string())
        .collect();

    if entries.is_empty() {
        return "{}".to_string();
    }

    format!("{{ {} }}", entries.join(", "))
}

fn format_binop(binop: &BinOp, indent: usize) -> String {
    format!("{} {} {}",
        format_expr(&binop.lhs().ok(), indent),
        binop.op_kind(),
        format_expr(&binop.rhs().ok(), indent)
    )
}

fn format_unary(unary: &rnix::ast::UnaryOp, indent: usize) -> String {
    format!("{}{}", unary.op_kind(), format_expr(&unary.expr().ok(), indent))
}

fn format_select(select: &HasAttr, indent: usize) -> String {
    format!("{}.${}",
        format_expr(&select.expr().ok(), indent),
        select.attr_path()
    )
}

fn format_hasattr(hasattr: &HasAttr, indent: usize) -> String {
    format!("hasAttr {}", hasattr.attr_path())
}

fn format_apply(call: &Call, indent: usize) -> String {
    format!("{} {}",
        format_expr(&call.function().ok(), indent),
        format_expr(&call.argument().ok(), indent)
    )
}

fn format_str(str_node: &Str, indent: usize) -> String {
    str_node.to_string()
}

fn format_concat(concat: &rnix::ast::Concat, indent: usize) -> String {
    format!("{} + {}",
        format_expr(&concat.left().ok(), indent),
        format_expr(&concat.right().ok(), indent)
    )
}

fn format_ifelse(ifelse: &IfElse, indent: usize) -> String {
    format!("if {} then {} else {}",
        format_expr(&ifelse.condition().ok(), indent),
        format_expr(&ifelse.then().ok(), indent),
        format_expr(&ifelse.else_expr().ok(), indent)
    )
}

fn format_case(case: &Case, indent: usize) -> String {
    format!("case {} of\n{}",
        format_expr(&case.expr().ok(), indent),
        case.patterns().filter_map(|p| p.ok()).map(|p| format!("  {} => {}", p.pattern(), format_expr(&p.expr().ok(), indent))).collect::<Vec<_>>().join("\n")
    )
}

fn format_inherit(inherit: &Inherit, indent: usize) -> String {
    if inherit.from_clause().is_some() {
        format!("inherit from {} ({});",
            inherit.attr_path(),
            format_expr(&inherit.from_clause().ok(), indent)
        )
    } else {
        format!("inherit {};", inherit.attr_path())
    }
}

// ── Main ─────────────────────────────────────────────────────────────────────

fn format_content(content: &str) -> Result<String, String> {
    let parsed = Root::parse(content)
        .ok()
        .ok_or_else(|| "Failed to parse Nix expression".to_string())?;

    let expr = parsed.expr().ok_or("No expression found")?;
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
        if content != formatted {
            if let Some(ref filepath) = file {
                eprintln!("File '{}' is not formatted correctly", filepath);
            } else {
                eprintln!("Input is not formatted correctly");
            }
            return ExitCode::FAILURE;
        }
    } else {
        print!("{}", formatted);
    }

    ExitCode::SUCCESS
}
