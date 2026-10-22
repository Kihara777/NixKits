# 安全策略 — impure 分支

## 本分支的特殊风险：它故意不可复现

`llama-cpp-ver` 每次求值都取 GitHub 上 llama.cpp 的**最新 release JSON**，
`nixpkgs` 跟随 `nixos-unstable`，而 `flake.lock` **故意不提交**。这意味着：

- 你在不同时间 `nix build`，可能得到不同的内容；
- 上游一旦误发或被篡改 release，**下一次求值就会取到它**，而你手上没有 lock
  可以作为「我构建的是这个」的凭证；
- CI 产物也无法用 commit 复现。

这是**有意的取舍**：把浮动关进一个只装一个包的分支，换取 `main` 可以锁定。
**不要在本分支装第二个包**——浮动面越小越好审。

## 缓解措施

| 措施 | 说明 |
|---|---|
| **内容仍被上游 tag 钉住** | 版本号浮动，但取的是 `releases/latest` 的 tag；同一个 tag 的源码内容不变 |
| **hash 改动必须过 review** | 升级版本号会同时改 overlay 里的 hash，那次 diff 就是人工审查点 |
| **上游单一** | `ggml-org/llama.cpp` 是本机推理链路的唯一上游，不引入第二个源 |
| **不在 CI 里运行上游二进制** | 本分支只构建与安装；真正跑 llama.cpp 是下游部署的事 |

## 报告漏洞

同 `main`：见 `main` 分支的 `SECURITY.md`——走私有渠道，**不要开公开 issue**。
涉及本分支自身（overlay / module / flake 定义）的问题，请在该提示中注明
「impure 分支」。
