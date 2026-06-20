# llama-cpp-rocm

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [llama-cpp-rocm] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [llama-cpp-rocm] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [llama-cpp-rocm] . md )

[Upstream] [llama] . [cpp] ｳｨｽﾞ ﾛｯｸｴﾑ [GPU] [acceleration] . [Dynamically] [fetches] ｻﾞ [latest] GitHub [Release] ﾊﾞｰｼﾞｮﾝ ｱｯﾄ ﾋﾞﾙﾄﾞ [time] ﾌｫｱ [testing] [cutting-edge] ﾌｨｰﾁｬｰｽﾞ .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|ｵｰﾄ - tracks upstream
Upstream|[ ggml - org / llama . cpp ] ( https : / / github . com / ggml - org / llama . cpp )
ﾉｰﾄ|ｵｰﾊﾞｰﾚｲ - ｵﾝﾘｰ , ﾉｰ standalone ﾊﾟｯｹｰｼﾞ ｱｳﾄﾌﾟｯﾄ

## Install

```nix
{
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . [llama-cpp-rocm] ];
ｴﾝﾊﾞｲﾛﾒﾝﾄ . [systemPackages] = [ [pkgs] . [llama-cpp-rocm] ];
}
```

## Usage

ｼｰ [upstream] [llama] . [cpp] ﾄﾞｷｭｽﾞ .

## Flake Module

```nix
# flake.nix
{
ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . ﾕｰｱｰﾙｴﾙ = " [github] : [Kihara777] / NixKits ";

[outputs] = { [nixpkgs] , [nix-kits] , ... }: {
[nixosConfigurations] . [your-host] = [nixpkgs] . ﾘﾌﾞ . [nixosSystem] {
ﾓｼﾞｭｰﾙｽﾞ = [
[nix-kits] . [nixosModules] . [llama-cpp-rocm]
{
[services] . [llama-cpp] = {
[enable] = [true] ;
ﾊﾟｯｹｰｼﾞ = [pkgs] . [llama-cpp-rocm] ;
[port] = 2027 ;
};
[nixkits] . [llama-cpp-rocm] = {
[enable] = [true] ;
ﾕｰｻﾞｰ = " [kix] ";
[group] = " [users] ";
[modelsPreset] = {
["*"] = {
[presence-penalty] = " 0 . 0 ";
[repeat-penalty] = " 1 . 0 ";
[flash-attn] = " ｵﾝ ";
[n-gpu-layers] = " 99 ";
[cache-type-k] = " [q4_0] ";
[cache-type-v] = " [q4_0] ";
[threads] = " 32 ";
[mmap] = " [off] ";
[warmup] = " ｵﾝ ";
[jinja] = " ｵﾝ ";
[fit] = " [off] ";
[prio] = " 3 ";
};
" [Qwen3] . [6-27B-MTP] " = {
[hf-repo] = " [unsloth] / [Qwen3] . [6-27B-MTP-GGUF] : [UD-Q4_K_XL] ";
[alias] = " [Qwen3] . [6-27B-MTP] ";
[temp] = " 0 . 6 ";
[top-p] = " 0 . 95 ";
[top-k] = " 20 ";
[min-p] = " 0 . 00 ";
[ctx-size] = " 1048576 ";
[rope-scaling] = " [yarn] ";
[rope-scale] = " 4 ";
[yarn-orig-ctx] = " 262144 ";
[spec-type] = " [draft-mtp] ";
[spec-draft-n-max] = " 2 ";
};
" [Qwen3] . [6-35B-A3B-MTP] " = {
[hf-repo] = " [unsloth] / [Qwen3] . [6-35B-A3B-MTP-GGUF] : [UD-Q4_K_XL] ";
[alias] = " [Qwen3] . [6-35B-A3B-MTP] ";
[temp] = " 0 . 6 ";
[top-p] = " 0 . 95 ";
[top-k] = " 20 ";
[min-p] = " 0 . 00 ";
[ctx-size] = " 1048576 ";
[rope-scaling] = " [yarn] ";
[rope-scale] = " 4 ";
[yarn-orig-ctx] = " 262144 ";
[spec-type] = " [draft-mtp] ";
[spec-draft-n-max] = " 2 ";
};
" [Qwen3] . [5-122B-A10B-MTP] " = {
[hf-repo] = " [unsloth] / [Qwen3] . [5-122B-A10B-MTP-GGUF] : [UD-Q4_K_XL] ";
[alias] = " [Qwen3] . [5-122B-A10B-MTP] ";
[temp] = " 0 . 6 ";
[top-p] = " 0 . 95 ";
[top-k] = " 20 ";
[min-p] = " 0 . 00 ";
[ctx-size] = " 1048576 ";
[rope-scaling] = " [yarn] ";
[rope-scale] = " 4 ";
[yarn-orig-ctx] = " 262144 ";
[spec-type] = " [draft-mtp] ";
[spec-draft-n-max] = " 2 ";
};
" [Qwen3-Coder-Next] " = {
[hf-repo] = " [unsloth] / [Qwen3-Coder-Next-GGUF] : [UD-Q4_K_XL] ";
[alias] = " [Qwen3-Coder-Next] ";
[temp] = " 1 . 0 ";
[top-p] = " 0 . 95 ";
[top-k] = " 40 ";
[min-p] = " 0 . 01 ";
[seed] = " 3407 ";
[ctx-size] = " 1048576 ";
[rope-scaling] = " [yarn] ";
[rope-scale] = " 4 ";
[yarn-orig-ctx] = " 262144 ";
};
" [MiniMax-M2] . 7 " = {
[hf-repo] = " [unsloth] / [MiniMax-M2] . [7-GGUF] : [UD-Q2_K_XL] ";
[alias] = " [MiniMax-M2] . 7 ";
[temp] = " 1 . 0 ";
[top-p] = " 0 . 95 ";
[top-k] = " 40 ";
[min-p] = " 0 . 01 ";
[ctx-size] = " 196608 ";
};
};
};
}
];
};
};
}
```

ｻﾞ ﾓｼﾞｭｰﾙ [auto-sets] ` [LLAMA_CACHE] ` ﾄｩ `/ ﾎｰﾑ /< ﾕｰｻﾞｰ [>/.] [cache] / [huggingface] / [hub] ` ｱﾝﾄﾞ [lifts] `/ ﾎｰﾑ ` ｱﾝﾄﾞ `/ [proc] ` [sandbox] [restrictions] .

> ** ﾜｰﾆﾝｸﾞ : ﾎｰﾑ [Manager] [llama-cpp] ｻｰﾋﾞｽ **
>
> If [enabled] [via] ﾎｰﾑ [Manager] , [additional] [user-level] [sandboxing] ﾒｲ [prevent] [GPU] [access] (`/ ﾃﾞﾌﾞ / [dri] `, `/ ﾃﾞﾌﾞ / [kfd] `). [Prefer] [system-level] ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ .

## Migration Guide

### Affected Versions

Component|Affected|Change
- - - - - - - - - - -|- - - - - - - - - -|- - - - - - - -
nixpkgs|≥ 2026 - 06 ( master )|` services . llama - cpp . modelsPreset ` removed ; ` port ` / ` host ` / ` ﾓﾃﾞﾙ ` / ` modelsDir ` renamed ﾄｩ ` ｾｯﾃｨﾝｸﾞｽﾞ . port ` / ` ｾｯﾃｨﾝｸﾞｽﾞ . host ` / …
NixKits|≥ ` 6f52ddf ` ( ` ﾓｼﾞｭｰﾙｽﾞ / llama - cpp - ﾛｯｸｴﾑ . ﾆｯｸｽ ` )|Namespace : ` services . llama - cpp - ﾛｯｸｴﾑ ` → ` nixkits . llama - cpp - ﾛｯｸｴﾑ `
Upstream llama . cpp|b9605|` - - models - preset ` CLI ｱｰｷﾞｭﾒﾝﾄ retained

### Config Key Mapping

ｵｰﾙﾄﾞ ( deprecated )|ﾆｭｰ|ﾉｰﾂ
- - - - - - - - - - - - - - - - - -|- - - - -|- - - - - - -
` services . llama - cpp . modelsPreset `|` nixkits . llama - cpp - ﾛｯｸｴﾑ . modelsPreset `|Removed ﾌﾛﾑ nixpkgs , restored via NixKits
` services . llama - cpp - ﾛｯｸｴﾑ . enable `|` nixkits . llama - cpp - ﾛｯｸｴﾑ . enable `|Namespace unified
` services . llama - cpp - ﾛｯｸｴﾑ . ﾕｰｻﾞｰ `|` nixkits . llama - cpp - ﾛｯｸｴﾑ . ﾕｰｻﾞｰ `|Namespace unified
` services . llama - cpp - ﾛｯｸｴﾑ . group `|` nixkits . llama - cpp - ﾛｯｸｴﾑ . group `|Namespace unified
` services . llama - cpp . port `|` services . llama - cpp . ｾｯﾃｨﾝｸﾞｽﾞ . port `|nixpkgs rename
` services . llama - cpp . host `|` services . llama - cpp . ｾｯﾃｨﾝｸﾞｽﾞ . host `|nixpkgs rename
` services . llama - cpp . ﾓﾃﾞﾙ `|` services . llama - cpp . ｾｯﾃｨﾝｸﾞｽﾞ . ﾓﾃﾞﾙ `|nixpkgs rename
` services . llama - cpp . modelsDir `|` services . llama - cpp . ｾｯﾃｨﾝｸﾞｽﾞ . models - dir `|nixpkgs rename
Manual ` systemd . services . llama - cpp . serviceConfig `|ﾘﾑｰﾌﾞ|Handled ﾊﾞｲ NixKits ﾓｼﾞｭｰﾙ
` services . llama - cpp . extraFlags `|ｱﾄﾞ ﾌﾗｸﾞｽﾞ ﾄｩ ` services . llama - cpp . ｾｯﾃｨﾝｸﾞｽﾞ `|nixpkgs removal

### Migration Example

> [**⚠️] ｽﾃｯﾌﾟ 1 [**:] ｱﾄﾞ ` [nix-kits] . [nixosModules] . [llama-cpp-rocm] ` ﾄｩ [your] ﾌﾚｲｸ ﾓｼﾞｭｰﾙ ﾘｽﾄ .

** ﾋﾞﾌｫｱ [**:]

```nix
# flake.nix — module list
{ ﾓｼﾞｭｰﾙｽﾞ = [
# [nix-kits] . [nixosModules] . [llama-cpp-rocm] # ← ﾉｯﾄ [yet] [imported]
[];}]

# llama-cpp.nix
{
[services] . [llama-cpp-rocm] = {
[enable] = [true] ;
ﾕｰｻﾞｰ = " [kix] ";
[group] = " [users] ";
};
[services] . [llama-cpp] = {
[enable] = [true] ;
ﾊﾟｯｹｰｼﾞ = [pkgs] . [llama-cpp-rocm] ;
[port] = 2027 ;
[modelsPreset] = {
" [Qwen3-Coder-Next] " = {
[hf-repo] = " [unsloth] / [Qwen3-Coder-Next-GGUF] ";
[hf-file] = " [Qwen3-Coder-Next-UD-Q4_K_XL] . [gguf] ";
[temp] = " 1 . 0 ";
};
};
};
# [Manual] [systemd] [overrides]
[systemd] . [services] . [llama-cpp] . [serviceConfig] = {
[DynamicUser] = ﾘﾌﾞ . [mkForce] [false] ;
[PrivateUsers] = ﾘﾌﾞ . [mkForce] [false] ;
[ProtectHome] = ﾘﾌﾞ . [mkForce] [false] ;
ﾕｰｻﾞｰ = ﾘﾌﾞ . [mkForce] " [kix] ";
[Group] = ﾘﾌﾞ . [mkForce] " [users] ";
ｴﾝﾊﾞｲﾛﾒﾝﾄ = ﾘﾌﾞ . [mkForce] [
" [LLAMA_CACHE] =/ ﾎｰﾑ / [kix] /. [cache] / [huggingface] / [hub] "
" [GGML_CUDA_ENABLE_UNIFIED_MEMORY] = 1 "
];
[ProcSubset] = ﾘﾌﾞ . [mkForce] " ｵｰﾙ ";
};
}
```

** ｱﾌﾀｰ [**:]

```nix
# flake.nix — module list (new)
{ ﾓｼﾞｭｰﾙｽﾞ = [
[nix-kits] . [nixosModules] . [llama-cpp-rocm]
[];}]

# llama-cpp.nix
{
[services] . [llama-cpp] = {
[enable] = [true] ;
ﾊﾟｯｹｰｼﾞ = [pkgs] . [llama-cpp-rocm] ;
ｾｯﾃｨﾝｸﾞｽﾞ . [port] = 2027 ;
};
[nixkits] . [llama-cpp-rocm] = {
[enable] = [true] ;
ﾕｰｻﾞｰ = " [kix] ";
[group] = " [users] ";
[hfCacheDir] = "/ ﾎｰﾑ / [kix] /. [cache] / [huggingface] / [hub] ";
[modelsPreset] = {
" [Qwen3-Coder-Next] " = {
[hf-repo] = " [unsloth] / [Qwen3-Coder-Next-GGUF] ";
[hf-file] = " [Qwen3-Coder-Next-UD-Q4_K_XL] . [gguf] ";
[temp] = " 1 . 0 ";
};
};
};
# [Extra] ｴﾇﾌﾞｲ [vars] ﾉｯﾄ [covered] ﾊﾞｲ NixKits ｵﾌﾟｼｮﾝｽﾞ
[systemd] . [services] . [llama-cpp] . [serviceConfig] . ｴﾝﾊﾞｲﾛﾒﾝﾄ = ﾘﾌﾞ . [mkForce] [
" [LLAMA_CACHE] =/ ﾎｰﾑ / [kix] /. [cache] / [huggingface] / [hub] "
" [GGML_CUDA_ENABLE_UNIFIED_MEMORY] = 1 "
];
}
```