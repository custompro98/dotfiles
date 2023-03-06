local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Treesitter ** --
local aufold = vim.api.nvim_create_augroup("custompro98-fold", {})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = aufold,
  pattern = "*",
  command = "norm! zx"
})

require("nvim-treesitter.configs").setup {
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
  ensure_installed =  "all",
  ignore_install = { "phpdoc", "haskell" },
  autopairs = { enable = true }
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }

require("nvim-treesitter.configs").setup {
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = { -- You can use the capture groups defined in textobjects.scm
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
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

-- TS Node Action
vim.keymap.set("n", "<Leader>ta", require("ts-node-action").node_action, { desc = "Trigger Node Action" })
