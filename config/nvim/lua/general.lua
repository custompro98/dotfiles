local vim = vim
local opt = vim.opt
local api = vim.api

-- ** General Configuration ** --

-- spaces not tabs
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

-- line numbers
opt.number = true
opt.relativenumber = true

-- formatting hints
vim.wo.colorcolumn = "80"

-- nowrap
vim.wo.wrap = false
