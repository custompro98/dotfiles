-- ** Convenience ** --

-- ** Mappings ** --
-- easy escape
vim.keymap.set("i", "jk", "<Esc>", { desc = "Easier alternative to <Esc>" })

-- resource config
vim.keymap.set("n", "<Leader>r", ":source ~/.config/nvim/init.lua<CR>", {})

-- ** Abbreviations ** --
vim.cmd("cabbrev tn tabnew")
vim.cmd("cabbrev sw w !sudo tee %")
