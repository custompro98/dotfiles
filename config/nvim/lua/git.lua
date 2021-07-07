local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Git ** --

require'vgit'.setup()

api.nvim_set_keymap('n', '<Leader>gb', ':VGit show_blame<CR>', {})
api.nvim_set_keymap('n', '<Leader>gd', ':VGit buffer_preview<CR>', {})
