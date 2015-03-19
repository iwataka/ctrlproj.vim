if exists('g:loaded_ctrlproj_ref') && g:loaded_ctrlproj_ref || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlproj_ref = 1

call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlproj#ref#init()',
  \ 'accept': 'ctrlproj#ref#accept',
  \ 'type': 'path',
  \ 'sort': 0,
  \ 'specinput': 0,
  \ })

fu! ctrlproj#ref#init()
  let l:files = ctrlp#files()
  " If this is not here, the word 'Indexing...' is remained.
  cal ctrlp#progress('')
  retu l:files
endf

fu! ctrlproj#ref#accept(mode, str)
  call ctrlproj#utils#accept(a:mode, a:str)
endf

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlproj#ref#id()
  retu s:id
endf
