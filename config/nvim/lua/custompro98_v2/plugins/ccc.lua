-- ** CCC ** --
local utils = require("custompro98_v2.plugins.utils")

-- Color highlighting
vim.pack.add({ utils.gh("uga-rosa/ccc.nvim") })
require("ccc").setup({
	highlighter = {
		auto_enable = true,
	},
	lsp = true,
})
