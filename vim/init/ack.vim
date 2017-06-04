" ag in ack.vim
if executable('ag')
  let g:ackprg = 'ag --nogroup --nocolor --column'
endif

""" Abbreviations
cnoreabbrev ack Ack!

