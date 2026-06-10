-- ** Init ** --

vim.loader.enable()

vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

vim.g.have_nerd_font = true

-- non-plugin configuration
require("custompro98_v2.appearance")
require("custompro98_v2.convenience")
require("custompro98_v2.copy-paste")
require("custompro98_v2.general")
require("custompro98_v2.navigation")
require("custompro98_v2.quickfix")
require("custompro98_v2.terminal")

-- plugin configuration
require("custompro98_v2.plugins")

-- set company overrides (if applicable)
local override_path = "~/.config/nvim/override/after"
vim.opt.runtimepath:append(override_path)
