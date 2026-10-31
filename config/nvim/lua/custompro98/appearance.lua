-- ** Appearance ** --

-- Spacing
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Split directions
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Truecolor (not auto-detected in headless/--remote-ui nvim, e.g. herdr-nvim sidebar)
vim.o.termguicolors = true

-- Remove jitter
vim.opt.signcolumn = "yes"

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10
