-- leader
vim.g.mapleader = ';'

require('plugins')

require('_lsp')
require('appearance')
require('completion')
require('convenience')
require('copy-paste')
require('general')
require('git')
require('navigation')
require('terminal')
require('treesitter')

-- I can't convert this natively yet
vim.cmd('source ~/.config/nvim/lua/text-manipulation.vim')
