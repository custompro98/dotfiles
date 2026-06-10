-- ** indent ** --
local utils = require("custompro98_v2.plugins.utils")

vim.pack.add({ utils.gh("NMAC427/guess-indent.nvim") })
require("guess-indent").setup({})

vim.pack.add({ utils.gh("lukas-reineke/indent-blankline.nvim") })
require("ibl").setup({})
