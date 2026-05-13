use std::env;
use std::fs;
use std::io::{self, Read, Write};
use std::process::{Command, ExitCode, Stdio};

const VERSION: &str = env!("CARGO_PKG_VERSION");

fn print_usage() {
    eprintln!("kitsfmt - A minimal Nix configuration formatter");
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

fn find_nixpkgs_fmt() -> String {
    // Priority 1: NIXPKGS_FMT_PATH environment variable (if set and not empty)
    if let Ok(path) = env::var("NIXPKGS_FMT_PATH") {
        if !path.is_empty() && std::path::Path::new(&path).exists() {
            return path;
        }
    }

    // Priority 2: Try common Nix store paths
    let common_paths = [
        "/nix/store/*nixpkgs-fmt*/bin/nixpkgs-fmt",
        "/nix/store/nixpkgs-fmt/bin/nixpkgs-fmt",
    ];
    
    for pattern in &common_paths {
        if let Ok(entries) = glob::glob(pattern) {
            for entry in entries.flatten() {
                if entry.is_file() {
                    return entry.to_string_lossy().to_string();
                }
            }
        }
    }

    // Priority 3: fall back to PATH
    "nixpkgs-fmt".to_string()
}

fn format_content(content: &str) -> Result<String, String> {
    let nixpkgs_fmt = find_nixpkgs_fmt();

    match Command::new(&nixpkgs_fmt)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
    {
        Ok(mut child) => {
            let mut stdin = child.stdin.take().expect("Failed to open stdin");
            stdin.write_all(content.as_bytes()).map_err(|e| {
                format!("Failed to write to nixpkgs-fmt stdin: {}", e)
            })?;
            drop(stdin);

            match child.wait_with_output() {
                Ok(output) => {
                    if output.status.success() {
                        Ok(String::from_utf8_lossy(&output.stdout).to_string())
                    } else {
                        let stderr = String::from_utf8_lossy(&output.stderr);
                        Err(format!("nixpkgs-fmt failed: {}", stderr))
                    }
                }
                Err(e) => Err(format!("Failed to wait for nixpkgs-fmt: {}", e)),
            }
        }
        Err(e) => Err(format!("Failed to spawn nixpkgs-fmt ({}): {}. Is it installed?", nixpkgs_fmt, e)),
    }
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
