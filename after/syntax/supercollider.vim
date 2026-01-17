" 2025-12-05 SCLang pattern highlighting

" Special P* with their own colors
syntax keyword SCLangPdefn   Pdefn
syntax keyword SCLangPbindef Pbindef
syntax keyword SCLangPdef    Pdef

" All other common Pattern classes as one group
syntax keyword SCLangPattern
      \ Pseq Pser Pshuf Pn
      \ Pseries Pgeom Pgauss Pbeta
      \ Pwhite Pbrown Pexprand Pwrand
      \ Pfunc Pfuncn Pfuncx
      \ Pbind Pbindf Pmono PmonoArtic
      \ Ppar Pspawner Ppatlace Pstutter
      \ Pclutch Pgate Pif Pcase
      \ Pfin Pfindur Psync Psyncg
      \ Pstep Pwalk Pslide Ptuple
      \ Pslidex Pstretch Pstretchp
      \ Pswitch Pswitch1 Pchain
      \ Prand Pxorand Pinterleave
      \ PdegreeToKey Pkey Pindex
      \ Pnary Pgeomw Pserp Pwrandp Rest
      \ Place Ppatlace Psection

" Highlights
highlight default SCLangPdefn    guifg=#ff5555 gui=bold
highlight default SCLangPbindef  guifg=#55aaff gui=bold
highlight default SCLangPdef     guifg=#55ff55 gui=bold
highlight default SCLangPattern  guifg=#ffd633 gui=bold
