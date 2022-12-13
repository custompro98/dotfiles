local vim = vim

-- ** Convenience Mappings ** --

-- easy escape
vim.keymap.set("i", "jk", "<Esc>", { remap = true })
vim.keymap.set("t", "jk", "<Esc>", { remap = true })

-- toggle highlight search
vim.keymap.set("n", "<Leader>h", ":set hlsearch<CR>", {})
vim.keymap.set("n", "<Leader>H", ":set nohlsearch<CR>", {})

-- resource config
vim.keymap.set("n", "<Leader>r", ":source ~/.config/nvim/init.lua<CR>", {})

-- ** Abbreviations ** --
vim.cmd("cabbrev tn tabnew")
vim.cmd("cabbrev sw w !sudo tee %")

-- ** Autocommands ** --
-- remove trailing whitespace on save
local autrail = vim.api.nvim_create_augroup("custompro98-autormtrail", {})
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = autrail,
  pattern = "*[^.md]",
  command = "%s/\\s\\+$//e",
})
