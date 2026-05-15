use std::env;
use std::fs;
use std::io::{self, Read, Write};
use std::process::ExitCode;

const VERSION: &str = env!("CARGO_PKG_VERSION");

// ── Token types ──────────────────────────────────────────────────────────────

#[derive(Debug, Clone, PartialEq)]
enum Keyword {
    Let, In, With, Rec, If, Then, Else, Inherit, Assert, Null, True, False,
}

#[derive(Debug, Clone, PartialEq)]
enum Punct {
    LBrace, RBrace, LBracket, RBracket,
    Colon, Equals, Semicolon, Comma,
    At, Plus, Minus, Star, Slash,
    Eq, Ne, Lt, Gt, Le, Ge,
    QuestionMark, Dot,
    Ampersand, Pipe, Bang,
    Arrow,
}

#[derive(Debug, Clone, PartialEq)]
enum RawStrKind {
    Simple,
    Indented,
}

#[derive(Debug, Clone, PartialEq)]
enum Token {
    KW(Keyword),
    P(Punct),
    Str(String),
    RawStr { kind: RawStrKind, content: String },
    Num(String),
    Path(String),
    Ident(String),
    Comment(String),
    InterpStart,
    InterpEnd,
    Newline,
}

fn is_ident_start(c: char) -> bool {
    c.is_ascii_alphabetic() || c == '_'
}

fn is_ident_char(c: char) -> bool {
    c.is_ascii_alphanumeric() || c == '_' || c == '\'' || c == '.'
}

fn tokenize(input: &str) -> Vec<Token> {
    let mut tokens = Vec::new();
    let chars: Vec<char> = input.chars().collect();
    let mut i = 0;
    let len = chars.len();

    while i < len {
        if chars[i] == '\n' {
            tokens.push(Token::Newline);
            i += 1;
            continue;
        }

        if chars[i].is_whitespace() {
            i += 1;
            continue;
        }

        if chars[i] == '#' {
            let mut comment = String::new();
            comment.push('#');
            i += 1;
            while i < len && chars[i] != '\n' {
                comment.push(chars[i]);
                i += 1;
            }
            tokens.push(Token::Comment(comment));
            continue;
        }

        if chars[i] == '$' && i + 1 < len && chars[i + 1] == '{' {
            tokens.push(Token::InterpStart);
            i += 2;
            continue;
        }

        if chars[i] == '}' {
            tokens.push(Token::InterpEnd);
            i += 1;
            continue;
        }

        if chars[i] == '"' {
            let mut s = String::new();
            s.push('"');
            i += 1;
            while i < len && chars[i] != '"' {
                if chars[i] == '\\' && i + 1 < len {
                    s.push(chars[i]);
                    i += 1;
                    if i < len {
                        s.push(chars[i]);
                        i += 1;
                    }
                } else {
                    s.push(chars[i]);
                    i += 1;
                }
            }
            if i < len {
                s.push('"');
                i += 1;
            }
            tokens.push(Token::Str(s));
            continue;
        }

        if chars[i] == '\'' {
            if i + 1 < len && chars[i + 1] == '\'' {
                let mut kind = RawStrKind::Simple;
                i += 2;
                if i < len && chars[i] == '\'' {
                    kind = RawStrKind::Indented;
                    i += 1;
                }
                let mut content = String::new();
                while i < len {
                    if chars[i] == '\'' && i + 1 < len && chars[i + 1] == '\'' {
                        if kind == RawStrKind::Simple {
                            i += 2;
                            break;
                        } else {
                            if i + 3 < len
                                && chars[i + 1] == '\''
                                && chars[i + 2] == '\''
                                && chars[i + 3] == '\''
                            {
                                i += 4;
                                break;
                            }
                            content.push(chars[i]);
                            i += 1;
                        }
                    } else {
                        content.push(chars[i]);
                        i += 1;
                    }
                }
                tokens.push(Token::RawStr { kind, content });
            }
            continue;
        }

        if chars[i] == '.' && i + 1 < len && chars[i + 1] == '/' {
            let mut path = String::new();
            path.push('.');
            path.push('/');
            i += 2;
            while i < len && !chars[i].is_whitespace() && chars[i] != ';'
                && chars[i] != ',' && chars[i] != ':' && chars[i] != ')'
                && chars[i] != ']' && chars[i] != '}' && chars[i] != '\n'
            {
                path.push(chars[i]);
                i += 1;
            }
            tokens.push(Token::Path(path));
            continue;
        }

        if chars[i] == '/' && i + 1 < len && chars[i + 1] == '/' {
            let mut path = String::new();
            path.push('/');
            i += 1;
            while i < len && !chars[i].is_whitespace() && chars[i] != ';'
                && chars[i] != ',' && chars[i] != ':' && chars[i] != ')'
                && chars[i] != ']' && chars[i] != '}' && chars[i] != '\n'
            {
                path.push(chars[i]);
                i += 1;
            }
            tokens.push(Token::Path(path));
            continue;
        }

        if chars[i].is_ascii_digit() {
            let mut num = String::new();
            while i < len && chars[i].is_ascii_digit() {
                num.push(chars[i]);
                i += 1;
            }
            tokens.push(Token::Num(num));
            continue;
        }

        if is_ident_start(chars[i]) {
            let mut ident = String::new();
            while i < len && is_ident_char(chars[i]) {
                ident.push(chars[i]);
                i += 1;
            }
            let kw = match ident.as_str() {
                "let" => Some(Token::KW(Keyword::Let)),
                "in" => Some(Token::KW(Keyword::In)),
                "with" => Some(Token::KW(Keyword::With)),
                "rec" => Some(Token::KW(Keyword::Rec)),
                "if" => Some(Token::KW(Keyword::If)),
                "then" => Some(Token::KW(Keyword::Then)),
                "else" => Some(Token::KW(Keyword::Else)),
                "inherit" => Some(Token::KW(Keyword::Inherit)),
                "assert" => Some(Token::KW(Keyword::Assert)),
                "null" => Some(Token::KW(Keyword::Null)),
                "true" => Some(Token::KW(Keyword::True)),
                "false" => Some(Token::KW(Keyword::False)),
                _ => None,
            };
            if let Some(t) = kw {
                tokens.push(t);
            } else {
                tokens.push(Token::Ident(ident));
            }
            continue;
        }

        if i + 1 < len {
            let two: String = chars[i..i + 2].iter().collect();
            match two.as_str() {
                "//" => { tokens.push(Token::P(Punct::Slash)); i += 2; continue; }
                "==" => { tokens.push(Token::P(Punct::Eq)); i += 2; continue; }
                "!=" => { tokens.push(Token::P(Punct::Ne)); i += 2; continue; }
                "<=" => { tokens.push(Token::P(Punct::Le)); i += 2; continue; }
                ">=" => { tokens.push(Token::P(Punct::Ge)); i += 2; continue; }
                "&&" => { tokens.push(Token::P(Punct::Ampersand)); i += 2; continue; }
                "||" => { tokens.push(Token::P(Punct::Pipe)); i += 2; continue; }
                "->" => { tokens.push(Token::P(Punct::Arrow)); i += 2; continue; }
                "?." => { tokens.push(Token::P(Punct::QuestionMark)); i += 2; continue; }
                _ => {}
            }
        }

        let t = match chars[i] {
            '{' => Some(Token::P(Punct::LBrace)),
            '}' => Some(Token::P(Punct::RBrace)),
            '[' => Some(Token::P(Punct::LBracket)),
            ']' => Some(Token::P(Punct::RBracket)),
            ':' => Some(Token::P(Punct::Colon)),
            '=' => Some(Token::P(Punct::Equals)),
            ';' => Some(Token::P(Punct::Semicolon)),
            ',' => Some(Token::P(Punct::Comma)),
            '@' => Some(Token::P(Punct::At)),
            '+' => Some(Token::P(Punct::Plus)),
            '-' => Some(Token::P(Punct::Minus)),
            '*' => Some(Token::P(Punct::Star)),
            '/' => Some(Token::P(Punct::Slash)),
            '<' => Some(Token::P(Punct::Lt)),
            '>' => Some(Token::P(Punct::Gt)),
            '?' => Some(Token::P(Punct::QuestionMark)),
            '.' => Some(Token::P(Punct::Dot)),
            '!' => Some(Token::P(Punct::Bang)),
            _ => None,
        };
        if let Some(t) = t {
            tokens.push(t);
            i += 1;
            continue;
        }

        i += 1;
    }

    tokens
}

fn keyword_str(kw: &Keyword) -> &'static str {
    match kw {
        Keyword::Let => "let",
        Keyword::In => "in",
        Keyword::With => "with",
        Keyword::Rec => "rec",
        Keyword::If => "if",
        Keyword::Then => "then",
        Keyword::Else => "else",
        Keyword::Inherit => "inherit",
        Keyword::Assert => "assert",
        Keyword::Null => "null",
        Keyword::True => "true",
        Keyword::False => "false",
    }
}

fn punct_str(p: &Punct) -> &'static str {
    match p {
        Punct::LBrace => "{",
        Punct::RBrace => "}",
        Punct::LBracket => "[",
        Punct::RBracket => "]",
        Punct::Colon => ":",
        Punct::Equals => "=",
        Punct::Semicolon => ";",
        Punct::Comma => ",",
        Punct::At => "@",
        Punct::Plus => "+",
        Punct::Minus => "-",
        Punct::Star => "*",
        Punct::Slash => "/",
        Punct::Eq => "==",
        Punct::Ne => "!=",
        Punct::Lt => "<",
        Punct::Gt => ">",
        Punct::Le => "<=",
        Punct::Ge => ">=",
        Punct::QuestionMark => "?",
        Punct::Dot => ".",
        Punct::Ampersand => "&&",
        Punct::Pipe => "||",
        Punct::Bang => "!",
        Punct::Arrow => "->",
    }
}

fn fmt(tokens: &[Token]) -> String {
    let mut output = String::new();
    let mut indent_level: usize = 0;

    // Track context
    let mut after_equals = false;
    let mut after_colon = false;
    let mut after_comma = false;
    let mut after_semicolon = false;
    let mut just_closed_block = false; // After } or ]

    let mut i = 0;
    while i < tokens.len() {
        let tok = &tokens[i];

        match tok {
            Token::Newline => {
                i += 1;
                continue;
            }

            Token::Comment(c) => {
                // Comments always on their own line with proper indent
                if !output.ends_with('\n') {
                    output.push('\n');
                }
                for _ in 0..indent_level {
                    output.push_str("  ");
                }
                output.push_str(c);
                output.push('\n');
                just_closed_block = false;
                i += 1;
                continue;
            }

            // Opening braces/brackets - always on their own line
            Token::P(Punct::LBrace) => {
                if !output.ends_with('\n') {
                    output.push('\n');
                }
                for _ in 0..indent_level {
                    output.push_str("  ");
                }
                output.push('{');
                indent_level += 1;
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::P(Punct::LBracket) => {
                if !output.ends_with('\n') {
                    output.push('\n');
                }
                for _ in 0..indent_level {
                    output.push_str("  ");
                }
                output.push('[');
                indent_level += 1;
                just_closed_block = false;
                i += 1;
                continue;
            }

            // Closing braces/brackets - always on their own line
            Token::P(Punct::RBrace) => {
                output.push('\n');
                indent_level = indent_level.saturating_sub(1);
                for _ in 0..indent_level {
                    output.push_str("  ");
                }
                output.push('}');
                just_closed_block = true;
                after_equals = false;
                after_colon = false;
                i += 1;
                continue;
            }

            Token::P(Punct::RBracket) => {
                output.push('\n');
                indent_level = indent_level.saturating_sub(1);
                for _ in 0..indent_level {
                    output.push_str("  ");
                }
                output.push(']');
                just_closed_block = true;
                after_equals = false;
                after_colon = false;
                i += 1;
                continue;
            }

            Token::P(Punct::Semicolon) => {
                output.push(';');
                output.push('\n');
                indent_level = indent_level.saturating_sub(1);
                after_semicolon = true;
                after_equals = false;
                after_colon = false;
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::P(Punct::Equals) => {
                output.push(' ');
                output.push('=');
                output.push(' ');
                after_equals = true;
                after_colon = false;
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::P(Punct::Colon) => {
                output.push(' ');
                output.push(':');
                output.push(' ');
                after_colon = true;
                after_equals = false;
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::P(Punct::Comma) => {
                output.push(',');
                output.push('\n');
                after_comma = true;
                after_equals = false;
                after_colon = false;
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::KW(kw) => {
                match kw {
                    Keyword::Let | Keyword::In | Keyword::With | Keyword::Rec
                    | Keyword::If | Keyword::Else | Keyword::Inherit
                    | Keyword::Assert => {
                        if !output.ends_with('\n') {
                            output.push('\n');
                        }
                        for _ in 0..indent_level {
                            output.push_str("  ");
                        }
                        output.push_str(keyword_str(kw));
                        just_closed_block = false;
                    }
                    Keyword::Then => {
                        output.push(' ');
                        output.push_str(keyword_str(kw));
                    }
                    Keyword::Null | Keyword::True | Keyword::False => {
                        output.push_str(keyword_str(kw));
                    }
                }
                i += 1;
                continue;
            }

            Token::InterpStart => {
                output.push_str("${");
                i += 1;
                continue;
            }

            Token::InterpEnd => {
                output.push('}');
                i += 1;
                continue;
            }

            Token::Str(s) => {
                output.push_str(s);
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::RawStr { kind, content } => {
                let quote = match kind {
                    RawStrKind::Simple => "''",
                    RawStrKind::Indented => "''''",
                };
                output.push_str(quote);
                output.push_str(content);
                output.push_str(quote);
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::Num(n) => {
                output.push_str(n);
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::Path(p) => {
                output.push_str(p);
                just_closed_block = false;
                i += 1;
                continue;
            }

            Token::Ident(id) => {
                output.push_str(id);
                just_closed_block = false;
                i += 1;
                continue;
            }

            // Other operators
            Token::P(p) => {
                output.push(' ');
                output.push_str(punct_str(p));
                output.push(' ');
                just_closed_block = false;
                i += 1;
                continue;
            }

            _ => {
                i += 1;
                continue;
            }
        }
    }

    // Clean up: remove trailing whitespace on each line
    let mut result = String::new();
    for line in output.lines() {
        result.push_str(line.trim_end());
        result.push('\n');
    }

    result
}

fn print_usage() {
    eprintln!("kitsfmt - A Nix configuration formatter");
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

fn format_content(content: &str) -> String {
    let tokens = tokenize(content);
    fmt(&tokens)
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();

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

    let formatted = format_content(&content);

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
        if content.trim_end() != formatted.trim_end() {
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
