""" Key bindings
map <C-\> :NERDTreeToggle<CR>

""" Auto cmds

" Close NerdTree if last window open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
