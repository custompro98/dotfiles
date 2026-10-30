-- ** Herdr ** --
local utils = require("custompro98.plugins.utils")

vim.pack.add({ utils.gh("ChmaraX/herdr-nvim") })

require("herdr-nvim").setup({
	prefix = "<leader>a",
	keymaps = true,
	clear_after_send = true,
})
