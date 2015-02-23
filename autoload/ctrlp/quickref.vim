if exists('g:loaded_ctrlp_quickref') && g:loaded_ctrlp_quickref || v:version < 700 || &cp
    finish
en
let g:loaded_ctrlp_quickref = 1

if !exists('g:ctrlp_quickref_readonly_enabled')
    let g:ctrlp_quickref_readonly_enabled = 1
en

if !exists('g:ctrlp_quickref_open_extensions')
    let g:ctrlp_quickref_open_extensions = ['html', 'pdf']
en

if !exists('g:ctrlp_quickref_last_dir')
    let g:ctrlp_quickref_last_dir = ''
en

if !exists('g:ctrlp_quickref_configuration_file')
    let g:ctrlp_quickref_configuration_file = '~/.vim/.ctrlp-quickref'
en

if !exists('g:ctrlp_quickref_rootmarker_dirs')
    let g:ctrlp_quickref_rootmarker_dirs = [
        \ '.git',
        \ '.hg',
        \ '.svn',
        \ '.bzr',
        \ '_darcs'
        \ ]
en

if !exists('g:ctrlp_quickref_rootmarker_files')
    let g:ctrlp_quickref_rootmarker_files = [
        \ '.projectile',
        \ '.travis.yml',
        \ 'build.xml',
        \ 'build.sbt'
        \ ]
en

fu! ctrlp#quickref#edit()
    if filereadable(expand(g:ctrlp_quickref_configuration_file))
        echom 'readable'
        exe "normal! :e ".g:ctrlp_quickref_configuration_file."\<cr>"
    en
endf

fu! ctrlp#quickref#root(path)
    let l:fullpath = fnamemodify(expand(a:path), ":p")
    let l:prev = ''
    let l:dir = l:fullpath
    while 1
        let l:prev = l:dir
        let l:dir = fnamemodify(l:dir, ":h")
        for marker in g:ctrlp_quickref_rootmarker_dirs
            if filereadable(l:dir.'/'.marker) || isdirectory(l:dir.'/'.marker)
                retu l:dir
            en
        endfo
        for marker in g:ctrlp_quickref_rootmarker_files
            if filereadable(l:dir.'/'.marker) || !isdirectory(l:dir.'/'.marker)
                retu l:dir
            en
        endfo
        if l:dir == l:prev
            brea
        en
    endw
    retu ''
endf

" Note that this chanegs the current directory to the 'path'
fu! s:files(path)
    let l:fullpath = fnamemodify(expand(a:path), ":p")
    cal ctrlp#setdir(l:fullpath)
    let l:files = ctrlp#files()
    cal ctrlp#progress('')
    retu l:files
endf

fu! ctrlp#quickref#remove(path)
    let l:pwd = fnamemodify('.', ":p")
    let l:files = s:files(a:path)
    let l:first_buffer = 1
    let l:last_buffer = bufnr("$")
    let l:bufnr = l:first_buffer
    while !(l:bufnr > l:last_buffer)
        if bufexists(l:bufnr)
            silent exe "norm! :".l:bufnr."buffer\<cr>"
            let l:name = bufname(l:bufnr)
            if &modified
                let l:response = input("Save changes in [".l:name."] ?(y/n)")
                if l:response =~ '[yY(yes)(Yes)(YES)]'
                    silent exe "norm! :write\<cr>"
                en
            en
            if !&modified && s:contains(l:files, l:name)
                silent exe "norm! :".l:bufnr."bdelete\<cr>"
            en
        en
        let l:bufnr = l:bufnr + 1
    endw
    silent exe "norm! :cd ".l:pwd."\<cr>"
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
        en
    endfo
    let l:paths = []
    for path in l:inclusive_paths
        if !s:contains(exclusive_paths, path)
            call add(l:paths, path)
        en
    endfo
    retu l:paths
endf

fu! s:read_file_config()

    if filereadable(expand(g:ctrlp_quickref_configuration_file))
        let l:lines = readfile(expand(g:ctrlp_quickref_configuration_file))
        retu s:read_config(l:lines)
    el
        retu []
    en
endf

fu! s:read_variable_config()
    if exists('g:ctrlp_quickref_paths')
        retu s:read_config(g:ctrlp_quickref_paths)
    el
        retu []
    en
endf

fu! s:add_directories(list, paths)
    for path in a:paths
        if isdirectory(path)
            call add(a:list, path)
        en
    endfo
endf

fu! s:contains(list, item)
    for i in a:list
        if i == a:item
            retu 1
        en
    endfo
    retu 0
endf

fu! s:grep_with_prompt(path)
    let l:keyword = input('Keyword? ')
    if exists('g:ctrlp_quickref_grepprg') && g:ctrlp_quickref_grepprg != ''
        let l:tmp_grepprg = &grepprg
        let &grepprg = g:ctrlp_quickref_grepprg
    en
    sil exe 'normal! :grep '."\'".l:keyword."\'".' '.a:path."\<cr>"
    if exists('l:tmp_grepprg')
        let &grepprg = l:tmp_grepprg
    en
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
    en
endf

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlp#quickref#id()
    retu s:id
endf
