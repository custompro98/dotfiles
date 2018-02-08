" ag in ack.vim
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

""" Abbreviations
cnoreabbrev ack Ack!

