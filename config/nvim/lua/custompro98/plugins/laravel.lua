return {
	"adalessa/laravel.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"tpope/vim-dotenv",
		"MunifTanjim/nui.nvim",
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
			ui = require("laravel.config.ui"),
			commands_options = require("laravel.config.command_options"),
			environments = require("laravel.config.environments"),
			user_commands = require("laravel.config.user_commands"),
			resources = require("laravel.config.resources"),
		})
	end,
}
