local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Appearance ** --

-- Split directions
opt.splitright = true
opt.splitbelow = true

-- Remove jitter
opt.signcolumn = 'yes'

-- Theme

opt.termguicolors = true

require("catppuccin").setup({
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
    transparent_background = false,
    term_colors = false,
    dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.05,
    },
    styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
    },
    color_overrides = {},
    custom_highlights = {},
    integrations = {
        cmp = true,
        mason = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

vim.cmd.colorscheme 'catppuccin'

-- Statusline
require 'lualine'.setup {
	options = {
		icons_enabled = true,
		theme = 'auto',
		component_separators = { '', '' },
		section_separators = { '', '' },
		disabled_filetypes = {}
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'branch' },
		lualine_c = { { 'filename', path = 1 } },
		lualine_x = { 'encoding', 'filetype' },
		lualine_y = { 'progress' },
		lualine_z = { 'location' }
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { 'filename' },
		lualine_x = { 'location' },
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	extensions = {}
}

-- Zoom a split
api.nvim_set_keymap('n', '<Leader>-', ':wincmd _<CR>:wincmd |<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>=', ':wincmd =<CR>', { noremap = true })
