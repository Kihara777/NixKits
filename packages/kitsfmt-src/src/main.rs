use rnix::ast::{self, AstToken, Entry, HasEntry};
use rnix::match_ast;
use rnix::{Root, SyntaxNode};
use rowan::NodeOrToken;
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

/// Get comments before a node
fn comments_before(node: &SyntaxNode) -> String {
    node.siblings_with_tokens(rowan::Direction::Prev)
        .skip(1)
        .map_while(|element| match element {
            NodeOrToken::Token(token) => match_ast! {
                match token {
                    ast::Comment(it) => Some(Some(it)),
                    ast::Whitespace(ws) => {
                        let text = ws.text();
                        if text.contains('\n') {
                            Some(None)
                        } else {
                            None
                        }
                    }
                    _ => None,
                }
            },
            _ => None,
        })
        .scan(String::new(), |state, comment| {
            if let Some(c) = comment {
                let text = c.text().trim().to_string();
                if text.starts_with("#") || text.starts_with("//") {
                    *state = text;
                    Some(text)
                } else {
                    None
                }
            } else {
                // newline separator
                if !state.is_empty() {
                    Some("\n".to_string())
                } else {
                    None
                }
            }
        })
        .collect::<Vec<_>>()
        .join("")
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
            if let Some(attr_path) = inherit.attr_path() {
                format!("inherit {}", attr_path.to_string().trim())
            } else {
                "inherit".to_string()
            }
        }
        Entry::Error => String::new(),
    }
}

/// Format a single entry with its comments
fn format_entry(entry: &Entry, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    
    match entry {
        Entry::AttrpathValue(attrpath_value) => {
            let comments = comments_before(attrpath_value.syntax());
            let comment_part = if !comments.is_empty() {
                format!("{}{}\n", comments, prefix)
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
                    format!("{}{}{};", prefix, comment_part, attrpath)
                }
            } else {
                String::new()
            }
        }
        Entry::Inherit(inherit) => {
            let comments = comments_before(inherit.syntax());
            let comment_part = if !comments.is_empty() {
                format!("{}{}\n", comments, prefix)
            } else {
                String::new()
            };
            
            if let Some(attr_path) = inherit.attr_path() {
                if let Some(from_clause) = inherit.from_clause() {
                    format!(
                        "{}{}inherit from {}({});",
                        comment_part,
                        prefix,
                        attr_path,
                        format_expr(&from_clause, indent)
                    )
                } else {
                    format!("{}{}inherit {};", comment_part, prefix, attr_path)
                }
            } else {
                format!("{}{}inherit;", comment_part, prefix)
            }
        }
        Entry::Error => String::new(),
    }
}

/// Format an expression
fn format_expr(expr: &ast::Expr, indent: usize) -> String {
    match expr {
        ast::Expr::Var(var) => var.to_string(),
        ast::Expr::Literal(literal) => literal.to_string(),
        ast::Expr::Paren(paren) => format!("({})", format_expr(&paren.expr(), indent)),
        ast::Expr::List(list) => format_list(list, indent),
        ast::Expr::Attrset(attrset) => format_attrset(attrset, indent),
        ast::Expr::Let(let_in) => format_let(let_in, indent),
        ast::Expr::If(if_expr) => format_if(if_expr, indent),
        ast::Expr::Assert(assert) => format_assert(assert, indent),
        ast::Expr::With(with) => format_with(with, indent),
        ast::Expr::Lambda(lambda) => format_lambda(lambda, indent),
        ast::Expr::BinOp(binop) => format_binop(binop, indent),
        ast::Expr::UnaryOp(unary) => format_unary(unary, indent),
        ast::Expr::Select(select) => format_select(select, indent),
        ast::Expr::HasAttr(hasattr) => format_hasattr(hasattr, indent),
        ast::Expr::Apply(call) => format_apply(call, indent),
        ast::Expr::Str(str_node) => format_str(str_node, indent),
        ast::Expr::Concat(concat) => format_concat(concat, indent),
        ast::Expr::IfElse(ifelse) => format_ifelse(ifelse, indent),
        ast::Expr::Case(case) => format_case(case, indent),
        ast::Expr::Inherit(inherit) => format_inherit_expr(inherit, indent),
        ast::Expr::Pattern(pattern) => format_pattern(pattern, indent),
        ast::Expr::Error(_) => String::new(),
    }
}

fn format_list(list: &ast::List, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    let items: Vec<String> = list
        .items()
        .filter_map(|item| item.ok())
        .map(|item| format_expr(&item, indent + 1))
        .collect();

    if items.is_empty() {
        return "[]".to_string();
    }

    let formatted_items: Vec<String> = items
        .iter()
        .map(|item| format!("{}  {}", prefix, item))
        .collect();

    format!("[\n{}\n{}]", formatted_items.join("\n"), prefix)
}

fn format_attrset(attrset: &ast::Attrset, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    let entries: Vec<Entry> = attrset
        .entries()
        .filter_map(|entry| entry.ok())
        .collect();

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

    // Format each entry
    let formatted_entries: Vec<String> = sorted_entries
        .iter()
        .map(|entry| format_entry(entry, indent))
        .collect();

    format!("{{\n{}\n{}}}", formatted_entries.join("\n"), prefix)
}

fn format_let(let_in: &ast::LetIn, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    let bindings: Vec<String> = let_in
        .bindings()
        .filter_map(|b| b.ok())
        .map(|b| format!("{}{} = {};", prefix, b.name(), b.value().ok().map(|v| format_expr(&v, indent)).unwrap_or_default()))
        .collect();

    format!("let\n{}\nin\n{}",
        bindings.join("\n"),
        format_expr(&let_in.body().ok_or_else(|| rnix::ast::Error::new()).unwrap_or_default(), indent)
    )
}

fn format_if(if_expr: &ast::If, indent: usize) -> String {
    format!("if {} then {} else {}",
        format_expr(&if_expr.condition().ok().unwrap_or_default(), indent),
        format_expr(&if_expr.then().ok().unwrap_or_default(), indent),
        format_expr(&if_expr.else_expr().ok().unwrap_or_default(), indent)
    )
}

fn format_assert(assert: &ast::Assert, indent: usize) -> String {
    format!("assert {};",
        format_expr(&assert.condition().ok().unwrap_or_default(), indent)
    )
}

fn format_with(with: &ast::With, indent: usize) -> String {
    format!("with {};\n{}",
        format_expr(&with.expr().ok().unwrap_or_default(), indent),
        format_expr(&with.body().ok().unwrap_or_default(), indent + 1)
    )
}

fn format_lambda(lambda: &ast::Lambda, indent: usize) -> String {
    let prefix = "  ".repeat(indent);
    match lambda.arg() {
        Some(arg) => {
            let arg_str = match arg {
                ast::Arg::Simple(s) => s.name(),
                ast::Arg::Pattern(p) => format!("@{}", format_pattern(&p, indent)),
            };
            format!("{}{}: {}", prefix, arg_str, format_expr(&lambda.body().ok().unwrap_or_default(), indent))
        }
        None => format_expr(&lambda.body().ok().unwrap_or_default(), indent)
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

fn format_binop(binop: &ast::BinOp, indent: usize) -> String {
    format!("{} {} {}",
        format_expr(&binop.lhs().ok().unwrap_or_default(), indent),
        binop.op_kind(),
        format_expr(&binop.rhs().ok().unwrap_or_default(), indent)
    )
}

fn format_unary(unary: &ast::UnaryOp, indent: usize) -> String {
    format!("{}{}", unary.op_kind(), format_expr(&unary.expr().ok().unwrap_or_default(), indent))
}

fn format_select(select: &ast::Select, indent: usize) -> String {
    format!("{}.${}",
        format_expr(&select.expr().ok().unwrap_or_default(), indent),
        select.attr_path()
    )
}

fn format_hasattr(hasattr: &ast::HasAttr, indent: usize) -> String {
    format!("hasAttr {}", hasattr.attr_path())
}

fn format_apply(call: &ast::Apply, indent: usize) -> String {
    format!("{} {}",
        format_expr(&call.function().ok().unwrap_or_default(), indent),
        format_expr(&call.argument().ok().unwrap_or_default(), indent)
    )
}

fn format_str(str_node: &ast::Str, indent: usize) -> String {
    str_node.to_string()
}

fn format_concat(concat: &ast::Concat, indent: usize) -> String {
    format!("{} + {}",
        format_expr(&concat.left().ok().unwrap_or_default(), indent),
        format_expr(&concat.right().ok().unwrap_or_default(), indent)
    )
}

fn format_ifelse(ifelse: &ast::IfElse, indent: usize) -> String {
    format!("if {} then {} else {}",
        format_expr(&ifelse.condition().ok().unwrap_or_default(), indent),
        format_expr(&ifelse.then().ok().unwrap_or_default(), indent),
        format_expr(&ifelse.else_expr().ok().unwrap_or_default(), indent)
    )
}

fn format_case(case: &ast::Case, indent: usize) -> String {
    format!("case {} of\n{}",
        format_expr(&case.expr().ok().unwrap_or_default(), indent),
        case.patterns().filter_map(|p| p.ok()).map(|p| format!("  {} => {}", p.pattern(), format_expr(&p.expr().ok().unwrap_or_default(), indent))).collect::<Vec<_>>().join("\n")
    )
}

fn format_inherit_expr(inherit: &ast::Inherit, indent: usize) -> String {
    if let Some(attr_path) = inherit.attr_path() {
        if let Some(from_clause) = inherit.from_clause() {
            format!("inherit from {}({});",
                attr_path,
                format_expr(&from_clause, indent)
            )
        } else {
            format!("inherit {};", attr_path)
        }
    } else {
        "inherit;".to_string()
    }
}

// ── Main ─────────────────────────────────────────────────────────────────────

fn format_content(content: &str) -> Result<String, String> {
    let root = Root::parse(content)
        .ok()
        .ok_or_else(|| "Failed to parse Nix expression".to_string())?;

    let expr = root.expr().ok_or("No expression found")?;
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
