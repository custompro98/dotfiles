-- ** Quickfix ** --

-- quickfix navigation
vim.keymap.set("n", "<Leader>co", "<cmd>copen<CR>", { desc = "Quickfix [O]pen" })
vim.keymap.set("n", "<Leader>cc", "<cmd>cclose<CR>", { desc = "Quickfix [C]lose" })
vim.keymap.set("n", "<Leader>cn", "<cmd>cnext<CR>", { desc = "Quickfix [N]ext item" })
vim.keymap.set("n", "<Leader>cp", "<cmd>cprev<CR>", { desc = "Quickfix [P]revious item" })
vim.keymap.set("n", "<Leader>cx", "<cmd>cexpr[]<CR>", { desc = "Quickfix clear (e[X]punge)" })
