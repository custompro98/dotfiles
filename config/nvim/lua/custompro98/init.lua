local vim = vim
local opt = vim.opt

-- ** Init ** --

-- leader
vim.g.mapleader = ";"

-- set runtime
local override_path = "~/.config/nvim/override/after"
opt.runtimepath:append(override_path)

require("custompro98.plugins")

require("custompro98.appearance")
require("custompro98.convenience")
require("custompro98.copy-paste")
require("custompro98.general")
require("custompro98.quickfix")
require("custompro98.terminal")
