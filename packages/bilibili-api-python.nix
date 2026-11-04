{
  lib,
  python3Packages,
  fetchPypi,
}:

# bilibili-api-python —— B 站的 Python API 库。
#
# 为什么本仓要自带它：`bili-agent`（`bili` 命令）钉死 `bilibili-api-python==17.4.2`，
# 而 nixpkgs 里**没有**这个包（2026-11-04 查过）。上游 `pyproject` 的版本上限是
# 硬约束，不是「大概能跑」——同一族的 `blender-mcp` 就吃过 `mcp<2` 的亏：
# 跳过检查后运行期立刻 `ModuleNotFoundError`。
#
# 依赖全部来自 nixpkgs（12 个，逐个点名过）；本包本身是纯 Python。
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "bilibili-api-python";
  version = "17.4.2";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchPypi {
    # PyPI 的规范化名是下划线版本（sdist 文件名 `bilibili_api_python-17.4.2.tar.gz`）。
    pname = "bilibili_api_python";
    inherit (finalAttrs) version;
    hash = "sha256-PsYuqkVwJ3mVfq9w+6DF/3yFgFSATLYFeA92/uOI69U=";
  };

  pyproject = true;
  # `setuptools-scm` 是**构建期**依赖（上游用它从 git 推导版本）——放在
  # `dependencies` 里会被 `pythonRuntimeDepsCheckHook` 当成运行期要求，
  # 而放错层的症状是构建期 `Unmet dependencies … setuptools-scm`。
  build-system = [
    python3Packages.setuptools
    python3Packages.setuptools-scm
  ];

  dependencies = with python3Packages; [
    beautifulsoup4
    colorama
    lxml
    pyyaml
    brotli
    qrcode
    apscheduler
    pillow
    yarl
    pycryptodomex
    qrcode-terminal
    pyjwt
  ];

  # 模块名与包名不同：`import bilibili_api`。这条不是装饰——装上了但 import 不到
  # 时，第 4 层（运行）才会炸，而那是最晚的一层。
  pythonImportsCheck = [ "bilibili_api" ];

  meta = {
    description = "Bilibili API library for Python";
    homepage = "https://github.com/Nemo2011/bilibili-api";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.kitsunori ];
    platforms = lib.platforms.unix;
  };
})
