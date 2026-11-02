-- ** Git ** --
local utils = require("custompro98.plugins.utils")

-- Adds git related signs to the gutter, as well as utilities for managing changes
vim.pack.add({ utils.gh("lewis6991/gitsigns.nvim") })
require("gitsigns").setup({
	signs = {
		add = { text = "+" }, ---@diagnostic disable-line: missing-fields
		change = { text = "~" }, ---@diagnostic disable-line: missing-fields
		delete = { text = "_" }, ---@diagnostic disable-line: missing-fields
		topdelete = { text = "‾" }, ---@diagnostic disable-line: missing-fields
		changedelete = { text = "~" }, ---@diagnostic disable-line: missing-fields
	},
})
vim.keymap.set("n", "<Leader>gb", "<cmd>Gitsigns blame<CR>", { desc = "[G]it [B]lame" })
vim.keymap.set("n", "<Leader>gn", "<cmd>Gitsigns next_hunk<CR>", { desc = "[G]it [N]ext hunk" })
vim.keymap.set("n", "<Leader>gp", "<cmd>Gitsigns prev_hunk<CR>", { desc = "[G]it [P]revious hunk" })
