local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Treesitter ** --
api.nvim_exec([[
  augroup treesitter_folds
  autocmd!
  autocmd BufEnter * norm! zx
  augroup end
]], false)

require('nvim-treesitter.configs').setup {
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
  ensure_installed =  'all',
  ignore_install = { 'phpdoc', 'haskell' },
  autopairs = { enable = true }
}

local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
parser_config.tsx.filetype_to_parsername = { 'javascript', 'typescript.tsx' }

require('nvim-treesitter.configs').setup {
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aP"] = "@paramenter.outer",
        ["iP"] = "@paramenter.inner",
      },
    },
  },
}

-- folding
opt.foldlevelstart = 99
opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'
