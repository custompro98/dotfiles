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
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
require('telescope').load_extension('fzf')

api.nvim_set_keymap('n', '<Leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fr', '<cmd>Telescope lsp_references<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fs', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true })

-- split navigation
--[[ api.nvim_set_keymap('n', '<C-J>', '<C-W><C-J>', { noremap = true })
api.nvim_set_keymap('n', '<C-K>', '<C-W><C-K>', { noremap = true })
api.nvim_set_keymap('n', '<C-L>', '<C-W><C-L>', { noremap = true })
api.nvim_set_keymap('n', '<C-H>', '<C-W><C-H>', { noremap = true }) ]]

-- tmux integration
require("tmux").setup({
  navigation = {
    -- enables default keybindings (C-hjkl) for normal mode
    enable_default_keybindings = true,
    cycle_navigation = false,
  },
  resize = {
    -- enables default keybindings (A-hjkl) for normal mode
    enable_default_keybindings = true,
  }
})
