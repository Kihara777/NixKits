{
  lib,
  buildNpmPackage,
  # 预设内容来源：一个含 `<mode>/preset.patch.yml` + `<mode>/skills/` 的目录。
  #
  # 默认 = 仓库内目录（HEAD）。stable 通道传**钉住 rev** 的那一份，见
  # dsh-nixos-shell-stable.nix —— 稳定通道的预设内容要冻结，不能随 HEAD 漂。
  #
  # 为什么是包参数而不是在 flake 层拼 store 路径：`presets/` 是预设正文、各预设
  # 自带技能目录、构建期生成的 skills-nixos 三个东西的**同一棵树**。modules/dsh.nix
  # 从它读 preset.patch.yml 正文，skill-filesystem 行运行期又从这个包解析技能根
  # ——参数化保证「读到哪份正文」与「技能来自哪棵树」永远是同一份。
  presetsSource ? ./dsh-nixos-shell/presets,
}:

let
  # Skills registered by the NixOS模式 preset (and inherited by 维护模式).
  # Sourced from the repo `skills/` tree at build time; keep in sync with the
  # `customSkillDirs` entry that points at `skills-nixos/`.
  nixosModeSkills = [
    "nixos-modern-cli"
    "recover-nixos-config"
    "nixos-specialisation-tuning"
  ];
  # The subset must live INSIDE each preset directory: the NixOS module seeds a
  # preset with `cp -r presets/<mode> $DSH_HOME/.agent-presets/<id>`, so a root
  # pointing outside the preset directory (`../../skills-nixos/`) still resolves
  # in the store but dangles once seeded — the copy does not carry it along.
  # `skills-nixos/` therefore sits beside the preset's own `skills/`, which is
  # what the existing root already relies on.
  presetDirs = [
    "presets/nixos-mode"
    "presets/maintenance-mode"
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
  # `presets/*/skills-nixos/` is a whitelisted subset of the same tree,
  # registered by the NixOS模式 preset (and therefore by 维护模式, which derives
  # from it). A subset directory is needed because the skill-filesystem
  # provider registers every child of each configured root — pointing it at the
  # whole `skills-embedded/` tree would also mount the documentation/maintenance
  # skills, which belong to 维护模式 only. Generating it at build time keeps the
  # repo tree the single source of truth: no committed duplicate to drift.
  postPatch = ''
    # 预设树换成 presetsSource 指定的那份。默认就是 src 里那份（自复制，无害）；
    # stable 变体给的是钉住 rev 的 packages/dsh-nixos-shell/presets。
    #
    # 用 rm -rf + cp -r 整体替换，而不是逐文件覆盖：两个 rev 的预设**集合**可能
    # 不同（增删过预设目录），逐文件覆盖会把 HEAD 独有的旧目录留在树里。
    rm -rf ./presets
    cp -r ${presetsSource} ./presets
    # store 里的源树是只读的（0555 目录），而下面要往每个预设目录里建
    # skills-nixos/ —— 先放开写权限，否则 mkdir 直接 Permission denied。
    chmod -R u+w ./presets

    cp -r ${../skills} ./skills-embedded
    for preset in ${lib.concatStringsSep " " presetDirs}; do
      mkdir -p "$preset/skills-nixos"
      for skill in ${lib.concatStringsSep " " nixosModeSkills}; do
        cp -r "${../skills}/$skill" "$preset/skills-nixos/$skill"
      done
    done
    chmod -R u+w ./skills-embedded ./presets
  '';

  # modules/dsh.nix 从 `passthru.presetsSource` 在**求值期**读 preset.patch.yml
  # 正文（stable 变体给的是 builtins.fetchTarball 取到的路径，故没有
  # import-from-derivation）。少了它，模块会明确报错而不是猜路径。
  passthru = { inherit presetsSource; };

  # dsh ecosystem packages declare peers against same-release prereleases;
  # the plugin resolves those peers from the host dsh tree at runtime.
  # Lock generation and install both need the legacy resolver.
  npmFlags = [ "--legacy-peer-deps" ];

  # Pure JS plugin (lib/index.js committed); no build script to run.
  dontNpmBuild = true;

  # Same dependency tree as the former dsh-nix-shell package (dsh-tools +
  # schemastery, peers resolved at runtime from the host dsh tree).
  npmDepsHash = "sha256-5jd5O4OKcpd7aL02e8J5uZhgY8Ju2JO0BGNOqj3lte8=";

  meta = {
    description = "Consolidated NixOS operations plugin for the DeepSeek Harness (shell execution, tool bootstrap, sudo daemon routing, read-only NixOS diagnostics, NixOS-mode gate and maintenance-mode skill presets)";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
