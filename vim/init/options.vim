""" Settings
set expandtab
set is
set number
set shiftwidth=2
set splitright
set splitbelow
set tabstop=2
set timeout timeoutlen=1000 ttimeoutlen=100

" Delete text from previous insert mode
set backspace=indent,eol,start

filetype plugin on

""" Command Abbreviations
" Abbreviate tabnew
cabbrev tn tabnew

" Sudo save
cabbrev sw w !sudo tee %

" View current syntax
cabbrev syn echo b:current_syntax

" Open terminal in splits
cabbrev vterm 100vsplit \| terminal
cabbrev sterm 20split \| terminal

""" Key bindings

" Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Easy escape
imap jk <Esc>
tmap jk <Esc>

" Toggle highlight search
nnoremap <Leader>h :set hlsearch<CR>
nnoremap <Leader>H :set nnoohlsearch<CR>

" Leave terminal mode
tnoremap <Leader>t <C-\><C-n>
tmap <Esc> <C-\><C-n>

" Open terminal
nnoremap <Leader>t :20split \| terminal<CR>

" Re-source vimrc
nnoremap <Leader>s :source ~/.vimrc<CR>

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
set background=dark
colorscheme gruvbox
