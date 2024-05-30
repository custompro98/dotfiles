return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- LSP Autocomplete
			"hrsh7th/cmp-nvim-lsp",

			-- Snippet Autocomplete
			{
				"saadparwaiz1/cmp_luasnip",
				dependencies = {
					"L3MON4D3/LuaSnip",
					"rafamadriz/friendly-snippets",
				},
			},

			-- Generic Autocomplete
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
			"custompro98/cmp-kitty",
			{
				"supermaven-inc/supermaven-nvim",
				config = function()
					require("supermaven-nvim").setup({
						keymaps = {
							accept_suggestion = "<C-f>",
							clear_suggestion = "<C-]>",
							accept_word = "<C-g>",
						},
						ignore_filetypes = {},
						color = {
							suggestion_color = "#ffffff",
							cterm = 244,
						},
						disable_inline_completion = false, -- disables inline completion for use with cmp
						disable_keymaps = false, -- disables built in keymaps for more manual control
					})
				end,
			},
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end),
					["<C-p>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete({}),
				}),
				sources = {
					{ name = "kity" },
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},
}
