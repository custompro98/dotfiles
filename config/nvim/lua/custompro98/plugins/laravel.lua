return {
	"adalessa/laravel.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"tpope/vim-dotenv",
		"MunifTanjim/nui.nvim",
		"kevinhwang91/promise-async",
	},
	cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
	keys = {
		{ "<leader>la", ":Laravel artisan<cr>" },
		{ "<leader>lr", ":Laravel routes<cr>" },
		{ "<leader>lm", ":Laravel related<cr>" },
	},
	event = { "VeryLazy" },
	config = function()
		require("laravel").setup({
			lsp_server = "intelephense",
			register_user_commands = true,
			features = {
				null_ls = {
					enable = false,
				},
				route_info = {
					enable = true,
					position = "right",
				},
			},
			ui = require("laravel.options.ui"),
			commands_options = require("laravel.options.command_options"),
			environments = require("laravel.options.environments"),
			user_commands = require("laravel.options.user_commands"),
			resources = require("laravel.options.resources"),
		})
	end,
}
