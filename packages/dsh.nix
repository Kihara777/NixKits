{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  makeWrapper,
  python3,
  # version/hash/lock overridden for other channels (e.g. dsh-alpha)
  version ? "0.1.1-rc.2",
  hash ? "sha256-R+wF9FraWrh3ea4YqQRWtev/VCHcD/XBeWd9ZeHBYFc=",
  npmDepsHash ? "sha256-Xq49esW1IT7KRpxNrJlivtqkU2BFS97wTnBPzx7Qnts=",
  lockFile ? ./dsh-package-lock.json,
}:

buildNpmPackage (finalAttrs: {
  pname = "dsh";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${version}.tgz";
    inherit hash;
  };

  inherit npmDepsHash;

  # Prebuilt npm package (bin → lib/bin.js); no build script to run.
  dontNpmBuild = true;

  # npm package tarballs ship no lock file; vendor one so npmDepsHash is stable.
  # The tarball's devDependencies reference unpublished monorepo-internal
  # packages (dsh-experimental-agent-team & co. — 404 on the registry) and a
  # prebuilt package never needs dev deps at runtime: drop the field so
  # `npm install` (and lock generation) never tries to resolve them.
  postPatch = ''
    cp ${lockFile} package-lock.json
    # Drop devDependencies (the last top-level field in the npm tarball's
    # package.json) so `npm install` never resolves the unpublished
    # monorepo-internal dev deps.  Plain sed: neither node nor npm is on
    # PATH during the npm-deps patchPhase.  The dependencies block's own
    # closing `},` becomes the document tail — strip its comma, then close
    # the top-level object again.
    sed -i '/^  "devDependencies": {/,$d' package.json
    sed -i '$s/,$//' package.json
    echo '}' >> package.json
  '';

  # Native addon (node-addon-require-builtin) needs node-gyp during install.
  nativeBuildInputs = [
    makeWrapper
    python3
  ];

  buildInputs = [ nodejs ];

  postInstall = ''
    wrapProgram "$out/bin/dsh" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}

    # crypto.randomUUID() is unavailable in browsers on non-secure contexts
    # (plain HTTP on a LAN IP, i.e. via the lighttpd reverse proxy).  Patch
    # the browser-side client bundles to fall back to crypto.getRandomValues
    # (available in every context) when randomUUID is missing.
    # Server-side index.js files use Node's crypto, which is fine.
    # Guarded by [ -f ]: the exact client package set drifts between dsh
    # versions, so missing targets must not fail the build.
    UUID_FALLBACK='function __dshUuid(){if(globalThis.crypto&&globalThis.crypto.randomUUID)return globalThis.crypto.randomUUID();var b=globalThis.crypto.getRandomValues(new Uint8Array(16));b[6]=b[6]&15|64;b[8]=b[8]&63|128;var h=Array.from(b,function(x){return x.toString(16).padStart(2,"0")});return h.slice(0,4).join("")+"-"+h.slice(4,6).join("")+"-"+h.slice(6,8).join("")+"-"+h.slice(8,10).join("")+"-"+h.slice(10).join("");}'
    for f in \
      "$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-connection/lib/client.js" \
      "$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-ui-conversation/lib/client.js"; do
      if [ -f "$f" ]; then
        sed -i 's#crypto\.randomUUID#__dshUuid#g' "$f"
        sed -i "/factory: (require) => {/a\\$UUID_FALLBACK" "$f"
      fi
    done

    # cordis-plugin-timer 的已知 bug（上游最新 1.1.3 未修）：Context dispose
    # 时 cleanup 会 reject pending 的 ctx.timeout() promise（"Context has been
    # disposed"），调用者未 catch 时成为 unhandled rejection，被 dsh-app-boot
    # 的 installFailLoud 捕获后 process.exit(1)。这是正常的 dispose 竞态，
    # 不应终止整个服务 —— 忽略该特定错误，其余 fatal rejection 仍照常退出。
    # Guarded by [ -f ]: the file path drifts between dsh versions.
    BOOT_IDX="$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-app-boot/lib/index.js"
    if [ -f "$BOOT_IDX" ]; then
      sed -i '/if (assembledActivationRejections.has(err)) return;/a\\t\tif (err instanceof Error \&\& err.message === "Context has been disposed") return;' \
        "$BOOT_IDX"
    fi
  '';

  meta = {
    description = "DeepSeek Harness (DSH) — Everything is a Plugin";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    changelog = "https://github.com/deepseek-ai/deepseek-harness/releases";
    license = lib.licenses.mit;
    mainProgram = "dsh";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
