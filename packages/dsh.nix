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
