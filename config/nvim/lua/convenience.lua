local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Convenience Mappings ** --

-- easy escape
api.nvim_set_keymap('i', 'jk', '<Esc>', {})
api.nvim_set_keymap('t', 'jk', '<Esc>', {})

-- toggle highlight search
api.nvim_set_keymap('n', '<Leader>h', ':set hlsearch<CR>', { noremap = true})
api.nvim_set_keymap('n', '<Leader>H', ':set nohlsearch<CR>', { noremap = true})

-- resource config
api.nvim_set_keymap('n', '<Leader>r', ':source ~/.config/nvim/init.lua<CR>', { noremap = true })

-- ** Abbreviations ** --

vim.cmd('cabbrev tn tabnew')
vim.cmd('cabbrev sw w !sudo tee %')

-- ** Autocommands ** --

-- remove trailing whitespace on save
vim.cmd('autocmd BufWritePre *[^.md] %s/\\s\\+$//e')
