local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn

-- ensure that packer is installed
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
  execute 'packadd packer.nvim'
end

vim.cmd('packadd packer.nvim')

local packer = require 'packer'
local util = require 'packer.util'

packer.init({
  package_root = util.join_paths(fn.stdpath('data'), 'site', 'pack')
})

-- startup and configure plugins
return packer.startup(function(use)
  -- let packer manage itself
  use 'wbthomason/packer.nvim'

  -- lsp
  use {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
  }

  -- autocomplete
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'custompro98/cmp-kitty'

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/playground'

  -- development
  -- debugging
  use {
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
    'nvim-telescope/telescope-dap.nvim',
  }

  -- formatting
  use 'b3nj5m1n/kommentary'
  use 'windwp/nvim-autopairs'
  use 'windwp/nvim-ts-autotag'
  use 'tpope/vim-surround'
  use 'custompro98/listify.nvim'

  -- tooling
  use 'tpope/vim-fugitive'
  use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
    },
  }
  use {
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  }

  -- language
  use 'fladson/vim-kitty'

  -- navigation
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
  }
  use { 'knubie/vim-kitty-navigator',
    run = 'cp ./*.py ~/.config/kitty',
  }
  use 'chentoast/marks.nvim'
  use {
    'ThePrimeagen/harpoon',
    requires = {
      'nvim-lua/plenary.nvim',
    }
  }

  -- searching
  use {
    'nvim-telescope/telescope.nvim',
    requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } }
  }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- appearance
  use 'kyazdani42/nvim-web-devicons'
  use 'catppuccin/nvim'
  use 'hoob3rt/lualine.nvim'

  -- hack
  use 'antoinemadec/FixCursorHold.nvim' -- resolves https://github.com/neovim/neovim/issues/12587
end)
