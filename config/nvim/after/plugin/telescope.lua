local vim = vim

local actions = require("telescope.actions")
local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")

telescope.setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    },
    live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      -- define mappings, e.g.
      mappings = { -- extend mappings
        i = {
          ["<C-k>"] = lga_actions.quote_prompt(),
          ["<C-j>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
          ["<C-l>"] = lga_actions.quote_prompt({ postfix = " -t " }),
        },
      },
    },
  },
  defaults = {
    mappings = {
      i = {
        ["<Leader>q"] = actions.send_selected_to_qflist + actions.open_qflist,
      },
      n = {
        ["<Leader>q"] = actions.send_selected_to_qflist + actions.open_qflist,
      },
    },
  },
}
telescope.load_extension("fzf")
telescope.load_extension("live_grep_args")

function TelescopeDotfiles()
  require("telescope.builtin").git_files {
    cwd = "~/.dotfiles/",
  }
end

vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope find_files<CR>", {})
vim.keymap.set("n", "<Leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", {})
vim.keymap.set("n", "<Leader>fr", "<cmd>Telescope lsp_references<CR>", {})
vim.keymap.set("n", "<Leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", {})
vim.keymap.set("n", "<Leader>fh", "<cmd>Telescope help_tags<CR>", {})
vim.keymap.set("n", "<Leader>fd", "<cmd>lua TelescopeDotfiles()<CR>", {})
vim.keymap.set("n", "<Leader>fm", "<cmd>Telescope man_pages<CR>", {})
vim.keymap.set("n", "<Leader>fb", "<cmd>Telescope buffers<CR>", {})

require("telescope").load_extension("dap")
