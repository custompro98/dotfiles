-- ** Convenience ** --

-- ** Mappings ** --
-- easy escape
vim.keymap.set("i", "jk", "<Esc>", { remap = true })
vim.keymap.set("t", "jk", "<Esc>", { remap = true })

-- toggle highlight search
vim.keymap.set("n", "<Leader>h", function()
	vim.opt.hlsearch = true
end, {})
vim.keymap.set("n", "<Leader>H", function()
	vim.opt.hlsearch = false
end, {})

-- resource config
vim.keymap.set("n", "<Leader>r", ":source ~/.config/nvim/init.lua<CR>", {})

-- ** Abbreviations ** --
vim.cmd("cabbrev tn tabnew")
vim.cmd("cabbrev sw w !sudo tee %")

-- ** Autocommands ** --
-- remove trailing whitespace on save
local autrail = vim.api.nvim_create_augroup("custompro98-autormtrail", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = autrail,
	pattern = "*[^.md]",
	command = "%s/\\s\\+$//e",
})
