local vim = vim
local api = vim.api

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
api.nvim_set_keymap('n', '<Leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true })
