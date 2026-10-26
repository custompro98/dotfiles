-- ** mini.nvim ** --
local utils = require("custompro98.plugins.utils")

--  A collection of various small independent plugins/modules
vim.pack.add({
	-- must be added before mini so mini.ai can use specs
	utils.gh("nvim-treesitter/nvim-treesitter-textobjects"),
	utils.gh("nvim-mini/mini.nvim"),
})

-- ** Text Editing ** --

-- Autopairs
require("mini.pairs").setup()

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
local spec_treesitter = require("mini.ai").gen_spec.treesitter
require("mini.ai").setup({
	n_lines = 500,
	custom_textobjects = {
		F = spec_treesitter({
			a = "@function.outer",
			i = "@function.inner",
		}),
		o = spec_treesitter({
			a = { "@conditional.outer", "@loop.outer" },
			i = { "@conditional.inner", "@loop.inner" },
		}),
	},
})

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- Uses vim-surround style mappings, see `:help MiniSurround-vim-surround-config`
--
-- - ysiw) - [Y]ou [S]urround [I]nner [W]ord [)]Paren
-- - ds'   - [D]elete [S]urrounding [']quotes
-- - cs)'  - [C]hange [S]urrounding [)] to [']
-- - dsn)  - [D]elete [S]urrounding [N]ext [)] (`l` for last)
require("mini.surround").setup({
	n_lines = 500,
	mappings = {
		add = "ys",
		delete = "ds",
		find = "",
		find_left = "",
		highlight = "",
		replace = "cs",
		update_n_lines = "",
	},
	search_method = "cover_or_next",
})

-- Surround the visual selection with `S`, and the whole line with `yss`
vim.keymap.del("x", "ys")
vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
vim.keymap.set("n", "yss", "ys_", { remap = true })

-- Commenting
require("mini.comment").setup()

-- Trailing whitespace
require("mini.trailspace").setup()

-- ** Workflow ** --

-- Show next-key clues after a trigger key, see `:help MiniClue-examples`
local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},
	clues = {
		{ mode = "n", keys = "<Leader>c", desc = "+Code/Quickfix" },
		{ mode = "n", keys = "<Leader>d", desc = "+Debug" },
		{ mode = "n", keys = "<Leader>f", desc = "+Find" },
		{ mode = "n", keys = "<Leader>g", desc = "+Git/LSP" },
		{ mode = "n", keys = "<Leader>t", desc = "+Toggle/Terminal" },
		{ mode = "n", keys = "<Leader>y", desc = "+Yarn" },
		miniclue.gen_clues.square_brackets(),
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},
	window = {
		delay = 300,
	},
})

-- ** Appearance ** --

-- Simple and easy statusline.
--  You could remove this setup call if you don't like it,
--  and try some other statusline plugin
local statusline = require("mini.statusline")
-- Set `use_icons` to true if you have a Nerd Font
statusline.setup({ use_icons = vim.g.have_nerd_font })

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
	return "%2l:%-2v"
end
