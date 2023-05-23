local vim = vim
local opt = vim.opt

-- ** General Configuration ** --

-- spaces not tabs
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

-- line numbers
opt.number = true
opt.relativenumber = true

-- formatting hints
vim.wo.colorcolumn = "100"

-- nowrap
vim.wo.wrap = false

-- no mouse mode
vim.opt.mouse = ""

--[[ local autsc = vim.api.nvim_create_augroup("custompro98-tsc", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = autsc,
  pattern = {"typescript", "typescriptreact" },
  command = "compiler tsc | setlocal makeprg=npx\\ tsc\\ --noEmit"
}) ]]
