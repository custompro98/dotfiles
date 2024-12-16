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
