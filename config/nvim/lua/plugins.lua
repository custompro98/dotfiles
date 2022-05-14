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
  use 'williamboman/nvim-lsp-installer'

  -- autocomplete
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/cmp-emoji'
  -- use '~/Projects/vim/cmp-kitty'
  use 'custompro98/cmp-kitty'
  use { 'tzachar/cmp-tabnine',
    run = './install.sh'
  }

  use 'scalameta/nvim-metals'

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    branch = '0.5-compat'
  }
  use 'nvim-treesitter/playground'
  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = '0.5-compat'
  }


  -- development
  use 'b3nj5m1n/kommentary'
  use 'windwp/nvim-autopairs'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-surround'
  use 'aserowy/tmux.nvim'
  use { 'knubie/vim-kitty-navigator',
    run = 'cp ./*.py ~/.config/kitty',
  }
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
  }
  use 'custompro98/listify.nvim'
  use 'chentoast/marks.nvim'
  use {
    'sidebar-nvim/sidebar.nvim',
    branch = 'dev'
  }
  -- use '~/Projects/vim/sidebar.nvim'
  use 'custompro98/curloc-sidebar.nvim'
  use 'fladson/vim-kitty'

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
  use "projekt0n/github-nvim-theme"
  use 'hoob3rt/lualine.nvim'

  -- hack
  use 'antoinemadec/FixCursorHold.nvim' -- resolves https://github.com/neovim/neovim/issues/12587
end)
