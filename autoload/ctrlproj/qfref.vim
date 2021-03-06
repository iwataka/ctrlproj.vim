if exists('g:loaded_ctrlproj_qfref') && g:loaded_ctrlproj_qfref || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlproj_qfref = 1

call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlp#quickfix#init()',
  \ 'accept': 'ctrlproj#qfref#accept',
  \ 'exit': 'ctrlproj#qfref#exit()',
  \ 'lname': 'quickfix',
  \ 'sname': 'qfx',
  \ 'type': 'line',
  \ 'sort': 0,
  \ 'nolim': 1
  \ })

fu! ctrlproj#qfref#init_with_path(path)
  let s:cd = a:path
  cal ctrlp#init(ctrlproj#qfref#id())
endfu

fu! ctrlproj#qfref#accept(mode, str)
  if g:ctrlproj_readonly_enabled
    aug ctrlproj-qfref
      au!
      au BufEnter * setlocal readonly
    aug END
  endif
  call call('ctrlp#quickfix#accept', [a:mode, a:str])
  if exists("#ctrlproj-qfref")
    au! ctrlproj-qfref
  endif
endf

fu! ctrlproj#qfref#exit()
  if exists("s:cd")
    exe "cd ".s:cd
  endif
endfu

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlproj#qfref#id()
  retu s:id
endf
