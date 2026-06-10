-- ** Todo Comment ** --
local utils = require("custompro98_v2.plugins.utils")

-- Highlight todo, notes, etc in comments
vim.pack.add({ utils.gh("folke/todo-comments.nvim") })
require("todo-comments").setup({ signs = false })
