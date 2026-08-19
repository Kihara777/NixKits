# dsh-skill-nixkits

[中文](../zh/dsh-skill-nixkits.md) | [English](../en/dsh-skill-nixkits.md) | 日本語  | [偽中国語](../pcn/dsh-skill-nixkits.md)

NixKits の全 7 スキルをネイティブ DeepSeek Harness（DSH）スキルプラグインとして提供。**各スキルが 1 つのプラグインエントリ**（パッケージのサブパスエクスポート）：プラグインはランタイムに `ctx.skills.register` で自身の内容を登録（runtime provider、rank 250、`~/.dsh/skills` などのファイルシステム由来より優先）し、コンポジションと共にマウント／アンマウント、`plugins.disabled` で entry id ごとに無効化でき、dsh のプラグイン一覧や設定 UI に表示される。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | DSH ホストプラグイン（npm パッケージ、ランタイム依存ゼロ）|
| npm 名 | `@kihara777/dsh-skill-nixkits` |
| バージョン | `0.1.0` |
| ライセンス | MIT |
| 内容ソース | リポジトリ `skills/`（ビルド時埋め込み、単一ソース）|

## プラグインエントリ

| サブパス | プラグイン名 | スキル |
|----------|--------------|--------|
| `nixkits-check-updates` | `skill-nixkits-check-updates` | 上流バージョン確認と自動適用 |
| `nixkits-skills` | `skill-nixkits-skills` | コーディングアシスタントへのスキル導入 |
| `nixos-modern-cli` | `skill-nixos-modern-cli` | モダン NixOS CLI ワークフロー規則 |
| `recover-nixos-config` | `skill-recover-nixos-config` | Nix store からの /etc/nixos 復旧 |
| `translate-pseudocn` | `skill-translate-pseudocn` | 偽中国語ドキュメントローカライズ |
| `write-maintenance-log` | `skill-write-maintenance-log` | メンテナンスログ執筆規則 |
| `write-project-docs` | `skill-write-project-docs` | 多言語プロジェクトドキュメント生成 |

## アーキテクチャ

```
コンポジション行（スキルごとに 1 行）
  └─ プラグイン apply() → ctx.skills.register({ name, description, content, source: "runtime",
                                                resourceBase: { kind: "directory", path: <スキルディレクトリ> },
                                                metadata: <frontmatter フィールド> })
```

- **単一ソース**：SKILL.md はリポジトリの `skills/` に残り、ビルド時（`postPatch cp -r`）に埋め込み。NixKits ドキュメントパイプラインの自動発見契約（frontmatter の `language_code`/`display_name`/`base_language`）は影響を受けず、フィールドは `metadata` に保持
- **登録ライフサイクル**：`apply()` は `skills.register()` の disposer を返し、コンポジションの解除と共に破棄
- **依存ゼロ**：`skills` 能力接続点のみ消費し、peer はホスト dsh ツリーが提供

## 使い方

`nixkits.dsh.skills` で 7 行すべてを一括登録：

```nix
{
  nixkits.dsh.skills = {
    enable = true;
    package = pkgs.dsh-skill-nixkits;  # 既定値
  };
}
```

手動コンポジション行（選択的マウント、npm パッケージが dsh から解決できる場合）：

```yaml
- id: skill-nixos-modern-cli
  name: '@kihara777/dsh-skill-nixkits/nixos-modern-cli'
```

単一スキルの無効化（通常のプラグインと同様）：

```nix
nixkits.dsh.plugins.disabled = [ "skill-translate-pseudocn" ];
```
