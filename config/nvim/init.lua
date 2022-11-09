-- leader
vim.g.mapleader = ';'

-- set runtime
local override_path = "~/.config/nvim/override/after"
vim.opt.runtimepath:append(override_path)

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
require('_telescope')
require('treesitter')
require('debugging') -- has to be after telescope
