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

require('kommentary.config').configure_language('lua', {
    prefer_single_line_comments = true,
})

require('kommentary.config').configure_language('php', {
    prefer_single_line_comments = true,
})

-- local loc_section = require('curloc-sidebar-nvim')

require("sidebar-nvim").setup({
  open = false,
  -- sections = { "datetime", "git-status", "lsp-diagnostics", loc_section },
  sections = { "datetime", "git" },
  datetime = {
    format = "%a %b %d, %l:%M %p",
    clocks = {
      { name = "eastern" },
      { name = "pacific", offset = -3 },
      { name = "ukraine", offset = 7 },
      { name = "india", offset = 9.5 },
      { name = "utc", offset = 5 },
    }
  },
  disable_closing_prompt = true
})

api.nvim_set_keymap('n', '<Leader>\\', '<cmd>SidebarNvimToggle<CR>', { noremap = true })
