let g:ale_linters = {
\   'ruby': ['rubocop'],
\   'javascript': ['eslint']
\}

let g:ale_fixers = {
\   'ruby': ['rubocop'],
\   'javascript': ['eslint']
\}

nnoremap <leader>f :ALEFix
