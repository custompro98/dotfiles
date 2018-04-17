let g:neoformat_try_formatprg = 1

augroup NeoformatAutoFormat
  autocmd!
  autocmd FileType javascript setlocal formatprg=prettier\
                                           \--stdin\
                                           \--print-width\ 120\
  autocmd BufWritePre *.js,*.jsx,*.json Neoformat
augroup END
