-- ** Telescope ** --
local utils = require("custompro98_v2.plugins.utils")

---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
	utils.gh("nvim-lua/plenary.nvim"),
	utils.gh("nvim-telescope/telescope.nvim"),
	utils.gh("nvim-telescope/telescope-live-grep-args.nvim"),
	utils.gh("nvim-telescope/telescope-ui-select.nvim"),
	utils.gh("nvim-treesitter/nvim-treesitter-textobjects"),
}

if vim.fn.executable("make") == 1 then
	table.insert(telescope_plugins, utils.gh("nvim-telescope/telescope-fzf-native.nvim"))
end

vim.pack.add(telescope_plugins)

-- See `:help telescope` and `:help telescope.setup()`
require("telescope").setup({
	-- You can put your default mappings / updates / etc. in here
	--  All the info you're looking for is in `:help telescope.setup()`
	--
	defaults = {
		mappings = {
			i = {
				["<Leader>q"] = require("telescope.actions").send_selected_to_qflist
					+ require("telescope.actions").open_qflist,
			},
			n = {
				["<Leader>q"] = require("telescope.actions").send_selected_to_qflist
					+ require("telescope.actions").open_qflist,
			},
		},
	},
	-- pickers = {}
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			over_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- "smart_case" or "ignore_case" or "respect_case"
		},
		live_grep_args = {
			auto_quoting = true,
			mappings = {
				i = {
					["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
					["<C-j>"] = require("telescope-live-grep-args.actions").quote_prompt({
						postfix = " --iglob ",
					}),
					["<C-l>"] = require("telescope-live-grep-args.actions").quote_prompt({
						postfix = " -t ",
					}),
				},
			},
		},
		["ui-select"] = { require("telescope.themes").get_dropdown() },
	},
})

-- Enable Telescope extensions if they are installed
pcall(require("telescope").load_extension("fzf"))
pcall(require("telescope").load_extension("live_grep_args"))
pcall(require("telescope").load_extension("ui-select"))

-- See `:help telescope.builtin`
local builtin = require("telescope.builtin")
local extension = require("telescope").extensions

vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
vim.keymap.set({ "n", "v" }, "<leader>fw", extension.live_grep_args.live_grep_args, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>fg", extension.live_grep_args.live_grep_args, { desc = "[F]ind by [G]rep" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
vim.keymap.set("n", "<leader>f.", builtin.resume, { desc = "[F]ind Resume (. for repeat)" })
vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "[F]ind [C]ommands" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind existing [B]uffers" })

-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
-- If you later switch picker plugins, this is where to update these mappings.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
	callback = function(event)
		local buf = event.buf

		-- Find references for the word under your cursor.
		vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { buffer = buf, desc = "[F]ind [R]eferences" })

		-- Jump to the implementation of the word under your cursor.
		-- Useful when your language has ways of declaring types without an actual implementation.
		vim.keymap.set("n", "gD", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })

		-- Jump to the definition of the word under your cursor.
		-- This is where a variable was first declared, or where a function is defined, etc.
		-- To jump back, press <C-t>.
		vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })

		-- Fuzzy find all the symbols in your current document.
		-- Symbols are things like variables, functions, types, etc.
		vim.keymap.set(
			"n",
			"<leader>fs",
			builtin.lsp_document_symbols,
			{ buffer = buf, desc = "[Find] Document [S]ymbols" }
		)

		-- Fuzzy find all the symbols in your current workspace.
		-- Similar to document symbols, except searches over your entire project.
		vim.keymap.set(
			"n",
			"fS",
			builtin.lsp_dynamic_workspace_symbols,
			{ buffer = buf, desc = "[F]ind Workspace [S]ymbols" }
		)

		-- Jump to the type of the word under your cursor.
		-- Useful when you're not sure what type a variable is and you want to see
		-- the definition of its *type*, not where it was *defined*.
		vim.keymap.set(
			"n",
			"<leader>ftd",
			builtin.lsp_type_definitions,
			{ buffer = buf, desc = "[Find [T]ype [D]efinition" }
		)
	end,
})

-- Override default behavior and theme when searching
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to Telescope to change the theme, layout, etc.
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set("n", "<leader>fg/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[F]ind with [G]rep [/] in Open Files" })

-- Shortcut for searching your dotfiles
vim.keymap.set("n", "<leader>fD", function()
	builtin.find_files({ cwd = "~/.dotfiles" })
end, { desc = "[F]earch [D]otfiles" })
