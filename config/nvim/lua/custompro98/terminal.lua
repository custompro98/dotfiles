-- ** Terminal ** --

local M = {
	termid = nil,
}

M.Terminal = function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("L")
	vim.api.nvim_win_set_width(0, vim.o.columns / 2.5)
end

-- enter terminal mode
vim.keymap.set("n", "<Leader>t", M.Terminal, { noremap = true })

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custompro98-termopen", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
		vim.cmd.startinsert()

		M.termid = vim.bo.channel
	end,
})

vim.api.nvim_create_autocmd("TermClose", {
	group = vim.api.nvim_create_augroup("custompro98-termclose", { clear = true }),
	callback = function()
		M.termid = nil
	end,
})

-- leave terminal mode
vim.keymap.set("t", "<Leader>t", "<C-\\><C-n>", {})
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { remap = true })

-- navigate from terminal
local function navigate(direction)
	vim.api.nvim_input("<ESC>")
	vim.cmd.wincmd(direction)
end

vim.keymap.set("t", "<C-h>", function()
	navigate("h")
end, { remap = true })
vim.keymap.set("t", "<C-j>", function()
	navigate("j")
end, { remap = true })
vim.keymap.set("t", "<C-k>", function()
	navigate("k")
end, { remap = true })
vim.keymap.set("t", "<C-l>", function()
	navigate("l")
end, { remap = true })

return M
