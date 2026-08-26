{
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "dsh-api-balance";
  version = "0.1.0";

  src = ./dsh-api-balance;

  # dsh ecosystem packages declare peers against same-release prereleases;
  # the plugin resolves those peers from the host dsh tree at runtime.
  # Lock generation and install both need the legacy resolver.
  npmFlags = [ "--legacy-peer-deps" ];

  # Pure JS plugin (lib/index.js + lib/client.js committed); no build script.
  dontNpmBuild = true;

  npmDepsHash = "sha256-4cTUf3iA/a7CqhB+8zyvmQ/IdI94VjaT+rFBvzE4kdg=";

  meta = {
    description = "API 用量余额插件 for the DeepSeek Harness — webui 用量显示旁添加「用量 / 开销」标签切换，开销视图展示当前 API KEY 的账户余额信息（DeepSeek /user/balance）";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
