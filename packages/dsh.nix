{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  makeWrapper,
  python3,
}:

buildNpmPackage (finalAttrs: {
  pname = "dsh";
  version = "0.1.0-rc.6";

  src = fetchurl {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${finalAttrs.version}.tgz";
    hash = "sha256-G4qaCtPH/q7OR5JuC9N8oVHHzPqZeVOvpf0BJheE6tw=";
  };

  npmDepsHash = "sha256-Zyex+9fS4Rb/Y1tqB3oJB+w4lM6gZLUNtLYSSikT8j0=";

  # Prebuilt npm package (bin → lib/bin.js); no build script to run.
  dontNpmBuild = true;

  # npm package tarballs ship no lock file; vendor one so npmDepsHash is stable.
  postPatch = ''
    cp ${./dsh-package-lock.json} package-lock.json
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
    UUID_FALLBACK='function __dshUuid(){if(globalThis.crypto&&globalThis.crypto.randomUUID)return globalThis.crypto.randomUUID();var b=globalThis.crypto.getRandomValues(new Uint8Array(16));b[6]=b[6]&15|64;b[8]=b[8]&63|128;var h=Array.from(b,function(x){return x.toString(16).padStart(2,"0")});return h.slice(0,4).join("")+"-"+h.slice(4,6).join("")+"-"+h.slice(6,8).join("")+"-"+h.slice(8,10).join("")+"-"+h.slice(10).join("");}'
    for f in \
      "$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-connection/lib/client.js" \
      "$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-ui-conversation/lib/client.js"; do
      sed -i 's#crypto\.randomUUID#__dshUuid#g' "$f"
      sed -i "/factory: (require) => {/a\\$UUID_FALLBACK" "$f"
    done
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
