# translate-katalish (Skill)

[ 中文 [](../../] ｾﾞｯﾄｴｲﾁ / ｽｷﾙｽﾞ / [translate-katalish] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [translate-katalish] . md ) | [ [日本語] [](../../] ｼﾞｪｲｴｲ / ｽｷﾙｽﾞ / [translate-katalish] . md )

> [Extra] [natural-language] ｻﾎﾟｰﾄ ﾌｫｱ ｻﾞ [document-writing] ｽｷﾙ . [Adds] ｻﾞ [ｶﾀﾘｯｼｭ] ( ｶﾀｶﾅ ｲﾝｸﾞﾘｯｼｭ ) ﾗﾝｹﾞｰｼﾞ .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾀｲﾌﾟ|ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ ( ﾗﾝｹﾞｰｼﾞ ﾊﾞｯｸｴﾝﾄﾞ )
ﾊﾟｽ|` ｽｷﾙｽﾞ / translate - ｶﾀﾘｯｼｭ / ｽｷﾙ . md `
Called ﾊﾞｲ|ﾗｲﾄ - ﾌﾟﾛｼﾞｪｸﾄ - ﾄﾞｷｭｽﾞ ( primary ) , nixkits - ﾁｪｯｸ - updates ( indirect )

## Features

- ﾆｭｰ [ｶﾀﾘｯｼｭ] ﾗﾝｹﾞｰｼﾞ — [mechanical] [word-level] ｲﾝｸﾞﾘｯｼｭ → [halfwidth-katakana] [substitution]
- [Built-in] [dictionary] (~ 20 [common] [tech-doc] [words] )
- [Rule-based] [phonetic] [fallback] ﾌｫｱ [words] ﾉｯﾄ ｲﾝ ｻﾞ [dictionary]
- [Markdown] [syntax] ｱﾝﾄﾞ ｺｰﾄﾞ [blocks] [preserved]
- ﾌｧｲﾙ [naming] [convention] : ` ﾄﾞｷｭｽﾞ / ｶﾀﾘｯｼｭ /< ﾈｰﾑ >. md `

## Usage

[Automatically] [invoked] ﾊﾞｲ [write-project-docs] ｳｪﾝ [producing] [ｶﾀﾘｯｼｭ] [documents] ; ｷｬﾝ ｵﾙｿ ﾋﾞｰ [called] [directly] :

- " [Generate] ｱ [katakana-english] ﾊﾞｰｼﾞｮﾝ ｵﾌﾞ ｻﾞ [document] "
- " ｱﾄﾞ [ｶﾀﾘｯｼｭ] ﾗﾝｹﾞｰｼﾞ [variant] "
- " [Translate] ﾄｩ ｶﾀｶﾅ ｲﾝｸﾞﾘｯｼｭ "

## Example

```
NixKits — ｿﾌﾄｳｪｱ , ﾊﾟｯﾁｰｽﾞ , ﾆｯｸｽOS ﾓｼﾞｭｰﾙｽﾞ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙｽﾞ .
```
→
```
[ﾆｯｸｽｷｯﾄ] — [ｿﾌﾄｳｪｱ] , [ﾊﾟｯﾁｰｽﾞ] , [ﾆｯｸｽOS] [ﾓｼﾞｭｰﾙ] [ｱﾝﾄﾞ] [ｺｰﾃﾞｨﾝｸﾞ] [ｴｰｼﾞｪﾝﾄ] [ｽｷﾙ] .
```