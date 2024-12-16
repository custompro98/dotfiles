-- ** General ** --

-- spaces not tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- formatting hints
vim.wo.colorcolumn = "100"

-- nowrap
vim.wo.wrap = false

-- no mouse mode
vim.opt.mouse = ""

-- save undo history
vim.o.undofile = true

-- local autsc = vim.api.nvim_create_augroup("custompro98-tsc", { clear = true })
-- vim.api.nvim_create_autocmd({ "FileType" }, {
-- 	group = autsc,
-- 	pattern = { "typescript", "typescriptreact" },
-- 	command = "compiler tsc | setlocal makeprg=npx\\ tsc\\ --noEmit",
-- })
