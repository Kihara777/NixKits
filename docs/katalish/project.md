# NixKits ﾌﾟﾛｼﾞｪｸﾄ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ

[中文](../zh/project.md) | [English](project.md) | [日本語](../ja/project.md)

## ﾌﾟﾛｼﾞｪｸﾄ Roles

| Role | ﾈｰﾑ | Responsibility |
|------|------|----------------|
| Creation & ﾒﾝﾃﾅﾝｽ | 狐莉 (キツのり) | Core ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ, architecture, release management |
| Design & ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ | 小爪 (キツのめ) | AI ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ, ﾋﾞﾙﾄﾞ ｺﾝﾌｨｸﾞ, ｽｷﾙ ｼｽﾃﾑ — feat. DeepSeek V4 Pro (Max) |
| Inference Infrastructure | 小小爪 (キツのめ) | Local LLM inference, ﾓﾃﾞﾙ quantization, ﾛｯｸｴﾑ acceleration — feat. llama-cpp-rocm |
| Translator (ja) | 尾巻 (オマキ) | ｵｰﾙ Japanese ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ translation ｱﾝﾄﾞ review |
| Translator (en) | 耳廓狐 (フェネック) | ｵｰﾙ English ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ translation ｱﾝﾄﾞ review |
| ﾄﾞｷｭ Design | 小爪 (キツのめ) | Multilingual ﾄﾞｷｭ ｼｽﾃﾑ architecture, ﾗﾝｹﾞｰｼﾞ switchers, templates |

## ﾌﾟﾛｼﾞｪｸﾄ Architecture

```
NixKits/
├── ﾊﾟｯｹｰｼﾞｰｽﾞ/          # ﾊﾟｯｹｰｼﾞ definitions (standalone binaries ｵｱ ｿｰｽ builds)
├── ﾓｼﾞｭｰﾙｽﾞ/           # NixOS ﾓｼﾞｭｰﾙｽﾞ (systemd services, ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ ｵﾌﾟｼｮﾝｽﾞ)
├── overlays/          # Nixpkgs overlays (standalone ｵｱ excluded ﾌﾛﾑ ﾃﾞﾌｫﾙﾄ)
├── ﾊﾟｯﾁｰｽﾞ/           # Standalone ﾊﾟｯﾁ ﾌｧｲﾙｽﾞ
├── ｽｷﾙｽﾞ/            # AI ｺｰﾃﾞｨﾝｸﾞ assistant ｽｷﾙ definitions
├── ﾄﾞｷｭｽﾞ/              # Multilingual ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ
│   ├── zh/            # Chinese (baseline)
│   ├── en/            # English
│   ├── ja/            # Japanese
│   └── katalish/      # Katakana English (auto-translated ﾌﾛﾑ en)
```

## Component Catalog

Full catalog ﾃﾞｰﾀ ｲｽﾞ ﾃﾞｨﾌｧｲﾝﾄﾞ ｲﾝ ｻﾞ Chinese baseline ﾄﾞｷｭﾒﾝﾄ:
[docs/zh/project.md](../zh/project.md)

ｷｰ ｾｸｼｮﾝｽﾞ:
- **ｿﾌﾄｳｪｱ** — 7 ﾊﾟｯｹｰｼﾞｰｽﾞ built directly via `nix build nix-kits#<name>`
- **NixOS ﾓｼﾞｭｰﾙｽﾞ** — 6 ﾓｼﾞｭｰﾙｽﾞ providing systemd services ｱﾝﾄﾞ ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ
- **Standalone Overlays** — 5 overlays (4 excluding `default`)
- **Standalone ﾊﾟｯﾁｰｽﾞ** — 3 ﾊﾟｯﾁｰｽﾞ referenced ﾊﾞｲ overlays ｵｱ ﾓｼﾞｭｰﾙｽﾞ
- **AI ｺｰﾃﾞｨﾝｸﾞ ｽｷﾙｽﾞ** — 8 ｽｷﾙｽﾞ ｳｨｽﾞ auto-discovery ﾌｫｱ translate-* ﾗﾝｹﾞｰｼﾞｰｽﾞ

### Relationship Graph

```
ﾌﾚｲｸ.ﾆｯｸｽ
├── ﾊﾟｯｹｰｼﾞｰｽﾞ.* ← 7 direct-output ﾊﾟｯｹｰｼﾞｰｽﾞ
├── nixosModules.* ← 6 ﾓｼﾞｭｰﾙｽﾞ
├── overlays.* ← 5 overlays (ｲｰﾁ overriding one ﾊﾟｯｹｰｼﾞ)
│   ├── llama-cpp-rocm → overrides pkgs.llama-cpp
│   ├── mihomo-alpha   → overrides pkgs.mihomo
│   ├── rcc-fix         → overrides pkgs.asusctl
│   └── ruyi-nixos-compat → overrides pkgs.ruyi
└── ｽｷﾙｽﾞ/ ← 8 AI ｽｷﾙｽﾞ
    ├── standalone: nixkits-skills, recover-nixos-config, nixos-modern-cli
    ├── ﾄﾞｷｭ chain: nixkits-check-updates → write-maintenance-log
    ├── extended ﾗﾝｹﾞｰｼﾞｰｽﾞ: translate-katalish, translate-pseudocn
    └── ﾄﾞｷｭ ｼﾞｪﾈﾚｰｼｮﾝ: write-project-docs → translate-* (auto-discovered)
```

## Multilingual ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ｼｽﾃﾑ

### ﾗﾝｹﾞｰｼﾞ Map

| ｺｰﾄﾞ | ﾃﾞｨｽﾌﾟﾚｲ ﾈｰﾑ | ﾃﾞｨﾚｸﾄﾘ | Naming | Translator |
|------|-------------|----------|--------|------------|
| zh | 中文 | `docs/zh/` | `<name>.md` (baseline) | 狐莉 |
| en | English | `docs/en/` | `<name>.md` | 耳廓狐 |
| ja | 日本語 | `docs/ja/` | `<name>.md` | 尾巻 |
| katalish | ｶﾀﾘｯｼｭ | `docs/katalish/` | `<name>.md` | 小爪 (ｵｰﾄ machine) |
| pcn | 偽中国語 | `docs/pcn/` | `<name>.md` | 小爪 (ｵｰﾄ machine) |

### ﾗﾝｹﾞｰｼﾞ Switcher ﾌｫｰﾏｯﾄ

**ﾓｼﾞｭｰﾙ ﾄﾞｷｭｽﾞ** (under `docs/<lang>/`):
```
[中文](../../zh/project.md) | [English](../en/project.md) | [日本語](../../ja/project.md) | [ｶﾀﾘｯｼｭ](project.md) | [偽中国語](../../pcn/project.md)
```

**ｽｷﾙ ﾄﾞｷｭｽﾞ** (under `docs/<lang>/skills/`):
```
[中文](<name>.md) | [English](../../en/skills/<name>.md) | [日本語](../../ja/skills/<name>.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/<name>.md)
```

### Extended ﾗﾝｹﾞｰｼﾞ Auto-Discovery

`translate-*` ｽｷﾙｽﾞ ｱｰ auto-discovered ﾊﾞｲ `write-project-docs`:

```
ｽｷﾙｽﾞ/translate-*/ｽｷﾙ.md → language_code ｱﾝﾄﾞ display_name ﾌﾛﾑ ﾌﾛﾝﾄﾏﾀｰ
```

Currently installed extended ﾗﾝｹﾞｰｼﾞｰｽﾞ:
- `translate-katalish`: `language_code: katalish` → Katakana English
- `translate-pseudocn`: `language_code: pcn` → Pseudo-Chinese

## ﾕｰｾｰｼﾞ

### Loading NixKits

```nix
{
  ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾕｰｱｰﾙｴﾙ = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nix-kits, ... }: {
    nixosConfigurations.<host> = nixpkgs.ﾘﾌﾞ.nixosSystem {
      ﾓｼﾞｭｰﾙｽﾞ = [
        nix-kits.nixosModules.llama-cpp-rocm
        nix-kits.nixosModules.comfyui-strix-halo
        nix-kits.nixosModules.ruyi
        {
          nixpkgs.overlays = [
            nix-kits.overlays.ﾃﾞﾌｫﾙﾄ
            nix-kits.overlays.llama-cpp-rocm
            nix-kits.overlays.mihomo-alpha
            nix-kits.overlays.rcc-fix
            nix-kits.overlays.ruyi-nixos-compat
          ];
        }
      ];
    };
  };
}
```

### ﾕｰｼﾞﾝｸﾞ devShell

```bash
ﾆｯｸｽ ﾚｼﾞｽﾄﾘ ｱﾄﾞ nix-kits github:Kihara777/NixKits
ﾆｯｸｽ develop nix-kits#ruyi
```