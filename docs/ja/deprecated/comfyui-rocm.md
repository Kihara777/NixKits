# comfyui-rocm パッチプロジェクト（廃止）

[中文](../../zh/deprecated/comfyui-rocm.md) | [English](../../en/deprecated/comfyui-rocm.md) | 日本語  | [偽中国語](../../pcn/deprecated/comfyui-rocm.md)

[← 廃止プロジェクト索引](../../../DEPRECATED.md)

**状態**：廃止（2026-09-15）
**旧位置**：`modules/comfyui-rocm.nix` + `patches/comfyui-nix-{strix-halo,nixpkgs-compat,stdenv-api}.patch`
**現状**：モジュールは保持し `nixkits.comfyui` に改名、**三つのパッチはすべて削除**

### 上流が積極的に保守を続け、ROCm 対応コンポーネントを StrixHalo をよく支える版まで更新した。本パッチの歴史的使命は完了した。

## かつて何を解決していたか

上流 `comfyui-nix` の ROCm 対応は、かつて Strix Halo（gfx1151 / RDNA 3.5）の要求に
遅れを取っていた。本パッチプロジェクトは三つのパッチでそれを補った：

| パッチ | かつて解決していた問題 |
|--------|------------------------|
| `comfyui-nix-strix-halo` | ROCm / PyTorch wheel を更新し、gfx1151 対応を追加 |
| `comfyui-nix-nixpkgs-compat` | nixpkgs のドリフトによるビルド失敗（サンドボックスで Python テストが通らない） |
| `comfyui-nix-stdenv-api` | 上流が非推奨の `stdenv.is<Platform>` 短縮記法を使っており、評価警告が出ていた |

## なぜ廃止できるか

上流 `comfyui-nix` **0.34.0** が上記をすべて内蔵済みである：

- **ROCm 対応**：上流は ROCm 7.1 / PyTorch 2.10.0 wheel を同梱し、その
  `nix/versions.nix` のバージョン・URL・hash は我々のパッチの産物と**逐バイト一致**する。
  モジュールも `gpuSupport = "rocm"` をネイティブに支持する。
- **stdenv 移行**：上流は全面的に `stdenv.hostPlatform.*` へ移行済み（旧記法は **0 箇所**、
  新記法は 34 箇所）で、非推奨警告は出ない。
- **nixpkgs 互換**：上流は Python テストのスキップ処理の大半を既にカバーしている。

## ⚠️ 記録に値する一度の誤判定

`comfyui-nix-nixpkgs-compat` の廃止判定は**当初誤っていた**：

1. 初回評価で「完全ビルド検証」を行った：717 個の derivation がすべて成功し、
   `scipy` / `jupyter-server` / `jupyterlab` / `fastapi` など「テストをスキップすべき」
   パッケージに失敗はなく、これに基づきパッチは不要と判定した。
2. **しかしその回の `scipy` はバイナリキャッシュ命中で、一度も実際にはビルドされていない。**
   検証していたのはキャッシュ内の産物であり、現実のビルドではなかった。
3. 実際にアップグレードすると直ちに失敗した：

   ```
   scipy-1.18.0  test_support_moments_sample
     ACTUAL:  array([0., 0.])
     DESIRED: array([0.000000e+00, 2.010276e-09])
   ```

   まさにパッチ自身のコメントが述べていた「flaky な浮動小数点アサーション」である。

**真の根因は、本機に残っていた一つの余分な pin である** ——
「下流の組み合わせは本質的に異なる」からではない。本機は `comfyui-nix` の
`inputs.nixpkgs` を `6438090`（2026-08-02）に固定し、一方でトップレベルは
rolling な `nixos-unstable` を追っていた。トップレベルは公共キャッシュに命中するが、
固定された子 flake は `scipy` を現にビルドする必要がある —— ゆえに「キャッシュが
解決したはずの問題」が「パッチを要する問題」に見えてしまった。
**その pin 行を削除すれば `comfyui-nix` はトップレベルと `dc5d91f` を共有し、
`scipy` はそのままキャッシュ命中、ビルドは全て通り、パッチは一切不要である。**

> **教訓その一**：ビルド検証は、対象の derivation がキャッシュ命中ではなく
> **本当にビルドされた**ことを確認しなければならない。`nix build --dry-run` の一覧と、
> ビルドログに `building '…'` の行が現れること —— これが「確かにビルドした」証拠である。
> 「ビルド成功」だけでは「ビルドを通過した」と「ビルドが不要だった」を区別できない。
>
> **教訓その二**：余分な `inputs.*` pin は子 flake を**主 nixpkgs のキャッシュ被覆から
> 切り離し**、キャッシュが解決したはずの問題をパッチが必要な問題に見せかける。
> pin を加える前にそれが何を解決するのか問い、問題が消えたら削除を忘れないこと。
> 本プロジェクトの二度の誤判定（「不要」→「我々の組み合わせがたまたま必要」）は、
> いずれもこの pin に辿り着けなかったことが原因である。

## 廃止後の設定方法

**もはや fork もパッチも不要である。** `comfyui-nix` input を上流へ直接向ける：

```nix
{
  inputs.comfyui-nix.url = "github:utensils/comfyui-nix";

  # モジュール名とオプションのパスは更新済み（旧 nixkits.comfyui-rocm）
  imports = [ inputs.nixkits.nixosModules.comfyui ];

  nixkits.comfyui.enable = true;
  services.comfyui = {
    enable = true;
    gpuSupport = "rocm";
    # rocmGfxOverride = "11.0.0";   # gfx1151 が認識されない場合のみ有効化
  };
}
```

> **改名について**：モジュールはかつて `nixkits.comfyui-rocm` だった ——
> その出自が「ROCm パッチプロジェクト」だったためである。パッチが消えた今、
> その責務は**統合の配線**（サービスオプション、デバイス権限、カーネルパラメータ、
> C ツールチェーン）のみとなったため、実際の責務に合わせ `nixkits.comfyui` へ改名した。

**モジュールの現状ドキュメント**：[`comfyui.md`](../comfyui.md) を参照。

## 歴史バージョン対照

| 項目 | パッチ時代 | 現在 |
|------|-----------|------|
| comfyui-nix バージョン | 0.30.2（ローカル fork、14 コミット） | 上流 0.34.0 |
| ROCm wheel | パッチで注入 | 上流が同梱 |
| 入力元 | `path:/home/kix/comfyui-nix-patched` | `github:utensils/comfyui-nix` |
| パッチ数 | 3 | 0 |
