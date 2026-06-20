# kitsfmt

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [kitsfmt] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [kitsfmt] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [kitsfmt] . md )

** ﾆｯｸｽ ﾌｫｰﾏｯﾀｰ ** — [AST-based] ｳｨｽﾞ [attribute] [sorting] , [comment] [preservation] , ｱﾝﾄﾞ [indentation] [normalization] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|0 . 5 . 0
ﾗﾝｹﾞｰｼﾞ|Rust
ｿｰｽ|ﾃﾞｨｽ repo ` ﾊﾟｯｹｰｼﾞｰｽﾞ / kitsfmt - src / `

## Usage

```bash
[kitsfmt] ﾌｧｲﾙ . ﾆｯｸｽ # ｱｳﾄﾌﾟｯﾄ ﾄｩ [stdout]
[kitsfmt] [--inplace] ﾌｧｲﾙ . ﾆｯｸｽ # [in-place] ﾌｫｰﾏｯﾄ
[kitsfmt] [--check] ﾌｧｲﾙ . ﾆｯｸｽ # ﾁｪｯｸ [formatting]
[kitsfmt] [--no-best-practices] # [disable] [auto-fixes]
[kitsfmt] [file1] . ﾆｯｸｽ [file2] . ﾆｯｸｽ # [multiple] ﾌｧｲﾙｽﾞ
```

ｴﾇﾌﾞｲ [vars] : ` [KITSFMT_INPLACE] = 1 `, ` [KITSFMT_CHECK] = 1 `, ` [KITSFMT_BEST_PRACTICES] = 0 `

## Install

```nix
# Direct
ｴﾝﾊﾞｲﾛﾒﾝﾄ . [systemPackages] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . ﾊﾟｯｹｰｼﾞｰｽﾞ [.${] [pkgs] . ｼｽﾃﾑ }. [kitsfmt] ];

# Default overlay (recommended)
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . ﾃﾞﾌｫﾙﾄ ]; # → [pkgs] . [kitsfmt]

# As nix fmt formatter
# formatter.${system} = inputs.nix-kits.formatter.${system};
# then: nix fmt
```

## Features

- [Attribute] [sorting] ( [including] [APC] ` ｱ . b . c ` [collapse] )
- [Comment] [preservation]
- [Idempotent] [formatting]
- ** [Best-practice] [auto-fixes] ** ( ﾃﾞﾌｫﾙﾄ ｵﾝ , ` -B ` ﾄｩ [disable] ):
- [Bare] ﾕｰｱｰﾙｴﾙ [quoting] ( [RFC] 45 ): ` https [://] x . [com] ` → `" https [://] x . [com] "`
- ` [rec] ` → ` [let-in] `: ` [rec] { ｱ = 1 ; }` → ` [let] ｱ = 1 ; ｲﾝ { [inherit] ｱ ; }`
- ` ｳｨｽﾞ ` → ` [builtins] . [attrValues] `: ` ｳｨｽﾞ [pkgs] ; [ ｱ b ]` → ` [builtins] . [attrValues] { [inherit] ( [pkgs] ) ｱ b ; }`