if exists('g:loaded_ctrlproj') && g:loaded_ctrlproj || v:version < 700 || &cp
  finish
en
let g:loaded_ctrlproj = 1

if !exists('g:ctrlproj_paths')
  let g:ctrlproj_paths = []
en

if !exists('g:ctrlproj_readonly_enabled')
  let g:ctrlproj_readonly_enabled = 1
en

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

fu! ctrlproj#switch_current_buffer()
  let l:bufname = fnamemodify(bufname("%"), ":p")
  let l:alt_name = ctrlproj#utils#switch_by_template(l:bufname, g:ctrlproj_src2test)
  if l:alt_name != ''
    silent exe "norm! :e ".l:alt_name."\<cr>"
  else
    let l:files = ctrlproj#switch('.', '%')
    if len(l:files) == 0
      echo "File not found."
    else
      for fl in l:files
        silent exe "norm! :e ".fl."\<cr>"
      endfo
    en
  en
endf

fu! ctrlproj#alternate_current_buffer()
  let l:files = ctrlproj#alternate('.', '%')
  for fl in l:files
    silent exe "norm! :e ".fl."\<cr>"
  endfo
endf

fu! ctrlproj#switch(path, file)
  let l:test_mark = '\(\(test\)\|\(spec\)\|\(Test\)\|\(Spec\)\)'
  let l:files = ctrlproj#files(a:path)
  let l:result = []
  let l:expanded_filename = expand(a:file)
  let l:rootname = fnamemodify(l:expanded_filename, ':t:r')
  let l:extension = fnamemodify(l:expanded_filename, ':t:e')
  let l:is_source = l:rootname !~ l:test_mark
  for fl in l:files
    let l:rt = fnamemodify(fl, ':t:r')
    let l:ex = fnamemodify(fl, ':t:e')
    let l:str = substitute(l:rootname, l:test_mark, '', '')
    let l:is_src = l:rt !~ l:test_mark
    if l:ex == l:extension && l:rt =~ l:str && xor(l:is_source, l:is_src)
      cal add(l:result, fl)
    en
  endfo
  retu l:result
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
            silent exe "norm! :".l:bufnr."bdelete\<cr>"
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

call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlproj#init()',
  \ 'accept': 'ctrlproj#accept',
  \ 'type': 'path',
  \ 'sort': 0,
  \ 'specinput': 0,
  \ })

fu! ctrlproj#init()
  retu ctrlproj#utils#parse_file(g:ctrlproj_configuration_path) + s:read_var_config()
endf

fu! s:read_var_config()
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
    cal ctrlproj#remove_buffers_inside_project()
    silent exe "norm! :cd ".a:str."\<cr>"
  elsei a:mode == 'v'
    silent exe "norm! :cd ".a:str."\<cr>"
  else
    let s:lastdir = a:str
    call ctrlp#init(ctrlproj#ref#id(), {'dir': a:str})
  en
endf

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

fu! ctrlproj#id()
  retu s:id
endf
