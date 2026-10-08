{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

# Thin wrapper around the independently maintained dsh-api-balance plugin.
#
# The plugin's source of truth is its own repository
# (https://github.com/Kihara777/dsh-api-balance) — it is a platform-agnostic
# DSH plugin rather than a NixOS-specific one, so it is distributed on its own
# and published to npm.  NixKits keeps this wrapper only so the `nixkits.dsh`
# module can offer declarative installation (version pinned by Nix, updated
# with system generations, reproducible) alongside the plugin's native
# `dsh plugin add` route.
#
# Bumping `version` means bumping `rev` and both hashes; the general flow is
# in the `nix-flake-update-check` skill.
buildNpmPackage (finalAttrs: {
  pname = "dsh-api-balance";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Kihara777";
    repo = "dsh-api-balance";
    rev = "43f4d18689f4395a4412f38d3e97d09edcb6636f";
    hash = "sha256-jNbfG09da6RYiSRfCm0P5pxBIo9LG38bpSAdVZaxyXc=";
  };

  # dsh ecosystem packages declare peers against same-release prereleases;
  # the plugin resolves those peers from the host dsh tree at runtime.
  # Lock generation and install both need the legacy resolver.
  npmFlags = [ "--legacy-peer-deps" ];

  # Pure JS plugin (lib/index.js + lib/client.js committed); no build script.
  dontNpmBuild = true;

  npmDepsHash = "sha256-t10nylB7Kgy/1gJ57ktPgIn6q+X8V2RNmMcuYg1Qf4g=";

  meta = {
    description = "API 用量余额插件 for the DeepSeek Harness — webui 用量显示旁添加「用量 / 开销」标签切换，开销视图展示当前 API KEY 的账户余额信息（DeepSeek /user/balance）";
    homepage = "https://github.com/Kihara777/dsh-api-balance";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
