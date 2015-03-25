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
    retu ctrlproj#utils#parse_config(l:lines)
  el
    retu []
  en
endf

fu! ctrlproj#utils#parse_config(lines)
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

fu! ctrlproj#utils#convert_path_wildcard(path)
  let l:all_regex = '\(.*\)'
  let l:tail_regex = '\\([^/]\\+\\)'
  let l:path_regex = '\\(\\([^/]\\+/\\)*\\)'
  let l:regex = substitute(a:path, '\([^\*]\)\(\*\)\([^\*]\)', '\1'.l:tail_regex.'\3', '')
  retu l:all_regex.substitute(l:regex, '\*\*/', l:path_regex, '')
endfu

fu! ctrlproj#utils#switch_by_template(path, dict)
  for [key, val] in items(a:dict)
    let l:key_flag = key =~ '\*\*/'
    let l:key_regex = ctrlproj#utils#convert_path_wildcard(key)
    let l:val_flag = val =~ '\*\*/'
    let l:val_regex = ctrlproj#utils#convert_path_wildcard(val)
    if a:path =~ l:key_regex
      if l:key_flag
        let [l:front, l:mid] = ctrlproj#utils#partition(val, '**/')
        let [l:mid, l:rear] = ctrlproj#utils#partition(l:mid, '*')
        retu substitute(a:path, l:key_regex, '\1'.l:front.'\2'.l:mid.'\4'.l:rear, '')
      else
        let [l:front, l:rear] = ctrlproj#utils#partition(val, '*')
        retu substitute(a:path, l:key_regex, '\1'.l:front.'\2'.l:rear, '')
      en
    elsei a:path =~ l:val_regex
      if l:val_flag
        let [l:front, l:mid] = ctrlproj#utils#partition(key, '**/')
        let [l:mid, l:rear] = ctrlproj#utils#partition(l:mid, '*')
        retu substitute(a:path, l:val_regex, '\1'.l:front.'\2'.l:mid.'\4'.l:rear, '')
      else
        let [l:front, l:rear] = ctrlproj#utils#partition(key, '*')
        retu substitute(a:path, l:val_regex, '\1'.l:front.'\2'.l:rear, '')
      en
    en
  endfo
  retu ''
endf

fu! ctrlproj#utils#switch_by_regexp(file, cands) 
  let l:test_mark = '\(\(_test\)\|\(_spec\)\|\(Test\)\|\(Spec\)\)'
  let l:result = []
  let l:expanded_filename = expand(a:file)
  let l:rootname = fnamemodify(l:expanded_filename, ':t:r')
  let l:extension = fnamemodify(l:expanded_filename, ':t:e')
  let l:is_source = l:rootname !~ l:test_mark
  for fl in a:cands
    let l:rt = fnamemodify(fl, ':t:r')
    let l:ex = fnamemodify(fl, ':t:e')
    let l:str = substitute(l:rootname, l:test_mark, '', '')
    let l:is_src = l:rt !~ l:test_mark
    if l:rt =~ l:str && xor(l:is_source, l:is_src)
      cal add(l:result, fl)
    en
  endfo
  retu l:result
endfu

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

fu! ctrlproj#utils#accept(...)
  let l:mode = a:1
  let l:str = a:2
  let l:line_num = a:0 > 2 ? a:3 : ''
  if s:check_extension(l:str)
    if s:open_command != ''
      call system(s:open_command.' '.l:str)
    else
      echoe "You don't have the command to open files"
    en
    call ctrlp#exit()
  el
    if g:ctrlproj_readonly_enabled
      aug ctrlproj-utils
        au!
        au BufEnter * setlocal readonly
      aug END
    endif
    call call('ctrlp#acceptfile', [l:mode, l:str, l:line_num])
    if exists("#ctrlproj-utils")
      au! ctrlproj-utils
    endif
  endif
endfu

fu! s:check_extension(fname)
  for ext in g:ctrlproj_open_extensions
    if a:fname =~ '.\?\.'.ext.'$'
      retu 1
    endif
  endfor
  retu 0
endf
