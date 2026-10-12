# PR #572912 完整内容核查（2026-10-12 修正版）

**这是「若现在重建分支并按新条目提交」之后的完整内容。**
上一版预览的插入点是错的（见文末），本版按修正后的位置。

---

## PR 改动的两个文件（共 +75 行）

### 文件 1/2 —— `pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix`

**新增文件，69 行，逐字如下：**

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

**插入 6 行。上游 master 33125 行 / 5293 条目 → 33131 行 / 5294 条目**

**插入点：第 15387 行**（`Kitt3120` 之前）

```diff
   Kitsune = {
     name = "Lunae V";
     github = "KitsuneDev";
     githubId = 11809449;
     email = "kitsune@akitsune.dev";
     matrix = "@kitsune:akitsune.dev";
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
   Kitt3120 = {
     email = "nixpkgs@schweren.dev";
     github = "Kitt3120";
     githubId = 10689811;
     name = "Torben Schweren";
   };
   kittyandrew = {
     email = "alias.nixpkgs.maintainer@kittymail.me";
     github = "kittyandrew";
     githubId = 45767571;
   };
```

> **看上面 `Kitsune` / `kitsunoff` / `kitsunori` / `Kitt3120` / `kittyandrew` 这一段** ——
> 大写小写混在一起，因为排序是**忽略大小写**的。这就是我上一版漏掉 340 个大写条目、
> 把插入点算到 `kittyandrew` 前面的原因。

---

## 两个 commit

```
maintainers: add kitsunori

Assisted-by: DeepSeek Harness (DeepSeek-V41-Flash)
```

```
obs-bilibili-stream: init at 2.1.5
```


---

## 核查依据（每条都跑过，且是**当前**跑的）

| 判据 | 结果 |
|---|---|
| 求值 + 构建 | ✅ `/nix/store/h8mg7vdl…-obs-bilibili-stream-2.1.5` |
| **运行层：真 OBS 加载** | ✅ OBS 日志里 `插件加载成功` + `bilibili-stream-for-obs.so` |
| **运行层对照臂** | ✅ `plugins = [ ]` 时那两行**都不出现** |
| 自动发现 + 属性名来源 + 反证臂 | ✅ |
| `discovery.sh` 的 maintainers 判据 | ✅ `['Kihara777']` |
| **插完之后整个文件仍有序** | ✅ 5294 条目，忽略大小写有序 = True |
| 反证：插到错位置 | ✅ **有序 = False** —— 会被 CI 抓到 |
| `nixfmt --check` + `nix-instantiate --parse`（带非 ASCII 的 name） | ✅ |
| SSOT 与文档逐字相同 | ✅ |
| 五项仓库检查 | ✅ 全 PASS |

## 与上一版预览的差异（**你要求重看的原因**）

| | 上一版（错） | 本版（修正） |
|---|---|---|
| 插入点 | 第 15393 行，`kittyandrew` 之前 | **第 15387 行，`Kitt3120` 之前** |
| 条目总数 | 4898 | **5293** |
| 属性名 | `kihara777` | **`kitsunori`** |
| `name` | `Kihara777` | **`狐莉`** |
| 包文件路径 | （`PR-POLICY-QUESTION.md` 里我写成了 `by-name/…`，错） | **`pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix`** |

**错因**：算插入点的正则只匹配小写开头的属性名，整个漏掉 340 个大写条目。

---

## 这份文档本身怎么核的

- **`maintainer-list.nix` 的上下文**：23 行逐字比对上游 master，**0 行找不到**。
- **文档里那条 `Kitsune` 条目**：我第一版**编造**了它（写成 `github = "KiTSune"` 并
  加了一句自己想的注释）。发现后换成上游原文，并加了上面这条比对作为判据。
  **编造的形状不是「写错」，是「写得像真的」** —— 所以判据必须是「拿原文比对」，
  不是「看着像」。
