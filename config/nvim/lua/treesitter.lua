local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Treesitter ** --
--
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = false,
    disable = {},
  },
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = { "BufWrite", "CursorHold" }
  },
  ensure_installed = 'maintained',
  autopairs = { enable = true }
}

local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
parser_config.tsx.used_by = { 'javascript', 'typescript.tsx' }

-- folding
opt.foldlevelstart = 99
opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
