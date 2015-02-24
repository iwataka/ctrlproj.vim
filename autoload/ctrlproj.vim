if exists('g:loaded_ctrlproj') && g:loaded_ctrlproj || v:version < 700 || &cp
    finish
en
let g:loaded_ctrlproj = 1

if !exists('g:ctrlproj_readonly_enabled')
    let g:ctrlproj_readonly_enabled = 1
en

if !exists('g:ctrlproj_open_extensions')
    let g:ctrlproj_open_extensions = ['html', 'pdf']
en

if !exists('g:ctrlproj_last_dir')
    let g:ctrlproj_last_dir = ''
en

if !exists('g:ctrlproj_configuration_path')
    let g:ctrlproj_configuration_path = '~/.vim/.ctrlproj'
en

if !exists('g:ctrlproj_autoremove_enabled')
    let g:ctrlproj_autoremove_enabled = 1
en

if !exists('g:ctrlproj_src2test')
    let g:ctrlproj_src2test = {
        \ 'src/main/java/*.java': 'src/test/java/*Test.java',
        \ 'src/main/scala/*.scala': 'src/test/scala/*Test.scala'
        \ }
en

" This function partite a given string once
fu! s:partition(str, mid)
    let l:idx = stridx(a:str, a:mid)
    if l:idx != -1
        let l:len = strlen(a:mid)
        retu [a:str[:(l:idx - 1)], a:str[(l:idx + l:len):]]
    else
        retu [a:str, '']
    en
endf

fu! ctrlproj#alternate_current_buffer()
    let l:bufname = fnamemodify(bufname("%"), ":p")
    let l:alt_name = ctrlproj#alternate(l:bufname)
    if type(l:alt_name) == 1 && l:alt_name != ''
        silent exe "norm! :e ".l:alt_name."\<cr>"
    else
        echoe "This file has no patterns which can be alternated."
    en
endf

fu! ctrlproj#alternate(path)
    let l:all_regex = '\(.*\)'
    let l:path_regex = '\\(\\([^/]\\+/\\)*[^/]\\+\\)'
    for [key, value] in items(g:ctrlproj_src2test)
        let l:key_regex = l:all_regex.substitute(key, '*', l:path_regex, '')
        let l:value_regex = l:all_regex.substitute(value, '*', l:path_regex, '')
        if a:path =~ l:key_regex
            let [l:front, l:rear] = s:partition(value, '*')
            retu substitute(a:path, l:key_regex, '\1'.l:front.'\2'.l:rear, '')
        elsei a:path =~ l:value_regex
            let [l:front, l:rear] = s:partition(key, '*')
            retu substitute(a:path, l:value_regex, '\1'.l:front.'\2'.l:rear, '')
        en
    endfo
endf

fu! ctrlproj#edit()
    silent exe "normal! :e ".g:ctrlproj_configuration_path."\<cr>"
endf

" Note that this chanegs the current directory in current window.
fu! ctrlproj#files(path)
    let l:fullpath = fnamemodify(expand(a:path), ":p")
    cal ctrlp#setdir(l:fullpath)
    let l:files = ctrlp#files()
    cal ctrlp#progress('')
    retu l:files
endf

" Note that this changes the current directory.
fu! ctrlproj#remove_buffers(path)
    let l:files = ctrlproj#files(a:path)
    let l:first_buffer = 1
    let l:last_buffer = bufnr("$")
    let l:bufnr = l:first_buffer
    while !(l:bufnr > l:last_buffer)
        if bufexists(l:bufnr)
            let l:name = bufname(l:bufnr)
            if !&readonly && &modifiable
                if s:contains(l:files, l:name)
                    if getbufvar(l:bufnr, "&modified")
                        let l:response = input("Save changes in [".l:name."]?(y/n)")
                        if l:response =~ '[yY(yes)(Yes)(YES)]'
                            silent exe "norm! :write\<cr>"
                        en
                    en
                    if !getbufvar(l:bufnr, "&modified")
                        silent exe "norm! :".l:bufnr."bdelete\<cr>"
                    en
                en
            en
        en
        let l:bufnr = l:bufnr + 1
    endw
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
    if filereadable(expand(g:ctrlproj_configuration_path))
        let l:lines = readfile(expand(g:ctrlproj_configuration_path))
        retu s:read_config(l:lines)
    el
        retu []
    en
endf

fu! s:read_variable_config()
    if exists('g:ctrlproj_paths')
        retu s:read_config(g:ctrlproj_paths)
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
    if exists('g:ctrlproj_grepprg') && g:ctrlproj_grepprg != ''
        let l:tmp_grepprg = &grepprg
        let &grepprg = g:ctrlproj_grepprg
    en
    sil exe 'normal! :grep '."\'".l:keyword."\'".' '.a:path."\<cr>"
    if exists('l:tmp_grepprg')
        let &grepprg = l:tmp_grepprg
    en
endf

call add(g:ctrlp_ext_vars, {
    \ 'init': 'ctrlproj#init()',
    \ 'accept': 'ctrlproj#accept',
    \ 'type': 'path',
    \ 'sort': 0,
    \ 'specinput': 0,
    \ })

fu! ctrlproj#init()
    retu s:read_file_config() + s:read_variable_config()
endf

fu! ctrlproj#accept(mode, str)
    call ctrlp#exit()
    if a:mode == 'h'
        cal s:grep_with_prompt(a:str)
    elsei a:mode == 't'
        if g:ctrlproj_autoremove_enabled
            cal ctrlp#setpathmode('r', fnamemodify('.', ':p'))
            let l:cd = fnamemodify('.', ':p')
            cal ctrlproj#remove_buffers(l:cd)
        en
        silent exe "norm! :cd ".a:str."\<cr>"
    elsei a:mode == 'v'
        silent exe "norm! :e ".a:str."\<cr>"
    else
        let g:ctrlproj_last_dir = a:str
        call ctrlp#init(ctrlp#reference#id(), {'dir': a:str})
    en
endf

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlproj#id()
    retu s:id
endf
