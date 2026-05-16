use std::fs;

#[test]
fn test_format_nix_file() {
    let input = fs::read_to_string("tests/input.nix").expect("Failed to read input.nix");
    let expected = fs::read_to_string("tests/expected.nix").expect("Failed to read expected.nix");

    // 这里需要调用 kitsfmt 的 format_content 函数
    // 但由于它是 binary crate，我们使用命令行方式测试
    let output = std::process::Command::new(env!("CARGO_BIN_EXE_kitsfmt"))
        .arg("tests/input.nix")
        .output()
        .expect("Failed to execute kitsfmt");

    let formatted = String::from_utf8_lossy(&output.stdout).to_string();
    assert_eq!(formatted.trim_end(), expected.trim_end());
}
