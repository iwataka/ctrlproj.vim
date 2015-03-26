com! -bar Ctrlproj cal ctrlp#init(ctrlproj#id())
com! -bar CtrlprojLastDir cal ctrlproj#init_lastdir()
com! -bar CtrlprojEdit cal ctrlproj#edit()
com! -bar CtrlprojSwitch cal ctrlproj#switch_current_buffer()
com! -bar CtrlprojVSwitch cal ctrlproj#switch_current_buffer('v')
com! -bar CtrlprojSSwitch cal ctrlproj#switch_current_buffer('s')
com! -bar CtrlprojAlternate cal ctrlproj#alternate_current_buffer()
com! -bar CtrlprojVAlternate cal ctrlproj#alternate_current_buffer('v')
com! -bar CtrlprojSAlternate cal ctrlproj#alternate_current_buffer('s')
com! -bar CtrlprojRemoveBuffers cal ctrlproj#remove_buffers_inside_project()
com! -bar CtrlprojRooter cal ctrlproj#cd_root()
com! -bar CtrlprojGrep cal ctrlproj#grep()

fu! ctrlproj#grep()
  let l:keyword = input("Keyword? ")
  let l:qflist = getqflist()
  let l:grep_cmd = "silent exe \"norm! :grep! '".l:keyword."'\\<cr>\""
  echom l:grep_cmd
  silent exe "norm! :noautocmd ".l:grep_cmd."\<cr>"
  cal ctrlp#init(ctrlp#quickfix#id())
  cal setqflist(l:qflist)
endfu
