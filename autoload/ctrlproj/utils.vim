if exists('g:loaded_ctrlproj_utils') && g:loaded_ctrlproj_utils || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlproj_utils = 1

" Checks if a given list contains an item.
fu! ctrlproj#utils#contains(list, item)
    for i in a:list
        if i == a:item
            retu 1
        en
    endfo
    retu 0
endf

fu! ctrlproj#utils#contains_regex(list, regex)
  for i in a:list
    if i =~ a:regex
      retu 1
    endif
  endfor
endfu

" Partites a given string once
fu! ctrlproj#utils#partition(str, mid)
    let l:idx = stridx(a:str, a:mid)
    if l:idx != -1
        let l:len = strlen(a:mid)
        retu [a:str[:(l:idx - 1)], a:str[(l:idx + l:len):]]
    else
        retu [a:str, '']
    en
endf

" Adds directories in a given paths to a list.
fu! ctrlproj#utils#add_dirs(list, paths)
    for path in a:paths
        if isdirectory(path)
            call add(a:list, path)
        en
    endfo
endf

fu! ctrlproj#utils#parse_file(file)
    let l:fl = expand(a:file)
    if filereadable(l:fl)
        let l:lines = readfile(l:fl)
        retu ctrlproj#utils#parse(l:lines)
    el
        retu []
    en
endf

fu! ctrlproj#utils#parse(lines)
    let l:exclusive_paths = []
    let l:inclusive_paths = []
    for line in a:lines
        if line =~ '^!\s\?'
            let l:tmp_paths = split(expand(substitute(line, '^!\s\?', "", "")), '\n')
            call ctrlproj#utils#add_dirs(l:exclusive_paths, l:tmp_paths)
        elseif line !~ '^#' && line != ''
            let l:tmp_paths = split(expand(line), '\n')
            call ctrlproj#utils#add_dirs(l:inclusive_paths, l:tmp_paths)
        en
    endfo
    let l:paths = []
    for path in l:inclusive_paths
        if !ctrlproj#utils#contains(exclusive_paths, path)
            call add(l:paths, path)
        en
    endfo
    retu l:paths
endf
