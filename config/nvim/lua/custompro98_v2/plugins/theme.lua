-- ** Theme ** --
local utils = require("custompro98_v2.plugins.utils")

if vim.g.have_nerd_font then
	vim.pack.add({ utils.gh("nvim-tree/nvim-web-devicons") })
end

vim.pack.add({ utils.gh("maxmx03/dracula.nvim") })
---@diagnostic disable-next-line: missing-fields
require("dracula").setup({})

-- Load the colorscheme here.
vim.cmd.colorscheme("dracula")
