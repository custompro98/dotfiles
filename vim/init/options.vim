""" Settings
set expandtab
set is
set number
set shiftwidth=2
set splitright
set tabstop=2
set timeout timeoutlen=1000 ttimeoutlen=1000

" Delete text from previous insert mode
set backspace=indent,eol,start

filetype plugin on

let mapleader = ","

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

" Abbreviate tabnew
cabbrev tn tabnew

" Sudo save
cabbrev sw w !sudo tee %

" View current syntax
cabbrev syn echo b:current_syntax

" Move lines up/down with alt+j/alt+k
" On a Mac: alt+j => ∆
" On a Mac: alt+k => ˚
let s:uname = system("echo -n \"$(uname)\"")
if s:uname == "Linux"
  nnoremap <A-j>  :m .+1<CR>==
  nnoremap <A-k> :m .-2<CR>==
  inoremap <A-j> <Esc>:m .+1<CR>==gi
  inoremap <A-k> <Esc>:m .-2<CR>==gi
  vnoremap <A-j> :m '>+1<CR>gv=gv
  vnoremap <A-k> :m '<-2<CR>gv=gv
endif

if s:uname == "Darwin"
  nnoremap ∆  :m .+1<CR>==
  nnoremap ˚ :m .-2<CR>==
  inoremap ∆ <Esc>:m .+1<CR>==gi
  inoremap ˚ <Esc>:m .-2<CR>==gi
  vnoremap ∆ :m '>+1<CR>gv=gv
  vnoremap ˚ :m '<-2<CR>gv=gv
endif

""" Auto cmds

" Remove trailing whitespace on save
autocmd BufWritePre *[^.md] %s/\s\+$//e

""" Theme
set termguicolors
" let ayucolor="light"
" colorscheme ayu
set background=dark
colorscheme gruvbox

""" Syntax highlighting
let g:jsx_ext_required=0
