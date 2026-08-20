# dsh-skill-nixkits

[中文](../zh/dsh-skill-nixkits.md) | [English](../en/dsh-skill-nixkits.md) | [日本語](../ja/dsh-skill-nixkits.md)  | 偽中国語

NixKits 全 7 技能原生 DeepSeek Harness（DSH）技能插件包。**各技能 1 插件条目**（包内子路輸出）：插件 runtime `ctx.skills.register` 自身内容登録（runtime provider、rank 250、`~/.dsh/skills` 等文件系統由来優先）、組合掛卸随行、`plugins.disabled` entry id 別無効可、dsh 插件清單与設定 UI 登場。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | DSH 宿主插件（npm 包、runtime 依存零）|
| npm 名 | `@kihara777/dsh-skill-nixkits` |
| 版本 | `0.1.0` |
| 許可 | MIT |
| 内容來源 | 倉庫 `skills/`（構築期嵌入、単一來源）|

## 插件条目

| 子路 | 插件名 | 技能 |
|------|--------|------|
| `nixkits-check-updates` | `skill-nixkits-nixkits-check-updates` | 上流版本確認與自動適用 |
| `nixkits-skills` | `skill-nixkits-nixkits-skills` | 編碼助手目録技能導入 |
| `nixos-modern-cli` | `skill-nixkits-nixos-modern-cli` | 現代 NixOS CLI 工作規則 |
| `recover-nixos-config` | `skill-nixkits-recover-nixos-config` | Nix store 自 /etc/nixos 復旧 |
| `translate-pseudocn` | `skill-nixkits-translate-pseudocn` | 偽中国語文書本地化 |
| `write-maintenance-log` | `skill-nixkits-write-maintenance-log` | 維護日誌執筆規則 |
| `write-project-docs` | `skill-nixkits-write-project-docs` | 多言語項目文書生成 |

## 架構

```
組合行（技能毎 1 行）
  └─ 插件 apply() → ctx.skills.register({ name, description, content, source: "runtime",
                                          resourceBase: { kind: "directory", path: <技能目録> },
                                          metadata: <frontmatter 字段> })
```

- **単一來源**：SKILL.md 倉庫 `skills/` 残置、構築期（`postPatch cp -r`）嵌入。NixKits 文書管自動発見契約（frontmatter `language_code`/`display_name`/`base_language`）不受影響、字段 `metadata` 保持
- **登録生命週期**：`apply()` `skills.register()` disposer 返、組合解除随破棄
- **依存零**：`skills` 能力接点消費、peer 宿主 dsh 樹提供

## 使用

`nixkits.dsh.skills` 7 行一括登録：

```nix
{
  nixkits.dsh.skills = {
    enable = true;
    package = pkgs.dsh-skill-nixkits;  # 既定値
  };
}
```

手動組合行（選択掛載、npm 包 dsh 可解時）：

```yaml
- insert:
  - id: skill-nixkits-nixos-modern-cli
    name: '@kihara777/dsh-skill-nixkits/nixos-modern-cli'
```

> **注意**：新規条目 `- insert:` 操作包裹必要——裸 `- id:` 行僅補丁既有条目、dsh 報 `patch: entry … not found` 行破棄。

単一技能無効化（普通插件同様）：

```nix
nixkits.dsh.plugins.disabled = [ "skill-nixkits-translate-pseudocn" ];
```
