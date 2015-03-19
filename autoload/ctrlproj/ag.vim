if exists('g:loaded_ctrlproj_ag') && g:loaded_ctrlproj_ag || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlproj_ag = 1

call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlproj#ag#init()',
  \ 'accept': 'ctrlproj#ag#accept',
  \ 'exit': 'ctrlproj#ag#exit()',
  \ 'type': 'path',
  \ 'sort': 0,
  \ 'specinput': 0,
  \ })

fu! ctrlproj#ag#init()
  let s:match_func_cache = g:ctrlp_match_func
  let g:ctrlp_match_func = { 'match': 'ctrlproj#ag#match' }
  retu ['Not Enough Characters', '']
endfu

fu! ctrlproj#ag#accept(mode, str)
  let l:fname = substitute(a:str, '\([^:]*\)\(:.*\)', '\1', '')
  let l:line_num = substitute(a:str, '\([^:]*\):\([0-9]*\)\(.*\)', '\2', '')
  call ctrlproj#utils#accept(a:mode, l:fname, l:line_num)
endfu

fu! ctrlproj#ag#exit()
  let g:ctrlp_match_func = s:match_func_cache
endfu

let g:ctrlproj_ag = ''

fu! ctrlproj#ag#match(items, str, limit, mmode, ispath, crfile, regex)
  let g:ctrlproj_ag = a:str
  call clearmatches()
  if strlen(a:str) < 3
    retu []
  endif
  let l:lines = split(system("ag ".a:str), "\n")
  retu ctrlproj#utils#parse_ag_result(l:lines)
endfu

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlproj#ag#id()
  retu s:id
endf
