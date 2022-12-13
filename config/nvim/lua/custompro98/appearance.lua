local vim = vim
local opt = vim.opt

-- ** Appearance ** --

-- Split directions
opt.splitright = true
opt.splitbelow = true

-- Remove jitter
opt.signcolumn = "yes"

-- Theme compatibility
opt.termguicolors = true

-- Zoom a split
vim.keymap.set("n", "<Leader>-", ":wincmd _<CR>:wincmd |<CR>", {})
vim.keymap.set("n", "<Leader>=", ":wincmd =<CR>", {})
