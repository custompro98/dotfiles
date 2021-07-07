local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Appearance ** --

-- Split directions
opt.splitright = true
opt.splitbelow = true

-- Theme

opt.termguicolors = true
opt.background = 'dark'
vim.cmd([[colorscheme gruvbox]])

-- Statusline
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

-- Zoom a split
api.nvim_set_keymap('n', '<Leader>-', ':wincmd _<CR>:wincmd |<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>=', ':wincmd =<CR>', { noremap = true })
