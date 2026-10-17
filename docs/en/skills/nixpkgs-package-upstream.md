# nixpkgs-package-upstream (Skill)

[中文](../../zh/skills/nixpkgs-package-upstream.md) | English | [日本語](../../ja/skills/nixpkgs-package-upstream.md)  | [偽中国語](../../pcn/skills/nixpkgs-package-upstream.md)

> The general workflow for submitting a self-packaged piece of software upstream to nixpkgs: assess → audit → dry-run → act.

## Basic information

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixpkgs-package-upstream/SKILL.md` |
| Dependencies | None (repository-specific steps are supplied by the adaptation layer) |

## Features

- **Feasibility assessment**: six questions, each answered with evidence — is it already in
  master, was it ever removed, are there in-flight PRs, is the licence identifiable
  **inside the tag we actually fetch**, is there a willingness to maintain it, and will its
  dependencies collide with the package sets shared across nixpkgs
- **Requirements audit**: the `by-name` layout and `nixpkgs-vet`'s 12 checks, its 3 ratchets,
  the mandatory `meta` attributes, nixfmt formatting, commit prefixes driving CI,
  no DCO requirement, and no need to open an issue first
- **Routing first**: first contribution vs repeat × new package vs version update — the maintainer entry is **one-time**, so a repeat contribution never touches the list, and an update skips both the feasibility and the placement sections
- **AI contribution policy**: an `Assisted-by:` trailer is the mandatory disclosure format
  while `Co-authored-by:` does not qualify; a responsible person must be in the loop
- **Where the package goes — three routes**: `by-name`, category directories, and **named
  sets** such as `obs-studio-plugins`. The last has no entry to add, and its discovery
  mechanism **can only be confirmed by evaluating** (`pkgs.<set> ? <name>`); the mechanism
  shown by an old PR may already have been deleted upstream
- **Identity constraint**: the `github` in the maintainer list **must equal the GitHub
  account that authors the commit** — this decides which account submits, not the reverse
- **Reviewer checklist**: the new-package review points from `pkgs/README.md`, applied to
  yourself before submitting
- **`nixpkgs-review`'s three traps**: an empty report means the evaluation failed; green but
  entirely cached has no verifying power; and the `pr` subcommand cannot review a PR living
  in a fork (use `rev` with the head sha)
- **Dry run**: evaluate, build, verify the artifact, and **run the artifact** against a real
  nixpkgs tree (four layers of criteria). Comparing artifacts built against different nixpkgs
  revisions: do **not** compare bytes, compare the **output paths**. Comparing artifacts built against different nixpkgs
  revisions: do **not** compare bytes, compare the **output paths**
- **Keep the PR body short**: the reviewer attached "the verification section could be a little shorter" to their approval — details belong in commit messages and the draft directory; the body only answers what/why/which rules
- **A mandatory declaration for Qt dependents**: if `buildInputs` contains `qt6.qtbase` you must pick one — an application adds `wrapQtAppsHook`, a library/plugin sets `dontWrapQtApps = true`; otherwise the build fails at the `qtPreHook` phase
- **Submission**: the ordering of the two commits (the maintainer entry comes first),
  branching and the PR, waiting, and how to speed things up
- **Trap list**: licence gaps, stale self-descriptions in a repository, the same software
  under different names, documentation drift, prebuilt binaries, and recursive `chmod`
  over a symlink tree reaching into the nix store

## Usage

Activated by an AI assistant when the user asks to "submit this package to nixpkgs"
or "contribute it upstream".

Repository-specific steps (four-language documentation, maintenance log, registering the
self-checks) live in the adaptation-layer skill
[`nixkits-package-upstream`](nixkits-package-upstream.md).

## Where the criteria come from

Every hard requirement in this skill comes from nixpkgs' own documentation or CI
implementation, and the skill cites the source for each one:

- `pkgs/README.md` (new-package rules, naming, meta, sources)
- `pkgs/by-name/README.md` (layout, limitations)
- `nixpkgs-vet`'s `README.md` (the 12 checks and 3 ratchets)
- `CONTRIBUTING.md` (commit conventions, AI policy, review process)
- `.github/workflows/lint.yml` and `.github/PULL_REQUEST_TEMPLATE.md`

**These files drift**, which is why the skill's step 0 is "sync first, then believe":
any statement about what nixpkgs currently looks like must be fetched fresh.
