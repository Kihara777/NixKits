{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
  makeWrapper,
  python3,
  # version/hash/lock overridden for other channels (e.g. dsh-alpha)
  #
  # ── 通道语义（2026-10-02 迁移到 0.2.0）────────────────────────────────────
  # 本包 = stable 通道，跟 npm `latest`。
  #
  # ⚠️ npm 的 dist-tag 在这里**不按字面排序**：`alpha` = 0.1.7-alpha.2（0.1.x
  # 线的尾巴），而 `latest` = `next` = 0.2.0-rc.2 —— 即 **alpha 比 stable 低**。
  # 所以「alpha 通道跟 `alpha` tag」这条老语义已经失效：`dsh-alpha` 改跟 `next`
  # （语义是 0.2.x 线的最新预发布，见 dsh-alpha.nix 的注释）。两个通道因此都跨了
  # 0.1.x → 0.2.x 这条线。
  #
  # 0.2.0 同时是一次**预设格式断层**：0.1.x 的 Agent 预设是
  # `$DSH_HOME/.agent-presets/<id>/` 目录（0.2.0 起该通道被删除），0.2.0 改成
  # profile 用户 patch 层（`$DSH_HOME/profiles/<profile>/cordis.patch.yml`）里的
  # 一条 `@deepseek-ai/dsh-agent-preset` 条目。仓库 HEAD 只维护新格式；旧格式的
  # 内容冻结在 packages/dsh-nixos-shell-stable.nix 钉住的 commit 里。
  #
  # `dshChannel` 供 modules/dsh.nix 判断本包属于哪个通道：stable 的**预设内容**
  # 取自钉住的 rev（冻结），alpha 的跟 HEAD。
  version ? "0.2.0-rc.2",
  hash ? "sha256-vSeEfERc1opWWsH5HAa7vMdjnvkwcfZ4u1nF66/ziFk=",
  npmDepsHash ? "sha256-7QtZIz8oDKi2eVHfmbLkdww5XxPvY7NP8ZmP5RxBzNY=",
  lockFile ? ./dsh-package-lock.json,
  dshChannel ? "stable",
  # 允许局域网（非 loopback）浏览器读写设置，见 postInstall 中的说明。
  allowLanSettings ? false,
}:

buildNpmPackage (finalAttrs: {
  pname = "dsh";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${version}.tgz";
    inherit hash;
  };

  inherit npmDepsHash;

  # Prebuilt npm package (bin → lib/bin.js); no build script to run.
  dontNpmBuild = true;

  # npm package tarballs ship no lock file; vendor one so npmDepsHash is stable.
  # The tarball's devDependencies reference unpublished monorepo-internal
  # packages (dsh-experimental-agent-team & co. — 404 on the registry) and a
  # prebuilt package never needs dev deps at runtime: drop the field so
  # `npm install` (and lock generation) never tries to resolve them.
  #
  # ⚠️ 必须按**块**删除，且不假设它的位置：
  #   · 0.2.0-rc.2 起 `exports` 排在 devDependencies **之后**，按「删到文件末尾」
  #     截断会连 `exports` 一并删掉 —— `./profile-boot` 等子路径导出随之失效，
  #     而构建照样成功（静默功能损坏）。
  #   · 0.1.5-rc.2 及更早则相反：devDependencies 是**最后一个**顶层字段，删除后
  #     必须同时去掉前一字段的尾逗号，否则 JSON 不闭合。
  # 下面的 awk 两种布局都覆盖：匹配顶层 devDependencies 块的起止行，删除后再
  # 按需修掉尾逗号。已在两份真实 tarball 上离线验证（JSON 均可解析、字段正确）。
  postPatch = ''
    cp ${lockFile} package-lock.json
    awk '
      /^  "devDependencies": \{/ { skip = 1; next }
      skip { if ($0 ~ /^  \},?$/) { skip = 0; deleted = 1 } next }
      { buf[++n] = $0 }
      END {
        if (deleted) {
          last = n
          while (last > 0 && buf[last] ~ /^[[:space:]]*$/) last--
          if (last >= 2 && buf[last] ~ /^\}[[:space:]]*$/ && buf[last-1] ~ /,[[:space:]]*$/)
            sub(/,[[:space:]]*$/, "", buf[last-1])
        }
        for (i = 1; i <= n; i++) print buf[i]
      }
    ' package.json > package.json.tmp
    mv package.json.tmp package.json
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
    # Guarded by [ -f ]: the exact client package set drifts between dsh
    # versions, so missing targets must not fail the build.
    UUID_FALLBACK='function __dshUuid(){if(globalThis.crypto&&globalThis.crypto.randomUUID)return globalThis.crypto.randomUUID();var b=globalThis.crypto.getRandomValues(new Uint8Array(16));b[6]=b[6]&15|64;b[8]=b[8]&63|128;var h=Array.from(b,function(x){return x.toString(16).padStart(2,"0")});return h.slice(0,4).join("")+"-"+h.slice(4,6).join("")+"-"+h.slice(6,8).join("")+"-"+h.slice(8,10).join("")+"-"+h.slice(10).join("");}'
    for f in \
      "$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-connection/lib/client.js" \
      "$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-ui-conversation/lib/client.js"; do
      if [ -f "$f" ]; then
        sed -i 's#crypto\.randomUUID#__dshUuid#g' "$f"
        sed -i "/factory: (require) => {/a\\$UUID_FALLBACK" "$f"
      fi
    done

    # cordis-plugin-timer 的已知 bug（上游最新 1.1.3 未修）：Context dispose
    # 时 cleanup 会 reject pending 的 ctx.timeout() promise（"Context has been
    # disposed"），调用者未 catch 时成为 unhandled rejection，被 dsh-app-boot
    # 的 installFailLoud 捕获后 process.exit(1)。这是正常的 dispose 竞态，
    # 不应终止整个服务 —— 忽略该特定错误，其余 fatal rejection 仍照常退出。
    # Guarded by [ -f ]: the file path drifts between dsh versions.
    BOOT_IDX="$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-app-boot/lib/index.js"
    if [ -f "$BOOT_IDX" ]; then
      sed -i '/if (assembledActivationRejections.has(err)) return;/a\\t\tif (err instanceof Error \&\& err.message === "Context has been disposed") return;' \
        "$BOOT_IDX"
    fi
'' + lib.optionalString allowLanSettings ''
    # 局域网设置读写：dsh 的 settings UI 只用「页面是否 loopback」决定设置
    # 镜像的持久化模式，非 loopback 页面被强制为 "memory"，镜像 status 置
    # "unavailable" 且 load()/ensure() 直接返回 —— 从不发出 settings/describe，
    # 模型设置页因此报 "settings are unavailable in this browser"。
    #
    # 服务端并不限制：settings/describe 与 settings/update 在 trustedHosts 的
    # authority 下均正常（实测 LAN authority 两者都返回 ok），Host fence 已是
    # 唯一且正确的边界。
    #
    # 浏览器端拿不到 trustedHosts，且 dsh ≥ 0.1.5 的 $host 服务不暴露
    # 连接状态（无 $host.state —— 旧 patch 的 state.getSnapshot() 会抛
    # "Cannot read properties of undefined"）。服务端 settings
    # describe/update 已有 Host fence（trustedHosts）作唯一边界，未认证
    # 页面无法通过 fence，故直接放宽为 "host" 持久化是安全的。
    # Guarded by [ -f ]：包路径随 dsh 版本漂移，缺失不应导致构建失败。
    #
    # 断言必须用 if/then，不能用 `grep -q … && { …; exit 1; }`：补丁**成功**时
    # grep 无匹配返回 1，&& 短路后整个命令列表的状态就是 1，而 genericBuild 在
    # set -e 下执行 postInstall —— 于是“打补丁成功”反而让构建中止（exit 1，
    # 且日志停在 npmInstallHook 之后、无任何错误文本，极难定位）。
    SETTINGS_CLIENT="$out/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-ui-settings/lib/client.js"
    if [ -f "$SETTINGS_CLIENT" ]; then
      sed -i 's#ctx\.remote\.\$host\.isLoopback ? "host" : "memory"#"host"#' "$SETTINGS_CLIENT"
      if grep -q 'isLoopback ? "host" : "memory"' "$SETTINGS_CLIENT"; then
        echo "dsh: lan-settings patch did not apply (upstream text changed)" >&2
        exit 1
      fi
    else
      echo "dsh: lan-settings patch target missing" >&2
      exit 1
    fi
'';

  # 通道标识（stable/alpha）：modules/dsh.nix 据此决定预设内容取自哪个
  # dsh-nixos-shell 变体（stable → 钉住的 rev，alpha → 仓库 HEAD）。
  # 放在 passthru 里而不是 meta：它不是包的元数据，是给本仓模块读的接线信息。
  passthru = { inherit dshChannel; };

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
