local tooling_by_ft = {
	blade = {
		form = { "blade-formatter", "pint" },
		lint = {},
	},
	lua = {
		form = { "stylua" },
		lint = {},
	},
	php = {
		form = { "pint" },
		lint = { "phpstan" },
	},
	python = {
		form = { "ruff" },
		lint = { "ruff" },
	},
	ruby = {
		form = { "rubocop" },
		lint = { "rubocop" },
	},
	eruby = {
		form = { "erb-formatter" },
		lint = {},
	},
	typescript = {
		form = { "prettierd", "biome-check" },
		lint = {},
	},
}

function AllTools()
	local everything = {}

	for ft in pairs(tooling_by_ft) do
		for tool in pairs(tooling_by_ft[ft]) do
			for _, member in ipairs(tooling_by_ft[ft][tool]) do
				if type(member) == "table" then
					for _, submember in ipairs(member) do
						table.insert(everything, submember)
					end
				else
					if member == "biome-check" then
						table.insert(everything, "biome")
					else
						table.insert(everything, member)
					end
				end
			end
		end
	end

	return everything
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "j-hui/fidget.nvim", opts = {} },
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			dependencies = {
				"mason-org/mason.nvim",
			},
			opts = {
				ensure_installed = AllTools(),
			},
		},
		{
			"mfussenegger/nvim-lint",
			config = function()
				local lint = require("lint")

				lint.linters_by_ft = {
					typescript = tooling_by_ft["typescript"].lint,
					typescriptreact = tooling_by_ft["typescript"].lint,
					javascript = tooling_by_ft["typescript"].lint,
					javascriptreact = tooling_by_ft["typescript"].lint,
					php = tooling_by_ft["php"].lint,
					python = tooling_by_ft["python"].lint,
					ruby = tooling_by_ft["ruby"].lint,
				}

				vim.api.nvim_create_autocmd({ "BufWritePost" }, {
					callback = function()
						lint.try_lint()
					end,
				})
			end,
		},
		{
			"stevearc/conform.nvim",
			config = function()
				local formatters = {
					prettierd = {
						require_cwd = true,
						cwd = require("conform.util").root_file({ ".prettierrc", ".prettierrc.json", ".prettierrc.js" }),
					},
				}

				-- biome-check has a `-` in the name and so cannot be used as a table key.
				-- this more general syntax will allow the `-` to be used in the table key.
				formatters["biome-check"] = {
					require_cwd = true,
					cwd = require("conform.util").root_file({ "biome.json" }),
				}

				require("conform").setup({
					formatters = formatters,
					formatters_by_ft = {
						astro = tooling_by_ft["typescript"].form,
						blade = tooling_by_ft["blade"].form,
						lua = tooling_by_ft["lua"].form,
						typescript = tooling_by_ft["typescript"].form,
						typescriptreact = tooling_by_ft["typescript"].form,
						javascript = tooling_by_ft["typescript"].form,
						javascriptreact = tooling_by_ft["typescript"].form,
						json = tooling_by_ft["typescript"].form,
						json5 = tooling_by_ft["typescript"].form,
						php = tooling_by_ft["php"].form,
						python = tooling_by_ft["python"].form,
						ruby = tooling_by_ft["ruby"].form,
						eruby = { "erb_format" },
					},
					format_on_save = {
						timeout_ms = 500,
						lsp_fallback = false,
					},
				})
			end,
		},
	},
	config = function()
		local servers = {
			astro = {
				format = false,
			},
			biome = {
				format = false,
			},
			buf_ls = {
				format = true,
			},
			cssls = {
				format = true,
			},
			denols = {
				format = true,
				root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
			},
			eslint = {
				format = false,
			},
			gh_actions_ls = {
				format = false,
			},
			gopls = {
				format = true,
			},
			html = {
				format = true,
			},
			htmx = {
				format = false,
			},
			intelephense = {
				format = false,
				filetypes = { "blade", "php" },
			},
			lua_ls = {
				format = false,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			},
			prismals = {
				single_file_support = false,
				root_dir = require("lspconfig.util").root_pattern("schema.prisma"),
				filetypes = {
					"prisma",
				},
			},
			pyright = {
				format = false,
			},
			ruff = {
				format = true,
			},
			rust_analyzer = {
				format = true,
			},
			tailwindcss = {
				settings = {
					tailwindCSS = {
						experimental = {
							classRegex = {
								[[class= "([^"]*)]],
								[[class: "([^"]*)]],
								[[class\("([^"]*)"\)]],
							},
						},
					},
				},
			},
			templ = {
				format = true,
			},
			ts_ls = {
				format = false,
				single_file_support = false,
				root_dir = require("lspconfig.util").root_pattern("package.json"),
				filetypes = {
					"typescript",
					"typescriptreact",
					"javascript",
					"javascriptreact",
					"json",
					"json5",
				},
			},
			zls = {
				format = false,
			},
		}

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = vim.tbl_keys(servers),
			automatic_enable = false,
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

		local on_attach = function(client, bufnr)
			local bufopts = { noremap = true, silent = true, buffer = bufnr }

			vim.diagnostic.config({ virtual_text = true })

			-- mapping
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
			vim.keymap.set("n", "gh", vim.lsp.buf.hover, bufopts)
			vim.keymap.set("i", "<Leader>gh", vim.lsp.buf.signature_help, bufopts)
			vim.keymap.set("n", "<Leader>D", vim.lsp.buf.type_definition, bufopts)
			vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, bufopts)
			vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, bufopts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)

			if client.name == "gleam" or servers[client.name].format then
				vim.keymap.set("n", "<Leader>f", vim.lsp.buf.format, bufopts)

				vim.api.nvim_create_autocmd({ "BufWritePost" }, {
					callback = function()
						vim.lsp.buf.format()
					end,
				})
			else
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false

				vim.keymap.set("n", "<Leader>f", function()
					require("conform").format({
						timeout_ms = 500,
						bufnr = bufnr,
					})
				end, bufopts)
			end

			vim.keymap.set("n", "<Leader>;", function()
				vim.diagnostic.open_float(nil, { focus = false })
			end, bufopts)

			vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, bufopts)
			vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, bufopts)
		end

		for server_name in pairs(servers) do
			require("lspconfig")[server_name].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = (servers[server_name] or {}).settings,
				filetypes = (servers[server_name] or {}).filetypes,
				single_file_support = (servers[server_name] or {}).single_file_support,
				root_dir = (servers[server_name] or {}).root_dir,
				on_init = (servers[server_name] or {}).on_init,
				init_options = (servers[server_name] or {}).init_options,
			})
		end

		require("lspconfig").gleam.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
	end,
}
