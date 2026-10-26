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
vim.keymap.set("n", "<Leader>tt", M.Terminal, { noremap = true })

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custompro98-termopen", { clear = true }),
	callback = function()
		vim.wo.number = false
		vim.wo.relativenumber = false
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
--  use the builtin <C-\><C-n>, so <Esc> and `;` still reach programs running in the terminal

-- navigate from terminal
local function navigate(direction)
	vim.api.nvim_input("<C-\\><C-n>")
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
