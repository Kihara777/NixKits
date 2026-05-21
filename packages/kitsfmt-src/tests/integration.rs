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
