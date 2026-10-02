# opencode-telegram —— OpenCode 的 Telegram Bot 客户端。
#
# ⚠️ **riscv64 不构建**（2026-10-02 决定，理由与证据见 AGENTS.md 的 CI 一节）：
# 本包**直接依赖** `better-sqlite3`，且在 `dist/app/services/session-cache-service.js`
# 里被**静态 import**（启动即加载）。而它：
#   · `prebuilds/` 只有 darwin/linux/musl/win32 × x64/arm64，**没有 riscv64**；
#   · v13 起取消了 `install` 脚本（改成纯 prebuilds 分发），所以 `npm rebuild`
#     也不会把它编出来——实测 riscv64 产物里根本没有 `better_sqlite3.node`；
#   · `lib/binding.js` 只认 `build/{Debug,Release}/better_sqlite3.node` 或
#     `prebuilds/<平台>-<架构>.node`，两条路在 riscv64 上都是空的。
# 结论：riscv64 产物**能构建、但一启动就抛**。本机也没有 riscv64 硬件可验证运行，
# 留一个「绿而不可用」的产物，比明确标记「不支持」更糟——故摘掉该 workflow。
#
# 若要恢复 riscv64：先解决 SQLite 绑定（`deps/sqlite3/sqlite3.c` 随 npm 包分发，
# 9 MB，可离线编，但需自己接一条构建步骤）。**顺带一个坑**：交叉构建的 PATH 上
# **没有裸 `gcc`**，而 `msgpackr-extract` 的 binding.gyp 会 shell out 执行
# `gcc -dumpversion | cut -d '.' -f 1`——命令失败 ⇒ 展开成空串 ⇒ gyp 里变成
# `"" >= 7` ⇒ `TypeError: '>=' not supported between instances of 'str' and 'int'`。
# 补一个指向**交叉**编译器的裸名 `gcc` shim 即可让那一步过（实测能产出真正的
# riscv64 `extract.node`），但光有它不够——better-sqlite3 那道坎还在。

{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
  python3,
}:

buildNpmPackage (finalAttrs: {
  pname = "opencode-telegram";
  version = "0.26.2";

  src = fetchFromGitHub {
    owner = "grinev";
    repo = "opencode-telegram-bot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t8MjkxXKKvAfqmC67o2M7vhx7QPIkhOmraxJ6XJ3LiU=";
  };

  npmDepsHash = "sha256-5IW3Zk1nRjUZHetvqKvJTlOlm8DzexkgNrkzCVRz0AQ=";
  npmBuildScript = "build";
  npmInstallFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [ nodejs ] ++ lib.optionals (lib.versionAtLeast nodejs.version "20") [ python3 ];

  postInstall = ''
    wrapProgram "$out/bin/opencode-telegram" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  meta = {
    description = "OpenCode Telegram Bot - Secure Telegram client for OpenCode CLI";
    homepage = "https://github.com/grinev/opencode-telegram-bot";
    changelog = "https://github.com/grinev/opencode-telegram-bot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "opencode-telegram";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
