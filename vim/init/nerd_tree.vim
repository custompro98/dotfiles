""" Key bindings
map <C-\> :NERDTreeToggle<CR>

""" Auto cmds

" Start NerdTree when no files specified in vim
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Close NerdTree if last window open
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

""" Settings
let NERDTreeShowHidden=1
