local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Navigation ** --

-- file explorer
api.nvim_set_keymap('n', '<C-\\>', ':NvimTreeToggle<CR>', { noremap = true })

-- searching
require('fzf').default_window_options = {
  window_on_create = function()
    vim.cmd('set winhl=Normal:Normal')
  end
}

api.nvim_set_keymap('n', '<C-p>', '<cmd>lua require"fzf-commands".files()<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Tab>', '<cmd>lua require"fzf-commands".rg()<CR>', { noremap = true })

-- split navigation
api.nvim_set_keymap('n', '<C-J>', '<C-W><C-J>', { noremap = true })
api.nvim_set_keymap('n', '<C-K>', '<C-W><C-K>', { noremap = true })
api.nvim_set_keymap('n', '<C-L>', '<C-W><C-L>', { noremap = true })
api.nvim_set_keymap('n', '<C-H>', '<C-W><C-H>', { noremap = true })
