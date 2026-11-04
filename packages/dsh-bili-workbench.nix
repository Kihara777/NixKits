{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  autoPatchelfHook,
  stdenv,
  chromium,
  zlib,
}:

# dsh-bili-workbench —— 「刷 B 站 / 素材库 / AI 出片 / 审核发布 / 自动互动」的 DSH 插件。
#
# 为什么本仓要打它：它是唯一一份**能把素材变成成片**的完整实现——素材库按 BV 幂等、
# 逐镜 TTS 给字级时间戳（不用 ASR 对齐）、Remotion 渲染 1080p、投稿前 dry-run。
#
# 三处非平凡的取舍，都是实测逼出来的：
#
# 1. **Chromium 打进来**。Remotion 要有 Chromium 内核；而 `bili-op/build.mjs` 的
#    `detectBrowser()` 只探测 **Windows** 路径（`C:\Program Files\...`），在 Linux 上会
#    退化成那个不存在的路径然后渲染失败。它读 `BILI_OP_CHROME`——所以 `postPatch`
#    把默认值钉到这个包闭包里的 chromium：**包自给自足，不依赖 dsh 进程的环境变量**。
#    代价是闭包多几百 MB，这是「功能完整可用」的价格。
#
# 2. **`sharp` 是 native**（libvips）。prebuilt 包（`@img/sharp-linux-*`）在
#    `package-lock.json` 里，`npm ci` 会装进来，但它是动态链接的 ELF——
#    `autoPatchelfHook` + `stdenv.cc.cc.lib` 才能让它在新机子上跑起来。
#
# 3. **`edge-tts` / `ffmpeg` / `ffprobe` / `bili` 走 PATH**，不打进闭包：
#    它们是「系统工具」，做法与本站其它包一致。运行环境（dsh 服务）的 PATH 里有
#    `/run/current-system/sw/bin`，`/etc/nixos` 把这三个加进 systemPackages 即可。
#    **这一点必须写清楚**：装了本包但没装 edge-tts，出片会在配音那一步失败，
#    而症状是「渲染失败」——两个不同的原因，同一个现象。
buildNpmPackage (finalAttrs: {
  pname = "dsh-bili-workbench";
  version = "1.2.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Userluckytian";
    repo = "dsh-bili-workbench";
    # 钉 commit 而不是 tag：浅克隆里没有 tag，而 commit 是**现取的**（2026-11-04）。
    rev = "ae4f4f53b565b7364e8b6cc211e332eb88178217";
    hash = "sha256-Mrp2u0LTIECccysJE4uXwBx5oZJzBhToP/kaqK4W/ik=";
  };

  npmDepsHash = "sha256-63ZiXA1kEODPZdklg34HClWAKQJv409a1i/8Jofw/yM=";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    # Remotion 的 compositor 与 sharp 的 glibc 变体都要 `libz.so.1`。
    zlib
  ];

  # **musl 变体在 glibc 系统上永不加载**：npm 的 optionalDependencies 按平台选，
  # 我们加载的是 `-gnu` 那套。但它们躺在 node_modules 里，`autoPatchelfHook` 会逐个
  # 去补——然后报 `could not satisfy dependency libc.musl-x86_64.so.1`（16 处）。
  #
  # 忽略而不是删除：删除能减小闭包，但要精确列出四类路径，而上游换个包名就失效。
  # 忽略的代价是「那几份 musl .so 保持原样」——它们本来也不会被 exec。
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];

  # 没有 build 脚本（只有 check / doctor），别让 buildNpmPackage 去找它。
  dontNpmBuild = true;

  postPatch = ''
    substituteInPlace bili-op/build.mjs \
      --replace-fail "const CHROME = detectBrowser()" \
        "const CHROME = process.env.BILI_OP_CHROME || '${chromium}/bin/chromium'"
  '';

  # 它不是 CLI，没有 bin——判据落在「产物里那几样东西在」上。
  # `bili-op/render/` 的源码要跟着走：渲染时 cwd 切到那里读 `src/index.tsx`。
  meta = {
    description = "DSH plugin: Bilibili workbench — material library, AI video render, review/publish, auto interactions";
    homepage = "https://github.com/Userluckytian/dsh-bili-workbench";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.kitsunori ];
    platforms = lib.platforms.linux;
  };
})
