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

-- TODO: this is for using nvim-tree. sad. issue #549
opt.shell = "/bin/bash"
