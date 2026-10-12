# PR #572912 —— 推送前的完整内容（2026-10-12 最终版）

**本文档的每一段都从源文件读出，不是手写的。** 生成脚本见文末。

---

## PR 改动的两个文件（共 +75 行）

上游 master：`4ac3b338334f`（我们 PR 的 base 是 `3bcc3c4`，master 已前进；
`maintainer-list.nix` 自那次起**未变**，所以补丁仍然适用）

### 文件 1/2（新增，69 行）

路径：`pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix`

```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  obs-studio,
  curl,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-bilibili-stream";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "Zarosmm";
    repo = "obs-bilibili-stream";
    tag = finalAttrs.version;
    hash = "sha256-cFIPbOHhafsH1YLV8wqnRZF+df3K/cEWP6h6KuZsqNc=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    obs-studio
    curl
    qt6.qtbase
  ];

  # Upstream enables both of these in its CMakePresets.json while CMakeLists.txt
  # defaults them to OFF:
  #
  # - ENABLE_QT finds the Qt headers the dialog needs; without it the build fails
  #   with "QMenuBar: No such file or directory".
  # - ENABLE_FRONTEND_API links libobs-frontend-api, which the plugin uses to
  #   register its menu entry; without it that library is missing from NEEDED.
  cmakeFlags = [
    "-DENABLE_FRONTEND_API=ON"
    "-DENABLE_QT=ON"
  ];

  # The plugin ships a Qt dialog but OBS resolves the Qt libraries itself, so
  # wrapping the plugin would be wrong.
  dontWrapQtApps = true;

  # Upstream's CMake installs the plugin twice: into lib/obs-plugins/ (the
  # layout the OBS wrapper reads, via OBS_PLUGINS_PATH) and into
  # obs-plugins/64bit/ (OBS's own default prefix). The second copy is unused
  # here and only adds weight and confusion, so drop it.
  postInstall = ''
    rm -rf "$out/obs-plugins"
  '';

  meta = {
    description = "Bilibili streaming plugin for OBS Studio";
    homepage = "https://github.com/Zarosmm/obs-bilibili-stream";
    changelog = "https://github.com/Zarosmm/obs-bilibili-stream/releases/tag/${finalAttrs.version}";
    # The project's own appstream metadata declares <project_license>GPL-2.0-only</project_license>.
    # The LICENSE file is the stock GPLv2 text, and src/plugin-support.{h,c.in} are the
    # unmodified OBS plugin template (placeholders still unfilled), so the "or any later
    # version" wording there is boilerplate rather than the author's grant.
    license = lib.licenses.gpl2Only;
    # A plugin cannot be built where its host cannot: obs-studio has no riscv64.
    inherit (obs-studio.meta) platforms;
    maintainers = with lib.maintainers; [ kitsunori ];
  };
})
```

### 文件 2/2 —— `maintainers/maintainer-list.nix`

插入 **6 行**，第 **15387** 行，`Kitt3120` 之前。
条目数 **5293 → 5294**；**插入后忽略大小写有序 = True**。

```diff
   };
   kitsunoff = {
     github = "kitsunoff";
     githubId = 58953114;
     name = "Maxim Belyy";
   };
+  kitsunori = {
+    email = "kitsunori@g41.moe";
+    github = "Kihara777";
+    githubId = 24633616;
+    name = "狐莉";
+  };
   kittyandrew = {
     email = "alias.nixpkgs.maintainer@kittymail.me";
     github = "kittyandrew";
     githubId = 45767571;
     matrix = "@kittyandrew:ndrew.me";
```

---

## 两个 commit

### commit 1

```
maintainers: add kitsunori

Assisted-by: DeepSeek Harness (DeepSeek-V41-Flash)
```

### commit 2

```
obs-bilibili-stream: init at 2.1.5
```

正文 = [`commit-message.txt`](commit-message.txt) 逐字。

---

## PR 标题

```
obs-bilibili-stream: init at 2.1.5
```


---

## 判据（本次全部重跑，用**当前**的上游文件）

| 判据 | 结果 |
|---|---|
| 上游 `maintainer-list.nix` 与上次分析的是否同一份 | ✅ **相同**（`cmp` 逐字节） |
| 插入后条目数 | ✅ 5293 → **5294** |
| **插入后整个文件仍忽略大小写有序** | ✅ **True** |
| 反证：插到 `kittyandrew` 之前（我先前算的错位置） | ✅ 有序 = **False** —— 会被 CI 抓到 |
| `nix-instantiate --parse`（插入后的完整文件） | ✅ |
| `nixfmt --check`（同上） | ✅ |
| 求值取回条目 | ✅ `{"email":"kitsunori@g41.moe","github":"Kihara777","githubId":24633616,"name":"狐莉"}` |
| 包定义求值 + 构建 | ✅ `/nix/store/h8mg7vdl…-obs-bilibili-stream-2.1.5` |
| 运行层：真 OBS 加载 | ✅ `插件加载成功` + `bilibili-stream-for-obs.so` |
| 运行层对照臂 | ✅ 不挂插件时那两行**都不出现** |
| 自动发现 + 属性名来源 + 反证臂 | ✅ |
| `discovery.sh` 的 maintainers 判据 | ✅ `['Kihara777']` |
| SSOT 与本文档逐字相同 | ✅ |
| 五项仓库检查 | ✅ 全 PASS |

## 本文档怎么生成的

**不是手写的。** 生成脚本从三个源读内容：

1. 条目（6 行）—— 从 `upstream/maintainer-entry.nix`（SSOT）读字段拼出
2. 包定义（69 行）—— 从 `upstream/obs-bilibili-stream/package.nix` 逐字读
3. 插入点与上下文 —— 从**当前上游 master** 的 `maintainer-list.nix` 现取

**为什么强调这一点**：我在同一份文档的上一版里**编造过一条上游条目**
（把 `Kitsune` 写成 `github = "KiTSune"` 还加了句自己想的注释）。
编造的形状不是「写错」，是「**写得像真的**」—— 所以判据只能是
「内容来自源文件」，不是「看着像」。
