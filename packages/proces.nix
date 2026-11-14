{
  lib,
  python3Packages,
  fetchurl,
}:

# proces —— 文本预处理的小工具库。
#
# 为什么本仓要自带它：它是 `cn2an` 的**唯一依赖**，而 nixpkgs 里没有
# （2026-11-13 查过）。`cn2an` 又是 Kokoro 中文前端的必需项，所以这条链
# 一个都不能少：
#
#   kokoro（nixpkgs 有）→ misaki.zh → cn2an（本仓）→ proces（本仓）
#
# 纯 Python，无自己的依赖。MIT。
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "proces";
  version = "0.1.7";

  strictDeps = true;
  # nixpkgs 新版要求显式声明构建后端（2026-11-13：不写会报
  # "does not configure a `format`"）。上游是 setuptools 的 setup.py。
  pyproject = true;
  build-system = [ python3Packages.setuptools ];
  __structuredAttrs = true;

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/source/p/proces/proces-0.1.7.tar.gz";
    hash = "sha256-cKBdnpc91oX3qQksWL5pWoGBpBHWN5bCEyMv0/3EN3U=";
  };

  # 上游没有测试套件（summary 一行「text preprocess.」就是这个包的全部自述）。
  doCheck = false;

  pythonImportsCheck = [ "proces" ];

  meta = {
    description = "Text preprocessing helpers (cn2an dependency)";
    homepage = "https://github.com/Ailln/proces";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
