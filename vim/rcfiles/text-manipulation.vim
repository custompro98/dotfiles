" All things wrapping text manipulation

""" Keybindings

" Move lines up/down with alt+j/alt+k
" On a Mac: alt+j => ∆
" On a Mac: alt+k => ˚
if g:uname == "Linux"
  nnoremap <A-j>  :m .+1<CR>==
  nnoremap <A-k> :m .-2<CR>==
  inoremap <A-j> <Esc>:m .+1<CR>==gi
  inoremap <A-k> <Esc>:m .-2<CR>==gi
  vnoremap <A-j> :m '>+1<CR>gv=gv
  vnoremap <A-k> :m '<-2<CR>gv=gv
endif

if g:uname == "Darwin"
  nnoremap ∆  :m .+1<CR>==
  nnoremap ˚ :m .-2<CR>==
  inoremap ∆ <Esc>:m .+1<CR>==gi
  inoremap ˚ <Esc>:m .-2<CR>==gi
  vnoremap ∆ :m '>+1<CR>gv=gv
  vnoremap ˚ :m '<-2<CR>gv=gv
endif

""" Commands
command! Collapse :call Collapse()
command! WrapLineInQuote :call WrapLineInQuote()
command! EndInComma :call EndInComma()
command! ToCSV :call ToCSV()

""" Functions
" Collapse entire file to a single line
function! Collapse()
  1,$join
endfunction

" Wrap the line in a single quote
function! WrapLineInQuote() range
  execute a:firstline . "," . a:lastline . "normal! I'\<esc>A'\<esc>"
endfunction

" End the current line in a comma
function! EndInComma() range
  execute a:firstline . "," . a:lastline . "normal! A,\<esc>"
endfunction

" Wrap up all lines to a single line
" Each individual line is single quoted
" Each indiviual line gets a comma at the end
" The end comma is removed
function! ToCSV() range abort
  %call WrapLineInQuote()
  %call EndInComma()
  call Collapse()
  execute "normal! $x"
endfunction
