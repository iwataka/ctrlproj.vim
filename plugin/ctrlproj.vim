com! -bar Ctrlproj cal ctrlp#init(ctrlproj#id())
com! -bar CtrlprojLastDir cal ctrlp#init(ctrlp#reference#id(), {'dir': g:ctrlproj_last_dir})
com! -bar CtrlprojEdit cal ctrlproj#edit()
com! -bar CtrlprojSwitch cal ctrlproj#switch_current_buffer()
com! -bar CtrlprojAlternate cal ctrlproj#alternate_current_buffer()
com! -bar CtrlprojRemoveBuffers cal ctrlproj#remove_buffers_inside_project()
com! -bar CtrlPCurRoot cal ctrlp#init(0, { 'mode': 'r', 'dir': '.'})
