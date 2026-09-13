# nixos-specialisation-tuning (Skill)

[中文](../../zh/skills/nixos-specialisation-tuning.md) | English | [日本語](../../ja/skills/nixos-specialisation-tuning.md)  | [偽中国語](../../pcn/skills/nixos-specialisation-tuning.md)

> Design NixOS specialisation faces and tune llama.cpp local inference on unified-memory (UMA) devices.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixos-specialisation-tuning/SKILL.md` |

## Features

- **Face architecture**: three-file layout (default face / optional face / shared base) and override-conflict rules
- **Ownership principle**: put a setting in the module that consumes it, avoiding cross-face side effects
- **llama.cpp tuning**: parameter quick-reference and forbidden items on UMA devices
- **Diagnostic order**: rule out the environment variable before suspecting quantisation or templates
- **Context-cost analysis**: detect the per-turn fixed cost of agent tool schemas
- **Silent-failure diagnosis**: recognise "service is active but does not work" problems
- **Experiment validity check**: recognise an invalid control experiment

## Usage

Activated by an AI assistant in these situations:

| Situation | Trigger |
|-----------|---------|
| Config split | Need two boot configs: minimal default + optional full |
| Inference fault | Local llama.cpp emits degenerate output, fails to load, or runs oddly |
| Optimisation call | Need cost/benefit/trade-off, not a single gain figure |
| Hard diagnosis | Service runs normally but the feature does not work |

## Core Principles

| Principle | Detail |
|-----------|--------|
| Never `mkForce` a list attribute | It deletes other modules' contributions; append to `systemPackages` instead |
| Settings belong to their consumer | A face not using a service should not inherit its side effects |
| Measure before claiming a gain | Never put an unmeasured number into advice |
| Read the config log, not just systemd state | Config keys of unloaded modules are silently ignored |
| When experiment contradicts production, suspect the experiment | Not the production environment |
