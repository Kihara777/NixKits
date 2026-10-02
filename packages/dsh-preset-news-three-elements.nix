{
  lib,
  stdenv,
}:

# 独立的 Agent 预设包：只装数据，不装插件。
#
# 「新闻三要素模式」不随 dsh-nixos-shell 分发，而是自成包。**分发方式在 dsh 0.2.0
# 变过一次**：
#   · 0.1.x：modules/dsh.nix 把 `share/dsh-agent-presets` 注册为 `agent-presets`
#     roster 的一个额外 root，roster 每次调用重扫 root，故预设永不落盘、也不漂。
#   · 0.2.0：roots 机制随复数宿主行（`agent-presets` → `agent-preset-registry`）
#     一起被删除。本包改为提供两样东西，与 NixKits 另两个预设同路：
#       1. `preset.patch.yml` —— 预设正文，模块**逐字**并进 profile 的
#          cordis.patch.yml（一条 `@deepseek-ai/dsh-agent-preset` 条目）；
#       2. `share/dsh-agent-presets/news-three-elements/` —— 插件文件与内置技能
#          副本，激活时组装到 `$DSH_HOME/.agent-presets/news-three-elements/`，
#          供 patch 行里的相对路径引用（0.2.0 只把 `.` 开头的 name 按 baseUrl
#          解析，绝对路径会被当裸包名 import 而失败）。
#
# 包内插件（news-skill / news-opening / news-language / news-material /
# readonly-gate）只依赖 Node 内置模块，无需 node_modules。
#
# `passthru.presetPatch` 让模块在**求值期**读到预设正文（源路径，无 IFD）；
# 少了它模块会明确报错，而不是猜路径。
stdenv.mkDerivation (finalAttrs: {
  pname = "dsh-preset-news-three-elements";
  # 版本跟 dsh 线：本包的**分发契约**随 dsh 0.2.0 变（roots → patch 行 + 内容目录），
  # 0.1.0 那份只对 0.1.x 的模块有意义。
  version = "0.2.0";

  # 参考源码路径，installPhase 直接复制（与 dsh-nixos-shell 内嵌 skills 同构）。
  src = ./dsh-preset-news-three-elements;

  dontUnpack = true;
  dontBuild = true;

  passthru = {
    presetPatch = ./dsh-preset-news-three-elements/preset.patch.yml;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/dsh-agent-presets"
    cp -r ${./dsh-preset-news-three-elements} "$out/share/dsh-agent-presets/news-three-elements"
    # store 复制来的目录/文件是只读的；模块只读取，chmod 保持可写只是方便手工排查。
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
