com! Ctrlproj cal ctrlp#init(ctrlproj#id())
com! CtrlprojLastDir cal ctrlp#init(ctrlp#reference#id(), {'dir': g:ctrlproj_last_dir})
com! CtrlprojEdit cal ctrlproj#edit()
com! CtrlprojSwitch cal ctrlproj#switch_current_buffer()
com! CtrlprojSwitchByTemplate cal ctrlproj#switch_current_buffer_by_template()
com! CtrlprojAlternate cal ctrlproj#alternate_current_buffer()
com! CtrlprojRemoveBuffers cal ctrlproj#remove_buffers_under_root()
