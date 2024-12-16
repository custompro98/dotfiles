-- ** Terminal ** --

-- enter terminal mode
vim.keymap.set("n", "<Leader>t", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("L")
	vim.api.nvim_win_set_width(0, 120)
	-- vim.api.nvim_open_term(0, { force_crlf = true })
end, { noremap = true })

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custompro98-termopen", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
		vim.cmd.startinsert()
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
