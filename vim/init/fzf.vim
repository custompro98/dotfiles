" Convenience for silve searcher
cnoreabbrev ag Ag

" [Buffers] Jump to the existing window if possible
let g:fzf_buffers_jump = 1

" Map ctrl-p to :Files for muscle memory's sake
nnoremap <C-p> :Files<Cr>

" Map ctrl-; to :Ag
nnoremap <C-p> :Files<Cr>

" Give :Files a preview window
command! -bang -nargs=? -complete=dir Files call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
