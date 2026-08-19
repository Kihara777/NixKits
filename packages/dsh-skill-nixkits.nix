{
  lib,
  stdenv,
}:

# Zero-dependency pure-JS plugin package, assembled directly instead of
# buildNpmPackage (whose npmInstallHook assumes a node_modules tree exists).
stdenv.mkDerivation (finalAttrs: {
  pname = "dsh-skill-nixkits";
  version = "0.1.0";

  src = ./dsh-skill-nixkits;

  # Embed the canonical skill sources (repo-root skills/) into the package so
  # each plugin entry registers its own SKILL.md at runtime.
  postPatch = ''
    cp -r ${../skills} ./skills
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/node_modules/@kihara777/dsh-skill-nixkits"
    cp -r lib skills package.json \
      "$out/lib/node_modules/@kihara777/dsh-skill-nixkits/"
    runHook postInstall
  '';

  meta = {
    description = "NixKits skills as native DeepSeek Harness (dsh) skill plugins";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
