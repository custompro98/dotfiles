-- ** Mark ** --
local utils = require("custompro98.plugins.utils")

vim.pack.add({ utils.gh("roerohan/mark.nvim") })

require("mark").setup({
	split_position = "right",
	split_size = 50,
	theme = "GitHub Dark",
})
