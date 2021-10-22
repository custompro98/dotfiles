local vim = vim
local opt = vim.opt
local api = vim.api

-- ** Navigation ** --

-- following options are the default
require'nvim-tree'.setup {
  -- disables netrw completely
  disable_netrw       = true,
  -- hijack netrw window on startup
  hijack_netrw        = true,
  -- open the tree when running this setup function
  open_on_setup       = false,
  -- will not open on setup if the filetype is in this list
  ignore_ft_on_setup  = {},
  -- closes neovim automatically when the tree is the last **WINDOW** in the view
  auto_close          = false,
  -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
  open_on_tab         = false,
  -- hijacks new directory buffers when they are opened.
  update_to_buf_dir   = {
    -- enable the feature
    enable = true,
    -- allow to open the tree if it was previously closed
    auto_open = true,
  },
  -- hijack the cursor in the tree to put it at the start of the filename
  hijack_cursor       = false,
  -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  update_cwd          = false,
  -- show lsp diagnostics in the signcolumn
  diagnostics = {
    enable = false,
    icons = {
      hint = "⁉️",
      info = "ℹ️",
      warning = "⚠️",
      error = "❌",
    }
  },
  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
  update_focused_file = {
    -- enables the feature
    enable      = false,
    -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    -- only relevant when `update_focused_file.enable` is true
    update_cwd  = false,
    -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
    -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
    ignore_list = {}
  },
  -- configuration options for the system open command (`s` in the tree by default)
  system_open = {
    -- the command to run this, leaving nil should work in most cases
    cmd  = nil,
    -- the command arguments as a list
    args = {}
  },

  view = {
    -- width of the window, can be either a number (columns) or a string in `%`, for left or right side placement
    width = 30,
    -- height of the window, can be either a number (columns) or a string in `%`, for top or bottom side placement
    height = 30,
    -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
    side = 'left',
    -- if true the tree will resize itself after opening a file
    auto_resize = false,
    mappings = {
      -- custom only false will merge the list with the default mappings
      -- if true, it will only use your list to set the mappings
      custom_only = false,
      -- list of mappings to set on the tree manually
      list = {}
    }
  }
}

api.nvim_set_keymap('n', '<C-\\>', '<cmd>NvimTreeToggle<CR>', { noremap = true })

-- searching
local telescope = require('telescope')
telescope.setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
telescope.load_extension('fzf')

function TelescopeDotfiles()
  require('telescope.builtin').git_files {
    cwd = '~/.dotfiles/',
  }
end

api.nvim_set_keymap('n', '<Leader>ff', '<cmd>Telescope git_files<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fr', '<cmd>Telescope lsp_references<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fs', '<cmd>Telescope lsp_document_symbols<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fd', '<cmd>lua TelescopeDotfiles()<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>fm', '<cmd>Telescope man_pages<CR>', { noremap = true })

-- split navigation
--[[ api.nvim_set_keymap('n', '<C-J>', '<C-W><C-J>', { noremap = true })
api.nvim_set_keymap('n', '<C-K>', '<C-W><C-K>', { noremap = true })
api.nvim_set_keymap('n', '<C-L>', '<C-W><C-L>', { noremap = true })
api.nvim_set_keymap('n', '<C-H>', '<C-W><C-H>', { noremap = true }) ]]

-- tmux integration
require("tmux").setup({
  navigation = {
    -- enables default keybindings (C-hjkl) for normal mode
    enable_default_keybindings = true,
    cycle_navigation = false,
  },
  resize = {
    -- enables default keybindings (A-hjkl) for normal mode
    enable_default_keybindings = true,
  }
})

-- marks navigation
require'marks'.setup {
  -- whether to map keybinds or not. default true
  default_mappings = true,
  -- which builtin marks to show. default {}
  builtin_marks = { ".", "<", ">", "^" },
  -- whether movements cycle back to the beginning/end of buffer. default true
  cyclic = true,
  -- whether the shada file is updated after modifying uppercase marks. default false
  force_write_shada = false,
  -- how often (in ms) to redraw signs/recompute mark positions.
  -- higher values will have better performance but may cause visual lag,
  -- while lower values may cause performance penalties. default 150.
  refresh_interval = 250,
  -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
  -- marks, and bookmarks.
  -- can be either a table with all/none of the keys, or a single number, in which case
  -- the priority applies to all marks.
  -- default 10.
  sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
  -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
  -- sign/virttext. Bookmarks can be used to group together positions and quickly move
  -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
  -- default virt_text is "".
  bookmark_0 = {
    sign = "⚑",
    virt_text = "hello world"
  },
  mappings = {}
}

-- quickfix navigation
api.nvim_set_keymap('n', '<Leader>co', '<cmd>copen<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>cc', '<cmd>cclose<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>cn', '<cmd>cnext<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>cp', '<cmd>cprev<CR>', { noremap = true })
