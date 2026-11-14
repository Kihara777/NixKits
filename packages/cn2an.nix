{
  lib,
  python3Packages,
  fetchurl,
  # **依赖显式传参**，不从 `python3Packages` 里取（2026-11-13 实测：
  # `pkgs.callPackage` 会直接拒绝带 `python3Packages` 的包——
  # "do not use python3Packages when building Python packages"）。
  # 本包在 nixpkgs 里没有，所以在调用方用 `ps:` 作用域构造出来再传进来。
  proces,
}:

# cn2an —— 中文数字转阿拉伯数字（「一百二十三」→ 123）。
#
# 为什么本仓要自带它：Kokoro 的中文前端（`misaki/zh.py`）`import cn2an`，而
# **nixpkgs 里没有这个包，也没有它的依赖 `proces`**（2026-11-13 逐个查过：
# `cn2an` / `cn-2-an` / `chinese2an` 三个属性名都不存在）。
#
# 后果不是「装不上」而是**装得上、一用中文就炸**：
#   nixpkgs 的 `python3Packages.kokoro` 没有声明中文路径的依赖，
#   于是 `kokoro -m zf_xxx -t "你好"` 运行时才 `ModuleNotFoundError`。
# 那条链上依次缺的是 `ordered_set` → `pypinyin` → `cn2an`。
#
# 依赖只有 `proces`（同作者，纯 Python，也在本仓 `proces.nix`）。两个都是 MIT。
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "cn2an";
  version = "0.5.24";

  strictDeps = true;
  # nixpkgs 新版要求显式声明构建后端（2026-11-13：不写会报
  # "does not configure a `format`"）。上游是 setuptools 的 setup.py。
  pyproject = true;
  build-system = [ python3Packages.setuptools ];
  __structuredAttrs = true;

  # `fetchPypi` 的 `format = "sdist"` 不被支持（2026-11-13 实测报
  # `Unsupported format sdist`），所以直接给 files.pythonhosted 的地址。
  # 用 `fetchurl` 而不是写死 pypi URL：前者接受 sha256 并进 store。
  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/source/c/cn2an/cn2an-0.5.24.tar.gz";
    hash = "sha256-wnbPxLPJ51ghSEHeWXUC6xeN5QuNomM+00VWT5BwXw4=";
  };

  dependencies = [ proces ];

  # 上游没有跑得起来的测试套件（sdist 里只有源代码），所以显式关掉而不是留空：
  # 「没有测试」和「测试没过」是两件事，这里写清楚是前者。
  doCheck = false;

  pythonImportsCheck = [ "cn2an" ];

  meta = {
    description = "Convert Chinese numerals to Arabic numerals";
    homepage = "https://github.com/Ailln/cn2an";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
