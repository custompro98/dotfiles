-- ** Highlight ** --

-- toggle highlight search
vim.keymap.set("n", "<Leader>h", function()
	if vim.opt.hlsearch == true then
		vim.opt.hlsearch = false
	else
		vim.opt.hlsearch = true
	end
end, { desc = "Toggle highlight search" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
