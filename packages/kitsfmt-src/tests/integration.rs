use std::fs;
use std::io::Write;
use std::process::{Command, Stdio};

fn format(input: &str) -> String {
    let mut child = Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to spawn kitsfmt");
    child.stdin.as_mut().unwrap().write_all(input.as_bytes()).unwrap();
    let output = child.wait_with_output().expect("Failed to wait");
    String::from_utf8_lossy(&output.stdout).to_string()
}

#[test]
fn test_format_nix_file() {
    let expected = fs::read_to_string("tests/expected.nix").expect("Failed to read expected.nix");

    let output = Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .arg("tests/input.nix")
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .expect("Failed to execute kitsfmt");

    let formatted = String::from_utf8_lossy(&output.stdout).to_string();
    assert_eq!(formatted.trim_end(), expected.trim_end());
}

#[test]
fn test_simple_attrset() {
    let result = format("{ b = 2; a = 1; }");
    assert_eq!(result.trim_end(), "{\n  a = 1;\n  b = 2;\n}");
}

#[test]
fn test_nested_attrset() {
    let result = format("{ z = { c = 3; a = 1; }; a = 2; }");
    assert_eq!(result.trim_end(), "{\n  a = 2;\n  z = {\n    a = 1;\n    c = 3;\n  };\n}");
}

#[test]
fn test_empty_attrset() {
    let result = format("{}");
    assert_eq!(result.trim_end(), "{}");
}

#[test]
fn test_empty_list() {
    let result = format("[]");
    assert_eq!(result.trim_end(), "[]");
}

#[test]
fn test_lambda_simple() {
    let result = format("{ x }: x + 1");
    assert_eq!(result.trim_end(), "{ x }: x + 1");
}

#[test]
fn test_lambda_multi() {
    let result = format("{ a, b }: a + b");
    assert_eq!(result.trim_end(), "{ a, b }: a + b");
}

#[test]
fn test_lambda_ellipsis() {
    let result = format("{ ... }: 1");
    assert_eq!(result.trim_end(), "{ ... }: 1");
}

#[test]
fn test_let_in() {
    let result = format("let x = 1; in x + 2");
    assert_eq!(result.trim_end(), "let\n  x = 1;\nin\nx + 2");
}

#[test]
fn test_select() {
    let result = format("pkgs.hello");
    assert_eq!(result.trim_end(), "pkgs.hello");
}

#[test]
fn test_select_with_or() {
    let result = format("x.foo or \"default\"");
    assert_eq!(result.trim_end(), "x.foo or \"default\"");
}

#[test]
fn test_list() {
    let result = format("[ 3 1 2 ]");
    assert_eq!(result.trim_end(), "[\n  3\n  1\n  2\n]");
}

#[test]
fn test_if_then_else() {
    let result = format("if true then 1 else 2");
    assert_eq!(result.trim_end(), "if true then\n  1 else\n  2");
}

#[test]
fn test_assert_with_body() {
    let result = format("assert true; { a = 1; }");
    assert_eq!(result.trim_end(), "assert true; {\n  a = 1;\n}");
}

#[test]
fn test_paren() {
    let result = format("(1 + 2)");
    assert_eq!(result.trim_end(), "(1 + 2)");
}

#[test]
fn test_unary_minus() {
    let result = format("-5");
    assert_eq!(result.trim_end(), "-5");
}

#[test]
fn test_unary_not() {
    let result = format("!true");
    assert_eq!(result.trim_end(), "!true");
}

#[test]
fn test_inherit() {
    let result = format("{ a = 1; inherit a; }");
    assert_eq!(result.trim_end(), "{\n  a = 1;\n  inherit a;\n}");
}

#[test]
fn test_with() {
    let result = format("with pkgs; { a = hello; }");
    assert_eq!(result.trim_end(), "with pkgs;\n{\n  a = hello;\n}");
}

#[test]
fn test_idempotent() {
    let formatted = format("{ b = 2; a = 1; }");
    let reformatted = format(formatted.trim_end());
    assert_eq!(formatted.trim_end(), reformatted.trim_end(), "Formatter is not idempotent");
}

// ── Inherit: spaces not commas (regression test for Issue A) ──────────────

#[test]
fn test_inherit_from_multiple_attrs() {
    let result = format("{ inherit (pkgs) curl jq ripgrep; }");
    assert_eq!(result.trim_end(), "{\n  inherit (pkgs) curl jq ripgrep;\n}");
}

#[test]
fn test_inherit_no_from_multiple_attrs() {
    let result = format("{ inherit a b c; }");
    assert_eq!(result.trim_end(), "{\n  inherit a b c;\n}");
}

#[test]
fn test_inherit_from_in_let() {
    let result = format("let inherit (pkgs) stdenv cmake; in stdenv");
    assert_eq!(result.trim_end(), "let\n  inherit (pkgs) stdenv cmake;\nin\nstdenv");
}

// ── Indented string preservation (regression test for Issue B) ────────────

#[test]
fn test_indented_string_preserved() {
    let result = format("{ val = pkgs.writeText \"t\" ''\n  hello\n''; }");
    assert_eq!(result.trim_end(), "{\n  val = pkgs.writeText \"t\" ''\n  hello\n'';\n}");
}

#[test]
fn test_indented_string_multiline_content() {
    let result = format("{ val = pkgs.writeText \"init\" ''\n  line1\n  line2\n''; }");
    assert_eq!(result.trim_end(), "{\n  val = pkgs.writeText \"init\" ''\n  line1\n  line2\n'';\n}");
}

// ── Lambda spacing (regression test for Issue D) ──────────────────────────

#[test]
fn test_curried_lambda_no_extra_spaces() {
    let result = format("name: value: value * 2");
    assert_eq!(result.trim_end(), "name: value: value * 2");
}

#[test]
fn test_lambda_inside_paren() {
    let result = format("{ val = f (x: x + 1); }");
    assert_eq!(result.trim_end(), "{\n  val = f (x: x + 1);\n}");
}

#[test]
fn test_lambda_with_nested_attrset() {
    let result = format("x: { a = 1; b = 2; }");
    assert_eq!(result.trim_end(), "x:\n{\n    a = 1;\n    b = 2;\n  }");
}

// ── Nested let‑in idempotency ─────────────────────────────────────────────

#[test]
fn test_nested_let_idempotent() {
    let formatted = format("let x = 1; y = let z = 2; in z + x; in x + y");
    let reformatted = format(formatted.trim_end());
    assert_eq!(formatted.trim_end(), reformatted.trim_end(), "Formatter is not idempotent");
}

// ── Deeply nested attrpath sorting ────────────────────────────────────────

#[test]
fn test_deep_attrpath_sorting() {
    let result = format("{ d.e.f = 3; a.b.c = 1; b.c.d = 2; }");
    assert_eq!(result.trim_end(), "{\n  a.b.c = 1;\n  b.c.d = 2;\n  d.e.f = 3;\n}");
}

// ── Comment preservation ──────────────────────────────────────────────────

#[test]
fn test_comments_before_entries() {
    let result = format("{ # first\n  a = 1;\n  # second\n  b = 2;\n}");
    assert_eq!(result.trim_end(), "{\n  # first\n  a = 1;\n  # second\n  b = 2;\n}");
}

// ── Complex expression idempotency ────────────────────────────────────────

#[test]
fn test_complex_idempotent() {
    let input = "{ services.nginx = { enable = true; port = 443; }; z = 1; a = 2; }";
    let formatted = format(input);
    let reformatted = format(formatted.trim_end());
    assert_eq!(formatted.trim_end(), reformatted.trim_end(), "Formatter is not idempotent");
}

#[test]
fn test_list_with_comments() {
    let result = format("[ # a\n  1\n  # b\n  2 ]");
    assert_eq!(result.trim_end(), "[\n  # a\n  1\n  # b\n  2\n]");
}

#[test]
fn test_mixed_inherit_and_attrs() {
    let result = format("{ z = 3; inherit a; b = 2; }");
    assert_eq!(result.trim_end(), "{\n  b = 2;\n  inherit a;\n  z = 3;\n}");
}

// ── Best-practice: URL quoting ──────────────────────────────────────────────

#[test]
fn test_bp_url_quoting_simple() {
    // Default: best practices ON — bare URL should be quoted
    let result = format("{ url = https://example.com; }");
    assert_eq!(result.trim_end(), "{\n  url = \"https://example.com\";\n}");
}

#[test]
fn test_bp_url_quoting_complex() {
    let result = format("{ src = fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz; }");
    assert_eq!(result.trim_end(), "{\n  src = fetchTarball \"https://github.com/NixOS/nixpkgs/archive/master.tar.gz\";\n}");
}

#[test]
fn test_bp_url_in_attrset_value() {
    let result = format("{ inputs.nixpkgs.url = github:NixOS/nixpkgs; }");
    assert_eq!(result.trim_end(), "{\n  inputs.nixpkgs.url = \"github:NixOS/nixpkgs\";\n}");
}

#[test]
fn test_bp_url_https_with_query() {
    let result = format("{ api = https://api.example.com/v1?key=value&lang=en; }");
    assert_eq!(result.trim_end(), "{\n  api = \"https://api.example.com/v1?key=value&lang=en\";\n}");
}

#[test]
fn test_bp_url_git_ssh() {
    let result = format("{ repo = git+ssh://git@github.com/NixOS/nix.git; }");
    assert_eq!(result.trim_end(), "{\n  repo = \"git+ssh://git@github.com/NixOS/nix.git\";\n}");
}

#[test]
fn test_bp_url_in_let() {
    let result = format("let src = https://example.com; in src");
    assert_eq!(result.trim_end(), "let\n  src = \"https://example.com\";\nin\nsrc");
}

#[test]
fn test_bp_url_in_list() {
    let result = format("[ https://a.example.com https://b.example.com ]");
    let output = format(result.as_str());
    assert!(output.contains("\"https://a.example.com\""));
    assert!(output.contains("\"https://b.example.com\""));
}

#[test]
fn test_bp_url_idempotent() {
    let input = "{ url = https://example.com; }";
    let formatted = format(input);
    let reformatted = format(formatted.trim_end());
    assert_eq!(formatted.trim_end(), reformatted.trim_end(), "URL quoting is not idempotent");
}

#[test]
fn test_bp_url_not_quoting_strings() {
    // Already-quoted strings should stay quoted and not be double-quoted
    let result = format("{ url = \"https://example.com\"; }");
    assert_eq!(result.trim_end(), "{\n  url = \"https://example.com\";\n}");
}

#[test]
fn test_bp_multiple_urls_in_attrset() {
    let result = format("{ a = https://a.com; b = 2; c = https://c.com; }");
    assert_eq!(result.trim_end(), "{\n  a = \"https://a.com\";\n  b = 2;\n  c = \"https://c.com\";\n}");
}

// ── Best-practice: rec → let-in transformation ────────────────────────────

#[test]
fn test_bp_rec_to_letin() {
    let result = format("rec { a = 1; b = a + 2; }");
    assert_eq!(result.trim_end(), "let\n  a = 1;\n  b = a + 2;\nin\n{\n  inherit a b;\n}");
}

#[test]
fn test_bp_rec_empty_attrset() {
    let result = format("rec {}");
    assert_eq!(result.trim_end(), "rec {}");
}

#[test]
fn test_bp_rec_to_letin_nested() {
    let result = format("rec { outer = rec { x = 1; y = x * 2; }; }");
    assert_eq!(result.trim_end(), "let\n  outer = let\n    x = 1;\n    y = x * 2;\nin\n  {\n    inherit x y;\n  };\nin\n{\n  inherit outer;\n}");
}

#[test]
fn test_bp_rec_to_letin_with_inherit() {
    let result = format("rec { a = 1; inherit (pkgs) curl jq; }");
    let output = format(result.as_str());
    assert!(output.contains("inherit (pkgs) curl jq;"));
    assert!(output.contains("inherit a curl jq;"));
}

#[test]
fn test_bp_rec_disabled() {
    // With -B flag, rec should be preserved as-is
    use std::process::{Command, Stdio};
    let mut child = Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .arg("-B")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to spawn kitsfmt");
    use std::io::Write;
    child.stdin.as_mut().unwrap().write_all(b"rec { a = 1; b = 2; }").unwrap();
    let output = child.wait_with_output().expect("Failed to wait");
    let result = String::from_utf8_lossy(&output.stdout).to_string();
    assert_eq!(result.trim_end(), "rec {\n  a = 1;\n  b = 2;\n}");
}

#[test]
fn test_bp_rec_to_letin_idempotent() {
    let input = "rec { a = 1; b = a + 2; c = 3; }";
    let formatted = format(input);
    let reformatted = format(formatted.trim_end());
    assert_eq!(formatted.trim_end(), reformatted.trim_end(), "rec→let-in is not idempotent");
}

// ── Best-practice: with → builtins.attrValues ─────────────────────────────

#[test]
fn test_bp_with_to_attrvalues_simple() {
    let result = format("with pkgs; [ curl jq ]");
    assert_eq!(result.trim_end(), "builtins.attrValues {\n  inherit (pkgs) curl jq;\n}");
}

#[test]
fn test_bp_with_to_attrvalues_inside_attrset() {
    let result = format("{ buildInputs = with pkgs; [ curl jq ]; }");
    assert_eq!(result.trim_end(), "{\n  buildInputs = builtins.attrValues {\n    inherit (pkgs) curl jq;\n  };\n}");
}

#[test]
fn test_bp_with_to_attrvalues_multiple() {
    let result = format("with pkgs; [ curl jq ripgrep htop ]");
    assert_eq!(result.trim_end(), "builtins.attrValues {\n  inherit (pkgs) curl jq ripgrep htop;\n}");
}

#[test]
fn test_bp_with_to_attrvalues_nested() {
    let result = format("{ x = with lib; [ mkOption mkIf mkForce ]; }");
    let output = format(result.as_str());
    assert!(output.contains("inherit (lib)"));
    assert!(output.contains("mkOption"));
}

#[test]
fn test_bp_with_to_attrvalues_no_transform_non_list() {
    let result = format("with pkgs; { a = curl; b = jq; }");
    assert!(result.contains("with pkgs;"));
}

#[test]
fn test_bp_with_to_attrvalues_no_transform_mixed() {
    let result = format("with pkgs; [ curl (jq.override { }) ]");
    assert!(result.contains("with pkgs;"));
}

#[test]
fn test_bp_with_to_attrvalues_disabled() {
    use std::process::{Command, Stdio};
    let mut child = Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .arg("-B")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to spawn kitsfmt");
    use std::io::Write;
    child.stdin.as_mut().unwrap().write_all(b"with pkgs; [ curl jq ]").unwrap();
    let output = child.wait_with_output().expect("Failed to wait");
    let result = String::from_utf8_lossy(&output.stdout).to_string();
    assert!(result.contains("with pkgs;"));
}

#[test]
fn test_bp_with_to_attrvalues_idempotent() {
    let input = "{ x = with pkgs; [ curl jq ripgrep ]; }";
    let formatted = format(input);
    let reformatted = format(formatted.trim_end());
    assert_eq!(formatted.trim_end(), reformatted.trim_end(), "with→attrValues is not idempotent");
}

#[test]
fn test_bp_with_to_attrvalues_empty_list_noop() {
    let result = format("with pkgs; []");
    assert!(result.contains("with pkgs;"));
}

// ── CLI: --stdin flag ──────────────────────────────────────────────────────

#[test]
fn test_stdin_flag_explicit() {
    let mut child = Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .arg("--stdin")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to spawn kitsfmt");
    child.stdin.as_mut().unwrap().write_all(b"{ a = 1; }").unwrap();
    let output = child.wait_with_output().expect("Failed to wait");
    let result = String::from_utf8_lossy(&output.stdout).to_string();
    assert_eq!(result.trim_end(), "{\n  a = 1;\n}");
}

#[test]
fn test_stdin_flag_overrides_files() {
    let mut child = Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .arg("--stdin")
        .arg("/nonexistent/file.nix")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to spawn kitsfmt");
    child.stdin.as_mut().unwrap().write_all(b"{ z = 1; }").unwrap();
    let output = child.wait_with_output().expect("Failed to wait");
    let result = String::from_utf8_lossy(&output.stdout).to_string();
    assert_eq!(result.trim_end(), "{\n  z = 1;\n}");
}

#[test]
fn test_stdin_flag_with_check() {
    let formatted = format("{ a = 1; }");
    let mut child = Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .arg("--stdin")
        .arg("-c")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to spawn kitsfmt");
    child.stdin.as_mut().unwrap().write_all(formatted.as_bytes()).unwrap();
    let output = child.wait_with_output().expect("Failed to wait");
    assert!(output.status.success(), "Check failed: {}", String::from_utf8_lossy(&output.stderr));
}

#[test]
fn test_stdin_flag_via_env() {
    let mut child = Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .arg("-s")
        .env("KITSFMT_BEST_PRACTICES", "0")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .expect("Failed to spawn kitsfmt");
    child.stdin.as_mut().unwrap().write_all(b"{ url = https://x.com; }").unwrap();
    let output = child.wait_with_output().expect("Failed to wait");
    let result = String::from_utf8_lossy(&output.stdout).to_string();
    assert!(result.contains("https://x.com"));
    assert!(!result.contains("\"https://x.com\""));
}
