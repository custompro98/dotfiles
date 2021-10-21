local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn

-- ensure that packer is installed
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

vim.cmd('packadd packer.nvim')

local packer = require'packer'
local util = require'packer.util'

packer.init({
  package_root = util.join_paths(fn.stdpath('data'), 'site', 'pack')
})

-- startup and configure plugins
return packer.startup(function(use)
  -- let packer manage itself
  use 'wbthomason/packer.nvim'

  -- lsp
  use 'neovim/nvim-lspconfig'
  use 'glepnir/lspsaga.nvim'
  use 'kabouzeid/nvim-lspinstall'
  use 'hrsh7th/nvim-compe'

  use 'scalameta/nvim-metals'

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/playground'

  -- development
  use 'b3nj5m1n/kommentary'
  use 'windwp/nvim-autopairs'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'aserowy/tmux.nvim'
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
  }
  use 'custompro98/listify.nvim'

  -- searching
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{ 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' }}
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- appearance
  use 'kyazdani42/nvim-web-devicons'
  use {
    'npxbr/gruvbox.nvim',
    requires = { 'rktjmp/lush.nvim' }
  }
  use 'hoob3rt/lualine.nvim'
end)
