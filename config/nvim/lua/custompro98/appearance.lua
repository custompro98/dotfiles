-- ** Appearance ** --

-- Split directions
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Remove jitter
vim.opt.signcolumn = "yes"

-- Zoom a split
vim.keymap.set("n", "<Leader>-", ":wincmd _<CR>:wincmd |<CR>", {})
vim.keymap.set("n", "<Leader>=", ":wincmd =<CR>", {})
