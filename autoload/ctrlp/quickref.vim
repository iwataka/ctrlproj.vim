if exists('g:loaded_ctrlp_quickref') && g:loaded_ctrlp_quickref || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlp_quickref = 1

if !exists('g:ctrlp_quickref_readonly_enabled')
    let g:ctrlp_quickref_readonly_enabled = 1
endif

if !exists('g:ctrlp_quickref_open_extensions')
    let g:ctrlp_quickref_open_extensions = ['html', 'pdf']
endif

if !exists('g:ctrlp_quickref_last_dir')
    let g:ctrlp_quickref_last_dir = ''
endif

if !exists('g:ctrlp_quickref_configuration_file')
    let g:ctrlp_quickref_configuration_file = '~/.vim/.ctrlp-quickref'
endif

if !exists('g:ctrlp_quickref_rootmarkers')
    let g:ctrlp_quickref_rootmarkers = [
        \ '.projectile',
        \ '.git',
        \ '.hg',
        \ '.svn',
        \ '.bzr',
        \ '_darcs',
        \ 'build.xml',
        \ 'build.sbt'
        \ ]
endif

fu! ctrlp#quickref#edit()
    if filereadable(expand(g:ctrlp_quickref_configuration_file))
        echom 'readable'
        exe "normal! :e ".g:ctrlp_quickref_configuration_file."\<cr>"
    endif
endf

fu! s:read_config(lines)
    let l:exclusive_paths = []
    let l:inclusive_paths = []
    for line in a:lines
        if line =~ '^!\s\?'
            let l:tmp_paths = split(expand(substitute(line, '^!\s\?', "", "")), '\n')
            call s:add_directories(l:exclusive_paths, l:tmp_paths)
        elseif line !~ '^#' && line != ''
            let l:tmp_paths = split(expand(line), '\n')
            call s:add_directories(l:inclusive_paths, l:tmp_paths)
        endif
    endfor
    let l:paths = []
    for path in l:inclusive_paths
        if !s:contains(exclusive_paths, path)
            call add(l:paths, path)
        endif
    endfor
    retu l:paths
endf

fu! s:read_file_config()
    if filereadable(expand(g:ctrlp_quickref_configuration_file))
        let l:lines = readfile(expand(g:ctrlp_quickref_configuration_file))
        retu s:read_config(l:lines)
    el
        retu []
    endif
endf

fu! s:read_variable_config()
    if exists('g:ctrlp_quickref_paths')
        retu s:read_config(g:ctrlp_quickref_paths)
    el
        retu []
    endif
endf

fu! s:add_directories(list, paths)
    for path in a:paths
        if isdirectory(path)
            call add(a:list, path)
        endif
    endfor
endf

fu! s:contains(list, item)
    for i in a:list
        if i == a:item
            retu 1
        endif
    endfor
    retu 0
endf

fu! s:grep_with_prompt(path)
    let l:keyword = input('Keyword? ')
    if exists('g:ctrlp_quickref_grepprg') && g:ctrlp_quickref_grepprg != ''
        let l:tmp_grepprg = &grepprg
        let &grepprg = g:ctrlp_quickref_grepprg
    endif
    sil exe 'normal! :grep '."\'".l:keyword."\'".' '.a:path."\<cr>"
    if exists('l:tmp_grepprg')
        let &grepprg = l:tmp_grepprg
    endif
endf

call add(g:ctrlp_ext_vars, {
    \ 'init': 'ctrlp#quickref#init()',
    \ 'accept': 'ctrlp#quickref#accept',
    \ 'type': 'path',
    \ 'sort': 0,
    \ 'specinput': 0,
    \ })

fu! ctrlp#quickref#init()
    retu s:read_file_config() + s:read_variable_config()
endf

fu! ctrlp#quickref#accept(mode, str)
    call ctrlp#exit()
    if a:mode == 'h'
        cal s:grep_with_prompt(a:str)
    else
        let g:ctrlp_quickref_last_dir = a:str
        call ctrlp#init(ctrlp#reference#id(), {'dir': a:str})
    endif
endf

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlp#quickref#id()
    retu s:id
endf
