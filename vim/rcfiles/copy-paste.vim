" Integrate the clipboard with Vim more naturally

""" Keybindings

nnoremap <Leader>v :Paste<CR>
vnoremap <Leader>c "+y

""" Commands

command! Paste :call SmartPaste()

""" Functions

function! SmartPaste()
  setl paste
  normal "+p
  setl nopaste
endfunction

