" All things wrapping text manipulation

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
