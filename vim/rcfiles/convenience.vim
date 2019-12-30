"  Make vim feel like home

""" Keybindings

" Easy escape
imap jk <Esc>
tmap jk <Esc>

" Leave terminal mode
tnoremap <Leader>t <C-\><C-n>
tmap <Esc> <C-\><C-n>

" Toggle highlight search
nnoremap <Leader>h :set hlsearch<CR>
nnoremap <Leader>H :set nohlsearch<CR>

" Re-source vimrc
nnoremap <Leader>r :source ~/.vimrc<CR>

" Open a scratch editor
nnoremap <Leader>vs :exec winwidth(0)/3.'vsplit' \| view scratch<CR>
nnoremap <Leader>s :exec winheight(0)/5.'split' \| view scratch<CR>

""" Abbreviations

cabbrev tn tabnew
" sudo write
cabbrev sw w !sudo tee %

""" Commands

" View current syntax
command! Syn echo b:current_syntax

""" Autocommands

" Remove trailing whitespace on save
autocmd BufWritePre *[^.md] %s/\s\+$//e
