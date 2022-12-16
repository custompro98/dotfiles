local vim = vim
local execute = vim.api.nvim_command
local fn = vim.fn

-- ensure that packer is installed
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
  execute "packadd packer.nvim"
end

vim.cmd("packadd packer.nvim")

local packer = require "packer"
local util = require "packer.util"

packer.init({
  package_root = util.join_paths(fn.stdpath("data"), "site", "pack")
})

-- startup and configure plugins
return packer.startup(function(use)
  -- let packer manage itself
  use "wbthomason/packer.nvim"

  -- lsp
  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-path'},
      {'hrsh7th/cmp-nvim-lua'},
      {'custompro98/cmp-kitty'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    }
  }

  -- treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate"
  }
  use "nvim-treesitter/playground"

  -- development
  -- debugging
  use {
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
    "nvim-telescope/telescope-dap.nvim",
  }

  -- formatting
  use "b3nj5m1n/kommentary"
  use "windwp/nvim-autopairs"
  use "windwp/nvim-ts-autotag"
  use "tpope/vim-surround"
  use "custompro98/listify.nvim"

  -- tooling
  use "tpope/vim-fugitive"
  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
  }
  -- language
  use "fladson/vim-kitty"

  -- navigation
  use {
    "kyazdani42/nvim-tree.lua",
    requires = "kyazdani42/nvim-web-devicons",
  }
  use { "knubie/vim-kitty-navigator",
    run = "cp ./*.py ~/.config/kitty",
  }
  use {
    "ThePrimeagen/harpoon",
    requires = {
      "nvim-lua/plenary.nvim",
    }
  }

  -- searching
  use {
    "nvim-telescope/telescope.nvim",
    requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } }
  }
  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }

  -- appearance
  use "catppuccin/nvim"
  use "hoob3rt/lualine.nvim"

  -- hack
  use "antoinemadec/FixCursorHold.nvim" -- resolves https://github.com/neovim/neovim/issues/12587
end)
