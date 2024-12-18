local terminal = require("custompro98.terminal")

local function get_term_id()
	if not terminal.termid then
		terminal.Terminal()
		terminal = require("custompro98.terminal")
	end

	return terminal.termid
end

vim.keymap.set("n", "<leader>yb", function()
	vim.fn.chansend(get_term_id(), "yarn build\n")
end, { remap = true })

vim.keymap.set("n", "<leader>yw", function()
	vim.fn.chansend(get_term_id(), "yarn watch\n")
end, { remap = true })

vim.keymap.set("n", "<leader>yt", function()
	vim.fn.chansend(get_term_id(), "yarn test\n")
end, { remap = true })

vim.keymap.set("n", "<leader>ytw", function()
	vim.fn.chansend(get_term_id(), "yarn test:watch\n")
end, { remap = true })
