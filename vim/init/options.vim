""" Settings
set expandtab
set is
set number
set shiftwidth=2
set splitright
set tabstop=2
set timeout timeoutlen=1000 ttimeoutlen=1000

""" Key bindings

" Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Easy escape
imap jk <Esc>

" Toggle highlight search
let hlstate=0
nnoremap <C-f> :if (hlstate%2 == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=hlstate+1<CR>:echo "toggled visibility for hlsearch"<CR>
inoremap <C-f> <ESC>:if (hlstate%2 == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=hlstate+1<CR>:echo "toggled visibility for hlsearch"<CR>

""" Auto cmds

" Remove trailing whitespace on save
autocmd BufWritePre *[^.md] %s/\s\+$//e

""" Theme
if exists(':ayu-vim')
  let ayucolor="mirage"
  colorscheme ayu
endif

let g:airline_theme='understated'
