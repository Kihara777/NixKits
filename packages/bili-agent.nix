{
  lib,
  python3Packages,
  fetchPypi,
  bilibili-api-python,
}:

# bili-agent —— 为 AI 代理设计的 B 站 CLI（命令名 `bili`）。
#
# 上游自述：每条命令只在 stdout 打**一个 JSON**、零交互、账号操作自带限流/审计/
# 私信白名单。这几条正是它能被无人值守会话使用的理由——输出可判、不需要人看着。
#
# 依赖里 `bilibili-api-python` **必须是本仓那个**：上游钉死 `==17.4.2`，而 nixpkgs
# 没有它。用 nixpkgs 的未来版本会撞上运行期行为差异，而且 `==` 本来就是硬约束。
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "bili-agent";
  version = "1.3.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchPypi {
    # PyPI 名 `bili-agent`，`pname` 取规范化后的下划线形式。
    pname = "bili_agent";
    inherit (finalAttrs) version;
    hash = "sha256-9K7bxKiultU/0xDx8h2ibL5ME06f9FnUJbLkOcyPlyk=";
  };

  pyproject = true;
  build-system = [ python3Packages.hatchling ];

  dependencies = [ bilibili-api-python ] ++ (with python3Packages; [
    typer
    qrcode
    # 上游写的是 `qrcode[pil]`：二维码要渲染成图片给人类扫，少了 pillow 只能出文本。
    pillow
    httpx
    curl-cffi
  ]);

  # 命令名 `bili`，模块名 `bili_cli`。装上了但 import 不到时，第三层（产物）
  # 看不出来，只有第四层（`bili --version`）会炸。
  pythonImportsCheck = [ "bili_cli" ];

  meta = {
    description = "Bilibili CLI designed for AI agents (JSON output, zero interaction)";
    homepage = "https://github.com/kukemc/bili-cli";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.kitsunori ];
    platforms = lib.platforms.unix;
    mainProgram = "bili";
  };
})
