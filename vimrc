set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" Vundle
Plugin 'VundleVim/Vundle.vim'

" General Plugins
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tomtom/tcomment_vim'
Plugin 'mileszs/ack.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'

" Syntax Specific Plugins
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-rails'

" Asctetic Plugins
Plugin 'ayu-theme/ayu-vim'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()            " required

filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set number
set tabstop=2
set shiftwidth=2
set expandtab
set splitright

syntax on

" NerdTree
map <C-\> :NERDTreeToggle<CR>

" Start NerdTree when no files specified in vim
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Close NerdTree if last window open
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" ag in ack.vim
if executable('ag')
  let g:ackprg = 'ag --nogroup --nocolor --column'
endif
cnoreabbrev ack Ack!
imap jk <Esc>

" Remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Git
cnoreabbrev gbl Gblame
cnoreabbrev gst Gstatus
cnoreabbrev gdf Gdiff
cnoreabbrev gco Gread                    "git checkout --<current file>, use u to undo checkout

" Tcomment
nnoremap <C-/> :TComment

" Statusline
set laststatus=2
let g:airline_powerline_fonts = 1
set t_Co=256

" Theme
let ayucolor="mirage"
colorscheme ayu
let g:airline_theme='understated'
