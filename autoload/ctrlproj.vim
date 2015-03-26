if exists('g:loaded_ctrlproj') && g:loaded_ctrlproj || v:version < 700 || &cp
  finish
en
let g:loaded_ctrlproj = 1

if !exists('g:ctrlproj_paths')
  if has('unix')
    let g:ctrlproj_paths = [
      \ '/usr/lib/ruby/[1-9]\+\(\.[1-9]\+\)*',
      \ '/usr/lib/python[1-9]\+\(\.[1-9]\+\)*',
      \ '/usr/lib/perl/[1-9]\+\(\.[1-9]\+\)*'
      \ ]
  else
    let g:ctrlproj_paths = []
  en
en

if !exists('g:ctrlproj_readonly_enabled')
  let g:ctrlproj_readonly_enabled = 1
en

if !exists('g:ctrlproj_refresh_enabled')
  let g:ctrlproj_refresh_enabled = 1
endif

if !exists('g:ctrlproj_open_extensions')
  let g:ctrlproj_open_extensions = ['html', 'pdf']
en

if !exists('g:ctrlproj_configuration_path')
  if has('win32') || has('win64')
    g:ctrlproj_configuration_path = '~/vimfiles/.ctrlproj'
  else
    let g:ctrlproj_configuration_path = '~/.vim/.ctrlproj'
  en
en

if !exists('g:ctrlproj_src2test')
  let g:ctrlproj_src2test = {
    \ 'src/main/java/**/*.java': 'src/test/java/**/*Test.java',
    \ 'src/main/scala/**/*.scala': 'src/test/scala/**/*Test.scala',
    \ 'app/admin/*.rb': 'spec/features/admin/*_spec.rb',
    \ 'app/controllers/*_controller.rb': 'spec/controllers/*_controller_spec.rb',
    \ 'app/decorators/*_decorator.rb': 'spec/decorators/*_decorator_spec.rb',
    \ 'app/helpers/*_helper.rb': 'spec/helpers/*_helper_spec.rb',
    \ 'app/mailers/*_mailers.rb': 'spec/mailers/*_mailer_spec.rb',
    \ 'app/models/*.rb': 'spec/models/*_spec.rb',
    \ 'app/workers/*.rb': 'spec/workers/*_spec.rb'
    \ }
en

let s:lastdir = ''

fu! s:Open(file, type)
  if a:type =~ '\(v\|vsplit\)'
    let l:cmd = 'vsplit'
  elsei a:type =~ '\(s\|split\)'
    let l:cmd = 'split'
  else
    let l:cmd = 'edit'
  endif
  let l:dir = fnamemodify(a:file, ':p:h')
  if !isdirectory(l:dir)
    silent exe "norm! :!mkdir -p ".l:dir."\<cr>"
  endif
  silent exe "norm! :".l:cmd." ".a:file."\<cr>"
endfu

fu! ctrlproj#switch_current_buffer(type)
  cal ctrlp#setpathmode('r', fnamemodify('.', ':p'))
  let l:files = ctrlproj#switch('.', '%')
  if len(l:files) != 0
    for l:fl in l:files
      call s:Open(l:fl, a:type)
    endfo
  else
    let l:bufname = fnamemodify(bufname("%"), ":p")
    let l:alt_name = ctrlproj#utils#switch_by_template(l:bufname, g:ctrlproj_src2test)
    if l:alt_name != ''
      call s:Open(l:alt_name, a:type)
    else
      echoe 'Not found'
    en
  en
endf

fu! ctrlproj#alternate_current_buffer(type)
  let l:files = ctrlproj#alternate('.', '%')
  let l:open_cmd = s:open_cmd(a:type)
  for fl in l:files
    silent exe "norm! :".l:open_cmd." ".fl."\<cr>"
  endfo
endf

fu! ctrlproj#switch(path, file)
  let l:cands = ctrlproj#files(a:path)
  retu ctrlproj#utils#switch_by_regexp(a:file,  l:cands)
endf

fu! ctrlproj#alternate(path, file)
  let l:files = ctrlproj#files(a:path)
  let l:result = []
  let l:expanded_filename = expand(a:file)
  let l:rootname = fnamemodify(expanded_filename, ':t:r')
  let l:extension = fnamemodify(expanded_filename, ':t:e')
  for fl in l:files
    let l:rt = fnamemodify(fl, ':t:r')
    let l:ex = fnamemodify(fl, ':t:e')
    if l:rt ==? l:rootname && l:ex != l:extension
      cal add(l:result, fl)
    en
  endfo
  retu l:result
endf

fu! ctrlproj#edit()
  silent exe "normal! :e ".g:ctrlproj_configuration_path."\<cr>"
endf

fu! ctrlproj#init_lastdir()
  cal ctrlp#init(ctrlproj#ref#id(), {'dir': s:lastdir})
endfu

" Note that this chanegs the current directory in current window.
fu! ctrlproj#files(path)
  let l:fullpath = fnamemodify(expand(a:path), ":p")
  cal ctrlp#setdir(l:fullpath)
  let l:files = ctrlp#files()
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
      if !getbufvar(l:bufnr, "&readonly") && getbufvar(l:bufnr, "&modifiable")
        if ctrlproj#utils#contains(l:files, l:name)
          if getbufvar(l:bufnr, "&modified")
            let l:res = input("Save changes in ".l:name."? ")
            if l:res =~ '[[yY]\|\(yes\)\|\(Yes\)\|\(YES\)]'
              silent exe "norm! :write\<cr>"
            en
          en
          if !getbufvar(l:bufnr, "&modified")
            silent! exe "norm! :".l:bufnr."bdelete\<cr>"
          en
        en
      en
    en
    let l:bufnr = l:bufnr + 1
  endw
endf

fu! ctrlproj#remove_buffers_inside_project()
  cal ctrlp#setpathmode('r', fnamemodify('.', ':p'))
  let l:cd = fnamemodify('.', ':p')
  cal ctrlproj#remove_buffers(l:cd)
endf

fu! ctrlproj#cd_root()
  cal ctrlp#setpathmode('r', fnamemodify('.', ':p'))
  let l:root = fnamemodify('.', ':p')
  exe "normal! :cd ".l:root."\<cr>"
endfu

call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlproj#init()',
  \ 'accept': 'ctrlproj#accept',
  \ 'type': 'path',
  \ 'sort': 0,
  \ 'specinput': 0,
  \ })

fu! ctrlproj#init()
  retu ctrlproj#utils#parse_file(g:ctrlproj_configuration_path) + s:Read_var_config()
endf

fu! s:Read_var_config()
  if exists('g:ctrlproj_paths')
    retu ctrlproj#utils#parse_config(g:ctrlproj_paths)
  el
    retu []
  en
endf

fu! ctrlproj#accept(mode, str)
  call ctrlp#exit()
  if a:mode == 'h'
    silent exe "norm! :e ".a:str."\<cr>"
  elsei a:mode == 't'
    if g:ctrlproj_refresh_enabled | cal ctrlp#clr() | en
    cal ctrlproj#remove_buffers_inside_project()
    silent exe "norm! :cd ".a:str."\<cr>"
  elsei a:mode == 'v'
    silent exe "norm! :cd ".a:str."\<cr>"
  else
    let s:lastdir = a:str
    call ctrlp#init(ctrlproj#ref#id(), {'dir': a:str})
  en
endf

fu! ctrlproj#grep(readonly, use_last_keyword)
  let l:qflist = getqflist()
  if a:use_last_keyword && exists("s:qflist")
    cal setqflist(s:qflist)
  else
    let l:keyword = input("Keyword? ")
    let l:grep_cmd = "silent exe \"norm! :grep! '".l:keyword."'\\<cr>\""
    silent exe "norm! :noautocmd ".l:grep_cmd."\<cr>"
    let s:qflist = getqflist()
  endif
  if a:readonly
    cal ctrlp#init(ctrlp#qfref#id())
  else
    cal ctrlp#init(ctrlp#quickfix#id())
  endif
  cal setqflist(l:qflist)
endfu

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlproj#id()
  retu s:id
endf
