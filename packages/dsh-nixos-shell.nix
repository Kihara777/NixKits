{
  lib,
  buildNpmPackage,
}:

let
  # Skills registered by the NixOS模式 preset (and inherited by 维护模式).
  # Sourced from the repo `skills/` tree at build time; keep in sync with the
  # `customSkillDirs` entry that points at `../../skills-nixos/`.
  nixosModeSkills = [
    "nixos-modern-cli"
    "recover-nixos-config"
    "nixos-specialisation-tuning"
  ];
in
buildNpmPackage (finalAttrs: {
  pname = "dsh-nixos-shell";
  version = "0.1.0";

  src = ./dsh-nixos-shell;

  # Embed the repository's canonical skills/ tree so the maintenance-skills
  # preset entry (维护模式) can register the latest skill content as runtime
  # skills at apply time — the repo skills/ directory stays the single source
  # of truth, the package snapshots it at build time.
  #
  # `skills-nixos/` is a whitelisted subset of the same tree, registered by
  # the NixOS模式 preset (and therefore by 维护模式, which derives from it).
  # A subset directory is needed because the skill-filesystem provider
  # registers every child of each configured root — pointing it at the whole
  # `skills-embedded/` tree would also mount the documentation/maintenance
  # skills, which belong to 维护模式 only. Copying at build time keeps the
  # repo tree the single source of truth: no committed duplicate to drift.
  postPatch = ''
    cp -r ${../skills} ./skills-embedded
    mkdir -p ./skills-nixos
    for skill in ${lib.concatStringsSep " " nixosModeSkills}; do
      cp -r "${../skills}/$skill" ./skills-nixos/$skill
    done
    chmod -R u+w ./skills-embedded ./skills-nixos
  '';

  # dsh ecosystem packages declare peers against same-release prereleases;
  # the plugin resolves those peers from the host dsh tree at runtime.
  # Lock generation and install both need the legacy resolver.
  npmFlags = [ "--legacy-peer-deps" ];

  # Pure JS plugin (lib/index.js committed); no build script to run.
  dontNpmBuild = true;

  # Same dependency tree as the former dsh-nix-shell package (dsh-tools +
  # schemastery, peers resolved at runtime from the host dsh tree).
  npmDepsHash = "sha256-I4r7QmOSMIBIiBENaBHS4gN5GsZpUAlJtJ94Yeg0HvE=";

  meta = {
    description = "Consolidated NixOS operations plugin for the DeepSeek Harness (shell execution, tool bootstrap, sudo daemon routing, read-only NixOS diagnostics, NixOS-mode gate and maintenance-mode skill presets)";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
