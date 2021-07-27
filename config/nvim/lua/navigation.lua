local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Navigation ** --

-- file explorer (just use netrw, everything else stinks)
vim.cmd([[
  let g:netrw_banner = 0
  let g:netrw_liststyle = 3
  let g:netrw_winsize = 25
]])
api.nvim_set_keymap('n', '<C-\\>', ':Explore<CR>', {})

-- searching
require('fzf').default_window_options = {
  window_on_create = function()
    vim.cmd('set winhl=Normal:Normal')
  end
}

--[[ api.nvim_set_keymap('n', '<Leader>p', '<cmd>lua require"fzf-commands".files()<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>o', '<cmd>lua require"fzf-commands".rg()<CR>', { noremap = true }) ]]

api.nvim_set_keymap('n', '<Leader>ff', '<cmd>lua require"telescope.builtin".find_files()<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fg', '<cmd>lua require"fzf-commands".rg()<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fr', '<cmd>lua require"telescope.builtin".lsp_references()<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fs', '<cmd>lua require"telescope.builtin".lsp_document_symbols()<CR>', { noremap = true })

-- split navigation
api.nvim_set_keymap('n', '<C-J>', '<C-W><C-J>', { noremap = true })
api.nvim_set_keymap('n', '<C-K>', '<C-W><C-K>', { noremap = true })
api.nvim_set_keymap('n', '<C-L>', '<C-W><C-L>', { noremap = true })
api.nvim_set_keymap('n', '<C-H>', '<C-W><C-H>', { noremap = true })
