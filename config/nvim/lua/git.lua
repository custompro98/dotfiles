local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Git ** --

api.nvim_set_keymap('n', '<Leader>gb', ':Git blame<CR>', {})
api.nvim_set_keymap('n', '<Leader>gd', ':Git diff %<CR>', {})
