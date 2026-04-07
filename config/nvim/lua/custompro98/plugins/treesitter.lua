return {
	{
		{
			"nvim-treesitter/nvim-treesitter",
			dependencies = {
				"nvim-treesitter/nvim-treesitter-textobjects",
				{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
				"windwp/nvim-ts-autotag",
				"EmranMR/tree-sitter-blade", -- enable custom treesitter highlighting for blade
			},
			build = ":TSUpdate",
			config = function()
				require("nvim-treesitter.configs").setup({
					highlight = {
						enable = true,
						disable = {},
					},
					indent = {
						enable = false,
						disable = {},
					},
					ensure_installed = "all",
					ignore_install = { "phpdoc", "haskell" },
					textobjects = {
						select = {
							enable = true,

							-- Automatically jump forward to textobj, similar to targets.vim
							lookahead = true,

							keymaps = { -- You can use the capture groups defined in textobjects.scm
								["af"] = "@function.outer",
								["if"] = "@function.inner",
								["ac"] = "@class.outer",
								["ic"] = "@class.inner",
								["aP"] = "@parameter.outer",
								["iP"] = "@parameter.inner",
							},
						},
					},
				})

				-- nvim-ts-autotag requires its own setup call (no longer configured via treesitter)
				require("nvim-ts-autotag").setup()

				-- register tsx parser for additional filetypes
				vim.treesitter.language.register("tsx", { "javascript", "typescript.tsx" })

				-- blade custom parser (not yet natively available in nvim-treesitter)
				local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
				parser_config.blade = {
					install_info = {
						url = "https://github.com/EmranMR/tree-sitter-blade.git",
						files = { "src/parser.c" },
						branch = "main",
					},
					filetype = "blade",
				}

				vim.opt.foldmethod = "expr"
				vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.opt.foldenable = false
			end,
		},
	},
}
