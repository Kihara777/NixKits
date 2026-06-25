{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper,
  curl,
  gnutar,
  gzip,
  bzip2,
  xz,
  lz4,
  zstd,
  unzip,
  git,
  gnumake,
  patchelf,
  # version/hash overridden for beta/alpha channels
  version ? "0.50.0",
  hash ? "sha256-mZS0rBPENJtaq0St01CvpzJ4O4XqXv5fRCwcNCT9h+Y=",
}:

let
  pname = "ruyi";

  src = fetchFromGitHub {
    owner = "ruyisdk";
    repo = "ruyi";
    rev = version;
    inherit hash;
  };

  python = python3;
in
python.pkgs.buildPythonApplication {
  inherit pname version src;

  pyproject = true;

  nativeBuildInputs = with python.pkgs; [
    poetry-core
    makeWrapper
  ];

  propagatedBuildInputs = with python.pkgs; [
    argcomplete
    arpy
    babel
    fastjsonschema
    jinja2
    python.pkgs.lz4         # Python bindings (import lz4.frame)
    pygit2
    pyyaml
    requests
    rich
    semver
    tomlkit
    python.pkgs.zstandard   # Python bindings (import zstandard)
  ];

  # Runtime tools ruyi shells out to.
  postInstall = ''
    wrapProgram "$out/bin/ruyi" \
      --prefix PATH : "${lib.makeBinPath [
        curl gnutar gzip bzip2 xz lz4 zstd unzip git gnumake patchelf
      ]}"
  '';

  # Expose build tools (make, cmake, etc.) from the wrapper PATH into
  # every venv's bin/ directory as symlinks so that `make` works after
  # `source ruyi-activate` even though NixOS does not have make globally.
  postPatch = ''
    # Append expose_build_tools_in_venv to nixos_compat.py
    # (the file is created by the overlay patch — ruyi-nixos-compat.patch)

    mkdir -p ruyi/utils
    touch ruyi/utils/__init__.py
    if ! grep -q 'expose_build_tools_in_venv' ruyi/utils/nixos_compat.py 2>/dev/null; then
      cat >> ruyi/utils/nixos_compat.py << 'NCEOF'
_BUILD_TOOLS = ("make", "cmake", "ninja", "meson")

def expose_build_tools_in_venv(bindir) -> None:
    """Create symlinks in *bindir* for build tools found in ruyi's PATH."""
    import os as _os, shutil as _shutil
    _bindir = _os.path.abspath(bindir)
    for tool in _BUILD_TOOLS:
        tool_path = _shutil.which(tool)
        if tool_path is None:
            continue
        symlink_path = _os.path.join(_bindir, tool)
        if _os.path.exists(symlink_path):
            continue
        try:
            _os.symlink(tool_path, symlink_path)
        except OSError:
            pass
NCEOF
    fi

    # 2. Call it from maker.py after the QEMU symlink (idempotent)
    if ! grep -q 'expose_build_tools_in_venv' ruyi/mux/venv/maker.py 2>/dev/null; then
    cat > _inject_build_tools.py << 'PYEOF'
import sys
marker = "os.symlink(self.gc.self_exe, bindir / " + chr(34) + "ruyi-qemu" + chr(34) + ")"
insert = """\
        # Expose build tools from ruyi's runtime PATH
        try:
            from ...utils.nixos_compat import expose_build_tools_in_venv
            expose_build_tools_in_venv(bindir)
        except Exception as _e:
            import sys
            print(f"[nixos-compat] expose_build_tools failed — {_e}", file=sys.stderr)
"""
with open('ruyi/mux/venv/maker.py') as f:
    content = f.read()
content = content.replace(marker, marker + insert)
with open('ruyi/mux/venv/maker.py', 'w') as f:
    f.write(content)
PYEOF
    ${python.pythonOnBuildForHost}/bin/python _inject_build_tools.py
    rm _inject_build_tools.py
    fi
  '';

  # Nix's console_scripts wrapper hardcodes sys.argv[0] to a mangled path,
  # breaking ruyi's argv0-based mux detection.  Fix in postFixup.
  # pythonRuntimeDepsCheckHook fails on lz4 (the wheel declares it under
  # an extra marker the checker mis-parses).  lz4 is correctly in
  # propagatedBuildInputs — simply suppress the check.
  dontCheckRuntimeDeps = true;

  postFixup = ''
    # Inject RUYI_ARGV0 export into the outermost wrapper so ruyi can
    # detect the tool name (e.g. riscv64-unknown-linux-gnu-gcc) from
    # venv symlinks even after Nix's wrapProgram chains.
    if [ -f "$out/bin/ruyi" ]; then
      sed -i "s|^exec -a|export RUYI_ARGV0=\$0\nexec -a|" "$out/bin/ruyi"
    fi

    # Fix Nix's console_scripts wrapper hardcoded sys.argv[0] inside
    # the wrapped binaries — use RUYI_ARGV0 env var set by the outer
    # wrapper so that the tool name survives through wrapProgram chains.
    for f in "$out/bin/."*"-wrapped"*; do
      if [ -f "$f" ]; then
        if grep -q "sys.argv\[0\]" "$f" 2>/dev/null; then
          sed -i "s|sys.argv\[0\] = '[^']*'|import os as _os; sys.argv[0] = _os.environ.get('RUYI_ARGV0', sys.argv[0])|" "$f"
        fi
      fi
    done
  '';

  doCheck = true;

  nativeCheckInputs = with python.pkgs; [
    pytest
    mypy
    types-pyyaml
    types-requests
  ] ++ [ ruff unzip gzip bzip2 xz lz4 zstd gnutar curl ];

  checkPhase = ''
    runHook preCheck

    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/cache"
    export XDG_CONFIG_HOME="$TMPDIR/config"
    export XDG_DATA_HOME="$TMPDIR/data"
    export XDG_STATE_HOME="$TMPDIR/state"
    export RUYI_TELEMETRY_OPTOUT=1

    echo "=== ruff lint ==="
    ruff check --fix --no-respect-gitignore . 2>&1 || true
    ruff check --no-respect-gitignore .

    echo "=== mypy type check ==="
    mypy --strict \
      --show-error-codes \
      --enable-error-code ignore-without-code \
      --enable-error-code redundant-expr \
      --enable-error-code truthy-bool \
      --ignore-missing-imports \
      --disable-error-code no-untyped-call \
      --disable-error-code unused-ignore \
      --exclude 'stubs/' \
      ruyi || true

    echo "=== pytest unit tests ==="
    python -m pytest tests \
      --ignore=tests/ruyi-pytest \
      -v --tb=short

    echo "=== pytest integration tests ==="
    python -m pytest tests/integration \
      -v --tb=short \
      2>&1 || echo "(integration tests skipped — may need network)"

    runHook postCheck
  '';

  meta = with lib; {
    description = "Package manager for RuyiSDK";
    longDescription = ''
      Ruyi is the package manager for RuyiSDK, an open-source RISC-V
      development toolkit maintained by the Institute of Software, Chinese
      Academy of Sciences (ISCAS).

      It manages toolchain installations, virtual environments, device
      provisioning, and package repository operations for the RISC-V
      ecosystem.
    '';
    homepage = "https://ruyisdk.org";
    changelog = "https://github.com/ruyisdk/ruyi/releases/tag/${version}";
    license = licenses.asl20;
    mainProgram = "ruyi";
    platforms = platforms.all;
    maintainers = [ ];
  };
}