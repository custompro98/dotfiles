" Visual settings

""" Configuration

" Split directions
set splitright
set splitbelow

" Theme
set termguicolors
set background=dark
colorscheme gruvbox

""" Keybindings

" zoom a vim pane, <C-w>= to re-balance
nnoremap <leader>- :wincmd _<cr>:wincmd \|<cr>
nnoremap <leader>= :wincmd =<cr>
