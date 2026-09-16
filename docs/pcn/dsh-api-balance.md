# dsh-api-balance

[中文](../zh/dsh-api-balance.md) | [English](../en/dsh-api-balance.md) | [日本語](../ja/dsh-api-balance.md)  | 偽中国語

API 用量残高 plugin（DeepSeek Harness）——webui 用量圓環（送信按鈕左 的 文脈使用量表示）的 popup panel 対「用量 / 残高」tab 切替 追加。

> **本 project 独立 repo 移転 済**：<https://github.com/Kihara777/dsh-api-balance>
>
> 此 **platform 非依存 DSH plugin**（NixOS 専用 非）故、独立配布 且 npm 公開。
> **完全 document（四言語）新 repo 内 有**：<https://github.com/Kihara777/dsh-api-balance#文档>
>
> 本 page NixKits 固有 一節——**宣言的 install**——限定 保持。

## 基本情報

| 項目 | 値 |
|------|-----|
| source repo | <https://github.com/Kihara777/dsh-api-balance> |
| npm 名 | `@kihara777/dsh-api-balance` |
| 種別 | DSH Host + Client plugin |
| license | MIT |
| NixKits 役割 | 薄 wrapper package（宣言的 install 提供）。source 保持 不 |

## 導入

### 方式 A：`dsh plugin add`（DSH native）

```bash
dsh plugin --profile web add github:Kihara777/dsh-api-balance
# 又 npm 自
dsh plugin --profile web add @kihara777/dsh-api-balance
```

### 方式 B：宣言的（NixOS module——本 page 固有）

NixKits 薄 `pkgs.dsh-api-balance` wrapper（新 repo source 自 build）保持、NixOS 利用者 宣言的 install 可能——版 Nix 固定、system 世代 共 更新、再現可能：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-api-balance;
    id = "api-balance";
    name = "@kihara777/dsh-api-balance";
    # config（任意）：
    #   apiKeyEnv = "DEEPSEEK_API_KEY";   # credential-ref
    #   baseURL = "https://api.deepseek.com";
    #   browserScan = true;               # 本機瀏覽器自動掃描
    #   browserScanIntervalMs = 21600000; # 掃描節流（預設 6 時間）
  }];
}
```

> ⚠️ **方式 A 與 併用 不**——両者 同一 entry id 登録 故 重複。

## 薄 wrapper 更新

`packages/dsh-api-balance.nix` 新 repo 的 一 `rev` 與 二 hash（source 與 `npmDepsHash`）固定。更新時 三 全部 同期 必要、一般手順 `nix-flake-update-check` 技能 有。

## 機能概要

完全 機能説明 [新 repo](https://github.com/Kihara777/dsh-api-balance) 有。概要：

- **残高**：DeepSeek 公式 `GET /user/balance`（API key 認証）
- **使用量**：当日 / 当月 / 30 日消費（金額 + token + model 別明細）與 日別 / 月別 chart
- **platform token**：預設 本機瀏覽器 登録状態 自 自動 scan、手動接続 fallback
- **音声**：音声 pack + TTS（瀏覽器内蔵 / 自訂 API）、peak・off-peak 課金 自動通知
- **UI 強化**：peak 時 赤表示、疑問 window scroll 修正、下部統計 bar scroll 等
