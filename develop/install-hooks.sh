#!/usr/bin/env bash
# 把仓库的 git 钩子挂上（每台机器设一次）。
#
# 钩子本身随仓放在 `.githooks/`（入 git），`core.hooksPath` 只指向那个目录，
# 所以换机器/重克隆之后跑一次这个脚本即可。
#
# 注意定位：钩子是**追加**的本地拦截，**兜底永远是 CI**——CI 不依赖这个脚本
# 是否被执行过。
set -euo pipefail
cd "$(dirname "$0")/.."

git config core.hooksPath .githooks
chmod +x .githooks/pre-push develop/precheck.sh

echo "已设置 core.hooksPath = .githooks"
echo "  推之前会跑 develop/precheck.sh（13 项，约 20 秒）"
echo "  临时绕过：git push --no-verify（等于把判断交给 CI）"
