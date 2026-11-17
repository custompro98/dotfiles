-- ** MdKite ** --
local utils = require("custompro98.plugins.utils")

vim.pack.add({
	utils.gh("selimacerbas/kitehost.nvim"),
	utils.gh("selimacerbas/mdkite.nvim"),
})

require("mdkite").setup({
	default_theme = "dark",
})
