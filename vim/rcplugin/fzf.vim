" Way better project searching

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

""" Configuration

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

""" Abbreviations

cnoreabbrev ag Ag
cnoreabbrev gst GFiles?

""" Keybindings

" Map ctrl-p to :Files for muscle memory's sake
nnoremap <C-p> :Files<Cr>
" Map ctrl-; to :Ag
nnoremap <C-i> :Ag<Cr>

""" Commands

" Give :Files and :Ag a preview window
command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=? -complete=dir Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview(), <bang>0)
