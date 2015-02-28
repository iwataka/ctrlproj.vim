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
    let l:len = strlen(a:mid)
    if l:idx == 0
        retu ['', a:str[1:]]
    elsei l:idx != -1
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

fu! ctrlproj#utils#switch_by_template(path, dict)
    let l:all_regex = '\(.*\)'
    let l:path_regex = '\\(\\([^/]\\+/\\)*\\)'
    let l:tail_regex = '\\([^/]\\+\\)'
    for [key, val] in items(a:dict)
        let l:key_regex = substitute(key, '\([^\*]\)\(\*\)\([^\*]\)', '\1'.l:tail_regex.'\3', '')
        let l:key_regex = l:all_regex.substitute(l:key_regex, '\*\*/', l:path_regex, '')
        let l:val_regex = substitute(val, '\([^\*]\)\(\*\)\([^\*]\)', '\1'.l:tail_regex.'\3', '')
        let l:val_regex = l:all_regex.substitute(l:val_regex, '\*\*/', l:path_regex, '')
        if a:path =~ l:key_regex
            let [l:front, l:mid] = ctrlproj#utils#partition(val, '**/')
            let [l:mid, l:rear] = ctrlproj#utils#partition(l:mid, '*')
            retu substitute(a:path, l:key_regex, '\1'.l:front.'\2'.l:mid.'\4'.l:rear, '')
        elsei a:path =~ l:val_regex
            let [l:front, l:mid] = ctrlproj#utils#partition(key, '**/')
            let [l:mid, l:rear] = ctrlproj#utils#partition(l:mid, '*')
            retu substitute(a:path, l:val_regex, '\1'.l:front.'\2'.l:mid.'\4'.l:rear, '')
        en
    endfo
    retu ''
endf
