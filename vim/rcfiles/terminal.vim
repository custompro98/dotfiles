" Wrappers around neovim's terminal mode

""" Keybindings

nnoremap <Leader>t :Sterm<CR>

""" Commands

" Open terminal in splits
command! Vterm :call OpenWindow('botright', winwidth(0)/3, 'vsplit|terminal')
command! Sterm :call OpenWindow('botright', winheight(0)/5, 'split|terminal')
