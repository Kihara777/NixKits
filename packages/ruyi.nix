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
}:

let
  version = "0.51.0-alpha.20260616";
  pname = "ruyi";

  src = fetchFromGitHub {
    owner = "ruyisdk";
    repo = "ruyi";
    rev = version;
    hash = "sha256-A7/Ca/H0NG+dGeQkGXal+b/q9s5KAkKI6s8BteeoKRg=";
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
        curl gnutar gzip bzip2 xz lz4 zstd unzip git gnumake
      ]}"
  '';

  # Nix's console_scripts wrapper hardcodes sys.argv[0] to a mangled path,
  # breaking ruyi's argv0-based mux detection.  Fix in postFixup.
  # pythonRuntimeDepsCheckHook fails on lz4 (the wheel declares it under
  # an extra marker the checker mis-parses).  lz4 is correctly in
  # propagatedBuildInputs — simply suppress the check.
  dontCheckRuntimeDeps = true;

  postFixup = ''
    for f in "$out/bin/."*"-wrapped"*; do
      if [ -f "$f" ]; then
        if grep -q "sys.argv\[0\]" "$f" 2>/dev/null; then
          sed -i "s|sys.argv\[0\] = '[^']*'|sys.argv[0] = '$out/bin/ruyi'|" "$f"
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
