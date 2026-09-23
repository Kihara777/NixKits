# 維護模式（Agent 預設）

[中文](../../zh/modes/maintenance.md) | [English](../../en/modes/maintenance.md) | [日本語](../../ja/modes/maintenance.md)  | 偽中国語

> NixOS模式基盤之倉庫保守専用代理：文書作成・維護日誌技能與上流更新点検技能注入、**二層構成**之維護工作流 prompt——汎用方法 + 本倉（NixKits）適配層——読込。

## 基本情報

| 項目 | 値 |
|------|-----|
| 模式 id | `maintenance` |
| 配布方式 | dsh-nixos-shell 包内 `presets/maintenance-mode/`、seed-once 方式 `$DSH_HOME/.agent-presets/maintenance` copy |
| 有効化選項 | `nixkits.dsh.presets.maintenanceMode = true` |
| 派生元 | [NixOS模式](nixos.md)（組合末尾固定行塊追加） |
| 文書 | [dsh-nixos-shell.md](../dsh-nixos-shell.md)（本模式配布之包） |

## 動作

NixOS模式全能力 + 以下：

- **実行時技能**：`maintenance-skills` entry apply 時、**build 期埋込**倉庫 `skills/` tree 自 `write-project-docs`、`write-maintenance-log`、`nix-flake-update-check`、`nixkits-check-updates` 登録、全 `translate-*` 言語拡張自動発見——技能内容 倉庫 `skills/` 単一來源、新規 session 常最新。
- **維護工作流 prompt、二層構成**（上述技能同一分法：汎用方法 ← 倉庫適配層）：

  | 段名 | 作用域 | 内容 |
  |------|--------|------|
  | `maintenance-workflow`（序号 901） | **汎用**——如何倉庫皆成立 | 論理類別毎分割 commit、push 後記録、文書與 code 同期、修正技能汎化、技能内容単一來源 |
  | `maintenance-workflow-repo`（序号 902） | **本倉（NixKits）約束** | 四言語與其基準（`docs/zh/` 先書）、`write-maintenance-log` 為準則、項目数一致之検証可能判据、技能 tree 単一來源 |

  判据唯一：**此規約、換倉庫尚成立乎？** 成立則留汎用層、不成立則入適配層。
  汎用層 本倉専名 一切 不出現（NixKits / 四言語 / `translate-*` / `MAINTENANCE.md` / `grep -c` / `docs/zh`）。

  Component 選項 `repoWorkflow: false` 唯 汎用層 残存 可——別倉庫維護 session 用。
- 其他（系統検証、`nixos_shell` / `nixos_cli`、開発 prompt、NixOS模式 同梱 5 技能）NixOS模式同一。

## 派生関係

維護模式組合 = NixOS模式組合**末尾固定 `maintenance-skills` 行塊追加**（comment 含）之物、両預設 `skills/` tree 逐書類一致——此外差異一切不認。

```yaml
- id: maintenance-skills
  name: '@kihara777/dsh-nixos-shell/maintenance-skills'
```

`develop/check-preset-derivation.py` 該派生関係検証、`nix flake check` 組込（CI 毎 push 実行）；drift 時 check 失敗、修正前 commit 不可。追加塊自体 意図的変更場合、script 内 `MAINTENANCE_DELTA` 定数 同期更新。詳細 倉庫 `AGENTS.md`「预设」節参照。

## 導入

```nix
{
  nixkits.dsh = {
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;
    presets.maintenanceMode = true;
  };
}
```

## 注意

- NixOS模式同様 **seed-once**：`$DSH_HOME/.agent-presets/maintenance` 既存場合 上書無。変更 該目録直接編集（模組書込権限開放）。
- NixOS模式変更後、同変更 維護模式 必 mirror。否則 `nix flake check` 派生 drift 失敗。
