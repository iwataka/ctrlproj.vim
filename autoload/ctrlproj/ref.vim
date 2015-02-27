if exists('g:loaded_ctrlproj_ref') && g:loaded_ctrlproj_ref || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlproj_ref = 1

let s:open_command = ''
if has('unix')
    if executable('xdg-open')
        let s:open_command = 'xdg-open'
    en
elsei has('win32unix')
    let s:open_command = 'cygstart'
elsei has('win32') || has('win64')
    let s:open_command = 'start'
elsei has('mac')
    let s:open_command = 'open'
endif

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
    if s:check_extension(a:str)
        if s:open_command != ''
            call system(s:open_command.' '.a:str)
        else
            echoe "You don't have the command to open files"
        en
        call ctrlp#exit()
    el
        if g:ctrlproj_readonly_enabled
            aug ctrlproj-ref
                au!
                au BufEnter * setlocal readonly
            aug END
        endif
        call call('ctrlp#acceptfile', [a:mode, a:str])
        if exists("#ctrlproj-ref")
            au! ctrlproj-ref
        endif
    endif
endf

fu! s:check_extension(fname)
    for extension in g:ctrlproj_open_extensions
        if a:fname =~ '.\?\.'.extension.'$'
            retu 1
        endif
    endfor
    retu 0
endf

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlproj#ref#id()
    retu s:id
endf
