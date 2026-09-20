# 陷阱与专项检查（配套参考）

本文件是 **`nix-flake-update-check` 技能**的参考部分：常见陷阱、以及不属于
主流程编号步骤的专项检查。**主流程在 `SKILL.md`。**

**第 7 步的「提交前八问自检」直接指向本文件**——八问中每一问都对应这里的
一个章节，命中后再深入阅读，不必通读全文。其中的 **Actions 更新**一节由
**第 2 步末尾**主动指向（它不属于"命中才读"，而是每轮都应确认的一类更新）。

## 目录

| 章节 | 何时查 |
|---|---|
| [常见陷阱（nixpkgs 漂移）](#常见陷阱nixpkgs-漂移) | 构建失败或系统切换失败时 |
| [检查补丁内版本](#检查补丁内版本) | 包依赖 `.patch` 文件时 |
| [审计文档中的外部链接](#审计文档中的外部链接) | 收尾审计时 |
| [检查 GitHub Actions 的更新](#检查-github-actions-的更新) | **每轮都要**（见 SKILL.md 第 2 步末尾） |

---

## 检查补丁内版本

部分补丁在上游项目的 `.patch` 文件中直接硬编码了依赖的版本号和 hash。
这类补丁的版本更新需要手动处理。

### 识别

```bash
# 搜索 patch 文件中的版本号模式（目录名按仓库实际调整）
grep -rln -E '[0-9]+\.[0-9]+\.[0-9]+' patches/*.patch | sort -u

for patch in $(grep -rln -E '[0-9]+\.[0-9]+\.[0-9]+' patches/*.patch); do
  echo "=== $patch ==="
  grep -n -E 'version|hash|url.*http' "$patch" | head -10
done
```

### 通用更新流程

1. 从 patch 中提取上游资源 URL 和当前版本
2. 检查上游是否有新版本：

```bash
# GitHub Release（如适用）—— 用 gh api，空结果须报错而非当成"最新"
gh api "repos/<owner>/<repo>/releases/latest" --jq .tag_name

# PyPI / wheel 目录（如适用）
curl -s "<wheel-index-url>" | grep -oP '<package>-[0-9]+\.[0-9]+\.[0-9]+' | sort -Vu | tail -1
```

> ⚠️ **取到空值时必须报错**，不要继续往下走。见 `SKILL.md` 第 3 步的
> 「用 `gh api` 而不是裸 `curl`」——**空结果被当成"已是最新"是本流程最危险的
> 失败形态**：不报错、只撒谎。

3. 下载新资源获取 SRI hash：

```bash
nix hash to-sri sha256:$(curl -sL <new-url> | sha256sum | cut -d' ' -f1)
```

4. 更新 patch 文件中对应的 `version`、`url`、`hash` 字段
5. 重新生成 patch：在上游仓库中修改后执行 `git diff > patches/<name>.patch`
6. 在目标环境测试构建

> **⚠️ 警告**：补丁内版本更新后，旧的 hash 将失效。务必在提交前完成完整的
> 构建测试。涉及 GPU/硬件相关补丁时，需在目标硬件上实测验证。

## 审计文档中的外部链接

更新流程结束前，检查文档里的上游链接是否仍然有效。**上游项目会改名、迁移
组织、归档仓库**——这些变化不产生任何构建错误，只让文档里的链接悄悄失效，
而链接恰恰是读者追溯来源的唯一入口。

```bash
# 抽取所有外部链接（含各语言文档），逐个探测
grep -rhoP 'https://[a-zA-Z0-9.-]+/[a-zA-Z0-9._/%#-]+' --include="*.md" . |
  sed 's/[.,)]*$//' | sort -u | while read u; do
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$u")
    case "$code" in 200|301|302|429) ;; *) echo "$code  $u";; esac
  done
```

**判定与处置**：

| 结果 | 含义 | 处置 |
|---|---|---|
| `404` | 目标确实不存在（项目迁移/改名） | **查证新地址并修正**（见下） |
| `403` | 常有反爬（如 `projects.blender.org`） | **不是死链**，用浏览器或 `gh api` 复核 |
| `429` | 被限流 | 稍后重试，**不要**据此判定失效 |
| `301/302` | 正常重定向 | 可保留 |

> ⚠️ **`curl` 的 404 不足以定案**：GitHub 对某些请求返回 404 也可能是
> 权限或限流所致。用 `gh api repos/<owner>/<repo>` 复核——
> **能取到仓库信息才是确证**。

**查证迁移去向**：项目改名后旧地址通常 404，新地址可用以下方式找到：

```bash
gh api repos/<old-owner>/<repo> --jq '.full_name'   # 404 → 已迁移
gh search repos <repo-name> --limit 5 --json fullName,stargazersCount
```

**修正时同步改「链接文字」**：显示文本若含 `owner/repo`，必须与新地址一致
（只改 URL 会让读者看到与实际不符的来源）。**多语言文档全部同步。**

> **不要改 vendored 第三方内容**：若链接出现在 `vendor/`、`*-src/` 等随上游
> 一同引入的路径中（如依赖包的 CHANGELOG），那是上游的文档，**其链接失效
> 不属我们的维护范围**，强行改写反而偏离上游。

## 检查 GitHub Actions 的更新

若仓库把第三方 action 固定到提交 SHA（供应链卫生的常见做法），
**固定之后就收不到更新通知了**——这是一处必须主动检查的盲点。

### 为什么这适用于所有经手人，而不只是维护者

固定 SHA 是**共同的选择**：任何为了供应链安全而把 action 钉到 SHA 的人——
仓库的维护者、被授权提交的贡献者、以及准备提交 PR 的潜在贡献者——都会
继承同一个副作用：**通知渠道随固定动作一起被关掉了**。

因此本节对以下角色**同样适用**，判据不依赖你在仓库中的身份：

| 角色 | 何时需要这条检查 |
|---|---|
| **维护者** | 定期检查（见下「触发时机」）——这是唯一会主动发现它的途径 |
| **贡献者 / 潜在贡献者** | 改动 workflow、或提交涉及 CI 的 PR 前先核对；发现 action 过期可**一并升级**再提 PR |
| **审计者 / 接手者** | 评估仓库供应链状态时，固定 SHA 的 action 正是"看得到但不会自动更新"的一类 |

**为什么要自己查而不是靠外部自动化**：Dependabot 一类工具是外部自动化集成，
**由托管平台运行、其行为不由仓库掌控，也无法审计**。若仓库的安全边界要求
「不引入外部自动化」（或其托管环境根本提供不了这类服务，如自托管 forge），
就应自行实现同等能力——下面的流程只用到 `gh api` 与 `git`，任何有读权限的
人都能跑，**完全可审计**。

> **判据是「能否自行实现」，不是「谁在用」**：托管平台若已启用此类自动化，
> 本节可作为**交叉核对**（自动化只在其配置的版本通道内推进，见 `builders.md`
> 关于 dist-tag 落后的说明）；若没有启用，本节就是**唯一**途径。两种情况都
> 值得跑一遍——命令是只读的，成本只有几秒。

### 触发时机

**每轮更新检查都跑一遍**（发现命令见 `SKILL.md` 第 2 步末尾）；此外：
改动任何 `ci/`、`.github/workflows/` 下的文件时，**顺手核对一次**。

### 第 1 步：列出所有固定的 action

```bash
grep -rhoE 'uses: [^ ]+@[0-9a-f]{40}' .github/workflows/*.yml |
  sed 's/uses: //' | sort -u
```

输出形如 `actions/checkout@3d3c42e5…`。**同时记下注释里的版本号**
（如 `# v7.0.1`），流程末尾需要同步更新它。

> ⚠️ **先看清"谁在引用"**：若某 action 出现在**可复用的 workflow**
> （如 `build-package.yml`）里、被其他几十个 workflow `uses:` 引用，
> 那么**只需改那一处**——不要按引用次数重复修改，否则会产生大量重复 diff。

```bash
# 每个 action 的实际引用处数量（1 处 = 只改可复用 workflow，多出的是调用方）
grep -rc '<owner>/<repo>@' .github/workflows/*.yml | grep -v ':0'
```

### 第 2 步：查最新版本

```bash
check_action() {
  local repo="$1"          # 如 actions/checkout
  echo "=== $repo ==="
  gh api "repos/$repo/releases/latest" --jq '.tag_name' 2>/dev/null ||
    gh api "repos/$repo/tags" --jq '.[0].name' 2>/dev/null ||
    echo "（无 release/tag，改用分支：见下）"
}
```

> ⚠️ **有些 action 不用 release**（如 `DeterminateSystems/nix-installer-action`
> 直接跟踪 `main`）。这类要查分支头：
>
> ```bash
> gh api repos/DeterminateSystems/nix-installer-action/commits/main --jq '.sha'
> ```

### 第 3 步：取 tag 对应的提交 SHA

**必须取 tag 指向的 commit，不能取分支头**——否则会把未发布状态引入 CI：

```bash
gh api repos/<owner>/<repo>/git/ref/tags/<tag> --jq '.object.sha'
```

> ⚠️ **若返回 `type: "tag"`（annotated tag）**，再取一层：
>
> ```bash
> gh api repos/<owner>/<repo>/git/tags/<sha> --jq '.object.sha'
> ```

### 第 4 步：更新并写回注释

```diff
-      - uses: actions/checkout@11d5960a…  # v4
+      - uses: actions/checkout@3d3c42e5…  # v7.0.1
```

**注释中的版本号必须一并更新**——它是下次检查时的比对基准，不同步会让
后续核对失去参照。

### 第 5 步：验证

```bash
nix flake check          # 语法与结构
```

并确认 CI 通过。**注意区分偶发失败**：GitHub API 限流（`HTTP error 403`
拉取 `api.github.com`）与 action 升级无关，重跑即可——判断方法是看**失败
的是否只有涉及该 API 的 job、其余 job 是否通过**。

### 判据：何时该升级

| 情况 | 处理 |
|------|------|
| 跨大版本（如 v4 → v7） | 读 release notes 确认 breaking change 与安全修复 |
| 仅 patch/minor | 通常可直接升 |
| action 跟踪浮动分支（`@main`） | **优先固定到 SHA**，而非被动跟随 |

#### 若你不是维护者：升级 action 也应走 PR

固定 SHA 之后的升级**改了仓库的 CI 行为**，属于需要评审的变更——即使你有
写权限，也建议开 PR 而非直接推 main（除非该仓库的约定允许直接提交）。

| 场景 | 做法 |
|---|---|
| 顺手发现 action 过期、与手头任务无关 | **不要混进当前 PR**——另开一个只改 action 的 PR，便于单独评审与回滚 |
| 与当前 PR 的 CI 改动相关 | 可在同一 PR 内一并升级，并在描述里点明 |
| 无写权限 | PR 是唯一途径；在描述里附上 release notes 链接与**新旧 SHA 的对照**，降低评审成本 |

> ⚠️ **改前先确认上游 tag 真实存在**：`gh api repos/<owner>/<repo>/git/ref/tags/<tag>`
> 要能取到——**不要凭记忆或 release 页面标题推断 SHA**。取不到就说明 tag 名不对
> （有的用 `v` 前缀、有的不用），回到第 2 步重新查。


## 常见陷阱（nixpkgs 漂移）

更新后若系统切换（`nixos-rebuild switch` / `darwin-rebuild switch`）失败，
优先排查以下 nixpkgs 漂移陷阱。

### 1. 恢复旧 generation / flake.lock 时必须核对 `inputs.*.follows`

只复制旧 `flake.lock` 而忽略 `flake.nix` 会丢失 `inputs.<x>.follows` 配置，
导致子 flake 重新用独立锁定的旧 nixpkgs（如 glibc 2.40）→ 运行时
`GLIBC_ABI_GNU2_TLS` 崩溃。恢复时需同时核对 `flake.nix` 中子 flake 的
follows/url 定义，并验证 eval 出的实际 nixpkgs rev。

### 2. python 包跳过测试用 `doInstallCheck = false`，不是 `doCheck = false`

`pytestCheckHook` 把 pytest 套件跑在 **installCheckPhase**，`doCheck=false`
无效（测试仍执行）。跳过测试必须设置 `doInstallCheck = false`。

### 3. nixpkgs ≥ 2026-08-05 的 `pythonRuntimeDepsCheckHook` 破坏 wheel 构建

新版 nixpkgs 引入 `pythonRuntimeDepsCheckHook`：wheel 的 METADATA 声明了运行时
依赖（由运行环境提供）时构建失败。对策：在 vendored wheel 的 mkWheel 中加
`dontCheckRuntimeDeps = true`。

### 4. 无参数 `nix flake lock` 会刷新所有浮动 input（nixpkgs 漂移重演）

`nix flake lock`（不带参数）会把所有浮动引用的 input（如
`nixpkgs.url = ".../nixos-unstable"`）更新到最新版本。恢复旧 generation /
固定依赖后若需重新 lock：

- ✅ 用 `nix flake lock --update-input <name>` 只更新目标 input
- ✅ 或直接在 `flake.nix` 中把 nixpkgs 固定到已验证 rev（`github:nixos/nixpkgs/<full-rev>`）
- ❌ 避免无参数 `nix flake lock` —— 会把 nixpkgs 漂移到新版本，触发新的
  `pythonRuntimeDepsCheckHook` / flaky 测试失败

> 判断方法：报错含 `pythonRuntimeDepsCheckHook` / `not installed` /
> `GLIBC_ABI_GNU2_TLS` 且位于 python 包构建阶段 → 命中陷阱 2 或 3；
> 位于服务启动阶段 → 命中陷阱 1。

### 5. 上游的「fail-closed 运行时依赖校验」：构建通过 ≠ 可用

有些项目在**启动时**校验依赖的精确版本，不匹配就直接拒绝启动。此时
`nix build` **会成功**，但你第一次运行才炸——典型的假成功。

实测样本（godot-ai v4）：`verify_runtime_dependencies()` 比对 9 个包的精确
版本，任一不符即 `RuntimeError: unsupported godot-ai runtime dependency set`。
nixpkgs（含 unstable/master）在 5 个包上落后，故构建产物**根本起不来**。

**识别**：上游把依赖写成 `==x.y.z` 硬 pin，且源码中有 `verify_*`/
`check_*version*` 一类的启动期校验函数。

**验证**：构建后**必须实际运行一次**（`--version` 即可），不能只看构建成功：

```bash
OUT=$(nix build .#<pkg> --print-out-paths --no-link)
"$OUT/bin/<pkg>" --version        # 构建成功但此处抛错 = 命中本陷阱
```

**对策（按优先级）**：

1. **抬依赖版本对齐上游**（推荐）——建 overlay 把 nixpkgs 的包改到上游要求
   的版本。nixpkgs 落后不代表不能改：用 `overridePythonAttrs` 改
   `version` + `src` + `hash` 即可（Rust 构建的包还要改 `cargoDeps`）。
2. **确认无法对齐时**（如多个包需大改），向用户提问取舍，不要自行打补丁
   绕过校验——那会**破坏上游有意的安全契约**，而 v4 的校验恰恰是为安全
   边界服务的。

> ⚠️ **不要把 `dontCheckRuntimeDeps = true` 当成万能解**：它只静默
> **构建期**的 `pythonRuntimeDepsCheckHook`，对**运行期**的自校验完全无效。
> 两者名字相似但作用阶段不同——构建期过了，运行时照样拒绝启动。

### 6. `overridePythonAttrs` 改动 Rust 构建的包时，`cargoDeps` 要一并重取

python 包若含原生扩展（如 `pydantic-core` 由 Rust 构建），改 `version`/`src`
后 `cargoDeps` 也必须重算，否则 vendor 阶段失败。取 hash 的报错路径：

```bash
# sourceRoot 用 fetchFromGitHub 解包后的实际目录名（通常是 "source/<子目录>"），
# 不是 "<pname>-<version>/<子目录>"——写错会报
# "chmod: cannot access '...': No such file or directory"
```

> 若包的测试套件在新版本中新增依赖（如 websockets 17.1 新增 `tests/trio/`
> 而 nixpkgs 的 check inputs 没有 trio），见下条。

### 7. 上游新增依赖：先分清「运行时依赖」与「测试依赖」，再看失败形态

升级中「构建失败」的高频根因是上游**新增了一个依赖**，而包定义没有跟上。
两处需要分别检查，**且不要只看报错表象**：

| 上游写在哪 | 需要补到哪 | 不补的后果 |
|---|---|---|
| `dependencies` / `install_requires` | `propagatedBuildInputs`（python）/ `buildInputs` | 构建能过，**运行时**才炸——最难查 |
| 测试目录内的 import（`tests/**`） | `nativeCheckInputs` / `checkInputs` | 构建期报 `ModuleNotFoundError` |

**判断优先级**：先读上游 `pyproject.toml` / `package.json` 的 `dependencies`，
**再**看测试目录。只按测试依赖处理、把运行时依赖漏掉，会得到「本地构建通过、
用户装完启动即崩」的假成功。

#### 失败形态决定了修复的紧迫度：collection error ≠ 单条失败

pytest 在**收集期**（collection）遇到 `import` 失败，报的是
`Interrupted: 1 error during collection`，**整个套件立即中止**，而不是把这一条
标记为 failed。因此：

- 看到 `Interrupted: ... error during collection` → 是**缺依赖**（导入期问题），
  不是测试逻辑失败。**不要去改测试或加 `--ignore`**，补依赖即可。
- 同一仓库的**其它通道**（stable / beta / alpha 共享一个 base 定义）会**一起**
  失败——因为依赖列在共享的 `.nix` 里。修一处即修全部，但要**逐个通道复验**。

```bash
# 定位是哪条 import 失败（报错里会给出文件与行号）
#   tests/ruyipkg/abi/test_elfbuilder.py:3: from elftools.elf.elffile import ELFFile
# 再回查上游声明，确认它是「运行时」还是「仅测试」：
curl -sL "https://raw.githubusercontent.com/<owner>/<repo>/<rev>/pyproject.toml" \
  | sed -n '/^dependencies/,/^\]/p'
```

**验证闭环**：补完后除构建通过，还要**核对文档里的测试数量**——上游加测试会让
文档中「pytest 单元测试（N 项）」这类硬编码数字过期。从构建日志直接取真值：

```bash
nix log .#<pkg> 2>/dev/null | grep -E '[0-9]+ passed'
```


