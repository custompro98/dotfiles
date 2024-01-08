-- ** Init ** --

-- leader
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- non-plugin configuration
require("custompro98.appearance")
require("custompro98.convenience")
require("custompro98.copy-paste")
require("custompro98.general")
require("custompro98.quickfix")
require("custompro98.terminal")

-- set company overrides
local override_path = "~/.config/nvim/override/after"
vim.opt.runtimepath:append(override_path)

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("custompro98.plugins")

require("custompro98.lsp")
