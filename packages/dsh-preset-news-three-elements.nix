{
  lib,
  stdenv,
}:

# 独立的 Agent 预设包：只装数据，不装插件。
#
# 「新闻三要素模式」不随 dsh-nixos-shell 分发，而是自成包、由 modules/dsh.nix
# 把这个目录注册为 agent-presets roster 的一个额外 root（`presets.newsThreeElements`）：
# roster 每次调用都重扫 root，因此预设永远取自本包的 store 路径，既不复制到
# `$DSH_HOME/.agent-presets`，也不会随用户目录里的旧副本漂移。
#
# 包内插件（news-skill / news-opening / news-language / readonly-gate）由预设
# 组合以相对路径（`./plugins/*.js`）引用，且只依赖 Node 内置模块——组合的
# `baseUrl` 就是预设目录，故整目录放在 store 里也能解析，无需 node_modules。
#
# 目录布局：`$out/share/dsh-agent-presets/<id>/`，其中 `<id>` 即可作为 root
# 被扫描的预设目录（root 下每个子目录是一个预设）。
stdenv.mkDerivation (finalAttrs: {
  pname = "dsh-preset-news-three-elements";
  version = "0.1.0";

  # 参考源码路径，installPhase 直接复制（与 dsh-nixos-shell 内嵌 skills 同构）。
  src = ./dsh-preset-news-three-elements;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/dsh-agent-presets"
    cp -r ${./dsh-preset-news-three-elements} "$out/share/dsh-agent-presets/news-three-elements"
    # store 复制来的目录/文件是只读的；roster 只需读取，但保持可写让后续
    # 用户用 roster 的 copy() 从本 root 派生自己的副本时不至于卡在权限上。
    chmod -R u+w "$out/share/dsh-agent-presets"
    runHook postInstall
  '';

  meta = {
    description = "新闻三要素模式 agent preset for the DeepSeek Harness (read-only newsroom mode: online skill package, opening picker, Simplified-Chinese gate)";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
