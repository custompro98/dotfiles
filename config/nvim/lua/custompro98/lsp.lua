-- ** LSP ** --

local servers = {
	dockerls = {},
	gopls = {},
	lua_ls = {
		settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
	},
	terraformls = {},
	denols = {
		single_file_support = false,
		root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
	},
	tsserver = {
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
	graphql = {},
	tailwindcss = {
		root_dir = require("lspconfig.util").root_pattern(
			"tailwind.config.js",
			"tailwind.config.ts",
			"twind.config.ts"
		),
	},
	bufls = {},
	rust_analyzer = {
		cmd = { "rustup", "run", "stable", "rust-analyzer" },
		settings = {
			["rust-analyzer"] = {
				imports = {
					granularity = {
						group = "module",
					},
					prefix = "self",
				},
				cargo = {
					buildScripts = {
						enable = true,
					},
				},
				procMacro = {
					enable = true,
				},
			},
		},
	},
	yamlls = {
		{
			yaml = {
				schemas = {
					kubernetes = "*.yaml",
					["http://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
					["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
					["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
					["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "*docker-compose*.{yml,yaml}",
				},
			},
		},
	},
	prismals = {
		single_file_support = false,
		root_dir = require("lspconfig.util").root_pattern("schema.prisma"),
		filetypes = {
			"typescript",
			"typescriptreact",
			"javascript",
			"javascriptreact",
			"json",
			"json5",
		},
	},
	templ = {},
	astro = {},
	pyright = {},
}

-- set appearances to differentiate
vim.cmd([[autocmd ColorScheme * highlight NormalFloat guibg=#1f2335]])
vim.cmd([[autocmd ColorScheme * highlight FloatBorder guifg=white guibg=#1f2335]])

local border = {
	{ "▛", "FloatBorder" },
	{ "▔", "FloatBorder" },
	{ "▜", "FloatBorder" },
	{ "▕", "FloatBorder" },
	{ "▟", "FloatBorder" },
	{ "▁", "FloatBorder" },
	{ "▙", "FloatBorder" },
	{ "▏", "FloatBorder" },
}

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

	vim.keymap.set("n", "<Leader>f", function()
		vim.lsp.buf.format({
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end, bufopts)

	vim.keymap.set("n", "<Leader>;", function()
		vim.diagnostic.open_float(nil, { focus = false })
	end, bufopts)

	vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, bufopts)
	vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, bufopts)

	-- apperances
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
end

require("neodev").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure servers are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = vim.tbl_keys(servers),
	automatic_installation = true,
})

mason_lspconfig.setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			single_file_support = (servers[server_name] or {}).single_file_support,
			root_dir = (servers[server_name] or {}).root_dir,
			cmd = (servers[server_name] or {}).cmd,
			settings = (servers[server_name] or {}).settings,
			filetypes = (servers[server_name] or {}).filetypes,
		})
	end,
})

-- Set gutter sign icons
local sign = function(opts)
	vim.fn.sign_define(opts.name, {
		texthl = opts.name,
		text = opts.text,
		numhl = "",
	})
end

sign({ name = "DiagnosticSignError", text = "❌" })
sign({ name = "DiagnosticSignWarn", text = "⚠️" })
sign({ name = "DiagnosticSignHint", text = "💡" })
sign({ name = "DiagnosticSignInfo", text = "ℹ️" })

-- nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "kity" },
		{
			name = "bulma",
			option = {
				filetypes = {
					"templ",
				},
			},
		},
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "path" },
	},
})

-- auto-format and lint

local languages = {
	docker = {
		require("efmls-configs.linters.hadolint"),
	},
	go = {
		require("efmls-configs.formatters.gofmt"),
		require("efmls-configs.linters.golint"),
	},
	html = {
		require("efmls-configs.linters.eslint_d"),
	},
	javascript = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	javascriptreact = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	json = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	lua = {
		require("efmls-configs.formatters.stylua"),
		require("efmls-configs.linters.luacheck"),
	},
	proto = {
	    require("efmls-configs.formatters.protolint"),
	    -- require("efmls-configs.linters.protolint"),
	},
	python = {
		require("efmls-configs.formatters.ruff"),
	},
	rust = {
		require("efmls-configs.formatters.rustfmt"),
	},
	terraform = {
		require("efmls-configs.formatters.terraform_fmt"),
	},
	typescript = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	typescriptreact = {
		require("efmls-configs.formatters.eslint_d"),
		require("efmls-configs.formatters.prettier_d"),
		require("efmls-configs.linters.eslint_d"),
	},
	yaml = {
		require("efmls-configs.linters.yamllint"),
	},
}

require("lspconfig").efm.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		rootMarkers = { ".git/" },
		languages = languages,
	},
	init_options = {
		documentFormatting = true,
		documentRangeFormatting = true,
	},
	filetypes = vim.tbl_keys(languages),
})
