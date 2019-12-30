" File tree

Plug 'scrooloose/nerdtree'

""" Keybindings

map <C-\> :NERDTreeToggle<CR>

""" Autocommands

" Close NerdTree if last window open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
