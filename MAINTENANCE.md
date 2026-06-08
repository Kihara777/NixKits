# MAINTENANCE.md

NixKits 软件更新维护日志。

---

## 2026-06-08T14:25:02+09:00

软件更新：mcp-searxng 1.1.0 → 1.2.1

Package update: mcp-searxng 1.1.0 → 1.2.1

パッケージ更新：mcp-searxng 1.1.0 → 1.2.1

### 变更内容

- **mcp-searxng** (`packages/mcp-searxng.nix`)
  - 版本号：`1.1.0` → `1.2.1`
  - source hash：未变（`sha256-OVllsRMst6dWO/RagsmGyWN3muz1ATtffxfmLTfa0qU=`）
  - npmDepsHash：未变（`sha256-LN9yDbwvlICoFl5KgQvzZjLGXflVM0QkSzaB2dJzR/w=`）
  - 构建验证：`/nix/store/2xs7h7y18p6ygggxmhh74rh2fdvycspj-mcp-searxng-1.2.1` ✅
  - 上游发布：<https://github.com/ihor-sokoliuk/MCP-searxng/releases/tag/v1.2.1>

### 文档

- `docs/zh/mcp-searxng.md` `docs/en/mcp-searxng.md` `docs/ja/mcp-searxng.md` — 版本号同步

---

## 2026-06-06T13:58:47+09:00

软件更新：codewhale 0.8.53、mcp-searxng 1.1.0、opencode-telegram 0.21.1

Package update: codewhale 0.8.53, mcp-searxng 1.1.0, opencode-telegram 0.21.1

パッケージ更新：codewhale 0.8.53、mcp-searxng 1.1.0、opencode-telegram 0.21.1

### 变更内容

- **codewhale** (`packages/codewhale.nix`) · 预编译二进制
  - 版本号：`0.8.49` → `0.8.53`
  - cli hash：`sha256-97zk4L...` → `sha256-VxBNH2o4iEkk0PrnuZHDPECjvm+ARXR9T/BV8QqvYtw=`
  - tui hash：`sha256-tc/s3e...` → `sha256-DBiWk4c4QFh/BKPlG5a3KkH0ZTxNQgqZ7IWwH4OaEEw=`
  - 上游发布：<https://github.com/Hmbown/CodeWhale/releases/tag/v0.8.53>

- **mcp-searxng** (`packages/mcp-searxng.nix`) · npm + fetchFromGitHub
  - 版本号：`1.0.4` → `1.1.0`
  - source hash：`sha256-ML5Hgle...` → `sha256-OVllsRMst6dWO/RagsmGyWN3muz1ATtffxfmLTfa0qU=`
  - npmDepsHash：`sha256-xnefgQ...` → `sha256-LN9yDbwvlICoFl5KgQvzZjLGXflVM0QkSzaB2dJzR/w=`
  - 上游发布：<https://github.com/ihor-sokoliuk/MCP-searxng/releases/tag/v1.1.0>

- **opencode-telegram** (`packages/opencode-telegram.nix`) · npm + fetchFromGitHub
  - 版本号：`0.21.0` → `0.21.1`
  - source hash：`sha256-Al7CVol...` → `sha256-V/rThMV5qZ5Z07A+A54Il4Vi/69bv8PVgV6uIr6vxGA=`
  - npmDepsHash：`sha256-ZOhS7l...` → `sha256-BcexuryL26CNLKeAOR9DffE07H4dYO1UYPqfX9aHm4g=`
  - 上游发布：<https://github.com/grinev/opencode-telegram-bot/releases/tag/v0.21.1>

### 文档

- 三语文档版本号同步：`codewhale`、`mcp-searxng`、`opencode-telegram` 各 3 份
