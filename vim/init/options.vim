""" Settings
set number
set tabstop=2
set shiftwidth=2
set expandtab
set splitright

""" Key bindings

" Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Easy escape
imap jk <Esc>

""" Auto cmds

" Remove trailing whitespace on save
autocmd BufWritePre *.[^.md] %s/\s\+$//e

""" Theme
let ayucolor="mirage"
colorscheme ayu

let g:airline_theme='understated'
